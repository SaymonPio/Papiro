-- Etapa 3 do isolamento de dados por curso: respostas_usuarios como registro imutável
-- do ponto de vista do cliente.
--
-- Situação encontrada: existe uma policy "Aluno atualiza respostas próprias" (UPDATE,
-- usuario_id = auth.uid()) sem nenhuma restrição de coluna. Isso permite ao cliente
-- reescrever, após o registro, exatamente os campos que representam o resultado
-- histórico da resposta: questao_id, alternativa_id, acertou, usuario_id, sessao_id —
-- ou seja, um aluno poderia "corrigir" retroativamente um erro para acerto.
--
-- Campos verificados (colunas reais de respostas_usuarios: id, usuario_id, questao_id,
-- alternativa_id, sessao_id, acertou, tempo_segundos, respondida_em):
--   - questao_id, alternativa_id, acertou, usuario_id, sessao_id, respondida_em:
--     representam o fato histórico da resposta — não devem ser editáveis pelo cliente.
--   - tempo_segundos: no fluxo atual do frontend (app/questoes/page.tsx), é sempre
--     enviado como null via registrar_resposta; não há nenhuma tela que edite esse
--     campo depois da resposta registrada. Não há, portanto, nenhum campo com uso
--     legítimo de UPDATE direto pelo cliente identificado no código atual.
--
-- Decisão adotada: remover completamente a capacidade de UPDATE do cliente sobre
-- respostas_usuarios (nenhuma policy de UPDATE é recriada — RLS nega por padrão).
-- INSERT já não tinha policy para aluno (confirmado antes) e continua possível apenas
-- via registrar_resposta (SECURITY DEFINER, não afetado por este arquivo). DELETE já
-- não tinha policy e permanece bloqueado. SELECT ("Aluno vê respostas próprias") não é
-- alterada. Caso surja no futuro um campo legitimamente editável pelo aluno (ex.: uma
-- nota pessoal sobre a resposta), a recomendação é criar uma policy de UPDATE nova,
-- restrita por privilégio de coluna a esse campo específico — não reabrir UPDATE geral.
--
-- Nenhum dado existente é alterado por este arquivo — só schema de policy.

alter table public.respostas_usuarios enable row level security;

drop policy if exists "Aluno atualiza respostas próprias" on public.respostas_usuarios;
