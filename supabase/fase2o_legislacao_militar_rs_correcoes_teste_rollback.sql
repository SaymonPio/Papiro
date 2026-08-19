-- ============================================================================
-- FASE 2O — LEGISLAÇÃO MILITAR ESTADUAL / BM-RS (LC 10.990, LC 10.991, LC 10.992, DEC 43.245)
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
  v_intocada_hash text;
  v_explicacao_check text;
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

  -- Validação dos hashes pré-apply das 22 questões auditadas no universo da BM/RS
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 12) <> '1125999709e4c7ca3fbcbd0c78427c25' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 12 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 20) <> '7b2bacd77c0676060f7d9bd8672292e6' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 20 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 39) <> 'd432476f6cb761a6da51fb7992347c17' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 39 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 43) <> '7d4e5653ee3fc34f266d394d4967109c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 43 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 45) <> '8385aff2580e403e5004bbf5adc8081e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 45 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 53) <> '7cfec26d75547fcfb22e1b72dafbe95b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 53 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 201) <> '28b0381fc245b69cbe167e988756afa9' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 201 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 202) <> '188e21474208d249e43fd26fd9d50f11' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 202 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 203) <> '7250b451fca89cd0abd4139d3d5ee0d1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 203 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 210) <> '1b295f6fe4707428094c13aeb7974282' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 210 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 211) <> '559cad60c6aec54a2dae205e62ee2449' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 211 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 212) <> 'a3c8936d7dd227a9c1c474fd8c115bec' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 212 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 271) <> '3572c57489c5934e090d4a363f422637' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 271 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 272) <> '8ccef36b7dab6e9db0b9ee4f09d8d06c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 272 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 300) <> '2255b733ff61e542e3c1ec64bc40b720' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 300 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 303) <> '393757b3158871d440336c8ff2dc6470' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 303 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 362) <> '10f245ccf93cf1032fc8562013cf3104' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 362 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 363) <> '00e8f8fe08cc318e4d163798cecfbba2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 363 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 364) <> 'f11bb6df86557538d09b6a3e56c412b3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 364 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 368) <> '1ea6df46d0176db8aa1acbe0c184d90f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 368 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 369) <> 'd7f185ecbb40dc980120b53773c92ccf' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 369 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 370) <> '96e172a42233c5748bd5bd71261af9bd' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 370 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 12) <> '309f4c2b9ab2878ff946b8068d332953' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 12 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 20) <> '034039705c5f86fc8117beb1240e92d2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 20 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 39) <> '3de56d47dea4b06e8efa1bc84d086e16' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 39 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 43) <> '34558e7ce2d01e5d29393e374fa7d26c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 43 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 45) <> '1639152f38fe4767580ec275b6209ae1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 45 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 53) <> 'e49731ef3a50bb5c9c8920b5ab3048c7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 53 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 201) <> 'f893d7f3bcec107f3a2207e084aa36fd' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 201 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 202) <> '01cfb5cd2470430e2586271e4484c367' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 202 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 203) <> 'f213fe51737a53bad359017bc0fa30c8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 203 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 210) <> 'e969481c4a982f7bfe911d95b7f9dc91' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 210 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 211) <> 'ec3f3c81253fe64f6fcc8094d2573c83' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 211 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 212) <> '307d0d8a107413dd8bf1ecd176a67d07' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 212 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 271) <> 'c67a830b6c0685021688bd8280793275' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 271 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 272) <> '665194766dbb81a46741d841efa5683b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 272 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 300) <> '6c6673763ab1e621834b064e2c0cca2c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 300 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 303) <> '87d0d92f7cc36be93aab3997e25be25d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 303 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 362) <> '030b8ccfea6e4fe2ffebcccaa1289725' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 362 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 363) <> 'f73cd7882133c20d32b8284f37aea362' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 363 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 364) <> '686a5cc72cecba7ba6e12a19f63135c5' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 364 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 368) <> '2ebcbeeb01314fa38d85f4f3aafca89c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 368 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 369) <> '8a4847657e3ae08afdf022ce2eb304e1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 369 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 370) <> 'd00058a27a7c6a35f74cdb276dd6cc4e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 370 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (9 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 210: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Regulamento Disciplinar da Brigada Militar do Estado do Rio Grande do Sul (aprovado pelo Decreto Estadual nº 43.245/2004) tem por finalidade central especificar as transgressões disciplinares, regular a aplicação das sanções disciplinares, estabelecer os recursos cabíveis e definir o processo administrativo disciplinar aplicável aos servidores militares estaduais, com o objetivo de preservar os pilares da hierarquia e da disciplina na corporação.

POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:
- B: Matéria tributária federal é regida pelo Código Tributário Nacional e pela Constituição Federal.
- C: A matéria eleitoral é privativa da União (Código Eleitoral).
- D: A criação de crimes e cominação de penas é competência privativa da União (Código Penal e Código Penal Militar).
- E: Contratos de direito privado são regidos pelo Código Civil.

BIZU DE PROVA:
Finalidade do Regulamento Disciplinar da BM (Decreto nº 43.245/2004):
Definir deveres, tipificar transgressões disciplinares, regular sanções administrativas e estabelecer os procedimentos disciplinares militares estaduais!',
         atualizado_em = now()
   WHERE id = 210;

  -- ID 211: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A aplicação de qualquer sanção disciplinar militar aos servidores da Brigada Militar e do Corpo de Bombeiros Militar do RS subordina-se estritamente ao princípio da legalidade, ao devido processo legal, ao contraditório e à ampla defesa, devendo observar rigorosamente os princípios, ritos e critérios dosimétricos fixados na Constituição Federal (Art. 5º, LV), no Estatuto dos Militares Estaduais (LC nº 10.990/1997) e no Regulamento Disciplinar da Brigada Militar (Decreto Estadual nº 43.245/2004).

POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:
- B: O poder disciplinar é vinculado e regrado pela lei e pelo regulamento, sendo vedado o arbítrio fundado em vontade pessoal.
- C: O direito à ampla defesa e ao contraditório é garantia constitucional inafastável no processo disciplinar.
- D: O direito administrativo disciplinar militar rege-se pelo princípio da legalidade estrita, não por meros costumes informais.
- E: A apuração disciplinar militar é técnica, impessoal e orientada pela verdade real dos fatos apurados.

BIZU DE PROVA:
Processo Disciplinar Militar (Decreto nº 43.245/2004):
A aplicação de sanções exige observância do DEVIDO PROCESSO LEGAL, contraditório, ampla defesa, proporcionalidade e legalidade estrita!',
         atualizado_em = now()
   WHERE id = 211;

  -- ID 212: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 42 c/c Artigo 142 da Constituição Federal, do Artigo 11 da Lei Complementar Estadual nº 10.990/1997 e do Regulamento Disciplinar da Brigada Militar (Decreto Estadual nº 43.245/2004), a HIERARQUIA e a DISCIPLINA constituem as bases institucionais permanentes da organização militar estadual, crescendo a autoridade e a responsabilidade com a elevação do grau hierárquico.

POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:
- B: Possuem máxima relevância e cogência jurídica, estruturando toda a corporação militar e o dever de obediência.
- C: São princípios fundamentais de direito público institucional militar.
- D e E: Não se confundem com regras eleitorais ou tributárias.

BIZU DE PROVA:
Pilares da Estrutura Militar (CF/88, LC 10.990/97 e Dec. 43.245/2004):
- HIERARQUIA: Ordenação progressiva da autoridade em postos (oficiais) e graduações (praças).
- DISCIPLINA: Rigorosa observância e acatamento integral das leis, ordens legais e regulamentos.',
         atualizado_em = now()
   WHERE id = 212;

  -- ID 362: Higiene de OCR no enunciado e alternativa D (explicação preservada)
  UPDATE public.questoes
     SET enunciado = 'De acordo com a Lei Complementar nº 10.990/1997 do Estado do Rio Grande do Sul, que trata do Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul, são direitos dos servidores militares, nos limites estabelecidos na legislação específica, EXCETO:',
         atualizado_em = now()
   WHERE id = 362;
  UPDATE public.alternativas
     SET texto = 'A assistência judiciária gratuita, em qualquer hipótese, quando processado em razão de atos praticados em objeto de serviço ou fora dele.'
   WHERE id = 1790 AND questao_id = 362;

  -- ID 363: Nova explicação (arts. 39 e 40 da LC 10.990/97) + higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'De acordo com o Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul, especificamente em relação à violação das obrigações e dos deveres, analise as assertivas abaixo:

