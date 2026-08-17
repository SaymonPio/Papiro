-- ============================================================================
-- SUB-LOTE 1 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (40 QUESTÕES)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado por scripts/gerar-harness-sublote1-explicacoes.mjs a partir de
-- scripts/sublote1-lei-maria-penha-explicacoes.mjs (fonte da verdade dos
-- textos).
--
-- Questões: 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1330
-- (as primeiras 40 das 85 SEM_EXPLICACAO do Lote 1 de importação, todas
-- assunto_id=19 / Lei Maria da Penha, ordenadas por id).
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam.
--
-- Nenhuma questão PROBLEMATICA (gabarito ambíguo) foi tocada — confirmado
-- na auditoria: nenhuma das 40 tem 0 ou mais de 1 alternativa correta.
--
-- As 40 explicações passaram por revisão jurídica dedicada nesta sessão
-- (3 pontos corrigidos por auditoria do usuário, mais 7 encontrados em
-- revisão sistemática, mais 2 correções finais de fonte oficial — ver
-- scripts/sublote1-lei-maria-penha-explicacoes.mjs para o texto final) e
-- por scripts/validar-sublote1-explicacoes.mjs (40/40 aprovadas: gabarito
-- de cada texto bate com a alternativa correta=true no banco, todas as
-- alternativas de cada questão comentadas individualmente, estrutura
-- obrigatória completa).
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
where q.id in (1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1330);

create temporary table _snapshot_antes_agregado on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_unidade,
  (select count(*) from public.curso_questoes) as total_curso_questoes,
  (select count(*) from public.questoes where explicacao is not null) as total_com_explicacao;

-- ----------------------------------------------------------------------------
-- Staging + precondições + escrita de teste (desfeita pelo ROLLBACK final).
-- ----------------------------------------------------------------------------
create temporary table _staging_explicacoes (
  questao_id bigint primary key,
  explicacao_nova text
) on commit drop;

