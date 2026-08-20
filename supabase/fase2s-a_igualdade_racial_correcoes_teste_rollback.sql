-- ============================================================================
-- FASE 2S-A — ESTATUTO DA IGUALDADE RACIAL (LEI 12.288/2010 E LEI ESTADUAL RS 13.694/2011)
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

  -- Validação dos hashes pré-apply das 7 questões do lote
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 131) <> 'accd373ee90f700378ffe443bcd40ff7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 131 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 136) <> '9e6f152e3e212ceabaedcf3a8873fac5' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 136 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 255) <> '2976c23f2b390af1c4a411b3709645e2' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 255 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 256) <> '99edd2a3015006ac76b7384d5f1a2435' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 256 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 850) <> '84597b5f3bd3187e97448a4196d9494e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 850 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 851) <> 'c619880d86c75762dca80f7103cef009' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 851 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 852) <> '1455e565166eff5a037c7fd6148d0e83' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 852 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 131) <> '899e93009f95c056cf9977b0c4b09512' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 131 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 136) <> '49a80b477ce500cd95a5b4b258b20218' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 136 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 255) <> 'e8bc2e77fa2ca39f0aa44800a878f03a' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 255 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 256) <> 'ba43f5afea0e1cfa28676a2810f0ca68' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 256 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 850) <> '40d6df0a650d938e6e2365cc164e39ed' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 850 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 851) <> '1235318206f0f969b6f080fef4468cb7' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 851 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 852) <> 'b5db5abe96db10b5f87b2c4041f8a91e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 852 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (7 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Artigo 3º da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) dispõe: "Além das normas constitucionais relativas aos princípios fundamentais, aos direitos e garantias fundamentais e aos direitos sociais, econômicos e culturais, o Estatuto da Igualdade Racial adota como diretriz político-jurídica a inclusão das vítimas de desigualdade ÉTNICO-RACIAL, a valorização da igualdade étnica e o fortalecimento da identidade nacional brasileira."
- I. (Incorreta): O texto legal fala em "vítimas de desigualdade étnico-racial", e não em "desigualdade social" como afirma a assertiva.
- II. (Correta): "A valorização da igualdade étnica" reproduz literalmente o dispositivo.
- III. (Correta): "O fortalecimento da identidade nacional brasileira" reproduz literalmente o dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I é falsa, e a assertiva III também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II também é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva I é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva I é falsa, pois o texto legal fala em desigualdade étnico-racial, não social.

BIZU DE PROVA:
Diretrizes Político-Jurídicas do Estatuto (Art. 3º da Lei 12.288/2010):
Inclusão das vítimas de desigualdade ÉTNICO-RACIAL (não "social"), valorização da igualdade étnica e fortalecimento da identidade nacional brasileira!', atualizado_em = now() WHERE id = 131;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é V – V – V, com fundamento no Artigo 17, caput e parágrafo único, da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial): "O Poder Público deverá promover políticas afirmativas que assegurem igualdade de oportunidades aos negros no acesso aos cargos públicos, proporcionalmente a sua parcela na composição da população do Estado, e incentivará a uma maior equidade para os negros nos empregos oferecidos na iniciativa privada. Parágrafo único - Para enfrentar a situação de desigualdade de oportunidades, deverão ser implementadas políticas e programas de formação profissional, emprego e geração de renda voltadas aos negros."
- (V) Políticas afirmativas de igualdade de oportunidades no acesso aos cargos públicos: reproduz o caput.
- (V) Políticas afirmativas de maior equidade na iniciativa privada: reproduz o caput.
- (V) Políticas e programas de formação profissional, emprego e geração de renda: reproduz o parágrafo único.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira e a segunda assertivas também são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva também é verdadeira.

BIZU DE PROVA:
Acesso ao Mercado de Trabalho (Art. 17 da Lei Estadual RS 13.694/2011):
Cargos públicos + iniciativa privada + formação profissional, emprego e geração de renda — todos voltados à população negra!', atualizado_em = now() WHERE id = 136;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, parágrafo único, inciso I, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) define: "discriminação racial ou étnico-racial: toda distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que tenha por objeto anular ou restringir o reconhecimento, gozo ou exercício, em igualdade de condições, de direitos humanos e liberdades fundamentais nos campos político, econômico, social, cultural ou em qualquer outro campo da vida pública ou privada."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O conceito legal não se limita a agressão física; abrange qualquer distinção, exclusão, restrição ou preferência que anule ou restrinja direitos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O conceito não se restringe a concursos públicos; alcança qualquer campo da vida pública ou privada.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dispositivo não exige que a conduta seja praticada por agente estatal; aplica-se também a particulares.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O conceito de discriminação racial do Estatuto não se limita a tipos penais do Código Penal.

