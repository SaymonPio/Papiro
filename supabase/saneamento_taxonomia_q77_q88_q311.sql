-- SANEAMENTO TAXONÔMICO DEDICADO — Q77 + Q88 + Q311 (assunto atual 34,
-- Leis de De Morgan) — operacao independente, separada do fechamento da
-- ordem 86 e de qualquer decisao estrutural futura sobre a unidade de
-- De Morgan (curso_conteudo_id=4).
--
-- Diagnostico (PROBLEMA_DE_TAXONOMIA_Q77/Q88/Q311 CONFIRMADO com alta
-- confianca, auditoria da ordem 86): as tres questoes exercitam
-- exatamente a mesma habilidade ja consolidada e aprovada no Eixo B da
-- unidade de Negacao de proposicoes (¬(P∧Q)≡¬P∨¬Q, trocar E<->OU,
-- resolver dupla negacao quando um termo ja vem negado — caso de Q77,
-- identico ao que Q337 ja cobre). O fato de Q77/Q88 mencionarem "Leis
-- de De Morgan" no comando nao cria habilidade cognitiva adicional —
-- criterio: habilidade nuclear que decide o gabarito, nao o texto do
-- comando. Q311 e a forma abstrata pura da mesma regra de Q312, ja
-- classificada em Negacao.
--
-- Escopo: SOMENTE Q77, Q88, Q311. NAO altera enunciado, alternativas,
-- gabarito, explicacao, banca, concurso, ano, fonte ou ativa — que
-- permanecem tecnicamente corretos. Altera apenas assunto_id (34 -> 35)
-- e cria exatamente 1 vinculo por questao com a unidade ja existente de
-- Negacao de proposicoes (c6ccefae-14df-4760-8c1d-2822090a2a93),
-- preservando os 4 vinculos ja existentes (Q81, Q86, Q312, Q337).
-- Operacao atomica: as 3 questoes migram juntas dentro da mesma
-- transacao, ou nenhuma migra (qualquer RAISE EXCEPTION aborta tudo).
--
-- Cronologia: a ordem 83 (Negacao de proposicoes) permanece
-- historicamente concluida (fila e commit anteriores nao sao
-- reabertos/reaplicados). Q77/Q88/Q311 sao reclassificadas
-- posteriormente, nesta operacao dedicada, durante a auditoria da
-- ordem 86, apos confirmacao de sobreposicao curricular. O estado LIVE
-- da unidade de Negacao passa de 4 para 7 vinculos a partir deste
-- commit.
--
-- NAO toca a unidade de De Morgan (5ad41c42-25b4-4853-b328-b562a9fc8076,
-- curso_conteudo_id=4) — permanece ativa, com 0 vinculos, titulo/escopo
-- inalterados. A decisao estrutural sobre o futuro dessa unidade e
-- separada e posterior a este saneamento. NAO fecha a ordem 86: apos
-- este apply, assunto_id=34 fica com 0 candidatas ativas.
--
-- Diferenca deste arquivo para o harness de teste
-- (saneamento_taxonomia_q77_q88_q311_teste_rollback.sql, ja executado
-- com tudo_ok = true): termina em COMMIT, e cada precondicao/
-- pos-condicao usa RAISE EXCEPTION — qualquer divergencia aborta a
-- transacao inteira antes de confirmar.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_77 text; v_explicacao_77 text; v_banca_77 text; v_concurso_77 text; v_ano_77 int; v_assunto_77 bigint; v_ativa_77 boolean; v_vinculos_77 int;
  v_enunciado_88 text; v_explicacao_88 text; v_banca_88 text; v_concurso_88 text; v_ano_88 int; v_assunto_88 bigint; v_ativa_88 boolean; v_vinculos_88 int;
  v_enunciado_311 text; v_explicacao_311 text; v_banca_311 text; v_concurso_311 text; v_ano_311 int; v_assunto_311 bigint; v_ativa_311 boolean; v_vinculos_311 int;
  v_unidade_conteudo bigint;
  v_unidade_assunto bigint;
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
  v_demorgan_conteudo bigint;
  v_demorgan_assunto bigint;
  v_demorgan_ativa boolean;
  v_vinculos_demorgan int;
