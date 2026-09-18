// Tipos e helpers PUROS (sem JSX) compartilhados entre ComponenteAulaView.tsx
// (renderer interativo) e prepararAulaImpressao.ts (transformação para
// PDF/impressão). Extraído para um arquivo .ts sem JSX de propósito: Node
// (node --test) só consegue importar módulos com sintaxe TypeScript pura —
// um arquivo com JSX (como ComponenteAulaView.tsx) nunca pode ser importado,
// nem indiretamente, por um teste rodado com node --test puro. Mantém as
// duas telas (e agora o PDF) sempre lendo a MESMA definição, nunca duas
// cópias divergentes.

// estrutura.componentes não tem nenhuma garantia de formato a nível de
// banco (só estrutura em si é validada como objeto JSON) — por isso
// ComponenteAula não presume mais nada além de `tipo`.
export type ComponenteAula = {
  tipo: string;
  [chave: string]: unknown;
};

// Os 5 tipos documentados em teoria_versionada.sql têm rótulo definido, mais
// o tipo nativo OPCIONAL "jurisprudencia_essencial" (só existe quando a
// própria aula o incluir — nunca obrigatório, ver validador.mjs); qualquer
// outro valor de `tipo` é exibido cru, sem inventar um nome.
export const ROTULOS_TIPO_COMPONENTE: Record<string, string> = {
  diagnostico: "Diagnóstico",
  conceito: "Conceito",
  recall: "Recall",
  questao_resolvida: "Questão resolvida",
  resumo_visual: "Resumo visual",
  jurisprudencia_essencial: "Jurisprudência essencial",
  quadrinho_didatico: "Exemplo visual",
};

export function ehString(valor: unknown): valor is string {
  return typeof valor === "string" && valor.trim().length > 0;
}

// quadrinho_didatico (v1, sem imagem): o roteiro é exibido como cards. Esta
// normalização é DEFENSIVA e pura (sem JSX, testável com node --test) —
// nunca lança e nunca duplica o validador do backend: só descarta o que não
// dá para exibir (quadro que não é objeto, quadro sem cena e sem falas,
// fala sem emissor/texto), para que um dado histórico/manual estranho não
// quebre a página.
export type FalaQuadrinho = { emissor: string; texto: string };
export type QuadroQuadrinho = { numero: number; cena: string | null; falas: FalaQuadrinho[]; legenda: string | null };
export type QuadrinhoNormalizado = { titulo: string | null; quadros: QuadroQuadrinho[]; fechamento: string | null };

export function normalizarQuadrinho(componente: ComponenteAula): QuadrinhoNormalizado {
  const quadrosBrutos = Array.isArray(componente.quadros) ? componente.quadros : [];
  const quadros: QuadroQuadrinho[] = [];
  for (const bruto of quadrosBrutos) {
    if (typeof bruto !== "object" || bruto === null || Array.isArray(bruto)) continue;
    const item = bruto as Record<string, unknown>;
    const falas: FalaQuadrinho[] = [];
    for (const fala of Array.isArray(item.falas) ? item.falas : []) {
      if (typeof fala !== "object" || fala === null) continue;
      const { emissor, texto } = fala as Record<string, unknown>;
      if (ehString(emissor) && ehString(texto)) falas.push({ emissor, texto });
    }
    const cena = ehString(item.cena) ? item.cena : null;
    if (!cena && falas.length === 0) continue;
    quadros.push({ numero: quadros.length + 1, cena, falas, legenda: ehString(item.legenda) ? item.legenda : null });
  }
  return {
    titulo: ehString(componente.titulo) ? componente.titulo : null,
    quadros,
    fechamento: ehString(componente.fechamento) ? componente.fechamento : null,
  };
}
