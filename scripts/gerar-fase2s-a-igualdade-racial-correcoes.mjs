#!/usr/bin/env node
// Fase 2S-A — Estatuto da Igualdade Racial (Lei 12.288/2010 e Lei Estadual RS 13.694/2011):
// Reescrita de explicação totalmente contaminada por outra matéria/lei, com fundamento
// confirmado contra texto oficial primário (extração local dos PDFs da Presidência da
// República/Casa Civil para a Lei 12.288/2010, e da publicação do gabinete do Deputado
// Estadual Raul Carrion/ALRS para a Lei 13.694/2011). Somente o campo `explicacao` é
// alterado em cada uma das 7 questões — enunciado, alternativas, gabarito, ordem das
// alternativas, status `ativa`, matéria, assunto e demais metadados permanecem intocados.
//
// Escopo:
//   - id 131: explicação (DUDH arts. 22-27, alheia) -> Art. 3º, Lei 12.288/2010 (diretrizes
//             político-jurídicas). Gabarito D (ordem 4, "Apenas II e III") preservado.
//   - id 255: explicação (DUDH art. 20, alheia) -> Art. 1º, parágrafo único, I, Lei 12.288/2010
//             (definição de discriminação racial/étnico-racial). Gabarito A (ordem 1) preservado.
//   - id 256: explicação (DUDH art. 21, alheia) -> Art. 1º, caput, Lei 12.288/2010 (finalidade
//             do Estatuto). Gabarito A (ordem 1) preservado.
//   - id 136: explicação (Lei de Abuso de Autoridade 13.869/2019, alheia) -> Art. 17, caput e
//             parágrafo único, Lei Estadual RS 13.694/2011 (cargos públicos, iniciativa privada,
//             formação profissional). Gabarito D (ordem 4, V-V-V) preservado.
//   - id 850: explicação (Estatuto do Desarmamento 10.826/2003, alheia) -> Arts. 13, 15 e 20,
//             Lei Estadual RS 13.694/2011 (campanhas de literatura negra, incentivo ao ensino
//             Médio/Técnico/Superior, percentual de afrodescendentes em publicidade oficial).
//             Gabarito C (ordem 3, V-V-V) preservado.
//   - id 851: explicação (Estatuto do Desarmamento, alheia) -> Art. 17, caput e parágrafo único,
//             Lei Estadual RS 13.694/2011 (mesmo fundamento de 136). Gabarito D (ordem 4, V-V-V)
//             preservado.
//   - id 852: explicação (Estatuto do Desarmamento, alheia) -> Arts. 18, 11 e 14, Lei Estadual RS
//             13.694/2011 (quesito raça, datas comemorativas, capoeira — "Kuduro" não consta na
//             lei). Gabarito D (ordem 4, V-V-F) preservado.
//
// Fora deste lote: as demais 17 questões do universo de 24 do assunto Igualdade Racial (entre
// elas 132 e 367, que têm o mesmo tipo de erro de número de artigo identificado na microanálise,
// mas ficam para uma eventual Fase 2S-B).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2s-a_igualdade_racial_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2s-a_igualdade_racial_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração.
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  131: 'accd373ee90f700378ffe443bcd40ff7',
  136: '9e6f152e3e212ceabaedcf3a8873fac5',
  255: '2976c23f2b390af1c4a411b3709645e2',
  256: '99edd2a3015006ac76b7384d5f1a2435',
  850: '84597b5f3bd3187e97448a4196d9494e',
  851: 'c619880d86c75762dca80f7103cef009',
  852: '1455e565166eff5a037c7fd6148d0e83',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  131: '899e93009f95c056cf9977b0c4b09512',
  136: '49a80b477ce500cd95a5b4b258b20218',
  255: 'e8bc2e77fa2ca39f0aa44800a878f03a',
  256: 'ba43f5afea0e1cfa28676a2810f0ca68',
  850: '40d6df0a650d938e6e2365cc164e39ed',
  851: '1235318206f0f969b6f080fef4468cb7',
  852: 'b5db5abe96db10b5f87b2c4041f8a91e',
};

// Ordem da alternativa correta (gabarito) de cada questão do lote — inalterado nesta fase
const GABARITO = { 131: 4, 136: 4, 255: 1, 256: 1, 850: 3, 851: 4, 852: 4 };

// --------------------------------------------------------------------------
// Textos novos das explicações
// --------------------------------------------------------------------------

