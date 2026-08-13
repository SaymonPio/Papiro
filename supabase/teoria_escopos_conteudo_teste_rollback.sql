-- ============================================================================
-- TESTE RUNTIME DA MIGRATION teoria_escopos_conteudo.sql (Fase 2J-B) —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Este arquivo é SEPARADO da migration real (supabase/teoria_escopos_
-- conteudo.sql, que continua terminando em COMMIT e é o arquivo a aplicar
-- de verdade quando chegar a hora). Este aqui é só para colar no SQL
-- Editor do Supabase, rodar de uma vez, ler o resultado e nunca persistir
-- nada — termina em ROLLBACK.
--
-- Precisa de pelo menos 4 public.curso_conteudos REAIS e distintos já
-- existentes (só leitura — nunca INSERT/UPDATE/DELETE nessa tabela) para
-- usar como FK nos testes de dados. Se não houver, aborta ANTES de
-- qualquer teste (fora de bloco de exceção, de propósito — não é um
-- teste esperado-para-falhar, é um pré-requisito).
--
-- O que faz, em ordem:
--   1. Aplica o corpo INTEIRO de teoria_escopos_conteudo.sql (tabela,
--      índices, função de trigger, trigger, RLS + REVOKEs) — idêntico ao
--      arquivo real, só sem o COMMIT final.
--   2. Validações estruturais (catálogo do Postgres): tabela existe, FK
--      para curso_conteudos (ON DELETE CASCADE), PK correta, RLS ativo.
--   3. Privilégios: authenticated e anon sem acesso direto nenhum.
--   4. Dados: várias partes compartilhando o mesmo grupo_id; grupos
--      diferentes podem repetir parte_ordem; artigos_esperados NULL é
--      aceito.
--   5. Blocos esperado-para-falhar, cada um ISOLADO em DO/EXCEPTION (uma
--      falha esperada nunca aborta a transação inteira): mesma
--      curso_conteudo_id duplicada (PK), parte_ordem duplicada dentro do
--      MESMO grupo_id (índice único parcial), parte_ordem = 0 e
--      parte_ordem negativa (CHECK).
--   6. UM SELECT final com todas as respostas em colunas booleanas.
--   7. ROLLBACK — desfaz tudo: a tabela, a função, o trigger, e todos os
--      dados de teste. O banco volta exatamente ao estado de antes.

BEGIN;

do $$
begin
  if (select count(*) from public.curso_conteudos) < 4 then
    raise exception 'Teste abortado: sao necessarios pelo menos 4 public.curso_conteudos reais e distintos para testar teoria_escopos_conteudo (FK), e o banco tem menos que isso.';
  end if;
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_escopos_conteudo.sql,
-- sem o COMMIT final)
-- ============================================================================

create table public.teoria_escopos_conteudo (
  curso_conteudo_id bigint primary key
    references public.curso_conteudos(id) on delete cascade,

  grupo_id uuid not null,

  parte_ordem smallint null
    check (parte_ordem is null or parte_ordem > 0),

  escopo text not null,

  artigos_esperados text[] null,

  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index teoria_escopos_conteudo_grupo_id_idx
  on public.teoria_escopos_conteudo (grupo_id);

create unique index teoria_escopos_conteudo_grupo_parte_idx
  on public.teoria_escopos_conteudo (grupo_id, parte_ordem)
  where parte_ordem is not null;

create function public.marcar_atualizacao_teoria_escopos_conteudo()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists teoria_escopos_conteudo_marca_atualizacao on public.teoria_escopos_conteudo;
create trigger teoria_escopos_conteudo_marca_atualizacao
  before update on public.teoria_escopos_conteudo
  for each row
  execute function public.marcar_atualizacao_teoria_escopos_conteudo();

revoke execute on function public.marcar_atualizacao_teoria_escopos_conteudo()
  from public, anon, authenticated;

alter table public.teoria_escopos_conteudo enable row level security;
revoke all on public.teoria_escopos_conteudo from anon, authenticated;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

create temporary table teste_2jb_resultados (
  chave text primary key,
  ok boolean
);

create temporary table teste_2jb_contexto (
  chave text primary key,
  valor text
);

-- ---------------------------------------------------------------------------
-- BLOCO 1 — pega 4 curso_conteudo_id reais e distintos.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id1 bigint;
  v_id2 bigint;
  v_id3 bigint;
  v_id4 bigint;
begin
  select id into v_id1 from public.curso_conteudos order by id limit 1 offset 0;
  select id into v_id2 from public.curso_conteudos order by id limit 1 offset 1;
  select id into v_id3 from public.curso_conteudos order by id limit 1 offset 2;
  select id into v_id4 from public.curso_conteudos order by id limit 1 offset 3;
  insert into teste_2jb_contexto values
    ('conteudo_id_1', v_id1::text),
    ('conteudo_id_2', v_id2::text),
    ('conteudo_id_3', v_id3::text),
    ('conteudo_id_4', v_id4::text),
    ('grupo_a', gen_random_uuid()::text),
    ('grupo_b', gen_random_uuid()::text);
exception when others then
  raise exception 'BLOCO 1 (setup de contexto) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 2 — validações estruturais (catálogo do Postgres).
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_2jb_resultados values (
    'tabela_existe',
    (select count(*) = 1 from information_schema.tables
     where table_schema = 'public' and table_name = 'teoria_escopos_conteudo')
  );
exception when others then
  insert into teste_2jb_resultados values ('tabela_existe', false);
  raise notice 'tabela_existe: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb_resultados values (
    'fk_curso_conteudos_ok',
    exists (
      select 1 from pg_constraint con
      join pg_class ch on ch.oid = con.conrelid
      join pg_class p on p.oid = con.confrelid
      join pg_namespace n on n.oid = ch.relnamespace
      where n.nspname = 'public' and ch.relname = 'teoria_escopos_conteudo' and p.relname = 'curso_conteudos'
        and con.contype = 'f' and con.confdeltype = 'c'
    )
  );
