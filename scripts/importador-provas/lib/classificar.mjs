// Sugestão de materia_id/assunto_id — NUNCA cria matéria/assunto novo,
// só tenta casar contra uma taxonomia real já existente no Papiro
// (snapshot local, mesmo espírito do snapshot de questões usado em
// scripts/dedupe-lote1-vs-supabase.js — sem depender de conexão viva com
// o banco nesta PoC).
//
// Regra de correspondência EXATA (nome do assunto === nome completo da
// matéria, trim, sem normalização de acento/caixa) é a mesma já usada em
// supabase/importar_questoes_lote.sql (importar_questoes_dry_run) — se o
// nome bater exatamente contra algum campo textual já conhecido (ex.: um
// cabeçalho de disciplina detectado no PDF), confiança alta. Quando não há
// esse sinal explícito, cai para um heurístico fraco (o nome do assunto
// aparece como substring dentro do enunciado) — confiança baixa, NUNCA
// "média" ou mais, porque é só uma coincidência textual, não uma
// classificação pedagógica real.

function normalizar(texto) {
  return (texto ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

const TAMANHO_MINIMO_SUBSTRING = 12;

export function classificarMateriaAssunto(questaoNormalizada, taxonomia, cabecalhoDisciplina = null) {
  const materias = taxonomia?.materias ?? [];
  const assuntos = taxonomia?.assuntos ?? [];

  if (cabecalhoDisciplina) {
    const alvo = normalizar(cabecalhoDisciplina);
    const materiaExata = materias.find((m) => normalizar(m.nome) === alvo);
    if (materiaExata) {
      return {
        materia_id: materiaExata.id,
        assunto_id: null,
        confidence: "alta",
        motivo: "cabecalho de disciplina bate exatamente com materia conhecida",
      };
    }
  }

  const enunciadoNormalizado = normalizar(questaoNormalizada.enunciado);
  let melhorAssunto = null;
  for (const assunto of assuntos) {
    const nomeNormalizado = normalizar(assunto.nome);
    if (nomeNormalizado.length < TAMANHO_MINIMO_SUBSTRING) continue;
    if (enunciadoNormalizado.includes(nomeNormalizado)) {
      if (!melhorAssunto || nomeNormalizado.length > normalizar(melhorAssunto.nome).length) melhorAssunto = assunto;
    }
  }

  if (melhorAssunto) {
    // Confiança "baixa" por definição NUNCA preenche materia_id/assunto_id
    // no resultado oficial (regra explícita do produto) — o candidato fica
    // só em materia_id_candidato/assunto_id_candidato, para auditoria e
    // para quem revisar manualmente decidir se confirma.
    return {
      materia_id: null,
      assunto_id: null,
      materia_id_candidato: melhorAssunto.materia_id,
      assunto_id_candidato: melhorAssunto.id,
      confidence: "baixa",
      motivo: `nome do assunto "${melhorAssunto.nome}" aparece no enunciado — coincidencia textual, nao classificacao pedagogica confirmada; status forcado para revisao_manual`,
    };
  }

  return { materia_id: null, assunto_id: null, confidence: "nenhuma", motivo: "nenhum sinal de classificacao encontrado" };
}
