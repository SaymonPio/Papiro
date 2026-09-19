-- CAMADA ILUSTRADA — FUNDAÇÃO DE DADOS + LEITURA SEGURA (APPLY REAL — NÃO EXECUTADO)
--
-- Fase Q9. Cria a infraestrutura mínima para associar ILUSTRAÇÕES (assets
-- derivados) aos quadros de `quadrinho_didatico`, sem tocar no conteúdo
-- pedagógico canônico (aula_versoes.estrutura) e sem alterar nenhuma aula:
--
--   1. public.aula_quadrinho_assets  — 1 linha por (versão da aula, componente,
--      índice do quadro); RLS ligado e ZERO acesso direto para anon/authenticated
--      (mesmo padrão de aulas, aula_versoes e aula_geracoes).
--   2. public.hash_cena_quadrinho(text)  — hash canônico da cena
--      (SHA-256 hex minúsculo de NFC(trim(cena))). ÚNICA fonte de verdade do
--      scene_hash: quem grava e quem lê usam esta função, nunca JS.
--   3. public.hash_cena_atual_quadrinho(uuid, uuid, smallint)  — hash da cena
--      REAL hoje presente na estrutura (localiza o componente pelo id, exige
--      tipo quadrinho_didatico, lê quadros[indice].cena). Helper interno.
--   4. public.carregar_quadrinho_assets_aula(p_missao_id, p_aula_versao_id)
--      — RPC do ALUNO: mesma autorização EFETIVA de
--      carregar_aula_publicada_da_missao (missão do usuário + matrícula ativa +
--      a versão pedida é exatamente a versão publicada entregue àquela missão).
--      Só devolve assets APROVADOS cujo scene_hash bate com a cena atual.
--   5. public.carregar_quadrinho_assets_admin(p_aula_versao_id)  — RPC do ADMIN
--      (eh_admin()): todos os status, com scene_hash_atual/asset_atual.
--   6. Bucket privado `quadrinhos-aulas` (image/webp, 256 KiB).
--
-- DECISÕES:
--   * NENHUMA policy em storage.objects para este bucket: só service_role
--     (Edge Functions) lê/grava/assina. A assinatura de URLs será server-side,
--     DEPOIS de a RPC do aluno autorizar — a autorização do asset é
--     literalmente a da aula.
--   * Sem FK em componente_id (é um UUID interno do JSON da aula) e sem UUID
--     por quadro (o contrato de quadrinho_didatico não muda).
--   * Sem RPCs de claim/conclusão/aprovação/criação de jobs (fase da pipeline).
--   * Sem trigger de atualizado_em (as futuras RPCs de escrita o definem).
--   * aprovado_por sem FK (auditoria simples; a RPC futura grava auth.uid()).
--   * CHECKs de coerência mínimos: gerada/aprovada exigem storage_path;
--     aprovada exige aprovado_em. Nenhuma máquina de estados rígida.
--   * UNIQUE parcial em storage_path: dois assets nunca compartilham o mesmo
--     arquivo (excluir/regenerar um não pode quebrar outro).
--
-- Fail-safe: ABORTA se já existir a tabela, o bucket, qualquer função com os
-- nomes a criar, policy de storage citando o bucket, ou se a RPC atual de
-- leitura da aula não tiver a autorização esperada. Não sobrescreve nada.
--
-- Todo DDL/DML abaixo (inclusive INSERT em storage.buckets) é transacional;
-- por isso o harness camada_ilustrada_base_teste_rollback.sql prova o pacote
-- inteiro com BEGIN ... ROLLBACK. Reversão: reverter_camada_ilustrada_base.sql.
-- Pós-check: pos_check_camada_ilustrada_base.sql.

begin;

-- >>> SECAO_PRECOND (identica no harness)
do $$
declare
  v_problemas text := '';
  v_def text;
