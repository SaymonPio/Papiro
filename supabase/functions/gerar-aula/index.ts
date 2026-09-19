import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { validarJurisprudenciasValidadasEntrada, montarBlocoJurisprudencia } from "../_shared/gerar-aula/jurisprudencia.mjs";
import { montarPromptContexto, resolverConfiguracaoModelo, submeterResponseBackground, PROMPT_VERSION } from "../_shared/gerar-aula/openaiResponses.mjs";
import { sanitizarErro } from "../_shared/gerar-aula/sanitizarErro.mjs";
import { expirarGeracoesOrfas } from "../_shared/gerar-aula/expiracao.mjs";

// Fase 2J-A — gerador real da Teoria Interativa.
// Fase 3A — geração ASSÍNCRONA (background:true na Responses API).
//
// Arquitetura (auditoria da Fase 2J confirmou este é o único padrão real
// de IA já em produção no Papiro): mesmo desenho de
// supabase/functions/processar-edital/index.ts — o browser NUNCA vê a
// chave da OpenAI; esta function roda no servidor (Deno, Supabase Edge
// Functions), lê OPENAI_API_KEY só de Deno.env, autentica o chamador via
// auth.getUser(token) e usa um client service_role separado para toda
// escrita privilegiada — as mesmas tabelas continuam com RLS fechado para
// authenticated, a escrita aqui não depende de nenhuma policy nova.
//
// O aluno NUNCA chama esta function. Autorização explícita por
// public.eh_admin() (mesma função já usada em todo o projeto) ANTES de
// qualquer leitura de material, qualquer chamada à OpenAI e qualquer
// escrita — checada com o client do PRÓPRIO usuário (nunca com
// service_role, que ignoraria RLS/RPC e mascararia a checagem).
//
// ============================================================================
// FASE 3A — MUDANÇA ARQUITETURAL (motivo: geração síncrona atingiu o teto
// de execução da Edge Function, ~150s, HTTP 546 do runtime, deixando
// aula_geracoes presa em 'processando' para sempre — caso real observado
// em produção, aula_geracoes.id f2a0d24c-9a2d-4adc-ad09-680e686bb31a).
// ============================================================================
//
// Esta function agora SÓ INICIA a geração — nunca espera a IA terminar:
//   1-9. (inalterado) auth, eh_admin, payload, resolução pedagógica,
//        fontes, escopo, lock de concorrência, montagem do prompt/anexos;
//   10. submete UMA Response em modo background:true + store:true à
//       Responses API — a chamada em si é rápida (a OpenAI só precisa
//       ACEITAR o job, não terminá-lo);
//   11. persiste openai_response_id + tentativa_ia=1 na MESMA linha de
//       aula_geracoes já travada em 'processando' (nenhum status novo —
//       ver decisão abaixo);
//   12. responde HTTP 202 imediatamente. NUNCA faz parse/validação da
//       resposta da IA, NUNCA cria aula/aula_versao — isso agora é
//       responsabilidade exclusiva de supabase/functions/
//       finalizar-geracao-aula/index.ts (o finalizador canônico,
//       chamado por um job periódico, nunca pelo browser).
//
// DECISÃO EXPLÍCITA: NÃO existe um status "aguardando_ia" novo.
// 'processando' continua significando "geração ativa" em qualquer uma
// das suas sub-fases (agora incluindo "aguardando a IA em background" e
// "aguardando finalização/correção") — o CHECK de status e o índice
// único parcial aula_geracoes_uma_unidade_processando_idx continuam
// EXATAMENTE como estavam, sem migration nenhuma nesses dois pontos (ver
// supabase/async_geracao_aula.sql, que só ACRESCENTA openai_response_id
// e tentativa_ia).
//
// Concorrência/idempotência: inalterado — a trava é o índice único
// parcial, a tentativa de INSERT acontece ANTES de qualquer chamada à
// OpenAI; se colidir (unique_violation, código 23505), a function nunca
// chega a gastar nada. Geração travada (>10min) continua expirando do
// mesmo jeito antes de tentar adquirir a trava de novo.
//
// A aula gerada NUNCA é publicada automaticamente: aula_versoes.status é
// sempre 'rascunho'. Isso é responsabilidade do FINALIZADOR agora, não
// mais desta function.
//
// Fase 2J-B (escopo fechado por parte) e Jurisprudência essencial:
// comportamento INALTERADO — só o local do código mudou (agora em
// supabase/functions/_shared/gerar-aula/). Ver os comentários originais
// nesses módulos.
//
// Sanitização de erros (Fase 3A): qualquer erro (inclusive o corpo bruto
// de erro da OpenAI, que pode conter fragmentos de API key em mensagens
// como "Incorrect API key provided") passa por sanitizarErro() ANTES de
// ser persistido em aula_geracoes.erro ou devolvido na resposta HTTP —
// nunca mais o texto bruto do provedor. Ver achado de segurança
// confirmado em produção (duas gerações reais de conteudo_id=57
// gravaram a chave mascarada apenas parcialmente pela própria OpenAI).

