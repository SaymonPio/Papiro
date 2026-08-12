"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { lerMissaoCronograma, lerMissionId, montarLinkMissao } from "@/utils/missao-cronograma.mjs";
import { createClient } from "@/utils/supabase/client";

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

export default function Teoria() {
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState("");
  const [missao, setMissao] = useState<Missao | null>(null);
  const [identidade, setIdentidade] = useState<IdentidadeAcademica | null>(null);
  const [quantidade, setQuantidade] = useState(10);
  const [materiaNome, setMateriaNome] = useState("");
  const [assuntoNome, setAssuntoNome] = useState("");

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

      setCarregando(false);
    }
    protegerPagina();
  }, []);

  if (carregando) return <main className="dashboard-loading"><p>Preparando a teoria de hoje...</p></main>;

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
        <p><small>Conteúdo teórico completo chega em uma fase futura — esta tela ainda é um placeholder.</small></p>
      </section>

      <Link
        className="answer-submit"
        href={montarLinkMissao({
          cursoMateriaId: identidade.cursoMateriaId,
          conteudoId: missao.conteudo_id,
          materiaId: identidade.materiaId,
          assuntoId: identidade.assuntoId ?? undefined,
          quantidade,
          missionId: missao.id,
        })}
      >
        Ir para as questões
      </Link>
    </main>
  );
}
