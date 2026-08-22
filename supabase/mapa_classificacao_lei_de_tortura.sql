-- Mapa de classificacao semantica das questoes validas de Lei de Tortura
-- (curso_conteudos.id = 73, assunto_id = 102,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/lei_de_tortura.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_lei_de_tortura_teste_rollback.sql
--   classificar_questoes_unidades_lei_de_tortura.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 73 (apos curadoria_unidades_lei_de_tortura.sql):
--   U1 392fd9fe-a3d2-4062-b912-0a299b414429  ordem 1  Lei de Tortura
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (59, '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid, 1, 'Condutas típicas do crime de tortura (multi-dispositivo)', 'Situação I: Simão, agente público, constrange Nicanor com violência/grave ameaça, causando sofrimento mental, para obter informação necessária à resolução de um crime — corresponde a art. 1º, I, "a" (verdadeira). Situação II: Atena submete Perséfone, sob sua guarda, com grave ameaça, a intenso sofrimento mental, como medida de caráter preventivo — corresponde a art. 1º, II (verdadeira). Situação III: Edvaldo, com violência física, causando sofrimento físico, constrange Carmem a provocar ação criminosa — corresponde a art. 1º, I, "b" (verdadeira). Gabarito ''I, II e III'' confere, pois as três situações efetivamente configuram tortura.', 'alta'),
    (138, '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid, 1, 'Inafiançabilidade e vedação a graça/anistia', 'Comando ''Nos termos da Lei nº 9.455/1997'' (literalidade normativa). Gabarito ''Inafiançável e insuscetível de graça ou anistia'' — cópia literal do art. 1º, §6º, sem extrapolar para ''indulto'' (não consta do dispositivo) nem ''imprescritível'' (tortura não é crime imprescritível pela CF/lei — só racismo e ação de grupos armados o são). Microchecagem confirmada sem divergência.', 'alta'),
    (293, '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid, 1, 'Causa de aumento de pena — agente público', 'Gabarito ''Agente público'' — corresponde ao art. 1º, §4º, I (causa de aumento de 1/6 a 1/3 quando o crime é cometido por agente público). Distratores sem correspondência com as causas de aumento previstas na lei (maioridade genérica, reincidência da vítima, advogado particular, testemunha).', 'alta'),
    (817, '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid, 1, 'Efeitos e regime do crime de tortura — alternativa INCORRETA (multi-dispositivo)', 'Comando ''Com base na Lei nº 9.455/1997... assinale a alternativa INCORRETA'' (literalidade normativa). Alt1 ''inafiançável'' (verdadeira) art. 1º, §6º. Alt2 ''insuscetível de graça ou anistia'' (verdadeira) art. 1º, §6º. Alt3 (INCORRETA selecionada, gabarito) ''iniciará o cumprimento da pena em regime fechado'', sem a ressalva ''salvo hipótese do §2º'' presente no texto legal — incorreta por omitir a exceção — art. 1º, §7º. Microchecagem de jurisprudência (STJ/STF, HC 111.840, afasta obrigatoriedade absoluta do regime fechado) realizada: como o comando pergunta pela literalidade da Lei 9.455/1997 e não formula regra jurídica atual absoluta e desvinculada do texto legal, o gabarito permanece válido pela leitura literal do dispositivo, que ainda contém a ressalva do §2º omitida pela alternativa; jurisprudência documentada em _nota/escopo, sem alteração de gabarito. Alt4 ''aquele que se omite... incorre em crime'' (verdadeira) art. 1º, §2º. Alt5 ''aplica-se ainda quando o crime não tenha sido cometido em território nacional...'' (verdadeira) art. 2º, caput.', 'alta'),
    (818, '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid, 1, 'Perda de cargo público', 'Caso concreto (Octávio, policial penal, condenado com trânsito em julgado por tortura contra detento sob custódia). Gabarito ''A condenação acarretará a perda do cargo, função ou emprego público e a interdição para seu exercício pelo dobro do prazo da pena aplicada'' — cópia literal do art. 1º, §5º. Distratores fabricam prazos de outros regimes (1 a 5 anos; até 5 anos — possível confusão com art. 92 do Código Penal) ou negam a perda do cargo, todos incorretos frente ao texto específico da Lei 9.455/1997.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 59,138,293,817,818

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Lei de Tortura: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
