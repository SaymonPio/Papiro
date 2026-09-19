-- CAMADA ILUSTRADA — PIPELINE DE JOBS DOS ASSETS (APPLY REAL — NÃO EXECUTADO)
--
-- Fase Q10.1. Camada de CONTROLE (banco) do pipeline assíncrono de imagens dos
-- quadros de `quadrinho_didatico`. Nenhuma Image API, nenhuma Edge, nenhum
-- Storage aqui: só máquina de estados, contratos de RPC e travas de concorrência.
--
-- Fluxo futuro:
--   admin decide gerar arte  -> criar_jobs_quadrinho_admin
--   worker (Edge, service_role) -> reservar_quadrinho_asset -> [Image API + upload]
--                                  -> concluir_quadrinho_asset | falhar_quadrinho_asset
--   admin revisa            -> aprovar_ | rejeitar_ | regenerar_quadrinho_asset_admin
--   limpeza                 -> preparar_exclusao_ + excluir_quadrinho_asset_admin
--   aluno                   -> carregar_quadrinho_assets_aula (Q9, INALTERADA): só `aprovada`
--                              + scene_hash igual ao hash da cena atual.
--
-- DECISÕES:
--   * FENCING: coluna `claim_token uuid`, gerado a cada reserva. `lease_ate` só
--     mede tempo (recuperação); a IDENTIDADE do dono do job é o token. Worker A
--     que perdeu o lease e termina depois de o worker B reservar tem token
--     antigo => concluir/falhar recusam (aceito=false) sem tocar na linha.
--     O mesmo token faz parte do path do arquivo (<versao>/<componente>/<indice>/
--     <hash10>-<claim_token>.webp): nenhuma tentativa sobrescreve o arquivo de outra.
--     UMA coluna cobre fencing E unicidade de arquivo por geração (sem generation_id).
--   * ARQUIVO ANTERIOR: `storage_path_anterior text` (única outra coluna nova).
--     Com uma linha por (versão, componente, índice), sobrescrever storage_path
--     deixaria o arquivo velho órfão em silêncio. Ao reiniciar um quadro
--     (regenerar / cena mudou) o path atual passa para storage_path_anterior; o
--     arquivo NUNCA é apagado aqui. Nunca é servido (a RPC do aluno só lê
--     storage_path). Um novo arquivamento é RECUSADO enquanto o anterior ainda
--     existir em storage.objects (nunca se perde o ponteiro de um arquivo vivo).
--     A limpeza real (remoção do objeto) é da futura Edge admin/GC.
--   * STATUS: os seis existentes bastam. `erro` = terminal até o admin agir;
--     falha com tentativas restantes volta a `pendente` (retry automático).
--   * TENTATIVAS: contadas na RESERVA (máx. 3, o CHECK da Q9). Regenerar e
--     sincronizar cena mudada abrem novo ciclo (tentativas = 0) — ação
--     deliberada do admin.
--   * LEASE: quadrinho_asset_lease() = 10 minutos, único ponto de ajuste. A
--     finalização de aulas usa 5 min para um trabalho de poucos segundos; a
--     documentação oficial da Image API cita até ~2 min de latência por imagem,
--     então 10 min dá ~5x de margem (geração + conversão + upload) sem deixar um
--     job morto trancado por muito tempo.
--   * Resultado obsoleto NUNCA é aceito: concluir/aprovar/reservar recalculam o
--     hash da cena ATUAL (mesma fonte de verdade da Q9) e comparam com scene_hash.
--   * RPCs de escrita atualizam atualizado_em = now() explicitamente (sem trigger).
--   * Worker RPCs: SÓ service_role (sem execute para public/anon/authenticated).
--     Admin RPCs: authenticated + eh_admin() como primeira instrução.
--
-- NÃO altera: RPC do aluno/admin de leitura da Q9, aulas, aula_versoes, bucket,
-- policies, cron, Vault, Edge. A Q9 (pos_check_camada_ilustrada_base.sql) deixa de
-- refletir a tabela depois deste apply (2 colunas e 2 CHECKs a mais): use o
-- pos-check deste pacote.
--
-- Fail-safe: ABORTA se a fundação Q9 divergir (colunas, definições das 4 funções,
-- bucket), se algo do pacote já existir ou se houver linhas incompatíveis com o
-- novo CHECK. Não sobrescreve nada. Reversão: reverter_camada_ilustrada_pipeline.sql.

