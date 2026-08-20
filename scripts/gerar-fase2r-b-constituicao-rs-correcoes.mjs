#!/usr/bin/env node
// Fase 2R-B — Constituição do Estado do Rio Grande do Sul (719, 720):
// Reescrita de explicação contaminada, com fundamento confirmado contra o texto oficial
// primário (PDF consolidado IRGA-RS, atualizado até EC nº 78/2020, mais confirmação da
// EC nº 82/2022 que incluiu a Polícia Penal). Somente o campo `explicacao` é alterado —
// enunciado, alternativas, gabarito e status `ativa` permanecem intocados.
//
// Escopo:
//   - id 719: explicação reescrita com fundamento nos Arts. 124 (caput), 125 (parágrafo
//             único), 127 (caput e parágrafo único), CE/RS. Registra nota explícita de que
//             "Coordenadoria-Geral de Perícias" é a denominação histórica (até 1997) e que a
//             instituição atual se chama Instituto-Geral de Perícias (EC nº 19/1997), sem
//             alterar o gabarito (as 4 assertivas continuam corretas em conteúdo/quantidade/
//             ordem dos órgãos). Gabarito E (ordem 5) preservado.
//   - id 720: explicação reescrita com fundamento nos Arts. 133 (caput e parágrafo único) e
//             134 (parágrafo único), CE/RS. Confirma I e IV verdadeiras; II falsa porque a
//             Corregedoria-Geral de Polícia não tem nenhuma previsão constitucional (só a
//             Academia de Polícia Civil tem assento no art. 134, §único); III falsa porque não
//             há, em nenhum dispositivo da Constituição Estadual, previsão de foro/processamento
//             por crime de responsabilidade do chefe de polícia. Gabarito B (ordem 2) preservado.
//
// Fora deste lote: 355, 356 e 718 (355/356 fechados na Fase 2R-A; 718 tratado em script hotfix
// separado, gerar-fase2r-a-hotfix-718-correcoes.mjs).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2r-b_constituicao_rs_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2r-b_constituicao_rs_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração.
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  719: 'dcd2767f6bada337dca36026ad8ecab3',
  720: '46ef4e68285d6331d09d12025b370c9f',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  719: 'f4f57bfa8d7bc02b6d81f10c3a969624',
  720: '8579e20ba0b1d9cef98980209e98ce63',
};

// Ordem da alternativa correta (gabarito) de cada questão do lote — inalterado nesta fase
const GABARITO = { 719: 5, 720: 2 };

// --------------------------------------------------------------------------
// Textos novos das explicações
// --------------------------------------------------------------------------

