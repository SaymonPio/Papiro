import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Regressão do bug: o link "Ver PDF da aula" existia, mas ficava depois dos
// 11 componentes + comentários, praticamente invisível sem rolar bastante a
// página. Este teste trava (1) que o link usa a versão já resolvida
// dinamicamente pelo próprio preview (aulaVersaoIdAtual), nunca dependente
// só de ?versao= estar na URL, e (2) que ele aparece ANTES do primeiro
// componente da aula no código-fonte (garantindo a posição no topo).

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const previewPage = readFileSync(path.join(raizProjeto, "app/admin/aulas/preview/page.tsx"), "utf8");

test("o link de PDF admin usa aulaVersaoIdAtual (versão já resolvida dinamicamente), não um UUID fixo", () => {
  assert.match(previewPage, /aula_versao_id=\$\{aulaVersaoIdAtual\}/);
});

test("o link de PDF admin não depende de aula.aula_versao_id (só disponível após a aula terminar de carregar)", () => {
  assert.doesNotMatch(previewPage, /aula_versao_id=\$\{aula\.aula_versao_id\}/);
});

test("nenhum id/uuid de curso, conteúdo, unidade ou aula está hardcoded no link de PDF admin", () => {
  const trechoLink = previewPage.slice(previewPage.indexOf("Ver PDF da aula") - 300, previewPage.indexOf("Ver PDF da aula") + 100);
  assert.doesNotMatch(trechoLink, /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i);
  assert.doesNotMatch(trechoLink, /curso_conteudo_id\s*=\s*73/);
});

test("o link de PDF admin aparece ANTES do primeiro componente da aula (nunca escondido no fim da rolagem)", () => {
  const posicaoLink = previewPage.indexOf("Ver PDF da aula");
  const posicaoComponentes = previewPage.indexOf("componentes.map((componente, i) =>");
  assert.ok(posicaoLink > -1, "link 'Ver PDF da aula' deveria existir no arquivo");
  assert.ok(posicaoComponentes > -1, "renderização dos componentes deveria existir no arquivo");
  assert.ok(posicaoLink < posicaoComponentes, "o link deveria vir ANTES da lista de componentes no JSX");
});

test("existe só UM ponto de acesso ao PDF admin nesta tela (sem duplicar/confundir)", () => {
  // Conta ocorrências do link real (href), não a string solta -- que
  // também aparece uma vez dentro do comentário explicativo acima dele.
  const ocorrencias = previewPage.split('href={`/teoria/imprimir?admin=1&aula_versao_id=').length - 1;
  assert.equal(ocorrencias, 1);
});

test("o link de PDF admin usa o modo admin=1 (nunca a rota de aluno sem esse parâmetro)", () => {
  assert.match(previewPage, /\/teoria\/imprimir\?admin=1&aula_versao_id=/);
});
