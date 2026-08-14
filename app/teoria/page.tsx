"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { lerMissaoCronograma, lerMissionId, montarLinkMissao } from "@/utils/missao-cronograma.mjs";
import { createClient } from "@/utils/supabase/client";
import ComponenteAulaView, { type ComponenteAula } from "@/components/teoria/ComponenteAulaView";
import ComentariosAula from "@/components/teoria/ComentariosAula";
import MarcaCarregando from "@/components/ui/MarcaCarregando";

// Contexto AUXILIAR vindo da URL — nunca a identidade da missão a partir
// desta etapa. Pode ser null (ex.: URL só com ?missao=<uuid>, sem
// materia/origem=cronograma) sem que isso invalide a missão: só significa
// que não há nada pra comparar/avisar sobre divergência, e quantidade cai
// no fallback 10.
type ContextoAuxiliar = {
  materiaId: number;
  assuntoId: number | null;
  cursoMateriaId: number | null;
  conteudoId: number | null;
  quantidade: number;
  missionId: string | null;
  refazer: boolean;
};

// Reflete exatamente o SELECT explícito feito em public.missoes — sem
// select *, só as colunas realmente usadas nesta tela.
type Missao = {
  id: string;
  matricula_id: string;
  conteudo_id: number;
  data_missao: string;
  status: string;
  progresso_teoria: Record<string, unknown>;
};

// Identidade acadêmica CANÔNICA da missão — derivada de missao.conteudo_id
// (curso_conteudos -> curso_materias -> materia_id/curso_materia_id;
// curso_conteudos.assunto_id direto), nunca dos parâmetros da URL.
type IdentidadeAcademica = {
  cursoMateriaId: number;
  materiaId: number;
  assuntoId: number | null;
};

type MateriaCursoAtivo = { materia_id: number; materia_nome: string; total_questoes: number | string };
type AssuntoCursoAtivo = { assunto_id: number; assunto_nome: string; total_questoes: number | string };

// Reflete exatamente o RETURNS TABLE de
// public.carregar_unidades_publicadas_da_missao(p_missao_id uuid) em
// supabase/unidades_pedagogicas_navegacao_rpc.sql — nada além das colunas
// realmente retornadas por essa RPC.
type FonteAula = {
  material_id: string;
  material_titulo: string;
  material_tipo: string;
  material_versao_id: string;
  numero_versao: number;
  titulo_versao: string | null;
  arquivo_path: string | null;
  checksum: string | null;
  vigente_desde: string | null;
  vigente_ate: string | null;
  ordem: number | null;
  observacao: string | null;
};

// aula_versoes.estrutura (teoria_versionada.sql) só garante, a nível de
// banco, "é um objeto JSON" — nenhum schema interno é imposto. A única
// convenção documentada (comentário em teoria_versionada.sql, não validada
// pelo banco) é: estrutura = { componentes: [...] }, cada componente com um
// campo `tipo` dentre diagnostico/conceito/recall/questao_resolvida/
// resumo_visual, já na ordem de apresentação. ComponenteAula (o tipo em si)
// vem de components/teoria/ComponenteAulaView — mesmo shape usado pelo
// renderer visual, para não haver dois formatos divergentes.
type EstruturaAula = {
  componentes?: unknown;
  [chave: string]: unknown;
};

type AulaPublicada = {
  missao_id: string;
  conteudo_id: number;
  missao_status: string;
  unidade_pedagogica_id: string;
  unidade_titulo: string;
  unidade_ordem: number;
  aula_id: string;
  aula_titulo: string;
  aula_versao_id: string;
  numero_versao: number;
  publicado_em: string;
  estrutura: EstruturaAula;
  fontes: FonteAula[];
};

type EstadoAula = "carregando" | "erro" | "indisponivel" | "disponivel";

type ResultadoConclusaoUnidade = {
  missao_id: string;
  status: string;
  unidade_pedagogica_id: string;
  aula_versao_id: string;
  total_unidades: number;
  unidades_concluidas: number;
  teoria_concluida: boolean;
  progresso_teoria: Record<string, unknown>;
};

