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
};

export function ehString(valor: unknown): valor is string {
  return typeof valor === "string" && valor.trim().length > 0;
}
