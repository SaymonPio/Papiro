// Gabarito final = gabarito base -> retificação 1 -> retificação 2 -> ...
//
// Bancas publicam o gabarito definitivo e, depois, editais retificativos
// que alteram ou anulam questões (checado num caso real: Fundatec/PP-RS
// 2026 — o Edital 24 anula as questões 17 e 75 e o Edital 27, posterior,
// anula também a 15). Nada aqui é específico de edital: a ORDEM é
// explícita (campo "ordem" do manifesto de gabaritos, nunca o nome do
// arquivo), cada retificação pode alterar a alternativa, anular ou
// desfazer uma anulação, e qualquer conflito sem ordem confiável vira
// revisão manual da questão.

function resultadoDe(entrada) {
  if (!entrada) return null;
  return entrada.anulada ? "ANULADA" : entrada.alternativa_correta;
}

// Entradas de UM documento para o mesmo número: valores iguais repetidos
// (ex.: "QUESTÃO: 15 - ANULADA" na justificativa e "15 *" na tabela) são
// a mesma informação; valores diferentes são conflito.
function consolidarDocumento(entradas) {
  const porNumero = new Map();
  for (const entrada of entradas) {
    const atual = porNumero.get(entrada.numero);
    const resultado = resultadoDe(entrada);
    // Decisão de justificativa (extrairGabarito.mjs): MANTIDA confirma a
    // letra vigente; ALTERA traz a letra de partida ("de"); indeterminada
    // (não reconhecida) nunca vira resposta.
    const decisao = entrada.decisao ? { tipo: entrada.decisao, de: entrada.de ?? null } : null;
    if (!atual) porNumero.set(entrada.numero, { resultado, conflito: false, indeterminada: entrada.status !== "ok", decisao });
    else {
      if (atual.resultado !== resultado) atual.conflito = true;
      if (entrada.status !== "ok") atual.indeterminada = true;
    }
  }
  return porNumero;
}

// Decisão oficial incompatível com o estado vigente da questão: "MANTIDA
// 'X'" com o gabarito vigente em outra letra, ou "ALTERA DE 'X'" com a
// vigente diferente de X — duas fontes oficiais dizendo coisas diferentes;
// nunca se escolhe uma delas automaticamente.
function conflitoComVigente(doDocumento, vigente) {
  const d = doDocumento.decisao;
  if (d?.tipo === "mantida" && doDocumento.resultado !== vigente) return `mantém ${doDocumento.resultado}, mas o gabarito vigente é ${vigente ?? "?"}`;
  if (d?.tipo === "alterada" && d.de !== vigente) return `altera de ${d.de} para ${doDocumento.resultado}, mas o gabarito vigente é ${vigente ?? "?"}`;
  return null;
}

function validarOrdens(retificacoes) {
  const problemas = [];
  const vistas = new Map();
  for (const r of retificacoes) {
    if (!Number.isInteger(r.ordem) || r.ordem < 1) problemas.push(`retificação "${r.documento}" sem ordem explícita válida (inteiro >= 1)`);
    else if (vistas.has(r.ordem)) problemas.push(`retificações "${vistas.get(r.ordem)}" e "${r.documento}" com a mesma ordem ${r.ordem}`);
    else vistas.set(r.ordem, r.documento);
  }
  return problemas;
}