begin;

-- >>> SECAO_PRECOND (identica no harness)
do $$
declare
  v_problemas text := '';
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO';
  v_fn record;
begin
  if to_regclass('public.aula_quadrinho_assets') is null then
    raise exception 'PRECOND: fundacao Q9 ausente (public.aula_quadrinho_assets)';
  end if;

  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then
    v_problemas := v_problemas || 'colunas da tabela divergem da fundacao Q9 (' || coalesce(v_colunas, 'nenhuma') || '); ';
  end if;

  if (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') <> 7 then
    v_problemas := v_problemas || 'esperado 7 CHECKs da Q9; ';
  end if;

  -- as 4 funcoes da Q9 devem estar EXATAMENTE como foram validadas no LIVE
  for v_fn in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84')
    ) as t(nome, md5_esperado)
  loop
    if (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) <> 1
       or (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) is distinct from v_fn.md5_esperado then
      v_problemas := v_problemas || 'funcao da Q9 divergente/ausente: ' || v_fn.nome || '; ';
    end if;
  end loop;

  if not exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) then
    v_problemas := v_problemas || 'bucket quadrinhos-aulas divergente/ausente; ';
  end if;
  if to_regprocedure('public.eh_admin()') is null then
    v_problemas := v_problemas || 'public.eh_admin() ausente; ';
  end if;

  -- nada deste pacote pode existir
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets' and column_name in ('claim_token', 'storage_path_anterior')) then
    v_problemas := v_problemas || 'coluna deste pacote ja existe; ';
  end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'criar_jobs_quadrinho_admin', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset',
      'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
      'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar')
  ) then
    v_problemas := v_problemas || 'ja existe funcao com nome reservado deste pacote; ';
  end if;
  if exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname in ('aula_quadrinho_assets_claim_coerente_check', 'aula_quadrinho_assets_path_anterior_check'))
     or to_regclass('public.aula_quadrinho_assets_path_anterior_key') is not null then
    v_problemas := v_problemas || 'constraint/indice deste pacote ja existe; ';
  end if;

  -- linhas existentes precisam caber no novo CHECK (gerando exige token, que ainda nao existe)
  if exists (select 1 from public.aula_quadrinho_assets where status = 'gerando' or lease_ate is not null) then
    v_problemas := v_problemas || 'ha linhas gerando/com lease incompativeis com o novo CHECK; ';
  end if;

  if v_problemas <> '' then
    raise exception 'PRECOND: %', v_problemas;
  end if;
  raise notice 'PRECOND OK: fundacao Q9 intacta, nada do pipeline existe';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
-- ================= 1) COLUNAS E CONSTRAINTS =================
alter table public.aula_quadrinho_assets
  add column claim_token uuid null,
  add column storage_path_anterior text null;

alter table public.aula_quadrinho_assets
  add constraint aula_quadrinho_assets_claim_coerente_check check (
    (status = 'gerando' and claim_token is not null and lease_ate is not null)
    or (status <> 'gerando' and claim_token is null and lease_ate is null)
  ),
  add constraint aula_quadrinho_assets_path_anterior_check check (
    storage_path_anterior is null
    or (length(btrim(storage_path_anterior)) > 0 and storage_path_anterior !~ '(^/|\.\.)' and storage_path_anterior is distinct from storage_path)
  );

create unique index aula_quadrinho_assets_path_anterior_key
  on public.aula_quadrinho_assets (storage_path_anterior)
  where storage_path_anterior is not null;

-- ================= 2) HELPERS INTERNOS (sem execute para clientes) =================
-- Configuração central do lease (único ponto de ajuste).
create function public.quadrinho_asset_lease()
returns interval
language sql
immutable
set search_path to ''
as $$ select interval '10 minutes' $$;

-- Componente quadrinho_didatico (jsonb) de uma versão, ou NULL.
create function public.quadrinho_componente(p_aula_versao_id uuid, p_componente_id uuid)
returns jsonb
language plpgsql
stable
set search_path to ''
as $$
declare
  v_comp jsonb;
