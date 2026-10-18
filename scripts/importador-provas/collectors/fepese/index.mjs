// Coletor FEPESE — implementa a interface comum de coletores definida
// para o importador de provas. O importador (scripts/importador-provas/
// cli.mjs) NUNCA importa nada deste diretório — é este arquivo que, uma
// vez com prova.pdf/gabarito.pdf/metadata.json em mãos, invoca o
// cli.mjs já existente (ver executar.mjs). Nenhuma lógica de parsing de
// PDF vive aqui.
//
// DESCOBERTA vs DOWNLOAD/PROCESSAMENTO — separação deliberada:
// buscarConcursos() é 100% local (lê indice-concursos.json, nunca toca
// rede) porque a listagem oficial da FEPESE não é crawlable de forma
// estável (cada concurso vive num subdomínio com slug arbitrário, sem
// catálogo central — confirmado no raio-x das bancas). Esse índice é
// um modelo HÍBRIDO explícito: pré-descoberto por meios legítimos
// (WebSearch), nunca por scraping do site da banca. Todas as funções
// a partir de listarProvas() usam rede real, só contra o domínio já
// confirmado do próprio concurso — nunca QConcursos ou outro agregador.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { extrairDocumentosDoHtml } from "./lib/parseHtml.mjs";
import { casarProvaComGabarito } from "./lib/pareamento.mjs";
import { validarPdfBuffer, calcularHashSha256 } from "./lib/validacao.mjs";
import { montarMetadataConcurso } from "./lib/metadata.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const PALAVRAS_PADRAO = ["policia", "policial", "guarda", "agente", "seguranca"];

function normalizar(texto) {
  return (texto ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "");
}

function carregarIndice() {
  const caminho = path.join(__dirname, "indice-concursos.json");
  return JSON.parse(fs.readFileSync(caminho, "utf8"));
}

export function buscarConcursos({ palavraChave, anoMin, anoMax } = {}) {
  const indice = carregarIndice();
  const palavras = (Array.isArray(palavraChave) ? palavraChave : palavraChave ? [palavraChave] : PALAVRAS_PADRAO).map(normalizar);

  return indice.filter((concurso) => {
    const texto = normalizar(`${concurso.orgao} ${(concurso.cargosConhecidos ?? []).join(" ")} ${concurso.titulo ?? ""}`);
    const batePalavra = palavras.some((p) => texto.includes(p));
    const bateAno = (anoMin === undefined || concurso.ano >= anoMin) && (anoMax === undefined || concurso.ano <= anoMax);
    return batePalavra && bateAno;
  });
}

export async function listarProvas(concurso) {
  const resposta = await fetch(concurso.url);
  if (!resposta.ok) throw new Error(`Falha ao listar documentos de ${concurso.url}: HTTP ${resposta.status}`);
  const html = await resposta.text();
  return extrairDocumentosDoHtml(html, concurso.url);
}

export async function obterDocumentos(concurso) {
  const documentos = await listarProvas(concurso);
  const pares = casarProvaComGabarito(documentos);
  return pares.map((par) => ({ ...par, concurso }));
}

async function baixarArquivo(url, destino) {
  const resposta = await fetch(url);
  if (!resposta.ok) throw new Error(`HTTP ${resposta.status} ao baixar ${url}`);
  const contentType = resposta.headers.get("content-type") ?? "";
  const buffer = Buffer.from(await resposta.arrayBuffer());

  const validacao = validarPdfBuffer(buffer);
  if (!validacao.valido) {
    throw new Error(`Download de ${url} rejeitado: ${validacao.motivo}`);
  }

  const hash = calcularHashSha256(buffer);

  if (fs.existsSync(destino)) {
    const hashExistente = calcularHashSha256(fs.readFileSync(destino));
    if (hashExistente !== hash) {
      throw new Error(
        `Recusado sobrescrever ${destino}: já existe um arquivo DIFERENTE neste caminho ` +
          `(hash existente ${hashExistente.slice(0, 12)}... != novo ${hash.slice(0, 12)}...). ` +
          `Apague ou mova manualmente antes de rebaixar.`,
      );
    }
    return { destino, hash, httpStatus: resposta.status, contentType, bytes: buffer.length, reutilizado: true };
  }

  fs.mkdirSync(path.dirname(destino), { recursive: true });
  fs.writeFileSync(destino, buffer);
  return { destino, hash, httpStatus: resposta.status, contentType, bytes: buffer.length, reutilizado: false };
}

export async function baixarProva(par, destino) {
  if (!par.prova) throw new Error("Par sem prova — nada para baixar");
  return baixarArquivo(par.prova.url, destino);
}

export async function baixarGabarito(par, destino) {
  if (!par.gabarito) throw new Error("Par sem gabarito pareado — nada para baixar (confira confidence antes de chamar)");
  return baixarArquivo(par.gabarito.url, destino);
}

export function montarMetadata(par) {
  const { concurso, prova } = par;
  return montarMetadataConcurso({
    banca: "FEPESE",
    ano: concurso.ano ?? null,
    orgao: concurso.orgao ?? null,
    cargo: prova.cargo ?? concurso.cargosConhecidos?.[0] ?? null,
    nomeProva: [concurso.orgao, concurso.ano, prova.cargo].filter(Boolean).join(" - ") || null,
    fonteUrl: prova.url,
    gabaritoUrl: par.gabarito?.url ?? null,
    fonteTipo: "oficial",
  });
}
