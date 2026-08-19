#!/usr/bin/env node
// Fase 2O — Legislação Militar Estadual / Brigada Militar do Rio Grande do Sul:
// Correções de explicação técnica / descarte de contaminações alienígenas (210, 211, 212, 363, 364, 369)
// e saneamento de OCR / expurgo de cabeçalho estranho (362, 363, 364, 368, 369, 370).
//
// Universo auditado: 22 questões únicas (13 intocadas + 9 tratadas).
// Escopo do lote de alteração (9 questões):
//   - id 210: Nova explicação (Regulamento Disciplinar da BM / Dec. nº 43.245/2004). Enunciado e alternativas intocados. Gabarito A preservado.
//   - id 211: Nova explicação (Regulamento Disciplinar da BM / Dec. nº 43.245/2004). Enunciado e alternativas intocados. Gabarito A preservado.
//   - id 212: Nova explicação (Hierarquia e disciplina militar / Dec. nº 43.245/2004). Enunciado e alternativas intocados. Gabarito A preservado.
//   - id 362: Higiene de OCR no enunciado e na alternativa D (1790). Explicação preservada byte a byte. Gabarito D preservado.
//   - id 363: Nova explicação (arts. 39 e 40 da LC nº 10.990/1997) + higiene de OCR no enunciado. Alternativas intocadas. Gabarito D preservado.
//   - id 364: Nova explicação (arts. 2º, § 2º, 3º, §§ 1º e 2º, e 5º, §§ 1º e 2º da LC nº 10.992/1997) + expurgo de cabeçalho estranho na alt E (1801) e higiene de OCR comprovada no enunciado e alternativas A (1797), B (1798), C (1799), D (1800) e E (1801). Gabarito B preservado.
//   - id 368: Higiene de OCR comprovada nas alternativas A (1817), B (1818), C (1819), D (1820: quebra e "policial-militar") e E (1821). Enunciado e explicação preservados byte a byte. Gabarito A preservado.
//   - id 369: Nova explicação (art. 14 e dispositivos efetivamente necessários às alternativas - arts. 14, 15, 16, 17, 19 e 20 do Dec. nº 43.245/2004) + higiene de OCR nas alternativas A (1822), B (1823), C (1824), D (1825) e E (1826). Enunciado preservado byte a byte. Gabarito D preservado.
//   - id 370: Higiene de OCR restrita comprovadamente ao enunciado e às alternativas B (1828) e C (1829). Explicação e alternativas A (1827), D (1830) e E (1831) preservadas byte a byte. Gabarito C preservado.
//
// 13 questões intocadas:
//   - ids: 12, 20, 39, 43, 45, 53, 201, 202, 203, 271, 272, 300, 303.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2o_legislacao_militar_rs_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2o_legislacao_militar_rs_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes capturados ao vivo do banco de produção antes desta migração (22 questões):
const HASH_QUESTAO_ANTES = {
  12: '1125999709e4c7ca3fbcbd0c78427c25',
  20: '7b2bacd77c0676060f7d9bd8672292e6',
  39: 'd432476f6cb761a6da51fb7992347c17',
  43: '7d4e5653ee3fc34f266d394d4967109c',
  45: '8385aff2580e403e5004bbf5adc8081e',
  53: '7cfec26d75547fcfb22e1b72dafbe95b',
  201: '28b0381fc245b69cbe167e988756afa9',
  202: '188e21474208d249e43fd26fd9d50f11',
  203: '7250b451fca89cd0abd4139d3d5ee0d1',
  210: '1b295f6fe4707428094c13aeb7974282',
  211: '559cad60c6aec54a2dae205e62ee2449',
  212: 'a3c8936d7dd227a9c1c474fd8c115bec',
  271: '3572c57489c5934e090d4a363f422637',
  272: '8ccef36b7dab6e9db0b9ee4f09d8d06c',
  300: '2255b733ff61e542e3c1ec64bc40b720',
  303: '393757b3158871d440336c8ff2dc6470',
  362: '10f245ccf93cf1032fc8562013cf3104',
  363: '00e8f8fe08cc318e4d163798cecfbba2',
  364: 'f11bb6df86557538d09b6a3e56c412b3',
  368: '1ea6df46d0176db8aa1acbe0c184d90f',
  369: 'd7f185ecbb40dc980120b53773c92ccf',
  370: '96e172a42233c5748bd5bd71261af9bd',
};

