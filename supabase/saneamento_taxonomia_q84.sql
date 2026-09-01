-- SANEAMENTO TAXONÔMICO DEDICADO — Q84 (assunto atual 39, Condicional e
-- contrapositiva) — operacao independente, separada da futura
-- curadoria final da ordem 88 e da curadoria ja concluida da ordem 84.
--
-- Diagnostico (PROBLEMA_DE_TAXONOMIA_Q84 CONFIRMADO, auditoria da ordem
-- 88): Q84 pergunta apenas, dado que P→Q e falsa, qual afirmacao e
-- necessariamente verdadeira. A resolucao exige somente a condicao de
-- falsidade da condicional (P→Q falsa apenas quando P=V e Q=F) — nao
-- exige contrapositiva (¬Q→¬P), que Q80 e Q309 (as duas outras
-- candidatas de Condicional e contrapositiva) exigem genuinamente. O
-- aluno que domina SOMENTE a semantica do conectivo condicional (ja
-- ensinada no Eixo A de Proposicoes e conectivos, curso_conteudo_id=1,
-- ja curado na ordem 84) resolve Q84 integralmente. Habilidade nuclear
-- e do assunto 36 (Proposicoes e conectivos), nao do assunto 39
-- (Condicional e contrapositiva).
--
-- Escopo: SOMENTE Q84. NAO altera enunciado, alternativas, gabarito,
-- explicacao, banca, concurso, ano, fonte ou ativa — que permanecem
-- tecnicamente corretos. Altera apenas assunto_id (39 -> 36) e cria
-- exatamente 1 vinculo pedagogico com a unidade ja existente de
-- Proposicoes e conectivos (6683c484-74a7-4b07-9cda-1a72190e6445),
-- preservando os 4 vinculos ja existentes (Q74, Q87, Q313, Q314).
--
-- NAO toca Q80 nem Q309 (permanecem assunto_id=39, ativas, 0 vinculos)
-- nem a unidade da ordem 88 (42f5f55c-350a-4fb6-904c-184cde415d1e,
-- permanece ativa, 0 vinculos). NAO fecha a ordem 88 nem reabre a
-- ordem 84 — o historico daquela ordem permanece intacto; apenas a
-- unidade LIVE ja concluida ganha um novo vinculo posterior.
--
-- Ordem exigida pelo trigger validar_questao_unidade_pedagogica (exige
-- assunto_id da questao == assunto_id do curso_conteudo da unidade
-- alvo): primeiro muda o assunto_id, so entao cria o vinculo.
--
-- Diferenca deste arquivo para o harness de teste
-- (saneamento_taxonomia_q84_teste_rollback.sql, ja executado com
-- tudo_ok = true): termina em COMMIT, e cada precondicao/pos-condicao
-- usa RAISE EXCEPTION — qualquer divergencia aborta a transacao inteira
-- antes de confirmar.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_ativa_atual boolean;
  v_vinculos_q84 int;
  v_unidade_curso_conteudo bigint;
  v_unidade_assunto bigint;
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
  v_assunto_80 bigint;
  v_vinculos_80 int;
  v_assunto_309 bigint;
  v_vinculos_309 int;
  v_ordem88_conteudo bigint;
  v_ordem88_assunto bigint;
  v_ordem88_ativa boolean;
  v_vinculos_ordem88 int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 84;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 84 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Sabendo que a sentença condicional “Se Pedro é aluno da turma B, então Pedro está aprovado” possui valor lógico falso, podemos afirmar que é verdadeira a sentença:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 84 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if position('SÓ é falsa em uma única situação' in v_explicacao_atual) = 0
     and position('SÓ é falsa em uma unica situacao' in v_explicacao_atual) = 0
  then
    if position('Condicional Falsa (V → F)' in v_explicacao_atual) = 0 then
      raise exception 'Precondicao falhou: explicacao atual da questao 84 diverge do esperado';
    end if;
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 84 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'SUSEPE RS - Agente Penitenciário' then
    raise exception 'Precondicao falhou: concurso da questao 84 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2022 then
    raise exception 'Precondicao falhou: ano da questao 84 diverge do esperado (2022) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 39 then
    raise exception 'Precondicao falhou: assunto_id da questao 84 diverge do esperado (39) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 84 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 84 and ordem = 3 and correta = true and texto = 'Pedro é aluno da turma B.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 84 nao e a alternativa "Pedro é aluno da turma B." (ordem 3)';
  end if;
  select count(*) into v_vinculos_q84 from public.questao_unidades_pedagogicas where questao_id = 84;
  if v_vinculos_q84 <> 0 then
    raise exception 'Precondicao falhou: questao 84 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_q84;
  end if;

  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_unidade_curso_conteudo, v_unidade_assunto, v_unidade_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = '6683c484-74a7-4b07-9cda-1a72190e6445';

  if v_unidade_curso_conteudo is distinct from 1 then
    raise exception 'Precondicao falhou: unidade destino nao pertence ao curso_conteudo_id=1 (Proposicoes e conectivos) — atual: %', v_unidade_curso_conteudo;
  end if;
  if v_unidade_assunto is distinct from 36 then
    raise exception 'Precondicao falhou: assunto_id do conteudo destino diverge do esperado (36) — atual: %', v_unidade_assunto;
  end if;
  if v_unidade_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade destino nao esta ativa';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445';
  if v_vinculos_unidade <> 4 then
    raise exception 'Precondicao falhou: unidade destino nao possui exatamente 4 vinculos antes do saneamento (Q74/Q87/Q313/Q314) — atual: %', v_vinculos_unidade;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 74)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 87)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 313)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 314) then
    raise exception 'Precondicao falhou: unidade destino nao contem exatamente Q74/Q87/Q313/Q314 antes do saneamento';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 84) then
    raise exception 'Precondicao falhou: unidade destino ja possui vinculo com Q84 antes do saneamento';
  end if;

  -- Q80/Q309 (permanecem na ordem 88) e a unidade da ordem 88 devem
  -- estar intocadas antes do saneamento.
  select assunto_id into v_assunto_80 from public.questoes where id = 80;
  select count(*) into v_vinculos_80 from public.questao_unidades_pedagogicas where questao_id = 80;
  select assunto_id into v_assunto_309 from public.questoes where id = 309;
  select count(*) into v_vinculos_309 from public.questao_unidades_pedagogicas where questao_id = 309;
  if v_assunto_80 is distinct from 39 or v_vinculos_80 <> 0 or v_assunto_309 is distinct from 39 or v_vinculos_309 <> 0 then
    raise exception 'Precondicao falhou: Q80/Q309 divergem do estado esperado antes do saneamento (assunto_80=%, vinc_80=%, assunto_309=%, vinc_309=%)', v_assunto_80, v_vinculos_80, v_assunto_309, v_vinculos_309;
  end if;

  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_ordem88_conteudo, v_ordem88_assunto, v_ordem88_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = '42f5f55c-350a-4fb6-904c-184cde415d1e';
  if v_ordem88_conteudo is distinct from 6 or v_ordem88_assunto is distinct from 39 or v_ordem88_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade da ordem 88 diverge do esperado (conteudo=%, assunto=%, ativa=%)', v_ordem88_conteudo, v_ordem88_assunto, v_ordem88_ativa;
  end if;
  select count(*) into v_vinculos_ordem88 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '42f5f55c-350a-4fb6-904c-184cde415d1e';
  if v_vinculos_ordem88 <> 0 then
    raise exception 'Precondicao falhou: unidade da ordem 88 ja possui vinculo (esperado 0) — atual: %', v_vinculos_ordem88;
  end if;
