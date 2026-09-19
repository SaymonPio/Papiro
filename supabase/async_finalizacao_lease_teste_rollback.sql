-- ============================================================================
-- TESTE RUNTIME da migration supabase/async_finalizacao_lease.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN...ROLLBACK)
-- ============================================================================
--
-- Mesmo princípio de supabase/async_geracao_aula_teste_rollback.sql:
-- colar no SQL Editor (ou `supabase db query --linked -f ...`), rodar de
-- uma vez, ler o resultado, nunca persistir nada.
--
-- Lição aplicada aqui (achado real da fase anterior): SAVEPOINT/ROLLBACK
-- TO SAVEPOINT como comandos SQL soltos dentro de um bloco `do $$...$$`
-- NUNCA é válido em PL/pgSQL — não é uma peculiaridade de transporte, é
-- erro de sintaxe real (42601). Esta migration não precisa testar
-- violação de nenhuma constraint (a coluna é só nullable, sem CHECK), então
-- este harness nem chega a precisar do idioma "begin...exception...end"
-- aninhado — só validações de leitura (information_schema/pg_constraint/
-- pg_indexes), sem nenhum INSERT/violação proposital.
--
-- O que valida, em ordem:
--   1. PRÉ-CONDIÇÃO: a coluna nova NÃO existe ainda, e o CHECK de status e
--      o índice de trava continuam exatamente como o estado hoje
--      documentado — se algo já divergir, aborta ANTES de qualquer ALTER.
--   2. Aplica o corpo exato da migration (sem o COMMIT final).
--   3. Confirma que a coluna existe com tipo/nullability/default corretos.
--   4. Confirma que TODAS as linhas existentes ficam com a coluna NULL
--      (nenhuma linha "ganha" um valor por causa da migration).
--   5. Confirma que o CHECK de status NÃO mudou.
--   6. Confirma que o índice de trava continua intacto.
--   7. UM SELECT final com todas as respostas em colunas booleanas.
--   8. ROLLBACK — desfaz tudo.

BEGIN;

create temporary table teste_lease_resultados (
  chave text primary key,
  ok boolean
);

-- ============================================================================
-- SEÇÃO 1 — PRÉ-CONDIÇÃO: a coluna nova não pode existir ainda.
-- ============================================================================
do $$
declare
  v_problemas text := '';
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate'
  ) then
    v_problemas := v_problemas || 'finalizacao_lease_ate ja existe; ';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.aula_geracoes'::regclass
      and conname = 'aula_geracoes_status_check'
      and pg_get_constraintdef(oid) = $CHK$CHECK ((status = ANY (ARRAY['processando'::text, 'concluida'::text, 'erro'::text])))$CHK$
  ) then
    v_problemas := v_problemas || 'CHECK de status diverge do esperado; ';
  end if;

  if not exists (
    select 1 from pg_indexes
    where schemaname='public' and tablename='aula_geracoes'
      and indexname='aula_geracoes_uma_unidade_processando_idx'
  ) then
    v_problemas := v_problemas || 'indice de trava esperado nao encontrado; ';
  end if;

  if v_problemas <> '' then
    raise exception 'PRE-CONDICAO falhou: %. Harness abortado ANTES de qualquer ALTER — nada foi alterado.', v_problemas;
  end if;
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/async_finalizacao_lease.sql,
-- sem o COMMIT final)
-- ============================================================================

ALTER TABLE public.aula_geracoes
  ADD COLUMN finalizacao_lease_ate timestamptz NULL;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- SEÇÃO 3 — coluna existe, com tipo/nullability/default corretos.
-- ---------------------------------------------------------------------------
do $$
declare
  v_col record;
begin
  select data_type, is_nullable, column_default into v_col
  from information_schema.columns
  where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate';

  insert into teste_lease_resultados values (
    'coluna_ok',
    v_col.data_type = 'timestamp with time zone' and v_col.is_nullable = 'YES' and v_col.column_default is null
  );
exception when others then
  insert into teste_lease_resultados values ('coluna_ok', false);
  raise notice 'SECAO 3: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 4 — todas as linhas existentes ficam com a coluna NULL.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_lease_resultados values (
    'historico_null',
    not exists (select 1 from public.aula_geracoes where finalizacao_lease_ate is not null)
  );
exception when others then
  insert into teste_lease_resultados values ('historico_null', false);
  raise notice 'SECAO 4: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 5 — CHECK de status não mudou.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_lease_resultados values (
    'status_check_inalterado',
    exists (
      select 1 from pg_constraint
      where conrelid = 'public.aula_geracoes'::regclass
        and conname = 'aula_geracoes_status_check'
        and pg_get_constraintdef(oid) = $CHK$CHECK ((status = ANY (ARRAY['processando'::text, 'concluida'::text, 'erro'::text])))$CHK$
    )
  );
exception when others then
  insert into teste_lease_resultados values ('status_check_inalterado', false);
  raise notice 'SECAO 5: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 6 — índice de trava continua intacto.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_lease_resultados values (
    'indice_trava_intacto',
    exists (
      select 1 from pg_indexes
      where schemaname='public' and tablename='aula_geracoes'
        and indexname='aula_geracoes_uma_unidade_processando_idx'
        and indexdef ilike '%UNIQUE INDEX%(unidade_pedagogica_id)%WHERE (status = ''processando''::text)%'
    )
  );
exception when others then
  insert into teste_lease_resultados values ('indice_trava_intacto', false);
  raise notice 'SECAO 6: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_lease_resultados where chave = 'coluna_ok') as coluna_ok,
  (select ok from teste_lease_resultados where chave = 'historico_null') as historico_null,
  (select ok from teste_lease_resultados where chave = 'status_check_inalterado') as status_check_inalterado,
  (select ok from teste_lease_resultados where chave = 'indice_trava_intacto') as indice_trava_intacto,
  not exists (
    select 1 from teste_lease_resultados where ok is distinct from true
  ) as tudo_ok;

ROLLBACK;