BIZU DE PROVA:
Discriminação Racial ou Étnico-Racial (Art. 1º, parágrafo único, I, da Lei 12.288/2010):
Toda distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que anule ou restrinja direitos humanos e liberdades fundamentais, em qualquer campo da vida pública ou privada!', atualizado_em = now() WHERE id = 255;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, caput, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) dispõe: "Esta Lei institui o Estatuto da Igualdade Racial, destinado a garantir à população negra a efetivação da igualdade de oportunidades, a defesa dos direitos étnicos individuais, coletivos e difusos e o combate à discriminação e às demais formas de intolerância étnica."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Estatuto não institui regime jurídico penal especial para a população negra.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Estatuto não confere privilégio absoluto sobre outros grupos; busca a efetivação da igualdade de oportunidades.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há previsão de isenção tributária geral no Estatuto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Estatuto não prevê acesso exclusivo a cargos públicos.

BIZU DE PROVA:
Finalidade do Estatuto da Igualdade Racial (Art. 1º, caput, da Lei 12.288/2010):
Efetivação da IGUALDADE DE OPORTUNIDADES + defesa dos direitos étnicos individuais, coletivos e difusos + combate à discriminação e à intolerância étnica!', atualizado_em = now() WHERE id = 256;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta é V – V – V, com fundamento em três dispositivos da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial):
- (V) Artigo 13: "O Poder Público deverá promover campanhas que divulguem a literatura produzida pelos negros e aquela que reproduza a história, as tradições e a cultura do povo negro."
- (V) Artigo 15: "O Estado deverá promover programas de incentivo, inclusão e permanência da população negra nos ensinos Médio, Técnico e Superior, adotando medidas para (...)."
- (V) Artigo 20: "A idealização, a realização e a exibição das peças publicitárias veiculadas pelo Poder Público deverão observar percentual de artistas, modelos e trabalhadores afrodescendentes em número equivalente ao resultante do censo do Instituto Brasileiro de Geografia e Estatística (IBGE) de afro-brasileiros na composição da população do Rio Grande do Sul."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira e a terceira assertivas também são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A segunda assertiva também é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A segunda e a terceira assertivas também são verdadeiras.

BIZU DE PROVA:
Estatuto Estadual da Igualdade Racial do RS:
Art. 13 (campanhas de literatura negra) + Art. 15 (incentivo ao ensino Médio/Técnico/Superior) + Art. 20 (percentual de afrodescendentes em publicidade oficial, conforme censo IBGE)!', atualizado_em = now() WHERE id = 850;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é V – V – V, com fundamento no Artigo 17, caput e parágrafo único, da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial): "O Poder Público deverá promover políticas afirmativas que assegurem igualdade de oportunidades aos negros no acesso aos cargos públicos, proporcionalmente a sua parcela na composição da população do Estado, e incentivará a uma maior equidade para os negros nos empregos oferecidos na iniciativa privada. Parágrafo único - Para enfrentar a situação de desigualdade de oportunidades, deverão ser implementadas políticas e programas de formação profissional, emprego e geração de renda voltadas aos negros."
- (V) Políticas afirmativas de igualdade de oportunidades no acesso aos cargos públicos: reproduz o caput.
- (V) Políticas afirmativas de maior equidade na iniciativa privada: reproduz o caput.
- (V) Políticas e programas de formação profissional, emprego e geração de renda: reproduz o parágrafo único.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira e a segunda assertivas também são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva também é verdadeira.