begin
  -- Q77
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_77, v_explicacao_77, v_banca_77, v_concurso_77, v_ano_77, v_assunto_77, v_ativa_77
    from public.questoes where id = 77;
  if v_enunciado_77 is distinct from 'De acordo com as Leis de De Morgan, a negação da sentença composta “Pedro fez a vacina e não teve febre amarela” é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 77 diverge do esperado — valor atual: %', v_enunciado_77;
  end if;
  if position('Regra de De Morgan para Conjunção' in v_explicacao_77) = 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 77 diverge do esperado';
  end if;
  if v_banca_77 is distinct from 'Fundatec' or v_concurso_77 is distinct from 'SUSEPE RS - Agente Penitenciário Administrativo' or v_ano_77 is distinct from 2022 then
    raise exception 'Precondicao falhou: proveniencia da questao 77 diverge do esperado (banca=%, concurso=%, ano=%)', v_banca_77, v_concurso_77, v_ano_77;
  end if;
  if v_assunto_77 is distinct from 34 then
    raise exception 'Precondicao falhou: assunto_id da questao 77 diverge do esperado (34) — valor atual: %', v_assunto_77;
  end if;
  if v_ativa_77 is distinct from true then
    raise exception 'Precondicao falhou: questao 77 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 77 and ordem = 1 and correta = true and texto = 'Pedro não fez a vacina ou teve febre amarela.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 77 diverge do esperado';
  end if;
  select count(*) into v_vinculos_77 from public.questao_unidades_pedagogicas where questao_id = 77;
  if v_vinculos_77 <> 0 then
    raise exception 'Precondicao falhou: questao 77 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_77;
  end if;

  -- Q88
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_88, v_explicacao_88, v_banca_88, v_concurso_88, v_ano_88, v_assunto_88, v_ativa_88
    from public.questoes where id = 88;
  if v_enunciado_88 is distinct from 'A negação da sentença composta “Artur fez a vacina da Covid e fez a vacina da gripe”, de acordo com as Leis de De Morgan, é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 88 diverge do esperado — valor atual: %', v_enunciado_88;
  end if;
  if position('1ª Lei de De Morgan' in v_explicacao_88) = 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 88 diverge do esperado';
  end if;
  if v_banca_88 is distinct from 'Fundatec' or v_concurso_88 is distinct from 'SUSEPE RS - Agente Penitenciário' or v_ano_88 is distinct from 2022 then
    raise exception 'Precondicao falhou: proveniencia da questao 88 diverge do esperado (banca=%, concurso=%, ano=%)', v_banca_88, v_concurso_88, v_ano_88;
  end if;
  if v_assunto_88 is distinct from 34 then
    raise exception 'Precondicao falhou: assunto_id da questao 88 diverge do esperado (34) — valor atual: %', v_assunto_88;
  end if;
  if v_ativa_88 is distinct from true then
    raise exception 'Precondicao falhou: questao 88 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 88 and ordem = 2 and correta = true and texto = 'Artur não fez a vacina da Covid ou não fez a vacina da gripe.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 88 diverge do esperado';
  end if;
  select count(*) into v_vinculos_88 from public.questao_unidades_pedagogicas where questao_id = 88;
  if v_vinculos_88 <> 0 then
    raise exception 'Precondicao falhou: questao 88 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_88;
  end if;

  -- Q311
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_311, v_explicacao_311, v_banca_311, v_concurso_311, v_ano_311, v_assunto_311, v_ativa_311
    from public.questoes where id = 311;
  if v_enunciado_311 is distinct from 'A negação de “P e Q” é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 311 diverge do esperado — valor atual: %', v_enunciado_311;
  end if;
  if position('Teorema de De Morgan' in v_explicacao_311) = 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 311 diverge do esperado';
  end if;
  if v_banca_311 is distinct from 'Papiro' or v_concurso_311 is distinct from 'PAPIRO - Adaptada do padrão Fundatec 2025/2026' or v_ano_311 is distinct from 2026 then
    raise exception 'Precondicao falhou: proveniencia da questao 311 diverge do esperado (banca=%, concurso=%, ano=%)', v_banca_311, v_concurso_311, v_ano_311;
  end if;
  if v_assunto_311 is distinct from 34 then
    raise exception 'Precondicao falhou: assunto_id da questao 311 diverge do esperado (34) — valor atual: %', v_assunto_311;
  end if;
  if v_ativa_311 is distinct from true then
    raise exception 'Precondicao falhou: questao 311 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 311 and ordem = 1 and correta = true and texto = 'Não P ou não Q.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 311 diverge do esperado';
  end if;
  select count(*) into v_vinculos_311 from public.questao_unidades_pedagogicas where questao_id = 311;
  if v_vinculos_311 <> 0 then
    raise exception 'Precondicao falhou: questao 311 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos_311;
  end if;

  -- Unidade destino (Negacao de proposicoes)
  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_unidade_conteudo, v_unidade_assunto, v_unidade_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_unidade_conteudo is distinct from 3 or v_unidade_assunto is distinct from 35 or v_unidade_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade destino (Negacao) diverge do esperado (conteudo=%, assunto=%, ativa=%)', v_unidade_conteudo, v_unidade_assunto, v_unidade_ativa;
  end if;
  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_unidade <> 4 then
    raise exception 'Precondicao falhou: unidade destino nao possui exatamente 4 vinculos antes do saneamento (Q81/Q86/Q312/Q337) — atual: %', v_vinculos_unidade;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 81)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 86)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 312)
     or not exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and questao_id = 337) then
    raise exception 'Precondicao falhou: unidade destino nao contem exatamente Q81/Q86/Q312/Q337 antes do saneamento';
  end if;

  -- Unidade De Morgan (nao deve ser tocada)
  select u.curso_conteudo_id, cc.assunto_id, u.ativa
    into v_demorgan_conteudo, v_demorgan_assunto, v_demorgan_ativa
    from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  if v_demorgan_conteudo is distinct from 4 or v_demorgan_assunto is distinct from 34 or v_demorgan_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade de De Morgan diverge do esperado (conteudo=%, assunto=%, ativa=%)', v_demorgan_conteudo, v_demorgan_assunto, v_demorgan_ativa;
  end if;
  select count(*) into v_vinculos_demorgan from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  if v_vinculos_demorgan <> 0 then
    raise exception 'Precondicao falhou: unidade de De Morgan ja possui vinculo (esperado 0) — atual: %', v_vinculos_demorgan;
  end if;
