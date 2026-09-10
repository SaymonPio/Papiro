-- TESTE DE ROLLBACK REAL da IMPORTACAO CV-AUT-01. Executa, dentro de UMA
-- transacao controlada que termina em ROLLBACK externo, a sequencia
-- completa: OLD (baseline) -> APPLY (mesma logica do apply real) -> TARGET
-- (verifica) -> REVERSAO REAL (mesma logica do reverter real) -> OLD_FINAL
-- (verifica). Nenhuma linha e alterada permanentemente — tudo e desfeito
-- por ROLLBACK.

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
  ordem int primary key, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;

insert into _lote_questoes (ordem, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 18, 'media', $FONTE1$PAPIRO — CV-AUT-01 — 01 — Núcleo do sujeito (múltiplas afirmativas)$FONTE1$, $ENUN1$Considere as frases a seguir quanto à concordância verbal.

I. A sequência de treinamentos prepara os recrutas para a avaliação.
II. Os resultados do último simulado demonstra a evolução da turma.
III. O comandante, referência para os novos soldados, orientou a equipe.
IV. A presença dos instrutores garantem maior segurança durante a atividade.

Quais estão corretas?$ENUN1$),
(2, 18, 'media', $FONTE2$PAPIRO — CV-AUT-01 — 02 — Acento diferencial (mantém/vem/têm) — microajuste editorial Fase 2D.3/2E.1$FONTE2$, $ENUN2$Assinale a alternativa que preenche corretamente as lacunas da frase a seguir:

A equipe ______ a rotina de treinamento, o novo instrutor ______ ao quartel logo cedo e os supervisores ______ autonomia para ajustar as atividades.$ENUN2$),
(3, 18, 'facil', $FONTE3$PAPIRO — CV-AUT-01 — 03 — Acento diferencial (contém/contêm)$FONTE3$, $ENUN3$Assinale a alternativa que preenche corretamente as lacunas da frase abaixo.

O relatório ______ dados sigilosos, enquanto os anexos ______ informações complementares.$ENUN3$),
(4, 18, 'media', $FONTE4$PAPIRO — CV-AUT-01 — 04 — Núcleo do sujeito x expressão preposicionada (identificação de erro)$FONTE4$, $ENUN4$Considere a frase:

“A revisão dos procedimentos operacionais começaram na segunda-feira.”

Sem alterar o sujeito nem o tempo verbal empregado, assinale a alternativa que identifica corretamente a existência de erro de concordância verbal e, se houver, apresenta a correção necessária.$ENUN4$),
(5, 18, 'media', $FONTE5$PAPIRO — CV-AUT-01 — 05 — Contraste HAVER x EXISTIR (múltiplas afirmativas, substituta Fase 2D.1)$FONTE5$, $ENUN5$Analise as afirmativas a seguir quanto à concordância verbal.

I. Naquela região, deve haver rotas alternativas para o resgate.
II. Podem existir falhas no sistema de comunicação.
III. Haviam obstáculos imprevistos durante a operação.
IV. Pode existirem soluções mais seguras para o deslocamento.

Quais afirmativas estão corretas?$ENUN5$),
(6, 18, 'media', $FONTE6$PAPIRO — CV-AUT-01 — 06 — FAZER indicando tempo decorrido (piloto Fase 2B)$FONTE6$, $ENUN6$Assinale a alternativa que preenche corretamente as lacunas da frase: “Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente.”$ENUN6$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$Estão corretas apenas I e III. Em I, o núcleo do sujeito é o substantivo singular “sequência”, por isso o verbo deve permanecer no singular: “prepara”. O termo plural “de treinamentos” é apenas um adjunto adnominal e não determina a concordância. Em II, o núcleo do sujeito é “resultados”, no plural; a forma adequada seria “demonstram”. Em III, o sujeito tem como núcleo “comandante”, no singular, e o trecho intercalado “referência para os novos soldados” funciona como aposto, não alterando a concordância de “orientou”. Em IV, o núcleo é “presença”, no singular; portanto, o correto seria “A presença dos instrutores garante”. O termo plural “dos instrutores” não justifica o emprego de “garantem”.

FUNDAMENTO: Regra geral de concordância verbal na norma-padrão: o verbo concorda em número e pessoa com o núcleo do sujeito. Adjuntos adnominais, apostos e outros termos próximos ao verbo não alteram essa relação de concordância.$EXPL1$),
(2, $EXPL2$A sequência correta é “mantém – vem – têm”. O sujeito “A equipe” está no singular, razão pela qual se emprega “mantém”, com acento agudo. O sujeito “o novo instrutor” também é singular, exigindo a forma “vem”, sem acento. Na última frase, o sujeito “Os supervisores” está no plural, o que determina o uso de “têm”, com acento circunflexo. As demais alternativas apresentam pelo menos uma forma verbal incompatível com o número do respectivo sujeito.

FUNDAMENTO: Concordância verbal e acento diferencial de número nos verbos ter, vir e seus derivados: na terceira pessoa do presente do indicativo, “tem” e “vem” indicam singular, enquanto “têm” e “vêm” indicam plural. Nos derivados, como “manter”, emprega-se “mantém” no singular e “mantêm” no plural.$EXPL2$),
(3, $EXPL3$Na primeira oração, o sujeito “O relatório” está no singular, exigindo a forma “contém”. Na segunda, o sujeito “os anexos” está no plural, exigindo “contêm”. As duas formas recebem acento, mas o circunflexo da forma plural marca graficamente a oposição de número: ele contém; eles contêm. As demais alternativas empregam uma ou ambas as formas em número incompatível com o respectivo sujeito ou eliminam indevidamente os acentos.

FUNDAMENTO: Concordância verbal e acento diferencial de número nas formas derivadas de ter: o verbo conter segue o padrão de ter — na 3ª pessoa do singular, emprega-se “contém”; na 3ª pessoa do plural, emprega-se “contêm”, com acento circunflexo indicador do plural.$EXPL3$),
(4, $EXPL4$Há erro de concordância verbal. O sujeito completo é “A revisão dos procedimentos operacionais”, mas seu núcleo é o substantivo singular “revisão”. A expressão preposicionada “dos procedimentos operacionais” apenas especifica qual revisão está sendo mencionada e não determina a flexão do verbo. Assim, preservado o pretérito perfeito, a forma correta é “começou”: “A revisão dos procedimentos operacionais começou na segunda-feira”. A alternativa B aplica indevidamente a concordância por proximidade, e a alternativa C trata “procedimentos” como segundo núcleo, embora o termo esteja introduzido pela preposição “de”. A forma “começam” mantém o verbo no plural e ainda altera o tempo verbal. Já a alteração para “As revisões” modificaria o sujeito, contrariando expressamente o comando.

FUNDAMENTO: Identificação do núcleo do sujeito e regra geral de concordância verbal: o verbo concorda em número e pessoa com o núcleo do sujeito. Em um sujeito simples formado por um substantivo singular acompanhado de expressão preposicionada plural, o termo interno à expressão preposicionada não substitui o núcleo nem determina a flexão verbal.$EXPL4$),
(5, $EXPL5$As afirmativas I e II estão corretas. Na afirmativa I, “haver”, empregado com sentido de existir, é impessoal e permanece na terceira pessoa do singular; por isso, o auxiliar também fica no singular em “deve haver”. Na afirmativa II, “existir” é um verbo pessoal, e o auxiliar “podem” concorda com o sujeito plural “falhas no sistema de comunicação”. A afirmativa III está incorreta porque “haver”, empregado com sentido de existir, é impessoal e deve permanecer no singular: “Havia obstáculos imprevistos durante a operação”. A afirmativa IV está incorreta porque, na locução com o verbo pessoal “existir”, a flexão deve ocorrer no auxiliar: “Podem existir soluções mais seguras para o deslocamento”.

FUNDAMENTO: Concordância verbal — contraste entre haver existencial e existir: o verbo “haver”, quando empregado com sentido de existir, ocorrer ou acontecer, é impessoal e permanece na terceira pessoa do singular, inclusive quando integra uma locução verbal; já “existir” é pessoal e concorda normalmente com seu sujeito, cabendo ao auxiliar expressar essa concordância nas locuções verbais.$EXPL5$),
(6, $EXPL6$Na primeira oração, fazer indica tempo decorrido e é impessoal. Assim, permanece na terceira pessoa do singular. Na locução “deve fazer”, o auxiliar também fica no singular; “quatro meses” expressa o tempo transcorrido e não funciona como sujeito. Na segunda oração, fazer apresenta uso pessoal: o sujeito é “os instrutores”, cujo núcleo está no plural, o que exige “fazem”. Portanto, a construção correta é “deve fazer quatro meses” e “os instrutores fazem atividades”. A, D e E flexionam indevidamente o verbo ou o auxiliar da construção temporal; C e D não estabelecem a concordância plural exigida pelo sujeito “os instrutores”.

FUNDAMENTO: Concordância verbal com fazer indicativo de tempo decorrido: fazer é impessoal quando indica tempo decorrido ou fenômeno atmosférico, permanecendo na terceira pessoa do singular. Em outros sentidos, pode ser pessoal e deve concordar normalmente com seu sujeito.$EXPL6$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_0$Apenas I.$ALT1_0$, false),
(1, 2, $ALT1_1$Apenas II e IV.$ALT1_1$, false),
(1, 3, $ALT1_2$Apenas I e III.$ALT1_2$, true),
(1, 4, $ALT1_3$Apenas I, II e III.$ALT1_3$, false),
(1, 5, $ALT1_4$I, II, III e IV.$ALT1_4$, false),
(2, 1, $ALT2_0$mantêm – vêm – tem$ALT2_0$, false),
(2, 2, $ALT2_1$mantém – vem – têm$ALT2_1$, true),
(2, 3, $ALT2_2$mantém – vêm – tem$ALT2_2$, false),
(2, 4, $ALT2_3$mantêm – vem – têm$ALT2_3$, false),
(2, 5, $ALT2_4$mantém – vem – tem$ALT2_4$, false),
(3, 1, $ALT3_0$contém – contêm$ALT3_0$, true),
(3, 2, $ALT3_1$contêm – contém$ALT3_1$, false),
(3, 3, $ALT3_2$contém – contém$ALT3_2$, false),
(3, 4, $ALT3_3$contêm – contêm$ALT3_3$, false),
(3, 5, $ALT3_4$contem – contem$ALT3_4$, false),
(4, 1, $ALT4_0$Há erro de concordância: “começaram” deve ser substituído por “começou”, pois o núcleo do sujeito é “revisão”.$ALT4_0$, true),
(4, 2, $ALT4_1$Não há erro de concordância, pois o verbo deve concordar com “procedimentos operacionais”, expressão plural mais próxima.$ALT4_1$, false),
(4, 3, $ALT4_2$Não há erro de concordância, pois “revisão” e “procedimentos” constituem dois núcleos de um sujeito composto.$ALT4_2$, false),
(4, 4, $ALT4_3$Há erro de concordância, e a forma correta é “começam”, porque o sujeito possui sentido coletivo.$ALT4_3$, false),
(4, 5, $ALT4_4$Há erro de concordância, e a correção adequada é substituir “A revisão” por “As revisões”, mantendo “começaram”.$ALT4_4$, false),
(5, 1, $ALT5_0$Apenas I.$ALT5_0$, false),
(5, 2, $ALT5_1$Apenas II e III.$ALT5_1$, false),
(5, 3, $ALT5_2$Apenas I e II.$ALT5_2$, true),
(5, 4, $ALT5_3$Apenas I e IV.$ALT5_3$, false),
(5, 5, $ALT5_4$Apenas III e IV.$ALT5_4$, false),
(6, 1, $ALT6_0$devem fazer — fazem$ALT6_0$, false),
(6, 2, $ALT6_1$deve fazer — fazem$ALT6_1$, true),
(6, 3, $ALT6_2$deve fazer — faz$ALT6_2$, false),
(6, 4, $ALT6_3$devem fazer — faz$ALT6_3$, false),
(6, 5, $ALT6_4$fazem — fazem$ALT6_4$, false);

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
  where up.id = '834a820d-48a7-440f-a013-be375be8a62d';
  insert into _relatorio values ('OLD','unidade_ok', coalesce(v_unidade_ok,false), 'ativa+relevante');

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_4', v_uteis = 4, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','real_2', v_real = 2, v_real::text);
  insert into _relatorio values ('OLD','autoral_2', v_autoral = 2, v_autoral::text);

  select count(*) into v_gap
  from (
    select distinct q.id from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa
    and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
  ) g;
  insert into _relatorio values ('OLD','gap_0', v_gap = 0, v_gap::text);

  select count(*) into v_dup from public.questoes q where q.ativa = true and lower(q.enunciado) in (
  lower($DUP1$Considere as frases a seguir quanto à concordância verbal.

I. A sequência de treinamentos prepara os recrutas para a avaliação.
II. Os resultados do último simulado demonstra a evolução da turma.
III. O comandante, referência para os novos soldados, orientou a equipe.
IV. A presença dos instrutores garantem maior segurança durante a atividade.

Quais estão corretas?$DUP1$),
  lower($DUP2$Assinale a alternativa que preenche corretamente as lacunas da frase a seguir:

A equipe ______ a rotina de treinamento, o novo instrutor ______ ao quartel logo cedo e os supervisores ______ autonomia para ajustar as atividades.$DUP2$),
  lower($DUP3$Assinale a alternativa que preenche corretamente as lacunas da frase abaixo.

O relatório ______ dados sigilosos, enquanto os anexos ______ informações complementares.$DUP3$),
  lower($DUP4$Considere a frase:

“A revisão dos procedimentos operacionais começaram na segunda-feira.”

Sem alterar o sujeito nem o tempo verbal empregado, assinale a alternativa que identifica corretamente a existência de erro de concordância verbal e, se houver, apresenta a correção necessária.$DUP4$),
  lower($DUP5$Analise as afirmativas a seguir quanto à concordância verbal.

I. Naquela região, deve haver rotas alternativas para o resgate.
II. Podem existir falhas no sistema de comunicação.
III. Haviam obstáculos imprevistos durante a operação.
IV. Pode existirem soluções mais seguras para o deslocamento.

Quais afirmativas estão corretas?$DUP5$),
  lower($DUP6$Assinale a alternativa que preenche corretamente as lacunas da frase: “Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente.”$DUP6$)
  );
  insert into _relatorio values ('OLD','sem_duplicidade', v_dup = 0, v_dup::text);
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record; v_novo_id bigint; v_count int := 0;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria CV-AUT-01 - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = 18
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_novo_id);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;

    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY','questoes_criadas_6', v_count = 6, v_count::text);
