// Manifesto de gabaritos de UMA prova: exatamente um gabarito base e
// 0..N retificações, cada uma com ORDEM explícita (nunca deduzida do nome
// do arquivo). Formato:
//   {
//     "gabaritos": [
//       { "tipo": "definitivo", "arquivo": "gabarito.pdf", "bloco": "24 - Policial Penal" },
//       { "tipo": "retificacao", "ordem": 1, "arquivo": "retificacao-1.pdf",
//         "documento": "Edital nº 27/2026", "url": "https://...", "bloco": null }
//     ]
//   }
// Caminhos relativos ao próprio manifesto. A URL do gabarito base continua
// vindo de metadata.json (gabarito_url), como antes.
// Estado final composto (definitivo consolidado não público):
//   { "estado_final": "composto", "gabaritos": [
//       { "tipo": "preliminar", "arquivo": "preliminar.html" },
//       { "tipo": "retificacao", "ordem": 1, "natureza": "justificativa_recursos", "bloco": "<cargo exato>", ... },
//       { "tipo": "retificacao", "ordem": 2, "arquivo": "edital-posterior.pdf", ... } ] }

import fs from "node:fs";
import path from "node:path";

// "preliminar" = gabarito publicado antes dos recursos: aceito para medir
// a extração, mas o planejador bloqueia qualquer apply com ele.
const TIPOS_BASE = ["definitivo", "base", "preliminar"];
// Natureza de uma retificação: ato retificativo (padrão) ou justificativa
// oficial dos recursos (decisão sobre o preliminar, por cargo).
const NATUREZAS = ["retificacao", "justificativa_recursos"];

export function lerManifestoDeGabaritos(caminho) {
  const conteudo = JSON.parse(fs.readFileSync(caminho, "utf8"));
  const diretorio = path.dirname(caminho);
  const entradas = Array.isArray(conteudo?.gabaritos) ? conteudo.gabaritos : null;
  if (!entradas) throw new Error(`manifesto de gabaritos "${caminho}" sem a lista "gabaritos"`);

  const bases = entradas.filter((e) => TIPOS_BASE.includes(e.tipo));
  const retificacoes = entradas.filter((e) => e.tipo === "retificacao");
  const desconhecidas = entradas.filter((e) => !TIPOS_BASE.includes(e.tipo) && e.tipo !== "retificacao");
  if (bases.length !== 1) throw new Error(`manifesto de gabaritos precisa de exatamente 1 gabarito base (tipo "definitivo" ou "preliminar"), veio ${bases.length}`);
  if (desconhecidas.length > 0) throw new Error(`tipo de gabarito desconhecido: ${desconhecidas.map((e) => JSON.stringify(e.tipo)).join(", ")}`);

  const resolver = (arquivo) => {
    if (typeof arquivo !== "string" || !arquivo.trim()) throw new Error("entrada do manifesto de gabaritos sem \"arquivo\"");
    const absoluto = path.resolve(diretorio, arquivo);
    if (!fs.existsSync(absoluto)) throw new Error(`arquivo de gabarito não encontrado: ${absoluto}`);
    return absoluto;
  };

  // Estado final COMPOSTO: o gabarito definitivo consolidado não é público,
  // mas o estado final de cada questão sai inteiro de documentos oficiais —
  // gabarito PRELIMINAR (base) + justificativa dos recursos DO CARGO
  // (natureza "justificativa_recursos", sempre com bloco = cargo) + atos
  // posteriores, na ordem explícita. O preliminar continua registrado como
  // preliminar; só o estado final é "composto".
  const estadoFinal = conteudo.estado_final ?? null;
  if (estadoFinal !== null && estadoFinal !== "composto") throw new Error(`estado_final desconhecido: ${JSON.stringify(estadoFinal)} (use "composto")`);
  for (const r of retificacoes) {
    if (r.natureza !== undefined && !NATUREZAS.includes(r.natureza)) throw new Error(`natureza de retificação desconhecida: ${JSON.stringify(r.natureza)} (use ${NATUREZAS.map((n) => `"${n}"`).join(" ou ")})`);
  }
  if (estadoFinal === "composto") {
    if (bases[0].tipo !== "preliminar") throw new Error('estado_final "composto" exige gabarito base do tipo "preliminar" (o preliminar nunca é chamado de definitivo)');
    const justificativas = retificacoes.filter((r) => r.natureza === "justificativa_recursos");
    if (justificativas.length === 0) throw new Error('estado_final "composto" exige ao menos uma retificação de natureza "justificativa_recursos" (a decisão oficial dos recursos)');
    if (justificativas.some((r) => typeof r.bloco !== "string" || !r.bloco.trim())) throw new Error('justificativa_recursos sem escopo: informe "bloco" com o cargo exato da seção da justificativa');
  }

  return {
    base: { arquivo: resolver(bases[0].arquivo), bloco: bases[0].bloco ?? null, tipo: bases[0].tipo === "preliminar" ? "preliminar" : "definitivo" },
    ...(estadoFinal ? { estadoFinal } : {}),
    retificacoes: retificacoes.map((r) => ({
      arquivo: resolver(r.arquivo),
      ordem: r.ordem,
      documento: typeof r.documento === "string" && r.documento.trim() ? r.documento.trim() : path.basename(r.arquivo),
      url: r.url ?? null,
      bloco: r.bloco ?? null,
      ...(r.natureza !== undefined ? { natureza: r.natureza } : {}),
    })),
  };
}

// Mesma regra para base e retificação: com mais de um bloco no documento,
// só um bloco explicitamente escolhido; par sem bloco rotulado não tem
// dono conhecido e fica de fora (nunca combinamos documentos/cargos).
// Seção de justificativa ("CARGO(S): A, B, C" — extrairGabarito.mjs): o
// bloco pedido precisa ser EXATAMENTE um dos cargos da lista (sem acento,
// caixa ou espaço extra) — "Procurador" nunca casa "Procurador da Fazenda".
const normalizarCargo = (t) => String(t).normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase().replace(/\s+/g, " ").trim();
function entradaDoBloco(g, alvo) {
  if (!g.bloco) return false;
  if (Array.isArray(g.cargos)) return g.cargos.some((c) => normalizarCargo(c) === normalizarCargo(alvo));
  return g.bloco.toLowerCase().includes(String(alvo).toLowerCase());
}

export function selecionarBloco(gabaritos, bloco, descricao) {
  const blocosDistintos = [...new Set(gabaritos.map((g) => g.bloco).filter(Boolean))];
  if (bloco) {
    const selecionados = gabaritos.filter((g) => entradaDoBloco(g, bloco));
    if (selecionados.length === 0) {
      throw new Error(`Nenhuma entrada de ${descricao} bate com o bloco "${bloco}". Blocos disponíveis: ${blocosDistintos.join(" | ") || "(nenhum bloco rotulado encontrado)"}`);
    }
    return selecionados;
  }
  if (blocosDistintos.length > 1) {
    throw new Error(
      `${descricao} tem ${blocosDistintos.length} blocos distintos (${blocosDistintos.join(" | ")}) — informe o bloco para escolher um. ` +
        "Nunca combinamos blocos diferentes automaticamente (números podem se repetir entre blocos de cargos diferentes, e misturá-los corromperia o pareamento).",
    );
  }
  return gabaritos;
}
