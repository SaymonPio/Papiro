import assert from "node:assert/strict";
import test from "node:test";
import { lerMissaoCronograma, montarLinkMissao } from "../utils/missao-cronograma.mjs";

test("leva a matéria e o assunto da missão do cronograma para questões", () => {
  const link = montarLinkMissao({
    cursoMateriaId: 40,
    conteudoId: 88,
    materiaId: 7,
    assuntoId: 19,
    quantidade: 12,
  });
  const missao = lerMissaoCronograma(link.split("?")[1]);

  assert.deepEqual(missao, {
    materiaId: 7,
    assuntoId: 19,
    cursoMateriaId: 40,
    conteudoId: 88,
    quantidade: 12,
  });
});

test("não transforma uma visita comum a questões em missão", () => {
  assert.equal(lerMissaoCronograma("materia=7&assunto=19"), null);
  assert.equal(montarLinkMissao({ materiaId: null }), "/questoes");
});
