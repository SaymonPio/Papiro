-- Pós-check READ-ONLY para rodar DEPOIS de um apply real (futuro) de
-- supabase/async_finalizacao_lease.sql. Mesmo padrão de
-- supabase/pos_check_async_geracao_aula.sql — só SELECTs, nenhuma escrita.

select
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate'
  ) as coluna_existe,
  (select data_type from information_schema.columns where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate') as coluna_tipo,
  (select is_nullable from information_schema.columns where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate') as coluna_nullable,
  (select column_default from information_schema.columns where table_schema='public' and table_name='aula_geracoes' and column_name='finalizacao_lease_ate') as coluna_default,
  (select pg_get_constraintdef(oid) from pg_constraint where conrelid='public.aula_geracoes'::regclass and conname='aula_geracoes_status_check') as status_check_def,
  (select indexdef from pg_indexes where schemaname='public' and tablename='aula_geracoes' and indexname='aula_geracoes_uma_unidade_processando_idx') as indice_trava_def,
  (select count(*) from public.aula_geracoes) as total_linhas,
  (select count(*) from public.aula_geracoes where finalizacao_lease_ate is not null) as linhas_com_lease_ativa;
