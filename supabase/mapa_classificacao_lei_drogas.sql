-- Mapa de classificação semântica das questões válidas de Lei de Drogas
-- (curso_conteudos.id = 66, assunto_id = 78, materia_id = 10), produzido
-- por leitura humana do enunciado + de TODAS as alternativas de cada
-- questão (nunca por ID, banca, concurso ou palavra-chave isolada) —
-- mesmo método de supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo não escreve nada — é a fonte única de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_lei_drogas_teste_rollback.sql
--   classificar_questoes_unidades_lei_drogas.sql
-- devem replicar byte a byte na tabela temporária _mapa antes de aplicar.
--
-- Unidade oficial do conteúdo 66 (após curadoria_unidades_lei_drogas.sql):
--   U1 ba2341c7-0598-48f1-99dd-484692c1dfdb  ordem 1  Lei de Drogas
--
-- Decisão aprovada: MANTER 1 ÚNICA UNIDADE — não há fracionamento. Por
-- isso não existe conceito de multiunidade neste conteúdo: mesmo a
-- questão 742 (multi-tema, testa tráfico privilegiado + consumo pessoal +
-- associação para o tráfico + cultivo na mesma questão) gera apenas 1
-- vínculo, porque só há uma unidade para vincular. A nota "multi-tema" é
-- só um registro de conteúdo, não uma duplicação de vínculo.
--
-- Resultado da curadoria: 15/16 questões ativas classificadas. A questão
-- 674 foi INTENCIONALMENTE excluída do mapa — achado da auditoria
-- anterior: seu enunciado e 4 das 5 alternativas tratam de extorsão
-- mediante sequestro, requisição de dados cadastrais, avocação de
-- inquérito e denúncia anônima (nenhum tema da Lei de Drogas); só a
-- alternativa-gabarito toca a Lei de Drogas, com um dado desatualizado
-- (prazo de inquérito). Fica pendente de saneamento futuro, fora do
-- escopo desta curadoria. As questões 143 e 869 (duplicata exata, mesmo
-- enunciado e mesmas 5 alternativas) permanecem AMBAS classificadas
-- normalmente, por decisão explícita — a duplicata também é saneamento
-- separado.

-- ============================================================================
-- 1) MAPA — uma linha por vínculo (nenhuma questão multiunidade possível
--    com 1 única unidade neste conteúdo).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (143, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal',
      'Penas aplicáveis a quem porta droga para consumo pessoal (advertência, medida educativa) — art. 28, caput.', 'alta'),
    (269, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal',
      'Consequência jurídica do porte para consumo pessoal (sujeição ao art. 28, sem pena privativa de liberdade).', 'alta'),
    (270, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal — diferenciação',
      'Critérios do art. 28, §2º, usados pelo juiz para diferenciar consumo pessoal de tráfico.', 'alta'),
    (740, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Cultivo/plantio na fronteira consumo x tráfico',
      'Plantação em local público com finalidade também de obtenção de recursos financeiros — gabarito nega tanto plantio/venda quanto uso, afastando a hipótese de consumo pessoal isolado.', 'alta'),
    (741, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Sisnad',
      'Articulação do Sisnad com outros sistemas de políticas públicas (SUS e Suas) na prevenção/atenção/reinserção.', 'alta'),
    (742, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Multi-tema: tráfico privilegiado + consumo + associação + cultivo',
      'Assertivas testam simultaneamente tráfico privilegiado (art. 33, §4º), natureza não privativa de liberdade do consumo pessoal (art. 28), associação para o tráfico (art. 35) e cultivo para consumo pessoal (art. 28, §1º). Classificada na única unidade existente — não há duplicação de vínculo por não haver segunda unidade.', 'media'),
    (781, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal',
      'Caso concreto de pequena quantidade (2 cigarros) — pena de advertência, art. 28, I.', 'alta'),
    (782, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Sisnad',
      'Pergunta pelo instituto criado pela Lei 11.343/2006 — Sistema Nacional de Políticas Públicas sobre Drogas.', 'alta'),
    (783, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal',
      'Caso concreto de posse de 100g de maconha, agente primário — penas cumulativas do art. 28.', 'alta'),
    (803, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Sisnad',
      'Pergunta pelo órgão nacional responsável pelas competências de prevenção/repressão da Lei — Sisnad.', 'alta'),
    (804, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Tráfico',
      'Venda de substância entorpecente a terceiros — base legal é a "Lei Antidrogas" (Lei 11.343/2006), tipificando tráfico.', 'alta'),
    (867, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Cultivo/plantio na fronteira consumo x tráfico',
      'Plantação de grande escala (300 m²) com zelador contratado — gabarito tipifica como crime de plantio de matéria-prima para preparação de drogas, afastando a hipótese de consumo pessoal.', 'alta'),
    (868, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Tráfico — figura equiparada/privilegiada',
      'Oferecimento eventual e sem fim de lucro a pessoa do relacionamento, para consumo em conjunto — figura do art. 33, §3º.', 'alta'),
    (869, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Porte para consumo pessoal',
      'Duplicata exata da questão 143 (mesmo enunciado, mesmas 5 alternativas) — classificada igual por ora; ver nota sobre saneamento separado no cabeçalho deste arquivo.', 'alta'),
    (870, 'ba2341c7-0598-48f1-99dd-484692c1dfdb'::uuid, 1, 'Sisnad — internação',
      'Regras de internação (voluntária, involuntária) em comunidades terapêuticas, prazos e comunicação a órgãos de fiscalização.', 'alta')
)
select * from mapa order by questao_id;

-- ============================================================================
-- 2) LISTAS EXPLÍCITAS.
-- ============================================================================

-- 2a) Questões classificadas (15/16 ativas) — 674 excluída de propósito.
-- 143,269,270,740,741,742,781,782,783,803,804,867,868,869,870

-- 2b) Questões multiunidade: nenhuma (impossível com 1 única unidade).

-- 2c) Questões sem classificação (excluídas de propósito): 674 — fora de
--     escopo aparente, pendente de saneamento (ver auditoria anterior).

-- 2d) Questões problemáticas / novos problemas encontrados nesta leitura:
--     nenhuma nova. Duplicata 143/869 e exclusão da 674 já haviam sido
--     identificadas na auditoria anterior — registradas aqui apenas como
--     referência, não tratadas por este arquivo.

-- ============================================================================
-- 3) Cobertura da unidade única (questões distintas, vínculos, gaps).
-- ============================================================================
--
-- Lei de Drogas: 15 questões distintas classificadas (14 de conteúdo
--    realmente distinto, descontada a duplicata 143/869) — cobertura
--    confortável para uma unidade única de prática (RPC
--    iniciar_pratica_unidade usa quantidade fixa de 10).
-- Total de vínculos esperados: 15 (não há multiunidade possível com 1
--    única unidade neste conteúdo).
