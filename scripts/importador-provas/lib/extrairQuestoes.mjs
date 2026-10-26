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

import { normalizarTexto } from "./deduplicar.mjs";
import { encontrarBlocosDeApoio, reconstruirTextoBase, referenciasAoTexto } from "./textoBase.mjs";

const MARCADOR_QUESTAO = /(?:^|\n)[ \t]*(\d{1,3})[.)][ \t]+/g;
// Marcador explícito "QUESTÃO 01 –" / "Questão 12:" no início da linha —
// convenção comum de várias bancas (checado numa prova real: Fundatec/
// Polícia Penal RS 2026, "QUESTÃO 01 – Considerando..."). Quando o
// documento numera questões assim, números soltos "1." / "2)" são listas
// internas (instruções da capa, itens de enunciado) e deixam de ser
// candidatos: sem isso, a lista de instruções "1. ... 11." da capa da
// mesma prova emendava na sequência real e ocupava as questões 1 a 11.
// "QUESTÂO" (Â no lugar de Ã) é erro de impressão da própria banca no
// marcador (checado numa prova real: Fundatec/SEJUSP-MG 2022, Q43 e Q45
// do TIPO 1) — vale só como marcador estrutural; o texto bruto não muda.
const MARCADOR_QUESTAO_EXPLICITO = /(?:^|\n)[ \t]*(?:QUEST[ÃÂA]O|Quest[ãâa]o)[ \t]+(\d{1,3})[ \t]*[-–—:.)][ \t]*/g;
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

