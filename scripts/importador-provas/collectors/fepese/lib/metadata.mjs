// Monta o metadata.json no formato esperado pelo importador já existente
// (scripts/importador-provas/cli.mjs). Nunca inventa campo que não foi
// confirmado — banca/orgao/cargo/ano ausentes ficam null e a confiança
// cai para "baixa", nunca um palpite.

export function montarMetadataConcurso({ banca, ano, orgao, cargo, nomeProva, fonteUrl, fonteTipo }) {
  const camposObrigatorios = { banca, ano, orgao, cargo };
  const faltando = Object.entries(camposObrigatorios)
    .filter(([, valor]) => valor === null || valor === undefined || valor === "")
    .map(([chave]) => chave);

  return {
    metadata: {
      banca: banca ?? null,
      ano: ano ?? null,
      orgao: orgao ?? null,
      cargo: cargo ?? null,
      nome_prova: nomeProva ?? null,
      fonte_url: fonteUrl ?? null,
      fonte_tipo: fonteTipo ?? "oficial",
    },
    confidence: faltando.length > 0 ? "baixa" : "alta",
    camposFaltando: faltando,
  };
}
