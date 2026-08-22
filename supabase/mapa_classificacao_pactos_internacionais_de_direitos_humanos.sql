-- Mapa de classificacao semantica das questoes validas de Pactos Internacionais de Direitos Humanos
-- (curso_conteudos.id = 84, assunto_id = 82,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pactos_internacionais_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pactos_internacionais_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_pactos_internacionais_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 84 (apos curadoria_unidades_pactos_internacionais_de_direitos_humanos.sql):
--   U1 7cfd81f6-49ab-4a15-b643-9a8a7b026deb  ordem 1  Pactos Internacionais de Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (174, '7cfd81f6-49ab-4a15-b643-9a8a7b026deb'::uuid, 1, 'Identidade do par — PIDCP e PIDESC', 'Fundamento: doutrina/história do Direito Internacional dos Direitos Humanos, sem dispositivo normativo específico. Gabarito ''Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais'' — correto: os dois grandes Pactos de 1966 são o PIDCP e o PIDESC. Distratores citam tratados/protocolos de natureza totalmente distinta, sem relação com direitos humanos como objeto central (Pacto de Varsóvia, Tratado de Roma de 1957, Protocolo de Kyoto, Tratado de Maastricht).', 'alta'),
    (175, '7cfd81f6-49ab-4a15-b643-9a8a7b026deb'::uuid, 1, 'Origem institucional dos Pactos de 1966', 'Fundamento: história institucional dos Pactos, sem dispositivo normativo específico. Gabarito ''Organização das Nações Unidas'' — correto: os dois Pactos de 1966 foram adotados no âmbito da ONU. Distratores citam organismos regionais/de outra natureza (OEA, União Europeia, Mercosul, OTAN).', 'alta'),
    (176, '7cfd81f6-49ab-4a15-b643-9a8a7b026deb'::uuid, 1, 'Função dos Pactos — desenvolvimento e vinculação jurídica dos direitos', 'Fundamento: doutrina de Direito Internacional dos Direitos Humanos, sem dispositivo normativo específico. Gabarito ''Desenvolver e tornar juridicamente vinculantes diversos direitos reconhecidos no plano internacional'' — correto, é a função doutrinária clássica dos Pactos de 1966: a DUDH foi proclamada por resolução da Assembleia Geral da ONU e não é tratado internacional; os Pactos de 1966 desenvolveram os direitos nela proclamados e os positivaram em tratados juridicamente vinculantes para os respectivos Estados Partes (ajuste de precisão: sem afirmar de forma absoluta que a DUDH ''não é juridicamente vinculante'', já que determinadas normas nela refletidas também podem corresponder a direito internacional costumeiro). Distratores fabricam efeitos absurdos (revogar Constituições automaticamente, criar governo mundial, substituir tribunais nacionais, regular apenas comércio internacional).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 174,175,176

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pactos Internacionais de Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
