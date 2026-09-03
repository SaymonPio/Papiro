-- Harness de teste (SEMPRE termina em ROLLBACK) do saneamento documental
-- da Q351 (Direitos Humanos e Cidadania, assunto_id=99, "Tratados de
-- Direitos Humanos com força de Emenda Constitucional").
--
-- Escopo estritamente limitado: UPDATE do campo `explicacao` de UMA UNICA
-- questao (id=351). NAO altera enunciado, alternativas, ordem, gabarito
-- (correta), banca, concurso, ano, fonte, assunto_id, ativa. NAO cria
-- vinculo — Q351 permanece sem vinculo pedagogico apos este saneamento.
--
-- Motivo do saneamento: a explicacao armazenada descrevia o Art. 16 da
-- Convencao sobre os Direitos das Pessoas com Deficiencia (protecao
-- contra exploracao/violencia/abuso), mas as 5 alternativas reais da
-- questao tratam de outros dispositivos (adaptacao razoavel x desenho
-- universal; direito de opiniao da crianca com deficiencia, art. 7 §3;
-- acessibilidade como principio, art. 3 f; medidas especificas nao
-- discriminatorias, art. 5 §4; definicao de discriminacao por
-- deficiencia). O gabarito (alternativa de ordem 2) foi recalculado
-- independentemente e confirmado correto — o defeito estava exclusivamente
-- na explicacao, nao no gabarito.
--
-- Termina SEMPRE em ROLLBACK — nada aqui persiste no banco.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select id, ativa, assunto_id, banca, concurso, ano, fonte, enunciado, explicacao,
  (select count(*) from public.alternativas where questao_id = 351) as n_alt,
  (select array_agg(ordem order by ordem) from public.alternativas where questao_id = 351) as ordens,
  (select array_agg(texto order by ordem) from public.alternativas where questao_id = 351) as textos,
  (select ordem from public.alternativas where questao_id = 351 and correta) as ordem_correta,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 351) as vinculos
from public.questoes
where id = 351;

create temporary table _total_sistema_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos;

-- Precondicoes.
do $$
declare v_cnt int;
begin
  if not exists (select 1 from _snapshot_antes where id = 351) then
    raise exception 'Precondicao falhou: Q351 nao encontrada';
  end if;
  if not exists (select 1 from _snapshot_antes where ativa = true) then
    raise exception 'Precondicao falhou: Q351 nao esta ativa';
  end if;
  if not exists (select 1 from _snapshot_antes where n_alt = 5) then
    raise exception 'Precondicao falhou: Q351 nao tem exatamente 5 alternativas';
  end if;
  if not exists (select 1 from _snapshot_antes where ordem_correta = 2) then
    raise exception 'Precondicao falhou: alternativa correta nao e a de ordem 2';
  end if;
  if not exists (select 1 from _snapshot_antes where vinculos = 0) then
    raise exception 'Precondicao falhou: Q351 ja possui vinculo — este saneamento pressupoe questao ainda sem vinculo';
  end if;
end $$;

-- Aplicacao do UPDATE (apenas explicacao).
update public.questoes
set explicacao = E'GABARITO: alternativa 2 (a segunda das cinco alternativas)\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o Art. 7º, §3º, da Convenção Internacional sobre os Direitos das Pessoas com Deficiência (Decreto nº 6.949/2009, com status de emenda constitucional pelo rito do art. 5º, §3º, da CF): os Estados Partes assegurarão que as crianças com deficiência tenham o direito de expressar livremente sua opinião sobre todos os assuntos que lhes disserem respeito, tenham essa opinião devidamente valorizada de acordo com sua idade e maturidade, em igualdade de oportunidades com as demais crianças, e recebam atendimento adequado à sua deficiência e idade para que possam exercer tal direito.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa 1: descreve, na verdade, a definição de ADAPTAÇÃO RAZOÁVEL (Art. 2º da Convenção) — as modificações e ajustes necessários e adequados, sem ônus desproporcional, para assegurar às pessoas com deficiência o gozo dos direitos humanos em igualdade de condições. DESENHO UNIVERSAL é conceito distinto: concepção de produtos, ambientes, programas e serviços a serem usados por todos, na maior medida possível, sem necessidade de adaptação ou projeto específico.\nAlternativa 3: a acessibilidade é, sim, um dos princípios gerais da Convenção, previsto expressamente no Art. 3º, alínea "f".\nAlternativa 4: o Art. 5º, §4º, da Convenção estabelece o oposto — as medidas específicas necessárias para acelerar ou alcançar a efetiva igualdade das pessoas com deficiência NÃO serão consideradas discriminatórias, ou seja, são expressamente permitidas, não vedadas.\nAlternativa 5: a definição de "discriminação por motivo de deficiência" (Art. 2º) abrange todas as formas de discriminação, INCLUSIVE a recusa de adaptação razoável — e não a excetua, como afirma a alternativa.\n\nBIZU DE PROVA:\nMemorize o par de conceitos que a banca gosta de trocar: ADAPTAÇÃO RAZOÁVEL (ajuste sob medida, caso a caso) × DESENHO UNIVERSAL (concepção já acessível a todos, sem necessidade de ajuste posterior). E lembre-se: a Convenção sempre trata medidas afirmativas e a recusa de adaptação razoável como favoráveis à inclusão das pessoas com deficiência — nunca como proibidas ou excluídas do conceito de discriminação.'
where id = 351;