insert into _staging_explicacoes (questao_id, explicacao_nova) values
  (1291, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As medidas protetivas de urgência (arts. 18 a 24 da Lei 11.340/2006) são providências autônomas e urgentes, concedidas pelo juiz para proteger a integridade da mulher em situação de risco. Elas não dependem da existência de um processo criminal já instaurado contra o agressor — podem ser requeridas e deferidas de forma independente, inclusive antes do oferecimento de qualquer denúncia, justamente porque seu objetivo é afastar o risco imediato, e não punir.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 19, §1º, da Lei permite que as medidas protetivas sejam concedidas de imediato, independentemente de audiência das partes e de manifestação do Ministério Público. Não há exigência de oitiva prévia do agressor — pelo contrário, essa exigência inverteria a lógica de urgência e proteção da vítima.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A punição do agressor não depende de a vítima "solicitar expressamente" a punição. Diversos crimes praticados com violência doméstica são de ação penal pública incondicionada (a exemplo da lesão corporal, conforme a Súmula 542 do STJ), processando-se independentemente da vontade da vítima quanto à punição.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, III, da Lei estende a proteção a "qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação" — não há exigência de casamento ou união estável formal.

BIZU DE PROVA:
A Lei Maria da Penha não exige processo criminal em andamento, nem vínculo formal (casamento/união estável), nem coabitação para conceder medidas protetivas — o critério é a relação de afeto (mesmo passada) e o risco à mulher.'),
  (1292, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O envio reiterado de mensagens com xingamentos, humilhações e ameaças veladas, somado à vigilância nas redes sociais e ao comparecimento repetido no trabalho da vítima, configura violência psicológica (art. 7º, II, da Lei 11.340/2006 — conduta que causa dano emocional, mediante ameaça, humilhação, manipulação e vigilância constante). Essa perseguição reiterada também se amolda ao crime de perseguição (stalking) do art. 147-B do Código Penal, cuja pena é aumentada de metade quando cometido contra mulher por razões da condição de sexo feminino (art. 147-B, §1º, II, CP).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 41 da Lei 11.340/2006 afasta expressamente a aplicação da Lei 9.099/95 (Juizados Especiais Criminais) aos crimes praticados com violência doméstica contra a mulher, qualquer que seja a pena cominada. Não existe, portanto, exigência de tentativa de conciliação prévia — essa é justamente a lógica que a Lei Maria da Penha veio romper.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A violência psicológica não exige contato presencial. O próprio rol do art. 7º, II, é amplo ("ou qualquer outro meio"), e a jurisprudência reconhece a caracterização por meios virtuais, como mensagens e redes sociais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para a caracterização de violência doméstica em relação íntima de afeto — o vínculo de ex-companheiros já basta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A conduta não se limita a uma contravenção penal de perturbação do sossego, nem exige convivência atual: trata-se de violência doméstica psicológica plenamente tipificada pela Lei 11.340/2006, ainda que o relacionamento tenha terminado.

BIZU DE PROVA:
Violência psicológica pode ocorrer por qualquer meio, inclusive virtual, sem exigir coabitação nem convivência atual — perseguição reiterada por redes sociais e no local de trabalho pode configurar o crime do art. 147-B do CP, com pena aumentada quando praticado por razões de gênero.'),
  (1293, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O texto reproduz, com fidelidade, a redação do art. 7º, II, da Lei 11.340/2006, que define violência psicológica como qualquer conduta que cause dano emocional e diminuição da autoestima, ou que prejudique o pleno desenvolvimento, ou que vise degradar ou controlar as ações da mulher, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Essa é a definição de violência FÍSICA (art. 7º, I) — conduta que ofende a integridade ou saúde corporal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Essa é a definição de violência PATRIMONIAL (art. 7º, IV) — retenção, subtração ou destruição de bens, documentos e instrumentos de trabalho.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Essa é a definição de violência MORAL (art. 7º, V) — calúnia, difamação ou injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Essa é a definição de violência SEXUAL (art. 7º, III) — constranger a presenciar, manter ou participar de relação sexual não desejada, entre outras condutas ligadas à liberdade sexual e reprodutiva.

BIZU DE PROVA:
O art. 7º lista 5 formas de violência — decore o núcleo de cada uma: física = integridade/saúde corporal; psicológica = dano emocional/controle; sexual = constrangimento sexual/reprodutivo; patrimonial = bens/dinheiro; moral = calúnia/difamação/injúria. Bancas adoram trocar os rótulos entre si.'),
  (1294, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Os arts. 1º e 14 da Lei 11.340/2006 preveem expressamente a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher, órgãos da Justiça Ordinária com competência cível e criminal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha protege especificamente a mulher (art. 5º) em situação de violência doméstica e familiar. Não é uma lei de proteção genérica que abranja igualmente o homem.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O agressor pode ser qualquer pessoa que tenha vínculo doméstico, familiar ou de relação íntima de afeto com a vítima — não apenas homens. A Lei já foi aplicada, por exemplo, a agressões entre mulheres em relação homoafetiva ou entre mãe e filho.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Calúnia, difamação e injúria configuram violência MORAL (art. 7º, V), não psicológica (art. 7º, II) — são categorias distintas dentro do rol legal.

BIZU DE PROVA:
O sujeito ativo da violência doméstica pode ser qualquer pessoa (homem ou mulher) com vínculo doméstico, familiar ou afetivo com a vítima — o que a Lei exige é que a vítima seja mulher.'),
  (1295, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A afirmativa I está correta: os Juizados de Violência Doméstica e Familiar (arts. 14 e 29) têm competência para processar e julgar os casos, contando com equipe de atendimento multidisciplinar. A afirmativa II também está correta: as medidas protetivas de urgência do art. 22 incluem exatamente o afastamento do agressor do lar, a suspensão/restrição de porte de armas e a prestação de alimentos provisórios. A afirmativa III está incorreta, pois exige coabitação, requisito expressamente dispensado pelo art. 5º, III.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui a afirmativa III, que é falsa (exige coabitação indevidamente).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a afirmativa III, que é falsa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a afirmativa III, que é falsa, e exclui a I, que é verdadeira.

BIZU DE PROVA:
Cuidado com afirmativas que colam um requisito de "coabitação obrigatória" — é pegadinha clássica; a Lei Maria da Penha dispensa coabitação (art. 5º, III) para relação íntima de afeto.'),
  (1296, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A afirmativa I está correta: o juiz pode aplicar de imediato a suspensão da posse ou restrição do porte de armas (art. 22, I) independentemente da profissão do agressor, inclusive se for policial militar. A afirmativa III está correta: o art. 14-A prevê a competência cível do Juizado de Violência Doméstica para ações relacionadas à situação de violência, inclusive divórcio e dissolução de união estável.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui as afirmativas II e IV, ambas falsas: a Lei se aplica sim a relacionamentos de namoro já terminados (art. 5º, III) e a violência patrimonial é expressamente prevista (art. 7º, IV).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As afirmativas II e IV são falsas, não verdadeiras: a Lei se aplica ao caso do ex-namorado, e a violência patrimonial (esbulho) é amparada pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A afirmativa III é verdadeira, mas a IV é falsa — a violência patrimonial está sim prevista no art. 7º, IV.

BIZU DE PROVA:
Relação de namoro (mesmo terminada) e mera convivência íntima de afeto atraem a Lei Maria da Penha, mesmo sem coabitação; violência patrimonial (esbulho, subtração de bens) também está expressamente prevista — não pense que só existe violência física.'),
  (1297, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A afirmativa I está correta, combinando o art. 6º (a violência doméstica constitui uma das formas de violação dos direitos humanos) com o art. 8º, caput (política pública por ação articulada de União, Estados, DF, Municípios e ações não governamentais). A afirmativa II está incompleta e, por isso, falsa: a definição legal do art. 5º, caput, exige "morte, lesão, sofrimento físico, sexual OU PSICOLÓGICO E DANO MORAL OU PATRIMONIAL" — a afirmativa omitiu o sofrimento psicológico e o dano moral/patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirma que ambas são verdadeiras, mas a II está incompleta e, portanto, falsa para fins de prova.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverte a avaliação: é a I que é verdadeira, e a II que é falsa, não o contrário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A afirmativa I é verdadeira, não falsa.

BIZU DE PROVA:
Decore a definição completa do art. 5º, caput — "morte, lesão, sofrimento físico, sexual OU PSICOLÓGICO e dano moral OU PATRIMONIAL" — bancas adoram cortar um desses elementos para testar se você decorou tudo.'),
  (1298, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 5º, III, da Lei estende a proteção a qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — um namoro de dois anos se enquadra plenamente nesse conceito, ainda que não tenha havido coabitação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Embora a Lei se aplique ao caso, a alternativa erra ao afirmar que "a ação penal pública é condicionada à representação" para o conjunto dos dois crimes narrados. Isso é impreciso ao menos quanto à lesão corporal: pela Súmula 542 do STJ, a ação penal pelo crime de lesão corporal decorrente de violência doméstica é pública INCONDICIONADA, não dependendo de representação da vítima (diferente da ameaça do art. 147 do CP, que, isoladamente, segue exigindo representação).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A premissa está errada — há sim violência física concreta no caso (o tapa no rosto), o que já afasta a alegação de que "inexiste violência física concreta".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, III, fala em relação na qual o agressor "conviva OU TENHA CONVIVIDO" com a ofendida — abrange relacionamentos já encerrados, não exigindo que o casal ainda esteja junto ou more no mesmo ambiente.

BIZU DE PROVA:
A expressão "tenha convivido" no art. 5º, III, cobre relacionamentos já terminados — não é preciso estar namorando ou coabitando no momento do fato.'),
  (1299, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa reproduz literalmente a definição do art. 5º, caput, da Lei 11.340/2006: "qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É uma paráfrase incompleta que restringe indevidamente o local ("dentro, ou fora do domicílio") e o resultado ("sofrimento, aflição psicológica e emocional"), deixando de fora lesão física, sexual, morte e dano patrimonial/moral, que também integram a definição legal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restringe indevidamente a violência à "esposa e filhos" e ao resultado "lesão física ou dano psicológico", quando a Lei protege qualquer mulher em relação doméstica, familiar ou afetiva, e prevê também dano sexual, moral e patrimonial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Restringe a violência à "unidade familiar" (quando a Lei também abrange a unidade doméstica e a relação íntima de afeto) e ao resultado "sofrimento físico e/ou emocional", omitindo sexual, moral e patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Restringe indevidamente o sujeito passivo a "a esposa" e o resultado a "dor física, emocional e dano moral", deixando de fora o dano patrimonial e o sofrimento sexual.

BIZU DE PROVA:
A definição do art. 5º, caput, é a mais cobrada de toda a Lei — decore-a palavra por palavra: ação OU omissão; baseada no gênero; morte, lesão, sofrimento físico, sexual OU psicológico; dano moral OU patrimonial.'),
  (1300, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 dispõe expressamente que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O dever da autoridade policial não se restringe a ouvir a vítima e lavrar boletim de ocorrência. Os arts. 11 e 12 preveem um rol muito mais amplo de providências: garantir proteção policial, encaminhar ao IML, fornecer transporte, colher provas, requisitar exames periciais, ouvir agressor e testemunhas, entre outras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A atribuição da autoridade policial (ou guarda municipal, quando aplicável) não se limita a fornecer transporte — esse é apenas um dos itens do rol amplo do art. 11.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não se restringe à proteção contra violência sexual — o art. 7º prevê 5 modalidades de violência doméstica (física, psicológica, sexual, patrimonial e moral).

BIZU DE PROVA:
Cuidado com alternativas que usam "somente"/"exclusivamente"/"apenas" para descrever as atribuições da autoridade policial — a Lei sempre prevê um rol amplo e não taxativo ("entre outras providências").'),
  (1301, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 9º, §2º, II, assegura à mulher em situação de violência doméstica a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até 6 (seis) meses.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A conduta descrita ("qualquer conduta que configure calúnia, difamação ou injúria") é a definição legal de violência MORAL (art. 7º, V), não de violência psicológica (art. 7º, II) — a alternativa trocou o rótulo da modalidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 9º, §1º, determina que a inclusão em programa assistencial seja feita "por tempo certo", e não por prazo incerto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As diretrizes de inquirição do art. 10-A vão no sentido exatamente oposto: garantir que a mulher, familiares e testemunhas NÃO tenham contato direto com investigados ou suspeitos, nunca autorizar esse contato.

BIZU DE PROVA:
Decore o prazo de 6 meses para manutenção do vínculo trabalhista (art. 9º, §2º, II) — é um dos números mais cobrados da Lei, junto com os prazos de 48h para o juiz decidir sobre medida protetiva e 24h nas hipóteses de afastamento provisório do agressor.'),
  (1302, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A agressão de João contra a mãe, Maria, configura violência doméstica em contexto familiar (art. 5º, II — comunidade formada por indivíduos aparentados por laços naturais). A Lei Maria da Penha se aplica sempre que a vítima é mulher e há relação doméstica, familiar ou afetiva com o agressor, independentemente de quem seja este.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A relação de mãe e filho se enquadra expressamente no "âmbito da família" do art. 5º, II — há sim violência doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
João já é maior de idade (18 anos), de forma que o Estatuto da Criança e do Adolescente não se aplica a ele como autor do fato; e ainda que fosse adolescente, isso não afastaria a proteção da mãe pela Lei Maria da Penha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não exige vulnerabilidade econômica ou social da vítima — o art. 2º garante proteção a toda mulher, independentemente de classe, raça, renda, cultura ou nível educacional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não existe essa exceção por "hierarquia" na relação — o vínculo de parentesco (mãe e filho) já basta para a incidência da Lei, independentemente de quem detenha mais autoridade prática na relação.

BIZU DE PROVA:
A Lei Maria da Penha protege a mulher em qualquer relação familiar de parentesco (mãe, filha, irmã, sogra, nora etc.), não apenas entre cônjuges ou companheiros — a vítima pode ser agredida por filho, pai, irmão etc.'),
  (1303, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A alternativa sintetiza corretamente as 5 formas de violência criminalizadas pelo art. 7º (física, psicológica, sexual, patrimonial e moral) somadas às medidas de prevenção (art. 8º) e assistência às vítimas (arts. 9º e seguintes) previstas na Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não existe obrigatoriedade de comparecimento a audiência de conciliação. Pelo contrário: o art. 41 afasta a aplicação da Lei 9.099/95 (onde existiriam institutos conciliatórios) justamente para não banalizar a violência doméstica como conflito de menor potencial ofensivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há previsão de suspensão automática de procurações conferidas PELO agressor À ofendida. O que a Lei prevê (art. 24, III), como medida de proteção patrimonial, é o inverso: a suspensão de procurações conferidas PELA ofendida AO agressor.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou de outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa — não há incentivo a penas alternativas para reincidentes.

BIZU DE PROVA:
Cuidado com a troca de sujeito na procuração — "procuração da ofendida ao agressor" é suspensa por lei; "procuração do agressor à ofendida" não tem previsão nenhuma. Leia com atenção quem é o outorgante.'),
  (1304, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa reproduz a definição do art. 5º, caput: configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A medida de afastamento do lar (art. 22, II) não exige risco de vida iminente como único requisito — cabe em qualquer situação de violência doméstica constatada, a critério do juiz.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há essa restrição — qualquer pessoa pode comunicar/noticiar a situação de violência às autoridades, não apenas a própria vítima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não existe regra de pena fixa em regime fechado independentemente da gravidade — a pena depende do crime praticado, conforme o Código Penal, e das circunstâncias do caso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei se aplica também a casais homoafetivos — o parágrafo único do art. 5º dispensa orientação sexual como requisito.

BIZU DE PROVA:
Parágrafo único do art. 5º — "as relações pessoais enunciadas neste artigo independem de orientação sexual" — cobre casais homoafetivos; é pegadinha recorrente dizer que a Lei só vale para heterossexuais.'),
  (1305, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é F-F-F-V-F. Item 1 (falso): o art. 5º, III, dispensa expressamente a coabitação para relação íntima de afeto. Item 2 (falso): o prazo de manutenção do vínculo trabalhista é de até 6 meses (art. 9º, §2º, II), não 9 meses. Item 3 (falso): a Lei não proíbe a realização de atos processuais em horário noturno. Item 4 (verdadeiro): o art. 22, V, permite ao juiz determinar de imediato a prestação de alimentos provisionais como medida protetiva de urgência. Item 5 (falso): há hipótese legal de admissibilidade da prisão preventiva no art. 313, III, do CPP, para garantir a execução das medidas protetivas, observados os requisitos concretos do art. 312 do CPP (indícios de autoria e risco concreto decorrente da liberdade do agressor) — o item erra ao afirmar que ela "não caberá", uma impossibilidade absoluta que a lei não estabelece. Não se trata de decretação automática: depende de decisão fundamentada do juiz (art. 20 da Lei), sempre lastreada nos requisitos concretos do art. 312.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência V-F-V-F-V não corresponde à avaliação correta dos 5 itens.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência V-V-V-F-V está invertida em relação ao gabarito correto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência V-F-F-F-V não corresponde à avaliação correta, especialmente por marcar o item 1 como verdadeiro e o item 4 como falso.

BIZU DE PROVA:
Decore os números certos: afastamento do trabalho é até 6 meses (não 9); prazo do juiz para decidir sobre medida protetiva é 48h; e há hipótese legal de admissibilidade da prisão preventiva no art. 313, III, do CPP, para garantir a execução das medidas protetivas, independentemente da pena máxima do crime — sempre observados os requisitos concretos do art. 312 do CPP, nunca de forma automática.'),
  (1306, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A destruição parcial ou total de instrumentos de trabalho da mulher configura violência patrimonial, nos termos do art. 7º, IV, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A coabitação não é requisito para a caracterização da violência doméstica em relação íntima de afeto (art. 5º, III).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O chamado "débito conjugal" do direito civil não legitima o constrangimento à relação sexual não desejada — essa conduta configura violência sexual (art. 7º, III), independentemente do estado civil do casal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Impedir o uso de método contraceptivo, ainda que sob justificativa religiosa do companheiro, configura violência sexual (art. 7º, III, que trata expressamente da conduta de impedir o uso de qualquer método contraceptivo) — a mulher pode sim alegar violência doméstica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A injúria estar tipificada no Código Penal não impede que a mesma conduta seja também classificada como violência moral pela Lei Maria da Penha para fins de medidas protetivas — a Lei não cria um novo tipo penal de injúria, apenas qualifica a violência doméstica, sem duplicidade de punição.

BIZU DE PROVA:
Impedir o uso de método contraceptivo e negar autonomia reprodutiva, por qualquer motivo, é expressamente violência sexual pela Lei (art. 7º, III) — não existe "exceção religiosa".'),
  (1307, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As situações de nervosismo e mal-estar recorrentes causados pelo ciúme e pelas discussões do genro configuram violência psicológica, definida no art. 7º, II, como qualquer conduta que cause dano emocional e diminuição da autoestima ou que prejudique a saúde psicológica da vítima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Quem concede medida protetiva de urgência é o juiz (arts. 18 e 19), não a autoridade policial. A autoridade policial encaminha o expediente ao juiz em até 48 horas (art. 12, III) e, quando necessário, requisita diretamente o exame de corpo de delito (art. 12, IV) — não é o juiz quem solicita esse exame à polícia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A informação sobre a posse de arma pelo agressor deve constar do expediente policial (art. 12, §1º) — não há nenhum impedimento a esse registro; muito pelo contrário, é dado relevante para a análise do risco.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A prisão preventiva pode ser decretada em qualquer fase do inquérito policial ou da instrução criminal (art. 20), não apenas ao final do inquérito, e pode ser revista a qualquer tempo — não tem caráter irrevogável.

BIZU DE PROVA:
Quem concede medida protetiva de urgência é sempre o juiz — a autoridade policial instrui, requisita exames e encaminha o expediente, mas não decide em definitivo.'),
  (1308, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As afirmativas I e III estão corretas. I reproduz a definição do art. 5º, caput. III reproduz o art. 8º, caput, sobre a política pública articulada entre União, Estados, Distrito Federal e Municípios.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui a afirmativa II, que é falsa: a violência doméstica não se restringe à ação praticada pelo marido — o agressor pode ser qualquer pessoa com vínculo doméstico, familiar ou afetivo, e a Lei abrange três âmbitos distintos (unidade doméstica, família e relação íntima de afeto).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui as afirmativas II e IV, ambas falsas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a afirmativa II, que é falsa, e exclui a I, que é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a afirmativa IV, que é falsa: quem decreta medidas protetivas como suspensão de posse de armas e afastamento do lar é o juiz (art. 22), e o afastamento do lar é medida expressamente prevista, não vedada.

BIZU DE PROVA:
O agressor nunca precisa ser "o marido" — pode ser qualquer pessoa com vínculo doméstico, familiar ou afetivo com a vítima mulher.'),
  (1309, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 9º, §2º, II, assegura à mulher em situação de violência doméstica a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até 6 (seis) meses.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O prazo de 3 meses não corresponde ao previsto em lei, que é de até 6 meses.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O prazo de 1 ano não corresponde ao previsto em lei, que é de até 6 meses.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há previsão de faixa "de 6 meses a 1 ano" — o prazo legal é um limite máximo único, de até 6 meses.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Existe sim essa possibilidade de manutenção do vínculo trabalhista — é justamente o direito assegurado pelo art. 9º, §2º, II.

BIZU DE PROVA:
O prazo de 6 meses para manutenção do vínculo trabalhista (art. 9º, §2º, II) é um dos números mais cobrados da Lei — decore-o com atenção às variações que as bancas costumam testar (3, 9, 12 meses).'),
  (1310, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é F-V-F-V. Item 1 (falso): a criação de condições para o exercício dos direitos da mulher não é atribuição "singular" da União — é dever articulado de todos os entes federativos (art. 8º, caput). Item 2 (verdadeiro): o art. 6º dispõe que a violência doméstica constitui uma das formas de violação dos direitos da pessoa humana. Item 3 (falso): pela mesma razão do item 1, não é atribuição exclusiva do Município. Item 4 (verdadeiro): o atendimento policial e pericial especializado é diretriz e direito previstos nos arts. 8º, IV, e 11.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência F-F-F-F está incorreta, pois os itens 2 e 4 são verdadeiros.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência V-F-V-F está incorreta — os itens 1 e 3 são falsos (não há exclusividade de ente federativo), e os itens 2 e 4 são verdadeiros.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência V-V-V-V está incorreta, pois os itens 1 e 3 são falsos.

BIZU DE PROVA:
Nenhuma competência da política pública de combate à violência doméstica é "exclusiva" de um único ente federativo — é sempre ação articulada da União, Estados, DF e Municípios (art. 8º, caput), mais participação da sociedade civil.'),
  (1311, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A Súmula 542 do Superior Tribunal de Justiça estabelece que a ação penal relativa ao crime de lesão corporal resultante de violência doméstica contra a mulher é pública incondicionada, ou seja, não depende de representação da vítima.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou de outras de prestação pecuniária, além da substituição de pena que implique pagamento isolado de multa — não há admissão irrestrita de substituição por "quaisquer" penas restritivas de direitos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A coabitação, atual ou pretérita, não é exigida — o art. 5º, III, fala em relação íntima de afeto independentemente de coabitação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei se aplica também a relações homoafetivas entre duas mulheres, conforme o parágrafo único do art. 5º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O descumprimento de medida protetiva de urgência é crime autônomo desde a Lei 13.641/2018 (art. 24-A da Lei 11.340/2006), com pena de detenção de 3 meses a 2 anos.

BIZU DE PROVA:
Súmula 542/STJ — lesão corporal decorrente de violência doméstica é ação penal pública incondicionada, mesmo quando a lesão é leve (que, fora desse contexto, normalmente seria condicionada).'),
  (1312, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 41 da Lei 11.340/2006 afasta integralmente a aplicação da Lei 9.099/95 (que prevê a transação penal) aos crimes praticados com violência doméstica e familiar contra a mulher, independentemente da pena cominada — entendimento pacificado pelo STF na ADI 4.424 e pela Súmula 536 do STJ.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há vedação absoluta e ilimitada de substituição por pena restritiva de direitos em qualquer hipótese — o que a Lei veda especificamente (art. 17) é a pena de cesta básica ou de prestação pecuniária isolada.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A coabitação não é exigida para a caracterização da violência doméstica e familiar (art. 5º, III).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A suspensão condicional do processo também é afastada pelo art. 41 combinado com a Súmula 536 do STJ, e não se aplica aos casos de violência doméstica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Pela Súmula 542 do STJ, a ação penal por lesão corporal decorrente de violência doméstica é pública incondicionada, e não condicionada à representação.

BIZU DE PROVA:
O art. 41 (afasta a Lei 9.099/95) somado à Súmula 536/STJ (não cabe suspensão condicional do processo) e à Súmula 542/STJ (lesão corporal é ação pública incondicionada) formam o trio mais cobrado sobre processo penal na Lei Maria da Penha.'),
  (1313, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As assertivas I, IV e V estão corretas. I reproduz o rol de 5 formas de violência do art. 7º. IV reproduz a definição de violência patrimonial (art. 7º, IV). V reproduz o crime autônomo de descumprimento de medida protetiva (art. 24-A).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa: a definição apresentada ("calúnia, difamação ou injúria") é de violência MORAL (art. 7º, V), não física.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa: a definição apresentada ("ofenda integridade ou saúde corporal") é de violência FÍSICA (art. 7º, I), não patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa pelo mesmo motivo acima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa pelo mesmo motivo acima.

BIZU DE PROVA:
Essa questão troca os rótulos das definições (física vira patrimonial, moral vira física) — sempre releia a definição e confirme com qual das 5 modalidades do art. 7º ela realmente corresponde.'),
  (1314, 'GABARITO: CERTO

POR QUE:
A AMEAÇA de divulgar fotos íntimas da namorada caso ela termine o relacionamento configura, por si só, violência psicológica (art. 7º, II — ameaça e chantagem para controlar as ações da vítima), praticada em relação de namoro, que se enquadra no art. 5º, III (relação íntima de afeto, independentemente de coabitação). Isso já basta para a incidência da Lei Maria da Penha. Importante não confundir a ameaça com a divulgação em si: o crime do art. 218-C do Código Penal pune o ato de efetivamente oferecer, transmitir ou divulgar a cena íntima — a mera ameaça de fazê-lo, isoladamente, não consuma esse tipo penal (podendo, a depender do caso concreto, configurar o crime de ameaça do art. 147 do CP, sem prejuízo de eventual tentativa se a divulgação chegasse a ser iniciada).

PEGADINHA:
Se a questão dissesse que a Lei só se aplica a casais casados ou que coabitem, estaria errada — namoro, mesmo sem coabitação, já é suficiente para a incidência da Lei.

BIZU DE PROVA:
Ameaças ligadas ao término do relacionamento (inclusive de expor imagens íntimas) são clássicas de violência psicológica dentro de "relação íntima de afeto" — não é preciso coabitação nem vínculo formal.'),
  (1315, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 dispõe que a violência contra a mulher constitui uma violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A manutenção do vínculo trabalhista com afastamento do local de trabalho (art. 9º, §2º, II) não se restringe a casos de lesão corporal grave — cabe em qualquer situação de violência doméstica que exija o afastamento.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não se restringe a agressor masculino nem exige necessariamente parentesco ou afeto pré-existente da forma restrita descrita — abrange qualquer relação de âmbito doméstico, familiar ou afetivo, inclusive entre mulheres (parágrafo único do art. 5º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei Maria da Penha é de 2006 (Lei 11.340/2006), não de 1998.

BIZU DE PROVA:
O art. 6º é curto e direto — "a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos" — decore literalmente, é resposta certa recorrente em questões genéricas sobre o espírito da Lei.'),
  (1316, 'GABARITO: CERTO

POR QUE:
O art. 5º, caput, da Lei 11.340/2006 define violência doméstica e familiar como "qualquer ação OU OMISSÃO baseada no gênero" que cause os resultados previstos em lei. A omissão — por exemplo, deixar deliberadamente de prestar socorro ou cuidado devido — também pode configurar violência doméstica, não apenas condutas ativas.

PEGADINHA:
Se o item afirmasse que só a "ação" configura violência doméstica, excluindo a omissão, estaria errado — a Lei expressamente inclui as duas formas de conduta.

BIZU DE PROVA:
Grave o binômio "ação OU omissão" logo no início da definição do art. 5º — é frequentemente testado isoladamente em itens de Certo/Errado.'),
  (1317, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 3-1-2. O primeiro item (dano emocional, diminuição da autoestima, degradar/controlar) corresponde à violência PSICOLÓGICA (3). O segundo item (ofende integridade ou saúde corporal) corresponde à violência FÍSICA (1). O terceiro item (calúnia, difamação ou injúria) corresponde à violência MORAL (2).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência 1-2-3 inverte as associações corretas entre as definições e as modalidades de violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência 3-2-1 acerta o primeiro item, mas troca física por moral e moral por física nos dois últimos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência 2-1-3 não corresponde às associações corretas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência 2-3-1 não corresponde às associações corretas.

BIZU DE PROVA:
Psicológica é sobre a mente/emoção, física é sobre o corpo, moral é sobre a honra (os mesmos crimes contra a honra do Código Penal: calúnia, difamação, injúria).'),
  (1318, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
As ameaças e os escândalos provocados por Aline no local de trabalho de Sandra, após o término do relacionamento, configuram violência psicológica (art. 7º, II — ameaça, humilhação) e, a depender do conteúdo dos "escândalos", também moral (art. 7º, V), praticadas por Aline contra Sandra.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei se aplica sim a uniões homoafetivas — o parágrafo único do art. 5º dispensa orientação sexual como requisito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A alternativa inverte os polos da relação narrada: quem procura o Nudem relatando as ameaças é Sandra (vítima), e não Aline.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei se aplica mesmo após o término do relacionamento, pois o art. 5º, III, abrange quem "conviva ou tenha convivido" com a ofendida.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há previsão de "pagamento de cesta básica" como consequência de violência doméstica — pelo contrário, o art. 17 veda expressamente esse tipo de pena.

BIZU DE PROVA:
A Lei Maria da Penha protege a mulher também em relações homoafetivas femininas — o que importa é a relação de afeto e a condição de vítima mulher, não a orientação sexual das partes.'),
  (1319, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10-A, caput, assegura à mulher em situação de violência doméstica o atendimento policial e pericial especializado, ininterrupto, prestado por servidores PREFERENCIALMENTE do sexo feminino, previamente capacitados — a redação que trata indistintamente "sexo masculino ou feminino" contraria essa diretriz de preferência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As medidas protetivas de urgência também podem ser requeridas pelo Ministério Público (art. 19, caput: "a requerimento do Ministério Público ou a pedido da ofendida"), não exclusivamente pela vítima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As medidas protetivas podem ser aplicadas cumulativamente e substituídas por outras de maior eficácia sempre que os direitos da mulher estiverem ameaçados — não há vedação de substituição.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 21, parágrafo único, veda expressamente que a ofendida entregue intimação ou notificação ao agressor.

BIZU DE PROVA:
Medida protetiva pode ser pedida pela ofendida OU requerida pelo Ministério Público (não é exclusividade da vítima); e a ofendida nunca pode ser a portadora de intimação/notificação ao agressor (art. 21, parágrafo único).'),
  (1320, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O texto legal (art. 2º, proteção a "toda mulher", sem discriminação de orientação sexual entre outros fatores; e art. 5º, parágrafo único, que dispensa orientação sexual nas relações pessoais) já garante a proteção a mulheres heterossexuais e homossexuais. Quanto às mulheres transexuais, a letra da Lei não menciona expressamente identidade de gênero — mas o STJ já reconheceu, em sua jurisprudência, a aplicação da Lei Maria da Penha à mulher trans em situação de violência doméstica, considerando o gênero autopercebido e a finalidade protetiva da norma. É essa combinação (texto legal + entendimento do STJ) que sustenta a alternativa como correta.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não se restringe a mulheres casadas nem heterossexuais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não protege homens vítimas de violência doméstica — é lei de proteção específica de gênero, voltada à mulher.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há recorte religioso ou filosófico como critério de proteção da Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há exclusão de profissionais do sexo — a Lei protege toda mulher, sem discriminação quanto à ocupação (art. 2º).

BIZU DE PROVA:
O texto do art. 5º garante a proteção independente de orientação sexual; a extensão a mulheres trans e travestis vem do entendimento do STJ, não de uma menção literal do dispositivo — não confunda texto de lei com jurisprudência ao fundamentar a resposta.'),
  (1321, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Os itens I e II estão corretos. O item I reproduz a definição de violência física do art. 7º, I (conduta que ofenda a integridade ou saúde corporal). O item II reproduz uma das providências da autoridade policial previstas no art. 11, II (encaminhar a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas o item I como correto, mas o item II também está correto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item II como correto, mas o item I também está correto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera os dois itens como incorretos, quando ambos estão corretos.

BIZU DE PROVA:
O art. 7º, I (violência física) e o art. 11 (rol de providências da autoridade policial no atendimento) costumam ser cobrados juntos — memorize o rol do art. 11 (proteção, IML, transporte, retirada de pertences, informação de direitos).'),
  (1322, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A 1ª parte reproduz corretamente a definição de violência psicológica do art. 7º, II. A 2ª parte reproduz corretamente a previsão de equipe de atendimento multidisciplinar dos Juizados de Violência Doméstica e Familiar, prevista no art. 29 da Lei. Ambas as partes estão certas, tornando a sentença totalmente correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirma que só a 1ª parte está correta, mas a 2ª parte (equipe multidisciplinar) também reproduz corretamente o texto legal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirma que só a 2ª parte está correta, mas a 1ª parte (definição de violência psicológica) também reproduz corretamente o texto legal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirma que a sentença é totalmente incorreta, mas as duas partes reproduzem fielmente dispositivos da Lei 11.340/2006.

BIZU DE PROVA:
Questões que combinam duas partes literais da Lei costumam usar uma delas como "isca" para gerar dúvida — sempre confira cada parte separadamente contra o texto legal antes de decidir se a combinação está certa.'),
  (1323, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 9º, §3º, da Lei prevê expressamente que a assistência à mulher em situação de violência doméstica compreende, entre outras ações, a contracepção de emergência, a profilaxia das Doenças Sexualmente Transmissíveis (DST) e da AIDS, e outros procedimentos médicos necessários e cabíveis nos casos de violência sexual — a exclusão descrita na alternativa não existe na Lei, que trata exatamente do oposto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A autoridade policial não depende de autorização judicial para adotar providências imediatas diante de violência doméstica — o art. 10 é expresso ao determinar que a autoridade policial "adotará, de imediato, as providências legais cabíveis" ao tomar conhecimento do fato.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 16 exige que a renúncia à representação ocorra ANTES do recebimento da denúncia, e não depois.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica e a substituição de pena por pagamento isolado de multa.

BIZU DE PROVA:
Cuidado com a inversão "antes/depois" no art. 16 — a renúncia à representação só pode ocorrer antes do recebimento da denúncia, nunca depois.'),
  (1324, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — fundamento aplicável ao "ciclo de violência" descrito na situação hipotética.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A coabitação não é requisito para a aplicação da Lei em relação íntima de afeto (art. 5º, III), ainda que o relacionamento tenha durado 12 anos sem coabitação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 15 estabelece o foro à escolha da OFENDIDA (domicílio/residência dela, lugar do fato ou domicílio do agressor) — a competência não é definida por opção do ofensor.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prisão preventiva é decretada pelo juiz — de ofício, a requerimento do Ministério Público, ou mediante representação da autoridade policial (art. 20) — nunca diretamente pela autoridade policial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A pena de cesta básica e os institutos despenalizadores da Lei 9.099/95 são vedados pela própria Lei Maria da Penha (arts. 17 e 41), não aplicáveis aos processos de sua competência.

BIZU DE PROVA:
O foro do art. 15 é escolha da ofendida, não do agressor; e só o juiz decreta prisão preventiva — a autoridade policial apenas representa por ela.'),
  (1325, 'GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 prevê taxativamente 5 formas de violência doméstica: física, psicológica, sexual, patrimonial e moral. Não existe a categoria "violência simbólica" no rol legal — trata-se de conceito sociológico, não de uma modalidade jurídica prevista na Lei. Além disso, os fatos narrados (insultos constantes, ofensas, questionamento da paternidade dos filhos) descrevem principalmente violência psicológica (art. 7º, II) e, a depender da conduta, moral (art. 7º, V), não uma suposta "violência patrimonial classificada como simbólica".

PEGADINHA:
A banca usa um termo que parece jurídico ("violência simbólica") para testar se o candidato confunde teoria sociológica sobre gênero com o rol taxativo do art. 7º da Lei.

BIZU DE PROVA:
Memorize que o art. 7º só reconhece 5 modalidades — física, psicológica, sexual, patrimonial e moral. Qualquer outro nome ("simbólica", "institucional" etc.) não está na letra da lei.'),
  (1326, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado EXCETO):
Afirmar que "a característica inovadora" da Lei é contemplar especificamente a agressão física inverte o mérito histórico da Lei: a violência física já era tratada pelo Código Penal antes de 2006. A real inovação da Lei Maria da Penha foi ampliar o conceito de violência doméstica para além da física, reconhecendo expressamente as violências psicológica, sexual, patrimonial e moral (art. 7º), além de criar mecanismos processuais e assistenciais específicos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmação verdadeira sobre a Lei, não a exceção pedida):
A Lei realmente se aplica a mulheres heterossexuais e homossexuais, por força do art. 5º, parágrafo único (que dispensa orientação sexual); e a jurisprudência do STJ já estendeu essa proteção também a mulheres trans, com base no gênero autopercebido e na finalidade protetiva da norma — a afirmativa está correta tanto pelo texto legal quanto pelo entendimento consolidado nos tribunais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmação verdadeira sobre a Lei, não a exceção pedida):
O agressor de fato não precisa ser marido ou companheiro — pode ser qualquer pessoa do convívio doméstico ou familiar da vítima.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmação verdadeira sobre a Lei, não a exceção pedida):
A Lei de fato veda a substituição por cesta básica ou multa isolada (art. 17), e admite a prisão do agressor conforme as circunstâncias do caso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma afirmação compatível com dados de conhecimento popular e pesquisas divulgadas à época, não a exceção jurídica pedida):
Trata-se de dado estatístico de divulgação pública, coerente com o enunciado, e não com um erro de conteúdo jurídico da Lei.

BIZU DE PROVA:
Questões "EXCETO" pedem a alternativa ERRADA — aqui a pegadinha está em dizer que a "novidade" foi tratar da violência física (que já existia no Código Penal), quando a real inovação foi ampliar a proteção para as outras 4 modalidades (psicológica, sexual, patrimonial e moral).'),
  (1327, 'GABARITO: ERRADO

POR QUE:
A definição legal completa do art. 5º, caput, exige "...sofrimento físico, sexual OU PSICOLÓGICO E DANO MORAL OU PATRIMONIAL". O item transcreveu apenas "morte, lesão, sofrimento físico, sexual ou psicológico", omitindo a parte final da definição ("e dano moral ou patrimonial"), o que torna a transcrição incompleta e, portanto, incorreta para fins de prova que cobra a redação literal do dispositivo.

PEGADINHA:
Bancas costumam "cortar o final" de definições legais extensas — sempre compare o item com a redação completa antes de marcar Certo.

BIZU DE PROVA:
Toda vez que a questão citar a definição do art. 5º, confira se aparecem os elementos: morte, lesão, sofrimento físico/sexual/psicológico E dano moral/patrimonial — se faltar um pedaço, o item geralmente está errado.'),
  (1328, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O dever de criar condições para o exercício dos direitos previstos na Lei não é exclusivo do poder público — o art. 3º, §2º, atribui essa obrigação também à família e à sociedade em geral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A definição do art. 5º inclui o dano patrimonial ("...e dano moral OU PATRIMONIAL") — a alternativa erra ao excetuá-lo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A política pública se faz por ações da União, dos Estados, do Distrito Federal E dos Municípios, além de ações não governamentais (art. 8º, caput) — não é restrita a União e Estados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os Juizados de Violência Doméstica e Familiar, embora integrem a Justiça Ordinária com competência cível e criminal, não são de criação exclusiva da União: o art. 14 atribui à União a criação nos Territórios e no Distrito Federal (cujo Judiciário é organizado e mantido pela União, art. 21, XIII, da CF), enquanto cada Estado cria e organiza os seus próprios Juizados.

BIZU DE PROVA:
O art. 3º, §2º, atribui o dever de criar condições para os direitos da mulher à família, à sociedade e ao poder público em conjunto — nunca de forma "exclusiva" a um só desses agentes.'),
  (1329, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa reproduz o art. 7º, III, que define violência sexual, incluindo a conduta de forçar a mulher ao matrimônio mediante coação, chantagem, suborno ou manipulação, bem como limitar ou anular o exercício de seus direitos sexuais e reprodutivos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A coabitação não é exigida para a caracterização da violência doméstica e familiar (art. 5º, III).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A competência dos Juizados de Violência Doméstica e Familiar é cível E criminal (art. 14), não exclusivamente criminal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º, I, define unidade doméstica como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, "inclusive as esporadicamente agregadas" — a alternativa trocou "inclusive" por "salvo", invertendo o sentido do dispositivo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 21, parágrafo único, veda que a ofendida entregue intimação ou notificação ao agressor, mesmo quando não houver outro meio disponível.

BIZU DE PROVA:
No art. 5º, I, a unidade doméstica inclui as pessoas esporadicamente agregadas — bancas costumam trocar "inclusive" por "salvo/exceto" para inverter o sentido do dispositivo.'),
  (1330, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Foi lavrado Boletim de Ocorrência porque Dulce foi vítima de violência patrimonial (dilapidação do patrimônio comum e de bens particulares sem prestação de contas ou partilha, art. 7º, IV) e psicológica (ofensas diárias por palavras e gestos, art. 7º, II), praticadas por razão de gênero — a relação homoafetiva entre duas mulheres está plenamente protegida pela Lei (parágrafo único do art. 5º).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não se trata de mera notificação para comparecimento como averiguada — diante do relato de violência, cabe o registro direto do Boletim de Ocorrência com as providências do art. 12.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não é caso de Termo Circunstanciado nem de aplicação da Lei 9.099/95 — o art. 41 afasta expressamente essa lei dos casos de violência doméstica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O fato de a autora da violência (Ana) também ser mulher não afasta a proteção de Dulce — a Lei se aplica a relações homoafetivas femininas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A violência patrimonial está expressamente prevista no art. 7º, IV, da Lei — não é mero ilícito civil desvinculado da proteção da Lei Maria da Penha.

BIZU DE PROVA:
Relação homoafetiva entre duas mulheres está plenamente protegida pela Lei — inclusive quando a violência é patrimonial (dilapidação de bens, abuso de procuração), modalidade que muitos candidatos esquecem que também integra o art. 7º.');

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
  if v_total <> 40 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 40 questoes (tem %)', v_total;
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

  -- Nenhuma PROBLEMATICA (gabarito ambiguo) pode ser atualizada, mesmo que
  -- tenha entrado no staging por engano.
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
-- ESCRITA — única coluna alterada: questoes.explicacao.
-- ----------------------------------------------------------------------------
update public.questoes q
set explicacao = s.explicacao_nova
from _staging_explicacoes s
where q.id = s.questao_id;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_sublote1_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_sublote1_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_sublote1_asserts (descricao, ok) values (p_descricao, p_ok);
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

  call teste_sublote1_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_antes.total_questoes);
  call teste_sublote1_assert('nenhuma alternativa criada/removida/alterada em quantidade (total_alternativas inalterado)', v_total_alternativas = v_antes.total_alternativas);
  call teste_sublote1_assert('nenhum vinculo de unidade pedagogica criado/removido', v_total_vinculos_unidade = v_antes.total_vinculos_unidade);
  call teste_sublote1_assert('nenhum vinculo de curso_questoes criado/removido', v_total_curso_questoes = v_antes.total_curso_questoes);
  call teste_sublote1_assert('explicacao passou a existir em exatamente +40 questoes', v_total_com_explicacao = v_antes.total_com_explicacao + 40);

  -- Hash linha a linha: prova que NENHUM outro campo das 40 questoes mudou,
  -- e que alternativas/vinculos de CADA uma delas continuam byte a byte
  -- iguais.
  select count(*) into v_diferentes_enunciado_ou_metadado
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call teste_sublote1_assert('enunciado/fonte/banca/concurso/materia/assunto/ativa idênticos em todas as 40 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _snapshot_antes_questoes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call teste_sublote1_assert('alternativas (texto/correta/ordem) idênticas em todas as 40 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call teste_sublote1_assert('vinculos de unidade pedagogica idênticos em todas as 40 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call teste_sublote1_assert('vinculos de curso_questoes idênticos em todas as 40 (hash bate)', v_diferentes_vinculo_curso = 0);

  -- Nenhuma explicacao vazia, nenhuma so gabarito/fonte (mesma regra
  -- estrutural da auditoria, supabase/classificar_explicacoes_questoes.sql).
  select count(*) into v_sem_explicacao_pos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call teste_sublote1_assert('nenhuma das 40 ficou com explicacao vazia', v_sem_explicacao_pos = 0);

  select count(*) into v_generica_ou_vazia
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso';
  call teste_sublote1_assert('nenhuma das 40 contém apenas boilerplate de gabarito/fonte', v_generica_ou_vazia = 0);

  -- Reclassifica as 40 pela MESMA regra da auditoria: todas precisam virar
  -- EXPLICACAO_COMPLETA.
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
  call teste_sublote1_assert('todas as 40 reclassificam como EXPLICACAO_COMPLETA pela mesma regra da auditoria', v_incompletas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_sublote1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
