-- TESTE DE ROLLBACK REAL da IMPORTACAO LEG-AUT-HIERARQUIA-01. Executa,
-- dentro de UMA transacao controlada que termina em ROLLBACK externo, a
-- sequencia completa:
--   OLD (baseline) -> APPLY (mesma logica do apply real) -> TARGET (verifica)
--   -> REVERSAO REAL (mesma logica do reverter real) -> OLD_FINAL (verifica)
-- Nenhuma linha e alterada permanentemente — tudo e desfeito por ROLLBACK.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key, codigo text, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;
insert into _lote_questoes (ordem, codigo, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, $COD1$leg-aut-hierarquia-01-01$COD1$, 52, 'facil', $FONTE1$PAPIRO — LEG-AUT-HIERARQUIA-01 — 01 — Base institucional (Art.12 caput)$FONTE1$, $ENUN1$A Lei Complementar Estadual RS nº 10.990/1997 dispõe sobre o Estatuto dos Militares Estaduais da Brigada Militar. Um Soldado recém-incorporado observa que, na rotina de sua unidade, os oficiais de posto mais elevado respondem por decisões e consequências institucionais que não recaem sobre os militares de grau hierárquico inferior. Sobre o fundamento dessa organização, à luz do art. 12, caput, da referida Lei Complementar, assinale a alternativa CORRETA.$ENUN1$),
(2, $COD2$leg-aut-hierarquia-01-02$COD2$, 52, 'media', $FONTE2$PAPIRO — LEG-AUT-HIERARQUIA-01 — 02 — Extensão da disciplina (Art.12 §3º)$FONTE2$, $ENUN2$Segundo o art. 12, §3º, da LC Estadual RS nº 10.990/1997, assinale a alternativa que reproduz corretamente a extensão da disciplina militar e do respeito à hierarquia prevista nesse dispositivo.$ENUN2$),
(3, $COD3$leg-aut-hierarquia-01-03$COD3$, 52, 'media', $FONTE3$PAPIRO — LEG-AUT-HIERARQUIA-01 — 03 — Círculos hierárquicos (Art.13)$FONTE3$, $ENUN3$Sobre os círculos hierárquicos na Brigada Militar, nos termos do art. 13 da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.$ENUN3$),
(4, $COD4$leg-aut-hierarquia-01-04$COD4$, 52, 'media', $FONTE4$PAPIRO — LEG-AUT-HIERARQUIA-01 — 04 — Precedência, regra geral (Art.15 caput)$FONTE4$, $ENUN4$Dois Capitães da Brigada Militar, ambos da ativa, possuem o mesmo grau hierárquico. Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, qual é a regra geral aplicável para fins de precedência entre eles?$ENUN4$),
(5, $COD5$leg-aut-hierarquia-01-05$COD5$, 52, 'dificil', $FONTE5$PAPIRO — LEG-AUT-HIERARQUIA-01 — 05 — Precedência funcional (Art.15 caput)$FONTE5$, $ENUN5$Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, a ressalva de precedência funcional à regra geral da antiguidade é expressamente prevista para quais funções?$ENUN5$),
(6, $COD6$leg-aut-hierarquia-01-06$COD6$, 52, 'dificil', $FONTE6$PAPIRO — LEG-AUT-HIERARQUIA-01 — 06 — Ordenação hierárquica aplicada (Art.12 §1º)$FONTE6$, $ENUN6$Em uma ocorrência policial-militar, encontram-se presentes os seguintes servidores militares da Brigada Militar, todos da ativa: Alpha, Capitão mais antigo no posto; Bravo, Capitão mais moderno no posto; Charlie, 1º Tenente; e Delta, Sargento. Considerando exclusivamente a ordenação hierárquica prevista no art. 12, §1º, da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.$ENUN6$),
(7, $COD7$leg-aut-hierarquia-01-07$COD7$, 52, 'media', $FONTE7$PAPIRO — LEG-AUT-HIERARQUIA-01 — 07 — Integração Arts.12/13$FONTE7$, $ENUN7$Sobre a hierarquia e a disciplina na Brigada Militar, considere as assertivas abaixo, à luz da LC Estadual RS nº 10.990/1997:

I. A disciplina militar traduz-se pelo cumprimento do dever por parte de todos e de cada um dos componentes da corporação.

II. Os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.

III. A disciplina militar e o respeito à hierarquia devem ser mantidos exclusivamente entre os militares da ativa.

Está(ão) correta(s):$ENUN7$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz o art. 12, caput, da LC Estadual RS nº 10.990/1997: a hierarquia e a disciplina militares constituem a base institucional da Brigada Militar, e a autoridade e a responsabilidade crescem com o grau hierárquico.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A hierarquia e a disciplina militares não são princípios facultativos: o art. 12, caput, as estabelece como base institucional da corporação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 12, caput, atribui a condição de base institucional tanto à hierarquia quanto à disciplina, e não apenas a esta última.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O dispositivo estabelece o sentido inverso: a autoridade e a responsabilidade crescem, e não decrescem, com o grau hierárquico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A hierarquia militar está associada ao posto ou à graduação ocupados pelo militar, e não ao tempo de serviço público.

BIZU DE PROVA:
Art. 12, caput, da LC 10.990/97: HIERARQUIA e DISCIPLINA = base institucional da Brigada Militar. Autoridade e responsabilidade CRESCEM com o grau hierárquico!$EXPL1$),
(2, $EXPL2$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Reproduz o art. 12, §3º, da LC Estadual RS nº 10.990/1997: a disciplina militar e o respeito à hierarquia devem ser mantidos entre os servidores militares da ativa, da reserva remunerada e reformados.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O §3º estende expressamente essa exigência também aos da reserva remunerada e aos reformados, não a restringindo aos da ativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os reformados também estão expressamente incluídos pelo §3º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dispositivo não condiciona essa exigência ao exercício de cargo de comando.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O §3º inclui expressamente os militares da reserva remunerada, não os dispensando dessa exigência.

BIZU DE PROVA:
Art. 12, §3º, da LC 10.990/97: disciplina e respeito à hierarquia valem para ATIVA + RESERVA REMUNERADA + REFORMADOS — não só para quem está na ativa!$EXPL2$),
(3, $EXPL3$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Reproduz o art. 13 da LC Estadual RS nº 10.990/1997: os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O dispositivo trata da convivência entre militares da mesma categoria, e não de categorias distintas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Corresponde a um conteúdo diverso, relativo à organização da escala de postos e graduações da corporação, e não ao âmbito de convivência disciplinado pelo art. 13.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os círculos hierárquicos não substituem a ordenação por postos e graduações; tratam-se de institutos distintos, previstos em dispositivos diferentes.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O próprio art. 13 ressalva expressamente que os círculos hierárquicos não prejudicam o respeito mútuo entre seus integrantes.

BIZU DE PROVA:
Art. 13 da LC 10.990/97: círculos hierárquicos = convivência entre a MESMA categoria + camaradagem + estima e confiança, SEM prejuízo do respeito mútuo!$EXPL3$),
(4, $EXPL4$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Reproduz a regra geral do art. 15, caput, da LC Estadual RS nº 10.990/1997: a precedência entre militares da ativa do mesmo grau hierárquico é assegurada pela antiguidade no posto ou na graduação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A idade civil não é o critério de precedência previsto no art. 15, caput.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A nota do curso de formação não é o critério previsto no art. 15, caput.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O tempo de contribuição previdenciária não é o critério previsto no art. 15, caput.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Há critério legal expresso — a antiguidade no posto ou na graduação —, não havendo lacuna a ser suprida por sorteio.

BIZU DE PROVA:
Art. 15, caput, da LC 10.990/97: precedência entre militares da ativa do MESMO GRAU = ANTIGUIDADE no posto ou na graduação.$EXPL4$),
(5, $EXPL5$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 15, caput, prevê expressamente a ressalva de precedência funcional para três funções: o Comandante-Geral, o Subcomandante-Geral e o Chefe do Estado-Maior — são as três funções expressamente mencionadas no dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Está incompleta: o dispositivo também menciona o Chefe do Estado-Maior.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Corregedor-Geral não é uma das três funções mencionadas no art. 15, caput.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A ressalva não abrange genericamente todos os Oficiais Superiores; alcança especificamente as três funções mencionadas no dispositivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Está incompleta: o dispositivo também menciona o Comandante-Geral.

BIZU DE PROVA:
Art. 15, caput, da LC 10.990/97 — exceção à antiguidade: as três funções expressamente mencionadas são Comandante-Geral, Subcomandante-Geral e Chefe do Estado-Maior.$EXPL5$),
(6, $EXPL6$GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Nos termos do art. 12, §1º, da LC Estadual RS nº 10.990/1997, a ordenação hierárquica se dá por postos ou graduações e, dentro de um mesmo posto ou graduação, pela antiguidade nesse posto ou graduação. Como Alpha e Bravo ocupam o mesmo posto (Capitão), a antiguidade no posto é o critério aplicável, e Alpha, por ser mais antigo, antecede Bravo nessa ordenação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A ordenação entre postos e graduações distintos, como entre Charlie e Delta, é regida pelo art. 12, §1º (hierarquia por postos e graduações), e não pelo art. 13 (círculos hierárquicos), dispositivo diverso que trata do âmbito de convivência entre militares da mesma categoria.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O critério primário de ordenação é o posto ou a graduação; a antiguidade é aplicada apenas como critério dentro de um mesmo posto ou graduação, não isoladamente entre postos ou graduações distintos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A lei prevê expressamente o critério de antiguidade no posto para a ordenação entre militares do mesmo posto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 12, §1º, não adota o tempo total de serviço público como critério de ordenação dentro do mesmo posto ou graduação; o critério é a antiguidade naquele posto ou graduação especificamente.

BIZU DE PROVA:
Art. 12, §1º, da LC 10.990/97 — ordenação hierárquica: 1º por POSTO/GRADUAÇÃO; dentro do MESMO posto/graduação, por ANTIGUIDADE nesse posto/graduação!$EXPL6$),
(7, $EXPL7$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A assertiva I reproduz o art. 12, §2º: a disciplina militar traduz-se pelo cumprimento do dever por parte de todos e de cada um dos componentes da corporação. A assertiva II reproduz o art. 13: os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, com espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo. A assertiva III é incorreta, pois o art. 12, §3º, estende a disciplina militar e o respeito à hierarquia também aos militares da reserva remunerada e aos reformados, não apenas aos da ativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está incorreta, e a assertiva II também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva I também está correta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Disciplina (art. 12, §2º) = cumprimento do dever de todos. Círculos hierárquicos (art. 13) = mesma categoria + camaradagem + respeito mútuo. Extensão da disciplina/hierarquia (art. 12, §3º) = ativa + reserva remunerada + reformados — nunca só a ativa!$EXPL7$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;
insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_0$A hierarquia e a disciplina militares são princípios facultativos, aplicáveis apenas quando previstos em regulamento interno de cada unidade.$ALT1_0$, false),
(1, 2, $ALT1_1$Somente a disciplina militar constitui a base institucional da Brigada Militar, cabendo à hierarquia um papel meramente protocolar.$ALT1_1$, false),
(1, 3, $ALT1_2$A autoridade e a responsabilidade decrescem com o grau hierárquico, cabendo aos militares de grau hierárquico mais baixo a maior parcela de responsabilidade institucional.$ALT1_2$, false),
(1, 4, $ALT1_3$A hierarquia militar decorre exclusivamente do tempo de serviço público do militar, sendo irrelevante o posto ou a graduação ocupados.$ALT1_3$, false),
(1, 5, $ALT1_4$A hierarquia e a disciplina militares constituem a base institucional da Brigada Militar, e a autoridade e a responsabilidade crescem com o grau hierárquico.$ALT1_4$, true),
(2, 1, $ALT2_0$Devem ser mantidos exclusivamente entre os militares da ativa, não se estendendo aos da reserva remunerada nem aos reformados.$ALT2_0$, false),
(2, 2, $ALT2_1$Devem ser mantidos entre os militares da ativa e da reserva remunerada, excluídos os reformados.$ALT2_1$, false),
(2, 3, $ALT2_2$Devem ser mantidos entre os servidores militares da ativa, da reserva remunerada e reformados.$ALT2_2$, true),
(2, 4, $ALT2_3$Aplicam-se apenas aos militares em atividade que ocupem cargo de comando.$ALT2_3$, false),
(2, 5, $ALT2_4$São dispensados para os militares da reserva remunerada, por não integrarem mais o efetivo operacional da corporação.$ALT2_4$, false),
(3, 1, $ALT3_0$Círculos hierárquicos são âmbitos de convivência entre militares de categorias distintas, destinados a aproximar oficiais e praças em atividades de caráter operacional.$ALT3_0$, false),
(3, 2, $ALT3_1$Círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.$ALT3_1$, true),
(3, 3, $ALT3_2$Círculos hierárquicos correspondem à tabela de postos e graduações que compõe a escala hierárquica da corporação.$ALT3_2$, false),
(3, 4, $ALT3_3$Círculos hierárquicos substituem, para todos os efeitos, a ordenação por postos e graduações prevista no art. 12, §1º.$ALT3_3$, false),
(3, 5, $ALT3_4$Círculos hierárquicos são incompatíveis com o respeito mútuo entre seus integrantes, por pressuporem hierarquia rígida entre os presentes.$ALT3_4$, false),
(4, 1, $ALT4_0$A precedência é assegurada pela antiguidade no posto ou na graduação.$ALT4_0$, true),
(4, 2, $ALT4_1$A precedência é definida pela idade civil de cada um, prevalecendo o mais velho.$ALT4_1$, false),
(4, 3, $ALT4_2$A precedência é definida pela nota obtida no curso de formação de oficiais, prevalecendo o de melhor classificação.$ALT4_2$, false),
(4, 4, $ALT4_3$A precedência é definida pelo tempo de contribuição previdenciária de cada militar.$ALT4_3$, false),
(4, 5, $ALT4_4$A precedência é definida por sorteio realizado pelo comando da unidade, na ausência de critério legal expresso.$ALT4_4$, false),
(5, 1, $ALT5_0$Comandante-Geral e Subcomandante-Geral, apenas.$ALT5_0$, false),
(5, 2, $ALT5_1$Comandante-Geral, Subcomandante-Geral e o Corregedor-Geral da corporação.$ALT5_1$, false),
(5, 3, $ALT5_2$Comandante-Geral, Subcomandante-Geral e Chefe do Estado-Maior.$ALT5_2$, true),
(5, 4, $ALT5_3$Todos os Oficiais Superiores da corporação, independentemente da função exercida.$ALT5_3$, false),
(5, 5, $ALT5_4$Subcomandante-Geral e Chefe do Estado-Maior, apenas.$ALT5_4$, false),
(6, 1, $ALT6_0$Entre Charlie (1º Tenente) e Delta (Sargento), a ordenação hierárquica é indiferente, pois ambos pertencem ao mesmo círculo de convivência previsto no art. 13.$ALT6_0$, false),
(6, 2, $ALT6_1$A ordenação entre postos e graduações distintos, como entre Charlie (1º Tenente) e Delta (Sargento), é irrelevante para fins do art. 12, §1º, prevalecendo sempre o critério de antiguidade isoladamente.$ALT6_1$, false),
(6, 3, $ALT6_2$Entre Alpha e Bravo, ambos Capitães, a ordenação é indiferente, pois a lei não prevê critério de desempate entre militares do mesmo posto.$ALT6_2$, false),
(6, 4, $ALT6_3$Entre Alpha e Bravo, ambos Capitães, a ordenação dentro do mesmo posto se faz pela antiguidade, razão pela qual Alpha, mais antigo no posto, antecede Bravo nessa ordenação.$ALT6_3$, true),
(6, 5, $ALT6_4$Entre militares do mesmo posto ou graduação, a ordenação é definida pelo tempo total de serviço público, independentemente da antiguidade naquele posto ou graduação.$ALT6_4$, false),
(7, 1, $ALT7_0$Apenas a assertiva I.$ALT7_0$, false),
(7, 2, $ALT7_1$Apenas as assertivas I e III.$ALT7_1$, false),
(7, 3, $ALT7_2$Apenas as assertivas I e II.$ALT7_2$, true),
(7, 4, $ALT7_3$Apenas as assertivas II e III.$ALT7_3$, false),
(7, 5, $ALT7_4$As assertivas I, II e III.$ALT7_4$, false);

