-- ============================================================================
-- FASE 2T-C2 — SANEAMENTO TEXTUAL MÍNIMO (ID 3 explicacao / ID 676 enunciado)
-- Modo: TESTE COM ROLLBACK OBRIGATÓRIO
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_explicacao_check text;
  v_enunciado_check text;
BEGIN
  -- --------------------------------------------------------------------------
  -- 1. PRECONDIÇÕES E GUARDAS CONTRA DRIFT (ESTADO PRÉ-APPLY)
  -- --------------------------------------------------------------------------

  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Precondição falhou: totais globais divergentes. Esperado 915/907/8, obtido %/%/%',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Precondição: hash da questão e da explicação do ID 3 (estado pré-apply)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 3) <> '6dc229c0c4c99033e5ffe71821163c7a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 3 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 3) <> '2a0470d04673953e5349fe8bcf98e2c7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 3 divergiu do estado auditado.';
  END IF;

  -- Precondição: hash da questão e da explicação do ID 676 (estado pré-apply)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 676) <> 'a51abba0cd1544112efac2c5e8b6a9ae' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 676 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 676) <> '634dbc7309eb33f9656cb016254e5493' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 676 divergiu do estado auditado.';
  END IF;

  -- Precondição: ambas ativas, com materia_id/assunto_id e estrutura de alternativas esperados
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 3 AND ativa = true AND materia_id = 3 AND assunto_id = 2) THEN
    RAISE EXCEPTION 'Precondição falhou: questão 3 divergente do estado esperado (ativa/materia_id/assunto_id).';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 676 AND ativa = true AND materia_id = 10 AND assunto_id = 17) THEN
    RAISE EXCEPTION 'Precondição falhou: questão 676 divergente do estado esperado (ativa/materia_id/assunto_id).';
  END IF;

  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 3) <> 4 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 3 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 3 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão 3 divergente do esperado (4 alternativas, 1 correta na ordem 1).';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 676) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 676 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 676 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão 676 divergente do esperado (5 alternativas, 1 correta na ordem 3).';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO — CADA QUESTÃO EM SOMENTE UM CAMPO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 144, §8º, da Constituição Federal estabelece que os Municípios poderão constituir guardas municipais destinadas à proteção de seus BENS, SERVIÇOS E INSTALAÇÕES, conforme dispuser a lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As guardas municipais não têm competência constitucional para exercer apuração penal geral privativa da polícia judiciária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A competência não abrange policiamento ostensivo rodoviário federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não atuam na fiscalização aduaneira ou controle de fronteiras privativo federal.

BIZU DE PROVA:
Competência Constitucional das Guardas Municipais (Art. 144, §8º da CF/88):
Proteção de BENS, SERVIÇOS e INSTALAÇÕES do Município!' WHERE id = 3;
  UPDATE public.questoes SET enunciado = 'A Constituição Federal de 1988 instituiu a possibilidade de criação de um órgão responsável pela proteção dos bens, serviços e instalações dos municípios. Qual é esse órgão?' WHERE id = 676;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: ID 3 continua ativa, materia_id=3, assunto_id=2
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 3 AND ativa = true AND materia_id = 3 AND assunto_id = 2) THEN
    RAISE EXCEPTION 'Assert 2 falhou: questão 3 teve ativa/materia_id/assunto_id alterados indevidamente';
  END IF;

  -- Assert 3: ID 676 continua ativa, materia_id=10, assunto_id=17
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 676 AND ativa = true AND materia_id = 10 AND assunto_id = 17) THEN
    RAISE EXCEPTION 'Assert 3 falhou: questão 676 teve ativa/materia_id/assunto_id alterados indevidamente';
  END IF;

  -- Assert 4: alternativas e gabarito de ambas as questões inalterados (estrutura e ordem correta)
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 3) <> 4 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 3 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 3 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativas/gabarito da questão 3 foram alterados indevidamente';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 676) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 676 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 676 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativas/gabarito da questão 676 foram alterados indevidamente';
  END IF;

  -- Assert 5: ID 3 — enunciado (hash_questao) permanece EXATAMENTE IGUAL (só explicacao mudou)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 3) <> '6dc229c0c4c99033e5ffe71821163c7a' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 3 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 6: ID 676 — explicação (hash_explicacao) permanece EXATAMENTE IGUAL (só enunciado mudou)
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 676) <> '634dbc7309eb33f9656cb016254e5493' THEN
    RAISE EXCEPTION 'Assert 6 falhou: hash da explicação da questão 676 foi alterado indevidamente — só o enunciado deveria mudar';
  END IF;

  -- Assert 7: ID 3 — explicação nova confere com o hash esperado e não contém mais o
  -- resíduo da "alternativa E" inexistente
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 3;
  IF md5(regexp_replace(v_explicacao_check, E'\r\n', E'\n', 'g')) <> 'ded234fff1cbcdc5844734d1d6f1ec56' THEN
    RAISE EXCEPTION 'Assert 7 falhou: hash da explicação pós-correção da questão 3 não confere com o esperado';
  END IF;
  IF v_explicacao_check ILIKE '%ALTERNATIVA E%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 3 ainda contém referência à alternativa E inexistente';
  END IF;

  -- Assert 8: ID 676 — enunciado novo confere com o hash esperado, contém "é esse" e
  -- não contém mais "éesse"
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 676;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 676) <> '5f3554f6f7234f6695491fdbd6a66e94' THEN
    RAISE EXCEPTION 'Assert 8 falhou: hash da questão pós-correção da questão 676 não confere com o esperado';
  END IF;
  IF v_enunciado_check NOT ILIKE '%é esse órgão%' OR v_enunciado_check ILIKE '%éesse%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: enunciado da questão 676 ainda contém "éesse" ou não contém "é esse órgão"';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2T-C2 (SANEAMENTO TEXTUAL ID 3 / ID 676) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;