// Carimbo de um SUB-caderno: um caderno pode juntar partes impressas em
// separado, cada uma com o próprio carimbo no topo (checado numa prova
// real: Fundatec/IGP-RS 2025 — parte comum, parte específica e redação,
// com carimbos diferentes). O carimbo da parte comum fica em menos da
// metade das páginas do documento, mas é a PRIMEIRA (ou a ÚLTIMA) linha
// de várias páginas CONSECUTIVAS — posição que conteúdo de questão não
// repete. Marcador de questão/alternativa nunca conta ("QUESTÃO # –
// Assinale..." ou "E) Apenas I." podem abrir/fechar páginas seguidas).
const MARCADOR_DE_CONTEUDO = /^(?:\(?[A-Ea-e][ \t]*(?:\)|⇒|→|\.)|(?:QUEST[ÃÂA]O|Quest[ãâa]o)[ \t]+#|#[.)])/;

function chavesEmExtremoDePaginasConsecutivas(paginasDeLinhas) {
  const chaves = new Set();
  for (const extremo of [(l) => l[0], (l) => l.at(-1)]) {
    let anterior = null;
    let sequencia = 0;
    for (const linhas of paginasDeLinhas) {
      const chave = linhas.length > 0 ? chaveLinhaCorrida(extremo(linhas)) : null;
      sequencia = chave !== null && chave === anterior ? sequencia + 1 : 1;
      anterior = chave;
      if (chave !== null && sequencia >= MINIMO_PAGINAS_LINHA_CORRIDA && chave !== "#" && !MARCADOR_DE_CONTEUDO.test(chave)) chaves.add(chave);
    }
  }
  return chaves;
}

function bordasDasPaginas(paginas) {
  return paginas.map((p) => {
    const linhas = (p.texto ?? "").split("\n");
    const indices = linhas.map((l, i) => (l.trim() ? i : -1)).filter((i) => i >= 0);
    return { linhas, borda: new Set([...indices.slice(0, LINHAS_BORDA_PAGINA), ...indices.slice(-LINHAS_BORDA_PAGINA)]) };
  });
}

// Chaves (números como "#") das linhas corridas do documento — o MESMO
// critério da remoção, reaproveitado pelo gate de integridade
// (lib/integridade.mjs) para achar fragmento de cabeçalho/rodapé que
// escapou da remoção e grudou numa questão.
export function chavesDeLinhasCorridas(paginas) {
  return encontrarCorridas(bordasDasPaginas(paginas), paginas.length);
}

function encontrarCorridas(bordas, totalPaginas) {
  const paginasPorLinha = new Map();
  for (const { linhas, borda } of bordas) {
    for (const texto of new Set([...borda].map((i) => chaveLinhaCorrida(linhas[i])))) paginasPorLinha.set(texto, (paginasPorLinha.get(texto) ?? 0) + 1);
  }
  // Linha só de número (ex.: "1", que pode ser a própria questão no topo
  // da página) nunca é tratada como corrida.
  const corridas = new Set(
    [...paginasPorLinha].filter(([texto, n]) => texto !== "#" && n >= MINIMO_PAGINAS_LINHA_CORRIDA && n >= totalPaginas / 2).map(([texto]) => texto),
  );
  // O extremo é medido sem as linhas corridas já confirmadas (o carimbo
  // pode vir logo abaixo de um "Execução: ..." comum a todas as páginas).
  const semCorridas = bordas.map(({ linhas }) => linhas.filter((l) => l.trim() && !corridas.has(chaveLinhaCorrida(l))));
  for (const chave of chavesEmExtremoDePaginasConsecutivas(semCorridas)) corridas.add(chave);
  return corridas;
}

function removerLinhasCorridas(paginas) {
  const bordas = bordasDasPaginas(paginas);
  const corridas = encontrarCorridas(bordas, paginas.length);
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
  if (selecionarSequenciaValida(explicitos).length >= MINIMO_SEQUENCIA_EXPLICITA) return Object.assign(explicitos, { familia: "explicito" });
  const pontuados = candidatosDoMarcador(textoCompleto, MARCADOR_QUESTAO);
  const isolados = candidatosDoMarcador(textoCompleto, MARCADOR_QUESTAO_ISOLADO);
  const sequenciaIsolada = selecionarSequenciaValida(isolados).length;
  if (sequenciaIsolada >= MINIMO_SEQUENCIA_EXPLICITA && sequenciaIsolada > selecionarSequenciaValida(pontuados).length) return Object.assign(isolados, { familia: "isolado" });
  return Object.assign(pontuados, { familia: "pontuado" });
}

// Cadernos concatenados num único PDF (checado numa prova real: Fundatec/
// PC-RS 2025 Delegado — P1 e P2, cada uma em 4 tipos, 8 cadernos no mesmo
// arquivo): a numeração recomeça em 1 a cada caderno. A maior sequência
// +1 emendaria "1..40" de um caderno com "41..80" de outro, misturando
// questões e gabaritos sem nenhum aviso. Cada recomeço em 1 que sustenta
// MINIMO_QUESTOES_CADERNO+ questões até o próximo recomeço é um caderno;
// com dois ou mais, nenhuma sequência é escolhida — a parte a extrair
// precisa ser declarada (metadata.parte.paginas). Listas internas de
// enunciado ("1. ... 2. ... 3.") nunca chegam a esse tamanho. Só vale
// para "QUESTÃO N" e "N." (ver extrairQuestoesDoTexto).
const MINIMO_QUESTOES_CADERNO = 10;

function encontrarCadernos(candidatos) {
  const ordenados = [...candidatos].sort((a, b) => a.offsetMarcador - b.offsetMarcador);
  const recomecos = ordenados.filter((c) => c.numero === 1);
  const cadernos = [];
  for (const [i, inicio] of recomecos.entries()) {
    const limite = recomecos[i + 1]?.offsetMarcador ?? Infinity;
    const doTrecho = ordenados.filter((c) => c.offsetMarcador >= inicio.offsetMarcador && c.offsetMarcador < limite);
    let atual = inicio;
    let tamanho = 1;
    for (const c of doTrecho) {
      if (c.numero === atual.numero + 1 && c.offsetMarcador > atual.offsetMarcador) {
        atual = c;
        tamanho++;
      }
    }
    if (tamanho >= MINIMO_QUESTOES_CADERNO) cadernos.push({ inicio: inicio.offsetMarcador, fim: atual.offsetMarcador, questoes: tamanho });
  }
  return cadernos;
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
// Diagrama/fluxograma/esquema só contam como peça visual com contexto de
// posição explícito ("diagrama lógico abaixo", "fluxograma a seguir",
// "esquema apresentado") — "esquema de corrupção", "diagramas de Venn"
// soltos não bastam (checado numa prova real: Fundatec/Araquari 2025,
// questão 15 passava sem mídia nem gate). "esquema" é o mais ambíguo e
// "apresentado/dado" também narra ("esquema tático dado pelo treinador"):
// fora diagrama/fluxograma + posição, aceita no máximo uma palavra entre
// o termo e a posição, e o particípio nunca seguido de agente (por/pelo).
const DIAGRAMA = "(?:diagramas?|fluxogramas?)";
const ESQUEMATICO = "(?:diagramas?|fluxogramas?|esquemas?)";
const UMA_PALAVRA = "(?:[ \\t\\n]+[^\\s.,;:()]+)?[ \\t\\n]+";
const REFERENCIA_ESQUEMA_VISUAL = new RegExp(
  [
    `\\b${DIAGRAMA}\\b[^.\\n]{0,25}?\\b(?:a seguir|abaixo|acima|ao lado)\\b`,
    `\\b${ESQUEMATICO}${UMA_PALAVRA}(?:a seguir|abaixo|acima|ao lado|seguintes?)\\b`,
    `\\b${ESQUEMATICO}${UMA_PALAVRA}(?:apresentad|dad)[ao]s?\\b(?![ \\t\\n]+(?:por|pel[ao]s?)\\b)`,
    `\\b(?:seguintes?|abaixo)[ \\t\\n]+${ESQUEMATICO}\\b`,
  ].join("|"),
  "i",
);
const TEXTO_SEM_CONTEUDO = /\b(?:leia|observe|analise|considere)\b[^\n]{0,60}?\ba seguir\b[^\n]{0,60}:?[ \t]*\n[ \t]*(?:https?:\/\/|dispon[íi]vel em)/i;

function referenciaVisual(texto) {
  if (TEXTO_SEM_CONTEUDO.test(texto)) return "o texto/peça \"a seguir\" não tem conteúdo extraído (só a fonte) — provavelmente é imagem";
  const match = texto.match(REFERENCIA_DESTAQUE) ?? texto.match(REFERENCIA_IMAGEM) ?? texto.match(REFERENCIA_PECA_VISUAL) ?? texto.match(REFERENCIA_ESQUEMA_VISUAL);
  return match ? `cita elemento visual que o texto extraído não preserva ("${match[0].replace(/\s+/g, " ")}")` : null;
}

// "pontos ... destacados na figura": o destaque está DENTRO da peça visual
// — a mídia extraída o preserva, não é destaque tipográfico do texto
// (checado numa prova real: Fundatec/GM Sant'Ana do Livramento 2025,
// questão 46).
const DESTAQUE_NA_PECA = /\b(?:destacad[ao]s?|em destaque|hachurad[ao]s?)[ \t\n]+(?:n[ao]s?|em)[ \t\n]+(?:figuras?|imagens?|ilustra[çc][ãa]o|gr[áa]ficos?|mapas?|quadros?|tabelas?|charges?)\b/gi;

export function temReferenciaDeDestaque(texto) {
  return REFERENCIA_DESTAQUE.test((texto ?? "").replace(DESTAQUE_NA_PECA, " "));
}

// Só a parte de referenciaVisual que uma MÍDIA pode resolver (figura,
// gráfico, charge, "texto a seguir" que era imagem...). Destaque
// tipográfico (sublinhado, negrito...) fica de fora: nenhuma imagem o
// resolve. rotulos = "figura 1", "grafico 2"... citados no texto.
const ROTULO_MIDIA = /\b(figura|gr[áa]fico|tabela|imagem|quadro|mapa)\s*(?:n[ºo°.]?\s*)?(\d{1,2})\b/gi;
export function referenciaDeMidia(texto) {
  const sinal = TEXTO_SEM_CONTEUDO.test(texto) ? "texto a seguir sem conteúdo extraído" : (texto.match(REFERENCIA_IMAGEM) ?? texto.match(REFERENCIA_PECA_VISUAL) ?? texto.match(REFERENCIA_ESQUEMA_VISUAL))?.[0];
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

function encontrarRegiaoDeTexto(textoCompleto, { inicioBusca, limiteInferior, fimBusca, numeroImpresso, titulos, mapaPaginas, entreQuestoes }) {
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
  return entreQuestoes ? encontrarTextoNumerado(textoCompleto, mapaPaginas, limiteInferior, fimBusca) : null;
}

// Texto-base SEM nenhum cabeçalho entre duas questões: o sinal forte é a
// numeração de linhas recomeçando em 1 depois da última alternativa da
// questão anterior (checado numa prova real: Fundatec/PC-RS 2025 Delegado
// P1 — um texto em três partes, cada uma no topo de uma página com título,
// subtítulo, autoria e linhas 01… próprias; sem isto, as partes 2 e 3
// grudavam na alternativa E das questões 11 e 21 e todas as questões
// seguintes recebiam a parte 1, passando por todos os gates). Sozinho, o
// recomeço não basta — exige também: MINIMO_LINHAS_TEXTO_NUMERADO linhas
// CONTÍGUAS 1, 2, 3... (a leitura linear entrega os números sozinhos, a
// posicional com o conteúdo ao lado: as duas formas contam), corpo de
// texto de TAMANHO_MINIMO_TEXTO_IMPLICITO+ caracteres e uma fronteira
// provada com a alternativa anterior. Autoria ("Por ...") e fonte
// ("Disponível em") nunca são exigidas. Fronteira sem prova (abertura
// longa demais, linha em minúscula, alternativa sem pontuação final) não
// muda nada: o candidato é descartado e a extração fica exatamente como
// sem este detector — nenhum texto criado, nenhuma alternativa cortada.
// O detector só SEPARA um texto novo de um texto-base ainda ativo (o que
// seria herdado se o bloco novo não fosse reconhecido) — não descobre o
// primeiro texto-base de uma prova: ver extrairQuestoesDoTexto.
const NUMERO_DE_LINHA_NO_INICIO = /^[ \t]*(\d{1,3})(?=[ \t]|$)/;
const MINIMO_LINHAS_TEXTO_NUMERADO = 5;
// Linhas de abertura (título, subtítulo, autoria) entre a alternativa e a
// linha 1 — o mesmo limite das bordas de página.
const MAXIMO_LINHAS_DE_ABERTURA = LINHAS_BORDA_PAGINA;
const ALTERNATIVA_ENCERRADA = /[.!?…;:)”"»]$/;

function encontrarTextoNumerado(textoCompleto, mapaPaginas, limiteInferior, fimBusca) {
  if (!Number.isFinite(limiteInferior)) return null;
  const quebraDaAlternativa = textoCompleto.indexOf("\n", limiteInferior);
  if (quebraDaAlternativa === -1 || quebraDaAlternativa >= fimBusca) return null;
  const inicioDasLinhas = quebraDaAlternativa + 1;
  const linhas = [];
  let offset = inicioDasLinhas;
  for (const texto of textoCompleto.slice(inicioDasLinhas, fimBusca).split("\n")) {
    linhas.push({ texto, inicio: offset, numero: Number(texto.match(NUMERO_DE_LINHA_NO_INICIO)?.[1] ?? NaN) });
    offset += texto.length + 1;
  }
  const primeira = linhas.findIndex((l, k) => l.numero === 1 && linhas.slice(k, k + MINIMO_LINHAS_TEXTO_NUMERADO).every((x, j) => x.numero === j + 1));
  if (primeira === -1) return null;
  const corpo = linhas.slice(primeira).map((l) => l.texto.replace(NUMERO_DE_LINHA_NO_INICIO, "")).join(" ").trim();
  if (corpo.length < TAMANHO_MINIMO_TEXTO_IMPLICITO) return null;

  const linhaUm = linhas[primeira];
  const naoVazias = (de, ate) => textoCompleto.slice(de, ate).split("\n").filter((l) => l.trim());
  const comecaEmMinuscula = (l) => /^[a-zà-öø-ÿ]/.test(l.trim());
  const paginaDaLinhaUm = mapaPaginas.find((p) => linhaUm.inicio >= p.inicio && linhaUm.inicio <= p.fim);
  let inicio = null;
  if (paginaDaLinhaUm && paginaDaLinhaUm.inicio > limiteInferior) {
    // Texto no topo de uma página seguinte: começa no início da página.
    const abertura = naoVazias(paginaDaLinhaUm.inicio, linhaUm.inicio);
    if (abertura.length <= MAXIMO_LINHAS_DE_ABERTURA && !abertura.some(comecaEmMinuscula)) inicio = paginaDaLinhaUm.inicio;
  } else {
    // Mesma página: as linhas de abertura só vão para o texto se a
    // alternativa terminou na própria linha (pontuação final).
    const abertura = naoVazias(inicioDasLinhas, linhaUm.inicio);
    const linhaDaAlternativa = textoCompleto.slice(limiteInferior, quebraDaAlternativa).trim();
    if (abertura.length === 0) inicio = linhaUm.inicio;
    else if (abertura.length <= MAXIMO_LINHAS_DE_ABERTURA && ALTERNATIVA_ENCERRADA.test(linhaDaAlternativa) && !abertura.some(comecaEmMinuscula)) inicio = inicioDasLinhas;
  }
  return inicio === null ? null : { inicio, fim: fimBusca, tipo: "numerado", rotulo: null, faixaNumeros: null };
}

function segmentosDaRegiao(paginas, mapaPaginas, textoCompleto, inicio, fim) {
  const segmentos = [];
  for (const [i, entrada] of mapaPaginas.entries()) {
    const a = Math.max(inicio, entrada.inicio);
    const b = Math.min(fim, entrada.fim);
    if (b > a) segmentos.push({ numeroPagina: entrada.numero, texto: textoCompleto.slice(a, b), itens: paginas[i].itens ?? null, linhas: paginas[i].linhas ?? null });
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
const REFERENCIA_A_VARIOS_TEXTOS =
  /\b(?:os|ambos[ \t\n]+os|dois|tr[eê]s|quatro|cinco)[ \t\n]+textos\b(?![ \t\n]*(?:\d|[IVX]+\b))|\b(?:duas|tr[eê]s|quatro|cinco|v[áa]rias|todas[ \t\n]+as)[ \t\n]+partes[ \t\n]+do[ \t\n]+texto\b/i;

// Defesa independente da detecção: a questão cita linha(s) do texto que
// recebeu ("l. 12", "linhas 10 e 11", "(l. 27-28)") — a linha precisa
// existir NELE; e o trecho citado junto da linha ("“...” (l. 04)") precisa
// estar naquelas linhas. Compara o texto normalizado sem espaços (a quebra
// de linha do PDF pode partir uma palavra), por partes quando o trecho tem
// supressão ("...", "(...)"); nunca por semelhança. Só olha textos
// confiáveis com numeração reconhecida — texto não confiável já vai para
// revisão; texto confiável sem numeração não tem a linha citada.
const LINHAS_CITADAS = /(?:\bls?\.|\blinhas?\b)[ \t\n]*(\d{1,3})(?:[ \t\n]*(?:-|–|a|e|até)[ \t\n]*(\d{1,3}))?/gi;
const TRECHO_COM_LINHA = /“([^”]{1,300})”[ \t\n]*\([ \t\n]*(?:ls?\.|linhas?)[ \t\n]*(\d{1,3})(?:[ \t\n]*(?:-|–|a|e|até)[ \t\n]*(\d{1,3}))?[ \t\n]*\)/gi;
const SUPRESSAO_NO_TRECHO = /\.{3,}|…|_{2,}|\([ \t]*\.\.\.[ \t]*\)|\[[ \t]*\.\.\.[ \t]*\]/;
const LACUNA_NO_TEXTO = /_{3,}|\.{4,}/;
const compacto = (texto) => normalizarTexto(texto).replace(/ /g, "");

function inconsistenciasDoTextoBase(r) {
  const textos = r.textos ?? [];
  if (textos.length === 0 || !textos.every((t) => t.confiavel)) return [];
  const conteudoQuestao = [r.enunciado, ...r.alternativas.map((a) => a.texto)].join("\n");
  const citadas = [...conteudoQuestao.matchAll(LINHAS_CITADAS)].map((m) => ({ de: Number(m[1]), ate: Number(m[2] ?? m[1]), texto: m[0].replace(/\s+/g, " ") }));
  if (citadas.length === 0) return [];
  const linhasDoTexto = new Map();
  for (const t of textos) for (const m of t.conteudo.matchAll(/^\[(\d{1,3})\][ \t]?(.*)$/gm)) linhasDoTexto.set(Number(m[1]), `${linhasDoTexto.get(Number(m[1])) ?? ""} ${m[2]}`);
  const ultima = Math.max(0, ...linhasDoTexto.keys());
  const fora = citadas.filter((c) => c.de > ultima || c.ate > ultima);
  if (fora.length > 0) {
    const descricao = ultima === 0 ? "o texto-base associado não tem numeração de linhas reconhecida" : `o texto-base associado vai só até a linha ${ultima}`;
    return [{ codigo: "referencia_linha_fora_do_texto_base", motivo: `cita ${fora.map((c) => `"${c.texto}"`).join(", ")}, mas ${descricao}` }];
  }
  const ausentes = [];
  for (const m of conteudoQuestao.matchAll(TRECHO_COM_LINHA)) {
    const de = Number(m[2]);
    const ate = Number(m[3] ?? m[2]);
    const linhasDaJanela = Array.from({ length: (m[3] ? ate : de + 1) - de + 1 }, (_, k) => linhasDoTexto.get(de + k) ?? "").join(" ");
    // Trecho com lacuna citando linha que também tem lacuna ("“en__urrada”
    // (l. 02)" para a palavra que preenche o "________" da linha — checado
    // numa prova real: Fundatec/PP-RS 2022, questão 16): não há como
    // conferir sem supor o preenchimento — nada é sinalizado.
    if (SUPRESSAO_NO_TRECHO.test(m[1]) && LACUNA_NO_TEXTO.test(linhasDaJanela)) continue;
    const janela = compacto(linhasDaJanela);
    const partes = m[1].split(SUPRESSAO_NO_TRECHO).map(compacto).filter(Boolean);
    if (partes.length > 0 && !partes.every((p) => janela.includes(p))) ausentes.push(`“${m[1].replace(/\s+/g, " ")}” (l. ${m[3] ? `${de}-${ate}` : de})`);
  }
  return ausentes.length > 0 ? [{ codigo: "citacao_ausente_do_texto_base", motivo: `trecho citado não está na(s) linha(s) indicada(s) do texto-base associado: ${ausentes.join("; ")}` }] : [];
}

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
    // Texto-base sem faixa que esta questão herdaria (se o citar) caso
    // nenhum texto novo começasse aqui.
    q.blocoAtivoNaEntrada = ativos.length > 0 && i - ultimaAtividade <= LACUNA_MAXIMA_BLOCO_TEXTUAL;
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
        // "As três partes do texto...", "os dois textos": só o mais recente
        // seria anexado — a questão pede mais do que vai receber.
        if (ativos.length > 1 && REFERENCIA_A_VARIOS_TEXTOS.test([q.enunciado, ...q.alternativas.map((a) => a.texto)].join("\n"))) {
          dependenciaIncerta = "cita mais de um texto (ou partes do texto), mas só o texto-base mais recente seria associado";
        }
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

// Título de nova seção DEPOIS da última alternativa: tudo dali em diante
// não pertence à questão (checado numa prova real: Fundatec/IGP-RS 2025 —
// "LÍNGUA INGLESA" + texto em inglês entre a última alternativa da questão
// 15 e a questão 16; "PROVA DE REDAÇÃO" + instruções depois da última
// alternativa da última questão). Só corta título inequívoco: linha em
// maiúsculas, com palavra de 4+ letras (não "I, II, III, IV"), que é o
// nome declarado da próxima seção na composição OU abre um bloco de
// TAMANHO_MINIMO_TEXTO_IMPLICITO+ caracteres antes da próxima questão (ou
// do fim do documento). Se o título está no topo de uma página seguinte,
// o corte vai para o início dessa página — o carimbo/cabeçalho da página
// nova também não é da questão —, desde que nada antes dele na página
// pareça continuação da alternativa (linha começando em minúscula).
const PALAVRA_DE_TITULO = /[A-ZÀ-ÖØ-Þ]{4,}/;

function corteDeSecaoAposUltimaAlternativa(textoCompleto, mapaPaginas, inicioSpan, fimSpan, proximaSecao) {
  const { offsetUltimaAlternativa } = segmentarAlternativas(textoCompleto.slice(inicioSpan, fimSpan));
  if (offsetUltimaAlternativa === null) return null;
  const inicioUltima = inicioSpan + offsetUltimaAlternativa;
  const quebra = textoCompleto.indexOf("\n", inicioUltima);
  if (quebra === -1 || quebra >= fimSpan) return null;
  let inicioLinha = quebra + 1;
  for (const linha of textoCompleto.slice(inicioLinha, fimSpan).split("\n")) {
    const fimLinha = inicioLinha + linha.length;
    const inequivoco =
      ehTituloSecao(linha) &&
      PALAVRA_DE_TITULO.test(linha) &&
      ((proximaSecao && normalizarTitulo(linha) === normalizarTitulo(proximaSecao)) || textoCompleto.slice(fimLinha, fimSpan).trim().length >= TAMANHO_MINIMO_TEXTO_IMPLICITO);
    if (inequivoco) {
      const pagina = mapaPaginas.find((p) => inicioLinha >= p.inicio && inicioLinha <= p.fim);
      if (pagina && pagina.inicio > inicioUltima) {
        const antes = textoCompleto.slice(pagina.inicio, inicioLinha).split("\n").filter((l) => l.trim());
        if (antes.length < LINHAS_BORDA_PAGINA && !antes.some((l) => /^[a-zà-öø-ÿ]/.test(l.trim()))) return pagina.inicio;
      }
      return inicioLinha;
    }
    inicioLinha = fimLinha + 1;
  }
  return null;
}

// Texto numerado implícito (encontrarTextoNumerado) só entra quando separa
// um texto novo de um texto-base ainda ATIVO. Os candidatos são decididos
// em ordem de documento, cada um pela associação da extração SEM ele (com
// os anteriores já decididos): aceito só se, na entrada da sua questão, um
// texto-base continua no bloco (associarTextosBase) e seria herdado. Sem
// candidato aceito, a extração é exatamente a de antes do detector. A lista
// de candidatos não depende dos aceitos (o limite de cada um vem da última
// alternativa da questão anterior antes de qualquer corte por região).
export function extrairQuestoesDoTexto(paginasOriginais, opcoes = {}) {
  const aceitos = new Set();
  let extracao = extrairComTextosNumerados(paginasOriginais, opcoes, aceitos);
  for (const i of extracao.candidatosNumerados) {
    if (!extracao.blocoAtivoNaEntrada[i]) continue;
    aceitos.add(i);
    extracao = extrairComTextosNumerados(paginasOriginais, opcoes, aceitos);
  }
  return extracao.resultado;
}

function extrairComTextosNumerados(paginasOriginais, opcoes, aceitos) {
  const composicao = Array.isArray(opcoes.composicao) && opcoes.composicao.length > 0 ? opcoes.composicao : null;
  const { paginas, topoRemovido } = removerLinhasCorridas(paginasOriginais);
  const mapaPaginas = construirMapaDePaginas(paginas);
  const textoCompleto = paginas.map((p) => p.texto ?? "").join("\n");

  const candidatos = encontrarCandidatosQuestao(textoCompleto);
  const cabecalhosBloco = encontrarCabecalhosDeBloco(textoCompleto);
  // Numeração por bloco declarado ("Português 5 questões") recomeça de
  // propósito e já é tratada por montarSegmentos — não é caderno novo.
  // Número isolado na linha fica de fora: a numeração de linhas de cada
  // texto-base ("01", "02"...) também recomeça em 1 e seria confundida.
  const cadernos = cabecalhosBloco.length === 0 && candidatos.familia !== "isolado" ? encontrarCadernos(candidatos) : [];
  if (cadernos.length > 1) {
    const descricao = cadernos.map((c) => `p. ${paginaDoOffset(mapaPaginas, c.inicio)}–${paginaDoOffset(mapaPaginas, c.fim)} (${c.questoes} questões)`);
    return {
      resultado: {
        questoes: [],
        numerosIgnorados: [],
        avisos: [],
        cadernos: descricao,
        bloqueio: `documento com ${cadernos.length} cadernos/partes concatenados (a numeração recomeça em 1): ${descricao.join("; ")} — declare a parte a extrair (metadata.parte.paginas); nenhuma sequência é escolhida entre cadernos`,
      },
      candidatosNumerados: [],
      blocoAtivoNaEntrada: [],
    };
  }
  const { itens: sequencia, numerosIgnorados } = montarSegmentos(textoCompleto, candidatos, cabecalhosBloco);
  const titulosSecao = encontrarTitulosDeSecao(textoCompleto, sequencia, mapaPaginas, topoRemovido);

  // 1ª passada: limite de cada questão (título de seção logo antes da
  // próxima não pertence a esta) e a região de texto de apoio que
  // antecede cada questão — que é cortada do fim da anterior.
  const fins = sequencia.map((atual) => {
    const tituloNoFim = titulosSecao.find((t) => t.antesDeQuestao && t.inicio >= atual.inicioSpan && t.inicio < atual.fimSpan);
    return tituloNoFim ? tituloNoFim.inicio : atual.fimSpan;
  });
  const candidatosNumerados = [];
  const regioes = sequencia.map((atual, i) => {
    let limiteInferior = 0;
    if (i > 0) {
      const anterior = sequencia[i - 1];
      const { offsetUltimaAlternativa } = segmentarAlternativas(textoCompleto.slice(anterior.inicioSpan, fins[i - 1]));
      limiteInferior = offsetUltimaAlternativa === null ? Infinity : anterior.inicioSpan + offsetUltimaAlternativa;
    }
    const regiao = encontrarRegiaoDeTexto(textoCompleto, {
      inicioBusca: i === 0 ? 0 : sequencia[i - 1].offsetFimMarcador,
      limiteInferior,
      fimBusca: atual.offsetMarcador,
      numeroImpresso: atual.numeroImpresso,
      titulos: titulosSecao,
      mapaPaginas,
      entreQuestoes: i > 0,
    });
    if (regiao?.tipo !== "numerado") return regiao;
    candidatosNumerados.push(i);
    return aceitos.has(i) ? regiao : null;
  });
  for (let i = 1; i < sequencia.length; i++) if (regioes[i]) fins[i - 1] = Math.min(fins[i - 1], regioes[i].inicio);
  for (let i = 0; i < sequencia.length; i++) {
    const proxima = sequencia[i + 1];
    const proximaSecao = proxima ? secaoDaComposicao(composicao, proxima.numeroImpresso) : null;
    const nomeProximaSecao = proximaSecao && proximaSecao.inicio === proxima.numeroImpresso ? proximaSecao.materia : null;
    const corte = corteDeSecaoAposUltimaAlternativa(textoCompleto, mapaPaginas, sequencia[i].inicioSpan, fins[i], nomeProximaSecao);
    if (corte !== null) fins[i] = Math.min(fins[i], corte);
  }

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
  for (const r of rascunhos) r.inconsistencias = inconsistenciasDoTextoBase(r);

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
    ...(r.inconsistencias.length > 0 ? { inconsistencias_texto_base: r.inconsistencias } : {}),
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

  return {
    resultado: { questoes, numerosIgnorados, avisos, cadernos: [], bloqueio: null },
    candidatosNumerados,
    blocoAtivoNaEntrada: rascunhos.map((r) => r.blocoAtivoNaEntrada),
  };
}
