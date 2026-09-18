// Função pura do painel "Gerar aula" (app/admin/aulas/page.tsx) — extraída
// para um módulo próprio sem JSX/React para poder ser testada com node
// --test puro, mesmo princípio já usado em banco-unidade.ts (e em
// supabase/functions/_shared/gerar-aula/*.mjs, do lado do backend).
//
// Corrige o bloqueio circular do botão "Gerar aula": a UI tratava QUALQUER
// aula_geracoes.status='processando' como bloqueante, inclusive um
// registro legado/órfão do fluxo síncrono antigo (openai_response_id
// nunca chegou a ser persistido, e o backend só consegue expirar essa
// linha — supabase/functions/_shared/gerar-aula/expiracao.mjs — na
// PRÓXIMA tentativa de geração, que a UI nunca deixava acontecer).
//
// A RPC public.listar_geracoes_conteudo_admin (supabase/teoria_geracoes_
// admin_tem_response_id.sql, LIVE) agora expõe `tem_response_id boolean`,
// calculado no banco como (openai_response_id IS NOT NULL) — o
// identificador bruto da OpenAI nunca chega ao cliente.

export type GeracaoParaGuard = {
  status: string;
  iniciado_em: string;
  tem_response_id: boolean;
};

// Mesmo limite usado no backend (MINUTOS_GERACAO_EXPIRADA em
// supabase/functions/gerar-aula/index.ts, via expirarGeracoesOrfas) para
// considerar uma geração 'processando' sem response_id como órfã.
// Replicado aqui só para a UI decidir quando parar de tratar essa linha
// como bloqueante — quem de fato marca a linha como 'erro' continua
// sendo exclusivamente o backend, na próxima tentativa de geração; a UI
// só deixa essa tentativa acontecer em vez de bloquear o botão para
// sempre.
export const LIMITE_GERACAO_SEM_RESPONSE_MS = 10 * 60 * 1000;

/**
 * Uma geração só deve bloquear uma NOVA tentativa quando for uma geração
 * realmente ativa:
 *  - já tem response_id (entregue à OpenAI em background) → bloqueia
 *    SEMPRE, não importa a idade — geração em background pode
 *    legitimamente levar mais de 10 minutos, isso nunca significa
 *    "travada";
 *  - ainda sem response_id → só bloqueia enquanto "recente" (pode estar
 *    exatamente entre criar a linha e persistir o response_id); passado
 *    o limite, é um órfão do fluxo síncrono antigo e não deve mais travar
 *    o botão.
 * Fail-safe: iniciado_em ilegível bloqueia (nunca arrisca permitir uma
 * geração duplicada só por não conseguir calcular a idade).
 *
 * @param agora injetável para testes determinísticos (padrão: Date.now()).
 */
export function geracaoBloqueiaNovaGeracao(geracao: GeracaoParaGuard, agora: number = Date.now()): boolean {
  if (geracao.status !== "processando") return false;
  if (geracao.tem_response_id) return true;

  const iniciadoEm = new Date(geracao.iniciado_em).getTime();
  if (!Number.isFinite(iniciadoEm)) return true;

  return agora - iniciadoEm < LIMITE_GERACAO_SEM_RESPONSE_MS;
}
