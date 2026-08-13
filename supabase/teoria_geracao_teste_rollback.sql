-- ============================================================================
-- TESTE RUNTIME COMPLETO DA FASE 2J-A — TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Cobre as 3 migrations novas desta fase:
--   - supabase/materiais_teoria_storage.sql (bucket + policies)
--   - supabase/aula_geracoes.sql (tabela de trava/auditoria de geração)
--   - supabase/teoria_geracao_admin_rpc.sql (5 RPCs administrativas)
--
-- Mesma técnica de simulação de auth.uid() já usada nos harnesses das
-- Fases 2F/2I: set_config de request.jwt.claims + SET LOCAL ROLE, ambos
-- "local" à transação, desfeitos automaticamente no ROLLBACK final. NÃO
-- insere em auth.users.
--
-- public.eh_admin() já existe no banco real e NÃO é definida em SQL
-- versionado neste repositório (mesmo aviso já documentado em
-- cursos_matriculas.sql) — este harness NÃO pode criar um admin do zero.
-- Em vez disso, procura um usuário real para quem eh_admin() já retorna
-- true, impersonando (via a mesma técnica de request.jwt.claims) até 50
-- usuários reais de auth.users, um de cada vez, na ordem de criação, e
-- parando no primeiro que for admin. Se nenhum for encontrado (ambiente
-- sem nenhum admin ainda ativado via "Ativar minha área administrativa"
-- em /admin), os testes que dependem de um admin real ficam NULL + NOTICE
-- — nunca inventa/promove um usuário a admin.
--
-- public.aulas tem UNIQUE(conteudo_id): os cenários que criam uma
-- aula_versao de teste usam um curso_conteudos livre (sem aula), mesmo
-- padrão de descoberta já usado nos harnesses das Fases 2F/2I.

BEGIN;

create temporary table teste_2ja_contexto (
  chave text primary key,
  valor text
);

create temporary table teste_2ja_resultados (
  chave text primary key,
  ok boolean
);

-- ============================================================================
-- Contexto: matrícula ativa real, curso, duas curso_materias reais com
-- conteúdo (para o teste de isolamento), um conteúdo livre (sem aula, para
-- o teste de rascunho/fontes), e um usuário admin real (se existir).
-- ============================================================================
do $$
declare
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_curso_id uuid;
  v_materia_a bigint;
  v_materia_b bigint;
  v_conteudo_livre bigint;
  v_admin_usuario_id uuid;
  v_candidato uuid;
