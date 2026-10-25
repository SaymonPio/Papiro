-- PC-RS 2025 Escrivão e Inspetor de Polícia (Fundatec, concurso 993; Concurso Público nº 02/2025) — REGISTRO SANITIZADO
-- da decisão de leitura da P2, TIPO 1 (caderno canônico), questão 41. Sem texto de questão.
--
-- Decisão (aprovada pelo usuário em 2026-10-25): ORDEM_OFICIAL_CONFIRMADA_POR_LEITURA_POSICIONAL
--   concurso = 993; parte = P2; tipo_caderno = 1; numero_original = 41; leitura = posicional
--   assinatura_escolhida  (leitura linear, rejeitada)  = d7c0b86f44dad1bb6090bf54a5a6fa77510e887f89ddcc52413d4540cdd18d45
--   assinatura_posicional (leitura posicional, usada) = 72368a618166c669797fc6d5d101f4bf399f32a58cfee313c4eef430b1011985
--   (sha256 de lib/integridade.mjs assinaturaDaQuestao; aplicada por lib/decisoesLeitura.mjs a partir de
--   metadata.decisoes_leitura do staging da P2 — a biblioteca não tem nada específico desta prova.)
-- Documentos: prova TIPO 1 sha256 d42fcf2635e3b571d8c03b60088d39f25472305224e63bab99f14d4dc8b1dba0;
--   prova TIPO 2 (prova cruzada) sha256 9d9a0a51182ebf295e98c067d498f68ea25029f7bae6b63bf31a8321191e8b51;
--   gabarito definitivo Edital nº 14/2026 (Anexo II) sha256 e9553c4aeb30304dabddc0acaf50aaabac38e55f9466b7164bd3dfd079c33562.
-- Evidências (geometria do PDF, sem texto):
--   TIPO 1, p. 26: a frase que explica a fórmula está em y=707, acima do parágrafo do comando (y=693/680), mas o stream
--   de conteúdo a emite depois do comando (item #28 > #27) — a leitura linear segue o stream; a posicional, a página;
--   a leitura posicional difere da linear SÓ no enunciado da Q41, com as mesmas palavras (as outras 69 são idênticas);
--   TIPO 2, Q45 (= T1 Q41): mesma ordem da leitura posicional, com stream e página concordando (y=709 antes de y=695).
-- Gate genérico que detectou a divergência: ordem_leituras_divergente (commit 9532ba6).
--
-- Somente leitura: depois do apply, confere que a P2 Q41 gravada é a representação POSICIONAL (md5 do enunciado
-- posicional) e não a linear (md5 rejeitado). Nenhuma linha antes do apply da P2.

with esperado (numero_original, md5_enunciado_posicional, md5_enunciado_linear_rejeitado, md5_alternativas, gabarito_ordem) as (
  values (41, '280987515b1cecab136a00fe587afe2c', '23dc7a29a87af700291630835eda4ceb', 'a5a797e1c91725f9e95b5538ea353e38', 3)
)
select q.id as questao_id, p.id as prova_id, pp.codigo as parte, q.numero_original,
       md5(q.enunciado) = e.md5_enunciado_posicional as enunciado_posicional,
       md5(q.enunciado) <> e.md5_enunciado_linear_rejeitado as nao_e_a_linear,
       (select md5(string_agg(a.texto, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = e.md5_alternativas as alternativas,
       (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta) = e.gabarito_ordem as gabarito,
       md5(q.enunciado) = e.md5_enunciado_posicional
         and (select md5(string_agg(a.texto, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = e.md5_alternativas
         and (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta) = e.gabarito_ordem as ok
  from esperado e
  join public.questoes q on q.numero_original = e.numero_original
  join public.provas p on p.id = q.prova_id and p.hash_prova = 'd42fcf2635e3b571d8c03b60088d39f25472305224e63bab99f14d4dc8b1dba0'
  join public.prova_partes pp on pp.id = q.prova_parte_id and pp.prova_id = p.id and pp.codigo = 'P2';
