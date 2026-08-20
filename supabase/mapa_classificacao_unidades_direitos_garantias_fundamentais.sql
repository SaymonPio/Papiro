-- Mapa de classificação semântica das questões ativas de Direitos e
-- Garantias Fundamentais (curso_conteudos.id = 47, assunto_id = 71,
-- materia_id = 10), produzido por leitura humana do enunciado + de TODAS as
-- alternativas de cada questão (nunca por ID, banca, concurso ou
-- palavra-chave isolada) — mesmo método de
-- supabase/mapa_classificacao_unidades_lei_maria_penha.sql.
--
-- SOMENTE LEITURA. Este arquivo não escreve nada — é a fonte única de
-- verdade (mapa proposto, pendente de aprovação) que
--   classificar_questoes_unidades_direitos_garantias_fundamentais_teste_rollback.sql
--   classificar_questoes_unidades_direitos_garantias_fundamentais.sql
-- devem replicar byte a byte na tabela temporária _mapa antes de aplicar.
--
-- Unidades oficiais do conteúdo 47 (após curadoria_unidades_direitos_
-- garantias_fundamentais.sql):
--   U1 0c5d1d64-0cae-406e-be19-b03d387bee8a  ordem 1  Direitos Individuais e Coletivos Fundamentais
--   U2 f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63  ordem 2  Garantias Constitucionais e Remédios Constitucionais
--
-- Resultado da curadoria: 21/21 questões ativas classificadas, 0 sem
-- classificação, 1 multiunidade (questão 46), 0 problemas novos encontrados.
-- U2 fica com menos questões que U1 (7 exclusivas + 1 multiunidade = 8,
-- contra 13 exclusivas + 1 multiunidade = 14 em U1) — GAP REAL DO BANCO,
-- registrado na seção de cobertura abaixo; nenhuma questão foi inventada,
-- clonada ou reativada para compensar.

