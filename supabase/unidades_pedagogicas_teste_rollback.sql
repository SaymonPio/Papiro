-- Harness runtime não destrutivo da Fase 2J-C. Execute somente depois das
-- duas migrations 2J-C; tudo é revertido ao final.
begin;

do $$
declare
  v_conteudo_a bigint;
  v_conteudo_b bigint;
  v_unidade uuid;
  v_ordem integer;
  v_bloqueou_mismatch boolean := false;
begin
  select id into v_conteudo_a from public.curso_conteudos order by id limit 1;
  select id into v_conteudo_b from public.curso_conteudos where id <> v_conteudo_a order by id limit 1;
  if v_conteudo_a is null or v_conteudo_b is null then
    raise exception 'Teste 2J-C exige ao menos dois curso_conteudos reais';
  end if;

  if exists (
    select 1 from public.curso_conteudos cc
    where not exists (select 1 from public.unidades_pedagogicas u where u.curso_conteudo_id=cc.id)
  ) then raise exception 'Backfill não cobriu todos os curso_conteudos'; end if;

  select coalesce(max(ordem),0)+1 into v_ordem
  from public.unidades_pedagogicas where curso_conteudo_id=v_conteudo_a;
  insert into public.unidades_pedagogicas(curso_conteudo_id,titulo,ordem,escopo)
  values(v_conteudo_a,'Unidade teste 2J-C',v_ordem,'Escopo teste 2J-C') returning id into v_unidade;

  begin
    insert into public.aulas(conteudo_id,unidade_pedagogica_id,titulo)
    values(v_conteudo_b,v_unidade,'Mismatch que deve falhar');
  exception when foreign_key_violation then
    v_bloqueou_mismatch := true;
  end;
  if not v_bloqueou_mismatch then
    raise exception 'FK composta aceitou unidade de outro curso_conteudo';
  end if;

  insert into public.aulas(conteudo_id,unidade_pedagogica_id,titulo)
  values(v_conteudo_a,v_unidade,'Aula teste 2J-C');

  if not exists (
    select 1 from pg_indexes where schemaname='public'
      and indexname='aula_geracoes_uma_unidade_processando_idx'
  ) then raise exception 'Trava de geração por unidade não existe'; end if;
end;
$$;

rollback;
