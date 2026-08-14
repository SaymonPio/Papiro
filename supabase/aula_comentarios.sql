-- Comunidade da Teoria Interativa: comentários pertencem à aula lógica e
-- sobrevivem à publicação de novas versões. Toda leitura/escrita passa por RPC.
begin;

create table public.aula_comentarios (
  id uuid primary key default gen_random_uuid(),
  aula_id uuid not null references public.aulas(id) on delete restrict,
  usuario_id uuid not null references auth.users(id) on delete cascade,
  texto text not null check (char_length(btrim(texto)) between 2 and 1000),
  status text not null default 'ativo' check (status in ('ativo','removido','oculto')),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index aula_comentarios_aula_criado_idx
  on public.aula_comentarios(aula_id, criado_em desc) where status='ativo';
create index aula_comentarios_usuario_idx on public.aula_comentarios(usuario_id);

alter table public.aula_comentarios enable row level security;
revoke all on public.aula_comentarios from anon, authenticated;

create function public.usuario_pode_comentar_aula(p_aula_id uuid, p_usuario_id uuid)
returns boolean language sql stable security definer set search_path to '' as $$
  select exists (
    select 1 from public.aulas a
    join public.unidades_pedagogicas u on u.id=a.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id=u.curso_conteudo_id
    join public.curso_materias cm on cm.id=cc.curso_materia_id
    join public.matriculas m on m.curso_id=cm.curso_id
    where a.id=p_aula_id and a.ativa and u.ativa
      and m.usuario_id=p_usuario_id and m.status='ativa'
  );
$$;
revoke execute on function public.usuario_pode_comentar_aula(uuid,uuid) from public,anon,authenticated;

create function public.listar_comentarios_aula(p_aula_id uuid)
returns table (comentario_id uuid, autor_nome text, texto text, criado_em timestamptz, meu boolean)
language plpgsql stable security definer set search_path to '' as $$
declare v_usuario uuid := auth.uid();
begin
  if v_usuario is null then raise exception 'Usuario nao autenticado'; end if;
  if not public.usuario_pode_comentar_aula(p_aula_id,v_usuario) and not public.eh_admin() then
    raise exception 'Aula indisponivel para este usuario';
  end if;
  return query
  select c.id,
    coalesce(nullif(btrim(u.raw_user_meta_data->>'nome'),''),
             nullif(btrim(u.raw_user_meta_data->>'full_name'),''),
             nullif(btrim(u.raw_user_meta_data->>'name'),''),'Aluno Papiro'),
    c.texto,c.criado_em,c.usuario_id=v_usuario
  from public.aula_comentarios c join auth.users u on u.id=c.usuario_id
  where c.aula_id=p_aula_id and c.status='ativo'
  order by c.criado_em asc limit 200;
end;
$$;

create function public.comentar_aula(p_aula_id uuid,p_texto text)
returns uuid language plpgsql security definer set search_path to '' as $$
declare v_usuario uuid:=auth.uid(); v_id uuid;
begin
  if v_usuario is null then raise exception 'Usuario nao autenticado'; end if;
  if not public.usuario_pode_comentar_aula(p_aula_id,v_usuario) then
    raise exception 'Apenas alunos matriculados podem comentar esta aula';
  end if;
  if char_length(btrim(coalesce(p_texto,''))) not between 2 and 1000 then
    raise exception 'Comentario deve ter entre 2 e 1000 caracteres';
  end if;
  if (select count(*) from public.aula_comentarios
      where usuario_id=v_usuario and criado_em>now()-interval '1 minute')>=5 then
    raise exception 'Aguarde um pouco antes de comentar novamente';
  end if;
  insert into public.aula_comentarios(aula_id,usuario_id,texto)
  values(p_aula_id,v_usuario,btrim(p_texto)) returning id into v_id;
  return v_id;
end;
$$;

create function public.remover_meu_comentario_aula(p_comentario_id uuid)
returns boolean language plpgsql security definer set search_path to '' as $$
declare v_usuario uuid:=auth.uid(); v_total integer;
begin
  if v_usuario is null then raise exception 'Usuario nao autenticado'; end if;
  update public.aula_comentarios set status='removido',atualizado_em=now()
  where id=p_comentario_id and usuario_id=v_usuario and status='ativo';
  get diagnostics v_total=row_count;
  return v_total=1;
end;
$$;

create function public.ocultar_comentario_aula_admin(p_comentario_id uuid)
returns boolean language plpgsql security definer set search_path to '' as $$
declare v_total integer;
begin
  if not public.eh_admin() then raise exception 'Apenas administradores podem moderar comentarios'; end if;
  update public.aula_comentarios set status='oculto',atualizado_em=now()
  where id=p_comentario_id and status='ativo';
  get diagnostics v_total=row_count;
  return v_total=1;
end;
$$;

revoke execute on function public.listar_comentarios_aula(uuid) from public,anon;
revoke execute on function public.comentar_aula(uuid,text) from public,anon;
revoke execute on function public.remover_meu_comentario_aula(uuid) from public,anon;
revoke execute on function public.ocultar_comentario_aula_admin(uuid) from public,anon;
grant execute on function public.listar_comentarios_aula(uuid) to authenticated;
grant execute on function public.comentar_aula(uuid,text) to authenticated;
grant execute on function public.remover_meu_comentario_aula(uuid) to authenticated;
grant execute on function public.ocultar_comentario_aula_admin(uuid) to authenticated;
commit;
