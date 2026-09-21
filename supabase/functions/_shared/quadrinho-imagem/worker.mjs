// Orquestração de UM quadro (Fase Q12.1). Sem Deno, sem rede própria: todo I/O entra
// por `deps` (injeção), então o fluxo inteiro é testável com mocks.
//
//   claim (feito pelo handler)
//     -> contexto (cenas do MESMO quadrinho, só cenas) -> prompt determinístico
//     -> Image API (WebP) -> validação de bytes (RIFF/WEBP, <= 262144)
//     -> upload SEM sobrescrever no path do claim -> concluir_quadrinho_asset.
//
// Toda falha ANTES do upload vira falhar_quadrinho_asset (a RPC decide retry/erro; a
// Edge não reimplementa a máquina de estados). O path é sempre o storage_path_esperado
// devolvido pelo claim — o SQL é a fonte da verdade.
//
// FENCING: se concluir devolver aceito=false (claim perdido / cena mudou), removemos
// SOMENTE o objeto que ESTA execução acabou de criar e paramos; nunca tocamos no estado
// novo. Se a remoção falhar, o GC de uploads órfãos (Q11) cobre.
//
// Processo morto de forma abrupta não passa por aqui: lease, fencing, retry e GC cobrem.

import { extrairCenas, montarPromptVisual } from "./prompt.mjs";
import { camposDeLogSeguros, sanitizarFalhaImagem } from "./sanitizar.mjs";
import { validarWebp } from "./webp.mjs";

/**
 * @typedef {{
 *   asset_id: string, aula_versao_id: string, componente_id: string, quadro_indice: number,
 *   scene_hash: string, cena: string, tentativa: number, claim_token: string, storage_path_esperado: string
 * }} Claim
 */

/**
 * Nunca lança: todo erro é convertido em resultado + falhar_quadrinho_asset.
 *
 * @param {{ claim: Claim, config: any, deps: {
 *   obterComponente: (aulaVersaoId: string, componenteId: string) => Promise<unknown>,
 *   gerarImagem: (a: { prompt: string, config: any }) => Promise<Uint8Array>,
 *   uploadWebp: (a: { path: string, bytes: Uint8Array }) => Promise<{ error?: unknown } | void>,
 *   removerObjeto: (path: string) => Promise<{ error?: unknown } | void>,
 *   concluir: (a: { assetId: string, claimToken: string, sceneHash: string, storagePath: string, modelo: string, promptVersion: string, promptVisual: string }) => Promise<{ aceito: boolean, motivo?: string }>,
 *   falhar: (a: { assetId: string, claimToken: string, erro: string }) => Promise<unknown>,
 *   agora?: () => number,
 *   log?: (evento: string, campos: Record<string, unknown>) => void,
 * } }} entrada
 */
export async function processarAsset({ claim, config, deps }) {
  const agora = deps.agora ?? Date.now;
  const inicio = agora();
  const literais = [claim.claim_token, claim.storage_path_esperado];
  const log = (evento, campos) => {
    try {
      deps.log?.(evento, camposDeLogSeguros({ asset_id: claim.asset_id, quadro_indice: claim.quadro_indice, tentativa: claim.tentativa, ...campos }, { literais }));
    } catch {
      /* log nunca pode derrubar o fluxo */
    }
  };
  const duracao = () => agora() - inicio;
  const path = claim.storage_path_esperado;

  async function registrarFalha(etapa, erro) {
    const mensagem = sanitizarFalhaImagem(erro, { literais });
    try {
      await deps.falhar({ assetId: claim.asset_id, claimToken: claim.claim_token, erro: mensagem });
      log("falha_registrada", { etapa, erro: mensagem, duracao_ms: duracao() });
      return { resultado: "falhou", etapa, erro: mensagem };
    } catch (falhaAoFalhar) {
      // A lease expira sozinha e o retry/GC cobrem; nunca mascarar o erro original.
      log("falha_ao_registrar_falha", { etapa, erro: sanitizarFalhaImagem(falhaAoFalhar, { literais }), duracao_ms: duracao() });
      return { resultado: "falhou_sem_registro", etapa, erro: mensagem };
    }
  }

  async function removerProprioObjeto() {
    try {
      const r = await deps.removerObjeto(path);
      if (r && r.error) throw r.error;
      return true;
    } catch (erro) {
      log("cleanup_falhou", { etapa: "remover_objeto", erro: sanitizarFalhaImagem(erro, { literais }) });
      return false;
    }
  }

  // ---- 1) contexto + prompt (determinístico) ----
  let prompt;
  try {
    const componente = await deps.obterComponente(claim.aula_versao_id, claim.componente_id);
    const cenas = extrairCenas(componente);
    prompt = montarPromptVisual({ cenaAtual: claim.cena, quadroIndice: claim.quadro_indice, cenas, promptVersion: config.promptVersion });
  } catch (erro) {
    return registrarFalha("contexto", erro);
  }

  // ---- 2) Image API + validação real dos bytes (nada é enviado ao Storage antes) ----
  let bytes;
  try {
    bytes = await deps.gerarImagem({ prompt, config });
    validarWebp(bytes, { maxBytes: config.maxBytes });
  } catch (erro) {
    return registrarFalha("imagem", erro);
  }
  log("imagem_validada", { etapa: "imagem", bytes: bytes.length, duracao_ms: duracao() });

  // ---- 3) upload SEM sobrescrever; conflito/erro = falha (nunca apagamos objeto alheio) ----
  try {
    const up = await deps.uploadWebp({ path, bytes });
    if (up && up.error) throw up.error;
  } catch (erro) {
    return registrarFalha("upload", erro);
  }

  // ---- 4) concluir com o claim_token (fencing). Daqui em diante o objeto é NOSSO. ----
  const argsConcluir = {
    assetId: claim.asset_id,
    claimToken: claim.claim_token,
    sceneHash: claim.scene_hash,
    storagePath: path,
    modelo: config.model,
    promptVersion: config.promptVersion,
    promptVisual: prompt,
  };
  let resultado;
  try {
    resultado = await deps.concluir(argsConcluir);
  } catch {
    // Falha de transporte: o banco PODE ter concluído. concluir é idempotente para o mesmo
    // path, então repetimos uma vez ANTES de decidir qualquer limpeza.
    try {
      resultado = await deps.concluir(argsConcluir);
    } catch (erro) {
      // Estado desconhecido: NÃO removemos (pode estar referenciado). Registramos a falha; se o
      // claim ainda for o atual o retry acontece, senão o objeto vira candidato do GC (Q11).
      const falha = await registrarFalha("concluir", erro);
      return { ...falha, resultado: "concluir_indeterminado" };
    }
  }

  if (resultado && resultado.aceito === true) {
    log("asset_concluido", { resultado: "concluido", motivo: resultado.motivo, bytes: bytes.length, duracao_ms: duracao() });
    return { resultado: "concluido", motivo: resultado.motivo ?? null };
  }

  // aceito=false (claim_invalido, cena_alterada, stale...): removemos SÓ o que criamos agora.
  const removido = await removerProprioObjeto();
  log("resultado_stale", { resultado: removido ? "stale_limpo" : "stale_limpeza_falhou", motivo: resultado?.motivo ?? "desconhecido", duracao_ms: duracao() });
  return { resultado: removido ? "stale_limpo" : "stale_limpeza_falhou", motivo: resultado?.motivo ?? null };
}
