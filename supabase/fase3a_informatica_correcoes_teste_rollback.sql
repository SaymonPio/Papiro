-- ============================================================================
-- FASE 3A — INFORMÁTICA (SANEAMENTO DE ELEMENTOS VISUAIS E HIGIENE OCR)
-- Modo: TESTE COM ROLLBACK OBRIGATÓRIO
-- ============================================================================

BEGIN;

-- Garante sessão em leitura e escrita para o harness/apply
SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_enunciado_check text;
  v_alt_check text;
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

  -- Validação dos hashes pré-apply das 89 questões de Informática
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 11) <> '4e3aeb7cdd3ef4dc455e52259af2a579' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 11 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 15) <> 'f117002c7a2df47ae27cb8c78f9f85af' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 15 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 31) <> 'ef843ae0953970de7ad2cded8f79797c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 31 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 32) <> '84b58d8b56cba2eae2bc33b1cef51b92' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 32 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 33) <> '7b30f58ed88c4e96e61d70fbf054119c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 33 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 60) <> '4c869b984b37ed9c0a345de08194f0f0' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 60 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 61) <> '03dfc8cb627c237cd5b7da41bb22ff23' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 61 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 62) <> 'fdb3f282186e4151855d3f5d7e284f4f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 62 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 63) <> 'e58f47083df5aa02966939435d5e4eae' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 63 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 64) <> '666092c70eab2d7518ed5b036f42bde1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 64 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 91) <> 'cbca6e1550aa4fc88c70d5481bd4d63c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 91 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 92) <> '044df8ca78f9cc922d55be4f8a817529' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 92 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 93) <> 'cf221e3cb80e60e76f724681d2f62553' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 93 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 94) <> 'eef7188484e1669d283fa44d35a66473' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 94 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 95) <> '379d386e9b88bc9bb94c0c4a1205851a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 95 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 96) <> '29447b377c86e9db7f41d85159dbe7ef' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 96 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 97) <> '4eeb77615efc62bafcc64a6424cae8c4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 97 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 98) <> '918de151dbddb1889836abd036fc3080' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 98 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 99) <> '91a16ec954c6ae3c007ebe9b44947068' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 99 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 100) <> '7aeaeed842e0652db24885f2679cb7f5' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 100 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 101) <> 'dcc4b247d7ab65f8f25f40d471607671' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 101 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 102) <> 'e14ef78c141fbce4d065b5a0921d8f3e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 102 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 103) <> '9b19df533c974163bc00304b9fe7aa12' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 103 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 104) <> '22f20de454438fb2183555c605a94d04' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 104 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 105) <> 'b89ab7797351332a7431e5dcacd6f226' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 105 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 106) <> '8a07adee33e941913531fe97b559224d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 106 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 107) <> '73411e2cfd74e0ca486d5b16d6dbdaf8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 107 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 108) <> '004a86990e08796e729da01cf39efb71' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 108 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 109) <> '65872511e5b32694e74d518b5cd7ac03' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 109 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 110) <> 'b5eb2481e9c214d92a7298c8ce3db6ed' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 110 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 294) <> 'c4c088d94adcfd286e2ab17e7bf7b6c7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 294 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 338) <> '77840cfdd31e67e69256177fe3b43ca2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 338 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 339) <> '69a54ba500554230adabfa1d547ffce6' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 339 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 340) <> '8b6d94b4788569fe79813263243f4322' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 340 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 341) <> 'b0c036fbff041d0451456cf2c4c9915d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 341 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 492) <> '0590db1b3a92d86cc6e2b9ae8f887b35' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 492 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 493) <> '798f863ab04a49411ef022df194eb681' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 493 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 494) <> 'b12ccea857d97a79aed0b76822b5bdc1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 494 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 495) <> 'd7935e72d77775474199d5f8a71be65c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 495 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 496) <> 'c585409cdc52d9bc22d9b7c5d44ad455' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 496 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 497) <> 'a86a6892e78fb496e026cfa285b2ee1f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 497 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 498) <> '2a6e782d3b08452b3e5e030537fff2a8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 498 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 499) <> '15b370a60938a7666ad295cc691bfdaf' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 499 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 626) <> 'e0a2ea0730b33a52cf59d1fc1f621f65' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 626 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 627) <> 'f5d17f22dc3beb0881debb1b52cfe0f9' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 627 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 628) <> '4a432fa3a202c53bf731fed9f7b24f34' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 628 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 629) <> '8094769b496019bf1294ed111592cd3b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 629 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 630) <> 'c526abcc82ac37c857b5c61431c91c6b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 630 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 631) <> '9fda50487b355f1fef903dd7fc4ec555' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 631 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 632) <> '5b6d65a5d83f2104c1d48075e8da5f25' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 632 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 633) <> '84035418115c2b1229298020d298a075' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 633 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 634) <> '05521baf796800d41091ceab36d7d60d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 634 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 635) <> '54e616049521f153086fbd74ae559b86' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 635 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 636) <> '119b6c32a43fa0621813338098e02d3b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 636 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 637) <> '68a12e6689652bc263410a9b77a39ae7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 637 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 638) <> '4f150eaafbfe601fc7af988de6296cba' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 638 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 639) <> '09cab23deb8319579cd15d8fcde4e67d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 639 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 640) <> 'fe36a8fadbcfe601764839370738dabb' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 640 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 641) <> 'e21502d7a1cb158adb92c10878850bd8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 641 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 642) <> '79eb19246c7a33371d0e984704901121' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 642 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 643) <> '8d9e80920ae8fd6d6d62c7ad30a3684d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 643 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 644) <> '6560dd904788c125d824d899986c7c0c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 644 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 645) <> '6eb971615424cb28d2376c7a253f6d8d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 645 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 698) <> 'fdcd5a3f80b33ef3fd99b6463133246c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 698 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 699) <> '34d9de3e369ba6bc3989e47bbee6721a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 699 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 700) <> '12120e3a757f595c2fd7baf1ee1c687d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 700 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 701) <> '303daf1af83302ee0ccae8b8477f2cdc' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 701 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 702) <> '96799869fb573d492709eb3998209730' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 702 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 703) <> '903f946a5d0186440fb4c04bae1af8ea' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 703 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 704) <> 'd15f427206067f98e016b2069091f321' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 704 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 705) <> '1684aee80e82d34aad4a6027670b4231' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 705 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 706) <> 'ab6b85cf75393bdccc2cfe12512a6923' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 706 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 707) <> '0b0353101dd12a79a8c0eada726295dc' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 707 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 708) <> '9536d8a84c07c122d5ede47c0ba10c83' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 708 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 709) <> '2e46c5b0fcb6e5687d8e230cec8a3e62' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 709 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 710) <> '02d80ca4a6c30eb109a6b35efd1b7bd2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 710 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 711) <> '830547c1cc31925701eb8fa7c49814f2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 711 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 768) <> '3d15ec6886c3e6860cbd2c724bdb3478' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 768 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 769) <> '5596246b8929a63c9a523079db8a1d5f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 769 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 770) <> 'db1f99ac895426a04e354a42882bc7b8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 770 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 791) <> 'c701084d3a36827a8b3441375e831201' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 791 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 792) <> '00d38c88ddc6c6bad1413d434e2eff9f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 792 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 830) <> 'ebe5562e9a840ddec19f73aa0d75bdab' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 830 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 831) <> '355d5c1b07ebde1a902ac873fcac6f12' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 831 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 832) <> '3c5eff3c2c2cc22f949736038f265223' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 832 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 833) <> 'a3ad954f4e888f1f3c2a35eb5258346c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 833 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 834) <> '6362e16495dab37b6638dc807cd6aa66' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 834 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 835) <> '1853eee163a2d6cc0c888813229994dc' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 835 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 836) <> 'b48c0251ffa80af307d32ac6284a88b4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 836 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 11) <> '051a4ea25d11c9bafe220706dfa94f20' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 11 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 15) <> 'dadcb215cd370d5194644fac5774c972' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 15 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 31) <> '6c07cead85c1b06cd7df189d067d7dd4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 31 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 32) <> '65c8a66d516bff62b8c6aafe68917cc7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 32 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 33) <> '422a3c43f0656492132d65ae88bc2897' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 33 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 60) <> 'f42b551276c42ee31d38d0b0648c388e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 60 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 61) <> 'b12c8639ec815731c09ea0dc9b9e386c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 61 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 62) <> '8d8dfed52b46f86ef8aa60201898db47' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 62 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 63) <> '7088d88bd0966a4fddf5686def666a81' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 63 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 64) <> 'be86d8ebe60d58711c5c7d89bc7b8679' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 64 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 91) <> '3d359049ce0feb70fb7080ea1eb0f2ed' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 91 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 92) <> 'dcd949e1024fe8b446d446e4749d3448' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 92 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 93) <> '8b880defbddb4a20151c44f85a0d7c67' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 93 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 94) <> '4ae574d898d5cc0163423a6dd39910cd' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 94 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 95) <> '938a02712318d130d4805f84d8c1f29e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 95 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 96) <> '1772fc3affac3643a15698bb9e3dd8a0' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 96 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 97) <> '389581dc6b09f3ed722adc4507ab5c7f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 97 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 98) <> '46b27c1c3c50d016d4f2fb131360854e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 98 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 99) <> '1bc4939d04c42eea804ce01ee662badd' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 99 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 100) <> '5e47c395249d43ad9bd0d5b82ee900c2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 100 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 101) <> 'b2e0deafdbbff255b565e01bb626ee9c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 101 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 102) <> '33fe39aa769d06e7ea16ac70cf49fa79' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 102 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 103) <> 'f0b2b8a5a3f270e9deeaad84c9a9f2b8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 103 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 104) <> '780074d1939695a8a7d796aa568a0b35' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 104 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 105) <> '21fa0d74f26b5ad085394dcf2b085bc4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 105 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 106) <> '586d34c1888819e9d5771d502c73a8bb' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 106 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 107) <> '6a54a8bd1b3672759ad1e1e166f94cae' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 107 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 108) <> '4db646dc4b10ddc2f05aadcfffeb7fdb' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 108 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 109) <> '68340ee4ca957d8bfecd9fd920e1f39b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 109 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 110) <> '7dcf57b53c302aeca6752a98fdb65676' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 110 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 294) <> 'f5a520e26bbaebae540337ca199ffaa5' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 294 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 338) <> 'dab289957ace083ae4a421bbfc5b80f3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 338 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 339) <> '74c736fa620636774681b53bfec9e9ae' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 339 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 340) <> '865ae19edc79e36a18262ad45c7f79d3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 340 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 341) <> '454f43a2fee6b32d57b0a3458c3d8178' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 341 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 492) <> '66cb56b8058df7b99fc4530b5f0d5678' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 492 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 493) <> 'd1c40eeff375884be9d50b4e80c8e5b7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 493 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 494) <> 'c7673ba240677825597113136a56ec69' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 494 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 495) <> '109239919a92afed3a484a87a20ec904' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 495 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 496) <> '5a1af9a6bd4b46917141a1b28dacf973' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 496 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 497) <> '85d644e0c2832f199aa3e91cf12100d7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 497 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 498) <> '1c8751f5f53cbcd48b87b926aabbced3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 498 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 499) <> '7357dd37bd2e286c8d1b75601bf7f40e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 499 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 626) <> '35f1dcd7834c18966f26ad6a26b07552' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 626 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 627) <> 'ae580f97a92d2498a9a1d6bb3aa09770' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 627 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 628) <> 'a0c6f18e6666ede8414db90863c891a7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 628 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 629) <> 'fbcc9a8b9ee310960c0795d6ecc39cd2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 629 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 630) <> '7283a6e18828073819d27c5f12a053ad' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 630 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 631) <> 'ab401cf2f4da3d660408f25e8be1abb3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 631 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 632) <> '89b9245acb7ea75c890afeeb05ebe2de' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 632 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 633) <> '3eca3eed0c94efb5355d26d80bf0df8a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 633 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 634) <> 'b337eea3a4633682e751a104f6e297ac' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 634 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 635) <> '455d5310005247cbc4dbbf09cebe68ae' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 635 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 636) <> 'd38b4ae74485103b99f0fb93f4ab5d17' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 636 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 637) <> '7f02cdaa569955aa64f4338c8394eea8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 637 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 638) <> '28da3a22aa69d2a7bf2fc56fc1bf5bd0' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 638 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 639) <> '2423edd4b8bf111a3afebffe13da407c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 639 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 640) <> '9710c2a1814023d796c0b288137efda2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 640 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 641) <> 'cab213f152ba7ecad2d1f48a73830bea' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 641 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 642) <> 'efc3c0ad87eb0d9d01c58c8a3cc1b9a1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 642 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 643) <> '9ba9c22000d901e8555da897190097bb' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 643 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 644) <> '446c8a92ee742e32dd5e8c3c18fe158e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 644 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 645) <> 'c177615956c4dba277225f73780f7894' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 645 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 698) <> 'a056b2722ec4f38992ac0924185be3a4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 698 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 699) <> '7a52e1dea08b9509e2907b204c1d9a67' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 699 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 700) <> '579465c47b30471dd0f0c273c65c39a3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 700 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 701) <> '7af5acb0c70de9ea081f99855cb48a64' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 701 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 702) <> '93b171187ae8289636d9795fef1eab8e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 702 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 703) <> '1abbb98d025b5fb6473e08b4713f1193' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 703 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 704) <> 'f47184f3d41d19f98e074481f437b72d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 704 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 705) <> 'e60d262de69a4713d632ae79a972bac0' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 705 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 706) <> 'd80786d2efd6ab080cc66163d2fd6859' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 706 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 707) <> '6dc9482245f4647886e364889e8f3aef' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 707 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 708) <> '4f4c7dc8494d86c1cdc8c5f740d7d47d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 708 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 709) <> '7103089b6af9a23438ffce93c835684f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 709 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 710) <> '8420355bdd8a33e0ce32ff39e8ae9e6a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 710 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 711) <> '930574088364cc54154ead9299a66cf2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 711 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 768) <> '3e919f91bfec9dbc20231cad4a93673a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 768 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 769) <> 'e50d702850e53c4560a37218e76dd38d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 769 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 770) <> 'e91a3595d1ca3776579f05107670eb48' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 770 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 791) <> '35f07bb0f56e264298264fef159e2da6' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 791 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 792) <> '3ddba4077341030b9bba0fe66150aa01' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 792 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 830) <> '3867ed3ff80c41ef7ad8eeda7c701b52' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 830 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 831) <> '49915c09fb680aab36175793ef3b6e4b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 831 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 832) <> '84caf59df418b7c4762093b065bceea4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 832 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 833) <> 'c9d65152bb9b41cf354a8ad32c008868' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 833 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 834) <> 'a51f2944201de50603b351edc21174bd' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 834 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 835) <> '2d413add3e59f01d344e6a6dfd0136d6' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 835 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 836) <> '0ef2db5d84dd575fa5eaf45a59fac53d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 836 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (12 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 60: Enunciado autossuficiente (Barra de Acesso Rápido)
  UPDATE public.questoes
     SET enunciado = 'No Explorador de Arquivos do Microsoft Windows 10, em sua configuração padrão e versão em português, a Barra de Ferramentas de Acesso Rápido (localizada na parte superior esquerda da janela) permite personalizar e exibir botões com as seguintes funções, EXCETO:',
         atualizado_em = now()
   WHERE id = 60;

  -- ID 64: Enunciado autossuficiente (Botão Compartilhar do Google Drive)
  UPDATE public.questoes
     SET enunciado = 'No Google Drive (versão web para computador), ao selecionar um arquivo na listagem, o botão representado pelo ícone de uma silhueta de pessoa acompanhada de um sinal de adição (+) tem como função:',
         atualizado_em = now()
   WHERE id = 64;

  -- ID 338: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'No Microsoft Windows 10, em sua configuração padrão e em português, como é chamado o tipo de ícone utilizado comumente para criar um link rápido para um programa, arquivo ou pasta?',
         atualizado_em = now()
   WHERE id = 338;

  -- ID 341: Higiene de OCR no enunciado e expurgo de cabeçalho na Alt E
  UPDATE public.questoes
     SET enunciado = 'No Microsoft Word 2016, versão para computador, em sua configuração padrão e em português, para riscar um texto, inserindo uma linha horizontal sobre o meio das letras, pode-se utilizar a opção de formatação de texto conhecida como:',
         atualizado_em = now()
   WHERE id = 341;
  UPDATE public.alternativas
     SET texto = 'Tachado.'
   WHERE id = 1686 AND questao_id = 341;

  -- ID 492: Enunciado com tabela de ocorrências diárias
  UPDATE public.questoes
     SET enunciado = 'Considere a seguinte planilha elaborada no Microsoft Excel 2016 para controlar a quantidade de ocorrências diárias da Guarda Municipal:

