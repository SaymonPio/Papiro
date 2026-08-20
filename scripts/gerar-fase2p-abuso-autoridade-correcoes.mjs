#!/usr/bin/env node
// Fase 2P — Abuso de Autoridade (Lei nº 13.869/2019):
// Correções de explicação jurídica (713, 793, 837, 838, 839) e higiene de OCR (713, 771, 772, 793, 837, 838, 839).
//
// Universo auditado do lote de assunto "Abuso de Autoridade" (materia_id=10, assunto_id=79): 11 questões.
// Escopo desta Fase 2P (7 questões corrigidas):
//   - id 713: Reescrita da explicação (Art. 31/alvará de soltura -> Art. 13, situação vexatória do preso/detido,
//             fundamento já presente na própria alternativa B) + higiene de OCR no enunciado e nas 5 alternativas.
//             Gabarito B preservado.
//   - id 771: Higiene estrita de OCR no enunciado. Explicação e alternativas preservadas byte a byte. Gabarito C preservado.
//   - id 772: Higiene estrita de OCR no enunciado. Explicação e alternativas preservadas byte a byte. Gabarito C preservado.
//   - id 793: Reescrita da explicação (narrativa de "preso vexado"/Art. 13, alheia ao enunciado -> Art. 1º, §1º,
//             elemento subjetivo geral) + higiene de OCR no enunciado. Gabarito B preservado.
//   - id 837: Reescrita da explicação (Art. 22/invasão de domicílio, alheio ao enunciado -> Art. 13, I e II
//             c/c Art. 1º, §1º, decisão oficial pós-microanálise) + higiene de OCR no enunciado. Gabarito C preservado.
//   - id 838: Correção pontual da explicação (assertiva II: Art. 3º §1º -> Art. 5º, II; assertiva III: prazo de
//             ação subsidiária -> independência das instâncias civil/penal/administrativa) + higiene de OCR no
//             enunciado. Gabarito A preservado.
//   - id 839: Correção pontual da explicação (Art. 22 -> Art. 13, em 3 ocorrências: fundamento principal e
//             justificativas das alternativas A e C) + higiene de OCR no enunciado. Gabarito D preservado.
//
// Fora deste lote (tratamento próprio, conforme decisão oficial):
//   - id 712: candidato a desativação por possível contaminação de matéria/gabarito (Fraude Processual, CP art. 347,
//             indevidamente classificada como Abuso de Autoridade). NÃO tocado nesta Fase 2P.
//
// 3 questões do universo de 11 permanecem intocadas por não fazerem parte do lote de correção nem do candidato
// a desativação: ids 192, 193, 194 (classificadas OK na auditoria).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2p_abuso_autoridade_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2p_abuso_autoridade_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração.
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  713: 'eb5cbb44581a43c91708a1b65249b228',
  771: '54900842171427b87f93ffc75fd1e5bd',
  772: '133293912fe142efc49ca449bd5f3cb5',
  793: '63de7c16cdcf05e457480ffe44897c2e',
  837: '27bd0fac2ddaf3e53ac9c6eea2190982',
  838: '3151ff953931e2ebf85046c2330d47dd',
  839: 'aa7f441ee1b44863bd272fbb741755d9',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  713: 'f1957db9f89e3cdfebf7260b4ece1c3f',
  771: 'bee9d7d978f9ae42f3c694ab3f86a3bb',
  772: 'bd711d29b9033a78ec71816a8f0294dd',
  793: '4c9f2afab62dedf3b7a393235c0da174',
  837: '7afc335c25d6a4b1e168423121537c45',
  838: '91ca6963bf1a7378b0225e385bf8c2e3',
  839: '6b1abce0609345a2ca71bd652c7b23d7',
};

// IDs (das próprias linhas de alternativas) e ordem/gabarito de cada questão do lote
const GABARITO = { 713: 2, 771: 3, 772: 3, 793: 2, 837: 3, 838: 1, 839: 4 };

// Hashes de referência da questão 712 (fora do lote, tratamento próprio por possível contaminação
// de matéria/gabarito — ver microanálise). Usados exclusivamente no Assert 13 para provar que este
// script não a toca. Capturados ao vivo do banco de produção na mesma sessão de auditoria dos demais
// hashes deste arquivo. Mantidos como constantes nomeadas e separadas (em vez de literais inline)
// para eliminar qualquer ambiguidade de leitura no assert de guarda.
const HASH_QUESTAO_712 = '870aba3b71a18696de9eb5692e206b8b'; // md5(enunciado) da questão 712
const HASH_EXPLICACAO_712 = 'f15884ff613cfd2202991895219f336d'; // md5(explicacao) da questão 712

