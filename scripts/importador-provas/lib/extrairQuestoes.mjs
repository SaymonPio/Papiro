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

import { encontrarBlocosDeApoio, reconstruirTextoBase, referenciasAoTexto } from "./textoBase.mjs";

const MARCADOR_QUESTAO = /(?:^|\n)[ \t]*(\d{1,3})[.)][ \t]+/g;
// Marcador explícito "QUESTÃO 01 –" / "Questão 12:" no início da linha —
// convenção comum de várias bancas (checado numa prova real: Fundatec/
// Polícia Penal RS 2026, "QUESTÃO 01 – Considerando..."). Quando o
// documento numera questões assim, números soltos "1." / "2)" são listas
// internas (instruções da capa, itens de enunciado) e deixam de ser
// candidatos: sem isso, a lista de instruções "1. ... 11." da capa da
// mesma prova emendava na sequência real e ocupava as questões 1 a 11.
const MARCADOR_QUESTAO_EXPLICITO = /(?:^|\n)[ \t]*(?:QUEST[ÃA]O|Quest[ãa]o)[ \t]+(\d{1,3})[ \t]*[-–—:.)][ \t]*/g;
const MINIMO_SEQUENCIA_EXPLICITA = 3;
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

// Cabeçalho/rodapé corrido: a MESMA linha entre as primeiras ou últimas
// linhas de muitas páginas (checado numa prova real: Fundatec/PP-RS 2026,
// "1092_BASE_CE_24_NS_DM 23/07/2026 13:27:17" / "Execução: Fundatec" /
// "24 – POLICIAL PENAL" no topo de 20 das 22 páginas). Sem remoção, essas
// linhas grudavam no fim da última alternativa de toda questão que
// atravessa página. Só é removida nas bordas da página — a mesma frase no
// meio do conteúdo nunca é tocada.
const LINHAS_BORDA_PAGINA = 4;
const MINIMO_PAGINAS_LINHA_CORRIDA = 3;

// Rodapé com o número da página ("CNS201 - ... – PÁGINA 7", checado numa
// prova real: FGV/PCPR 2026) muda a cada página: na comparação, todo
// número vira "#".
function chaveLinhaCorrida(linha) {
  return linha.trim().replace(/\d+/g, "#");
}

function removerLinhasCorridas(paginas) {
  const bordas = paginas.map((p) => {
    const linhas = (p.texto ?? "").split("\n");
    const indices = linhas.map((l, i) => (l.trim() ? i : -1)).filter((i) => i >= 0);
    return { linhas, borda: new Set([...indices.slice(0, LINHAS_BORDA_PAGINA), ...indices.slice(-LINHAS_BORDA_PAGINA)]) };
  });
  const paginasPorLinha = new Map();
  for (const { linhas, borda } of bordas) {
    for (const texto of new Set([...borda].map((i) => chaveLinhaCorrida(linhas[i])))) paginasPorLinha.set(texto, (paginasPorLinha.get(texto) ?? 0) + 1);
  }
  // Linha só de número (ex.: "1", que pode ser a própria questão no topo
  // da página) nunca é tratada como corrida.
  const corridas = new Set(
    [...paginasPorLinha].filter(([texto, n]) => texto !== "#" && n >= MINIMO_PAGINAS_LINHA_CORRIDA && n >= paginas.length / 2).map(([texto]) => texto),
  );
  if (corridas.size === 0) return { paginas, topoRemovido: paginas.map(() => false) };

  const topoRemovido = [];
  const limpas = paginas.map((pagina, indicePagina) => {
    const { linhas, borda } = bordas[indicePagina];
    const primeiraComConteudo = linhas.findIndex((l) => l.trim());
    const manter = linhas.map((l, i) => !(borda.has(i) && corridas.has(chaveLinhaCorrida(l))));
    topoRemovido.push(primeiraComConteudo >= 0 && !manter[primeiraComConteudo]);
    return { ...pagina, texto: linhas.filter((_, i) => manter[i]).join("\n") };
  });
  return { paginas: limpas, topoRemovido };
}

