#!/usr/bin/env node
// Fase 2T-A — Segurança Pública / Direito Administrativo / Atos Administrativos:
// correção de explicações contaminadas por conteúdo de outra matéria/lote (267, 268, 675)
// e de um erro jurisprudencial confirmado (743). Somente o campo `explicacao` é alterado em
// cada uma das 4 questões — enunciado, alternativas, gabarito, ordem das alternativas, status
// `ativa`, matéria, assunto e demais metadados permanecem intocados.
//
// Escopo:
//   - id 267 (Atos administrativos): explicação citava integralmente Lei 11.343/2006 (tráfico
//             de drogas), sem relação com o enunciado (atributos do ato administrativo —
//             presunção de legitimidade). Corrigida para o conceito doutrinário correto.
//             Gabarito A (ordem 1) preservado.
//   - id 268 (Atos administrativos): explicação citava integralmente tráfico privilegiado
//             (Lei 11.343/2006, art. 33, §4º), sem relação com o enunciado (revogação de ato
//             administrativo válido). Corrigida com base em doutrina + Súmula 473 STF + art. 53
//             da Lei 9.784/1999 (reforço normativo federal). Gabarito A (ordem 1) preservado.
//   - id 675 (Segurança pública): explicação citava integralmente a Lei Maria da Penha (Lei
//             11.340/2006), sem relação com as assertivas (Art. 144, caput e §4º, CF + Art. 126
//             da Constituição do Estado do RS — Conselhos de Defesa e Segurança da Comunidade).
//             Corrigida com fundamentação individual de cada assertiva, deixando explícito que a
//             assertiva III decorre da Constituição ESTADUAL do RS, não da Constituição Federal.
//             Gabarito E (ordem 5, I/II/III corretas) preservado.
//   - id 743 (Segurança pública / Guarda Municipal): explicação citava "Tema 1.256" do STF como
//             precedente sobre Guardas Municipais — erro jurisprudencial confirmado (Tema 1.256 =
//             RE 1.428.399, sobre honorários contratuais de FUNDEF/FUNDEB, sem relação com o
//             tema). Corrigida citando ADPF 995/DF (Rel. Min. Alexandre de Moraes, j. 28/08/2023)
//             e Tema 656/RE 608.588 (Rel. Min. Luiz Fux, mérito 20/02/2025, acórdão publicado
//             22/08/2025) para a assertiva I, e explicitando que o vício da assertiva III está no
//             acréscimo indevido de "administração" às atribuições das polícias penais (art. 144,
//             §5º-A, CF — que fala apenas em "segurança" dos estabelecimentos penais), preservando
//             como correta a subordinação aos Governadores (art. 144, §6º, CF, EC 104/2019).
//             Gabarito B (ordem 2, apenas I e II corretas) preservado.
//
// Referência (Fase 2T-A, microanálise jurídica já entregue nesta sessão, com revisão adicional
// de fontes primárias confirmada pelo usuário antes desta geração):
//   ADPF 995/DF (STF) / Tema 656 - RE 608.588 (STF) / Súmula 473 (STF) / art. 53, Lei 9.784/1999
//   / art. 144, caput, §4º, §5º-A e §6º, CF/88 / art. 126, Constituição do Estado do RS.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2t-a_seguranca_admin_atos_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2t-a_seguranca_admin_atos_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração (Fase 2T,
// reconfirmados sem drift no início da Fase 2T-A).
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  267: '48c7505ec1de96d0a6cb03d4bee2918e',
  268: '389277e01238e9ea78c6c92c67f32dd8',
  675: 'd26e3eacad26bd28e9e8d2274ed4ed57',
  743: 'c896edca31ffdeec764ce2472029c9ca',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  267: '58f4644789ca9e9299631ffeaf55ed27',
  268: '15742f2668720b3dae105015c6ae58a3',
  675: '593551dab493e0c6ae7ba809364b228e',
  743: 'f002be80acb56b750b791738540f2cd3',
};