const EXPLICACAO_NOVA_131 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
O Artigo 3º da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) dispõe: "Além das normas constitucionais relativas aos princípios fundamentais, aos direitos e garantias fundamentais e aos direitos sociais, econômicos e culturais, o Estatuto da Igualdade Racial adota como diretriz político-jurídica a inclusão das vítimas de desigualdade ÉTNICO-RACIAL, a valorização da igualdade étnica e o fortalecimento da identidade nacional brasileira."\r
- I. (Incorreta): O texto legal fala em "vítimas de desigualdade étnico-racial", e não em "desigualdade social" como afirma a assertiva.\r
- II. (Correta): "A valorização da igualdade étnica" reproduz literalmente o dispositivo.\r
- III. (Correta): "O fortalecimento da identidade nacional brasileira" reproduz literalmente o dispositivo.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A assertiva I é falsa, e a assertiva III também é verdadeira.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
A assertiva II também é verdadeira.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A assertiva I é falsa.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A assertiva I é falsa, pois o texto legal fala em desigualdade étnico-racial, não social.\r
\r
BIZU DE PROVA:\r
Diretrizes Político-Jurídicas do Estatuto (Art. 3º da Lei 12.288/2010):\r
Inclusão das vítimas de desigualdade ÉTNICO-RACIAL (não "social"), valorização da igualdade étnica e fortalecimento da identidade nacional brasileira!`;

const EXPLICACAO_NOVA_255 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
O Artigo 1º, parágrafo único, inciso I, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) define: "discriminação racial ou étnico-racial: toda distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que tenha por objeto anular ou restringir o reconhecimento, gozo ou exercício, em igualdade de condições, de direitos humanos e liberdades fundamentais nos campos político, econômico, social, cultural ou em qualquer outro campo da vida pública ou privada."\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
O conceito legal não se limita a agressão física; abrange qualquer distinção, exclusão, restrição ou preferência que anule ou restrinja direitos.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
O conceito não se restringe a concursos públicos; alcança qualquer campo da vida pública ou privada.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
O dispositivo não exige que a conduta seja praticada por agente estatal; aplica-se também a particulares.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
O conceito de discriminação racial do Estatuto não se limita a tipos penais do Código Penal.\r
\r
BIZU DE PROVA:\r
Discriminação Racial ou Étnico-Racial (Art. 1º, parágrafo único, I, da Lei 12.288/2010):\r
Toda distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que anule ou restrinja direitos humanos e liberdades fundamentais, em qualquer campo da vida pública ou privada!`;

const EXPLICACAO_NOVA_256 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
O Artigo 1º, caput, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) dispõe: "Esta Lei institui o Estatuto da Igualdade Racial, destinado a garantir à população negra a efetivação da igualdade de oportunidades, a defesa dos direitos étnicos individuais, coletivos e difusos e o combate à discriminação e às demais formas de intolerância étnica."\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
O Estatuto não institui regime jurídico penal especial para a população negra.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
O Estatuto não confere privilégio absoluto sobre outros grupos; busca a efetivação da igualdade de oportunidades.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Não há previsão de isenção tributária geral no Estatuto.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
O Estatuto não prevê acesso exclusivo a cargos públicos.\r
\r
BIZU DE PROVA:\r
Finalidade do Estatuto da Igualdade Racial (Art. 1º, caput, da Lei 12.288/2010):\r
Efetivação da IGUALDADE DE OPORTUNIDADES + defesa dos direitos étnicos individuais, coletivos e difusos + combate à discriminação e à intolerância étnica!`;

const EXPLICACAO_NOVA_136 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
A sequência correta é V – V – V, com fundamento no Artigo 17, caput e parágrafo único, da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial): "O Poder Público deverá promover políticas afirmativas que assegurem igualdade de oportunidades aos negros no acesso aos cargos públicos, proporcionalmente a sua parcela na composição da população do Estado, e incentivará a uma maior equidade para os negros nos empregos oferecidos na iniciativa privada. Parágrafo único - Para enfrentar a situação de desigualdade de oportunidades, deverão ser implementadas políticas e programas de formação profissional, emprego e geração de renda voltadas aos negros."\r
- (V) Políticas afirmativas de igualdade de oportunidades no acesso aos cargos públicos: reproduz o caput.\r
- (V) Políticas afirmativas de maior equidade na iniciativa privada: reproduz o caput.\r
- (V) Políticas e programas de formação profissional, emprego e geração de renda: reproduz o parágrafo único.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A primeira assertiva também é verdadeira.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Todas as três assertivas são verdadeiras.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A primeira e a segunda assertivas também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A terceira assertiva também é verdadeira.\r
\r
BIZU DE PROVA:\r
Acesso ao Mercado de Trabalho (Art. 17 da Lei Estadual RS 13.694/2011):\r
Cargos públicos + iniciativa privada + formação profissional, emprego e geração de renda — todos voltados à população negra!`;

