-- ============================================================================
-- HOTFIX FASE 2R-A — QUESTÃO 718 (correção de artigo e denominação na explicação)
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

  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 718) <> '953e588d9180ba830f5d5339622c426f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 718 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 718) <> 'f280f8ad2c7aa6584dfebb1a5d29ea8d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 718 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÃO (1 QUESTÃO) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- I. (Correta): O Artigo 124, caput, da Constituição do Estado do Rio Grande do Sul dispõe que a segurança pública é exercida através de 5 órgãos: Brigada Militar, Polícia Civil, Instituto-Geral de Perícias, Corpo de Bombeiros Militar e Polícia Penal. NOTA: a denominação "Coordenadoria-Geral de Perícias", usada pela assertiva, é a designação HISTÓRICA do órgão, vigente até 1997; desde a Emenda Constitucional nº 19, de 16/07/1997, a instituição chama-se INSTITUTO-GERAL DE PERÍCIAS (IGP-RS). O órgão permanece expressamente listado no art. 124 como integrante da segurança pública, apenas sob a denominação atual.
- II. (Correta): A organização e o funcionamento dos órgãos de segurança pública são disciplinados por lei, nos termos do Artigo 125, caput, do mesmo capítulo constitucional.
- III. (Incorreta): O Artigo 128 da Constituição Estadual dispõe que "os Municípios poderão constituir: I - guardas municipais destinadas à proteção de seus bens, serviços e instalações, conforme dispuser a lei" — trata-se de faculdade dos Municípios, e não de obrigação, ao contrário do que afirma a assertiva.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III é falsa, pois a criação de guardas municipais é facultativa ("poderão"), não obrigatória.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III é falsa pelo mesmo motivo.

BIZU DE PROVA:
Segurança Pública na Constituição Estadual do RS (Art. 124, caput):
5 órgãos: Brigada Militar, Polícia Civil, Instituto-Geral de Perícias (nome atual desde a EC 19/1997; antiga "Coordenadoria-Geral de Perícias"), Corpo de Bombeiros Militar e Polícia Penal!
Guardas Municipais (Art. 128): facultativas — "PODERÃO" constituir, nunca "deverão"!',
         atualizado_em = now()
   WHERE id = 718;

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

  -- Assert 2: Status "ativa" preservado
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 718 AND ativa = true) THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa da questão 718 foi alterado indevidamente';
  END IF;

  -- Assert 3: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 718) <> '953e588d9180ba830f5d5339622c426f' THEN
    RAISE EXCEPTION 'Assert 3 falhou: hash da questão 718 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 4: Gabarito da questão 718 preservado (alternativa C, ordem 3)
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 718 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 718 (esperado ordem 3)';
  END IF;

  -- Assert 5: 5 alternativas presentes e exatamente 1 correta
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 718) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 718 AND correta = true) <> 1 THEN
    RAISE EXCEPTION 'Assert 5 falhou: alternativas da questão 718 divergentes do estado esperado';
  END IF;

  -- Assert 6: Explicação corrigida — cita "Artigo 128" para guardas municipais, NÃO cita mais
  -- "Artigo 129" nesse contexto, e usa "Instituto-Geral de Perícias" como nome atual, com nota
  -- explícita sobre a denominação histórica
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 718;
  IF v_explicacao_check NOT ILIKE '%Artigo 128 da Constituição Estadual%' OR
     v_explicacao_check ILIKE '%Artigo 129 da Constituição Estadual%' OR
     v_explicacao_check ILIKE '%(Art. 129):%' OR
     v_explicacao_check NOT ILIKE '%Instituto-Geral de Perícias%' OR
     v_explicacao_check NOT ILIKE '%designação HISTÓRICA%' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 718 não reflete a correção esperada (Art. 128 + Instituto-Geral de Perícias)';
  END IF;

  -- Assert 7: Questões 355 e 356 (mesma Fase 2R-A, fora deste hotfix) permanecem absolutamente
  -- intocadas
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 355) <> '94e01d471989b2bf7dc162a635f3f046' THEN
    RAISE EXCEPTION 'Assert 7a falhou: questão 355 foi modificada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 355) <> '39d9f779a4e99a106c781cc3b2dab62d' THEN
    RAISE EXCEPTION 'Assert 7b falhou: explicação da questão 355 foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 356) <> '61b7e825eb52940e8418352b331771ee' THEN
    RAISE EXCEPTION 'Assert 7c falhou: questão 356 foi modificada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 356) <> 'c35920d0c0f7b6983dbe78e12ac853b0' THEN
    RAISE EXCEPTION 'Assert 7d falhou: explicação da questão 356 foi modificada indevidamente';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DO HOTFIX FASE 2R-A (QUESTÃO 718) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;