// --------------------------------------------------------------------------
// Textos novos / higienizados
// --------------------------------------------------------------------------

const ENUNCIADO_NOVO_713 = "Delegado de polícia que assume nova unidade policial e deseja mostrar perfil operacional e atuante à nova equipe, no exercício de suas funções, realiza abordagem de indivíduo em via pública. Durante a abordagem, sem qualquer justificativa legal ou indícios de ilícito, submete o abordado a constrangimento excessivo, incluindo revista íntima vexatória e prolongada detenção em viatura policial sem comunicação imediata à autoridade competente. A conduta causa intenso sofrimento psicológico à vítima, mas não resulta em lesões físicas. Com base na Lei de Abuso de Autoridade (Lei nº 13.869/2019), assinale a alternativa correta.";

const ALT_NOVAS_713 = {
  3542: "A autoridade policial responde pelo crime de tortura previsto na Lei nº 9.455/1997, pois submeteu a vítima a sofrimento psíquico mediante violência ou grave ameaça, ainda que sem lesões físicas.",
  3543: "A autoridade policial pratica o crime de abuso de autoridade previsto no art. 13 da Lei nº 13.869/2019 (constranger o preso ou detido), pois realizou constrangimento ilegal durante a detenção do abordado ao submetê-lo à revista íntima pública e vexatória, agindo com a finalidade específica de satisfazer o sentimento pessoal de demonstrar perfil profissional que julga ser interessante ao assumir nova unidade policial.",
  3544: "Não há crime de abuso de autoridade, pois a Lei nº 13.869/2019 exige elemento subjetivo específico consistente na finalidade específica de prejudicar outrem ou beneficiar a si mesmo ou a terceiro, não sendo suficiente o dolo genérico.",
  3545: "A conduta configura exclusivamente o crime de constrangimento ilegal previsto no art. 146 do Código Penal, não se aplicando a Lei de Abuso de Autoridade por ausência de finalidade específica ou violação de direito expressamente tutelado.",
  3546: "A autoridade policial responde pelos crimes previstos nos arts. 9º (decretar prisão ilegal) e 15 (constranger a produzir prova contra si) da Lei nº 13.869/2019, em concurso material, pelos diversos constrangimentos impostos durante a abordagem.",
};

const EXPLICACAO_NOVA_713 = `GABARITO: alternativa B\r
\r
POR QUE A ALTERNATIVA B ESTÁ CORRETA:\r
Conforme o Artigo 13, caput e inciso II, da Lei nº 13.869/2019 (Lei de Abuso de Autoridade), comete crime a autoridade policial que constrange o preso ou o detido, mediante violência, grave ameaça ou redução de sua capacidade de resistência, a submeter-se a situação vexatória ou a constrangimento não autorizado em lei. No caso, a revista íntima pública e vexatória foi realizada sem qualquer justificativa legal ou indício de ilícito, com a finalidade específica (art. 1º, §1º) de satisfazer o sentimento pessoal do delegado de demonstrar perfil operacional perante a nova equipe.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A tortura (Lei nº 9.455/1997) exige finalidade de obter confissão, aplicar castigo ou discriminar; a conduta narrada não tem esse propósito, amoldando-se ao tipo específico do art. 13 da Lei 13.869/2019.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A finalidade específica exigida pelo art. 1º, §1º está presente na motivação pessoal do agente (demonstrar perfil perante a equipe), o que afasta a alegação de mero dolo genérico.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Há tipo específico e mais gravoso na Lei de Abuso de Autoridade (art. 13), que prevalece sobre o art. 146 do Código Penal por especialidade.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A conduta não se limita aos arts. 9º (decretar prisão manifestamente ilegal) ou 15 (constranger a produzir prova contra si); o constrangimento por revista íntima vexatória amolda-se especificamente ao art. 13, II.\r
\r
BIZU DE PROVA:\r
Situação Vexatória do Preso/Detido (Art. 13 da Lei nº 13.869/19):\r
Constranger o preso ou detido, mediante violência, grave ameaça ou redução de sua capacidade de resistência, a situação vexatória ou constrangimento não autorizado em lei, com finalidade específica (art. 1º, §1º) = CRIME DE ABUSO DE AUTORIDADE!`;