const HASH_EXPLICACAO_ANTES = {
  12: '309f4c2b9ab2878ff946b8068d332953',
  20: '034039705c5f86fc8117beb1240e92d2',
  39: '3de56d47dea4b06e8efa1bc84d086e16',
  43: '34558e7ce2d01e5d29393e374fa7d26c',
  45: '1639152f38fe4767580ec275b6209ae1',
  53: 'e49731ef3a50bb5c9c8920b5ab3048c7',
  201: 'f893d7f3bcec107f3a2207e084aa36fd',
  202: '01cfb5cd2470430e2586271e4484c367',
  203: 'f213fe51737a53bad359017bc0fa30c8',
  210: 'e969481c4a982f7bfe911d95b7f9dc91',
  211: 'ec3f3c81253fe64f6fcc8094d2573c83',
  212: '307d0d8a107413dd8bf1ecd176a67d07',
  271: 'c67a830b6c0685021688bd8280793275',
  272: '665194766dbb81a46741d841efa5683b',
  300: '6c6673763ab1e621834b064e2c0cca2c',
  303: '87d0d92f7cc36be93aab3997e25be25d',
  362: '030b8ccfea6e4fe2ffebcccaa1289725',
  363: 'f73cd7882133c20d32b8284f37aea362',
  364: '686a5cc72cecba7ba6e12a19f63135c5',
  368: '2ebcbeeb01314fa38d85f4f3aafca89c',
  369: '8a4847657e3ae08afdf022ce2eb304e1',
  370: 'd00058a27a7c6a35f74cdb276dd6cc4e',
};

// Textos novos / higienizados:
const EXPLICACAO_NOVA_210 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
O Regulamento Disciplinar da Brigada Militar do Estado do Rio Grande do Sul (aprovado pelo Decreto Estadual nº 43.245/2004) tem por finalidade central especificar as transgressões disciplinares, regular a aplicação das sanções disciplinares, estabelecer os recursos cabíveis e definir o processo administrativo disciplinar aplicável aos servidores militares estaduais, com o objetivo de preservar os pilares da hierarquia e da disciplina na corporação.\r
\r
POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:\r
- B: Matéria tributária federal é regida pelo Código Tributário Nacional e pela Constituição Federal.\r
- C: A matéria eleitoral é privativa da União (Código Eleitoral).\r
- D: A criação de crimes e cominação de penas é competência privativa da União (Código Penal e Código Penal Militar).\r
- E: Contratos de direito privado são regidos pelo Código Civil.\r
\r
BIZU DE PROVA:\r
Finalidade do Regulamento Disciplinar da BM (Decreto nº 43.245/2004):\r
Definir deveres, tipificar transgressões disciplinares, regular sanções administrativas e estabelecer os procedimentos disciplinares militares estaduais!`;

const EXPLICACAO_NOVA_211 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
A aplicação de qualquer sanção disciplinar militar aos servidores da Brigada Militar e do Corpo de Bombeiros Militar do RS subordina-se estritamente ao princípio da legalidade, ao devido processo legal, ao contraditório e à ampla defesa, devendo observar rigorosamente os princípios, ritos e critérios dosimétricos fixados na Constituição Federal (Art. 5º, LV), no Estatuto dos Militares Estaduais (LC nº 10.990/1997) e no Regulamento Disciplinar da Brigada Militar (Decreto Estadual nº 43.245/2004).\r
\r
POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:\r
- B: O poder disciplinar é vinculado e regrado pela lei e pelo regulamento, sendo vedado o arbítrio fundado em vontade pessoal.\r
- C: O direito à ampla defesa e ao contraditório é garantia constitucional inafastável no processo disciplinar.\r
- D: O direito administrativo disciplinar militar rege-se pelo princípio da legalidade estrita, não por meros costumes informais.\r
- E: A apuração disciplinar militar é técnica, impessoal e orientada pela verdade real dos fatos apurados.\r
\r
BIZU DE PROVA:\r
Processo Disciplinar Militar (Decreto nº 43.245/2004):\r
A aplicação de sanções exige observância do DEVIDO PROCESSO LEGAL, contraditório, ampla defesa, proporcionalidade e legalidade estrita!`;

