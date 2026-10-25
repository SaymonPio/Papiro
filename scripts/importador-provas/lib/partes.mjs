// Recorte de um PDF oficial que concatena vários cadernos (checado em provas
// reais: Fundatec/PC-RS 2025 Delegado — P1 e P2 em 4 tipos no mesmo
// arquivo; Fundatec/PC-RS 2025 Escrivão-Inspetor — P1 e P2 por tipo;
// Fundatec/SEJUSP-MG 2022 — 4 tipos da mesma prova). A numeração recomeça
// em 1 a cada caderno, então o número da questão sozinho não identifica a
// parte: o intervalo de páginas precisa ser DECLARADO no staging, nunca
// inferido do conteúdo.
//
// Duas declarações, mutuamente exclusivas:
// - metadata.parte = { codigo, nome, ordem, paginas: [início, fim], ... }:
//   parte de uma prova (P1/P2), gravada em public.prova_partes;
// - metadata.caderno = { paginas: [início, fim], ... }: só o recorte físico
//   do caderno canônico quando os cadernos são versões (tipos) da MESMA
//   prova — não cria parte.
// Gates opcionais, determinísticos, aceitos nas duas:
// - cabecalho: carimbo/identificador impresso nas páginas do caderno
//   (ex.: "BASE_TIPO1_NS_DT") — precisa estar em toda página de onde sai
//   uma questão e em nenhuma página fora do intervalo;
// - total_questoes: número exato de questões do caderno;
// - gabarito_bloco: o bloco do gabarito tem de ser exatamente este.
// Qualquer divergência BLOQUEIA: nenhuma parte é escolhida em silêncio.

const normalizar = (texto) => (texto ?? "").replace(/\s+/g, " ").trim().toLowerCase();
// Linha curta ("01", "A) b") aparece em qualquer lugar; só linha com texto conta como vazamento.
const TAMANHO_MINIMO_LINHA_VAZADA = 12;

function intervaloValido(paginas, totalPaginas) {
  return Array.isArray(paginas) && paginas.length === 2 && paginas.every(Number.isInteger) && paginas[0] >= 1 && paginas[0] <= paginas[1] && paginas[1] <= totalPaginas;
}

// Declaração ativa (parte ou caderno) e as páginas a ler. Sem declaração,
// o documento inteiro, exatamente como antes.
export function selecionarIntervalo(metadata, todasAsPaginas, totalPaginas) {
  const parte = metadata?.parte ?? null;
  const caderno = metadata?.caderno ?? null;
  if (parte && caderno) {
    return { bloqueio: "metadata.parte e metadata.caderno declarados juntos — declare o recorte de páginas em um só lugar (parte da prova OU caderno canônico)" };
  }
  const declaracao = parte ?? caderno;
  if (!declaracao) return { paginas: todasAsPaginas, intervalo: null, declaracao: null, origem: null };
  const origem = parte ? "metadata.parte" : "metadata.caderno";
  if (!intervaloValido(declaracao.paginas, totalPaginas)) {
    return { bloqueio: `${origem}.paginas inválido (${JSON.stringify(declaracao.paginas)}): use [início, fim] dentro de 1..${totalPaginas}` };
  }
  if (declaracao.total_questoes !== undefined && !(Number.isInteger(declaracao.total_questoes) && declaracao.total_questoes > 0)) {
    return { bloqueio: `${origem}.total_questoes inválido (${JSON.stringify(declaracao.total_questoes)})` };
  }
  if (declaracao.cabecalho !== undefined && !(typeof declaracao.cabecalho === "string" && normalizar(declaracao.cabecalho).length >= 4)) {
    return { bloqueio: `${origem}.cabecalho inválido (${JSON.stringify(declaracao.cabecalho)})` };
  }
  const [inicio, fim] = declaracao.paginas;
  return { paginas: todasAsPaginas.filter((p) => p.numero >= inicio && p.numero <= fim), intervalo: declaracao.paginas, declaracao, origem };
}

// Conferência da declaração contra o documento inteiro, as questões extraídas
// do intervalo (pagina_origem de cada uma) e o bloco de gabarito escolhido.
export function conferirDeclaracao({ declaracao, origem, intervalo, todasAsPaginas, questoes, blocoGabarito }) {
  if (!declaracao) return null;
  const [inicio, fim] = intervalo;
  if (declaracao.cabecalho !== undefined) {
    const marca = normalizar(declaracao.cabecalho);
    const comMarca = todasAsPaginas.filter((p) => normalizar(p.texto).includes(marca)).map((p) => p.numero);
    const fora = comMarca.filter((n) => n < inicio || n > fim);
    if (fora.length > 0) return `${origem}.cabecalho "${declaracao.cabecalho}" aparece fora do intervalo ${inicio}–${fim} (p. ${fora.join(", ")}) — o intervalo não cobre o caderno inteiro`;
    const semMarca = [...new Set(questoes.map((q) => q.pagina_origem).filter((n) => Number.isInteger(n) && !comMarca.includes(n)))];
    if (semMarca.length > 0) return `${origem}.cabecalho "${declaracao.cabecalho}" ausente em página(s) com questão (p. ${semMarca.join(", ")}) — o intervalo inclui páginas de outro caderno`;
    // Página do intervalo sem o carimbo (capa, rascunho... ou o começo do
    // caderno vizinho, cuja sequência curta o extrator ignora) pode existir,
    // mas o texto dela nunca pode entrar numa questão: senão a capa e as
    // primeiras questões do vizinho grudam na última alternativa.
    const textoQuestoes = questoes.map((q) => `${q.enunciado}\n${(q.alternativas ?? []).map((a) => a.texto).join("\n")}`).join("\n");
    const vazadas = todasAsPaginas
      .filter((p) => p.numero >= inicio && p.numero <= fim && !comMarca.includes(p.numero))
      .filter((p) => (p.texto ?? "").split("\n").map((l) => l.trim()).some((l) => l.length >= TAMANHO_MINIMO_LINHA_VAZADA && textoQuestoes.includes(l)))
      .map((p) => p.numero);
    if (vazadas.length > 0) return `${origem}.cabecalho "${declaracao.cabecalho}": texto de página sem o carimbo (p. ${vazadas.join(", ")}) entrou numa questão — o intervalo mistura conteúdo de fora do caderno`;
  }
  if (declaracao.total_questoes !== undefined && questoes.length !== declaracao.total_questoes) {
    return `${origem}.total_questoes = ${declaracao.total_questoes}, mas foram extraídas ${questoes.length} questão(ões) no intervalo ${inicio}–${fim}`;
  }
  if (declaracao.gabarito_bloco !== undefined && declaracao.gabarito_bloco !== blocoGabarito) {
    return `${origem}.gabarito_bloco = "${declaracao.gabarito_bloco}", mas o gabarito usa o bloco "${blocoGabarito}" — gabarito de outra parte/caderno`;
  }
  return null;
}
