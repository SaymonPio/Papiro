-- SANEAMENTO TAXONÔMICO DEDICADO — Q287 (assunto atual 33,
-- Quantificadores) — operacao independente, separada da futura
-- curadoria final da ordem 89 e da curadoria ja concluida da ordem 83.
--
-- Diagnostico (PROBLEMA_DE_TAXONOMIA_Q287 CONFIRMADO, auditoria da
-- ordem 89): Q287 pergunta "a negacao logica de 'Todos os candidatos
-- foram aprovados' e:" — a transformacao exigida e exatamente
-- ¬∀x P(x) ≡ ∃x ¬P(x), ja explicitamente coberta pelo Eixo A da
-- unidade LIVE de Negacao de proposicoes (curso_conteudo_id=3, ja
-- curada na ordem 83). Q287 e estruturalmente da mesma familia de Q81
-- (negacao de universal, ja vinculada la) e Q86 (negacao de
-- existencial, tambem ja vinculada la). O aluno que domina SOMENTE a
-- regra de negacao de proposicoes quantificadas (ja ensinada em
-- Negacao) resolve Q287 integralmente, sem precisar de nenhuma
-- competencia adicional de "Quantificadores" (avaliar verdade sobre
-- dominio explicito, reconhecer tipo de quantificador). Habilidade
-- nuclear e do assunto 35 (Negacao de proposicoes), nao do assunto 33
-- (Quantificadores).
--
-- Escopo: SOMENTE Q287. NAO altera enunciado, alternativas, gabarito,
-- explicacao, banca, concurso, ano, fonte ou ativa — que permanecem
-- tecnicamente corretos. Altera apenas assunto_id (33 -> 35) e cria
-- exatamente 1 vinculo pedagogico com a unidade ja existente de
-- Negacao de proposicoes (c6ccefae-14df-4760-8c1d-2822090a2a93),
-- preservando os 7 vinculos ja existentes (Q77, Q81, Q86, Q88, Q311,
-- Q312, Q337).
--
-- NAO toca Q83 nem Q288 (permanecem assunto_id=33, ativas, 0 vinculos)
-- nem a unidade da ordem 89 (b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c,
-- permanece ativa, 0 vinculos). NAO fecha a ordem 89 nem reabre a
-- ordem 83 — o historico daquela ordem permanece intacto; apenas a
-- unidade LIVE ja concluida ganha um novo vinculo posterior.
--
-- Ordem exigida pelo trigger validar_questao_unidade_pedagogica (exige
-- assunto_id da questao == assunto_id do curso_conteudo da unidade
-- alvo): primeiro muda o assunto_id, so entao cria o vinculo.
--
-- Diferenca deste arquivo para o harness de teste
-- (saneamento_taxonomia_q287_teste_rollback.sql, ja executado com
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
  v_vinculos_q287 int;
  v_unidade_curso_conteudo bigint;
  v_unidade_assunto bigint;
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
  v_assunto_83 bigint;
  v_vinculos_83 int;
  v_assunto_288 bigint;
  v_vinculos_288 int;
  v_ordem89_conteudo bigint;
  v_ordem89_assunto bigint;
  v_ordem89_ativa boolean;
  v_vinculos_ordem89 int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 287;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 287 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'A negação lógica de “Todos os candidatos foram aprovados” é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 287 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if position('Negação do TODO' in v_explicacao_atual) = 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 287 diverge do esperado';
  end if;
  if v_banca_atual is distinct from 'Papiro' then
    raise exception 'Precondicao falhou: banca da questao 287 diverge do esperado (Papiro) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Precondicao falhou: concurso da questao 287 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2026 then
    raise exception 'Precondicao falhou: ano da questao 287 diverge do esperado (2026) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 33 then
    raise exception 'Precondicao falhou: assunto_id da questao 287 diverge do esperado (33) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 287 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 287 and ordem = 1 and correta = true and texto = 'Pelo menos um candidato não foi aprovado.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 287 nao e a alternativa "Pelo menos um candidato não foi aprovado." (ordem 1)';
  end if;
  select count(*) into v_vinculos_q287 from public.questao_unidades_pedagogicas where questao_id = 287;
  if v_vinculos_q287 <> 0 then
    raise exception 'Precondicao falhou: questao 287 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_q287;
  end if;

  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_unidade_curso_conteudo, v_unidade_assunto, v_unidade_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';

  if v_unidade_curso_conteudo is distinct from 3 then
    raise exception 'Precondicao falhou: unidade destino nao pertence ao curso_conteudo_id=3 (Negacao de proposicoes) — atual: %', v_unidade_curso_conteudo;
  end if;
  if v_unidade_assunto is distinct from 35 then
    raise exception 'Precondicao falhou: assunto_id do conteudo destino diverge do esperado (35) — atual: %', v_unidade_assunto;
  end if;
  if v_unidade_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade destino nao esta ativa';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_unidade <> 7 then
    raise exception 'Precondicao falhou: unidade destino nao possui exatamente 7 vinculos antes do saneamento — atual: %', v_vinculos_unidade;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 77)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 81)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 86)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 88)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 311)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 312)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 337) then
    raise exception 'Precondicao falhou: unidade destino nao contem exatamente Q77/Q81/Q86/Q88/Q311/Q312/Q337 antes do saneamento';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 287) then
    raise exception 'Precondicao falhou: unidade destino ja possui vinculo com Q287 antes do saneamento';
  end if;

  -- Q83/Q288 (permanecem na ordem 89) e a unidade da ordem 89 devem
  -- estar intocadas antes do saneamento.
  select assunto_id into v_assunto_83 from public.questoes where id = 83;
  select count(*) into v_vinculos_83 from public.questao_unidades_pedagogicas where questao_id = 83;
  select assunto_id into v_assunto_288 from public.questoes where id = 288;
  select count(*) into v_vinculos_288 from public.questao_unidades_pedagogicas where questao_id = 288;
  if v_assunto_83 is distinct from 33 or v_vinculos_83 <> 0 or v_assunto_288 is distinct from 33 or v_vinculos_288 <> 0 then
    raise exception 'Precondicao falhou: Q83/Q288 divergem do estado esperado antes do saneamento (assunto_83=%, vinc_83=%, assunto_288=%, vinc_288=%)', v_assunto_83, v_vinculos_83, v_assunto_288, v_vinculos_288;
  end if;

  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_ordem89_conteudo, v_ordem89_assunto, v_ordem89_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c';
  if v_ordem89_conteudo is distinct from 7 or v_ordem89_assunto is distinct from 33 or v_ordem89_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade da ordem 89 diverge do esperado (conteudo=%, assunto=%, ativa=%)', v_ordem89_conteudo, v_ordem89_assunto, v_ordem89_ativa;
  end if;
  select count(*) into v_vinculos_ordem89 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c';
  if v_vinculos_ordem89 <> 0 then
    raise exception 'Precondicao falhou: unidade da ordem 89 ja possui vinculo (esperado 0) — atual: %', v_vinculos_ordem89;
  end if;