const EXPLICACAO_NOVA_719 = `GABARITO: alternativa E\r
\r
POR QUE A ALTERNATIVA E ESTÁ CORRETA:\r
Todas as assertivas I, II, III e IV estão corretas, fundamentadas nos seguintes dispositivos da Constituição do Estado do Rio Grande do Sul:\r
\r
- I. (Correta): O Artigo 124, caput, dispõe que "a segurança pública, dever do Estado, direito e responsabilidade de todos, é exercida para a preservação da ordem pública, das prerrogativas da cidadania, da incolumidade das pessoas e do patrimônio", através de 5 órgãos: Brigada Militar, Polícia Civil, Instituto-Geral de Perícias, Corpo de Bombeiros Militar e Polícia Penal (este último incluído pela Emenda Constitucional nº 82, de 10/08/2022). NOTA: a denominação "Coordenadoria-Geral de Perícias", usada pela assertiva, é a designação HISTÓRICA do órgão, vigente até 1997; desde a Emenda Constitucional nº 19, de 16/07/1997, a instituição chama-se INSTITUTO-GERAL DE PERÍCIAS (IGP-RS). A quantidade e a ordem dos órgãos citados pela assertiva correspondem exatamente ao texto vigente do art. 124; apenas o nome do terceiro órgão está desatualizado.\r
\r
- II. (Correta): O Artigo 127, caput, garante ao "policial civil ou militar, o bombeiro militar, e os integrantes dos quadros dos servidores penitenciários e do Instituto-Geral de Perícias, quando feridos em serviço", direito ao "custeio integral, pelo Estado, das despesas médicas, hospitalares e de reabilitação para o exercício de atividades que lhes garantam a subsistência" — os policiais civis mencionados na assertiva estão abrangidos por esse dispositivo.\r
\r
- III. (Correta): O Artigo 127, parágrafo único, prevê que "Lei Complementar disporá sobre a promoção extraordinária do servidor integrante dos quadros da Polícia Civil, do Instituto-Geral de Perícias e dos serviços penitenciários que morrer ou ficar permanentemente inválido em virtude de lesão sofrida em serviço, bem como, na mesma situação, praticar ato de bravura" — texto praticamente idêntico ao da assertiva.\r
\r
- IV. (Correta): O Artigo 125, parágrafo único, dispõe expressamente que "o Estado só poderá operar serviços de informações que se refiram exclusivamente ao que a lei defina como delinquência" — texto idêntico ao da assertiva.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
Incompleta ("Apenas I e II") — as assertivas III e IV também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Incompleta ("Apenas I e IV") — as assertivas II e III também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Incompleta ("Apenas II e III") — as assertivas I e IV também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Incompleta ("Apenas II, III e IV") — a assertiva I também é verdadeira.\r
\r
BIZU DE PROVA:\r
Segurança Pública na Constituição Estadual do RS:\r
Art. 124 (5 órgãos, incluindo o atual Instituto-Geral de Perícias) + Art. 125, §único (serviços de informação restritos à delinquência) + Art. 127 (custeio médico integral e promoção extraordinária por morte/invalidez/ato de bravura)!`;

const EXPLICACAO_NOVA_720 = `GABARITO: alternativa B\r
\r
POR QUE A ALTERNATIVA B ESTÁ CORRETA:\r
Estão corretas apenas as assertivas I e IV:\r
\r
- I. (Correta): O Artigo 133, parágrafo único, da Constituição do Estado do Rio Grande do Sul dispõe: "São autoridades policiais os Delegados de Polícia de carreira, cargos privativos de bacharéis em Direito." — texto idêntico ao da assertiva.\r
\r
- II. (Incorreta): O único órgão da Polícia Civil com assento expresso na Constituição Estadual é a Academia de Polícia Civil (Artigo 134, parágrafo único: "O recrutamento, a seleção, a formação, o aperfeiçoamento e a especialização do pessoal da Polícia Civil competem à Academia de Polícia Civil"). A "Corregedoria-Geral de Polícia" NÃO possui nenhuma previsão constitucional — não consta em nenhum dispositivo do capítulo da segurança pública nem da Polícia Civil (arts. 124 a 139 da CE/RS). A assertiva erra ao afirmar que são dois os órgãos com assento constitucional e ao atribuir competência de controle interno a um órgão sem previsão na Constituição Estadual.\r
\r
- III. (Incorreta): Não há, na Constituição do Estado do Rio Grande do Sul, nenhum dispositivo que trate de foro ou processamento por crime de responsabilidade do chefe de polícia — nem no capítulo da segurança pública, nem em qualquer outro título. As únicas hipóteses de crime de responsabilidade previstas na Constituição Estadual dizem respeito ao Governador, Vice-Governador e Secretários de Estado, e ao Procurador-Geral do Estado, Procurador-Geral de Justiça e Titular da Defensoria Pública — não ao chefe de polícia. A afirmação de que existiu previsão de foro no Tribunal de Justiça posteriormente declarada inconstitucional pelo STF não encontra correspondência no texto constitucional vigente.\r
\r
- IV. (Correta): O Artigo 133, caput, dispõe: "À Polícia Civil, dirigida pelo Chefe de Polícia, delegado de carreira da mais elevada classe, de livre escolha, nomeação e exoneração pelo Governador do Estado, incumbem, ressalvada a competência da União, as funções de polícia judiciária e a apuração das infrações penais, exceto as militares." — texto idêntico ao da assertiva.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
"Apenas I e II" inclui a assertiva II, que é falsa.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
"Apenas III e IV" inclui a assertiva III, que é falsa.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
"Apenas I, II e IV" inclui a assertiva II, que é falsa.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
"I, II, III e IV" inclui as assertivas II e III, ambas falsas.\r
\r
BIZU DE PROVA:\r
Polícia Civil na Constituição Estadual do RS (Arts. 133 e 134):\r
Chefe de Polícia = delegado de carreira da mais elevada classe, livre nomeação/exoneração pelo Governador (Art. 133, caput);\r
Delegados de carreira = privativos de bacharéis em Direito (Art. 133, §único);\r
Único órgão com assento constitucional = Academia de Polícia Civil (Art. 134, §único) — NÃO existe Corregedoria-Geral nem foro do chefe de polícia na Constituição Estadual!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2R-B — CONSTITUIÇÃO DO ESTADO DO RIO GRANDE DO SUL (719, 720)
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

  -- Validação dos hashes pré-apply das 2 questões do lote
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (2 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  -- ID 719: reescrita da explicação (Arts. 124, 125 §único, 127 caput e §único, CE/RS)
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_719)},
         atualizado_em = now()
   WHERE id = 719;

  -- ID 720: reescrita da explicação (Arts. 133 caput/§único, 134 §único, CE/RS)
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_720)},
         atualizado_em = now()
   WHERE id = 720;

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
  IF (SELECT count(*) FROM public.questoes WHERE id IN (719, 720) AND ativa = true) <> 2 THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa alterado indevidamente em alguma questão do lote';
  END IF;

  -- Assert 3: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 3 falhou: hash da questão ${id} (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;`).join('\n')}

  -- Assert 4: Exatamente 1 alternativa correta por questão, 5 alternativas presentes, gabarito preservado
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (719, 720)) <> 2 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id IN (719, 720)) <> 10 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (719, 720)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativas divergentes do estado esperado (5 por questão, exatamente 1 correta)';
  END IF;

