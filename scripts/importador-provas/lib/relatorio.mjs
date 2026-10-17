// Agrega as métricas finais do dry-run — só leitura/contagem sobre o que
// já foi calculado nas etapas anteriores, nenhuma lógica nova de negócio.

export function gerarRelatorio(questoesComScore, contextoDocumento) {
  const total = questoesComScore.length;
  // O objeto normalizado nunca carrega um campo "gabarito" de nível
  // superior (normalizar.mjs só expõe o status via _interno) — usar
  // q.gabarito aqui seria sempre `undefined !== null` (sempre true) e
  // contaria toda questão como "com gabarito", mesmo quando não há.
  const comGabarito = questoesComScore.filter((q) => q._interno.gabarito_status !== "ausente").length;
  const semGabarito = total - comGabarito;
  const novas = questoesComScore.filter((q) => q.dedup.status === "nova").length;
  const duplicadas = questoesComScore.filter((q) => q.dedup.status === "duplicada").length;
  const provavelDuplicadas = questoesComScore.filter((q) => q.dedup.status === "provavel_duplicada").length;
  const prontasParaRevisao = questoesComScore.filter((q) => q.status === "PRONTA_PARA_REVISAO").length;
  const revisaoManual = total - prontasParaRevisao;
  const classificadasAutomaticamente = questoesComScore.filter((q) => q.confidence === "alta").length;

  return {
    gerado_em: new Date().toISOString(),
    documento: contextoDocumento,
    total_detectado: total,
    total_com_gabarito: comGabarito,
    total_sem_gabarito: semGabarito,
    total_novas: novas,
    total_duplicadas: duplicadas,
    total_provavel_duplicadas: provavelDuplicadas,
    total_revisao_manual: revisaoManual,
    total_classificadas_automaticamente: classificadasAutomaticamente,
    taxa_confianca: total > 0 ? Number((prontasParaRevisao / total).toFixed(4)) : 0,
  };
}