begin
  if to_regclass('public.aula_quadrinho_assets') is not null then
    v_problemas := v_problemas || 'tabela public.aula_quadrinho_assets ja existe; ';
  end if;
  if exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' or name = 'quadrinhos-aulas') then
    v_problemas := v_problemas || 'bucket quadrinhos-aulas ja existe; ';
  end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin')
  ) then
    v_problemas := v_problemas || 'ja existe funcao com nome reservado; ';
  end if;
  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'
  ) then
    v_problemas := v_problemas || 'ja existe policy de storage citando quadrinhos-aulas; ';
  end if;
  if to_regclass('public.aula_versoes') is null then
    v_problemas := v_problemas || 'public.aula_versoes ausente; ';
  end if;
  if to_regprocedure('public.eh_admin()') is null then
    v_problemas := v_problemas || 'public.eh_admin() ausente; ';
  end if;
  if to_regprocedure('public.carregar_aula_publicada_da_missao(uuid)') is null then
    v_problemas := v_problemas || 'carregar_aula_publicada_da_missao(uuid) ausente; ';
  else
    v_def := pg_get_functiondef('public.carregar_aula_publicada_da_missao(uuid)'::regprocedure);
    if position('auth.uid()' in v_def) = 0
       or position('m.usuario_id=v_usuario_id' in v_def) = 0
       or position('m.status=''ativa''' in v_def) = 0
       or position('av.status=''publicada''' in v_def) = 0
       or position('u.curso_conteudo_id=v_conteudo_id' in v_def) = 0 then
      v_problemas := v_problemas || 'autorizacao de carregar_aula_publicada_da_missao mudou — revisar a RPC de assets antes de aplicar; ';
    end if;
  end if;
  if normalize(chr(97) || chr(769), NFC) is distinct from chr(225) then
    v_problemas := v_problemas || 'normalize(..., NFC) indisponivel/incorreto; ';
  end if;
  if v_problemas <> '' then
    raise exception 'PRECOND: %', v_problemas;
  end if;
  raise notice 'PRECOND OK: nada a criar existe; autorizacao da RPC de leitura da aula confere; NFC disponivel';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
-- ================= 1) TABELA =================
create table public.aula_quadrinho_assets (
  id uuid primary key default gen_random_uuid(),
  aula_versao_id uuid not null references public.aula_versoes(id) on delete cascade,
  componente_id uuid not null,
  quadro_indice smallint not null,
  scene_hash text not null,
  status text not null default 'pendente',
  storage_path text null,
  modelo text null,
  prompt_version text null,
  prompt_visual text null,
  tentativas smallint not null default 0,
  lease_ate timestamptz null,
  erro_sanitizado text null,
  aprovado_por uuid null,
  aprovado_em timestamptz null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint aula_quadrinho_assets_chave_key unique (aula_versao_id, componente_id, quadro_indice),
  constraint aula_quadrinho_assets_quadro_indice_check check (quadro_indice between 0 and 5),
  constraint aula_quadrinho_assets_scene_hash_check check (scene_hash ~ '^[0-9a-f]{64}$'),
  constraint aula_quadrinho_assets_status_check check (status in ('pendente', 'gerando', 'gerada', 'aprovada', 'rejeitada', 'erro')),
  constraint aula_quadrinho_assets_tentativas_check check (tentativas between 0 and 3),
  constraint aula_quadrinho_assets_storage_path_check check (storage_path is null or (length(btrim(storage_path)) > 0 and storage_path !~ '(^/|\.\.)')),
  constraint aula_quadrinho_assets_gerada_exige_path_check check (status not in ('gerada', 'aprovada') or storage_path is not null),
  constraint aula_quadrinho_assets_aprovada_exige_data_check check (status <> 'aprovada' or aprovado_em is not null)
);

create unique index aula_quadrinho_assets_storage_path_key
  on public.aula_quadrinho_assets (storage_path)
  where storage_path is not null;

-- RLS ligado e zero acesso direto: escrita só por service_role (Edge) e por
-- RPCs SECURITY DEFINER; leitura só pelas RPCs abaixo. Nenhuma policy.
alter table public.aula_quadrinho_assets enable row level security;
revoke all on table public.aula_quadrinho_assets from public, anon, authenticated;

-- ================= 2) HASH CANONICO DA CENA =================
-- SHA-256 hex minúsculo de NFC(trim(cena)); trim = espaço, tab, CR e LF.
-- IMMUTABLE, sem dependência de usuário/sessão (search_path vazio).
create function public.hash_cena_quadrinho(p_cena text)
returns text
language plpgsql
immutable
set search_path to ''
as $$
declare
  v_norm text;
begin
  if p_cena is null then
    raise exception 'cena nula';
  end if;
  v_norm := normalize(btrim(p_cena, E' \t\r\n'), NFC);
  if length(v_norm) = 0 then
    raise exception 'cena vazia';
  end if;
  return encode(sha256(convert_to(v_norm, 'UTF8')), 'hex');
end;
$$;