// estrutura.componentes não tem nenhuma garantia de formato a nível de
// banco (só estrutura em si é validada como objeto JSON) — nem de ser
// array, nem de cada item ter o formato de ComponenteAula. A apresentação
// visual em si (títulos, negrito, ícones, BIZU DE PROVA etc.) vive em
// components/teoria/ComponenteAulaView — este arquivo só carrega/filtra os
// dados, nunca decide como desenhá-los.
function ehComponenteAula(valor: unknown): valor is ComponenteAula {
  return (
    typeof valor === "object" &&
    valor !== null &&
    !Array.isArray(valor) &&
    typeof (valor as Record<string, unknown>).tipo === "string"
  );
}

// Nunca chamar .map direto sobre o valor cru: filtra tanto "não é array"
// quanto "item individual não tem o formato mínimo esperado" antes de
// qualquer item chegar em ComponenteAulaView.
function obterComponentesAula(estrutura: EstruturaAula): ComponenteAula[] {
  if (!Array.isArray(estrutura?.componentes)) return [];
  return estrutura.componentes.filter(ehComponenteAula);
}

function obterIdsUnidadesConcluidas(
  progresso: Record<string, unknown>,
  unidadesAtuais: AulaPublicada[],
): string[] {
  if (progresso?.schema_version !== 2 || !Array.isArray(progresso?.unidades_concluidas)) return [];

  return progresso.unidades_concluidas.flatMap((item) => {
    if (
      typeof item === "object" &&
      item !== null &&
      typeof (item as Record<string, unknown>).unidade_pedagogica_id === "string" &&
      typeof (item as Record<string, unknown>).aula_versao_id === "string"
    ) {
      const registro = item as Record<string, string>;
      const aindaEhVersaoAtual = unidadesAtuais.some(
        (unidade) =>
          unidade.unidade_pedagogica_id === registro.unidade_pedagogica_id &&
          unidade.aula_versao_id === registro.aula_versao_id,
      );
      return aindaEhVersaoAtual ? [registro.unidade_pedagogica_id] : [];
    }
    return [];
  });
}

