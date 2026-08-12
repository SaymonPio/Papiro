-- ============================================================================
-- TESTE RUNTIME COMPLETO DA FASE 2E — TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Este arquivo é SEPARADO da migration real (supabase/teoria_versionada.sql,
-- que continua terminando em COMMIT e é o arquivo a aplicar de verdade
-- quando chegar a hora). Este aqui é só para você colar no SQL Editor do
-- Supabase, rodar de uma vez, ler o resultado e nunca persistir nada.
--
-- O que faz, em ordem:
--   1. Verifica que existe pelo menos um public.curso_conteudos real (só
--      leitura — nunca INSERT/UPDATE/DELETE nessa tabela).
--   2. Aplica o corpo INTEIRO de teoria_versionada.sql (as 5 tabelas, as 2
--      funções de trigger, os 2 triggers, o índice parcial, RLS + REVOKEs)
--      — idêntico ao arquivo real, só sem o COMMIT final.
--   3. Roda uma bateria de validações estruturais (catálogo do Postgres:
--      pg_class/pg_constraint/pg_trigger/pg_index/information_schema).
--   4. Roda um ciclo real de dados (curso_conteudos existente -> materiais
--      -> material_versoes -> aulas -> aula_versoes -> aula_versao_fontes),
--      com dados marcados "[TESTE FASE 2E]".
--   5. Roda uma bateria de tentativas que DEVEM falhar (CHECK/UNIQUE/índice
--      parcial), cada uma isolada num bloco DO com EXCEPTION — uma falha
--      esperada NUNCA aborta a transação inteira.
--   6. Roda um caso que DEVE ser aceito (arquivada com publicado_em).
--   7. Testa os dois triggers de atualizado_em.
--   8. Produz UM SELECT final com todas as respostas em colunas booleanas.
--   9. ROLLBACK — desfaz tudo: as 5 tabelas, as funções, os triggers, e
--      todos os dados de teste. O banco volta exatamente ao estado de
--      antes de rodar este arquivo.
--
-- Não toca em public.missoes, public.sessoes_estudo, public.
-- progresso_conteudo_matricula, nem em public.curso_conteudos além de um
-- SELECT de leitura para pegar um id existente.

BEGIN;

-- ---------------------------------------------------------------------------
-- Segurança do teste: exige pelo menos um curso_conteudos real. Se não
-- houver, aborta aqui (fora de qualquer bloco de exceção, de propósito —
-- isto não é um teste esperado-para-falhar, é um pré-requisito do teste).
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.curso_conteudos) then
    raise exception 'Teste abortado: nao ha nenhum public.curso_conteudos existente para usar como FK.';
  end if;
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_versionada.sql, sem o
-- COMMIT final)
-- ============================================================================