begin
  select m.id, m.usuario_id, m.curso_id
  into v_matricula_id, v_usuario_id, v_curso_id
  from public.matriculas m
  where m.status = 'ativa'
  order by m.id
  limit 1;

  if v_matricula_id is null then
    raise exception 'Teste abortado: nenhuma matricula ativa real encontrada.';
  end if;

  select cm.id into v_materia_a
  from public.curso_materias cm
  where cm.curso_id = v_curso_id
    and exists (select 1 from public.curso_conteudos cc where cc.curso_materia_id = cm.id)
  order by cm.id
  limit 1;

  select cm.id into v_materia_b
  from public.curso_materias cm
  where cm.curso_id = v_curso_id
    and cm.id <> coalesce(v_materia_a, 0)
    and exists (select 1 from public.curso_conteudos cc where cc.curso_materia_id = cm.id)
  order by cm.id
  limit 1;

  if v_materia_a is null then
    raise exception 'Teste abortado: nenhuma curso_materia com conteudo encontrada para o curso da matricula de teste.';
  end if;

  select cc.id into v_conteudo_livre
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cm.curso_id = v_curso_id
    and not exists (select 1 from public.aulas a where a.conteudo_id = cc.id)
  order by cc.id
  limit 1;

  -- Procura um admin real (nunca cria um). Impersonação temporária,
  -- desfeita a cada iteração via reset role.
  for v_candidato in select id from auth.users order by created_at limit 50 loop
    perform set_config('request.jwt.claims', json_build_object('sub', v_candidato::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    if public.eh_admin() then
      v_admin_usuario_id := v_candidato;
    end if;
    reset role;
    exit when v_admin_usuario_id is not null;
  end loop;

  insert into teste_2ja_contexto (chave, valor) values
    ('matricula_id', v_matricula_id::text),
    ('usuario_id', v_usuario_id::text),
    ('curso_id', v_curso_id::text),
    ('materia_a', v_materia_a::text),
    ('materia_b', coalesce(v_materia_b::text, '')),
    ('conteudo_livre', coalesce(v_conteudo_livre::text, '')),
    ('admin_usuario_id', coalesce(v_admin_usuario_id::text, ''));
end $$;

-- ============================================================================
-- CORPO DAS 3 MIGRATIONS (idêntico aos arquivos reais, sem os COMMIT finais)
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('materiais-teoria', 'materiais-teoria', false, 26214400, array['application/pdf'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Administrador envia materiais da teoria" on storage.objects;
create policy "Administrador envia materiais da teoria"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'materiais-teoria' and public.eh_admin());

drop policy if exists "Administrador acessa materiais da teoria" on storage.objects;
create policy "Administrador acessa materiais da teoria"
  on storage.objects for select to authenticated
  using (bucket_id = 'materiais-teoria' and public.eh_admin());

drop policy if exists "Administrador exclui materiais da teoria" on storage.objects;
create policy "Administrador exclui materiais da teoria"
  on storage.objects for delete to authenticated
  using (bucket_id = 'materiais-teoria' and public.eh_admin());

create table public.aula_geracoes (
  id uuid primary key default gen_random_uuid(),
  conteudo_id bigint not null references public.curso_conteudos(id) on delete restrict,
  status text not null default 'processando' check (status in ('processando', 'concluida', 'erro')),
  criado_por uuid not null references auth.users(id) on delete restrict,
  prompt_version text not null,
  modelo text null,
  contexto jsonb not null default '{}'::jsonb check (jsonb_typeof(contexto) = 'object'),
  tokens_entrada integer null check (tokens_entrada is null or tokens_entrada >= 0),
  tokens_saida integer null check (tokens_saida is null or tokens_saida >= 0),
  aula_versao_id uuid null references public.aula_versoes(id) on delete restrict,
  erro text null,
  iniciado_em timestamptz not null default now(),
  finalizado_em timestamptz null,
  criado_em timestamptz not null default now()
);

create unique index aula_geracoes_uma_processando_idx
  on public.aula_geracoes (conteudo_id)
  where status = 'processando';

create index aula_geracoes_conteudo_id_idx
  on public.aula_geracoes (conteudo_id);

alter table public.aula_geracoes enable row level security;
revoke all on public.aula_geracoes from anon, authenticated;

create function public.listar_conteudos_curso_admin(p_curso_materia_id bigint)
returns table (
  conteudo_id bigint,
  assunto_id bigint,
  nome text,
  ordem integer,
  relevante_para_preparacao boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar conteudos para geracao de aula';
  end if;

  return query
  select
    cc.id,
    cc.assunto_id,
    coalesce(a.nome, 'Conteúdo sem nome'),
    cc.ordem,
    cc.relevante_para_preparacao
  from public.curso_conteudos cc
  left join public.assuntos a on a.id = cc.assunto_id
  where cc.curso_materia_id = p_curso_materia_id
  order by cc.ordem;
end;
$function$;

revoke execute on function public.listar_conteudos_curso_admin(bigint) from public;
revoke execute on function public.listar_conteudos_curso_admin(bigint) from anon;
grant execute on function public.listar_conteudos_curso_admin(bigint) to authenticated;

create function public.registrar_material_pdf_admin(
  p_material_id uuid,
  p_titulo text,
  p_tipo text,
  p_descricao text,
  p_titulo_versao text,
  p_arquivo_path text,
  p_checksum text
)
returns table (
  material_id uuid,
  material_versao_id uuid,
  numero_versao integer
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_material_id uuid;
  v_proximo_numero integer;
  v_versao_id uuid;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem registrar materiais da teoria';
  end if;

  if p_arquivo_path is null or btrim(p_arquivo_path) = '' then
    raise exception 'arquivo_path e obrigatorio';
  end if;

  if p_arquivo_path like '%://%' then
    raise exception 'arquivo_path deve ser o caminho do objeto dentro do bucket materiais-teoria, nunca uma URL';
  end if;

  if not exists (
    select 1 from storage.objects
    where bucket_id = 'materiais-teoria' and name = p_arquivo_path
  ) then
    raise exception 'Nenhum arquivo encontrado em materiais-teoria com o caminho informado (%); faca o upload antes de registrar o material', p_arquivo_path;
  end if;

  if p_material_id is null then
    if p_titulo is null or btrim(p_titulo) = '' then
      raise exception 'titulo e obrigatorio para criar um novo material';
    end if;
    if p_tipo is null or btrim(p_tipo) = '' then
      raise exception 'tipo e obrigatorio para criar um novo material';
    end if;

    insert into public.materiais (titulo, tipo, descricao)
    values (btrim(p_titulo), btrim(p_tipo), nullif(btrim(coalesce(p_descricao, '')), ''))
    returning id into v_material_id;
  else
    select id into v_material_id from public.materiais where id = p_material_id;
    if v_material_id is null then
      raise exception 'Material % nao encontrado', p_material_id;
    end if;
  end if;

  select coalesce(max(mv.numero_versao), 0) + 1
  into v_proximo_numero
  from public.material_versoes mv
  where mv.material_id = v_material_id;

  insert into public.material_versoes (material_id, numero_versao, titulo_versao, arquivo_path, checksum)
  values (v_material_id, v_proximo_numero, nullif(btrim(coalesce(p_titulo_versao, '')), ''), p_arquivo_path, p_checksum)
  returning id into v_versao_id;

  return query select v_material_id, v_versao_id, v_proximo_numero;
end;
$function$;

revoke execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) from public;
revoke execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) from anon;
grant execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) to authenticated;

create function public.listar_materiais_admin()
returns table (
  material_id uuid,
  titulo text,
  tipo text,
  ativo boolean,
  ultima_versao_id uuid,
  ultimo_numero_versao integer,
  ultima_versao_titulo text
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar materiais da teoria';
  end if;

  return query
  select
    m.id,
    m.titulo,
    m.tipo,
    m.ativo,
    mv.id,
    mv.numero_versao,
    mv.titulo_versao
  from public.materiais m
  left join lateral (
    select mvv.id, mvv.numero_versao, mvv.titulo_versao
    from public.material_versoes mvv
    where mvv.material_id = m.id
    order by mvv.numero_versao desc
    limit 1
  ) mv on true
  order by m.criado_em desc;
end;
$function$;

revoke execute on function public.listar_materiais_admin() from public;
revoke execute on function public.listar_materiais_admin() from anon;
grant execute on function public.listar_materiais_admin() to authenticated;

create function public.listar_geracoes_conteudo_admin(p_conteudo_id bigint)
returns table (
  geracao_id uuid,
  status text,
  iniciado_em timestamptz,
  finalizado_em timestamptz,
  aula_versao_id uuid,
  erro text,
  prompt_version text,
  modelo text
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem consultar geracoes de aula';
  end if;

  return query
  select
    g.id,
    g.status,
    g.iniciado_em,
    g.finalizado_em,
    g.aula_versao_id,
    g.erro,
    g.prompt_version,
    g.modelo
  from public.aula_geracoes g
  where g.conteudo_id = p_conteudo_id
  order by g.iniciado_em desc;
end;
$function$;

revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from public;
revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from anon;
grant execute on function public.listar_geracoes_conteudo_admin(bigint) to authenticated;

create function public.carregar_aula_rascunho_admin(p_aula_versao_id uuid)
returns table (
  aula_id uuid,
  aula_titulo text,
  aula_versao_id uuid,
  numero_versao integer,
  status text,
  estrutura jsonb,
  criado_em timestamptz,
  publicado_em timestamptz,
  fontes jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem visualizar rascunhos de aula';
  end if;

  return query
  select
    a.id,
    a.titulo,
    av.id,
    av.numero_versao,
    av.status,
    av.estrutura,
    av.criado_em,
    av.publicado_em,
    coalesce(f.fontes, '[]'::jsonb) as fontes
  from public.aula_versoes av
  join public.aulas a on a.id = av.aula_id
  left join lateral (
    select jsonb_agg(
      jsonb_build_object(
        'material_id', mv.material_id,
        'material_titulo', mat.titulo,
        'material_tipo', mat.tipo,
        'material_versao_id', mv.id,
        'numero_versao', mv.numero_versao,
        'titulo_versao', mv.titulo_versao,
        'ordem', avf.ordem,
        'observacao', avf.observacao
      )
      order by avf.ordem nulls last, mv.numero_versao, mv.id
    ) as fontes
    from public.aula_versao_fontes avf
    join public.material_versoes mv on mv.id = avf.material_versao_id
    join public.materiais mat on mat.id = mv.material_id
    where avf.aula_versao_id = av.id
  ) f on true
  where av.id = p_aula_versao_id;
end;
$function$;

revoke execute on function public.carregar_aula_rascunho_admin(uuid) from public;
revoke execute on function public.carregar_aula_rascunho_admin(uuid) from anon;
grant execute on function public.carregar_aula_rascunho_admin(uuid) to authenticated;

-- ============================================================================
-- FIM DO CORPO DAS MIGRATIONS — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Estrutura: bucket, policies, tabela, índice, RPCs.
-- ---------------------------------------------------------------------------
insert into teste_2ja_resultados values (
  'bucket_materiais_teoria_existe',
  exists (select 1 from storage.buckets where id = 'materiais-teoria')
);

insert into teste_2ja_resultados values (
  'bucket_materiais_teoria_privado',
  exists (select 1 from storage.buckets where id = 'materiais-teoria' and public = false)
);

insert into teste_2ja_resultados values (
  'storage_policies_existem',
  (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects'
    and policyname in ('Administrador envia materiais da teoria', 'Administrador acessa materiais da teoria', 'Administrador exclui materiais da teoria')) = 3
);

insert into teste_2ja_resultados values (
  'tabela_aula_geracoes_existe',
  exists (select 1 from pg_tables where schemaname = 'public' and tablename = 'aula_geracoes')
);

insert into teste_2ja_resultados values (
  'indice_unico_processando_existe',
  exists (
    select 1 from pg_indexes
    where schemaname = 'public' and tablename = 'aula_geracoes' and indexname = 'aula_geracoes_uma_processando_idx'
  )
);

insert into teste_2ja_resultados values (
  'rpcs_existem',
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'listar_conteudos_curso_admin', 'registrar_material_pdf_admin', 'listar_materiais_admin',
      'listar_geracoes_conteudo_admin', 'carregar_aula_rascunho_admin'
    )) = 5
);

insert into teste_2ja_resultados values (
  'authenticated_pode_executar_rpcs',
  has_function_privilege('authenticated', 'public.listar_conteudos_curso_admin(bigint)', 'EXECUTE')
  and has_function_privilege('authenticated', 'public.registrar_material_pdf_admin(uuid,text,text,text,text,text,text)', 'EXECUTE')
  and has_function_privilege('authenticated', 'public.listar_materiais_admin()', 'EXECUTE')
  and has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  and has_function_privilege('authenticated', 'public.carregar_aula_rascunho_admin(uuid)', 'EXECUTE')
);

insert into teste_2ja_resultados values (
  'anon_nao_pode_executar_rpcs',
  not has_function_privilege('anon', 'public.listar_conteudos_curso_admin(bigint)', 'EXECUTE')
  and not has_function_privilege('anon', 'public.registrar_material_pdf_admin(uuid,text,text,text,text,text,text)', 'EXECUTE')
  and not has_function_privilege('anon', 'public.listar_materiais_admin()', 'EXECUTE')
  and not has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  and not has_function_privilege('anon', 'public.carregar_aula_rascunho_admin(uuid)', 'EXECUTE')
);

-- ---------------------------------------------------------------------------
-- Usuário comum (não-admin) bloqueado em cada RPC.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_admin_id text;
  v_bloqueado boolean;
begin
  select valor::uuid into v_usuario_id from teste_2ja_contexto where chave = 'usuario_id';
  select valor into v_admin_id from teste_2ja_contexto where chave = 'admin_usuario_id';

  if v_admin_id is not null and v_admin_id <> '' and v_admin_id = v_usuario_id::text then
    insert into teste_2ja_resultados values ('usuario_comum_bloqueado_listar_conteudos', null);
    insert into teste_2ja_resultados values ('usuario_comum_bloqueado_registrar_material', null);
    insert into teste_2ja_resultados values ('usuario_comum_bloqueado_carregar_rascunho', null);
    raise notice 'Testes de "usuario comum bloqueado" pulados: o unico usuario real disponivel de contexto tambem e o admin encontrado.';
    return;
  end if;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.listar_conteudos_curso_admin(1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_listar_conteudos', v_bloqueado);

  begin
    perform * from public.registrar_material_pdf_admin(null, 'x', 'pdf', null, null, 'x/y.pdf', null);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_registrar_material', v_bloqueado);

  begin
    perform * from public.carregar_aula_rascunho_admin(gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_carregar_rascunho', v_bloqueado);

  reset role;
exception when others then
  reset role;
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_listar_conteudos', false);
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_registrar_material', false);
  insert into teste_2ja_resultados values ('usuario_comum_bloqueado_carregar_rascunho', false);
  raise notice 'Testes de usuario comum bloqueado falharam: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- anon bloqueado (reforço dinâmico em cima de uma RPC de leitura).
-- ---------------------------------------------------------------------------
do $$
declare
  v_bloqueado boolean := false;
begin
  set local role anon;
  begin
    perform * from public.listar_materiais_admin();
    v_bloqueado := false;
  exception
    when insufficient_privilege then v_bloqueado := true;
    when others then v_bloqueado := false;
  end;
  reset role;

  update teste_2ja_resultados set ok = (coalesce(ok, true) and v_bloqueado) where chave = 'anon_nao_pode_executar_rpcs';
exception when others then
  reset role;
  update teste_2ja_resultados set ok = false where chave = 'anon_nao_pode_executar_rpcs';
  raise notice 'Reforco live de anon_nao_pode_executar_rpcs falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Admin real, BLOCO 1: listar_conteudos_curso_admin (não depende de
-- Storage/materiais). Isolado num DO próprio de propósito: uma falha aqui
-- não pode mascarar nem ser mascarada pelos blocos de materiais/rascunho a
-- seguir — cada bloco agora tem seu próprio diagnóstico e não compartilha
-- um único catch-all genérico com os outros.
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_admin_usuario_id uuid;
  v_materia_a bigint;
  v_materia_b text;
  v_conteudos_a integer;
  v_conteudos_b_vazando integer;
  v_ok_lista boolean;
  v_ok_isola boolean;
begin
  select valor into v_admin_id from teste_2ja_contexto where chave = 'admin_usuario_id';
  select valor::bigint into v_materia_a from teste_2ja_contexto where chave = 'materia_a';
  select valor into v_materia_b from teste_2ja_contexto where chave = 'materia_b';

  if v_admin_id is null or v_admin_id = '' then
    insert into teste_2ja_resultados values ('admin_pode_listar_conteudos', null), ('listar_conteudos_isola_por_curso_materia', null);
    raise notice '[admin_pode_listar_conteudos/listar_conteudos_isola_por_curso_materia] pulados: nenhum admin real encontrado neste banco (nenhum ainda ativado via /admin).';
    return;
  end if;

  v_admin_usuario_id := v_admin_id::uuid;
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select count(*) into v_conteudos_a from public.listar_conteudos_curso_admin(v_materia_a);
  v_ok_lista := (v_conteudos_a >= 0);

  if v_materia_b is not null and v_materia_b <> '' then
    select count(*) into v_conteudos_b_vazando
    from public.listar_conteudos_curso_admin(v_materia_a)
    where conteudo_id in (select cc.id from public.curso_conteudos cc where cc.curso_materia_id = v_materia_b::bigint);
    v_ok_isola := (v_conteudos_b_vazando = 0);
  else
    v_ok_isola := null;
  end if;

  reset role;
  -- Só grava os resultados depois de terminar todo o trabalho arriscado —
  -- evita inserir 'admin_pode_listar_conteudos' aqui e o catch-all tentar
  -- inserir a MESMA chave de novo (violaria a PK da tabela temporária).
  insert into teste_2ja_resultados values ('admin_pode_listar_conteudos', v_ok_lista);
  insert into teste_2ja_resultados values ('listar_conteudos_isola_por_curso_materia', v_ok_isola);
exception when others then
  reset role;
  insert into teste_2ja_resultados values ('admin_pode_listar_conteudos', false);
  insert into teste_2ja_resultados values ('listar_conteudos_isola_por_curso_materia', false);
  raise notice '[admin_pode_listar_conteudos/listar_conteudos_isola_por_curso_materia] falharam: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Admin real, BLOCO 2: registrar_material_pdf_admin (cria material+versão,
-- incrementa versão, e os 4 testes de integridade de arquivo). As fixtures
-- de storage.objects são criadas dentro de um BEGIN/EXCEPTION próprio,
-- separado do resto: se o INSERT nessas fixtures falhar (por exemplo, por
-- alguma coluna/trigger do schema REAL de storage.objects não coberta por
-- este INSERT mínimo — não confirmável sem executar no banco), o NOTICE
-- abaixo aponta exatamente para isso, em vez de um erro genérico
-- "testes de admin falharam" que obrigaria a adivinhar de novo.
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_admin_usuario_id uuid;
  v_material_id uuid;
  v_versao1_id uuid;
  v_versao2_id uuid;
  v_numero1 integer;
  v_numero2 integer;
  v_total_materiais_antes integer;
  v_total_materiais_depois integer;
  v_total_versoes_antes integer;
  v_total_versoes_depois integer;
  v_ok_fixture1 boolean := false;
  v_ok_fixture2 boolean := false;
  v_ok_fixture_outro_bucket boolean := false;
  v_ok_registrar boolean := false;
  v_ok_incrementa boolean;
  v_ok_lista_materiais boolean := false;
  v_ok_inexistente_bloqueado boolean := false;
  v_ok_inexistente_nao_material boolean := false;
  v_ok_inexistente_nao_versao boolean := false;
  v_ok_outro_bucket boolean;
begin
  select valor into v_admin_id from teste_2ja_contexto where chave = 'admin_usuario_id';

  if v_admin_id is null or v_admin_id = '' then
    insert into teste_2ja_resultados values
      ('admin_pode_registrar_material', null),
      ('registrar_material_incrementa_versao', null),
      ('admin_pode_listar_materiais', null),
      ('registrar_material_arquivo_inexistente_bloqueado', null),
      ('registrar_material_arquivo_inexistente_nao_cria_material', null),
      ('registrar_material_arquivo_inexistente_nao_cria_versao', null),
      ('registrar_material_outro_bucket_bloqueado', null);
    raise notice '[registrar_material_pdf_admin] grupo pulado: nenhum admin real encontrado neste banco.';
    return;
  end if;

  v_admin_usuario_id := v_admin_id::uuid;

  -- Fixtures em storage.objects — feitas como dono da transação (nenhum
  -- SET LOCAL ROLE ativo ainda neste ponto). Cada uma com seu próprio
  -- boolean + NOTICE: um teste cuja fixture não existe fica NULL, nunca
  -- FALSE como se a RPC tivesse errado algo.
  begin
    insert into storage.objects (bucket_id, name) values ('materiais-teoria', '2ja-teste/v1.pdf');
    v_ok_fixture1 := true;
    raise notice '[fixture storage.objects v1] OK.';
  exception when others then
    v_ok_fixture1 := false;
    raise notice '[fixture storage.objects v1] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
  end;

  begin
    insert into storage.objects (bucket_id, name) values ('materiais-teoria', '2ja-teste/v2.pdf');
    v_ok_fixture2 := true;
    raise notice '[fixture storage.objects v2] OK.';
  exception when others then
    v_ok_fixture2 := false;
    raise notice '[fixture storage.objects v2] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
  end;

  begin
    insert into storage.objects (bucket_id, name) values ('editais', '2ja-teste/outro-bucket.pdf');
    v_ok_fixture_outro_bucket := true;
    raise notice '[fixture storage.objects outro bucket] OK.';
  exception when others then
    v_ok_fixture_outro_bucket := false;
    raise notice '[fixture storage.objects outro bucket] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
  end;

  if not v_ok_fixture1 then
    insert into teste_2ja_resultados values
      ('admin_pode_registrar_material', null),
      ('registrar_material_incrementa_versao', null),
      ('admin_pode_listar_materiais', null),
      ('registrar_material_arquivo_inexistente_bloqueado', null),
      ('registrar_material_arquivo_inexistente_nao_cria_material', null),
      ('registrar_material_arquivo_inexistente_nao_cria_versao', null),
      ('registrar_material_outro_bucket_bloqueado', null);
    return;
  end if;

  -- PASSO 2: chamada válida de registrar_material_pdf_admin (cria material
  -- novo + versão "v1"). SET LOCAL ROLE só envolve a CHAMADA da RPC —
  -- nunca as verificações diretas de tabela, que vêm depois de RESET ROLE.
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  begin
    select material_id, material_versao_id, numero_versao
    into v_material_id, v_versao1_id, v_numero1
    from public.registrar_material_pdf_admin(
      null, '[TESTE FASE 2J-A] Material de teste', 'pdf', 'material de teste', 'v1', '2ja-teste/v1.pdf', 'checksum1'
    );
    v_ok_registrar := (v_material_id is not null and v_numero1 = 1);
    raise notice '[PASSO 2: registrar_material_pdf_admin, material novo] OK: material_id=%, material_versao_id=%, numero_versao=%', v_material_id, v_versao1_id, v_numero1;
  exception when others then
    v_ok_registrar := false;
    raise notice '[PASSO 2: registrar_material_pdf_admin, material novo] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
  end;
  reset role;

  -- PASSO 3: consulta posterior em public.materiais — como DONO da
  -- transação (authenticated não tem SELECT direto nessa tabela de
  -- propósito; testar isso sob authenticated derrubaria o teste por
  -- insufficient_privilege, não por um problema real da RPC). Só
  -- diagnóstico — não redefine o critério de admin_pode_registrar_material,
  -- que continua sendo o retorno da própria RPC no PASSO 2.
  if v_material_id is not null then
    begin
      if exists (select 1 from public.materiais where id = v_material_id) then
        raise notice '[PASSO 3: SELECT em public.materiais] OK: linha encontrada para material_id=%', v_material_id;
      else
        raise notice '[PASSO 3: SELECT em public.materiais] linha NAO encontrada para material_id=% (a RPC retornou um id que nao persistiu)', v_material_id;
      end if;
    exception when others then
      raise notice '[PASSO 3: SELECT em public.materiais] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
    end;
  else
    raise notice '[PASSO 3: SELECT em public.materiais] pulado: PASSO 2 nao retornou material_id.';
  end if;

  -- PASSO 4: consulta posterior em public.material_versoes — idem, como
  -- dono da transação, só diagnóstico.
  if v_versao1_id is not null then
    begin
      if exists (select 1 from public.material_versoes where id = v_versao1_id) then
        raise notice '[PASSO 4: SELECT em public.material_versoes] OK: linha encontrada para material_versao_id=%', v_versao1_id;
      else
        raise notice '[PASSO 4: SELECT em public.material_versoes] linha NAO encontrada para material_versao_id=% (a RPC retornou um id que nao persistiu)', v_versao1_id;
      end if;
    exception when others then
      raise notice '[PASSO 4: SELECT em public.material_versoes] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
    end;
  else
    raise notice '[PASSO 4: SELECT em public.material_versoes] pulado: PASSO 2 nao retornou material_versao_id.';
  end if;

  -- Incrementa versão (2ª chamada, mesmo material) — precisa do PASSO 2
  -- (material_id) E da fixture v2. Sem a fixture v2, o resultado fica NULL
  -- (não testável), nunca FALSE, porque a causa não seria a RPC.
  if v_material_id is null then
    v_ok_incrementa := null;
    raise notice '[registrar_material_pdf_admin, incrementa versao] pulado: PASSO 2 nao retornou material_id.';
  elsif not v_ok_fixture2 then
    v_ok_incrementa := null;
    raise notice '[registrar_material_pdf_admin, incrementa versao] pulado: fixture storage.objects v2 nao foi criada (ver NOTICE acima) — nao e possivel provar nada sobre a RPC sem ela.';
  else
    perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    begin
      select material_versao_id, numero_versao
      into v_versao2_id, v_numero2
      from public.registrar_material_pdf_admin(
        v_material_id, null, null, null, 'v2', '2ja-teste/v2.pdf', 'checksum2'
      );
      v_ok_incrementa := (v_numero2 = 2 and v_versao2_id <> v_versao1_id);
      raise notice '[registrar_material_pdf_admin, incrementa versao] OK: material_versao_id=%, numero_versao=%', v_versao2_id, v_numero2;
    exception when others then
      v_ok_incrementa := false;
      raise notice '[registrar_material_pdf_admin, incrementa versao] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
    end;
    reset role;
  end if;

  -- listar_materiais_admin enxerga o material criado — é uma RPC (não
  -- acesso direto a tabela), então SET LOCAL ROLE aqui é correto.
  if v_material_id is not null then
    perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    begin
      select exists (select 1 from public.listar_materiais_admin() where material_id = v_material_id) into v_ok_lista_materiais;
      raise notice '[listar_materiais_admin] OK: material encontrado=%', v_ok_lista_materiais;
    exception when others then
      v_ok_lista_materiais := false;
      raise notice '[listar_materiais_admin] FALHOU: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
    end;
    reset role;
  else
    raise notice '[listar_materiais_admin] pulado: PASSO 2 nao retornou material_id.';
  end if;

  -- PASSO 5: chamada com arquivo inexistente — precisa ser bloqueada.
  -- A) contagem ANTES como dono da transação (nunca sob authenticated).
  select count(*) into v_total_materiais_antes from public.materiais;
  select count(*) into v_total_versoes_antes from public.material_versoes;

  -- B) a chamada da RPC em si, sob authenticated.
  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  begin
    perform * from public.registrar_material_pdf_admin(
      null, '[TESTE FASE 2J-A] Nunca deve existir', 'pdf', null, 'v1', '2ja-teste/nao-existe.pdf', null
    );
    v_ok_inexistente_bloqueado := false;
    raise notice '[PASSO 5: arquivo inexistente] NAO foi bloqueado (deveria ter lancado excecao) — falha da RPC.';
  exception when others then
    v_ok_inexistente_bloqueado := true;
    raise notice '[PASSO 5: arquivo inexistente] bloqueado como esperado: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
  end;
  -- C) reset role antes de qualquer nova leitura direta de tabela.
  reset role;

  -- D) contagem DEPOIS como dono da transação.
  select count(*) into v_total_materiais_depois from public.materiais;
  select count(*) into v_total_versoes_depois from public.material_versoes;
  v_ok_inexistente_nao_material := (v_total_materiais_depois = v_total_materiais_antes);
  v_ok_inexistente_nao_versao := (v_total_versoes_depois = v_total_versoes_antes);

  -- PASSO 6: caminho que só existe em OUTRO bucket (mesmo "name",
  -- bucket_id diferente) — nunca deve ser aceito. Precisa da fixture do
  -- outro bucket; sem ela, o teste não prova nada sobre a RPC e fica NULL.
  if not v_ok_fixture_outro_bucket then
    v_ok_outro_bucket := null;
    raise notice '[PASSO 6: caminho de outro bucket] pulado: fixture storage.objects em outro bucket nao foi criada (ver NOTICE acima) — nao e possivel provar isolamento de bucket sem ela.';
  else
    perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    begin
      perform * from public.registrar_material_pdf_admin(
        null, '[TESTE FASE 2J-A] Outro bucket', 'pdf', null, 'v1', '2ja-teste/outro-bucket.pdf', null
      );
      v_ok_outro_bucket := false;
      raise notice '[PASSO 6: caminho de outro bucket] NAO foi bloqueado (deveria ter lancado excecao) — falha da RPC.';
    exception when others then
      v_ok_outro_bucket := true;
      raise notice '[PASSO 6: caminho de outro bucket] bloqueado como esperado: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
    end;
    reset role;
  end if;

  -- Guarda o material_versao "v1" real para o BLOCO 3 (carregar_aula_
  -- rascunho_admin) reaproveitar sem depender de variável de outro DO.
  if v_versao1_id is not null then
    insert into teste_2ja_contexto (chave, valor) values ('material_versao1_id_teste', v_versao1_id::text);
  end if;

  insert into teste_2ja_resultados values ('admin_pode_registrar_material', v_ok_registrar);
  insert into teste_2ja_resultados values ('registrar_material_incrementa_versao', v_ok_incrementa);
  insert into teste_2ja_resultados values ('admin_pode_listar_materiais', v_ok_lista_materiais);
  insert into teste_2ja_resultados values ('registrar_material_arquivo_inexistente_bloqueado', v_ok_inexistente_bloqueado);
  insert into teste_2ja_resultados values ('registrar_material_arquivo_inexistente_nao_cria_material', v_ok_inexistente_nao_material);
  insert into teste_2ja_resultados values ('registrar_material_arquivo_inexistente_nao_cria_versao', v_ok_inexistente_nao_versao);
  insert into teste_2ja_resultados values ('registrar_material_outro_bucket_bloqueado', v_ok_outro_bucket);
