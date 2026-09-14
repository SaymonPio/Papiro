// Funções puras do painel "BANCO DA UNIDADE" (app/admin/aulas/page.tsx) —
// extraídas para um módulo próprio sem JSX/React para poder ser testadas
// com node --test puro (o projeto não tem infraestrutura de teste de React
// hoje, e este arquivo não é motivo para adicionar uma), mesmo princípio já
// usado em supabase/functions/gerar-aula/escopo.mjs e validador.mjs.

// Não existe nenhuma coluna em questoes (nem no retorno de
// inspecionar_candidatas_papiro_admin) marcando explicitamente REAL/AUTORAL
// — confirmado por inspeção do schema (banca, fonte, gerada_por_ia,
// usuario_id: nenhum distingue de forma confiável) e pelo próprio
// comentário já registrado em app/questoes/page.tsx, onde este EXATO
// critério já é usado em produção para a mesma distinção: banca ausente,
// ou começando com "papiro", é questão autoral Papiro; qualquer outra
// banca preenchida é uma questão real de banca. Reutilizado aqui verbatim,
// não reinventado.
export function classificarOrigemQuestao(banca: string | null | undefined): "REAL" | "AUTORAL" {
  const bancaLimpa = banca?.trim();
  return !bancaLimpa || bancaLimpa.toLowerCase().startsWith("papiro") ? "AUTORAL" : "REAL";
}

export function inicioEnunciado(enunciado: string, limite = 110): string {
  const limpo = enunciado.trim();
  return limpo.length > limite ? `${limpo.slice(0, limite).trimEnd()}…` : limpo;
}