const EXPLICACAO_NOVA_850 = `GABARITO: alternativa C\r
\r
POR QUE A ALTERNATIVA C ESTÁ CORRETA:\r
A sequência correta é V – V – V, com fundamento em três dispositivos da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial):\r
- (V) Artigo 13: "O Poder Público deverá promover campanhas que divulguem a literatura produzida pelos negros e aquela que reproduza a história, as tradições e a cultura do povo negro."\r
- (V) Artigo 15: "O Estado deverá promover programas de incentivo, inclusão e permanência da população negra nos ensinos Médio, Técnico e Superior, adotando medidas para (...)."\r
- (V) Artigo 20: "A idealização, a realização e a exibição das peças publicitárias veiculadas pelo Poder Público deverão observar percentual de artistas, modelos e trabalhadores afrodescendentes em número equivalente ao resultante do censo do Instituto Brasileiro de Geografia e Estatística (IBGE) de afro-brasileiros na composição da população do Rio Grande do Sul."\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A primeira assertiva também é verdadeira.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
A primeira e a terceira assertivas também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
A segunda assertiva também é verdadeira.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A segunda e a terceira assertivas também são verdadeiras.\r
\r
BIZU DE PROVA:\r
Estatuto Estadual da Igualdade Racial do RS:\r
Art. 13 (campanhas de literatura negra) + Art. 15 (incentivo ao ensino Médio/Técnico/Superior) + Art. 20 (percentual de afrodescendentes em publicidade oficial, conforme censo IBGE)!`;

const EXPLICACAO_NOVA_851 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
A sequência correta é V – V – V, com fundamento no Artigo 17, caput e parágrafo único, da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial): "O Poder Público deverá promover políticas afirmativas que assegurem igualdade de oportunidades aos negros no acesso aos cargos públicos, proporcionalmente a sua parcela na composição da população do Estado, e incentivará a uma maior equidade para os negros nos empregos oferecidos na iniciativa privada. Parágrafo único - Para enfrentar a situação de desigualdade de oportunidades, deverão ser implementadas políticas e programas de formação profissional, emprego e geração de renda voltadas aos negros."\r
- (V) Políticas afirmativas de igualdade de oportunidades no acesso aos cargos públicos: reproduz o caput.\r
- (V) Políticas afirmativas de maior equidade na iniciativa privada: reproduz o caput.\r
- (V) Políticas e programas de formação profissional, emprego e geração de renda: reproduz o parágrafo único.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A primeira assertiva também é verdadeira.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
Todas as três assertivas são verdadeiras.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A primeira e a segunda assertivas também são verdadeiras.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A terceira assertiva também é verdadeira.\r
\r
BIZU DE PROVA:\r
Acesso ao Mercado de Trabalho (Art. 17 da Lei Estadual RS 13.694/2011):\r
Cargos públicos + iniciativa privada + formação profissional, emprego e geração de renda — todos voltados à população negra!`;

const EXPLICACAO_NOVA_852 = `GABARITO: alternativa D\r
\r
POR QUE A ALTERNATIVA D ESTÁ CORRETA:\r
A sequência correta é V – V – F, com fundamento em três dispositivos da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial):\r
- (V) Artigo 18: "A inclusão do quesito raça, a ser registrado segundo a autoclassificação, será obrigatória em todos os registros administrativos direcionados a empregadores e trabalhadores dos setores público e privado."\r
- (V) Artigo 11: "Nas datas comemorativas de caráter cívico, as instituições de ensino públicas deverão inserir nas aulas, palestras, trabalhos e atividades afins, dados históricos sobre a participação dos negros nos fatos comemorados."\r
- (F) Artigo 14: "Nas instituições de ensino, públicas e privadas, deverá ser oportunizado o aprendizado e a prática da CAPOEIRA, como atividade esportiva, cultural e lúdica, sendo facultada a participação dos mestres tradicionais de capoeira para atuarem como instrutores desta arte-esporte." A lei fala expressamente em capoeira — "Kuduro" (dança de origem angolana) não consta em nenhum dispositivo deste Estatuto.\r
\r
POR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r
A primeira e a segunda assertivas são verdadeiras.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
A primeira assertiva é verdadeira.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A segunda assertiva é verdadeira e a terceira é falsa.\r
\r
POR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r
A terceira assertiva é falsa (a lei estadual refere-se expressamente à capoeira, não a Kuduro).\r
\r
BIZU DE PROVA:\r
Estatuto Estadual da Igualdade Racial do RS:\r
Quesito raça = Art. 18; Datas comemorativas cívicas = Art. 11; Capoeira nas escolas = Art. 14 — "Kuduro" NÃO consta na lei!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2S-A — ESTATUTO DA IGUALDADE RACIAL (LEI 12.288/2010 E LEI ESTADUAL RS 13.694/2011)
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

  -- Validação dos hashes pré-apply das 7 questões do lote
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (7 QUESTÕES) — SOMENTE O CAMPO EXPLICACAO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_131)}, atualizado_em = now() WHERE id = 131;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_136)}, atualizado_em = now() WHERE id = 136;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_255)}, atualizado_em = now() WHERE id = 255;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_256)}, atualizado_em = now() WHERE id = 256;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_850)}, atualizado_em = now() WHERE id = 850;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_851)}, atualizado_em = now() WHERE id = 851;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_852)}, atualizado_em = now() WHERE id = 852;

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
${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão ${id} (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;`).join('\n')}

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

${mode === 'rollback' ? 'ROLLBACK;' : 'COMMIT;'}`;
}

const harnessSql = body('rollback');
const applySql = body('apply');

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Arquivos gerados com sucesso:`);
console.log(` - ${HARNESS_OUT_PATH}`);
console.log(` - ${APPLY_OUT_PATH}`);