end $$;

update public.questoes
   set assunto_id = 35,
       atualizado_em = now()
 where id in (77, 88, 311);

select public.classificar_questao_unidade_admin(77, 'c6ccefae-14df-4760-8c1d-2822090a2a93');
select public.classificar_questao_unidade_admin(88, 'c6ccefae-14df-4760-8c1d-2822090a2a93');
select public.classificar_questao_unidade_admin(311, 'c6ccefae-14df-4760-8c1d-2822090a2a93');

do $$
declare
  v_assunto_77 bigint; v_assunto_88 bigint; v_assunto_311 bigint;
  v_enunciado_77 text; v_enunciado_88 text; v_enunciado_311 text;
  v_total_alt_77 int; v_total_alt_88 int; v_total_alt_311 int;
  v_vinculos_77 int; v_vinculos_88 int; v_vinculos_311 int;
  v_vinculos_unidade int;
  v_qids_unidade bigint[];
  v_candidatas_34 int;
  v_vinculos_demorgan int;
  v_demorgan_ativa boolean;
begin
  select assunto_id, enunciado into v_assunto_77, v_enunciado_77 from public.questoes where id = 77;
  select assunto_id, enunciado into v_assunto_88, v_enunciado_88 from public.questoes where id = 88;
  select assunto_id, enunciado into v_assunto_311, v_enunciado_311 from public.questoes where id = 311;

  if v_assunto_77 is distinct from 35 then raise exception 'Pos-condicao falhou: assunto_id da questao 77 nao foi atualizado para 35 — atual: %', v_assunto_77; end if;
  if v_assunto_88 is distinct from 35 then raise exception 'Pos-condicao falhou: assunto_id da questao 88 nao foi atualizado para 35 — atual: %', v_assunto_88; end if;
  if v_assunto_311 is distinct from 35 then raise exception 'Pos-condicao falhou: assunto_id da questao 311 nao foi atualizado para 35 — atual: %', v_assunto_311; end if;

  if v_enunciado_77 is distinct from 'De acordo com as Leis de De Morgan, a negação da sentença composta “Pedro fez a vacina e não teve febre amarela” é:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 77 foi alterado indevidamente';
  end if;
  if v_enunciado_88 is distinct from 'A negação da sentença composta “Artur fez a vacina da Covid e fez a vacina da gripe”, de acordo com as Leis de De Morgan, é:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 88 foi alterado indevidamente';
  end if;
  if v_enunciado_311 is distinct from 'A negação de “P e Q” é:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 311 foi alterado indevidamente';
  end if;

  select count(*) into v_total_alt_77 from public.alternativas where questao_id = 77;
  select count(*) into v_total_alt_88 from public.alternativas where questao_id = 88;
  select count(*) into v_total_alt_311 from public.alternativas where questao_id = 311;
  if v_total_alt_77 <> 5 or v_total_alt_88 <> 5 or v_total_alt_311 <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas mudou (77=%,88=%,311=%)', v_total_alt_77, v_total_alt_88, v_total_alt_311;
  end if;

  select count(*) into v_vinculos_77 from public.questao_unidades_pedagogicas where questao_id = 77 and unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  select count(*) into v_vinculos_88 from public.questao_unidades_pedagogicas where questao_id = 88 and unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  select count(*) into v_vinculos_311 from public.questao_unidades_pedagogicas where questao_id = 311 and unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_77 <> 1 or v_vinculos_88 <> 1 or v_vinculos_311 <> 1 then
    raise exception 'Pos-condicao falhou: alguma das 3 questoes nao tem exatamente 1 vinculo na unidade destino (77=%,88=%,311=%)', v_vinculos_77, v_vinculos_88, v_vinculos_311;
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_unidade <> 7 then
    raise exception 'Pos-condicao falhou: unidade destino deveria possuir exatamente 7 vinculos apos o saneamento — atual: %', v_vinculos_unidade;
  end if;

  select array_agg(questao_id order by questao_id) into v_qids_unidade
  from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_qids_unidade is distinct from array[77,81,86,88,311,312,337]::bigint[] then
    raise exception 'Pos-condicao falhou: QIDs da unidade destino diferem do esperado — atual: %', v_qids_unidade;
  end if;

  select count(*) into v_candidatas_34
  from public.questoes where ativa = true and materia_id = 18 and assunto_id = 34;
  if v_candidatas_34 <> 0 then
    raise exception 'Pos-condicao falhou: assunto 34 (De Morgan) deveria ficar com 0 candidatas ativas apos a migracao — atual: %', v_candidatas_34;
  end if;

  select count(*) into v_vinculos_demorgan from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  select ativa into v_demorgan_ativa from public.unidades_pedagogicas where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  if v_vinculos_demorgan <> 0 then
    raise exception 'Pos-condicao falhou: unidade de De Morgan ganhou vinculo (esperado 0) — atual: %', v_vinculos_demorgan;
  end if;
  if v_demorgan_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: unidade de De Morgan foi desativada indevidamente';
  end if;

  raise notice 'Pos-condicoes OK: Q77/Q88/Q311 reclassificadas para assunto_id=35 com exatamente 1 vinculo cada na unidade Negacao de proposicoes (total 7: 77,81,86,88,311,312,337), assunto 34 com 0 candidatas ativas, unidade De Morgan intocada (ativa, 0 vinculos).';
end $$;

commit;
