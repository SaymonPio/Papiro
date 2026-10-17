// Segmentação de questões a partir de texto já extraído (paginas: [{numero,
// texto}], vindo de extrairTextoPdf.mjs ou, nos testes, escrito à mão —
// nenhuma dependência de PDF real aqui, só processamento de texto puro).
//
// Estratégia de detecção de número de questão: candidatos são números no
// início de linha seguidos de "." ou ")" (ex.: "12.", "12)"). Em vez de
// aceitar qualquer candidato (o que confundiria datas, artigos de lei,
// itens de lista dentro do enunciado etc.), só aceitamos uma SEQUÊNCIA
// estritamente crescente de +1 em +1 — é assim que provas reais numeram
// questões, e qualquer outro número no meio do texto nunca forma essa
// sequência por acaso. Isso é deliberadamente conservador: prefere não
// detectar uma questão a detectar uma errada.
//
// Alternativas: candidatas são letras A-E início de linha OU logo após
// uma tabulação (ex.: duas alternativas na mesma linha física, separadas
// por \t — layout em colunas visto em provas reais), entre parênteses
// opcionais, seguidas de um terminador. Três terminadores observados em
// provas reais: ")" (ex.: "a)", "(A)", "D)"), uma seta (ex.: "A ⇒", "B
// →" — ACAFE/PC-SC 2008) e "." seguido de uma caixa de marcação opcional
// "( )"/"( X )" (ex.: "a. ( \t) texto", "d. ( X ) texto" — FEPESE/PMBC
// 2014). Generalização deliberada, não um caso especial: qualquer
// combinação de posição/terminador é aceita em qualquer questão, sem
// detectar banca nem se adaptar a uma prova específica. A ordem de
// aparição no texto NÃO precisa ser alfabética (ver segmentarAlternativas)
// — só a presença e a unicidade de cada letra são exigidas.

const MARCADOR_QUESTAO = /(?:^|\n)[ \t]*(\d{1,3})[.)][ \t]+/g;
// 'i' não é usado — a letra sempre é normalizada para maiúscula na
// captura abaixo, nunca comparada no caso original (provas reais variam
// entre "a)" minúsculo e "(A)" maiúsculo).
const MARCADOR_ALTERNATIVA = /(?:^|\n|\t)[ \t]*\(?([A-Ea-e])[ \t]*(?:\)|⇒|→|\.[ \t]*\([ \tXx]*\))[ \t]+/g;
// Exige "Texto"/"TEXTO" capitalizado (nunca "texto" minúsculo) — um
// cabeçalho real de texto-base é escrito como título ("Texto 1 - ...");
// uma referência dentro do próprio enunciado ("...segundo o texto 2.")
// usa a forma minúscula comum do português e pode cair no início de uma
// linha só por causa da quebra de linha do PDF, sem ser um cabeçalho.
// Checado numa prova real (ACAFE/PC-SC 2008): sem essa exigência, essa
// única linha ("segundo o\ntexto 2.") era reconhecida como um novo
// texto-base e se propagava para as 73 questões seguintes.
const MARCADOR_TEXTO_BASE = /(?:^|\n)[ \t]*(?:Texto|TEXTO)[ \t]*(?:[-–][ \t]*base)?[ \t]*(\d{0,3})\b.*$/gm;

