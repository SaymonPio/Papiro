#!/usr/bin/env node
// Fase 2R-A — Constituição do Estado do Rio Grande do Sul (lote parcial):
// Correções de explicação contaminada (355, 356, 718) e higiene de OCR/formatação/lixo de
// importação (355, 356, 718). Nenhum gabarito é alterado.
//
// Escopo desta Fase 2R-A (3 de 14 questões do assunto "Constituição do Estado do RS"):
//   - id 355: Formatação do enunciado (quebras de linha literais, "art. 2 º" -> "art. 2º",
//             "plesbicito" -> "plebiscito") + remoção de lixo de importação colado na alternativa
//             5 ("LEGISLAÇÃO ESPECÍFICA") + reescrita da explicação (Estatuto Militar RS/LC 10.990/97,
//             tema totalmente alheio -> Art. 2º da CE/RS, soberania popular, confirmado contra
//             fonte oficial). Gabarito A preservado.
//   - id 356: Formatação do enunciado (quebras de linha literais, "diretam ente" -> "diretamente")
//             + reescrita da explicação (Art. 37 CF genérico, alheio ao enunciado -> Art. 19,
//             §§1º, 2º e 3º [EC 79/2020], CE/RS, confirmado literalmente). Gabarito A preservado.
//   - id 718: Higiene de OCR no enunciado (falta de espaço após pontuação: ":I.", ".II.", ".III.",
//             "lei.Quais") + reescrita da explicação (Art. 40 CF/aposentadoria, tema totalmente
//             alheio -> Art. 124, caput, e Art. 129, CE/RS, confirmados). Gabarito C preservado.
//
// Fora deste lote (pendências jurídicas não fechadas, tratamento em fase própria):
//   - id 719: assertiva IV (serviços de informação/delinquência) sem confirmação de fonte oficial.
//   - id 720: assertivas I, II e III sem confirmação de fonte oficial (números de artigo
//             conflitantes entre fontes secundárias consultadas).
//
// 11 questões restantes do universo de 14 (39, 52, 295, 357, 359, 719, 720, 795, 842, 843, 844)
// não fazem parte deste lote.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2r-a_constituicao_rs_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2r-a_constituicao_rs_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração.
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  355: '8497769a34c4da1400cfba519d721c5e',
  356: 'c71992223466f093653db6b08c1c037a',
  718: '8fb6f29ee8eaf833ad3eb7752f8ca943',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  355: 'd84b5b128ed5ad4608039de21c822e5e',
  356: 'd2234fbe49b6146d8eff8583f2bae66e',
  718: '4847f118b7cc51743ed36379c94f8367',
};

// Ordem da alternativa correta (gabarito) de cada questão do lote
const GABARITO = { 355: 1, 356: 1, 718: 3 };

// Hashes de referência das questões 719 e 720 (fora do lote, pendências jurídicas não fechadas).
// Usados exclusivamente nos asserts de guarda para provar que este script não as toca.
const HASH_ENUNCIADO_719 = 'e9e944deae7ca8115c0a64f469a6a2e2';
const HASH_EXPLICACAO_719 = 'b18ebeb0ed41bee253489aa0ba3ff238';
const HASH_ENUNCIADO_720 = '06bb8e2e50c5a644542c6b75f4de7650';
const HASH_EXPLICACAO_720 = '95c991434a6cb32dc82c3c4662a15a5a';

// --------------------------------------------------------------------------
// Textos novos
// --------------------------------------------------------------------------

const ENUNCIADO_NOVO_355 = "Conforme o art. 2º da Constituição do Estado do Rio Grande do Sul, analise as assertivas abaixo e assinale a alternativa correta. I. A soberania popular será exercida por sufrágio universal. II. A população terá direito a voto direto e secreto, com igual valor para todos. III. A soberania popular pode ser exercida de três formas: iniciativa popular, referendo e plebiscito.";

const ALT_NOVA_355_ORDEM5 = "Apenas as assertivas II e III estão corretas.";

