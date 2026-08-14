import assert from "node:assert/strict";
import test from "node:test";
import {
  lerMissaoCronograma,
  lerMissionId,
  montarLinkMissao,
  montarLinkTeoria,
  podeIniciarMissaoAutomaticamente,
} from "../utils/missao-cronograma.mjs";

const MISSION_ID = "a1b2c3d4-e5f6-4789-a012-3456789abcde";

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
    missionId: null,
    refazer: false,
  });
});

test("não transforma uma visita comum a questões em missão", () => {
  assert.equal(lerMissaoCronograma("materia=7&assunto=19"), null);
  assert.equal(montarLinkMissao({ materiaId: null }), "/questoes");
});

test("a missão agora abre pela teoria, com os mesmos parâmetros que iriam para questões", () => {
  const linkTeoria = montarLinkTeoria({
    cursoMateriaId: 40,
    conteudoId: 88,
    materiaId: 7,
    assuntoId: 19,
    quantidade: 12,
  });

  assert.match(linkTeoria, /^\/teoria\?/);

  const missaoDaTeoria = lerMissaoCronograma(linkTeoria.split("?")[1]);
  const missaoDasQuestoes = lerMissaoCronograma(
    montarLinkMissao({ cursoMateriaId: 40, conteudoId: 88, materiaId: 7, assuntoId: 19, quantidade: 12 }).split(
      "?",
    )[1],
  );

  // Mesma matéria/assunto/cursoMateria/conteúdo/quantidade nos dois destinos
  // — a teoria e as questões precisam apontar para a mesma missão.
  assert.deepEqual(missaoDaTeoria, missaoDasQuestoes);
});

test("sem matéria, teoria cai no mesmo fallback que questões", () => {
  assert.equal(montarLinkTeoria({ materiaId: null }), "/questoes");
});

test("montarLinkTeoria com missionId inclui missao=<uuid> e preserva o resto dos parâmetros", () => {
  const link = montarLinkTeoria({
    cursoMateriaId: 40,
    conteudoId: 88,
    materiaId: 7,
    assuntoId: 19,
    quantidade: 12,
    missionId: MISSION_ID,
    refazer: false,
  });

  assert.match(link, /^\/teoria\?/);

  const parametros = new URLSearchParams(link.split("?")[1]);
  assert.equal(parametros.get("missao"), MISSION_ID);
  assert.equal(parametros.get("origem"), "cronograma");
  assert.equal(parametros.get("materia"), "7");
  assert.equal(parametros.get("assunto"), "19");
  assert.equal(parametros.get("cursoMateria"), "40");
  assert.equal(parametros.get("conteudo"), "88");
  assert.equal(parametros.get("quantidade"), "12");

  const missao = lerMissaoCronograma(link.split("?")[1]);
  assert.deepEqual(missao, {
    materiaId: 7,
    assuntoId: 19,
    cursoMateriaId: 40,
    conteudoId: 88,
    quantidade: 12,
    missionId: MISSION_ID,
    refazer: false,
  });
});

test("montarLinkTeoria sem missionId não inclui missao na URL (compatibilidade)", () => {
  const link = montarLinkTeoria({ cursoMateriaId: 40, conteudoId: 88, materiaId: 7, assuntoId: 19, quantidade: 12 });
  const parametros = new URLSearchParams(link.split("?")[1]);

  assert.equal(parametros.has("missao"), false);
  assert.equal(lerMissaoCronograma(link.split("?")[1]).missionId, null);
});

test("montarLinkMissao com missionId também inclui missao=<uuid> (sem regressão do comportamento anterior)", () => {
  const semMissao = montarLinkMissao({ cursoMateriaId: 40, conteudoId: 88, materiaId: 7, assuntoId: 19, quantidade: 12 });
  assert.equal(new URLSearchParams(semMissao.split("?")[1]).has("missao"), false);

  const comMissao = montarLinkMissao({
    cursoMateriaId: 40,
    conteudoId: 88,
    materiaId: 7,
    assuntoId: 19,
    quantidade: 12,
    missionId: MISSION_ID,
  });
  assert.match(comMissao, /^\/questoes\?/);
  assert.equal(new URLSearchParams(comMissao.split("?")[1]).get("missao"), MISSION_ID);
});

test("refazer é preservado da teoria até as questões sem contaminar uma missão normal", () => {
  const teoria = montarLinkTeoria({
    cursoMateriaId: 40,
    conteudoId: 88,
    materiaId: 7,
    assuntoId: 19,
    missionId: MISSION_ID,
    refazer: true,
  });
  const contexto = lerMissaoCronograma(teoria.split("?")[1]);

  assert.equal(contexto.refazer, true);
  assert.equal(new URLSearchParams(teoria.split("?")[1]).get("refazer"), "1");

  const questoes = montarLinkMissao({ ...contexto });
  assert.equal(new URLSearchParams(questoes.split("?")[1]).get("refazer"), "1");
  assert.equal(lerMissaoCronograma("origem=cronograma&materia=7").refazer, false);
});

test("lerMissaoCronograma descarta um parâmetro missao malformado", () => {
  const missao = lerMissaoCronograma("origem=cronograma&materia=7&missao=nao-e-um-uuid");
  assert.equal(missao.missionId, null);
});

test("lerMissionId extrai o mission_id mesmo sem materia/origem=cronograma (/teoria?missao=<uuid>)", () => {
  assert.equal(lerMissionId(`missao=${MISSION_ID}`), MISSION_ID);
  // sem nenhum outro parâmetro na URL, nem origem=cronograma
  assert.equal(lerMissaoCronograma(`missao=${MISSION_ID}`), null);
});

test("lerMissionId rejeita um missao malformado/ausente", () => {
  assert.equal(lerMissionId("missao=nao-e-um-uuid"), null);
  assert.equal(lerMissionId(""), null);
  assert.equal(lerMissionId("origem=cronograma&materia=7"), null);
});

test("inicia automaticamente quando os dados da missão estão prontos", () => {
  assert.equal(
    podeIniciarMissaoAutomaticamente({
      origemCronograma: true,
      jaIniciada: false,
      materiaId: 7,
      materiasDisponiveis: [7, 9, 18],
      carregandoMaterias: false,
      carregandoAssuntos: false,
      assuntoPendente: false,
    }),
    true,
  );
});

test("aguarda o assunto e impede uma segunda sessão automática", () => {
  const base = {
    origemCronograma: true,
    materiaId: 7,
    materiasDisponiveis: [7],
    carregandoMaterias: false,
    carregandoAssuntos: false,
  };

  assert.equal(
    podeIniciarMissaoAutomaticamente({ ...base, jaIniciada: false, assuntoPendente: true }),
    false,
  );
  assert.equal(
    podeIniciarMissaoAutomaticamente({ ...base, jaIniciada: true, assuntoPendente: false }),
    false,
  );
});
