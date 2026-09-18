// Transformação PURA (sem JSX/React) de aula_versoes.estrutura — a MESMA
// fonte canônica lida por ComponenteAulaView.tsx — para um modelo já
// normalizado e pronto para a versão impressa/PDF da aula (AulaImpressao.tsx).
//
// Princípio: o PDF não é uma segunda aula. Nenhum texto é inventado ou
// reescrito aqui — cada campo do modelo de saída é lido diretamente do
// mesmo componente que a tela interativa já lê (mesmos nomes de campo do
// contrato em supabase/functions/gerar-aula/validador.mjs). A única coisa
// que muda é a FORMA como o dado é organizado para uma
// apresentação estática (sem "revelar", sem interação, sem botões): a
// resposta/gabarito sempre aparece junto da pergunta, nunca atrás de um
// clique que não existe em papel.
//
// Genérico de propósito: nenhuma linha aqui sabe o nome de nenhuma
// aula/unidade/conteúdo/curso específico — funciona para qualquer aula que
// respeite o contrato de componentes (ver supabase/functions/gerar-aula/
// validador.mjs).

// Este arquivo é testado com node --test puro (tests/prepararAulaImpressao.test.mjs)
// — o ESM nativo do Node exige extensão explícita em specifiers relativos
// (".ts"), mas TypeScript com moduleResolution "bundler" (tsconfig.json
// deste projeto) rejeita import com extensão ".ts" sem
// allowImportingTsExtensions (não habilitado aqui). Como as duas regras são
// incompatíveis para um import relativo entre dois arquivos .ts, este
// módulo fica deliberadamente AUTOCONTIDO (sem nenhum import relativo) em
// vez de importar de ./tiposComponenteAula.ts — só repete a checagem
// ehString (1 linha, type guard) e usa o tipo bruto como rótulo do bloco
// "desconhecido" em vez de reaproveitar ROTULOS_TIPO_COMPONENTE.
type ComponenteAula = { tipo: string; [chave: string]: unknown };

function ehString(valor: unknown): valor is string {
  return typeof valor === "string" && valor.trim().length > 0;
}

export type AlternativaImpressao = { letra: string; texto: string; correta: boolean };

export type FalaImpressao = { emissor: string; texto: string };
export type QuadroImpressao = { numero: number; cena: string | null; falas: FalaImpressao[]; legenda: string | null };

export type ComponenteImpressao =
  | { tipo: "diagnostico"; titulo: string | null; introducao: string | null; pergunta: string | null; respostaEsperada: string | null }
  | { tipo: "conceito"; titulo: string | null; explicacao: string | null; exemplo: string | null; pontoDeProva: string | null; pegadinha: string | null }
  | {
      tipo: "jurisprudencia_essencial";
      titulo: string | null;
      tribunal: string | null;
      identificacaoPrecedente: string | null;
      dispositivoRelacionado: string | null;
      entendimento: string | null;
      comoCaiNaProva: string | null;
      fonte: string | null;
    }
  | { tipo: "recall"; titulo: string | null; pergunta: string | null; dica: string | null; resposta: string | null }
  | { tipo: "questao_resolvida"; enunciado: string | null; alternativas: AlternativaImpressao[]; gabarito: string | null; raciocinio: string | null; pegadinha: string | null }
  | { tipo: "resumo_visual"; titulo: string | null; pontos: string[] }
  | { tipo: "quadrinho_didatico"; titulo: string | null; quadros: QuadroImpressao[]; fechamento: string | null }
  | { tipo: "desconhecido"; tipoOriginal: string; rotulo: string; campos: { chave: string; valor: string }[] };

export type FonteImpressao = {
  titulo: string;
  tituloVersao: string | null;
  tipo: string | null;
};

export type AulaImpressaoModelo = {
  materiaNome: string | null;
  conteudoNome: string | null;
  unidadeTitulo: string;
  aulaTitulo: string;
  cursoNome: string | null;
  numeroVersao: number;
  publicadoEm: string | null;
  componentes: ComponenteImpressao[];
  fontes: FonteImpressao[];
};

function valorOuNull(valor: unknown): string | null {
  return ehString(valor) ? valor : null;
}

function normalizarAlternativas(bruto: unknown, gabaritoBruto: unknown): AlternativaImpressao[] {
  const alternativasBrutas = Array.isArray(bruto) ? bruto : [];
  const gabarito = ehString(gabaritoBruto) ? gabaritoBruto.trim().toUpperCase() : "";
  const alternativas: AlternativaImpressao[] = [];
  for (const item of alternativasBrutas) {
    if (typeof item !== "object" || item === null) continue;
    const { letra, texto } = item as Record<string, unknown>;
    if (!ehString(letra) || !ehString(texto)) continue;
    const letraNormalizada = letra.trim().toUpperCase();
    alternativas.push({ letra: letraNormalizada, texto, correta: letraNormalizada === gabarito });
  }
  return alternativas;
}

// Mesma regra defensiva de normalizarQuadrinho (tiposComponenteAula.ts),
// repetida aqui de propósito: este módulo é autocontido (ver nota no topo).
function normalizarQuadros(bruto: unknown): QuadroImpressao[] {
  const quadros: QuadroImpressao[] = [];
  for (const item of Array.isArray(bruto) ? bruto : []) {
    if (typeof item !== "object" || item === null || Array.isArray(item)) continue;
    const q = item as Record<string, unknown>;
    const falas: FalaImpressao[] = [];
    for (const fala of Array.isArray(q.falas) ? q.falas : []) {
      if (typeof fala !== "object" || fala === null) continue;
      const { emissor, texto } = fala as Record<string, unknown>;
      if (ehString(emissor) && ehString(texto)) falas.push({ emissor, texto });
    }
    const cena = valorOuNull(q.cena);
    if (!cena && falas.length === 0) continue;
    quadros.push({ numero: quadros.length + 1, cena, falas, legenda: valorOuNull(q.legenda) });
  }
  return quadros;
}

