-- Harness transacional da navegação por unidades. Usa registros reais apenas
-- como referência, cria uma missão temporária e desfaz tudo ao final.
begin;

create temporary table teste_navegacao_unidades_resultados (
  chave text primary key,
  ok boolean not null
);

do $test$
declare
  v_usuario_id uuid;
  v_matricula_id uuid;
  v_conteudo_id bigint;
  v_missao_id uuid;
  v_esperadas integer;
  v_retornadas integer;
  v_ordens integer[];
begin
  select m.usuario_id, m.id, cc.id
  into v_usuario_id, v_matricula_id, v_conteudo_id
  from public.matriculas m
  join public.curso_materias cm on cm.curso_id = m.curso_id
  join public.curso_conteudos cc on cc.curso_materia_id = cm.id
  where m.status = 'ativa'
    and (
      select count(*)
      from public.unidades_pedagogicas u
      join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
      join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
      where u.curso_conteudo_id = cc.id and u.ativa = true
    ) > 1
  order by cc.id
  limit 1;

  if v_matricula_id is null then
    raise exception 'Teste requer uma matricula ativa ligada a um conteudo com mais de uma unidade publicada';
  end if;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '1901-01-01')
  on conflict (matricula_id, conteudo_id, data_missao)
  do update set atualizado_em = public.missoes.atualizado_em
  returning id into v_missao_id;

  perform set_config('request.jwt.claim.sub', v_usuario_id::text, true);

  select count(*)
  into v_esperadas
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id and u.ativa = true;

  select count(*), array_agg(x.unidade_ordem order by x.unidade_ordem)
  into v_retornadas, v_ordens
  from public.carregar_unidades_publicadas_da_missao(v_missao_id) x;

  insert into teste_navegacao_unidades_resultados values
    ('retorna_todas_as_unidades_publicadas', v_retornadas = v_esperadas and v_retornadas > 1),
    ('ordens_sem_repeticao', cardinality(v_ordens) = cardinality(array(select distinct unnest(v_ordens))));
end;
$test$;

insert into teste_navegacao_unidades_resultados values
  ('authenticated_pode_executar', has_function_privilege(
    'authenticated',
    'public.carregar_unidades_publicadas_da_missao(uuid)',
    'EXECUTE'
  )),
  ('anon_nao_pode_executar', not has_function_privilege(
    'anon',
    'public.carregar_unidades_publicadas_da_missao(uuid)',
    'EXECUTE'
  ));

select * from teste_navegacao_unidades_resultados order by chave;
rollback;