end $$;

update public.questoes
   set assunto_id = 35,
       atualizado_em = now()
 where id = 287;

select public.classificar_questao_unidade_admin(287, 'c6ccefae-14df-4760-8c1d-2822090a2a93');

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
  v_vinculos_q287 int;
  v_vinculo_correto boolean;
  v_vinculos_unidade int;
  v_qids_unidade bigint[];
  v_assunto_83 bigint;
  v_vinculos_83 int;
  v_assunto_288 bigint;
  v_vinculos_288 int;
  v_vinculos_ordem89 int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 287;

  if v_assunto is distinct from 35 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 287 nao foi atualizado para 35 — atual: %', v_assunto;
  end if;
  if v_enunciado is distinct from 'A negação lógica de “Todos os candidatos foram aprovados” é:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 287 foi alterado indevidamente';
  end if;
  if v_banca is distinct from 'Papiro' then
    raise exception 'Pos-condicao falhou: banca da questao 287 foi alterada indevidamente — atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' then
    raise exception 'Pos-condicao falhou: concurso da questao 287 foi alterado indevidamente — atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 287 foi alterado indevidamente — atual: %', v_ano;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 287 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 287;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 287 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select ordem, texto into v_gabarito_ordem, v_gabarito_texto from public.alternativas where questao_id = 287 and correta = true;
  if v_gabarito_ordem is distinct from 1 or v_gabarito_texto is distinct from 'Pelo menos um candidato não foi aprovado.' then
    raise exception 'Pos-condicao falhou: gabarito da questao 287 mudou (ordem=%, texto=%)', v_gabarito_ordem, v_gabarito_texto;
  end if;

  select count(*) into v_vinculos_q287 from public.questao_unidades_pedagogicas where questao_id = 287;
  if v_vinculos_q287 <> 1 then
    raise exception 'Pos-condicao falhou: questao 287 deveria possuir exatamente 1 vinculo pedagogico apos o saneamento — atual: %', v_vinculos_q287;
  end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id = 287 and unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93') into v_vinculo_correto;
  if not v_vinculo_correto then
    raise exception 'Pos-condicao falhou: o vinculo da questao 287 nao aponta para a unidade destino esperada (Negacao de proposicoes)';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_unidade <> 8 then
    raise exception 'Pos-condicao falhou: unidade destino deveria possuir exatamente 8 vinculos apos o saneamento — atual: %', v_vinculos_unidade;
  end if;

  select array_agg(questao_id order by questao_id) into v_qids_unidade
    from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_qids_unidade is distinct from array[77,81,86,88,287,311,312,337]::bigint[] then
    raise exception 'Pos-condicao falhou: QIDs da unidade destino diferem do esperado — atual: %', v_qids_unidade;
  end if;

  -- Q83/Q288 e a unidade da ordem 89 permanecem intocadas.
  select assunto_id into v_assunto_83 from public.questoes where id = 83;
  select count(*) into v_vinculos_83 from public.questao_unidades_pedagogicas where questao_id = 83;
  select assunto_id into v_assunto_288 from public.questoes where id = 288;
  select count(*) into v_vinculos_288 from public.questao_unidades_pedagogicas where questao_id = 288;
  if v_assunto_83 is distinct from 33 or v_vinculos_83 <> 0 or v_assunto_288 is distinct from 33 or v_vinculos_288 <> 0 then
    raise exception 'Pos-condicao falhou: Q83/Q288 foram alteradas indevidamente (assunto_83=%, vinc_83=%, assunto_288=%, vinc_288=%)', v_assunto_83, v_vinculos_83, v_assunto_288, v_vinculos_288;
  end if;

  select count(*) into v_vinculos_ordem89 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c';
  if v_vinculos_ordem89 <> 0 then
    raise exception 'Pos-condicao falhou: unidade da ordem 89 ganhou vinculo inesperado — atual: %', v_vinculos_ordem89;
  end if;

  raise notice 'Pos-condicoes OK: Q287 reclassificada para assunto_id=35 com exatamente 1 vinculo na unidade Negacao de proposicoes (total 8: 77,81,86,88,287,311,312,337), Q83/Q288 e unidade da ordem 89 intocadas.';
end $$;

commit;
