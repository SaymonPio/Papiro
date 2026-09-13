-- IMPORTACAO LOTE07_LEGISLACAO_INSTITUCIONAL — 23 questoes autorais para 4
-- unidades de Legislacao Especifica (curso Brigada Militar RS): Lei de
-- Organizacao Basica da BM (+8), Plano de Carreira dos Servidores
-- Militares (+6), Estatuto dos Militares Estaduais (+5), Regulamento
-- Disciplinar da Brigada Militar (+4).
--
-- Human sign-off explicito, revisao final unica (mandato "PAPIRO — LOTE 07 —
-- HUMAN REVIEW FINAL + EDIT LOB-10 + FREEZE 23 + IMPORTACAO + POS-CHECK +
-- COMMIT/PUSH"). 23 SELECTED (LOB 8, Plano de Carreira 6, Estatuto 5,
-- Regulamento Disciplinar 4). 2 APPROVED_RESERVE (ES-02, RD-02) — NAO
-- importadas nesta fase, preservadas apenas no review/frozen-support. 7
-- NORMATIVE_CONTENT_BLOCK (LOB-01, LOB-06, LOB-07, LOB-09, PC-03, PC-06,
-- RD-01) — NAO importadas. LOB-10 na versao EDITADA pelo humano (art. 13,
-- Estado-Maior) — ver frozen para o texto anterior substituido.
--
-- Padrao identico aos lotes precedentes (multi-unidade, igual ao Lote05):
-- staging de questoes/explicacoes/alternativas, insercao por INSERT direto
-- em questoes/alternativas (nunca em questao_unidades_pedagogicas), vinculo
-- exclusivamente via classificar_questao_unidade_admin (RPC que sincroniza
-- curso_questoes automaticamente).
--
-- NAO altera nenhuma questao existente nas 4 unidades.
-- NAO altera unidades/conteudos/materias/aulas. NAO cria migration/schema.
--
-- Texto final persistido em
-- outputs/curadoria-autoral/review/LOTE07-LEGISLACAO-INSTITUCIONAL-HUMAN-REVIEW.md,
-- congelado em outputs/curadoria-autoral/review/LOTE07-FROZEN-23.json.
--
-- ROLLBACK-TESTADO em importar_lote07_legislacao_institucional_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_lote07_legislacao_institucional.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;