create table public.materiais (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  tipo text not null,
  descricao text null,
  origem text null,
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create function public.marcar_atualizacao_material()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists materiais_marca_atualizacao on public.materiais;
create trigger materiais_marca_atualizacao
  before update on public.materiais
  for each row
  execute function public.marcar_atualizacao_material();

revoke execute on function public.marcar_atualizacao_material()
  from public, anon, authenticated;

create table public.material_versoes (
  id uuid primary key default gen_random_uuid(),
  material_id uuid not null references public.materiais(id) on delete restrict,
  numero_versao integer not null check (numero_versao > 0),
  titulo_versao text null,
  conteudo_texto text null,
  arquivo_path text null,
  checksum text null,
  vigente_desde date null,
  vigente_ate date null,
  criado_em timestamptz not null default now(),
  unique (material_id, numero_versao),
  check (vigente_desde is null or vigente_ate is null or vigente_ate >= vigente_desde)
);

create table public.aulas (
  id uuid primary key default gen_random_uuid(),
  conteudo_id bigint not null references public.curso_conteudos(id) on delete restrict,
  titulo text not null,
  ativa boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (conteudo_id)
);

create function public.marcar_atualizacao_aula()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists aulas_marca_atualizacao on public.aulas;
create trigger aulas_marca_atualizacao
  before update on public.aulas
  for each row
  execute function public.marcar_atualizacao_aula();

revoke execute on function public.marcar_atualizacao_aula()
  from public, anon, authenticated;

create table public.aula_versoes (
  id uuid primary key default gen_random_uuid(),
  aula_id uuid not null references public.aulas(id) on delete restrict,
  numero_versao integer not null check (numero_versao > 0),
  status text not null default 'rascunho'
    check (status in ('rascunho', 'publicada', 'arquivada')),
  estrutura jsonb not null check (jsonb_typeof(estrutura) = 'object'),
  criado_em timestamptz not null default now(),
  publicado_em timestamptz null,
  check (status <> 'publicada' or publicado_em is not null),
  unique (aula_id, numero_versao)
);

create unique index aula_versoes_uma_publicada_idx
  on public.aula_versoes (aula_id)
  where status = 'publicada';

create table public.aula_versao_fontes (
  aula_versao_id uuid not null references public.aula_versoes(id) on delete cascade,
  material_versao_id uuid not null references public.material_versoes(id) on delete restrict,
  ordem integer null check (ordem is null or ordem > 0),
  observacao text null,
  criado_em timestamptz not null default now(),
  primary key (aula_versao_id, material_versao_id)
);

create index aula_versao_fontes_material_versao_id_idx
  on public.aula_versao_fontes (material_versao_id);

alter table public.materiais enable row level security;
alter table public.material_versoes enable row level security;
alter table public.aulas enable row level security;
alter table public.aula_versoes enable row level security;
alter table public.aula_versao_fontes enable row level security;

revoke all on public.materiais from anon, authenticated;
revoke all on public.material_versoes from anon, authenticated;
revoke all on public.aulas from anon, authenticated;
revoke all on public.aula_versoes from anon, authenticated;
revoke all on public.aula_versao_fontes from anon, authenticated;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- Tabelas de apoio do teste (não fazem parte da migration real).
create temporary table teste_2e_resultados (
  chave text primary key,
  ok boolean not null
);

create temporary table teste_2e_contexto (
  chave text primary key,
  valor text
);

-- ---------------------------------------------------------------------------
-- Validações estruturais (catálogo do Postgres)
-- ---------------------------------------------------------------------------

insert into teste_2e_resultados values (
  'cinco_tabelas_ok',
  (select count(*) = 5 from information_schema.tables
   where table_schema = 'public'
     and table_name in ('materiais', 'material_versoes', 'aulas', 'aula_versoes', 'aula_versao_fontes'))
);

insert into teste_2e_resultados values (
  'funcoes_timestamp_ok',
  (select count(*) = 2 from pg_proc p
   join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'
     and p.proname in ('marcar_atualizacao_material', 'marcar_atualizacao_aula'))
);

insert into teste_2e_resultados values (
  'triggers_ok',
  (select count(*) = 2 from pg_trigger t
   join pg_class c on c.oid = t.tgrelid
   join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and t.tgname in ('materiais_marca_atualizacao', 'aulas_marca_atualizacao')
     and not t.tgisinternal
     and t.tgenabled <> 'D')
);

insert into teste_2e_resultados values (
  'rls_ok',
  (select count(*) = 5 from pg_class c
   join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relname in ('materiais', 'material_versoes', 'aulas', 'aula_versoes', 'aula_versao_fontes')
     and c.relrowsecurity)
);

insert into teste_2e_resultados values (
  'anon_sem_acesso',
  not exists (
    select 1 from unnest(array['materiais', 'material_versoes', 'aulas', 'aula_versoes', 'aula_versao_fontes']) as t
    where has_table_privilege('anon', format('public.%I', t), 'SELECT,INSERT,UPDATE,DELETE')
  )
);

insert into teste_2e_resultados values (
  'authenticated_sem_acesso',
  not exists (
    select 1 from unnest(array['materiais', 'material_versoes', 'aulas', 'aula_versoes', 'aula_versao_fontes']) as t
    where has_table_privilege('authenticated', format('public.%I', t), 'SELECT,INSERT,UPDATE,DELETE')
  )
);

insert into teste_2e_resultados values (
  'uniques_ok',
  (
    exists (
      select 1 from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'material_versoes' and con.contype = 'u'
        and pg_get_constraintdef(con.oid) = 'UNIQUE (material_id, numero_versao)'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'aulas' and con.contype = 'u'
        and pg_get_constraintdef(con.oid) = 'UNIQUE (conteudo_id)'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'aula_versoes' and con.contype = 'u'
        and pg_get_constraintdef(con.oid) = 'UNIQUE (aula_id, numero_versao)'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'aula_versao_fontes' and con.contype = 'p'
        and pg_get_constraintdef(con.oid) = 'PRIMARY KEY (aula_versao_id, material_versao_id)'
    )
  )
);

insert into teste_2e_resultados values (
  'indice_publicada_ok',
  exists (
    select 1 from pg_index i
    join pg_class ic on ic.oid = i.indexrelid
    join pg_namespace n on n.oid = ic.relnamespace
    where n.nspname = 'public' and ic.relname = 'aula_versoes_uma_publicada_idx'
      and i.indisunique
      and i.indpred is not null
      and pg_get_indexdef(i.indexrelid) ilike '%where (status = ''publicada''%'
  )
);

insert into teste_2e_resultados values (
  'on_delete_ok',
  (
    exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'material_versoes' and p.relname = 'materiais'
        and con.contype = 'f' and con.confdeltype = 'r'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'aulas' and p.relname = 'curso_conteudos'
        and con.contype = 'f' and con.confdeltype = 'r'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'aula_versoes' and p.relname = 'aulas'
        and con.contype = 'f' and con.confdeltype = 'r'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'aula_versao_fontes' and p.relname = 'aula_versoes'
        and con.contype = 'f' and con.confdeltype = 'c'
    )
    and exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'aula_versao_fontes' and p.relname = 'material_versoes'
        and con.contype = 'f' and con.confdeltype = 'r'
    )
  )
);

