-- ============================================================================
-- FASE 2N — IMPROBIDADE ADMINISTRATIVA (LEI Nº 8.429/1992 / LEI Nº 14.230/2021)
-- Modo: APPLY DEFINITIVO COM COMMIT
-- ============================================================================

BEGIN;

-- Garante sessão em leitura e escrita para o harness/apply
SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_corretas_count integer;
  v_intocada_hash text;
  v_explicacao_check text;
  v_enunciado_check text;
  v_alt_check text;
  v_ativa_665 boolean;
BEGIN
  -- --------------------------------------------------------------------------
  -- 1. PRECONDIÇÕES E GUARDAS CONTRA DRIFT (ESTADO PRÉ-APPLY)
  -- --------------------------------------------------------------------------

  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 908 OR v_total_inativas <> 7 THEN
    RAISE EXCEPTION 'Precondição falhou: totais globais divergentes. Esperado 915/908/7, obtido %/%/%',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Validação dos hashes pré-apply das 16 questões do escopo
  
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 42) <> '34c0c03db5386ccfde1e9f6a711a7d7b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 42 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 49) <> '831e15817fbc2d589bbf3b610e38b70b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 49 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 137) <> 'ac84c0b1442d7f4340aaf79ddedf0cd3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 137 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 361) <> '7d84464ffddaeeac694ba27d6ea139c5' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 361 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 665) <> '3e5b08e05d29e1c88814c0a5da872115' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 665 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 666) <> 'efeee5df1d929887a11104173b916aaa' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 666 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 667) <> '664d626d406be6417f504e2f52707959' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 667 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 668) <> '515baadb5459975debc54d2dce1e5cc7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 668 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 669) <> '726a7612fd08ce3ccf6758e602718113' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 669 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 731) <> '170550325aedc0bd69b0a59e7bdbf421' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 731 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 732) <> 'a86d3fc16428a78d2ec2311ccf5bf7a7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 732 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 856) <> 'de33c8fc65c57bd669141f086532448e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 856 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 857) <> '74b1957e437d68f555c8ee55af52ed06' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 857 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 858) <> 'dc7b9cf6b11a7b52d7654c64ef20b4e7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 858 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 859) <> '86728cc8b889336366d6151b005cf1c7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 859 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 860) <> '92104ecbb0702fb7e015c5bfe6fe063d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 860 divergiu do estado auditado.';
  END IF;

  
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 42) <> '9ceeaaf730d5d0c2afebbb236abb57b4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 42 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 49) <> '187cc7736360518f328a8d54c8d67386' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 49 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 137) <> '816adb7910ee53968a02e0c023fd27be' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 137 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 361) <> '501aaee47e6e8f603f625a9ea9e34b09' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 361 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 665) <> 'ce4a0534c027cc6b8edaa7ad68a78ad0' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 665 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 666) <> '0d0ca408195e4ec8e737724ecf57c701' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 666 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 667) <> '262a23a9b41dc0e92873236617c4b597' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 667 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 668) <> '19edcef9c2ed63d8045b34a22d31e41d' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 668 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 669) <> '634c9ffe03708350049110b28806c1e8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 669 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 731) <> 'efa61fc47567b1daad936167a71499c4' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 731 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 732) <> '028a9406cd43934a3cc45e25ff1b8311' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 732 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 856) <> '5097413ccc796e7ff318b7bdae3edc8c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 856 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 857) <> '5f757c84acbe4f1613fcd14a2d9f7c55' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 857 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 858) <> 'd9fec3eceba598db3fdf2158532b7ae1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 858 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 859) <> '7a485234f586068b82f932c7b1000eb8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 859 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 860) <> '1b604fc629b7ad04e0ff08eba212b0da' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 860 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO
  -- --------------------------------------------------------------------------

  -- ID 42: Atualização de explicação
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C reproduz expressamente a literalidade do Artigo 1º, § 7º, da Lei nº 8.429/1992 (Lei de Improbidade Administrativa, incluído pela Lei nº 14.230/2021): "Independentemente de integrar a administração indireta, estão sujeitos às sanções desta Lei os atos de improbidade praticados contra o patrimônio de entidade privada para cuja criação ou custeio o erário haja concorrido ou concorra no seu patrimônio ou receita atual, limitado o ressarcimento de prejuízos, nesse caso, à repercussão do ilícito sobre a contribuição dos cofres públicos."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 1º, § 3º da LIA dispõe que o mero exercício da função ou desempenho de competências públicas, sem comprovação de ato doloso com fim ilícito, AFASTA a responsabilidade por ato de improbidade administrativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sujeição de entidades privadas às sanções da LIA exige que a entidade receba subvenção, benefício ou incentivo, fiscal ou creditício, de entes públicos (Art. 1º, § 6º) ou que o erário tenha concorrido ou concorra para sua criação ou custeio no patrimônio ou receita atual (Art. 1º, § 7º). A entidade privada somente não se sujeita à LIA caso não esteja abrangida por nenhuma dessas hipóteses legais específicas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Artigo 1º, § 8º da LIA prevê que não configura improbidade a ação ou omissão decorrente de divergência interpretativa da lei, baseada em jurisprudência, ainda que não pacificada. Conforme a interpretação conforme fixada pelo STF nas ADIs 7156/7236, a proteção do art. 1º, § 8º não alcança situações em que se evidencie dolo ou erro grosseiro, consideradas as circunstâncias do caso e a gravidade da infração. O STF também delimitou a base jurisprudencial apta à incidência da regra, exigindo jurisprudência assentada nos Tribunais Superiores ou no STF ou, na falta dela, decisão de mérito transitada em julgado de órgão colegiado de 2º grau.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Artigo 2º, parágrafo único da LIA sujeita às sanções o particular, pessoa física OU jurídica, que celebre com a administração pública convênio, contrato de repasse, termo de parceria ou ajuste administrativo equivalente.

