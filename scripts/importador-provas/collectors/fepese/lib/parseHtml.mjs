// Extrai documentos de download de uma página de concurso FEPESE.
//
// Estrutura real confirmada por fetch direto em guardabc.fepese.org.br
// (2026-10-17), nunca inventada:
//   <a href="?go=download&arquivo=NOME.pdf" class="inscricao">
//     <b>RÓTULO</b>[<br>CARGO]
//   </a>
// O tipo do documento (prova/gabarito/outro) vem da primeira palavra do
// rótulo; o cargo (quando existe) vem do texto depois do <br> — no HTML
// real observado, só "Prova" tem essa segunda parte; "Gabarito" nunca
// menciona cargo (ver limitação de pareamento em pareamento.mjs).

const LINK_DOCUMENTO = /<a\s+href="([^"]*go=download[^"]*arquivo=([^"&]+\.pdf)[^"]*)"[^>]*>([\s\S]*?)<\/a>/gi;

function limparHtmlInline(html) {
  return html
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/&nbsp;/gi, " ")
    .trim();
}

function decodificarEntidades(texto) {
  return texto.replace(/&amp;/gi, "&");
}

export function extrairDocumentosDoHtml(html, baseUrl) {
  const documentos = [];
  for (const match of html.matchAll(LINK_DOCUMENTO)) {
    const hrefBruto = decodificarEntidades(match[1]);
    const arquivo = decodeURIComponent(match[2]);
    const linhas = limparHtmlInline(match[3])
      .split("\n")
      .map((l) => l.trim())
      .filter(Boolean);
    const rotulo = linhas.join(" ");
    const primeiraLinha = linhas[0] ?? "";

    let tipo = "outro";
    if (/^prova\b/i.test(primeiraLinha)) tipo = "prova";
    else if (/^gabarito\b/i.test(primeiraLinha)) tipo = "gabarito";

    const cargo = tipo === "prova" && linhas.length > 1 ? linhas.slice(1).join(" ") : null;

    let url;
    try {
      url = new URL(hrefBruto, baseUrl).toString();
    } catch {
      continue; // href malformado — documento ignorado, nunca quebra o resto da listagem
    }

    documentos.push({ tipo, rotulo, cargo, arquivo, url });
  }
  return documentos;
}
