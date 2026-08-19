"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import ComponenteAulaView, { type ComponenteAula } from "@/components/teoria/ComponenteAulaView";
import ComentariosAula from "@/components/teoria/ComentariosAula";
import MarcaCarregando from "@/components/ui/MarcaCarregando";

// Prévia administrativa, somente leitura, do PERCURSO COMPLETO do Modo
// Papiro — aula publicada de cada unidade (exatamente como o aluno vê em
// /teoria: mesmo ComponenteAulaView, mesma ComentariosAula) seguida das
// questões que seriam candidatas à prática daquela unidade, e uma aba
// separada de Missão Final com as candidatas ao pool misturado. Chama só
// RPCs somente-leitura (carregar_aula_rascunho_admin, já usada pelo "Ver
// rascunho" de app/admin/aulas/page.tsx, e inspecionar_candidatas_papiro_
// admin, nova — ver supabase/inspecionar_candidatas_papiro_admin_rpc.sql).
// Nunca chama RPC de missão/progresso/resposta; nunca inicia sessão real.
//
// As 5 unidades abaixo são as do conteúdo 53 (Lei Maria da Penha) no momento
// em que esta página foi criada — ferramenta de inspeção pontual, não uma
// tela nova do produto. Se um novo número de versão for publicado depois,
// atualize o aulaVersaoId correspondente aqui.
const CONTEUDO_ID = 53;