BIZU DE PROVA:
Entidades Privadas na LIA (Art. 1º, §§ 6º e 7º da Lei nº 8.429/92):
- Recebem subvenção/benefício/incentivo fiscal: Art. 1º, § 6º.
- Erário concorre para criação ou custeio: Art. 1º, § 7º (ressarcimento limitado à repercussão sobre a contribuição pública)!',
         atualizado_em = now()
   WHERE id = 42;

  -- ID 137: Atualização de explicação (Ressalva Jurídica STJ)
  UPDATE public.questoes
     SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (ENQUADRAMENTO FORMAL DA LIA):
Na situação narrada, o agente público Josué permitiu que seu amigo Salomão utilizasse máquinas do Estado na construção de sua residência particular. Sob a tipologia legal da Lei nº 8.429/1992, essa conduta amolda-se formalmente ao Artigo 10, inciso XIII, que tipifica como ato causador de PREJUÍZO AO ERÁRIO "permitir que se utilize, em obra ou serviço particular, veículos, máquinas, equipamentos ou material de qualquer natureza, de propriedade ou à disposição de qualquer das entidades mencionadas no art. 1º desta Lei". O particular Salomão, por ter concorrido dolosamente e se beneficiado da facilitação indevida, responde nos termos do Artigo 3º c/c Artigo 10, XIII da LIA.

RESSALVA JURÍDICA (STJ E REQUISITO DE DANO EFETIVO):
O gabarito D é mantido como gabarito oficial/histórico da questão pela classificação típica objetiva do art. 10, XIII. Contudo, cabe ressalva jurídica: nos termos do caput do Artigo 10 da LIA (redação da Lei nº 14.230/2021) e da jurisprudência consolidada do Superior Tribunal de Justiça (STJ), a configuração dos atos do art. 10 exige perda patrimonial EFETIVA E COMPROVADA, sendo inadmissível o dano presumido (in re ipsa). Em processo judicial concreto, exige-se a demonstração do desfalque material efetivo aos cofres públicos (combustível, desgaste, horas-máquina despendidas).

POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:
- A e B: A cessão indevida de bens a terceiros é tipificada como lesão ao erário (Art. 10, XIII), reservando-se o Art. 9º, IV para o uso direto do bem pelo próprio agente.
- C: Havendo tipo específico de lesão patrimonial no Art. 10, afasta-se a imputação genérica subsidiária ao Art. 11.
- E: Ambos praticaram conduta dolosa descrita na Lei de Improbidade Administrativa.

