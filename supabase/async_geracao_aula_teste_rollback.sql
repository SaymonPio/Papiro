-- ============================================================================
-- TESTE RUNTIME da migration supabase/async_geracao_aula.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN...ROLLBACK)
-- ============================================================================
--
-- Este arquivo é SEPARADO da migration real (que termina em COMMIT e é o
-- arquivo a aplicar de verdade quando chegar a hora). Este aqui só serve
-- para colar no SQL Editor do Supabase, rodar de uma vez, ler o
-- resultado e NUNCA persistir nada.
--
-- O que valida, em ordem:
--   1. PRÉ-CONDIÇÃO: as colunas novas NÃO existem ainda, o CHECK de
--      status continua com exatamente os 3 valores antigos, e o índice
--      de trava é exatamente o esperado — se algo já divergir do estado
--      hoje documentado, aborta ANTES de qualquer ALTER.
--   2. Aplica o corpo exato da migration (sem o COMMIT final).
--   3. Confirma que as colunas novas existem com tipo/nullability/default
--      corretos.
--   4. Confirma que o CHECK de tentativa_ia aceita 1 e 2 (fixtures válidas
--      inseridas e depois desfeitas via RAISE proposital + EXCEPTION —
--      NUNCA via SAVEPOINT/ROLLBACK TO explícito, que não é um statement
--      válido dentro de um bloco PL/pgSQL em nenhum transporte).
--   5. Confirma que o CHECK de tentativa_ia REJEITA 0 e 3 — cada
--      tentativa de INSERT inválido roda dentro de um bloco `begin ...
--      exception when check_violation ... end;` aninhado, cuja
--      subtransação IMPLÍCITA desfaz só aquele INSERT, nunca deixando
--      lixo nem abortando o resto do harness.
--   6. Confirma que o CHECK de status NÃO mudou (continua só
--      'processando'/'concluida'/'erro' — um 4º valor continua sendo
--      rejeitado).
--   7. Confirma que o índice único parcial de trava
--      (aula_geracoes_uma_unidade_processando_idx) continua intacto,
--      mesma definição de antes.
--   8. Confirma que nenhuma linha existente teve status/openai_response_id
--      alterados pela migration (openai_response_id deve ser NULL e
--      tentativa_ia deve ser 1 para todo o histórico).
--   9. UM SELECT final com todas as respostas em colunas booleanas.
--  10. ROLLBACK — desfaz tudo, inclusive as fixtures.

BEGIN;

create temporary table teste_async_resultados (
  chave text primary key,
  ok boolean
);

-- ============================================================================
-- SEÇÃO 1 — PRÉ-CONDIÇÃO: nada disto pode existir ainda.
-- ============================================================================
do $$
declare
  v_problemas text := '';
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes' and column_name='openai_response_id'
  ) then
    v_problemas := v_problemas || 'openai_response_id ja existe; ';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes' and column_name='tentativa_ia'
  ) then
    v_problemas := v_problemas || 'tentativa_ia ja existe; ';
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.aula_geracoes'::regclass
      and conname = 'aula_geracoes_status_check'
      and pg_get_constraintdef(oid) = $CHK$CHECK ((status = ANY (ARRAY['processando'::text, 'concluida'::text, 'erro'::text])))$CHK$
  ) then
    v_problemas := v_problemas || 'CHECK de status diverge do esperado (3 valores antigos); ';
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
-- CORPO DA MIGRATION (idêntico a supabase/async_geracao_aula.sql, sem o
-- COMMIT final)
-- ============================================================================

ALTER TABLE public.aula_geracoes
  ADD COLUMN openai_response_id text NULL;

ALTER TABLE public.aula_geracoes
  ADD COLUMN tentativa_ia smallint NOT NULL DEFAULT 1;

ALTER TABLE public.aula_geracoes
  ADD CONSTRAINT aula_geracoes_tentativa_ia_check
    CHECK (tentativa_ia BETWEEN 1 AND 2);

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- SEÇÃO 3 — colunas existem, com tipo/nullability/default corretos.
-- ---------------------------------------------------------------------------
do $$
declare
  v_col record;
begin
  select data_type, is_nullable, column_default into v_col
  from information_schema.columns
  where table_schema='public' and table_name='aula_geracoes' and column_name='openai_response_id';

  insert into teste_async_resultados values (
    'openai_response_id_ok',
    v_col.data_type = 'text' and v_col.is_nullable = 'YES' and v_col.column_default is null
  );

  select data_type, is_nullable, column_default into v_col
  from information_schema.columns
  where table_schema='public' and table_name='aula_geracoes' and column_name='tentativa_ia';

  insert into teste_async_resultados values (
    'tentativa_ia_ok',
    v_col.data_type = 'smallint' and v_col.is_nullable = 'NO' and v_col.column_default = '1'
  );