// Ordem da alternativa correta (gabarito) de cada questão do lote — inalterado nesta fase
const GABARITO = { 267: 1, 268: 1, 675: 5, 743: 2 };

// --------------------------------------------------------------------------
// Textos novos das explicações
// --------------------------------------------------------------------------

const EXPLICACAO_NOVA_267 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
A presunção de legitimidade (também chamada presunção de veracidade ou de legalidade) é um dos atributos clássicos do ato administrativo, ao lado da imperatividade, da autoexecutoriedade e da tipicidade. Trata-se de construção doutrinária consolidada (Hely Lopes Meirelles, Maria Sylvia Zanella Di Pietro, José dos Santos Carvalho Filho): todo ato administrativo nasce com a presunção de que foi praticado em conformidade com o Direito, de modo que cabe, em regra, a quem contesta o ato o ônus de demonstrar sua ilegitimidade, sem prejuízo das regras processuais próprias de cada caso concreto. É presunção relativa (juris tantum), e não absoluta — pode ser afastada por prova em sentido contrário, seja na via administrativa, seja na via judicial.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Nem todo ato administrativo é irrevogável — a revogabilidade é a regra para os atos discricionários válidos, por razões de conveniência e oportunidade; a presunção de legitimidade não se confunde com a (ir)revogabilidade do ato.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Autoexecutoriedade é atributo distinto, presente apenas quando a lei expressamente autoriza ou a urgência da medida exige a execução material do ato pela própria Administração, sem prévia intervenção do Poder Judiciário — não é característica universal de todo ato.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Ao contrário, a própria lógica da presunção de legitimidade dispensa, em regra, autorização judicial prévia para que o ato produza efeitos.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Nem todo ato administrativo é discricionário; há também atos vinculados, em que a Administração não dispõe de margem de escolha quanto ao conteúdo do ato.\r
\r
BIZU DE PROVA:\r
Presunção de Legitimidade (ou Veracidade) do Ato Administrativo:\r
- Presunção RELATIVA (juris tantum) — admite prova em contrário;\r
- Não se confunde com imperatividade (obrigatoriedade), autoexecutoriedade (execução material sem prévia ordem judicial) ou tipicidade (correspondência a modelo legal);\r
- Fundamento doutrinário clássico — não decorre de um único artigo de lei que o defina nominalmente.`;

const EXPLICACAO_NOVA_268 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
A revogação é a extinção de um ato administrativo válido, promovida pela própria Administração Pública, fundada em juízo de conveniência e oportunidade — isto é, no mérito administrativo. Diferentemente da anulação, que pressupõe ilegalidade, a revogação pressupõe um ato originalmente válido que a Administração, no exercício de sua autotutela, decide extinguir por não mais atender ao interesse público. A Súmula 473 do STF consolida essa distinção: "A administração pode anular seus próprios atos, quando eivados de vícios que os tornam ilegais, porque deles não se originam direitos; ou revogá-los, por motivo de conveniência ou oportunidade, respeitados os direitos adquiridos, e ressalvada, em todos os casos, a apreciação judicial." No mesmo sentido, o art. 53 da Lei nº 9.784/1999 positiva, no âmbito federal, essa mesma lógica: a Administração "pode revogá-los por motivo de conveniência ou oportunidade, respeitados os direitos adquiridos". Os efeitos da revogação são, em regra, prospectivos (ex nunc), preservando os efeitos já produzidos pelo ato revogado.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Ilegalidade originária é fundamento de anulação, não de revogação.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Decisão criminal não é, em regra, fundamento de revogação de atos administrativos.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Inconstitucionalidade é vício de legalidade em sentido amplo, que leva à anulação (ou à declaração de inconstitucionalidade pela via própria), e não à revogação.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Ausência de competência legislativa também configura vício de legalidade, tema de anulação, não de revogação.\r
\r
BIZU DE PROVA:\r
Revogação x Anulação:\r
- REVOGAÇÃO = ato VÁLIDO + conveniência e oportunidade (mérito) + efeitos EX NUNC + só a Administração revoga;\r
- ANULAÇÃO = ato ILEGAL + efeitos EX TUNC + Administração OU Judiciário podem anular (Súmula 473, STF).`;

