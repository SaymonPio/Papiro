-- ============================================================================
-- FASE 2T-B — SANEAMENTO OCR DA QUESTÃO ID 358 (ATOS ADMINISTRATIVOS)
-- Remoção de LF residual em 5 alternativas + correção de espaço espúrio (ordem 5)
-- Modo: APPLY DEFINITIVO COM COMMIT
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_texto_check text;
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

  -- Precondição: hash da questão 358 (não inclui texto de alternativas — deve
  -- permanecer inalterado antes e depois desta migração)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 358) <> 'd611777f82de1ff74e95dfdad03dd254' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 358 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 358) <> '273a9827fbf14eec3710507434412db1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 358 divergiu do estado auditado.';
  END IF;

  -- Precondição: questão 358 ativa, com 5 alternativas e exatamente 1 correta na ordem 1
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 358 AND ativa = true) THEN
    RAISE EXCEPTION 'Precondição falhou: questão 358 não está ativa.';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 358) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 358 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 358 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão 358 divergente do esperado (5 alternativas, 1 correta na ordem 1).';
  END IF;

  -- Precondição: cada alternativa com id, questao_id, ordem, correta e hash do texto exatos
  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = 1767 AND questao_id = 358 AND ordem = 1 AND correta = true
       AND md5(texto) = '730239911c4f1c2a6b1ac301ba4a5238'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa 1767 (ordem 1) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = 1768 AND questao_id = 358 AND ordem = 2 AND correta = false
       AND md5(texto) = '89716adbba5b76b3b384cab43f43a8f3'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa 1768 (ordem 2) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = 1769 AND questao_id = 358 AND ordem = 3 AND correta = false
       AND md5(texto) = 'ae1099ad6ed1f8d75984f2852c416982'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa 1769 (ordem 3) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = 1770 AND questao_id = 358 AND ordem = 4 AND correta = false
       AND md5(texto) = 'cdd0a8d9d017897cd2e1a13d7ebaae82'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa 1770 (ordem 4) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = 1771 AND questao_id = 358 AND ordem = 5 AND correta = false
       AND md5(texto) = 'be10579e1371a4af2474abe0c4e162b8'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa 1771 (ordem 5) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (5 ALTERNATIVAS) — SOMENTE O CAMPO TEXTO
  -- --------------------------------------------------------------------------

  UPDATE public.alternativas SET texto = 'Segundo a presunção de legitimidade, o ato administrativo é considerado válido, até prova em sentido contrário.' WHERE id = 1767;
  UPDATE public.alternativas SET texto = 'O atributo da imperatividade significa que o ato administrativo pode criar bilateralmente obrigações aos particulares, com sua anuência.' WHERE id = 1768;
  UPDATE public.alternativas SET texto = 'A exigibilidade consiste no atributo que permite à Administração aplicar punições aos particulares por violação da ordem jurídica, com a necessária intervenção judicial.' WHERE id = 1769;
  UPDATE public.alternativas SET texto = 'A autoexecutoriedade permite que a Administração Pública realize a execução material dos atos administrativos ou de dispositivos legais, usando a força física se preciso for para desconstituir situação violadora da ordem jurídica, exclusivamente quando autorizada pelo Poder Judiciário.' WHERE id = 1770;
  UPDATE public.alternativas SET texto = 'A exequibilidade diz respeito à necessidade de respeitar-se a finalidade específica definida na lei para cada espécie de ato administrativo.' WHERE id = 1771;

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

  -- Assert 2: hash da questão 358 e da explicação permanecem EXATAMENTE IGUAIS
  -- (prova de que nada em public.questoes foi tocado)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 358) <> 'd611777f82de1ff74e95dfdad03dd254' THEN
    RAISE EXCEPTION 'Assert 2 falhou: hash da questão 358 foi alterado indevidamente — esta migração não deveria tocar public.questoes';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 358) <> '273a9827fbf14eec3710507434412db1' THEN
    RAISE EXCEPTION 'Assert 2 falhou: hash da explicação da questão 358 foi alterado indevidamente — esta migração não deveria tocar public.questoes';
  END IF;

  -- Assert 3: questão 358 continua ativa, com 5 alternativas, 1 correta, na ordem 1
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 358 AND ativa = true) THEN
    RAISE EXCEPTION 'Assert 3 falhou: questão 358 não está mais ativa';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 358) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 358 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1767 AND questao_id = 358 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 3 falhou: estrutura de alternativas da questão 358 divergente do esperado após a correção';
  END IF;

  -- Assert 4: ordem, questao_id e correta preservados em cada alternativa (nada além do texto mudou)
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1767 AND questao_id = 358 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa 1767 teve ordem, questao_id ou correta alterados indevidamente';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1768 AND questao_id = 358 AND ordem = 2 AND correta = false) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa 1768 teve ordem, questao_id ou correta alterados indevidamente';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1769 AND questao_id = 358 AND ordem = 3 AND correta = false) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa 1769 teve ordem, questao_id ou correta alterados indevidamente';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1770 AND questao_id = 358 AND ordem = 4 AND correta = false) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa 1770 teve ordem, questao_id ou correta alterados indevidamente';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1771 AND questao_id = 358 AND ordem = 5 AND correta = false) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa 1771 teve ordem, questao_id ou correta alterados indevidamente';
  END IF;

  -- Assert 5: hash do texto NOVO de cada alternativa confere com o esperado
  IF (SELECT md5(texto) FROM public.alternativas WHERE id = 1767) <> '9b2ef1d9d2c500d8c63ca2338ebcfc01' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa 1767 não confere com o esperado';
  END IF;
  IF (SELECT md5(texto) FROM public.alternativas WHERE id = 1768) <> '76ddd9be6d24e6d4ff316ac4eb6396bd' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa 1768 não confere com o esperado';
  END IF;
  IF (SELECT md5(texto) FROM public.alternativas WHERE id = 1769) <> '968a16fac95136d2fa2d4b485a840c90' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa 1769 não confere com o esperado';
  END IF;
  IF (SELECT md5(texto) FROM public.alternativas WHERE id = 1770) <> '50c41ffaba10430a07a40c7e018c18b3' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa 1770 não confere com o esperado';
  END IF;
  IF (SELECT md5(texto) FROM public.alternativas WHERE id = 1771) <> '371b5efcf4043f5fba6704e6197ce15b' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa 1771 não confere com o esperado';
  END IF;

  -- Assert 6: nenhuma das 5 alternativas contém LF ou CR residual no texto
  IF EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id IN (1767, 1768, 1769, 1770, 1771)
       AND (texto ~ E'\n' OR texto ~ E'\r')
  ) THEN
    RAISE EXCEPTION 'Assert 6 falhou: ao menos uma alternativa ainda contém caractere de quebra de linha (LF/CR) residual';
  END IF;

  -- Assert 7: alternativa 1771 não contém mais "respeitar -se" e passa a conter "respeitar-se"
  SELECT texto INTO v_texto_check FROM public.alternativas WHERE id = 1771;
  IF v_texto_check ILIKE '%respeitar -se%' OR v_texto_check NOT ILIKE '%respeitar-se%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: alternativa 1771 ainda contém o espaço espúrio antes do hífen ou não contém "respeitar-se"';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2T-B (SANEAMENTO OCR ID 358) PASSARAM COM SUCESSO!';
END $$;

COMMIT;