-- Pos-condicoes.
do $$
declare
  v_explicacao_mudou boolean;
  v_enunciado_igual boolean;
  v_alt_intactas int;
  v_ordem_correta int;
  v_n_alt int;
  v_vinculos int;
  v_ativa boolean;
  v_assunto_id bigint;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_fonte text;
begin
  select
    (q.explicacao is distinct from sa.explicacao),
    (q.enunciado = sa.enunciado),
    q.ativa, q.assunto_id, q.banca, q.concurso, q.ano, q.fonte
  into v_explicacao_mudou, v_enunciado_igual, v_ativa, v_assunto_id, v_banca, v_concurso, v_ano, v_fonte
  from public.questoes q, _snapshot_antes sa
  where q.id = 351 and sa.id = 351;

  if not v_explicacao_mudou then
    raise exception 'Pos-condicao falhou: explicacao nao foi alterada';
  end if;
  if not v_enunciado_igual then
    raise exception 'Pos-condicao falhou: enunciado foi alterado indevidamente';
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa mudou (esperado true)';
  end if;
  if v_assunto_id is distinct from 99 then
    raise exception 'Pos-condicao falhou: assunto_id mudou (esperado 99, obtido %)', v_assunto_id;
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca mudou (esperado Fundatec, obtido %)', v_banca;
  end if;
  if v_concurso is distinct from 'Corpo de Bombeiros Militar RS - Soldado de Primeira Classe' then
    raise exception 'Pos-condicao falhou: concurso mudou (obtido %)', v_concurso;
  end if;
  if v_ano is distinct from 2025 then
    raise exception 'Pos-condicao falhou: ano mudou (obtido %)', v_ano;
  end if;
  if v_fonte is distinct from 'Fundatec — CBMRS Soldado de Primeira Classe 2025 — Questão 61' then
    raise exception 'Pos-condicao falhou: fonte mudou (obtido %)', v_fonte;
  end if;

  select count(*) into v_n_alt from public.alternativas where questao_id = 351;
  if v_n_alt <> 5 then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou (esperado 5, obtido %)', v_n_alt;
  end if;

  select count(*) into v_alt_intactas
  from public.alternativas a
  join (select unnest((select ordens from _snapshot_antes)) as ordem, unnest((select textos from _snapshot_antes)) as texto) s
    on s.ordem = a.ordem and s.texto = a.texto
  where a.questao_id = 351;
  if v_alt_intactas <> 5 then
    raise exception 'Pos-condicao falhou: texto/ordem de alguma alternativa foi alterado (esperado 5 intactas, obtido %)', v_alt_intactas;
  end if;

  select ordem into v_ordem_correta from public.alternativas where questao_id = 351 and correta;
  if v_ordem_correta is distinct from 2 then
    raise exception 'Pos-condicao falhou: alternativa correta mudou (esperado ordem 2, obtido %)', v_ordem_correta;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 351;
  if v_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: Q351 ganhou vinculo indevido (esperado 0, obtido %)', v_vinculos;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _total_sistema_antes) then
    raise exception 'Pos-condicao falhou: contagem total de questoes mudou (nao deveria, e um UPDATE)';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _total_sistema_antes) then
    raise exception 'Pos-condicao falhou: contagem total de alternativas mudou';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _total_sistema_antes) then
    raise exception 'Pos-condicao falhou: contagem total de vinculos mudou';
  end if;

  raise notice 'Pos-condicoes OK: apenas explicacao de Q351 mudou; enunciado, 5 alternativas (texto/ordem), alternativa correta (ordem 2), banca, concurso, ano, fonte, assunto_id, ativa e vinculos (0) permanecem intactos.';
end $$;

rollback;
