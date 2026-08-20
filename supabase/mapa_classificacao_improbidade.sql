-- Mapa de classificação semântica das questões ativas de Improbidade
-- Administrativa (curso_conteudos.id = 55, assunto_id = 64, materia_id =
-- 10), produzido por leitura humana do enunciado + de TODAS as
-- alternativas de cada questão (nunca por ID, banca, concurso ou
-- palavra-chave isolada) — mesmo método de
-- supabase/mapa_classificacao_unidades_direitos_garantias_fundamentais.sql.
--
-- SOMENTE LEITURA. Este arquivo não escreve nada — é a fonte única de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_improbidade_teste_rollback.sql
--   classificar_questoes_unidades_improbidade.sql
-- devem replicar byte a byte na tabela temporária _mapa antes de aplicar.
--
-- Unidades oficiais do conteúdo 55 (após curadoria_unidades_improbidade.sql):
--   U1 60927a85-1b4a-480a-b8da-8eb318520692  ordem 1  Atos de Improbidade Administrativa
--   U2 9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84  ordem 2  Sujeitos, Sanções e Processo de Improbidade
--
-- Resultado da curadoria: 15/15 questões ativas classificadas, 0 sem
-- classificação, 1 multiunidade (questão 732), 0 problemas novos
-- encontrados nesta leitura. As questões 137 e 857 permanecem classificadas
-- normalmente (ambas em U1) — são uma duplicata real (mesmo enunciado e
-- mesmas 5 alternativas), mas a decisão de desativar uma delas foi
-- explicitamente adiada para um saneamento separado, fora do escopo desta
-- curadoria de unidades. A questão 858 tem um risco de desatualização
-- normativa sinalizado na auditoria anterior (rol do art. 11 tornou-se
-- taxativo pela Lei 14.230/2021) — classificada mesmo assim, pois a decisão
-- de correção de conteúdo também é um saneamento separado.

-- ============================================================================
-- 1) MAPA — uma linha por vínculo (questão multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, artigos_relacionados, justificativa, confianca) as (
  values
    (42,  '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 1º; art. 2º; art. 3º',
      'Testa o âmbito de aplicação da lei a entidade privada que recebe subvenção/benefício de ente público, e a limitação do ressarcimento à repercussão da contribuição pública — sujeitos e âmbito, não tipificação de ato.', 'alta'),
    (49,  '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 3º; art. 17; art. 8º-A',
      'Assinale a INCORRETA reunindo extensão a terceiro que induz o ato (art. 3º), representação ao Ministério Público (art. 17) e responsabilidade sucessória de herdeiros (art. 8º-A) — nenhuma alternativa trata da tipificação dos atos em si.', 'media'),
    (137, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 10',
      'Uso de máquinas públicas para finalidade diversa da adquirida, com dolo de facilitar obra particular — configura ato causador de prejuízo ao erário, gabarito explícito.', 'alta'),
    (361, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 17',
      'Trata do procedimento de representação e da medida de indisponibilidade de bens (limites e escopo da medida) — processo, não tipificação.', 'alta'),
    (666, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 10',
      'Uso de veículo público em serviço particular causando perda patrimonial ao Município — gabarito expresso "causa lesão ao erário".', 'alta'),
    (667, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 10, incisos',
      'Três condutas (nepotismo, aquisição por preço acima do mercado, fraude em fiscalização de parcerias) — todas hipóteses do rol de atos que causam prejuízo ao erário.', 'alta'),
    (668, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 9º',
      'Pede a alternativa que NÃO é enriquecimento ilícito entre 5 condutas — tema central da questão é a tipificação do art. 9º, mesmo com um distrator de outra categoria.', 'alta'),
    (669, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 3º',
      'Sócia/cotista sem prova de participação ou benefício direto no ato da empresa — regra de extensão de responsabilidade a terceiros (sujeitos), não tipificação.', 'alta'),
    (731, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 12; art. 2º; art. 17',
      'Três assertivas (responsabilização de pessoa jurídica/sanções, condição de posse do agente, legitimidade de representação) — todas do bloco de sujeitos/sanções/processo, nenhuma sobre tipificação de ato.', 'media'),
    (732, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 1º, §1º',
      'Assertiva III testa que o enriquecimento ilícito exige dolo (não mais culpa, pós Lei 14.230/2021) — elemento subjetivo central da tipificação, dentro do escopo da Unidade 1.', 'media'),
    (732, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 17; art. 3º',
      'Assertivas I e II testam indisponibilidade de bens (processo) e extensão da lei a terceiro que induz/concorre dolosamente (sujeitos) — ambas do escopo da Unidade 2; o gabarito da questão ("Apenas I e II") reforça o peso maior neste lado.', 'media'),
    (856, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 11',
      'Ação dolosa que viole honestidade, imparcialidade e legalidade — definição literal do ato que atenta contra os princípios da Administração.', 'alta'),
    (857, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 10',
      'Duplicata exata da questão 137 (mesmo enunciado, mesmas 5 alternativas) — classificada igual por ora; ver nota sobre saneamento separado no cabeçalho deste arquivo.', 'alta'),
    (858, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 11',
      'Deixar de prestar contas dolosamente, ocultando irregularidades — gabarito classifica como atentado aos princípios da Administração. Risco de desatualização normativa já sinalizado na auditoria (rol do art. 11 tornou-se taxativo pela Lei 14.230/2021); classificada mesmo assim, correção de conteúdo é saneamento separado.', 'media'),
    (859, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid, 1, 'art. 9º; art. 11',
      'Agente penitenciário aceita vantagem para facilitar entrada de celular a detento — gabarito classifica como enriquecimento ilícito E atentatório aos princípios simultaneamente; ambos os temas já pertencem à Unidade 1, dispensando vínculo com a Unidade 2.', 'alta'),
    (860, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid, 2, 'art. 8º-A',
      'Responsabilidade sucessória em fusão/incorporação de pessoa jurídica que causou dano ao erário — regra de sanções/sucessão, não tipificação de ato.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLÍCITAS.
-- ============================================================================

-- 2a) Questões classificadas (15/15) — nenhuma ficou de fora.
-- 42,49,137,361,666,667,668,669,731,732,856,857,858,859,860

-- 2b) Questões multiunidade (1): 732 (U1 + U2)

-- 2c) Questões sem classificação: nenhuma (0/15)

-- 2d) Questões problemáticas / novos problemas encontrados nesta leitura:
--     nenhuma nova. Duplicata 137/857 e risco de desatualização da questão
--     858 já haviam sido identificados na auditoria anterior — registrados
--     aqui apenas como referência, não tratados por este arquivo (fora de
--     escopo desta curadoria de unidades).

-- ============================================================================
-- 3) Cobertura por unidade (questões distintas, vínculos, gaps).
--    NÃO força nenhuma unidade a atingir 10; unidades fracas são GAP REAL DO
--    BANCO, registrado aqui, não erro técnico.
-- ============================================================================
--
-- U1 Atos de Improbidade Administrativa: 9 questões distintas
--    (8 exclusivas + 732 multiunidade) — inclui a duplicata 137/857, então
--    a cobertura REAL de conteúdo distinto é 8, não 9.
-- U2 Sujeitos, Sanções e Processo de Improbidade: 7 questões distintas
--    (6 exclusivas + 732 multiunidade) — ABAIXO do ideal de 10; a prática
--    desta unidade vai repetir questões com mais frequência até o banco
--    crescer. GAP REAL DO BANCO, não corrigido artificialmente aqui.
-- Total de vínculos esperados: 16 (15 questões distintas + 1 vínculo extra
--    da questão 732, multiunidade).
