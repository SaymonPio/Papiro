-- Fase 2J-C: camada pedagógica entre o conteúdo real do edital e as aulas.
-- curso_conteudos continua sendo a identidade programática; uma unidade é
-- apenas um recorte didático desse conteúdo. Migration aditiva e compatível.

begin;

create table public.unidades_pedagogicas (
  id uuid primary key default gen_random_uuid(),
  curso_conteudo_id bigint not null
    references public.curso_conteudos(id) on delete restrict,
  titulo text not null check (btrim(titulo) <> ''),
  ordem integer not null check (ordem > 0),
  escopo text not null check (btrim(escopo) <> ''),
  artigos_esperados text[] null,
  ativa boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (curso_conteudo_id, ordem),
  unique (id, curso_conteudo_id)
);

create function public.marcar_atualizacao_unidade_pedagogica()
returns trigger language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

create trigger unidades_pedagogicas_marca_atualizacao
  before update on public.unidades_pedagogicas
  for each row execute function public.marcar_atualizacao_unidade_pedagogica();

revoke execute on function public.marcar_atualizacao_unidade_pedagogica()
  from public, anon, authenticated;

-- Uma unidade padrão preserva todas as aulas existentes sem inferir partes
-- por nome. O título/escopo vêm do assunto programático real.
insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo, artigos_esperados)
select
  cc.id,
  coalesce(nullif(btrim(ass.nome), ''), 'Conteúdo #' || cc.id::text),
  1,
  coalesce(nullif(btrim(te.escopo), ''), nullif(btrim(ass.nome), ''), 'Conteúdo #' || cc.id::text),
  te.artigos_esperados
from public.curso_conteudos cc
left join public.assuntos ass on ass.id = cc.assunto_id
left join public.teoria_escopos_conteudo te on te.curso_conteudo_id = cc.id;

alter table public.aulas
  add column unidade_pedagogica_id uuid null;

update public.aulas a
set unidade_pedagogica_id = up.id
from public.unidades_pedagogicas up
where up.curso_conteudo_id = a.conteudo_id and up.ordem = 1;

alter table public.aulas
  alter column unidade_pedagogica_id set not null,
  add constraint aulas_unidade_conteudo_fk
    foreign key (unidade_pedagogica_id, conteudo_id)
    references public.unidades_pedagogicas(id, curso_conteudo_id) on delete restrict;

alter table public.aulas drop constraint aulas_conteudo_id_key;
alter table public.aulas add constraint aulas_unidade_pedagogica_id_key unique (unidade_pedagogica_id);
create index aulas_conteudo_id_idx on public.aulas (conteudo_id);

alter table public.aula_geracoes
  add column unidade_pedagogica_id uuid null
    references public.unidades_pedagogicas(id) on delete restrict;

update public.aula_geracoes g
set unidade_pedagogica_id = a.unidade_pedagogica_id
from public.aula_versoes av
join public.aulas a on a.id = av.aula_id
where av.id = g.aula_versao_id;

-- Gerações antigas com erro/processando podem não ter aula_versao; ligá-las
-- à unidade padrão mantém o histórico íntegro.
update public.aula_geracoes g
set unidade_pedagogica_id = up.id
from public.unidades_pedagogicas up
where g.unidade_pedagogica_id is null
  and up.curso_conteudo_id = g.conteudo_id and up.ordem = 1;

alter table public.aula_geracoes alter column unidade_pedagogica_id set not null;
drop index public.aula_geracoes_uma_processando_idx;
create unique index aula_geracoes_uma_unidade_processando_idx
  on public.aula_geracoes (unidade_pedagogica_id)
  where status = 'processando';
create index aula_geracoes_unidade_idx
  on public.aula_geracoes (unidade_pedagogica_id, iniciado_em desc);

alter table public.unidades_pedagogicas enable row level security;
revoke all on public.unidades_pedagogicas from anon, authenticated;

-- Admin lista os recortes reais e pode criar novos sem fabricar
-- curso_conteudos. Escrita continua protegida por eh_admin().
create function public.listar_unidades_pedagogicas_admin(p_conteudo_id bigint)
returns table (unidade_id uuid, titulo text, ordem integer, escopo text,
  artigos_esperados text[], ativa boolean)
language plpgsql security definer set search_path to '' as $$
begin
  if not public.eh_admin() then raise exception 'Apenas administradores podem listar unidades pedagogicas'; end if;
  return query select u.id, u.titulo, u.ordem, u.escopo, u.artigos_esperados, u.ativa
    from public.unidades_pedagogicas u
    where u.curso_conteudo_id = p_conteudo_id order by u.ordem;
end;
$$;
revoke execute on function public.listar_unidades_pedagogicas_admin(bigint) from public, anon;
grant execute on function public.listar_unidades_pedagogicas_admin(bigint) to authenticated;

create function public.salvar_unidade_pedagogica_admin(
  p_conteudo_id bigint, p_unidade_id uuid, p_titulo text, p_ordem integer,
  p_escopo text, p_artigos_esperados text[], p_ativa boolean default true)
returns uuid language plpgsql security definer set search_path to '' as $$
declare v_id uuid;
begin
  if not public.eh_admin() then raise exception 'Apenas administradores podem salvar unidades pedagogicas'; end if;
  if p_unidade_id is null then
    insert into public.unidades_pedagogicas
      (curso_conteudo_id, titulo, ordem, escopo, artigos_esperados, ativa)
    values (p_conteudo_id, btrim(p_titulo), p_ordem, btrim(p_escopo), p_artigos_esperados, coalesce(p_ativa, true))
    returning id into v_id;
  else
    update public.unidades_pedagogicas set titulo=btrim(p_titulo), ordem=p_ordem,
      escopo=btrim(p_escopo), artigos_esperados=p_artigos_esperados, ativa=coalesce(p_ativa,true)
    where id=p_unidade_id and curso_conteudo_id=p_conteudo_id returning id into v_id;
    if v_id is null then raise exception 'Unidade pedagogica nao encontrada neste conteudo'; end if;
  end if;
  return v_id;
end;
$$;
revoke execute on function public.salvar_unidade_pedagogica_admin(bigint,uuid,text,integer,text,text[],boolean) from public, anon;
grant execute on function public.salvar_unidade_pedagogica_admin(bigint,uuid,text,integer,text,text[],boolean) to authenticated;

commit;
