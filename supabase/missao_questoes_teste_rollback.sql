begin;
create temporary table teste_missao_questoes_resultados(chave text primary key,ok boolean not null);

do $$
declare
  v_usuario uuid;
  v_matricula uuid;
  v_conteudo bigint;
  v_questao bigint;
  v_alternativa bigint;
  v_missao uuid;
  v_sessao bigint;
  v_inicio record;
  v_fim record;
  v_progresso jsonb;
  v_bloqueou boolean:=false;
begin
  select m.usuario_id,m.id,cc.id,q.id,a.id
  into v_usuario,v_matricula,v_conteudo,v_questao,v_alternativa
  from public.matriculas m
  join public.curso_materias cm on cm.curso_id=m.curso_id
  join public.curso_conteudos cc on cc.curso_materia_id=cm.id
  join public.curso_questoes cq on cq.curso_id=m.curso_id
  join public.questoes q on q.id=cq.questao_id and q.ativa and q.materia_id=cm.materia_id
  join public.alternativas a on a.questao_id=q.id
  where m.status='ativa'
    and exists (
      select 1 from public.unidades_pedagogicas u
      join public.aulas au on au.unidade_pedagogica_id=u.id and au.ativa
      join public.aula_versoes av on av.aula_id=au.id and av.status='publicada'
      where u.curso_conteudo_id=cc.id and u.ativa
    )
  order by cc.id,q.id,a.ordem
  limit 1;
  if v_usuario is null then raise exception 'Harness requer aluno, conteudo publicado e questao ativa'; end if;

  select jsonb_build_object(
    'schema_version',2,
    'unidades_concluidas',jsonb_agg(jsonb_build_object(
      'unidade_pedagogica_id',x.unidade_id::text,
      'aula_versao_id',x.versao_id::text
    ) order by x.ordem)
  ) into v_progresso
  from (
    select distinct on (u.id) u.id unidade_id,av.id versao_id,u.ordem
    from public.unidades_pedagogicas u
    join public.aulas au on au.unidade_pedagogica_id=u.id and au.ativa
    join public.aula_versoes av on av.aula_id=au.id and av.status='publicada'
    where u.curso_conteudo_id=v_conteudo and u.ativa
    order by u.id,u.ordem
  ) x;

  insert into public.missoes(matricula_id,conteudo_id,data_missao,status,progresso_teoria,teoria_concluida_em)
  values(v_matricula,v_conteudo,date '1901-01-04','teoria_concluida',v_progresso,now())
  returning id into v_missao;
  perform set_config('request.jwt.claim.sub',v_usuario::text,true);

  select * into v_inicio from public.iniciar_questoes_da_missao(v_missao,array[v_questao]);
  v_sessao:=v_inicio.sessao_id;
  insert into teste_missao_questoes_resultados values
    ('inicio_avanca_status',v_inicio.missao_status='questoes_iniciadas'),
    ('sessao_vinculada',exists(select 1 from public.sessoes_estudo s where s.id=v_sessao and s.missao_id=v_missao)),
    ('lista_planejada_congelada',exists(select 1 from public.sessao_questoes_planejadas sq where sq.sessao_id=v_sessao and sq.questao_id=v_questao));

  select * into v_inicio from public.iniciar_questoes_da_missao(v_missao,array[v_questao]);
  insert into teste_missao_questoes_resultados values ('inicio_idempotente',v_inicio.sessao_id=v_sessao and v_inicio.recuperada);

  perform * from public.registrar_resposta(v_questao,v_alternativa,v_sessao,null);
  begin
    perform * from public.registrar_resposta(v_questao,v_alternativa,v_sessao,null);
  exception when others then v_bloqueou:=true;
  end;
  insert into teste_missao_questoes_resultados values ('resposta_duplicada_bloqueada',v_bloqueou);

  select * into v_fim from public.concluir_questoes_da_missao(v_missao,v_sessao);
  insert into teste_missao_questoes_resultados values
    ('conclusao_avanca_missao',v_fim.missao_status='concluida' and exists(select 1 from public.missoes where id=v_missao and concluida_em is not null)),
    ('conclusao_fecha_sessao',v_fim.sessao_status='concluida' and exists(select 1 from public.sessoes_estudo where id=v_sessao and fim_em is not null));

  insert into teste_missao_questoes_resultados values
    ('anon_sem_rpc',not has_function_privilege('anon','public.iniciar_questoes_da_missao(uuid,bigint[],boolean)','execute')),
    ('authenticated_com_rpc',has_function_privilege('authenticated','public.iniciar_questoes_da_missao(uuid,bigint[],boolean)','execute')),
    ('tabela_planejada_fechada',not has_table_privilege('authenticated','public.sessao_questoes_planejadas','select')),
    ('policy_all_legada_removida',not exists(select 1 from pg_policies where schemaname='public' and tablename='sessoes_estudo' and cmd='ALL'));
end;
$$;

table teste_missao_questoes_resultados;
rollback;
