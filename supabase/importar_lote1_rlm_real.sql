-- Aplicacao REAL do Lote 1 REAL de Raciocinio Logico — 8 questoes novas
-- + 40 alternativas + 8 vinculos, validado pelo harness
-- supabase/importar_lote1_rlm_real_teste_rollback.sql (tudo_ok = true
-- confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_rlm_lote1_real.json (candidatas 1-8, status_final =
-- PRONTA_PARA_IMPORTAR). A candidata 9 (Diagramas logicos, Prefeitura de
-- Xangri-la) esta EXCLUIDA deste arquivo — permanece BLOQUEADA_POR_ASSET,
-- nao aparece em nenhuma linha abaixo. Nenhuma das 34 questoes ja
-- existentes em Raciocinio Logico e tocada por este arquivo.
--
-- Origem: REAL (banca Fundatec) em todas as 8 — nunca AUTORAL_PAPIRO.
-- Gabaritos e explicacoes foram recalculados de forma independente (nao
-- copiados do relatorio do Gemini); a questao de Viamao (Tautologia)
-- corrige explicitamente um erro do Gemini sobre a alternativa E
-- (contingencia, nao contradicao — a contradicao genuina e a alternativa C).
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

create temporary table _lote_questoes (
  ordem int primary key,
  unidade_id uuid,
  assunto_id bigint,
  banca text,
  concurso text,
  ano int,
  fonte text,
  enunciado text
) on commit drop;

insert into _lote_questoes (ordem, unidade_id, assunto_id, banca, concurso, ano, fonte, enunciado) values
(1, '6683c484-74a7-4b07-9cda-1a72190e6445', 36, 'Fundatec', 'SPGG-RS - Médico Clínica-geral', 2023,
 'Fundatec — SPGG-RS Médico Clínica-geral 29/01/2023 — Questão 26 (página 5)',
 'Se Cristiano Ronaldo vai ficar no banco de reservas, então Portugal vai golear a Croácia. Sabendo que a proposição composta acima é uma proposição condicional, é correto afirmar que o conectivo presente nessa proposição é:'),
(2, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Fundatec', 'Prefeitura de Vacaria - Agente Administrativo Auxiliar', 2021,
 'Fundatec — Prefeitura de Vacaria, Agente Administrativo Auxiliar, 2021 — Questão 35 (página 7)',
 'Se P, Q e R são proposições simples, então o número de linhas da tabela verdade da proposição composta (P ∧ Q) ↔ R será:'),
(3, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Fundatec', 'SPGG-RS - Analista Administrador', 2022,
 'Fundatec — SPGG-RS Analista Administrador 13/03/2022 — Questão 30 (página 6)',
 'A alternativa que apresenta uma proposição equivalente a "Se o sol nasce, então os pássaros cantam" é:'),
(4, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Fundatec', 'SPGG-RS - Médico Clínica-geral', 2023,
 'Fundatec — SPGG-RS Médico Clínica-geral 29/01/2023 — Questão 28 (página 5)',
 'Se 26 é um número par, então 188 é um número par. A proposição contrapositiva da condicional acima é:'),
(5, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Fundatec', 'SPGG-RS - Médico Clínica-geral', 2023,
 'Fundatec — SPGG-RS Médico Clínica-geral 29/01/2023 — Questão 29 (página 5)',
 'Considere o universo U = {-2, -1, 0, 1, 2} e as sentenças: I. ∃x∈U (x+3=2). II. ∀x∈U (x≠3). III. ∃x∈U (x-4=2). Quais proposições são verdadeiras?'),
(6, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Fundatec', 'Prefeitura de Viamão - Concurso 649', 2022,
 'Fundatec — Prefeitura de Viamão, concurso 649, 2022 — Questão 37',
 'A proposição composta que representa uma tautologia é a que está indicada na alternativa:'),
(7, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Fundatec', 'SPGG-RS - Analista Administrador', 2022,
 'Fundatec — SPGG-RS Analista Administrador 13/03/2022 — Questão 27 (páginas 5/6)',
 'Considere o universo U = {1, 2, 3, 4, 5} e a sentença aberta composta: x² + 4 > 20 ∧ x + 2 < 7. O conjunto-verdade dessa sentença, em U, é:'),
(8, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Fundatec', 'SPGG-RS - Analista Administrador', 2022,
 'Fundatec — SPGG-RS Analista Administrador 13/03/2022 — Questão 29 (página 6)',
 'Considere as premissas: Todo triângulo equilátero é isósceles. ABC é um triângulo equilátero. A partir dessas afirmações, é possível deduzir que é verdade que:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nA estrutura "Se P, então Q" é, por definição, o conectivo CONDICIONAL (P→Q). A frase apresentada tem exatamente essa forma, com "Cristiano Ronaldo vai ficar no banco de reservas" como antecedente e "Portugal vai golear a Croácia" como consequente.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA) Disjunção inclusiva usaria "ou", não "se...então".\nB) Conjunção usaria "e".\nC) Bicondicional exigiria "se e somente se", ligando as proposições nos dois sentidos.\nD) Disjunção exclusiva também usaria "ou", com exclusividade, não a estrutura condicional.\n\nBIZU DE PROVA:\n"Se P, então Q" = sempre CONDICIONAL (→), independentemente do conteúdo ou da plausibilidade fática das proposições envolvidas.'),
(2, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\nCom 3 proposições simples distintas (P, Q, R), o número de linhas da tabela-verdade completa é sempre 2ⁿ, aqui 2³ = 8.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA), B), D) e E) (3, 5, 10 e 12) não correspondem a nenhuma potência de 2 relevante para o número de proposições simples envolvidas.\n\nBIZU DE PROVA:\nNúmero de linhas da tabela-verdade = 2^(número de proposições simples distintas), sempre — independentemente da complexidade da fórmula composta.'),
(3, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\nAplicando a equivalência P→Q ≡ ¬P∨Q, com P="o sol nasce" e Q="os pássaros cantam", obtemos "o sol não nasce ou os pássaros cantam" — exatamente a alternativa D.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA) "O sol nasce e os pássaros cantam" é P∧Q (conjunção), não equivalente à condicional original.\nB) "Se o sol não nasce, então os pássaros não cantam" é ¬P→¬Q, a INVERSA da condicional — não equivalente a ela.\nC) "O sol não nasce ou os pássaros não cantam" é ¬P∨¬Q — usa a negação de Q em vez de Q, alterando o significado.\nE) "Se os pássaros cantam, então o sol nasce" é Q→P, a RECÍPROCA — também não equivalente.\n\nBIZU DE PROVA:\nP→Q ≡ ¬P∨Q sempre — "nega o antecedente, troca ''então'' por ''ou'', mantém o consequente".'),
(4, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nA contrapositiva de P→Q é ¬Q→¬P (inverte a ordem E nega ambos os termos). Com P="26 é par" e Q="188 é par", a contrapositiva é "Se 188 não é par, então 26 não é par" — exatamente a alternativa E.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA) é P∧Q, uma conjunção, não uma transformação condicional.\nB) é P→¬Q, mantém a ordem original e nega só o consequente — não é a contrapositiva.\nC) é ¬P→Q, nega só o antecedente e mantém a ordem — não é a contrapositiva.\nD) é ¬P→¬Q, a INVERSA (nega ambos, mas NÃO inverte a ordem) — o erro clássico de confundir inversa com contrapositiva.\n\nBIZU DE PROVA:\nContrapositiva = inverte a ordem E nega os dois termos (¬Q→¬P); inversa só nega (¬P→¬Q); recíproca só inverte (Q→P) — apenas a contrapositiva é logicamente equivalente à condicional original.'),
(5, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA B ESTÁ CORRETA:\nEm U={-2,-1,0,1,2}: (I) ∃x∈U(x+3=2) → x=-1, que pertence a U → VERDADEIRA. (II) ∀x∈U(x≠3) → nenhum elemento de U é igual a 3 → VERDADEIRA para os 5 elementos. (III) ∃x∈U(x-4=2) → x=6, que NÃO pertence a U → FALSA. Logo, apenas I e II são verdadeiras.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA) omite II, que também é verdadeira.\nC) inclui III, que é falsa (6∉U).\nD) omite I, que é verdadeira, e inclui III, que é falsa.\nE) inclui III, que é falsa.\n\nBIZU DE PROVA:\n∃ basta UM elemento do domínio satisfazer; ∀ exige TODOS — sempre verificar se o valor que resolve a equação pertence de fato ao universo dado.'),
(6, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\n(p∧q)→p é sempre verdadeira: se p∧q é verdadeira, então p necessariamente também é (a conjunção implica cada um dos seus termos); se p∧q é falsa, a condicional é automaticamente verdadeira. Nas 4 linhas possíveis (VV, VF, FV, FF), o resultado é sempre V — TAUTOLOGIA.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA) (~p∧q)∨~p assume os valores F,F,V,V — CONTINGÊNCIA.\nB) ~(p∧q)∨~p assume F,V,V,V — CONTINGÊNCIA.\nC) ~((p∧q)→p): como (p∧q)→p é sempre verdadeira (é a própria fórmula da alternativa D), sua negação é sempre falsa — CONTRADIÇÃO.\nE) (p∧q)↔~p assume os valores F,V,F,F — CONTINGÊNCIA (há uma linha verdadeira, quando p=V e q=F; não é contradição).\n\nBIZU DE PROVA:\nUma fórmula da forma (A∧B)→A é sempre tautológica, pois a conjunção nunca pode ser verdadeira sem que cada um dos seus termos também seja.'),
(7, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nEm U={1,2,3,4,5}, x²+4>20 equivale a x²>16, satisfeito apenas por x=5 (5²=25>16; x=4 dá 16, que não é >16). Já x+2<7 equivale a x<5, satisfeito por {1,2,3,4}. A conjunção exige as DUAS condições simultaneamente — mas o único valor que satisfaz a primeira (x=5) não satisfaz a segunda (5 não é menor que 5), e nenhum valor de {1,2,3,4} satisfaz a primeira. Logo, o conjunto-verdade é vazio.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB) {4}: 4 não satisfaz x²+4>20 (4²+4=20, que não é >20).\nC) {5}: 5 não satisfaz x+2<7 (5+2=7, que não é <7).\nD) {4,5}: nenhum dos dois satisfaz as duas condições simultaneamente.\nE) {1,2,3,4,5}: nenhum elemento do universo satisfaz as duas condições ao mesmo tempo.\n\nBIZU DE PROVA:\nEm uma sentença aberta composta por conjunção (∧), o conjunto-verdade é a INTERSEÇÃO dos conjuntos-verdade de cada condição — testar cada elemento do domínio contra AMBAS as condições antes de incluí-lo.'),
(8, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nAs premissas afirmam que todo triângulo equilátero é isósceles (relação de inclusão entre as classes) e que ABC é um triângulo equilátero. Como ABC pertence à classe dos equiláteros, e todo equilátero pertence à classe dos isósceles, ABC necessariamente pertence à classe dos isósceles — não há cenário possível em que as premissas sejam verdadeiras e essa conclusão seja falsa (modus ponens categórico).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB) contradiz diretamente a conclusão necessária.\nC) inverte a relação de inclusão das premissas — a primeira premissa não afirma que todo isósceles é equilátero.\nD) contradiz frontalmente a primeira premissa.\nE) é irrelevante e falso — a segunda premissa já afirma que ABC é um triângulo.\n\nBIZU DE PROVA:\n"Todo A é B" + "x é A" ⊢ "x é B" é sempre válido (modus ponens categórico) — não existe contraexemplo possível quando a relação de inclusão entre as classes é dada como premissa.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'Disjunção inclusiva.',false),(1,2,'Conjunção.',false),(1,3,'Bicondicional.',false),(1,4,'Disjunção exclusiva.',false),(1,5,'Condicional.',true),
(2,1,'3.',false),(2,2,'5.',false),(2,3,'8.',true),(2,4,'10.',false),(2,5,'12.',false),
(3,1,'O sol nasce e os pássaros cantam.',false),(3,2,'Se o sol não nasce, então os pássaros não cantam.',false),(3,3,'O sol não nasce ou os pássaros não cantam.',false),(3,4,'O sol não nasce ou os pássaros cantam.',true),(3,5,'Se os pássaros cantam, então o sol nasce.',false),
(4,1,'26 é um número par e 188 é um número par.',false),(4,2,'Se 26 é um número par, então 188 não é um número par.',false),(4,3,'Se 26 não é um número par, então 188 é um número par.',false),(4,4,'Se 26 não é um número par, então 188 não é um número par.',false),(4,5,'Se 188 não é um número par, então 26 não é um número par.',true),
(5,1,'Apenas I.',false),(5,2,'Apenas I e II.',true),(5,3,'Apenas I e III.',false),(5,4,'Apenas II e III.',false),(5,5,'I, II e III.',false),
(6,1,'(~p ∧ q) ∨ ~p',false),(6,2,'~(p ∧ q) ∨ ~p',false),(6,3,'~((p ∧ q) → p)',false),(6,4,'(p ∧ q) → p',true),(6,5,'(p ∧ q) ↔ ~p',false),
(7,1,'{ }',true),(7,2,'{4}',false),(7,3,'{5}',false),(7,4,'{4,5}',false),(7,5,'{1,2,3,4,5}',false),
(8,1,'ABC é um triângulo isósceles.',true),(8,2,'ABC não é um triângulo isósceles.',false),(8,3,'Todo triângulo isósceles é equilátero.',false),(8,4,'Nenhum triângulo equilátero é isósceles.',false),(8,5,'ABC não é triângulo.',false);