const EXPLICACAO_NOVA_212 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
Nos termos do Artigo 42 c/c Artigo 142 da Constituição Federal, do Artigo 11 da Lei Complementar Estadual nº 10.990/1997 e do Regulamento Disciplinar da Brigada Militar (Decreto Estadual nº 43.245/2004), a HIERARQUIA e a DISCIPLINA constituem as bases institucionais permanentes da organização militar estadual, crescendo a autoridade e a responsabilidade com a elevação do grau hierárquico.\r
\r
POR QUE AS ALTERNATIVAS B, C, D E E ESTÃO INCORRETAS:\r
- B: Possuem máxima relevância e cogência jurídica, estruturando toda a corporação militar e o dever de obediência.\r
- C: São princípios fundamentais de direito público institucional militar.\r
- D e E: Não se confundem com regras eleitorais ou tributárias.\r
\r
BIZU DE PROVA:\r
Pilares da Estrutura Militar (CF/88, LC 10.990/97 e Dec. 43.245/2004):\r
- HIERARQUIA: Ordenação progressiva da autoridade em postos (oficiais) e graduações (praças).\r
- DISCIPLINA: Rigorosa observância e acatamento integral das leis, ordens legais e regulamentos.`;

const ENUNCIADO_NOVO_362 = "De acordo com a Lei Complementar nº 10.990/1997 do Estado do Rio Grande do Sul, que trata do Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul, são direitos dos servidores militares, nos limites estabelecidos na legislação específica, EXCETO:";
const ALT_NOVAS_362 = {
  1790: "A assistência judiciária gratuita, em qualquer hipótese, quando processado em razão de atos praticados em objeto de serviço ou fora dele.",
};

const ENUNCIADO_NOVO_363 = "De acordo com o Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul, especificamente em relação à violação das obrigações e dos deveres, analise as assertivas abaixo:\n\nI. A violação das obrigações ou dos deveres policiais-militares constituirá crime, contravenção ou transgressão disciplinar, conforme dispuserem a legislação ou regulamentação específicas.\nII. A responsabilidade disciplinar é subordinada às responsabilidades civil e penal.\nIII. Não se caracteriza como violação das obrigações e dos deveres do servidor militar o inadimplemento de obrigações pecuniárias assumidas na vida privada.\nIV. A inobservância dos deveres especificados nas leis e regulamentos, ou a falta de exação no cumprimento dos mesmos, acarreta, para o servidor militar, responsabilidade funcional, pecuniária, disciplinar e penal, consoante legislação específica.\n\nQuais estão corretas?";
const EXPLICACAO_NOVA_363 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
Estão corretas as assertivas I, III e IV, nos termos expressos da Lei Complementar Estadual nº 10.990/1997 (Estatuto dos Militares Estaduais do RS):\r
\r
- Assertiva I (Correta): Reproduz textualmente o Artigo 39, caput: "A violação das obrigações ou dos deveres policiais-militares constituirá crime, contravenção ou transgressão disciplinar, conforme dispuserem a legislação ou regulamentação específicas."\r
- Assertiva II (Incorreta): O Artigo 40, § 1º prescreve que "a responsabilidade disciplinar é INDEPENDENTE das responsabilidades civil e penal", e não subordinada a elas.\r
- Assertiva III (Correta): Reproduz expressamente o Artigo 39, § 1º: "Não se caracteriza como violação das obrigações e dos deveres do servidor militar o inadimplemento de obrigações pecuniárias assumidas na vida privada."\r
- Assertiva IV (Correta): Reproduz a literalidade do Artigo 40, caput: "A inobservância dos deveres especificados nas leis e regulamentos, ou a falta de exação no cumprimento dos mesmos, acarreta, para o servidor militar, responsabilidade funcional, pecuniária, disciplinar e penal, consoante legislação específica."\r
\r
POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:\r
- A, C e E: Incluem incorretamente a assertiva II, que traz a falsa premissa de subordinação da responsabilidade disciplinar.\r
- B: Incompleta, pois omite a assertiva I, que também é juridicamente correta.\r
\r
BIZU DE PROVA:\r
Violação de Deveres Militares (LC nº 10.990/1997):\r
1. Esferas de Responsabilidade (Art. 40, §1º): A responsabilidade disciplinar é INDEPENDENTE das esferas civil e penal!\r
2. Dívidas Privadas (Art. 39, §1º): Inadimplemento de obrigação pecuniária civil privada NÃO configura falta funcional militar.`;

