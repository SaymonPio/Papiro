-- ETAPA 4 e 5 do PROMPT MESTRE de curadoria das unidades pedagógicas da Lei
-- Maria da Penha — mapa explícito de classificação semântica das 28
-- questões candidatas (curso_conteudos.id = 53), produzido por leitura
-- humana do enunciado + de TODAS as alternativas de cada questão (nunca por
-- ID, banca, concurso ou palavra-chave isolada).
--
-- SOMENTE LEITURA. Este arquivo não escreve nada — é a fonte única de
-- verdade (mapa aprovado) que os arquivos
--   classificar_questoes_unidades_lei_maria_penha_teste_rollback.sql (Etapa 6/7)
--   classificar_questoes_unidades_lei_maria_penha.sql (Etapa 8)
-- replicam byte a byte na mesma tabela temporária _mapa antes de aplicar.
--
-- Unidades oficiais do conteúdo 53:
--   U1 e260b54c-6a75-4398-97f6-7a432c405041  ordem 1  Fundamentos e campo de aplicação (arts. 1º-7º)
--   U2 ab29ba89-1dcc-46c2-9659-f5808be3d976  ordem 2  Prevenção e assistência à mulher (arts. 8º-9º)
--   U3 4d593bc4-6e4f-4c1f-8817-e41c78fe9491  ordem 3  Atendimento policial e providências imediatas (arts. 10-12-D)
--   U4 7164d7f2-86f7-413e-b0fc-64070dd2e2f5  ordem 4  Procedimentos e medidas protetivas de urgência (arts. 13-24-A)
--   U5 53dc06a1-cd16-4004-a76b-8201d95a91c4  ordem 5  Rede de justiça, equipe multidisciplinar e disposições finais (arts. 25-46)
--
-- Resultado da curadoria: 28/28 questões classificadas, 0 sem classificação,
-- 3 multiunidade (51, 673, 799), 0 problemas novos encontrados (duplicatas,
-- gabarito, corrupção ou fora de escopo já haviam sido tratados nas fases
-- anteriores — ver diagnostico_pendencias_curadoria_lei_maria_penha.sql e o
-- commit acbfe8b). U4 e U5 ficam abaixo da reserva ideal — GAP REAL DO
-- BANCO, registrado na seção de cobertura abaixo; nenhuma questão foi
-- inventada, clonada ou reativada para compensar.