${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4b falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Questão 719 - explicação fundamentada nos Arts. 124/125/127 CE/RS, com nota sobre
  -- a denominação histórica, e sem resíduo do Art. 37-41 CF (servidor público genérico)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 719;
  IF v_explicacao_check NOT ILIKE '%Artigo 124, caput%' OR
     v_explicacao_check NOT ILIKE '%Artigo 125, parágrafo único%' OR
     v_explicacao_check NOT ILIKE '%Artigo 127, caput%' OR
     v_explicacao_check NOT ILIKE '%Artigo 127, parágrafo único%' OR
     v_explicacao_check NOT ILIKE '%Instituto-Geral de Perícias%' OR
     v_explicacao_check NOT ILIKE '%designação HISTÓRICA%' OR
     v_explicacao_check ILIKE '%Art. 41%' OR
     v_explicacao_check ILIKE '%avaliação especial de desempenho%' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão 719 incorreta ou ainda contendo resíduo de servidor público genérico (Art. 37-41 CF)';
  END IF;

  -- Assert 6: Questão 720 - explicação fundamentada nos Arts. 133/134 CE/RS, confirmando
  -- ausência de Corregedoria-Geral e de foro do chefe de polícia, sem resíduo do Art. 37 CF
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 720;
  IF v_explicacao_check NOT ILIKE '%Artigo 133, parágrafo único%' OR
     v_explicacao_check NOT ILIKE '%Artigo 133, caput%' OR
     v_explicacao_check NOT ILIKE '%Artigo 134, parágrafo único%' OR
     v_explicacao_check NOT ILIKE '%NÃO possui nenhuma previsão constitucional%' OR
     v_explicacao_check ILIKE '%concurso público de provas ou de provas e títulos%' OR
     v_explicacao_check ILIKE '%Art. 48, X%' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 720 incorreta ou ainda contendo resíduo do Art. 37 CF genérico';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2R-B (CONSTITUIÇÃO DO ESTADO DO RS — 719 E 720) PASSARAM COM SUCESSO!';
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