BIZU DE PROVA:
Máquinas Públicas em Obra Particular (LIA):
- Permitir que terceiro utilize: Art. 10, XIII (Prejuízo ao Erário) c/c Art. 3º para o particular!
- STJ: Exige comprovação do dano patrimonial efetivo (vedado dano presumido in re ipsa).',
         atualizado_em = now()
   WHERE id = 137;

  -- ID 361: Higiene de OCR no enunciado e alternativas (explicação preservada)
  UPDATE public.questoes
     SET enunciado = 'De acordo com o disposto na Lei nº 8.429/1992 (conhecida como Lei de Improbidade Administrativa), assinale a alternativa INCORRETA.',
         atualizado_em = now()
   WHERE id = 361;

  
  UPDATE public.alternativas
     SET texto = 'Qualquer pessoa poderá representar à autoridade administrativa competente para que seja instaurada investigação destinada a apurar a prática de ato de improbidade.'
   WHERE id = 1782 AND questao_id = 361;
  UPDATE public.alternativas
     SET texto = 'A representação, que será escrita ou reduzida a termo e assinada, conterá a qualificação do representante, as informações sobre o fato e sua autoria e a indicação das provas de que tenha conhecimento.'
   WHERE id = 1783 AND questao_id = 361;
  UPDATE public.alternativas
     SET texto = 'A indisponibilidade recairá sobre bens que assegurem exclusivamente o integral ressarcimento do dano ao erário e a multa civil, sem incidir sobre os valores a serem eventualmente aplicados sobre acréscimo patrimonial decorrente de atividade lícita.'
   WHERE id = 1784 AND questao_id = 361;
  UPDATE public.alternativas
     SET texto = 'Atendidos os requisitos da representação, a autoridade determinará a imediata apuração dos fatos, observada a legislação que regula o processo administrativo disciplinar aplicável ao agente.'
   WHERE id = 1785 AND questao_id = 361;
  UPDATE public.alternativas
     SET texto = 'A comissão processante dará conhecimento ao Ministério Público e ao Tribunal ou Conselho de Contas da existência de procedimento administrativo para apurar a prática de ato de improbidade.'
   WHERE id = 1786 AND questao_id = 361;

  -- ID 665: Desativação técnica por vício de tipicidade no rol taxativo do art. 11 pós-2021
  UPDATE public.questoes
     SET ativa = false,
         atualizado_em = now()
   WHERE id = 665;

  -- ID 666: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Maria, servidora pública do município de Araquari, permitiu dolosamente que se utilizasse, em serviço particular, veículo de propriedade do Município, causando perda patrimonial à municipalidade. Considerando a situação narrada e as disposições da Lei nº 8.429/1992, é correto afirmar que Maria cometeu um ato de improbidade administrativa que',
         atualizado_em = now()
   WHERE id = 666;

  -- ID 667: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'São casos que configuram ato de improbidade administrativa que causa prejuízo ao erário: I. Nomear cônjuge, companheiro ou parente em linha reta, colateral ou por afinidade, até o terceiro grau, inclusive, da autoridade nomeante, para o exercício de cargo em comissão ou de confiança ou, ainda, de função gratificada na administração pública direta e indireta. II. Permitir ou facilitar a aquisição, permuta ou locação de bem ou serviço por preço superior ao de mercado. III. Agir para a configuração de ilícito na celebração, na fiscalização e na análise das prestações de contas de parcerias firmadas pela administração pública com entidades privadas. Quais estão INCORRETOS?',
         atualizado_em = now()
   WHERE id = 667;

  -- ID 668: Higiene de OCR em 4 alternativas
  
  UPDATE public.alternativas
     SET texto = 'Aceitar emprego, comissão ou exercer atividade de consultoria ou assessoramento para pessoa física ou jurídica que tenha interesse suscetível de ser atingido ou amparado por ação ou omissão decorrente das atribuições do agente público, durante a atividade.'
   WHERE id = 3317 AND questao_id = 668;
  UPDATE public.alternativas
     SET texto = 'Revelar fato ou circunstância de que tem ciência em razão das atribuições e que deva permanecer em segredo, propiciando beneficiamento por informação privilegiada ou colocando em risco a segurança da sociedade e do Estado.'
   WHERE id = 3318 AND questao_id = 668;
  UPDATE public.alternativas
     SET texto = 'Perceber vantagem econômica, direta ou indireta, para facilitar a alienação, permuta ou locação de bem público ou o fornecimento de serviço por ente estatal por preço inferior ao valor de mercado.'
   WHERE id = 3319 AND questao_id = 668;
  UPDATE public.alternativas
     SET texto = 'Receber vantagem econômica de qualquer natureza, direta ou indireta, para tolerar a exploração ou a prática de jogos de azar, de lenocínio, de narcotráfico, de contrabando, de usura ou de qualquer outra atividade ilícita, ou aceitar promessa de tal vantagem.'
   WHERE id = 3321 AND questao_id = 668;
  UPDATE public.questoes SET atualizado_em = now() WHERE id = 668;

  -- ID 669: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Geovana é cotista da empresa Sobretudos de Lã Ltda. A ela foi imputada prática de ato de improbidade à referida empresa, mesmo sem provas de que ela tenha participação e benefício direto. Considerando a situação narrada, é correto afirmar que Geovana:',
         atualizado_em = now()
   WHERE id = 669;

  -- ID 731: Reescrita total da explicação (LIA) + Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Conforme a Lei de Improbidade Administrativa, analise as assertivas abaixo: I. Na responsabilização da pessoa jurídica, deverão ser considerados os efeitos econômicos e sociais das sanções, de modo a viabilizar a manutenção de suas atividades. II. A posse e o exercício de agente público ficam condicionados à apresentação de declaração de imposto de renda e proventos de qualquer natureza, que tenha sido apresentada à Secretaria Especial da Receita Federal do Brasil, a fim de ser arquivada no serviço de pessoal competente. III. Qualquer pessoa poderá representar à autoridade administrativa competente para que seja instaurada investigação destinada a apurar a prática de ato de improbidade. Quais estão corretas?',
         explicacao = 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as três assertivas (I, II e III) estão CORRETAS nos termos expressos da Lei nº 8.429/1992 (Lei de Improbidade Administrativa, com as alterações da Lei nº 14.230/2021):

- Assertiva I (Correta): O Artigo 12, § 3º da LIA estabelece expressamente que "na responsabilização da pessoa jurídica, deverão ser considerados os efeitos econômicos e sociais das sanções, de modo a viabilizar a manutenção de suas atividades, a continuidade dos serviços prestados e a preservação dos empregos".
- Assertiva II (Correta): O Artigo 13, caput da LIA prescreve que "a posse e o exercício de agente público ficam condicionados à apresentação de declaração de imposto de renda e proventos de qualquer natureza, que tenha sido apresentada à Secretaria Especial da Receita Federal do Brasil, a fim de ser arquivada no serviço de pessoal competente".
- Assertiva III (Correta): O Artigo 14, caput da LIA dispõe expressamente que "qualquer pessoa poderá representar à autoridade administrativa competente para que seja instaurada investigação destinada a apurar a prática de ato de improbidade".