// base: entradas do gabarito base (já filtradas pelo bloco do cargo).
// retificacoes: [{ documento, ordem, gabaritos: entradas, mencoes: [{numero, acao}] }].
// Devolve as entradas FINAIS (mesmo formato de extrairGabaritoDoTexto,
// mais `historico`) e os problemas de documento.
export function aplicarRetificacoes(base, retificacoes = []) {
  const problemasDeOrdem = validarOrdens(retificacoes);
  const ordemConfiavel = problemasDeOrdem.length === 0;
  const ordenadas = [...retificacoes].sort((a, b) => (a.ordem ?? 0) - (b.ordem ?? 0));

  const consolidadoBase = consolidarDocumento(base.filter((g) => g.status === "ok" || g.observacao?.includes("duplicado")));
  const numerosBase = new Set(base.map((g) => g.numero));
  const avisos = [];

  const finais = base.map((entradaBase) => {
    const historico = {
      resultado_original: resultadoDe(entradaBase),
      resultado_final: resultadoDe(entradaBase),
      alteracoes: [],
      status_final: entradaBase.status === "ok" ? (entradaBase.anulada ? "anulada" : "ok") : "revisao_manual",
      motivos: entradaBase.status === "ok" ? [] : ["gabarito base ambíguo para esta questão"],
    };
    if (consolidadoBase.get(entradaBase.numero)?.conflito) {
      historico.status_final = "revisao_manual";
      historico.motivos.push("gabarito base com valores diferentes para a mesma questão");
    }

    const valoresPorRetificacao = [];
    for (const retificacao of ordenadas) {
      const doDocumento = consolidarDocumento(retificacao.gabaritos).get(entradaBase.numero);
      const mencao = (retificacao.mencoes ?? []).find((m) => m.numero === entradaBase.numero);
      if (doDocumento?.conflito) {
        historico.status_final = "revisao_manual";
        historico.motivos.push(`"${retificacao.documento}" traz valores diferentes para a questão`);
        continue;
      }
      if (doDocumento?.indeterminada) {
        historico.status_final = "revisao_manual";
        historico.motivos.push(`"${retificacao.documento}" traz decisão não reconhecida para a questão`);
        continue;
      }
      const conflito = doDocumento ? conflitoComVigente(doDocumento, historico.resultado_final) : null;
      if (conflito) {
        historico.status_final = "revisao_manual";
        historico.motivos.push(`GABARITO_OFICIAL_CONFLITANTE: "${retificacao.documento}" ${conflito}`);
        continue;
      }
      // Texto corrido que anuncia mudança ("Anula-se a Questão nº 15")
      // precisa ser confirmado pela tabela do mesmo documento — prosa
      // sem entrada estruturada, ou contrária a ela, nunca é aplicada.
      if (mencao && (!doDocumento || (mencao.acao === "anula" && doDocumento.resultado !== "ANULADA"))) {
        historico.status_final = "revisao_manual";
        historico.motivos.push(`"${retificacao.documento}" anuncia ${mencao.acao === "anula" ? "anulação" : "alteração"} da questão sem entrada de gabarito que a confirme`);
        continue;
      }
      if (!doDocumento) continue;
      valoresPorRetificacao.push({ documento: retificacao.documento, ordem: retificacao.ordem, resultado: doDocumento.resultado });
      if (doDocumento.resultado !== historico.resultado_final) {
        historico.alteracoes.push({ documento: retificacao.documento, ordem: retificacao.ordem, de: historico.resultado_final, para: doDocumento.resultado });
        historico.resultado_final = doDocumento.resultado;
      }
    }

    if (!ordemConfiavel && new Set(valoresPorRetificacao.map((v) => v.resultado)).size > 1) {
      historico.status_final = "revisao_manual";
      historico.motivos.push("retificações com valores diferentes e sem ordem confiável entre elas");
    }
    if (historico.status_final !== "revisao_manual") historico.status_final = historico.resultado_final === "ANULADA" ? "anulada" : "ok";

    const anulada = historico.resultado_final === "ANULADA";
    return {
      ...entradaBase,
      alternativa_correta: anulada ? null : historico.resultado_final,
      anulada,
      alterada: entradaBase.alterada || historico.alteracoes.length > 0,
      observacao:
        historico.alteracoes.length > 0
          ? [entradaBase.observacao, ...historico.alteracoes.map((a) => `${a.de ?? "?"} -> ${a.para} por "${a.documento}" (ordem ${a.ordem})`)].filter(Boolean).join(" — ")
          : entradaBase.observacao,
      status: historico.status_final === "revisao_manual" ? "revisao_manual" : "ok",
      historico,
    };
  });

  for (const retificacao of ordenadas) {
    for (const numero of consolidarDocumento(retificacao.gabaritos).keys()) {
      if (!numerosBase.has(numero)) avisos.push(`"${retificacao.documento}" cita a questão ${numero}, que não existe no gabarito base — ignorada`);
    }
  }

  return { gabaritos: finais, problemas: problemasDeOrdem, avisos };
}
