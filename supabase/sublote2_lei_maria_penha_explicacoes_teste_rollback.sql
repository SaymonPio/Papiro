-- ============================================================================
-- SUB-LOTE 2 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (38 QUESTÕES)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado por scripts/gerar-harness-sublote2-explicacoes.mjs a partir de
-- scripts/sublote2-lei-maria-penha-explicacoes.mjs (fonte da verdade dos
-- textos). As 38 explicações já passaram por
-- scripts/validar-sublote2-explicacoes.mjs (38/38 aprovadas: gabarito de
-- cada texto bate com a alternativa correta=true no banco, todas as
-- alternativas de cada questão são comentadas individualmente, estrutura
-- obrigatória completa).
--
-- Questões: 1331, 1332, 1333, 1334, 1335, 1336, 1338, 1339, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348, 1349, 1350, 1351, 1352, 1353, 1354, 1355, 1356, 1357, 1358, 1359, 1360, 1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 1369, 1370
-- (as próximas 40 das 45 SEM_EXPLICACAO restantes do Lote 1 de importação,
-- todas assunto_id=19 / Lei Maria da Penha, ordenadas por id, MENOS as
-- ids 1337 e 1340 — ver exclusão documentada abaixo).
--
-- QUESTÕES EXCLUÍDAS DESTE SUB-LOTE — PROBLEMATICA/DESATUALIZADA (não
-- entram neste harness, não estão em nenhuma UPDATE abaixo, permanecem
-- SEM_EXPLICACAO em produção até decisão editorial futura):
--
--   id 1337 — banca cobrou o entendimento de que maus-tratos/violência
--   cometidos por responsável contra criança/adolescente do sexo feminino
--   no âmbito doméstico seriam tratados fora da Lei Maria da Penha
--   (competência do ECA). Esse era o entendimento predominante à época da
--   prova. O STJ, em julgamento de recurso repetitivo (Tema Repetitivo
--   1.186), fixou que a condição de sexo feminino da vítima é suficiente
--   para atrair a incidência da Lei Maria da Penha mesmo quando a vítima
--   é criança ou adolescente, e que, havendo conflito de competência, a
--   Lei Maria da Penha prevalece sobre o ECA. O gabarito histórico da
--   banca contraria esse entendimento hoje vinculante — por isso não é
--   gerada explicação que apresente o gabarito original como direito
--   atual. Questão marcada PROBLEMATICA/DESATUALIZADA, não SEM_EXPLICACAO.
--
--   id 1340 — mesma razão do id 1337: uma das assertivas do item
--   (maus-tratos de pais adotivos contra filha criança tratados pelo ECA,
--   fora dos Juizados de Violência Doméstica) foi redigida pela banca como
--   verdadeira, contrariando o Tema Repetitivo 1.186/STJ hoje vigente.
--   Mesma classificação: PROBLEMATICA/DESATUALIZADA.
--
-- Auditoria textual prévia (não bloqueante — nenhuma altera gabarito ou
-- fundamento jurídico, por isso nenhuma das 38 aplicadas foi marcada
-- PROBLEMATICA por esse motivo):
-- id 1363 tem "prisão preventivav"/"adotadará" (erros de digitação no
-- enunciado/alternativa originais); id 1367 cita "Lei nº 11.340/2008" (o
-- correto é 2006); id 1348 tem acentuação inconsistente; id 1359 e 1361 têm
-- prefixo "(PMLM/URCA 2025)" e "$8º" em vez de "§8º" (mesmo padrão OCR já
-- visto e aceito nos cadernos 971/974 da auditoria original do Lote 1).
-- ENUNCIADO E ALTERNATIVAS NÃO FORAM ALTERADOS — só registrados para
-- conferência futura contra o PDF original.
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam — provado abaixo por
-- hash md5 linha a linha antes/depois, não só por contagem agregada.
--
-- Nenhuma questão PROBLEMATICA por gabarito ambíguo (0 ou >1 alternativa
-- correta) foi tocada — confirmado na auditoria: nenhuma das 38 aplicadas
-- tem esse problema estrutural. As duas exclusões por conteúdo jurídico
-- desatualizado (1337, 1340) estão documentadas acima e ficam fora deste
-- UPDATE.
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
where q.id in (1331, 1332, 1333, 1334, 1335, 1336, 1338, 1339, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348, 1349, 1350, 1351, 1352, 1353, 1354, 1355, 1356, 1357, 1358, 1359, 1360, 1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 1369, 1370);

create temporary table _snapshot_antes_agregado on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_unidade,
  (select count(*) from public.curso_questoes) as total_curso_questoes,
  (select count(*) from public.questoes where explicacao is not null) as total_com_explicacao;

-- ----------------------------------------------------------------------------
-- Staging: as 38 explicações novas.
-- ----------------------------------------------------------------------------
create temporary table _staging_explicacoes (
  questao_id bigint primary key,
  explicacao_nova text
) on commit drop;