POR QUE AS ALTERNATIVAS A, B, C E D ESTÃO INCORRETAS:
As opções A, B, C e D indicam apenas parte das assertivas, ao passo que todas as três proposições (I, II e III) são juridicamente verdadeiras e válidas.

BIZU DE PROVA:
Pontos-Chave da Lei de Improbidade Administrativa (Lei nº 8.429/92):
1. Sanções a Pessoa Jurídica (Art. 12, §3º): Ponderam-se os efeitos econômicos/sociais para preservar a atividade da empresa e empregos.
2. Declaração de Bens/IR (Art. 13): Requisito obrigatório para posse e exercício.
3. Representação (Art. 14): Qualquer cidadão/pessoa pode representar à autoridade administrativa.',
         atualizado_em = now()
   WHERE id = 731;

  -- ID 732: Reescrita total da explicação (LIA) + Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Analise as assertivas abaixo conforme a Lei de Improbidade Administrativa (Lei nº 8.429/1992 e alterações posteriores): I. Na ação por improbidade administrativa, poderá ser formulado, em caráter antecedente ou incidente, pedido de indisponibilidade de bens dos réus, a fim de garantir a integral recomposição do erário ou do acréscimo patrimonial resultante de enriquecimento ilícito. II. As disposições da referida Lei e suas alterações posteriores são aplicáveis, no que couber, àquele que, mesmo não sendo agente público, induza ou concorra dolosamente para a prática do ato de improbidade. III. Constitui ato de improbidade administrativa importando em enriquecimento ilícito auferir, mediante a prática de ato culposo ou doloso, qualquer tipo de vantagem patrimonial indevida em razão do exercício de cargo, de mandato, de função, de emprego ou de atividade nas entidades referidas no art. 1º da referida Lei e suas alterações posteriores. Quais estão corretas?',
         explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão CORRETAS apenas as assertivas I e II:

- Assertiva I (Correta): Reproduz expressamente o Artigo 16, caput da Lei nº 8.429/1992 (com redação da Lei nº 14.230/2021), que prevê a possibilidade de formulação de pedido de indisponibilidade de bens dos réus, em caráter antecedente ou incidente, a fim de garantir a integral recomposição do erário ou do acréscimo patrimonial resultante de enriquecimento ilícito.
- Assertiva II (Correta): Reproduz a literalidade do Artigo 3º, caput da Lei nº 8.429/1992, aplicando as sanções da lei ao terceiro que, mesmo não sendo agente público, induza ou concorra dolosamente para a prática do ato de improbidade.
- Assertiva III (Incorreta): O Artigo 9º, caput da LIA tipifica o enriquecimento ilícito exclusivamente na modalidade dolosa ("auferir, mediante a prática de ato doloso..."). A Lei nº 14.230/2021 revogou qualquer modalidade culposa de ato de improbidade administrativa (Art. 1º, §§ 1º a 3º), tornando incorreta a menção a "ato culposo".

POR QUE AS ALTERNATIVAS A, B, D E E ESTÃO INCORRETAS:
- A: Incompleta, pois a assertiva II também é correta.
- B, D e E: Incorretas por incluírem a assertiva III, que traz o erro jurídico da menção à culpa.

BIZU DE PROVA:
Inovações da Lei nº 14.230/2021 na LIA:
1. Indisponibilidade de Bens (Art. 16): Pode ser antecedente ou incidente para garantir ressarcimento/enriquecimento ilícito.
2. Terceiro/Particular (Art. 3º): Responde apenas se agir com DOLO (induzir ou concorrer dolosamente).
3. Fim da Improbidade Culposa: TODAS as modalidades da LIA (arts. 9º, 10 e 11) exigem DOLO COMPROVADO!',
         atualizado_em = now()
   WHERE id = 732;

  -- ID 856: Nova explicação (art. 11 caput) + Higiene de OCR no enunciado e alt C
  UPDATE public.questoes
     SET enunciado = 'Com fundamento na Lei de Improbidade Administrativa, a ação dolosa que viole os deveres de honestidade, de imparcialidade e de legalidade constitui ato de improbidade administrativa que:',
         explicacao = 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa B corresponde diretamente à definição conceitual do Artigo 11, caput, da Lei nº 8.429/1992: "Constitui ato de improbidade administrativa que atenta contra os princípios da administração pública a ação ou omissão dolosa que viole os deveres de honestidade, de imparcialidade e de legalidade, caracterizada por uma das seguintes condutas:".