I. A violação das obrigações ou dos deveres policiais-militares constituirá crime, contravenção ou transgressão disciplinar, conforme dispuserem a legislação ou regulamentação específicas.
II. A responsabilidade disciplinar é subordinada às responsabilidades civil e penal.
III. Não se caracteriza como violação das obrigações e dos deveres do servidor militar o inadimplemento de obrigações pecuniárias assumidas na vida privada.
IV. A inobservância dos deveres especificados nas leis e regulamentos, ou a falta de exação no cumprimento dos mesmos, acarreta, para o servidor militar, responsabilidade funcional, pecuniária, disciplinar e penal, consoante legislação específica.

Quais estão corretas?',
         explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I, III e IV, nos termos expressos da Lei Complementar Estadual nº 10.990/1997 (Estatuto dos Militares Estaduais do RS):

- Assertiva I (Correta): Reproduz textualmente o Artigo 39, caput: "A violação das obrigações ou dos deveres policiais-militares constituirá crime, contravenção ou transgressão disciplinar, conforme dispuserem a legislação ou regulamentação específicas."
- Assertiva II (Incorreta): O Artigo 40, § 1º prescreve que "a responsabilidade disciplinar é INDEPENDENTE das responsabilidades civil e penal", e não subordinada a elas.
- Assertiva III (Correta): Reproduz expressamente o Artigo 39, § 1º: "Não se caracteriza como violação das obrigações e dos deveres do servidor militar o inadimplemento de obrigações pecuniárias assumidas na vida privada."
- Assertiva IV (Correta): Reproduz a literalidade do Artigo 40, caput: "A inobservância dos deveres especificados nas leis e regulamentos, ou a falta de exação no cumprimento dos mesmos, acarreta, para o servidor militar, responsabilidade funcional, pecuniária, disciplinar e penal, consoante legislação específica."

POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:
- A, C e E: Incluem incorretamente a assertiva II, que traz a falsa premissa de subordinação da responsabilidade disciplinar.
- B: Incompleta, pois omite a assertiva I, que também é juridicamente correta.

BIZU DE PROVA:
Violação de Deveres Militares (LC nº 10.990/1997):
1. Esferas de Responsabilidade (Art. 40, §1º): A responsabilidade disciplinar é INDEPENDENTE das esferas civil e penal!
2. Dívidas Privadas (Art. 39, §1º): Inadimplemento de obrigação pecuniária civil privada NÃO configura falta funcional militar.',
         atualizado_em = now()
   WHERE id = 363;

  -- ID 364: Nova explicação (arts. 2º, § 2º, 3º, §§ 1º e 2º, e 5º, §§ 1º e 2º da LC 10.992/97) + expurgo de cabeçalho e OCR no enunciado/alternativas
  UPDATE public.questoes
     SET enunciado = 'Considere o disposto na Lei Complementar nº 10.992/1997, que dispõe sobre a carreira dos Servidores Militares do Estado do Rio Grande do Sul, e assinale a alternativa INCORRETA.',
         explicacao = 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B É A INCORRETA (GABARITO):
A assertiva B contraria expressamente o Artigo 2º, § 2º, da Lei Complementar Estadual nº 10.992/1997 (Plano de Carreira dos Servidores Militares do RS), que estabelece: "A inclusão no quadro de acesso para a promoção ao posto de Coronel PODERÁ ser recusada pelo servidor." Portanto, a afirmação de que não poderia ser recusada torna a alternativa incorreta.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO CORRETAS NA LEI:
- Alternativa A (Correta): Reproduz textualmente o Artigo 3º, § 1º da LC nº 10.992/1997 (ingresso no CSPM mediante concurso de provas e títulos com exigência de bacharelado em Ciências Jurídicas e Sociais).
- Alternativa C (Correta): Espelha a redação do Artigo 3º, § 2º da LC nº 10.992/1997 (condição de Aluno-Oficial durante a frequência ao CSPM, com duração máxima de dois anos).
- Alternativa D (Correta): Reflete expressamente o Artigo 5º, § 1º da LC nº 10.992/1997 (requisitos para Major: 3 anos de serviço em órgão de execução e aprovação no CAAPM).
- Alternativa E (Correta): Reproduz o Artigo 5º, § 2º da LC nº 10.992/1997 (exigência de aprovação no CEPGSP para promoção de Tenente-Coronel a Coronel).