const ENUNCIADO_NOVO_771 = "Um agente público, no exercício de suas funções, praticou conduta com a finalidade específica de prejudicar a terceiro, por mero capricho. Ele realizou esse abuso de autoridade mais de uma vez, ficando explícito que sua intenção era realizar uma vingança pessoal, portanto, com motivos estranhos ao da atividade pública que exercia. Após ser julgado, ele foi condenado à perda do cargo. Essa sentença foi proferida pois:";

const ENUNCIADO_NOVO_772 = "Um servidor público se negou a atender uma pessoa e a retirou do recinto de atendimento público, sem qualquer explicação ou motivo. Esse ato, entendido como abuso de autoridade, foi publicado na mídia, porém não houve qualquer ação do Ministério Público. Um ano após o ocorrido, um familiar da pessoa que necessitava de atendimento resolveu prestar queixa sobre o fato. Essa queixa não foi acolhida e processada, porque:";

const ENUNCIADO_NOVO_793 = "Qual o crime cometido por agente público quando for praticado ato com a finalidade específica de prejudicar outrem ou beneficiar a si mesmo ou a terceiro, ou ainda, por mero capricho pessoal?";

const EXPLICACAO_NOVA_793 = `GABARITO: alternativa B\r
\r
POR QUE A ALTERNATIVA B ESTÁ CORRETA:\r
O Artigo 1º, §1º, da Lei nº 13.869/2019 estabelece que as condutas descritas na lei somente constituem crime de ABUSO DE AUTORIDADE quando praticadas pelo agente público com a finalidade específica de prejudicar outrem, beneficiar a si mesmo ou a terceiro, ou, ainda, por mero capricho ou satisfação pessoal. É esse elemento subjetivo especial — e não o dolo genérico — que qualifica a conduta como abuso de autoridade, independentemente de qual tipo penal específico da lei venha a se configurar no caso concreto.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
Não constitui infração puramente administrativa, havendo responsabilidade penal expressa quando presente a finalidade específica do art. 1º, §1º.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A tortura (Lei 9.455/97) exige sofrimento físico ou mental grave voltado a confissão, castigo ou discriminação específica — elemento distinto da finalidade específica genérica do art. 1º, §1º da Lei 13.869/2019.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Prevaricação (Art. 319 CP) tutela a probidade do ato de ofício por sentimento pessoal, mas não se confunde com o regime específico da Lei de Abuso de Autoridade.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Desacato é crime praticado por particular contra agente público, e não pelo agente contra o cidadão.\r
\r
BIZU DE PROVA:\r
Elemento Subjetivo Geral do Abuso de Autoridade (Art. 1º, §1º da Lei nº 13.869/19):\r
Finalidade específica de PREJUDICAR OUTREM, BENEFICIAR A SI/TERCEIRO, ou agir por MERO CAPRICHO/SATISFAÇÃO PESSOAL = elemento que qualifica a conduta como ABUSO DE AUTORIDADE!`;

const ENUNCIADO_NOVO_837 = "Um Guarda Municipal, ao atender uma ocorrência de discussão e agressão, com origem de relação afetiva entre dois homens, sendo um deles homossexual, que vestia roupas femininas e tinha seios alterados pelo uso de silicone, recebeu deste forte reação verbal e uso de palavras ofensivas. De imediato, imobilizou-o e algemou-o. Por se sentir desrespeitado e ofendido, baixou a parte superior do vestido que o homossexual utilizava e deixou-o exposto na via pública. Esta condição ocorreu durante o dia, no centro da cidade, durando cerca de 20 minutos, até a chegada de uma viatura com equipe de apoio. Como deve ser tipificada essa conduta do Guarda Municipal em relação à exposição pública?";

