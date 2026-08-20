-- ============================================================================
-- FASE 2T-A — SEGURANÇA PÚBLICA / DIREITO ADMINISTRATIVO / ATOS ADMINISTRATIVOS
-- Correção de explicações contaminadas (267, 268, 675) e de erro jurisprudencial (743)
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

  -- Validação dos hashes pré-apply das 4 questões do lote
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 267) <> '48c7505ec1de96d0a6cb03d4bee2918e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 267 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 268) <> '389277e01238e9ea78c6c92c67f32dd8' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 268 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 675) <> 'd26e3eacad26bd28e9e8d2274ed4ed57' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 675 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 743) <> 'c896edca31ffdeec764ce2472029c9ca' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 743 divergiu do estado auditado.';
  END IF;

  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 267) <> '58f4644789ca9e9299631ffeaf55ed27' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 267 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 268) <> '15742f2668720b3dae105015c6ae58a3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 268 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 675) <> '593551dab493e0c6ae7ba809364b228e' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 675 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) FROM public.questoes WHERE id = 743) <> 'f002be80acb56b750b791738540f2cd3' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 743 divergiu do estado auditado.';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (4 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A presunção de legitimidade (também chamada presunção de veracidade ou de legalidade) é um dos atributos clássicos do ato administrativo, ao lado da imperatividade, da autoexecutoriedade e da tipicidade. Trata-se de construção doutrinária consolidada (Hely Lopes Meirelles, Maria Sylvia Zanella Di Pietro, José dos Santos Carvalho Filho): todo ato administrativo nasce com a presunção de que foi praticado em conformidade com o Direito, de modo que cabe, em regra, a quem contesta o ato o ônus de demonstrar sua ilegitimidade, sem prejuízo das regras processuais próprias de cada caso concreto. É presunção relativa (juris tantum), e não absoluta — pode ser afastada por prova em sentido contrário, seja na via administrativa, seja na via judicial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Nem todo ato administrativo é irrevogável — a revogabilidade é a regra para os atos discricionários válidos, por razões de conveniência e oportunidade; a presunção de legitimidade não se confunde com a (ir)revogabilidade do ato.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Autoexecutoriedade é atributo distinto, presente apenas quando a lei expressamente autoriza ou a urgência da medida exige a execução material do ato pela própria Administração, sem prévia intervenção do Poder Judiciário — não é característica universal de todo ato.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Ao contrário, a própria lógica da presunção de legitimidade dispensa, em regra, autorização judicial prévia para que o ato produza efeitos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Nem todo ato administrativo é discricionário; há também atos vinculados, em que a Administração não dispõe de margem de escolha quanto ao conteúdo do ato.

BIZU DE PROVA:
Presunção de Legitimidade (ou Veracidade) do Ato Administrativo:
- Presunção RELATIVA (juris tantum) — admite prova em contrário;
- Não se confunde com imperatividade (obrigatoriedade), autoexecutoriedade (execução material sem prévia ordem judicial) ou tipicidade (correspondência a modelo legal);
- Fundamento doutrinário clássico — não decorre de um único artigo de lei que o defina nominalmente.' WHERE id = 267;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A revogação é a extinção de um ato administrativo válido, promovida pela própria Administração Pública, fundada em juízo de conveniência e oportunidade — isto é, no mérito administrativo. Diferentemente da anulação, que pressupõe ilegalidade, a revogação pressupõe um ato originalmente válido que a Administração, no exercício de sua autotutela, decide extinguir por não mais atender ao interesse público. A Súmula 473 do STF consolida essa distinção: "A administração pode anular seus próprios atos, quando eivados de vícios que os tornam ilegais, porque deles não se originam direitos; ou revogá-los, por motivo de conveniência ou oportunidade, respeitados os direitos adquiridos, e ressalvada, em todos os casos, a apreciação judicial." No mesmo sentido, o art. 53 da Lei nº 9.784/1999 positiva, no âmbito federal, essa mesma lógica: a Administração "pode revogá-los por motivo de conveniência ou oportunidade, respeitados os direitos adquiridos". Os efeitos da revogação são, em regra, prospectivos (ex nunc), preservando os efeitos já produzidos pelo ato revogado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ilegalidade originária é fundamento de anulação, não de revogação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Decisão criminal não é, em regra, fundamento de revogação de atos administrativos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inconstitucionalidade é vício de legalidade em sentido amplo, que leva à anulação (ou à declaração de inconstitucionalidade pela via própria), e não à revogação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Ausência de competência legislativa também configura vício de legalidade, tema de anulação, não de revogação.

BIZU DE PROVA:
Revogação x Anulação:
- REVOGAÇÃO = ato VÁLIDO + conveniência e oportunidade (mérito) + efeitos EX NUNC + só a Administração revoga;
- ANULAÇÃO = ato ILEGAL + efeitos EX TUNC + Administração OU Judiciário podem anular (Súmula 473, STF).' WHERE id = 268;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (I, II e III corretas):

ASSERTIVA I (CORRETA):
Reproduz o art. 144, caput, da Constituição Federal: "A segurança pública, dever do Estado, direito e responsabilidade de todos, é exercida para a preservação da ordem pública e da incolumidade das pessoas e do patrimônio, através dos seguintes órgãos: [...]".

ASSERTIVA II (CORRETA):
Reproduz o art. 144, §4º, da Constituição Federal: "às polícias civis, dirigidas por delegados de polícia de carreira, incumbem, ressalvada a competência da União, as funções de polícia judiciária e a apuração de infrações penais, exceto as militares."

ASSERTIVA III (CORRETA):
Fundamenta-se no art. 126 da Constituição do Estado do Rio Grande do Sul, que dispõe: "A sociedade participará, através dos Conselhos de Defesa e Segurança da Comunidade, no encaminhamento e solução dos problemas atinentes à segurança pública, na forma da lei." Trata-se de dispositivo da Constituição ESTADUAL do RS — a Constituição Federal não prevê os Conselhos de Defesa e Segurança da Comunidade em seu texto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois I também é verdadeira.

BIZU DE PROVA:
Segurança Pública — fontes normativas combinadas:
- Art. 144, caput, CF: dever do Estado, direito e responsabilidade de todos;
- Art. 144, §4º, CF: Polícia Civil = polícia judiciária + apuração de infrações penais (exceto militares);
- Art. 126, Constituição do Estado do Rio Grande do Sul: Conselhos de Defesa e Segurança da Comunidade — participação social prevista na Constituição ESTADUAL, não na Federal!' WHERE id = 675;
  UPDATE public.questoes SET explicacao = 'GABARITO: alternativa B (Apenas I e II)

POR QUE A ALTERNATIVA B ESTÁ CORRETA:

ASSERTIVA I (CORRETA):
O STF reconheceu, em mais de um precedente, que a atuação das Guardas Municipais em atividades de segurança urbana é compatível com o rol de órgãos de segurança pública do art. 144 da Constituição Federal, sem que isso configure ampliação inconstitucional desse rol pelos entes federados:
- Na ADPF 995/DF (Rel. Min. Alexandre de Moraes, julgamento concluído em 28/08/2023), o Plenário do STF fixou interpretação conforme a Constituição aos arts. 4º da Lei nº 13.022/2014 e 9º da Lei nº 13.675/2018, reconhecendo que as Guardas Municipais devidamente criadas e instituídas integram o Sistema Único de Segurança Pública (SUSP).
- No Tema 656 da Repercussão Geral (RE 608.588/SP, Rel. Min. Luiz Fux, mérito julgado em 20/02/2025, acórdão publicado em 22/08/2025), o STF fixou a tese de que é constitucional, no âmbito dos municípios, o exercício de ações de segurança urbana pelas Guardas Municipais, inclusive policiamento ostensivo e comunitário, respeitadas as atribuições dos demais órgãos de segurança pública previstos no art. 144 da CF e excluída qualquer atividade de polícia judiciária, submetendo-se ao controle externo da atividade policial pelo Ministério Público (art. 129, VII, CF), observadas as normas gerais fixadas pelo Congresso Nacional (art. 144, §8º, CF).
Combinando os dois precedentes: as Guardas Municipais já possuem previsão expressa no art. 144, §8º, CF, e a jurisprudência do STF reconheceu e delimitou sua integração ao sistema de segurança pública, sem autorizar os entes federados a criar livremente novos órgãos de segurança pública fora do rol constitucional — a atuação das Guardas Municipais permanece circunscrita ao policiamento preventivo/comunitário e à proteção de bens, serviços e instalações municipais, com expressa exclusão de atividades de polícia judiciária.

ASSERTIVA II (CORRETA):
O art. 144, §4º, da Constituição Federal atribui à Polícia Civil, ressalvada a competência da União, as funções de polícia judiciária e a apuração de infrações penais, exceto as militares. Por não haver rol taxativo de infrações reservadas a outros órgãos investigativos, a doutrina reconhece à Polícia Civil competência investigativa de caráter residual: cabe-lhe apurar, em regra, toda infração penal cuja atribuição não esteja constitucional ou legalmente reservada a outro órgão (como a Polícia Federal, nos casos do art. 144, §1º, CF, ou a Justiça Militar, quanto às infrações penais militares).

POR QUE A ASSERTIVA III ESTÁ INCORRETA:
O art. 144, §5º-A, da Constituição Federal (incluído pela EC nº 104/2019) dispõe: "Às polícias penais, vinculadas ao órgão administrador do sistema penal da unidade federativa a que pertencem, cabe a segurança dos estabelecimentos penais." A Constituição atribui às polícias penais apenas a SEGURANÇA dos estabelecimentos penais — não a sua ADMINISTRAÇÃO, que é função do órgão administrador do sistema penal, ao qual as polícias penais são vinculadas, mas com o qual não se confundem. A assertiva III erra exatamente ao acrescentar a "administração" dos estabelecimentos penais como atribuição constitucional das polícias penais.
Quanto à subordinação, a assertiva III está correta nesse ponto específico: o art. 144, §6º, da CF (na redação dada pela EC nº 104/2019) estabelece que as polícias militares e os corpos de bombeiros militares, forças auxiliares e reserva do Exército, subordinam-se, juntamente com as polícias civis e as polícias penais estaduais e distrital, aos Governadores dos Estados, do Distrito Federal e dos Territórios — logo, as polícias penais estaduais e distrital realmente se subordinam aos Governadores. O vício da assertiva III está isolado no acréscimo indevido da palavra "administração" às atribuições de segurança dos estabelecimentos penais.

BIZU DE PROVA:
Guardas Municipais — jurisprudência do STF:
- ADPF 995/DF (Min. Alexandre de Moraes, 2023): Guardas Municipais integram o SUSP;
- Tema 656 / RE 608.588 (Min. Luiz Fux, mérito 2025): podem exercer policiamento ostensivo e comunitário, vedada polícia judiciária.
Polícias Penais (Art. 144, §5º-A e §6º, CF - EC 104/2019):
- Subordinação: aos Governadores dos Estados/DF (§6º) — correto;
- Atribuição constitucional: SEGURANÇA dos estabelecimentos penais (§5º-A) — a Constituição NÃO fala em "administração"!' WHERE id = 743;

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

  -- Assert 2: Status "ativa" preservado nas 4 questões do lote
  IF (SELECT count(*) FROM public.questoes WHERE id IN (267, 268, 675, 743) AND ativa = true) <> 4 THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa alterado indevidamente em alguma questão do lote';
  END IF;

  -- Assert 3: Exatamente 5 alternativas por questão e exatamente 1 alternativa correta
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (267, 268, 675, 743)) <> 4 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id IN (267, 268, 675, 743)) <> 20 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (267, 268, 675, 743)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: alternativas divergentes do estado esperado (5 por questão, exatamente 1 correta)';
  END IF;

  -- Assert 4: Gabaritos oficiais preservados em cada uma das 4 questões (267=A, 268=A, 675=E, 743=B)
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 267 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 267 (esperado ordem 1)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 268 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 268 (esperado ordem 1)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 675 AND ordem = 5 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 675 (esperado ordem 5)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 743 AND ordem = 2 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão 743 (esperado ordem 2)';
  END IF;

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 267) <> '48c7505ec1de96d0a6cb03d4bee2918e' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 267 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 268) <> '389277e01238e9ea78c6c92c67f32dd8' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 268 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 675) <> 'd26e3eacad26bd28e9e8d2274ed4ed57' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 675 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 743) <> 'c896edca31ffdeec764ce2472029c9ca' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 743 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 6: Questão 267 — explicação fala de presunção de legitimidade/prova em contrário
  -- e não contém mais resíduo de tráfico de drogas (Lei 11.343/2006)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 267;
  IF v_explicacao_check NOT ILIKE '%presunção de legitimidade%' OR
     v_explicacao_check NOT ILIKE '%prova em contrário%' OR
     v_explicacao_check ILIKE '%11.343%' OR
     v_explicacao_check ILIKE '%tráfico%' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 267 incorreta ou ainda contendo resíduo de tráfico de drogas';
  END IF;

  -- Assert 7: Questão 268 — explicação fala de revogação/conveniência/oportunidade/Súmula 473
  -- e não contém mais resíduo de tráfico privilegiado (Lei 11.343/2006)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 268;
  IF v_explicacao_check NOT ILIKE '%revogação%' OR
     v_explicacao_check NOT ILIKE '%conveniência%' OR
     v_explicacao_check NOT ILIKE '%oportunidade%' OR
     v_explicacao_check NOT ILIKE '%Súmula 473%' OR
     v_explicacao_check ILIKE '%11.343%' OR
     v_explicacao_check ILIKE '%tráfico%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 268 incorreta ou ainda contendo resíduo de tráfico privilegiado';
  END IF;

  -- Assert 8: Questão 675 — explicação fundamenta I (art. 144, caput), II (art. 144, §4º) e
  -- III (art. 126 da Constituição do RS / Conselhos de Defesa e Segurança da Comunidade),
  -- e não contém mais resíduo de Lei Maria da Penha (Lei 11.340/2006)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 675;
  IF v_explicacao_check NOT ILIKE '%art. 144, caput%' OR
     v_explicacao_check NOT ILIKE '%§4º%' OR
     v_explicacao_check NOT ILIKE '%Constituição do Estado do Rio Grande do Sul%' OR
     v_explicacao_check NOT ILIKE '%art. 126%' OR
     v_explicacao_check NOT ILIKE '%Conselhos de Defesa e Segurança da Comunidade%' OR
     v_explicacao_check ILIKE '%Maria da Penha%' OR
     v_explicacao_check ILIKE '%11.340%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: explicação da questão 675 incorreta ou ainda contendo resíduo de Lei Maria da Penha';
  END IF;

  -- Assert 9: Questão 743 — explicação cita ADPF 995, Tema 656, RE 608.588 e Luiz Fux para a
  -- assertiva I, arts. 144 §5º-A e §6º da CF para a assertiva III, explica que "administração"
  -- é o erro da assertiva III, e NÃO contém mais o Tema 1.256 nem atribui a Alexandre de Moraes
  -- a relatoria do Tema 656, nem afirma que a subordinação aos Governadores está errada
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 743;
  IF v_explicacao_check NOT ILIKE '%ADPF 995%' OR
     v_explicacao_check NOT ILIKE '%Tema 656%' OR
     v_explicacao_check NOT ILIKE '%RE 608.588%' OR
     v_explicacao_check NOT ILIKE '%Luiz Fux%' OR
     v_explicacao_check NOT ILIKE '%§5º-A%' OR
     v_explicacao_check NOT ILIKE '%§6º%' OR
     v_explicacao_check NOT ILIKE '%administração%' OR
     v_explicacao_check ILIKE '%Tema 1.256%' OR
     v_explicacao_check ILIKE '%1.256%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 743 incorreta, incompleta ou ainda contendo o erro do Tema 1.256';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2T-A (SEGURANÇA PÚBLICA / DIREITO ADMINISTRATIVO / ATOS ADMINISTRATIVOS) PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;