insert into _lote_questoes (ordem, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 63, $D1$media$D1$, $FONTE1$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-02$FONTE1$, $ENUN1$Sobre a relação da Brigada Militar com a organização estadual de segurança pública, assinale a alternativa correta.$ENUN1$),
(2, 63, $D2$media$D2$, $FONTE2$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-03$FONTE2$, $ENUN2$No contexto da organização institucional da Brigada Militar, a expressão “competências da instituição” refere-se, corretamente, ao conjunto de$ENUN2$),
(3, 63, $D3$media$D3$, $FONTE3$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-04$FONTE3$, $ENUN3$A estrutura organizacional da Brigada Militar é composta por três níveis. Assinale a alternativa que apresenta corretamente essa composição.$ENUN3$),
(4, 63, $D4$media$D4$, $FONTE4$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-05$FONTE4$, $ENUN4$Considerando a organização da Brigada Militar, assinale a alternativa que caracteriza corretamente a expressão Órgão de Polícia Militar (OPM).$ENUN4$),
(5, 63, $D5$media$D5$, $FONTE5$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-08$FONTE5$, $ENUN5$Assinale a alternativa que apresenta corretamente a competência do Chefe do Estado-Maior da Brigada Militar.$ENUN5$),
(6, 63, $D6$media$D6$, $FONTE6$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-10$FONTE6$, $ENUN6$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa correta acerca do Estado-Maior da Brigada Militar.$ENUN6$),
(7, 63, $D7$media$D7$, $FONTE7$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-11$FONTE7$, $ENUN7$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa que apresenta corretamente atribuições do Subcomandante-Geral da Brigada Militar.$ENUN7$),
(8, 63, $D8$media$D8$, $FONTE8$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — LOB-12$FONTE8$, $ENUN8$A respeito do Conselho Superior da Brigada Militar, conforme a Lei Complementar nº 16.450/2025, assinale a alternativa correta.$ENUN8$),
(9, 65, $D9$media$D9$, $FONTE9$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-01$FONTE9$, $ENUN9$No âmbito da carreira dos Servidores Militares Estaduais de Nível Superior, assinale a alternativa que apresenta corretamente os quadros que compõem sua estrutura.$ENUN9$),
(10, 65, $D10$media$D10$, $FONTE10$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-02$FONTE10$, $ENUN10$Considerando a inclusão no quadro de acesso destinado à promoção ao posto de Coronel, assinale a alternativa correta.$ENUN10$),
(11, 65, $D11$media$D11$, $FONTE11$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-04$FONTE11$, $ENUN11$Para ingressar no Curso Superior de Polícia Militar, exige-se que o candidato seja aprovado em concurso público e possua qual formação?$ENUN11$),
(12, 65, $D12$media$D12$, $FONTE12$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-05$FONTE12$, $ENUN12$Em relação à situação dos candidatos aprovados no concurso para ingresso no quadro de oficiais, assinale a alternativa correta quanto à denominação recebida durante a frequência do Curso Superior de Polícia Militar e à duração máxima desse curso.$ENUN12$),
(13, 65, $D13$media$D13$, $FONTE13$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-07$FONTE13$, $ENUN13$No contexto das regras de promoção da carreira, assinale a situação em que um Capitão preenche, simultaneamente, as condições específicas exigidas para a promoção ao posto de Major.$ENUN13$),
(14, 65, $D14$media$D14$, $FONTE14$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — PC-08$FONTE14$, $ENUN14$Para que um Tenente-Coronel tenha acesso à promoção ao posto de Coronel, qual condição relativa à formação deve estar cumprida?$ENUN14$),
(15, 51, $D15$media$D15$, $FONTE15$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — ES-01$FONTE15$, $ENUN15$Assinale a alternativa que apresenta corretamente, de forma conjunta, as características do serviço policial-militar e da carreira de servidor militar.$ENUN15$),
(16, 51, $D16$media$D16$, $FONTE16$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — ES-03$FONTE16$, $ENUN16$Considerando as regras sobre os Oficiais nomeados Juízes do Tribunal Militar do Estado e sobre a precedência entre servidores militares, assinale a alternativa correta.$ENUN16$),
(17, 51, $D17$media$D17$, $FONTE17$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — ES-04$FONTE17$, $ENUN17$A respeito das consequências decorrentes da violação de obrigações e deveres policiais-militares, assinale a alternativa correta.$ENUN17$),
(18, 51, $D18$media$D18$, $FONTE18$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — ES-05$FONTE18$, $ENUN18$No rol de direitos dos servidores militares estaduais, assinale a alternativa que apresenta corretamente os direitos relacionados à inatividade e aos períodos de afastamento regular.$ENUN18$),
(19, 51, $D19$media$D19$, $FONTE19$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — ES-06$FONTE19$, $ENUN19$Quanto aos direitos assistenciais dos servidores militares estaduais, assinale a alternativa correta.$ENUN19$),
(20, 64, $D20$media$D20$, $FONTE20$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — RD-03$FONTE20$, $ENUN20$No tocante às sanções disciplinares e às respectivas formas de aplicação, assinale a alternativa correta.$ENUN20$),
(21, 64, $D21$media$D21$, $FONTE21$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — RD-04$FONTE21$, $ENUN21$Considerando as características da detenção e da prisão administrativa, assinale a alternativa correta.$ENUN21$),
(22, 64, $D22$media$D22$, $FONTE22$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — RD-05$FONTE22$, $ENUN22$Um militar estadual tomou conhecimento de fato contrário à disciplina e optou por comunicá-lo verbalmente ao seu superior imediato. Nessa situação, assinale a alternativa correta quanto à formalização da comunicação.$ENUN22$),
(23, 64, $D23$media$D23$, $FONTE23$PAPIRO — LOTE07_LEGISLACAO_INSTITUCIONAL — RD-06$FONTE23$, $ENUN23$Em relação ao processo administrativo disciplinar militar, assinale a alternativa correta.$ENUN23$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$A alternativa C está correta, pois expressa a vinculação e a integração da Brigada Militar ao Sistema de Segurança Pública do Estado. As alternativas A e B negam essa relação institucional. A D desloca indevidamente a vinculação para outros entes federativos, e a E substitui, de forma incorreta, o sistema estadual pela segurança privada.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 2º. — O art. 2º estabelece a vinculação e a integração da Brigada Militar ao Sistema de Segurança Pública do Estado, o que sustenta a alternativa C e afasta as demais, que negam, invertem ou restringem essa vinculação.$EXPL1$),
(2, $EXPL2$Competências institucionais correspondem às atribuições e responsabilidades conferidas à Brigada Militar para o desempenho de suas funções. A alternativa B trata de níveis estruturais; a C limita indevidamente o conceito à disciplina; a D confunde competências com efetivo; e a E restringe o conceito a procedimentos internos, que não esgotam as atribuições institucionais.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 3º. — O art. 3º trata das competências da Brigada Militar, entendidas como o conjunto de atribuições e responsabilidades institucionais a ela conferidas, o que sustenta a alternativa A; as demais confundem competências com outros temas da lei (níveis estruturais, disciplina, efetivo, procedimentos).$EXPL2$),
(3, $EXPL3$A composição correta reúne os níveis de Direção-Geral, Direção Setorial e Execução. As demais alternativas substituem um ou mais níveis por denominações não integrantes da tríade prevista, como Direção Operacional, Fiscalização, Administração, Direção Estratégica, Direção Tática, Planejamento, Coordenação ou Controle.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 4º. — O art. 4º define os três níveis da estrutura organizacional — Direção-Geral, Direção Setorial e Execução —, o que sustenta exatamente a alternativa A e afasta as demais, que substituem um ou mais níveis por denominações não previstas.$EXPL3$),
(4, $EXPL4$A alternativa A está correta, pois OPM é uma designação aplicável aos órgãos que compõem a estrutura institucional, abrangendo a consideração de espécies, classificação e denominação. A alternativa B restringe indevidamente o conceito ao atendimento de ocorrências; as alternativas C, D e E atribuem ao termo sentidos absolutos ou meramente circunstanciais que não correspondem à sua função organizacional.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 5º. — O art. 5º trata do conceito, das espécies, da classificação e da denominação dos Órgãos de Polícia Militar (OPM), o que sustenta a alternativa A; as demais restringem ou alteram indevidamente o alcance da expressão OPM.$EXPL4$),
(5, $EXPL5$A alternativa A reproduz corretamente a competência atribuída ao Chefe do Estado-Maior: assessoramento ao Comandante-Geral em assuntos de ordem estratégica e coordenação geral das atividades dos órgãos de direção setorial. A alternativa B restringe indevidamente o assessoramento a matéria disciplinar e altera o objeto da coordenação. A alternativa C confunde a função com a de substituição do Comandante-Geral. A alternativa D elimina o assessoramento estratégico. A alternativa E modifica tanto o destinatário do assessoramento quanto o caráter geral da coordenação.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 10. — O art. 10 atribui ao Chefe do Estado-Maior a competência de assessorar o Comandante-Geral nos assuntos de ordem estratégica da Instituição e coordenar, em caráter geral, as atividades dos Órgãos do Nível de Direção Setorial — reprodução literal que sustenta a alternativa A e afasta as demais, que alteram o destinatário, o objeto ou o caráter do assessoramento/coordenação.$EXPL5$),
(6, $EXPL6$A alternativa A está correta. Conforme o art. 13 da Lei Complementar nº 16.450/2025, o Estado-Maior da Brigada Militar é órgão de assessoramento do Comando-Geral, incumbido do estudo e do planejamento estratégico da Instituição.

A alternativa B atribui ao Estado-Maior função operacional que não corresponde ao art. 13. A alternativa C confunde o Estado-Maior com o Conselho Superior e ainda atribui poder deliberativo não previsto. A alternativa D altera tanto o órgão assessorado quanto a natureza de suas atribuições. A alternativa E o coloca incorretamente fora da estrutura institucional.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 13. — O art. 13 estabelece que o Estado-Maior da Brigada Militar é órgão de assessoramento do Comando-Geral, incumbido do estudo e do planejamento estratégico da Instituição.$EXPL6$),
(7, $EXPL7$A alternativa B está correta, pois o Subcomandante-Geral assessora o Comandante-Geral no cumprimento das atribuições da Brigada Militar e coordena, em caráter geral, as atividades de ordem operacional dos Comandos Regionais e Especializados. A alternativa A descreve a competência do Chefe do Estado-Maior, ligada a assuntos estratégicos e aos Órgãos do Nível de Direção Setorial. As alternativas C e D atribuem funções não previstas ao Subcomandante-Geral. A alternativa E erra ao restringir a substituição do Comandante-Geral à vacância definitiva: a substituição ocorre nas ausências e impedimentos.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 9º e parágrafo único — O art. 9º estabelece que compete ao Subcomandante-Geral assessorar o Comandante-Geral no cumprimento das atribuições da Brigada Militar e coordenar, em caráter geral, as atividades de ordem operacional desenvolvidas pelos Comandos Regionais e Especializados. O parágrafo único prevê que o Subcomandante-Geral é o substituto do Comandante-Geral em suas ausências e impedimentos.$EXPL7$),
(8, $EXPL8$A alternativa B reproduz corretamente os dois aspectos previstos para o Conselho Superior: sua composição, limitada aos Coronéis da ativa em exercício na Instituição, e sua função de assessoramento em assuntos de interesse da Corporação. A alternativa A amplia indevidamente a composição e lhe atribui poder decisório vinculante. A alternativa C inclui inativos e prevê aprovação de atos não estabelecida no dispositivo. A alternativa D troca os Coronéis por oficiais superiores e atribui coordenação operacional. A alternativa E confunde a função do Conselho Superior com a substituição exercida pelo Subcomandante-Geral.

FUNDAMENTO: Lei Complementar nº 16.450/2025, art. 12 — O art. 12 dispõe que o Conselho Superior é constituído pelos Coronéis da ativa em exercício na Instituição e que presta assessoramento em assuntos de interesse da Corporação. Portanto, não inclui genericamente todos os oficiais, não abrange inativos e não recebe competência deliberativa vinculante no dispositivo.$EXPL8$),
(9, $EXPL9$A carreira é estruturada por dois quadros: o Quadro de Oficiais de Estado Maior (QOEM) e o Quadro de Oficiais Especialistas em Saúde (QOES). A alternativa B altera a denominação do segundo quadro; a C introduz quadro não previsto; e D e E estão incorretas porque indicam apenas um dos dois quadros que integram a estrutura.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 2º, caput. — O art. 2º estrutura a carreira dos Servidores Militares Estaduais de Nível Superior nos quadros QOEM (Quadro de Oficiais de Estado-Maior) e QOES (Quadro de Oficiais Especialistas de Saúde), o que sustenta a alternativa A e afasta as demais, que alteram a denominação de um dos quadros, introduzem quadro não previsto ou omitem um dos dois quadros.$EXPL9$),
(10, $EXPL10$É admitida a recusa, pelo próprio servidor, de sua inclusão no quadro de acesso para promoção ao posto de Coronel. Por isso, a alternativa B está correta. A alternativa A nega essa possibilidade; a C desloca indevidamente a recusa para momento posterior à promoção; a D atribui a recusa apenas à Administração; e a E cria condição não indicada para o exercício dessa possibilidade.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 2º, §2º. — O § 2º prevê expressamente que a inclusão no quadro de acesso para a promoção ao posto de Coronel poderá ser recusada pelo servidor, o que sustenta a alternativa B e afasta as demais, que negam essa faculdade ou lhe atribuem condição não prevista.$EXPL10$),
(11, $EXPL11$O acesso ao Curso Superior de Polícia Militar ocorre mediante concurso público de provas e títulos, sendo exigida a diplomação no Curso de Ciências Jurídicas e Sociais. A alternativa A omite os títulos e altera a exigência de formação. A B modifica tanto a modalidade do concurso quanto o diploma requerido. A D substitui o concurso público por concurso interno, e a E indica formação diversa da exigida.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 3º, §1º. — O § 1º exige, para o ingresso no Curso Superior de Polícia Militar, concurso público de provas e títulos e diplomação no Curso de Ciências Jurídicas e Sociais, o que sustenta a alternativa C e afasta as demais, que alteram a modalidade do concurso ou a formação exigida.$EXPL11$),
(12, $EXPL12$A alternativa B está correta: durante a frequência do Curso Superior de Polícia Militar, os aprovados são considerados Alunos-Oficiais, e a duração do curso não pode exceder dois anos. A letra A emprega denominação e prazo incorretos. A letra C erra a denominação. A letra D transforma um limite máximo em duração obrigatória. A letra E apresenta denominação e prazo diversos dos previstos.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 3º, §2º. — O § 2º prevê que os aprovados, enquanto frequentam o Curso Superior de Polícia Militar (duração não excedente a dois anos), são considerados Alunos-Oficiais, o que sustenta a alternativa B e afasta as demais, que alteram a denominação ou transformam o limite máximo de dois anos em duração obrigatória ou diversa.$EXPL12$),
(13, $EXPL13$A alternativa A está correta porque reúne os dois requisitos de forma cumulativa: prestação de serviços em órgão de execução pelo período mínimo de três anos, admitida a contagem não contínua, e conclusão do CAAPM com aprovação. Em B, a mera matrícula não equivale à conclusão com aprovação. Em C, o tempo é inferior ao mínimo. Em D, não há comprovação de exercício em órgão de execução. Em E, exige-se especificamente o CAAPM, não outro curso.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 5º, §1º. — O § 1º exige, para a promoção a Major, três anos (consecutivos ou não) de serviço em órgão de execução e conclusão, com aprovação, do CAAPM, requisitos cumulativos que sustentam a alternativa A e afastam as demais, que alteram o tempo mínimo, a natureza do serviço ou o curso exigido.$EXPL13$),
(14, $EXPL14$A alternativa A está correta, pois o requisito formativo é a conclusão do CEPGSP com aprovação. Em B, a matrícula não demonstra conclusão. Em C, o CAAPM não é o curso exigido para esse acesso. Em D, o requisito de tempo em órgão de execução não substitui a formação exigida. Em E, a simples frequência é insuficiente, porque também é necessária a aprovação.

FUNDAMENTO: Lei Complementar nº 10.992/1997, art. 5º, §2º. — O § 2º exige, para a promoção a Coronel, a conclusão com aprovação do CEPGSP, o que sustenta a alternativa A e afasta as demais, que substituem o curso exigido, aceitam mera matrícula/frequência sem aprovação ou trocam o requisito por tempo de serviço.$EXPL14$),
(15, $EXPL15$A alternativa B é a correta porque reúne integralmente os dois enunciados: o serviço envolve atividades próprias da Brigada Militar e todos os encargos previstos na legislação específica e peculiar; a carreira, por sua vez, é restrita ao pessoal da ativa, começa com o ingresso e desenvolve-se conforme a sequência hierárquica. A alternativa A restringe indevidamente o serviço e inclui inativos na carreira. C e D alteram o marco inicial da carreira e reduzem o alcance do serviço. E exclui a legislação específica e peculiar e afasta a necessária sequência hierárquica.

FUNDAMENTO: Lei Complementar nº 10.990/1997, art. 4º, caput, e art. 5º, parágrafo único. — O art. 4º define o serviço policial-militar como o exercício de atividades inerentes à Brigada Militar e todos os encargos da legislação específica e peculiar; o art. 5º, parágrafo único, define a carreira como privativa do pessoal da ativa, iniciada com o ingresso e seguindo a sequência de graus hierárquicos — o que sustenta integralmente a alternativa B.$EXPL15$),
(16, $EXPL16$A alternativa B está correta, pois a precedência entre servidores militares da ativa com o mesmo grau hierárquico é estabelecida pela antiguidade no posto ou na graduação, excetuadas as situações de precedência funcional expressamente previstas. A alternativa A está errada porque os Oficiais nomeados Juízes do Tribunal Militar do Estado possuem regime definido por legislação própria. A alternativa C inverte a regra de precedência entre ativa e inatividade. A D substitui indevidamente a antiguidade pela idade. A E erra ao afirmar que a nomeação elimina as regras de precedência funcional.

FUNDAMENTO: Lei Complementar nº 10.990/1997, art. 8º, parágrafo único, e art. 15, caput. — O art. 8º, parágrafo único, submete os Oficiais nomeados Juízes do Tribunal Militar do Estado a legislação própria; o art. 15, caput, estabelece a antiguidade no posto ou na graduação como critério de precedência entre servidores da ativa de igual grau, ressalvada a precedência funcional do Comandante-Geral, do Subcomandante-Geral e do Chefe do Estado-Maior — o que sustenta a alternativa B.$EXPL16$),
(17, $EXPL17$A alternativa C está correta. A violação de obrigações ou deveres policiais-militares pode receber enquadramento como crime, contravenção ou transgressão disciplinar, conforme a disciplina específica. Além disso, a responsabilidade disciplinar não depende das responsabilidades civil e penal. A alternativa A reduz indevidamente as possíveis consequências à esfera disciplinar. A B contraria a independência entre as esferas de responsabilidade. A D ignora que a inobservância de deveres pode gerar responsabilidades funcional, pecuniária, disciplinar e penal. A E também nega, de modo incorreto, a possibilidade de apurações em mais de uma esfera.

FUNDAMENTO: Lei Complementar nº 10.990/1997, art. 35, caput e §2º. — O caput do art. 35 prevê que a violação de obrigações ou deveres pode caracterizar crime, contravenção ou transgressão disciplinar; o §2º estabelece que a responsabilidade disciplinar é independente das responsabilidades civil e penal — o que sustenta integralmente a alternativa C.$EXPL17$),
(18, $EXPL18$A alternativa A reproduz corretamente os dois direitos: a transferência para a reserva remunerada ou a reforma e as férias e as licenças. As demais alternativas alteram indevidamente o conteúdo do rol, ao excluir a reforma, as férias ou as licenças, ou ao atribuir ausência de remuneração e condicionamentos não previstos.

FUNDAMENTO: Lei Complementar nº 10.990/1997, art. 46, VII e VIII. — Os incisos VII e VIII do art. 46 asseguram, respectivamente, a transferência para a reserva remunerada ou a reforma, e as férias e as licenças, o que sustenta literalmente a alternativa A.$EXPL18$),
(19, $EXPL19$A alternativa A reúne corretamente os direitos previstos: assistência judiciária gratuita quando houver processo em razão de atos praticados em objeto de serviço; assistência social e médico-hospitalar; e saúde, higiene e segurança do trabalho. A alternativa B elimina a condição ligada aos atos praticados em objeto de serviço. As alternativas C, D e E restringem, excluem ou negam direitos que integram o rol.

FUNDAMENTO: Lei Complementar nº 10.990/1997, art. 46, XIII, XIV e XV. — Os incisos XIII, XIV e XV do art. 46 asseguram, respectivamente, a assistência judiciária gratuita quando processado em razão de atos praticados em objeto de serviço, a assistência social e médico-hospitalar, e a saúde, higiene e segurança do trabalho, o que sustenta literalmente a alternativa A.$EXPL19$),
(20, $EXPL20$A alternativa A está correta: a advertência é a forma mais branda de sanção, possui aplicação ostensiva por publicação em Boletim e deve ser registrada nos assentamentos individuais. A repreensão também é ostensiva, publicada em Boletim e averbada nos assentamentos, razão pela qual B, D e E estão incorretas. Já o licenciamento a bem da disciplina e a exclusão a bem da disciplina integram, sim, a enumeração das sanções disciplinares, tornando falsa a alternativa C.

FUNDAMENTO: Decreto Estadual nº 43.245/2004, art. 9º, V e VI, e arts. 10 e 11. — O art. 10 define a advertência como a sanção mais branda, aplicada ostensivamente por publicação em Boletim e registrada nos assentamentos individuais, o que sustenta a alternativa A; o art. 11 confirma que a repreensão também é ostensiva e averbada, e o art. 9º, V e VI, confirma que licenciamento e exclusão a bem da disciplina integram a relação de sanções — o que afasta as demais alternativas.$EXPL20$),
(21, $EXPL21$A alternativa B está correta, pois a prisão administrativa tem emprego exclusivo nas situações de conversão de infração penal em disciplinar e implica permanência no âmbito do aquartelamento, com prejuízo do serviço e da instrução. A detenção, por sua vez, cerceia a liberdade do punido, que deve permanecer no local determinado, mas sem ficar confinado. Por isso, A e E erram ao afirmar confinamento; C erra ao ampliar indevidamente o uso da prisão administrativa; e D nega o próprio cerceamento de liberdade característico da detenção.

FUNDAMENTO: Decreto Estadual nº 43.245/2004, art. 12, caput, e art. 13. — O art. 13 define a prisão administrativa como exclusiva para conversão de infração penal em disciplinar, consistindo na permanência no aquartelamento com prejuízo do serviço e da instrução, o que sustenta a alternativa B; o art. 12, caput, confirma que a detenção cerceia a liberdade sem confinamento, afastando as alternativas que alegam confinamento.$EXPL21$),
(22, $EXPL22$A alternativa C está correta: quando a comunicação é realizada verbalmente ao superior imediato, deve haver confirmação por escrito em até dois dias úteis. A alternativa A está errada porque a forma verbal não dispensa a confirmação escrita. A B erra ao excluir a possibilidade de comunicação verbal. A D reduz indevidamente o prazo previsto. A E está incorreta porque a comunicação deve ser dirigida ao superior imediato.

FUNDAMENTO: Decreto Estadual nº 43.245/2004, art. 26. — O art. 26 exige que a comunicação verbal de fato contrário à disciplina seja confirmada por escrito no prazo de até dois dias úteis, o que sustenta literalmente a alternativa C.$EXPL22$),
(23, $EXPL23$A alternativa D reúne corretamente as garantias e diretrizes aplicáveis: devido processo, ampla defesa, contraditório, celeridade e busca da verdade real, além da competência atribuída às autoridades aptas a aplicar sanção administrativa. A alternativa A erra porque a verdade real não elimina defesa e contraditório. A B confunde princípios de simplificação procedimental com dispensa de garantias. A C amplia indevidamente a competência para qualquer superior hierárquico. A E é incorreta porque economia procedimental não autoriza encerrar o processo sem assegurar defesa.

FUNDAMENTO: Decreto Estadual nº 43.245/2004, art. 28, caput e parágrafo único, e art. 29, caput. — O art. 28, caput, assegura ampla defesa e contraditório; o parágrafo único orienta o processo pela celeridade e pela busca da verdade real, entre outros princípios; o art. 29, caput, atribui a instauração, condução e julgamento à autoridade competente para aplicar a sanção — o que sustenta integralmente a alternativa D.$EXPL23$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$A Brigada Militar atua de modo desvinculado do Sistema de Segurança Pública do Estado.$ALT1_1$, false),
(1, 2, $ALT1_2$A integração da Brigada Militar ao Sistema de Segurança Pública é incompatível com sua atuação institucional.$ALT1_2$, false),
(1, 3, $ALT1_3$A Brigada Militar encontra-se vinculada e integrada ao Sistema de Segurança Pública do Estado.$ALT1_3$, true),
(1, 4, $ALT1_4$A Brigada Militar vincula-se exclusivamente a sistemas de segurança de outros entes federativos.$ALT1_4$, false),
(1, 5, $ALT1_5$A vinculação da Brigada Militar restringe-se à segurança privada, sem integração ao sistema estadual.$ALT1_5$, false),
(2, 1, $ALT2_1$atribuições e responsabilidades institucionais que lhe são conferidas.$ALT2_1$, true),
(2, 2, $ALT2_2$níveis estruturais destinados à distribuição interna dos órgãos.$ALT2_2$, false),
(2, 3, $ALT2_3$regras aplicáveis exclusivamente à conduta disciplinar de seus integrantes.$ALT2_3$, false),
(2, 4, $ALT2_4$dados numéricos relativos apenas ao quantitativo de pessoal.$ALT2_4$, false),
(2, 5, $ALT2_5$procedimentos administrativos restritos à elaboração de atos internos.$ALT2_5$, false),
(3, 1, $ALT3_1$Direção-Geral, Direção Setorial e Execução.$ALT3_1$, true),
(3, 2, $ALT3_2$Direção-Geral, Direção Operacional e Fiscalização.$ALT3_2$, false),
(3, 3, $ALT3_3$Administração, Direção Setorial e Execução.$ALT3_3$, false),
(3, 4, $ALT3_4$Direção Estratégica, Direção Tática e Execução.$ALT3_4$, false),
(3, 5, $ALT3_5$Planejamento, Coordenação e Controle.$ALT3_5$, false),
(4, 1, $ALT4_1$Designa órgão integrante da estrutura institucional, cuja identificação considera suas espécies, sua classificação e sua denominação próprias.$ALT4_1$, true),
(4, 2, $ALT4_2$Designa exclusivamente as unidades responsáveis pelo atendimento direto de ocorrências policiais.$ALT4_2$, false),
(4, 3, $ALT4_3$Substitui a denominação de toda a estrutura da Brigada Militar, sem distinção entre seus órgãos.$ALT4_3$, false),
(4, 4, $ALT4_4$Corresponde apenas a uma designação honorífica atribuída a órgãos de maior precedência.$ALT4_4$, false),
(4, 5, $ALT4_5$Refere-se unicamente a órgãos criados em caráter temporário para operações especiais.$ALT4_5$, false),
(5, 1, $ALT5_1$Assessora o Comandante-Geral nos assuntos de ordem estratégica da Instituição e coordena, em caráter geral, as atividades dos Órgãos do Nível de Direção Setorial.$ALT5_1$, true),
(5, 2, $ALT5_2$Assessora o Comandante-Geral exclusivamente em assuntos disciplinares e coordena diretamente as atividades operacionais de todas as unidades.$ALT5_2$, false),
(5, 3, $ALT5_3$Substitui o Comandante-Geral em qualquer situação e exerce, de modo exclusivo, a direção dos órgãos setoriais.$ALT5_3$, false),
(5, 4, $ALT5_4$Coordena apenas atividades administrativas internas, sem prestar assessoramento ao Comandante-Geral em assuntos estratégicos.$ALT5_4$, false),
(5, 5, $ALT5_5$Exerce assessoramento estratégico aos dirigentes setoriais e coordena, de forma específica, as atividades de cada órgão.$ALT5_5$, false),
(6, 1, $ALT6_1$É órgão de assessoramento do Comando-Geral, incumbido do estudo e do planejamento estratégico da Instituição.$ALT6_1$, true),
(6, 2, $ALT6_2$É órgão de execução responsável pela coordenação operacional direta dos Comandos Regionais e Especializados.$ALT6_2$, false),
(6, 3, $ALT6_3$É órgão colegiado constituído pelos Coronéis da ativa, responsável por deliberar de forma vinculante sobre os atos do Comandante-Geral.$ALT6_3$, false),
(6, 4, $ALT6_4$É órgão de assessoramento exclusivo do Subcomandante-Geral, responsável pela execução das atividades operacionais da Corporação.$ALT6_4$, false),
(6, 5, $ALT6_5$É órgão externo à estrutura da Brigada Militar, responsável pelo controle administrativo de seus órgãos de direção.$ALT6_5$, false),
(7, 1, $ALT7_1$Assessorar o Comandante-Geral em assuntos de ordem estratégica e coordenar os Órgãos do Nível de Direção Setorial.$ALT7_1$, false),
(7, 2, $ALT7_2$Assessorar o Comandante-Geral no cumprimento das atribuições da Brigada Militar e coordenar, em caráter geral, as atividades de ordem operacional desenvolvidas pelos Comandos Regionais e Especializados.$ALT7_2$, true),
(7, 3, $ALT7_3$Deliberar sobre os assuntos de interesse da Corporação, com decisões vinculantes para todos os órgãos da Instituição.$ALT7_3$, false),
(7, 4, $ALT7_4$Coordenar exclusivamente as atividades administrativas dos Comandos Regionais, sem função de assessoramento ao Comandante-Geral.$ALT7_4$, false),
(7, 5, $ALT7_5$Assessorar o Comandante-Geral em matérias estratégicas e substituí-lo apenas quando houver vacância definitiva do cargo.$ALT7_5$, false),
(8, 1, $ALT8_1$É constituído por todos os oficiais da ativa e possui competência decisória vinculante em assuntos institucionais.$ALT8_1$, false),
(8, 2, $ALT8_2$É constituído pelos Coronéis da ativa em exercício na Instituição e presta assessoramento em assuntos de interesse da Corporação.$ALT8_2$, true),
(8, 3, $ALT8_3$É composto pelos Coronéis da ativa e da inatividade, cabendo-lhe aprovar os atos administrativos do Comandante-Geral.$ALT8_3$, false),
(8, 4, $ALT8_4$É formado pelos oficiais superiores em exercício na Instituição e exerce funções de coordenação operacional dos Comandos Regionais.$ALT8_4$, false),
(8, 5, $ALT8_5$É integrado pelos Coronéis da ativa em exercício e tem a atribuição de substituir o Comandante-Geral em suas ausências e impedimentos.$ALT8_5$, false),
(9, 1, $ALT9_1$Quadro de Oficiais de Estado Maior (QOEM) e Quadro de Oficiais Especialistas em Saúde (QOES).$ALT9_1$, true),
(9, 2, $ALT9_2$Quadro de Oficiais de Estado Maior (QOEM) e Quadro de Praças Especialistas em Saúde (QPES).$ALT9_2$, false),
(9, 3, $ALT9_3$Quadro de Oficiais Especialistas em Saúde (QOES) e Quadro de Oficiais Administrativos (QOA).$ALT9_3$, false),
(9, 4, $ALT9_4$Quadro de Oficiais de Estado Maior (QOEM), exclusivamente.$ALT9_4$, false),
(9, 5, $ALT9_5$Quadro de Oficiais Especialistas em Saúde (QOES), exclusivamente.$ALT9_5$, false),
(10, 1, $ALT10_1$A inclusão é obrigatória, não sendo admitida manifestação contrária do servidor.$ALT10_1$, false),
(10, 2, $ALT10_2$O servidor pode recusar a inclusão no quadro de acesso.$ALT10_2$, true),
(10, 3, $ALT10_3$A recusa somente é possível após a promoção ao posto de Coronel.$ALT10_3$, false),
(10, 4, $ALT10_4$A inclusão pode ser recusada exclusivamente pela Administração, sem participação do servidor.$ALT10_4$, false),
(10, 5, $ALT10_5$A recusa da inclusão depende de o servidor requerer transferência para outro quadro.$ALT10_5$, false),
(11, 1, $ALT11_1$Concurso público de provas, com diplomação em qualquer curso superior.$ALT11_1$, false),
(11, 2, $ALT11_2$Concurso público de títulos, com diplomação em Curso de Administração.$ALT11_2$, false),
(11, 3, $ALT11_3$Concurso público de provas e títulos, com diplomação no Curso de Ciências Jurídicas e Sociais.$ALT11_3$, true),
(11, 4, $ALT11_4$Concurso interno de provas e títulos, com diplomação no Curso de Ciências Jurídicas e Sociais.$ALT11_4$, false),
(11, 5, $ALT11_5$Concurso público de provas e títulos, com conclusão de curso técnico na área de segurança.$ALT11_5$, false),
(12, 1, $ALT12_1$São denominados Cadetes, e o curso pode durar até um ano.$ALT12_1$, false),
(12, 2, $ALT12_2$São considerados Alunos-Oficiais, e o curso não pode exceder dois anos.$ALT12_2$, true),
(12, 3, $ALT12_3$São considerados Aspirantes a Oficial, e o curso pode durar até dois anos.$ALT12_3$, false),
(12, 4, $ALT12_4$São denominados Alunos-Oficiais, e o curso deve durar exatamente dois anos.$ALT12_4$, false),
(12, 5, $ALT12_5$São considerados Oficiais-alunos, e o curso não pode exceder três anos.$ALT12_5$, false),
(13, 1, $ALT13_1$Prestou serviços em órgão de execução por três anos, ainda que em períodos não contínuos, e concluiu o CAAPM com aprovação.$ALT13_1$, true),
(13, 2, $ALT13_2$Prestou serviços em órgão de execução por três anos consecutivos e encontra-se matriculado no CAAPM, sem tê-lo concluído.$ALT13_2$, false),
(13, 3, $ALT13_3$Prestou serviços em órgão de execução por dois anos e onze meses e concluiu o CAAPM com aprovação.$ALT13_3$, false),
(13, 4, $ALT13_4$Exerceu atividades administrativas por três anos e concluiu o CAAPM com aprovação.$ALT13_4$, false),
(13, 5, $ALT13_5$Prestou serviços em órgão de execução por três anos e concluiu, com aprovação, curso diverso do CAAPM.$ALT13_5$, false),
(14, 1, $ALT14_1$Ter concluído, com aprovação, o Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP).$ALT14_1$, true),
(14, 2, $ALT14_2$Estar regularmente matriculado no Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP).$ALT14_2$, false),
(14, 3, $ALT14_3$Ter concluído, com aprovação, o Curso Avançado de Administração Policial Militar (CAAPM).$ALT14_3$, false),
(14, 4, $ALT14_4$Ter prestado serviços em órgão de execução por, no mínimo, três anos.$ALT14_4$, false),
(14, 5, $ALT14_5$Ter frequentado o Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP), independentemente de aprovação.$ALT14_5$, false),
(15, 1, $ALT15_1$O serviço policial-militar limita-se às atividades operacionais ostensivas, e a carreira é acessível tanto ao pessoal da ativa quanto ao da inatividade.$ALT15_1$, false),
(15, 2, $ALT15_2$O serviço policial-militar compreende atividades inerentes à Brigada Militar e os encargos previstos na legislação específica e peculiar; a carreira é privativa do pessoal da ativa, inicia-se com o ingresso na Brigada Militar e segue a sequência de graus hierárquicos.$ALT15_2$, true),
(15, 3, $ALT15_3$O serviço policial-militar abrange somente encargos administrativos, e a carreira inicia-se após a confirmação no cargo, independentemente de graus hierárquicos.$ALT15_3$, false),
(15, 4, $ALT15_4$O serviço policial-militar é exercido exclusivamente por integrantes em início de carreira, a qual se inicia com a primeira promoção.$ALT15_4$, false),
(15, 5, $ALT15_5$O serviço policial-militar compreende apenas encargos definidos em normas gerais, e a carreira pode ser estruturada sem observância da sequência hierárquica.$ALT15_5$, false),
(16, 1, $ALT16_1$Os Oficiais nomeados Juízes do Tribunal Militar do Estado submetem-se integralmente às mesmas normas de carreira aplicáveis aos demais Oficiais da ativa.$ALT16_1$, false),
(16, 2, $ALT16_2$Entre servidores militares da ativa de igual grau hierárquico, a antiguidade no posto ou na graduação define a precedência, ressalvadas as hipóteses de precedência funcional do Comandante-Geral, do Subcomandante-Geral e do Chefe do Estado-Maior.$ALT16_2$, true),
(16, 3, $ALT16_3$Em igualdade de posto ou graduação, o servidor militar na inatividade tem precedência sobre o servidor militar da ativa em razão da maior experiência funcional.$ALT16_3$, false),
(16, 4, $ALT16_4$A precedência entre servidores militares do mesmo grau hierárquico é sempre definida pela idade, independentemente da antiguidade no posto ou na graduação.$ALT16_4$, false),
(16, 5, $ALT16_5$A nomeação de Oficial para atuar como Juiz do Tribunal Militar do Estado elimina toda regra de precedência funcional prevista para os servidores militares da ativa.$ALT16_5$, false),
(17, 1, $ALT17_1$A violação de dever policial-militar produz somente responsabilidade disciplinar, pois as demais esferas são absorvidas por ela.$ALT17_1$, false),
(17, 2, $ALT17_2$A responsabilidade disciplinar depende do reconhecimento prévio de responsabilidade penal ou civil pelo mesmo fato.$ALT17_2$, false),
(17, 3, $ALT17_3$A violação das obrigações ou dos deveres policiais-militares poderá caracterizar crime, contravenção ou transgressão disciplinar, conforme a disciplina específica aplicável, sendo a responsabilidade disciplinar independente das responsabilidades civil e penal.$ALT17_3$, true),
(17, 4, $ALT17_4$A inobservância de deveres previstos em normas internas acarreta apenas responsabilidade funcional, sem repercussão pecuniária, disciplinar ou penal.$ALT17_4$, false),
(17, 5, $ALT17_5$A caracterização de transgressão disciplinar impede, necessariamente, a apuração de responsabilidade civil e penal decorrente da mesma conduta.$ALT17_5$, false),
(18, 1, $ALT18_1$A transferência para a reserva remunerada ou a reforma, bem como as férias e as licenças.$ALT18_1$, true),
(18, 2, $ALT18_2$A transferência obrigatória para a reserva não remunerada, bem como as férias, vedadas as licenças.$ALT18_2$, false),
(18, 3, $ALT18_3$A reforma exclusivamente por incapacidade, bem como férias e licenças condicionadas à renúncia à remuneração.$ALT18_3$, false),
(18, 4, $ALT18_4$A transferência para a reserva remunerada, excluída a reforma, bem como apenas férias anuais.$ALT18_4$, false),
(18, 5, $ALT18_5$A transferência para a reserva ou a reforma sem remuneração, bem como licenças, excluídas as férias.$ALT18_5$, false),
(19, 1, $ALT19_1$É assegurada assistência judiciária gratuita quando o servidor militar for processado em razão de atos praticados em objeto de serviço, além de assistência social e médico-hospitalar e de saúde, higiene e segurança do trabalho.$ALT19_1$, true),
(19, 2, $ALT19_2$É assegurada assistência judiciária gratuita em qualquer processo, independentemente da relação com atos praticados em objeto de serviço, além de assistência social e médico-hospitalar.$ALT19_2$, false),
(19, 3, $ALT19_3$É assegurada assistência judiciária gratuita somente em processos civis, além de assistência médico-hospitalar, excluídas a assistência social e a segurança do trabalho.$ALT19_3$, false),
(19, 4, $ALT19_4$É assegurada assistência social e médico-hospitalar apenas aos servidores inativos, bem como assistência judiciária gratuita sem requisito relacionado ao serviço.$ALT19_4$, false),
(19, 5, $ALT19_5$É assegurada saúde e higiene do trabalho, mas a segurança do trabalho depende de autorização individual, e a assistência judiciária é sempre onerosa.$ALT19_5$, false),
(20, 1, $ALT20_1$A advertência é a sanção mais branda, aplicada ostensivamente mediante publicação em Boletim e registrada nos assentamentos individuais do transgressor.$ALT20_1$, true),
(20, 2, $ALT20_2$A repreensão é aplicada reservadamente e somente poderá ser averbada nos assentamentos individuais se houver reincidência.$ALT20_2$, false),
(20, 3, $ALT20_3$O licenciamento a bem da disciplina e a exclusão a bem da disciplina não integram a relação de sanções disciplinares.$ALT20_3$, false),
(20, 4, $ALT20_4$A advertência dispensa publicação em Boletim, enquanto a repreensão deve ser aplicada de forma sigilosa.$ALT20_4$, false),
(20, 5, $ALT20_5$A repreensão não é averbada nos assentamentos individuais, pois tal registro é exclusivo da advertência.$ALT20_5$, false),
(21, 1, $ALT21_1$A detenção implica confinamento do punido no local determinado pela autoridade competente.$ALT21_1$, false),
(21, 2, $ALT21_2$A prisão administrativa consiste na permanência do punido no âmbito do aquartelamento, com prejuízo do serviço e da instrução, exclusivamente para atender às hipóteses de conversão de infração penal em disciplinar.$ALT21_2$, true),
(21, 3, $ALT21_3$A prisão administrativa pode ser empregada como modalidade ordinária de detenção, sem vinculação à conversão de infração penal em disciplinar.$ALT21_3$, false),
(21, 4, $ALT21_4$Na detenção, o punido permanece em liberdade plena, sem obrigação de se apresentar em local determinado.$ALT21_4$, false),
(21, 5, $ALT21_5$A detenção e a prisão administrativa possuem idêntico regime: ambas exigem confinamento do punido e preservam integralmente o serviço e a instrução.$ALT21_5$, false),
(22, 1, $ALT22_1$A comunicação verbal dispensa confirmação escrita, desde que realizada perante o superior imediato.$ALT22_1$, false),
(22, 2, $ALT22_2$A comunicação deve ser feita exclusivamente por escrito, não sendo admitida a forma verbal.$ALT22_2$, false),
(22, 3, $ALT22_3$A comunicação verbal deve ser confirmada por escrito no prazo de até dois dias úteis.$ALT22_3$, true),
(22, 4, $ALT22_4$A confirmação escrita da comunicação verbal deve ocorrer no primeiro dia útil subsequente.$ALT22_4$, false),
(22, 5, $ALT22_5$A comunicação pode ser dirigida a qualquer autoridade militar, independentemente de ser superior imediato.$ALT22_5$, false),
(23, 1, $ALT23_1$A busca da verdade real permite afastar o contraditório e a ampla defesa quando houver urgência na apuração.$ALT23_1$, false),
(23, 2, $ALT23_2$A simplicidade e a informalidade autorizam a autoridade a deixar de assegurar o devido processo ao imputado.$ALT23_2$, false),
(23, 3, $ALT23_3$A competência para instaurar, conduzir e julgar o processo pertence a qualquer superior hierárquico da unidade.$ALT23_3$, false),
(23, 4, $ALT23_4$O processo deve assegurar ao imputado ampla defesa e contraditório, orientar-se, entre outros, pela celeridade e pela busca da verdade real, e ser instaurado, conduzido e julgado por autoridade competente para aplicar sanção administrativa.$ALT23_4$, true),
(23, 5, $ALT23_5$A economia procedimental impõe que o processo seja encerrado tão logo exista indício de autoria, ainda que não tenha sido oportunizada defesa ao imputado.$ALT23_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 8, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid),
(9, 14, '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid),
(15, 19, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid),
(20, 23, '454f8501-7818-4dc4-b22a-337247678c58'::uuid);

-- ================= PRECONDICOES =================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
  r record;
begin
  for r in select unidade_pedagogica_id, ordem_min, ordem_max from _unidades_ordem loop
    select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
    into v_unidade_ok
    from public.unidades_pedagogicas up
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where up.id = r.unidade_pedagogica_id;
    if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade % nao esta ativa/relevante conforme esperado', r.unidade_pedagogica_id; end if;

    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
           count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
      into v_real, v_autoral
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(*) into v_gap
    from (
      select distinct q.id from public.questoes q
      join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa
      and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
    ) g;
    if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes na unidade %=% esperado 0', r.unidade_pedagogica_id, v_gap; end if;

    raise notice 'PRECOND unidade % OK: uteis=% real=% autoral=% gap=%', r.unidade_pedagogica_id, v_uteis, v_real, v_autoral, v_gap;
  end loop;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Sobre a relação da Brigada Militar com a organização estadual de segurança pública, assinale a alternativa correta.$DUP1$),
  lower($DUP2$No contexto da organização institucional da Brigada Militar, a expressão “competências da instituição” refere-se, corretamente, ao conjunto de$DUP2$),
  lower($DUP3$A estrutura organizacional da Brigada Militar é composta por três níveis. Assinale a alternativa que apresenta corretamente essa composição.$DUP3$),
  lower($DUP4$Considerando a organização da Brigada Militar, assinale a alternativa que caracteriza corretamente a expressão Órgão de Polícia Militar (OPM).$DUP4$),
  lower($DUP5$Assinale a alternativa que apresenta corretamente a competência do Chefe do Estado-Maior da Brigada Militar.$DUP5$),
  lower($DUP6$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa correta acerca do Estado-Maior da Brigada Militar.$DUP6$),
  lower($DUP7$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa que apresenta corretamente atribuições do Subcomandante-Geral da Brigada Militar.$DUP7$),
  lower($DUP8$A respeito do Conselho Superior da Brigada Militar, conforme a Lei Complementar nº 16.450/2025, assinale a alternativa correta.$DUP8$),
  lower($DUP9$No âmbito da carreira dos Servidores Militares Estaduais de Nível Superior, assinale a alternativa que apresenta corretamente os quadros que compõem sua estrutura.$DUP9$),
  lower($DUP10$Considerando a inclusão no quadro de acesso destinado à promoção ao posto de Coronel, assinale a alternativa correta.$DUP10$),
  lower($DUP11$Para ingressar no Curso Superior de Polícia Militar, exige-se que o candidato seja aprovado em concurso público e possua qual formação?$DUP11$),
  lower($DUP12$Em relação à situação dos candidatos aprovados no concurso para ingresso no quadro de oficiais, assinale a alternativa correta quanto à denominação recebida durante a frequência do Curso Superior de Polícia Militar e à duração máxima desse curso.$DUP12$),
  lower($DUP13$No contexto das regras de promoção da carreira, assinale a situação em que um Capitão preenche, simultaneamente, as condições específicas exigidas para a promoção ao posto de Major.$DUP13$),
  lower($DUP14$Para que um Tenente-Coronel tenha acesso à promoção ao posto de Coronel, qual condição relativa à formação deve estar cumprida?$DUP14$),
  lower($DUP15$Assinale a alternativa que apresenta corretamente, de forma conjunta, as características do serviço policial-militar e da carreira de servidor militar.$DUP15$),
  lower($DUP16$Considerando as regras sobre os Oficiais nomeados Juízes do Tribunal Militar do Estado e sobre a precedência entre servidores militares, assinale a alternativa correta.$DUP16$),
  lower($DUP17$A respeito das consequências decorrentes da violação de obrigações e deveres policiais-militares, assinale a alternativa correta.$DUP17$),
  lower($DUP18$No rol de direitos dos servidores militares estaduais, assinale a alternativa que apresenta corretamente os direitos relacionados à inatividade e aos períodos de afastamento regular.$DUP18$),
  lower($DUP19$Quanto aos direitos assistenciais dos servidores militares estaduais, assinale a alternativa correta.$DUP19$),
  lower($DUP20$No tocante às sanções disciplinares e às respectivas formas de aplicação, assinale a alternativa correta.$DUP20$),
  lower($DUP21$Considerando as características da detenção e da prisão administrativa, assinale a alternativa correta.$DUP21$),
  lower($DUP22$Um militar estadual tomou conhecimento de fato contrário à disciplina e optou por comunicá-lo verbalmente ao seu superior imediato. Nessa situação, assinale a alternativa correta quanto à formalização da comunicação.$DUP22$),
  lower($DUP23$Em relação ao processo administrativo disciplinar militar, assinale a alternativa correta.$DUP23$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 23';
end $$;

-- ================= INSERT das 23 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_uid uuid;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    select unidade_pedagogica_id into v_uid from _unidades_ordem where r.ordem between ordem_min and ordem_max;

    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE07_LEGISLACAO_INSTITUCIONAL - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = (select curso_conteudo_id from _lote_questoes where ordem = r.ordem)
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id, unidade_pedagogica_id) values (r.ordem, v_novo_id, v_uid);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;
  end loop;
