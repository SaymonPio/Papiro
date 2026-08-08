-- Etapa 3 do isolamento de dados por curso: vínculo de sessoes_estudo com matriculas.
-- public.sessoes_estudo JÁ EXISTE (id, usuario_id, data_sessao, nivel_meta, status, inicio_em,
-- fim_em, minutos_revisao, questoes_planejadas, questoes_respondidas, acertos, observacoes,
-- criado_em, atualizado_em). Este arquivo só ADICIONA a coluna matricula_id — nenhuma outra
-- coluna existente é alterada, nenhum dado é apagado ou reescrito.
--
-- matricula_id nasce NULLABLE porque já existem sessões legadas sem forma segura de saber
-- a qual matrícula pertenceriam. Nenhum backfill heurístico é feito aqui ou em outro momento.
-- on delete set null (não cascade): se uma matrícula for removida, a sessão em si (histórico
-- de estudo do aluno) é preservada — só perde o vínculo de curso, ficando como as demais
-- linhas legadas sem curso identificável.
--
-- RLS redesenhada (SELECT / INSERT / UPDATE / DELETE tratados separadamente, sem policy ALL):
--   - SELECT: aluno vê todas as próprias sessões, incluindo as antigas sem matricula_id e as
--     de matrículas hoje canceladas — ver histórico não é um risco de vazamento entre cursos.
--   - INSERT: só permite gravar uma sessão nova se matricula_id for informado, pertencer ao
--     próprio usuário e a matrícula estiver com status = 'ativa'. Isso impede a criação de
--     sessões "sem curso" a partir de agora.
--   - UPDATE: aluno só atualiza as próprias sessões; a policy de RLS não impede sozinha que
--     matricula_id/usuario_id sejam trocados num UPDATE, então o privilégio de coluna abaixo
--     restringe o que o papel authenticated pode de fato alterar via UPDATE direto (status e
--     fim_em — os únicos campos que o frontend atualiza fora da RPC). Os contadores
--     (questoes_respondidas, acertos) só são escritos internamente por registrar_resposta.
--   - DELETE: nenhuma policy é criada. sessoes_estudo é histórico de estudo/auditoria; não há
--     hoje nenhum fluxo do app que apague uma sessão, e permitir que o aluno apague o próprio
--     histórico livremente reduziria a confiabilidade de estatísticas/cronograma sem necessidade
--     real. Se um caso de uso legítimo de exclusão surgir, deve ser uma policy própria (ex.:
--     restrita a admin), não reaberta por padrão.

do $$
declare
  tipo_atual text;
begin
  select data_type into tipo_atual
  from information_schema.columns
  where table_schema = 'public' and table_name = 'sessoes_estudo' and column_name = 'matricula_id';

  if tipo_atual is not null and tipo_atual <> 'uuid' then
    raise exception 'public.sessoes_estudo.matricula_id existe com tipo % (esperado uuid). Resolva manualmente antes de reexecutar esta migração.', tipo_atual;
  end if;
end;
$$;

alter table public.sessoes_estudo
  add column if not exists matricula_id uuid references public.matriculas(id) on delete set null;

create index if not exists sessoes_estudo_matricula_id_idx on public.sessoes_estudo (matricula_id);

alter table public.sessoes_estudo enable row level security;

drop policy if exists "Aluno gerencia sessões próprias" on public.sessoes_estudo;

drop policy if exists "Aluno visualiza sessões próprias" on public.sessoes_estudo;
create policy "Aluno visualiza sessões próprias"
  on public.sessoes_estudo for select to authenticated
  using (usuario_id = auth.uid());

drop policy if exists "Aluno cria sessão vinculada a matrícula ativa própria" on public.sessoes_estudo;
create policy "Aluno cria sessão vinculada a matrícula ativa própria"
  on public.sessoes_estudo for insert to authenticated
  with check (
    usuario_id = auth.uid()
    and matricula_id is not null
    and exists (
      select 1 from public.matriculas m
      where m.id = matricula_id
        and m.usuario_id = auth.uid()
        and m.status = 'ativa'
    )
  );

drop policy if exists "Aluno atualiza sessões próprias" on public.sessoes_estudo;
create policy "Aluno atualiza sessões próprias"
  on public.sessoes_estudo for update to authenticated
  using (usuario_id = auth.uid())
  with check (usuario_id = auth.uid());

-- Reforço por privilégio de coluna: mesmo passando pela policy de UPDATE acima, o papel
-- authenticated só pode escrever status/fim_em via UPDATE direto — nunca matricula_id,
-- usuario_id ou os contadores (que são de responsabilidade exclusiva de registrar_resposta).
revoke update on public.sessoes_estudo from authenticated;
grant update (status, fim_em) on public.sessoes_estudo to authenticated;
