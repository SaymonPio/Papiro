"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import ComponenteAulaView, { type ComponenteAula } from "@/components/teoria/ComponenteAulaView";
import ComentariosAula from "@/components/teoria/ComentariosAula";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { classificarOrigemQuestao } from "@/app/admin/aulas/banco-unidade";
import {
  resolverAulaVersaoDaUnidade,
  resolverInfoConteudo,
  resolverTituloPercurso,
  type GeracaoResumo,
} from "./percurso";

// Prévia administrativa, somente leitura, do PERCURSO COMPLETO do Modo
// Papiro — aula (publicada OU rascunho, ver resolverAulaVersaoDaUnidade em
// ./percurso.ts) de cada unidade ATIVA de QUALQUER curso_conteudo_id
// (exatamente como o aluno vê em /teoria: mesmo ComponenteAulaView, mesma
// ComentariosAula) seguida das questões que seriam candidatas à prática
// daquela unidade, e uma aba separada de Missão Final com as candidatas ao
// pool misturado. Chama só RPCs somente-leitura já existentes
// (listar_unidades_pedagogicas_admin, listar_geracoes_conteudo_admin,
// carregar_aula_rascunho_admin, inspecionar_candidatas_papiro_admin — as
// 4 mesmas já usadas em app/admin/aulas/page.tsx). Nenhuma RPC nova.
// Nunca chama RPC de missão/progresso/resposta; nunca inicia sessão real.
//
// Generalização (esta rodada): esta tela era hardcoded para o conteúdo 53
// (Lei Maria da Penha) — CONTEUDO_ID e UNIDADES_PREVIEW fixos no código.
// Agora conteudoId vem de ?conteudo=<id> na própria URL, as unidades vêm
// de listar_unidades_pedagogicas_admin (mesma RPC do gerador de aulas) e a
// aula_versao_id de cada unidade é resolvida a partir do histórico de
// gerações (percurso.ts), sem precisar de nenhum SELECT direto em
// curso_conteudos (tabela sem policy de SELECT para admin — só RPCs
// security definer) nem de nenhuma RPC nova.
const QUANTIDADE_PADRAO_UNIDADE = 10;
const QUANTIDADE_PADRAO_MISSAO_FINAL = 30;

type UnidadePreview = { unidadeId: string; ordem: number; titulo: string };
type UnidadePreviewResolvida = UnidadePreview & { aulaVersaoId: string | null };

type AulaCarregada = {
  aula_id: string;
  aula_titulo: string;
  aula_versao_id: string;
  numero_versao: number;
  status: string;
  estrutura: { componentes?: ComponenteAula[] };
  publicado_em: string | null;
};

type Candidata = {
  questao_id: number;
  origem: "unidade" | "vinculada" | "banco_geral";
  enunciado: string;
  fonte: string | null;
  banca: string | null;
  concurso: string | null;
  explicacao: string | null;
  alternativas: { ordem: number; texto: string; correta: boolean }[] | null;
};

const LETRAS = "ABCDEFGHIJ";

function CardCandidata({ c, mostrarOrigem }: { c: Candidata; mostrarOrigem: boolean }) {
  // Reaproveita o MESMO renderer interativo que a aula usa para
  // "questao_resolvida" (selecionar, cortar alternativa, confirmar, ver
  // certo/errado) -- em vez de recriar uma versão estática própria. Estado
  // 100% local dentro de ComponenteAulaView (sem Supabase, sem progresso,
  // sem caderno de erros), só precisa receber o mesmo formato de dados que
  // uma aula publicada já usaria: alternativas como {letra, texto} e o
  // gabarito como a LETRA da alternativa marcada `correta` no banco.
  const alternativasLetra = (c.alternativas ?? []).map((alt) => ({
    letra: LETRAS[alt.ordem - 1] ?? String(alt.ordem),
    texto: alt.texto,
  }));
  const gabarito = (c.alternativas ?? []).find((alt) => alt.correta);
  const componente: ComponenteAula = {
    tipo: "questao_resolvida",
    enunciado: c.enunciado,
    alternativas: alternativasLetra,
    gabarito: gabarito ? (LETRAS[gabarito.ordem - 1] ?? String(gabarito.ordem)) : "",
  };
  const origemBancoAutoral = classificarOrigemQuestao(c.banca);

  return (
    <div className="admin-candidata-questao">
      <div className="admin-candidata-cabecalho">
        <strong>Questão {c.questao_id}</strong>
        {mostrarOrigem && (
          <span className={`notice-status ${c.origem === "banco_geral" ? "erro" : "concluido"}`}>
            {c.origem === "banco_geral" ? "Banco geral" : "Vinculada"}
          </span>
        )}
        <span className={`notice-status ${origemBancoAutoral === "REAL" ? "concluido" : "processando"}`}>
          {origemBancoAutoral}
        </span>
        <small>{[c.banca, c.concurso].filter(Boolean).join(" — ") || "Fonte não registrada"}</small>
        {c.fonte && <small>{c.fonte}</small>}
      </div>
      <ComponenteAulaView componente={componente} />
      {/* Sempre visível (nao atras do "Confirmar resposta") -- auditoria de
          conteudo precisa ler a explicacao de cada questao rapido, sem ter
          que responder uma a uma. So leitura de questoes.explicacao, nunca
          chama registrar_resposta. */}
      <div className="teoria-exemplo">
        <p className="teoria-subtitulo">GABARITO · EXPLICAÇÃO</p>
        <p className="teoria-texto">
          {c.explicacao || "Sem explicação cadastrada para esta questão."}
        </p>
      </div>
    </div>
  );
}