-- ============================================================================
-- 1) MAPA — uma linha por vínculo (questão multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, artigos_relacionados, justificativa, confianca) as (
  values
    (21,  'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º',
      'Pede a definição legal de violência doméstica e familiar; a alternativa correta reproduz o caput do art. 5º (ação ou omissão baseada no gênero).', 'alta'),
    (40,  '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 11, IV',
      'Testa a atuação policial no atendimento à ofendida (garantir proteção policial, comunicar MP/Judiciário); núcleo é providência policial imediata, apesar de um distrator tocar o art. 9º.', 'alta'),
    (51,  'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 8º; art. 9º',
      'Assertivas 1 e 2 (INCORRETA pedida) testam diretriz de política pública (art. 8º, DEAMs) e matrícula prioritária em educação básica (art. 9º).', 'alta'),
    (51,  '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 10-A; art. 11; art. 12-C',
      'Assertivas 3 a 5 testam atendimento policial imediato (art. 10-A/11); a alternativa correta (INCORRETA) nega a vedação do afastamento do agressor pelo policial, art. 12-C.', 'alta'),
    (129, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 10-A',
      'Diretrizes de inquirição da mulher em situação de violência (salvaguarda, proteção policial, não revitimização) reproduzem literalmente o art. 10-A.', 'alta'),
    (133, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid, 4, 'art. 18',
      'Prazo de 48 horas para o juiz conhecer do expediente e decidir sobre medida protetiva de urgência é o art. 18, caput.', 'alta'),
    (134, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 9º, §2º',
      'Medidas asseguradas pelo juiz à mulher (remoção prioritária, assistência judiciária, manutenção do vínculo trabalhista) decorrem do art. 9º, §2º — assistência à mulher.', 'alta'),
    (344, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 8º; art. 9º',
      'As três assertivas (todas V) reproduzem diretrizes de política pública (art. 8º) e assistência prioritária no SUS/Susp (art. 9º, caput); tema central é prevenção/assistência, não atendimento policial.', 'alta'),
    (345, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 2º',
      'Reproduz o caput do art. 2º sobre direitos fundamentais assegurados a toda mulher, independentemente de classe/raça/etnia etc.', 'alta'),
    (346, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º',
      'As três assertivas testam os incisos I a III do art. 5º (família, relação íntima de afeto, unidade doméstica) e suas condições de configuração.', 'alta'),
    (347, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 7º',
      'Associação de tipos de violência (sexual, psicológica, patrimonial, física) às condutas descritas reproduz os incisos do art. 7º.', 'alta'),
    (671, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 11',
      'Pede as condutas da autoridade policial adotadas de imediato (lista do art. 11); a alternativa a excluir contraria a proteção contra contato com investigados.', 'alta'),
    (672, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 10-A; art. 11; art. 12-C',
      'Todas as alternativas tratam de atendimento policial especializado, inquirição e restrições ligadas às providências policiais/afastamento imediato do agressor.', 'alta'),
    (673, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º, parágrafo único; art. 6º',
      'Alternativas 1 e 5 testam a irrelevância da orientação sexual (art. 5º, parágrafo único) e a natureza de violação de direitos humanos (art. 6º).', 'alta'),
    (673, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 8º, III',
      'A alternativa correta trata da capacitação permanente da Guarda Municipal quanto a questões de gênero e raça/etnia, diretriz do art. 8º.', 'alta'),
    (734, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 7º, IV',
      'Caso concreto de destruição de bens de trabalho da vítima configura violência patrimonial — art. 7º, IV.', 'alta'),
    (735, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º, III; art. 5º, parágrafo único',
      'Caso de agressão entre casal homoafetivo testa a aplicação da lei independentemente de orientação sexual, em relação íntima de afeto.', 'alta'),
    (736, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 11, II',
      'Providência adicional após apartar as partes e registrar o fato é encaminhar a ofendida ao hospital/IML — art. 11, II.', 'alta'),
    (737, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 8º, III',
      'Pergunta pelo órgão de atenção especializada (Delegacia Especializada de Atendimento à Mulher), diretriz de política pública do art. 8º, III.', 'alta'),
    (739, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º; art. 7º',
      'Caso concreto de coação em união estável exige reconhecer o campo de aplicação da lei (relação íntima de afeto) para identificá-la.', 'alta'),
    (778, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 7º, IV',
      'Caso concreto de violência patrimonial explicitamente rotulado no enunciado; testa reconhecimento da lei aplicável a esse tipo de violência.', 'alta'),
    (779, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 11',
      'Pede as providências da autoridade policial (lista do art. 11); a alternativa a excluir contraria o dever de informar sobre assistência judiciária.', 'alta'),
    (780, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 1º',
      'Pergunta pela finalidade da lei — objeto definido no art. 1º.', 'alta'),
    (799, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º, I',
      'Assertiva II (verdadeira) reproduz a definição de âmbito da unidade doméstica do art. 5º, I.', 'alta'),
    (799, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'art. 8º, III',
      'Assertiva I (falsa) nega que a lei ainda preveja atendimento policial especializado, tema do art. 8º, III. Classificação de apoio: confiança média porque o dispositivo exato da assertiva III (benefícios do desenvolvimento científico/tecnológico) não foi identificado com certeza.', 'media'),
    (800, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 11; art. 12',
      'Condutas dos agentes nos momentos iniciais da ocorrência — condução da ofendida à Delegacia de Atendimento à Mulher — providências policiais imediatas.', 'alta'),
    (801, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid, 4, 'art. 22, I',
      'Medida protetiva de urgência aplicável de imediato ao agressor (restrição do porte de arma) é espécie do art. 22, I.', 'alta'),
    (802, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 1º',
      'Mesma pergunta de finalidade da lei do art. 1º (par temático de 780, não duplicata — enunciados distintos já confirmados na Etapa 1).', 'alta'),
    (861, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º',
      'Reproduz o caput do art. 5º sobre o âmbito familiar e os danos que configuram violência doméstica (morte, sofrimento sexual, dano moral).', 'alta'),
    (862, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'art. 5º, III; art. 7º, III',
      'Caso concreto de violência sexual em união estável (relação íntima de afeto) exige reconhecer o campo de aplicação da lei.', 'alta'),
    (866, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'art. 12-C, §1º',
      'Prazo de 24 horas para comunicação ao juiz após afastamento do agressor pelo policial (município sem comarca) é o art. 12-C, §1º.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLÍCITAS exigidas pela Etapa 4.
-- ============================================================================

-- 2a) Questões classificadas (28/28) — nenhuma ficou de fora.
-- 21,40,51,129,133,134,344,345,346,347,671,672,673,734,735,736,737,739,
-- 778,779,780,799,800,801,802,861,862,866

-- 2b) Questões multiunidade (3): 51 (U2+U3), 673 (U1+U2), 799 (U1+U2, confiança média em U2)