exception when others then
  insert into teste_2jb_resultados values ('fk_curso_conteudos_ok', false);
  raise notice 'fk_curso_conteudos_ok: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb_resultados values (
    'pk_ok',
    exists (
      select 1 from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'teoria_escopos_conteudo' and con.contype = 'p'
        and pg_get_constraintdef(con.oid) = 'PRIMARY KEY (curso_conteudo_id)'
    )
  );
exception when others then
  insert into teste_2jb_resultados values ('pk_ok', false);
  raise notice 'pk_ok: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb_resultados values (
    'rls_ativo',
    coalesce((
      select relrowsecurity from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'teoria_escopos_conteudo'
    ), false)
  );
exception when others then
  insert into teste_2jb_resultados values ('rls_ativo', false);
  raise notice 'rls_ativo: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 3 — privilégios (authenticated/anon sem acesso direto nenhum).
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_2jb_resultados values (
    'authenticated_sem_acesso',
    not has_table_privilege('authenticated', 'public.teoria_escopos_conteudo', 'SELECT,INSERT,UPDATE,DELETE')
  );
exception when others then
  insert into teste_2jb_resultados values ('authenticated_sem_acesso', false);
  raise notice 'authenticated_sem_acesso: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb_resultados values (
    'anon_sem_acesso',
    not has_table_privilege('anon', 'public.teoria_escopos_conteudo', 'SELECT,INSERT,UPDATE,DELETE')
  );
exception when others then
  insert into teste_2jb_resultados values ('anon_sem_acesso', false);
  raise notice 'anon_sem_acesso: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 4 — várias partes compartilhando o MESMO grupo_id, com
-- artigos_esperados deliberadamente omitido (NULL) na parte 1.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id1 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_1');
  v_id2 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_2');
  v_grupo_a uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_a');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id1, v_grupo_a, 1, '[TESTE 2J-B] escopo da parte 1');

  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo, artigos_esperados)
  values (v_id2, v_grupo_a, 2, '[TESTE 2J-B] escopo da parte 2', array['art. 5º', 'art. 7º']);

  insert into teste_2jb_resultados values (
    'grupo_compartilhado_ok',
    (select count(*) = 2 from public.teoria_escopos_conteudo where grupo_id = v_grupo_a)
  );

  insert into teste_2jb_resultados values (
    'artigos_esperados_null_permitido',
    (select artigos_esperados is null from public.teoria_escopos_conteudo where curso_conteudo_id = v_id1)
  );
exception when others then
  insert into teste_2jb_resultados values ('grupo_compartilhado_ok', false);
  insert into teste_2jb_resultados values ('artigos_esperados_null_permitido', false);
  raise notice 'BLOCO 4 (grupo compartilhado) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 5 — grupo_id DIFERENTE pode reusar o mesmo parte_ordem (1) sem
-- conflito nenhum com o grupo A do BLOCO 4.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id3 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_3');
  v_grupo_b uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_b');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id3, v_grupo_b, 1, '[TESTE 2J-B] escopo de outro grupo, mesma parte_ordem=1');

  insert into teste_2jb_resultados values (
    'grupos_diferentes_mesma_parte_ordem_ok',
    (select count(*) = 1 from public.teoria_escopos_conteudo where grupo_id = v_grupo_b and parte_ordem = 1)
  );
exception when others then
  insert into teste_2jb_resultados values ('grupos_diferentes_mesma_parte_ordem_ok', false);
  raise notice 'BLOCO 5 (grupos diferentes) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 6 — mesma curso_conteudo_id não pode ter duas linhas (PK).
-- Reusa v_id1, que já tem uma linha real do BLOCO 4 — a tentativa abaixo
-- TEM que falhar com unique_violation.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id1 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_1');
  v_grupo_b uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_b');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id1, v_grupo_b, 5, '[TESTE 2J-B] tentativa de duplicar curso_conteudo_id');
  insert into teste_2jb_resultados values ('curso_conteudo_id_duplicado_bloqueado', false);