// Cabeçalho de bloco/matéria ("Português 5 questões", "Conhecimentos
// Gerais (10 questões)") — algumas provas reais numeram questões POR
// MATÉRIA, reiniciando em 1 a cada bloco, em vez de numerar o documento
// inteiro de 1 a N (checado numa prova real: FEPESE/PMBC 2014 — "Estudos
// Sociais" termina em 5, "Português" reinicia em 1). O padrão "Nome +
// contagem + questão(ões)" não é específico de nenhuma banca — é uma
// convenção comum a vários editais. Ancorado ao fim da própria linha
// para não confundir com frases comuns tipo "... 40 questões de
// conhecimentos gerais e 40 questões de conhecimentos específicos."
// (ACAFE), que nunca terminam a linha logo depois de "questões".
const CABECALHO_BLOCO = /(?:^|\n)[ \t]*([A-ZÀ-ÚÃÕÇ][^\n\d(]{1,60}?)[ \t]*\(?[ \t]*(\d{1,3})[ \t]*quest(?:ão|ões)[ \t]*\)?[ \t]*(?=\n|$)/g;

const TAMANHO_MINIMO_LACUNA_TEXTO_BASE = 40;

function encontrarCabecalhosDeBloco(textoCompleto) {
  const blocos = [];
  for (const match of textoCompleto.matchAll(CABECALHO_BLOCO)) {
    blocos.push({
      materia: match[1].trim(),
      quantidadeDeclarada: Number(match[2]),
      offsetFimCabecalho: match.index + match[0].length,
    });
  }
  return blocos;
}

function construirMapaDePaginas(paginas) {
  const mapa = [];
  let offset = 0;
  for (const pagina of paginas) {
    const texto = pagina.texto ?? "";
    mapa.push({ numero: pagina.numero, inicio: offset, fim: offset + texto.length });
    offset += texto.length + 1; // +1 pelo "\n" que une as páginas no texto concatenado
  }
  return mapa;
}

function paginaDoOffset(mapaPaginas, offset) {
  for (const entrada of mapaPaginas) {
    if (offset >= entrada.inicio && offset <= entrada.fim) return entrada.numero;
  }
  return mapaPaginas.at(-1)?.numero ?? null;
}

function encontrarCandidatosQuestao(textoCompleto) {
  const candidatos = [];
  for (const match of textoCompleto.matchAll(MARCADOR_QUESTAO)) {
    candidatos.push({ numero: Number(match[1]), offsetMarcador: match.index + match[0].indexOf(match[1]), offsetFimMarcador: match.index + match[0].length });
  }
  return candidatos;
}

// Entre todos os candidatos, acha a maior sequência consecutiva (+1) e
// devolve só ela, em ordem. Se houver mais de uma sequência de mesmo
// tamanho, usa a que aparece primeiro no texto.
function selecionarSequenciaValida(candidatos) {
  let melhor = [];
  for (let i = 0; i < candidatos.length; i++) {
    const sequencia = [candidatos[i]];
    let atual = candidatos[i];
    for (let j = i + 1; j < candidatos.length; j++) {
      if (candidatos[j].numero === atual.numero + 1 && candidatos[j].offsetMarcador > atual.offsetMarcador) {
        sequencia.push(candidatos[j]);
        atual = candidatos[j];
      }
    }
    if (sequencia.length > melhor.length) melhor = sequencia;
  }
  return melhor;
}

const FAIXA_TEXTO_BASE = /quest(?:[õo]es?)[^\d]{0,15}(\d{1,3})[^\d]{1,6}(?:a|e|até)[^\d]{0,6}(\d{1,3})/i;

function extrairTextoBaseAntes(textoCompleto, inicioBusca, fimBusca) {
  const trecho = textoCompleto.slice(inicioBusca, fimBusca);
  const matches = [...trecho.matchAll(MARCADOR_TEXTO_BASE)];
  if (matches.length === 0) return null;
  const ultimo = matches.at(-1);
  const conteudo = trecho.slice(ultimo.index).trim();
  if (conteudo.length === 0) return null;

  // Se o próprio texto-base declarar o intervalo de questões a que se
  // aplica ("...questões de 1 a 2"), usamos esse intervalo em vez de
  // carregar o texto-base indefinidamente para as questões seguintes —
  // evita associar um texto-base antigo a uma questão que não tem
  // nenhuma relação com ele.
  const faixa = conteudo.match(FAIXA_TEXTO_BASE);
  const faixaNumeros = faixa ? { inicio: Number(faixa[1]), fim: Number(faixa[2]) } : null;

  return { conteudo, faixaNumeros };
}

const LETRAS_VALIDAS = ["A", "B", "C", "D", "E"];

// Não exige que as letras apareçam em ordem alfabética no texto. Provas
// reais podem imprimir alternativas em duas colunas (ex.: A e C na mesma
// linha, separadas por tabulação; B e D na linha de baixo) — nesse caso a
// ordem de EXTRAÇÃO do texto vira A, C, B, D, não A, B, C, D, mesmo a
// prova estando correta. O limite de cada alternativa continua sendo
// "até o próximo marcador em ordem de aparição no texto" (isso nunca
// muda); só deixamos de usar a ordem alfabética como critério de
// validade — passamos a usar presença + unicidade de cada letra.
function segmentarAlternativas(textoQuestao) {
  const candidatos = [...textoQuestao.matchAll(MARCADOR_ALTERNATIVA)].map((match) => ({
    letra: match[1].toUpperCase(),
    offsetMarcador: match.index,
    offsetFimMarcador: match.index + match[0].length,
  }));

  const candidatosPorLetra = new Map();
  const letrasRepetidas = new Set();
  for (const candidato of candidatos) {
    if (!LETRAS_VALIDAS.includes(candidato.letra)) continue;
    if (candidatosPorLetra.has(candidato.letra)) {
      // Letra repetida dentro da mesma questão — ambíguo, nunca escolhido
      // arbitrariamente; fica fora do resultado e marca alternativa
      // faltante (tratado como erro de extração, não como duas
      // alternativas de mesma letra).
      letrasRepetidas.add(candidato.letra);
      continue;
    }
    candidatosPorLetra.set(candidato.letra, candidato);
  }

  // Ordenado por posição real no texto (não por letra) — é essa ordem
  // que determina onde cada alternativa termina.
  const candidatosOrdenados = [...candidatosPorLetra.values()].sort((a, b) => a.offsetMarcador - b.offsetMarcador);

  const enunciadoFim = candidatosOrdenados.length > 0 ? candidatosOrdenados[0].offsetMarcador : textoQuestao.length;
  const enunciado = textoQuestao.slice(0, enunciadoFim).trim();

  const alternativasExtraidas = candidatosOrdenados.map((candidato, indice) => {
    const fim = indice + 1 < candidatosOrdenados.length ? candidatosOrdenados[indice + 1].offsetMarcador : textoQuestao.length;
    return { letra: candidato.letra, texto: textoQuestao.slice(candidato.offsetFimMarcador, fim).trim() };
  });

  // Apresentação final sempre em ordem alfabética, independente da ordem
  // de extração.
  alternativasExtraidas.sort((a, b) => LETRAS_VALIDAS.indexOf(a.letra) - LETRAS_VALIDAS.indexOf(b.letra));

  const letrasEncontradas = new Set(candidatosPorLetra.keys());
  const faltouAlgumaDasQuatroPrimeiras = !["A", "B", "C", "D"].every((letra) => letrasEncontradas.has(letra));
  const alternativaFaltante = faltouAlgumaDasQuatroPrimeiras || letrasRepetidas.size > 0;

  return { enunciado, alternativas: alternativasExtraidas, alternativaFaltante };
}

// Monta a sequência final de questões, já em ordem de documento, a
// partir de um ou mais SEGMENTOS independentes. Sem nenhum cabeçalho de
// bloco no documento, há só um segmento implícito cobrindo o texto
// inteiro — comportamento idêntico ao de antes desta função existir
// (caso ACAFE/PC-SC 2008: numero_impresso === numero_original sempre).
// Com cabeçalhos de bloco (caso FEPESE/PMBC 2014), cada segmento busca
// sua própria sequência válida de +1 em +1 A PARTIR DO PRÓPRIO PONTO —
// nunca do documento inteiro de uma vez — porque a numeração impressa
// reinicia a cada matéria; numero_original (posição global, usada para
// casar com o gabarito) é sempre a contagem corrida de tudo que foi
// aceito, em ordem de documento, independente do número impresso.
function montarSegmentos(textoCompleto, candidatos, cabecalhosBloco) {
  const limites = [0, ...cabecalhosBloco.map((b) => b.offsetFimCabecalho), textoCompleto.length];
  const segmentos = [];
  for (let i = 0; i < limites.length - 1; i++) {
    segmentos.push({
      inicio: limites[i],
      fim: limites[i + 1],
      materia: cabecalhosBloco[i - 1]?.materia ?? null,
      quantidadeDeclarada: cabecalhosBloco[i - 1]?.quantidadeDeclarada ?? null,
    });
  }

  const itens = [];
  const numerosIgnorados = [];
  for (const segmento of segmentos) {
    const candidatosDoSegmento = candidatos.filter(
      (c) => c.offsetMarcador >= segmento.inicio && c.offsetMarcador < segmento.fim,
    );
    const sequenciaLocal = selecionarSequenciaValida(candidatosDoSegmento);

    const numerosDoSegmento = new Set(candidatosDoSegmento.map((c) => c.numero));
    const numerosAceitos = new Set(sequenciaLocal.map((s) => s.numero));
    for (const numero of numerosDoSegmento) if (!numerosAceitos.has(numero)) numerosIgnorados.push(numero);

    // Se o cabeçalho declarou uma contagem ("5 questões") e o que foi
    // efetivamente reconhecido neste segmento não bate, marca TODAS as
    // questões deste segmento para revisão manual — nunca desloca a
    // numeração global dos segmentos seguintes por causa de um gap aqui
    // (um segmento incompleto não deveria corromper o alinhamento de
    // tudo que vem depois dele).
    const contagemDivergente =
      segmento.quantidadeDeclarada !== null && sequenciaLocal.length !== segmento.quantidadeDeclarada;

    for (let i = 0; i < sequenciaLocal.length; i++) {
      const atual = sequenciaLocal[i];
      const proximoLocal = sequenciaLocal[i + 1] ?? null;
      itens.push({
        numeroImpresso: atual.numero,
        offsetMarcador: atual.offsetMarcador,
        offsetFimMarcador: atual.offsetFimMarcador,
        inicioSpan: atual.offsetFimMarcador,
        fimSpan: proximoLocal ? proximoLocal.offsetMarcador : segmento.fim,
        materia: segmento.materia,
        contagemMateriaDivergente: contagemDivergente,
      });
    }
  }

  return { itens, numerosIgnorados };
}

export function extrairQuestoesDoTexto(paginas) {
  const mapaPaginas = construirMapaDePaginas(paginas);
  const textoCompleto = paginas.map((p) => p.texto ?? "").join("\n");

  const candidatos = encontrarCandidatosQuestao(textoCompleto);
  const cabecalhosBloco = encontrarCabecalhosDeBloco(textoCompleto);
  const { itens: sequencia, numerosIgnorados } = montarSegmentos(textoCompleto, candidatos, cabecalhosBloco);

  const questoes = [];
  let textoBaseAtual = null;
  let contadorTextoBase = 0;

  for (let i = 0; i < sequencia.length; i++) {
    const atual = sequencia[i];
    const inicioSpan = atual.inicioSpan;
    const fimSpan = atual.fimSpan;

    const inicioBuscaTextoBase = i === 0 ? 0 : sequencia[i - 1].offsetFimMarcador;
    const novoTextoBase = extrairTextoBaseAntes(textoCompleto, inicioBuscaTextoBase, atual.offsetMarcador);
    if (novoTextoBase) {
      contadorTextoBase += 1;
      // Sem faixa declarada ("...questões de X a Y"), o padrão é
      // conservador: aplica só à questão onde o cabeçalho foi encontrado,
      // nunca propaga indefinidamente para a frente. Checado numa prova
      // real (ACAFE/PC-SC 2008): um cabeçalho de texto-base sem faixa
      // declarada ("Texto 2 - Um ano sem festa") se propagava, sem este
      // limite, por 73 questões de disciplinas completamente diferentes
      // (Informática, Legislação...), até o fim do documento. A faixa
      // declarada usa o número IMPRESSO (o que o próprio texto-base
      // cita), nunca a posição global.
      const faixaNumeros = novoTextoBase.faixaNumeros ?? { inicio: atual.numeroImpresso, fim: atual.numeroImpresso };
      textoBaseAtual = { id: `TB${contadorTextoBase}`, texto: novoTextoBase.conteudo, faixaNumeros };
    } else if (
      textoBaseAtual?.faixaNumeros &&
      (atual.numeroImpresso < textoBaseAtual.faixaNumeros.inicio || atual.numeroImpresso > textoBaseAtual.faixaNumeros.fim)
    ) {
      // A questão atual já saiu do intervalo declarado pelo texto-base
      // vigente ("...questões de X a Y") — não associa mais, mesmo sem um
      // novo marcador de texto-base ter aparecido.
      textoBaseAtual = null;
    }

    const textoQuestao = textoCompleto.slice(inicioSpan, fimSpan);
    const { enunciado, alternativas, alternativaFaltante } = segmentarAlternativas(textoQuestao);

    const paginaInicio = paginaDoOffset(mapaPaginas, atual.offsetMarcador);
    const paginaFim = paginaDoOffset(mapaPaginas, fimSpan > inicioSpan ? fimSpan - 1 : fimSpan);

    questoes.push({
      numero_original: i + 1,
      numero_impresso: atual.numeroImpresso,
      materia_detectada: atual.materia,
      enunciado,
      alternativas,
      pagina_origem: paginaInicio,
      atravessa_pagina: paginaFim !== null && paginaInicio !== null && paginaFim !== paginaInicio,
      texto_base_id: textoBaseAtual?.id ?? null,
      texto_base: textoBaseAtual?.texto ?? null,
      alternativa_faltante: alternativaFaltante,
      contagem_materia_divergente: atual.contagemMateriaDivergente,
    });
  }

  return { questoes, numerosIgnorados };
}
