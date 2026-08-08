-- Etapa 3 do isolamento de dados por curso: fecha o bypass de registrar_resposta em
-- erros_usuarios e revisoes.
--
-- Situação encontrada: as duas tabelas tinham uma única policy "ALL" para o aluno
-- (usuario_id = auth.uid()), o que inclui INSERT e DELETE. Isso permite que o cliente
-- grave diretamente um erros_usuarios/revisoes sem nunca passar pela validação nova de
-- registrar_resposta (sessão -> matrícula ativa -> curso -> curso_questoes) e, pior, sem
-- nenhuma checagem de que o resposta_id/erro_id informado realmente pertence ao próprio
-- usuário (a policy ALL só valida usuario_id da linha sendo inserida, não a cadeia de
-- FKs). Depois desta mudança, INSERT nessas duas tabelas passa a ser possível somente
-- através de registrar_resposta (SECURITY DEFINER, roda com os privilégios do dono da
-- função — não é afetado pelos REVOKE abaixo, que valem só para o papel authenticated).
--
-- DELETE também não recebe policy nova (fica bloqueado por padrão) pelo mesmo motivo já
-- aplicado a sessoes_estudo: são registros de histórico/auditoria de aprendizado, e não
-- há hoje nenhum fluxo do app que os apague.
--
-- UPDATE continua liberado para o aluno, mas restrito por privilégio de coluna aos campos
-- que representam o próprio acompanhamento do erro/revisão pelo aluno, não a classificação
-- nem o agendamento (que devem continuar sob controle de registrar_resposta/admin):
--   - erros_usuarios: corrigido, corrigido_em, reflexao_aluno;
--   - revisoes: status, concluida_em, desempenho_pos_revisao, observacoes.
--
-- Nenhum dado existente é alterado por este arquivo — só schema de policies/privilégios.

alter table public.erros_usuarios enable row level security;
alter table public.revisoes enable row level security;

-- erros_usuarios
drop policy if exists "Aluno gerencia erros próprios" on public.erros_usuarios;

drop policy if exists "Aluno visualiza erros próprios" on public.erros_usuarios;
create policy "Aluno visualiza erros próprios"
  on public.erros_usuarios for select to authenticated
  using (usuario_id = auth.uid());

drop policy if exists "Aluno atualiza erros próprios" on public.erros_usuarios;
create policy "Aluno atualiza erros próprios"
  on public.erros_usuarios for update to authenticated
  using (usuario_id = auth.uid())
  with check (usuario_id = auth.uid());

revoke update on public.erros_usuarios from authenticated;
grant update (corrigido, corrigido_em, reflexao_aluno) on public.erros_usuarios to authenticated;

-- revisoes
drop policy if exists "Aluno gerencia revisões próprias" on public.revisoes;

drop policy if exists "Aluno visualiza revisões próprias" on public.revisoes;
create policy "Aluno visualiza revisões próprias"
  on public.revisoes for select to authenticated
  using (usuario_id = auth.uid());

drop policy if exists "Aluno atualiza revisões próprias" on public.revisoes;
create policy "Aluno atualiza revisões próprias"
  on public.revisoes for update to authenticated
  using (usuario_id = auth.uid())
  with check (usuario_id = auth.uid());

revoke update on public.revisoes from authenticated;
grant update (status, concluida_em, desempenho_pos_revisao, observacoes) on public.revisoes to authenticated;