-- ---------------------------------------------------------------------------
-- Ciclo real: curso_conteudos existente -> materiais -> material_versoes ->
-- aulas -> aula_versoes -> aula_versao_fontes. Cria também uma SEGUNDA
-- material_versoes (numero_versao=2) só para os testes de "ordem" (H/I)
-- não colidirem com a PK da linha real de aula_versao_fontes. Também
-- valida que o vínculo aula_versao -> aula_versao_fontes -> material_versao
-- -> material resolve de fato.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_material_id uuid;
  v_material_versao_id uuid;
  v_material_versao_id_2 uuid;
  v_aula_id uuid;
  v_aula_versao_id uuid;
begin
  select id into v_conteudo_id from public.curso_conteudos order by id limit 1;

  -- atualizado_em explicitamente retroagido: dentro de uma única transação,
  -- now() é o timestamp de INÍCIO da transação e não avança (nem com
  -- pg_sleep) — se o INSERT usasse o DEFAULT now(), o valor "antes" seria
  -- idêntico ao "depois" que o trigger grava no UPDATE do teste, fazendo
  -- v_depois > v_antes dar falso mesmo com o trigger funcionando
  -- corretamente. Retroagir aqui garante uma diferença real pro teste do
  -- trigger comparar, sem depender da passagem do relógio.
  insert into public.materiais (titulo, tipo, descricao, atualizado_em)
  values (
    '[TESTE FASE 2E] Material de teste',
    'teste',
    'Linha criada só para o teste transacional da Fase 2E — desfeita por ROLLBACK, nunca persiste.',
    now() - interval '1 day'
  )
  returning id into v_material_id;

  insert into public.material_versoes (material_id, numero_versao, titulo_versao, conteudo_texto, vigente_desde)
  values (v_material_id, 1, '[TESTE FASE 2E] v1', 'Conteúdo de teste da Fase 2E.', current_date)
  returning id into v_material_versao_id;

  insert into public.material_versoes (material_id, numero_versao, titulo_versao, conteudo_texto)
  values (v_material_id, 2, '[TESTE FASE 2E] v2 (só para testes de ordem)', 'Segunda versão de teste.')
  returning id into v_material_versao_id_2;

  -- Mesmo motivo do atualizado_em retroagido em materiais, acima.
  insert into public.aulas (conteudo_id, titulo, atualizado_em)
  values (v_conteudo_id, '[TESTE FASE 2E] Aula de teste', now() - interval '1 day')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 1, 'rascunho', '{"componentes": []}'::jsonb)
  returning id into v_aula_versao_id;

  insert into public.aula_versao_fontes (aula_versao_id, material_versao_id, ordem)
  values (v_aula_versao_id, v_material_versao_id, 1);

  -- Valida que o vínculo aula_versao -> aula_versao_fontes -> material_versao
  -- -> material resolve corretamente antes de marcar o ciclo como ok.
  if not exists (
    select 1
    from public.aula_versoes av
    join public.aula_versao_fontes avf on avf.aula_versao_id = av.id
    join public.material_versoes mv on mv.id = avf.material_versao_id
    join public.materiais m on m.id = mv.material_id
    where av.id = v_aula_versao_id
      and m.id = v_material_id
      and m.titulo = '[TESTE FASE 2E] Material de teste'
  ) then
    raise exception 'vinculo aula_versao -> material_versao -> material nao resolveu';
  end if;

  insert into teste_2e_contexto (chave, valor) values
    ('conteudo_id', v_conteudo_id::text),
    ('material_id', v_material_id::text),
    ('material_versao_id', v_material_versao_id::text),
    ('material_versao_id_2', v_material_versao_id_2::text),
    ('aula_id', v_aula_id::text),
    ('aula_versao_id', v_aula_versao_id::text);

  insert into teste_2e_resultados values ('ciclo_completo_ok', true);
