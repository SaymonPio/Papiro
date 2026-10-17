import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Robustez estrutural do layout da QUESTÃO ATIVA (app/questoes/page.tsx) após
// a rodada de compactação de densidade/cabeçalho. Garante, por leitura
// estática de código (nunca por pixel exato — este arquivo não mede nada,
// só confirma a AUSÊNCIA de padrões que cortariam/esconderiam conteúdo),
// que o layout continua seguro para questões curtas, médias e longas,
// independentemente do tamanho específico do enunciado atual.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const globalsCss = readFileSync(path.join(raizProjeto, "app/globals.css"), "utf8");
const questoesPage = readFileSync(path.join(raizProjeto, "app/questoes/page.tsx"), "utf8");

function blocosDoSeletor(css, seletor) {
  const blocos = [];
  let cursor = 0;
  for (;;) {
    const inicio = css.indexOf(`${seletor} {`, cursor);
    if (inicio === -1) break;
    const fim = css.indexOf("}", inicio);
    blocos.push(css.slice(inicio, fim));
    cursor = fim + 1;
  }
  return blocos;
}

test("A) nenhuma ocorrência de .question-card (nem .question-card h1) define max-height, overflow, line-clamp, text-overflow ou white-space:nowrap — questão longa nunca é cortada/escondida", () => {
  for (const seletor of [".question-card", ".question-card h1"]) {
    const blocos = blocosDoSeletor(globalsCss, seletor);
    assert.ok(blocos.length > 0, `esperava pelo menos um bloco "${seletor}" em globals.css`);
    for (const bloco of blocos) {
      assert.doesNotMatch(bloco, /max-height/);
      assert.doesNotMatch(bloco, /overflow/);
      assert.doesNotMatch(bloco, /line-clamp/);
      assert.doesNotMatch(bloco, /text-overflow/);
      assert.doesNotMatch(bloco, /white-space:\s*nowrap/);
    }
  }
});

test("B) nenhum seletor global de .answer-choice define height fixa (só min-height) — alternativa de 2+ linhas cresce livremente", () => {
  const blocos = blocosDoSeletor(globalsCss, ".answer-choice");
  assert.ok(blocos.length > 0, "esperava pelo menos um bloco .answer-choice");
  for (const bloco of blocos) {
    // min-height é permitido (piso de clique confortável); height: fixo não.
    assert.doesNotMatch(bloco, /(?<!min-)(?<!max-)\bheight:\s*\d/);
  }
});

test("C) nenhum seletor global de .answer-choice/.question-card/.answer-list/.answer-option-row/.answer-submit usa position absolute/fixed — CTA nunca pode ficar sobreposto às alternativas", () => {
  for (const seletor of [".question-card", ".answer-list", ".answer-option-row", ".answer-choice", ".answer-submit"]) {
    const blocos = blocosDoSeletor(globalsCss, seletor);
    for (const bloco of blocos) {
      assert.doesNotMatch(bloco, /position:\s*(absolute|fixed)/);
    }
  }
});

test("D) .answer-option-row reserva a coluna de texto com minmax(0, ...) — pré-condição para o texto da alternativa quebrar linha em vez de estourar o card", () => {
  const bloco = blocosDoSeletor(globalsCss, ".answer-option-row")[0];
  assert.ok(bloco, "esperava um bloco .answer-option-row");
  assert.match(bloco, /grid-template-columns:\s*minmax\(0,/);
});

test("E) globals.css não usa -webkit-line-clamp em nenhum lugar relacionado à questão/alternativas — nenhum truncamento de texto foi introduzido", () => {
  assert.doesNotMatch(globalsCss, /-webkit-line-clamp/);
});

test("F) no JSX, o CTA da questão ativa (Confirmar resposta / Próxima questão) aparece DEPOIS de .answer-list no fluxo normal do documento — nunca antes, nunca sobreposto", () => {
  const idxAnswerList = questoesPage.indexOf('className="answer-list"');
  // lastIndexOf de propósito: "answer-submit" também estiliza o botão
  // "Iniciar sessão" da tela de preparação (className reaproveitado para
  // visual, não é o mesmo botão) — o da questão ativa é sempre o último
  // no arquivo, depois de .answer-list.
  const idxAnswerSubmit = questoesPage.lastIndexOf('className="answer-submit"');
  const idxAnswerFeedbackNext = questoesPage.lastIndexOf('className="answer-feedback-next"');
  assert.ok(idxAnswerList > -1 && idxAnswerSubmit > -1 && idxAnswerFeedbackNext > -1);
  assert.ok(idxAnswerList < idxAnswerSubmit, "answer-submit da questão ativa deveria vir depois de answer-list no JSX");
  assert.ok(idxAnswerList < idxAnswerFeedbackNext, "answer-feedback-next deveria vir depois de answer-list no JSX");
});

test("G) ComentariosQuestao (recursos secundários) renderiza DEPOIS do fechamento de .question-card — comentários sempre abaixo do CTA, nunca disputando a mesma dobra", () => {
  const idxFimQuestionCard = questoesPage.indexOf("</article>");
  const idxComentarios = questoesPage.indexOf("<ComentariosQuestao");
  assert.ok(idxFimQuestionCard > -1 && idxComentarios > -1);
  assert.ok(idxFimQuestionCard < idxComentarios, "ComentariosQuestao deveria vir depois do </article> do question-card");
});