-- ================= 3) HASH DA CENA ATUAL NA ESTRUTURA =================
-- Devolve NULL (nunca erro) se a versão/componente não existe, se o
-- componente não é quadrinho_didatico, se o índice está fora do array ou se a
-- cena não é um texto não vazio. Helper interno: sem grant para clientes.
create function public.hash_cena_atual_quadrinho(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint)
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
  if p_aula_versao_id is null or p_componente_id is null or p_quadro_indice is null or p_quadro_indice < 0 then
    return null;
  end if;

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

  if v_comp is null then return null; end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then return null; end if;
  if p_quadro_indice >= jsonb_array_length(v_comp->'quadros') then return null; end if;

  v_quadro := v_comp->'quadros'->(p_quadro_indice::int);
  if jsonb_typeof(v_quadro) is distinct from 'object' then return null; end if;
  if jsonb_typeof(v_quadro->'cena') is distinct from 'string' then return null; end if;

  v_cena := v_quadro->>'cena';
  if length(btrim(v_cena, E' \t\r\n')) = 0 then return null; end if;

  return public.hash_cena_quadrinho(v_cena);
end;
$$;

-- ================= 4) RPC DO ALUNO =================
-- Autorização = a de carregar_aula_publicada_da_missao (mesmas tabelas,
-- mesmos predicados, mesma seleção da versão): auth.uid() obrigatório; a
-- missão precisa ser do usuário com matrícula 'ativa'; a versão acessível é
-- a publicada da primeira unidade ativa do conteúdo da missão. Se
-- p_aula_versao_id NÃO for exatamente essa versão, não retorna nada.
create function public.carregar_quadrinho_assets_aula(p_missao_id uuid, p_aula_versao_id uuid)
returns table (
  asset_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  storage_path text,
  scene_hash text
)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_versao_acessivel uuid;
begin
  v_usuario_id := auth.uid();
  if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;

  select ms.id, ms.conteudo_id into v_missao_id, v_conteudo_id
  from public.missoes ms join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id and m.usuario_id = v_usuario_id and m.status = 'ativa';
  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  select av.id into v_versao_acessivel
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id and u.ativa
  order by u.ordem
  limit 1;

  if v_versao_acessivel is null or p_aula_versao_id is distinct from v_versao_acessivel then
    return;
  end if;

  return query
  select q.id, q.componente_id, q.quadro_indice, q.storage_path, q.scene_hash
  from public.aula_quadrinho_assets q
  where q.aula_versao_id = v_versao_acessivel
    and q.status = 'aprovada'
    and q.storage_path is not null
    and q.scene_hash = public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice)
  order by q.componente_id, q.quadro_indice;
end;
$$;

-- ================= 5) RPC DO ADMIN =================
create function public.carregar_quadrinho_assets_admin(p_aula_versao_id uuid)
returns table (
  id uuid,
  aula_versao_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  scene_hash text,
  scene_hash_atual text,
  asset_atual boolean,
  status text,
  storage_path text,
  modelo text,
  prompt_version text,
  prompt_visual text,
  tentativas smallint,
  erro_sanitizado text,
  aprovado_por uuid,
  aprovado_em timestamptz,
  criado_em timestamptz,
  atualizado_em timestamptz
)
language plpgsql
stable
security definer
set search_path to ''
as $$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem visualizar assets de quadrinhos';
  end if;

  return query
  select q.id, q.aula_versao_id, q.componente_id, q.quadro_indice, q.scene_hash,
    h.hash_atual,
    (h.hash_atual is not null and h.hash_atual = q.scene_hash),
    q.status, q.storage_path, q.modelo, q.prompt_version, q.prompt_visual, q.tentativas,
    q.erro_sanitizado, q.aprovado_por, q.aprovado_em, q.criado_em, q.atualizado_em
  from public.aula_quadrinho_assets q
  cross join lateral (
    select public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice) as hash_atual
  ) h
  where q.aula_versao_id = p_aula_versao_id
  order by q.componente_id, q.quadro_indice;
end;
$$;

-- ================= 6) GRANTS DAS FUNCOES =================
revoke all on function public.hash_cena_quadrinho(text) from public, anon, authenticated;
revoke all on function public.hash_cena_atual_quadrinho(uuid, uuid, smallint) from public, anon, authenticated;
revoke all on function public.carregar_quadrinho_assets_aula(uuid, uuid) from public, anon;
revoke all on function public.carregar_quadrinho_assets_admin(uuid) from public, anon;
grant execute on function public.carregar_quadrinho_assets_aula(uuid, uuid) to authenticated;
grant execute on function public.carregar_quadrinho_assets_admin(uuid) to authenticated;