exception when others then
  insert into teste_2e_resultados values ('ciclo_completo_ok', false);
  raise notice 'Ciclo real falhou: %', sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Tentativas que DEVEM falhar (cada uma isolada, nunca aborta a transação)
-- ---------------------------------------------------------------------------

-- A) numero_versao = 0 em material_versoes
do $$
declare v_material_id uuid;
begin
  select valor::uuid into v_material_id from teste_2e_contexto where chave = 'material_id';
  if v_material_id is null then raise exception 'contexto ausente'; end if;

  insert into public.material_versoes (material_id, numero_versao) values (v_material_id, 0);

  insert into teste_2e_resultados values ('material_versao_zero_bloqueado', false);
exception
  when check_violation then insert into teste_2e_resultados values ('material_versao_zero_bloqueado', true);
  when others then insert into teste_2e_resultados values ('material_versao_zero_bloqueado', false);
end $$;

-- B) vigente_ate < vigente_desde
do $$
declare v_material_id uuid;
begin
  select valor::uuid into v_material_id from teste_2e_contexto where chave = 'material_id';
  if v_material_id is null then raise exception 'contexto ausente'; end if;

  insert into public.material_versoes (material_id, numero_versao, vigente_desde, vigente_ate)
  values (v_material_id, 101, date '2024-06-01', date '2024-01-01');

  insert into teste_2e_resultados values ('vigencia_invalida_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('vigencia_invalida_bloqueada', true);
  when others then insert into teste_2e_resultados values ('vigencia_invalida_bloqueada', false);
end $$;

-- C) duplicar (material_id, numero_versao) — reusa numero_versao=1, já usado no ciclo real
do $$
declare v_material_id uuid;
begin
  select valor::uuid into v_material_id from teste_2e_contexto where chave = 'material_id';
  if v_material_id is null then raise exception 'contexto ausente'; end if;

  insert into public.material_versoes (material_id, numero_versao) values (v_material_id, 1);

  insert into teste_2e_resultados values ('material_versao_duplicada_bloqueada', false);