-- ===================== FASE OLD =====================
do $$
declare
  v_unidade_ok boolean; v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
begin
  select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
  into v_unidade_ok
  from public.unidades_pedagogicas up
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where up.id = 'cbde0aeb-3df8-4c41-a82f-91b83b529668';
  insert into _relatorio values ('OLD','unidade_ok', coalesce(v_unidade_ok,false), 'ativa+relevante');

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_3', v_uteis = 3, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','real_1', v_real = 1, v_real::text);
  insert into _relatorio values ('OLD','autoral_2', v_autoral = 2, v_autoral::text);

  select count(*) into v_gap
  from (
    select distinct q.id from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa
    and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
  ) g;
  insert into _relatorio values ('OLD','gap_0', v_gap = 0, v_gap::text);

  select count(*) into v_dup from public.questoes q where q.ativa = true and lower(q.enunciado) in (
    lower('A Lei Complementar Estadual RS nº 10.990/1997 dispõe sobre o Estatuto dos Militares Estaduais da Brigada Militar. Um Soldado recém-incorporado observa que, na rotina de sua unidade, os oficiais de posto mais elevado respondem por decisões e consequências institucionais que não recaem sobre os militares de grau hierárquico inferior. Sobre o fundamento dessa organização, à luz do art. 12, caput, da referida Lei Complementar, assinale a alternativa CORRETA.'),
    lower('Segundo o art. 12, §3º, da LC Estadual RS nº 10.990/1997, assinale a alternativa que reproduz corretamente a extensão da disciplina militar e do respeito à hierarquia prevista nesse dispositivo.'),
    lower('Sobre os círculos hierárquicos na Brigada Militar, nos termos do art. 13 da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.'),
    lower('Dois Capitães da Brigada Militar, ambos da ativa, possuem o mesmo grau hierárquico. Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, qual é a regra geral aplicável para fins de precedência entre eles?'),
    lower('Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, a ressalva de precedência funcional à regra geral da antiguidade é expressamente prevista para quais funções?'),
    lower('Em uma ocorrência policial-militar, encontram-se presentes os seguintes servidores militares da Brigada Militar, todos da ativa: Alpha, Capitão mais antigo no posto; Bravo, Capitão mais moderno no posto; Charlie, 1º Tenente; e Delta, Sargento. Considerando exclusivamente a ordenação hierárquica prevista no art. 12, §1º, da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.'),
    lower('Sobre a hierarquia e a disciplina na Brigada Militar, considere as assertivas abaixo, à luz da LC Estadual RS nº 10.990/1997:

I. A disciplina militar traduz-se pelo cumprimento do dever por parte de todos e de cada um dos componentes da corporação.

II. Os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.

III. A disciplina militar e o respeito à hierarquia devem ser mantidos exclusivamente entre os militares da ativa.

Está(ão) correta(s):')
  );
  insert into _relatorio values ('OLD','sem_duplicidade', v_dup = 0, v_dup::text);
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_count int := 0;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LEG-AUT-HIERARQUIA-01 - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = 52
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_novo_id);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;

    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY','questoes_criadas_7', v_count = 7, v_count::text);
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY','vinculos_criados_7', v_count = 7, v_count::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_uteis int; v_real int; v_autoral int;
  v_gabaritos text; v_dificuldades text;
  v_vinc_ok int; v_cq_ok int;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('TARGET','questoes_delta_7', v_questoes - v_snap.total_questoes = 7, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET','alternativas_delta_35', v_alternativas - v_snap.total_alternativas = 35, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET','vinculos_delta_7', v_vinculos - v_snap.total_vinculos = 7, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET','curso_questoes_delta_7', v_curso_questoes - v_snap.total_curso_questoes = 7, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_10', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','real_1', v_real = 1, v_real::text);
  insert into _relatorio values ('TARGET','autoral_9', v_autoral = 9, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem) into v_gabaritos from _mapa_ids m;
  insert into _relatorio values ('TARGET','gabaritos', v_gabaritos = 'ECBACDC', v_gabaritos);

  select string_agg((select dificuldade from public.questoes where id=m.questao_id), ',' order by m.ordem) into v_dificuldades from _mapa_ids m;
  insert into _relatorio values ('TARGET','dificuldades', v_dificuldades = 'facil,media,media,media,dificil,dificil,media', v_dificuldades);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668')
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> 'cbde0aeb-3df8-4c41-a82f-91b83b529668');
  insert into _relatorio values ('TARGET','vinculos_7_na_unidade_correta_apenas', v_vinc_ok = 7, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET','curso_questoes_7', v_cq_ok = 7, v_cq_ok::text);

  insert into _relatorio values ('TARGET','ativa_7de7',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 7, 'ativa');
  insert into _relatorio values ('TARGET','origem_papiro_7de7',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 7, 'banca papiro');
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'TESTE ABORTADO: guard pre-reversao falhou (uteis=%), nao reverter as cegas', v_uteis; end if;
  insert into _relatorio values ('REVERSAO_GUARD','uteis_10_antes_de_reverter', v_uteis = 10, v_uteis::text);
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id from _mapa_ids order by ordem loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('REVERSAO','vinculos_removidos_7', v_count = 7, v_count::text);
end $$;

do $$
declare
  v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','curso_questoes_removidas_7', v_count = 7, v_count::text);
end $$;

do $$
declare
  v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','alternativas_removidas_35', v_count = 35, v_count::text);
end $$;

do $$
declare
  v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','questoes_removidas_7', v_count = 7, v_count::text);
end $$;

-- ===================== FASE OLD_FINAL (pos-reversao) =====================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_uteis int; v_real int; v_autoral int;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('OLD_FINAL','questoes_restauradas', v_questoes = v_snap.total_questoes, v_questoes::text);
  insert into _relatorio values ('OLD_FINAL','alternativas_restauradas', v_alternativas = v_snap.total_alternativas, v_alternativas::text);
  insert into _relatorio values ('OLD_FINAL','vinculos_restaurados', v_vinculos = v_snap.total_vinculos, v_vinculos::text);
  insert into _relatorio values ('OLD_FINAL','curso_questoes_restauradas', v_curso_questoes = v_snap.total_curso_questoes, v_curso_questoes::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_3', v_uteis = 3, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','real_1', v_real = 1, v_real::text);
  insert into _relatorio values ('OLD_FINAL','autoral_2', v_autoral = 2, v_autoral::text);
end $$;

-- ===================== RESUMO =====================
select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare
  v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LEG_AUT_HIERARQUIA_01_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
