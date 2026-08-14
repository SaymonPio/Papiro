-- Harness transacional do progresso por unidade. Cria uma missão de teste,
-- exercita chamadas reais da RPC e desfaz todas as alterações no final.
begin;

create temporary table teste_progresso_unidades_resultados (
  chave text primary key,
  ok boolean not null
);

do $test$
declare
  v_usuario_id uuid;
  v_matricula_id uuid;
  v_conteudo_id bigint;
  v_missao_id uuid;
  v_versao_id uuid;
  v_total integer;
  v_resultado record;
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
    raise exception 'Teste requer matricula ativa e conteudo com mais de uma unidade publicada';
  end if;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '1901-01-02')
  on conflict (matricula_id, conteudo_id, data_missao)
  do update set progresso_teoria = '{}'::jsonb, status = 'iniciada', teoria_concluida_em = null
  returning id into v_missao_id;

  perform set_config('request.jwt.claim.sub', v_usuario_id::text, true);

  select count(*)::integer
  into v_total
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id and u.ativa = true;

  select av.id
  into v_versao_id
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id and u.ativa = true
  order by u.ordem
  limit 1;

  select * into v_resultado
  from public.registrar_unidade_teoria_concluida(v_missao_id, v_versao_id);

  insert into teste_progresso_unidades_resultados values
    ('primeira_unidade_nao_conclui_teoria',
      v_resultado.unidades_concluidas = 1
      and v_resultado.total_unidades = v_total
      and v_resultado.teoria_concluida = false
      and v_resultado.status = 'iniciada'),
    ('schema_v2_gravado',
      (v_resultado.progresso_teoria -> 'schema_version') = to_jsonb(2::integer)
      and jsonb_array_length(v_resultado.progresso_teoria -> 'unidades_concluidas') = 1);

  select * into v_resultado
  from public.registrar_unidade_teoria_concluida(v_missao_id, v_versao_id);

  insert into teste_progresso_unidades_resultados values
    ('repeticao_idempotente', v_resultado.unidades_concluidas = 1);

  for v_versao_id in
    select av.id
    from public.unidades_pedagogicas u
    join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
    join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
    where u.curso_conteudo_id = v_conteudo_id and u.ativa = true
    order by u.ordem
  loop
    select * into v_resultado
    from public.registrar_unidade_teoria_concluida(v_missao_id, v_versao_id);
  end loop;

  insert into teste_progresso_unidades_resultados values
    ('ultima_unidade_conclui_teoria',
      v_resultado.unidades_concluidas = v_total
      and v_resultado.teoria_concluida = true
      and v_resultado.status = 'teoria_concluida'),
    ('conclusao_preenche_data', exists (
      select 1 from public.missoes
      where id = v_missao_id and teoria_concluida_em is not null
    ));
end;
$test$;

insert into teste_progresso_unidades_resultados values
  ('authenticated_pode_executar', has_function_privilege(
    'authenticated', 'public.registrar_unidade_teoria_concluida(uuid,uuid)', 'EXECUTE'
  )),
  ('anon_nao_pode_executar', not has_function_privilege(
    'anon', 'public.registrar_unidade_teoria_concluida(uuid,uuid)', 'EXECUTE'
  ));

select * from teste_progresso_unidades_resultados order by chave;
rollback;
