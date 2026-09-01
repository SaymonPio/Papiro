-- SANEAMENTO TAXONÔMICO DEDICADO — Q314 (assunto atual 38, Tabela-verdade)
-- — operacao independente, separada da futura curadoria final da ordem 85
-- e do saneamento de fidelidade ja concluido da Q89 (commit 1eb3fa9).
--
-- Diagnostico (PROBLEMA_DE_TAXONOMIA_Q314 CONFIRMADO, auditoria da ordem
-- 85): Q314 pergunta apenas "quando P e Q e verdadeira?", cuja resposta
-- ("ambas verdadeiras") e a condicao de verdade da CONJUNCAO. O aluno que
-- domina SOMENTE Proposicoes e conectivos resolve integralmente — nao ha
-- necessidade de montar/completar/interpretar tabela-verdade. A
-- habilidade nuclear e do assunto 36 (Proposicoes e conectivos, ja
-- curado na ordem 84, curso_conteudo_id = 1), nao do assunto 38
-- (Tabela-verdade).
--
-- Escopo: SOMENTE Q314. NAO altera enunciado, alternativas, gabarito,
-- explicacao, banca, concurso, ano, fonte ou ativa — que permanecem
-- tecnicamente corretos. Altera apenas assunto_id (38 -> 36) e cria
-- exatamente 1 vinculo pedagogico com a unidade ja existente de
-- Proposicoes e conectivos (6683c484-74a7-4b07-9cda-1a72190e6445),
-- preservando os 3 vinculos ja existentes (Q74, Q87, Q313).
--
-- Ordem exigida pelo trigger validar_questao_unidade_pedagogica (exige
-- assunto_id da questao == assunto_id do curso_conteudo da unidade
-- alvo): primeiro muda o assunto_id, so entao cria o vinculo.
--
-- NAO fecha a ordem 85. NAO toca Q75 nem Q89. NAO reabre nem reaplica a
-- ordem 84 (permanece concluida no commit ec47531 como checkpoint
-- historico valido daquele momento).
--
-- Harness de teste (SEMPRE termina em ROLLBACK) — nada aqui persiste no
-- banco. Ver saneamento_taxonomia_q314.sql para a aplicacao real
-- (termina em COMMIT).

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
  v_vinculos_q314 int;
  v_unidade_curso_conteudo bigint;
  v_unidade_assunto bigint;
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 314;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 314 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Uma proposição composta P e Q é verdadeira somente quando:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 314 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if position('CONJUNÇÃO' in v_explicacao_atual) = 0
     or position('V ∧ V = V' in v_explicacao_atual) = 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 314 diverge do esperado (nao contem o raciocinio da conjuncao)';
  end if;
  if v_banca_atual is distinct from 'Papiro' then
    raise exception 'Precondicao falhou: banca da questao 314 diverge do esperado (Papiro) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Precondicao falhou: concurso da questao 314 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2026 then
    raise exception 'Precondicao falhou: ano da questao 314 diverge do esperado (2026) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 38 then
    raise exception 'Precondicao falhou: assunto_id da questao 314 diverge do esperado (38, Tabela-verdade) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 314 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 314 and ordem = 1 and correta = true and texto = 'P e Q são ambas verdadeiras.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 314 nao e a alternativa "P e Q são ambas verdadeiras." (ordem 1)';
  end if;

  select count(*) into v_vinculos_q314 from public.questao_unidades_pedagogicas where questao_id = 314;
  if v_vinculos_q314 <> 0 then
    raise exception 'Precondicao falhou: questao 314 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_q314;
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
  if v_vinculos_unidade <> 3 then
    raise exception 'Precondicao falhou: unidade destino nao possui exatamente 3 vinculos antes do saneamento (Q74/Q87/Q313) — atual: %', v_vinculos_unidade;
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 314) then
    raise exception 'Precondicao falhou: unidade destino ja possui vinculo com Q314 antes do saneamento';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 74)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 87)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 313) then
    raise exception 'Precondicao falhou: unidade destino nao contem exatamente Q74/Q87/Q313 antes do saneamento';
  end if;
end $$;

update public.questoes
   set assunto_id = 36,
       atualizado_em = now()
 where id = 314;

select public.classificar_questao_unidade_admin(314, '6683c484-74a7-4b07-9cda-1a72190e6445');

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
  v_vinculos_q314 int;
  v_vinculo_correto boolean;
  v_vinculos_unidade int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 314;

  if v_assunto is distinct from 36 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 314 nao foi atualizado para 36 — atual: %', v_assunto;
  end if;
  if v_enunciado is distinct from 'Uma proposição composta P e Q é verdadeira somente quando:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 314 foi alterado indevidamente — atual: %', v_enunciado;
  end if;
  if position('CONJUNÇÃO' in v_explicacao) = 0 or position('V ∧ V = V' in v_explicacao) = 0 then
    raise exception 'Pos-condicao falhou: explicacao da questao 314 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Papiro' then
    raise exception 'Pos-condicao falhou: banca da questao 314 foi alterada indevidamente — atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Pos-condicao falhou: concurso da questao 314 foi alterado indevidamente — atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 314 foi alterado indevidamente — atual: %', v_ano;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 314 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 314;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 314 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select ordem, texto into v_gabarito_ordem, v_gabarito_texto from public.alternativas where questao_id = 314 and correta = true;
  if v_gabarito_ordem is distinct from 1 or v_gabarito_texto is distinct from 'P e Q são ambas verdadeiras.' then
    raise exception 'Pos-condicao falhou: gabarito da questao 314 mudou (ordem=%, texto=%)', v_gabarito_ordem, v_gabarito_texto;
  end if;

  select count(*) into v_vinculos_q314 from public.questao_unidades_pedagogicas where questao_id = 314;
  if v_vinculos_q314 <> 1 then
    raise exception 'Pos-condicao falhou: questao 314 deveria possuir exatamente 1 vinculo pedagogico apos o saneamento — atual: %', v_vinculos_q314;
  end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id = 314 and unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445') into v_vinculo_correto;
  if not v_vinculo_correto then
    raise exception 'Pos-condicao falhou: o vinculo da questao 314 nao aponta para a unidade destino esperada (Proposicoes e conectivos)';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445';
  if v_vinculos_unidade <> 4 then
    raise exception 'Pos-condicao falhou: unidade destino deveria possuir exatamente 4 vinculos (Q74/Q87/Q313/Q314) apos o saneamento — atual: %', v_vinculos_unidade;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 74)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 87)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445' and questao_id = 313) then
    raise exception 'Pos-condicao falhou: unidade destino perdeu um dos vinculos preexistentes (Q74/Q87/Q313)';
  end if;

  raise notice 'tudo_ok = true — Q314 reclassificada para assunto_id=36 com exatamente 1 vinculo na unidade Proposicoes e conectivos, unidade destino com 4 vinculos totais (Q74/Q87/Q313/Q314), conteudo/gabarito/metadados de Q314 inalterados.';
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