exception when others then
  reset role;
  insert into teste_2ja_resultados values
    ('admin_pode_registrar_material', v_ok_registrar),
    ('registrar_material_incrementa_versao', v_ok_incrementa),
    ('admin_pode_listar_materiais', v_ok_lista_materiais),
    ('registrar_material_arquivo_inexistente_bloqueado', v_ok_inexistente_bloqueado),
    ('registrar_material_arquivo_inexistente_nao_cria_material', v_ok_inexistente_nao_material),
    ('registrar_material_arquivo_inexistente_nao_cria_versao', v_ok_inexistente_nao_versao),
    ('registrar_material_outro_bucket_bloqueado', v_ok_outro_bucket);
  raise notice '[registrar_material_pdf_admin] algo inesperado fora dos passos individuais falhou: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Admin real, BLOCO 3: carregar_aula_rascunho_admin — depende só de
-- conteudo_livre (contexto inicial) e do material_versao "v1" criado no
-- BLOCO 2 (via teste_2ja_contexto). Se qualquer pré-requisito faltar, o
-- resultado é NULL com um NOTICE dizendo exatamente qual, nunca um FALSE
-- que sugira falha da RPC quando o problema é só falta de pré-condição.
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_admin_usuario_id uuid;
  v_conteudo_livre text;
  v_versao1_id text;
  v_aula_id uuid;
  v_aula_versao_id uuid;
  r record;
  v_ok_fontes boolean;