function normalizarComponenteDesconhecido(componente: ComponenteAula): ComponenteImpressao {
  const { tipo, ...outros } = componente;
  const campos = Object.entries(outros)
    .filter(([, valor]) => valor !== null && valor !== undefined && valor !== "")
    .map(([chave, valor]) => ({
      chave,
      valor: typeof valor === "string" ? valor : JSON.stringify(valor),
    }));
  return {
    tipo: "desconhecido",
    tipoOriginal: String(tipo),
    rotulo: String(tipo),
    campos,
  };
}

// Nunca deixa um componente "desaparecer" por tipo não reconhecido — cai no
// bloco "desconhecido" (mostrado de forma genérica), nunca é omitido.
export function normalizarComponenteImpressao(componente: ComponenteAula): ComponenteImpressao {
  switch (componente.tipo) {
    case "diagnostico":
      return {
        tipo: "diagnostico",
        titulo: valorOuNull(componente.titulo),
        introducao: valorOuNull(componente.introducao),
        pergunta: valorOuNull(componente.pergunta),
        respostaEsperada: valorOuNull(componente.resposta_esperada),
      };
    case "conceito":
      return {
        tipo: "conceito",
        titulo: valorOuNull(componente.titulo),
        explicacao: valorOuNull(componente.explicacao),
        exemplo: valorOuNull(componente.exemplo),
        pontoDeProva: valorOuNull(componente.ponto_de_prova),
        pegadinha: valorOuNull(componente.pegadinha),
      };
    case "jurisprudencia_essencial":
      return {
        tipo: "jurisprudencia_essencial",
        titulo: valorOuNull(componente.titulo),
        tribunal: valorOuNull(componente.tribunal),
        identificacaoPrecedente: valorOuNull(componente.identificacao_precedente),
        dispositivoRelacionado: valorOuNull(componente.dispositivo_relacionado),
        entendimento: valorOuNull(componente.entendimento),
        comoCaiNaProva: valorOuNull(componente.como_cai_na_prova),
        fonte: valorOuNull(componente.fonte),
      };
    case "recall":
      return {
        tipo: "recall",
        titulo: valorOuNull(componente.titulo),
        pergunta: valorOuNull(componente.pergunta),
        dica: valorOuNull(componente.dica),
        resposta: valorOuNull(componente.resposta),
      };
    case "questao_resolvida":
      return {
        tipo: "questao_resolvida",
        enunciado: valorOuNull(componente.enunciado),
        alternativas: normalizarAlternativas(componente.alternativas, componente.gabarito),
        gabarito: valorOuNull(componente.gabarito),
        raciocinio: valorOuNull(componente.raciocinio),
        pegadinha: valorOuNull(componente.pegadinha),
      };
    case "resumo_visual":
      return {
        tipo: "resumo_visual",
        titulo: valorOuNull(componente.titulo),
        pontos: Array.isArray(componente.pontos) ? componente.pontos.filter(ehString) : [],
      };
    case "quadrinho_didatico":
      return {
        tipo: "quadrinho_didatico",
        titulo: valorOuNull(componente.titulo),
        quadros: normalizarQuadros(componente.quadros),
        fechamento: valorOuNull(componente.fechamento),
      };
    default:
      return normalizarComponenteDesconhecido(componente);
  }
}

function normalizarFonte(bruto: unknown): FonteImpressao | null {
  if (typeof bruto !== "object" || bruto === null) return null;
  const item = bruto as Record<string, unknown>;
  if (!ehString(item.material_titulo)) return null;
  return {
    titulo: item.material_titulo,
    tituloVersao: valorOuNull(item.titulo_versao),
    tipo: valorOuNull(item.material_tipo),
  };
}

/**
 * Entrada: exatamente o formato devolvido por
 * public.carregar_unidades_publicadas_da_missao / public.carregar_aula_rascunho_admin
 * para UMA unidade (aula_titulo, unidade_titulo, numero_versao, publicado_em,
 * estrutura, fontes) — nunca um formato inventado.
 */
export function prepararAulaImpressao(dados: {
  materiaNome?: string | null;
  conteudoNome?: string | null;
  unidadeTitulo: string;
  aulaTitulo: string;
  cursoNome?: string | null;
  numeroVersao: number;
  publicadoEm: string | null;
  estrutura: { componentes?: unknown };
  fontes?: unknown;
}): AulaImpressaoModelo {
  const componentesBrutos = Array.isArray(dados.estrutura?.componentes) ? dados.estrutura.componentes : [];
  const componentes = componentesBrutos
    .filter((item): item is ComponenteAula => typeof item === "object" && item !== null && ehString((item as ComponenteAula).tipo))
    .map(normalizarComponenteImpressao);

  const fontesBrutas = Array.isArray(dados.fontes) ? dados.fontes : [];
  const fontes = fontesBrutas.map(normalizarFonte).filter((f): f is FonteImpressao => f !== null);

  return {
    materiaNome: dados.materiaNome ?? null,
    conteudoNome: dados.conteudoNome ?? null,
    unidadeTitulo: dados.unidadeTitulo,
    aulaTitulo: dados.aulaTitulo,
    cursoNome: dados.cursoNome ?? null,
    numeroVersao: dados.numeroVersao,
    publicadoEm: dados.publicadoEm,
    componentes,
    fontes,
  };
}
