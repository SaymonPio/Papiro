"use client";

import Link from "next/link";
import { ChangeEvent, useEffect, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import ComponenteAulaView, { type ComponenteAula } from "@/components/teoria/ComponenteAulaView";
import ComentariosAula from "@/components/teoria/ComentariosAula";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { classificarOrigemQuestao, inicioEnunciado } from "./banco-unidade";

// crypto.randomUUID() exige um "contexto seguro" do navegador — indisponível
// em HTTP por IP local (ex.: http://10.0.0.100:5173), só em localhost/HTTPS.
// Usado aqui só para nomear o caminho do arquivo no Storage (não é o id de
// nenhum componente de aula, que continua sendo gerado no servidor). Nunca
// usa Math.random() — o fallback é crypto.getRandomValues(), a mesma fonte
// de aleatoriedade criptograficamente segura, só montando o UUID v4 (RFC
// 4122) manualmente quando o atalho randomUUID() não existe.
function gerarIdArquivoMaterial(): string {
  const criptografia = globalThis.crypto;
  if (typeof criptografia?.randomUUID === "function") return criptografia.randomUUID();

  const bytes = new Uint8Array(16);
  criptografia.getRandomValues(bytes);
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // versão 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante RFC 4122
  const hex = Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

type Curso = { id: string; concurso: string | null; cargo: string | null; banca: string | null };
type CursoMateria = { id: number; nome: string };
type ConteudoAdmin = {
  conteudo_id: number;
  assunto_id: number | null;
  nome: string;
  ordem: number;
  relevante_para_preparacao: boolean;
};
type UnidadePedagogicaAdmin = {
  unidade_id: string;
  titulo: string;
  ordem: number;
  escopo: string;
  artigos_esperados: string[] | null;
  ativa: boolean;
};
type MaterialAdmin = {
  material_id: string;
  titulo: string;
  tipo: string;
  ativo: boolean;
  ultima_versao_id: string | null;
  ultimo_numero_versao: number | null;
  ultima_versao_titulo: string | null;
};
// validacao_escopo (Fase 2J-B): auditoria NÃO bloqueante de artigos fora
// do escopo cadastrado para a parte — populada só quando
// teoria_escopos_conteudo.artigos_esperados não é null para o conteúdo
// gerado (ver supabase/functions/gerar-aula/escopo.mjs). "executada:
// false" é o estado normal quando não há metadado de escopo cadastrado.
type ValidacaoEscopo =
  | { executada: false }
  | {
      executada: true;
      tem_alerta: boolean;
      artigos_abordados: string[];
      artigos_esperados: string[];
      artigos_fora_do_escopo: string[];
      referencias_nao_normalizadas: string[];
    };

type GeracaoAdmin = {
  geracao_id: string;
  status: string;
  iniciado_em: string;
  finalizado_em: string | null;
  aula_versao_id: string | null;
  erro: string | null;
  prompt_version: string;
  modelo: string | null;
  // Reflete public.listar_geracoes_conteudo_admin depois de
  // supabase/teoria_geracoes_admin_contexto.sql (migration nova — só
  // aplicada manualmente pelo usuário; até lá a RPC real ainda não
  // retorna "contexto", por isso toda leitura abaixo é defensiva e trata
  // ausência como "sem alerta", nunca como erro).
  contexto: {
    unidade_pedagogica_id?: string;
    unidade_pedagogica?: string;
    validacao_escopo?: ValidacaoEscopo;
  } | null;
};

// Nunca lança, nunca presume formato — contexto pode não existir ainda
// (RPC antiga, migration não aplicada) ou validacao_escopo pode não ter
// sido calculada (geração anterior à Fase 2J-B, ou sem metadado de
// escopo cadastrado). Só admin vê isto (esta página inteira já é
// gate eh_admin()); nunca aparece para o aluno.
function artigosForaDoEscopo(g: GeracaoAdmin): string[] {
  const validacao = g.contexto?.validacao_escopo;
  if (!validacao || validacao.executada !== true || !validacao.tem_alerta) return [];
  return Array.isArray(validacao.artigos_fora_do_escopo)
    ? validacao.artigos_fora_do_escopo.filter((a): a is string => typeof a === "string")
    : [];
}

// Reflete o RETURNS TABLE de public.carregar_aula_rascunho_admin — mesmo
// princípio já usado em app/teoria/page.tsx: os tipos aqui espelham
// exatamente a RPC, nunca inventam formato.
type FonteRascunho = {
  material_id: string;
  material_titulo: string;
  material_tipo: string;
  material_versao_id: string;
  numero_versao: number;
  titulo_versao: string | null;
  ordem: number | null;
  observacao: string | null;
};

type AulaRascunho = {
  aula_id: string;
  aula_titulo: string;
  aula_versao_id: string;
  numero_versao: number;
  status: string;
  estrutura: { componentes?: ComponenteAula[] };
  criado_em: string;
  publicado_em: string | null;
  fontes: FonteRascunho[];
};

// Painel "BANCO DA UNIDADE" — read-only, admin only. Reflete exatamente o
// RETURNS TABLE de public.inspecionar_candidatas_papiro_admin (mesma RPC já
// usada por app/admin/aulas/preview/page.tsx, aqui só no modo "unidade",
// com p_unidade_pedagogica_id sempre preenchido). "origem", nesse modo, é
// sempre a string fixa "unidade" (só distingue "vinculada"/"banco_geral" no
// modo Missão Final, com unidade nula) — não é a classificação REAL/AUTORAL
// usada abaixo, que vem de um campo diferente (ver classificarOrigemQuestao).
type AlternativaCandidata = { ordem: number; texto: string; correta: boolean };
type CandidataBancoUnidade = {
  questao_id: number;
  origem: string;
  enunciado: string;
  fonte: string | null;
  banca: string | null;
  concurso: string | null;
  explicacao: string | null;
  alternativas: AlternativaCandidata[] | null;
};

export default function AdminAulas() {
  const [verificando, setVerificando] = useState(true);
  const [admin, setAdmin] = useState(false);

  const [cursos, setCursos] = useState<Curso[]>([]);
  const [cursoId, setCursoId] = useState("");
  const [materias, setMaterias] = useState<CursoMateria[]>([]);
  const [materiaId, setMateriaId] = useState("");
  const [conteudos, setConteudos] = useState<ConteudoAdmin[]>([]);
  const [conteudoId, setConteudoId] = useState<number | null>(null);
  const [unidades, setUnidades] = useState<UnidadePedagogicaAdmin[]>([]);
  const [unidadeId, setUnidadeId] = useState("");

  const [materiais, setMateriais] = useState<MaterialAdmin[]>([]);
  const [fontesSelecionadas, setFontesSelecionadas] = useState<Set<string>>(new Set());
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [tituloMaterial, setTituloMaterial] = useState("");
  const [enviandoMaterial, setEnviandoMaterial] = useState(false);

  const [geracoes, setGeracoes] = useState<GeracaoAdmin[]>([]);
  const [gerando, setGerando] = useState(false);
  const [mensagem, setMensagem] = useState("");

  const [rascunho, setRascunho] = useState<AulaRascunho | null>(null);
  const [carregandoRascunho, setCarregandoRascunho] = useState(false);
  const [publicando, setPublicando] = useState(false);

  const [candidatas, setCandidatas] = useState<CandidataBancoUnidade[]>([]);
  const [carregandoCandidatas, setCarregandoCandidatas] = useState(false);
  const [erroCandidatas, setErroCandidatas] = useState("");
  const [questoesExpandidas, setQuestoesExpandidas] = useState<Set<number>>(new Set());
  // Guarda de corrida: cada troca de unidade/conteúdo incrementa este
  // contador; a resposta de uma requisição só é aplicada se ainda for a
  // mais recente — evita o corpus da unidade anterior "vazar" na tela
  // quando o admin troca de unidade rápido e a resposta antiga chega depois.
  const candidatasRequisicaoRef = useRef(0);
  // Reset síncrono durante o RENDER (nunca dentro de um useEffect) quando
  // unidadeId muda — mesmo padrão recomendado pelo próprio React para
  // "ajustar estado quando uma prop muda" sem disparar o aviso
  // react-hooks/set-state-in-effect. Garante que o corpus da unidade
  // anterior nunca fique visível enquanto a nova seleção ainda carrega.
  const [unidadeAnteriorBanco, setUnidadeAnteriorBanco] = useState(unidadeId);
  if (unidadeId !== unidadeAnteriorBanco) {
    setUnidadeAnteriorBanco(unidadeId);
    setCandidatas([]);
    setErroCandidatas("");
    setQuestoesExpandidas(new Set());
    setCarregandoCandidatas(Boolean(conteudoId && unidadeId));
    // O rascunho exibido abaixo (verRascunho) não guarda a que unidade
    // pertence — limpar aqui garante que trocar de unidade nunca deixe um
    // rascunho de OUTRA unidade visível, e que o link "abrir preview
    // completo" (que usa rascunho?.aula_versao_id) nunca aponte para a
    // unidade errada.
    setRascunho(null);
  }

  useEffect(() => {
    async function verificar() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }
      const { data } = await supabase.rpc("eh_admin");
      setAdmin(Boolean(data));
      setVerificando(false);
    }
    verificar();
  }, []);

  useEffect(() => {
    if (!admin) return;
    createClient().from("cursos").select("id, concurso, cargo, banca").order("concurso").then(({ data }) => {
      setCursos((data as Curso[] | null) ?? []);
    });
  }, [admin]);

  useEffect(() => {
    setMaterias([]); setMateriaId(""); setConteudos([]); setConteudoId(null);
    if (!cursoId) return;
    createClient().from("curso_materias").select("id, nome").eq("curso_id", cursoId).order("nome").then(({ data }) => {
      setMaterias((data as CursoMateria[] | null) ?? []);
    });
  }, [cursoId]);

  useEffect(() => {
    setConteudos([]); setConteudoId(null);
    if (!materiaId) return;
    createClient().rpc("listar_conteudos_curso_admin", { p_curso_materia_id: Number(materiaId) }).then(({ data }) => {
      setConteudos((data as ConteudoAdmin[] | null) ?? []);
    });
  }, [materiaId]);

  async function carregarMateriais() {
    const { data } = await createClient().rpc("listar_materiais_admin");
    setMateriais((data as MaterialAdmin[] | null) ?? []);
  }

  async function carregarGeracoes(id: number) {
    const { data } = await createClient().rpc("listar_geracoes_conteudo_admin", { p_conteudo_id: id });
    setGeracoes((data as GeracaoAdmin[] | null) ?? []);
  }

  useEffect(() => {
    setRascunho(null); setMensagem("");
    setUnidades([]); setUnidadeId("");
    if (!conteudoId) { setGeracoes([]); return; }
    createClient().rpc("listar_unidades_pedagogicas_admin", { p_conteudo_id: conteudoId }).then(({ data }) => {
      const lista = (data as UnidadePedagogicaAdmin[] | null) ?? [];
      setUnidades(lista);
      const primeiraAtiva = lista.find((u) => u.ativa);
      setUnidadeId(primeiraAtiva?.unidade_id ?? "");
    });
    carregarMateriais();
    carregarGeracoes(conteudoId);
  }, [conteudoId]);

  // Banco da unidade (painel read-only, admin-only): busca as questões
  // elegíveis desta unidade sempre que conteudoId/unidadeId mudarem. Sem
  // unidade selecionada, não busca nada e limpa qualquer corpus anterior
  // (nunca mostra dado desatualizado). Usa a MESMA RPC já usada pela prévia
  // de app/admin/aulas/preview/page.tsx (inspecionar_candidatas_papiro_admin,
  // somente leitura) — nenhuma RPC nova, nenhuma migration.
  useEffect(() => {
    candidatasRequisicaoRef.current += 1;
    const idRequisicao = candidatasRequisicaoRef.current;
    if (!conteudoId || !unidadeId) return;
    createClient()
      .rpc("inspecionar_candidatas_papiro_admin", { p_conteudo_id: conteudoId, p_unidade_pedagogica_id: unidadeId })
      .then(({ data, error }) => {
        if (candidatasRequisicaoRef.current !== idRequisicao) return; // resposta de uma seleção já superada
        if (error) setErroCandidatas("Não foi possível carregar as questões desta unidade.");
        else setCandidatas((data as CandidataBancoUnidade[] | null) ?? []);
        setCarregandoCandidatas(false);
      });
  }, [conteudoId, unidadeId]);

  function alternarExpansaoQuestao(questaoId: number) {
    setQuestoesExpandidas((atuais) => {
      const novo = new Set(atuais);
      if (novo.has(questaoId)) novo.delete(questaoId); else novo.add(questaoId);
      return novo;
    });
  }

  function alternarFonte(materialVersaoId: string) {
    setFontesSelecionadas((atuais) => {
      const novo = new Set(atuais);
      if (novo.has(materialVersaoId)) novo.delete(materialVersaoId); else novo.add(materialVersaoId);
      return novo;
    });
  }

  function selecionarArquivo(evento: ChangeEvent<HTMLInputElement>) {
    const file = evento.target.files?.[0];
    setMensagem("");
    if (!file) { setArquivo(null); return; }
    if (file.type !== "application/pdf") { setMensagem("Escolha um arquivo no formato PDF."); return; }
    if (file.size > 25 * 1024 * 1024) { setMensagem("O material deve ter no máximo 25 MB."); return; }
    setArquivo(file);
  }

  async function enviarMaterial() {
    if (!arquivo || !conteudoId || enviandoMaterial) return;
    setEnviandoMaterial(true); setMensagem("");
    const supabase = createClient();
    const caminho = `${conteudoId}/${gerarIdArquivoMaterial()}.pdf`;

    const { error: erroUpload } = await supabase.storage.from("materiais-teoria").upload(caminho, arquivo, { contentType: "application/pdf", upsert: false });
    if (erroUpload) { setMensagem("Não foi possível enviar o PDF."); setEnviandoMaterial(false); return; }

    const { error: erroRegistro } = await supabase.rpc("registrar_material_pdf_admin", {
      p_material_id: null,
      p_titulo: tituloMaterial || arquivo.name,
      p_tipo: "pdf",
      p_descricao: null,
      p_titulo_versao: "v1",
      p_arquivo_path: caminho,
      p_checksum: null,
    });

    if (erroRegistro) {
      await supabase.storage.from("materiais-teoria").remove([caminho]);
      setMensagem("Não foi possível registrar o material.");
      setEnviandoMaterial(false);
      return;
    }

    setArquivo(null); setTituloMaterial(""); setMensagem("Material enviado.");
    setEnviandoMaterial(false);
    await carregarMateriais();
  }

  async function gerarAula() {
    if (!conteudoId || !unidadeId || gerando) return; // camada 1 de idempotência: bloqueia clique duplo
    setGerando(true); setMensagem("Gerando aula — isso pode levar alguns minutos...");

    const { data, error } = await createClient().functions.invoke("gerar-aula", {
      body: { conteudoId, unidadePedagogicaId: unidadeId, materialVersaoIds: Array.from(fontesSelecionadas) },
    });

    setGerando(false);

    if (error || (data as { error?: string } | null)?.error) {
      const erroDados = data as { error?: string } | null;
      setMensagem(
        erroDados?.error === "geracao_em_andamento"
          ? "Já existe uma geração em andamento para este conteúdo. Aguarde a conclusão."
          : "Não foi possível gerar a aula agora. Veja o histórico de gerações para detalhes.",
      );
    } else {
      setMensagem("Aula gerada como rascunho.");
    }

    await carregarGeracoes(conteudoId);
  }

  async function verRascunho(aulaVersaoId: string) {
    setCarregandoRascunho(true); setRascunho(null);
    const { data } = await createClient().rpc("carregar_aula_rascunho_admin", { p_aula_versao_id: aulaVersaoId });
    const linha = (data as AulaRascunho[] | null)?.[0] ?? null;
    setRascunho(linha);
    setCarregandoRascunho(false);
  }

  async function publicarRascunho() {
    if (!rascunho || rascunho.status !== "rascunho" || publicando) return;
    setPublicando(true); setMensagem("Publicando a versão revisada...");
    const { error } = await createClient().rpc("publicar_aula_versao_admin", {
      p_aula_versao_id: rascunho.aula_versao_id,
    });
    setPublicando(false);
    if (error) { setMensagem("Não foi possível publicar esta versão."); return; }
    setMensagem("Aula publicada.");
    await verRascunho(rascunho.aula_versao_id);
    if (conteudoId) await carregarGeracoes(conteudoId);
  }

  if (verificando) return <main className="dashboard-loading"><MarcaCarregando texto="Verificando acesso administrativo..." /></main>;

  if (!admin) {
    return (
      <main className="admin-page admin-activation">
        <div>
          <p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p>
          <h1>Acesso restrito</h1>
          <p>Esta área é exclusiva de administradores.</p>
          <Link href="/admin">Ir para a administração</Link>
        </div>
      </main>
    );
  }

  const componentesRascunho = Array.isArray(rascunho?.estrutura?.componentes) ? rascunho!.estrutura.componentes! : [];
  const geracoesDaUnidade = unidadeId
    ? geracoes.filter((g) => g.contexto?.unidade_pedagogica_id === unidadeId)
    : [];

  const totalCandidatas = candidatas.length;
  const totalCandidatasReal = candidatas.filter((c) => classificarOrigemQuestao(c.banca) === "REAL").length;
  const totalCandidatasAutoral = totalCandidatas - totalCandidatasReal;

  return (
    <main className="admin-page">
      <header className="admin-header">
        <div>
          <p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p>
          <h1>Gerador de aulas da Teoria Interativa</h1>
          <span>Curso → conteúdo → fontes → geração por IA → revisão do rascunho.</span>
        </div>
        <div className="admin-header-actions">
          <Link href="/admin">Questões</Link>
          <Link className="admin-header-action-active" href="/admin/aulas">Gerar aulas</Link>
          <Link href="/admin/aulas/preview">Prévia da aula publicada</Link>
          <Link href="/painel">Voltar ao painel</Link>
        </div>
      </header>

      <section className="admin-foundations">
        <div className="admin-form-grid">
          <label>
            Curso
            <select value={cursoId} onChange={(e) => setCursoId(e.target.value)}>
              <option value="">Selecione um curso</option>
              {cursos.map((c) => <option key={c.id} value={c.id}>{c.concurso} — {c.cargo} ({c.banca})</option>)}
            </select>
          </label>

          <label>
            Matéria
            <select value={materiaId} onChange={(e) => setMateriaId(e.target.value)} disabled={!cursoId}>
              <option value="">Selecione uma matéria</option>
              {materias.map((m) => <option key={m.id} value={m.id}>{m.nome}</option>)}
            </select>
          </label>

          <label>
            Conteúdo
            <select value={conteudoId ?? ""} onChange={(e) => setConteudoId(e.target.value ? Number(e.target.value) : null)} disabled={!materiaId}>
              <option value="">Selecione um conteúdo</option>
              {conteudos.map((c) => (
                <option key={c.conteudo_id} value={c.conteudo_id}>
                  {c.nome}{!c.relevante_para_preparacao ? " (não relevante)" : ""}
                </option>
              ))}
            </select>
          </label>

          <label>
            Unidade pedagógica
            <select value={unidadeId} onChange={(e) => setUnidadeId(e.target.value)} disabled={!conteudoId}>
              <option value="">Selecione uma unidade</option>
              {unidades.map((u) => (
                <option key={u.unidade_id} value={u.unidade_id} disabled={!u.ativa}>
                  {u.ordem}. {u.titulo}{!u.ativa ? " (inativa)" : ""}
                </option>
              ))}
            </select>
          </label>
        </div>
      </section>

      {conteudoId && (
        <section className="admin-foundations">
          <div className="admin-section-heading">
            <div><p className="dashboard-label">BANCO DA UNIDADE</p><h2>Questões elegíveis desta unidade</h2></div>
            {unidadeId && !carregandoCandidatas && !erroCandidatas && (
              <span>{totalCandidatas} questão(ões) elegível(is) · REAL: {totalCandidatasReal} · AUTORAL: {totalCandidatasAutoral}</span>
            )}
          </div>

          {unidadeId && (
            <div className="admin-preview-acesso">
              <Link
                className="admin-preview-link"
                href={`/admin/aulas/preview?conteudo=${conteudoId}&unidade=${unidadeId}${
                  rascunho ? `&versao=${rascunho.aula_versao_id}` : ""
                }${conteudos.find((c) => c.conteudo_id === conteudoId) ? `&nome=${encodeURIComponent(conteudos.find((c) => c.conteudo_id === conteudoId)!.nome)}` : ""}`}
              >
                Ver aula completa
              </Link>
              <small className="admin-preview-link-hint">Aula + prática simulada + Missão Final</small>
            </div>
          )}

          {!unidadeId && <p>Selecione uma unidade pedagógica acima para ver as questões elegíveis vinculadas a ela.</p>}
          {unidadeId && carregandoCandidatas && <p>Carregando questões desta unidade...</p>}
          {unidadeId && !carregandoCandidatas && erroCandidatas && <p role="alert">{erroCandidatas}</p>}
          {unidadeId && !carregandoCandidatas && !erroCandidatas && candidatas.length === 0 && (
            <p>Nenhuma questão elegível encontrada para esta unidade.</p>
          )}

          {unidadeId && !carregandoCandidatas && !erroCandidatas && candidatas.length > 0 && (
            <div className="admin-recent">
              {candidatas.map((c) => {
                const origemQuestao = classificarOrigemQuestao(c.banca);
                const expandida = questoesExpandidas.has(c.questao_id);
                return (
                  <article key={c.questao_id}>
                    <span className={`notice-status ${origemQuestao === "REAL" ? "concluido" : "processando"}`}>
                      {origemQuestao}
                    </span>
                    <div>
                      <strong>Q{c.questao_id}{c.banca ? ` · ${c.banca}` : ""}</strong>
                      <small>{inicioEnunciado(c.enunciado)}</small>
                      {expandida && (
                        <>
                          <p>{c.enunciado}</p>
                          {Array.isArray(c.alternativas) && c.alternativas.length > 0 && (
                            <ul>
                              {c.alternativas.map((alt) => (
                                <li key={alt.ordem}>{alt.correta ? <strong>{alt.texto} (gabarito)</strong> : alt.texto}</li>
                              ))}
                            </ul>
                          )}
                          <small>{[c.banca, c.concurso].filter(Boolean).join(" — ") || "Fonte não registrada"}</small>
                          {c.fonte && <small>{c.fonte}</small>}
                          {c.explicacao && <p>{c.explicacao}</p>}
                        </>
                      )}
                    </div>
                    <button type="button" onClick={() => alternarExpansaoQuestao(c.questao_id)}>
                      {expandida ? "Ocultar detalhes" : "Ver detalhes"}
                    </button>
                  </article>
                );
              })}
            </div>
          )}
        </section>
      )}

      {conteudoId && (
        <>
          <section className="admin-foundations">
            <div className="admin-section-heading">
              <div><p className="dashboard-label">FONTES</p><h2>Materiais desta aula</h2></div>
            </div>

            <div className="admin-form-grid">
              <label>
                Título do novo material
                <input value={tituloMaterial} onChange={(e) => setTituloMaterial(e.target.value)} placeholder="Ex.: Lei Orgânica da Brigada Militar" />
              </label>
              <label>
                Arquivo PDF
                <input type="file" accept="application/pdf,.pdf" onChange={selecionarArquivo} />
              </label>
            </div>
            <button type="button" onClick={enviarMaterial} disabled={!arquivo || enviandoMaterial}>
              {enviandoMaterial ? "Enviando..." : "Enviar material"}
            </button>

            <fieldset className="admin-alternatives">
              <legend>Selecione as fontes usadas nesta geração (versão mais recente de cada material)</legend>
              {materiais.length === 0 && <p>Nenhum material cadastrado ainda.</p>}
              {materiais.map((m) => (
                <label key={m.material_id}>
                  <input
                    type="checkbox"
                    disabled={!m.ultima_versao_id}
                    checked={m.ultima_versao_id ? fontesSelecionadas.has(m.ultima_versao_id) : false}
                    onChange={() => m.ultima_versao_id && alternarFonte(m.ultima_versao_id)}
                  />
                  <span>{m.titulo} {m.ultimo_numero_versao ? `— v${m.ultimo_numero_versao}` : "(sem versão)"}</span>
                </label>
              ))}
            </fieldset>
          </section>

          <section className="admin-foundations">
            <div className="admin-section-heading">
              <div><p className="dashboard-label">GERAÇÃO</p><h2>Gerar aula (rascunho)</h2></div>
              <span>{geracoesDaUnidade.length} geração(ões) desta unidade</span>
            </div>

            <button className="admin-publish" type="button" onClick={gerarAula} disabled={gerando}>
              {gerando ? "Gerando aula..." : "Gerar aula"}
            </button>
            {mensagem && <p className="upload-message" role="status">{mensagem}</p>}

            <div className="admin-recent">
              {geracoesDaUnidade.map((g) => (
                <article key={g.geracao_id}>
                  <span className={`notice-status ${g.status}`}>
                    {g.status === "concluida" ? "Concluída" : g.status === "erro" ? "Erro" : "Processando"}
                  </span>
                  <div>
                    <strong>{new Date(g.iniciado_em).toLocaleString("pt-BR")}</strong>
                    <small>{g.contexto?.unidade_pedagogica ?? "Unidade pedagógica não registrada"}</small>
                    <small>{g.prompt_version} · {g.modelo ?? "modelo não registrado"}</small>
                    {g.erro && <small role="alert">{g.erro}</small>}
                    {artigosForaDoEscopo(g).length > 0 && (
                      <small role="alert" className="admin-alerta-escopo">
                        <strong>ATENÇÃO AO ESCOPO</strong> — esta geração citou dispositivos possivelmente fora
                        da faixa cadastrada para esta parte: {artigosForaDoEscopo(g).join(", ")}. Revise antes de
                        publicar.
                      </small>
                    )}
                  </div>
                  {g.status === "concluida" && g.aula_versao_id && (
                    <button type="button" onClick={() => verRascunho(g.aula_versao_id as string)} disabled={carregandoRascunho}>
                      Ver rascunho
                    </button>
                  )}
                </article>
              ))}
            </div>
          </section>

          {rascunho && (
            <section className="admin-foundations">
              <div className="admin-section-heading">
                <div><p className="dashboard-label">RASCUNHO — status: {rascunho.status}</p><h2>{rascunho.aula_titulo}</h2></div>
            <span>versão {rascunho.numero_versao}</span>
            {rascunho.status === "rascunho" && (
              <button type="button" onClick={publicarRascunho} disabled={publicando}>
                {publicando ? "Publicando..." : "Publicar versão revisada"}
              </button>
            )}
              </div>
              <p>
                Fontes: {rascunho.fontes.length === 0 ? "nenhuma" : rascunho.fontes.map((f) => `${f.material_titulo} (v${f.numero_versao})`).join(", ")}
              </p>
              {/* Mesma apresentação visual que o aluno vê em /teoria — nunca um
                  renderer próprio do admin que possa divergir. */}
              <div className="teoria-aula">
                {componentesRascunho.map((componente, indice) => (
                  <ComponenteAulaView key={componente?.tipo ? `${componente.tipo}-${indice}` : indice} componente={componente} />
                ))}
                <ComentariosAula aulaId={rascunho.aula_id} modoPrevia />
              </div>
            </section>
          )}
        </>
      )}
    </main>
  );
}