end $$;

-- ===================== VINCULO via RPC sancionada =====================
do $$
declare
  r record; v_count int := 0;
begin
  for r in select questao_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, '834a820d-48a7-440f-a013-be375be8a62d'::uuid);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY','vinculos_criados_6', v_count = 6, v_count::text);
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

  insert into _relatorio values ('TARGET','questoes_delta_6', v_questoes - v_snap.total_questoes = 6, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET','alternativas_delta_30', v_alternativas - v_snap.total_alternativas = 30, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET','vinculos_delta_6', v_vinculos - v_snap.total_vinculos = 6, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET','curso_questoes_delta_6', v_curso_questoes - v_snap.total_curso_questoes = 6, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_10', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','real_2', v_real = 2, v_real::text);
  insert into _relatorio values ('TARGET','autoral_8', v_autoral = 8, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem) into v_gabaritos from _mapa_ids m;
  insert into _relatorio values ('TARGET','gabaritos', v_gabaritos = 'CBAACB', v_gabaritos);

  select string_agg((select dificuldade from public.questoes where id=m.questao_id), ',' order by m.ordem) into v_dificuldades from _mapa_ids m;
  insert into _relatorio values ('TARGET','dificuldades', v_dificuldades = 'media,media,facil,media,media,media', v_dificuldades);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d')
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> '834a820d-48a7-440f-a013-be375be8a62d');
  insert into _relatorio values ('TARGET','vinculos_6_na_unidade_correta_apenas', v_vinc_ok = 6, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET','curso_questoes_6', v_cq_ok = 6, v_cq_ok::text);

  insert into _relatorio values ('TARGET','ativa_6de6',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 6, 'ativa');
  insert into _relatorio values ('TARGET','origem_papiro_6de6',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 6, 'banca papiro');
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'TESTE ABORTADO: guard pre-reversao falhou (uteis=%), nao reverter as cegas', v_uteis; end if;
  insert into _relatorio values ('REVERSAO_GUARD','uteis_10_antes_de_reverter', v_uteis = 10, v_uteis::text);
end $$;

do $$
declare
  r record; v_count int := 0;
begin
  for r in select questao_id from _mapa_ids order by ordem loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, '834a820d-48a7-440f-a013-be375be8a62d'::uuid);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('REVERSAO','vinculos_removidos_6', v_count = 6, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','curso_questoes_removidas_6', v_count = 6, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','alternativas_removidas_30', v_count = 30, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO','questoes_removidas_6', v_count = 6, v_count::text);
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
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_4', v_uteis = 4, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','real_2', v_real = 2, v_real::text);
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — CV_AUT_01_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