const EXPLICACAO_NOVA_675 = `GABARITO: alternativa E\r
\r
POR QUE A ALTERNATIVA E ESTÁ CORRETA (I, II e III corretas):\r
\r
ASSERTIVA I (CORRETA):\r
Reproduz o art. 144, caput, da Constituição Federal: "A segurança pública, dever do Estado, direito e responsabilidade de todos, é exercida para a preservação da ordem pública e da incolumidade das pessoas e do patrimônio, através dos seguintes órgãos: [...]".\r
\r
ASSERTIVA II (CORRETA):\r
Reproduz o art. 144, §4º, da Constituição Federal: "às polícias civis, dirigidas por delegados de polícia de carreira, incumbem, ressalvada a competência da União, as funções de polícia judiciária e a apuração de infrações penais, exceto as militares."\r
\r
ASSERTIVA III (CORRETA):\r
Fundamenta-se no art. 126 da Constituição do Estado do Rio Grande do Sul, que dispõe: "A sociedade participará, através dos Conselhos de Defesa e Segurança da Comunidade, no encaminhamento e solução dos problemas atinentes à segurança pública, na forma da lei." Trata-se de dispositivo da Constituição ESTADUAL do RS — a Constituição Federal não prevê os Conselhos de Defesa e Segurança da Comunidade em seu texto.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
Incompleta, pois II e III também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Incompleta, pois I e III também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Incompleta, pois III também é verdadeira.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Incompleta, pois I também é verdadeira.\r
\r
BIZU DE PROVA:\r
Segurança Pública — fontes normativas combinadas:\r
- Art. 144, caput, CF: dever do Estado, direito e responsabilidade de todos;\r
- Art. 144, §4º, CF: Polícia Civil = polícia judiciária + apuração de infrações penais (exceto militares);\r
- Art. 126, Constituição do Estado do Rio Grande do Sul: Conselhos de Defesa e Segurança da Comunidade — participação social prevista na Constituição ESTADUAL, não na Federal!`;

