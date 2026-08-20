-- ============================================================================
-- FASE 2S-B — ESTATUTO ESTADUAL DA IGUALDADE RACIAL (LEI ESTADUAL RS 13.694/2011)
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

  -- Validação dos hashes pré-apply das 2 questões do lote
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 132) <> '93fff4839caedd121cb3a33690ed1ccc' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 132 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 367) <> '1a314728ac4dbd9239d9bae027fbe54d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 367 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 132) <> '9cbe461900aef9000576a0e22c383e08' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 132 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 367) <> 'e1c1b60a02f7993efc4f94f9e03c9b9d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 367 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (2 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é V – V – F, com fundamento em três dispositivos da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial):
- (V) Artigo 18: "A inclusão do quesito raça, a ser registrado segundo a autoclassificação, será obrigatória em todos os registros administrativos direcionados a empregadores e trabalhadores dos setores público e privado."
- (V) Artigo 11: "Nas datas comemorativas de caráter cívico, as instituições de ensino públicas deverão inserir nas aulas, palestras, trabalhos e atividades afins, dados históricos sobre a participação dos negros nos fatos comemorados."
- (F) Artigo 14: "Nas instituições de ensino, públicas e privadas, deverá ser oportunizado o aprendizado e a prática da CAPOEIRA, como atividade esportiva, cultural e lúdica, sendo facultada a participação dos mestres tradicionais de capoeira para atuarem como instrutores desta arte-esporte." A lei fala expressamente em capoeira — "Kuduro" (dança de origem angolana) não consta em nenhum dispositivo deste Estatuto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira e a segunda assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é verdadeira e a terceira é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva é falsa (a lei estadual refere-se expressamente à capoeira, não a Kuduro).

BIZU DE PROVA:
Estatuto Estadual da Igualdade Racial do RS:
Quesito raça = Art. 18; Datas comemorativas cívicas = Art. 11; Capoeira nas escolas = Art. 14 — "Kuduro" NÃO consta na lei!', atualizado_em = now() WHERE id = 132;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa B (é a alternativa INCORRETA)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (E É O GABARITO):
O Artigo 14 da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial) dispõe: "Nas instituições de ensino, públicas e privadas, deverá ser oportunizado o aprendizado e a prática da capoeira, como atividade esportiva, cultural e lúdica, sendo FACULTADA a participação dos mestres tradicionais de capoeira para atuarem como instrutores desta arte-esporte." A alternativa altera o sentido do dispositivo legal ao afirmar que essa participação é "OBRIGATÓRIA" — o texto da lei é exatamente o oposto: a participação dos mestres tradicionais é facultativa, não obrigatória. Essa inversão de palavra-chave (facultada → obrigatória) é o que torna a alternativa incorreta, e não a simples menção à capoeira.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO CORRETAS:
As alternativas A, C, D e E reproduzem, sem alteração de sentido, disposições do Estatuto Estadual da Igualdade Racial (Lei nº 13.694/2011) sobre saúde da população negra, comunidades quilombolas, acesso ao ensino e a atividades esportivas, e respeito à diversidade racial nas instituições de ensino — por isso não são a alternativa a ser assinalada.

BIZU DE PROVA:
Capoeira nas escolas (Art. 14 da Lei Estadual RS 13.694/2011):
A participação dos mestres tradicionais de capoeira como instrutores é FACULTADA, nunca obrigatória — fique atento a essa inversão clássica de banca!', atualizado_em = now() WHERE id = 367;

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

  -- Assert 2: Status "ativa" preservado nas 2 questões do lote
  IF (SELECT count(*) FROM public.questoes WHERE id IN (132, 367) AND ativa = true) <> 2 THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa alterado indevidamente em alguma questão do lote';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão, 5 alternativas presentes
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (132, 367)) <> 2 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id IN (132, 367)) <> 10 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (132, 367)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: alternativas divergentes do estado esperado (5 por questão, exatamente 1 correta)';
  END IF;

  -- Assert 4: Gabaritos oficiais preservados em cada uma das 2 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 132 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 132 (esperado ordem 4)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 367 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 367 (esperado ordem 2)';
  END IF;

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 132) <> '93fff4839caedd121cb3a33690ed1ccc' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 132 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 367) <> '1a314728ac4dbd9239d9bae027fbe54d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 367 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 6: Questão 132 - explicação contém os três artigos corretos da Lei 13.694/2011
  -- (Art. 18, Art. 11 e Art. 14) e não contém mais os números errados anteriores
  -- (Artigo 50, Artigo 17 e Artigo 20 usados como fundamento das três assertivas)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 132;
  IF v_explicacao_check NOT ILIKE '%Artigo 18%' OR
     v_explicacao_check NOT ILIKE '%Artigo 11%' OR
     v_explicacao_check NOT ILIKE '%Artigo 14%' OR
     v_explicacao_check NOT ILIKE '%Kuduro%' OR
     v_explicacao_check ILIKE '%Artigo 50%' OR
     v_explicacao_check ILIKE '%Artigo 17%' OR
     v_explicacao_check ILIKE '%Artigo 20%' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 132 incorreta ou ainda contendo número de artigo errado';
  END IF;

  -- Assert 7: Questão 367 - explicação contém o artigo correto (Art. 14) e a fundamentação
  -- reforçada da inversão facultada/obrigatória, e não contém mais o número errado (Art. 20)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 367;
  IF v_explicacao_check NOT ILIKE '%Artigo 14%' OR
     v_explicacao_check NOT ILIKE '%FACULTADA%' OR
     v_explicacao_check NOT ILIKE '%OBRIGATÓRIA%' OR
     v_explicacao_check ILIKE '%Artigo 20%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 367 incorreta ou ainda contendo número de artigo errado / sem a fundamentação da inversão facultada-obrigatória';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2S-B (ESTATUTO ESTADUAL DA IGUALDADE RACIAL) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;