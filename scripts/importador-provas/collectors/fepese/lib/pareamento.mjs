// Pareamento prova <-> gabarito. Regra inegociável do produto: NUNCA
// parear só porque os dois pertencem ao mesmo concurso/ano — isso é
// explicitamente proibido (uma página pode ter várias provas de cargos
// diferentes e só um gabarito relevante para cada). O pareamento usa
// SÓ tokens distintivos do nome do arquivo/rótulo; ano nunca entra na
// conta.
//
// Validado contra um caso real (guardabc.fepese.org.br, PMBC 2014,
// cargos Guarda Municipal + Armeiro): "GM_Guarda_Municipal.pdf" compartilha
// o token "gm" com "Gabarito GM BC_definitivo.pdf" e "Gabarito_Provisorio_
// GM_BC.pdf" — as duas versões do gabarito têm a MESMA assinatura de
// tokens distintivos (diferem só na palavra de versão), então não são
// tratadas como ambíguas entre si, só como duas revisões do mesmo
// gabarito (escolhe a mais oficial). Já "AR_Armeiro.pdf" não compartilha
// nenhum token com nenhum gabarito da página — fica sem par, nunca
// escolhido por exclusão.

export function tokenizarNomeArquivo(texto) {
  return new Set(
    (texto ?? "")
      // Não ancorado ao fim da string: esta função também recebe
      // "arquivo + cargo" concatenados (pareamento.mjs), onde ".pdf" não
      // fica no fim literal por causa do texto do cargo depois dele —
      // sem isso, "pdf" sobra como token espúrio "compartilhado" entre
      // QUALQUER prova e QUALQUER gabarito (os dois têm extensão .pdf).
      .replace(/\.pdf\b/gi, "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .split(/[^a-z0-9]+/)
      .filter((token) => token.length >= 2),
  );
}

const PALAVRAS_VERSAO = ["definitivo", "final", "oficial", "preliminar", "provisorio", "posrecurso"];
const PALAVRAS_GENERICAS = new Set(["gabarito", "prova", "cp", "ed", "edital", ...PALAVRAS_VERSAO]);

// Um token só é "distintivo" se discrimina entre cargos — nunca um
// número puro (ano, sequência) e nunca um token que aparece em 2+
// provas diferentes do mesmo concurso (ex.: o código do edital,
// "CP001", compartilhado por TODAS as provas da página). Sem este
// filtro, dois documentos de CARGOS diferentes mas do MESMO edital
// pareariam por engano pelo código do edital — exatamente o que a
// regra "nunca parear só por pertencer ao mesmo concurso/ano" proíbe.
// Calculado a partir das PROVAS (nunca dos gabaritos), porque é entre
// provas que a ambiguidade de cargo pode existir.
function construirFiltroDistintivo(provas) {
  const contagemPorProva = new Map();
  for (const prova of provas) {
    for (const token of tokenizarNomeArquivo(`${prova.arquivo} ${prova.cargo ?? ""}`)) {
      contagemPorProva.set(token, (contagemPorProva.get(token) ?? 0) + 1);
    }
  }
  return function distintivo(token) {
    if (PALAVRAS_GENERICAS.has(token)) return false;
    if (/^\d+$/.test(token)) return false;
    if (provas.length >= 2 && (contagemPorProva.get(token) ?? 0) >= 2) return false;
    return true;
  };
}

function assinatura(tokens) {
  return [...tokens].sort().join("+");
}

function prioridadeVersao(gabarito) {
  const tokens = tokenizarNomeArquivo(`${gabarito.arquivo} ${gabarito.rotulo}`);
  for (let i = 0; i < PALAVRAS_VERSAO.length; i++) {
    if (tokens.has(PALAVRAS_VERSAO[i])) return i;
  }
  return PALAVRAS_VERSAO.length;
}

export function casarProvaComGabarito(documentos) {
  const provas = documentos.filter((d) => d.tipo === "prova");
  const gabaritos = documentos.filter((d) => d.tipo === "gabarito");
  const distintivo = construirFiltroDistintivo(provas);
  const tokensDistintivos = (tokens) => new Set([...tokens].filter(distintivo));

  return provas.map((prova) => {
    const tokensProva = tokensDistintivos(tokenizarNomeArquivo(`${prova.arquivo} ${prova.cargo ?? ""}`));

    const candidatos = gabaritos
      .map((gabarito) => {
        const tokensGabarito = tokensDistintivos(tokenizarNomeArquivo(`${gabarito.arquivo} ${gabarito.rotulo}`));
        const interseccao = [...tokensProva].filter((t) => tokensGabarito.has(t));
        return { gabarito, interseccao, assinatura: assinatura(tokensGabarito) };
      })
      .filter((c) => c.interseccao.length > 0);

    if (candidatos.length === 0) {
      if (gabaritos.length === 1 && provas.length === 1) {
        // Único caso aceitável de pareamento "por posição": só existe UMA
        // prova e UM gabarito no concurso inteiro — não há ambiguidade
        // possível mesmo sem token de nome compartilhado. Confiança
        // "media", nunca "alta", porque não houve confirmação textual.
        return {
          prova,
          gabarito: gabaritos[0],
          confidence: "media",
          motivo: "único par prova/gabarito no concurso — sem token de nome compartilhado, pareado só por não haver outra opção",
        };
      }
      return {
        prova,
        gabarito: null,
        confidence: "baixa",
        motivo: "nenhum gabarito com nome/rótulo relacionado a esta prova foi encontrado",
      };
    }

    const melhorInterseccao = Math.max(...candidatos.map((c) => c.interseccao.length));
    const empatados = candidatos.filter((c) => c.interseccao.length === melhorInterseccao);
    const assinaturasDistintas = new Set(empatados.map((c) => c.assinatura));

    empatados.sort((a, b) => prioridadeVersao(a.gabarito) - prioridadeVersao(b.gabarito));
    const escolhido = empatados[0];

    const ambiguo = assinaturasDistintas.size > 1;
    return {
      prova,
      gabarito: escolhido.gabarito,
      confidence: ambiguo ? "media" : "alta",
      motivo: ambiguo
        ? `múltiplos gabaritos com conteúdo de nome DIFERENTE empatam na correspondência (tokens: ${escolhido.interseccao.join(",")}) — escolhido "${escolhido.gabarito.rotulo}" pela versão mais oficial, mas precisa revisão humana antes de importar`
        : `token(s) de nome compartilhado: ${escolhido.interseccao.join(",")}${empatados.length > 1 ? ` (${empatados.length} revisões do mesmo gabarito — escolhida a mais oficial: "${escolhido.gabarito.rotulo}")` : ""}`,
    };
  });
}
