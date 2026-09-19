// Expiração de gerações 'processando' travadas (Fase 4 — auditoria final
// pré-deploy). Extraído de gerar-aula/index.ts para ser testável (node
// --test), mesmo princípio dual-runtime de sanitizarErro.mjs/escopo.mjs.
//
// Só pode expirar uma geração ÓRFÃ/LEGADA: 'processando' há mais de
// minutosExpiracao E SEM openai_response_id (nunca chegou a submeter nada
// em background — ex.: travou entre o INSERT do lock e a submissão, ou é
// resquício do fluxo síncrono antigo, anterior à Fase 3A). Uma geração com
// openai_response_id PREENCHIDO pode legitimamente continuar
// 'queued'/'in_progress' do lado da OpenAI por vários minutos — só o
// finalizador (consultando o provider de verdade via GET /v1/responses/
// {id}) tem autoridade para decidir o destino dela. Sem o filtro
// openai_response_id IS NULL, esta rotina marcaria 'erro' uma geração
// async genuinamente em andamento assim que outro admin tentasse gerar de
// novo para a mesma unidade depois de 10 minutos — um falso positivo que o
// fluxo síncrono antigo não tinha como produzir (antes 'processando' nunca
// durava mais que a própria chamada HTTP síncrona).
//
// O limite de minutos em si é inalterado — só o filtro adicional muda.

/**
 * @param {{
 *   admin: import("https://esm.sh/@supabase/supabase-js@2").SupabaseClient,
 *   conteudoId: number,
 *   unidadePedagogicaId: string,
 *   minutosExpiracao: number,
 * }} params
 */
export async function expirarGeracoesOrfas({ admin, conteudoId, unidadePedagogicaId, minutosExpiracao }) {
  const limite = new Date(Date.now() - minutosExpiracao * 60_000).toISOString();
  await admin
    .from("aula_geracoes")
    .update({
      status: "erro",
      erro: `Geração expirada (travada há mais de ${minutosExpiracao} minutos)`,
      finalizado_em: new Date().toISOString(),
    })
    .eq("conteudo_id", conteudoId)
    .eq("unidade_pedagogica_id", unidadePedagogicaId)
    .eq("status", "processando")
    .is("openai_response_id", null)
    .lt("iniciado_em", limite);
}
