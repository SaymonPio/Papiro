#!/usr/bin/env node
// Fase 2S-B — Estatuto Estadual da Igualdade Racial (Lei Estadual RS nº 13.694/2011):
// Correção de números de artigo errados na explicação, confirmados contra texto oficial
// primário (extração local do PDF da publicação do gabinete do Deputado Estadual Raul
// Carrion/ALRS). Somente o campo `explicacao` é alterado em cada uma das 2 questões —
// enunciado, alternativas, gabarito, ordem das alternativas, status `ativa`, matéria,
// assunto e demais metadados permanecem intocados.
//
// Escopo:
//   - id 132: explicação cita "Artigo 50" (quesito raça), "Artigo 17" (datas comemorativas)
//             e "Artigo 20" (capoeira) — todos errados. Corrigido para Art. 18 (quesito raça),
//             Art. 11 (datas comemorativas) e Art. 14 (capoeira). O conteúdo/raciocínio já
//             estava correto (V-V-F, capoeira não é Kuduro); só a numeração dos artigos
//             estava errada. Gabarito D (ordem 4, V-V-F) preservado.
//   - id 367: explicação cita "Artigo 20" para a capoeira — errado. Corrigido para Art. 14.
//             Fundamentação reforçada: a alternativa B é a INCORRETA porque inverte o texto
//             legal — a Lei diz que a participação dos mestres tradicionais de capoeira é
//             FACULTADA, e a alternativa afirma que é OBRIGATÓRIA. Gabarito B (ordem 2)
//             preservado.
//
// Referência (Fase 2S-B, microanálise de leitura já entregue nesta sessão):
//   Art. 11 (datas comemorativas cívicas) / Art. 14 (capoeira, participação facultada de
//   mestres tradicionais) / Art. 18 (quesito raça, autoclassificação obrigatória) da Lei
//   Estadual RS nº 13.694/2011.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2s-b_igualdade_racial_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2s-b_igualdade_racial_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração.
// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
const HASH_QUESTAO_ANTES = {
  132: '93fff4839caedd121cb3a33690ed1ccc',
  367: '1a314728ac4dbd9239d9bae027fbe54d',
};

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
const HASH_EXPLICACAO_ANTES = {
  132: '9cbe461900aef9000576a0e22c383e08',
  367: 'e1c1b60a02f7993efc4f94f9e03c9b9d',
};

// Ordem da alternativa correta (gabarito) de cada questão do lote — inalterado nesta fase
const GABARITO = { 132: 4, 367: 2 };

// --------------------------------------------------------------------------
// Textos novos das explicações
// --------------------------------------------------------------------------

const EXPLICACAO_NOVA_132 = `GABARITO: alternativa D\r
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

const EXPLICACAO_NOVA_367 = `GABARITO: alternativa B (é a alternativa INCORRETA)\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA (E É O GABARITO):\r
O Artigo 14 da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial) dispõe: "Nas instituições de ensino, públicas e privadas, deverá ser oportunizado o aprendizado e a prática da capoeira, como atividade esportiva, cultural e lúdica, sendo FACULTADA a participação dos mestres tradicionais de capoeira para atuarem como instrutores desta arte-esporte." A alternativa altera o sentido do dispositivo legal ao afirmar que essa participação é "OBRIGATÓRIA" — o texto da lei é exatamente o oposto: a participação dos mestres tradicionais é facultativa, não obrigatória. Essa inversão de palavra-chave (facultada → obrigatória) é o que torna a alternativa incorreta, e não a simples menção à capoeira.\r
\r
POR QUE AS DEMAIS ALTERNATIVAS ESTÃO CORRETAS:\r
As alternativas A, C, D e E reproduzem, sem alteração de sentido, disposições do Estatuto Estadual da Igualdade Racial (Lei nº 13.694/2011) sobre saúde da população negra, comunidades quilombolas, acesso ao ensino e a atividades esportivas, e respeito à diversidade racial nas instituições de ensino — por isso não são a alternativa a ser assinalada.\r
\r
BIZU DE PROVA:\r
Capoeira nas escolas (Art. 14 da Lei Estadual RS 13.694/2011):\r
A participação dos mestres tradicionais de capoeira como instrutores é FACULTADA, nunca obrigatória — fique atento a essa inversão clássica de banca!`;

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2S-B — ESTATUTO ESTADUAL DA IGUALDADE RACIAL (LEI ESTADUAL RS 13.694/2011)
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

  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_132)}, atualizado_em = now() WHERE id = 132;
  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_367)}, atualizado_em = now() WHERE id = 367;

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
  IF (SELECT count(*) FROM public.questoes WHERE id IN (132, 367) AND ativa = true) <> 2 THEN
    RAISE EXCEPTION 'Assert 2 falhou: status ativa alterado indevidamente em alguma questão do lote';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão, 5 alternativas presentes
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas WHERE questao_id IN (132, 367)) <> 2 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id IN (132, 367)) <> 10 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas
        WHERE questao_id IN (132, 367)
        GROUP BY questao_id
       HAVING count(*) FILTER (WHERE correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: alternativas divergentes do estado esperado (5 por questão, exatamente 1 correta)';
  END IF;

  -- Assert 4: Gabaritos oficiais preservados em cada uma das 2 questões
${Object.entries(GABARITO).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ordem} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência em gabarito oficial da questão ${id} (esperado ordem ${ordem})';
  END IF;`).join('\n')}

  -- Assert 5: Hash da questão (enunciado+fonte+banca+concurso+materia+assunto+ativa) permanece
  -- EXATAMENTE IGUAL ao capturado antes — prova de que nada além de "explicacao" foi tocado
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão ${id} (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;`).join('\n')}

  -- Assert 6: Questão 132 - explicação contém os três artigos corretos da Lei 13.694/2011
  -- (Art. 18, Art. 11 e Art. 14) e não contém mais os números errados anteriores
  -- (Artigo 50, Artigo 17 e Artigo 20 usados como fundamento das três assertivas)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 132;
  IF v_explicacao_check NOT ILIKE '%Artigo 18%' OR
     v_explicacao_check NOT ILIKE '%Artigo 11%' OR
     v_explicacao_check NOT ILIKE '%Artigo 14%' OR
     v_explicacao_check NOT ILIKE '%Kuduro%' OR
     v_explicacao_check ILIKE '%Artigo 50%' OR
     v_explicacao_check ILIKE '%Artigo 17%' OR
     v_explicacao_check ILIKE '%Artigo 20%' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão 132 incorreta ou ainda contendo número de artigo errado';
  END IF;

  -- Assert 7: Questão 367 - explicação contém o artigo correto (Art. 14) e a fundamentação
  -- reforçada da inversão facultada/obrigatória, e não contém mais o número errado (Art. 20)
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 367;
  IF v_explicacao_check NOT ILIKE '%Artigo 14%' OR
     v_explicacao_check NOT ILIKE '%FACULTADA%' OR
     v_explicacao_check NOT ILIKE '%OBRIGATÓRIA%' OR
     v_explicacao_check ILIKE '%Artigo 20%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 367 incorreta ou ainda contendo número de artigo errado / sem a fundamentação da inversão facultada-obrigatória';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2S-B (ESTATUTO ESTADUAL DA IGUALDADE RACIAL) PASSARAM COM SUCESSO!';
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
