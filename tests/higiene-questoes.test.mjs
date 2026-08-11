import assert from "node:assert/strict";
import test from "node:test";
import {
  limparResiduoImportacao,
  temResiduoImportacao,
} from "../utils/higiene-questoes.mjs";

test("remove o rodapé de importação anexado à alternativa", () => {
  const contaminada =
    "As férias e as licenças. 973_BASE_NM_DT 09/06/2025 10:22:44 SOLDADO BOMBEIRO MILITAR PRIMEIRA CLASSE";

  assert.equal(temResiduoImportacao(contaminada), true);
  assert.equal(limparResiduoImportacao(contaminada), "As férias e as licenças.");
});

test("preserva alternativas legítimas", () => {
  const legitima = "A base legal para a concessão das férias e das licenças.";

  assert.equal(temResiduoImportacao(legitima), false);
  assert.equal(limparResiduoImportacao(legitima), legitima);
});