export default function Teoria() {
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [missao, setMissao] = useState<Missao | null>(null);
  const [identidade, setIdentidade] = useState<IdentidadeAcademica | null>(null);
  const [quantidade, setQuantidade] = useState(10);
  const [refazer, setRefazer] = useState(false);
  const [materiaNome, setMateriaNome] = useState("");
  const [assuntoNome, setAssuntoNome] = useState("");
  const [estadoAula, setEstadoAula] = useState<EstadoAula>("carregando");
  const [unidadesPublicadas, setUnidadesPublicadas] = useState<AulaPublicada[]>([]);
  const [indiceUnidade, setIndiceUnidade] = useState(0);
  const [unidadesConcluidas, setUnidadesConcluidas] = useState<string[]>([]);
  const [salvandoProgresso, setSalvandoProgresso] = useState(false);
  const [mensagemProgresso, setMensagemProgresso] = useState("");

  useEffect(() => {
    async function protegerPagina() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      // missionId é lido ISOLADAMENTE — não depende de origem=cronograma nem
      // de materia estarem presentes/válidos na URL. lerMissaoCronograma
      // continua existindo só para contexto AUXILIAR (quantidade e
      // comparação/aviso de divergência) — nunca mais como porta de entrada
      // obrigatória para abrir uma missão.
      const missionId = lerMissionId(window.location.search);
      const contextoAuxiliar = lerMissaoCronograma(window.location.search) as ContextoAuxiliar | null;
      setRefazer(Boolean(contextoAuxiliar?.refazer));

      if (!missionId) {
        if (!contextoAuxiliar) {
          // Nem mission_id nem o formato antigo de link do cronograma —
          // isto não é uma visita a uma missão. Mesmo fallback de sempre.
          window.location.replace("/questoes");
          return;
        }
        // Tem formato antigo (origem=cronograma&materia=...) mas sem
        // mission_id: o cronograma sempre cria a missão antes de linkar
        // pra /teoria a partir desta etapa, então isso é um link
        // desatualizado/anômalo — não confia nos dados antigos da URL.
        setErro("Não foi possível identificar sua missão. Volte ao cronograma e inicie a missão novamente.");
        setCarregando(false);
        return;
      }

      if (contextoAuxiliar) setQuantidade(contextoAuxiliar.quantidade);

      // A partir de missionId válido, consultar public.missoes. Se a
      // consulta falhar, ou se a missão não existir/não for visível pelo
      // RLS (o RLS de public.missoes só deixa o dono da matrícula enxergar
      // a própria missão), a página NÃO segue como se fosse uma missão
      // válida: mostra erro controlado.
      const { data: missaoCarregada, error: erroMissao } = await supabase
        .from("missoes")
        .select("id, matricula_id, conteudo_id, data_missao, status, progresso_teoria")
        .eq("id", missionId)
        .maybeSingle();

      if (erroMissao) {
        console.error("Falha ao carregar a missão:", {
          message: erroMissao.message,
          code: erroMissao.code,
          details: erroMissao.details,
          hint: erroMissao.hint,
        });
        setErro("Não foi possível carregar sua missão agora. Tente novamente.");
        setCarregando(false);
        return;
      }

      if (!missaoCarregada) {
        // Não dá pra distinguir, do lado do cliente, "não existe" de "existe
        // mas o RLS não deixa este usuário ver" — e não precisa: o
        // tratamento é o mesmo nos dois casos.
        setErro("Esta missão não foi encontrada ou não pertence a você.");
        setCarregando(false);
        return;
      }

      // A missão vinda do banco é a fonte de verdade para conteudo_id (e
      // status) — nunca o que a URL disser, quando ela existir.
      if (
        contextoAuxiliar?.conteudoId &&
        contextoAuxiliar.conteudoId !== missaoCarregada.conteudo_id
      ) {
        console.warn(
          `[teoria] conteudo da URL (${contextoAuxiliar.conteudoId}) diverge de missoes.conteudo_id (${missaoCarregada.conteudo_id}) para a missão ${missaoCarregada.id}; usando o valor da missão.`,
        );
      }
      setMissao(missaoCarregada as Missao);

      // Identidade acadêmica (matéria/assunto) também vem do conteúdo
      // canônico da missão, não dos parâmetros da URL. curso_conteudos já
      // tem RLS de leitura para aluno matriculado ativo ("Aluno matriculado
      // visualiza conteúdos do curso"); usamos o relacionamento embutido
      // para curso_materias (mesmo padrão de outras telas) para chegar em
      // curso_materia_id/materia_id sem select *.
      const { data: conteudo, error: erroConteudo } = await supabase
        .from("curso_conteudos")
        .select("assunto_id, curso_materia_id, curso_materias(materia_id)")
        .eq("id", missaoCarregada.conteudo_id)
        .maybeSingle();

      const cursoMateria = (
        conteudo as { curso_materias: { materia_id: number | null } | null } | null
      )?.curso_materias;

      if (erroConteudo || !conteudo || !cursoMateria?.materia_id) {
        // Sem curso_materia_id/materia_id resolvidos não há como montar uma
        // identidade acadêmica confiável — não inventa nem cai de volta pros
        // valores da URL. Mostra erro controlado.
        if (erroConteudo) {
          console.error("Falha ao resolver a identidade acadêmica da missão:", {
            message: erroConteudo.message,
            code: erroConteudo.code,
            details: erroConteudo.details,
            hint: erroConteudo.hint,
          });
        }
        setErro("Não foi possível carregar a matéria/assunto desta missão. Tente novamente.");
        setCarregando(false);
        return;
      }

      const identidadeCanonica: IdentidadeAcademica = {
        cursoMateriaId: conteudo.curso_materia_id,
        materiaId: cursoMateria.materia_id,
        assuntoId: conteudo.assunto_id ?? null,
      };
      setIdentidade(identidadeCanonica);

      if (
        contextoAuxiliar &&
        ((contextoAuxiliar.materiaId && contextoAuxiliar.materiaId !== identidadeCanonica.materiaId) ||
          (contextoAuxiliar.assuntoId && contextoAuxiliar.assuntoId !== identidadeCanonica.assuntoId) ||
          (contextoAuxiliar.cursoMateriaId && contextoAuxiliar.cursoMateriaId !== identidadeCanonica.cursoMateriaId))
      ) {
        console.warn(
          `[teoria] materia/assunto/cursoMateria da URL divergem da identidade canônica da missão ${missaoCarregada.id}; usando os valores derivados de conteudo_id.`,
        );
      }

      // Nomes de exibição: mesmas RPCs já usadas por /questoes para essa
      // mesma finalidade (materias_do_curso_ativo/assuntos_do_curso_ativo,
      // já comprovadas acessíveis a um aluno comum via SECURITY DEFINER) —
      // só que agora chamadas com o materiaId/assuntoId CANÔNICOS.
      const { data: materias } = await supabase.rpc("materias_do_curso_ativo");
      const materia = (materias as MateriaCursoAtivo[] | null)?.find(
        (item) => item.materia_id === identidadeCanonica.materiaId,
      );
      setMateriaNome(materia?.materia_nome ?? "");

      if (identidadeCanonica.assuntoId) {
        const { data: assuntos } = await supabase.rpc("assuntos_do_curso_ativo", {
          p_materia_id: identidadeCanonica.materiaId,
        });
        const assunto = (assuntos as AssuntoCursoAtivo[] | null)?.find(
          (item) => item.assunto_id === identidadeCanonica.assuntoId,
        );
        setAssuntoNome(assunto?.assunto_nome ?? "");
      }

      // Única porta de leitura da aula: a RPC, nunca SELECT direto em
      // aulas/aula_versoes/aula_versao_fontes/materiais/material_versoes —
      // essas tabelas não têm SELECT direto concedido a authenticated de
      // propósito (Fase 2E/2F). Só o id da missão é enviado; usuario_id,
      // matricula_id, conteudo_id, aula_id e aula_versao_id são todos
      // derivados no servidor, dentro da própria RPC.
      const { data: aulaCarregada, error: erroAula } = await supabase.rpc(
        "carregar_unidades_publicadas_da_missao",
        { p_missao_id: missaoCarregada.id },
      );

      if (erroAula) {
        // Erro da RPC (rede, banco fora do ar, etc.) não é a mesma coisa
        // que "missão inválida" — a página continua aberta (cabeçalho,
        // botão para as questões), só a seção da aula mostra erro
        // controlado. Detalhe interno só no console, nunca na tela.
        console.error("Falha ao carregar a aula da missão:", {
          message: erroAula.message,
          code: erroAula.code,
          details: erroAula.details,
          hint: erroAula.hint,
        });
        setEstadoAula("erro");
      } else {
        // A RPC devolve uma linha por unidade ativa que tenha versão
        // publicada, já ordenada pela ordem pedagógica. Zero linhas não é
        // erro: significa que esta missão ainda não tem aula publicada.
        const linhas = (aulaCarregada as AulaPublicada[] | null) ?? [];
        if (linhas.length > 0) {
          setUnidadesPublicadas(linhas);
          setUnidadesConcluidas(obterIdsUnidadesConcluidas(missaoCarregada.progresso_teoria, linhas));
          setEstadoAula("disponivel");
        } else {
          setEstadoAula("indisponivel");
        }
      }

      setCarregando(false);
    }
    protegerPagina();
  }, []);

  const selecionarUnidade = (novoIndice: number) => {
    if (novoIndice < 0 || novoIndice >= unidadesPublicadas.length) return;
    setMensagemProgresso("");
    setIndiceUnidade(novoIndice);
    window.requestAnimationFrame(() => {
      document.getElementById("conteudo-unidade-atual")?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  };

  const concluirUnidade = async () => {
    const aulaAtual = unidadesPublicadas[indiceUnidade];
    if (!aulaAtual || !missao || !identidade || salvandoProgresso) return;

    setMensagemProgresso("");
    setSalvandoProgresso(true);

    let idsConcluidos = unidadesConcluidas;
    let statusMissao = missao.status;
    let progressoMissao = missao.progresso_teoria;

    if (refazer && !unidadesConcluidas.includes(aulaAtual.unidade_pedagogica_id)) {
      idsConcluidos = [...unidadesConcluidas, aulaAtual.unidade_pedagogica_id];
      setUnidadesConcluidas(idsConcluidos);
    } else if (!unidadesConcluidas.includes(aulaAtual.unidade_pedagogica_id)) {
      const supabase = createClient();
      const { data, error } = await supabase.rpc("registrar_unidade_teoria_concluida", {
        p_missao_id: missao.id,
        p_aula_versao_id: aulaAtual.aula_versao_id,
      });

      if (error) {
        console.error("Falha ao registrar conclusão da unidade:", {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint,
        });
        setMensagemProgresso("Não foi possível salvar seu progresso agora. Tente novamente.");
        setSalvandoProgresso(false);
        return;
      }

      const resultado = ((data as ResultadoConclusaoUnidade[] | null) ?? [])[0];
      if (!resultado) {
        setMensagemProgresso("Não foi possível confirmar a conclusão desta unidade.");
        setSalvandoProgresso(false);
        return;
      }

      idsConcluidos = obterIdsUnidadesConcluidas(resultado.progresso_teoria, unidadesPublicadas);
      statusMissao = resultado.status;
      progressoMissao = resultado.progresso_teoria;
      setUnidadesConcluidas(idsConcluidos);
      setMissao((atual) => atual ? { ...atual, status: statusMissao, progresso_teoria: progressoMissao } : atual);
    }

    setSalvandoProgresso(false);

    if (indiceUnidade < unidadesPublicadas.length - 1) {
      selecionarUnidade(indiceUnidade + 1);
      return;
    }

    window.location.assign(montarLinkMissao({
      cursoMateriaId: identidade.cursoMateriaId,
      conteudoId: missao.conteudo_id,
      materiaId: identidade.materiaId,
      assuntoId: identidade.assuntoId ?? undefined,
      quantidade,
      missionId: missao.id,
      refazer,
    }));
  };

  if (carregando) return <main className="dashboard-loading"><MarcaCarregando texto="Preparando a teoria de hoje..." /></main>;

  if (erro || !missao || !identidade) {
    return (
      <main className="method-page">
        <header>
          <p className="dashboard-label">MISSÃO DIÁRIA · TEORIA</p>
          <h1>Não foi possível abrir esta missão</h1>
        </header>
        <section>
          <p role="alert">{erro || "Não foi possível carregar sua missão."}</p>
        </section>
        <Link className="answer-submit" href="/cronograma">Voltar ao cronograma</Link>
      </main>
    );
  }

  return (
    <main className="method-page">
      <header>
        <p className="dashboard-label">MISSÃO DIÁRIA · TEORIA</p>
        <h1>{materiaNome || "Teoria de hoje"}</h1>
        {assuntoNome && <span>{assuntoNome}</span>}
      </header>

      <section>
        <p role="status">Missão iniciada.</p>
        <p>
          Revise a teoria de {assuntoNome || materiaNome || "hoje"} antes de praticar. Quando terminar, siga
          para as questões desta mesma missão.
        </p>

        {estadoAula === "carregando" && <p>Carregando a aula desta missão...</p>}

        {estadoAula === "erro" && (
          <p role="alert">Não foi possível carregar a aula desta missão agora. Tente novamente.</p>
        )}

        {estadoAula === "indisponivel" && (
          <div>
            <h2>Aula ainda não disponível</h2>
            <p>O conteúdo teórico desta missão ainda não foi publicado. Você já pode seguir para as questões.</p>
          </div>
        )}

        {estadoAula === "disponivel" && unidadesPublicadas.length > 0 && (() => {
          const aula = unidadesPublicadas[indiceUnidade] ?? unidadesPublicadas[0];
          const componentes = obterComponentesAula(aula.estrutura);
          // Aula publicada existe de fato — "sem componentes válidos" não é
          // o mesmo caso que "sem aula publicada" e não pode reaproveitar a
          // mensagem de "Aula ainda não disponível".
          if (componentes.length === 0) {
            return <p>Esta aula ainda não possui conteúdo para exibição.</p>;
          }
          return (
            <div className="teoria-unidades">
              <nav className="teoria-unidades-navegacao" aria-label="Unidades desta aula">
                <div className="teoria-unidades-cabecalho">
                  <div>
                    <p>TRILHA DA AULA</p>
                    <h2>{aula.aula_titulo}</h2>
                  </div>
                  <span>{unidadesConcluidas.length} de {unidadesPublicadas.length} concluídas</span>
                </div>
                <div className="teoria-unidades-lista" role="tablist" aria-label="Escolha uma unidade">
                  {unidadesPublicadas.map((unidade, indice) => {
                    const concluida = unidadesConcluidas.includes(unidade.unidade_pedagogica_id);
                    return (
                      <button
                        key={unidade.unidade_pedagogica_id}
                        type="button"
                        role="tab"
                        aria-selected={indice === indiceUnidade}
                        aria-controls="conteudo-unidade-atual"
                        className={`${indice === indiceUnidade ? "ativa" : ""}${concluida ? " concluida" : ""}`.trim()}
                        onClick={() => selecionarUnidade(indice)}
                      >
                        <b aria-hidden="true">{concluida ? "✓" : unidade.unidade_ordem}</b>
                        <span>{unidade.unidade_titulo}</span>
                        <em>{concluida ? "Concluída" : indice === indiceUnidade ? "Em andamento" : "Pendente"}</em>
                      </button>
                    );
                  })}
                </div>
              </nav>

              <div
                id="conteudo-unidade-atual"
                className="teoria-aula"
                role="tabpanel"
                aria-label={`Unidade ${aula.unidade_ordem}: ${aula.unidade_titulo}`}
              >
                <div className="teoria-unidade-titulo">
                  <p>UNIDADE {aula.unidade_ordem}</p>
                  <h2>{aula.unidade_titulo}</h2>
                </div>
                {componentes.map((componente, indice) => (
                  <ComponenteAulaView key={componente?.tipo ? `${componente.tipo}-${indice}` : indice} componente={componente} />
                ))}
                <ComentariosAula aulaId={aula.aula_id} />

                <div className="teoria-unidades-acoes" aria-label="Navegação entre unidades">
                  <button
                    type="button"
                    onClick={() => selecionarUnidade(indiceUnidade - 1)}
                    disabled={indiceUnidade === 0}
                  >
                    Unidade anterior
                  </button>
                  <button
                    type="button"
                    className="principal"
                    onClick={concluirUnidade}
                    disabled={salvandoProgresso}
                  >
                    {salvandoProgresso
                      ? "Salvando progresso..."
                      : indiceUnidade === unidadesPublicadas.length - 1
                        ? unidadesConcluidas.includes(aula.unidade_pedagogica_id)
                          ? "Ir para as questões"
                          : "Concluir teoria e ir para as questões"
                        : unidadesConcluidas.includes(aula.unidade_pedagogica_id)
                          ? "Próxima unidade"
                          : "Concluir unidade e avançar"}
                  </button>
                </div>
                {mensagemProgresso && <p className="teoria-progresso-mensagem" role="alert">{mensagemProgresso}</p>}
              </div>
            </div>
          );
        })()}
      </section>

      {estadoAula !== "disponivel" && (
        <Link
          className="answer-submit"
          href={montarLinkMissao({
            cursoMateriaId: identidade.cursoMateriaId,
            conteudoId: missao.conteudo_id,
            materiaId: identidade.materiaId,
            assuntoId: identidade.assuntoId ?? undefined,
            quantidade,
            missionId: missao.id,
            refazer,
          })}
        >
          Ir para as questões
        </Link>
      )}
    </main>
  );
}