const EXPLICACAO_NOVA_355 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
O Artigo 2º da Constituição do Estado do Rio Grande do Sul dispõe: "A soberania popular será exercida por sufrágio universal e pelo voto direto e secreto, com igual valor para todos e, nos termos da lei, mediante: I - plebiscito; II - referendo; III - iniciativa popular." As três assertivas reproduzem corretamente esse dispositivo:\r
- I. (Correta): "Sufrágio universal" reproduz o trecho inicial do caput.\r
- II. (Correta): "Voto direto e secreto, com igual valor para todos" reproduz o trecho seguinte do caput.\r
- III. (Correta): A soberania popular é exercida por três formas — plebiscito, referendo e iniciativa popular —, correspondendo aos incisos I, II e III do artigo, ainda que listadas em ordem diferente da constitucional.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
As três assertivas reproduzem corretamente o texto do art. 2º da Constituição Estadual.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Incompleta, pois as assertivas II e III também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Incompleta, pois a assertiva III também é verdadeira.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Incompleta, pois a assertiva I também é verdadeira.\r
\r
BIZU DE PROVA:\r
Soberania Popular (Art. 2º da Constituição Estadual do RS):\r
Exercida por sufrágio universal e voto direto e secreto, e mediante três formas: PLEBISCITO, REFERENDO e INICIATIVA POPULAR!`;

const ENUNCIADO_NOVO_356 = "Considerando o disposto na Constituição do Estado do Rio Grande do Sul, analise as assertivas abaixo e assinale a alternativa correta. I. A publicidade dos atos, programas, obras e serviços, e as campanhas dos órgãos e entidades da administração pública, ainda que não custeadas diretamente por esta, deverão ter caráter educativo, informativo ou de orientação social, nelas não podendo constar símbolos, expressões, nomes, “slogans” ideológicos político-partidários ou imagens que caracterizem promoção pessoal de autoridade ou de servidores públicos. II. Cabe à administração pública, na forma da lei, gerenciar a documentação governamental, desenvolver plataformas digitais e adotar as providências para franquear sua consulta a quem dela necessite, bem como realizar os procedimentos administrativos com ampla transparência. III. A ação político-administrativa do Estado será acompanhada e avaliada, através de mecanismos estáveis, por Conselhos Populares, na forma da lei.";

const EXPLICACAO_NOVA_356 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
Todas as assertivas I, II e III estão em conformidade com o Artigo 19 da Constituição do Estado do Rio Grande do Sul:\r
- I. (Correta - Art. 19, §1º): a publicidade de atos, programas e campanhas públicas deve ter caráter educativo, informativo ou de orientação social, vedada a promoção pessoal de autoridade ou servidor.\r
- II. (Correta - Art. 19, §3º, incluído pela Emenda Constitucional nº 79/2020): "Cabe à administração pública, na forma da lei, gerenciar a documentação governamental, desenvolver plataformas digitais e adotar as providências para franquear sua consulta a quem dela necessite, bem como realizar os procedimentos administrativos com ampla transparência."\r
- III. (Correta - Art. 19, §2º): "A ação político-administrativa do Estado será acompanhada e avaliada, através de mecanismos estáveis, por Conselhos Populares, na forma da lei."\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
As três assertivas são plenamente verdadeiras.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
Incompleta, pois II e III também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Incompleta, pois III também é verdadeira.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Incompleta, pois I também é verdadeira.\r
\r
BIZU DE PROVA:\r
Art. 19 da Constituição Estadual do RS:\r
§1º - Publicidade sem promoção pessoal;\r
§2º - Conselhos Populares acompanham a ação político-administrativa;\r
§3º (EC 79/2020) - Gestão documental, plataformas digitais e transparência administrativa!`;

const ENUNCIADO_NOVO_718 = "Conforme a Constituição do Estado do Rio Grande do Sul, no que se refere à segurança pública, analise as assertivas abaixo: I. A Coordenadoria-Geral de Perícias é um órgão da segurança pública. II. A lei disciplinará a organização e o funcionamento dos órgãos responsáveis pela segurança pública, de maneira a assegurar-lhes a eficiência das atividades. III. Os Municípios deverão, obrigatoriamente, constituir guardas municipais destinadas à proteção de seus bens, serviços e instalações, conforme dispuser a lei. Quais estão corretas?";