// Título de seção sem contagem ("INFORMÁTICA", "LEGISLAÇÃO APLICADA/
// DIREITO"): linha inteira em maiúsculas. Só é aceito em duas posições
// que não deixam dúvida — (i) imediatamente antes de um marcador de
// questão aceito, ou (ii) antes da primeira questão, como primeira linha
// de uma página logo abaixo do cabeçalho corrido removido. Uma linha em
// maiúsculas dentro de um enunciado ("VISTO QUE", entre duas asserções)
// não está em nenhuma das duas posições e nunca vira seção.
const TITULO_SECAO = /^[A-ZÀ-ÖØ-Þ][A-ZÀ-ÖØ-Þ0-9 ,/–—-]{3,80}$/;

function ehTituloSecao(linha) {
  const texto = linha.trim();
  return TITULO_SECAO.test(texto) && (texto.match(/[A-ZÀ-ÖØ-Þ]/g) ?? []).length >= 6 && !/^[A-E][)]/.test(texto);
}

function encontrarTitulosDeSecao(textoCompleto, sequencia, mapaPaginas, topoRemovido) {
  const titulos = [];
  const inicioDosMarcadores = new Set(sequencia.map((s) => s.offsetMarcador));
  const primeiroMarcador = sequencia[0]?.offsetMarcador ?? Infinity;
  const iniciosDePagina = new Map(mapaPaginas.map((p, i) => [p.inicio, topoRemovido[i]]));
  let offset = 0;
  const linhas = textoCompleto.split("\n");
  for (let i = 0; i < linhas.length; i++) {
    const inicioLinha = offset;
    offset += linhas[i].length + 1;
    if (!ehTituloSecao(linhas[i])) continue;
    let proxima = offset;
    let j = i + 1;
    for (; j < linhas.length && !linhas[j].trim(); j++) proxima += linhas[j].length + 1;
    const recuo = j < linhas.length ? linhas[j].length - linhas[j].trimStart().length : 0;
    const antesDeQuestao = inicioDosMarcadores.has(proxima + recuo);
    const topoDePaginaNoPreambulo = inicioLinha < primeiroMarcador && iniciosDePagina.get(inicioLinha) === true;
    if (antesDeQuestao || topoDePaginaNoPreambulo) titulos.push({ titulo: linhas[i].trim(), inicio: inicioLinha, antesDeQuestao });
  }
  return titulos;
}

// offsetMarcador = início do marcador visível ("12." ou "QUESTÃO 12 –"),
// não do número: é onde termina o texto da questão anterior — com o
// marcador explícito, apontar para o número deixava "QUESTÃO" grudado no
// fim da última alternativa da questão anterior.
function candidatosDoMarcador(textoCompleto, marcador) {
  const candidatos = [];
  for (const match of textoCompleto.matchAll(marcador)) {
    candidatos.push({ numero: Number(match[1]), offsetMarcador: match.index + match[0].search(/\S/), offsetFimMarcador: match.index + match[0].length });
  }
  return candidatos;
}

// Número sozinho na linha ("1", "26") — convenção de outras bancas
// (checado numa prova real: FGV/PCPR 2026, 100 questões numeradas assim).
// Só vale quando forma uma sequência +1 MAIOR que a de "N." / "N)": num
// documento numerado com ponto, números soltos (página, tabela) nunca
// formam sequência mais longa que a das questões.
const MARCADOR_QUESTAO_ISOLADO = /(?:^|\n)[ \t]*(\d{1,3})[ \t]*(?=\n)/g;

// Tamanho da maior sequência +1 de marcadores de questão — usado pela
// estratégia "auto" para comparar duas ordens de leitura do mesmo PDF.
export function comprimentoDaSequenciaDeQuestoes(paginas) {
  const { paginas: limpas } = removerLinhasCorridas(paginas);
  return selecionarSequenciaValida(encontrarCandidatosQuestao(limpas.map((p) => p.texto ?? "").join("\n"))).length;
}

function encontrarCandidatosQuestao(textoCompleto) {
  const explicitos = candidatosDoMarcador(textoCompleto, MARCADOR_QUESTAO_EXPLICITO);
  if (selecionarSequenciaValida(explicitos).length >= MINIMO_SEQUENCIA_EXPLICITA) return explicitos;
  const pontuados = candidatosDoMarcador(textoCompleto, MARCADOR_QUESTAO);
  const isolados = candidatosDoMarcador(textoCompleto, MARCADOR_QUESTAO_ISOLADO);
  const sequenciaIsolada = selecionarSequenciaValida(isolados).length;
  if (sequenciaIsolada >= MINIMO_SEQUENCIA_EXPLICITA && sequenciaIsolada > selecionarSequenciaValida(pontuados).length) return isolados;
  return pontuados;
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

  return {
    enunciado,
    alternativas: alternativasExtraidas,
    alternativaFaltante,
    offsetUltimaAlternativa: candidatosOrdenados.at(-1)?.offsetFimMarcador ?? null,
  };
}

