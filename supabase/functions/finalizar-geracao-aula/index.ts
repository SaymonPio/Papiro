import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { validarRespostaGerador } from "../_shared/gerar-aula/validador.mjs";
import { auditarEscopoArtigos } from "../_shared/gerar-aula/escopo.mjs";
import { persistirAulaGerada } from "../_shared/gerar-aula/persistirAulaGerada.mjs";
import { reivindicarGeracaoParaFinalizar, liberarLeaseFinalizacao } from "../_shared/gerar-aula/idempotencia.mjs";
import { buscarResponse, extrairTextoSaida, submeterResponseBackground, resolverConfiguracaoModelo, classificarStatusOpenAI } from "../_shared/gerar-aula/openaiResponses.mjs";
import { sanitizarErro } from "../_shared/gerar-aula/sanitizarErro.mjs";
import { agregarTokens } from "../_shared/gerar-aula/tokens.mjs";

// Fase 3A — FINALIZADOR CANÔNICO da geração assíncrona de aulas.
//
// Function INTERNA — nunca chamada pelo aluno, nunca pelo admin, nunca
// pelo browser. Seu único chamador legítimo é um job agendado (Supabase
// Cron/Scheduled Function — ver docs/async-cron-finalizar-geracao-aula.md,
// PREPARADO mas NÃO habilitado nesta fase). Por isso a autenticação AQUI
// não usa JWT de usuário nem eh_admin() — é um segredo interno dedicado
// (ver verificarAutenticacaoInterna abaixo), nunca reaproveitando o JWT de
// admin nem o service_role no lugar errado.
//
// Responsabilidade: localizar gerações 'processando' com
// openai_response_id preenchido, consultar o estado real na OpenAI (GET
// /v1/responses/{id}) e:
//   - queued/in_progress          -> não faz nada, tenta de novo depois;
//   - failed/cancelled/incomplete -> status='erro', mensagem sanitizada;
//   - completed + válido          -> persiste aula/aula_versao/fontes,
//                                    status='concluida' (usa o MESMO
//                                    finalizador de persistência que a
//                                    versão síncrona antiga usava —
//                                    persistirAulaGerada.mjs, extraído,
//                                    nunca duplicado);
//   - completed + JSON inválido/reprovado no validador:
//       - tentativa_ia=1 -> submete UMA correção em background,
//         atualiza openai_response_id e tentativa_ia=2, mantém
//         'processando' (nunca espera essa correção terminar NESTA
//         execução — ela será conferida no próximo ciclo do cron);
//       - tentativa_ia=2 -> essa JÁ ERA a correção; se também falhar,
//         status='erro' definitivo. Nunca existe uma 3ª tentativa —
//         reforçado pelo próprio CHECK (tentativa_ia BETWEEN 1 AND 2) na
//         migration supabase/async_geracao_aula.sql.
//
// Idempotência (Fase 3A; endurecida na Fase 4; substituída por LEASE
// recuperável na Fase 4.1): antes de fazer qualquer trabalho nesta
// geração — inclusive antes de consultar a OpenAI —, o finalizador
// reivindica a linha por LEASE (ver reivindicarGeracaoParaFinalizar em
// idempotencia.mjs), nunca mais um SELECT seguido de uma decisão separada
// (TOCTOU: dois workers podem ler 'processando' ao mesmo tempo, ambos
// passarem no SELECT, e ambos tentarem persistir, criando duas
// aula_versoes para a mesma geração). A reivindicação é UM ÚNICO UPDATE
// condicional (checagem + reivindicação no mesmo passo) — duas execuções
// concorrentes serializam no lock de linha do Postgres, só uma vence.
//
// Fase 4 tentou resolver isso reaproveitando `finalizado_em` como
// marcador de "reivindicado agora" — mas isso criava um problema novo: se
// o worker que reivindicou morresse (crash/timeout) ANTES de concluir, a
// linha ficava com status='processando' E finalizado_em preenchido para
// sempre, e nenhuma execução futura sabia reconhecer isso como "pode
// tentar de novo" (a condição de reivindicação exigia justamente
// finalizado_em IS NULL). Fase 4.1 corrige isso com uma coluna dedicada
// (`finalizacao_lease_ate`, migration supabase/async_finalizacao_lease.sql)
// que expira sozinha depois de LEASE_FINALIZACAO_MINUTOS — um worker
// morto nunca mais prende uma geração permanentemente, o próximo ciclo do
// cron simplesmente reivindica de novo assim que a lease vencer.
// `finalizado_em` volta a significar EXCLUSIVAMENTE "terminou de forma
// terminal" (status='concluida' ou 'erro') — NUNCA um mutex.
//
// Quando o processamento desta execução termina SEM um resultado terminal
// (queued/in_progress do provider, status desconhecido, ou depois de só
// submeter uma correção em background), a lease é liberada explicitamente
// (liberarLeaseFinalizacao) — a geração fica elegível de novo já no
// PRÓXIMO ciclo do cron, sem precisar esperar a lease vencer sozinha.
//
// Prova automatizada: tests/finalizarIdempotencia.test.mjs (inclui o
// cenário "worker A e B disputando a mesma geração" e "lease sobrevive a
// um crash simulado e permite recuperação após expirar").

