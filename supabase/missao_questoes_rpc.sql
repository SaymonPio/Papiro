-- Fecha o ciclo missão -> teoria -> questões -> conclusão.
-- Uma sessão de questões pode pertencer a uma missão e, nesse caso, a lista
-- planejada fica congelada no servidor. O aluno não escreve status da missão.
begin;

alter table public.sessoes_estudo
  add column if not exists missao_id uuid null
  references public.missoes(id) on delete set null;

create unique index if not exists sessoes_estudo_missao_unica_idx
  on public.sessoes_estudo(missao_id)
  where missao_id is not null;

create table if not exists public.sessao_questoes_planejadas (
  sessao_id bigint not null references public.sessoes_estudo(id) on delete cascade,
  questao_id bigint not null references public.questoes(id) on delete restrict,
  ordem integer not null check (ordem > 0),
  primary key (sessao_id,questao_id),
  unique (sessao_id,ordem)
);

create index if not exists sessao_questoes_planejadas_questao_idx
  on public.sessao_questoes_planejadas(questao_id);

alter table public.sessao_questoes_planejadas enable row level security;
revoke all on public.sessao_questoes_planejadas from anon,authenticated;

-- Remove a policy antiga que ainda concedia ALL ao dono da sessão. A escrita
-- comum continua limitada pelas policies específicas; sessões de missão só
-- podem ser criadas pela RPC abaixo.
drop policy if exists "Aluno gerencia sessoes proprias" on public.sessoes_estudo;
drop policy if exists "Aluno gerencia sessões próprias" on public.sessoes_estudo;
drop policy if exists "Aluno cria sessão vinculada a matrícula ativa própria" on public.sessoes_estudo;
create policy "Aluno cria sessão vinculada a matrícula ativa própria"
  on public.sessoes_estudo for insert to authenticated
  with check (
    usuario_id=auth.uid()
    and matricula_id is not null
    and missao_id is null
    and exists (
      select 1 from public.matriculas m
      where m.id=matricula_id and m.usuario_id=auth.uid() and m.status='ativa'
    )
  );

revoke all on public.sessoes_estudo from anon;
revoke delete,truncate,references,trigger on public.sessoes_estudo from authenticated;
revoke update on public.sessoes_estudo from authenticated;
grant select,insert on public.sessoes_estudo to authenticated;
grant update(status,fim_em) on public.sessoes_estudo to authenticated;

create or replace function public.iniciar_questoes_da_missao(
  p_missao_id uuid,
  p_questao_ids bigint[]
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
  v_usuario_id uuid := auth.uid();
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
  if v_status_missao='iniciada' then raise exception 'Conclua a teoria antes de iniciar as questoes'; end if;

  select s.id,s.status
  into v_sessao_id,v_sessao_status
  from public.sessoes_estudo s
  where s.missao_id=p_missao_id
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

  if v_status_missao<>'teoria_concluida' then
    raise exception 'Estado da missao incompativel com o inicio das questoes';
  end if;

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

  update public.missoes
  set status='questoes_iniciadas',questoes_iniciadas_em=coalesce(questoes_iniciadas_em,now())
  where id=p_missao_id;

  v_status_missao:='questoes_iniciadas';
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
  if v_status_missao<>'questoes_iniciadas' or v_status_sessao<>'em_andamento' then
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
  update public.missoes
  set status='concluida',concluida_em=coalesce(concluida_em,now())
  where id=p_missao_id;

  return query select p_missao_id,'concluida'::text,p_sessao_id,'concluida'::text;
end;
$function$;

-- A trava é aplicada no INSERT real de respostas, inclusive quando a escrita
-- vem de uma RPC SECURITY DEFINER. O lock da sessão fecha corrida de duplicata.
create or replace function public.validar_resposta_da_sessao()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_status text;
  v_missao_id uuid;
  v_usuario_id uuid;
begin
  if new.sessao_id is null then return new; end if;

  select s.status,s.missao_id,s.usuario_id
  into v_status,v_missao_id,v_usuario_id
  from public.sessoes_estudo s
  where s.id=new.sessao_id
  for update;

  if v_status is null or v_usuario_id<>new.usuario_id then raise exception 'Sessao invalida'; end if;
  if v_status<>'em_andamento' then raise exception 'Sessao nao esta em andamento'; end if;
  if exists (
    select 1 from public.respostas_usuarios ru
    where ru.sessao_id=new.sessao_id and ru.questao_id=new.questao_id
  ) then raise exception 'Questao ja respondida nesta sessao'; end if;
  if v_missao_id is not null and not exists (
    select 1 from public.sessao_questoes_planejadas sq
    where sq.sessao_id=new.sessao_id and sq.questao_id=new.questao_id
  ) then raise exception 'Questao nao planejada para esta missao'; end if;
  return new;
end;
$function$;

drop trigger if exists respostas_valida_sessao on public.respostas_usuarios;
create trigger respostas_valida_sessao
  before insert on public.respostas_usuarios
  for each row execute function public.validar_resposta_da_sessao();

revoke execute on function public.validar_resposta_da_sessao() from public,anon,authenticated;
revoke execute on function public.iniciar_questoes_da_missao(uuid,bigint[]) from public,anon;
revoke execute on function public.concluir_questoes_da_missao(uuid,bigint) from public,anon;
grant execute on function public.iniciar_questoes_da_missao(uuid,bigint[]) to authenticated;
grant execute on function public.concluir_questoes_da_missao(uuid,bigint) to authenticated;

commit;