// Alternativa muito mais longa que as irmãs quase sempre é texto de fora
// grudado nela (texto-base da questão seguinte, rodapé, "página em
// branco") — checado em provas reais: ACAFE/PC-SC 2008 (Texto 2 inteiro
// na alternativa D da questão 6) e FEPESE/PMBC 2014 (rodapé na
// alternativa E da última questão). Só sinaliza, nunca corta.
const TAMANHO_MINIMO_ALTERNATIVA_SUSPEITA = 200;
const FATOR_ALTERNATIVA_SUSPEITA = 3;

function alternativaSuspeita(alternativas) {
  if (alternativas.length < 2) return null;
  for (const alternativa of alternativas) {
    const outras = alternativas.filter((a) => a !== alternativa).map((a) => a.texto.length).sort((a, b) => a - b);
    const mediana = outras[Math.floor(outras.length / 2)];
    if (alternativa.texto.length >= TAMANHO_MINIMO_ALTERNATIVA_SUSPEITA && alternativa.texto.length > mediana * FATOR_ALTERNATIVA_SUSPEITA) {
      return `alternativa ${alternativa.letra} com ${alternativa.texto.length} caracteres (mediana das demais: ${mediana}) — possível texto de fora grudado`;
    }
  }
  return null;
}

// Questão que depende de algo que o texto extraído não carrega: destaque
// tipográfico ("destacada em negrito", "vírgula hachurada", "sujeito
// sublinhado") ou imagem ("a figura 01", "a charge a seguir", "o gráfico
// a seguir"). Checado em provas reais (PP-RS 2026 q.6 e q.12; ACAFE 2008
// figuras/charges; FEPESE 2014 q.5). Só sinaliza — revisão manual.
const REFERENCIA_DESTAQUE = /\b(?:destacad[ao]s?|em destaque|sublinhad[ao]s?|grifad[ao]s?|hachurad[ao]s?|em negrito|em it[áa]lico)\b/i;
const REFERENCIA_IMAGEM =
  /\b(?:figuras?|imagens?|ilustra[çc][ãa]o|charge|tirinha|gr[áa]fico|infogr[áa]fico|mapa|quadro|tabela)\b[^.\n]{0,25}?(?:\ba seguir\b|\babaixo\b|\bacima\b|\bao lado\b|\bseguinte\b|\b\d{1,2}\b)|\b(?:seguinte|abaixo)[ \t\n]+(?:figura|imagem|ilustra[çc][ãa]o|charge|tirinha|gr[áa]fico|quadro|tabela)\b/i;

// Peças essencialmente visuais ("Observe o cartum a seguir", "cartaz de
// campanha") e "Leia o texto a seguir:" seguido direto da fonte — o
// "texto" era uma imagem e nada dele foi extraído (checado numa prova
// real: FGV/PCPR 2026, questões 3, 9 e 20).
const PECA_VISUAL = "(?:cartaz|cartum|cartuns|foto|fotografia|meme|tirinhas?|quadrinhos?|hq|infogr[áa]fico|anúncio publicitário)";
const REFERENCIA_PECA_VISUAL = new RegExp(
  `\\b(?:observe|analise|veja)\\b[^.\\n]{0,40}?\\b${PECA_VISUAL}\\b|\\b${PECA_VISUAL}\\b[^.\\n]{0,25}?\\b(?:a seguir|abaixo|acima)\\b`,
  "i",
);
const TEXTO_SEM_CONTEUDO = /\b(?:leia|observe|analise|considere)\b[^\n]{0,60}?\ba seguir\b[^\n]{0,60}:?[ \t]*\n[ \t]*(?:https?:\/\/|dispon[íi]vel em)/i;

function referenciaVisual(texto) {
  if (TEXTO_SEM_CONTEUDO.test(texto)) return "o texto/peça \"a seguir\" não tem conteúdo extraído (só a fonte) — provavelmente é imagem";
  const match = texto.match(REFERENCIA_DESTAQUE) ?? texto.match(REFERENCIA_IMAGEM) ?? texto.match(REFERENCIA_PECA_VISUAL);
  return match ? `cita elemento visual que o texto extraído não preserva ("${match[0].replace(/\s+/g, " ")}")` : null;
}