BIZU DE PROVA:
Acesso ao Mercado de Trabalho (Art. 17 da Lei Estadual RS 13.694/2011):
Cargos públicos + iniciativa privada + formação profissional, emprego e geração de renda — todos voltados à população negra!', atualizado_em = now() WHERE id = 851;
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
Quesito raça = Art. 18; Datas comemorativas cívicas = Art. 11; Capoeira nas escolas = Art. 14 — "Kuduro" NÃO consta na lei!', atualizado_em = now() WHERE id = 852;

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

  -- Assert 2: Status "ativa" preservado nas 7 questões do lote
  IF (SELECT count(*) FROM public.questoes WHERE id IN (131, 136, 255, 256, 850, 851, 852) AND ativa = true) <> 7 THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa alterado indevidamente em alguma questão do lote';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão, 5 alternativas presentes
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (131, 136, 255, 256, 850, 851, 852)) <> 7 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id IN (131, 136, 255, 256, 850, 851, 852)) <> 35 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (131, 136, 255, 256, 850, 851, 852)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: alternativas divergentes do estado esperado (5 por questão, exatamente 1 correta)';
  END IF;

  -- Assert 4: Gabaritos oficiais preservados em cada uma das 7 questões
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 131 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 131 (esperado ordem 4)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 136 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 136 (esperado ordem 4)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 255 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 255 (esperado ordem 1)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 256 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 256 (esperado ordem 1)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 850 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 850 (esperado ordem 3)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 851 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 851 (esperado ordem 4)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 852 AND ordem = 4 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 852 (esperado ordem 4)';
  END IF;

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 131) <> 'accd373ee90f700378ffe443bcd40ff7' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 131 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 136) <> '9e6f152e3e212ceabaedcf3a8873fac5' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 136 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 255) <> '2976c23f2b390af1c4a411b3709645e2' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 255 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 256) <> '99edd2a3015006ac76b7384d5f1a2435' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 256 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 850) <> '84597b5f3bd3187e97448a4196d9494e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 850 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 851) <> 'c619880d86c75762dca80f7103cef009' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 851 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 852) <> '1455e565166eff5a037c7fd6148d0e83' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 852 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 6a: Questões 131/255/256 - explicações contêm os artigos corretos da Lei 12.288/2010
  -- e não contêm mais nenhum resíduo da Declaração Universal dos Direitos Humanos (DUDH)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 131;
  IF v_explicacao_check NOT ILIKE '%Artigo 3º%' OR v_explicacao_check ILIKE '%DUDH%' OR v_explicacao_check ILIKE '%Declaração Universal%' THEN
    RAISE EXCEPTION 'Assert 6a falhou: explicação da questão 131 incorreta ou ainda contendo resíduo da DUDH';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 255;
  IF v_explicacao_check NOT ILIKE '%Artigo 1º, parágrafo único, inciso I%' OR v_explicacao_check ILIKE '%DUDH%' OR v_explicacao_check ILIKE '%liberdade de reunião%' THEN
    RAISE EXCEPTION 'Assert 6a falhou: explicação da questão 255 incorreta ou ainda contendo resíduo da DUDH';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 256;
  IF v_explicacao_check NOT ILIKE '%Artigo 1º, caput%' OR v_explicacao_check ILIKE '%DUDH%' OR v_explicacao_check ILIKE '%soberania popular%' THEN
    RAISE EXCEPTION 'Assert 6a falhou: explicação da questão 256 incorreta ou ainda contendo resíduo da DUDH';
  END IF;

  -- Assert 6b: Questão 136 - explicação contém o Art. 17 da Lei 13.694/2011 e não contém mais
  -- nenhum resíduo da Lei de Abuso de Autoridade
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 136;
  IF v_explicacao_check NOT ILIKE '%Artigo 17, caput e parágrafo único%' OR
     v_explicacao_check ILIKE '%13.869%' OR
     v_explicacao_check ILIKE '%dolo específico%' OR
     v_explicacao_check ILIKE '%crime de hermenêutica%' THEN
    RAISE EXCEPTION 'Assert 6b falhou: explicação da questão 136 incorreta ou ainda contendo resíduo da Lei de Abuso de Autoridade';
  END IF;

  -- Assert 6c: Questões 850/851/852 - explicações contêm os artigos corretos da Lei 13.694/2011
  -- e não contêm mais nenhum resíduo do Estatuto do Desarmamento
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 850;
  IF v_explicacao_check NOT ILIKE '%Artigo 13%' OR v_explicacao_check NOT ILIKE '%Artigo 15%' OR v_explicacao_check NOT ILIKE '%Artigo 20%' OR
     v_explicacao_check ILIKE '%10.826%' OR v_explicacao_check ILIKE '%arma de fogo%' THEN
    RAISE EXCEPTION 'Assert 6c falhou: explicação da questão 850 incorreta ou ainda contendo resíduo do Estatuto do Desarmamento';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 851;
  IF v_explicacao_check NOT ILIKE '%Artigo 17, caput e parágrafo único%' OR
     v_explicacao_check ILIKE '%10.826%' OR v_explicacao_check ILIKE '%arma de fogo%' THEN
    RAISE EXCEPTION 'Assert 6c falhou: explicação da questão 851 incorreta ou ainda contendo resíduo do Estatuto do Desarmamento';
  END IF;

  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 852;
  IF v_explicacao_check NOT ILIKE '%Artigo 18%' OR v_explicacao_check NOT ILIKE '%Artigo 11%' OR v_explicacao_check NOT ILIKE '%Artigo 14%' OR
     v_explicacao_check NOT ILIKE '%Kuduro%' OR
     v_explicacao_check ILIKE '%10.826%' OR v_explicacao_check ILIKE '%arma de fogo%' THEN
    RAISE EXCEPTION 'Assert 6c falhou: explicação da questão 852 incorreta ou ainda contendo resíduo do Estatuto do Desarmamento';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2S-A (ESTATUTO DA IGUALDADE RACIAL) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;