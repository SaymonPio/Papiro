-- Pós-check READ-ONLY de supabase/async_geracao_aula.sql — rodar depois
-- do apply real em produção. Nenhum INSERT/UPDATE/DELETE/DDL — só
-- SELECT. Seguro de rodar quantas vezes quiser.

select
  -- colunas existem com tipo/nullability/default corretos
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes'
      and column_name='openai_response_id' and data_type='text' and is_nullable='YES'
  ) as openai_response_id_ok,

  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes'
      and column_name='tentativa_ia' and data_type='smallint' and is_nullable='NO' and column_default='1'
  ) as tentativa_ia_ok,

  -- constraint de tentativa_ia existe com a definição esperada
  exists (
    select 1 from pg_constraint
    where conrelid = 'public.aula_geracoes'::regclass
      and conname = 'aula_geracoes_tentativa_ia_check'
      and pg_get_constraintdef(oid) ilike '%tentativa_ia >= 1%tentativa_ia <= 2%'
  ) as tentativa_ia_check_ok,

  -- CHECK de status NÃO mudou (continua só os 3 valores antigos)
  exists (
    select 1 from pg_constraint
    where conrelid = 'public.aula_geracoes'::regclass
      and conname = 'aula_geracoes_status_check'
      and pg_get_constraintdef(oid) = $CHK$CHECK ((status = ANY (ARRAY['processando'::text, 'concluida'::text, 'erro'::text])))$CHK$
  ) as status_check_inalterado,

  -- índice de trava continua intacto
  exists (
    select 1 from pg_indexes
    where schemaname='public' and tablename='aula_geracoes'
      and indexname='aula_geracoes_uma_unidade_processando_idx'
      and indexdef ilike '%UNIQUE INDEX%(unidade_pedagogica_id)%WHERE (status = ''processando''::text)%'
  ) as indice_trava_intacto,

  -- nenhuma linha histórica foi tocada
  not exists (
    select 1 from public.aula_geracoes
    where openai_response_id is not null or tentativa_ia <> 1
  ) as historico_intacto,

  (select count(*) from public.aula_geracoes) as total_linhas_aula_geracoes;