begin
  if p_aula_versao_id is null or p_componente_id is null then return null; end if;
  select c.value into v_comp
  from public.aula_versoes av
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(av.estrutura->'componentes') = 'array' then av.estrutura->'componentes' else '[]'::jsonb end
  ) with ordinality as c(value, ord)
  where av.id = p_aula_versao_id
    and jsonb_typeof(c.value) = 'object'
    and lower(c.value->>'id') = p_componente_id::text
    and c.value->>'tipo' = 'quadrinho_didatico'
  order by c.ord
  limit 1;
  return v_comp;
end;
$$;

-- Texto da cena ATUAL (NULL se versão/componente/índice/cena inválidos). O hash
-- dele é, por construção, o mesmo de hash_cena_atual_quadrinho (Q9).
create function public.cena_atual_quadrinho(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint)
returns text
language plpgsql
stable
set search_path to ''
as $$
declare
  v_comp jsonb;
  v_quadro jsonb;
  v_cena text;
begin
  if p_quadro_indice is null or p_quadro_indice < 0 then return null; end if;
  v_comp := public.quadrinho_componente(p_aula_versao_id, p_componente_id);
  if v_comp is null then return null; end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then return null; end if;
  if p_quadro_indice >= jsonb_array_length(v_comp->'quadros') then return null; end if;
  v_quadro := v_comp->'quadros'->(p_quadro_indice::int);
  if jsonb_typeof(v_quadro) is distinct from 'object' then return null; end if;
  if jsonb_typeof(v_quadro->'cena') is distinct from 'string' then return null; end if;
  v_cena := v_quadro->>'cena';
  if length(btrim(v_cena, E' \t\r\n')) = 0 then return null; end if;
  return v_cena;
end;
$$;

-- O objeto existe de fato em storage.objects? (prova de "ainda existe / já removido")
create function public.quadrinho_path_no_storage(p_path text)
returns boolean
language sql
stable
set search_path to ''
as $$
  select p_path is not null and exists (
    select 1 from storage.objects o where o.bucket_id = 'quadrinhos-aulas' and o.name = p_path
  );
$$;

-- Reinicia um quadro (novo ciclo) SEM apagar arquivo: o path atual vai para
-- storage_path_anterior. O chamador já segura o lock da linha. Recusa se o anterior
-- (outro arquivo) ainda existir no Storage — nunca se perde o ponteiro de um
-- arquivo vivo. Devolve o path arquivado (ou NULL).
create function public.quadrinho_asset_reiniciar(p_asset_id uuid, p_scene_hash text)
returns text
language plpgsql
volatile
set search_path to ''
as $$
declare
  v_atual text;
  v_ant text;
begin
  select q.storage_path, q.storage_path_anterior into v_atual, v_ant
  from public.aula_quadrinho_assets q where q.id = p_asset_id;

  if v_atual is not null and v_ant is not null and v_ant is distinct from v_atual and public.quadrinho_path_no_storage(v_ant) then
    raise exception 'LIMPEZA_PENDENTE: o arquivo anterior (%) ainda existe no Storage; remova-o antes de reiniciar este quadro', v_ant;
  end if;

  update public.aula_quadrinho_assets q
  set storage_path_anterior = coalesce(v_atual, q.storage_path_anterior),
      storage_path = null,
      scene_hash = p_scene_hash,
      status = 'pendente',
      tentativas = 0,
      lease_ate = null,
      claim_token = null,
      erro_sanitizado = null,
      aprovado_por = null,
      aprovado_em = null,
      modelo = null,
      prompt_version = null,
      prompt_visual = null,
      atualizado_em = now()
  where q.id = p_asset_id;

  return v_atual;
end;
$$;