-- 2c) Questões sem classificação: nenhuma (0/28)

-- 2d) Questões problemáticas / novos problemas encontrados nesta leitura: nenhuma.
--     Duplicatas, questão 738 fora de escopo e gabaritos já tinham sido
--     tratados nas fases anteriores (ver commit acbfe8b e os diagnósticos
--     de pendências/duplicatas já existentes em supabase/). Nenhuma nova
--     duplicata, gabarito suspeito, alternativa quebrada ou conteúdo de
--     outra lei foi identificado entre as 28 candidatas nesta leitura.

-- ============================================================================
-- 3) ETAPA 5 — cobertura por unidade (questões distintas, vínculos, gaps).
--    NÃO força nenhuma unidade a atingir 10; unidades fracas são GAP REAL
--    DO BANCO, registrado aqui, não erro técnico.
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade) as (
  values
    (21,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(40,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (51,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),(51,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (129,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),(133,'7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid,4),
    (134,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),(344,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),
    (345,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(346,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (347,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(671,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (672,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),(673,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (673,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),(734,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (735,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(736,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (737,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),(739,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (778,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(779,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (780,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(799,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (799,'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2),(800,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3),
    (801,'7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid,4),(802,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (861,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),(862,'e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1),
    (866,'4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3)
),
unidades (unidade_id, ordem_unidade, titulo) as (
  values
    ('e260b54c-6a75-4398-97f6-7a432c405041'::uuid,1,'Fundamentos e campo de aplicação'),
    ('ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid,2,'Prevenção e assistência à mulher'),
    ('4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid,3,'Atendimento policial e providências imediatas'),
    ('7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid,4,'Procedimentos e medidas protetivas de urgência'),
    ('53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid,5,'Rede de justiça, equipe multidisciplinar e disposições finais')
)
select
  u.ordem_unidade,
  u.titulo,
  coalesce(count(distinct m.questao_id), 0) as questoes_distintas,
  coalesce(count(m.questao_id), 0) as total_vinculos,
  greatest(0, 10 - coalesce(count(distinct m.questao_id), 0)) as faltam_para_10,
  greatest(0, 15 - coalesce(count(distinct m.questao_id), 0)) as faltam_para_15_reserva_ideal,
  case when coalesce(count(distinct m.questao_id), 0) < 10 then 'GAP REAL DO BANCO' else 'ok' end as observacao
from unidades u
left join mapa m on m.unidade_pedagogica_id = u.unidade_id
group by u.ordem_unidade, u.titulo
order by u.ordem_unidade;
