// Deduplicação contra o banco atual — mesmo algoritmo de 3 camadas já
// validado em scripts/dedupe-lote1-vs-supabase.js (Camada A: igualdade
// exata de enunciado normalizado; Camada B seria por ID de fonte externa,
// não aplicável ainda aqui pois o banco atual não tem fonte_externa_id —
// ver proposta de schema; Camada C: similaridade Jaccard, nunca resolvida
// automaticamente). Renomeado para o vocabulário desta fase (nova /
// provavel_duplicada / duplicada) e adaptado para comparar contra um
// snapshot local de `questoes` (modo SOMENTE LEITURA — este módulo nunca
// escreve, nunca faz UPDATE/DELETE, só compara dois arrays em memória).

export function normalizarTexto(valor) {
  return (valor ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

// Como normalizarTexto, mas PRESERVANDO símbolos e números não ASCII
// (∨ ¬ → ↔ ≤ ≥ ² π...): normalizarTexto apaga a fórmula, e enunciados de
// lógica diferentes viram o mesmo texto (checado no banco real: "A
// proposição composta p ∨ ~p ∨ q é classificada como:" e "... p → (p ∧ q)
// ..." colidiam). Texto sem símbolo sai igual ao de normalizarTexto.
export function normalizarComSimbolos(valor) {
  return (valor ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^\p{L}\p{N}\p{S} ]+/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

// Identidade de CONTEÚDO de uma questão: enunciado + conjunto de
// alternativas. O enunciado sozinho não identifica questão — comando
// genérico ("Assinale a alternativa INCORRETA.") repete-se entre questões
// diferentes (checado numa prova real: Fundatec/PC-RS 2025 Escrivão-
// Inspetor, P2 47, 48 e 51).
export function chaveDeConteudo(questao) {
  return [normalizarComSimbolos(questao.enunciado), ...(questao.alternativas ?? []).map((a) => normalizarComSimbolos(a.texto)).sort()].join("\u0000");
}

export function jaccard(a, b) {
  const setA = new Set(normalizarTexto(a).split(" ").filter(Boolean));
  const setB = new Set(normalizarTexto(b).split(" ").filter(Boolean));
  if (setA.size === 0 || setB.size === 0) return 0;
  let intersecao = 0;
  for (const palavra of setA) if (setB.has(palavra)) intersecao++;
  const uniao = setA.size + setB.size - intersecao;
  return uniao === 0 ? 0 : intersecao / uniao;
}

const LIMIAR_SIMILARIDADE = 0.35;
const LIMIAR_ALTERNATIVAS_COMPATIVEIS = 0.6;

function textoAlternativas(alternativas) {
  return (alternativas ?? []).map((a) => a.texto).join(" ");
}

function tokensDe(texto) {
  return normalizarTexto(texto).split(" ").filter(Boolean);
}

function multiconjunto(tokens) {
  const mapa = new Map();
  for (const t of tokens) mapa.set(t, (mapa.get(t) ?? 0) + 1);
  return mapa;
}

// Proporção do texto-base que uma questão existente embute (legado
// autossuficiente guarda texto + comando no mesmo enunciado).
const PROPORCAO_TEXTO_EMBUTIDO = 0.6;

// Enunciado existente SEM o texto-base da questão nova, quando ele o
// embute: o que sobra é o comando da questão existente.
function semTextoBase(enunciadoExistente, tokensTexto) {
  const existente = tokensDe(enunciadoExistente);
  const restante = multiconjunto(tokensTexto);
  let comuns = 0;
  const sobra = [];
  for (const t of existente) {
    if ((restante.get(t) ?? 0) > 0) {
      restante.set(t, restante.get(t) - 1);
      comuns++;
    } else {
      sobra.push(t);
    }
  }
  return tokensTexto.length > 0 && comuns / tokensTexto.length >= PROPORCAO_TEXTO_EMBUTIDO ? sobra.join(" ") : enunciadoExistente;
}

// Questão com texto-base incorporado: o texto é COMPARTILHADO por várias
// questões da mesma prova (e pode estar embutido no legado), então ele
// não pode, sozinho, fazer duas questões parecerem a mesma (checado numa
// prova real: Fundatec/GM Porto Alegre 2025 — 9 questões de Português
// "prováveis duplicatas" de uma única questão antiga que embute o texto).
//   - duplicada (exata): enunciado COMPLETO idêntico + alternativas
//     compatíveis — mesma regra de sempre;
//   - provável: só pelo COMANDO + alternativas, comparados com cada
//     questão existente já descontado o texto-base que ela embute.
// Questão sem texto-base segue exatamente o algoritmo de antes.
export function classificarDuplicidade(questaoNormalizada, bancoExistente) {
  const comando = questaoNormalizada._interno?.enunciado_comando;
  if (!comando || normalizarTexto(comando) === normalizarTexto(questaoNormalizada.enunciado)) {
    return classificarDuplicidadeDoEnunciado(questaoNormalizada, bancoExistente);
  }

  const exata = classificarDuplicidadeDoEnunciado(questaoNormalizada, bancoExistente, { soExata: true });
  if (exata.status === "duplicada") return exata;

  const restante = multiconjunto(tokensDe(questaoNormalizada.enunciado));
  for (const t of tokensDe(comando)) if ((restante.get(t) ?? 0) > 0) restante.set(t, restante.get(t) - 1);
  const tokensTexto = [...restante].flatMap(([t, n]) => Array(n).fill(t));

  // Cada existente entra com os candidatos a "comando dele": sem o texto
  // compartilhado, o último bloco (depois da última linha em branco) e a
  // cauda do enunciado — legado com OUTRO texto embutido não dilui a
  // comparação (só aumenta o que é detectado, nunca o contrário).
  const tamanhoComando = tokensDe(comando).length;
  const bancoSemTexto = bancoExistente.flatMap((existente) => {
    const enunciado = existente.enunciado ?? "";
    const candidatos = new Set([
      semTextoBase(enunciado, tokensTexto),
      enunciado.split(/\n[ \t]*\n/).at(-1),
      tokensDe(enunciado).slice(-Math.ceil(tamanhoComando * 1.5)).join(" "),
    ]);
    return [...candidatos].map((candidato) => ({ ...existente, enunciado: candidato }));
  });
  const resultado = classificarDuplicidadeDoEnunciado({ ...questaoNormalizada, enunciado: comando }, bancoSemTexto);
  if (resultado.status === "nova") return resultado;
  // Comando igual mas texto-base diferente nunca é duplicata EXATA.
  return {
    status: "provavel_duplicada",
    motivo: `${resultado.motivo.replace(/^enunciado identico e alternativas compativeis/, "comando idêntico (texto-base diferente) e alternativas compatíveis — requer leitura manual")} (comparando o comando, sem o texto-base compartilhado)`,
    match_id: resultado.match_id,
  };
}

function classificarDuplicidadeDoEnunciado(questaoNormalizada, bancoExistente, { soExata = false } = {}) {
  const enunciadoNovo = normalizarComSimbolos(questaoNormalizada.enunciado);
  const alternativasNovo = textoAlternativas(questaoNormalizada.alternativas);

  for (const existente of bancoExistente) {
    if (normalizarComSimbolos(existente.enunciado) === enunciadoNovo) {
      const simAlternativas = jaccard(alternativasNovo, textoAlternativas(existente.alternativas));
      if (simAlternativas >= LIMIAR_ALTERNATIVAS_COMPATIVEIS) {
        return { status: "duplicada", motivo: `enunciado identico e alternativas compativeis (questoes.id=${existente.id})`, match_id: existente.id };
      }
      // Mesmo enunciado "stub" mas alternativas muito diferentes: não é
      // considerado a mesma questão — segue para a camada de similaridade
      // combinada abaixo em vez de decidir aqui.
    }
  }

  if (soExata) return { status: "nova", motivo: "nenhuma correspondencia exata", match_id: null };

  let melhor = null;
  for (const existente of bancoExistente) {
    const combinadoNovo = `${questaoNormalizada.enunciado} ${alternativasNovo}`;
    const combinadoExistente = `${existente.enunciado ?? ""} ${textoAlternativas(existente.alternativas)}`;
    const similaridade = jaccard(combinadoNovo, combinadoExistente);
    if (similaridade >= LIMIAR_SIMILARIDADE && (!melhor || similaridade > melhor.similaridade)) {
      melhor = { existente, similaridade };
    }
  }

  if (melhor) {
    return {
      status: "provavel_duplicada",
      motivo: `similaridade Jaccard ${melhor.similaridade.toFixed(2)} com questoes.id=${melhor.existente.id} — requer leitura manual antes de decidir`,
      match_id: melhor.existente.id,
    };
  }

  return { status: "nova", motivo: "nenhuma correspondencia exata nem similaridade relevante contra o snapshot fornecido", match_id: null };
}