const EXPLICACAO_NOVA_718 = `GABARITO: alternativa C\r
\r
POR QUE A ALTERNATIVA C ESTÁ CORRETA:\r
Estão corretas apenas as assertivas I e II:\r
- I. (Correta): O Artigo 124, caput, da Constituição do Estado do Rio Grande do Sul dispõe: "A segurança pública, dever do Estado, direito e responsabilidade de todos, é exercida para a preservação da ordem pública, das prerrogativas da cidadania, da incolumidade das pessoas e do patrimônio, através da Brigada Militar, da Polícia Civil, da Coordenadoria-Geral de Perícias, do Corpo de Bombeiros Militar e da Polícia Penal." A Coordenadoria-Geral de Perícias está expressamente listada como órgão de segurança pública.\r
- II. (Correta): A organização e o funcionamento dos órgãos de segurança pública são disciplinados por lei, nos termos do mesmo capítulo constitucional.\r
- III. (Incorreta): O Artigo 129 da Constituição Estadual dispõe que "os Municípios PODERÃO constituir guardas municipais destinadas à proteção de seus bens, serviços e instalações, conforme dispuser a lei" — trata-se de faculdade dos Municípios, e não de obrigação, ao contrário do que afirma a assertiva.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
Incompleta, pois a assertiva II também é verdadeira.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Incompleta, pois a assertiva I também é verdadeira.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
A assertiva III é falsa, pois a criação de guardas municipais é facultativa ("poderão"), não obrigatória.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A assertiva III é falsa pelo mesmo motivo.\r
\r
BIZU DE PROVA:\r
Segurança Pública na Constituição Estadual do RS (Art. 124, caput):\r
5 órgãos: Brigada Militar, Polícia Civil, Coordenadoria-Geral de Perícias, Corpo de Bombeiros Militar e Polícia Penal!\r
Guardas Municipais (Art. 129): facultativas — "PODERÃO" constituir, nunca "deverão"!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2R-A — CONSTITUIÇÃO DO ESTADO DO RIO GRANDE DO SUL (LOTE PARCIAL: 355, 356, 718)
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

  -- Validação dos hashes pré-apply das 3 questões do lote (ids 719 e 720 excluídos)
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (3 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 355: formatação do enunciado + remoção de lixo na alternativa 5 + reescrita da explicação (Estatuto Militar RS -> Art. 2º CE/RS)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_355)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_355)},
         atualizado_em = now()
   WHERE id = 355;
  UPDATE public.alternativas
     SET texto = ${sqlStr(ALT_NOVA_355_ORDEM5)}
   WHERE id = 1756 AND questao_id = 355;

  -- ID 356: formatação do enunciado + reescrita da explicação (Art. 37 CF genérico -> Art. 19 CE/RS)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_356)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_356)},
         atualizado_em = now()
   WHERE id = 356;

  -- ID 718: higiene de OCR no enunciado + reescrita da explicação (Art. 40 CF/aposentadoria -> Art. 124 e 129 CE/RS)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_718)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_718)},
         atualizado_em = now()
   WHERE id = 718;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados (nenhuma ativação/desativação nesta Fase 2R-A)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (as 3 questões continuam ativa = true)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (355, 356, 718) AND ativa = true) <> 3 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões do lote da Fase 2R-A tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão e presença das 3 questões
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (355, 356, 718)) <> 3 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (355, 356, 718)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões do lote não possuem exatamente 1 alternativa correta ou estão ausentes no conjunto de alternativas';
  END IF;

  -- Assert 4: Gabaritos oficiais preservados em cada uma das 3 questões
${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Ausência de resíduos de formatação/OCR/lixo de importação nos enunciados tratados
  IF (SELECT count(*) FROM public.questoes WHERE id IN (355, 356, 718) AND (
        position(E'\\n' in enunciado) > 0 OR
        enunciado LIKE '%art. 2 º%' OR
        enunciado LIKE '%plesbicito%' OR
        enunciado LIKE '%diretam ente%' OR
        enunciado LIKE '%abaixo:I.%' OR
        enunciado LIKE '%pública.II.%' OR
        enunciado LIKE '%atividades.III.%' OR
        enunciado LIKE '%lei.Quais%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 5 falhou: resíduos de formatação/OCR ainda detectados em algum enunciado do lote';
  END IF;

  -- Assert 6: Ausência do lixo de importação na alternativa 5 da questão 355
  SELECT texto INTO v_alt_check FROM public.alternativas WHERE id = 1756 AND questao_id = 355;
  IF v_alt_check ILIKE '%LEGISLAÇÃO ESPECÍFICA%' OR position(E'\\n' in v_alt_check) > 0 THEN
    RAISE EXCEPTION 'Assert 6 falhou: lixo de importação ainda presente na alternativa 5 da questão 355';
  END IF;

  -- Assert 7: Questão 355 - explicação fundamentada no Art. 2º CE/RS e sem resíduo do Estatuto Militar
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 355;
  IF v_explicacao_check NOT ILIKE '%Artigo 2º%' OR
     v_explicacao_check ILIKE '%Estatuto dos Militares%' OR
     v_explicacao_check ILIKE '%LC Estadual nº 10.990%' OR
     v_explicacao_check ILIKE '%cabos e soldados%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 355 incorreta ou ainda contendo resíduo do Estatuto Militar';
  END IF;

  -- Assert 8: Questão 356 - explicação fundamentada no Art. 19 CE/RS e sem resíduo do Art. 37 CF genérico
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 356;
  IF v_explicacao_check NOT ILIKE '%Artigo 19%' OR
     v_explicacao_check ILIKE '%improbidade administrativa%' OR
     v_explicacao_check ILIKE '%Art. 37, II)%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: explicação da questão 356 incorreta ou ainda contendo resíduo do Art. 37 CF genérico';
  END IF;

  -- Assert 9: Questão 718 - explicação fundamentada nos Arts. 124 e 129 CE/RS e sem resíduo do Art. 40 CF/aposentadoria
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 718;
  IF v_explicacao_check NOT ILIKE '%Artigo 124, caput%' OR
     v_explicacao_check NOT ILIKE '%Artigo 129%' OR
     v_explicacao_check ILIKE '%aposentadoria%' OR
     v_explicacao_check ILIKE '%Artigo 40%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 718 incorreta ou ainda contendo resíduo do Art. 40 CF/aposentadoria';
  END IF;

  -- Assert 10: Questões 719 e 720 (fora do lote, pendências jurídicas não fechadas) permanecem absolutamente intocadas
  IF (SELECT md5(enunciado) FROM public.questoes WHERE id = 719) <> '${HASH_ENUNCIADO_719}' THEN
    RAISE EXCEPTION 'Assert 10a falhou: enunciado da questão 719 (fora do lote) foi modificado indevidamente';
  END IF;
  IF (SELECT md5(explicacao) FROM public.questoes WHERE id = 719) <> '${HASH_EXPLICACAO_719}' THEN
    RAISE EXCEPTION 'Assert 10b falhou: explicação da questão 719 (fora do lote) foi modificada indevidamente';
  END IF;
  IF (SELECT md5(enunciado) FROM public.questoes WHERE id = 720) <> '${HASH_ENUNCIADO_720}' THEN
    RAISE EXCEPTION 'Assert 10c falhou: enunciado da questão 720 (fora do lote) foi modificado indevidamente';
  END IF;
  IF (SELECT md5(explicacao) FROM public.questoes WHERE id = 720) <> '${HASH_EXPLICACAO_720}' THEN
    RAISE EXCEPTION 'Assert 10d falhou: explicação da questão 720 (fora do lote) foi modificada indevidamente';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2R-A (CONSTITUIÇÃO DO ESTADO DO RS — LOTE PARCIAL) PASSARAM COM SUCESSO!';
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