insert into _staging_explicacoes (questao_id, explicacao_nova) values
  (1331, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Ser constantemente insultada, difamada e humilhada pelo marido, com diminuição progressiva da autoestima, é a definição legal de violência psicológica (art. 7º, II, da Lei 11.340/2006). A Lei se aplica independentemente da idade da vítima ou do agressor — não há exceção etária que afaste sua incidência quando presente a relação conjugal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Abandono" não é uma das 5 modalidades de violência doméstica do art. 7º da Lei Maria da Penha (é conceito mais associado ao Estatuto do Idoso, lei diversa da que a questão pede).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Maus tratos" não é o termo técnico usado pelo art. 7º para descrever o relato apresentado; o enquadramento correto, dentro da Lei Maria da Penha, é violência psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação não trata de vulnerabilidade socioeconômica — o relato descreve insultos e humilhações reiterados, não privação material.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência emocional" não é o termo empregado pelo art. 7º da Lei — o termo legal correto é violência psicológica (art. 7º, II).

BIZU DE PROVA:
A Lei Maria da Penha não tem exceção etária: protege a mulher em situação de violência doméstica independentemente de sua idade ou da idade do agressor. E fique atento a sinônimos que a banca usa no lugar dos 5 termos técnicos do art. 7º (física, psicológica, sexual, patrimonial, moral) — "violência emocional" e "maus tratos" não são esses termos.'),
  (1332, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todos os 5 itens descrevem formas de violência doméstica previstas no art. 7º da Lei: I (difamação por mídia virtual) é violência moral/psicológica praticada por qualquer meio, inclusive virtual; II (proibição de usar métodos contraceptivos) é violência sexual (art. 7º, III); III (destruição de documentos pessoais) é violência patrimonial (art. 7º, IV); IV (cárcere privado) é violência física, por ofender a liberdade e a integridade da vítima; V (agressão física por companheira em relação homoafetiva) está abrangida porque o art. 5º, parágrafo único, dispensa orientação sexual como requisito.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente a resposta a apenas um item (II), quando os 5 itens estão corretos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui os itens III e V, que também estão corretos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui os itens II e IV, que também estão corretos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui os itens I, II e III, que também estão corretos.

BIZU DE PROVA:
O art. 7º é um rol amplo — quase qualquer conduta que prejudique a mulher no âmbito doméstico/familiar/afetivo (inclusive por meio virtual, e inclusive entre parceiras do mesmo sexo) se enquadra em alguma das 5 modalidades. Desconfie de alternativas que excluem itens sem uma razão jurídica clara para isso.'),
  (1333, 'GABARITO: CERTO

POR QUE:
A conduta do marido que configure calúnia, difamação ou injúria contra a esposa é, pela letra do art. 7º, V, da Lei 11.340/2006, expressamente classificada como violência moral. O item reproduz corretamente a definição legal.

PEGADINHA:
Se o item trocasse "violência moral" por "violência psicológica" ou "violência física", estaria errado — calúnia, difamação e injúria são, especificamente, violência moral.

BIZU DE PROVA:
Calúnia, difamação, injúria = violência moral (art. 7º, V) — são os mesmos crimes contra a honra do Código Penal, e é assim que a banca costuma testar essa modalidade.'),
  (1334, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou de outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 41 afasta expressamente a aplicação da Lei 9.099/1995 aos crimes praticados com violência doméstica e familiar contra a mulher.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Pelo contrário: calúnia, difamação ou injúria contra a mulher caracterizam, sim, violência moral, nos termos do art. 7º, V.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção da Lei não é limitada a mulheres adultas — alcança a mulher em situação de violência doméstica e familiar sem essa exclusão etária, sem prejuízo da aplicação conjunta do Estatuto da Criança e do Adolescente quando a vítima for criança ou adolescente.

BIZU DE PROVA:
O art. 6º ("violação dos direitos humanos") é a resposta certa mais recorrente em questões genéricas "assinale a correta" sobre o espírito da Lei — mas sempre confira as outras alternativas, porque geralmente há uma ou duas pegadinhas clássicas (cesta básica, Lei 9.099) junto.'),
  (1335, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A destruição de instrumentos de trabalho da esposa configura violência patrimonial (art. 7º, IV). Diante disso, há hipótese legal de admissibilidade da prisão preventiva do agressor, decretada pelo juiz mediante requerimento do Ministério Público ou representação da autoridade policial (art. 20 da Lei), sempre observados os requisitos concretos do art. 312 do CPP — não se trata de decretação automática, nem de ofício (o art. 311 do CPP, após a Lei 13.964/2019, exige sempre provocação, entendimento também aplicado pelo STJ aos casos de violência doméstica), mas de uma possibilidade jurídica real diante do quadro de violência doméstica, desde que provocada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a pena de cesta básica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O âmbito familiar não afasta a Lei — pelo contrário, é um dos três âmbitos de incidência previstos no art. 5º (unidade doméstica, família e relação íntima de afeto).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A violência patrimonial está expressamente prevista no art. 7º, IV — a Lei não se limita a agressões físicas, psicológicas ou morais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 21, parágrafo único, veda que a própria ofendida entregue intimação ou notificação ao agressor — Ciclana não poderia fazer essa entrega pessoalmente.

BIZU DE PROVA:
Destruir instrumentos de trabalho é violência patrimonial clássica (art. 7º, IV). E lembre: quem decide sobre prisão preventiva é sempre o juiz, mediante provocação (Ministério Público ou representação policial) — nunca de ofício, e nunca a vítima entregando qualquer documento pessoalmente ao agressor.'),
  (1336, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, II, define violência familiar como a praticada no âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa — daí a referência a vínculo de natureza familiar ou por vontade expressa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A habitualidade não é elemento constitutivo do tipo de violência doméstica — um único episódio de violência baseada no gênero, nos termos do art. 5º, já é suficiente para a incidência da Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei Maria da Penha protege a mulher como vítima de violência de gênero; no caso descrito, quem agride é a empregada doméstica e quem sofre a agressão é o patrão (homem) — não se trata de violência doméstica contra a mulher nos termos desta Lei (o fato pode ter relevância penal por outras vias, inclusive em razão da idade do ofendido, mas não se subsome à Lei Maria da Penha).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Mera relação de vizinhança, sem vínculo doméstico, familiar ou de relação íntima de afeto entre as envolvidas, não se enquadra em nenhum dos três âmbitos do art. 5º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O vínculo familiar não é imprescindível — a Lei também abrange a unidade doméstica (art. 5º, I, que dispensa vínculo familiar) e a relação íntima de afeto (art. 5º, III), âmbitos alternativos, não cumulativos.

BIZU DE PROVA:
O art. 5º tem 3 âmbitos alternativos (unidade doméstica, família, relação íntima de afeto) — basta UM deles estar presente. E lembre: a Lei protege a mulher como vítima; se quem agride é mulher e quem sofre é homem, o caso não se subsome a esta Lei especificamente.'),
  (1338, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 41 da Lei 11.340/2006 afasta expressamente a aplicação da Lei 9.099/1995 aos crimes praticados com violência doméstica e familiar contra a mulher, independentemente da pena prevista — exatamente o oposto do que a alternativa afirma.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmação verdadeira, não a exceção pedida):
O art. 45 da Lei, ao alterar o parágrafo único do art. 152 da Lei de Execução Penal, permite ao juiz determinar o comparecimento obrigatório do agressor a programas de recuperação e reeducação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 26, III, atribui ao Ministério Público, entre outras atribuições, cadastrar os casos de violência doméstica e familiar contra a mulher.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 7º, III, qualifica como violência sexual impedir a mulher de usar qualquer método contraceptivo, mediante coação, chantagem, suborno ou manipulação.

BIZU DE PROVA:
Questões "assinale a incorreta" sobre a Lei 9.099/1995 costumam inverter a regra do art. 41 — decore: a Lei 9.099 NUNCA se aplica aos crimes com violência doméstica, qualquer que seja a pena.'),
  (1339, 'GABARITO: ERRADO

POR QUE:
O art. 7º, IV, da Lei 11.340/2006 prevê expressamente a violência patrimonial como uma das formas de violência doméstica e familiar contra a mulher (retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos). O item erra ao afirmar que dano patrimonial não pode caracterizar violência doméstica.

PEGADINHA:
A afirmação tenta restringir a violência doméstica só à lesão corporal — mas a Lei reconhece 5 modalidades (física, psicológica, sexual, patrimonial e moral), não apenas a física.

BIZU DE PROVA:
Sempre que uma questão tentar "reduzir" a violência doméstica a um único tipo de dano (só físico, só corporal), desconfie — o art. 7º é um rol de 5 modalidades, todas igualmente reconhecidas.'),
  (1341, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 15 da Lei estabelece competência à escolha da ofendida entre o domicílio/residência dela, o lugar do fato ou o domicílio do agressor — a alternativa erra ao afirmar que o foro do domicílio/residência da ofendida se aplica "independente da opção da ofendida", quando na verdade a escolha é justamente dela.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 11, II, prevê o encaminhamento da ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal como uma das providências da autoridade policial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz, com um pequeno erro de digitação ("pisicológico"), a definição do art. 5º, caput.

BIZU DE PROVA:
O foro do art. 15 é sempre uma escolha da ofendida entre 3 opções (domicílio/residência dela, lugar do fato, domicílio do agressor) — nunca uma imposição "independente da opção dela".'),
  (1342, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
Crimes cometidos a bordo de aeronaves são, por regra constitucional (art. 109, IX, da Constituição Federal), de competência da Justiça Federal, e não da Justiça Estadual — a alternativa inverte essa regra de competência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 5º, III, inclui relações entre ex-namorados independentemente de ter havido convivência (coabitação).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
A Lei não criou um rito processual próprio: aplica-se subsidiariamente o Código de Processo Penal e demais legislação de proteção (art. 13), preservadas as competências e medidas protetivas específicas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Os Juizados de Violência Doméstica e Familiar são órgãos da Justiça Ordinária estadual (regra geral); logo, o recurso de apelação segue ao Tribunal de Justiça respectivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
A Lei abrange relações homoafetivas entre mulheres, por força do art. 5º, parágrafo único.

BIZU DE PROVA:
Crime a bordo de aeronave é regra constitucional geral de competência (art. 109, IX, CF) — Justiça Federal, não Estadual. Não é um dispositivo específico da Lei Maria da Penha, mas costuma ser combinado com ela nas provas.'),
  (1343, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 5º, caput, expressamente considera violência doméstica e familiar contra a mulher a omissão baseada no gênero que lhe cause sofrimento psicológico em relação íntima de afeto — a alternativa erra ao afirmar que a Lei NÃO considera essa hipótese como violência doméstica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz a definição de violência patrimonial do art. 7º, IV.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz as medidas protetivas de urgência do art. 22 (afastamento do lar, proibição de aproximação, alimentos provisórios, entre outras).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 17 veda expressamente penas de cesta básica ou prestação pecuniária isolada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
O art. 16 exige que a renúncia à representação ocorra perante o juiz, em audiência específica, antes do recebimento da denúncia e ouvido o Ministério Público.

BIZU DE PROVA:
A Lei protege contra "ação OU omissão" que cause sofrimento físico, sexual OU psicológico — uma alternativa que tenta excluir a omissão ou o sofrimento psicológico do conceito está, quase sempre, errada.'),
  (1344, 'GABARITO: CERTO

POR QUE:
Segundo entendimento do STJ sobre prisão preventiva em contexto de violência doméstica, ameaças de morte reiteradas e concretas dirigidas à ex-companheira, aliadas à disciplina protetiva da Lei Maria da Penha (que autoriza a prisão preventiva para garantir a execução de medidas protetivas, nos termos do art. 313, III, do CPP), podem fundamentar a segregação cautelar, desde que demonstrado o risco concreto exigido pelo art. 312 do CPP (periculum libertatis) — não bastando ameaças genéricas ou abstratas, mas sim a possibilidade real de cumprimento, como descrito no item.

PEGADINHA:
O item fala em "possibilidade REAL" de cumprir as ameaças — se fosse uma ameaça vaga ou remota, sem lastro concreto, a fundamentação da prisão preventiva já não estaria automaticamente justificada; o risco precisa ser concreto, não presumido.

BIZU DE PROVA:
Ameaça de morte concreta e reiterada, em contexto de violência doméstica, é fundamento clássico de risco à integridade da vítima (periculum libertatis) para a prisão preventiva — mas sempre exige demonstração do risco real no caso concreto, nunca é automática.'),
  (1345, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 7º, V, define violência moral como qualquer conduta que configure calúnia, difamação ou injúria — reproduzido corretamente na alternativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 11, IV, inclui, entre as providências da autoridade policial, acompanhar a ofendida para assegurar a retirada de seus pertences do local — a alternativa erra ao afirmar que essa providência não está incluída.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 12, IV, determina — não torna discricionário "dependendo da gravidade" — que a autoridade policial determine a realização do exame de corpo de delito da ofendida e requisite outros exames periciais necessários.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 23, IV, permite expressamente ao juiz determinar a separação de corpos como medida de proteção à ofendida — não há vedação por se tratar de matéria de direito civil.

BIZU DE PROVA:
Calúnia, difamação, injúria = violência moral (art. 7º, V) — mesmo bizu de sempre. E lembre: o exame de corpo de delito e as demais providências do art. 12 não são discricionárias "conforme a gravidade" — são determinações a serem adotadas de imediato.'),
  (1346, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 9º, §5º, da Lei (incluído pela Lei 13.871/2019) prevê que os dispositivos de segurança destinados a situações de perigo iminente e disponibilizados para o monitoramento de vítimas amparadas por medidas protetivas de urgência terão seus custos ressarcidos pelo agressor.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O prazo de manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, é de até 6 (seis) meses (art. 9º, §2º, II) — não de um ano.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O acesso prioritário à remoção (art. 9º, §2º, I) é assegurado à mulher servidora pública, integrante da administração direta ou indireta — não a "todas as trabalhadoras", e não há exigência de comprovação de lesão corporal como condição.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 9º, §4º (incluído pela Lei 13.871/2019), obriga quem, por ação ou omissão, causar lesão, violência física, sexual ou psicológica e dano moral ou patrimonial à mulher a ressarcir ao SUS os custos dos serviços de saúde prestados, conforme a tabela SUS — sem a restrição a apenas "violência física e sexual" que a alternativa descreve.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Embora a mulher em situação de violência doméstica tenha prioridade de matrícula dos dependentes sem exigência de documentos comprobatórios, a alternativa acrescenta uma justificativa ("visando à preservação da integridade física e psicológica de seus dependentes") que não corresponde à redação da Lei para esse dispositivo — não é essa a alternativa que a banca considerou correta.

BIZU DE PROVA:
Art. 9º ampliado pela Lei 13.871/2019: §4º (agressor ressarce o SUS pelos custos do tratamento da vítima) e §5º (agressor também custeia os dispositivos de segurança de monitoramento) — soma-se a isso os clássicos §1º (cadastro assistencial por prazo certo), §2º (remoção prioritária de servidora pública + 6 meses de vínculo trabalhista) e §3º (contracepção de emergência/profilaxia DST-AIDS).'),
  (1347, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 11, V, prevê, entre as providências da autoridade policial no atendimento à mulher em situação de violência doméstica, informar à ofendida os direitos a ela conferidos e os serviços disponíveis.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 10 determina que a autoridade policial adote, de imediato, as providências cabíveis — não há previsão de aguardar manifestação do Ministério Público antes de agir.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O encaminhamento ao Instituto Médico-Legal (art. 11, II) não é condicionado à existência de lesão corporal grave.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A autoridade policial não concede medidas protetivas de urgência diretamente — essa competência é do juiz (arts. 18 e 19); a polícia encaminha o expediente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A autoridade policial age de imediato ao tomar conhecimento do fato (art. 10), sem aguardar representação formal da vítima para as primeiras providências.

BIZU DE PROVA:
"Informar a vítima sobre seus direitos e os serviços disponíveis" é uma das providências mais discretas do art. 11 — memorize o rol completo: proteção, IML, transporte, retirada de pertences, informação de direitos.'),
  (1348, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 12-C, III, autoriza o próprio policial que atendeu a ocorrência a afastar imediatamente o agressor do lar quando o Município não for sede de comarca e não houver delegado disponível no momento — exatamente a hipótese descrita (madrugada, sem delegado, sem plantão judicial instalado).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há previsão de afastamento determinado por "Chefe de Cartório" na Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A hipótese de afastamento pelo delegado (art. 12-C, II) pressupõe que exista delegado disponível, ainda que de outra comarca dentro de sua competência — o caso descrito é justamente de AUSÊNCIA de delegado disponível, o que aciona a hipótese seguinte (o policial).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não atribui essa competência de afastamento imediato ao Ministério Público por requisição à polícia nessa hipótese específica.

BIZU DE PROVA:
O art. 12-C tem 3 níveis, nessa ordem: (1) juiz, sempre; (2) delegado, quando o município não é sede de comarca; (3) o próprio policial, quando o município não é sede de comarca E não há delegado disponível no momento. Decore essa cadeia.'),
  (1349, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 22, II, combinado com o art. 12-C, autoriza o afastamento do agressor do lar quando verificado risco atual ou iminente à vida OU à integridade física OU psicológica da mulher OU de seus dependentes — reproduzido fielmente pela alternativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restringe indevidamente a hipótese só ao risco "iminente", excluindo o risco "atual", que também autoriza a medida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Restringe indevidamente a hipótese à integridade patrimonial, que não é o critério legal para essa medida específica (que trata de risco à vida e à integridade física/psicológica).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o risco psicológico e os dependentes da mulher, que também estão contemplados pela norma.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Exclui indevidamente a própria mulher, tratando a hipótese como se só protegesse os dependentes.

BIZU DE PROVA:
A hipótese de afastamento por risco é ampla: vida OU integridade física OU psicológica, da mulher OU de seus dependentes — qualquer alternativa que restrinja essa amplitude, cortando uma das opções, está errada.'),
  (1350, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 12, II, determina que, feito o registro da ocorrência, a autoridade policial colha, de imediato, todas as provas que servirem para o esclarecimento do fato e de suas circunstâncias, em todos os casos de violência doméstica e familiar contra a mulher.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10 determina que a autoridade policial adote as providências cabíveis de imediato, ao tomar conhecimento do fato — não há exigência de aguardar "confirmação" prévia da violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há previsão de prazo fixo de 24 horas para comunicar o fato ao Ministério Público e ao Poder Judiciário nessa hipótese geral (o prazo de 24 horas na Lei está associado a outra situação específica: a comunicação ao juiz do afastamento provisório do agressor decretado pelo delegado ou pelo policial, art. 12-C).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O prazo correto para a autoridade policial remeter o expediente ao juiz com o pedido de medidas protetivas é de 48 (quarenta e oito) horas (art. 12, III), não 24 horas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O afastamento do agressor pelo policial diretamente não cabe "em qualquer hipótese" — só nas condições específicas do art. 12-C (risco + Município que não é sede de comarca + delegado indisponível).

BIZU DE PROVA:
Cuidado com prazos "emprestados" de um dispositivo para outro: 48h é para remeter expediente com pedido de medida protetiva (art. 12, III); 24h é para comunicar ao juiz um afastamento provisório já decretado (art. 12-C). Não são a mesma coisa.'),
  (1351, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 9º, §3º, da Lei prevê que a assistência à mulher em situação de violência doméstica compreende, entre outras ações, o acesso aos benefícios decorrentes do desenvolvimento científico e tecnológico, incluindo a contracepção de emergência, a profilaxia das Doenças Sexualmente Transmissíveis (DST) e da AIDS, e outros procedimentos médicos necessários e cabíveis nos casos de violência sexual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O prazo de manutenção do vínculo trabalhista é de até 6 (seis) meses (art. 9º, §2º, II) — não um "prazo mínimo de doze meses".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O acesso prioritário à remoção (art. 9º, §2º, I) é garantido especificamente à mulher servidora pública, integrante da administração direta ou indireta — não a todas as trabalhadoras, públicas ou privadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 9º, §1º, determina que a inclusão no cadastro de programas assistenciais seja feita por prazo CERTO, não por prazo indeterminado.

BIZU DE PROVA:
Art. 9º tem 3 parágrafos centrais mais cobrados: §1º (cadastro assistencial, prazo certo), §2º (remoção prioritária de servidora pública + 6 meses de vínculo trabalhista), §3º (contracepção de emergência + profilaxia DST/AIDS). Decore qual conteúdo está em qual parágrafo.'),
  (1352, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 12-C estabelece a cadeia de competência para o afastamento imediato do agressor: pela autoridade judicial; pelo delegado de polícia, quando o Município não for sede de comarca; ou pelo policial, quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Substitui incorretamente o delegado de polícia pelo Promotor de Justiça na segunda hipótese, e exige "ausência de representante do Ministério Público" em vez de "ausência de delegado" na terceira — nenhuma dessas variações corresponde ao texto do art. 12-C.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Substitui a autoridade judicial pelo Promotor de Justiça na primeira hipótese, o que não corresponde ao art. 12-C (a autoridade judicial é sempre uma via possível).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Omite a hipótese do policial (quando não há delegado disponível) e substitui a autoridade judicial pelo Promotor de Justiça, incorreto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite as hipóteses do delegado e do policial, restringindo indevidamente a autoridade judicial e o Promotor de Justiça (que sequer tem essa competência no art. 12-C).

BIZU DE PROVA:
A cadeia do art. 12-C é sempre: autoridade judicial (sempre) → delegado (se não é sede de comarca) → policial (se não é sede de comarca E não há delegado disponível). O Ministério Público não decreta esse afastamento diretamente.'),
  (1353, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 12-C, II, autoriza o delegado de polícia a determinar o afastamento imediato do agressor quando o Município não for sede de comarca — hipótese corretamente descrita na alternativa, sem alegar exclusividade indevida.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente a competência "somente" à autoridade judicial, excluindo as hipóteses do delegado e do policial previstas no art. 12-C.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirma que o delegado pode determinar o afastamento "em qualquer situação", quando na verdade essa competência do delegado só existe quando o Município não é sede de comarca.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirma que o policial pode determinar o afastamento "em qualquer situação", quando na verdade essa competência só existe quando o Município não é sede de comarca E não há delegado disponível.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Usa "somente pelo policial", excluindo indevidamente as hipóteses da autoridade judicial e do delegado, que também são válidas.

BIZU DE PROVA:
Desconfie de alternativas com "somente"/"em qualquer situação" quando o tema é a cadeia de competência do art. 12-C — ela tem 3 níveis com condições específicas, nenhum deles é absoluto isoladamente.'),
  (1354, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 10 determina que, na iminência ou na prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência adote, de imediato, as providências legais cabíveis.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência estrutural" não é uma das 5 modalidades do art. 7º da Lei; a definição apresentada ("ofenda sua integridade ou saúde corporal") corresponde à violência FÍSICA (art. 7º, I).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A definição apresentada ("calúnia, difamação ou injúria") é, na verdade, a definição de violência MORAL (art. 7º, V) — não de violência psicológica e patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A política pública de combate à violência doméstica não se faz exclusivamente por ações da União — o art. 8º, caput, exige ação articulada entre União, Estados, Distrito Federal, Municípios e ações não governamentais.

BIZU DE PROVA:
Fique atento a nomes "quase certos" para as modalidades de violência ("violência estrutural", "violência simbólica", "violência emocional") — nenhum desses é um dos 5 termos técnicos do art. 7º.'),
  (1355, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 9º, §4º, da Lei (incluído pela Lei 13.871/2019) obriga quem, por ação ou omissão, causar lesão, violência física, sexual ou psicológica, ou dano moral ou patrimonial a uma mulher, a ressarcir ao Sistema Único de Saúde (SUS), conforme a tabela SUS, os custos dos serviços de saúde prestados para o tratamento da vítima.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente a obrigação de ressarcimento apenas aos danos psicológicos e ao pagamento de sessões de acompanhamento, quando a obrigação de ressarcir é mais ampla, incluindo os custos suportados pelo SUS.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Restringe indevidamente o ressarcimento a danos morais e materiais "comprovados", excluindo expressamente o ressarcimento ao SUS previsto na Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há previsão de um "benefício mensal" à vítima como consequência dessa obrigação — a Lei trata de ressarcimento dos custos efetivamente suportados, não de uma renda mensal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há previsão de contratação de serviços privados de saúde "a critério da vítima" como obrigação do agressor — o mecanismo previsto é o ressarcimento ao SUS.

BIZU DE PROVA:
Art. 9º, §4º (Lei 13.871/2019): quem pratica violência contra a mulher deve ressarcir o SUS pelos custos do tratamento da vítima, conforme a tabela SUS — tema que aparece em mais de uma questão deste sub-lote, por isso vale decorar o número do parágrafo.'),
  (1356, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 12, I, determina que, feito o registro da ocorrência, a autoridade policial deverá, de imediato, entre outras providências, ouvir a ofendida, lavrar o boletim de ocorrência e tomar a representação a termo, se apresentada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O prazo correto para remeter o expediente ao juiz com o pedido de medidas protetivas é de 48 horas (art. 12, III), não 36 horas; além disso, a autoridade policial não solicita "diretamente" a prisão preventiva ao juízo — o correto é a possibilidade de representação (art. 20), o pedido de prisão preventiva propriamente dito segue outro caminho.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O exame de corpo de delito é determinado diretamente pela autoridade policial (art. 12, IV), sem depender de autorização judicial; tampouco a oitiva do agressor depende de manifestação prévia do Ministério Público.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A oitiva de testemunhas indicadas pela ofendida (art. 12, V) não depende de "autorização" — é providência que a autoridade policial adota diretamente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há previsão, na Lei, de manter a ofendida em "ambiente isolado" por 48 horas — essa medida não existe no texto legal.

BIZU DE PROVA:
O art. 12 lista as providências imediatas da autoridade policial (ouvir a ofendida, lavrar o BO, colher provas, remeter expediente em 48h, determinar exames, ouvir agressor/testemunhas) — nenhuma delas depende de autorização prévia do juiz ou do Ministério Público.'),
  (1357, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A asserção I é falsa: a política pública de combate à violência doméstica não é responsabilidade "primordial" isolada do Estado — o art. 8º, caput, exige ação articulada entre União, Estados, Distrito Federal, Municípios e ações não governamentais, sem atribuir primazia a um único ente. A asserção II é verdadeira: o art. 8º, VII, elenca a capacitação permanente das Polícias Civil e Militar, da Guarda Municipal e do Corpo de Bombeiros quanto às questões de gênero e de raça ou etnia como diretriz da política pública.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera a asserção I verdadeira, quando ela é falsa pelo motivo acima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Também considera a I verdadeira, incorretamente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a II falsa, quando ela é verdadeira (reproduz o art. 8º, VII).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas falsas, mas a II é verdadeira.

BIZU DE PROVA:
Cuidado com "responsabilidade primordial/exclusiva de um único ente" em questões sobre a política pública do art. 8º — a Lei sempre fala em ação ARTICULADA entre todos os entes federativos e a sociedade civil, nunca em primazia isolada de um deles.'),
  (1358, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As três assertivas estão corretas. I: o art. 12-B autoriza a autoridade policial a afastar provisoriamente o agressor do lar, mesmo sem autorização judicial prévia, em casos excepcionais de risco. II: o art. 42 da Lei alterou o art. 313 do CPP para admitir a prisão preventiva quando o crime envolver violência doméstica e familiar, para garantir a execução das medidas protetivas. III: as medidas protetivas de urgência têm natureza autônoma e podem ser concedidas independentemente de inquérito, ação penal ou cível já formalizados — o que já se viu, por exemplo, na questão sobre concessão de medida protetiva sem processo criminal em andamento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera corretas apenas a I, quando as três estão corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera correta apenas a II, quando as três estão corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera correta apenas a III, quando as três estão corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera corretas a I e a II, mas exclui a III, que também está correta.

BIZU DE PROVA:
As medidas protetivas de urgência são um mecanismo autônomo e urgente — não dependem de inquérito, ação penal ou boletim de ocorrência já formalizados para serem concedidas.'),
  (1359, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 10-A, §1º, incisos I e II, estabelece como diretrizes de inquirição: a salvaguarda da integridade física, psíquica e emocional da depoente, considerada sua condição peculiar de pessoa em situação de violência doméstica e familiar; e a garantia de que, em nenhuma hipótese, a mulher, familiares e testemunhas terão contato direto com investigados ou suspeitos e pessoas a eles relacionadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura corretamente o registro em meio eletrônico (que integra as diretrizes de inquirição do §1º) com o encaminhamento ao hospital/IML, que é providência distinta do art. 11, II — não do §1º do art. 10-A.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Mistura o acompanhamento para retirada de pertences (art. 11, IV) com a inquirição intermediada por profissional especializado — cada trecho pertence a um dispositivo diferente, não ambos ao §1º do art. 10-A na forma combinada da alternativa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Reproduz o art. 10, e não o §1º do art. 10-A pedido pela questão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Reproduz o dispositivo sobre prioridade de matrícula escolar dos dependentes (art. 9º), e não as diretrizes de inquirição do art. 10-A, §1º.

BIZU DE PROVA:
Questões que citam o número exato do artigo (aqui, "art. 10-A, §1º") estão testando se você sabe QUAL conteúdo pertence a QUAL dispositivo — desconfie de alternativas que misturam conteúdo real de dois artigos diferentes como se fossem do mesmo parágrafo.'),
  (1360, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA (é a alternativa que NÃO é diretriz, pedida pelo enunciado):
"Capacitação da mulher para ingressar no mercado de trabalho" não consta do rol de diretrizes de prevenção do art. 8º da Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma diretriz real, não a exceção pedida):
A promoção e realização de campanhas educativas de prevenção é diretriz expressa do art. 8º, V.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma diretriz real, não a exceção pedida):
A capacitação permanente das Polícias Civil e Militar, da Guarda Municipal e do Corpo de Bombeiros quanto a gênero e raça/etnia é diretriz do art. 8º, VII.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma diretriz real, não a exceção pedida):
A promoção de estudos, pesquisas e estatísticas com perspectiva de gênero é diretriz do art. 8º, II.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma diretriz real, não a exceção pedida):
A integração operacional do Judiciário, Ministério Público e Defensoria Pública com as áreas de segurança pública, assistência social, saúde, educação, trabalho e habitação é diretriz do art. 8º, I.

BIZU DE PROVA:
O rol do art. 8º é sobre POLÍTICA PÚBLICA articulada entre instituições (integração, capacitação de agentes públicos, estudos, campanhas, convênios) — não sobre capacitação profissional da própria mulher, que não é uma das diretrizes listadas.'),
  (1361, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa INCORRETA como diretriz do art. 8º, pedida pelo enunciado):
O conteúdo sobre acesso a contracepção de emergência, profilaxia de DST e da AIDS pertence ao art. 9º, §3º da Lei — que trata da ASSISTÊNCIA à mulher em situação de violência doméstica — e não ao art. 8º, que trata das diretrizes da política pública de PREVENÇÃO. A alternativa erra ao apresentar conteúdo de um dispositivo (art. 9º) como se fosse diretriz de outro (art. 8º).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é diretriz real do art. 8º, não a exceção pedida):
A promoção de estudos, pesquisas e estatísticas com perspectiva de gênero e de raça/etnia é diretriz do art. 8º, II.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é diretriz real do art. 8º, não a exceção pedida):
A celebração de convênios, protocolos e ajustes entre órgãos governamentais e entidades não governamentais é diretriz do art. 8º, VI.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é diretriz real do art. 8º, não a exceção pedida):
A promoção de programas educacionais que disseminem valores éticos de respeito à dignidade humana, com perspectiva de gênero e de raça/etnia, é diretriz do art. 8º, VIII.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é diretriz real do art. 8º, não a exceção pedida):
A promoção de campanhas educativas de prevenção, voltadas ao público escolar e à sociedade, é diretriz do art. 8º, V.

BIZU DE PROVA:
Não confunda art. 8º (diretrizes de PREVENÇÃO, dirigidas a instituições) com art. 9º (ASSISTÊNCIA concreta à mulher vítima, incluindo saúde reprodutiva). Contracepção de emergência e profilaxia de DST/AIDS são sempre art. 9º, §3º — nunca art. 8º.'),
  (1362, 'GABARITO: CERTO

POR QUE:
O art. 12, V, determina que a autoridade policial, feito o registro da ocorrência, ouça o agressor e as testemunhas em todos os casos de violência doméstica e familiar contra a mulher, como uma das providências a serem adotadas de imediato.

PEGADINHA:
Se o item restringisse essa oitiva a "alguns casos" ou a condicionasse a critérios de gravidade, estaria errado — a Lei determina a providência para TODOS os casos.

BIZU DE PROVA:
O rol do art. 12 (ouvir a ofendida, colher provas, remeter expediente, determinar exames, ouvir agressor e testemunhas, identificar o agressor) vale para TODOS os casos, sem exceção por gravidade.'),
  (1363, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO, ao tomar conhecimento da iminência ou prática de violência doméstica — não existe, para essa hipótese, um prazo de "até 48 horas" como a alternativa inventa (o prazo de 48 horas da Lei está associado a outra situação: a remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira quanto à literalidade do art. 20, não a exceção pedida):
Reproduz o texto literal do art. 20 da Lei sobre prisão preventiva do agressor, inclusive a menção a decretação "de ofício". Ressalva importante para a prática: o art. 311 do CPP, após a Lei 13.964/2019 (Pacote Anticrime), passou a exigir sempre provocação para a prisão preventiva, e o STJ já decidiu que o juiz não pode decretá-la de ofício, nem mesmo em contexto de violência doméstica — a redação do art. 20 não foi atualizada, mas essa parte específica está superada na prática pela jurisprudência. Para fins desta questão, que cobra a literalidade do dispositivo, a alternativa foi corretamente tratada como verdadeira pela banca.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 4º sobre interpretação da Lei considerando os fins sociais e a condição peculiar da mulher em situação de violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 9º, §1º, sobre inclusão em cadastro de programas assistenciais por prazo certo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 6º sobre violação dos direitos humanos.

BIZU DE PROVA:
"De imediato" (art. 10) é diferente de "em até 48 horas" (art. 12, III) — são dispositivos e momentos distintos. Bancas gostam de emprestar o prazo de um para inventar prazo em outro.'),
  (1364, 'GABARITO: ERRADO

POR QUE:
Ouvir o agressor e as testemunhas (art. 12, V) não é uma faculdade discricionária da autoridade policial ("deliberação sobre a necessidade") — é providência a ser adotada de imediato, em todos os casos, feito o registro da ocorrência.

PEGADINHA:
O item tenta transformar uma providência obrigatória em uma escolha discricionária da autoridade policial — a Lei não dá esse espaço de decisão sobre "se é necessário" ouvir agressor e testemunhas.

BIZU DE PROVA:
As providências do art. 12 (incluindo ouvir agressor e testemunhas) não são "a critério" da autoridade policial — são determinações da Lei, a serem cumpridas de imediato.'),
  (1365, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 12, III, determina que a autoridade policial remeta, no prazo de 48 (quarenta e oito) horas, expediente apartado ao juiz com o pedido da ofendida, para a concessão de medidas protetivas de urgência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
12 horas não é o prazo previsto no art. 12, III.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
24 horas não é o prazo previsto no art. 12, III — esse prazo (24h) está associado a outra situação (comunicação ao juiz do afastamento provisório do agressor pelo delegado ou policial, art. 12-C).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
36 horas não é o prazo previsto no art. 12, III.

BIZU DE PROVA:
48 horas é o prazo do art. 12, III (remessa de expediente ao juiz com pedido de medida protetiva) — o número mais cobrado desse artigo.'),
  (1366, 'GABARITO: ERRADO

POR QUE:
O art. 8º, I, elenca, entre as diretrizes da política pública de combate à violência doméstica, a integração operacional do Poder Judiciário, do Ministério Público e da Defensoria Pública com as áreas de segurança pública, assistência social, saúde, educação, trabalho E HABITAÇÃO — o item substitui "habitação" por "transporte", que não consta do dispositivo.

PEGADINHA:
A troca de uma única área ("habitação" por "transporte") é sutil — sempre confira a lista completa do art. 8º, I, palavra por palavra, quando a questão testar esse dispositivo.

BIZU DE PROVA:
As áreas do art. 8º, I são: segurança pública, assistência social, saúde, educação, trabalho e habitação. "Transporte" não está nessa lista.'),
  (1367, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 12-C, III, autoriza o afastamento imediato do agressor pelo próprio policial quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia, diante de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher ou de seus dependentes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Quando há risco à integridade da ofendida ou à efetividade da medida protetiva de urgência, a lógica da Lei é de reforço da restrição de liberdade do agressor (inclusive por prisão preventiva), não de concessão de liberdade provisória.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Laudos e prontuários médicos são admitidos como meio de prova — não há vedação dessa natureza na Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O prazo para a autoridade policial remeter o expediente com pedido de medidas protetivas é de 48 horas (art. 12, III), não 24 horas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 17 veda a aplicação de penas de cesta básica ou de prestação pecuniária, mesmo em casos considerados "leves".

BIZU DE PROVA:
A cadeia de competência do art. 12-C (juiz → delegado quando não sede de comarca → policial quando não sede de comarca e sem delegado disponível) é o dispositivo mais recorrente nas provas mais recentes deste sub-lote — decore essa ordem.'),
  (1368, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 9º, §4º, da Lei (incluído pela Lei 13.871/2019) obriga quem, por ação ou omissão, causar lesão à mulher a ressarcir ao SUS, conforme a tabela SUS, os custos relativos aos serviços de saúde prestados para o tratamento da vítima, recolhidos os recursos ao Fundo de Saúde do ente federado responsável pela unidade que prestou o atendimento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O atendimento por servidoras do sexo feminino é PREFERENCIAL (art. 10-A, caput), não obrigatório — a alternativa erra ao transformar preferência em obrigatoriedade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O prazo para remeter o expediente com o pedido de medidas protetivas é de 48 horas (art. 12, III), não 24 horas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O enunciado não indica que o Município não seja sede de comarca nem que não haja delegado disponível — condições exigidas pelo art. 12-C para o afastamento ser determinado diretamente pelo policial; além disso, a existência de plantão judicial (e não o "horário" do juiz titular) é o que trata das situações fora do expediente comum.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O prazo de manutenção do vínculo trabalhista é de até 6 meses (art. 9º, §2º, II), não um ano.

BIZU DE PROVA:
"Preferencialmente do sexo feminino" (art. 10-A, caput) nunca é "obrigatoriamente" — essa troca é uma das pegadinhas mais recorrentes sobre a Lei. E o ressarcimento ao SUS é art. 9º, §4º (Lei 13.871/2019).'),
  (1369, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é V-F-F-V. Item 1 (verdadeiro): a integração entre Judiciário, Ministério Público, Defensoria Pública e as áreas de segurança pública, saúde e educação é diretriz expressa do art. 8º, I. Item 2 (falso): a Lei não prevê mecanismos de mediação entre vítima e agressor para pacificação familiar — pelo contrário, o art. 41 afasta a Lei 9.099/1995 exatamente para não permitir esse tipo de conciliação, mesmo nos casos de reincidência. Item 3 (falso): a articulação entre entes federativos não é opcional — é diretriz obrigatória da política pública (art. 8º, caput). Item 4 (verdadeiro): a capacitação permanente de profissionais das áreas de segurança, saúde, educação e assistência social integra as diretrizes de prevenção da Lei (art. 8º, VII, quanto às forças de segurança, e o espírito geral do art. 8º quanto às demais áreas mencionadas).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência V-F-F-F está incorreta, pois o item 4 é verdadeiro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência V-V-V-V está incorreta, pois os itens 2 e 3 são falsos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência F-F-V-V está incorreta, pois o item 1 é verdadeiro e o item 3 é falso.

BIZU DE PROVA:
A Lei Maria da Penha NUNCA prevê mediação/conciliação entre vítima e agressor — isso contraria toda a lógica protetiva da Lei, inclusive o afastamento da Lei 9.099/1995 pelo art. 41.'),
  (1370, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 9º, §2º, II, assegura à mulher em situação de violência doméstica a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até 6 (seis) meses.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda a aplicação de penas de cesta básica — a alternativa erra já na primeira parte, ao afirmar que essa pena é permitida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há previsão de sigilo do nome da ofendida e do ofensor nos processos dessa natureza.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A comunicação à ofendida sobre os atos processuais relativos ao agressor não é feita exclusivamente por advogado ou defensor público — a notificação é dirigida à própria ofendida, sem prejuízo da intimação (cumulativa, não exclusiva) do seu advogado constituído ou defensor público (art. 21).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O atendimento policial e pericial especializado deve ser prestado, preferencialmente — não exclusivamente — por servidores do sexo feminino (art. 10-A, caput).

BIZU DE PROVA:
6 meses de vínculo trabalhista (art. 9º, §2º, II) e "preferencialmente" (nunca "exclusivamente") do sexo feminino (art. 10-A, caput) são dois dos pontos mais recorrentes de todo este sub-lote.');

-- ----------------------------------------------------------------------------
-- Revalidação de premissas dentro da própria transação, antes de qualquer
-- escrita (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_fora_do_assunto int;
  v_ja_tem_explicacao int;
  v_inativa int;
  v_gabarito_ambiguo int;
begin
  select count(*) into v_total from _staging_explicacoes;
  if v_total <> 38 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 38 questoes (tem %)', v_total;
  end if;

  select count(*) into v_fora_do_assunto
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.assunto_id <> 19;
  if v_fora_do_assunto > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging nao pertencem ao assunto Lei Maria da Penha (assunto_id=19)', v_fora_do_assunto;
  end if;

  select count(*) into v_ja_tem_explicacao
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is not null;
  if v_ja_tem_explicacao > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging ja tem explicacao preenchida (estado mudou desde a auditoria)', v_ja_tem_explicacao;
  end if;

  select count(*) into v_inativa
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where not q.ativa;
  if v_inativa > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging estao inativas', v_inativa;
  end if;

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

-- ----------------------------------------------------------------------------
-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).
-- ----------------------------------------------------------------------------
update public.questoes q
set explicacao = s.explicacao_nova
from _staging_explicacoes s
where q.id = s.questao_id;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_sublote2_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_sublote2_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_sublote2_asserts (descricao, ok) values (p_descricao, p_ok);
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
begin
  select * into v_antes from _snapshot_antes_agregado;

  select count(*) into v_total_questoes from public.questoes;
  select count(*) into v_total_alternativas from public.alternativas;
  select count(*) into v_total_vinculos_unidade from public.questao_unidades_pedagogicas;
  select count(*) into v_total_curso_questoes from public.curso_questoes;
  select count(*) into v_total_com_explicacao from public.questoes where explicacao is not null;

  call teste_sublote2_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_antes.total_questoes);
  call teste_sublote2_assert('nenhuma alternativa criada/removida/alterada em quantidade (total_alternativas inalterado)', v_total_alternativas = v_antes.total_alternativas);
  call teste_sublote2_assert('nenhum vinculo de unidade pedagogica criado/removido', v_total_vinculos_unidade = v_antes.total_vinculos_unidade);
  call teste_sublote2_assert('nenhum vinculo de curso_questoes criado/removido', v_total_curso_questoes = v_antes.total_curso_questoes);
  call teste_sublote2_assert('explicacao passou a existir em exatamente +38 questoes', v_total_com_explicacao = v_antes.total_com_explicacao + 38);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call teste_sublote2_assert('enunciado/fonte/banca/concurso/materia/assunto/ativa idênticos em todas as 38 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _snapshot_antes_questoes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call teste_sublote2_assert('alternativas (texto/correta/ordem) idênticas em todas as 38 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call teste_sublote2_assert('vinculos de unidade pedagogica idênticos em todas as 38 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call teste_sublote2_assert('vinculos de curso_questoes idênticos em todas as 38 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_sem_explicacao_pos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call teste_sublote2_assert('nenhuma das 38 ficou com explicacao vazia', v_sem_explicacao_pos = 0);

  select count(*) into v_generica_ou_vazia
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso';
  call teste_sublote2_assert('nenhuma das 38 contém apenas boilerplate de gabarito/fonte', v_generica_ou_vazia = 0);

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
  call teste_sublote2_assert('todas as 38 reclassificam como EXPLICACAO_COMPLETA pela mesma regra da auditoria', v_incompletas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_sublote2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