exception
  when unique_violation then insert into teste_2e_resultados values ('material_versao_duplicada_bloqueada', true);
  when others then insert into teste_2e_resultados values ('material_versao_duplicada_bloqueada', false);
end $$;

-- D) numero_versao = 0 em aula_versoes
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 0, 'rascunho', '{}'::jsonb);

  insert into teste_2e_resultados values ('aula_versao_zero_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('aula_versao_zero_bloqueada', true);
  when others then insert into teste_2e_resultados values ('aula_versao_zero_bloqueada', false);
end $$;

-- E) estrutura = []::jsonb (não é objeto)
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 3, 'rascunho', '[]'::jsonb);

  insert into teste_2e_resultados values ('estrutura_array_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('estrutura_array_bloqueada', true);
  when others then insert into teste_2e_resultados values ('estrutura_array_bloqueada', false);
end $$;

-- F) status='publicada' com publicado_em=NULL
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 4, 'publicada', '{}'::jsonb, null);

  insert into teste_2e_resultados values ('publicada_sem_data_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('publicada_sem_data_bloqueada', true);
  when others then insert into teste_2e_resultados values ('publicada_sem_data_bloqueada', false);
end $$;

-- G) status inválido
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 5, 'nao_existe', '{}'::jsonb);

  insert into teste_2e_resultados values ('status_invalido_bloqueado', false);
exception
  when check_violation then insert into teste_2e_resultados values ('status_invalido_bloqueado', true);
  when others then insert into teste_2e_resultados values ('status_invalido_bloqueado', false);
end $$;

-- H) ordem = 0 em aula_versao_fontes (usa material_versao_id_2 pra não colidir com a PK da linha real)
do $$
declare
  v_aula_versao_id uuid;
  v_material_versao_id_2 uuid;
begin
  select valor::uuid into v_aula_versao_id from teste_2e_contexto where chave = 'aula_versao_id';
  select valor::uuid into v_material_versao_id_2 from teste_2e_contexto where chave = 'material_versao_id_2';
  if v_aula_versao_id is null or v_material_versao_id_2 is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versao_fontes (aula_versao_id, material_versao_id, ordem)
  values (v_aula_versao_id, v_material_versao_id_2, 0);

  insert into teste_2e_resultados values ('ordem_zero_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('ordem_zero_bloqueada', true);
  when others then insert into teste_2e_resultados values ('ordem_zero_bloqueada', false);
end $$;

-- I) ordem negativa em aula_versao_fontes
do $$
declare
  v_aula_versao_id uuid;
  v_material_versao_id_2 uuid;
begin
  select valor::uuid into v_aula_versao_id from teste_2e_contexto where chave = 'aula_versao_id';
  select valor::uuid into v_material_versao_id_2 from teste_2e_contexto where chave = 'material_versao_id_2';
  if v_aula_versao_id is null or v_material_versao_id_2 is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versao_fontes (aula_versao_id, material_versao_id, ordem)
  values (v_aula_versao_id, v_material_versao_id_2, -1);

  insert into teste_2e_resultados values ('ordem_negativa_bloqueada', false);
exception
  when check_violation then insert into teste_2e_resultados values ('ordem_negativa_bloqueada', true);
  when others then insert into teste_2e_resultados values ('ordem_negativa_bloqueada', false);
end $$;

-- J) segunda aula com o mesmo conteudo_id
do $$
declare v_conteudo_id bigint;
begin
  select valor::bigint into v_conteudo_id from teste_2e_contexto where chave = 'conteudo_id';
  if v_conteudo_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aulas (conteudo_id, titulo)
  values (v_conteudo_id, '[TESTE FASE 2E] Aula duplicada (deve falhar)');

  insert into teste_2e_resultados values ('aula_duplicada_bloqueada', false);
exception
  when unique_violation then insert into teste_2e_resultados values ('aula_duplicada_bloqueada', true);
  when others then insert into teste_2e_resultados values ('aula_duplicada_bloqueada', false);
end $$;