const EXPLICACAO_NOVA_837 = `GABARITO: alternativa C\r
\r
POR QUE A ALTERNATIVA C ESTÁ CORRETA:\r
A conduta do agente público que constrange o preso ou o detento, mediante violência, grave ameaça ou redução de sua capacidade de resistência, a exibir-se ou ter seu corpo exibido à curiosidade pública, ou a submeter-se a situação vexatória, configura o crime de ABUSO DE AUTORIDADE tipificado no Artigo 13, incisos I e II, da Lei nº 13.869/2019. No caso, a vítima estava algemada (redução da capacidade de resistência) quando o Guarda Municipal expôs seu corpo na via pública por motivação pessoal — "por se sentir desrespeitado e ofendido" —, o que caracteriza a finalidade específica de mero capricho ou satisfação pessoal exigida pelo art. 1º, §1º, da mesma lei.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
Não se trata de pleno exercício do poder legal, havendo crime específico consumado.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Não existe previsão regulamentar que autorize a exposição vexatória de pessoa sob custódia, ainda que em situação de abalo moral do agente.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
A conduta é desproporcional aos fatos: a reação verbal ofensiva da vítima não autoriza a exposição pública de seu corpo.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
Não há lesão corporal descrita nos fatos; a conduta relevante é a exposição vexatória, tipificada como abuso de autoridade, e não como crime contra a integridade física.\r
\r
BIZU DE PROVA:\r
Exposição Vexatória de Preso/Detido (Art. 13, I e II, da Lei nº 13.869/19):\r
Exibir o corpo do detido à curiosidade pública ou submetê-lo a situação vexatória, mediante violência, grave ameaça ou redução de sua capacidade de resistência, com finalidade específica de satisfação pessoal (art. 1º, §1º) = CRIME DE ABUSO DE AUTORIDADE (pena de detenção de 1 a 4 anos e multa)!`;

const ENUNCIADO_NOVO_838 = "Com referência na Lei de Abuso de autoridade, Lei nº 13.869/2019, analise as assertivas abaixo: I. O agente público condenado por praticar crime de abuso de autoridade poderá perder o cargo ou função pública. II. A suspensão do exercício do cargo ou da função, pelo prazo de 1 (um) a 6 (seis) meses, é pena restritiva de direitos prevista na lei. III. Para que o agente público seja responsabilizado civil e administrativamente, é necessária a condenação na esfera criminal, por serem ramos do direito dependentes entre si. Quais estão corretas?";