export function temReferenciaDeDestaque(texto) {
  return REFERENCIA_DESTAQUE.test(texto);
}

// Só a parte de referenciaVisual que uma MÍDIA pode resolver (figura,
// gráfico, charge, "texto a seguir" que era imagem...). Destaque
// tipográfico (sublinhado, negrito...) fica de fora: nenhuma imagem o
// resolve. rotulos = "figura 1", "grafico 2"... citados no texto.
const ROTULO_MIDIA = /\b(figura|gr[áa]fico|tabela|imagem|quadro|mapa)\s*(?:n[ºo°.]?\s*)?(\d{1,2})\b/gi;
export function referenciaDeMidia(texto) {
  const sinal = TEXTO_SEM_CONTEUDO.test(texto) ? "texto a seguir sem conteúdo extraído" : (texto.match(REFERENCIA_IMAGEM) ?? texto.match(REFERENCIA_PECA_VISUAL))?.[0];
  if (!sinal) return null;
  const rotulos = [...texto.matchAll(ROTULO_MIDIA)].map((m) => `${m[1].normalize("NFD").replace(/\p{M}/gu, "").toLowerCase()} ${Number(m[2])}`);
  return { sinal: sinal.replace(/\s+/g, " "), rotulos: [...new Set(rotulos)] };
}

// Região de texto de apoio que antecede a questão atual: cabeçalho
// "Texto N", bloco "Para responder às questões X e Y..." ou texto sem
// cabeçalho logo abaixo do título de seção no preâmbulo. Só é aceita
// DEPOIS da última alternativa da questão anterior — é dali que ela é
// cortada, para nunca ficar grudada na alternativa E da anterior.
const TAMANHO_MINIMO_TEXTO_IMPLICITO = 300;

function encontrarRegiaoDeTexto(textoCompleto, { inicioBusca, limiteInferior, fimBusca, numeroImpresso, titulos }) {
  const trecho = textoCompleto.slice(inicioBusca, fimBusca);
  const absoluto = (offsetRelativo) => inicioBusca + offsetRelativo;

  const apoio = encontrarBlocosDeApoio(trecho)
    .map((b) => (b.proximas ? { ...b, numeros: new Set(Array.from({ length: b.proximas }, (_, k) => numeroImpresso + k)) } : b))
    .filter((b) => b.numeros.has(numeroImpresso) && absoluto(b.offset) >= limiteInferior)
    .at(-1);
  const cabecalho = [...trecho.matchAll(MARCADOR_TEXTO_BASE)]
    .map((m) => ({ offset: m.index + m[0].search(/\S/), rotulo: m[1] ? Number(m[1]) : null }))
    .filter((c) => absoluto(c.offset) >= limiteInferior)
    .at(-1);

  if (cabecalho || apoio) {
    const inicio = absoluto(Math.min(cabecalho?.offset ?? Infinity, apoio?.offset ?? Infinity));
    const conteudo = textoCompleto.slice(inicio, fimBusca);
    const faixa = conteudo.match(FAIXA_TEXTO_BASE);
    let faixaNumeros = apoio?.numeros ?? null;
    if (!faixaNumeros && faixa) {
      faixaNumeros = new Set();
      for (let n = Number(faixa[1]); n <= Number(faixa[2]); n++) faixaNumeros.add(n);
    }
    return { inicio, fim: fimBusca, tipo: cabecalho ? "cabecalho" : "apoio", rotulo: cabecalho?.rotulo ?? null, faixaNumeros };
  }

  const titulo = titulos.filter((t) => !t.antesDeQuestao && t.inicio >= Math.max(inicioBusca, limiteInferior) && t.inicio < fimBusca).at(-1);
  if (titulo) {
    const inicio = textoCompleto.indexOf("\n", titulo.inicio) + 1;
    if (inicio > 0 && textoCompleto.slice(inicio, fimBusca).trim().length >= TAMANHO_MINIMO_TEXTO_IMPLICITO) {
      return { inicio, fim: fimBusca, tipo: "implicito", rotulo: null, faixaNumeros: null };
    }
  }
  return null;
}