-- K) segunda versão com o mesmo (aula_id, numero_versao) — reusa numero_versao=1
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura)
  values (v_aula_id, 1, 'rascunho', '{}'::jsonb);

  insert into teste_2e_resultados values ('aula_versao_duplicada_bloqueada', false);
exception
  when unique_violation then insert into teste_2e_resultados values ('aula_versao_duplicada_bloqueada', true);
  when others then insert into teste_2e_resultados values ('aula_versao_duplicada_bloqueada', false);
end $$;

-- L) duas versões 'publicada' para a mesma aula — a primeira deve funcionar
-- normalmente (não é o alvo do teste), só a segunda deve ser bloqueada pelo
-- índice único parcial. Ambas com publicado_em preenchido, pra garantir que
-- é o índice parcial barrando, não o CHECK de publicado_em.
do $$
declare
  v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 6, 'publicada', '{}'::jsonb, now());

  begin
    insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
    values (v_aula_id, 7, 'publicada', '{}'::jsonb, now());

    insert into teste_2e_resultados values ('duas_publicadas_bloqueadas', false);
  exception
    when unique_violation then insert into teste_2e_resultados values ('duas_publicadas_bloqueadas', true);
    when others then insert into teste_2e_resultados values ('duas_publicadas_bloqueadas', false);
  end;
exception when others then
  -- a PRIMEIRA insert (que deveria funcionar) falhou por algum motivo
  -- inesperado — reporta como não-testado (false) em vez de mascarar.
  insert into teste_2e_resultados values ('duas_publicadas_bloqueadas', false);
end $$;

-- ---------------------------------------------------------------------------
-- Caso que DEVE ser aceito: arquivada com publicado_em preenchido
-- ---------------------------------------------------------------------------
do $$
declare v_aula_id uuid;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 8, 'arquivada', '{}'::jsonb, now() - interval '30 days');

  insert into teste_2e_resultados values ('arquivada_com_publicado_em_aceita', true);
exception when others then
  insert into teste_2e_resultados values ('arquivada_com_publicado_em_aceita', false);
  -- Revisão estática (numero_versao já usado, índice parcial de publicada,
  -- UNIQUE(aula_id,numero_versao), CHECK de status, CHECK de publicado_em)
  -- não encontrou nenhuma colisão esperada para este INSERT — por isso não
  -- mascarar: mostra a causa real no próximo Run em vez de adivinhar.
  raise notice 'Teste arquivada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Triggers de atualizado_em
-- ---------------------------------------------------------------------------
do $$
declare
  v_material_id uuid;
  v_antes timestamptz;
  v_depois timestamptz;
begin
  select valor::uuid into v_material_id from teste_2e_contexto where chave = 'material_id';
  if v_material_id is null then raise exception 'contexto ausente'; end if;

  -- Sem pg_sleep: now() é o timestamp de início da transação e não avança
  -- dentro dela, então pg_sleep não ajudaria em nada aqui — o que faz
  -- v_depois > v_antes ser um teste válido é o atualizado_em ter sido
  -- INSERIDO retroagido (now() - 1 dia, no ciclo real acima); o trigger
  -- substitui esse valor antigo por now() (o now() da transação) no UPDATE.
  select atualizado_em into v_antes from public.materiais where id = v_material_id;
  update public.materiais set titulo = titulo || ' (editado)' where id = v_material_id;
  select atualizado_em into v_depois from public.materiais where id = v_material_id;

  insert into teste_2e_resultados values ('trigger_material_ok', v_depois > v_antes);
exception when others then
  insert into teste_2e_resultados values ('trigger_material_ok', false);
  raise notice 'Teste trigger_material_ok falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
declare
  v_aula_id uuid;
  v_antes timestamptz;
  v_depois timestamptz;