-- ================= 7) BUCKET PRIVADO =================
-- INSERT simples (a precondição garante que o bucket não existe): nunca
-- reconfigura um bucket alheio. 262144 bytes = 256 KiB. Sem policies.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('quadrinhos-aulas', 'quadrinhos-aulas', false, 262144, array['image/webp']);
-- <<< SECAO_CORPO

-- >>> SECAO_POSCOND (identica no harness)
do $$
declare
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO';
  v_rel oid := 'public.aula_quadrinho_assets'::regclass;
  v_papel text;
  v_priv text;
  v_bucket record;
  v_fn text;
begin
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then raise exception 'POSCOND: colunas divergem: %', v_colunas; end if;

  if not (select relrowsecurity from pg_class where oid = v_rel) then raise exception 'POSCOND: RLS nao habilitado'; end if;
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') then
    raise exception 'POSCOND: nao deveria haver policy na tabela';
  end if;

  foreach v_papel in array array['anon', 'authenticated'] loop
    foreach v_priv in array array['select', 'insert', 'update', 'delete', 'truncate', 'references', 'trigger'] loop
      if has_table_privilege(v_papel, v_rel, v_priv) then raise exception 'POSCOND: % tem % direto na tabela', v_papel, v_priv; end if;
    end loop;
  end loop;

  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'p') <> 1 then raise exception 'POSCOND: PK'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and contype = 'f' and confrelid = 'public.aula_versoes'::regclass and confdeltype = 'c') then
    raise exception 'POSCOND: FK aula_versao_id -> aula_versoes ON DELETE CASCADE';
  end if;
  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'f') <> 1 then raise exception 'POSCOND: deveria haver apenas 1 FK'; end if;
  if not exists (
    select 1 from pg_constraint c where c.conrelid = v_rel and c.contype = 'u' and c.conname = 'aula_quadrinho_assets_chave_key'
      and (select array_agg(a.attname::text order by k.ord) from unnest(c.conkey) with ordinality k(attnum, ord) join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum)
          = array['aula_versao_id', 'componente_id', 'quadro_indice']
  ) then raise exception 'POSCOND: UNIQUE (aula_versao_id, componente_id, quadro_indice)'; end if;
  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'c') <> 7 then raise exception 'POSCOND: esperado 7 CHECKs'; end if;
  if not exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets' and indexname = 'aula_quadrinho_assets_storage_path_key' and indexdef ilike '%UNIQUE%(storage_path)%WHERE%storage_path IS NOT NULL%') then
    raise exception 'POSCOND: indice unico parcial de storage_path';
  end if;

  foreach v_fn in array array['public.hash_cena_quadrinho(text)', 'public.hash_cena_atual_quadrinho(uuid,uuid,smallint)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % nao deveria executar %', v_papel, v_fn; end if;
    end loop;
  end loop;
  foreach v_fn in array array['public.carregar_quadrinho_assets_aula(uuid,uuid)', 'public.carregar_quadrinho_assets_admin(uuid)'] loop
    if has_function_privilege('anon', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: anon executa %', v_fn; end if;
    if not has_function_privilege('authenticated', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: authenticated nao executa %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
  end loop;

  select id, name, public, file_size_limit, allowed_mime_types into v_bucket from storage.buckets where id = 'quadrinhos-aulas';
  if v_bucket.id is null then raise exception 'POSCOND: bucket ausente'; end if;
  if v_bucket.public is distinct from false then raise exception 'POSCOND: bucket deveria ser privado'; end if;
  if v_bucket.file_size_limit is distinct from 262144 then raise exception 'POSCOND: limite do bucket'; end if;
  if v_bucket.allowed_mime_types is distinct from array['image/webp'] then raise exception 'POSCOND: MIME do bucket'; end if;
  if exists (
    select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'
  ) then raise exception 'POSCOND: nao deveria existir policy de storage para quadrinhos-aulas'; end if;

  -- vetores de teste do hash: 'abc' (vetor publico SHA-256), trim e NFC equivalentes
  if public.hash_cena_quadrinho('abc') <> 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad' then raise exception 'POSCOND: vetor SHA-256 de abc'; end if;
  if public.hash_cena_quadrinho('  Teste ' || E'\n') <> public.hash_cena_quadrinho('Teste') then raise exception 'POSCOND: trim'; end if;
  if public.hash_cena_quadrinho('Jos' || chr(233)) <> public.hash_cena_quadrinho('Jose' || chr(769)) then raise exception 'POSCOND: NFC composto x decomposto'; end if;

  raise notice 'POSCOND OK: tabela, constraints, RLS, revokes, funcoes, grants, bucket privado e hash conferem';
end $$;
-- <<< SECAO_POSCOND

commit;