function segmentosDaRegiao(paginas, mapaPaginas, textoCompleto, inicio, fim) {
  const segmentos = [];
  for (const [i, entrada] of mapaPaginas.entries()) {
    const a = Math.max(inicio, entrada.inicio);
    const b = Math.min(fim, entrada.fim);
    if (b > a) segmentos.push({ numeroPagina: entrada.numero, texto: textoCompleto.slice(a, b), itens: paginas[i].itens ?? null });
  }
  return segmentos;
}

// Associação texto-base -> questão. Faixa declarada ("questões 07 e 08",
// "de 1 a 2") associa toda questão da faixa. Sem faixa, o texto só vai
// para a questão que o cita ("segundo o texto", "texto 2", "l. 34",
// "trecho"...), dentro do bloco textual (mesma seção, sem mais de
// LACUNA_MAXIMA_BLOCO_TEXTUAL questões seguidas sem citar texto). Questão
// dentro do bloco que não cita nada fica com dependência incerta (revisão
// manual) — nunca recebe um texto por suposição, nem fica sem ele por
// suposição.
const LACUNA_MAXIMA_BLOCO_TEXTUAL = 3;

function associarTextosBase(rascunhos) {
  let ativos = [];
  let comFaixa = [];
  let secaoAtual;
  let ultimaAtividade = -Infinity;

  for (const [i, q] of rascunhos.entries()) {
    if (q.secao !== secaoAtual) {
      ativos = [];
      comFaixa = [];
      secaoAtual = q.secao;
      ultimaAtividade = -Infinity;
    }
    for (const texto of q.textosQueComecamAqui) {
      if (texto.faixaNumeros) comFaixa.push(texto);
      else ativos.push(texto);
      ultimaAtividade = i;
    }

    const refs = referenciasAoTexto([q.enunciado, ...q.alternativas.map((a) => a.texto)].join("\n"));
    const daFaixa = comFaixa.filter((t) => t.faixaNumeros.has(q.numeroImpresso));
    const coberta = daFaixa.length > 0;
    const noBloco = ativos.length > 0 && i - ultimaAtividade <= LACUNA_MAXIMA_BLOCO_TEXTUAL;
    let principais = [];
    let dependenciaIncerta = null;

    if (noBloco) {
      if (refs.numeros.size > 0) {
        principais = ativos.filter((t) => t.rotulo !== null && refs.numeros.has(t.rotulo));
        if (principais.length < refs.numeros.size) dependenciaIncerta = `cita texto(s) ${[...refs.numeros].join(", ")}, mas nem todos foram localizados na prova`;
      } else if (refs.texto || refs.linhas || (refs.indireta && !coberta)) {
        principais = [ativos.at(-1)];
      } else if (!coberta) {
        dependenciaIncerta = "questão dentro do bloco de um texto-base sem citá-lo explicitamente — confirmar se depende do texto";
      }
    } else if (!coberta && (refs.numeros.size > 0 || refs.linhas)) {
      dependenciaIncerta = "cita texto/linhas, mas nenhum texto-base foi associado";
    }
    if (principais.length > 0 || coberta) ultimaAtividade = i;

    q.textos = [...principais, ...daFaixa.filter((t) => !principais.includes(t))];
    q.dependenciaTextoIncerta = dependenciaIncerta;
  }
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

// Composição declarada da prova (do edital oficial, no metadata do
// staging): [{ materia, inicio, fim }] por número IMPRESSO. Quando existe,
// define a matéria de cada questão e permite cortar o título da
// disciplina ("Raciocínio Lógico-matemático", "Direito Penal (incluindo
// Legislação Penal\nExtravagante)") do fim da questão anterior — só quando
// as últimas linhas do trecho reproduzem EXATAMENTE (normalizado) o nome
// declarado; senão nada é cortado e fica um aviso.
function secaoDaComposicao(composicao, numeroImpresso) {
  return composicao?.find((s) => numeroImpresso >= s.inicio && numeroImpresso <= s.fim) ?? null;
}

function normalizarTitulo(texto) {
  return texto.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]+/g, "");
}