-- ================= 3) RPCs ADMIN (authenticated + eh_admin()) =================
-- Cria/sincroniza 1 job por quadro. Idempotente: hash igual => não mexe; hash
-- diferente => reinicia (arquivo anterior arquivado, nunca apagado).
create function public.criar_jobs_quadrinho_admin(p_aula_versao_id uuid, p_componente_id uuid)
returns table (indice smallint, acao text, status_job text, hash_cena text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_comp jsonb;
  v_n int;
  i int;
  v_hash text;
  v_id uuid;
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem criar jobs de arte de quadrinhos';
  end if;
  if not exists (select 1 from public.aula_versoes av where av.id = p_aula_versao_id) then
    raise exception 'Versao de aula nao encontrada';
  end if;
  v_comp := public.quadrinho_componente(p_aula_versao_id, p_componente_id);
  if v_comp is null then
    raise exception 'Componente quadrinho_didatico nao encontrado nesta versao';
  end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then
    raise exception 'Componente sem lista de quadros';
  end if;
  v_n := jsonb_array_length(v_comp->'quadros');
  if v_n < 3 or v_n > 6 then
    raise exception 'O quadrinho deve ter entre 3 e 6 quadros (encontrado %)', v_n;
  end if;
  for i in 0 .. v_n - 1 loop
    if public.cena_atual_quadrinho(p_aula_versao_id, p_componente_id, i::smallint) is null then
      raise exception 'Quadro % sem cena valida', i + 1;
    end if;
  end loop;

  for i in 0 .. v_n - 1 loop
    v_hash := public.hash_cena_quadrinho(public.cena_atual_quadrinho(p_aula_versao_id, p_componente_id, i::smallint));
    v_id := null;
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash)
    values (p_aula_versao_id, p_componente_id, i, v_hash)
    on conflict on constraint aula_quadrinho_assets_chave_key do nothing
    returning id into v_id;

    if v_id is not null then
      indice := i; acao := 'criado'; status_job := 'pendente'; hash_cena := v_hash;
      return next;
      continue;
    end if;

    select q.id, q.scene_hash, q.status, q.lease_ate into v_row
    from public.aula_quadrinho_assets q
    where q.aula_versao_id = p_aula_versao_id and q.componente_id = p_componente_id and q.quadro_indice = i
    for update;

    if v_row.scene_hash = v_hash then
      indice := i; acao := 'inalterado'; status_job := v_row.status; hash_cena := v_hash;
      return next;
      continue;
    end if;

    if v_row.status = 'gerando' and v_row.lease_ate > now() then
      raise exception 'Quadro % esta em geracao (lease ativo); aguarde antes de sincronizar', i + 1;
    end if;
    perform public.quadrinho_asset_reiniciar(v_row.id, v_hash);
    indice := i; acao := 'invalidado'; status_job := 'pendente'; hash_cena := v_hash;
    return next;
  end loop;

  -- linhas antigas fora do array atual: apenas informadas (nunca alteradas aqui)
  for v_row in
    select q.quadro_indice, q.status
    from public.aula_quadrinho_assets q
    where q.aula_versao_id = p_aula_versao_id and q.componente_id = p_componente_id and q.quadro_indice >= v_n
    order by q.quadro_indice
  loop
    indice := v_row.quadro_indice; acao := 'fora_do_array'; status_job := v_row.status; hash_cena := null;
    return next;
  end loop;
  return;
end;
$$;

create function public.aprovar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, data_aprovacao timestamptz)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_hash_atual text;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem aprovar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status <> 'gerada' then
    raise exception 'Somente um asset gerado pode ser aprovado (status atual: %)', v_row.status;
  end if;
  if v_row.storage_path is null then
    raise exception 'Asset gerado sem storage_path';
  end if;
  v_hash_atual := public.hash_cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_hash_atual is distinct from v_row.scene_hash then
    raise exception 'CENA_ALTERADA: a cena mudou depois da geracao; regenere a arte antes de aprovar';
  end if;

  update public.aula_quadrinho_assets q
  set status = 'aprovada', aprovado_por = auth.uid(), aprovado_em = now(), atualizado_em = now()
  where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'aprovada'; data_aprovacao := now();
  return next;
end;
$$;

create function public.rejeitar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, path_atual text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem rejeitar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status not in ('gerada', 'aprovada') then
    raise exception 'Somente um asset gerado ou aprovado pode ser rejeitado (status atual: %)', v_row.status;
  end if;

  -- o arquivo permanece (inspeção/limpeza posterior); só deixa de ser servido
  update public.aula_quadrinho_assets q
  set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now()
  where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'rejeitada'; path_atual := v_row.storage_path;
  return next;
