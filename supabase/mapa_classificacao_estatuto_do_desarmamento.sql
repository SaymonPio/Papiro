-- Mapa de classificacao semantica das questoes validas de Estatuto do Desarmamento
-- (curso_conteudos.id = 56, assunto_id = 68,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_do_desarmamento.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_do_desarmamento_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_do_desarmamento.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 56 (apos curadoria_unidades_estatuto_do_desarmamento.sql):
--   U1 d88a80ae-187b-4a24-a5cb-3b20ff32e26f  ordem 1  Estatuto do Desarmamento
--
-- Resultado da curadoria: 12/12 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (50, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Aquisição, porte e posse', 'Assertiva I: art. 4º, caput e I (efetiva necessidade e idoneidade/certidões para aquisição). Assertiva II: art. 10, caput (autorização de porte, competência da PF, após autorização do Sinarm). Assertiva III: art. 12, caput (posse irregular de arma de uso permitido).', 'alta'),
    (142, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Registro de arma de uso restrito', 'Armas de uso restrito são registradas no Comando do Exército — art. 3º, parágrafo único. DUPLICATA de 853 (mesmo fato, mesmas alternativas).', 'alta'),
    (299, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Crimes em espécie', 'Porte de arma de uso permitido sem autorização — art. 14, caput.', 'alta'),
    (664, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Crimes em espécie', 'Arma com numeração suprimida, independentemente de ser de uso permitido e de estar desmuniciada — art. 16, §1º, IV (equiparação, autônomo em relação a arts. 12/14).', 'alta'),
    (728, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Crimes em espécie', 'Deixar de observar cautelas necessárias, permitindo que menor se apodere de arma de fogo — art. 13, caput (omissão de cautela).', 'alta'),
    (729, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Crimes em espécie', 'Gabarito: porte ilegal de arma de fogo de uso permitido após cessar a excludente de ilicitude — art. 14, caput. Distrator: art. 12, caput (posse irregular).', 'alta'),
    (730, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Destino de arma apreendida', 'Arma apreendida, periciada e sem mais interesse à persecução penal: destruição ou doação a órgãos de segurança pública mediante autorização judicial — art. 25, caput.', 'alta'),
    (776, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Sinarm', 'Compete ao Sinarm cadastrar transferências de propriedade, extravio, furto, roubo e outras ocorrências — art. 2º, IV.', 'alta'),
    (777, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Sinarm', 'Compete ao Sinarm cadastrar as autorizações de porte de arma de fogo e as renovações expedidas pela Polícia Federal — art. 2º, III.', 'alta'),
    (853, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Registro de arma de uso restrito', 'Armas de uso restrito são registradas no Comando do Exército — art. 3º, parágrafo único. DUPLICATA de 142 (mesmo fato, mesmas alternativas).', 'alta'),
    (854, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Aquisição, porte e posse', 'Vedado ao menor de 25 anos adquirir arma de fogo — art. 28, caput.', 'alta'),
    (855, 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f'::uuid, 1, 'Crimes em espécie', 'Numeração de série adulterada equipara o porte ao tratamento de uso restrito — art. 16, §1º, IV; pena aumentada pela metade por ser agente das categorias do art. 6º/7º/8º — art. 20, I. Nenhuma alternativa exige, de forma segura, o texto específico do art. 6º.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (12/12).
-- 50,142,299,664,728,729,730,776,777,853,854,855

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto do Desarmamento: 12 questoes distintas
-- Total de vinculos esperados: 12 (12 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