const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-finalizador-secret" };

// Máximo de gerações processadas por execução — conservador de propósito:
// cada execução do cron tem seu próprio teto de tempo (mesma classe de
// limite que já derrubou a geração síncrona), e cada geração pendente
// pode envolver 1-2 chamadas HTTP à OpenAI (GET de status, e
// eventualmente um novo POST de correção). 3 a 5 é uma margem segura
// para nunca aproximar esse teto mesmo no pior caso (5 gerações × 2
// chamadas HTTP rápidas cada, tipicamente <1s por chamada de status/
// submissão — bem diferente de esperar uma geração inteira terminar).
const MAX_GERACOES_POR_EXECUCAO = 5;

/**
 * Autenticação interna do finalizador — NUNCA um JWT de usuário/admin,
 * NUNCA o service_role usado como bearer token. Compara um header
 * dedicado contra um secret dedicado (FINALIZAR_GERACAO_SECRET),
 * configurado separadamente do OPENAI_API_KEY/SUPABASE_SERVICE_ROLE_KEY.
 * Ver Etapa 11 do mandato: o secret real NÃO é criado nesta fase — este
 * código já está pronto para quando ele existir; enquanto
 * FINALIZAR_GERACAO_SECRET não estiver configurado, a function recusa
 * QUALQUER chamada (fail-closed, nunca fail-open).
 */
function autenticacaoInternaOk(req: Request): boolean {
  const secretConfigurado = Deno.env.get("FINALIZAR_GERACAO_SECRET");
  if (!secretConfigurado) return false; // fail-closed: sem secret configurado, ninguém passa.
  const recebido = req.headers.get("x-finalizador-secret");
  if (!recebido) return false;
  // Comparação em tempo constante evita vazamento por timing-attack —
  // mesmo padrão recomendado para comparação de segredos.
  return timingSafeEqual(recebido, secretConfigurado);
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diferenca = 0;
  for (let i = 0; i < a.length; i += 1) diferenca |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diferenca === 0;
}