const EXPLICACAO_NOVA_743 = `GABARITO: alternativa B (Apenas I e II)\r
\r
POR QUE A ALTERNATIVA B ESTÁ CORRETA:\r
\r
ASSERTIVA I (CORRETA):\r
O STF reconheceu, em mais de um precedente, que a atuação das Guardas Municipais em atividades de segurança urbana é compatível com o rol de órgãos de segurança pública do art. 144 da Constituição Federal, sem que isso configure ampliação inconstitucional desse rol pelos entes federados:\r
- Na ADPF 995/DF (Rel. Min. Alexandre de Moraes, julgamento concluído em 28/08/2023), o Plenário do STF fixou interpretação conforme a Constituição aos arts. 4º da Lei nº 13.022/2014 e 9º da Lei nº 13.675/2018, reconhecendo que as Guardas Municipais devidamente criadas e instituídas integram o Sistema Único de Segurança Pública (SUSP).\r
- No Tema 656 da Repercussão Geral (RE 608.588/SP, Rel. Min. Luiz Fux, mérito julgado em 20/02/2025, acórdão publicado em 22/08/2025), o STF fixou a tese de que é constitucional, no âmbito dos municípios, o exercício de ações de segurança urbana pelas Guardas Municipais, inclusive policiamento ostensivo e comunitário, respeitadas as atribuições dos demais órgãos de segurança pública previstos no art. 144 da CF e excluída qualquer atividade de polícia judiciária, submetendo-se ao controle externo da atividade policial pelo Ministério Público (art. 129, VII, CF), observadas as normas gerais fixadas pelo Congresso Nacional (art. 144, §8º, CF).\r
Combinando os dois precedentes: as Guardas Municipais já possuem previsão expressa no art. 144, §8º, CF, e a jurisprudência do STF reconheceu e delimitou sua integração ao sistema de segurança pública, sem autorizar os entes federados a criar livremente novos órgãos de segurança pública fora do rol constitucional — a atuação das Guardas Municipais permanece circunscrita ao policiamento preventivo/comunitário e à proteção de bens, serviços e instalações municipais, com expressa exclusão de atividades de polícia judiciária.\r
\r
ASSERTIVA II (CORRETA):\r
O art. 144, §4º, da Constituição Federal atribui à Polícia Civil, ressalvada a competência da União, as funções de polícia judiciária e a apuração de infrações penais, exceto as militares. Por não haver rol taxativo de infrações reservadas a outros órgãos investigativos, a doutrina reconhece à Polícia Civil competência investigativa de caráter residual: cabe-lhe apurar, em regra, toda infração penal cuja atribuição não esteja constitucional ou legalmente reservada a outro órgão (como a Polícia Federal, nos casos do art. 144, §1º, CF, ou a Justiça Militar, quanto às infrações penais militares).\r
\r
POR QUE A ASSERTIVA III ESTÁ INCORRETA:\r
O art. 144, §5º-A, da Constituição Federal (incluído pela EC nº 104/2019) dispõe: "Às polícias penais, vinculadas ao órgão administrador do sistema penal da unidade federativa a que pertencem, cabe a segurança dos estabelecimentos penais." A Constituição atribui às polícias penais apenas a SEGURANÇA dos estabelecimentos penais — não a sua ADMINISTRAÇÃO, que é função do órgão administrador do sistema penal, ao qual as polícias penais são vinculadas, mas com o qual não se confundem. A assertiva III erra exatamente ao acrescentar a "administração" dos estabelecimentos penais como atribuição constitucional das polícias penais.\r
Quanto à subordinação, a assertiva III está correta nesse ponto específico: o art. 144, §6º, da CF (na redação dada pela EC nº 104/2019) estabelece que as polícias militares e os corpos de bombeiros militares, forças auxiliares e reserva do Exército, subordinam-se, juntamente com as polícias civis e as polícias penais estaduais e distrital, aos Governadores dos Estados, do Distrito Federal e dos Territórios — logo, as polícias penais estaduais e distrital realmente se subordinam aos Governadores. O vício da assertiva III está isolado no acréscimo indevido da palavra "administração" às atribuições de segurança dos estabelecimentos penais.\r
\r
BIZU DE PROVA:\r
Guardas Municipais — jurisprudência do STF:\r
- ADPF 995/DF (Min. Alexandre de Moraes, 2023): Guardas Municipais integram o SUSP;\r
- Tema 656 / RE 608.588 (Min. Luiz Fux, mérito 2025): podem exercer policiamento ostensivo e comunitário, vedada polícia judiciária.\r
Polícias Penais (Art. 144, §5º-A e §6º, CF - EC 104/2019):\r
- Subordinação: aos Governadores dos Estados/DF (§6º) — correto;\r
- Atribuição constitucional: SEGURANÇA dos estabelecimentos penais (§5º-A) — a Constituição NÃO fala em "administração"!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2T-A — SEGURANÇA PÚBLICA / DIREITO ADMINISTRATIVO / ATOS ADMINISTRATIVOS
-- Correção de explicações contaminadas (267, 268, 675) e de erro jurisprudencial (743)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
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
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (4 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_267)} WHERE id = 267;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_268)} WHERE id = 268;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_675)} WHERE id = 675;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_743)} WHERE id = 743;

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
${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão ${id} (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;`).join('\n')}

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

${mode === 'rollback' ? 'ROLLBACK;' : 'COMMIT;'}`;
}

const harnessSql = body('rollback');
const applySql = body('apply');

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Arquivos gerados com sucesso:`);
console.log(` - ${HARNESS_OUT_PATH}`);
console.log(` - ${APPLY_OUT_PATH}`);