end;
$$;

-- Novo ciclo de geração. Não interfere em job com lease válido. Devolve o path
-- anterior para a futura limpeza segura (nada é apagado aqui).
create function public.regenerar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, hash_cena text, path_anterior text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_hash text;
  v_ant text;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem regenerar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;
  v_hash := public.hash_cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_hash is null then
    raise exception 'A cena atual deste quadro nao existe mais na estrutura; sincronize os jobs do componente';
  end if;

  perform public.quadrinho_asset_reiniciar(p_asset_id, v_hash);
  select q.storage_path_anterior into v_ant from public.aula_quadrinho_assets q where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'pendente'; hash_cena := v_hash; path_anterior := v_ant;
  return next;
end;
$$;

-- Exclusão em 2 fases (banco + Storage não são atômicos):
--   1) preparar_exclusao: tira o asset de circulação (rejeitada) e devolve os paths;
--   2) a Edge admin remove os objetos;
--   3) excluir: só apaga a linha se NENHUM dos paths ainda existir em storage.objects.
create function public.preparar_exclusao_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, path_atual text, path_anterior text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem excluir assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;

  if v_row.status in ('gerada', 'aprovada') then
    update public.aula_quadrinho_assets q
    set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now()
    where q.id = p_asset_id;
    v_row.status := 'rejeitada';
  elsif v_row.status = 'gerando' then
    update public.aula_quadrinho_assets q
    set status = 'erro', erro_sanitizado = 'exclusao solicitada', lease_ate = null, claim_token = null, atualizado_em = now()
    where q.id = p_asset_id;
    v_row.status := 'erro';
  end if;

  asset_id := p_asset_id; status_final := v_row.status; path_atual := v_row.storage_path; path_anterior := v_row.storage_path_anterior;
  return next;
end;
$$;

create function public.excluir_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, excluido boolean)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem excluir assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;
  if public.quadrinho_path_no_storage(v_row.storage_path) then
    raise exception 'ARQUIVO_AINDA_EXISTE: remova % do Storage antes de excluir a linha', v_row.storage_path;
  end if;
  if public.quadrinho_path_no_storage(v_row.storage_path_anterior) then
    raise exception 'ARQUIVO_AINDA_EXISTE: remova % do Storage antes de excluir a linha', v_row.storage_path_anterior;
  end if;

  delete from public.aula_quadrinho_assets q where q.id = p_asset_id;
  asset_id := p_asset_id; excluido := true;
  return next;
end;
$$;

-- ================= 4) RPCs DO WORKER (somente service_role) =================
-- Reserva UM job (pendente, ou gerando com lease expirado) com SKIP LOCKED.
-- Devolve só o necessário à geração: nunca a aula, questões, gabaritos ou dados pessoais.
create function public.reservar_quadrinho_asset(p_aula_versao_id uuid default null)
returns table (
  asset_id uuid,
  aula_versao_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  scene_hash text,
  cena text,
  tentativa smallint,
  claim_token uuid,
  lease_ate timestamptz,
  storage_path_esperado text
)
language plpgsql
volatile
security definer
set search_path to ''
as $$
#variable_conflict use_column
declare
  v_row record;
  v_cena text;
  v_token uuid;
  v_lease_ate timestamptz;