| | A | B | C | D | E |
|---|---|---|---|---|---|
| 3 | Dia | Manhã | Tarde | Noite | Total |
| 4 | Seg | 4 | 5 | 4 | =SOMA(B4:D4) |
| 5 | Ter | 3 | 6 | 4 | |
| 6 | Qua | 5 | 3 | 5 | |
| 7 | Qui | 6 | 4 | 6 | |
| 8 | Sex | 4 | 7 | 6 | |

Na célula E4, o resultado calculado é 13. Ao selecionar a célula E4, clicar na alça de preenchimento e arrastá-la até a célula E8, quais serão os resultados apresentados, respectivamente, nas células E5, E6, E7 e E8?',
         atualizado_em = now()
   WHERE id = 492;

  -- ID 493: Enunciado autossuficiente (guia Inserir do Excel)
  UPDATE public.questoes
     SET enunciado = 'No Microsoft Excel 2016 (versão em português), opções e grupos de comandos como "Tabelas" (Tabela Dinâmica), "Ilustrações" (Imagens, Formas, Ícones), "Gráficos" e "Minigráficos" estão disponíveis na guia:',
         atualizado_em = now()
   WHERE id = 493;

  -- ID 494: Enunciado autossuficiente (aba Desempenho do Gerenciador de Tarefas)
  UPDATE public.questoes
     SET enunciado = 'No Gerenciador de Tarefas do Microsoft Windows 10, a aba que apresenta gráficos de utilização em tempo real e métricas de desempenho dos componentes de hardware da máquina (CPU, Memória, Disco, Rede e GPU) é denominada:',
         atualizado_em = now()
   WHERE id = 494;

  -- ID 495: Enunciado com tabela Calc em Markdown e botões descritos
  UPDATE public.questoes
     SET enunciado = 'Considere a tabela abaixo, criada no LibreOffice Calc:

