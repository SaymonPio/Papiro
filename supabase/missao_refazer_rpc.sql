-- Permite novas tentativas de uma missão já concluída sem apagar a primeira
-- sessão, respostas, estatísticas ou o selo de conclusão da missão.
begin;

drop index if exists public.sessoes_estudo_missao_unica_idx;

drop function if exists public.iniciar_questoes_da_missao(uuid,bigint[]);

create function public.iniciar_questoes_da_missao(
  p_missao_id uuid,
  p_questao_ids bigint[],
  p_refazer boolean default false
)
returns table (
  sessao_id bigint,
  sessao_status text,
  missao_status text,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid:=auth.uid();
  v_matricula_id uuid;
  v_conteudo_id bigint;
  v_status_missao text;
  v_progresso jsonb;
  v_data_missao date;
  v_curso_id uuid;
  v_materia_id bigint;
  v_sessao_id bigint;
  v_sessao_status text;
  v_ids bigint[];
  v_total_ids integer;
  v_total_validas integer;
  v_total_unidades integer;
  v_total_concluidas integer;
begin
  if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;

  select ms.matricula_id,ms.conteudo_id,ms.status,ms.progresso_teoria,
         ms.data_missao,m.curso_id,cm.materia_id
  into v_matricula_id,v_conteudo_id,v_status_missao,v_progresso,
       v_data_missao,v_curso_id,v_materia_id
  from public.missoes ms
  join public.matriculas m on m.id=ms.matricula_id
  join public.curso_conteudos cc on cc.id=ms.conteudo_id
  join public.curso_materias cm on cm.id=cc.curso_materia_id and cm.curso_id=m.curso_id
  where ms.id=p_missao_id and m.usuario_id=v_usuario_id and m.status='ativa'
  for update of ms;

  if v_matricula_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario, ou a matricula nao esta ativa';
  end if;
  if v_status_missao='abandonada' then raise exception 'Missao abandonada'; end if;
  if p_refazer and v_status_missao<>'concluida' then
    raise exception 'A missao precisa estar concluida antes de ser refeita';
  end if;
  if not p_refazer and v_status_missao='iniciada' then
    raise exception 'Conclua a teoria antes de iniciar as questoes';
  end if;

  -- Na primeira execução, recupera qualquer sessão já ligada à missão.
  -- Ao refazer, recupera somente a nova tentativa ainda em andamento; uma
  -- tentativa já concluída nunca impede a criação da próxima.
  select s.id,s.status
  into v_sessao_id,v_sessao_status
  from public.sessoes_estudo s
  where s.missao_id=p_missao_id
    and (not p_refazer or s.status='em_andamento')
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id=v_sessao_id;

    if coalesce(cardinality(v_ids),0)=0 then
      raise exception 'Sessao da missao sem lista de questoes planejadas';
    end if;

    return query select v_sessao_id,v_sessao_status,v_status_missao,v_ids,true;
    return;
  end if;

  if not p_refazer and v_status_missao<>'teoria_concluida' then
    raise exception 'Estado da missao incompativel com o inicio das questoes';
  end if;

  -- A primeira tentativa continua exigindo o progresso formal da teoria.
  -- A repetição já parte de uma missão concluída e não reescreve o histórico
  -- pedagógico original, inclusive se uma aula ganhou versão nova depois.
  if not p_refazer then
    if jsonb_typeof(v_progresso)<>'object'
       or (v_progresso->'schema_version') is distinct from to_jsonb(2::integer)
       or jsonb_typeof(v_progresso->'unidades_concluidas')<>'array' then
      raise exception 'Progresso da teoria invalido';
    end if;

    select count(distinct u.id)::integer
    into v_total_unidades
    from public.unidades_pedagogicas u
    join public.aulas a on a.unidade_pedagogica_id=u.id and a.ativa
    join public.aula_versoes av on av.aula_id=a.id and av.status='publicada'
    where u.curso_conteudo_id=v_conteudo_id and u.ativa;

    select count(distinct u.id)::integer
    into v_total_concluidas
    from jsonb_array_elements(v_progresso->'unidades_concluidas') item
    join public.unidades_pedagogicas u
      on item->>'unidade_pedagogica_id'=u.id::text
     and u.curso_conteudo_id=v_conteudo_id and u.ativa
    join public.aulas a on a.unidade_pedagogica_id=u.id and a.ativa
    join public.aula_versoes av
      on av.aula_id=a.id and av.status='publicada'
     and item->>'aula_versao_id'=av.id::text;

    if v_total_unidades=0 or v_total_concluidas<>v_total_unidades then
      raise exception 'Conclua todas as unidades publicadas antes de iniciar as questoes';
    end if;
  end if;

  v_total_ids:=coalesce(cardinality(p_questao_ids),0);
  if v_total_ids not between 1 and 100 then
    raise exception 'A missao deve ter entre 1 e 100 questoes';
  end if;
  if (select count(distinct x) from unnest(p_questao_ids) x)<>v_total_ids then
    raise exception 'Lista de questoes duplicada ou invalida';
  end if;

  select count(*)::integer
  into v_total_validas
  from unnest(p_questao_ids) x(questao_id)
  join public.questoes q on q.id=x.questao_id and q.ativa and q.materia_id=v_materia_id
  join public.curso_questoes cq on cq.questao_id=q.id and cq.curso_id=v_curso_id;

  if v_total_validas<>v_total_ids then
    raise exception 'Uma ou mais questoes nao pertencem a materia e ao curso da missao';
  end if;

  insert into public.sessoes_estudo(
    usuario_id,matricula_id,missao_id,data_sessao,nivel_meta,status,
    inicio_em,minutos_revisao,questoes_planejadas
  ) values (
    v_usuario_id,v_matricula_id,p_missao_id,v_data_missao,'personalizada','em_andamento',
    now(),0,v_total_ids
  ) returning id,status into v_sessao_id,v_sessao_status;

  insert into public.sessao_questoes_planejadas(sessao_id,questao_id,ordem)
  select v_sessao_id,x.questao_id,x.ordem::integer
  from unnest(p_questao_ids) with ordinality x(questao_id,ordem);

  if not p_refazer then
    update public.missoes
    set status='questoes_iniciadas',questoes_iniciadas_em=coalesce(questoes_iniciadas_em,now())
    where id=p_missao_id;
    v_status_missao:='questoes_iniciadas';
  end if;

  v_ids:=p_questao_ids;
  return query select v_sessao_id,v_sessao_status,v_status_missao,v_ids,false;
end;
$function$;

create or replace function public.concluir_questoes_da_missao(
  p_missao_id uuid,
  p_sessao_id bigint
)
returns table (missao_id uuid,missao_status text,sessao_id bigint,sessao_status text)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid:=auth.uid();
  v_status_missao text;
  v_status_sessao text;
  v_planejadas integer;
  v_respondidas integer;
begin
  if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;

  select ms.status into v_status_missao
  from public.missoes ms
  join public.matriculas m on m.id=ms.matricula_id
  where ms.id=p_missao_id and m.usuario_id=v_usuario_id and m.status='ativa'
  for update of ms;
  if v_status_missao is null then raise exception 'Missao indisponivel para este usuario'; end if;

  select s.status into v_status_sessao
  from public.sessoes_estudo s
  where s.id=p_sessao_id and s.missao_id=p_missao_id and s.usuario_id=v_usuario_id
  for update;
  if v_status_sessao is null then raise exception 'Sessao nao pertence a esta missao'; end if;

  if v_status_missao='concluida' and v_status_sessao='concluida' then
    return query select p_missao_id,v_status_missao,p_sessao_id,v_status_sessao;
    return;
  end if;
  if v_status_missao not in ('questoes_iniciadas','concluida') or v_status_sessao<>'em_andamento' then
    raise exception 'Estado incompativel com a conclusao da missao';
  end if;

  select count(*)::integer,count(ru.questao_id)::integer
  into v_planejadas,v_respondidas
  from public.sessao_questoes_planejadas sq
  left join public.respostas_usuarios ru
    on ru.sessao_id=sq.sessao_id and ru.questao_id=sq.questao_id
  where sq.sessao_id=p_sessao_id;

  if v_planejadas=0 or v_respondidas<>v_planejadas then
    raise exception 'Responda todas as questoes planejadas antes de concluir a missao';
  end if;

  update public.sessoes_estudo
  set status='concluida',fim_em=coalesce(fim_em,now())
  where id=p_sessao_id;

  if v_status_missao<>'concluida' then
    update public.missoes
    set status='concluida',concluida_em=coalesce(concluida_em,now())
    where id=p_missao_id;
    v_status_missao:='concluida';
  end if;

  return query select p_missao_id,v_status_missao,p_sessao_id,'concluida'::text;
end;
$function$;

revoke execute on function public.iniciar_questoes_da_missao(uuid,bigint[],boolean) from public,anon;
grant execute on function public.iniciar_questoes_da_missao(uuid,bigint[],boolean) to authenticated;

commit;