const ENUNCIADO_NOVO_364 = "Considere o disposto na Lei Complementar nº 10.992/1997, que dispõe sobre a carreira dos Servidores Militares do Estado do Rio Grande do Sul, e assinale a alternativa INCORRETA.";
const ALT_NOVAS_364 = {
  1797: "O ingresso no Curso Superior de Polícia Militar dar-se-á mediante concurso público de provas e títulos com exigência de diplomação no Curso de Ciências Jurídicas e Sociais.",
  1798: "A inclusão no quadro de acesso para a promoção ao posto de Coronel não poderá ser recusada pelo servidor.",
  1799: "Os aprovados no concurso público de provas e títulos para ingresso no Quadro de Oficiais da Estado Maior, enquanto estiverem frequentando o Curso Superior de Polícia Militar, cujo prazo de duração não excederá a dois anos, serão considerados Alunos-Oficiais.",
  1800: "Para a promoção ao posto de Major, o ocupante do posto de Capitão deverá ter prestado serviços em órgão de execução por um período, consecutivo ou não, de, no mínimo, três anos e ter concluído, com aprovação, o Curso Avançado de Administração Policial Militar (CAAPM).",
  1801: "O acesso à promoção ao posto de Coronel, pelo ocupante do posto de Tenente-Coronel, exige a conclusão, com aprovação, do Curso de Especialização em Políticas e Gestão de Segurança Pública (CEPGSP).",
};
const EXPLICACAO_NOVA_364 = `GABARITO: alternativa B\r
\r
POR QUE A ALTERNATIVA B É A INCORRETA (GABARITO):\r
A assertiva B contraria expressamente o Artigo 2º, § 2º, da Lei Complementar Estadual nº 10.992/1997 (Plano de Carreira dos Servidores Militares do RS), que estabelece: "A inclusão no quadro de acesso para a promoção ao posto de Coronel PODERÁ ser recusada pelo servidor." Portanto, a afirmação de que não poderia ser recusada torna a alternativa incorreta.\r
\r
POR QUE AS DEMAIS ALTERNATIVAS ESTÃO CORRETAS NA LEI:\r
- Alternativa A (Correta): Reproduz textualmente o Artigo 3º, § 1º da LC nº 10.992/1997 (ingresso no CSPM mediante concurso de provas e títulos com exigência de bacharelado em Ciências Jurídicas e Sociais).\r
- Alternativa C (Correta): Espelha a redação do Artigo 3º, § 2º da LC nº 10.992/1997 (condição de Aluno-Oficial durante a frequência ao CSPM, com duração máxima de dois anos).\r
- Alternativa D (Correta): Reflete expressamente o Artigo 5º, § 1º da LC nº 10.992/1997 (requisitos para Major: 3 anos de serviço em órgão de execução e aprovação no CAAPM).\r
- Alternativa E (Correta): Reproduz o Artigo 5º, § 2º da LC nº 10.992/1997 (exigência de aprovação no CEPGSP para promoção de Tenente-Coronel a Coronel).\r
\r
BIZU DE PROVA:\r
Promoção ao Posto de Coronel (LC nº 10.992/1997, Art. 2º, §2º):
A inclusão no Quadro de Acesso ao posto de Coronel É FACULTATIVA, PODENDO SER RECUSADA formalmente pelo próprio Oficial militar!`;

const ALT_NOVAS_368 = {
  1817: "Os Militares Estaduais na inatividade são alcançados, em qualquer hipótese, pelas disposições do Regulamento Disciplinar da Brigada Militar do Estado do Rio Grande do Sul.",
  1818: "A camaradagem é indispensável à formação e ao convívio entre os integrantes da Corporação, devendo estes primar pela melhor relação social entre si.",
  1819: "Incumbe ao superior hierárquico incentivar e manter a harmonia e a amizade entre seus subordinados.",
  1820: "A civilidade, como parte da educação policial-militar, é de importância vital para a disciplina no âmbito da Brigada Militar.",
  1821: "É indispensável que o superior trate com cortesia, urbanidade e justiça os seus subordinados e, em contrapartida, o subordinado deve externar, aos seus superiores, toda manifestação de respeito e deferência.",
};

