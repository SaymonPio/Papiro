-- SANEAMENTO TAXONOMICO Q279 — REESCRITA (assunto_id 49) -> CONECTORES
-- (assunto_id 57, curso_conteudo_id 14, ja concluido). Operacao propria,
-- separada, seguindo o mesmo padrao da Operacao C de Coesao textual
-- (correcao do assunto_id de Q683: 47->55), que e o precedente tecnico
-- para mover assunto_id ANTES de vincular, pois o trigger
-- validar_questao_unidade_pedagogica bloqueia vinculo com assunto_id
-- divergente.
--
-- Motivo: microauditoria confirmou que Q279 ("Assinale a reescrita que
-- mantem o sentido de 'Embora estivesse cansado, continuou estudando'")
-- e resolvida integralmente por reconhecimento do valor semantico de
-- conectores/locucoes (relacao concessiva x causal x condicional x
-- conclusiva x negacao do fato pressuposto) — habilidade pedagogicamente
-- indistinguivel de Q121 e Q334, ja classificadas em Conectores. Nao ha
-- operacao propria de "reescrita" (transposicao de voz, mudanca de
-- sujeito/objeto) exigida para chegar ao gabarito. PROBLEMA_DE_TAXONOMIA_Q279,
-- nao QUESTAO_HIBRIDA_MULTICONTEUDO — questao especifica e vinculavel,
-- apenas estava no assunto errado.
--
-- Q279 e AUTORAL_PAPIRO — sua entrada em Conectores NAO aumenta
-- incidencia real/frequencia Fundatec/recorrencia; aumenta apenas massa
-- de pratica autoral. Explicacao ja revisada e confirmada correta
-- (gramatical e semanticamente) — NAO alterada nesta operacao.
--
-- Altera SOMENTE questoes.assunto_id da questao 279 e cria 1 vinculo
-- pedagogico novo (via RPC oficial). Enunciado, alternativas, gabarito,
-- explicacao, banca, concurso, ano, fonte, ativa e os 5 vinculos
-- pre-existentes de Conectores (Q67, Q121, Q305, Q316, Q334) sao
-- verificados como inalterados nas pos-condicoes.
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

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_ativa_atual boolean;
  v_vinculos_q279 int;
  v_vinculos_conectores int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 279;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 279 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Assinale a reescrita que mantém o sentido de “Embora estivesse cansado, continuou estudando”.' then
    raise exception 'Precondicao falhou: enunciado atual da questao 279 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A oração original "Embora estivesse cansado, continuou estudando" é estruturada por uma oração subordinada adverbial CONCESSIVA ("Embora estivesse cansado"). A locução "Mesmo estando cansado" (com gerúndio precedido de operador concessivo "mesmo") preserva integralmente o sentido original de ressalva/concessão e a relação de coerência do período.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Altera o sentido ao introduzir valor de causa ("Como estava cansado") e inverter o desfecho ("deixou de estudar").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Altera o sentido original para relação de causa e conclusão ("por isso não estudou").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Altera o sentido para uma hipótese/condição ("Se estivesse cansado...").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirma categoricamente que ele não estava cansado, contrariando o fato expresso no texto original.

BIZU DE PROVA:
Reescritas de CONCESSÃO (ideia de obstáculo superado):
"Embora estivesse cansado..." = "Mesmo estando cansado..." = "Ainda que estivesse cansado..." = "Apesar de estar cansado..." = "Conquanto estivesse cansado...". Todas mantêm o valor concessivo!' then
    raise exception 'Precondicao falhou: explicacao atual da questao 279 diverge do esperado';
  end if;
  if v_banca_atual is distinct from 'Papiro' then
    raise exception 'Precondicao falhou: banca da questao 279 diverge do esperado (Papiro) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Precondicao falhou: concurso da questao 279 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2026 then
    raise exception 'Precondicao falhou: ano da questao 279 diverge do esperado (2026) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 49 then
    raise exception 'Precondicao falhou: assunto_id atual da questao 279 diverge do esperado (49) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 279 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 279 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 279 nao e a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos_q279 from public.questao_unidades_pedagogicas where questao_id = 279;
  if v_vinculos_q279 <> 0 then
    raise exception 'Precondicao falhou: questao 279 ja possui % vinculo(s) pedagogico(s) (esperado 0)', v_vinculos_q279;
  end if;

  -- Confirma estado da unidade de Conectores e dos 5 vinculos ja aprovados.
  if not exists (select 1 from public.unidades_pedagogicas where id = 'd1e31767-d27d-431b-ba59-7a2008c7473d' and curso_conteudo_id = 14 and ordem = 1 and ativa) then
    raise exception 'Precondicao falhou: unidade de Conectores nao confere (id/ordem/conteudo/ativa)';
  end if;

  select count(*) into v_vinculos_conectores
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 14;
  if v_vinculos_conectores <> 5 then
    raise exception 'Precondicao falhou: Conectores possui % vinculo(s) (esperado 5, antes desta operacao)', v_vinculos_conectores;
  end if;

  if (select count(distinct qup.questao_id)
        from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
        where u.curso_conteudo_id = 14 and qup.questao_id in (67,121,305,316,334)) <> 5 then
    raise exception 'Precondicao falhou: os 5 vinculos esperados de Conectores (67,121,305,316,334) nao conferem exatamente';
  end if;
end $$;

-- Correcao taxonomica: move Q279 do assunto de Reescrita (49) para o
-- assunto de Conectores (57). Pre-requisito tecnico para o trigger
-- validar_questao_unidade_pedagogica permitir o vinculo a seguir.
update public.questoes
   set assunto_id = 57,
       atualizado_em = now()
 where id = 279;

do $$
begin
  if not exists (select 1 from public.questoes where id = 279 and assunto_id = 57) then
    raise exception 'Pos-condicao (intermediaria) falhou: assunto_id da questao 279 nao foi atualizado para 57';
  end if;
end $$;

-- Criacao do vinculo pedagogico via RPC oficial (agora permitido pelo
-- trigger, pois materia_id e assunto_id conferem com a unidade).
select public.classificar_questao_unidade_admin(279, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid);

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia —
-- so chega ao COMMIT final se passar tudo.
do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_gabarito_ok boolean;
  v_total_alt int;
  v_vinculos_q279 int;
  v_total_vinculos_conectores int;
  v_questoes_distintas_conectores int;
  v_vinculos_antigos_intactos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 279;

  if v_enunciado is distinct from 'Assinale a reescrita que mantém o sentido de “Embora estivesse cansado, continuou estudando”.' then
    raise exception 'Pos-condicao falhou: enunciado da questao 279 foi alterado indevidamente';
  end if;
  if v_explicacao is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A oração original "Embora estivesse cansado, continuou estudando" é estruturada por uma oração subordinada adverbial CONCESSIVA ("Embora estivesse cansado"). A locução "Mesmo estando cansado" (com gerúndio precedido de operador concessivo "mesmo") preserva integralmente o sentido original de ressalva/concessão e a relação de coerência do período.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Altera o sentido ao introduzir valor de causa ("Como estava cansado") e inverter o desfecho ("deixou de estudar").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Altera o sentido original para relação de causa e conclusão ("por isso não estudou").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Altera o sentido para uma hipótese/condição ("Se estivesse cansado...").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirma categoricamente que ele não estava cansado, contrariando o fato expresso no texto original.

BIZU DE PROVA:
Reescritas de CONCESSÃO (ideia de obstáculo superado):
"Embora estivesse cansado..." = "Mesmo estando cansado..." = "Ainda que estivesse cansado..." = "Apesar de estar cansado..." = "Conquanto estivesse cansado...". Todas mantêm o valor concessivo!' then
    raise exception 'Pos-condicao falhou: explicacao da questao 279 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Papiro' then
    raise exception 'Pos-condicao falhou: banca da questao 279 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Pos-condicao falhou: concurso da questao 279 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 279 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 57 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 279 nao e 57 (esperado apos correcao taxonomica) — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 279 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 279;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 279 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 279 and ordem = 1 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 279 nao e mais a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos_q279 from public.questao_unidades_pedagogicas where questao_id = 279;
  if v_vinculos_q279 <> 1 then
    raise exception 'Pos-condicao falhou: questao 279 possui % vinculo(s) (esperado exatamente 1)', v_vinculos_q279;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 279 and unidade_pedagogica_id = 'd1e31767-d27d-431b-ba59-7a2008c7473d') then
    raise exception 'Pos-condicao falhou: o vinculo da questao 279 nao aponta para a unidade de Conectores';
  end if;
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 279 and u.curso_conteudo_id = 21
  ) then
    raise exception 'Pos-condicao falhou: a questao 279 ainda possui vinculo no conteudo de Reescrita (21)';
  end if;

  select count(*) into v_total_vinculos_conectores
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 14;
  if v_total_vinculos_conectores <> 6 then
    raise exception 'Pos-condicao falhou: total de vinculos de Conectores=% (esperado 6)', v_total_vinculos_conectores;
  end if;

  select count(distinct qup.questao_id) into v_questoes_distintas_conectores
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 14;
  if v_questoes_distintas_conectores <> 6 then
    raise exception 'Pos-condicao falhou: questoes distintas de Conectores=% (esperado 6)', v_questoes_distintas_conectores;
  end if;

  select count(*) into v_vinculos_antigos_intactos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 14 and qup.questao_id in (67,121,305,316,334);
  if v_vinculos_antigos_intactos <> 5 then
    raise exception 'Pos-condicao falhou: os 5 vinculos antigos de Conectores nao estao todos intactos (encontrados: %)', v_vinculos_antigos_intactos;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 14) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 14 mudou (deveria continuar 1)';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou (nenhuma unidade nova deveria ter sido criada)';
  end if;
  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos do sistema nao cresceu exatamente 1';
  end if;

  raise notice 'Pos-condicoes OK: questao 279 movida para assunto_id=57 (Conectores), vinculada exatamente 1 vez a unidade d1e31767-d27d-431b-ba59-7a2008c7473d, sem vinculo remanescente em Reescrita, os 5 vinculos antigos de Conectores (67,121,305,316,334) permanecem intactos, enunciado/explicacao/alternativas/gabarito/proveniencia/ativa inalterados.';
end $$;

commit;