exception
  when unique_violation then
    insert into teste_2jb_resultados values ('curso_conteudo_id_duplicado_bloqueado', true);
  when others then
    insert into teste_2jb_resultados values ('curso_conteudo_id_duplicado_bloqueado', false);
    raise notice 'BLOCO 6 (curso_conteudo_id duplicado): SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 7 — parte_ordem duplicada DENTRO DO MESMO grupo_id é bloqueada
-- (índice único parcial). Usa v_id4 (ainda sem linha nenhuma) tentando
-- entrar no grupo A com parte_ordem=1, já usado por v_id1.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id4 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_4');
  v_grupo_a uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_a');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id4, v_grupo_a, 1, '[TESTE 2J-B] tentativa de parte_ordem duplicada no mesmo grupo');
  insert into teste_2jb_resultados values ('parte_ordem_duplicada_no_grupo_bloqueada', false);
exception
  when unique_violation then
    insert into teste_2jb_resultados values ('parte_ordem_duplicada_no_grupo_bloqueada', true);
  when others then
    insert into teste_2jb_resultados values ('parte_ordem_duplicada_no_grupo_bloqueada', false);
    raise notice 'BLOCO 7 (parte_ordem duplicada): SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 8 — parte_ordem = 0 é rejeitada (CHECK). v_id4 continua livre:
-- o BLOCO 7 falhou, então nada foi persistido para ele (savepoint
-- implícito do PL/pgSQL em EXCEPTION desfaz só aquela tentativa).
-- ---------------------------------------------------------------------------
do $$
declare
  v_id4 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_4');
  v_grupo_a uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_a');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id4, v_grupo_a, 0, '[TESTE 2J-B] tentativa de parte_ordem = 0');
  insert into teste_2jb_resultados values ('parte_ordem_zero_bloqueada', false);
exception
  when check_violation then
    insert into teste_2jb_resultados values ('parte_ordem_zero_bloqueada', true);
  when others then
    insert into teste_2jb_resultados values ('parte_ordem_zero_bloqueada', false);
    raise notice 'BLOCO 8 (parte_ordem = 0): SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 9 — parte_ordem negativa é rejeitada (CHECK). Mesmo raciocínio de
-- v_id4 livre do BLOCO 8.
-- ---------------------------------------------------------------------------
do $$
declare
  v_id4 bigint := (select valor::bigint from teste_2jb_contexto where chave = 'conteudo_id_4');
  v_grupo_a uuid := (select valor::uuid from teste_2jb_contexto where chave = 'grupo_a');
begin
  insert into public.teoria_escopos_conteudo (curso_conteudo_id, grupo_id, parte_ordem, escopo)
  values (v_id4, v_grupo_a, -1, '[TESTE 2J-B] tentativa de parte_ordem negativa');
  insert into teste_2jb_resultados values ('parte_ordem_negativa_bloqueada', false);
exception
  when check_violation then
    insert into teste_2jb_resultados values ('parte_ordem_negativa_bloqueada', true);
  when others then
    insert into teste_2jb_resultados values ('parte_ordem_negativa_bloqueada', false);
    raise notice 'BLOCO 9 (parte_ordem negativa): SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_2jb_resultados where chave = 'tabela_existe') as tabela_existe,
  (select ok from teste_2jb_resultados where chave = 'fk_curso_conteudos_ok') as fk_curso_conteudos_ok,
  (select ok from teste_2jb_resultados where chave = 'pk_ok') as pk_ok,
  (select ok from teste_2jb_resultados where chave = 'rls_ativo') as rls_ativo,
  (select ok from teste_2jb_resultados where chave = 'authenticated_sem_acesso') as authenticated_sem_acesso,
  (select ok from teste_2jb_resultados where chave = 'anon_sem_acesso') as anon_sem_acesso,
  (select ok from teste_2jb_resultados where chave = 'grupo_compartilhado_ok') as grupo_compartilhado_ok,
  (select ok from teste_2jb_resultados where chave = 'artigos_esperados_null_permitido') as artigos_esperados_null_permitido,
  (select ok from teste_2jb_resultados where chave = 'grupos_diferentes_mesma_parte_ordem_ok') as grupos_diferentes_mesma_parte_ordem_ok,
  (select ok from teste_2jb_resultados where chave = 'curso_conteudo_id_duplicado_bloqueado') as curso_conteudo_id_duplicado_bloqueado,
  (select ok from teste_2jb_resultados where chave = 'parte_ordem_duplicada_no_grupo_bloqueada') as parte_ordem_duplicada_no_grupo_bloqueada,
  (select ok from teste_2jb_resultados where chave = 'parte_ordem_zero_bloqueada') as parte_ordem_zero_bloqueada,
  (select ok from teste_2jb_resultados where chave = 'parte_ordem_negativa_bloqueada') as parte_ordem_negativa_bloqueada,
  not exists (select 1 from teste_2jb_resultados where ok is distinct from true) as tudo_ok;

ROLLBACK;