RESSALVA JURÍDICA (ROL TAXATIVO DO ARTIGO 11):
O gabarito B é mantido por refletir com precisão a classificação categorial e o conceito abstrato do caput do Art. 11 (diferenciando os atos contra princípios dos atos de enriquecimento ilícito do art. 9º e de prejuízo ao erário do art. 10). Contudo, cabe ressalva jurídica: sob a vigência da Lei nº 14.230/2021 e a jurisprudência vinculante do STF (Tema 1.199 e ADI 7236) e do STJ, o caput do art. 11 não opera como cláusula aberta autônoma; para a imputação processual e condenação em caso concreto, exige-se obrigatoriamente a subsunção a um dos incisos taxativos vigentes (incisos III, IV, V, VI, VII, VIII, XI e XII) e o cumprimento dos requisitos dos §§ 1º a 4º do art. 11.

POR QUE AS ALTERNATIVAS A, C E D ESTÃO INCORRETAS:
- A: Os atos do Art. 10 caracterizam-se pela exigência de efetiva e comprovada perda patrimonial ao erário.
- C: Os atos do Art. 9º exigem a percepção de vantagem patrimonial indevida pelo agente.
- D: A LIA comina sanções de natureza político-administrativa e patrimonial (Art. 12), não prevendo sanções penais de privação de liberdade.

BIZU DE PROVA:
Espécies de Improbidade Administrativa (Lei nº 8.429/92):
- Art. 9º: Enriquecimento Ilícito (vantagem patrimonial indevida).
- Art. 10: Prejuízo ao Erário (dano patrimonial efetivo e comprovado).
- Art. 11: Atentado aos Princípios (violação a deveres de honestidade/imparcialidade/legalidade em rol TAXATIVO dos incisos).',
         atualizado_em = now()
   WHERE id = 856;

  
  UPDATE public.alternativas
     SET texto = 'Importa enriquecimento ilícito.'
   WHERE id = 4251 AND questao_id = 856;

  -- ID 857: Nova explicação (Ressalva Jurídica STJ) + Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Josué, agente público do Estado, permitiu que seu amigo, Salomão, utilizasse, na construção de sua casa, máquinas de propriedade do Estado. Ambos agiram querendo facilitar a realização da obra e conscientes de que o maquinário foi utilizado para finalidade diversa da adquirida pelo Ente Público. Nos termos da Lei de Improbidade Administrativa:',
         explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (ENQUADRAMENTO FORMAL DA LIA):
Na situação narrada, o agente público Josué permitiu que seu amigo Salomão utilizasse máquinas do Estado na construção de sua residência particular. Sob a tipologia legal da Lei nº 8.429/1992, essa conduta amolda-se formalmente ao Artigo 10, inciso XIII, que tipifica como ato causador de PREJUÍZO AO ERÁRIO "permitir que se utilize, em obra ou serviço particular, veículos, máquinas, equipamentos ou material de qualquer natureza, de propriedade ou à disposição de qualquer das entidades mencionadas no art. 1º desta Lei". O particular Salomão, por ter concorrido dolosamente e se beneficiado da facilitação indevida, responde nos termos do Artigo 3º c/c Artigo 10, XIII da LIA.

RESSALVA JURÍDICA (STJ E REQUISITO DE DANO EFETIVO):
O gabarito D é mantido como gabarito oficial/histórico da questão pela classificação típica objetiva do art. 10, XIII. Contudo, cabe ressalva jurídica: nos termos do caput do Artigo 10 da LIA (redação da Lei nº 14.230/2021) e da jurisprudência consolidada do Superior Tribunal de Justiça (STJ), a configuração dos atos do art. 10 exige perda patrimonial EFETIVA E COMPROVADA, sendo inadmissível o dano presumido (in re ipsa). Em processo judicial concreto, exige-se a demonstração do desfalque material efetivo aos cofres públicos (combustível, desgaste, horas-máquina despendidas).

POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:
- A e B: A cessão indevida de bens a terceiros é tipificada como lesão ao erário (Art. 10, XIII), reservando-se o Art. 9º, IV para o uso direto do bem pelo próprio agente.
- C: Havendo tipo específico de lesão patrimonial no Art. 10, afasta-se a imputação genérica subsidiária ao Art. 11.
- E: Ambos praticaram conduta dolosa descrita na Lei de Improbidade Administrativa.

BIZU DE PROVA:
Máquinas Públicas em Obra Particular (LIA):
- Permitir que terceiro utilize: Art. 10, XIII (Prejuízo ao Erário) c/c Art. 3º para o particular!
- STJ: Exige comprovação do dano patrimonial efetivo (vedado dano presumido in re ipsa).',
         atualizado_em = now()
   WHERE id = 857;

  -- ID 858: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = 'Antônio, agente público do Estado, com vistas a ocultar irregularidades, de forma livre e consciente, deixou de prestar contas quando era obrigado e dispunha de condições para isso. Nos termos da Lei nº 8.429/1992, assinale a alternativa correta.',
         atualizado_em = now()
   WHERE id = 858;

  -- ID 859: Nova explicação (art. 9º, I) + Higiene de OCR no enunciado e alt D
  UPDATE public.questoes
     SET enunciado = 'Roberval, agente penitenciário, faz parte da equipe que tem como atribuição a revista na entrada do Presídio objetivando coibir o ingresso de materiais proibidos. Ramiro, familiar de um preso, ofereceu 2 mil reais, que foram aceitos por Roberval, de forma livre e consciente, para facilitar que um aparelho celular chegasse ao detento. Com base no fato narrado, assinale a alternativa correta.',
         explicacao = 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B É MANTIDA:
Ao aceitar propina de R$ 2.000,00 de familiar de detento para facilitar a entrada de aparelho celular no presídio, Roberval praticou ato de improbidade administrativa que IMPORTA ENRIQUECIMENTO ILÍCITO, tipificado expressamente no Artigo 9º, inciso I da Lei nº 8.429/1992 ("receber, para si ou para outrem, dinheiro, bem móvel ou imóvel, ou qualquer outra vantagem econômica, direta ou indireta, a título de comissão, percentagem, gratificação ou presente de quem tenha interesse, direto ou indireto, que possa ser atingido ou amparado por ação ou omissão decorrente das atribuições do agente público").

RESSALVA JURÍDICA (ENQUADRAMENTO TÍPICO E FORMULAÇÃO DA BANCA):
O gabarito B é mantido como a alternativa oficial e mais adequada da prova porque reconhece o enriquecimento ilícito (Art. 9º, I) e descarta com precisão a ocorrência de prejuízo ao erário (presente incorretamente nas opções A, C e D). Contudo, cabe ressalva jurídica: a expressão "atentatório aos princípios da Administração Pública" constante da alternativa constitui formulação ampla e pedagógica da banca, pois, sob a tipicidade estrita e o rol taxativo do Artigo 11 da LIA, a conduta de auferir vantagem indevida possui tipificação específica e plena no Artigo 9º, inciso I (não havendo tipo autônomo do art. 11 para recebimento de propina).

POR QUE AS ALTERNATIVAS A, C, D E E ESTÃO INCORRETAS:
- A, C e D: Estão erradas porque imputam prejuízo ao erário (Art. 10), inexistente no caso narrado, uma vez que não houve perda patrimonial ou desfalque comprovado aos cofres públicos.
- E: Roberval praticou ato doloso gravíssimo de improbidade administrativa (Art. 9º, I) e crime de corrupção passiva (Art. 317 do CP).