exception when others then
  insert into teste_async_resultados values ('openai_response_id_ok', false);
  insert into teste_async_resultados values ('tentativa_ia_ok', false);
  raise notice 'SECAO 3: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 4/5 — CHECK de tentativa_ia aceita 1 e 2, rejeita 0 e 3.
--
-- CORREÇÃO (2ª rodada desta fase): a versão anterior usava SAVEPOINT/
-- ROLLBACK TO SAVEPOINT como comandos SQL soltos dentro de um bloco
-- `do $$ ... $$`. Isso NUNCA é válido em PL/pgSQL, em nenhum transporte
-- — SAVEPOINT/ROLLBACK TO são comandos de controle de transação do SQL
-- de topo, não statements PL/pgSQL, e um bloco PL/pgSQL não pode emiti-
-- los diretamente (reproduzido isoladamente: "ERROR 42601: syntax error
-- at or near "to"", o MESMO erro que abortou a rodada anterior — não era
-- um artefato do splitter da Management API, era um erro real de SQL).
--
-- Correção: cada tentativa agora usa um bloco `begin ... exception when
-- ... end;` ANINHADO simples — o idioma padrão documentado pelo Postgres
-- para "tente e desfaça só isto se der erro". Cada bloco assim cria uma
-- subtransação IMPLÍCITA sozinho (internamente equivalente a um
-- SAVEPOINT automático); nenhum SAVEPOINT explícito é necessário nem
-- válido aqui.
--
-- Para "rejeita 0/3", o INSERT inválido já dispara check_violation
-- (23514) de verdade — a cláusula EXCEPTION captura e desfaz só aquele
-- INSERT automaticamente.
--
-- Para "aceita 1/2", os INSERTs são válidos (não geram exceção sozinhos),
-- então preciso de um jeito de desfazê-los ANTES da Seção 8 rodar (senão
-- ficariam na tabela até o ROLLBACK final do arquivo inteiro e quebrariam
-- "historico_intacto", que audita tentativa_ia<>1 em TODA a tabela). A
-- forma correta em PL/pgSQL puro (sem SAVEPOINT explícito) é forçar o
-- próprio bloco a levantar uma exceção proposital DEPOIS dos inserts
-- (RAISE EXCEPTION, SQLSTATE padrão P0001/"raise_exception") — isso aciona
-- a mesma subtransação implícita do bloco, desfazendo só os 2 INSERTs
-- acima dela, e a cláusula EXCEPTION distingue esse sinal proposital (pela
-- mensagem exata) de um erro genuíno inesperado.
do $$
declare
  v_admin_id uuid;
  v_conteudo_id bigint;
  v_unidade_id uuid;
begin
  select id into v_admin_id from auth.users order by created_at limit 1;
  select cc.id, u.id into v_conteudo_id, v_unidade_id
    from public.curso_conteudos cc
    join public.unidades_pedagogicas u on u.curso_conteudo_id = cc.id
    limit 1;

  if v_admin_id is null or v_conteudo_id is null then
    insert into teste_async_resultados values ('tentativa_ia_aceita_1_e_2', null);
    insert into teste_async_resultados values ('tentativa_ia_rejeita_0', null);
    insert into teste_async_resultados values ('tentativa_ia_rejeita_3', null);
    raise notice 'SECAO 4/5 pulada: nenhum usuario e/ou curso_conteudos/unidade_pedagogica real encontrado neste banco.';
    return;
  end if;

  -- aceita 1 e 2 — insere as 2 fixtures válidas, confirma que nenhuma foi
  -- rejeitada, e então desfaz só essas 2 linhas (via RAISE proposital +
  -- EXCEPTION, nunca SAVEPOINT explícito) antes de seguir para a Seção 8.
  begin
    insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, tentativa_ia)
    values (v_conteudo_id, v_unidade_id, 'erro', v_admin_id, '[TESTE-ASYNC]', 1);
    insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, tentativa_ia)
    values (v_conteudo_id, v_unidade_id, 'erro', v_admin_id, '[TESTE-ASYNC]', 2);
    raise exception 'fixture_aceita_1_e_2_ok';
  exception
    when raise_exception then
      if sqlerrm = 'fixture_aceita_1_e_2_ok' then
        insert into teste_async_resultados values ('tentativa_ia_aceita_1_e_2', true);
      else
        insert into teste_async_resultados values ('tentativa_ia_aceita_1_e_2', false);
        raise notice 'tentativa_ia_aceita_1_e_2: mensagem inesperada=%', sqlerrm;
      end if;
    when others then
      insert into teste_async_resultados values ('tentativa_ia_aceita_1_e_2', false);
      raise notice 'tentativa_ia_aceita_1_e_2: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
  end;

  -- rejeita 0 — o INSERT deve violar a constraint sozinho; a subtransação
  -- implícita do bloco desfaz só esse INSERT.
  begin
    insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, tentativa_ia)
    values (v_conteudo_id, v_unidade_id, 'erro', v_admin_id, '[TESTE-ASYNC]', 0);
    insert into teste_async_resultados values ('tentativa_ia_rejeita_0', false); -- não deveria chegar aqui
  exception
    when check_violation then
      insert into teste_async_resultados values ('tentativa_ia_rejeita_0', true);
    when others then
      insert into teste_async_resultados values ('tentativa_ia_rejeita_0', false);
      raise notice 'tentativa_ia_rejeita_0: SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
  end;

  -- rejeita 3 — mesmo padrão.
  begin
    insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, tentativa_ia)
    values (v_conteudo_id, v_unidade_id, 'erro', v_admin_id, '[TESTE-ASYNC]', 3);
    insert into teste_async_resultados values ('tentativa_ia_rejeita_3', false); -- não deveria chegar aqui
  exception
    when check_violation then
      insert into teste_async_resultados values ('tentativa_ia_rejeita_3', true);
    when others then
      insert into teste_async_resultados values ('tentativa_ia_rejeita_3', false);
      raise notice 'tentativa_ia_rejeita_3: SQLSTATE inesperado=%, erro=%', sqlstate, sqlerrm;
  end;
