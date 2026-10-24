// Gabarito publicado só como PÁGINA HTML (sem PDF): a banca exibe a grade
// numa tabela (checado num caso real: Fundatec/PP-RS 2022, "Gabaritos
// Definitivos" do concurso 650). O documento oficial é o HTML — é ele que
// tem o hash registrado na proveniência; o texto abaixo é só a
// representação técnica que o extrator de gabarito lê, derivada de forma
// DETERMINÍSTICA (mesmos bytes -> mesmo texto), sem nenhuma edição manual:
//   - charset declarado na página; sem declaração, UTF-8 se os bytes forem
//     UTF-8 válido, senão Latin-1 (páginas antigas de bancas);
//   - <script>/<style> fora; entidades HTML decodificadas;
//   - uma linha por linha de tabela FOLHA (<tr> sem outra <tr> dentro —
//     tabelas de leiaute repetiriam o texto), células separadas por espaço.

import crypto from "node:crypto";

const ENTIDADES = {
  nbsp: " ", amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", ordm: "º", ordf: "ª", deg: "°", sect: "§", ndash: "–", mdash: "—",
  aacute: "á", agrave: "à", acirc: "â", atilde: "ã", auml: "ä", eacute: "é", egrave: "è", ecirc: "ê", euml: "ë", iacute: "í", igrave: "ì", icirc: "î", iuml: "ï",
  oacute: "ó", ograve: "ò", ocirc: "ô", otilde: "õ", ouml: "ö", uacute: "ú", ugrave: "ù", ucirc: "û", uuml: "ü", ccedil: "ç", ntilde: "ñ",
  Aacute: "Á", Agrave: "À", Acirc: "Â", Atilde: "Ã", Auml: "Ä", Eacute: "É", Egrave: "È", Ecirc: "Ê", Euml: "Ë", Iacute: "Í", Igrave: "Ì", Icirc: "Î", Iuml: "Ï",
  Oacute: "Ó", Ograve: "Ò", Ocirc: "Ô", Otilde: "Õ", Ouml: "Ö", Uacute: "Ú", Ugrave: "Ù", Ucirc: "Û", Uuml: "Ü", Ccedil: "Ç", Ntilde: "Ñ",
};

function decodificarBytes(bytes) {
  const cabeca = Buffer.from(bytes).subarray(0, 4096).toString("latin1");
  const declarado = (cabeca.match(/<meta[^>]+charset=["']?\s*([\w-]+)/i) ?? [])[1]?.toLowerCase();
  if (declarado === "utf-8" || declarado === "utf8") return new TextDecoder("utf-8").decode(bytes);
  if (declarado && /^(iso-8859-1|latin1|windows-1252|cp1252)$/.test(declarado)) return new TextDecoder("windows-1252").decode(bytes);
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return new TextDecoder("windows-1252").decode(bytes);
  }
}

function decodificarEntidades(texto) {
  return texto.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (inteira, nome) => {
    if (nome[0] === "#") {
      const codigo = nome[1].toLowerCase() === "x" ? parseInt(nome.slice(2), 16) : Number(nome.slice(1));
      return Number.isInteger(codigo) && codigo > 0 && codigo <= 0x10ffff ? String.fromCodePoint(codigo) : inteira;
    }
    return ENTIDADES[nome] ?? inteira;
  });
}

const textoDaCelula = (html) => decodificarEntidades(html.replace(/<[^>]+>/g, " ")).replace(/\s+/g, " ").trim();

export function textoDeGabaritoHtml(bytes) {
  const html = decodificarBytes(bytes).replace(/<script[\s\S]*?<\/script>/gi, "").replace(/<style[\s\S]*?<\/style>/gi, "").replace(/<!--[\s\S]*?-->/g, "");
  const linhas = [...html.matchAll(/<tr\b(?:(?!<tr\b)[\s\S])*?<\/tr>/gi)].map((m) => textoDaCelula(m[0])).filter(Boolean);
  return `${linhas.join("\n")}\n`;
}

export const sha256DoTexto = (texto) => crypto.createHash("sha256").update(texto, "utf8").digest("hex");
