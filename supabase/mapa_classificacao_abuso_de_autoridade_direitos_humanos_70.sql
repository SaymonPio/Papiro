-- Mapa de classificacao semantica das questoes validas de Abuso de Autoridade
-- (curso_conteudos.id = 70, assunto_id = 103,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/abuso_de_autoridade_direitos_humanos_70.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_abuso_de_autoridade_direitos_humanos_70_teste_rollback.sql
--   classificar_questoes_unidades_abuso_de_autoridade_direitos_humanos_70.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 70 (apos curadoria_unidades_abuso_de_autoridade_direitos_humanos_70.sql):
--   U1 d4d8a1fc-4c52-4c85-879c-031d0085be88  ordem 1  Abuso de Autoridade
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (57, 'd4d8a1fc-4c52-4c85-879c-031d0085be88'::uuid, 1, 'Efeitos da condenação', 'Situação I (indenizar): tornar certa a obrigação de indenizar o dano causado pelo crime, com valor mínimo fixado na sentença mediante requerimento do ofendido — este efeito é automático — art. 4º, I. Situações II (inabilitação) e III (perda do cargo): condicionadas à ocorrência de reincidência em crime de abuso de autoridade, não automáticas, devendo ser declaradas motivadamente na sentença — art. 4º, II e III combinado com art. 4º, parágrafo único. Gabarito ''Apenas II e III'' confere: apenas os efeitos dos incisos II e III exigem a condição de reincidência e declaração motivada.', 'alta'),
    (128, 'd4d8a1fc-4c52-4c85-879c-031d0085be88'::uuid, 1, 'Falsa identidade ao preso', 'Beltrano, ao prender Sicrano, declara identidade falsa quando indagado. Gabarito ''A falsa atribuição de identidade é crime previsto na Lei nº 13.869/2019, apenado com detenção de seis meses a dois anos e multa'' — cópia literal do art. 16, caput. Distratores invertem a regra (alt4 nega que seja crime cometido no momento da captura) ou fabricam agravante inexistente (alt5 — o parágrafo único prevê a MESMA pena para o responsável por interrogatório que se identifica falsamente, não pena agravada) — art. 16, parágrafo único.', 'alta'),
    (291, 'd4d8a1fc-4c52-4c85-879c-031d0085be88'::uuid, 1, 'Divergência de interpretação não configura abuso', 'Gabarito ''Não configura abuso de autoridade por si só'' — cópia literal do art. 1º, §2º (''A divergência na interpretação de lei ou na avaliação de fatos e provas não configura abuso de autoridade''). QUASE-DUPLICATA documentada: Q193 (conteúdo 62, já concluído) testa o mesmo tema com o mesmo gabarito e 3 das 5 alternativas idênticas, diferindo apenas em 2 distratores (''É equiparada a tortura''/''Dispensa dolo específico'' nesta questão vs. ''É automaticamente improbidade''/''É crime hediondo'' na Q193). Q193 não foi movida nem alterada.', 'alta'),
    (354, 'd4d8a1fc-4c52-4c85-879c-031d0085be88'::uuid, 1, 'Crimes em espécie e exceção de licitude (multi-dispositivo)', 'Situação I (Caio, servidor militar, submete testemunha de crimes violentos a procedimento repetitivo que a leva a reviver, sem estrita necessidade, a situação de violência) — configura crime de violência institucional, art. 15-A, caput (vítima de infração penal ou testemunha de crimes violentos). Situação II (Tício inova artificiosamente o estado de coisa no curso de diligência, com o fim de agravar a responsabilidade de Mário) — configura crime, art. 23, caput (''inovar artificiosamente... com o fim de... agravar-lhe a responsabilidade''); o dispositivo do projeto de lei original que numericamente antecederia este foi integralmente vetado no processo legislativo e não possui texto vigente, por isso não serve de fundamento. Situação III (Rômulo ingressa em residência à revelia do morador, sem determinação judicial, em situação de desastre, para prestar socorro a terceiro) — NÃO configura crime, por se enquadrar na exceção do art. 22, §2º (não há crime se o ingresso for para prestar socorro ou em razão de flagrante delito ou desastre). Gabarito ''Apenas I e II'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 57,128,291,354

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Abuso de Autoridade: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
