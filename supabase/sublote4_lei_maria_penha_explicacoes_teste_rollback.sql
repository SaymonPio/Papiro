-- ============================================================================
-- SUB-LOTE 4 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (31 QUESTÕES)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado por scripts/gerar-harness-sublote4-explicacoes.mjs a partir de
-- scripts/sublote4-lei-maria-penha-explicacoes.mjs (fonte da verdade dos
-- textos, aprovada na Fase 2). As 31 explicações já passaram por
-- scripts/validar-sublote4-explicacoes.mjs (31/31 aprovadas: gabarito de
-- cada texto bate com a alternativa correta=true no banco, todas as
-- alternativas de cada questão são comentadas individualmente, estrutura
-- obrigatória completa, 31 ids únicos confirmados, id 738 confirmado
-- ausente, pares 129/864, 133/865 e 134/863 confirmados idênticos).
--
-- Questões: 21, 40, 51, 129, 133, 134, 344, 345, 346, 347, 671, 672, 673, 734, 735, 736, 737, 739, 778, 779, 780, 799, 800, 801, 802, 861, 862, 863, 864, 865, 866
-- (31 questões de Lei Maria da Penha JÁ EXISTENTES no banco, fora do Lote
-- 1 de importação, que estavam classificadas EXPLICACAO_INCOMPLETA —
-- texto boilerplate sem estrutura pedagógica. id 738, que também estava
-- nesse conjunto, foi excluído do lote — PROBLEMATICA/FUNDAMENTO INCERTO,
-- gabarito atribui a delegado de polícia poder de afastamento cautelar em
-- violência contra criança/adolescente sem base legal confirmada no texto
-- vigente do art. 130 do ECA (que reserva a medida à autoridade
-- judiciária) nem na própria Lei Maria da Penha.
--
-- Ressalvas de precisão jurídica aplicadas nas explicações (Fase 1 e 2,
-- já revisadas pelo usuário): ids 51 e 866 esclarecem que o enunciado usa
-- a redação antiga do art. 12-C ("física ou psicológica"), enquanto a
-- redação vigente (Lei 15.411/2026) ampliou o critério de risco para
-- física, sexual, psicológica, moral ou patrimonial — sem alterar o
-- gabarito de nenhuma das duas. id 780 esclarece que "erradicar" não é a
-- redação literal do art. 1º ("coibir e prevenir"), mas continua sendo a
-- melhor alternativa entre as 5 oferecidas. id 800 esclarece que a
-- alternativa correta (Delegacia de Atendimento à Mulher) se sustenta como
-- diretriz institucional dos arts. 8º, IV e 12-A, não como providência
-- imediata citada literalmente nos arts. 10 a 12.
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam — provado abaixo por
-- hash md5 linha a linha antes/depois, não só por contagem agregada.
--
-- Nenhuma questão PROBLEMATICA (gabarito ambíguo) foi tocada — confirmado
-- na auditoria: nenhuma das 31 tem 0 ou mais de 1 alternativa correta.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash por questão (prova de que só explicacao muda) +
-- contadores agregados (prova de ausência de efeito colateral em outras
-- tabelas).
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes_questoes on commit drop as
select
  q.id,
  q.ativa as ativa_antes,
  md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_questao,
  (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = q.id
  ) as hash_alternativas,
  (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id
  ) as hash_vinculos_unidade,
  (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = q.id
  ) as hash_vinculos_curso
from public.questoes q
where q.id in (21, 40, 51, 129, 133, 134, 344, 345, 346, 347, 671, 672, 673, 734, 735, 736, 737, 739, 778, 779, 780, 799, 800, 801, 802, 861, 862, 863, 864, 865, 866);

create temporary table _snapshot_antes_agregado on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_unidade,
  (select count(*) from public.curso_questoes) as total_curso_questoes,
  (select count(*) from public.questoes where explicacao is not null) as total_com_explicacao;

-- ----------------------------------------------------------------------------
-- Staging: as 31 explicações novas.
-- ----------------------------------------------------------------------------
create temporary table _staging_explicacoes (
  questao_id bigint primary key,
  explicacao_nova text
) on commit drop;

insert into _staging_explicacoes (questao_id, explicacao_nova) values
  (21, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 5º, caput, da Lei 11.340/2006 define que configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial — exatamente a definição reproduzida pela alternativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restringe indevidamente a violência doméstica à agressão física com incapacidade permanente — a Lei reconhece 6 modalidades de violência (física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária), e mesmo dentro da violência física não há exigência de incapacidade permanente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º não exige casamento — abrange a unidade doméstica (inciso I), a família por laços naturais, afinidade ou vontade expressa (inciso II) e qualquer relação íntima de afeto, com ou sem coabitação (inciso III).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Nenhum dos três âmbitos do art. 5º exige que a violência ocorra dentro da residência — a relação íntima de afeto, por exemplo, independe de coabitação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A configuração da violência doméstica e familiar, para os efeitos da Lei, não depende de comunicação prévia à autoridade policial — isso é uma condição de registro/procedimento, não um elemento da definição do art. 5º.

BIZU DE PROVA:
A definição do art. 5º tem 3 elementos: ação OU omissão + baseada no gênero + um dos 3 âmbitos (unidade doméstica, família, relação íntima de afeto). Nenhum deles exige casamento, coabitação ou comunicação prévia à polícia.'),
  (40, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 11, I, da Lei determina que, no atendimento à mulher em situação de violência doméstica e familiar, a autoridade policial deverá, entre outras providências, garantir proteção policial, quando necessário, comunicando de imediato ao Ministério Público e ao Poder Judiciário — exatamente como descreve a alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a regra do art. 9º, §7º: a prioridade de matrícula/transferência dos dependentes na instituição de educação básica mais próxima do domicílio é condicionada à apresentação dos documentos comprobatórios do registro da ocorrência ou do processo em curso — não é "independentemente" disso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO ao tomar conhecimento da iminência ou da prática de violência doméstica — não há exigência de autorização judicial prévia para essa atuação inicial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 10-A, caput, garante atendimento policial e pericial especializado prestado por servidores PREFERENCIALMENTE do sexo feminino — não "obrigatoriamente".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 12-B, §3º, autoriza a autoridade policial a requisitar diretamente os serviços públicos necessários à defesa da mulher e de seus dependentes — não há intermediação do Ministério Público para esse ato.

BIZU DE PROVA:
"Preferencialmente do sexo feminino" (nunca "obrigatoriamente") e "de imediato" (nunca "mediante autorização judicial") são as trocas de palavra mais cobradas sobre os arts. 10 a 11 — decore essas duas.'),
  (51, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
Dizer que é "vedado ao policial afastar o agressor... em qualquer hipótese" contraria diretamente o art. 12-C, III, que autoriza expressamente o policial a determinar o afastamento imediato do agressor quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia — não se trata de vedação absoluta.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz corretamente o art. 8º, IV, sobre a implementação de atendimento policial especializado, em particular nas Delegacias de Atendimento à Mulher, como diretriz da política pública de prevenção.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 9º, §7º, sobre a prioridade de matrícula/transferência dos dependentes mediante apresentação dos documentos comprobatórios.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 10, caput, sobre a atuação de imediato da autoridade policial diante da iminência ou prática de violência doméstica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 10-A, caput, sobre o direito a atendimento policial e pericial especializado, preferencialmente por servidores do sexo feminino.

BIZU DE PROVA:
Nota sobre a redação da alternativa E: ela usa a fórmula antiga do art. 12-C ("risco... à integridade física ou psicológica"). A redação vigente, desde a Lei 15.411/2026, ampliou esse critério para física, sexual, psicológica, moral ou patrimonial. Isso não muda o gabarito — o erro da alternativa está em dizer "vedado em qualquer hipótese", não na extensão do risco —, mas fica o registro: hoje o rol de riscos que autorizam o afastamento é mais amplo do que a alternativa reproduz.'),
  (129, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As assertivas I e III reproduzem, respectivamente, os incisos I e III do art. 10-A, §1º, da Lei: I — salvaguarda da integridade física, psíquica e emocional da depoente; III — não revitimização, evitando sucessivas inquirições sobre o mesmo fato nos âmbitos criminal, cível e administrativo, bem como questionamentos sobre a vida privada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, mas a III também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas a assertiva II, que não integra o rol do art. 10-A, §1º — "garantia de proteção policial, comunicando ao Ministério Público e ao Poder Judiciário" é providência do art. 11, I, não uma diretriz de inquirição.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa pelo motivo acima, e ainda assim omite a assertiva III, que é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui todas as três assertivas, mas a II não é uma diretriz de inquirição do art. 10-A, §1º.

BIZU DE PROVA:
As diretrizes de inquirição do art. 10-A, §1º são só 3: salvaguarda da integridade (I), vedação de contato direto com investigados/suspeitos (II — não confundir com "proteção policial"!) e não revitimização (III). "Garantir proteção policial, comunicando ao MP e Judiciário" é do art. 11, um dispositivo diferente.'),
  (133, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 18, caput, da Lei determina que, recebido o expediente com o pedido da ofendida, caberá ao juiz, no prazo de 48 (quarenta e oito) horas, conhecer do expediente e do pedido e decidir sobre as medidas protetivas de urgência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
12 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
18 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
24 horas é o prazo de outro dispositivo — a comunicação ao juiz do afastamento provisório do agressor decretado pelo delegado ou pelo policial (art. 12-C, §1º), não o prazo do art. 18 para decidir sobre as medidas protetivas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
36 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

BIZU DE PROVA:
48 horas = prazo do juiz para decidir sobre medidas protetivas (art. 18) E prazo da autoridade policial para remeter o expediente com o pedido da ofendida (art. 12, III). 24 horas = prazo de comunicação ao juiz quando o afastamento é decretado por delegado ou policial (art. 12-C, §1º). São números fáceis de trocar — sempre identifique QUEM está fazendo o quê antes de escolher o prazo.'),
  (134, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As assertivas I e II reproduzem o art. 9º, §2º, incisos I e III: I — acesso prioritário à remoção quando servidora pública, integrante da administração direta ou indireta; II — encaminhamento à assistência judiciária, inclusive para eventual ajuizamento de ação de separação judicial, divórcio, anulação de casamento ou dissolução de união estável.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, mas a II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas a assertiva II, mas a I também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa: o art. 9º, §2º, II, prevê manutenção do vínculo trabalhista quando necessário o afastamento do local de trabalho por até SEIS meses, não três.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa pelo mesmo motivo acima.

BIZU DE PROVA:
O art. 9º, §2º, tem 3 incisos: I — remoção prioritária (servidora pública); II — assistência judiciária; III — manutenção do vínculo trabalhista por até SEIS meses (não três, não doze — bancas adoram trocar esse número).'),
  (344, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As três assertivas são verdadeiras. A primeira reproduz o art. 8º, I (integração operacional do Poder Judiciário, Ministério Público e Defensoria Pública com as áreas de segurança pública, assistência social, saúde, educação, trabalho e habitação). A segunda reproduz literalmente o caput vigente do art. 9º, na redação dada pela Lei 14.887/2024 (assistência prestada em caráter prioritário no SUS e no Susp). A terceira reproduz o art. 9º, §5º (dispositivos de segurança para monitoramento de vítimas amparadas por medidas protetivas, com custos ressarcidos pelo agressor).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca a terceira assertiva como falsa, quando na verdade é verdadeira (art. 9º, §5º).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca a segunda e a terceira assertivas como falsas, quando ambas são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca a primeira e a segunda assertivas como falsas, quando ambas são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Marca a primeira assertiva como falsa, quando na verdade é verdadeira (art. 8º, I).

BIZU DE PROVA:
Essa questão já cobra a redação vigente do art. 9º, caput (Lei 14.887/2024): "caráter prioritário no SUS e no Susp" — decore essa expressão exata, é a mais cobrada em provas recentes sobre esse artigo.'),
  (345, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 2º da Lei assegura a toda mulher as oportunidades e facilidades para viver sem violência, preservar sua saúde física e mental e seu aperfeiçoamento MORAL, INTELECTUAL e SOCIAL — as três assertivas reproduzem exatamente esses três termos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, mas II e III também estão corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas a assertiva II, mas I e III também estão corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas I e II, mas a III também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera apenas II e III, mas a I também está correta.

BIZU DE PROVA:
O art. 2º fecha com a tríade "aperfeiçoamento moral, intelectual e social" — decore os três juntos, é comum a banca pedir só um ou dois para testar se você lembra do trio completo.'),
  (346, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Somente a assertiva III está correta: reproduz o art. 5º, I, que define o âmbito da unidade doméstica como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I é falsa: o art. 5º, III, exige relação íntima de afeto, mas dispensa expressamente a coabitação — a assertiva inverte a regra ao exigi-la.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmar que todas as assertivas estão incorretas ignora que a III é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva I é falsa, pelo motivo já explicado (coabitação não é exigida na relação íntima de afeto).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva II é falsa: o art. 5º, II, define família como a comunidade formada por indivíduos unidos por laços naturais, por afinidade OU por vontade expressa — a assertiva restringe indevidamente a "laços sanguíneos", excluindo afinidade e vontade expressa.

BIZU DE PROVA:
Duas pegadinhas clássicas nessa questão: exigir coabitação na relação íntima de afeto (art. 5º, III — não exige) e restringir "família" a laços sanguíneos (art. 5º, II — também inclui afinidade e vontade expressa).'),
  (347, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 2-1-4-3, associando cada descrição à modalidade de violência do art. 7º: "causar dano emocional e diminuição da autoestima..." é violência PSICOLÓGICA (2, art. 7º, II); "constranger a presenciar relação sexual não desejada" é violência SEXUAL (1, art. 7º, III); "ofender sua integridade ou saúde corporal" é violência FÍSICA (4, art. 7º, I); "destruir parcial ou totalmente seus objetos" é violência PATRIMONIAL (3, art. 7º, IV).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Troca a terceira e a quarta posições, associando incorretamente "ofender integridade ou saúde corporal" à violência patrimonial e "destruir objetos" à violência física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Troca a primeira e a segunda posições, associando "dano emocional" à violência sexual e "presenciar relação sexual" à violência psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte quase toda a sequência, associando "dano emocional" à violência patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Associa "dano emocional" à violência física, quando na verdade define violência psicológica.

BIZU DE PROVA:
Decore o núcleo de cada modalidade do art. 7º: física = corpo; psicológica = emoção/controle; sexual = liberdade sexual; patrimonial = bens/objetos; moral = calúnia/difamação/injúria (não cobrada nesta questão, mas faz parte do mesmo rol — hoje ampliado com a violência vicária, art. 7º, VI, Lei 15.384/2026).'),
  (671, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado "EXCETO"):
O art. 10-A, §1º, II, garante justamente o oposto: a garantia de que, em nenhuma hipótese, a mulher em situação de violência doméstica e familiar, familiares e testemunhas terão contato direto com investigados ou suspeitos e pessoas a eles relacionadas. A alternativa inverte essa regra.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma conduta imediata prevista, não a exceção pedida):
Reproduz o art. 12, II — colher todas as provas que servirem para o esclarecimento do fato e de suas circunstâncias.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma conduta imediata prevista, não a exceção pedida):
Reproduz o art. 12, IV — determinar o exame de corpo de delito da ofendida e requisitar outros exames periciais necessários.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma conduta imediata prevista, não a exceção pedida):
Reproduz o art. 12, I — ouvir a ofendida, lavrar o boletim de ocorrência e tomar a representação a termo, se apresentada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma conduta imediata prevista, não a exceção pedida):
Reproduz o art. 12, V — ouvir o agressor e as testemunhas.

BIZU DE PROVA:
O rol do art. 12 é extenso e todas as providências são cabíveis "em todos os casos" — a pegadinha típica é inverter uma regra de proteção (como a vedação de contato direto com investigados) transformando-a no seu oposto.'),
  (672, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 12-C, §2º, determina que, nos casos de risco à integridade física da ofendida ou à efetividade da medida protetiva de urgência, não será concedida liberdade provisória ao preso.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 10-A, caput, garante justamente o oposto: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, prestado preferencialmente por servidores do sexo feminino.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10-A, §2º, prevê esse recinto especialmente projetado como procedimento PREFERENCIAL, não obrigatório em toda e qualquer inquirição.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 12-B, §3º, autoriza expressamente a autoridade policial a requisitar os serviços públicos necessários à defesa da mulher e de seus dependentes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 11, III, determina exatamente o oposto: fornecer transporte para a ofendida e seus dependentes para abrigo ou local seguro, quando houver risco de vida.

BIZU DE PROVA:
"Não será concedida liberdade provisória" nos casos de risco à integridade física ou à efetividade da medida protetiva (art. 12-C, §2º) é uma das regras mais cobradas sobre prisão/liberdade na Lei — decore essa vedação.'),
  (673, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 8º, VII, inclui, entre as diretrizes da política pública de prevenção, a capacitação permanente das Polícias Civil e Militar, da Guarda Municipal, do Corpo de Bombeiros e dos profissionais das áreas enunciadas no inciso I, quanto às questões de gênero e de raça ou etnia.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, parágrafo único, dispõe exatamente o oposto: as relações pessoais enunciadas no artigo independem de orientação sexual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 3º, §2º, atribui à família, à sociedade e ao poder público o dever de criar as condições necessárias para o efetivo exercício dos direitos do caput, incluindo cultura e esporte.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Desde a Lei 14.887/2024, o caput do art. 9º prevê caráter prioritário tanto no SUS quanto no Susp (Sistema Único de Segurança Pública) — não apenas no SUS.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 6º dispõe exatamente o oposto: a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
Desde 2024, o art. 9º fala em "SUS e Susp" — qualquer alternativa que restrinja essa prioridade só ao SUS está desatualizada/errada. E o art. 8º, VII, inclui expressamente a Guarda Municipal na capacitação, não só as polícias.'),
  (734, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Destruir o computador, a impressora e os documentos de trabalho de Aline configura violência patrimonial, nos termos do art. 7º, IV — conduta que configure retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de conduta que cause dano emocional, controle ou degradação psicológica — o episódio narrado é especificamente sobre destruição de bens e instrumentos de trabalho.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há calúnia, difamação ou injúria descrita na situação — elementos que caracterizariam violência moral (art. 7º, V).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há conduta de natureza sexual descrita no caso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de agressão à integridade física ou saúde corporal de Aline — a conduta de Arthur recaiu sobre bens materiais, não sobre o corpo dela.

BIZU DE PROVA:
Destruir instrumentos de trabalho e documentos é o exemplo mais clássico de violência patrimonial (art. 7º, IV) nas provas — sempre que o enunciado descrever dano a objetos/bens/documentos, pense primeiro em patrimonial.'),
  (735, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A situação se enquadra na Lei Maria da Penha porque houve agressão física entre duas mulheres em relação íntima de afeto (casal em relação homoafetiva) — nos termos do art. 5º, III, combinado com o parágrafo único, que dispensa expressamente qualquer exigência quanto à orientação sexual das envolvidas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O local público não é o fundamento da aplicação da Lei — o que importa é a relação entre agressora e ofendida (relação íntima de afeto), não o local da agressão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A aplicação da Lei não depende de a situação ser domiciliar — o art. 5º também abrange a relação íntima de afeto, independentemente de coabitação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não se restringe a crimes dolosos — trata da violência doméstica e familiar em suas diferentes formas e contextos, sem essa limitação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — a alternativa afirma justamente o contrário do texto legal.

BIZU DE PROVA:
Relação íntima de afeto independe de orientação sexual (art. 5º, parágrafo único) e de coabitação (art. 5º, III) — a Lei protege a mulher enquanto vítima de violência de gênero em qualquer desses vínculos, incluindo relações homoafetivas entre mulheres.'),
  (736, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Além de apartar as partes e registrar os fatos, o art. 11, II, determina que a autoridade policial encaminhe a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal, como uma das providências no atendimento à mulher em situação de violência doméstica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há previsão legal de comunicação a autoridade religiosa para fins de conciliação — pelo contrário, a Lei afasta mecanismos de conciliação/mediação nesses casos (art. 41 c/c a vedação da Lei 9.099/1995).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há previsão de encaminhamento da ofendida ao cartório para divórcio imediato como providência do atendimento inicial — o encaminhamento à assistência judiciária (art. 11, V) é o caminho correto, não um "divórcio imediato" no cartório.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há previsão de audiência pública entre familiares como providência de atendimento — isso contrariaria, inclusive, a proteção e o sigilo devidos à ofendida.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há previsão de acionamento de síndico por omissão de socorro como providência da Lei Maria da Penha.

BIZU DE PROVA:
O rol de providências do art. 11 inclui encaminhar ao hospital/posto de saúde E ao IML — decore essa dupla, é uma das mais cobradas junto com "transporte para abrigo quando há risco de vida".'),
  (737, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 8º, IV, estabelece como diretriz da política pública de prevenção a implementação de atendimento policial especializado para as mulheres, em particular nas Delegacias de Atendimento à Mulher (DEAMs) — reforçado pelo art. 12-A, que determina aos Estados e ao Distrito Federal dar prioridade, no âmbito da Polícia Civil, à criação dessas delegacias especializadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Departamento de Ordem Pública e Social" não é órgão previsto na Lei Maria da Penha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Divisão Policial das Relações Sexuais e de Gênero" não é órgão previsto na Lei Maria da Penha — nome fantasioso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Setor Criminal de Perícia Alternativa" não é órgão previsto na Lei Maria da Penha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Secretaria Municipal da Assistência e Promoção Produtiva" não é órgão previsto na Lei Maria da Penha.

BIZU DE PROVA:
Sempre que a questão perguntar pelo órgão especializado no atendimento à mulher em situação de violência doméstica, a resposta-padrão é a Delegacia Especializada de Atendimento à Mulher (DEAM), citada nos arts. 8º, IV e 12-A.'),
  (739, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A conduta de Arthur — forçar a esposa ao aborto mediante ameaça de retirar apoio financeiro — configura violência sexual, nos termos do art. 7º, III, que expressamente prevê como violência sexual a conduta que force a mulher ao aborto mediante coação, chantagem, suborno ou manipulação. A Lei Maria da Penha é a legislação específica que protege a mulher nessa hipótese.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Decreto-Lei ''João Traído''" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Lei da Vergonha Pública" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Código de Defesa Familiar" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Lei do Ventre Livre" é uma lei histórica de 1871, sobre a condição dos filhos de mulheres escravizadas — não tem relação com a proteção da mulher contra violência doméstica.

BIZU DE PROVA:
Forçar a mulher ao aborto, à gravidez, ao matrimônio ou impedi-la de usar método contraceptivo, mediante coação, chantagem, suborno ou manipulação, é violência SEXUAL pelo art. 7º, III — não pense automaticamente em violência física só porque envolve o corpo da vítima.'),
  (778, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A retirada da máquina de costura e dos documentos pessoais de registro profissional da vítima, impedindo-a de exercer sua profissão e obter recursos econômicos, configura violência patrimonial (art. 7º, IV), e a Lei Maria da Penha é a legislação específica de proteção da mulher nessa hipótese.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Lei do Ventre Livre" é uma lei histórica de 1871, sem relação com a proteção da mulher contra violência doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Código de Proteção Familiar" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Lei Estadual das Mulheres" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Código de Trânsito Profissional" não existe como legislação brasileira — nome fantasioso.

BIZU DE PROVA:
Retenção, subtração ou destruição de objetos, instrumentos de trabalho, documentos pessoais, bens, valores ou recursos econômicos da mulher é sempre violência patrimonial (art. 7º, IV) — e a legislação específica de proteção é sempre a Lei Maria da Penha.'),
  (779, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado "EXCETO"):
O art. 11, V, determina justamente o oposto: informar à ofendida os direitos a ela conferidos na Lei e os serviços disponíveis, inclusive os de assistência judiciária para eventual ajuizamento de ação de separação judicial, divórcio, anulação de casamento ou dissolução de união estável. A alternativa inverte essa obrigação em uma suposta "impossibilidade".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma providência prevista, não a exceção pedida):
Reproduz o art. 11, I — garantir proteção policial, quando necessário, comunicando de imediato ao Ministério Público e ao Poder Judiciário.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma providência prevista, não a exceção pedida):
Reproduz o art. 11, II — encaminhar a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma providência prevista, não a exceção pedida):
Reproduz o art. 11, III — fornecer transporte para a ofendida e seus dependentes para abrigo ou local seguro, quando houver risco de vida.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma providência prevista, não a exceção pedida):
Reproduz o art. 11, I — garantir proteção policial, quando necessário.

BIZU DE PROVA:
O art. 11 tem 5 incisos de providências no atendimento — memorize o rol completo (proteção, IML, transporte, retirada de pertences, informação de direitos) para identificar rápido quando a banca inverte uma delas em "impossibilidade" ou "vedação".'),
  (780, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Entre as 5 opções, "erradicar a violência doméstica e familiar contra a mulher" é a que melhor traduz a finalidade da Lei. É importante registrar, porém, que a redação literal do art. 1º usa outros verbos: a Lei "cria mecanismos para COIBIR E PREVENIR a violência doméstica e familiar contra a mulher" — "erradicar" não é a palavra exata do texto legal, mas, diante das demais alternativas (claramente desconectadas do tema), é a única que capta corretamente o propósito da norma.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha não trata de controle ou punição ao uso de drogas ilícitas — esse é objeto de legislação distinta (Lei de Drogas).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei Maria da Penha não trata de discriminação racial — esse é objeto de legislação distinta (Estatuto da Igualdade Racial, entre outras).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei Maria da Penha não trata de acidentes de trânsito — tema alheio ao seu objeto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei Maria da Penha não "defende a prática da liberdade sexual de todas as formas" — ela protege a mulher contra a violência doméstica e familiar, inclusive a violência sexual praticada contra ela, o que é diferente de promover liberdade sexual em geral.

BIZU DE PROVA:
Se a prova pedir a redação LITERAL do art. 1º, a resposta é "coibir e prevenir" — não "erradicar". Mas se todas as outras opções forem visivelmente erradas (como aqui), "erradicar a violência doméstica" ainda é a única alternativa alinhada ao propósito da Lei, mesmo sem ser cópia literal do texto.'),
  (799, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As assertivas II e III estão corretas: II reproduz o art. 5º, I (unidade doméstica como espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas); III reproduz o art. 9º, §3º (assistência compreende acesso aos benefícios decorrentes do desenvolvimento científico e tecnológico).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva III, mas a II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva I, que é falsa: a Lei NÃO deixou de prever a implementação de atendimento policial especializado — essa diretriz continua expressamente prevista no art. 8º, IV.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva I, que é falsa pelo mesmo motivo acima.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva I, que é falsa pelo mesmo motivo acima.

BIZU DE PROVA:
Cuidado com assertivas que dizem que a Lei "deixou de prever" ou "revogou" algo central como o atendimento policial especializado — isso nunca aconteceu; o art. 8º, IV, permanece em vigor desde a redação original de 2006.'),
  (800, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conduzir a vítima à Delegacia de Atendimento à Mulher é a alternativa que melhor reflete o modelo de atendimento especializado da Lei. Vale o registro de precisão: não existe, nos arts. 10 a 12 (que tratam das condutas imediatas da autoridade policial), uma regra literal dizendo "conduza a vítima à DEAM" — o fundamento correto é institucional, arts. 8º, IV, e 12-A, que estabelecem a implementação de atendimento policial especializado e a prioridade na criação de Delegacias Especializadas de Atendimento à Mulher como diretrizes da política pública de prevenção. Entre as 5 alternativas oferecidas, é a única alinhada ao modelo da Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O registro da ocorrência de violência doméstica contra a mulher segue os próprios arts. 10 a 12 da Lei Maria da Penha, não o Estatuto da Criança e do Adolescente — lei distinta, que trata de outro sujeito de proteção.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Comunicar imediatamente aos meios de comunicação viola o sigilo assegurado à ofendida pelo art. 17-A, que determina que seu nome fique sob sigilo nos processos que apuram crimes de violência doméstica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há previsão legal de intervenção imediata de familiares como conduta padrão da autoridade policial — a Lei estrutura o atendimento em torno de profissionais especializados, não de familiares.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Apoio especializado na área de vias urbanas" não corresponde a nenhuma providência prevista na Lei.

BIZU DE PROVA:
A DEAM é o símbolo do atendimento especializado da Lei Maria da Penha (arts. 8º, IV e 12-A) — mas lembre que essa é uma diretriz institucional de política pública, não uma "conduta imediata" citada literalmente nos arts. 10 a 12. Nas demais alternativas, o erro está em outro lugar: lei errada (A), violação de sigilo (C), ou ausência total de previsão legal (D, E).'),
  (801, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Encontrando-se o agressor nas condições do art. 6º da Lei 10.826/2003 (Estatuto do Desarmamento) — o que inclui policiais —, o art. 22, §2º, determina que o juiz comunique ao órgão, corporação ou instituição responsável as medidas protetivas concedidas e determine a restrição do porte de armas, cabendo ao superior imediato do agressor zelar pelo cumprimento, sob pena de prevaricação ou desobediência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há previsão de "proibição de práticas trabalhistas" como medida protetiva de urgência na Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há previsão de retirada da CNH por prazo indeterminado entre as medidas protetivas do art. 22.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há previsão de "declaração formal e pública de pedido de desculpas" como medida protetiva de urgência na Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A suspensão do convívio da ofendida com os próprios filhos não é uma medida protetiva prevista contra o agressor — pelo contrário, a Lei protege a convivência da ofendida com seus dependentes.

BIZU DE PROVA:
Quando o agressor for agente com porte de arma (ex.: policial), a medida específica é a restrição do porte de armas, com comunicação à corporação e responsabilização do superior imediato (art. 22, §2º) — uma regra específica dentro do rol geral de medidas protetivas.'),
  (802, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 1º da Lei estabelece, em sua redação literal, que ela "cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher" — exatamente a finalidade descrita pela alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha não trata de proteção ao "cidadão de bem" de forma genérica — seu objeto é especificamente a violência doméstica e familiar contra a mulher.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei Maria da Penha não trata de proteção ecológica ou ambiental.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei Maria da Penha não trata de menores infratores — esse é objeto do Estatuto da Criança e do Adolescente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei Maria da Penha não trata de proteção patrimonial de instituições religiosas.

BIZU DE PROVA:
"Coibir e prevenir a violência doméstica e familiar contra a mulher" é a redação literal do art. 1º — decore essas duas palavras (coibir + prevenir) para reconhecer de cara quando a alternativa é uma citação exata do artigo.'),
  (861, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As três assertivas reproduzem o rol de resultados lesivos do art. 5º, caput: morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial — morte (I), sofrimento sexual (II) e dano moral (III) estão todos expressamente previstos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva II, mas I e III também estão corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas I e II, mas a III também está correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas I e III, mas a II também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera apenas II e III, mas a I também está correta.

BIZU DE PROVA:
O art. 5º, caput, lista 5 resultados possíveis: morte, lesão, sofrimento físico, sofrimento sexual, sofrimento psicológico, dano moral OU dano patrimonial — qualquer um desses, presente em um dos 3 âmbitos (doméstico, familiar, relação íntima de afeto), configura violência doméstica.'),
  (862, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Forçar a companheira a se prostituir com terceiros, mediante ameaça, configura violência sexual, nos termos do art. 7º, III, que prevê como tal a conduta que induza a mulher a comercializar ou utilizar, de qualquer modo, a sua sexualidade, mediante coação, chantagem, suborno ou manipulação. A Lei Maria da Penha é a legislação específica de proteção nessa hipótese.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Lei do Livre Matrimônio" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Lei sexual – ''Lei Amarildo Santos''" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Lei da Estabilidade no Casamento" não existe como legislação brasileira — nome fantasioso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Lei de Exceção" não existe como legislação brasileira nesse contexto — nome fantasioso.

BIZU DE PROVA:
Induzir a mulher a comercializar ou utilizar sua sexualidade mediante coação, chantagem, suborno ou manipulação é violência SEXUAL pelo art. 7º, III — mesmo sem contato físico direto do agressor, a coação em si já caracteriza a violência.'),
  (863, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As assertivas I e II reproduzem o art. 9º, §2º, incisos I e III: I — acesso prioritário à remoção quando servidora pública, integrante da administração direta ou indireta; II — encaminhamento à assistência judiciária, inclusive para eventual ajuizamento de ação de separação judicial, divórcio, anulação de casamento ou dissolução de união estável.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, mas a II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas a assertiva II, mas a I também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa: o art. 9º, §2º, II, prevê manutenção do vínculo trabalhista quando necessário o afastamento do local de trabalho por até SEIS meses, não três.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa pelo mesmo motivo acima.

BIZU DE PROVA:
O art. 9º, §2º, tem 3 incisos: I — remoção prioritária (servidora pública); II — assistência judiciária; III — manutenção do vínculo trabalhista por até SEIS meses (não três, não doze — bancas adoram trocar esse número).'),
  (864, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As assertivas I e III reproduzem, respectivamente, os incisos I e III do art. 10-A, §1º, da Lei: I — salvaguarda da integridade física, psíquica e emocional da depoente; III — não revitimização, evitando sucessivas inquirições sobre o mesmo fato nos âmbitos criminal, cível e administrativo, bem como questionamentos sobre a vida privada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, mas a III também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas a assertiva II, que não integra o rol do art. 10-A, §1º — "garantia de proteção policial, comunicando ao Ministério Público e ao Poder Judiciário" é providência do art. 11, I, não uma diretriz de inquirição.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa pelo motivo acima, e ainda assim omite a assertiva III, que é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui todas as três assertivas, mas a II não é uma diretriz de inquirição do art. 10-A, §1º.

BIZU DE PROVA:
As diretrizes de inquirição do art. 10-A, §1º são só 3: salvaguarda da integridade (I), vedação de contato direto com investigados/suspeitos (II — não confundir com "proteção policial"!) e não revitimização (III). "Garantir proteção policial, comunicando ao MP e Judiciário" é do art. 11, um dispositivo diferente.'),
  (865, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 18, caput, da Lei determina que, recebido o expediente com o pedido da ofendida, caberá ao juiz, no prazo de 48 (quarenta e oito) horas, conhecer do expediente e do pedido e decidir sobre as medidas protetivas de urgência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
12 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
18 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
24 horas é o prazo de outro dispositivo — a comunicação ao juiz do afastamento provisório do agressor decretado pelo delegado ou pelo policial (art. 12-C, §1º), não o prazo do art. 18 para decidir sobre as medidas protetivas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
36 horas não corresponde a nenhum prazo previsto na Lei para essa decisão.

BIZU DE PROVA:
48 horas = prazo do juiz para decidir sobre medidas protetivas (art. 18) E prazo da autoridade policial para remeter o expediente com o pedido da ofendida (art. 12, III). 24 horas = prazo de comunicação ao juiz quando o afastamento é decretado por delegado ou policial (art. 12-C, §1º). São números fáceis de trocar — sempre identifique QUEM está fazendo o quê antes de escolher o prazo.'),
  (866, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 12-C, §1º, determina que, nas hipóteses de afastamento do agressor decretado pelo delegado de polícia ou, como no caso descrito, pelo próprio policial (quando o Município não for sede de comarca e não houver delegado disponível), o juiz será comunicado no prazo máximo de 24 (vinte e quatro) horas e decidirá, em igual prazo, sobre a manutenção ou a revogação da medida, dando ciência ao Ministério Público concomitantemente.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
12 horas não corresponde ao prazo previsto no art. 12-C, §1º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
18 horas não corresponde ao prazo previsto no art. 12-C, §1º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
36 horas não corresponde ao prazo previsto no art. 12-C, §1º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
48 horas é o prazo de outro dispositivo (remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III), não o prazo de comunicação do art. 12-C, §1º.

BIZU DE PROVA:
Nota sobre a redação do enunciado: ele reproduz a fórmula antiga do art. 12-C ("integridade física ou psicológica"). A redação vigente, desde a Lei 15.411/2026, ampliou esse critério de risco para física, sexual, psicológica, moral ou patrimonial — isso não muda o gabarito (a pergunta é sobre o prazo de 24 horas, que não foi alterado), mas fica o registro da redação atual, mais abrangente.');

-- ----------------------------------------------------------------------------
-- Revalidação de premissas dentro da própria transação, antes de qualquer
-- escrita (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_fora_do_assunto int;
  v_ativas int;
  v_inativas int;
  v_ids_inativos text;
  v_gabarito_ambiguo int;
  v_tem_738 int;
begin
  select count(*) into v_total from _staging_explicacoes;
  if v_total <> 31 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 31 questoes (tem %)', v_total;
  end if;

  select count(*) into v_tem_738 from _staging_explicacoes where questao_id = 738;
  if v_tem_738 > 0 then
    raise exception 'Precondicao falhou: id 738 nao pode estar neste sub-lote (PROBLEMATICA/FUNDAMENTO INCERTO)';
  end if;

  select count(*) into v_fora_do_assunto
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.assunto_id <> 19;
  if v_fora_do_assunto > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging nao pertencem ao assunto Lei Maria da Penha (assunto_id=19)', v_fora_do_assunto;
  end if;

  -- Composicao EXATA exigida para este sub-lote (decisao explicita do
  -- usuario): 28 ativas + 3 inativas, e as 3 inativas tem que ser
  -- especificamente 863, 864 e 865 (gemeas de 134, 129 e 133). Qualquer
  -- desvio dessa composicao aborta a transacao.
  select count(*) filter (where q.ativa), count(*) filter (where not q.ativa),
    string_agg(q.id::text, ', ' order by q.id) filter (where not q.ativa)
    into v_ativas, v_inativas, v_ids_inativos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id;

  if v_ativas <> 28 then
    raise exception 'Precondicao falhou: esperado exatamente 28 questoes ATIVAS no staging, encontrado %', v_ativas;
  end if;
  if v_inativas <> 3 then
    raise exception 'Precondicao falhou: esperado exatamente 3 questoes INATIVAS no staging, encontrado %', v_inativas;
  end if;
  if v_ids_inativos is distinct from '863, 864, 865' then
    raise exception 'Precondicao falhou: as 3 inativas devem ser exatamente 863, 864, 865 -- encontrado (%)', coalesce(v_ids_inativos, 'nenhuma');
  end if;
  raise notice 'Composicao confirmada: 28 ativas + 3 inativas (863, 864, 865), conforme decisao do usuario.';

  select count(*) into v_gabarito_ambiguo
  from (
    select a.questao_id, count(*) filter (where a.correta) as n_corretas, count(*) as n_alt
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ) x
  where x.n_corretas <> 1 or x.n_alt = 0;
  if v_gabarito_ambiguo > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging tem gabarito ambiguo (PROBLEMATICA) -- nao pode ser atualizada automaticamente', v_gabarito_ambiguo;
  end if;
end $$;

-- Nota: ao contrário dos sub-lotes 1-3, estas 31 questões JÁ TÊM
-- explicação (boilerplate) — por isso não há precondição "já tem
-- explicação preenchida"; o objetivo aqui é justamente SUBSTITUIR esse
-- texto pelo padrão pedagógico completo.

-- ----------------------------------------------------------------------------
-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas_afetadas int;
begin
  update public.questoes q
  set explicacao = s.explicacao_nova
  from _staging_explicacoes s
  where q.id = s.questao_id;

  get diagnostics v_linhas_afetadas = row_count;
  if v_linhas_afetadas <> 31 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 31 -- abortando', v_linhas_afetadas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_sublote4_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_sublote4_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_sublote4_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_antes record;
  v_total_questoes int;
  v_total_alternativas int;
  v_total_vinculos_unidade int;
  v_total_curso_questoes int;
  v_total_com_explicacao int;
  v_diferentes_enunciado_ou_metadado int;
  v_diferentes_alternativas int;
  v_diferentes_vinculo_unidade int;
  v_diferentes_vinculo_curso int;
  v_sem_explicacao_pos int;
  v_generica_ou_vazia int;
  v_incompletas int;
  v_diferentes_ativa int;
  v_863_864_865_ainda_inativas int;
  v_explicacao_863 text;
  v_explicacao_134 text;
  v_explicacao_864 text;
  v_explicacao_129 text;
  v_explicacao_865 text;
  v_explicacao_133 text;
begin
  select * into v_antes from _snapshot_antes_agregado;

  select count(*) into v_total_questoes from public.questoes;
  select count(*) into v_total_alternativas from public.alternativas;
  select count(*) into v_total_vinculos_unidade from public.questao_unidades_pedagogicas;
  select count(*) into v_total_curso_questoes from public.curso_questoes;
  select count(*) into v_total_com_explicacao from public.questoes where explicacao is not null;

  call teste_sublote4_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_antes.total_questoes);
  call teste_sublote4_assert('nenhuma alternativa criada/removida/alterada em quantidade (total_alternativas inalterado)', v_total_alternativas = v_antes.total_alternativas);
  call teste_sublote4_assert('nenhum vinculo de unidade pedagogica criado/removido', v_total_vinculos_unidade = v_antes.total_vinculos_unidade);
  call teste_sublote4_assert('nenhum vinculo de curso_questoes criado/removido', v_total_curso_questoes = v_antes.total_curso_questoes);
  call teste_sublote4_assert('total_com_explicacao inalterado (as 31 ja tinham explicacao boilerplate -- so o CONTEUDO muda, nao a contagem)', v_total_com_explicacao = v_antes.total_com_explicacao);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call teste_sublote4_assert('enunciado/fonte/banca/concurso/materia/assunto/ativa idênticos em todas as 31 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  -- Assert DEDICADO só do campo ativa (independente do hash combinado
  -- acima) -- compara valor a valor contra o snapshot capturado antes do
  -- UPDATE, para as 31 questões, incluindo as 3 inativas.
  select count(*) into v_diferentes_ativa
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where q.ativa is distinct from ant.ativa_antes;
  call teste_sublote4_assert('campo ativa idêntico (valor a valor, comparação dedicada) em todas as 31 questões', v_diferentes_ativa = 0);

  -- Assert NOMEADO: confirma explicitamente que 863, 864 e 865 continuam
  -- ativa=false depois do UPDATE (não é só "não mudou" -- é "continua
  -- exatamente inativa", checado por id específico).
  select count(*) into v_863_864_865_ainda_inativas
  from public.questoes
  where id in (863, 864, 865) and not ativa;
  call teste_sublote4_assert('863, 864 e 865 continuam ativa=false, especificamente, depois do UPDATE', v_863_864_865_ainda_inativas = 3);

  -- Assert de identidade dos pares gêmeos, lendo o valor JÁ GRAVADO pelo
  -- UPDATE de teste diretamente da tabela (não do array-fonte) -- prova
  -- que 863/134, 864/129 e 865/133 ficaram com o mesmo texto na prática.
  select explicacao into v_explicacao_863 from public.questoes where id = 863;
  select explicacao into v_explicacao_134 from public.questoes where id = 134;
  select explicacao into v_explicacao_864 from public.questoes where id = 864;
  select explicacao into v_explicacao_129 from public.questoes where id = 129;
  select explicacao into v_explicacao_865 from public.questoes where id = 865;
  select explicacao into v_explicacao_133 from public.questoes where id = 133;
  call teste_sublote4_assert('explicacao de 863 idêntica à de 134 (par gêmeo)', v_explicacao_863 = v_explicacao_134);
  call teste_sublote4_assert('explicacao de 864 idêntica à de 129 (par gêmeo)', v_explicacao_864 = v_explicacao_129);
  call teste_sublote4_assert('explicacao de 865 idêntica à de 133 (par gêmeo)', v_explicacao_865 = v_explicacao_133);

  select count(*) into v_diferentes_alternativas
  from _snapshot_antes_questoes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call teste_sublote4_assert('alternativas (texto/correta/ordem, ou seja, o gabarito) idênticas em todas as 31 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call teste_sublote4_assert('vinculos de unidade pedagogica idênticos em todas as 31 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call teste_sublote4_assert('vinculos de curso_questoes idênticos em todas as 31 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_sem_explicacao_pos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call teste_sublote4_assert('nenhuma das 31 ficou com explicacao vazia', v_sem_explicacao_pos = 0);

  select count(*) into v_generica_ou_vazia
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso';
  call teste_sublote4_assert('nenhuma das 31 contém apenas boilerplate de gabarito/fonte (confirma que o texto antigo foi substituído)', v_generica_ou_vazia = 0);

  with alt_stats as (
    select a.questao_id, count(*) as n_alt,
      bool_and(lower(btrim(a.texto)) in ('certo','errado')) and count(*) = 2 as eh_certo_errado
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ),
  reclassificado as (
    select q.id,
      case
        when st.eh_certo_errado then
          case when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA' then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
        else
          case when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
            and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= st.n_alt
            then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
      end as status
    from public.questoes q
    join alt_stats st on st.questao_id = q.id
  )
  select count(*) into v_incompletas from reclassificado where status <> 'EXPLICACAO_COMPLETA';
  call teste_sublote4_assert('todas as 31 reclassificam como EXPLICACAO_COMPLETA pela mesma regra da auditoria', v_incompletas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_sublote4_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
