-- Fundação da Teoria Interativa (Fase 2J-A): bucket privado de Storage para
-- as fontes (PDFs) usadas na geração de aulas.
--
-- Auditoria feita antes deste arquivo (localizada, sem reabrir auditoria
-- geral): o único bucket hoje é "editais" (supabase/editais.sql), privado
-- (public=false), limitado a 25MB e a application/pdf, com policies de
-- storage.objects restritas por pasta-por-usuário
-- ((storage.foldername(name))[1] = auth.uid()::text). Este arquivo segue o
-- MESMO princípio de privacidade (bucket privado, só PDF, mesmo limite de
-- tamanho), mas a autorização é por public.eh_admin() em vez de "dono da
-- pasta": materiais da teoria são um recurso administrativo compartilhado
-- (qualquer administrador pode reaproveisar/gerenciar o material de
-- qualquer outro), não um arquivo pessoal de aluno — por isso não há
-- convenção de pasta-por-usuário aqui.
--
-- public.eh_admin() já existe no banco real (não é definida em SQL
-- versionado neste repositório — mesmo padrão documentado em
-- supabase/cursos_matriculas.sql) e já é usada em várias policies
-- existentes (supabase/cursos_matriculas.sql, base_programatica_curso.sql).
-- Reaproveitada aqui, não redefinida.
--
-- Não altera nenhuma migration histórica. Não cria Storage para nada além
-- deste bucket novo.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- Idempotente por natureza (bucket é identificado por id fixo) — mesmo
-- padrão de editais.sql: ON CONFLICT DO UPDATE só nos campos de
-- configuração, nunca duplica o bucket.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('materiais-teoria', 'materiais-teoria', false, 26214400, array['application/pdf'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

-- Só administrador envia/lê/exclui objetos deste bucket. Nenhum aluno,
-- nenhum anon. Nunca público.
drop policy if exists "Administrador envia materiais da teoria" on storage.objects;
create policy "Administrador envia materiais da teoria"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'materiais-teoria' and public.eh_admin());

drop policy if exists "Administrador acessa materiais da teoria" on storage.objects;
create policy "Administrador acessa materiais da teoria"
  on storage.objects for select to authenticated
  using (bucket_id = 'materiais-teoria' and public.eh_admin());

drop policy if exists "Administrador exclui materiais da teoria" on storage.objects;
create policy "Administrador exclui materiais da teoria"
  on storage.objects for delete to authenticated
  using (bucket_id = 'materiais-teoria' and public.eh_admin());

COMMIT;
