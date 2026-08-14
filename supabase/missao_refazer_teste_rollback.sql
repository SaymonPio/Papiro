begin;
create temporary table teste_refazer_missao_resultados(chave text primary key,ok boolean not null);

do $$
declare
  v_usuario uuid;
  v_matricula uuid;
  v_conteudo bigint;
  v_questao bigint;
  v_alternativa bigint;
  v_missao uuid;
  v_primeira_sessao bigint;
  v_nova_sessao bigint;
  v_inicio record;
  v_progresso jsonb;
  v_concluida_em timestamptz;
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
  values(v_matricula,v_conteudo,date '1901-01-05','teoria_concluida',v_progresso,now())
  returning id into v_missao;
  perform set_config('request.jwt.claim.sub',v_usuario::text,true);

  select * into v_inicio
  from public.iniciar_questoes_da_missao(v_missao,array[v_questao],false);
  v_primeira_sessao:=v_inicio.sessao_id;
  perform * from public.registrar_resposta(v_questao,v_alternativa,v_primeira_sessao,null);
  perform * from public.concluir_questoes_da_missao(v_missao,v_primeira_sessao);
  select concluida_em into v_concluida_em from public.missoes where id=v_missao;

  select * into v_inicio
  from public.iniciar_questoes_da_missao(v_missao,array[v_questao],true);
  v_nova_sessao:=v_inicio.sessao_id;

  insert into teste_refazer_missao_resultados values
    ('nova_sessao_criada',v_nova_sessao<>v_primeira_sessao and not v_inicio.recuperada),
    ('historico_preservado',exists(select 1 from public.sessoes_estudo where id=v_primeira_sessao and status='concluida')),
    ('missao_permanece_concluida',v_inicio.missao_status='concluida' and exists(select 1 from public.missoes where id=v_missao and status='concluida')),
    ('duas_sessoes_na_missao',(select count(*) from public.sessoes_estudo where missao_id=v_missao)=2);

  select * into v_inicio
  from public.iniciar_questoes_da_missao(v_missao,array[v_questao],true);
  insert into teste_refazer_missao_resultados values
    ('refazer_idempotente_em_andamento',v_inicio.sessao_id=v_nova_sessao and v_inicio.recuperada);

  perform * from public.registrar_resposta(v_questao,v_alternativa,v_nova_sessao,null);
  perform * from public.concluir_questoes_da_missao(v_missao,v_nova_sessao);

  insert into teste_refazer_missao_resultados values
    ('nova_tentativa_concluida',exists(select 1 from public.sessoes_estudo where id=v_nova_sessao and status='concluida' and fim_em is not null)),
    ('conclusao_original_preservada',(select concluida_em from public.missoes where id=v_missao)=v_concluida_em),
    ('indice_unico_removido',to_regclass('public.sessoes_estudo_missao_unica_idx') is null),
    ('authenticated_com_rpc_refazer',has_function_privilege('authenticated','public.iniciar_questoes_da_missao(uuid,bigint[],boolean)','execute')),
    ('anon_sem_rpc_refazer',not has_function_privilege('anon','public.iniciar_questoes_da_missao(uuid,bigint[],boolean)','execute'));
end;
$$;

table teste_refazer_missao_resultados;
rollback;