exception when others then
  insert into teste_async_resultados values ('tentativa_ia_aceita_1_e_2', false);
  insert into teste_async_resultados values ('tentativa_ia_rejeita_0', false);
  insert into teste_async_resultados values ('tentativa_ia_rejeita_3', false);
  raise notice 'SECAO 4/5 (setup) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 6 — CHECK de status não mudou (continua só os 3 valores antigos).
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_async_resultados values (
    'status_check_inalterado',
    exists (
      select 1 from pg_constraint
      where conrelid = 'public.aula_geracoes'::regclass
        and conname = 'aula_geracoes_status_check'
        and pg_get_constraintdef(oid) = $CHK$CHECK ((status = ANY (ARRAY['processando'::text, 'concluida'::text, 'erro'::text])))$CHK$
    )
  );
exception when others then
  insert into teste_async_resultados values ('status_check_inalterado', false);
  raise notice 'status_check_inalterado: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 7 — índice de trava continua intacto (mesma definição).
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_async_resultados values (
    'indice_trava_intacto',
    exists (
      select 1 from pg_indexes
      where schemaname='public' and tablename='aula_geracoes'
        and indexname='aula_geracoes_uma_unidade_processando_idx'
        and indexdef ilike '%UNIQUE INDEX%(unidade_pedagogica_id)%WHERE (status = ''processando''::text)%'
    )
  );
exception when others then
  insert into teste_async_resultados values ('indice_trava_intacto', false);
  raise notice 'indice_trava_intacto: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 8 — nenhuma linha histórica foi alterada pela migration.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_async_resultados values (
    'historico_intacto',
    not exists (
      select 1 from public.aula_geracoes
      where openai_response_id is not null or tentativa_ia <> 1
    )
  );
exception when others then
  insert into teste_async_resultados values ('historico_intacto', false);
  raise notice 'historico_intacto: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_async_resultados where chave = 'openai_response_id_ok') as openai_response_id_ok,
  (select ok from teste_async_resultados where chave = 'tentativa_ia_ok') as tentativa_ia_ok,
  (select ok from teste_async_resultados where chave = 'tentativa_ia_aceita_1_e_2') as tentativa_ia_aceita_1_e_2,
  (select ok from teste_async_resultados where chave = 'tentativa_ia_rejeita_0') as tentativa_ia_rejeita_0,
  (select ok from teste_async_resultados where chave = 'tentativa_ia_rejeita_3') as tentativa_ia_rejeita_3,
  (select ok from teste_async_resultados where chave = 'status_check_inalterado') as status_check_inalterado,
  (select ok from teste_async_resultados where chave = 'indice_trava_intacto') as indice_trava_intacto,
  (select ok from teste_async_resultados where chave = 'historico_intacto') as historico_intacto,
  not exists (
    select 1 from teste_async_resultados where ok is distinct from true and ok is not null
  ) as tudo_ok;

ROLLBACK;
