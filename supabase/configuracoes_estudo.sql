-- Etapa 2 (extensão) do isolamento de dados por curso: preferências de estudo por matrícula.
-- public.matriculas = controle de acesso do usuário ao curso (não é tocada aqui).
-- public.configuracoes_estudo = preferências de estudo daquela matrícula (1:1 via matricula_id).
--
-- Este arquivo cria schema apenas (nenhum dado é escrito aqui — a migração de horas_diarias
-- a partir de public.objetivos está, comentada, em supabase/objetivos_para_matriculas.sql).
--
-- RLS aplicada:
--   - aluno faz SELECT apenas da configuração das próprias matrículas;
--   - aluno faz INSERT apenas para uma matrícula própria já existente (o FK para
--     matriculas garante que a matrícula precisa existir antes; o WITH CHECK garante
--     que é uma matrícula do próprio usuário — nunca de outro usuário);
--   - aluno faz UPDATE apenas na própria configuração; matricula_id não pode ser trocado,
--     nem mesmo para outra matrícula própria — isso é reforçado por privilégio de coluna
--     (GRANT UPDATE só em horas_diarias), não só pela policy de RLS;
--   - atualizado_em é sempre carimbado por trigger, nunca pelo valor enviado pelo cliente;
--   - aluno não pode apagar configuracoes_estudo (nenhuma policy de DELETE é concedida a ele);
--     administrador pode apagar via policy restrita por public.eh_admin().

create table if not exists public.configuracoes_estudo (
  matricula_id uuid primary key references public.matriculas(id) on delete cascade,
  horas_diarias numeric(4,2) not null default 1 check (horas_diarias > 0),
  atualizado_em timestamptz not null default now()
);

-- Garante que atualizado_em reflita sempre o momento real da alteração,
-- independentemente do que o cliente enviar nessa coluna.
create or replace function public.marcar_atualizacao_configuracao_estudo()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists configuracoes_estudo_marca_atualizacao on public.configuracoes_estudo;
create trigger configuracoes_estudo_marca_atualizacao
  before update on public.configuracoes_estudo
  for each row
  execute function public.marcar_atualizacao_configuracao_estudo();

alter table public.configuracoes_estudo enable row level security;

drop policy if exists "Aluno visualiza a própria configuração de estudo" on public.configuracoes_estudo;
create policy "Aluno visualiza a própria configuração de estudo"
  on public.configuracoes_estudo for select to authenticated
  using (exists (
    select 1 from public.matriculas m
    where m.id = matricula_id and m.usuario_id = auth.uid()
  ));

drop policy if exists "Aluno cria a própria configuração de estudo" on public.configuracoes_estudo;
create policy "Aluno cria a própria configuração de estudo"
  on public.configuracoes_estudo for insert to authenticated
  with check (exists (
    select 1 from public.matriculas m
    where m.id = matricula_id and m.usuario_id = auth.uid()
  ));

drop policy if exists "Aluno atualiza a própria configuração de estudo" on public.configuracoes_estudo;
create policy "Aluno atualiza a própria configuração de estudo"
  on public.configuracoes_estudo for update to authenticated
  using (exists (
    select 1 from public.matriculas m
    where m.id = matricula_id and m.usuario_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.matriculas m
    where m.id = matricula_id and m.usuario_id = auth.uid()
  ));

drop policy if exists "Administrador remove configuração de estudo" on public.configuracoes_estudo;
create policy "Administrador remove configuração de estudo"
on public.configuracoes_estudo
for delete
to authenticated
using (public.eh_admin());

-- Reforço por privilégio de coluna: mesmo passando pela policy de UPDATE acima,
-- o papel authenticated só tem permissão de escrever horas_diarias — nunca matricula_id.
-- (REVOKE de um privilégio não concedido é um no-op seguro no PostgreSQL.)
revoke update on public.configuracoes_estudo from authenticated;
grant update (horas_diarias) on public.configuracoes_estudo to authenticated;