begin
  select valor into v_admin_id from teste_2ja_contexto where chave = 'admin_usuario_id';
  select valor into v_conteudo_livre from teste_2ja_contexto where chave = 'conteudo_livre';
  select valor into v_versao1_id from teste_2ja_contexto where chave = 'material_versao1_id_teste';

  if v_admin_id is null or v_admin_id = '' then
    insert into teste_2ja_resultados values ('carregar_rascunho_retorna_fontes_vinculadas', null);
    raise notice '[carregar_rascunho_retorna_fontes_vinculadas] pulado: nenhum admin real encontrado neste banco.';
    return;
  end if;

  if v_conteudo_livre is null or v_conteudo_livre = '' then
    insert into teste_2ja_resultados values ('carregar_rascunho_retorna_fontes_vinculadas', null);
    raise notice '[carregar_rascunho_retorna_fontes_vinculadas] pulado: nenhum curso_conteudos livre (sem aula) disponivel.';
    return;
  end if;

  if v_versao1_id is null then
    insert into teste_2ja_resultados values ('carregar_rascunho_retorna_fontes_vinculadas', null);
    raise notice '[carregar_rascunho_retorna_fontes_vinculadas] pulado: o BLOCO 2 (registrar_material_pdf_admin) nao produziu um material_versao de teste (foi pulado ou falhou antes) — ver o NOTICE desse bloco.';
    return;
  end if;

  v_admin_usuario_id := v_admin_id::uuid;

  insert into public.aulas (conteudo_id, titulo)
  values (v_conteudo_livre::bigint, '[TESTE FASE 2J-A] Aula rascunho')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 1, 'rascunho', '{"componentes": []}'::jsonb)
  returning id into v_aula_versao_id;

  insert into public.aula_versao_fontes (aula_versao_id, material_versao_id, ordem)
  values (v_aula_versao_id, v_versao1_id::uuid, 1);

  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select * into r from public.carregar_aula_rascunho_admin(v_aula_versao_id);

  v_ok_fontes := (
    r.status = 'rascunho'
    and jsonb_typeof(r.fontes) = 'array'
    and jsonb_array_length(r.fontes) = 1
    and exists (
      select 1 from jsonb_array_elements(r.fontes) elem
      where (elem ->> 'material_versao_id')::uuid = v_versao1_id::uuid
    )
  );

  reset role;
  insert into teste_2ja_resultados values ('carregar_rascunho_retorna_fontes_vinculadas', v_ok_fontes);