begin
  -- 1) lease expirado sem tentativas restantes: encerra como erro (nunca fica trancado)
  update public.aula_quadrinho_assets q
  set status = 'erro', erro_sanitizado = 'tempo limite excedido sem tentativas restantes',
      lease_ate = null, claim_token = null, atualizado_em = now()
  where q.id in (
    select x.id from public.aula_quadrinho_assets x
    where x.status = 'gerando' and x.lease_ate < now() and x.tentativas >= 3
      and (p_aula_versao_id is null or x.aula_versao_id = p_aula_versao_id)
    for update skip locked
  );

  loop
    select q.* into v_row
    from public.aula_quadrinho_assets q
    where (p_aula_versao_id is null or q.aula_versao_id = p_aula_versao_id)
      and q.tentativas < 3
      and (q.status = 'pendente' or (q.status = 'gerando' and q.lease_ate < now()))
    order by q.criado_em, q.aula_versao_id, q.componente_id, q.quadro_indice
    limit 1
    for update skip locked;

    if not found then return; end if;

    -- nunca gerar para uma cena que mudou (ou sumiu)
    v_cena := public.cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
    if v_cena is null or public.hash_cena_quadrinho(v_cena) is distinct from v_row.scene_hash then
      update public.aula_quadrinho_assets q
      set status = 'erro', erro_sanitizado = 'cena alterada; sincronize os jobs do componente',
          lease_ate = null, claim_token = null, atualizado_em = now()
      where q.id = v_row.id;
      continue;
    end if;

    v_token := gen_random_uuid();
    v_lease_ate := now() + public.quadrinho_asset_lease();
    update public.aula_quadrinho_assets q
    set status = 'gerando', tentativas = q.tentativas + 1, claim_token = v_token, lease_ate = v_lease_ate, atualizado_em = now()
    where q.id = v_row.id;

    asset_id := v_row.id;
    aula_versao_id := v_row.aula_versao_id;
    componente_id := v_row.componente_id;
    quadro_indice := v_row.quadro_indice;
    scene_hash := v_row.scene_hash;
    cena := v_cena;
    tentativa := (v_row.tentativas + 1)::smallint;
    claim_token := v_token;
    lease_ate := v_lease_ate;
    storage_path_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text
      || '/' || left(v_row.scene_hash, 10) || '-' || v_token::text || '.webp';
    return next;
    return;
  end loop;
end;
$$;

