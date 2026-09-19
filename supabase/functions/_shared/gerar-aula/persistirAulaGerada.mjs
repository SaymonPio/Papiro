// Persistência canônica de uma geração de aula validada com sucesso
// (Fase 3A) — extraído de gerar-aula/index.ts (etapas 12-16 do fluxo
// original) para ser chamado exclusivamente pelo finalizador
// (finalizar-geracao-aula), nunca duplicado entre os dois mundos
// síncrono/assíncrono. Lógica de persistência IDÊNTICA à versão síncrona
// anterior — nenhuma regra de negócio mudou, só o ponto de chamada.
//
// Sem I/O próprio de rede — recebe o client `admin` (service_role) já
// pronto, como o resto do projeto já faz.

/**
 * @param {{
 *   admin: import("https://esm.sh/@supabase/supabase-js@2").SupabaseClient,
 *   geracaoId: string,
 *   conteudoId: number,
 *   unidadePedagogicaId: string,
 *   unidadeTitulo: string,
 *   materiaisSelecionados: Array<{ id: string }>,
 *   componentes: Array<Record<string, unknown>>,
 *   artigosAbordados: string[],
 *   artigosEsperados: string[] | null,
 *   contextoSnapshot: Record<string, unknown>,
 *   tokensEntrada: number | null,
 *   tokensSaida: number | null,
 *   auditarEscopoArtigos: (artigosAbordados: string[], artigosEsperados: string[] | null) => unknown,
 * }} params
 * @returns {Promise<{ ok: true, aulaId: string, aulaVersaoId: string, numeroVersao: number } | { ok: false, erro: string }>}
 */
export async function persistirAulaGerada({
  admin,
  geracaoId,
  conteudoId,
  unidadePedagogicaId,
  unidadeTitulo,
  materiaisSelecionados,
  componentes,
  artigosAbordados,
  artigosEsperados,
  contextoSnapshot,
  tokensEntrada,
  tokensSaida,
  auditarEscopoArtigos,
}) {
  // UUIDs gerados AQUI, no servidor, DEPOIS da validação — a IA nunca
  // decide um id (o validador já rejeitou qualquer "id" vindo da IA).
  const componentesComId = componentes.map((c) => ({ id: crypto.randomUUID(), ...c }));

  // Auditoria NÃO BLOQUEANTE de escopo — só um sinal para revisão humana.
  const validacaoEscopo = auditarEscopoArtigos(artigosAbordados, artigosEsperados);

  // Uma aula lógica por unidade: regenerações criam novas versões da
  // mesma aula; outra unidade do conteúdo recebe outra aula lógica.
  let aulaId;
  const { data: aulaExistente } = await admin.from("aulas").select("id").eq("unidade_pedagogica_id", unidadePedagogicaId).maybeSingle();
  if (aulaExistente) {
    aulaId = aulaExistente.id;
  } else {
    const { data: aulaCriada, error: erroAula } = await admin
      .from("aulas")
      .insert({ conteudo_id: conteudoId, unidade_pedagogica_id: unidadePedagogicaId, titulo: unidadeTitulo })
      .select("id")
      .single();
    if (erroAula || !aulaCriada) return { ok: false, erro: "Não foi possível criar a aula." };
    aulaId = aulaCriada.id;
  }

  const { data: ultimaVersao } = await admin
    .from("aula_versoes")
    .select("numero_versao")
    .eq("aula_id", aulaId)
    .order("numero_versao", { ascending: false })
    .limit(1)
    .maybeSingle();
  const proximoNumero = (ultimaVersao?.numero_versao ?? 0) + 1;

  // SEMPRE 'rascunho'. Nunca publica automaticamente. Toda geração
  // (inclusive regeneração intencional) cria uma versão NOVA — nunca
  // sobrescreve numero_versao existente.
  const { data: novaVersao, error: erroVersao } = await admin
    .from("aula_versoes")
    .insert({
      aula_id: aulaId,
      numero_versao: proximoNumero,
      status: "rascunho",
      estrutura: { schema_version: 1, artigos_abordados: artigosAbordados, componentes: componentesComId },
    })
    .select("id")
    .single();
  if (erroVersao || !novaVersao) return { ok: false, erro: "Não foi possível criar a versão da aula." };
  const aulaVersaoId = novaVersao.id;

  // Só os material_versoes REALMENTE usados nesta geração — nenhum
  // vínculo além disso. Erro aqui aborta a geração — nunca marcamos
  // 'concluida' com um vínculo de fontes incompleto/ausente.
  if (materiaisSelecionados.length > 0) {
    const { error: erroFontes } = await admin.from("aula_versao_fontes").insert(
      materiaisSelecionados.map((m, indice) => ({ aula_versao_id: aulaVersaoId, material_versao_id: m.id, ordem: indice + 1 })),
    );
    if (erroFontes) return { ok: false, erro: "A aula foi criada, mas não foi possível vincular as fontes usadas na geração." };
  }

  const { error: erroConclusao } = await admin
    .from("aula_geracoes")
    .update({
      status: "concluida",
      finalizado_em: new Date().toISOString(),
      aula_versao_id: aulaVersaoId,
      tokens_entrada: tokensEntrada,
      tokens_saida: tokensSaida,
      contexto: { ...contextoSnapshot, validacao_escopo: validacaoEscopo },
      // Fase 4.1: uma geração concluída nunca deve continuar com uma
      // lease de finalização "ativa" — limpa por higiene, mesmo que
      // nenhuma execução futura volte a reivindicar uma linha que já não
      // está mais 'processando' (a condição de reivindicação já exige
      // status='processando', então isto nunca é estritamente necessário
      // para correção, só para nunca deixar um valor de lease "morto" e
      // enganoso numa linha terminal).
      finalizacao_lease_ate: null,
    })
    .eq("id", geracaoId);
  if (erroConclusao) {
    // A aula/versão/fontes já existem neste ponto, mas a auditoria da
    // geração não pôde ser fechada como 'concluida'. Quem chama decide
    // como tratar isso (o finalizador marca 'erro' com uma mensagem
    // específica, nunca retorna sucesso sem essa confirmação).
    return { ok: false, erro: "A aula foi gerada, mas não foi possível concluir o registro da geração. Verifique manualmente antes de reutilizar este conteúdo." };
  }

  return { ok: true, aulaId, aulaVersaoId, numeroVersao: proximoNumero };
}