BIZU DE PROVA:
Promoção ao Posto de Coronel (LC nº 10.992/1997, Art. 2º, §2º):
A inclusão no Quadro de Acesso ao posto de Coronel É FACULTATIVA, PODENDO SER RECUSADA formalmente pelo próprio Oficial militar!',
         atualizado_em = now()
   WHERE id = 364;
  UPDATE public.alternativas
     SET texto = 'O ingresso no Curso Superior de Polícia Militar dar-se-á mediante concurso público de provas e títulos com exigência de diplomação no Curso de Ciências Jurídicas e Sociais.'
   WHERE id = 1797 AND questao_id = 364;
  UPDATE public.alternativas
     SET texto = 'A inclusão no quadro de acesso para a promoção ao posto de Coronel não poderá ser recusada pelo servidor.'
   WHERE id = 1798 AND questao_id = 364;
  UPDATE public.alternativas
     SET texto = 'Os aprovados no concurso público de provas e títulos para ingresso no Quadro de Oficiais da Estado Maior, enquanto estiverem frequentando o Curso Superior de Polícia Militar, cujo prazo de duração não excederá a dois anos, serão considerados Alunos-Oficiais.'
   WHERE id = 1799 AND questao_id = 364;
  UPDATE public.alternativas
     SET texto = 'Para a promoção ao posto de Major, o ocupante do posto de Capitão deverá ter prestado serviços em órgão de execução por um período, consecutivo ou não, de, no mínimo, três anos e ter concluído, com aprovação, o Curso Avançado de Administração Policial Militar (CAAPM).'
   WHERE id = 1800 AND questao_id = 364;
  UPDATE public.alternativas
     SET texto = 'O acesso à promoção ao posto de Coronel, pelo ocupante do posto de Tenente-Coronel, exige a conclusão, com aprovação, do Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP).'
   WHERE id = 1801 AND questao_id = 364;

  -- ID 368: Higiene de OCR nas alternativas A, B, C, D e E (explicação preservada)
  UPDATE public.alternativas
     SET texto = 'Os Militares Estaduais na inatividade são alcançados, em qualquer hipótese, pelas disposições do Regulamento Disciplinar da Brigada Militar do Estado do Rio Grande do Sul.'
   WHERE id = 1817 AND questao_id = 368;
  UPDATE public.alternativas
     SET texto = 'A camaradagem é indispensável à formação e ao convívio entre os integrantes da Corporação, devendo estes primar pela melhor relação social entre si.'
   WHERE id = 1818 AND questao_id = 368;
  UPDATE public.alternativas
     SET texto = 'Incumbe ao superior hierárquico incentivar e manter a harmonia e a amizade entre seus subordinados.'
   WHERE id = 1819 AND questao_id = 368;
  UPDATE public.alternativas
     SET texto = 'A civilidade, como parte da educação policial-militar, é de importância vital para a disciplina no âmbito da Brigada Militar.'
   WHERE id = 1820 AND questao_id = 368;
  UPDATE public.alternativas
     SET texto = 'É indispensável que o superior trate com cortesia, urbanidade e justiça os seus subordinados e, em contrapartida, o subordinado deve externar, aos seus superiores, toda manifestação de respeito e deferência.'
   WHERE id = 1821 AND questao_id = 368;
  UPDATE public.questoes SET atualizado_em = now() WHERE id = 368;

  -- ID 369: Nova explicação (art. 14 e dispositivos pertinentes do Dec. nº 43.245/2004) + higiene de OCR nas alternativas
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A alternativa D reproduz expressamente a literalidade do Artigo 14, § 4º, do Regulamento Disciplinar da Brigada Militar (aprovado pelo Decreto Estadual nº 43.245/2004): "Exclusivamente para o atendimento das disposições de conversão de infração penal em disciplinar, previstas na lei penal militar, haverá o instituto da prisão administrativa, que consiste na permanência do punido no âmbito do aquartelamento, com prejuízo do serviço e da instrução."

POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:
- Alternativa A (Incorreta): A forma mais branda das sanções é a advertência (Art. 14, I). A repreensão é aplicada por escrito e publicada em boletim com averbação, mas não é a mais branda (Art. 16).
- Alternativa B (Incorreta): Nos termos do Artigo 15, § 1º, a advertência é a sanção mais branda, tem caráter estritamente verbal e confidencial, "não constará das alterações do Militar Estadual e não será publicada em Boletim".
- Alternativa C (Incorreta): O Artigo 17, caput dispõe expressamente que na detenção o militar punido permanece no local determinado "sem que fique confinado".
- Alternativa E (Incorreta): O licenciamento a bem da disciplina (Art. 19) e a exclusão a bem da disciplina (Art. 20) são sanções disciplinares expulsórias aplicadas de ofício (ex officio) pela autoridade competente, e não a pedido do militar.

BIZU DE PROVA:
Sanções Disciplinares na Brigada Militar (Decreto Estadual nº 43.245/2004):
1. Advertência (Art. 15): Mais branda, verbal/reservada, NÃO vai a boletim e NÃO vai aos assentamentos.
2. Repreensão (Art. 16): Escrita, publicada em boletim e averbada nos assentamentos.
3. Detenção (Art. 17): Cerceamento no quartel/local SEM confinamento.
4. Prisão Administrativa (Art. 14, §4º): Exclusiva para conversão de infração penal em disciplinar.
5. Licenciamento/Exclusão a bem da disciplina (Arts. 19/20): Punições expulsórias de ofício!',
         atualizado_em = now()
   WHERE id = 369;
  UPDATE public.alternativas
     SET texto = 'A repreensão, forma mais branda das sanções, será aplicada ostensivamente, por meio de publicação em Boletim, e será registrada nos assentamentos individuais do transgressor.'
   WHERE id = 1822 AND questao_id = 369;
  UPDATE public.alternativas
     SET texto = 'A advertência é sanção imposta ao transgressor de forma ostensiva, mediante publicação em Boletim, devendo sempre ser averbada nos assentamentos individuais do transgressor.'
   WHERE id = 1823 AND questao_id = 369;
  UPDATE public.alternativas
     SET texto = 'A detenção consiste no cerceamento da liberdade do punido, o qual deverá permanecer no local que lhe for determinado, ficando confinado.'
   WHERE id = 1824 AND questao_id = 369;
  UPDATE public.alternativas
     SET texto = 'Exclusivamente para o atendimento das disposições de conversão de infração penal em disciplinar, previstas na lei penal militar, haverá o instituto da prisão administrativa, que consiste na permanência do punido no âmbito do aquartelamento, com prejuízo do serviço e da instrução.'
   WHERE id = 1825 AND questao_id = 369;
  UPDATE public.alternativas
     SET texto = 'O licenciamento e a exclusão a bem da disciplina consistem no afastamento a pedido do Militar Estadual do serviço ativo, conforme preceitua o Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul.'
   WHERE id = 1826 AND questao_id = 369;

  -- ID 370: Higiene de OCR estrita ao enunciado e alternativas B e C (explicação e alternativas A, D, E preservadas)
  UPDATE public.questoes
     SET enunciado = 'A respeito do processo administrativo disciplinar militar previsto no referido Regulamento, assinale a alternativa INCORRETA.',
         atualizado_em = now()
   WHERE id = 370;
  UPDATE public.alternativas
     SET texto = 'Quando duas autoridades de níveis hierárquicos diferentes, ambas com competência disciplinar sobre o transgressor, tiverem conhecimento da transgressão disciplinar, caberá à de maior hierarquia apurá-la ou determinar que a menos graduada o faça.'
   WHERE id = 1828 AND questao_id = 370;
  UPDATE public.alternativas
     SET texto = 'Todo Militar Estadual que tiver conhecimento de um fato contrário à disciplina deverá participar ao seu superior imediato, por escrito ou verbalmente, independentemente de confirmação escrita.'
   WHERE id = 1829 AND questao_id = 370;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais (915 total / 907 ativas / 8 inativas - nenhuma ativação/desativação nesta Fase 2O)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (as 22 questões continuam com ativa inalterada)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (12, 20, 39, 43, 45, 53, 201, 202, 203, 210, 211, 212, 271, 272, 300, 303, 362, 363, 364, 368, 369, 370) AND ativa = true) <> 22 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões do universo da BM/RS tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão e presença de todas as 22 questões
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (12, 20, 39, 43, 45, 53, 201, 202, 203, 210, 211, 212, 271, 272, 300, 303, 362, 363, 364, 368, 369, 370)) <> 22 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (12, 20, 39, 43, 45, 53, 201, 202, 203, 210, 211, 212, 271, 272, 300, 303, 362, 363, 364, 368, 369, 370)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões do universo da BM/RS não possuem exatamente 1 alternativa correta ou estão ausentes no conjunto de alternativas';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos específicos em cada uma das 22 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 12 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 20 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 39 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 43 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 45 AND ordem = 2 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 53 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 201 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 202 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 203 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 210 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 211 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 212 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 271 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 272 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 300 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 303 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 362 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 363 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 364 AND ordem = 2 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 368 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 369 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 370 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial de uma das 22 questões';
  END IF;

  -- Assert 5: 13 questões intocadas mantiveram seus hashes integrais
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 12) <> '1125999709e4c7ca3fbcbd0c78427c25' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 12) <> '309f4c2b9ab2878ff946b8068d332953' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 12 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 20) <> '7b2bacd77c0676060f7d9bd8672292e6' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 20) <> '034039705c5f86fc8117beb1240e92d2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 20 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 39) <> 'd432476f6cb761a6da51fb7992347c17' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 39) <> '3de56d47dea4b06e8efa1bc84d086e16' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 39 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 43) <> '7d4e5653ee3fc34f266d394d4967109c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 43) <> '34558e7ce2d01e5d29393e374fa7d26c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 43 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 45) <> '8385aff2580e403e5004bbf5adc8081e' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 45) <> '1639152f38fe4767580ec275b6209ae1' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 45 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 53) <> '7cfec26d75547fcfb22e1b72dafbe95b' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 53) <> 'e49731ef3a50bb5c9c8920b5ab3048c7' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 53 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 201) <> '28b0381fc245b69cbe167e988756afa9' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 201) <> 'f893d7f3bcec107f3a2207e084aa36fd' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 201 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 202) <> '188e21474208d249e43fd26fd9d50f11' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 202) <> '01cfb5cd2470430e2586271e4484c367' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 202 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 203) <> '7250b451fca89cd0abd4139d3d5ee0d1' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 203) <> 'f213fe51737a53bad359017bc0fa30c8' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 203 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 271) <> '3572c57489c5934e090d4a363f422637' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 271) <> 'c67a830b6c0685021688bd8280793275' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 271 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 272) <> '8ccef36b7dab6e9db0b9ee4f09d8d06c' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 272) <> '665194766dbb81a46741d841efa5683b' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 272 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 300) <> '2255b733ff61e542e3c1ec64bc40b720' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 300) <> '6c6673763ab1e621834b064e2c0cca2c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 300 (intocada) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 303) <> '393757b3158871d440336c8ff2dc6470' OR
     (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 303) <> '87d0d92f7cc36be93aab3997e25be25d' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão 303 (intocada) foi modificada indevidamente';
  END IF;

  -- Assert 6: Explicações das questões de OCR puro (362, 368, 370) preservadas byte a byte
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 362) <> '030b8ccfea6e4fe2ffebcccaa1289725' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 362 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 368) <> '2ebcbeeb01314fa38d85f4f3aafca89c' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 368 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 370) <> 'd00058a27a7c6a35f74cdb276dd6cc4e' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 370 (OCR puro) foi alterada indevidamente';
  END IF;

  -- Assert 7: Questão 210 - fundamentação exclusiva no RDBM e ausência de contaminação por abuso/desvio de poder
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 210;
  IF v_explicacao_check NOT ILIKE '%Decreto Estadual nº 43.245/2004%' OR
     v_explicacao_check NOT ILIKE '%transgressões disciplinares%' OR
     v_explicacao_check ILIKE '%abuso de poder%' OR
     v_explicacao_check ILIKE '%excesso de poder%' OR
     v_explicacao_check ILIKE '%desvio de finalidade%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 210 incorreta ou contendo resíduos de abuso de poder';
  END IF;

  -- Assert 8: Questão 211 - fundamentação em princípios disciplinares e ausência de serviços públicos/CDC/Lei 8.987
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 211;
  IF v_explicacao_check NOT ILIKE '%Decreto Estadual nº 43.245/2004%' OR
     v_explicacao_check NOT ILIKE '%devido processo legal%' OR
     v_explicacao_check ILIKE '%serviço público%' OR
     v_explicacao_check ILIKE '%8.987%' OR
     v_explicacao_check ILIKE '%cdc%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: explicação da questão 211 incorreta ou contendo resíduos de concessão/serviços públicos';
  END IF;

  -- Assert 9: Questão 212 - fundamentação em hierarquia e disciplina militar e ausência de modicidade tarifária
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 212;
  IF v_explicacao_check NOT ILIKE '%HIERARQUIA%' OR
     v_explicacao_check NOT ILIKE '%DISCIPLINA%' OR
     v_explicacao_check ILIKE '%modicidade%' OR
     v_explicacao_check ILIKE '%tarifa%' OR
     v_explicacao_check ILIKE '%8.987%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 212 incorreta ou contendo resíduos de modicidade tarifária';
  END IF;

  -- Assert 10: Questão 363 - fundamentação nos arts. 39 e 40 da LC 10.990/97 e ausência de promoção/merecimento alienígenas
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 363;
  IF v_explicacao_check NOT ILIKE '%Artigo 39%' OR
     v_explicacao_check NOT ILIKE '%Artigo 40, § 1º%' OR
     v_explicacao_check NOT ILIKE '%INDEPENDENTE das responsabilidades civil e penal%' OR
     v_explicacao_check ILIKE '%ingresso nos quadros de oficiais%' OR
     v_explicacao_check ILIKE '%promoção por merecimento%' THEN
    RAISE EXCEPTION 'Assert 10 falhou: explicação da questão 363 incorreta ou contendo conteúdo alienígena sobre promoções';
  END IF;

  -- Assert 11: Questão 364 - fundamentação precisa nos arts. 2º, § 2º, 3º e 5º da LC 10.992/97 e ausência do cabeçalho de Igualdade Racial
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 364;
  IF v_explicacao_check NOT ILIKE '%Artigo 2º, § 2º%' OR
     v_explicacao_check NOT ILIKE '%PODERÁ ser recusada%' OR
     v_explicacao_check NOT ILIKE '%Artigo 3º, § 1º%' OR
     v_explicacao_check NOT ILIKE '%Artigo 3º, § 2º%' OR
     v_explicacao_check NOT ILIKE '%Artigo 5º, § 1º%' OR
     v_explicacao_check NOT ILIKE '%Artigo 5º, § 2º%' THEN
    RAISE EXCEPTION 'Assert 11a falhou: explicação da questão 364 não contém o mapeamento legal oficial exato dos artigos 2º, 3º e 5º da LC 10.992/97';
  END IF;

  SELECT texto INTO v_alt_check FROM public.alternativas WHERE id = 1801 AND questao_id = 364;
  IF v_alt_check ILIKE '%Estatuto da Igualdade Racial%' OR
     v_alt_check ILIKE '%13.694/2011%' OR
     v_alt_check ILIKE '%questões 75 a 77%' OR
     v_alt_check NOT ILIKE 'O acesso à promoção ao posto de Coronel, pelo ocupante do posto de Tenente-Coronel, exige a conclusão, com aprovação, do Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP).' THEN
    RAISE EXCEPTION 'Assert 11b falhou: alternativa E da questão 364 ainda contém cabeçalho alienígena ou texto truncado';
  END IF;

  -- Assert 12: Questão 369 - fundamentação no art. 14 e § 4º do Decreto nº 43.245/2004, sem conselho de justificação alienígena e sem teses falsas
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 369;
  IF v_explicacao_check NOT ILIKE '%Artigo 14, § 4º%' OR
     v_explicacao_check NOT ILIKE '%prisão administrativa%' OR
     v_explicacao_check ILIKE '%Conselho de Justificação: Julga os OFICIAIS%' OR
     v_explicacao_check ILIKE '%CONSELHO DE DISCIPLINA%' THEN
    RAISE EXCEPTION 'Assert 12a falhou: explicação da questão 369 incorreta ou contendo conteúdo alienígena sobre conselhos';
  END IF;

  IF v_explicacao_check ILIKE '%atualmente veda%' OR
     v_explicacao_check ILIKE '%atualmente proíbe%' THEN
    RAISE EXCEPTION 'Assert 12b falhou: explicação da questão 369 não pode afirmar que a Lei 13.967/19 atualmente veda a prisão disciplinar';
  END IF;

  -- Assert 13a: Enunciados de linha única (362, 364, 370) sem quebras de linha e sem resíduos de OCR
  IF (SELECT count(*) FROM public.questoes WHERE id IN (362, 364, 370) AND (
        position(E'\n' in enunciado) > 0 OR
        position('\n' in enunciado) > 0 OR
        enunciado LIKE '%n º%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 13a falhou: quebras de linha ou resíduos de OCR ainda detectados nos enunciados 362/364/370';
  END IF;

  -- Assert 13b: Enunciado com assertivas semânticas (363) - validação exata e ausência de resíduos de OCR
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 363;
  IF v_enunciado_check LIKE '%policiais -militares%' OR
     v_enunciado_check LIKE '%exa ção%' OR
     position('\n' in v_enunciado_check) > 0 OR
     v_enunciado_check <> 'De acordo com o Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul, especificamente em relação à violação das obrigações e dos deveres, analise as assertivas abaixo:

I. A violação das obrigações ou dos deveres policiais-militares constituirá crime, contravenção ou transgressão disciplinar, conforme dispuserem a legislação ou regulamentação específicas.
II. A responsabilidade disciplinar é subordinada às responsabilidades civil e penal.
III. Não se caracteriza como violação das obrigações e dos deveres do servidor militar o inadimplemento de obrigações pecuniárias assumidas na vida privada.
IV. A inobservância dos deveres especificados nas leis e regulamentos, ou a falta de exação no cumprimento dos mesmos, acarreta, para o servidor militar, responsabilidade funcional, pecuniária, disciplinar e penal, consoante legislação específica.

Quais estão corretas?' THEN
    RAISE EXCEPTION 'Assert 13b falhou: enunciado da questão 363 não confere com o texto higienizado aprovado ou contém resíduos de OCR';
  END IF;

  -- Assert 14: Ausência de resíduos colados de OCR nas alternativas tratadas (362, 364, 368, 369, 370)
  IF (SELECT count(*) FROM public.alternativas WHERE (
        (questao_id = 362 AND id = 1790) OR
        (questao_id = 364 AND id IN (1797, 1798, 1799, 1800, 1801)) OR
        (questao_id = 368 AND id IN (1817, 1818, 1819, 1820, 1821)) OR
        (questao_id = 369 AND id IN (1822, 1823, 1824, 1825, 1826)) OR
        (questao_id = 370 AND id IN (1828, 1829))
     ) AND (
        position(E'\n' in texto) > 0 OR
        position('\n' in texto) > 0 OR
        texto LIKE '%policial -militar%' OR
        texto LIKE '%Tenente -Coronel%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 14 falhou: resíduos de OCR ainda detectados em alternativas tratadas';
  END IF;

  RAISE NOTICE 'TODOS OS 14 ASSERTS DA FASE 2O (LEGISLAÇÃO MILITAR ESTADUAL / BM-RS) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;