| | A | B | C |
|---|---|---|---|
| 1 | 30 | 35 | 50 |
| 2 | 25 | 40 | 65 |
| 3 | 10 | 15 | 20 |
| 4 | | | |

Sobre essa planilha e as ferramentas do LibreOffice Calc, analise as assertivas abaixo:

I. Ao digitar a fórmula =SOMA(A1:C3) na célula C4, o resultado apresentado será 50.
II. Considerando que a célula C3 esteja selecionada e que o usuário clique no botão "Formato numérico: moeda" (ou "Adicionar casa decimal"), o valor exibido passará a ser 20,00.
III. O botão "Inserir Anotação" (representado pelo ícone de balão de diálogo) tem como funcionalidade inserir um comentário na célula selecionada.

Quais estão corretas?',
         atualizado_em = now()
   WHERE id = 495;

  -- ID 496: Enunciado autossuficiente (botão Compartilhar no Chrome)
  UPDATE public.questoes
     SET enunciado = 'Na barra de ferramentas e de endereços do navegador Google Chrome (versão para computador), o botão representado por uma caixa com uma seta apontando para cima e para fora tem como função:',
         atualizado_em = now()
   WHERE id = 496;

  -- ID 497: Enunciado autossuficiente (botão Recarregar no Firefox)
  UPDATE public.questoes
     SET enunciado = 'Na barra de navegação e de endereços do navegador Mozilla Firefox, o botão representado por uma seta circular (acionável pelo atalho F5 ou Ctrl+R) tem como função:',
         atualizado_em = now()
   WHERE id = 497;

  -- ID 791: Enunciado e alternativas com descrição dos ícones do Writer
  UPDATE public.questoes
     SET enunciado = 'Assinale a alternativa que apresenta INCORRETAMENTE a relação entre o ícone de botão e sua funcionalidade no LibreOffice Writer:',
         atualizado_em = now()
   WHERE id = 791;
  UPDATE public.alternativas
     SET texto = 'Ícone do Pincel de Pintura – Clonar Formatação.'
   WHERE id = 3932 AND questao_id = 791;
  UPDATE public.alternativas
     SET texto = 'Ícone da Lupa com Página – Zoom.'
   WHERE id = 3933 AND questao_id = 791;
  UPDATE public.alternativas
     SET texto = 'Ícone de Página Partida – Inserir Quebra de Página.'
   WHERE id = 3934 AND questao_id = 791;
  UPDATE public.alternativas
     SET texto = 'Ícone da Prancheta com Papel – Colar.'
   WHERE id = 3935 AND questao_id = 791;
  UPDATE public.alternativas
     SET texto = 'Ícone da Letra Grega Ômega (Ω) – Inserir Caracteres Especiais.'
   WHERE id = 3936 AND questao_id = 791;

  -- ID 831: Enunciado com lacuna e símbolo do botão Mostrar/Ocultar (¶)
  UPDATE public.questoes
     SET enunciado = 'No Microsoft Word 2016, o botão ____________ (representado pelo símbolo de parágrafo ¶) liga e desliga caracteres ocultos como espaços, marcadores de parágrafo ou marcas de tabulação. Assinale a alternativa que preenche corretamente a lacuna do trecho acima.',
         atualizado_em = now()
   WHERE id = 831;

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

  -- Assert 2: Nenhuma alteração de ativa no escopo (todas as 89 questões de Informática ativas)
  IF (SELECT count(*) FROM public.questoes WHERE materia_id = 9 AND ativa = true) <> 89 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões de Informática tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão em todo o universo das 89 questões de Informática
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas a JOIN public.questoes q ON q.id = a.questao_id WHERE q.materia_id = 9) <> 89 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas a
         JOIN public.questoes q ON q.id = a.questao_id
        WHERE q.materia_id = 9
        GROUP BY a.questao_id
       HAVING count(*) FILTER (WHERE a.correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões de Informática não possuem exatamente 1 alternativa correta';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos específicos em cada uma das 89 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 11 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 11 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 15 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 15 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 31 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 31 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 32 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 32 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 33 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 33 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 60 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 60 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 61 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 61 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 62 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 62 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 63 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 63 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 64 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 64 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 91 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 91 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 92 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 92 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 93 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 93 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 94 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 94 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 95 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 95 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 96 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 96 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 97 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 97 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 98 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 98 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 99 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 99 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 100 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 100 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 101 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 101 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 102 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 102 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 103 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 103 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 104 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 104 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 105 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 105 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 106 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 106 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 107 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 107 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 108 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 108 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 109 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 109 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 110 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 110 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 294 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 294 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 338 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 338 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 339 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 339 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 340 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 340 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 341 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 341 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 492 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 492 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 493 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 493 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 494 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 494 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 495 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 495 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 496 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 496 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 497 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 497 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 498 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 498 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 499 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 499 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 626 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 626 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 627 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 627 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 628 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 628 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 629 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 629 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 630 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 630 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 631 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 631 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 632 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 632 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 633 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 633 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 634 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 634 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 635 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 635 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 636 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 636 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 637 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 637 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 638 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 638 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 639 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 639 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 640 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 640 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 641 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 641 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 642 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 642 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 643 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 643 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 644 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 644 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 645 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 645 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 698 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 698 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 699 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 699 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 700 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 700 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 701 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 701 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 702 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 702 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 703 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 703 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 704 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 704 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 705 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 705 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 706 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 706 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 707 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 707 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 708 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 708 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 709 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 709 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 710 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 710 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 711 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 711 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 768 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 768 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 769 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 769 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 770 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 770 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 791 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 791 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 792 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 792 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 830 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 830 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 831 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 831 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 832 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 832 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 833 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 833 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 834 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 834 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 835 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 835 de Informática';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 836 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão 836 de Informática';
  END IF;

  -- Assert 5: 77 questões intocadas mantiveram seus hashes integrais
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 11) <> '4e3aeb7cdd3ef4dc455e52259af2a579' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 11) <> '051a4ea25d11c9bafe220706dfa94f20' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 11 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 15) <> 'f117002c7a2df47ae27cb8c78f9f85af' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 15) <> 'dadcb215cd370d5194644fac5774c972' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 15 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 31) <> 'ef843ae0953970de7ad2cded8f79797c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 31) <> '6c07cead85c1b06cd7df189d067d7dd4' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 31 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 32) <> '84b58d8b56cba2eae2bc33b1cef51b92' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 32) <> '65c8a66d516bff62b8c6aafe68917cc7' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 32 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 33) <> '7b30f58ed88c4e96e61d70fbf054119c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 33) <> '422a3c43f0656492132d65ae88bc2897' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 33 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 61) <> '03dfc8cb627c237cd5b7da41bb22ff23' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 61) <> 'b12c8639ec815731c09ea0dc9b9e386c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 61 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 62) <> 'fdb3f282186e4151855d3f5d7e284f4f' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 62) <> '8d8dfed52b46f86ef8aa60201898db47' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 62 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 63) <> 'e58f47083df5aa02966939435d5e4eae' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 63) <> '7088d88bd0966a4fddf5686def666a81' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 63 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 91) <> 'cbca6e1550aa4fc88c70d5481bd4d63c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 91) <> '3d359049ce0feb70fb7080ea1eb0f2ed' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 91 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 92) <> '044df8ca78f9cc922d55be4f8a817529' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 92) <> 'dcd949e1024fe8b446d446e4749d3448' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 92 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 93) <> 'cf221e3cb80e60e76f724681d2f62553' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 93) <> '8b880defbddb4a20151c44f85a0d7c67' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 93 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 94) <> 'eef7188484e1669d283fa44d35a66473' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 94) <> '4ae574d898d5cc0163423a6dd39910cd' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 94 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 95) <> '379d386e9b88bc9bb94c0c4a1205851a' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 95) <> '938a02712318d130d4805f84d8c1f29e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 95 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 96) <> '29447b377c86e9db7f41d85159dbe7ef' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 96) <> '1772fc3affac3643a15698bb9e3dd8a0' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 96 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 97) <> '4eeb77615efc62bafcc64a6424cae8c4' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 97) <> '389581dc6b09f3ed722adc4507ab5c7f' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 97 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 98) <> '918de151dbddb1889836abd036fc3080' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 98) <> '46b27c1c3c50d016d4f2fb131360854e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 98 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 99) <> '91a16ec954c6ae3c007ebe9b44947068' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 99) <> '1bc4939d04c42eea804ce01ee662badd' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 99 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 100) <> '7aeaeed842e0652db24885f2679cb7f5' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 100) <> '5e47c395249d43ad9bd0d5b82ee900c2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 100 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 101) <> 'dcc4b247d7ab65f8f25f40d471607671' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 101) <> 'b2e0deafdbbff255b565e01bb626ee9c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 101 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 102) <> 'e14ef78c141fbce4d065b5a0921d8f3e' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 102) <> '33fe39aa769d06e7ea16ac70cf49fa79' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 102 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 103) <> '9b19df533c974163bc00304b9fe7aa12' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 103) <> 'f0b2b8a5a3f270e9deeaad84c9a9f2b8' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 103 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 104) <> '22f20de454438fb2183555c605a94d04' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 104) <> '780074d1939695a8a7d796aa568a0b35' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 104 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 105) <> 'b89ab7797351332a7431e5dcacd6f226' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 105) <> '21fa0d74f26b5ad085394dcf2b085bc4' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 105 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 106) <> '8a07adee33e941913531fe97b559224d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 106) <> '586d34c1888819e9d5771d502c73a8bb' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 106 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 107) <> '73411e2cfd74e0ca486d5b16d6dbdaf8' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 107) <> '6a54a8bd1b3672759ad1e1e166f94cae' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 107 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 108) <> '004a86990e08796e729da01cf39efb71' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 108) <> '4db646dc4b10ddc2f05aadcfffeb7fdb' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 108 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 109) <> '65872511e5b32694e74d518b5cd7ac03' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 109) <> '68340ee4ca957d8bfecd9fd920e1f39b' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 109 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 110) <> 'b5eb2481e9c214d92a7298c8ce3db6ed' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 110) <> '7dcf57b53c302aeca6752a98fdb65676' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 110 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 294) <> 'c4c088d94adcfd286e2ab17e7bf7b6c7' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 294) <> 'f5a520e26bbaebae540337ca199ffaa5' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 294 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 339) <> '69a54ba500554230adabfa1d547ffce6' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 339) <> '74c736fa620636774681b53bfec9e9ae' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 339 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 340) <> '8b6d94b4788569fe79813263243f4322' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 340) <> '865ae19edc79e36a18262ad45c7f79d3' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 340 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 498) <> '2a6e782d3b08452b3e5e030537fff2a8' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 498) <> '1c8751f5f53cbcd48b87b926aabbced3' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 498 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 499) <> '15b370a60938a7666ad295cc691bfdaf' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 499) <> '7357dd37bd2e286c8d1b75601bf7f40e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 499 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 626) <> 'e0a2ea0730b33a52cf59d1fc1f621f65' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 626) <> '35f1dcd7834c18966f26ad6a26b07552' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 626 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 627) <> 'f5d17f22dc3beb0881debb1b52cfe0f9' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 627) <> 'ae580f97a92d2498a9a1d6bb3aa09770' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 627 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 628) <> '4a432fa3a202c53bf731fed9f7b24f34' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 628) <> 'a0c6f18e6666ede8414db90863c891a7' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 628 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 629) <> '8094769b496019bf1294ed111592cd3b' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 629) <> 'fbcc9a8b9ee310960c0795d6ecc39cd2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 629 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 630) <> 'c526abcc82ac37c857b5c61431c91c6b' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 630) <> '7283a6e18828073819d27c5f12a053ad' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 630 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 631) <> '9fda50487b355f1fef903dd7fc4ec555' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 631) <> 'ab401cf2f4da3d660408f25e8be1abb3' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 631 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 632) <> '5b6d65a5d83f2104c1d48075e8da5f25' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 632) <> '89b9245acb7ea75c890afeeb05ebe2de' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 632 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 633) <> '84035418115c2b1229298020d298a075' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 633) <> '3eca3eed0c94efb5355d26d80bf0df8a' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 633 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 634) <> '05521baf796800d41091ceab36d7d60d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 634) <> 'b337eea3a4633682e751a104f6e297ac' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 634 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 635) <> '54e616049521f153086fbd74ae559b86' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 635) <> '455d5310005247cbc4dbbf09cebe68ae' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 635 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 636) <> '119b6c32a43fa0621813338098e02d3b' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 636) <> 'd38b4ae74485103b99f0fb93f4ab5d17' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 636 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 637) <> '68a12e6689652bc263410a9b77a39ae7' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 637) <> '7f02cdaa569955aa64f4338c8394eea8' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 637 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 638) <> '4f150eaafbfe601fc7af988de6296cba' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 638) <> '28da3a22aa69d2a7bf2fc56fc1bf5bd0' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 638 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 639) <> '09cab23deb8319579cd15d8fcde4e67d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 639) <> '2423edd4b8bf111a3afebffe13da407c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 639 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 640) <> 'fe36a8fadbcfe601764839370738dabb' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 640) <> '9710c2a1814023d796c0b288137efda2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 640 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 641) <> 'e21502d7a1cb158adb92c10878850bd8' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 641) <> 'cab213f152ba7ecad2d1f48a73830bea' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 641 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 642) <> '79eb19246c7a33371d0e984704901121' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 642) <> 'efc3c0ad87eb0d9d01c58c8a3cc1b9a1' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 642 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 643) <> '8d9e80920ae8fd6d6d62c7ad30a3684d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 643) <> '9ba9c22000d901e8555da897190097bb' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 643 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 644) <> '6560dd904788c125d824d899986c7c0c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 644) <> '446c8a92ee742e32dd5e8c3c18fe158e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 644 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 645) <> '6eb971615424cb28d2376c7a253f6d8d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 645) <> 'c177615956c4dba277225f73780f7894' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 645 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 698) <> 'fdcd5a3f80b33ef3fd99b6463133246c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 698) <> 'a056b2722ec4f38992ac0924185be3a4' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 698 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 699) <> '34d9de3e369ba6bc3989e47bbee6721a' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 699) <> '7a52e1dea08b9509e2907b204c1d9a67' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 699 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 700) <> '12120e3a757f595c2fd7baf1ee1c687d' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 700) <> '579465c47b30471dd0f0c273c65c39a3' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 700 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 701) <> '303daf1af83302ee0ccae8b8477f2cdc' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 701) <> '7af5acb0c70de9ea081f99855cb48a64' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 701 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 702) <> '96799869fb573d492709eb3998209730' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 702) <> '93b171187ae8289636d9795fef1eab8e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 702 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 703) <> '903f946a5d0186440fb4c04bae1af8ea' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 703) <> '1abbb98d025b5fb6473e08b4713f1193' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 703 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 704) <> 'd15f427206067f98e016b2069091f321' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 704) <> 'f47184f3d41d19f98e074481f437b72d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 704 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 705) <> '1684aee80e82d34aad4a6027670b4231' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 705) <> 'e60d262de69a4713d632ae79a972bac0' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 705 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 706) <> 'ab6b85cf75393bdccc2cfe12512a6923' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 706) <> 'd80786d2efd6ab080cc66163d2fd6859' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 706 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 707) <> '0b0353101dd12a79a8c0eada726295dc' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 707) <> '6dc9482245f4647886e364889e8f3aef' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 707 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 708) <> '9536d8a84c07c122d5ede47c0ba10c83' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 708) <> '4f4c7dc8494d86c1cdc8c5f740d7d47d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 708 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 709) <> '2e46c5b0fcb6e5687d8e230cec8a3e62' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 709) <> '7103089b6af9a23438ffce93c835684f' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 709 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 710) <> '02d80ca4a6c30eb109a6b35efd1b7bd2' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 710) <> '8420355bdd8a33e0ce32ff39e8ae9e6a' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 710 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 711) <> '830547c1cc31925701eb8fa7c49814f2' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 711) <> '930574088364cc54154ead9299a66cf2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 711 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 768) <> '3d15ec6886c3e6860cbd2c724bdb3478' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 768) <> '3e919f91bfec9dbc20231cad4a93673a' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 768 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 769) <> '5596246b8929a63c9a523079db8a1d5f' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 769) <> 'e50d702850e53c4560a37218e76dd38d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 769 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 770) <> 'db1f99ac895426a04e354a42882bc7b8' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 770) <> 'e91a3595d1ca3776579f05107670eb48' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 770 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 792) <> '00d38c88ddc6c6bad1413d434e2eff9f' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 792) <> '3ddba4077341030b9bba0fe66150aa01' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 792 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 830) <> 'ebe5562e9a840ddec19f73aa0d75bdab' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 830) <> '3867ed3ff80c41ef7ad8eeda7c701b52' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 830 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 832) <> '3c5eff3c2c2cc22f949736038f265223' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 832) <> '84caf59df418b7c4762093b065bceea4' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 832 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 833) <> 'a3ad954f4e888f1f3c2a35eb5258346c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 833) <> 'c9d65152bb9b41cf354a8ad32c008868' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 833 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 834) <> '6362e16495dab37b6638dc807cd6aa66' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 834) <> 'a51f2944201de50603b351edc21174bd' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 834 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 835) <> '1853eee163a2d6cc0c888813229994dc' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 835) <> '2d413add3e59f01d344e6a6dfd0136d6' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 835 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 836) <> 'b48c0251ffa80af307d32ac6284a88b4' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 836) <> '0ef2db5d84dd575fa5eaf45a59fac53d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 836 (intocada) foi modificada indevidamente';
  END IF;

  -- Assert 6: Explicações de todas as 89 questões de Informática preservadas byte a byte
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 11) <> '051a4ea25d11c9bafe220706dfa94f20' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 11 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 15) <> 'dadcb215cd370d5194644fac5774c972' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 15 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 31) <> '6c07cead85c1b06cd7df189d067d7dd4' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 31 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 32) <> '65c8a66d516bff62b8c6aafe68917cc7' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 32 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 33) <> '422a3c43f0656492132d65ae88bc2897' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 33 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 60) <> 'f42b551276c42ee31d38d0b0648c388e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 60 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 61) <> 'b12c8639ec815731c09ea0dc9b9e386c' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 61 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 62) <> '8d8dfed52b46f86ef8aa60201898db47' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 62 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 63) <> '7088d88bd0966a4fddf5686def666a81' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 63 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 64) <> 'be86d8ebe60d58711c5c7d89bc7b8679' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 64 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 91) <> '3d359049ce0feb70fb7080ea1eb0f2ed' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 91 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 92) <> 'dcd949e1024fe8b446d446e4749d3448' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 92 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 93) <> '8b880defbddb4a20151c44f85a0d7c67' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 93 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 94) <> '4ae574d898d5cc0163423a6dd39910cd' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 94 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 95) <> '938a02712318d130d4805f84d8c1f29e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 95 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 96) <> '1772fc3affac3643a15698bb9e3dd8a0' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 96 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 97) <> '389581dc6b09f3ed722adc4507ab5c7f' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 97 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 98) <> '46b27c1c3c50d016d4f2fb131360854e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 98 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 99) <> '1bc4939d04c42eea804ce01ee662badd' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 99 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 100) <> '5e47c395249d43ad9bd0d5b82ee900c2' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 100 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 101) <> 'b2e0deafdbbff255b565e01bb626ee9c' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 101 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 102) <> '33fe39aa769d06e7ea16ac70cf49fa79' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 102 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 103) <> 'f0b2b8a5a3f270e9deeaad84c9a9f2b8' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 103 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 104) <> '780074d1939695a8a7d796aa568a0b35' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 104 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 105) <> '21fa0d74f26b5ad085394dcf2b085bc4' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 105 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 106) <> '586d34c1888819e9d5771d502c73a8bb' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 106 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 107) <> '6a54a8bd1b3672759ad1e1e166f94cae' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 107 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 108) <> '4db646dc4b10ddc2f05aadcfffeb7fdb' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 108 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 109) <> '68340ee4ca957d8bfecd9fd920e1f39b' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 109 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 110) <> '7dcf57b53c302aeca6752a98fdb65676' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 110 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 294) <> 'f5a520e26bbaebae540337ca199ffaa5' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 294 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 338) <> 'dab289957ace083ae4a421bbfc5b80f3' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 338 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 339) <> '74c736fa620636774681b53bfec9e9ae' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 339 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 340) <> '865ae19edc79e36a18262ad45c7f79d3' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 340 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 341) <> '454f43a2fee6b32d57b0a3458c3d8178' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 341 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 492) <> '66cb56b8058df7b99fc4530b5f0d5678' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 492 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 493) <> 'd1c40eeff375884be9d50b4e80c8e5b7' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 493 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 494) <> 'c7673ba240677825597113136a56ec69' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 494 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 495) <> '109239919a92afed3a484a87a20ec904' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 495 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 496) <> '5a1af9a6bd4b46917141a1b28dacf973' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 496 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 497) <> '85d644e0c2832f199aa3e91cf12100d7' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 497 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 498) <> '1c8751f5f53cbcd48b87b926aabbced3' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 498 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 499) <> '7357dd37bd2e286c8d1b75601bf7f40e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 499 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 626) <> '35f1dcd7834c18966f26ad6a26b07552' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 626 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 627) <> 'ae580f97a92d2498a9a1d6bb3aa09770' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 627 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 628) <> 'a0c6f18e6666ede8414db90863c891a7' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 628 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 629) <> 'fbcc9a8b9ee310960c0795d6ecc39cd2' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 629 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 630) <> '7283a6e18828073819d27c5f12a053ad' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 630 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 631) <> 'ab401cf2f4da3d660408f25e8be1abb3' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 631 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 632) <> '89b9245acb7ea75c890afeeb05ebe2de' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 632 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 633) <> '3eca3eed0c94efb5355d26d80bf0df8a' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 633 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 634) <> 'b337eea3a4633682e751a104f6e297ac' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 634 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 635) <> '455d5310005247cbc4dbbf09cebe68ae' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 635 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 636) <> 'd38b4ae74485103b99f0fb93f4ab5d17' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 636 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 637) <> '7f02cdaa569955aa64f4338c8394eea8' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 637 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 638) <> '28da3a22aa69d2a7bf2fc56fc1bf5bd0' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 638 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 639) <> '2423edd4b8bf111a3afebffe13da407c' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 639 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 640) <> '9710c2a1814023d796c0b288137efda2' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 640 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 641) <> 'cab213f152ba7ecad2d1f48a73830bea' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 641 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 642) <> 'efc3c0ad87eb0d9d01c58c8a3cc1b9a1' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 642 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 643) <> '9ba9c22000d901e8555da897190097bb' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 643 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 644) <> '446c8a92ee742e32dd5e8c3c18fe158e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 644 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 645) <> 'c177615956c4dba277225f73780f7894' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 645 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 698) <> 'a056b2722ec4f38992ac0924185be3a4' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 698 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 699) <> '7a52e1dea08b9509e2907b204c1d9a67' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 699 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 700) <> '579465c47b30471dd0f0c273c65c39a3' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 700 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 701) <> '7af5acb0c70de9ea081f99855cb48a64' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 701 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 702) <> '93b171187ae8289636d9795fef1eab8e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 702 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 703) <> '1abbb98d025b5fb6473e08b4713f1193' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 703 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 704) <> 'f47184f3d41d19f98e074481f437b72d' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 704 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 705) <> 'e60d262de69a4713d632ae79a972bac0' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 705 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 706) <> 'd80786d2efd6ab080cc66163d2fd6859' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 706 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 707) <> '6dc9482245f4647886e364889e8f3aef' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 707 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 708) <> '4f4c7dc8494d86c1cdc8c5f740d7d47d' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 708 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 709) <> '7103089b6af9a23438ffce93c835684f' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 709 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 710) <> '8420355bdd8a33e0ce32ff39e8ae9e6a' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 710 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 711) <> '930574088364cc54154ead9299a66cf2' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 711 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 768) <> '3e919f91bfec9dbc20231cad4a93673a' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 768 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 769) <> 'e50d702850e53c4560a37218e76dd38d' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 769 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 770) <> 'e91a3595d1ca3776579f05107670eb48' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 770 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 791) <> '35f07bb0f56e264298264fef159e2da6' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 791 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 792) <> '3ddba4077341030b9bba0fe66150aa01' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 792 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 830) <> '3867ed3ff80c41ef7ad8eeda7c701b52' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 830 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 831) <> '49915c09fb680aab36175793ef3b6e4b' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 831 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 832) <> '84caf59df418b7c4762093b065bceea4' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 832 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 833) <> 'c9d65152bb9b41cf354a8ad32c008868' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 833 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 834) <> 'a51f2944201de50603b351edc21174bd' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 834 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 835) <> '2d413add3e59f01d344e6a6dfd0136d6' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 835 foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 836) <> '0ef2db5d84dd575fa5eaf45a59fac53d' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 836 foi alterada indevidamente';
  END IF;

  -- Assert 7: Validações específicas de conteúdo higienizado
  -- ID 60: Acesso Rápido presente e sem 'Figura 1 abaixo'
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 60;
  IF v_enunciado_check NOT ILIKE '%Barra de Ferramentas de Acesso Rápido%' OR v_enunciado_check ILIKE '%Figura 1 abaixo%' THEN
    RAISE EXCEPTION 'Assert 7a falhou: enunciado da questão 60 não contém a descrição da Barra de Acesso Rápido';
  END IF;

  -- ID 64: Ícone com silhueta e sinal + presente e sem 'imagem abaixo'
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 64;
  IF v_enunciado_check NOT ILIKE '%silhueta de pessoa acompanhada de um sinal de adição (+)%' OR v_enunciado_check ILIKE '%imagem abaixo%' THEN
    RAISE EXCEPTION 'Assert 7b falhou: enunciado da questão 64 não contém a descrição do botão de compartilhar';
  END IF;

  -- ID 341: Alt E limpa sem 'CONHECIMENTOS ESPECÍFICOS'
  SELECT texto INTO v_alt_check FROM public.alternativas WHERE id = 1686 AND questao_id = 341;
  IF v_alt_check <> 'Tachado.' THEN
    RAISE EXCEPTION 'Assert 7c falhou: alternativa E da questão 341 ainda contém resíduo de cabeçalho';
  END IF;

  -- ID 492: Tabela de ocorrências formatada
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 492;
  IF v_enunciado_check NOT ILIKE '%=SOMA(B4:D4)%' OR v_enunciado_check ILIKE '%Figura 1 abaixo%' THEN
    RAISE EXCEPTION 'Assert 7d falhou: enunciado da questão 492 não contém a tabela formatada';
  END IF;

  -- ID 495: Tabela Calc e botões descritos
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 495;
  IF v_enunciado_check NOT ILIKE '%Formato numérico: moeda%' OR v_enunciado_check NOT ILIKE '%Inserir Anotação%' THEN
    RAISE EXCEPTION 'Assert 7e falhou: enunciado da questão 495 não contém a descrição dos botões';
  END IF;

  -- ID 791: Alternativas com nomes de ícones
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 791 AND texto LIKE '– %') > 0 THEN
    RAISE EXCEPTION 'Assert 7f falhou: alternativas da questão 791 ainda contêm travessão isolado sem ícone';
  END IF;

  -- ID 831: Símbolo de parágrafo ¶ presente
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 831;
  IF v_enunciado_check NOT ILIKE '%¶%' OR v_enunciado_check NOT ILIKE '%____________%' THEN
    RAISE EXCEPTION 'Assert 7g falhou: enunciado da questão 831 não contém a lacuna ou o símbolo ¶';
  END IF;

  -- Assert 8: Ausência de resíduos colados de OCR nos enunciados de linha única (60, 64, 338, 341, 493, 494, 496, 497, 791, 831)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (60, 64, 338, 341, 493, 494, 496, 497, 791, 831) AND (
        position(E'\n' in enunciado) > 0 OR
        position('\n' in enunciado) > 0 OR
        enunciado LIKE '%pode -se%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 8 falhou: quebras de linha ou resíduos de OCR ainda detectados em enunciados';
  END IF;

  RAISE NOTICE 'TODOS OS 8 ASSERTS DA FASE 3A (INFORMÁTICA) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;