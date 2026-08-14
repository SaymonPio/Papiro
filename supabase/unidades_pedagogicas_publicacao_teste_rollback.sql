-- Harness runtime da publicação 2J-C. Tudo é revertido ao final.
begin;
do $$
declare v_conteudo bigint; v_unidade uuid; v_aula uuid; v_v1 uuid; v_v2 uuid;
begin
  select curso_conteudo_id into v_conteudo from public.unidades_pedagogicas order by criado_em limit 1;
  insert into public.unidades_pedagogicas(curso_conteudo_id,titulo,ordem,escopo)
  select v_conteudo,'Teste publicação 2J-C',max(ordem)+1,'Escopo teste'
  from public.unidades_pedagogicas where curso_conteudo_id=v_conteudo returning id into v_unidade;
  insert into public.aulas(conteudo_id,unidade_pedagogica_id,titulo)
  values(v_conteudo,v_unidade,'Aula teste publicação') returning id into v_aula;
  insert into public.aula_versoes(aula_id,numero_versao,status,estrutura,publicado_em)
  values(v_aula,1,'publicada','{}',now()-interval '1 day') returning id into v_v1;
  insert into public.aula_versoes(aula_id,numero_versao,status,estrutura)
  values(v_aula,2,'rascunho','{}') returning id into v_v2;

  -- Simula o núcleo transacional da RPC sem depender de auth.uid no harness.
  update public.aula_versoes set status='arquivada' where aula_id=v_aula and status='publicada';
  update public.aula_versoes set status='publicada',publicado_em=now() where id=v_v2;
  if (select status from public.aula_versoes where id=v_v1) <> 'arquivada'
    or (select status from public.aula_versoes where id=v_v2) <> 'publicada'
    or (select count(*) from public.aula_versoes where aula_id=v_aula and status='publicada') <> 1
  then raise exception 'Troca transacional de publicação falhou'; end if;
end;
$$;
rollback;