const ALT_NOVAS_369 = {
  1822: "A repreensão, forma mais branda das sanções, será aplicada ostensivamente, por meio de publicação em Boletim, e será registrada nos assentamentos individuais do transgressor.",
  1823: "A advertência é sanção imposta ao transgressor de forma ostensiva, mediante publicação em Boletim, devendo sempre ser averbada nos assentamentos individuais do transgressor.",
  1824: "A detenção consiste no cerceamento da liberdade do punido, o qual deverá permanecer no local que lhe for determinado, ficando confinado.",
  1825: "Exclusivamente para o atendimento das disposições de conversão de infração penal em disciplinar, previstas na lei penal militar, haverá o instituto da prisão administrativa, que consiste na permanência do punido no âmbito do aquartelamento, com prejuízo do serviço e da instrução.",
  1826: "O licenciamento e a exclusão a bem da disciplina consistem no afastamento a pedido do Militar Estadual do serviço ativo, conforme preceitua o Estatuto dos Servidores Militares da Brigada Militar do Estado do Rio Grande do Sul.",
};
const EXPLICACAO_NOVA_369 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
A alternativa D reproduz expressamente a literalidade do Artigo 14, § 4º, do Regulamento Disciplinar da Brigada Militar (aprovado pelo Decreto Estadual nº 43.245/2004): "Exclusivamente para o atendimento das disposições de conversão de infração penal em disciplinar, previstas na lei penal militar, haverá o instituto da prisão administrativa, que consiste na permanência do punido no âmbito do aquartelamento, com prejuízo do serviço e da instrução."\r
\r
POR QUE AS ALTERNATIVAS A, B, C E E ESTÃO INCORRETAS:\r
- Alternativa A (Incorreta): A forma mais branda das sanções é a advertência (Art. 14, I). A repreensão é aplicada por escrito e publicada em boletim com averbação, mas não é a mais branda (Art. 16).\r
- Alternativa B (Incorreta): Nos termos do Artigo 15, § 1º, a advertência é a sanção mais branda, tem caráter estritamente verbal e confidencial, "não constará das alterações do Militar Estadual e não será publicada em Boletim".\r
- Alternativa C (Incorreta): O Artigo 17, caput dispõe expressamente que na detenção o militar punido permanece no local determinado "sem que fique confinado".\r
- Alternativa E (Incorreta): O licenciamento a bem da disciplina (Art. 19) e a exclusão a bem da disciplina (Art. 20) são sanções disciplinares expulsórias aplicadas de ofício (ex officio) pela autoridade competente, e não a pedido do militar.\r
\r
BIZU DE PROVA:\r
Sanções Disciplinares na Brigada Militar (Decreto Estadual nº 43.245/2004):\r
1. Advertência (Art. 15): Mais branda, verbal/reservada, NÃO vai a boletim e NÃO vai aos assentamentos.\r
2. Repreensão (Art. 16): Escrita, publicada em boletim e averbada nos assentamentos.\r
3. Detenção (Art. 17): Cerceamento no quartel/local SEM confinamento.\r
4. Prisão Administrativa (Art. 14, §4º): Exclusiva para conversão de infração penal em disciplinar.\r
5. Licenciamento/Exclusão a bem da disciplina (Arts. 19/20): Punições expulsórias de ofício!`;

const ENUNCIADO_NOVO_370 = "A respeito do processo administrativo disciplinar militar previsto no referido Regulamento, assinale a alternativa INCORRETA.";
const ALT_NOVAS_370 = {
  1828: "Quando duas autoridades de níveis hierárquicos diferentes, ambas com competência disciplinar sobre o transgressor, tiverem conhecimento da transgressão disciplinar, caberá à de maior hierarquia apurá-la ou determinar que a menos graduada o faça.",
  1829: "Todo Militar Estadual que tiver conhecimento de um fato contrário à disciplina deverá participar ao seu superior imediato, por escrito ou verbalmente, independentemente de confirmação escrita.",
};

function body(mode) {
  return `-- ============================================================================