// Lê o contexto da própria URL de forma síncrona (lazy initializer de
// useState, nunca um useEffect — window não existe durante o render no
// servidor, mas esta página só mostra conteúdo real depois do gate
// eh_admin(), que só resolve no cliente, então não há risco de
// hydration mismatch visível).
function lerContextoDaUrl() {
  if (typeof window === "undefined") {
    return { conteudoId: null as number | null, unidadeQuery: null as string | null, versaoQuery: null as string | null, nomeQuery: null as string | null };
  }
  const params = new URLSearchParams(window.location.search);
  const conteudoParam = params.get("conteudo");
  return {
    conteudoId: conteudoParam && /^\d+$/.test(conteudoParam) ? Number(conteudoParam) : null,
    unidadeQuery: params.get("unidade"),
    versaoQuery: params.get("versao"),
    nomeQuery: params.get("nome"),
  };
}

export default function PreviewAula() {
  const [verificando, setVerificando] = useState(true);
  const [admin, setAdmin] = useState(false);

  // Contexto vindo da própria URL (?conteudo=&unidade=&versao=&nome=).
  // unidadeQuery/versaoQuery, quando presentes, indicam a unidade/versão
  // exatas que app/admin/aulas/page.tsx já tinha carregadas no momento em
  // que o admin clicou para abrir este preview.
  const [{ conteudoId, unidadeQuery, versaoQuery, nomeQuery }] = useState(lerContextoDaUrl);

  const [unidades, setUnidades] = useState<UnidadePreview[]>([]);
  const [carregandoUnidades, setCarregandoUnidades] = useState(Boolean(conteudoId));
  const [erroUnidades, setErroUnidades] = useState("");

  const [geracoes, setGeracoes] = useState<GeracaoResumo[]>([]);
  const [carregandoGeracoes, setCarregandoGeracoes] = useState(Boolean(conteudoId));

  const unidadesRequisicaoRef = useRef(0);
  useEffect(() => {
    unidadesRequisicaoRef.current += 1;
    const idRequisicao = unidadesRequisicaoRef.current;
    if (!admin || !conteudoId) return;
    createClient()
      .rpc("listar_unidades_pedagogicas_admin", { p_conteudo_id: conteudoId })
      .then(({ data, error }) => {
        if (unidadesRequisicaoRef.current !== idRequisicao) return;
        if (error) { setErroUnidades("Não foi possível carregar as unidades deste conteúdo."); setUnidades([]); }
        else {
          const ativas = ((data as { unidade_id: string; titulo: string; ordem: number; ativa: boolean }[] | null) ?? [])
            .filter((u) => u.ativa)
            .map((u) => ({ unidadeId: u.unidade_id, titulo: u.titulo, ordem: u.ordem }));
          setUnidades(ativas);
        }
        setCarregandoUnidades(false);
      });
  }, [admin, conteudoId]);

  const geracoesRequisicaoRef = useRef(0);
  useEffect(() => {
    geracoesRequisicaoRef.current += 1;
    const idRequisicao = geracoesRequisicaoRef.current;
    if (!admin || !conteudoId) return;
    createClient()
      .rpc("listar_geracoes_conteudo_admin", { p_conteudo_id: conteudoId })
      .then(({ data }) => {
        if (geracoesRequisicaoRef.current !== idRequisicao) return;
        setGeracoes((data as GeracaoResumo[] | null) ?? []);
        setCarregandoGeracoes(false);
      });
  }, [admin, conteudoId]);

  // Cada unidade ativa, com a aula_versao_id já resolvida — regra: se a
  // unidade for exatamente a que veio em ?unidade= E ?versao= também veio
  // preenchido, usa essa versão exata (o admin já estava olhando ela em
  // /admin/aulas); qualquer outra unidade resolve pela geração concluída
  // mais recente (ver percurso.ts). Nenhuma unidade "fabricada": a
  // quantidade vem só do LIVE (listar_unidades_pedagogicas_admin).
  const unidadesResolvidas: UnidadePreviewResolvida[] = unidades.map((u) => ({
    ...u,
    aulaVersaoId:
      versaoQuery && u.unidadeId === unidadeQuery ? versaoQuery : resolverAulaVersaoDaUnidade(geracoes, u.unidadeId),
  }));
  const infoConteudo = resolverInfoConteudo(geracoes);
  const tituloPercurso = conteudoId ? resolverTituloPercurso(infoConteudo, nomeQuery, conteudoId) : "";
  const missaoFinalIndice = unidadesResolvidas.length; // aba extra, sem aula

  const [indice, setIndice] = useState(0);
  // Assim que as unidades carregam, se ?unidade= apontar para uma unidade
  // ativa real, abre já nela -- comparação feita durante o RENDER (nunca
  // dentro de um efeito) e só uma vez, na primeira lista não vazia.
  const [indiceInicialAplicado, setIndiceInicialAplicado] = useState(false);
  if (!indiceInicialAplicado && unidadesResolvidas.length > 0) {
    setIndiceInicialAplicado(true);
    if (unidadeQuery) {
      const posicao = unidadesResolvidas.findIndex((u) => u.unidadeId === unidadeQuery);
      if (posicao >= 0) setIndice(posicao);
    }
  }

  const ehMissaoFinal = indice === missaoFinalIndice;
  const unidadeAtual = ehMissaoFinal ? null : unidadesResolvidas[indice] ?? null;
  const aulaVersaoIdAtual = unidadeAtual?.aulaVersaoId ?? null;

  function irParaSecao(novoIndice: number) {
    if (novoIndice < 0 || novoIndice > missaoFinalIndice) return;
    setIndice(novoIndice);
    window.requestAnimationFrame(() => {
      document.getElementById("conteudo-secao-atual")?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }

  const [aula, setAula] = useState<AulaCarregada | null>(null);
  const [carregandoAula, setCarregandoAula] = useState(true);
  const [erro, setErro] = useState("");
  const [candidatas, setCandidatas] = useState<Candidata[]>([]);
  const [carregandoCandidatas, setCarregandoCandidatas] = useState(true);
  const [erroCandidatas, setErroCandidatas] = useState("");

  // Reset síncrono durante o RENDER quando a seção muda (nunca dentro de
  // um useEffect — mesmo padrão já usado em app/admin/aulas/page.tsx,
  // painel "banco da unidade"): nunca deixa a aula/questões da seção
  // ANTERIOR visíveis enquanto a nova ainda carrega, e já liga o estado de
  // carregamento correto para a nova seção sem precisar de um setState
  // síncrono dentro do efeito de busca.
  const [indiceAnterior, setIndiceAnterior] = useState<number | null>(null);
  if (indice !== indiceAnterior) {
    setIndiceAnterior(indice);
    setAula(null); setErro("");
    setCandidatas([]); setErroCandidatas("");
    setCarregandoAula(!ehMissaoFinal && Boolean(aulaVersaoIdAtual));
    setCarregandoCandidatas(true);
  }

  // Guardas de corrida (uma por fluxo assíncrono): trocar de seção rápido
  // não pode deixar a resposta de uma seção antiga sobrescrever a atual.
  const aulaRequisicaoRef = useRef(0);
  const candidatasRequisicaoRef = useRef(0);

  useEffect(() => {
    aulaRequisicaoRef.current += 1;
    const idRequisicao = aulaRequisicaoRef.current;
    if (!admin || ehMissaoFinal || !aulaVersaoIdAtual) return; // SEM_AULA: sem geração concluída ainda
    createClient()
      .rpc("carregar_aula_rascunho_admin", { p_aula_versao_id: aulaVersaoIdAtual })
      .then(({ data, error }) => {
        if (aulaRequisicaoRef.current !== idRequisicao) return;
        if (error) { setErro("Não foi possível carregar esta unidade."); setAula(null); }
        else setAula(((data as AulaCarregada[] | null) ?? [])[0] ?? null);
        setCarregandoAula(false);
      });
  }, [admin, ehMissaoFinal, aulaVersaoIdAtual]);

  useEffect(() => {
    candidatasRequisicaoRef.current += 1;
    const idRequisicao = candidatasRequisicaoRef.current;
    if (!admin || !conteudoId) return;
    const unidadeId = ehMissaoFinal ? null : unidadeAtual?.unidadeId ?? null;
    createClient()
      .rpc("inspecionar_candidatas_papiro_admin", { p_conteudo_id: conteudoId, p_unidade_pedagogica_id: unidadeId })
      .then(({ data, error }) => {
        if (candidatasRequisicaoRef.current !== idRequisicao) return;
        if (error) { setErroCandidatas("Não foi possível carregar as questões candidatas."); setCandidatas([]); }
        else setCandidatas((data as Candidata[] | null) ?? []);
        setCarregandoCandidatas(false);
      });
  }, [admin, conteudoId, ehMissaoFinal, unidadeAtual?.unidadeId]);

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

  if (verificando) return <main className="dashboard-loading"><MarcaCarregando texto="Verificando acesso..." /></main>;

  if (!admin) {
    return (
      <main className="method-page">
        <header><h1>Acesso restrito</h1></header>
        <p role="alert">Esta prévia é só para administradores.</p>
        <Link className="answer-submit" href="/">Voltar</Link>
      </main>
    );
  }

  if (!conteudoId) {
    return (
      <main className="method-page">
        <header>
          <p className="dashboard-label">PRÉVIA ADMINISTRATIVA · SOMENTE LEITURA</p>
          <h1>Nenhum conteúdo informado</h1>
          <span>Abra este preview a partir de /admin/aulas, com um conteúdo e unidade selecionados.</span>
        </header>
        <Link className="answer-submit" href="/admin/aulas">Ir para o gerador de aulas</Link>
      </main>
    );
  }

  const componentes = Array.isArray(aula?.estrutura?.componentes) ? aula!.estrutura.componentes! : [];
  const quantidadePadrao = ehMissaoFinal ? QUANTIDADE_PADRAO_MISSAO_FINAL : QUANTIDADE_PADRAO_UNIDADE;
  const candidatasMostradas = candidatas.slice(0, quantidadePadrao);
  const faltam = quantidadePadrao - candidatas.length;
  const carregandoPercurso = carregandoUnidades || carregandoGeracoes;

  return (
    <main className="method-page">
      <header>
        <p className="dashboard-label">PRÉVIA ADMINISTRATIVA · SOMENTE LEITURA</p>
        <h1>{tituloPercurso} — percurso completo do Modo Papiro</h1>
        <span>Aula publicada ou rascunho de cada unidade + questões candidatas à prática, e a aba Missão Final com o pool misturado. Nenhum dado de missão, progresso ou resposta é lido ou alterado nesta tela; nenhuma sessão real é iniciada.</span>
      </header>

      {carregandoPercurso && <p>Carregando o percurso deste conteúdo...</p>}
      {!carregandoPercurso && erroUnidades && <p role="alert">{erroUnidades}</p>}
      {!carregandoPercurso && !erroUnidades && unidadesResolvidas.length === 0 && (
        <p>Este conteúdo ainda não possui nenhuma unidade pedagógica ativa cadastrada.</p>
      )}

      {!carregandoPercurso && !erroUnidades && unidadesResolvidas.length > 0 && (
        <section>
          <div className="teoria-unidades">
            <nav className="teoria-unidades-navegacao" aria-label="Unidades e Missão Final">
              <div className="teoria-unidades-cabecalho">
                <div>
                  <p>PERCURSO PAPIRO</p>
                  <h2>{tituloPercurso}</h2>
                </div>
              </div>
              <div className="teoria-unidades-lista" role="tablist" aria-label="Escolha uma unidade ou a Missão Final">
                {unidadesResolvidas.map((u, i) => (
                  <button
                    key={u.unidadeId}
                    type="button"
                    role="tab"
                    aria-selected={i === indice}
                    aria-controls="conteudo-secao-atual"
                    className={i === indice ? "ativa" : ""}
                    onClick={() => irParaSecao(i)}
                  >
                    <b aria-hidden="true">{u.ordem}</b>
                    <span>{u.titulo}</span>
                  </button>
                ))}
                <button
                  type="button"
                  role="tab"
                  aria-selected={ehMissaoFinal}
                  aria-controls="conteudo-secao-atual"
                  className={ehMissaoFinal ? "ativa" : ""}
                  onClick={() => irParaSecao(missaoFinalIndice)}
                >
                  <b aria-hidden="true">★</b>
                  <span>Missão Final</span>
                </button>
              </div>
            </nav>

            <div
              id="conteudo-secao-atual"
              className="teoria-aula"
              role="tabpanel"
              aria-label={ehMissaoFinal ? "Missão Final" : `Unidade ${unidadeAtual?.ordem}: ${unidadeAtual?.titulo}`}
            >
              <div className="teoria-unidade-titulo">
                <p>{ehMissaoFinal ? "MISSÃO FINAL PAPIRO" : `UNIDADE ${unidadeAtual?.ordem}`}</p>
                <h2>{ehMissaoFinal ? "30 questões misturadas do conteúdo inteiro" : unidadeAtual?.titulo}</h2>
              </div>

              {!ehMissaoFinal && (
                <>
                  {carregandoAula && <p>Carregando a aula desta unidade...</p>}
                  {!carregandoAula && erro && <p role="alert">{erro}</p>}
                  {!carregandoAula && !erro && !aulaVersaoIdAtual && (
                    <p>Esta unidade ainda não tem nenhuma aula gerada.</p>
                  )}
                  {!carregandoAula && !erro && aulaVersaoIdAtual && componentes.length === 0 && (
                    <p>Esta aula ainda não possui conteúdo para exibição.</p>
                  )}
                  {!carregandoAula && !erro && componentes.length > 0 && aula && (
                    <>
                      {componentes.map((componente, i) => (
                        <ComponenteAulaView key={componente?.tipo ? `${componente.tipo}-${i}` : i} componente={componente} />
                      ))}
                      <ComentariosAula aulaId={aula.aula_id} modoPrevia />
                      <p className="teoria-progresso-mensagem">
                        Versão {aula.numero_versao} · status {aula.status} · publicada em{" "}
                        {aula.publicado_em ? new Date(aula.publicado_em).toLocaleString("pt-BR") : "—"}
                      </p>
                    </>
                  )}
                </>
              )}

              <div className="admin-section-heading">
                <div>
                  <p className="dashboard-label">
                    {ehMissaoFinal ? "CANDIDATAS À MISSÃO FINAL" : "QUESTÕES DA PRÁTICA DESTA UNIDADE"}
                  </p>
                  <h2>{Math.min(candidatas.length, quantidadePadrao)} de {quantidadePadrao} exibidas</h2>
                </div>
                <span>{candidatas.length} candidata(s) elegível(is) no total</span>
              </div>

              {carregandoCandidatas && <p>Carregando questões candidatas...</p>}
              {!carregandoCandidatas && erroCandidatas && <p role="alert">{erroCandidatas}</p>}

              {!carregandoCandidatas && !erroCandidatas && faltam > 0 && (
                <p role="alert">
                  <strong>COBERTURA INSUFICIENTE</strong> — {ehMissaoFinal ? "a Missão Final" : `a ${unidadeAtual?.titulo}`}{" "}
                  possui apenas {candidatas.length} questõe(s) elegível(is); faltam {faltam} para completar
                  {ehMissaoFinal ? " as 30 da Missão Final" : " a prática padrão de 10"}.
                </p>
              )}

              {!carregandoCandidatas && !erroCandidatas && candidatas.length === 0 && (
                <p>Nenhuma questão elegível encontrada.</p>
              )}

              {!carregandoCandidatas && !erroCandidatas && candidatasMostradas.length > 0 && (
                <div className="admin-candidatas-lista">
                  {candidatasMostradas.map((c) => (
                    <CardCandidata key={c.questao_id} c={c} mostrarOrigem={ehMissaoFinal} />
                  ))}
                </div>
              )}

              <div className="teoria-unidades-acoes" aria-label="Navegação entre seções">
                <button type="button" onClick={() => irParaSecao(indice - 1)} disabled={indice === 0}>
                  Seção anterior
                </button>
                <button
                  type="button"
                  className="principal"
                  onClick={() => irParaSecao(indice + 1)}
                  disabled={indice === missaoFinalIndice}
                >
                  Próxima seção
                </button>
              </div>
            </div>
          </div>
        </section>
      )}
    </main>
  );
}
