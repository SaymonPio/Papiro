-- IMPORTACAO LOTE06_PORTUGUES_AUTORAL — 6 questoes autorais para a unidade
-- Redacao oficial (curso Brigada Militar RS), fechando o deficit de Lingua
-- Portuguesa nesta unidade (ultima deficitaria da materia).
--
-- Human sign-off explicito do source manifest (Decreto no 9.758/2019 tratado
-- como VALIDATED_PRIMARY_NORM) e human review final unica (mandato "PAPIRO —
-- LOTE 06 — HUMAN REVIEW FINAL + EDITS + FREEZE + IMPORTACAO"). Nao
-- selecionadas/reserva (2): REDOF-07, REDOF-08 — NENHUMA importada.
-- 3 edicoes humanas aplicadas: REDOF-02 (alternativa D), REDOF-05 e REDOF-06
-- (fundamento — dispositivos especificos do Decreto no 9.758/2019).
--
-- Padrao identico aos lotes precedentes: staging de questoes/explicacoes/
-- alternativas, insercao por INSERT direto em questoes/alternativas (nunca
-- em questao_unidades_pedagogicas), vinculo exclusivamente via
-- classificar_questao_unidade_admin (RPC que sincroniza curso_questoes
-- automaticamente).
--
-- NAO altera nenhuma questao existente na unidade (Q18, Q73, Q117, Q118
-- preservadas sem qualquer edicao).
-- NAO altera unidades/conteudos/materias/aulas.
--
-- Texto final persistido em
-- outputs/curadoria-autoral/review/LOTE06-PORTUGUES-REDACAO-OFICIAL-HUMAN-REVIEW.md,
-- congelado em outputs/curadoria-autoral/review/LOTE06-FROZEN-6.json
-- (corpus_hash 3847e827558753844867c7040b86b911c3fc1323c316a58c23f941960f90cfaa).
--
-- ROLLBACK-TESTADO em importar_lote06_portugues_autoral_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_lote06_portugues_autoral.sql

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
(1, 30, $D1$media$D1$, $FONTE1$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-01$FONTE1$, $ENUN1$Ao redigir um ofício da Brigada Militar destinado à Secretaria de Segurança Pública, um servidor deve preencher o campo assunto para informar, de modo sintético, o teor da comunicação. Assinale a alternativa que apresenta a formatação adequada desse campo, conforme o Manual de Redação da Presidência da República.$ENUN1$),
(2, 30, $D2$media$D2$, $FONTE2$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-02$FONTE2$, $ENUN2$O Comandante de uma unidade da Brigada Militar encaminhará ofício ao Presidente da República. Considerando as regras do Manual de Redação da Presidência da República quanto ao fecho e à identificação do signatário, assinale a alternativa que apresenta o encerramento corretamente redigido.$ENUN2$),
(3, 30, $D3$media$D3$, $FONTE3$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-03$FONTE3$, $ENUN3$Uma unidade administrativa da Brigada Militar pretende divulgar orientações sobre o acesso a um serviço eletrônico e, simultaneamente, encaminhar informações técnicas a outro órgão público. Considerando a definição de comunicação administrativa e o princípio da impessoalidade, assinale a alternativa correta.$ENUN3$),
(4, 30, $D4$media$D4$, $FONTE4$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-04$FONTE4$, $ENUN4$Em uma capacitação sobre redação oficial, um servidor afirmou que o mnemônico “C-P-O-C-I” — clareza, precisão, objetividade, concisão e impessoalidade — esgota todos os atributos exigidos para a elaboração de comunicações oficiais. À luz do Manual de Redação da Presidência da República, assinale a alternativa correta.$ENUN4$),
(5, 30, $D5$media$D5$, $FONTE5$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-05$FONTE5$, $ENUN5$Considerando exclusivamente a disciplina do Decreto nº 9.758/2019, assinale a alternativa correta acerca das comunicações escritas dirigidas a agentes públicos da administração pública federal direta e indireta.$ENUN5$),
(6, 30, $D6$media$D6$, $FONTE6$PAPIRO — LOTE06_PORTUGUES_AUTORAL — REDOF-06$FONTE6$, $ENUN6$À luz do Decreto nº 9.758/2019, que disciplina as comunicações com agentes públicos da administração pública federal, assinale a alternativa que apresenta formas incompatíveis com o padrão de tratamento instituído pelo decreto.$ENUN6$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$O campo assunto deve ser precedido da palavra “Assunto:” e apresentar uma síntese concisa do conteúdo do documento. Emprega-se letra maiúscula apenas no início da frase e em nomes próprios, como “Porto Alegre”. A alternativa A usa maiúsculas em todas as palavras; a B capitaliza indevidamente palavras comuns; a D substitui os dois-pontos por hífen; e a E inicia o enunciado do assunto com letra minúscula, além de apresentar erro gráfico.

FUNDAMENTO: Manual de Redação da Presidência da República (MRPR), 3ª edição, 2018, orientações sobre o padrão ofício e o campo assunto. — O assunto deve sintetizar o teor do documento, ser antecedido por “Assunto:” e ser grafado com maiúscula apenas na primeira letra da frase e em nomes próprios.$EXPL1$),
(2, $EXPL2$Como o destinatário é autoridade de hierarquia superior, inclusive o Presidente da República, o fecho adequado é “Respeitosamente,”. Na identificação, o nome do signatário deve estar em letras maiúsculas, sem negrito e sem linha ou traço de assinatura acima dele; o cargo é escrito com apenas a letra inicial maiúscula. Por isso, a alternativa D é correta. A emprega “Atenciosamente”, fecho reservado a destinatário de mesma hierarquia, inferior ou ao público em geral. A B inclui linha de assinatura, a C usa negrito e a E não registra integralmente o nome em maiúsculas.

FUNDAMENTO: Manual de Redação da Presidência da República (MRPR), 3ª edição, 2018, orientações sobre fechos para comunicações e identificação do signatário no padrão ofício. — Usa-se “Respeitosamente” para autoridade de hierarquia superior. A identificação contém o nome em maiúsculas, sem negrito e sem linha de assinatura, seguido do cargo com inicial maiúscula.$EXPL2$),
(3, $EXPL3$A alternativa C apresenta corretamente os polos da comunicação administrativa: quem comunica é o serviço público; o conteúdo comunicado decorre das atribuições do órgão; e o destinatário pode ser o público, uma instituição privada ou outro órgão público. Também está correta ao vincular a impessoalidade à esfera pública. A alternativa A erra ao admitir conteúdo alheio às atribuições do órgão. A B restringe indevidamente os destinatários. A D confunde impessoalidade com supressão da identificação institucional, que deve estar presente. A E admite assunto de interesse pessoal do redator, o que não corresponde à finalidade administrativa.

FUNDAMENTO: Manual de Redação da Presidência da República, 3ª edição (2018), seção sobre comunicações oficiais e impessoalidade. — A redação oficial corresponde à maneira pela qual o Poder Público redige comunicações oficiais. A impessoalidade decorre da finalidade pública e da atuação institucional do órgão, não de interesses particulares de seus agentes.$EXPL3$),
(4, $EXPL4$A alternativa B é correta porque o mnemônico C-P-O-C-I reúne clareza, precisão, objetividade, concisão e impessoalidade, mas não apresenta uma lista exaustiva dos atributos da redação oficial. Também são exigidos coesão, coerência, formalidade, padronização e uso da norma-padrão. A alternativa A erra ao tratar esses elementos como meras consequências, e não como requisitos próprios. A C exclui indevidamente a impessoalidade. A D cria distinção inexistente entre destinatários. A E afirma, sem fundamento, incompatibilidade entre clareza e precisão, atributos que devem coexistir no texto oficial.

FUNDAMENTO: Manual de Redação da Presidência da República, 3ª edição (2018), capítulo sobre atributos da redação oficial. — A redação oficial deve observar clareza, precisão, objetividade, concisão, coesão, coerência, impessoalidade, formalidade, padronização e emprego da norma-padrão. Mnemônicos podem auxiliar a memorização, mas não substituem a relação completa dos atributos.$EXPL4$),
(5, $EXPL5$O Decreto nº 9.758/2019 estabelece, nas comunicações por ele abrangidas, “senhor” como forma de tratamento dirigida aos agentes públicos da administração pública federal direta e indireta, com a adequada flexão para feminino e plural. A regra independe da hierarquia, do cargo ou da função do destinatário. A alternativa A restringe indevidamente o alcance subjetivo; a C preserva distinção hierárquica incompatível com o pronome único adotado; a D é falsa, pois Presidente e Vice-Presidente estão abrangidos; e a E amplia indevidamente o âmbito do decreto para situações externas à administração pública federal.

FUNDAMENTO: Decreto nº 9.758/2019, art. 1º, caput e § 2º, IX; art. 2º, caput e parágrafo único. — O Decreto nº 9.758/2019 disciplina a forma de tratamento nas comunicações com agentes públicos da administração pública federal direta e indireta. O art. 1º, § 2º, IX, inclui expressamente o Vice-Presidente e o Presidente da República no âmbito de aplicação. O art. 2º estabelece "senhor" como único pronome de tratamento, independentemente do nível hierárquico, natureza do cargo ou função ou ocasião, com flexão para feminino e plural nos termos de seu parágrafo único.$EXPL5$),
(6, $EXPL6$O Decreto nº 9.758/2019 substitui, nas comunicações por ele abrangidas, formas honoríficas como “Vossa Excelência” e “Excelentíssimo Senhor” pelo emprego de “senhor”, com as flexões necessárias de gênero e número. Assim, a alternativa C reúne formas vedadas nesse contexto. As alternativas A, B e E apresentam flexões regulares de “senhor”; e a D corretamente indica que a escolha da forma não varia em razão da hierarquia do destinatário. Embora o MRPR seja anterior, a questão cobra expressamente o regime posterior instituído pelo decreto para agentes públicos federais.

FUNDAMENTO: Decreto nº 9.758/2019, art. 2º, caput e parágrafo único; art. 3º, caput e inciso I. — O art. 2º do Decreto nº 9.758/2019 estabelece "senhor" como único pronome de tratamento nas comunicações abrangidas pelo Decreto, admitidas as flexões de gênero e número previstas no parágrafo único. O art. 3º, inciso I, veda expressamente o uso de "Vossa Excelência" ou "Excelentíssimo".$EXPL6$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$ASSUNTO: SOLICITAÇÃO DE APOIO LOGÍSTICO PARA OPERAÇÃO EM PORTO ALEGRE.$ALT1_1$, false),
(1, 2, $ALT1_2$Assunto: Solicitação De Apoio Logístico Para Operação Em Porto Alegre.$ALT1_2$, false),
(1, 3, $ALT1_3$Assunto: Solicitação de apoio logístico para operação em Porto Alegre.$ALT1_3$, true),
(1, 4, $ALT1_4$Assunto - Solicitação de apoio logístico para operação em Porto Alegre.$ALT1_4$, false),
(1, 5, $ALT1_5$Assunto: solicitaçâo de apoio logístico para operação em Porto Alegre.$ALT1_5$, false),
(2, 1, $ALT2_1$Atenciosamente,

MARCOS ALMEIDA
Comandante da unidade$ALT2_1$, false),
(2, 2, $ALT2_2$Respeitosamente,

____________________________
MARCOS ALMEIDA
Comandante da unidade$ALT2_2$, false),
(2, 3, $ALT2_3$Respeitosamente,

**MARCOS ALMEIDA**
Comandante da unidade$ALT2_3$, false),
(2, 4, $ALT2_4$Respeitosamente,

MARCOS ALMEIDA
Comandante da unidade$ALT2_4$, true),
(2, 5, $ALT2_5$Respeitosamente,

MARCOS Almeida
Comandante da unidade$ALT2_5$, false),
(3, 1, $ALT3_1$A comunicação administrativa caracteriza-se pelo fato de o emissor ser necessariamente um agente público individualmente identificado, ainda que a mensagem não decorra das atribuições do órgão.$ALT3_1$, false),
(3, 2, $ALT3_2$Na comunicação administrativa, o destinatário deve ser sempre outro órgão público, pois comunicações dirigidas ao público ou a instituições privadas não possuem caráter oficial.$ALT3_2$, false),
(3, 3, $ALT3_3$A comunicação administrativa é realizada pelo serviço público; seu conteúdo decorre das atribuições do órgão; e pode dirigir-se ao público, a instituição privada ou a outro órgão público. Nesse âmbito, a impessoalidade é princípio próprio da esfera pública.$ALT3_3$, true),
(3, 4, $ALT3_4$A impessoalidade exige que toda comunicação administrativa omita a identificação do órgão responsável pela mensagem, a fim de impedir a personalização do ato.$ALT3_4$, false),
(3, 5, $ALT3_5$A comunicação administrativa pode tratar de assunto de interesse pessoal do servidor que a redige, desde que seja destinada a um órgão público.$ALT3_5$, false),
(4, 1, $ALT4_1$A afirmação está correta, pois coesão, coerência, formalidade, padronização e emprego da norma-padrão são consequências automáticas dos cinco elementos do mnemônico e não constituem atributos próprios.$ALT4_1$, false),
(4, 2, $ALT4_2$A afirmação está incorreta, pois o mnemônico é apenas parcial: além dos cinco atributos nele reunidos, a redação oficial requer, entre outros aspectos, coesão, coerência, formalidade, padronização e uso da norma-padrão.$ALT4_2$, true),
(4, 3, $ALT4_3$A afirmação está incorreta apenas porque a impessoalidade não integra os atributos da redação oficial, devendo ser substituída pela criatividade do redator.$ALT4_3$, false),
(4, 4, $ALT4_4$A afirmação está correta, desde que o texto seja destinado a outro órgão público; em comunicações ao público, a formalidade e a padronização deixam de ser exigidas.$ALT4_4$, false),
(4, 5, $ALT4_5$A afirmação está incorreta porque clareza e precisão são atributos incompatíveis: a busca por precisão necessariamente reduz a clareza do texto oficial.$ALT4_5$, false),
(5, 1, $ALT5_1$O decreto restringe-se às comunicações dirigidas a ocupantes de cargos efetivos, não alcançando agentes políticos.$ALT5_1$, false),
(5, 2, $ALT5_2$O emprego de “senhor”, com as flexões de gênero e número pertinentes, é obrigatório como forma de tratamento, independentemente da posição hierárquica do destinatário.$ALT5_2$, true),
(5, 3, $ALT5_3$O decreto determina o uso de “Vossa Excelência” para autoridades superiores e de “senhor” apenas para os demais agentes públicos.$ALT5_3$, false),
(5, 4, $ALT5_4$O Presidente e o Vice-Presidente da República não se incluem no âmbito de aplicação do decreto.$ALT5_4$, false),
(5, 5, $ALT5_5$As regras do decreto aplicam-se indistintamente às comunicações expedidas por qualquer ente federativo, inclusive Estados e Municípios, ainda que destinadas a agentes não federais.$ALT5_5$, false),
(6, 1, $ALT6_1$Senhor e senhora, conforme o gênero do destinatário.$ALT6_1$, false),
(6, 2, $ALT6_2$Senhores e senhoras, quando houver pluralidade de destinatários.$ALT6_2$, false),
(6, 3, $ALT6_3$Vossa Excelência e Excelentíssimo Senhor.$ALT6_3$, true),
(6, 4, $ALT6_4$Senhor, empregado sem variação decorrente da posição hierárquica do agente público.$ALT6_4$, false),
(6, 5, $ALT6_5$Senhora, quando a comunicação for dirigida a agente pública do sexo feminino.$ALT6_5$, false);

-- ================= PRECONDICOES =================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
begin
  select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
  into v_unidade_ok
  from public.unidades_pedagogicas up
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where up.id = '29bfb433-4013-4164-85de-fd847963199d';
  if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade % nao esta ativa/relevante conforme esperado', '29bfb433-4013-4164-85de-fd847963199d'; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id = '29bfb433-4013-4164-85de-fd847963199d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id = '29bfb433-4013-4164-85de-fd847963199d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

  select count(*) into v_gap
  from (
    select distinct q.id from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = '29bfb433-4013-4164-85de-fd847963199d' and q.ativa
    and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
  ) g;
  if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes na unidade %=% esperado 0', '29bfb433-4013-4164-85de-fd847963199d', v_gap; end if;

  raise notice 'PRECOND unidade % OK: uteis=% real=% autoral=% gap=%', '29bfb433-4013-4164-85de-fd847963199d', v_uteis, v_real, v_autoral, v_gap;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Ao redigir um ofício da Brigada Militar destinado à Secretaria de Segurança Pública, um servidor deve preencher o campo assunto para informar, de modo sintético, o teor da comunicação. Assinale a alternativa que apresenta a formatação adequada desse campo, conforme o Manual de Redação da Presidência da República.$DUP1$),
  lower($DUP2$O Comandante de uma unidade da Brigada Militar encaminhará ofício ao Presidente da República. Considerando as regras do Manual de Redação da Presidência da República quanto ao fecho e à identificação do signatário, assinale a alternativa que apresenta o encerramento corretamente redigido.$DUP2$),
  lower($DUP3$Uma unidade administrativa da Brigada Militar pretende divulgar orientações sobre o acesso a um serviço eletrônico e, simultaneamente, encaminhar informações técnicas a outro órgão público. Considerando a definição de comunicação administrativa e o princípio da impessoalidade, assinale a alternativa correta.$DUP3$),
  lower($DUP4$Em uma capacitação sobre redação oficial, um servidor afirmou que o mnemônico “C-P-O-C-I” — clareza, precisão, objetividade, concisão e impessoalidade — esgota todos os atributos exigidos para a elaboração de comunicações oficiais. À luz do Manual de Redação da Presidência da República, assinale a alternativa correta.$DUP4$),
  lower($DUP5$Considerando exclusivamente a disciplina do Decreto nº 9.758/2019, assinale a alternativa correta acerca das comunicações escritas dirigidas a agentes públicos da administração pública federal direta e indireta.$DUP5$),
  lower($DUP6$À luz do Decreto nº 9.758/2019, que disciplina as comunicações com agentes públicos da administração pública federal, assinale a alternativa que apresenta formas incompatíveis com o padrão de tratamento instituído pelo decreto.$DUP6$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 6';
end $$;

-- ================= INSERT das 6 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE06_PORTUGUES_AUTORAL - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = 30
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id, unidade_pedagogica_id) values (r.ordem, v_novo_id, '29bfb433-4013-4164-85de-fd847963199d');

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
  v_uteis int; v_real int; v_autoral int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes - v_snap.total_questoes <> 6 then raise exception 'POSCOND: questoes criadas=% esperado 6', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 30 then raise exception 'POSCOND: alternativas criadas=% esperado 30', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 6 then raise exception 'POSCOND: vinculos criados=% esperado 6', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 6 then raise exception 'POSCOND: curso_questoes criadas=% esperado 6', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='29bfb433-4013-4164-85de-fd847963199d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Redação oficial=% esperado 10', v_uteis; end if;

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='29bfb433-4013-4164-85de-fd847963199d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_autoral + v_real <> 10 then raise exception 'POSCOND: uteis(real+autoral) unidade Redação oficial=% esperado 10', v_autoral + v_real; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '29bfb433-4013-4164-85de-fd847963199d';
  if v_gabaritos <> 'CDCBBC' then raise exception 'POSCOND: gabaritos unidade Redação oficial=% esperado CDCBBC', v_gabaritos; end if;

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  if v_vinc_ok <> 6 then raise exception 'POSCOND: %/6 vinculos corretos (unidade unica) confirmados', v_vinc_ok; end if;

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 6 then raise exception 'POSCOND: %/6 curso_questoes novas confirmadas', v_cq_ok; end if;

  raise notice 'POSCONDICOES OK: +6 questoes, +30 alternativas, +6 vinculos, +6 curso_questoes; unidade Redação oficial com gabaritos e contagens confirmadas';
end $$;

commit;