exception when others then
  reset role;
  insert into teste_2ja_resultados values ('carregar_rascunho_retorna_fontes_vinculadas', false);
  raise notice '[carregar_rascunho_retorna_fontes_vinculadas] falhou: SQLSTATE=%, SQLERRM=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Trava de concorrência de aula_geracoes: só via constraint do banco,
-- não depende de auth/admin — testado direto como o dono da transação.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_conteudo_livre text;
  v_conteudo_id bigint;
  v_geracao1_id uuid;
  v_segunda_bloqueada boolean;
  v_retry_ok boolean;
  v_regeneracao_ok boolean;
begin
  select valor::uuid into v_usuario_id from teste_2ja_contexto where chave = 'usuario_id';
  select valor into v_conteudo_livre from teste_2ja_contexto where chave = 'conteudo_livre';

  if v_conteudo_livre is null or v_conteudo_livre = '' then
    insert into teste_2ja_resultados values
      ('lock_bloqueia_segunda_geracao_processando', null),
      ('geracao_erro_permite_retry', null),
      ('geracao_concluida_permite_regeneracao', null);
    raise notice 'Testes de trava de geracao pulados: nenhum conteudo livre disponivel.';
    return;
  end if;

  v_conteudo_id := v_conteudo_livre::bigint;

  insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version)
  values (v_conteudo_id, 'processando', v_usuario_id, '2j-a-teste')
  returning id into v_geracao1_id;

  begin
    insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version)
    values (v_conteudo_id, 'processando', v_usuario_id, '2j-a-teste');
    v_segunda_bloqueada := false;
  exception when unique_violation then
    v_segunda_bloqueada := true;
  end;
  insert into teste_2ja_resultados values ('lock_bloqueia_segunda_geracao_processando', v_segunda_bloqueada);

  update public.aula_geracoes set status = 'erro', erro = '[TESTE] falha simulada', finalizado_em = now() where id = v_geracao1_id;

  begin
    insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version)
    values (v_conteudo_id, 'processando', v_usuario_id, '2j-a-teste')
    returning id into v_geracao1_id;
    v_retry_ok := true;
  exception when others then
    v_retry_ok := false;
  end;
  insert into teste_2ja_resultados values ('geracao_erro_permite_retry', v_retry_ok);

  update public.aula_geracoes set status = 'concluida', finalizado_em = now() where id = v_geracao1_id;

  begin
    insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version)
    values (v_conteudo_id, 'processando', v_usuario_id, '2j-a-teste');
    v_regeneracao_ok := true;
  exception when others then
    v_regeneracao_ok := false;
  end;
  insert into teste_2ja_resultados values ('geracao_concluida_permite_regeneracao', v_regeneracao_ok);