begin
  select valor::uuid into v_aula_id from teste_2e_contexto where chave = 'aula_id';
  if v_aula_id is null then raise exception 'contexto ausente'; end if;

  -- Mesmo motivo do teste de materiais, acima — sem pg_sleep.
  select atualizado_em into v_antes from public.aulas where id = v_aula_id;
  update public.aulas set titulo = titulo || ' (editado)' where id = v_aula_id;
  select atualizado_em into v_depois from public.aulas where id = v_aula_id;

  insert into teste_2e_resultados values ('trigger_aula_ok', v_depois > v_antes);
exception when others then
  insert into teste_2e_resultados values ('trigger_aula_ok', false);
  raise notice 'Teste trigger_aula_ok falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ============================================================================
-- RESULTADO FINAL — esperado TRUE em todas (inclusive tudo_ok)
-- ============================================================================
select
  (select ok from teste_2e_resultados where chave = 'cinco_tabelas_ok') as cinco_tabelas_ok,
  (select ok from teste_2e_resultados where chave = 'funcoes_timestamp_ok') as funcoes_timestamp_ok,
  (select ok from teste_2e_resultados where chave = 'triggers_ok') as triggers_ok,
  (select ok from teste_2e_resultados where chave = 'rls_ok') as rls_ok,
  (select ok from teste_2e_resultados where chave = 'anon_sem_acesso') as anon_sem_acesso,
  (select ok from teste_2e_resultados where chave = 'authenticated_sem_acesso') as authenticated_sem_acesso,
  (select ok from teste_2e_resultados where chave = 'uniques_ok') as uniques_ok,
  (select ok from teste_2e_resultados where chave = 'indice_publicada_ok') as indice_publicada_ok,
  (select ok from teste_2e_resultados where chave = 'on_delete_ok') as on_delete_ok,
  (select ok from teste_2e_resultados where chave = 'ciclo_completo_ok') as ciclo_completo_ok,
  (select ok from teste_2e_resultados where chave = 'material_versao_zero_bloqueado') as material_versao_zero_bloqueado,
  (select ok from teste_2e_resultados where chave = 'vigencia_invalida_bloqueada') as vigencia_invalida_bloqueada,
  (select ok from teste_2e_resultados where chave = 'material_versao_duplicada_bloqueada') as material_versao_duplicada_bloqueada,
  (select ok from teste_2e_resultados where chave = 'aula_versao_zero_bloqueada') as aula_versao_zero_bloqueada,
  (select ok from teste_2e_resultados where chave = 'estrutura_array_bloqueada') as estrutura_array_bloqueada,
  (select ok from teste_2e_resultados where chave = 'publicada_sem_data_bloqueada') as publicada_sem_data_bloqueada,
  (select ok from teste_2e_resultados where chave = 'status_invalido_bloqueado') as status_invalido_bloqueado,
  (select ok from teste_2e_resultados where chave = 'ordem_zero_bloqueada') as ordem_zero_bloqueada,
  (select ok from teste_2e_resultados where chave = 'ordem_negativa_bloqueada') as ordem_negativa_bloqueada,
  (select ok from teste_2e_resultados where chave = 'aula_duplicada_bloqueada') as aula_duplicada_bloqueada,
  (select ok from teste_2e_resultados where chave = 'aula_versao_duplicada_bloqueada') as aula_versao_duplicada_bloqueada,
  (select ok from teste_2e_resultados where chave = 'duas_publicadas_bloqueadas') as duas_publicadas_bloqueadas,
  (select ok from teste_2e_resultados where chave = 'arquivada_com_publicado_em_aceita') as arquivada_com_publicado_em_aceita,
  (select ok from teste_2e_resultados where chave = 'trigger_material_ok') as trigger_material_ok,
  (select ok from teste_2e_resultados where chave = 'trigger_aula_ok') as trigger_aula_ok,
  -- coluna extra de conveniência (não pedida explicitamente): AND de tudo
  -- acima, pra ver o veredito geral numa olhada só.
  (select bool_and(ok) from teste_2e_resultados) as tudo_ok;

-- ============================================================================
-- DESFAZ TUDO — tabelas, funções, triggers, dados de teste. Nada persiste.
-- ============================================================================
ROLLBACK;