BIZU DE PROVA:
Recebimento de Propina por Agente Público (LIA):
- Tipifica ENRIQUECIMENTO ILÍCITO (Art. 9º, I da Lei nº 8.429/92)!
- Sem desfalque aos cofres públicos, NÃO há prejuízo ao erário (Art. 10).',
         atualizado_em = now()
   WHERE id = 859;

  
  UPDATE public.alternativas
     SET texto = 'Roberval praticou ato de improbidade administrativa que causa enriquecimento ilícito, atenta contra os princípios da Administração Pública e causa prejuízo ao erário.'
   WHERE id = 4266 AND questao_id = 859;

  -- ID 860: Higiene de OCR no enunciado e em 3 alternativas
  UPDATE public.questoes
     SET enunciado = 'A Lei nº 8.429/1992, que dispõe sobre as sanções aplicáveis em virtude da prática de ato de improbidade administrativa, prevê a responsabilidade sucessória daquele que causar dano ao erário ou que enriquecer ilicitamente. Na hipótese de fusão e de incorporação, a responsabilidade da sucessora:',
         atualizado_em = now()
   WHERE id = 860;

  
  UPDATE public.alternativas
     SET texto = 'Será restrita à obrigação de reparação integral do dano causado, até o limite do patrimônio transferido, não lhe sendo aplicáveis as demais sanções decorrentes de improbidade por atos e de fatos ocorridos antes da data da fusão ou da incorporação, exceto no caso de simulação ou de evidente intuito de fraude, devidamente comprovados.'
   WHERE id = 4268 AND questao_id = 860;
  UPDATE public.alternativas
     SET texto = 'Será restrita à obrigação de reparação integral do dano causado, até o limite do patrimônio transferido, incluindo as demais sanções decorrentes de improbidade por atos e de fatos ocorridos antes da data da fusão ou da incorporação, exceto no caso de simulação ou de evidente intuito de fraude, devidamente comprovados.'
   WHERE id = 4271 AND questao_id = 860;
  UPDATE public.alternativas
     SET texto = 'Será restrita à obrigação de reparação integral do dano causado, até o limite do patrimônio transferido, não lhe sendo aplicáveis as demais sanções decorrentes de improbidade por atos e de fatos ocorridos antes da data da fusão ou da incorporação, exceto no caso de suspeita de simulação ou de fraude.'
   WHERE id = 4272 AND questao_id = 860;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais (665 desativada: ativas passam de 908 para 907, inativas de 7 para 8)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Status ativa da questão 665 é false
  SELECT ativa INTO v_ativa_665 FROM public.questoes WHERE id = 665;
  IF v_ativa_665 <> false THEN
    RAISE EXCEPTION 'Assert 2 falhou: questão 665 deveria estar inativa (ativa = false)';
  END IF;

  -- Assert 3: As outras 15 questões continuam com ativa = true
  IF (SELECT count(*) FROM public.questoes WHERE id IN (42, 49, 137, 361, 666, 667, 668, 669, 731, 732, 856, 857, 858, 859, 860) AND ativa = true) <> 15 THEN
    RAISE EXCEPTION 'Assert 3 falhou: nem todas as 15 questões-alvo permaneceram ativas';
  END IF;

  -- Assert 4: Exatamente 1 alternativa correta por questão em todo o escopo de 16 questões
  SELECT count(DISTINCT questao_id)
    INTO v_corretas_count
    FROM public.alternativas
   WHERE questao_id IN (42, 49, 137, 361, 665, 666, 667, 668, 669, 731, 732, 856, 857, 858, 859, 860)
     AND correta = true;

  IF v_corretas_count <> 16 THEN
    RAISE EXCEPTION 'Assert 4 falhou: número de questões com alternativa correta <> 16 (obtido %)', v_corretas_count;
  END IF;

  -- Assert 5: Integridade dos gabaritos específicos em cada uma das 16 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 42 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 49 AND ordem = 5 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 137 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 361 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 665 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 666 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 667 AND ordem = 1 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 668 AND ordem = 2 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 669 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 731 AND ordem = 5 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 732 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 856 AND ordem = 2 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 857 AND ordem = 4 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 858 AND ordem = 3 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 859 AND ordem = 2 AND correta = true) OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 860 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 5 falhou: divergência em gabarito oficial de uma das 16 questões';
  END IF;

  -- Assert 6: Questão 49 intocada (hash preservado)
  SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text)
    INTO v_intocada_hash
    FROM public.questoes WHERE id = 49;
  IF v_intocada_hash <> '831e15817fbc2d589bbf3b610e38b70b' THEN
    RAISE EXCEPTION 'Assert 6 falhou: questão 49 (intocada) foi modificada indevidamente';
  END IF;

  -- Assert 7: Explicações das questões de OCR puro preservadas byte a byte
  
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 361) <> '501aaee47e6e8f603f625a9ea9e34b09' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 361 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 666) <> '0d0ca408195e4ec8e737724ecf57c701' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 666 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 667) <> '262a23a9b41dc0e92873236617c4b597' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 667 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 668) <> '19edcef9c2ed63d8045b34a22d31e41d' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 668 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 669) <> '634c9ffe03708350049110b28806c1e8' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 669 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 858) <> 'd9fec3eceba598db3fdf2158532b7ae1' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 858 (OCR puro) foi alterada indevidamente';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 860) <> '1b604fc629b7ad04e0ff08eba212b0da' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 860 (OCR puro) foi alterada indevidamente';
  END IF;

  -- Assert 8: Questão 42 - fundamentação correta dos §§ 6º, 7º, dolo ou erro grosseiro e ADIs 7156/7236
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 42;
  IF v_explicacao_check NOT ILIKE '%Artigo 1º, § 7º%' OR
     v_explicacao_check NOT ILIKE '%Art. 1º, § 6º%' OR
     v_explicacao_check NOT ILIKE '%ADIs 7156/7236%' OR
     v_explicacao_check NOT ILIKE '%dolo ou erro grosseiro%' OR
     v_explicacao_check ILIKE '%dolo com fraude ou evidente má-fé%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: explicação da questão 42 não contém os fundamentos esperados ou contém formulação superada';
  END IF;

  -- Assert 9: Questões 137 e 857 - enquadramento art. 10, XIII c/c art. 3º e ressalva STJ dano efetivo
  
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 137;
  IF v_explicacao_check NOT ILIKE '%Artigo 10, inciso XIII%' OR
     v_explicacao_check NOT ILIKE '%Artigo 3º%' OR
     v_explicacao_check NOT ILIKE '%Superior Tribunal de Justiça%' OR
     v_explicacao_check NOT ILIKE '%in re ipsa%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 137 não contém os fundamentos/ressalvas esperados';
  END IF;
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 857;
  IF v_explicacao_check NOT ILIKE '%Artigo 10, inciso XIII%' OR
     v_explicacao_check NOT ILIKE '%Artigo 3º%' OR
     v_explicacao_check NOT ILIKE '%Superior Tribunal de Justiça%' OR
     v_explicacao_check NOT ILIKE '%in re ipsa%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 857 não contém os fundamentos/ressalvas esperados';
  END IF;

  -- Assert 10: Questões 731 e 732 - expurgo absoluto de contaminação de Lei de Drogas e fundamentação correta
  
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 731;
  IF v_explicacao_check ILIKE '%droga%' OR
     v_explicacao_check ILIKE '%maconha%' OR
     v_explicacao_check ILIKE '%sisnad%' OR
     v_explicacao_check ILIKE '%entorpecente%' OR
     v_explicacao_check ILIKE '%cannabis%' THEN
    RAISE EXCEPTION 'Assert 10 falhou: explicação da questão 731 ainda contém resquícios da Lei de Drogas';
  END IF;
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 732;
  IF v_explicacao_check ILIKE '%droga%' OR
     v_explicacao_check ILIKE '%maconha%' OR
     v_explicacao_check ILIKE '%sisnad%' OR
     v_explicacao_check ILIKE '%entorpecente%' OR
     v_explicacao_check ILIKE '%cannabis%' THEN
    RAISE EXCEPTION 'Assert 10 falhou: explicação da questão 732 ainda contém resquícios da Lei de Drogas';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 731;
  IF v_explicacao_check NOT ILIKE '%Artigo 12, § 3º%' OR
     v_explicacao_check NOT ILIKE '%Artigo 13%' OR
     v_explicacao_check NOT ILIKE '%Artigo 14%' THEN
    RAISE EXCEPTION 'Assert 10a falhou: explicação da questão 731 não cita os arts. 12 §3º, 13 e 14 da LIA';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 732;
  IF v_explicacao_check NOT ILIKE '%Artigo 16%' OR
     v_explicacao_check NOT ILIKE '%Artigo 3º%' OR
     v_explicacao_check NOT ILIKE '%Artigo 9º%' OR
     v_explicacao_check NOT ILIKE '%revogou qualquer modalidade culposa%' THEN
    RAISE EXCEPTION 'Assert 10b falhou: explicação da questão 732 não fundamenta indisponibilidade/art. 3º/dolo';
  END IF;

  -- Assert 11: Questão 856 - fundamentação no caput do art. 11 com rol taxativo completo (incisos III, IV, V, VI, VII, VIII, XI e XII)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 856;
  IF v_explicacao_check NOT ILIKE '%Artigo 11, caput%' OR
     v_explicacao_check NOT ILIKE '%não opera como cláusula aberta%' OR
     v_explicacao_check NOT ILIKE '%(incisos III, IV, V, VI, VII, VIII, XI e XII)%' OR
     v_explicacao_check ILIKE '%concurso público ou processo seletivo%' THEN
    RAISE EXCEPTION 'Assert 11 falhou: explicação da questão 856 incorreta, omitindo incisos ou citando indevidamente concurso público';
  END IF;

  -- Assert 12: Questão 859 - fundamentação no art. 9º, I, ressalva pedagógica da banca e ausência de citação do art. 17, §10-D
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 859;
  IF v_explicacao_check NOT ILIKE '%Artigo 9º, inciso I%' OR
     v_explicacao_check NOT ILIKE '%RESSALVA JURÍDICA%' OR
     v_explicacao_check ILIKE '%17, §10-D%' OR
     v_explicacao_check ILIKE '%17, § 10-D%' THEN
    RAISE EXCEPTION 'Assert 12 falhou: explicação da questão 859 inválida ou citando art. 17 §10-D inconstitucional';
  END IF;

  -- Assert 13: Ausência de resíduos colados de OCR nos enunciados tratados
  IF (SELECT count(*) FROM public.questoes WHERE id IN (361, 666, 667, 669, 731, 732, 856, 857, 858, 859, 860) AND (
        position(E'\n' in enunciado) > 0 OR
        position('\n' in enunciado) > 0 OR
        enunciado LIKE '%causandoperda%' OR
        enunciado LIKE '%improbidadeadministrativa%' OR
        enunciado LIKE '%decargo%' OR
        enunciado LIKE '%comentidades%' OR
        enunciado LIKE '%tenhaparticipação%' OR
        enunciado LIKE '%abaixo:I.%' OR
        enunciado LIKE '%suasatividades.II.%' OR
        enunciado LIKE '%tenhasido%' OR
        enunciado LIKE '%competente.III.%' OR
        enunciado LIKE '%deimprobidade%' OR
        enunciado LIKE '%degarantir%' OR
        enunciado LIKE '%concorradolosamente%' OR
        enunciado LIKE '%devantagem%' OR
        enunciado LIKE '%referidaLei%' OR
        enunciado LIKE '%agiramquerendo%' OR
        enunciado LIKE '%deImprobidade%' OR
        enunciado LIKE '%dispunhadecondições%' OR
        enunciado LIKE '%proibidos.Ramiro%' OR
        enunciado LIKE '%aodetento%' OR
        enunciado LIKE '%sucessóriadaquele%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 13 falhou: resíduos de OCR ainda detectados em enunciados';
  END IF;

  -- Assert 13b: Ausência de resíduos colados de OCR nas alternativas tratadas
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id IN (361, 668, 856, 859, 860) AND (
        position(E'\n' in texto) > 0 OR
        position('\n' in texto) > 0 OR
        texto LIKE '%ouamparado%' OR
        texto LIKE '%informaçãoprivilegiada%' OR
        texto LIKE '%estatalpor%' OR
        texto LIKE '%decontrabando%' OR
        texto LIKE '%ilício%' OR
        texto LIKE '%aoerário%' OR
        texto LIKE '%decorrentesde%' OR
        texto LIKE '%fraude,devidamente%' OR
        texto LIKE '%improbidadepor%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 13b falhou: resíduos de OCR ainda detectados em alternativas';
  END IF;

  RAISE NOTICE 'TODOS OS 13 ASSERTS DA FASE 2N (IMPROBIDADE ADMINISTRATIVA) PASSARAM COM SUCESSO!';
END $$;

COMMIT;