const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type" };

const MINUTOS_GERACAO_EXPIRADA = 10;

// Trava conservadora de tamanho combinado dos anexos (ver comentário no
// ponto de uso, antes da montagem dos anexos): material_versoes não
// guarda o tamanho real do arquivo hoje, então não é possível somar bytes
// reais sem uma migration nova (fora do escopo desta fase — documentado,
// não improvisado). 1 PDF por geração é seguro mesmo no pior caso (o
// bucket materiais-teoria limita cada PDF a 25MB; o limite combinado
// documentado da OpenAI é 50MB por requisição de arquivos) — folga
// generosa sem precisar conhecer o tamanho real de cada arquivo.
const MAX_ANEXOS_PDF_POR_GERACAO = 1;

const TIPOS_EVIDENCIA_CONTEXTO_PROGRAMATICO = ["edital_atual", "edital_anterior"];
const TIPOS_EVIDENCIA_PERFIL_BANCA = ["historico_banca", "prova_anterior"];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  let geracaoId: string | null = null;
  let admin: ReturnType<typeof createClient> | null = null;

  try {
    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    const authorization = req.headers.get("Authorization");
    if (!openaiKey) return json({ error: "Chave da OpenAI não configurada." }, 500);
    if (!authorization) return json({ error: "Sessão não encontrada." }, 401);

    // Client escopado ao PRÓPRIO usuário (nunca service_role) — é isso que
    // faz auth.uid()/eh_admin() resolverem para quem realmente chamou.
    const auth = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authorization } },
    });
    const { data: { user } } = await auth.auth.getUser(authorization.replace("Bearer ", ""));
    if (!user) return json({ error: "Sessão inválida." }, 401);

    const { data: souAdmin } = await auth.rpc("eh_admin");
    if (!souAdmin) return json({ error: "Apenas administradores podem gerar aulas." }, 403);

    const corpo = await req.json();
    const conteudoId = Number(corpo?.conteudoId);
    const unidadePedagogicaId = typeof corpo?.unidadePedagogicaId === "string" ? corpo.unidadePedagogicaId : "";
    const materialVersaoIds: string[] = Array.isArray(corpo?.materialVersaoIds) ? corpo.materialVersaoIds : [];
    if (!Number.isFinite(conteudoId) || conteudoId <= 0) return json({ error: "conteudoId inválido." }, 400);
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(unidadePedagogicaId)) {
      return json({ error: "unidadePedagogicaId inválido." }, 400);
    }

    // Jurisprudências previamente validadas pela curadoria humana, enviadas
    // inline no corpo (sem tabela nova nesta fase). Ausente/vazia é o caso
    // normal — só um erro de FORMA aqui bloqueia a geração; o conteúdo em
    // si nunca é auditado contra nenhuma base além de "veio no corpo desta
    // requisição", porque quem decide o que é "validado" é sempre o admin
    // chamador, não esta function.
    const validacaoJurisprudencias = validarJurisprudenciasValidadasEntrada(corpo?.jurisprudenciasValidadas);
    if (!validacaoJurisprudencias.ok) {
      return json({ error: `jurisprudenciasValidadas inválida: ${validacaoJurisprudencias.erro}` }, 400);
    }
    const jurisprudenciasValidadas = validacaoJurisprudencias.itens;

    // Daqui pra frente, toda escrita privilegiada usa service_role — nunca
    // volta pro client do usuário (que não tem SELECT/INSERT direto nas
    // tabelas de materiais/aulas/aula_versoes/aula_geracoes de propósito).
    admin = createClient(supabaseUrl, serviceKey);

    // Contexto SEMPRE derivado do servidor a partir de conteudoId — nunca
    // de curso/matéria/banca enviados pelo cliente (nenhum desses campos é
    // sequer aceito no corpo da requisição).
    const { data: conteudo, error: erroConteudo } = await admin
      .from("curso_conteudos")
      .select(`
        id, assunto_id, curso_materia_id, relevante_para_preparacao,
        assuntos ( nome ),
        curso_materias ( id, nome, curso_id, cursos ( concurso, cargo, banca ) )
      `)
      .eq("id", conteudoId)
      .maybeSingle();

    if (erroConteudo || !conteudo) return json({ error: "Conteúdo não encontrado." }, 404);

    const cursoMateria = (conteudo as any).curso_materias;
    const cursoInfo = cursoMateria?.cursos;
    const conteudoNome = (conteudo as any).assuntos?.nome ?? "Conteúdo sem nome";
    const materiaNome = cursoMateria?.nome ?? "Matéria sem nome";
    const cursoMateriaId = (conteudo as any).curso_materia_id;

    if (!cursoMateria || !cursoInfo) return json({ error: "Não foi possível resolver curso/matéria deste conteúdo." }, 422);

    const { data: unidade, error: erroUnidade } = await admin
      .from("unidades_pedagogicas")
      .select("id, titulo, ordem, escopo, artigos_esperados, ativa")
      .eq("id", unidadePedagogicaId)
      .eq("curso_conteudo_id", conteudoId)
      .maybeSingle();
    if (erroUnidade || !unidade) return json({ error: "Unidade pedagógica não encontrada neste conteúdo." }, 404);
    if (!(unidade as any).ativa) return json({ error: "Esta unidade pedagógica está inativa." }, 422);
    const unidadeTitulo = (unidade as any).titulo as string;

    // Conteúdo marcado como não relevante para preparação nunca gera aula
    // — mesmo critério já usado em iniciar_ou_recuperar_missao_diaria
    // (missoes_rpc.sql) para bloquear missão nesse caso.
    if (!(conteudo as any).relevante_para_preparacao) {
      return json({ error: "Este conteúdo não está marcado como relevante para preparação." }, 422);
    }

    // Evidências reais (curso_evidencias), nunca inventadas — mesma tabela
    // já usada pelo cronograma (Fase 2H), agora lida também pelo conteúdo
    // OU pela matéria (mesmo critério dual já usado em app/cronograma/
    // page.tsx). Erro de leitura é tratado explicitamente — nunca vira
    // silenciosamente "sem evidências" (isso mudaria o conteúdo da aula
    // sem avisar ninguém).
    const { data: evidencias, error: erroEvidencias } = await admin
      .from("curso_evidencias")
      .select("tipo_origem, frequencia, descricao")
      .or(`curso_conteudo_id.eq.${conteudoId},curso_materia_id.eq.${cursoMateriaId}`);
    if (erroEvidencias) throw new Error("Falha ao carregar as evidências deste curso/conteúdo.");

    const listaEvidencias = (evidencias ?? []) as { tipo_origem: string; frequencia: number | null; descricao: string | null }[];
    const contextoProgramatico = listaEvidencias
      .filter((e) => TIPOS_EVIDENCIA_CONTEXTO_PROGRAMATICO.includes(e.tipo_origem) && e.descricao)
      .map((e) => e.descricao as string);
    const perfilBancaEvidencias = listaEvidencias
      .filter((e) => TIPOS_EVIDENCIA_PERFIL_BANCA.includes(e.tipo_origem) && e.descricao)
      .map((e) => (e.frequencia ? `${e.descricao} (frequência observada: ${e.frequencia})` : (e.descricao as string)));

    // Escopo por parte (Fase 2J-B, teoria_escopos_conteudo — migration
    // opcional, pode nem existir ainda aplicada). Ausência de linha para
    // este conteudoId é um estado NORMAL (fallback abaixo), nunca erro.
    // A relação com partes irmãs vem SOMENTE de grupo_id — nunca por nome/
    // substring. Erro de leitura é tratado explicitamente pelo mesmo
    // motivo das evidências acima.
    const { data: escopoAtual, error: erroEscopoAtual } = await admin
      .from("teoria_escopos_conteudo")
      .select("grupo_id, parte_ordem, escopo, artigos_esperados")
      .eq("curso_conteudo_id", conteudoId)
      .maybeSingle();
    if (erroEscopoAtual) throw new Error("Falha ao carregar o escopo cadastrado para este conteúdo.");

    const escopoAutorizado = (unidade as any).escopo as string;
    let grupoEscopoId: string | null = null;
    let parteOrdem: number | null = null;
    const artigosEsperados: string[] | null = ((unidade as any).artigos_esperados ?? null) as string[] | null;
    let partesIrmas: { conteudoId: number; parteOrdem: number | null; titulo: string }[] = [];

    if (escopoAtual) {
      grupoEscopoId = (escopoAtual as any).grupo_id;
      parteOrdem = (escopoAtual as any).parte_ordem;

      const { data: irmasData, error: erroIrmas } = await admin
        .from("teoria_escopos_conteudo")
        .select("curso_conteudo_id, parte_ordem, curso_conteudos ( assuntos ( nome ) )")
        .eq("grupo_id", grupoEscopoId as string)
        .neq("curso_conteudo_id", conteudoId)
        .order("parte_ordem", { ascending: true, nullsFirst: false });
      if (erroIrmas) throw new Error("Falha ao carregar as demais partes deste mesmo conteúdo.");

      partesIrmas = ((irmasData ?? []) as any[]).map((linha) => ({
        conteudoId: linha.curso_conteudo_id,
        parteOrdem: linha.parte_ordem,
        titulo: linha.curso_conteudos?.assuntos?.nome ?? `Conteúdo #${linha.curso_conteudo_id}`,
      }));
    }

    // As demais unidades do MESMO curso_conteudo são agora a fonte
    // canônica dos recortes que não podem vazar para esta aula.
    const { data: unidadesIrmas, error: erroUnidadesIrmas } = await admin
      .from("unidades_pedagogicas")
      .select("ordem, titulo")
      .eq("curso_conteudo_id", conteudoId)
      .eq("ativa", true)
      .neq("id", unidadePedagogicaId)
      .order("ordem");
    if (erroUnidadesIrmas) throw new Error("Falha ao carregar as demais unidades deste conteúdo.");
    const titulosJaIncluidos = new Set(partesIrmas.map((p) => p.titulo));
    for (const linha of (unidadesIrmas ?? []) as any[]) {
      if (!titulosJaIncluidos.has(linha.titulo)) {
        partesIrmas.push({ conteudoId, parteOrdem: linha.ordem, titulo: linha.titulo });
        titulosJaIncluidos.add(linha.titulo);
      }
    }

    // Fontes: só material_versoes realmente informadas pelo admin — nunca
    // vinculamos nada além disso.
    let materiaisSelecionados: { id: string; material_id: string; titulo_versao: string | null; conteudo_texto: string | null; arquivo_path: string | null; titulo: string }[] = [];
    if (materialVersaoIds.length > 0) {
      const { data: materiaisData, error: erroMateriais } = await admin
        .from("material_versoes")
        .select("id, material_id, titulo_versao, conteudo_texto, arquivo_path, materiais ( titulo )")
        .in("id", materialVersaoIds);

      if (erroMateriais) throw new Error("Falha ao carregar as fontes selecionadas.");
      if (!materiaisData || materiaisData.length !== materialVersaoIds.length) {
        return json({ error: "Uma ou mais fontes selecionadas não existem." }, 422);
      }
      materiaisSelecionados = materiaisData.map((m: any) => ({
        id: m.id,
        material_id: m.material_id,
        titulo_versao: m.titulo_versao,
        conteudo_texto: m.conteudo_texto,
        arquivo_path: m.arquivo_path,
        titulo: m.materiais?.titulo ?? "Material sem título",
      }));
    }

    // Trava conservadora de tamanho combinado (ver MAX_ANEXOS_PDF_POR_GERACAO
    // no topo do arquivo para o raciocínio completo) — checada cedo, antes
    // de qualquer trabalho caro (trava de geração, signed URLs, OpenAI).
    const quantidadePdfs = materiaisSelecionados.filter((m) => m.arquivo_path).length;
    if (quantidadePdfs > MAX_ANEXOS_PDF_POR_GERACAO) {
      return json({
        error: `Muitos PDFs selecionados (${quantidadePdfs}). No máximo ${MAX_ANEXOS_PDF_POR_GERACAO} arquivo(s) por geração nesta fase, para nunca ultrapassar o limite combinado de 50MB da OpenAI (cada PDF pode ter até 25MB).`,
      }, 422);
    }

    // Snapshot compacto do contexto — gravado ANTES de chamar a OpenAI,
    // sobrevive mesmo se a geração terminar em erro. Campos de escopo
    // (Fase 2J-B) só entram quando existe dado REAL vindo de
    // teoria_escopos_conteudo — nunca um valor inventado. validacao_escopo
    // é acrescentado depois, na finalização (só é calculável após a
    // resposta da IA chegar — ver finalizar-geracao-aula).
    const contextoSnapshot: Record<string, unknown> = {
      curso_id: cursoMateria.curso_id,
      curso_materia_id: cursoMateriaId,
      conteudo_id: conteudoId,
      unidade_pedagogica_id: unidadePedagogicaId,
      unidade_pedagogica: unidadeTitulo,
      concurso: cursoInfo.concurso ?? null,
      cargo: cursoInfo.cargo ?? null,
      banca: cursoInfo.banca ?? null,
      materia: materiaNome,
      conteudo: conteudoNome,
      escopo_da_unidade: escopoAutorizado,
      curso_evidencias_ids_usadas: listaEvidencias.length,
      material_versao_ids: materiaisSelecionados.map((m) => m.id),
    };
    if (grupoEscopoId) contextoSnapshot.grupo_escopo_id = grupoEscopoId;
    if (parteOrdem !== null) contextoSnapshot.parte_ordem = parteOrdem;
    if (partesIrmas.length > 0) contextoSnapshot.partes_irmas_consideradas = partesIrmas.map((p) => p.titulo);
    if (artigosEsperados !== null) contextoSnapshot.artigos_esperados = artigosEsperados;
    if (jurisprudenciasValidadas.length > 0) {
      contextoSnapshot.jurisprudencias_validadas_fornecidas = jurisprudenciasValidadas.map((j) => `${j.tribunal} — ${j.identificacao}`);
    }

    // Recuperação de geração travada — ver aula_geracoes.sql para a
    // justificativa dos 10 minutos, e _shared/gerar-aula/expiracao.mjs
    // para a regra exata (Fase 4: só expira geração ÓRFÃ/LEGADA, nunca uma
    // async genuinamente em andamento na OpenAI). Continua rodando ANTES
    // da trava.
    await expirarGeracoesOrfas({ admin, conteudoId, unidadePedagogicaId, minutosExpiracao: MINUTOS_GERACAO_EXPIRADA });

    const { modelo, reasoningEffort, maxOutputTokens } = resolverConfiguracaoModelo((nome) => Deno.env.get(nome));

    // Trava real: índice único parcial em aula_geracoes (unidade_pedagogica_id)
    // WHERE status='processando'. Isso acontece ANTES de qualquer chamada à
    // OpenAI — duas requisições simultâneas para a MESMA unidade nunca
    // resultam em duas chamadas pagas. tentativa_ia inicia em 1 (default da
    // coluna) — nenhuma mudança de comportamento aqui além de gravar
    // openai_response_id mais adiante, na mesma linha.
    const { data: geracao, error: erroLock } = await admin
      .from("aula_geracoes")
      .insert({
        conteudo_id: conteudoId,
        unidade_pedagogica_id: unidadePedagogicaId,
        status: "processando",
        criado_por: user.id,
        prompt_version: PROMPT_VERSION,
        modelo,
        contexto: contextoSnapshot,
      })
      .select("id")
      .single();

    if (erroLock) {
      if ((erroLock as any).code === "23505") {
        return json({ error: "geracao_em_andamento", message: "Já existe uma geração em andamento para esta unidade." }, 409);
      }
      throw new Error("Não foi possível iniciar a geração.");
    }
    geracaoId = (geracao as any).id;

    // Signed URLs (10 min, mesmo padrão de processar-edital) para as
    // fontes que têm PDF — bucket privado, nunca público. Se qualquer PDF
    // selecionado não puder ser disponibilizado (erro ou signedUrl
    // ausente), a geração inteira é abortada aqui — nunca seguimos adiante
    // nem vinculamos essa fonte como "usada" sem o arquivo ter realmente
    // chegado à OpenAI.
    const anexos: { type: "input_file"; file_url: string; detail: "low" }[] = [];
    const fontesTitulos: string[] = [];
    for (const material of materiaisSelecionados) {
      const rotulo = material.titulo_versao ? `${material.titulo} (${material.titulo_versao})` : material.titulo;
      if (material.arquivo_path) {
        const { data: assinatura, error: erroAssinatura } = await admin.storage.from("materiais-teoria").createSignedUrl(material.arquivo_path, 600);
        if (erroAssinatura || !assinatura?.signedUrl) {
          throw new Error(`Não foi possível disponibilizar o arquivo da fonte "${rotulo}" para a geração.`);
        }
        anexos.push({ type: "input_file", file_url: assinatura.signedUrl, detail: "low" });
      }
      fontesTitulos.push(rotulo);
    }

    const prompt = montarPromptContexto(
      { concurso: cursoInfo.concurso, cargo: cursoInfo.cargo, banca: cursoInfo.banca, materiaNome, conteudoNome: unidadeTitulo },
      contextoProgramatico,
      perfilBancaEvidencias,
      fontesTitulos,
      {
        temMetadata: true,
        escopoAutorizado,
        partesIrmasTitulos: partesIrmas.map((p) => p.titulo),
      },
      montarBlocoJurisprudencia(jurisprudenciasValidadas),
    );

    // ==========================================================================
    // FASE 3A — daqui pra baixo é TUDO diferente da versão síncrona: só
    // submete o job em background e retorna. Nunca espera a IA responder.
    // ==========================================================================
    const submissao = await submeterResponseBackground({
      openaiKey,
      modelo,
      reasoningEffort,
      maxOutputTokens,
      textoPrompt: prompt,
      anexos,
    });

    if (!submissao.ok) {
      const erroSanitizado = sanitizarErro(submissao.erroBruto, { etapa: "submissao_inicial" });
      throw new Error(erroSanitizado.mensagem);
    }

    // Persiste o response_id na MESMA linha já travada em 'processando' —
    // nenhuma mudança de status aqui (continua 'processando'; ver decisão
    // documentada no topo do arquivo). tentativa_ia permanece 1 (default).
    const { error: erroPersistResponseId } = await admin
      .from("aula_geracoes")
      .update({ openai_response_id: submissao.responseId })
      .eq("id", geracaoId);
    if (erroPersistResponseId) {
      throw new Error("A geração foi aceita pela OpenAI, mas não foi possível registrar o identificador de acompanhamento.");
    }

    // 202 Accepted: a geração está em andamento, mas ainda não terminou.
    // Nunca inclui openai_response_id no corpo — o browser não precisa
    // dele (só o finalizador, server-side, consulta a OpenAI).
    return json({ ok: true, async: true, geracaoId, status: "processando" }, 202);
  } catch (erro) {
    const erroSanitizado = sanitizarErro(erro, { etapa: "iniciador" });
    if (geracaoId && admin) {
      await admin.from("aula_geracoes").update({ status: "erro", erro: erroSanitizado.mensagem, finalizado_em: new Date().toISOString() }).eq("id", geracaoId);
    }
    return json({ error: erroSanitizado.mensagem }, 500);
  }
});