end $$;

update public.questoes
   set assunto_id = 36,
       atualizado_em = now()
 where id = 84;

select public.classificar_questao_unidade_admin(84, '6683c484-74a7-4b07-9cda-1a72190e6445');

do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_total_alt int;
  v_gabarito_texto text;
  v_gabarito_ordem int;
  v_vinculos_q84 int;
  v_vinculo_correto boolean;
  v_vinculos_unidade int;
  v_qids_unidade bigint[];
  v_assunto_80 bigint;
  v_vinculos_80 int;
  v_assunto_309 bigint;
  v_vinculos_309 int;
  v_vinculos_ordem88 int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 84;

  if v_assunto is distinct from 36 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 84 nao foi atualizado para 36 — atual: %', v_assunto;
  end if;
  if v_enunciado is distinct from 'Sabendo que a sentença condicional “Se Pedro é aluno da turma B, então Pedro está aprovado” possui valor lógico falso, podemos afirmar que é verdadeira a sentença:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 84 foi alterado indevidamente';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 84 foi alterada indevidamente — atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'SUSEPE RS - Agente Penitenciário' then
    raise exception 'Pos-condicao falhou: concurso da questao 84 foi alterado indevidamente — atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2022 then
    raise exception 'Pos-condicao falhou: ano da questao 84 foi alterado indevidamente — atual: %', v_ano;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 84 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 84;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 84 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select ordem, texto into v_gabarito_ordem, v_gabarito_texto from public.alternativas where questao_id = 84 and correta = true;
  if v_gabarito_ordem is distinct from 3 or v_gabarito_texto is distinct from 'Pedro é aluno da turma B.' then
    raise exception 'Pos-condicao falhou: gabarito da questao 84 mudou (ordem=%, texto=%)', v_gabarito_ordem, v_gabarito_texto;
  end if;

  select count(*) into v_vinculos_q84 from public.questao_unidades_pedagogicas where questao_id = 84;
  if v_vinculos_q84 <> 1 then
    raise exception 'Pos-condicao falhou: questao 84 deveria possuir exatamente 1 vinculo pedagogico apos o saneamento — atual: %', v_vinculos_q84;
  end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id = 84 and unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445') into v_vinculo_correto;
  if not v_vinculo_correto then
    raise exception 'Pos-condicao falhou: o vinculo da questao 84 nao aponta para a unidade destino esperada (Proposicoes e conectivos)';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445';
  if v_vinculos_unidade <> 5 then
    raise exception 'Pos-condicao falhou: unidade destino deveria possuir exatamente 5 vinculos (Q74/Q84/Q87/Q313/Q314) apos o saneamento — atual: %', v_vinculos_unidade;
  end if;

  select array_agg(questao_id order by questao_id) into v_qids_unidade
    from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445';
  if v_qids_unidade is distinct from array[74,84,87,313,314]::bigint[] then
    raise exception 'Pos-condicao falhou: QIDs da unidade destino diferem do esperado — atual: %', v_qids_unidade;
  end if;

  -- Q80/Q309 e a unidade da ordem 88 permanecem intocadas.
  select assunto_id into v_assunto_80 from public.questoes where id = 80;
  select count(*) into v_vinculos_80 from public.questao_unidades_pedagogicas where questao_id = 80;
  select assunto_id into v_assunto_309 from public.questoes where id = 309;
  select count(*) into v_vinculos_309 from public.questao_unidades_pedagogicas where questao_id = 309;
  if v_assunto_80 is distinct from 39 or v_vinculos_80 <> 0 or v_assunto_309 is distinct from 39 or v_vinculos_309 <> 0 then
    raise exception 'Pos-condicao falhou: Q80/Q309 foram alteradas indevidamente (assunto_80=%, vinc_80=%, assunto_309=%, vinc_309=%)', v_assunto_80, v_vinculos_80, v_assunto_309, v_vinculos_309;
  end if;

  select count(*) into v_vinculos_ordem88 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '42f5f55c-350a-4fb6-904c-184cde415d1e';
  if v_vinculos_ordem88 <> 0 then
    raise exception 'Pos-condicao falhou: unidade da ordem 88 ganhou vinculo inesperado — atual: %', v_vinculos_ordem88;
  end if;

  raise notice 'Pos-condicoes OK: Q84 reclassificada para assunto_id=36 com exatamente 1 vinculo na unidade Proposicoes e conectivos (total 5: 74,84,87,313,314), Q80/Q309 e unidade da ordem 88 intocadas.';
end $$;

commit;
