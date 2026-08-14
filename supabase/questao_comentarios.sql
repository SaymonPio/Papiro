-- Comunidade do banco de questões: a conversa pertence à questão lógica e
-- fica disponível para alunos com matrícula ativa em um curso que a contenha.
-- A tabela permanece fechada; toda leitura e escrita passa pelas RPCs abaixo.
begin;

create table if not exists public.questao_comentarios (
  id uuid primary key default gen_random_uuid(),
  questao_id bigint not null references public.questoes(id) on delete restrict,
  usuario_id uuid not null references auth.users(id) on delete cascade,
  texto text not null check (char_length(btrim(texto)) between 2 and 1000),
  status text not null default 'ativo' check (status in ('ativo','removido','oculto')),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index if not exists questao_comentarios_questao_criado_idx
  on public.questao_comentarios(questao_id, criado_em asc) where status='ativo';
create index if not exists questao_comentarios_usuario_idx
  on public.questao_comentarios(usuario_id);

alter table public.questao_comentarios enable row level security;
revoke all on public.questao_comentarios from anon, authenticated;

create or replace function public.usuario_pode_comentar_questao(
  p_questao_id bigint,
  p_usuario_id uuid
)
returns boolean
language sql
stable
security definer
set search_path to ''
as $$
  select exists (
    select 1
    from public.questoes q
    join public.curso_questoes cq on cq.questao_id=q.id
    join public.matriculas m on m.curso_id=cq.curso_id
    where q.id=p_questao_id
      and q.ativa
      and m.usuario_id=p_usuario_id
      and m.status='ativa'
  );
$$;
revoke execute on function public.usuario_pode_comentar_questao(bigint,uuid)
  from public, anon, authenticated;

create or replace function public.listar_comentarios_questao(p_questao_id bigint)
returns table (
  comentario_id uuid,
  autor_nome text,
  texto text,
  criado_em timestamptz,
  meu boolean
)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_usuario uuid := auth.uid();
begin
  if v_usuario is null then
    raise exception 'Usuario nao autenticado';
  end if;
  if not public.usuario_pode_comentar_questao(p_questao_id,v_usuario)
     and not public.eh_admin() then
    raise exception 'Questao indisponivel para este usuario';
  end if;

  return query
  select
    c.id,
    coalesce(
      nullif(btrim(u.raw_user_meta_data->>'nome'),''),
      nullif(btrim(u.raw_user_meta_data->>'full_name'),''),
      nullif(btrim(u.raw_user_meta_data->>'name'),''),
      'Aluno Papiro'
    ),
    c.texto,
    c.criado_em,
    c.usuario_id=v_usuario
  from public.questao_comentarios c
  join auth.users u on u.id=c.usuario_id
  where c.questao_id=p_questao_id and c.status='ativo'
  order by c.criado_em asc
  limit 200;
end;
$$;

create or replace function public.comentar_questao(p_questao_id bigint,p_texto text)
returns uuid
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_usuario uuid := auth.uid();
  v_id uuid;
begin
  if v_usuario is null then
    raise exception 'Usuario nao autenticado';
  end if;
  if not public.usuario_pode_comentar_questao(p_questao_id,v_usuario) then
    raise exception 'Apenas alunos matriculados podem comentar esta questao';
  end if;
  if char_length(btrim(coalesce(p_texto,''))) not between 2 and 1000 then
    raise exception 'Comentario deve ter entre 2 e 1000 caracteres';
  end if;
  if (
    select count(*)
    from public.questao_comentarios
    where usuario_id=v_usuario and criado_em>now()-interval '1 minute'
  ) >= 5 then
    raise exception 'Aguarde um pouco antes de comentar novamente';
  end if;

  insert into public.questao_comentarios(questao_id,usuario_id,texto)
  values(p_questao_id,v_usuario,btrim(p_texto))
  returning id into v_id;
  return v_id;
end;
$$;

create or replace function public.remover_meu_comentario_questao(p_comentario_id uuid)
returns boolean
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_usuario uuid := auth.uid();
  v_total integer;
begin
  if v_usuario is null then
    raise exception 'Usuario nao autenticado';
  end if;
  update public.questao_comentarios
  set status='removido', atualizado_em=now()
  where id=p_comentario_id and usuario_id=v_usuario and status='ativo';
  get diagnostics v_total=row_count;
  return v_total=1;
end;
$$;

create or replace function public.ocultar_comentario_questao_admin(p_comentario_id uuid)
returns boolean
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_total integer;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem moderar comentarios';
  end if;
  update public.questao_comentarios
  set status='oculto', atualizado_em=now()
  where id=p_comentario_id and status='ativo';
  get diagnostics v_total=row_count;
  return v_total=1;
end;
$$;

revoke execute on function public.listar_comentarios_questao(bigint) from public,anon;
revoke execute on function public.comentar_questao(bigint,text) from public,anon;
revoke execute on function public.remover_meu_comentario_questao(uuid) from public,anon;
revoke execute on function public.ocultar_comentario_questao_admin(uuid) from public,anon;
grant execute on function public.listar_comentarios_questao(bigint) to authenticated;
grant execute on function public.comentar_questao(bigint,text) to authenticated;
grant execute on function public.remover_meu_comentario_questao(uuid) to authenticated;
grant execute on function public.ocultar_comentario_questao_admin(uuid) to authenticated;

commit;