end $$;

-- ================= VINCULO via RPC sancionada =================
do $$
declare
  r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_snap record;
  v_uteis int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes - v_snap.total_questoes <> 23 then raise exception 'POSCOND: questoes criadas=% esperado 23', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 115 then raise exception 'POSCOND: alternativas criadas=% esperado 115', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 23 then raise exception 'POSCOND: vinculos criados=% esperado 23', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 23 then raise exception 'POSCOND: curso_questoes criadas=% esperado 23', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Lei de Organização Básica da Brigada Militar=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '3c033d9a-5543-422a-a935-c55095bdfc86';
  if v_gabaritos <> 'CAAAAABB' then raise exception 'POSCOND: gabaritos unidade Lei de Organização Básica da Brigada Militar=% esperado CAAAAABB', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Plano de Carreira dos Servidores Militares=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200';
  if v_gabaritos <> 'ABCBAA' then raise exception 'POSCOND: gabaritos unidade Plano de Carreira dos Servidores Militares=% esperado ABCBAA', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='bf13f365-3dd9-4d22-9ad7-f369a298eb19' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Estatuto dos Militares Estaduais=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'bf13f365-3dd9-4d22-9ad7-f369a298eb19';
  if v_gabaritos <> 'BBCAA' then raise exception 'POSCOND: gabaritos unidade Estatuto dos Militares Estaduais=% esperado BBCAA', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='454f8501-7818-4dc4-b22a-337247678c58' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Regulamento Disciplinar da Brigada Militar=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '454f8501-7818-4dc4-b22a-337247678c58';
  if v_gabaritos <> 'ABCD' then raise exception 'POSCOND: gabaritos unidade Regulamento Disciplinar da Brigada Militar=% esperado ABCD', v_gabaritos; end if;

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  if v_vinc_ok <> 23 then raise exception 'POSCOND: %/23 vinculos corretos (unidade unica) confirmados', v_vinc_ok; end if;

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 23 then raise exception 'POSCOND: %/23 curso_questoes novas confirmadas', v_cq_ok; end if;

  raise notice 'POSCONDICOES OK: +23 questoes, +115 alternativas, +23 vinculos, +23 curso_questoes; 4 unidades com gabaritos e contagens confirmadas';
end $$;

commit;
