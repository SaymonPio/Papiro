-- Mapa de classificacao semantica das questoes validas de Prevenção da tortura
-- (curso_conteudos.id = 99, assunto_id = 26,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/prevencao_da_tortura.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_prevencao_da_tortura_teste_rollback.sql
--   classificar_questoes_unidades_prevencao_da_tortura.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 99 (apos curadoria_unidades_prevencao_da_tortura.sql):
--   U1 1c05566b-5c71-4baa-b965-3577b8ffdc17  ordem 1  Prevenção da tortura
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (29, '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid, 1, 'Proibição absoluta da tortura — circunstâncias excepcionais', 'Fundamento normativo: Convenção contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (ONU, 1984), art. 2, item 2 — ''Em nenhum caso poderão invocar-se circunstâncias excepcionais, como ameaça ou estado de guerra, instabilidade política interna ou qualquer outra emergência pública, como justificação para a tortura.'' Gabarito ''Não, a proibição da tortura é absoluta'' — corresponde diretamente ao dispositivo. O art. 2, item 3 da mesma Convenção (''A ordem de um funcionário superior ou de uma autoridade pública não poderá ser invocada como justificativa para a tortura'') é relevante para eliminar o distrator ''ordem superior'', mas NÃO entra em artigos_esperados por decisão aprovada — o núcleo efetivamente testado é apenas a vedação a circunstâncias excepcionais (item 2); o item 3 deve aparecer na futura aula como contraste, documentado apenas em escopo/_nota. Escolha do diploma ONU (em vez da Convenção Interamericana, já usada no conteúdo 79 para a mesma tese) aprovada para diferenciação pedagógica entre os dois conteúdos. Distratores fabricam exceções inexistentes (ordem superior, estado de defesa, obter informação urgente, ausência de lesão permanente). Sobreposição temática (não duplicata) com Q250 do conteúdo 79 (Convenção Interamericana para Prevenir e Punir a Tortura, já concluído), que testa tese semelhante com diploma diferente.', 'alta'),
    (263, '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid, 1, 'Incompatibilidade da tortura com a dignidade humana (princípio)', 'Formulação principiológica ampla, sem redação literal idêntica em um dispositivo isolado — não adicionado artigo artificial (nem CF art. 1º, III, nem art. 5º, III) apenas para criar referência normativa. Gabarito ''A tortura é absolutamente incompatível com a dignidade humana'' — correto sob essa lógica principiológica, relacionada contextualmente à proibição absoluta já tratada na Q29 e aos instrumentos internacionais e constitucionais de proteção da dignidade. Distratores fabricam posições incompatíveis com o sistema de direitos humanos (tortura admitida mediante ordem superior, mera infração disciplinar, usada para obter confissão, dependente apenas de autorização judicial).', 'alta'),
    (264, '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid, 1, 'Mecanismos de inspeção e monitoramento de locais de privação de liberdade', 'Fundamento normativo: Protocolo Facultativo à Convenção da ONU contra a Tortura (OPCAT), art. 1 — objeto do protocolo é estabelecer um sistema de visitas regulares, efetuadas por órgãos internacionais e nacionais independentes, a lugares onde se encontrem pessoas privadas de liberdade, com o objetivo de prevenir a tortura. Gabarito ''Reduzir riscos de maus-tratos e fortalecer garantias das pessoas custodiadas'' — corresponde à finalidade do dispositivo. Lei nº 12.847/2013 (Sistema Nacional de Prevenção e Combate à Tortura, Comitê Nacional e Mecanismo Nacional de Prevenção e Combate à Tortura — MNPCT) documentada apenas como implementação doméstica em escopo/_nota, sem entrar em artigos_esperados, pois a questão não cobra dispositivo específico da lei. Distratores fabricam finalidades incompatíveis (substituir o Poder Judiciário, autorizar penas informais, afastar a fiscalização estatal, impedir registros de custódia).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 29,263,264

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Prevenção da tortura: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
