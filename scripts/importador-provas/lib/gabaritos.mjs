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

import fs from "node:fs";
import path from "node:path";

// "preliminar" = gabarito publicado antes dos recursos: aceito para medir
// a extração, mas o planejador bloqueia qualquer apply com ele.
const TIPOS_BASE = ["definitivo", "base", "preliminar"];

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

  return {
    base: { arquivo: resolver(bases[0].arquivo), bloco: bases[0].bloco ?? null, tipo: bases[0].tipo === "preliminar" ? "preliminar" : "definitivo" },
    retificacoes: retificacoes.map((r) => ({
      arquivo: resolver(r.arquivo),
      ordem: r.ordem,
      documento: typeof r.documento === "string" && r.documento.trim() ? r.documento.trim() : path.basename(r.arquivo),
      url: r.url ?? null,
      bloco: r.bloco ?? null,
    })),
  };
}

// Mesma regra para base e retificação: com mais de um bloco no documento,
// só um bloco explicitamente escolhido; par sem bloco rotulado não tem
// dono conhecido e fica de fora (nunca combinamos documentos/cargos).
export function selecionarBloco(gabaritos, bloco, descricao) {
  const blocosDistintos = [...new Set(gabaritos.map((g) => g.bloco).filter(Boolean))];
  if (bloco) {
    const alvo = String(bloco).toLowerCase();
    const selecionados = gabaritos.filter((g) => g.bloco && g.bloco.toLowerCase().includes(alvo));
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
