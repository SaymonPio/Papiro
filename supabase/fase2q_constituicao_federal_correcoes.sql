-- ============================================================================
-- FASE 2Q — CONSTITUIÇÃO FEDERAL DE 1988 / DIREITOS E GARANTIAS FUNDAMENTAIS
-- Modo: APPLY DEFINITIVO COM COMMIT
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
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

  -- Validação dos hashes pré-apply das 8 questões do lote (ids 659 e 717 excluídos)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 650) <> 'a50bded2a6a7c9180e96254ce9b75a3b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 650 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 653) <> '546b12e2836a82ac649eda75c4c8930f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 653 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 657) <> '4bd35dc2f925808fe0d1e7b7ea3af721' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 657 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 658) <> '05a95c66cb9f1e25a29447d7336e8de2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 658 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 661) <> '4b028cc8dbb1e02640477190f528442b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 661 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 663) <> 'd6cc37a0845c68f65c33dc2e5b0e9801' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 663 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 725) <> '7dfe7600a12b7d1ffe0ff79947cfb87f' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 725 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 849) <> 'ac96be3a2e0df1b6ad7784277cf7494b' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 849 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 650) <> 'aab304d6eddbe479bfae4345ea717080' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 650 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 653) <> 'a4e88a3eabca743c0aab59168b09898c' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 653 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 657) <> '7d7b66d60c7dd64cb3b0859728e6a8d1' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 657 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 658) <> '0d790f0edce6ab210a8ef1f28c379309' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 658 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 661) <> '3413527de2d5ff6019861efe0c937730' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 661 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 663) <> 'c85867a40d8398d27735de2b4e01891a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 663 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 725) <> 'e2f83d45aa1f1e54d38a7d675dd0c7e6' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 725 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 849) <> 'c85c6d4a430a272db8c6967e8d2ca960' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 849 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (8 QUESTÕES) — SOMENTE HIGIENE DE OCR
  -- --------------------------------------------------------------------------

  -- ID 650: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'A prefeitura do município de Viva Feliz pretende realizar um concurso público para investidura no cargo de guarda municipal. Para isso, a prefeitura publica em seu site um edital contendo todas as informações necessárias para inscrições e andamento do concurso. Essa ação de publicar o edital de forma acessível a todos visa atender mais especificamente a qual princípio previsto na Constituição Federal?',
         atualizado_em = now()
   WHERE id = 650;

  -- ID 653: OCR no enunciado e nas 5 alternativas (explicação preservada)
  UPDATE public.questoes
     SET enunciado = 'O art. 37 da Constituição Federal, além de enunciar princípios expressos aos quais a administração pública deve observância, também prescreve outros princípios e regras atinentes à sua organização. Assinale a alternativa que indica corretamente uma disposição geral aplicável à administração pública.',
         atualizado_em = now()
   WHERE id = 653;
  UPDATE public.alternativas
     SET texto = 'A publicidade dos atos, programas, obras, serviços e campanhas dos órgãos públicos deverá ter caráter educativo, informativo ou de orientação social, dela podendo constar, excepcionalmente, nomes, símbolos ou imagens que caracterizem promoção pessoal de autoridades ou servidores públicos.'
   WHERE id = 3242 AND questao_id = 653;
  UPDATE public.alternativas
     SET texto = 'A autonomia gerencial, orçamentária e financeira dos órgãos e entidades da administração direta e indireta não poderá ser ampliada mediante contrato, a ser firmado entre seus administradores e o poder público, que tenha por objeto a fixação de metas de desempenho para o órgão ou entidade.'
   WHERE id = 3243 AND questao_id = 653;
  UPDATE public.alternativas
     SET texto = 'Os órgãos e entidades da administração pública, individual ou conjuntamente, devem realizar avaliação das políticas públicas, inclusive com divulgação do objeto a ser avaliado e dos resultados alcançados, na forma da lei.'
   WHERE id = 3244 AND questao_id = 653;
  UPDATE public.alternativas
     SET texto = 'O servidor público titular de cargo efetivo poderá ser readaptado para exercício de cargo cujas atribuições e responsabilidades sejam compatíveis com a limitação que tenha sofrido em sua capacidade física ou mental, enquanto permanecer nesta condição, desde que possua a habilitação e o nível de escolaridade exigidos para o cargo de destino, assegurada a remuneração do cargo de destino.'
   WHERE id = 3245 AND questao_id = 653;
  UPDATE public.alternativas
     SET texto = 'Serão computadas, para efeito dos limites remuneratórios de que trata o inciso XI do caput do art. 37, as parcelas de caráter indenizatório expressamente previstas em lei ordinária, aprovada pelo Congresso Nacional, de caráter nacional, aplicada a todos os Poderes e órgãos constitucionalmente autônomos.'
   WHERE id = 3246 AND questao_id = 653;

  -- ID 657: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Notoriamente, as delegacias de polícia são órgãos públicos procurados para diversas orientações de distintas naturezas. Um policial civil está trabalhando no registro de ocorrências de uma delegacia de polícia e um cidadão ingressa no local, relatando uma situação pessoal e buscando orientação a respeito de remédios constitucionais. O policial, então, oferece as seguintes informações: o instrumento constitucional pelo qual o indivíduo obtém informações constantes de registros de entidades governamentais referentes a si ou para corrigir dados pessoais em registros públicos denomina-se ; já o instrumento destinado a proteger a liberdade de locomoção, quando alguém sofre ou se acha ameaçado por ilegalidade ou abuso de poder, denomina-se . Assinale a alternativa que preenche, correta e respectivamente, as lacunas do trecho acima.',
         atualizado_em = now()
   WHERE id = 657;

  -- ID 658: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Um policial civil está trabalhando na investigação de crime de extorsão mediante sequestro, recentemente ocorrido na circunscrição da delegacia de polícia na qual trabalha. Às 22h, ao passar em frente a uma residência, ele ouve gritos de socorro vindos do interior do imóvel. Diante da situação, decide ingressar, sem qualquer ordem judicial. Com base no art. 5º da Constituição Federal e no entendimento dos Tribunais Superiores, a conduta do policial foi:',
         atualizado_em = now()
   WHERE id = 658;

  -- ID 661: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Paula é cidadã brasileira e deseja se reunir com as suas amigas em local aberto ao público para realizar uma manifestação de cunho político. Considerando as disposições da Constituição Federal, assinale a alternativa correta.',
         atualizado_em = now()
   WHERE id = 661;

  -- ID 663: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Considerando as disposições da Constituição Federal, assinale a alternativa que indica o remédio constitucional cabível para a retificação de dados quando não se prefira fazê-lo por processo sigiloso, judicial ou administrativo.',
         atualizado_em = now()
   WHERE id = 663;

  -- ID 725: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Foi verificada a ocorrência de um estupro em uma residência, e os vizinhos pediram ajuda à guarda municipal, pois temiam intervir devido à falta de capacidade física e técnica para isso. O guarda municipal alegou que teria limitações para adentrar o imóvel devido ao fato de a ocorrência ser à noite, após às 21h. Considerando o caso apresentado, como se caracterizaria a entrada do guarda municipal no local sem autorização do ocupante da residência ou sem determinação judicial?',
         atualizado_em = now()
   WHERE id = 725;

  -- ID 849: OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = 'Em relação à literalidade do texto Constitucional, analise as assertivas abaixo: I. Às presidiárias serão asseguradas condições para que possam permanecer com seus filhos durante o período de amamentação. II. Todos os seres humanos nascem livres e iguais em dignidade e em direitos. III. O casamento não pode ser celebrado sem o livre e pleno consentimento dos futuros esposos. IV. Quem trabalha tem direito a uma remuneração equitativa e satisfatória, que lhe permita e à sua família uma existência conforme com a dignidade humana, e completada, se possível, por todos os outros meios de proteção social. Quais estão corretas?',
         atualizado_em = now()
   WHERE id = 849;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais preservados (nenhuma ativação/desativação nesta Fase 2Q)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Status "ativa" preservado nas 8 questões do lote (todas continuam ativa = true)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (650, 653, 657, 658, 661, 663, 725, 849) AND ativa = true) <> 8 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões do lote da Fase 2Q tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão e presença de todas as 8 questões
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (650, 653, 657, 658, 661, 663, 725, 849)) <> 8 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (650, 653, 657, 658, 661, 663, 725, 849)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões do lote não possuem exatamente 1 alternativa correta ou estão ausentes no conjunto de alternativas';
  END IF;

  -- Assert 4: Ausência de resíduos colados de OCR nos enunciados tratados (8 questões)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (650, 653, 657, 658, 661, 663, 725, 849) AND (
        enunciado LIKE '%seusite%' OR enunciado LIKE '%visaatender%' OR
        enunciado LIKE '%eregras%' OR
        enunciado LIKE '%registrode%' OR enunciado LIKE '%constitucionais.O%' OR enunciado LIKE '%entidadesgovernamentais%' OR enunciado LIKE '%aliberdade%' OR
        enunciado LIKE '%qualtrabalha%' OR enunciado LIKE '%ordemjudicial%' OR
        enunciado LIKE '%asdisposições%' OR
        enunciado LIKE '%seprefira%' OR
        enunciado LIKE '%capacidadefísica%' OR enunciado LIKE '%ocaso%' OR
        enunciado LIKE '%ecompletada%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 4 falhou: resíduos de OCR ainda detectados em algum enunciado do lote';
  END IF;

  -- Assert 4b: Ausência de resíduos colados de OCR nas 5 alternativas tratadas da questão 653
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 653 AND (
        texto LIKE '%delapodendo%' OR texto LIKE '%serfirmado%' OR texto LIKE '%objetoa%' OR
        texto LIKE '%alimitação%' OR texto LIKE '%escolaridadeexigidos%' OR texto LIKE '%expressamenteprevistas%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 4b falhou: resíduos de OCR ainda detectados nas alternativas da questão 653';
  END IF;

  -- Assert 5: Explicações preservadas byte a byte nas 8 questões (nenhuma explicação foi tocada nesta fase)
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 650) <> 'aab304d6eddbe479bfae4345ea717080' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 650 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 653) <> 'a4e88a3eabca743c0aab59168b09898c' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 653 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 657) <> '7d7b66d60c7dd64cb3b0859728e6a8d1' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 657 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 658) <> '0d790f0edce6ab210a8ef1f28c379309' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 658 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 661) <> '3413527de2d5ff6019861efe0c937730' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 661 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 663) <> 'c85867a40d8398d27735de2b4e01891a' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 663 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 725) <> 'e2f83d45aa1f1e54d38a7d675dd0c7e6' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 725 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 849) <> 'c85c6d4a430a272db8c6967e8d2ca960' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 849 foi alterada indevidamente (deveria permanecer byte a byte idêntica)';
  END IF;

  -- Assert 6: Gabaritos oficiais preservados em cada uma das 8 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 650 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 650 (esperado ordem 3)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 653 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 653 (esperado ordem 3)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 657 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 657 (esperado ordem 4)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 658 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 658 (esperado ordem 3)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 661 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 661 (esperado ordem 1)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 663 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 663 (esperado ordem 2)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 725 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 725 (esperado ordem 2)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 849 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 6 falhou: divergência em gabarito oficial da questão 849 (esperado ordem 1)';
  END IF;

  -- Assert 7: Questões 659 e 717 (fora do lote) permanecem absolutamente intocadas.
  -- Quatro verificações independentes (enunciado/explicação de cada uma), cada uma comparando
  -- o hash ATUAL do banco contra a constante capturada ANTES desta migração — nenhuma
  -- comparação é autorreferente.
  IF (SELECT md5(enunciado) FROM public.questoes WHERE id = 659) <> '876ddacb974d0b559a31fc3acdd714b7' THEN
    RAISE EXCEPTION 'Assert 7a falhou: enunciado da questão 659 (fora do lote) foi modificado indevidamente';
  END IF;
  IF (SELECT md5(explicacao) FROM public.questoes WHERE id = 659) <> '2f97297a62d05d83a2f64d1811c74f72' THEN
    RAISE EXCEPTION 'Assert 7b falhou: explicação da questão 659 (fora do lote) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado) FROM public.questoes WHERE id = 717) <> '9b52b4427b2939575caec8c2c410eec6' THEN
    RAISE EXCEPTION 'Assert 7c falhou: enunciado da questão 717 (fora do lote) foi modificado indevidamente';
  END IF;
  IF (SELECT md5(explicacao) FROM public.questoes WHERE id = 717) <> 'c06977e7013ad2910588219a55a72d51' THEN
    RAISE EXCEPTION 'Assert 7d falhou: explicação da questão 717 (fora do lote) foi modificada indevidamente';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2Q (CONSTITUIÇÃO FEDERAL / DIREITOS E GARANTIAS FUNDAMENTAIS) PASSARAM COM SUCESSO (1-6 + 7a-7d)!';
END $$;

COMMIT;