-- Conclui a geração. FENCING: só o dono atual do claim_token conclui. Resultado
-- obsoleto (cena mudou) é recusado com aceito=false — o chamador então remove o
-- arquivo que acabou de enviar. Mesmo path já concluído => idempotente.
create function public.concluir_quadrinho_asset(
  p_asset_id uuid, p_claim_token uuid, p_scene_hash text, p_storage_path text,
  p_modelo text, p_prompt_version text, p_prompt_visual text
)
returns table (aceito boolean, motivo text, status_final text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_esperado text;
  v_cena text;
begin
  if p_asset_id is null or p_claim_token is null then
    raise exception 'asset_id e claim_token sao obrigatorios';
  end if;
  if p_storage_path is null or length(btrim(p_storage_path)) = 0 then
    raise exception 'storage_path obrigatorio';
  end if;
  if coalesce(length(btrim(p_modelo)), 0) = 0 or coalesce(length(btrim(p_prompt_version)), 0) = 0 or coalesce(length(btrim(p_prompt_visual)), 0) = 0 then
    raise exception 'modelo, prompt_version e prompt_visual sao obrigatorios (auditoria)';
  end if;
  if length(p_prompt_visual) > 8000 then
    raise exception 'prompt_visual excede 8000 caracteres';
  end if;

  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then
    aceito := false; motivo := 'asset_inexistente'; status_final := null;
    return next; return;
  end if;

  if v_row.status = 'gerada' and v_row.storage_path = p_storage_path then
    aceito := true; motivo := 'ja_concluido'; status_final := 'gerada';
    return next; return;
  end if;
  if v_row.status <> 'gerando' or v_row.claim_token is distinct from p_claim_token then
    aceito := false; motivo := 'claim_invalido'; status_final := v_row.status;
    return next; return;
  end if;

  if p_scene_hash is distinct from v_row.scene_hash then
    raise exception 'scene_hash informado difere do scene_hash do job';
  end if;
  v_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text
    || '/' || left(v_row.scene_hash, 10) || '-' || p_claim_token::text || '.webp';
  if p_storage_path <> v_esperado then
    raise exception 'storage_path fora do padrao esperado para este claim';
  end if;

  v_cena := public.cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_cena is null or public.hash_cena_quadrinho(v_cena) is distinct from v_row.scene_hash then
    update public.aula_quadrinho_assets q
    set status = 'erro', erro_sanitizado = 'cena alterada durante a geracao; sincronize os jobs do componente',
        lease_ate = null, claim_token = null, atualizado_em = now()
    where q.id = p_asset_id;
    aceito := false; motivo := 'cena_alterada'; status_final := 'erro';
    return next; return;
  end if;

  update public.aula_quadrinho_assets q
  set status = 'gerada', storage_path = p_storage_path, modelo = p_modelo, prompt_version = p_prompt_version,
      prompt_visual = p_prompt_visual, lease_ate = null, claim_token = null, erro_sanitizado = null, atualizado_em = now()
  where q.id = p_asset_id;

  aceito := true; motivo := 'concluido'; status_final := 'gerada';
  return next;
end;
$$;

-- Registra falha. FENCING igual ao concluir. Guarda SÓ erro sanitizado (defesa em
-- profundidade: a Edge já sanitiza; aqui se remove chave/Bearer/JWT/base64 e se
-- limita a 300 caracteres). Retry: tentativas < 3 => volta a `pendente`; senão `erro`.
create function public.falhar_quadrinho_asset(p_asset_id uuid, p_claim_token uuid, p_erro text)
returns table (aceito boolean, motivo text, status_final text, tentativas_usadas smallint)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_erro text;
  v_final text;
begin
  if p_asset_id is null or p_claim_token is null then
    raise exception 'asset_id e claim_token sao obrigatorios';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then
    aceito := false; motivo := 'asset_inexistente'; status_final := null; tentativas_usadas := null;
    return next; return;
  end if;
  if v_row.status <> 'gerando' or v_row.claim_token is distinct from p_claim_token then
    aceito := false; motivo := 'claim_invalido'; status_final := v_row.status; tentativas_usadas := v_row.tentativas;
    return next; return;
  end if;

  v_erro := coalesce(nullif(btrim(p_erro), ''), 'erro desconhecido');
  v_erro := regexp_replace(v_erro, 'sk-[A-Za-z0-9_-]{8,}', '[chave]', 'g');
  v_erro := regexp_replace(v_erro, 'Bearer\s+[A-Za-z0-9._~+/=-]+', 'Bearer [token]', 'gi');
  v_erro := regexp_replace(v_erro, 'eyJ[A-Za-z0-9_-]{10,}(\.[A-Za-z0-9_-]+)*', '[jwt]', 'g');
  v_erro := regexp_replace(v_erro, '[A-Za-z0-9+/]{80,}={0,2}', '[dados]', 'g');
  v_erro := regexp_replace(v_erro, '[\r\n]+', ' ', 'g');
  v_erro := left(v_erro, 300);

  v_final := case when v_row.tentativas < 3 then 'pendente' else 'erro' end;
  update public.aula_quadrinho_assets q
  set status = v_final, erro_sanitizado = v_erro, lease_ate = null, claim_token = null, atualizado_em = now()
  where q.id = p_asset_id;

  aceito := true; motivo := 'falha_registrada'; status_final := v_final; tentativas_usadas := v_row.tentativas;
  return next;
end;
$$;

-- ================= 5) GRANTS =================
revoke all on function public.quadrinho_asset_lease() from public, anon, authenticated;
revoke all on function public.quadrinho_componente(uuid, uuid) from public, anon, authenticated;
revoke all on function public.cena_atual_quadrinho(uuid, uuid, smallint) from public, anon, authenticated;
revoke all on function public.quadrinho_path_no_storage(text) from public, anon, authenticated;
revoke all on function public.quadrinho_asset_reiniciar(uuid, text) from public, anon, authenticated;

