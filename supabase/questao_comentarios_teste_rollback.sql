-- Harness transacional: usa um aluno/questão já ligados por matrícula ativa e
-- desfaz o comentário de teste ao final.
begin;

create temporary table teste_questao_comentarios_resultados (
  chave text primary key,
  ok boolean not null
) on commit drop;

do $$
declare
  v_usuario uuid;
  v_questao bigint;
  v_comentario uuid;
  v_listado boolean;
  v_removido boolean;
begin
  select m.usuario_id,cq.questao_id
  into v_usuario,v_questao
  from public.matriculas m
  join public.curso_questoes cq on cq.curso_id=m.curso_id
  join public.questoes q on q.id=cq.questao_id and q.ativa
  where m.status='ativa'
  order by m.matriculado_em desc nulls last
  limit 1;

  if v_usuario is null or v_questao is null then
    raise exception 'Nenhum aluno com questao ativa no curso para executar o harness';
  end if;

  insert into teste_questao_comentarios_resultados values
    ('tabela_sem_acesso_direto',
      not has_table_privilege('authenticated','public.questao_comentarios','select')
      and not has_table_privilege('authenticated','public.questao_comentarios','insert')),
    ('anon_sem_rpc',
      not has_function_privilege('anon','public.listar_comentarios_questao(bigint)','execute')
      and not has_function_privilege('anon','public.comentar_questao(bigint,text)','execute')),
    ('authenticated_com_rpc',
      has_function_privilege('authenticated','public.listar_comentarios_questao(bigint)','execute')
      and has_function_privilege('authenticated','public.comentar_questao(bigint,text)','execute'));

  perform set_config('request.jwt.claim.sub',v_usuario::text,true);

  insert into teste_questao_comentarios_resultados
  values ('matricula_autoriza_questao',public.usuario_pode_comentar_questao(v_questao,v_usuario));

  v_comentario := public.comentar_questao(v_questao,'Comentário temporário do harness');
  select exists (
    select 1 from public.listar_comentarios_questao(v_questao) c
    where c.comentario_id=v_comentario and c.meu
  ) into v_listado;
  insert into teste_questao_comentarios_resultados values ('comentario_listado_como_meu',v_listado);

  v_removido := public.remover_meu_comentario_questao(v_comentario);
  insert into teste_questao_comentarios_resultados values ('autor_remove_proprio_comentario',v_removido);
  insert into teste_questao_comentarios_resultados
  values ('comentario_removido_some_da_leitura',not exists (
    select 1 from public.listar_comentarios_questao(v_questao) c
    where c.comentario_id=v_comentario
  ));
end;
$$;

table teste_questao_comentarios_resultados;
rollback;