-- ============================================================================
-- 1) MAPA — uma linha por vínculo (questão multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, artigos_relacionados, justificativa, confianca) as (
  values
    (46,  '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, X; art. 5º, XVI',
      'Assertivas 1 e 2 (V/F) testam inviolabilidade da intimidade/vida privada/honra/imagem e a regra de reunião pacífica sem prévio aviso à autoridade — núcleo de direitos individuais.', 'alta'),
    (46,  'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, XXXIX',
      'Assertiva 4 (V/F) reproduz o princípio da legalidade penal ("não há crime sem lei anterior que o defina nem pena sem prévia cominação legal") — garantia penal, não direito individual básico.', 'media'),
    (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XXXIII',
      'Gabarito (alternativa 5) trata do direito de acesso a informações de órgãos públicos, ressalvado sigilo de segurança do Estado — direito individual de petição/informação, não remédio constitucional.', 'alta'),
    (298, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XI',
      'Inviolabilidade do domicílio e hipótese de ingresso sem consentimento (flagrante delito) — item explícito do escopo da Unidade 1.', 'alta'),
    (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XII; art. 5º, XXXIII',
      'Assertivas testam sigilo de correspondência/comunicações e direito de acesso a informação — ambos direitos individuais, nenhuma menciona remédio ou processo.', 'alta'),
    (657, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, LXXII; art. 5º, LXVIII',
      'Pede diretamente os nomes dos remédios constitucionais habeas data e habeas corpus a partir de sua função — item explícito do escopo da Unidade 2.', 'alta'),
    (658, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XI',
      'Caso concreto de ingresso em domicílio para prestar socorro, sem mandado — mesma regra de inviolabilidade do domicílio da Unidade 1.', 'alta'),
    (660, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, VI; art. 5º, VII',
      'Direito à assistência religiosa em entidade de internação coletiva — liberdade religiosa, item explícito do escopo da Unidade 1.', 'alta'),
    (661, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XVI',
      'Caso concreto de reunião pacífica em local aberto ao público — direito de reunião, item explícito do escopo da Unidade 1.', 'alta'),
    (662, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, L',
      'Gabarito (alternativa 5) trata do direito das presidiárias a condições de amamentação — direitos dos presos, item explícito do escopo da Unidade 2; os demais distratores também são sobre direito penal/processual (retroatividade, perdimento de bens, imprescritibilidade).', 'alta'),
    (663, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, LXXII',
      'Pede o remédio constitucional cabível (habeas data) para retificação de dados — item explícito do escopo da Unidade 2.', 'alta'),
    (723, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, IX',
      'Liberdade de expressão da atividade intelectual/artística/científica/comunicação — item explícito do escopo da Unidade 1.', 'alta'),
    (724, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XI',
      'Caso concreto de ingresso em domicílio por desastre (inundação) — inviolabilidade do domicílio, Unidade 1.', 'alta'),
    (725, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XI',
      'Caso concreto de ingresso em domicílio por flagrante delito, à noite — inviolabilidade do domicílio, Unidade 1.', 'alta'),
    (726, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XI; art. 5º, XXVII; art. 5º, LI; art. 5º, LVIII',
      'Questão "assinale a INCORRETA" que reúne domicílio, direito autoral, extradição e identificação criminal — nenhuma alternativa trata de remédio constitucional ou devido processo; conjunto de direitos individuais diversos.', 'media'),
    (727, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, IV; art. 5º, XVII',
      'Gabarito (INCORRETA) é sobre liberdade de associação (veda caráter paramilitar); demais alternativas tratam de manifestação do pensamento, requisição de propriedade e publicidade processual — predomínio de liberdade/associação.', 'media'),
    (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, III',
      'Pede o fundamento constitucional da vedação a tortura e tratamento desumano ou degradante — tratado junto com vedação de penas (Unidade 2) por proximidade temática (limites ao poder punitivo do Estado), não é um dos direitos individuais nucleares listados na Unidade 1.', 'media'),
    (797, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XXI',
      'Legitimidade de entidades associativas para representar filiados — decorrência do direito de associação (liberdade), não um remédio constitucional nem regra de devido processo penal.', 'media'),
    (846, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, XLIX; art. 5º, L',
      'Assertivas tratam de integridade física/moral dos presos e condições de amamentação das presidiárias — direitos dos presos, item explícito do escopo da Unidade 2.', 'alta'),
    (847, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid, 1, 'art. 5º, XV; art. 5º, IX; art. 5º, XIII; art. 5º, X; art. 5º, XXII',
      'Questão "assinale a INCORRETA" reunindo locomoção, expressão, liberdade profissional, intimidade/vida privada e propriedade — todos direitos individuais, nenhuma alternativa trata de remédio ou processo.', 'media'),
    (848, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, XLVII',
      'Vedação da pena de morte, salvo guerra declarada — item explícito do escopo da Unidade 2 (vedação de penas).', 'alta'),
    (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid, 2, 'art. 5º, L',
      'Gabarito (apenas assertiva I) confirma o direito das presidiárias à amamentação como o único item de literalidade constitucional entre as quatro assertivas — direitos dos presos, Unidade 2.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLÍCITAS.
-- ============================================================================

-- 2a) Questões classificadas (21/21) — nenhuma ficou de fora.
-- 46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849

-- 2b) Questões multiunidade (1): 46 (U1 + U2)

-- 2c) Questões sem classificação: nenhuma (0/21)

-- 2d) Questões problemáticas / novos problemas encontrados nesta leitura:
--     nenhuma. Todas as 21 questões ativas têm enunciado e 5 alternativas
--     íntegras, com exatamente uma alternativa marcada como correta.

-- ============================================================================
-- 3) Cobertura por unidade (questões distintas, vínculos, gaps).
--    NÃO força nenhuma unidade a atingir 10; unidades fracas são GAP REAL DO
--    BANCO, registrado aqui, não erro técnico.
-- ============================================================================
--
-- U1 Direitos Individuais e Coletivos Fundamentais: 14 questões distintas
--    (13 exclusivas + 46 multiunidade) — cobertura confortável para a
--    prática de 10 questões (RPC iniciar_pratica_unidade usa quantidade
--    fixa de 10).
-- U2 Garantias Constitucionais e Remédios Constitucionais: 8 questões
--    distintas (7 exclusivas + 46 multiunidade) — ABAIXO do ideal de 10;
--    a prática desta unidade vai repetir questões com mais frequência até
--    o banco crescer. GAP REAL DO BANCO, não corrigido artificialmente
--    aqui.
-- Total de vínculos esperados: 22 (21 questões distintas + 1 vínculo extra
--    da questão 46, multiunidade).