-- Revalidacao de precondicoes — aborta a transacao em qualquer divergencia.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 8 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 8)', v_cnt;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % enunciado(s) identicos ja existem no banco', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % unidade(s)-alvo inexistente(s) ou inativa(s)', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  join public.unidades_pedagogicas u on u.id = lq.unidade_id
  join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
  where cc.assunto_id is distinct from lq.assunto_id;
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % linha(s) com assunto_id divergente da unidade-alvo', v_dup;
  end if;
end $$;

-- Insercao das questoes + alternativas (mapeamento ordem -> id real).
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (18, r.assunto_id, r.banca, r.concurso, r.ano, r.enunciado, 'media',
            (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
            r.fonte, true, false)
    returning id into v_id;
    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_id);

    insert into public.alternativas (questao_id, texto, correta, ordem)
    select v_id, la.texto, la.correta, la.ordem_alt
    from _lote_alternativas la
    where la.ordem = r.ordem
    order by la.ordem_alt;
  end loop;
end $$;

-- Vinculos via RPC oficial.
do $$
declare r record;
begin
  for r in select m.questao_id, lq.unidade_id from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
end $$;

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia —
-- so chega ao COMMIT final se passar tudo.
do $$
declare
  v_novas_questoes int;
  v_novas_alternativas int;
  v_corretas_por_questao int;
  v_novos_vinculos int;
  v_multiunidade int;
  v_nao_ativas int;
  v_nao_real int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 8 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 8)', v_novas_questoes;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 40 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 40)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_por_questao
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_por_questao <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_por_questao;
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 8 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 8)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  select count(*) into v_nao_ativas from public.questoes where id in (select questao_id from _mapa_ids) and ativa <> true;
  if v_nao_ativas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) nao ativas', v_nao_ativas;
  end if;

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  if v_nao_real <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0, todas Fundatec)', v_nao_real;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 8 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 8';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 40 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 40';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 8 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 8';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;

  raise notice 'Pos-condicoes OK: 8 questoes REAL novas / 40 alternativas / 8 vinculos / 0 multiunidade / banca Fundatec em todas / 34 questoes antigas de RLM intactas.';
end $$;

commit;