-- FASE 2O — LEGISLAÇÃO MILITAR ESTADUAL / BM-RS (LC 10.990, LC 10.991, LC 10.992, DEC 43.245)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
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
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (9 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 210: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_210)},
         atualizado_em = now()
   WHERE id = 210;

  -- ID 211: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_211)},
         atualizado_em = now()
   WHERE id = 211;

  -- ID 212: Nova explicação (RDBM)
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_212)},
         atualizado_em = now()
   WHERE id = 212;

  -- ID 362: Higiene de OCR no enunciado e alternativa D (explicação preservada)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_362)},
         atualizado_em = now()
   WHERE id = 362;
${Object.entries(ALT_NOVAS_362).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 362;`).join('\n')}

  -- ID 363: Nova explicação (arts. 39 e 40 da LC 10.990/97) + higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_363)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_363)},
         atualizado_em = now()
   WHERE id = 363;

  -- ID 364: Nova explicação (arts. 2º, § 2º, 3º, §§ 1º e 2º, e 5º, §§ 1º e 2º da LC 10.992/97) + expurgo de cabeçalho e OCR no enunciado/alternativas
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_364)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_364)},
         atualizado_em = now()
   WHERE id = 364;
${Object.entries(ALT_NOVAS_364).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 364;`).join('\n')}

  -- ID 368: Higiene de OCR nas alternativas A, B, C, D e E (explicação preservada)
${Object.entries(ALT_NOVAS_368).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 368;`).join('\n')}
  UPDATE public.questoes SET atualizado_em = now() WHERE id = 368;

  -- ID 369: Nova explicação (art. 14 e dispositivos pertinentes do Dec. nº 43.245/2004) + higiene de OCR nas alternativas
  UPDATE public.questoes
     SET explicacao = ${sqlStr(EXPLICACAO_NOVA_369)},
         atualizado_em = now()
   WHERE id = 369;
${Object.entries(ALT_NOVAS_369).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 369;`).join('\n')}

  -- ID 370: Higiene de OCR estrita ao enunciado e alternativas B e C (explicação e alternativas A, D, E preservadas)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_370)},
         atualizado_em = now()
   WHERE id = 370;
${Object.entries(ALT_NOVAS_370).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 370;`).join('\n')}

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
${[12, 20, 39, 43, 45, 53, 201, 202, 203, 271, 272, 300, 303].map(id => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${HASH_QUESTAO_ANTES[id]}' OR
     (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${HASH_EXPLICACAO_ANTES[id]}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão ${id} (intocada) foi modificada indevidamente';
  END IF;`).join('\n')}

  -- Assert 6: Explicações das questões de OCR puro (362, 368, 370) preservadas byte a byte
${[362, 368, 370].map(id => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${HASH_EXPLICACAO_ANTES[id]}' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão ${id} (OCR puro) foi alterada indevidamente';
  END IF;`).join('\n')}

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
        position(E'\\n' in enunciado) > 0 OR
        position('\\n' in enunciado) > 0 OR
        enunciado LIKE '%n º%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 13a falhou: quebras de linha ou resíduos de OCR ainda detectados nos enunciados 362/364/370';
  END IF;

  -- Assert 13b: Enunciado com assertivas semânticas (363) - validação exata e ausência de resíduos de OCR
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 363;
  IF v_enunciado_check LIKE '%policiais -militares%' OR
     v_enunciado_check LIKE '%exa ção%' OR
     position('\\n' in v_enunciado_check) > 0 OR
     v_enunciado_check <> ${sqlStr(ENUNCIADO_NOVO_363)} THEN
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
        position(E'\\n' in texto) > 0 OR
        position('\\n' in texto) > 0 OR
        texto LIKE '%policial -militar%' OR
        texto LIKE '%Tenente -Coronel%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 14 falhou: resíduos de OCR ainda detectados em alternativas tratadas';
  END IF;

  RAISE NOTICE 'TODOS OS 14 ASSERTS DA FASE 2O (LEGISLAÇÃO MILITAR ESTADUAL / BM-RS) PASSARAM COM SUCESSO!';
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