function cortarTituloDoFim(textoCompleto, inicio, fim, nomeSecao) {
  const linhas = textoCompleto.slice(inicio, fim).split("\n");
  let ultima = linhas.length;
  while (ultima > 0 && !linhas[ultima - 1].trim()) ultima--;
  const alvo = normalizarTitulo(nomeSecao);
  let acumulado = "";
  for (let j = ultima - 1; j >= 0; j--) {
    acumulado = normalizarTitulo(linhas[j]) + acumulado;
    if (acumulado === alvo) {
      // Título de bloco em maiúsculas logo antes ("CONHECIMENTOS ESPECÍFICOS") também sai.
      let primeira = j;
      while (primeira > 0 && (!linhas[primeira - 1].trim() || ehTituloSecao(linhas[primeira - 1]))) primeira--;
      return inicio + linhas.slice(0, primeira).join("\n").length;
    }
    if (!alvo.endsWith(acumulado)) return null;
  }
  return null;
}

export function extrairQuestoesDoTexto(paginasOriginais, opcoes = {}) {
  const composicao = Array.isArray(opcoes.composicao) && opcoes.composicao.length > 0 ? opcoes.composicao : null;
  const { paginas, topoRemovido } = removerLinhasCorridas(paginasOriginais);
  const mapaPaginas = construirMapaDePaginas(paginas);
  const textoCompleto = paginas.map((p) => p.texto ?? "").join("\n");

  const candidatos = encontrarCandidatosQuestao(textoCompleto);
  const cabecalhosBloco = encontrarCabecalhosDeBloco(textoCompleto);
  const { itens: sequencia, numerosIgnorados } = montarSegmentos(textoCompleto, candidatos, cabecalhosBloco);
  const titulosSecao = encontrarTitulosDeSecao(textoCompleto, sequencia, mapaPaginas, topoRemovido);

  // 1ª passada: limite de cada questão (título de seção logo antes da
  // próxima não pertence a esta) e a região de texto de apoio que
  // antecede cada questão — que é cortada do fim da anterior.
  const fins = sequencia.map((atual) => {
    const tituloNoFim = titulosSecao.find((t) => t.antesDeQuestao && t.inicio >= atual.inicioSpan && t.inicio < atual.fimSpan);
    return tituloNoFim ? tituloNoFim.inicio : atual.fimSpan;
  });
  const regioes = sequencia.map((atual, i) => {
    let limiteInferior = 0;
    if (i > 0) {
      const anterior = sequencia[i - 1];
      const { offsetUltimaAlternativa } = segmentarAlternativas(textoCompleto.slice(anterior.inicioSpan, fins[i - 1]));
      limiteInferior = offsetUltimaAlternativa === null ? Infinity : anterior.inicioSpan + offsetUltimaAlternativa;
    }
    return encontrarRegiaoDeTexto(textoCompleto, {
      inicioBusca: i === 0 ? 0 : sequencia[i - 1].offsetFimMarcador,
      limiteInferior,
      fimBusca: atual.offsetMarcador,
      numeroImpresso: atual.numeroImpresso,
      titulos: titulosSecao,
    });
  });
  for (let i = 1; i < sequencia.length; i++) if (regioes[i]) fins[i - 1] = Math.min(fins[i - 1], regioes[i].inicio);

  const avisos = [];
  if (composicao) {
    for (let i = 1; i < sequencia.length; i++) {
      const secao = secaoDaComposicao(composicao, sequencia[i].numeroImpresso);
      if (!secao || secao.inicio !== sequencia[i].numeroImpresso) continue;
      // Título já separado da questão anterior (título de seção em
      // maiúsculas, tratado acima): nada a cortar.
      if (normalizarTitulo(textoCompleto.slice(fins[i - 1], sequencia[i].offsetMarcador)).includes(normalizarTitulo(secao.materia))) continue;
      const corte = cortarTituloDoFim(textoCompleto, sequencia[i - 1].inicioSpan, fins[i - 1], secao.materia);
      if (corte === null) avisos.push(`título da seção "${secao.materia}" não encontrado antes da questão ${secao.inicio} — nada cortado`);
      else fins[i - 1] = corte;
    }
  }

  const alertasPorPagina = new Map(paginas.map((p) => [p.numero, p.alertas ?? []]));
  const expressoesPorPagina = new Map(paginas.map((p) => [p.numero, p.expressoes ?? []]));

  // 2ª passada: rascunho de cada questão + textos-base reconstruídos.
  let contadorTextoBase = 0;
  const rascunhos = sequencia.map((atual, i) => {
    const inicioSpan = atual.inicioSpan;
    const fimSpan = fins[i];
    const secao = titulosSecao.filter((t) => t.inicio < atual.offsetMarcador).at(-1)?.titulo ?? null;
    const { enunciado, alternativas, alternativaFaltante } = segmentarAlternativas(textoCompleto.slice(inicioSpan, fimSpan));

    const textosQueComecamAqui = [];
    if (regioes[i]) {
      contadorTextoBase += 1;
      const regiao = regioes[i];
      const segmentos = segmentosDaRegiao(paginas, mapaPaginas, textoCompleto, regiao.inicio, regiao.fim);
      const reconstruido = reconstruirTextoBase(segmentos);
      const alertas = segmentos.flatMap((s) => alertasPorPagina.get(s.numeroPagina) ?? []);
      textosQueComecamAqui.push({
        id: `TB${contadorTextoBase}`,
        tipo: regiao.tipo,
        rotulo: regiao.rotulo,
        faixaNumeros: regiao.faixaNumeros,
        conteudo: reconstruido.texto,
        confiavel: reconstruido.confiavel && alertas.length === 0,
        motivo: reconstruido.motivo ?? (alertas.length > 0 ? "expressão matemática incerta na região do texto" : null),
        linhasNumeradas: reconstruido.linhasNumeradas ?? false,
      });
    }

    const paginaInicio = paginaDoOffset(mapaPaginas, atual.offsetMarcador);
    const paginaFim = paginaDoOffset(mapaPaginas, fimSpan > inicioSpan ? fimSpan - 1 : fimSpan);
    const paginasDaQuestao = [...mapaPaginas.map((p) => p.numero)].filter((n) => n >= paginaInicio && n <= paginaFim);
    const conteudoDaQuestao = [enunciado, ...alternativas.map((a) => a.texto)].join("\n");

    return {
      numeroImpresso: atual.numeroImpresso,
      materia: secaoDaComposicao(composicao, atual.numeroImpresso)?.materia ?? atual.materia ?? secao,
      secao: secaoDaComposicao(composicao, atual.numeroImpresso)?.materia ?? atual.materia ?? secao,
      enunciado,
      alternativas,
      alternativaFaltante,
      paginaInicio,
      paginaFim,
      contagemMateriaDivergente: atual.contagemMateriaDivergente,
      textosQueComecamAqui,
      alertasExpressao: paginasDaQuestao.flatMap((n) => alertasPorPagina.get(n) ?? []),
      expressoes: paginasDaQuestao.flatMap((n) => expressoesPorPagina.get(n) ?? []).filter((e) => conteudoDaQuestao.includes(e.texto)).map((e) => ({ tipo: e.tipo, texto: e.texto })),
    };
  });

  associarTextosBase(rascunhos);

  const questoes = rascunhos.map((r, i) => ({
    numero_original: i + 1,
    numero_impresso: r.numeroImpresso,
    materia_detectada: r.materia,
    enunciado: r.enunciado,
    alternativas: r.alternativas,
    pagina_origem: r.paginaInicio,
    atravessa_pagina: r.paginaFim !== null && r.paginaInicio !== null && r.paginaFim !== r.paginaInicio,
    texto_base_id: r.textos[0]?.id ?? null,
    texto_base: r.textos[0]?.conteudo ?? null,
    textos_base: r.textos.map((t) => ({ id: t.id, tipo: t.tipo, texto: t.conteudo, confiavel: t.confiavel, motivo: t.motivo, linhas_numeradas: t.linhasNumeradas })),
    dependencia_texto_incerta: r.dependenciaTextoIncerta,
    alternativa_suspeita: alternativaSuspeita(r.alternativas),
    referencia_visual: referenciaVisual([r.enunciado, ...r.alternativas.map((a) => a.texto)].join("\n")),
    alertas_expressao: r.alertasExpressao,
    expressoes: r.expressoes,
    alternativa_faltante: r.alternativaFaltante,
    contagem_materia_divergente: r.contagemMateriaDivergente,
  }));

  // Contagem declarada x encontrada por seção da composição.
  if (composicao) {
    for (const secao of composicao) {
      const encontradas = questoes.filter((q) => q.numero_impresso >= secao.inicio && q.numero_impresso <= secao.fim);
      if (encontradas.length !== secao.fim - secao.inicio + 1) {
        avisos.push(`seção "${secao.materia}" declara ${secao.fim - secao.inicio + 1} questões e foram encontradas ${encontradas.length}`);
        for (const q of encontradas) q.contagem_materia_divergente = true;
      }
    }
  }

  return { questoes, numerosIgnorados, avisos };
}