type GeracaoPendente = {
  id: string;
  conteudo_id: number;
  unidade_pedagogica_id: string;
  openai_response_id: string;
  tentativa_ia: number;
  contexto: Record<string, unknown>;
  tokens_entrada: number | null;
  tokens_saida: number | null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

  if (!autenticacaoInternaOk(req)) {
    return json({ error: "Não autorizado." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const openaiKey = Deno.env.get("OPENAI_API_KEY");
  if (!openaiKey) return json({ error: "Chave da OpenAI não configurada." }, 500);

  const admin = createClient(supabaseUrl, serviceKey);
  const { modelo, reasoningEffort, maxOutputTokens } = resolverConfiguracaoModelo((nome) => Deno.env.get(nome));

  // Só gerações genuinamente em voo: 'processando' E já com
  // openai_response_id (uma geração recém-travada mas ainda montando o
  // prompt/anexos, sem response_id ainda, não é responsabilidade do
  // finalizador — é o próprio iniciador que está no meio da execução).
  const { data: pendentes, error: erroPendentes } = await admin
    .from("aula_geracoes")
    .select("id, conteudo_id, unidade_pedagogica_id, openai_response_id, tentativa_ia, contexto, tokens_entrada, tokens_saida")
    .eq("status", "processando")
    .not("openai_response_id", "is", null)
    .order("iniciado_em", { ascending: true })
    .limit(MAX_GERACOES_POR_EXECUCAO);

  if (erroPendentes) {
    return json({ error: "Não foi possível listar gerações pendentes." }, 500);
  }

  const resultados: Array<{ geracaoId: string; resultado: string }> = [];

  for (const geracao of (pendentes ?? []) as GeracaoPendente[]) {
    try {
      const resultado = await processarGeracao(admin, geracao, { openaiKey, modelo, reasoningEffort, maxOutputTokens });
      resultados.push({ geracaoId: geracao.id, resultado });
    } catch (erro) {
      // Uma geração com erro inesperado no PRÓPRIO finalizador (não vindo
      // da OpenAI) nunca deve travar as demais do lote — cada uma é
      // isolada no seu próprio try/catch. A geração problemática é
      // marcada 'erro' com mensagem sanitizada; o lote continua.
      const erroSanitizado = sanitizarErro(erro, { etapa: "finalizador" });
      await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
      resultados.push({ geracaoId: geracao.id, resultado: "erro_inesperado" });
    }
  }

  return json({ ok: true, processadas: resultados.length, resultados });
});

async function processarGeracao(
  admin: ReturnType<typeof createClient>,
  geracao: GeracaoPendente,
  openaiConfig: { openaiKey: string; modelo: string; reasoningEffort: string; maxOutputTokens: number },
): Promise<string> {
  // ---- reivindicação por LEASE ANTES de qualquer trabalho (ver idempotencia.mjs) ----
  // Protege a execução INTEIRA desta geração nesta tentativa — não só o
  // instante da persistência final. Se nenhum outro worker tem uma lease
  // ativa, esta chamada vence e os próximos LEASE_FINALIZACAO_MINUTOS são
  // exclusivos desta execução; se outro worker já reivindicou, ignora e
  // segue para a próxima geração do lote.
  const reivindicada = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: geracao.id });
  if (!reivindicada) {
    return "ja_reivindicada_por_outro_worker";
  }

  const busca = await buscarResponse({ openaiKey: openaiConfig.openaiKey, responseId: geracao.openai_response_id });

  if (!busca.ok) {
    const erroSanitizado = sanitizarErro(busca.erroBruto, { etapa: "consulta_status" });
    await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_consulta";
  }

  const statusOpenAI = busca.resultado?.status;
  const categoria = classificarStatusOpenAI(statusOpenAI);

  // Ainda rodando do lado da OpenAI — não altera status/finalizado_em,
  // libera a lease (nunca deixa a geração esperando a lease vencer
  // sozinha só para ficar elegível de novo) e tenta de novo no próximo
  // ciclo do cron.
  if (categoria === "aguardando") {
    await liberarLeaseFinalizacao({ admin, geracaoId: geracao.id });
    return "ainda_processando";
  }

  // Falha/cancelamento/incompletude terminal do lado da OpenAI.
  if (categoria === "erro_terminal") {
    const motivo = busca.resultado?.error ?? busca.resultado?.incomplete_details ?? { message: `Response terminou com status "${statusOpenAI}".` };
    const erroSanitizado = sanitizarErro(motivo, { etapa: "provider_terminal" });
    await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_provider";
  }

  if (categoria === "desconhecido") {
    // Estado desconhecido/futuro da API — não bloqueia nem quebra: trata
    // como "ainda não pronto" nesta execução, nunca marca erro por um
    // status que não reconhecemos ainda. Libera a lease pelo mesmo motivo
    // do caso "aguardando" acima.
    await liberarLeaseFinalizacao({ admin, geracaoId: geracao.id });
    return `status_desconhecido:${String(statusOpenAI)}`;
  }

  // ---- categoria === "completar": extrai, valida ----
  const texto = extrairTextoSaida(busca.resultado);
  const usage = busca.resultado?.usage;
  // usage descreve SÓ esta Response (tentativa atual) — nunca um total já
  // somado com uma tentativa anterior. Agregamos aqui, uma única vez, com
  // o que já estava gravado na linha (geracao.tokens_entrada/tokens_saida,
  // vindo do mesmo SELECT que trouxe esta geração) para que tokens da
  // tentativa 1 nunca sejam perdidos quando a tentativa 2 é avaliada (ver
  // _shared/gerar-aula/tokens.mjs). Todo o resto desta função usa só os
  // valores JÁ AGREGADOS abaixo — nunca o `usage` bruto de novo.
  const tokensEntrada = agregarTokens(geracao.tokens_entrada, typeof usage?.input_tokens === "number" ? usage.input_tokens : null);
  const tokensSaida = agregarTokens(geracao.tokens_saida, typeof usage?.output_tokens === "number" ? usage.output_tokens : null);

  if (!texto) {
    await admin.from("aula_geracoes").update({ status: "erro", erro: "A IA não retornou o conteúdo esperado.", finalizado_em: new Date().toISOString(), tokens_entrada: tokensEntrada, tokens_saida: tokensSaida, finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_sem_texto";
  }

  let dados: unknown;
  try {
    dados = JSON.parse(texto);
  } catch {
    return await tratarRespostaInvalida(admin, geracao, openaiConfig, "A IA retornou um JSON inválido.", tokensEntrada, tokensSaida);
  }

  const validacao = validarRespostaGerador(dados);
  if (!validacao.ok) {
    return await tratarRespostaInvalida(admin, geracao, openaiConfig, validacao.erro, tokensEntrada, tokensSaida);
  }

  // ---- válido: a lease já foi reivindicada no topo desta função, então
  // já temos posse exclusiva — persiste direto, sem uma segunda checagem
  // separada (a checagem-e-reivindicação já aconteceu uma única vez, e
  // cobriu esta execução inteira, não só este instante). ----
  const artigosEsperados = ((geracao.contexto as any)?.artigos_esperados ?? null) as string[] | null;
  const materiaisSelecionados = (((geracao.contexto as any)?.material_versao_ids ?? []) as string[]).map((id) => ({ id }));
  const unidadeTitulo = ((geracao.contexto as any)?.unidade_pedagogica ?? "Aula") as string;

  const persistencia = await persistirAulaGerada({
    admin,
    geracaoId: geracao.id,
    conteudoId: geracao.conteudo_id,
    unidadePedagogicaId: geracao.unidade_pedagogica_id,
    unidadeTitulo,
    materiaisSelecionados,
    componentes: validacao.componentes,
    artigosAbordados: validacao.artigosAbordados,
    artigosEsperados,
    contextoSnapshot: geracao.contexto,
    tokensEntrada,
    tokensSaida,
    auditarEscopoArtigos,
  });

  if (!persistencia.ok) {
    const erroSanitizado = sanitizarErro(persistencia.erro, { etapa: "persistencia" });
    await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_persistencia";
  }

  return "concluida";
}

/**
 * Resposta completed mas reprovada (JSON inválido ou validarRespostaGerador
 * falhou). Segue a MESMA regra de "exatamente 1 correção automática" que
 * a versão síncrona anterior — só que agora a correção também é
 * background:true (nunca uma segunda chamada longa síncrona dentro do
 * finalizador).
 */
async function tratarRespostaInvalida(
  admin: ReturnType<typeof createClient>,
  geracao: GeracaoPendente,
  openaiConfig: { openaiKey: string; modelo: string; reasoningEffort: string; maxOutputTokens: number },
  motivoErro: string,
  tokensEntrada: number | null,
  tokensSaida: number | null,
): Promise<string> {
  if (geracao.tentativa_ia >= 2) {
    // Já era a tentativa de correção — não há uma 3ª. Erro definitivo.
    const erroSanitizado = sanitizarErro(`Resposta da IA reprovada na validação mesmo após uma tentativa de correção: ${motivoErro}`, { etapa: "validacao_tentativa_2" });
    await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), tokens_entrada: tokensEntrada, tokens_saida: tokensSaida, finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_apos_correcao";
  }

  // tentativa_ia === 1: monta o prompt de correção e submete em
  // background de novo. Usa previous_response_id (encadeamento nativo da
  // Responses API) em vez de reconstruir o prompt inteiro do zero — evita
  // reenviar o anexo/PDF de novo na correção.
  const promptCorrecao = `A resposta anterior foi reprovada na validação automática pelo seguinte motivo:
${motivoErro}

Corrija a resposta INTEIRA para atender exatamente ao contrato e às regras estritas do formato já fornecido antes, e responda novamente SOMENTE em JSON válido, no mesmo formato — não descreva a correção, não inclua nenhum texto fora do JSON.`;

  const submissao = await submeterResponseBackground({
    openaiKey: openaiConfig.openaiKey,
    modelo: openaiConfig.modelo,
    reasoningEffort: openaiConfig.reasoningEffort,
    maxOutputTokens: openaiConfig.maxOutputTokens,
    textoPrompt: promptCorrecao,
    anexos: [],
    previousResponseId: geracao.openai_response_id,
  });

  if (!submissao.ok) {
    const erroSanitizado = sanitizarErro(submissao.erroBruto, { etapa: "submissao_correcao" });
    await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString(), tokens_entrada: tokensEntrada, tokens_saida: tokensSaida, finalizacao_lease_ate: null }).eq("id", geracao.id).eq("status", "processando");
    return "erro_submissao_correcao";
  }

  // Atualiza response_id + tentativa_ia=2, mantém 'processando', NÃO
  // preenche finalizado_em (não é um estado terminal) e libera a lease —
  // a geração fica elegível já no próximo ciclo do cron para consultar o
  // novo response_id, sem esperar a lease vencer sozinha. Nunca espera
  // essa correção terminar nesta execução.
  await admin
    .from("aula_geracoes")
    .update({ openai_response_id: submissao.responseId, tentativa_ia: 2, tokens_entrada: tokensEntrada, tokens_saida: tokensSaida, finalizacao_lease_ate: null })
    .eq("id", geracao.id)
    .eq("status", "processando");

  return "correcao_submetida";
}