const UNIDADES_PREVIEW: { ordem: number; titulo: string; unidadeId: string; aulaVersaoId: string }[] = [
  { ordem: 1, titulo: "Fundamentos e campo de aplicação", unidadeId: "e260b54c-6a75-4398-97f6-7a432c405041", aulaVersaoId: "9b430867-7595-4600-a2a8-7a769661cb5e" },
  { ordem: 2, titulo: "Prevenção e assistência à mulher", unidadeId: "ab29ba89-1dcc-46c2-9659-f5808be3d976", aulaVersaoId: "cfd879d2-4bb0-41b3-9da1-32ae3533966a" },
  { ordem: 3, titulo: "Atendimento policial e providências imediatas", unidadeId: "4d593bc4-6e4f-4c1f-8817-e41c78fe9491", aulaVersaoId: "49810ea3-20c3-4222-891c-20a3cab5aac8" },
  { ordem: 4, titulo: "Procedimentos e medidas protetivas de urgência", unidadeId: "7164d7f2-86f7-413e-b0fc-64070dd2e2f5", aulaVersaoId: "141b5e3f-0e34-4850-a3ff-b9145667f689" },
  { ordem: 5, titulo: "Rede de justiça, equipe multidisciplinar e disposições finais", unidadeId: "53dc06a1-cd16-4004-a76b-8201d95a91c4", aulaVersaoId: "dc5b3e4f-a7cc-4244-9bac-9389cb0057b8" },
];
const MISSAO_FINAL_INDICE = UNIDADES_PREVIEW.length; // 5 -- aba extra, sem aula
const QUANTIDADE_PADRAO_UNIDADE = 10;
const QUANTIDADE_PADRAO_MISSAO_FINAL = 30;

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

  return (
    <div className="admin-candidata-questao">
      <div className="admin-candidata-cabecalho">
        <strong>Questão {c.questao_id}</strong>
        {mostrarOrigem && (
          <span className={`notice-status ${c.origem === "banco_geral" ? "erro" : "concluido"}`}>
            {c.origem === "banco_geral" ? "Banco geral" : "Vinculada"}
          </span>
        )}
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

export default function PreviewAula() {
  const [verificando, setVerificando] = useState(true);
  const [admin, setAdmin] = useState(false);
  const [indice, setIndice] = useState(0);
  const [aula, setAula] = useState<AulaCarregada | null>(null);
  const [carregandoAula, setCarregandoAula] = useState(true);
  const [erro, setErro] = useState("");
  const [candidatas, setCandidatas] = useState<Candidata[]>([]);
  const [carregandoCandidatas, setCarregandoCandidatas] = useState(true);
  const [erroCandidatas, setErroCandidatas] = useState("");

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

  const ehMissaoFinal = indice === MISSAO_FINAL_INDICE;

  function irParaSecao(novoIndice: number) {
    if (novoIndice < 0 || novoIndice > MISSAO_FINAL_INDICE) return;
    setIndice(novoIndice);
    window.requestAnimationFrame(() => {
      document.getElementById("conteudo-secao-atual")?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }

  useEffect(() => {
    if (!admin || ehMissaoFinal) return;
    setCarregandoAula(true);
    setErro("");
    const unidade = UNIDADES_PREVIEW[indice];
    createClient()
      .rpc("carregar_aula_rascunho_admin", { p_aula_versao_id: unidade.aulaVersaoId })
      .then(({ data, error }) => {
        if (error) { setErro("Não foi possível carregar esta unidade."); setAula(null); }
        else setAula(((data as AulaCarregada[] | null) ?? [])[0] ?? null);
        setCarregandoAula(false);
      });
  }, [admin, indice, ehMissaoFinal]);

  useEffect(() => {
    if (!admin) return;
    setCarregandoCandidatas(true);
    setErroCandidatas("");
    const unidadeId = ehMissaoFinal ? null : UNIDADES_PREVIEW[indice].unidadeId;
    createClient()
      .rpc("inspecionar_candidatas_papiro_admin", { p_conteudo_id: CONTEUDO_ID, p_unidade_pedagogica_id: unidadeId })
      .then(({ data, error }) => {
        if (error) { setErroCandidatas("Não foi possível carregar as questões candidatas."); setCandidatas([]); }
        else setCandidatas((data as Candidata[] | null) ?? []);
        setCarregandoCandidatas(false);
      });
  }, [admin, indice, ehMissaoFinal]);

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

  const componentes = Array.isArray(aula?.estrutura?.componentes) ? aula!.estrutura.componentes! : [];
  const unidadeAtual = ehMissaoFinal ? null : UNIDADES_PREVIEW[indice];
  const quantidadePadrao = ehMissaoFinal ? QUANTIDADE_PADRAO_MISSAO_FINAL : QUANTIDADE_PADRAO_UNIDADE;
  const candidatasMostradas = candidatas.slice(0, quantidadePadrao);
  const faltam = quantidadePadrao - candidatas.length;

  return (
    <main className="method-page">
      <header>
        <p className="dashboard-label">PRÉVIA ADMINISTRATIVA · SOMENTE LEITURA</p>
        <h1>Lei Maria da Penha — percurso completo do Modo Papiro</h1>
        <span>Aula publicada de cada unidade + questões candidatas à prática, e a aba Missão Final com o pool misturado. Nenhum dado de missão, progresso ou resposta é lido ou alterado nesta tela; nenhuma sessão real é iniciada.</span>
      </header>

      <section>
        <div className="teoria-unidades">
          <nav className="teoria-unidades-navegacao" aria-label="Unidades e Missão Final">
            <div className="teoria-unidades-cabecalho">
              <div>
                <p>PERCURSO PAPIRO</p>
                <h2>Lei Maria da Penha</h2>
              </div>
            </div>
            <div className="teoria-unidades-lista" role="tablist" aria-label="Escolha uma unidade ou a Missão Final">
              {UNIDADES_PREVIEW.map((u, i) => (
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
                onClick={() => irParaSecao(MISSAO_FINAL_INDICE)}
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
            aria-label={ehMissaoFinal ? "Missão Final" : `Unidade ${unidadeAtual!.ordem}: ${unidadeAtual!.titulo}`}
          >
            <div className="teoria-unidade-titulo">
              <p>{ehMissaoFinal ? "MISSÃO FINAL PAPIRO" : `UNIDADE ${unidadeAtual!.ordem}`}</p>
              <h2>{ehMissaoFinal ? "30 questões misturadas do conteúdo inteiro" : unidadeAtual!.titulo}</h2>
            </div>

            {!ehMissaoFinal && (
              <>
                {carregandoAula && <p>Carregando a aula desta unidade...</p>}
                {erro && <p role="alert">{erro}</p>}
                {!carregandoAula && !erro && componentes.length === 0 && (
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
            {erroCandidatas && <p role="alert">{erroCandidatas}</p>}

            {!carregandoCandidatas && !erroCandidatas && faltam > 0 && (
              <p role="alert">
                <strong>COBERTURA INSUFICIENTE</strong> — {ehMissaoFinal ? "a Missão Final" : `a ${unidadeAtual!.titulo}`}{" "}
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
                disabled={indice === MISSAO_FINAL_INDICE}
              >
                Próxima seção
              </button>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
