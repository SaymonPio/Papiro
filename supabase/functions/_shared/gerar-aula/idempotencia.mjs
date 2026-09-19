// Reivindicação por LEASE recuperável de uma geração, antes de processá-la
// no finalizador (Fase 4.1 — substitui o claim baseado em `finalizado_em`
// da Fase 4).
//
// Problema real do design anterior: reaproveitar `finalizado_em` como
// marcador de "reivindicado agora" resolve concorrência entre workers
// simultâneos, mas cria uma trava permanente se o worker que reivindicou
// morrer (crash, timeout do runtime) ANTES de concluir — a linha fica com
// status='processando' E finalizado_em preenchido para sempre, e nenhuma
// condição de reivindicação futura reconhece esse estado como "pode
// tentar de novo" (a condição exigia justamente finalizado_em IS NULL).
//
// Solução: uma coluna dedicada com expiração por TEMPO —
// `finalizacao_lease_ate` (timestamptz nullable, migration
// supabase/async_finalizacao_lease.sql). Uma reivindicação é válida por
// LEASE_FINALIZACAO_MINUTOS; se o worker morrer no meio do caminho, a
// lease simplesmente expira sozinha e a PRÓXIMA execução do finalizador
// pode reivindicar de novo — nenhuma limpeza manual, nenhum estado preso
// permanentemente. `finalizado_em` volta a significar EXCLUSIVAMENTE
// "terminou de forma terminal" (status='concluida' ou 'erro') — nunca
// mais um mutex.
//
// A reivindicação é o PRIMEIRO passo do processamento de cada geração no
// finalizador (antes até de consultar a OpenAI) — protege a execução
// INTEIRA daquela linha nesta tentativa, não só o instante da persistência
// final. Isso é o que torna a recuperação de crash real: não importa em
// qual etapa o worker morre, a lease (se ainda válida) impede um segundo
// worker de processar a mesma linha ao mesmo tempo, e expira sozinha se
// ninguém a liberar explicitamente.
//
// UM ÚNICO UPDATE condicional funciona como checagem e reivindicação ao
// mesmo tempo — nunca um SELECT seguido de decisão separada (TOCTOU). O
// Postgres serializa UPDATEs concorrentes na MESMA linha (lock de linha):
// de duas execuções que tentem reivindicar ao mesmo tempo, só uma
// efetivamente casa o WHERE e recebe a linha de volta.
//
// Por que a lease continua necessária mesmo com pg_cron (Fase 4.1 —
// correção de uma afirmação imprecisa da Fase 4): o pg_cron, por padrão,
// mantém no máximo UMA instância SQL em execução por job — uma nova
// execução agendada fica enfileirada até a anterior terminar, ele NÃO
// dispara duas instâncias SQL do mesmo job ao mesmo tempo. O motivo real
// da concorrência não é o pg_cron rodar o job em paralelo consigo mesmo:
// é que `pg_net` é ASSÍNCRONO — o job SQL só ENFILEIRA a chamada
// net.http_post e termina rapidamente, sem esperar a Edge Function
// responder. Isso significa que, no próximo tick (1 minuto depois), o job
// SQL já pode rodar de novo e enfileirar uma SEGUNDA chamada HTTP
// enquanto a PRIMEIRA invocação de finalizar-geracao-aula ainda está em
// execução do lado do runtime das Edge Functions — são duas execuções da
// function, não duas execuções do job SQL. A lease protege exatamente
// essa janela.

export const LEASE_FINALIZACAO_MINUTOS = 5;

/**
 * Tenta reivindicar, por lease, uma geração para processamento exclusivo
 * nesta execução do finalizador.
 *
 * @param {{
 *   admin: import("https://esm.sh/@supabase/supabase-js@2").SupabaseClient,
 *   geracaoId: string,
 *   minutosLease?: number,
 *   agora?: Date,
 * }} params
 * @returns {Promise<boolean>} true se ESTA chamada reivindicou a geração
 *   (nenhum outro worker tem uma lease ativa agora); false se outro
 *   worker já tem uma lease ativa — nesse caso o chamador NUNCA deve
 *   prosseguir, apenas ignorar esta geração e seguir para a próxima.
 */
export async function reivindicarGeracaoParaFinalizar({ admin, geracaoId, minutosLease = LEASE_FINALIZACAO_MINUTOS, agora = new Date() }) {
  const agoraIso = agora.toISOString();
  const leaseAteIso = new Date(agora.getTime() + minutosLease * 60_000).toISOString();

  const { data, error } = await admin
    .from("aula_geracoes")
    .update({ finalizacao_lease_ate: leaseAteIso })
    .eq("id", geracaoId)
    .eq("status", "processando")
    .is("aula_versao_id", null)
    .or(`finalizacao_lease_ate.is.null,finalizacao_lease_ate.lt.${agoraIso}`)
    .select("id")
    .maybeSingle();

  if (error || !data) return false;
  return true;
}

/**
 * Libera a lease (finalizacao_lease_ate = NULL) sem tocar em nenhuma
 * outra coluna — usado quando o processamento desta execução termina sem
 * um resultado terminal (queued/in_progress do provider, status
 * desconhecido, ou depois de submeter uma correção em background) e a
 * geração deve continuar elegível para o PRÓXIMO ciclo do cron, sem
 * precisar esperar a lease expirar sozinha.
 *
 * Nunca lança — uma falha ao liberar explicitamente não é crítica (a
 * lease expira sozinha em até LEASE_FINALIZACAO_MINUTOS de qualquer
 * forma), então isso nunca deve interromper o restante do processamento.
 *
 * @param {{
 *   admin: import("https://esm.sh/@supabase/supabase-js@2").SupabaseClient,
 *   geracaoId: string,
 * }} params
 */
export async function liberarLeaseFinalizacao({ admin, geracaoId }) {
  try {
    await admin.from("aula_geracoes").update({ finalizacao_lease_ate: null }).eq("id", geracaoId);
  } catch {
    // Best-effort — a lease expira sozinha de qualquer forma.
  }
}