exception when others then
  insert into teste_2ja_resultados values
    ('lock_bloqueia_segunda_geracao_processando', false),
    ('geracao_erro_permite_retry', false),
    ('geracao_concluida_permite_regeneracao', false);
  raise notice 'Testes de trava de geracao falharam: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ============================================================================
-- RESULTADO FINAL
-- ============================================================================
select
  (select ok from teste_2ja_resultados where chave = 'bucket_materiais_teoria_existe') as bucket_materiais_teoria_existe,
  (select ok from teste_2ja_resultados where chave = 'bucket_materiais_teoria_privado') as bucket_materiais_teoria_privado,
  (select ok from teste_2ja_resultados where chave = 'storage_policies_existem') as storage_policies_existem,
  (select ok from teste_2ja_resultados where chave = 'tabela_aula_geracoes_existe') as tabela_aula_geracoes_existe,
  (select ok from teste_2ja_resultados where chave = 'indice_unico_processando_existe') as indice_unico_processando_existe,
  (select ok from teste_2ja_resultados where chave = 'rpcs_existem') as rpcs_existem,
  (select ok from teste_2ja_resultados where chave = 'authenticated_pode_executar_rpcs') as authenticated_pode_executar_rpcs,
  (select ok from teste_2ja_resultados where chave = 'anon_nao_pode_executar_rpcs') as anon_nao_pode_executar_rpcs,
  (select ok from teste_2ja_resultados where chave = 'usuario_comum_bloqueado_listar_conteudos') as usuario_comum_bloqueado_listar_conteudos,
  (select ok from teste_2ja_resultados where chave = 'usuario_comum_bloqueado_registrar_material') as usuario_comum_bloqueado_registrar_material,
  (select ok from teste_2ja_resultados where chave = 'usuario_comum_bloqueado_carregar_rascunho') as usuario_comum_bloqueado_carregar_rascunho,
  (select ok from teste_2ja_resultados where chave = 'admin_pode_listar_conteudos') as admin_pode_listar_conteudos,
  (select ok from teste_2ja_resultados where chave = 'listar_conteudos_isola_por_curso_materia') as listar_conteudos_isola_por_curso_materia,
  (select ok from teste_2ja_resultados where chave = 'admin_pode_registrar_material') as admin_pode_registrar_material,
  (select ok from teste_2ja_resultados where chave = 'registrar_material_incrementa_versao') as registrar_material_incrementa_versao,
  (select ok from teste_2ja_resultados where chave = 'admin_pode_listar_materiais') as admin_pode_listar_materiais,
  (select ok from teste_2ja_resultados where chave = 'carregar_rascunho_retorna_fontes_vinculadas') as carregar_rascunho_retorna_fontes_vinculadas,
  (select ok from teste_2ja_resultados where chave = 'registrar_material_arquivo_inexistente_bloqueado') as registrar_material_arquivo_inexistente_bloqueado,
  (select ok from teste_2ja_resultados where chave = 'registrar_material_arquivo_inexistente_nao_cria_material') as registrar_material_arquivo_inexistente_nao_cria_material,
  (select ok from teste_2ja_resultados where chave = 'registrar_material_arquivo_inexistente_nao_cria_versao') as registrar_material_arquivo_inexistente_nao_cria_versao,
  (select ok from teste_2ja_resultados where chave = 'registrar_material_outro_bucket_bloqueado') as registrar_material_outro_bucket_bloqueado,
  (select ok from teste_2ja_resultados where chave = 'lock_bloqueia_segunda_geracao_processando') as lock_bloqueia_segunda_geracao_processando,
  (select ok from teste_2ja_resultados where chave = 'geracao_erro_permite_retry') as geracao_erro_permite_retry,
  (select ok from teste_2ja_resultados where chave = 'geracao_concluida_permite_regeneracao') as geracao_concluida_permite_regeneracao,
  (select bool_and(ok) from teste_2ja_resultados where ok is not null) as tudo_ok;

ROLLBACK;