revoke all on function public.reservar_quadrinho_asset(uuid) from public, anon, authenticated;
revoke all on function public.concluir_quadrinho_asset(uuid, uuid, text, text, text, text, text) from public, anon, authenticated;
revoke all on function public.falhar_quadrinho_asset(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.reservar_quadrinho_asset(uuid) to service_role;
grant execute on function public.concluir_quadrinho_asset(uuid, uuid, text, text, text, text, text) to service_role;
grant execute on function public.falhar_quadrinho_asset(uuid, uuid, text) to service_role;

revoke all on function public.criar_jobs_quadrinho_admin(uuid, uuid) from public, anon;
revoke all on function public.aprovar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.rejeitar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.regenerar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.preparar_exclusao_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.excluir_quadrinho_asset_admin(uuid) from public, anon;
grant execute on function public.criar_jobs_quadrinho_admin(uuid, uuid) to authenticated;
grant execute on function public.aprovar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.rejeitar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.regenerar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.preparar_exclusao_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.excluir_quadrinho_asset_admin(uuid) to authenticated;
-- <<< SECAO_CORPO

-- >>> SECAO_POSCOND (identica no harness)
do $$
declare
  v_rel oid := 'public.aula_quadrinho_assets'::regclass;
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO,claim_token:uuid:YES,storage_path_anterior:text:YES';
  v_fn text;
  v_papel text;
  v_priv text;
  v_q9 record;
begin
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then raise exception 'POSCOND: colunas divergem: %', v_colunas; end if;

  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'c') <> 9 then raise exception 'POSCOND: esperado 9 CHECKs'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and conname = 'aula_quadrinho_assets_claim_coerente_check') then raise exception 'POSCOND: check de claim'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and conname = 'aula_quadrinho_assets_path_anterior_check') then raise exception 'POSCOND: check de path anterior'; end if;
  if not exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets' and indexname = 'aula_quadrinho_assets_path_anterior_key' and indexdef ilike '%UNIQUE%(storage_path_anterior)%WHERE%storage_path_anterior IS NOT NULL%') then
    raise exception 'POSCOND: indice unico parcial de storage_path_anterior';
  end if;

  -- fundacao Q9 intacta
  if not (select relrowsecurity from pg_class where oid = v_rel) then raise exception 'POSCOND: RLS'; end if;
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') then raise exception 'POSCOND: policy na tabela'; end if;
  foreach v_papel in array array['anon', 'authenticated'] loop
    foreach v_priv in array array['select', 'insert', 'update', 'delete', 'truncate', 'references', 'trigger'] loop
      if has_table_privilege(v_papel, v_rel, v_priv) then raise exception 'POSCOND: % tem % direto na tabela', v_papel, v_priv; end if;
    end loop;
  end loop;
  for v_q9 in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84')
    ) as t(nome, md5_esperado)
  loop
    if (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_q9.nome) is distinct from v_q9.md5_esperado then
      raise exception 'POSCOND: funcao da Q9 alterada: %', v_q9.nome;
    end if;
  end loop;
  if not exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) then raise exception 'POSCOND: bucket'; end if;
  if exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') then raise exception 'POSCOND: policy de storage para o bucket'; end if;

  -- helpers: fechados para clientes
  foreach v_fn in array array['public.quadrinho_asset_lease()', 'public.quadrinho_componente(uuid,uuid)', 'public.cena_atual_quadrinho(uuid,uuid,smallint)', 'public.quadrinho_path_no_storage(text)', 'public.quadrinho_asset_reiniciar(uuid,text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa helper %', v_papel, v_fn; end if;
    end loop;
  end loop;

  -- worker: só service_role; SECURITY DEFINER; search_path vazio
  foreach v_fn in array array['public.reservar_quadrinho_asset(uuid)', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)', 'public.falhar_quadrinho_asset(uuid,uuid,text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa RPC de worker %', v_papel, v_fn; end if;
    end loop;
    if not has_function_privilege('service_role', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: service_role sem execute em %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
  end loop;

  -- admin: authenticated (não anon); SECURITY DEFINER; search_path vazio; eh_admin
  foreach v_fn in array array['public.criar_jobs_quadrinho_admin(uuid,uuid)', 'public.aprovar_quadrinho_asset_admin(uuid)', 'public.rejeitar_quadrinho_asset_admin(uuid)', 'public.regenerar_quadrinho_asset_admin(uuid)', 'public.preparar_exclusao_quadrinho_asset_admin(uuid)', 'public.excluir_quadrinho_asset_admin(uuid)'] loop
    if has_function_privilege('anon', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: anon executa %', v_fn; end if;
    if not has_function_privilege('authenticated', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: authenticated sem execute em %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
    if position('public.eh_admin()' in pg_get_functiondef(v_fn::regprocedure)) = 0 then raise exception 'POSCOND: % sem eh_admin()', v_fn; end if;
  end loop;

  if public.quadrinho_asset_lease() <> interval '10 minutes' then raise exception 'POSCOND: lease'; end if;
  raise notice 'POSCOND OK: colunas, CHECKs, indice, funcoes, grants e fundacao Q9 intactos';
end $$;
-- <<< SECAO_POSCOND

commit;