const EXPLICACAO_NOVA_838 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
Estão corretas apenas as assertivas I e II:\r
- I. (Correta): O crime de abuso de autoridade é de ação penal pública incondicionada (Art. 3º da Lei 13.869/2019).\r
- II. (Correta): A suspensão do exercício do cargo, da função ou do mandato, pelo prazo de 1 (um) a 6 (seis) meses, com a perda dos vencimentos e das vantagens, é pena restritiva de direitos substitutiva expressamente prevista no art. 5º, II, da Lei nº 13.869/2019.\r
- III. (Incorreta): A responsabilização civil e administrativa do agente público independe de condenação na esfera criminal, tratando-se de instâncias autônomas.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Incompleta, pois a assertiva I também é verdadeira.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A assertiva III está errada (as instâncias civil, administrativa e penal são independentes).\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
A assertiva III invalida a opção.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A assertiva III torna o item incorreto.\r
\r
BIZU DE PROVA:\r
Efeitos e Sanções na Lei de Abuso de Autoridade (Arts. 3º e 5º da Lei 13.869/19):\r
- Ação penal: Regra é PÚBLICA INCONDICIONADA (Art. 3º);\r
- Suspensão do cargo (1 a 6 meses): PENA RESTRITIVA DE DIREITOS substitutiva (Art. 5º, II);\r
- Responsabilidades civil, administrativa e penal são INDEPENDENTES entre si!`;

const ENUNCIADO_NOVO_839 = "A Lei nº 13.869/2019, que dispõe sobre os crimes de abuso de autoridade, tipifica como tal constranger o preso ou o detento, mediante violência, grave ameaça ou redução de sua capacidade de resistência, a submeter-se a situação vexatória ou a constrangimento não autorizado em lei. A pena prevista para esse crime é de:";

const EXPLICACAO_NOVA_839 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
O crime de constrangimento do preso ou detento a situação vexatória (Artigo 13, caput, da Lei nº 13.869/2019) comina abstratamente as penas de DETENÇÃO, DE 1 (UM) A 4 (QUATRO) ANOS, E MULTA, SEM PREJUÍZO DA PENA COMINADA À VIOLÊNCIA.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A pena prevista no art. 13 é detenção de 1 a 4 anos e multa, e não reclusão de 6 meses a 2 anos.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
A pena de reclusão não é a espécie cominada nos crimes da Lei 13.869/19 (que comina penas de detenção).\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A pena de detenção de 6 meses a 2 anos aplica-se a outros tipos penais menos graves da lei, e não ao art. 13, cuja pena é de 1 a 4 anos.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A sanção criminal acumula obrigatoriamente pena privativa de liberdade de detenção e multa cumulativa.\r
\r
BIZU DE PROVA:\r
Penas da Lei de Abuso de Autoridade (Lei nº 13.869/2019):\r
TODOS os crimes cominam pena de DETENÇÃO (divididos em duas faixas: Detenção de 6 meses a 2 anos OU Detenção de 1 a 4 anos)!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2P — ABUSO DE AUTORIDADE (LEI Nº 13.869/2019)
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

  -- Validação dos hashes pré-apply das 7 questões do lote (id 712 excluído, tratamento próprio)
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (7 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 713: Higiene de OCR no enunciado e nas 5 alternativas + reescrita da explicação (Art. 31 -> Art. 13)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_713)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_713)},
         atualizado_em = now()
   WHERE id = 713;
${Object.entries(ALT_NOVAS_713).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 713;`).join('\n')}

  -- ID 771: Higiene estrita de OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_771)},
         atualizado_em = now()
   WHERE id = 771;

  -- ID 772: Higiene estrita de OCR no enunciado (explicação e alternativas preservadas)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_772)},
         atualizado_em = now()
   WHERE id = 772;

  -- ID 793: Higiene de OCR no enunciado + reescrita da explicação (narrativa alheia de Art. 13 -> Art. 1º, §1º)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_793)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_793)},
         atualizado_em = now()
   WHERE id = 793;

  -- ID 837: Higiene de OCR no enunciado + reescrita da explicação (Art. 22 -> Art. 13, I e II c/c Art. 1º, §1º)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_837)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_837)},
         atualizado_em = now()
   WHERE id = 837;

  -- ID 838: Higiene de OCR no enunciado + correção pontual da explicação (assertivas II e III)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_838)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_838)},
         atualizado_em = now()
   WHERE id = 838;

  -- ID 839: Higiene de OCR no enunciado + correção pontual da explicação (Art. 22 -> Art. 13)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_839)},
         explicacao = ${sqlStr(EXPLICACAO_NOVA_839)},
         atualizado_em = now()
   WHERE id = 839;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados (nenhuma ativação/desativação nesta Fase 2P)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (as 7 questões continuam com ativa = true)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (713, 771, 772, 793, 837, 838, 839) AND ativa = true) <> 7 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões do lote da Fase 2P tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão e presença de todas as 7 questões
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (713, 771, 772, 793, 837, 838, 839)) <> 7 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (713, 771, 772, 793, 837, 838, 839)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões do lote não possuem exatamente 1 alternativa correta ou estão ausentes no conjunto de alternativas';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos oficiais em cada uma das 7 questões
${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Questões de OCR puro (771, 772) - explicação e alternativas preservadas byte a byte
${[771, 772].map(id => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${HASH_EXPLICACAO_ANTES[id]}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: explicação da questão ${id} (OCR puro) foi alterada indevidamente';
  END IF;`).join('\n')}

  -- Assert 6: Ausência de resíduos colados de OCR nos enunciados tratados (todas as 7 questões)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (713, 771, 772, 793, 837, 838, 839) AND (
        enunciado LIKE '%abordagemde%' OR enunciado LIKE '%incluindorevista%' OR enunciado LIKE '%àvítima%' OR
        enunciado LIKE '%abusode%' OR enunciado LIKE '%queexercia%' OR
        enunciado LIKE '%comoabuso%' OR enunciado LIKE '%deatendimento%' OR
        enunciado LIKE '%ouainda%' OR
        enunciado LIKE '%quevestia%' OR enunciado LIKE '%algemou-o.Por%' OR enunciado LIKE '%durante odia%' OR enunciado LIKE '%Municipalem%' OR
        enunciado LIKE '%direitodependentes%' OR
        enunciado LIKE '%ouredução%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 6 falhou: resíduos de OCR ainda detectados em algum enunciado do lote';
  END IF;

  -- Assert 7: Ausência de resíduos colados de OCR nas 5 alternativas tratadas da questão 713
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 713 AND (
        texto LIKE '%graveameaça%' OR texto LIKE '%realizouconstrangimento%' OR texto LIKE '%osentimento%' OR
        texto LIKE '%oubeneficiar%' OR texto LIKE '%porausência%' OR texto LIKE '%2019,em%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 7 falhou: resíduos de OCR ainda detectados nas alternativas da questão 713';
  END IF;

  -- Assert 8: Questão 713 - explicação fundamentada no art. 13 e sem resíduo do art. 31/alvará de soltura
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 713;
  IF v_explicacao_check NOT ILIKE '%Artigo 13%' OR
     v_explicacao_check ILIKE '%Artigo 31%' OR
     v_explicacao_check ILIKE '%alvará de soltura%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: explicação da questão 713 incorreta ou ainda contendo resíduo do art. 31/alvará de soltura';
  END IF;

  -- Assert 9: Questão 793 - explicação fundamentada no art. 1º, §1º e sem narrativa de preso/situação vexatória
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 793;
  IF v_explicacao_check NOT ILIKE '%Artigo 1º, §1º%' OR
     v_explicacao_check ILIKE '%submete o preso%' OR
     v_explicacao_check ILIKE '%Artigo 13, incisos I e II%' THEN
    RAISE EXCEPTION 'Assert 9 falhou: explicação da questão 793 incorreta ou ainda contendo narrativa alheia de preso vexado';
  END IF;

  -- Assert 10: Questão 837 - explicação fundamentada no art. 13 c/c art. 1º, §1º e sem resíduo do art. 22/invasão de domicílio
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 837;
  IF v_explicacao_check NOT ILIKE '%Artigo 13, incisos I e II%' OR
     v_explicacao_check NOT ILIKE '%art. 1º, §1º%' OR
     v_explicacao_check ILIKE '%invasão de domicílio%' OR
     v_explicacao_check ILIKE '%Artigo 22%' THEN
    RAISE EXCEPTION 'Assert 10 falhou: explicação da questão 837 incorreta ou ainda contendo resíduo do art. 22/invasão de domicílio';
  END IF;

  -- Assert 11: Questão 838 - assertiva II fundamentada no art. 5º, II e assertiva III na independência de instâncias
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 838;
  IF v_explicacao_check NOT ILIKE '%art. 5º, II%' OR
     v_explicacao_check NOT ILIKE '%instâncias autônomas%' OR
     v_explicacao_check ILIKE '%prazo para ajuizar a ação subsidiária é de 6%' THEN
    RAISE EXCEPTION 'Assert 11 falhou: explicação da questão 838 incorreta ou ainda contendo fundamentação trocada nas assertivas II/III';
  END IF;

  -- Assert 12: Questão 839 - explicação fundamentada no art. 13 e sem nenhuma menção ao art. 22
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 839;
  IF v_explicacao_check NOT ILIKE '%Artigo 13, caput%' OR
     v_explicacao_check ILIKE '%Artigo 22%' OR
     v_explicacao_check ILIKE '%invasão de domicílio%' THEN
    RAISE EXCEPTION 'Assert 12 falhou: explicação da questão 839 incorreta ou ainda contendo resíduo do art. 22/invasão de domicílio';
  END IF;

  -- Assert 13: Questão 712 (fora do lote, tratamento próprio) permanece absolutamente intocada.
  -- Duas verificações independentes e nomeadas separadamente (enunciado x explicação) — nenhuma
  -- delas compara um valor contra si mesmo; ambas comparam o hash ATUAL do banco contra a constante
  -- capturada ANTES desta migração.
  IF (SELECT md5(enunciado) FROM public.questoes WHERE id = 712) <> '${HASH_QUESTAO_712}' THEN
    RAISE EXCEPTION 'Assert 13a falhou: enunciado da questão 712 (fora do lote) foi modificado indevidamente';
  END IF;
  IF (SELECT md5(explicacao) FROM public.questoes WHERE id = 712) <> '${HASH_EXPLICACAO_712}' THEN
    RAISE EXCEPTION 'Assert 13b falhou: explicação da questão 712 (fora do lote) foi modificada indevidamente';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2P (ABUSO DE AUTORIDADE) PASSARAM COM SUCESSO (1-12 + 13a/13b)!';
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
