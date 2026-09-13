-- TESTE DE ROLLBACK — IMPORTACAO LOTE09B_LEGISLACAO_ESPECIFICA (NAO aplica nada
-- permanente — termina em ROLLBACK; ver importar_lote09b_legislacao_especifica.sql
-- para o apply real) — 7 questoes autorais para 2
-- unidades de Legislacao Especifica (curso Brigada Militar RS): Poderes da
-- Administracao Publica (+2), Jurisprudencia do STF e STJ (+5).
--
-- Human review final (mandato "PAPIRO — LOTE 09B — HUMAN REVIEW FINAL —
-- CORRECAO ADPF347 + FREEZE 7 + IMPORTACAO FINAL + COVERAGE BMRS ZERO +
-- COMMIT/PUSH"). 7 SELECTED. 6 APPROVED_RESERVE (nao importadas, permanecem
-- so como metadata do review packet). 1 REJECTED_PRE_AUDIT (candidata
-- original defeituosa da Sumula 145, MALFORMED_TEXT_LITERAL_ESCAPE_SEQUENCE,
-- preservada intocada no audit trail, nao importada).
--
-- Correcao humana obrigatoria aplicada antes do freeze:
-- JURIS-ADPF347: alternativas A e B, explicacao e fundamento.descricao
-- reescritos para remover a atribuicao direta, a propria ADPF 347, da
-- extensao "audiencia de custodia a qualquer modalidade de prisao" — essa
-- extensao foi desenvolvida posteriormente na Rcl 29.303, com fundamento
-- adicional na legislacao processual penal. A questao agora preserva
-- apenas o que a ADPF 347 sustenta diretamente: apresentacao da pessoa
-- presa a autoridade judicial em ate 24 horas. Gabarito B mantido.
-- HUMAN_EDIT_APPLIED_ADPF347_SCOPE_PRECISION.
--
-- Padrao identico aos lotes precedentes: staging de questoes/explicacoes/
-- alternativas, insercao por INSERT direto em questoes/alternativas (nunca
-- em questao_unidades_pedagogicas), vinculo exclusivamente via
-- classificar_questao_unidade_admin (RPC que sincroniza curso_questoes
-- automaticamente).
--
-- NAO altera nenhuma questao existente nas 2 unidades.
-- NAO altera unidades/conteudos/materias/aulas/escopo pedagogico (o scope
-- update da unidade Jurisprudencia ja foi aplicado e verificado em rodada
-- anterior deste mesmo lote — NAO reaplicado aqui). NAO cria migration/schema.
--
-- Texto final persistido em
-- outputs/curadoria-autoral/review/LOTE09B-FINAL-HUMAN-REVIEW-V2.md,
-- congelado em outputs/curadoria-autoral/review/LOTE09B-FROZEN-7.json
-- (corpus_hash ec0e8525df3bd838d05a50d92ca39cdda16f8a90fade609d92da0ffeb1667469).
--
-- ROLLBACK-TESTADO em importar_lote09b_legislacao_especifica_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_lote09b_legislacao_especifica.sql

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
(1, 59, $D1$media$D1$, $FONTE1$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — PODERES-NORM-02$FONTE1$, $ENUN1$Após a aprovação de um projeto de lei pelo Congresso Nacional, o Presidente da República pratica o ato de sancioná-lo, promulgá-lo e determinar sua publicação. Posteriormente, para viabilizar a execução fiel dessa lei, expede decreto com disposições operacionais compatíveis com seu conteúdo. À luz do art. 84, IV, da Constituição Federal, os dois atos correspondem, respectivamente, a:$ENUN1$),
(2, 59, $D2$media$D2$, $FONTE2$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — PODERES-ENAP-02$FONTE2$, $ENUN2$Considere as situações a seguir:

I. A chefia de uma coordenadoria acompanhou a execução de atividades por órgão subordinado e, diante de falhas verificadas, chamou para si a análise de procedimento que estava em curso naquele órgão.

II. A Administração instaurou procedimento para apurar conduta funcional incompatível com os deveres do cargo e, assegurada a apuração cabível, aplicou sanção ao servidor responsável.

A classificação correta dos poderes que fundamentam as situações I e II é, respectivamente,$ENUN2$),
(3, 69, $D3$media$D3$, $FONTE3$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — JURIS-ADPF635-B$FONTE3$, $ENUN3$No julgamento da ADPF 635/RJ, conhecido como “ADPF das Favelas”, o STF examinou medidas voltadas à redução da letalidade policial no Estado do Rio de Janeiro. Considerando os limites e o alcance da decisão, assinale a alternativa correta.$ENUN3$),
(4, 69, $D4$media$D4$, $FONTE4$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — JURIS-ADPF347$FONTE4$, $ENUN4$À luz do entendimento firmado pelo STF na ADPF 347/DF sobre audiência de custódia, assinale a alternativa correta.$ENUN4$),
(5, 69, $D5$media$D5$, $FONTE5$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — JURIS-TEMA998-A$FONTE5$, $ENUN5$Em um estabelecimento prisional, a direção determina que todos os visitantes, indistintamente, sejam submetidos a desnudamento e a procedimentos corporais invasivos antes do ingresso, embora existam meios tecnológicos e outras formas menos invasivas de vistoria. À luz da tese final firmada pelo STF no Tema 998 da repercussão geral, assinale a alternativa correta.$ENUN5$),
(6, 69, $D6$media$D6$, $FONTE6$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — JURIS-SUMULA145-NEW-B$FONTE6$, $ENUN6$Considere as situações a seguir.

I. Policiais persuadem Renata a oferecer uma caixa supostamente contendo mercadorias ilícitas a um comprador indicado pelos próprios agentes. A caixa, contudo, fora previamente esvaziada e mantida sob integral controle policial, de modo que a entrega do objeto era inviável.

II. Após receberem informação de que Otávio, por iniciativa própria, realizaria uma venda ilícita em determinado local, policiais apenas passam a observar o ponto, sem qualquer contato ou estímulo ao suspeito, e efetuam a prisão quando ele inicia a entrega do objeto ao comprador.

Conforme a Súmula 145 do STF, assinale a alternativa correta.$ENUN6$),
(7, 69, $D7$media$D7$, $FONTE7$PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — JURIS-HC653515-B$FONTE7$, $ENUN7$Em processo criminal, a defesa sustenta que determinada prova deve ser automaticamente desconsiderada porque houve falhas na documentação de sua cadeia de custódia. À luz do entendimento exposto pela Sexta Turma do STJ no HC 653.515/RJ, assinale a alternativa correta.$ENUN7$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$A alternativa B está correta. O primeiro ato — sancionar, promulgar e fazer publicar a lei — integra a primeira parte do art. 84, IV, e relaciona-se à fase final do processo legislativo. O segundo ato — expedir decreto para a fiel execução da lei — decorre da segunda parte do mesmo inciso e expressa o poder regulamentar. A alternativa C inverte as classificações. As alternativas A, D e E atribuem aos atos poderes ou efeitos que não correspondem às competências descritas no caso.

FUNDAMENTO: Constituição da República Federativa do Brasil de 1988, art. 84, IV. — O dispositivo prevê, no mesmo inciso, a competência privativa do Presidente da República para sancionar, promulgar e fazer publicar as leis, bem como para expedir decretos e regulamentos para sua fiel execução.$EXPL1$),
(2, $EXPL2$Na situação I, a fiscalização da atuação de órgão subordinado e o chamamento do procedimento para análise pela chefia inserem-se na relação de subordinação administrativa, própria do poder hierárquico. Na situação II, a apuração de falta funcional e a aplicação de sanção ao servidor constituem manifestação do poder disciplinar. A alternativa A inverte as classificações; C e D atribuem indevidamente um único poder às duas situações; e E menciona poder regulamentar, que se relaciona à expedição de decretos e regulamentos para a fiel execução da lei, hipótese não descrita no caso.

FUNDAMENTO: Escola Nacional de Administração Pública (ENAP), material didático sobre Poderes da Administração Pública, item 4.2. — O item 4.2 do material pedagógico institucional da ENAP apresenta a distinção entre o poder hierárquico, incidente sobre relações internas de subordinação, fiscalização e coordenação, e o poder disciplinar, empregado na apuração de infrações e na imposição de sanções administrativas.$EXPL2$),
(3, $EXPL3$A alternativa B está correta. No julgamento da ADPF 635/RJ, o STF fixou determinações voltadas ao planejamento, ao controle e à redução da letalidade policial nas operações realizadas no Estado do Rio de Janeiro. A decisão não equivale a uma vedação absoluta e permanente de operações policiais. Por isso, a alternativa A é excessiva. Também não houve exigência de autorização judicial prévia para cada operação, como afirma a alternativa C, nem declaração de ilicitude automática de todo emprego de arma de fogo, como sugere a alternativa D. A alternativa E erra ao reduzir o conteúdo decisório a mera recomendação voluntária, pois o julgamento conteve determinações judiciais concretas.

FUNDAMENTO: STF, Tribunal Pleno, ADPF 635/RJ, Rel. Min. Edson Fachin, julgamento em 03/04/2025. — No julgamento da ADPF 635/RJ, o STF adotou determinações dirigidas ao Estado do Rio de Janeiro para o aperfeiçoamento de protocolos, planejamento, controle e redução da letalidade em operações policiais, sem estabelecer uma proibição geral e permanente de operações em comunidades.$EXPL3$),
(4, $EXPL4$A alternativa B está correta. Na ADPF 347/DF, o STF determinou a realização de audiência de custódia, de modo a viabilizar o comparecimento da pessoa presa à autoridade judicial em até 24 horas contadas do momento da prisão. A alternativa A erra ao admitir prazo de 72 horas mediante mera comunicação prévia ao juízo: a comunicação não substitui a apresentação da pessoa presa perante a autoridade judicial dentro do prazo determinado. A C é incorreta porque o mero envio documental não substitui a apresentação judicial do preso. A D contraria o prazo de 24 horas, e a E erra porque a realização da audiência não depende de requerimento da defesa.

FUNDAMENTO: STF, Tribunal Pleno, ADPF 347/DF. — Na ADPF 347/DF, o STF determinou a realização de audiências de custódia, de modo a viabilizar o comparecimento da pessoa presa à autoridade judicial em até 24 horas contadas do momento da prisão.$EXPL4$),
(5, $EXPL5$O Tema 998 do STF afirma a inadmissibilidade da revista íntima vexatória de visitantes em estabelecimentos prisionais. A preservação da segurança prisional não autoriza, por si só, desnudamentos ou práticas abusivas e invasivas, devendo ser privilegiados meios alternativos de vistoria que sejam menos gravosos à dignidade da pessoa. A alternativa B erra ao tratar o procedimento vexatório como medida ordinária; a C erra porque a mera invocação genérica de segurança não legitima a prática; a D extrapola a tese, que não impede toda inspeção pessoal; e a E ignora os limites constitucionais impostos à atuação administrativa.

FUNDAMENTO: STF, Tema 998 da repercussão geral, ARE 959.620/RS, tese final fixada em 14/08/2025. — É inadmissível a revista íntima vexatória de visitantes em estabelecimentos prisionais, devendo a fiscalização observar a dignidade da pessoa humana e priorizar meios alternativos de vistoria menos invasivos.$EXPL5$),
(6, $EXPL6$Na situação I, Renata foi induzida pelos policiais, que também controlaram a caixa de modo a tornar inviável a entrega. Trata-se de flagrante preparado; se a preparação policial torna impossível a consumação, incide a Súmula 145 do STF, não havendo crime. Na situação II, a polícia limitou-se a aguardar e observar fato iniciado por vontade própria de Otávio, sem provocá-lo: é flagrante esperado, que não se confunde com o preparado. A mera vigilância ou o conhecimento prévio não convertem o flagrante esperado em preparado, afastando A, B, D e E.

FUNDAMENTO: STF, Súmula 145 — Não há crime quando a preparação do flagrante pela polícia torna impossível a sua consumação. A hipótese não alcança o flagrante esperado, no qual não há provocação policial e os agentes apenas aguardam a prática delitiva.$EXPL6$),
(7, $EXPL7$No HC 653.515/RJ, a Sexta Turma do STJ ressaltou a importância da cadeia de custódia para a confiabilidade da prova e associou sua finalidade ao princípio da mesmidade: deve ser possível verificar que o elemento probatório analisado é o mesmo que foi originalmente arrecadado, sem adulteração ou substituição relevante. A inobservância de procedimentos da cadeia de custódia não produz, por si só e automaticamente, a inadmissibilidade da prova; é necessário avaliar, no caso concreto, o comprometimento de sua integridade e confiabilidade. Por isso, a alternativa A é absoluta e incorreta. A alternativa B ignora a função de garantia da cadeia de custódia. A alternativa D erra ao atribuir eficácia vinculante erga omnes a decisão de Turma em habeas corpus. A alternativa E distorce o sentido do princípio da mesmidade.

FUNDAMENTO: STJ, Sexta Turma, HC 653.515/RJ, julgamento em 23/11/2021. — A quebra da cadeia de custódia não acarreta automaticamente a inadmissibilidade da prova, devendo ser avaliado, no caso concreto, se a irregularidade comprometeu sua confiabilidade. O princípio da mesmidade orienta a verificação de que a prova produzida é a mesma originalmente colhida.$EXPL7$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$exercício do poder disciplinar e exercício do poder hierárquico.$ALT1_1$, false),
(1, 2, $ALT1_2$competência de sancionar, promulgar e fazer publicar as leis e exercício do poder regulamentar.$ALT1_2$, true),
(1, 3, $ALT1_3$exercício do poder regulamentar e competência de sancionar, promulgar e fazer publicar as leis.$ALT1_3$, false),
(1, 4, $ALT1_4$exercício do poder hierárquico e exercício do poder disciplinar.$ALT1_4$, false),
(1, 5, $ALT1_5$competência para declarar a nulidade da lei e exercício do poder disciplinar.$ALT1_5$, false),
(2, 1, $ALT2_1$disciplinar e hierárquico.$ALT2_1$, false),
(2, 2, $ALT2_2$hierárquico e disciplinar.$ALT2_2$, true),
(2, 3, $ALT2_3$hierárquico e hierárquico.$ALT2_3$, false),
(2, 4, $ALT2_4$disciplinar e disciplinar.$ALT2_4$, false),
(2, 5, $ALT2_5$regulamentar e hierárquico.$ALT2_5$, false),
(3, 1, $ALT3_1$O STF proibiu, de modo absoluto e permanente, a realização de operações policiais em comunidades do Estado do Rio de Janeiro.$ALT3_1$, false),
(3, 2, $ALT3_2$O STF estabeleceu determinações específicas dirigidas ao Estado do Rio de Janeiro, com parâmetros de planejamento, controle e redução da letalidade em operações, sem instituir uma proibição geral de toda atividade policial em comunidades.$ALT3_2$, true),
(3, 3, $ALT3_3$O STF transferiu ao Poder Judiciário a competência para autorizar previamente cada operação policial a ser realizada no Estado do Rio de Janeiro.$ALT3_3$, false),
(3, 4, $ALT3_4$A decisão declarou ilícito todo emprego de arma de fogo por agentes de segurança em operações realizadas em áreas densamente povoadas.$ALT3_4$, false),
(3, 5, $ALT3_5$A ADPF 635/RJ limitou-se a recomendar, sem impor providências concretas ao Estado do Rio de Janeiro, a adoção voluntária de políticas de segurança pública.$ALT3_5$, false),
(4, 1, $ALT4_1$A apresentação da pessoa presa à autoridade judicial pode ocorrer em até 72 horas, desde que a prisão tenha sido previamente comunicada ao juízo.$ALT4_1$, false),
(4, 2, $ALT4_2$A apresentação da pessoa presa à autoridade judicial deve ser viabilizada em até 24 horas contadas do momento da prisão.$ALT4_2$, true),
(4, 3, $ALT4_3$A audiência de custódia pode ser substituída, obrigatoriamente, pelo simples encaminhamento escrito do auto de prisão ao juízo competente.$ALT4_3$, false),
(4, 4, $ALT4_4$A apresentação judicial do preso somente é obrigatória depois de decorridas 48 horas da prisão, para possibilitar a conclusão de investigações preliminares.$ALT4_4$, false),
(4, 5, $ALT4_5$A audiência de custódia somente deve ser realizada se a defesa técnica requerer expressamente a sua designação.$ALT4_5$, false),
(5, 1, $ALT5_1$A revista íntima vexatória é inadmissível, devendo a segurança do estabelecimento priorizar meios alternativos e menos invasivos de fiscalização.$ALT5_1$, true),
(5, 2, $ALT5_2$O desnudamento de visitantes é medida ordinária legítima, desde que seja aplicado indistintamente a todos os que pretendam ingressar no estabelecimento.$ALT5_2$, false),
(5, 3, $ALT5_3$A revista íntima vexatória é admissível sempre que a administração penitenciária alegar a necessidade de prevenir o ingresso de objetos ilícitos.$ALT5_3$, false),
(5, 4, $ALT5_4$O STF vedou qualquer forma de inspeção pessoal de visitantes, inclusive aquelas não vexatórias e realizadas por meios tecnológicos.$ALT5_4$, false),
(5, 5, $ALT5_5$A escolha entre revista íntima vexatória e meios menos invasivos é ato discricionário da direção do estabelecimento, insuscetível de controle à luz da dignidade da pessoa humana.$ALT5_5$, false),
(6, 1, $ALT6_1$As situações I e II configuram flagrante preparado, pois em ambas a polícia acompanhou a conduta.$ALT6_1$, false),
(6, 2, $ALT6_2$A situação I configura flagrante esperado, e a situação II configura flagrante preparado, pois em ambas houve prévio conhecimento policial.$ALT6_2$, false),
(6, 3, $ALT6_3$A situação I configura flagrante preparado, sem crime quando a preparação policial torna impossível a consumação; a situação II configura flagrante esperado, válido por decorrer de conduta praticada sem provocação policial.$ALT6_3$, true),
(6, 4, $ALT6_4$A situação I configura tentativa punível, e a situação II não admite prisão em flagrante porque a polícia já tinha informação prévia sobre o fato.$ALT6_4$, false),
(6, 5, $ALT6_5$As situações I e II não produzem consequência penal, pois a presença policial anterior ao fato afasta o flagrante.$ALT6_5$, false),
(7, 1, $ALT7_1$Toda falha formal na cadeia de custódia gera, necessariamente e sem exame do caso concreto, a inadmissibilidade da prova.$ALT7_1$, false),
(7, 2, $ALT7_2$A cadeia de custódia é irrelevante para a valoração da prova, desde que ela tenha sido apresentada em juízo.$ALT7_2$, false),
(7, 3, $ALT7_3$A quebra da cadeia de custódia exige análise concreta de seus reflexos sobre a confiabilidade do vestígio; o princípio da mesmidade busca assegurar que a prova examinada seja a mesma que foi originalmente colhida.$ALT7_3$, true),
(7, 4, $ALT7_4$O HC 653.515/RJ constitui precedente vinculante erga omnes, equiparável a súmula vinculante, e impõe a nulidade de toda prova sem documentação integral.$ALT7_4$, false),
(7, 5, $ALT7_5$O princípio da mesmidade dispensa o registro do percurso da prova, pois se refere apenas à autoria da infração penal.$ALT7_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 2, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid),
(3, 7, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid);

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
  lower($DUP1$Após a aprovação de um projeto de lei pelo Congresso Nacional, o Presidente da República pratica o ato de sancioná-lo, promulgá-lo e determinar sua publicação. Posteriormente, para viabilizar a execução fiel dessa lei, expede decreto com disposições operacionais compatíveis com seu conteúdo. À luz do art. 84, IV, da Constituição Federal, os dois atos correspondem, respectivamente, a:$DUP1$),
  lower($DUP2$Considere as situações a seguir:

I. A chefia de uma coordenadoria acompanhou a execução de atividades por órgão subordinado e, diante de falhas verificadas, chamou para si a análise de procedimento que estava em curso naquele órgão.

II. A Administração instaurou procedimento para apurar conduta funcional incompatível com os deveres do cargo e, assegurada a apuração cabível, aplicou sanção ao servidor responsável.

A classificação correta dos poderes que fundamentam as situações I e II é, respectivamente,$DUP2$),
  lower($DUP3$No julgamento da ADPF 635/RJ, conhecido como “ADPF das Favelas”, o STF examinou medidas voltadas à redução da letalidade policial no Estado do Rio de Janeiro. Considerando os limites e o alcance da decisão, assinale a alternativa correta.$DUP3$),
  lower($DUP4$À luz do entendimento firmado pelo STF na ADPF 347/DF sobre audiência de custódia, assinale a alternativa correta.$DUP4$),
  lower($DUP5$Em um estabelecimento prisional, a direção determina que todos os visitantes, indistintamente, sejam submetidos a desnudamento e a procedimentos corporais invasivos antes do ingresso, embora existam meios tecnológicos e outras formas menos invasivas de vistoria. À luz da tese final firmada pelo STF no Tema 998 da repercussão geral, assinale a alternativa correta.$DUP5$),
  lower($DUP6$Considere as situações a seguir.

I. Policiais persuadem Renata a oferecer uma caixa supostamente contendo mercadorias ilícitas a um comprador indicado pelos próprios agentes. A caixa, contudo, fora previamente esvaziada e mantida sob integral controle policial, de modo que a entrega do objeto era inviável.

II. Após receberem informação de que Otávio, por iniciativa própria, realizaria uma venda ilícita em determinado local, policiais apenas passam a observar o ponto, sem qualquer contato ou estímulo ao suspeito, e efetuam a prisão quando ele inicia a entrega do objeto ao comprador.

Conforme a Súmula 145 do STF, assinale a alternativa correta.$DUP6$),
  lower($DUP7$Em processo criminal, a defesa sustenta que determinada prova deve ser automaticamente desconsiderada porque houve falhas na documentação de sua cadeia de custódia. À luz do entendimento exposto pela Sexta Turma do STJ no HC 653.515/RJ, assinale a alternativa correta.$DUP7$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 7';
end $$;

-- ================= INSERT das 7 questoes =================
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
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE09B_LEGISLACAO_ESPECIFICA - BM RS', 2026, r.dificuldade, r.enunciado,
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

  if v_questoes - v_snap.total_questoes <> 7 then raise exception 'POSCOND: questoes criadas=% esperado 7', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 35 then raise exception 'POSCOND: alternativas criadas=% esperado 35', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 7 then raise exception 'POSCOND: vinculos criados=% esperado 7', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 7 then raise exception 'POSCOND: curso_questoes criadas=% esperado 7', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='8cb82a8e-e0f4-4d46-a4a5-7443f31912a4' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Poderes da Administracao Publica=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4';
  if v_gabaritos <> 'BB' then raise exception 'POSCOND: gabaritos unidade Poderes da Administracao Publica=% esperado BB', v_gabaritos; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='8e1d1204-1f66-431c-a95f-6403e77882dc' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Jurisprudencia do STF e STJ=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '8e1d1204-1f66-431c-a95f-6403e77882dc';
  if v_gabaritos <> 'BBACC' then raise exception 'POSCOND: gabaritos unidade Jurisprudencia do STF e STJ=% esperado BBACC', v_gabaritos; end if;

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  if v_vinc_ok <> 7 then raise exception 'POSCOND: %/7 vinculos corretos (unidade unica) confirmados', v_vinc_ok; end if;

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 7 then raise exception 'POSCOND: %/7 curso_questoes novas confirmadas', v_cq_ok; end if;

  raise notice 'POSCONDICOES OK: +7 questoes, +35 alternativas, +7 vinculos, +7 curso_questoes; 2 unidades com gabaritos e contagens confirmadas';
end $$;

rollback;
