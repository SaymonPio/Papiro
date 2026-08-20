-- ============================================================================
-- FASE 3B-2B-RL — RACIOCÍNIO LÓGICO (SANEAMENTO PONTUAL QUESTÃO 337)
-- Modo: TESTE COM ROLLBACK OBRIGATÓRIO
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_divergente record;
  v_hashes_questoes json := '{"74":"ba2aafe25905765654a581aa2c9a7765","75":"904983e133faa7897c055f927c05ed86","76":"39cd6b5c7614b16d203a6e2d86b23b4d","77":"45b0333a279f781fa03693acdf4e686d","78":"df68258dfeb452cda8198219f941636a","79":"fd05e25fd0f16eef5177c1620541b695","80":"def435b905640f01275120f11c6cc053","81":"1f46f16781a5bd52929b0b34f857fc7c","82":"e6bbcea609811394f9caeb1f81769565","83":"84255dd24d93a604223d4c4295c7c98a","84":"c110228bc8ec0c8339ece8c357703524","85":"b1cecceef21f4c5469e6ff9423bd688e","86":"eced1bb9faf6c6943fb144279439aca2","87":"710197eef94f7dbbf2f966ce9debf8d9","88":"112f80962f610dcc63a1a110f24c5bcd","89":"919dadb41a0fdc05096a676416c27628","90":"83b77cfd648b53718f2daccbcaaa7f44","246":"4a03783176895e35f38fc8bc90a7b4b2","247":"f2748df3b0bbe8f4696d89ac39462b7f","248":"045e2cfe608cace736323cf1254fab6c","285":"408f985f77f60cefa63bb538e3d26e5d","286":"885c690b507fe6283667fa48aa9bba8d","287":"96abcdcba0bc2f1f63d52c422a9f238a","288":"32e5e65927148cab4e31622567af982a","289":"83411259c6019e14b83d719be0e84932","290":"39d73cccab98a067ffd71bf363c639f2","309":"bc3f7df509694d6e06ee145012e0c46f","310":"361faf1fe9c91557985a1957c6e0dc14","311":"8f40393ae074769cda27456056be68b6","312":"a5413514f295f98b9692e539e8fed8f6","313":"8971fd0b388dc34e5eb1f36de0971b00","314":"4fd999638b0856de347685b7febb1264","315":"1a52a4bef8dc9b577a71e0dae31fff6a","337":"fed3455ae35363c3b4e3a18363aae96f"}';
  v_hashes_explicacoes json := '{"74":"658fe9a3e6a5fba1128af8aab73ce2ad","75":"6c3e98ecc218a5d745942a0189c18038","76":"b47b102358a083f8c0e1fa0ea6211e1a","77":"ab0d88c04e5f6d890db69b290f7d1ab9","78":"b0358b2a0bd795a2615738707355a3bf","79":"2ed538a49d3c732499c53d160f8fbc15","80":"538e1d4ea0b83cb8bb162108213c3768","81":"66178195e8367629285ea0b855e57f23","82":"b4afdc3969b7d6dba0255b2f337421ee","83":"38e3d9d7ff7eff5c5e048cdb0455b133","84":"b9471035dc406ad1aebcd07a13306ea7","85":"bf5fed1cd34dc2feb8ccff8a8ad8b397","86":"eeba026881a011e0b4af8fa04239f5f8","87":"9b2c80b7b8c720b1fcb1a47aa894a339","88":"425e6703146c81c58da94b9684f014bb","89":"189b7876c1abbaef66eda9bd95c920a7","90":"ae80c60ad0d822886c2b3ccf8cf14a52","246":"885282c7f814afb9d9db6173a80dcb4f","247":"fca6900c9c572d1f4271eb53799f57e7","248":"40c2f9838d84652966d1393f2f63916f","285":"0ca4d1e8cdea0dac4e1b9a5c18c30091","286":"b81bccc0bde5b92ee92f87b9305bc967","287":"c0712a23e9d75244ecdbf4f0d00167bf","288":"762a992f1b9d4d10171ff413f4f743cd","289":"035f054b261d4bb1cdd7383639659b2d","290":"7785263953c6eddf3e3127f10325e55d","309":"847cd39c4a99bcb8b96f9dc594019313","310":"ddf5d22084ba2e506b908705861cad51","311":"b55abf0164d236b08954982beea771da","312":"5c21580e28195400c7320bd92a75602f","313":"6cb412b57d083c1ae0457d4fe193a37d","314":"28dd7f4a6f2c519a3414d826902c2040","315":"5b97ac7fb20535bf1cf2a929dbcd8420","337":"90489d05b939a5c6e713e36e04bb3115"}';
  v_gabaritos_ordem json := '{"74":4,"75":3,"76":2,"77":1,"78":2,"79":5,"80":4,"81":3,"82":3,"83":1,"84":3,"85":5,"86":2,"87":5,"88":2,"89":4,"90":4,"246":4,"247":1,"248":1,"285":1,"286":1,"287":1,"288":1,"289":1,"290":1,"309":1,"310":1,"311":1,"312":1,"313":1,"314":1,"315":1,"337":2}';
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

  -- Validação dos hashes pré-apply das 34 questões de Raciocínio Lógico (materia_id = 18)
  SELECT q.id, h.value as esperado,
         md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_questoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão % de RL divergiu do estado auditado (esperado %, obtido %)',
      v_divergente.id, v_divergente.esperado, v_divergente.obtido;
  END IF;

  -- Validação dos hashes pré-apply das 34 explicações de Raciocínio Lógico
  SELECT q.id, h.value as esperado,
         md5(replace(q.explicacao, chr(13), '')) as obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_explicacoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(replace(q.explicacao, chr(13), '')) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão % de RL divergiu do estado auditado (esperado %, obtido %)',
      v_divergente.id, v_divergente.esperado, v_divergente.obtido;
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (EXCLUSIVAMENTE QUESTÃO 337)
  -- --------------------------------------------------------------------------

  -- Saneamento do enunciado da questão 337 (remoção de quebra de linha órfã)
  UPDATE public.questoes
     SET enunciado = 'A negação da proposição composta “O celular tem 64 gigabytes de memória ou a câmera não tem 8 megapixels” é:',
         atualizado_em = now()
   WHERE id = 337;

  -- Saneamento da alternativa 5 da questão 337 (remoção do cabeçalho residual)
  UPDATE public.alternativas
     SET texto = 'O celular não tem 8 megapixels de memória ou a câmera tem 64 gigabytes.'
   WHERE questao_id = 337
     AND ordem = 5;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados (915 total / 907 ativas / 8 inativas)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (todas as 34 questões de RL ativas)
  IF (SELECT count(*) FROM public.questoes WHERE materia_id = 18 AND ativa = true) <> 34 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões de Raciocínio Lógico tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão em todo o universo das 34 questões de RL
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas a JOIN public.questoes q ON q.id = a.questao_id WHERE q.materia_id = 18) <> 34 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas a
         JOIN public.questoes q ON q.id = a.questao_id
        WHERE q.materia_id = 18
        GROUP BY a.questao_id
       HAVING count(*) FILTER (WHERE a.correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões de Raciocínio Lógico não possuem exatamente 1 alternativa correta';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos específicos em cada uma das 34 questões
  SELECT h.key::integer as questao_id, h.value::integer as ordem_esperada
    INTO v_divergente
    FROM json_each_text(v_gabaritos_ordem) h
   WHERE NOT EXISTS (
     SELECT 1
       FROM public.alternativas a
      WHERE a.questao_id = h.key::integer
        AND a.ordem = h.value::integer
        AND a.correta = true
   )
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão % de Raciocínio Lógico', v_divergente.questao_id;
  END IF;

  -- Assert 5: As 33 questões de RL fora do escopo mantiveram seus hashes idênticos
  SELECT q.id, h.value as hash_esperado,
         md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_questoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE q.id <> 337
     AND md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão % de RL (fora do lote) foi modificada indevidamente', v_divergente.id;
  END IF;

  -- Assert 6: Explicações de todas as 34 questões de Raciocínio Lógico preservadas byte a byte
  SELECT q.id, h.value as hash_esperado,
         md5(replace(q.explicacao, chr(13), '')) as hash_obtido
    INTO v_divergente
    FROM json_each_text(v_hashes_explicacoes) h
    JOIN public.questoes q ON q.id = h.key::integer
   WHERE md5(replace(q.explicacao, chr(13), '')) <> h.value
   LIMIT 1;

  IF FOUND THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão % de RL foi alterada indevidamente', v_divergente.id;
  END IF;

  -- Assert 7: Verificação do saneamento da questão 337 (enunciado exato e alternativa 5 sem cabeçalho)
  IF (SELECT enunciado FROM public.questoes WHERE id = 337) <> 'A negação da proposição composta “O celular tem 64 gigabytes de memória ou a câmera não tem 8 megapixels” é:' THEN
    RAISE EXCEPTION 'Assert 7 falhou: enunciado da questão 337 não corresponde ao texto saneado esperado';
  END IF;

  IF (SELECT texto FROM public.alternativas WHERE questao_id = 337 AND ordem = 5) <> 'O celular não tem 8 megapixels de memória ou a câmera tem 64 gigabytes.' THEN
    RAISE EXCEPTION 'Assert 7 falhou: alternativa 5 da questão 337 não corresponde ao texto saneado esperado';
  END IF;

  -- Assert 8: Ausência de cabeçalho residual 'CIÊNCIAS' e de \n literal na questão 337
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 337 AND (texto ILIKE '%CIÊNCIAS%' OR position('\n' in texto) > 0)) > 0 OR
     (SELECT count(*) FROM public.questoes WHERE id = 337 AND position('\n' in enunciado) > 0) > 0 THEN
    RAISE EXCEPTION 'Assert 8 falhou: resíduo de cabeçalho ou \n literal detectado na questão 337';
  END IF;

  RAISE NOTICE 'TODOS OS 8 ASSERTS DA FASE 3B-2B-RL (RACIOCÍNIO LÓGICO) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;