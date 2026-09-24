"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import AulaImpressao from "@/components/teoria/AulaImpressao";
import { prepararAulaImpressao, type AulaImpressaoModelo } from "@/components/teoria/prepararAulaImpressao";
import { useArtesQuadrinho } from "@/components/teoria/useArtesQuadrinho";
import { chaveArte } from "@/components/teoria/arteQuadrinho";
import MarcaCarregando from "@/components/ui/MarcaCarregando";

// Q12.21 — as MESMAS artes aprovadas (assinar-quadrinho-assets, reaproveitada sem mudança: mesmo hook, mesmo
// modo/aulaVersaoId/missaoId já usados pela tela) também aparecem no PDF. window.print() continua manual; o
// botão só habilita quando PRINT_READY (dados prontos + consulta inicial de arte concluída + imagens atuais
// resolvidas OU timeout de segurança) — nunca trava a impressão, nunca dispara sozinho.
const PRINT_IMAGES_TIMEOUT_MS = 8000;
const FONTS_READY_TIMEOUT_MS = 1500;

// Versão para impressão/PDF de UMA aula publicada — derivada da MESMA
// aula_versoes.estrutura, nunca um texto paralelo (ver
// components/teoria/prepararAulaImpressao.ts e AulaImpressao.tsx).
//
// Segurança: nenhum endpoint novo, nenhuma RPC nova. Reaproveita
// EXATAMENTE os mesmos dois caminhos autorizados já usados pelo resto do
// produto:
//   - aluno: public.carregar_unidades_publicadas_da_missao(p_missao_id) —
//     a mesma RPC que app/teoria/page.tsx já usa; ela mesma resolve
//     auth.uid() -> matrícula ativa -> aula publicada no servidor, nunca
//     aceita conteudo/unidade "soltos" vindos do cliente. Só devolve
//     linhas de unidades com aula_versoes.status = 'publicada' — nunca um
//     rascunho, mesmo que o cliente tente forçar um id de rascunho na URL.
//   - admin: public.carregar_aula_rascunho_admin(p_aula_versao_id), atrás
//     de eh_admin() (mesmo gate de app/admin/aulas/page.tsx), para
//     inspecionar a impressão de QUALQUER versão (inclusive rascunho)
//     antes de publicar. Rota opcional, só usada por
//     app/admin/aulas/preview/page.tsx. Matéria/curso da capa, no modo
//     admin, vêm de public.listar_geracoes_conteudo_admin(p_conteudo_id)
//     — a MESMA RPC que app/admin/aulas/preview/page.tsx já usa para
//     montar "PERCURSO PAPIRO" — nunca de texto na query string: a URL só
//     carrega o id de conteúdo (navegação), e só é aceito o contexto de
//     uma geração cujo aula_versao_id bate com a versão sendo impressa.
// Genérico: nenhuma linha aqui sabe o nome de nenhuma aula/unidade/
// conteúdo/curso específico.

type EstadoImpressao = "carregando" | "erro" | "indisponivel" | "pronto";

type LinhaMissao = {
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
  estrutura: { componentes?: unknown };
  fontes: unknown;
};

type LinhaAdmin = {
  aula_id: string;
  aula_titulo: string;
  aula_versao_id: string;
  numero_versao: number;
  status: string;
  estrutura: { componentes?: unknown };
  publicado_em: string | null;
  fontes: unknown;
};

// Linha de public.listar_geracoes_conteudo_admin — mesma RPC já usada por
// app/admin/aulas/preview/page.tsx para montar o cabeçalho "PERCURSO
// PAPIRO". "contexto" é o snapshot gravado em supabase/functions/gerar-
// aula/index.ts no momento da geração (materia/concurso como texto
// pronto para exibir).
type GeracaoAdmin = {
  aula_versao_id: string | null;
  contexto: { materia?: string; concurso?: string | null } | null;
};

export default function ImprimirAula() {
  const [estado, setEstado] = useState<EstadoImpressao>("carregando");
  const [modelo, setModelo] = useState<AulaImpressaoModelo | null>(null);
  const [mensagemErro, setMensagemErro] = useState("");
  // Contexto de arte, resolvido junto com os dados da aula (mesmos modo/aulaVersaoId/missaoId que a tela já usa).
  const [contextoArte, setContextoArte] = useState<{ modo: "admin" | "aluno"; aulaVersaoId: string | null; missaoId: string | null }>({
    modo: "aluno",
    aulaVersaoId: null,
    missaoId: null,
  });

  useEffect(() => {
    async function carregar() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      const params = new URLSearchParams(window.location.search);
      const missaoId = params.get("missao");
      const unidadeId = params.get("unidade");
      const aulaVersaoIdAdmin = params.get("aula_versao_id");
      const modoAdmin = params.get("admin") === "1";
      // A URL só transporta o ID de conteúdo (navegação/resolução) — NUNCA
      // texto de matéria/curso: um admin poderia editar a URL à mão e
      // produzir um PDF com metadados falsos na capa (conteúdo real, texto
      // inventado). materiaNome/cursoNome do modo admin são resolvidos
      // abaixo a partir de uma fonte canônica (listar_geracoes_conteudo_
      // admin), nunca confiados diretamente ao que vier em params.get(...).
      const conteudoIdAdminRaw = params.get("conteudo_id");
      const conteudoIdAdmin = conteudoIdAdminRaw && /^\d+$/.test(conteudoIdAdminRaw) ? Number(conteudoIdAdminRaw) : null;

      // Modo admin (opcional): inspeção de QUALQUER versão, inclusive
      // rascunho, por trás de eh_admin() — nunca o caminho do aluno.
      if (modoAdmin && aulaVersaoIdAdmin) {
        const { data: souAdmin } = await supabase.rpc("eh_admin");
        if (!souAdmin) {
          setMensagemErro("Esta versão de impressão é restrita a administradores.");
          setEstado("erro");
          return;
        }
        const { data, error } = await supabase.rpc("carregar_aula_rascunho_admin", { p_aula_versao_id: aulaVersaoIdAdmin });
        if (error) {
          setMensagemErro("Não foi possível carregar esta aula para impressão.");
          setEstado("erro");
          return;
        }
        const linha = ((data as LinhaAdmin[] | null) ?? [])[0];
        if (!linha) { setEstado("indisponivel"); return; }

        // Matéria/curso do modo admin: resolvidos por uma fonte canônica
        // (mesma RPC autorizada que app/admin/aulas/preview/page.tsx já usa
        // para montar "PERCURSO PAPIRO"), nunca por texto vindo da URL.
        // Conferência de integridade: só aceita o contexto de uma geração
        // cujo aula_versao_id bate EXATAMENTE com a versão sendo impressa
        // — um conteudo_id qualquer (real, mas de outro assunto) na URL
        // nunca encontra correspondência aqui, então nunca produz uma
        // combinação falsa (conteúdo real + matéria/curso de outra aula).
        // Sem correspondência: capa segue sem esses dois campos opcionais,
        // nunca quebra a impressão.
        let materiaNome: string | null = null;
        let cursoNome: string | null = null;
        if (conteudoIdAdmin) {
          const { data: geracoes } = await supabase.rpc("listar_geracoes_conteudo_admin", { p_conteudo_id: conteudoIdAdmin });
          const geracaoCorrespondente = ((geracoes as GeracaoAdmin[] | null) ?? []).find(
            (g) => g.aula_versao_id === aulaVersaoIdAdmin && g.contexto,
          );
          materiaNome = geracaoCorrespondente?.contexto?.materia ?? null;
          cursoNome = geracaoCorrespondente?.contexto?.concurso ?? null;
        }

        setModelo(
          prepararAulaImpressao({
            materiaNome,
            unidadeTitulo: linha.aula_titulo,
            aulaTitulo: linha.aula_titulo,
            cursoNome,
            numeroVersao: linha.numero_versao,
            publicadoEm: linha.publicado_em,
            estrutura: linha.estrutura,
            fontes: linha.fontes,
          }),
        );
        // Mesmo aulaVersaoId já resolvido acima (aulaVersaoIdAdmin); modo admin não usa missaoId.
        setContextoArte({ modo: "admin", aulaVersaoId: aulaVersaoIdAdmin, missaoId: null });
        setEstado("pronto");
        return;
      }

      // Modo aluno (padrão): só aulas efetivamente publicadas, resolvidas
      // no servidor a partir da missão do próprio usuário autenticado.
      if (!missaoId) {
        setMensagemErro("Não foi possível identificar a aula a imprimir.");
        setEstado("erro");
        return;
      }

      const { data, error } = await supabase.rpc("carregar_unidades_publicadas_da_missao", { p_missao_id: missaoId });
      if (error) {
        setMensagemErro("Não foi possível carregar a aula desta missão agora.");
        setEstado("erro");
        return;
      }
      const linhas = (data as LinhaMissao[] | null) ?? [];
      const linha = unidadeId ? linhas.find((l) => l.unidade_pedagogica_id === unidadeId) : linhas[0];
      if (!linha) { setEstado("indisponivel"); return; }

      // Matéria/curso para a capa — mesma primeira etapa de leitura já
      // usada por app/teoria/page.tsx (SELECT direto em curso_conteudos,
      // permitido pela RLS "Aluno matriculado visualiza conteúdos do
      // curso"), seguida de duas leituras simples e diretas em vez de um
      // embed aninhado do PostgREST: curso_materias NÃO tem nenhuma
      // foreign key registrada no banco (confirmado via
      // information_schema.table_constraints), então um embed do tipo
      // "curso_materias(materias(nome), cursos(concurso))" não tem como o
      // PostgREST resolver automaticamente — a consulta falhava
      // silenciosamente (data vinha null, sem lançar exceção). Falha aqui
      // não impede a impressão — a capa só fica sem esses dois campos
      // opcionais, nunca quebra a página.
      let materiaNome: string | null = null;
      let cursoNome: string | null = null;
      const { data: conteudo } = await supabase
        .from("curso_conteudos")
        .select("curso_materia_id")
        .eq("id", linha.conteudo_id)
        .maybeSingle();
      const cursoMateriaId = (conteudo as { curso_materia_id: number } | null)?.curso_materia_id;
      if (cursoMateriaId) {
        const { data: cursoMateria } = await supabase
          .from("curso_materias")
          .select("materia_id, curso_id")
          .eq("id", cursoMateriaId)
          .maybeSingle();
        const materiaId = (cursoMateria as { materia_id: number; curso_id: string } | null)?.materia_id;
        const cursoId = (cursoMateria as { materia_id: number; curso_id: string } | null)?.curso_id;
        if (materiaId) {
          const { data: materia } = await supabase.from("materias").select("nome").eq("id", materiaId).maybeSingle();
          materiaNome = (materia as { nome: string } | null)?.nome ?? null;
        }
        if (cursoId) {
          const { data: curso } = await supabase.from("cursos").select("concurso").eq("id", cursoId).maybeSingle();
          cursoNome = (curso as { concurso: string | null } | null)?.concurso ?? null;
        }
      }

      setModelo(
        prepararAulaImpressao({
          materiaNome,
          unidadeTitulo: linha.unidade_titulo,
          aulaTitulo: linha.aula_titulo,
          cursoNome,
          numeroVersao: linha.numero_versao,
          publicadoEm: linha.publicado_em,
          estrutura: linha.estrutura,
          fontes: linha.fontes,
        }),
      );
      // Mesmo missaoId já exigido acima; aulaVersaoId é o da própria unidade publicada resolvida (linha.aula_versao_id).
      setContextoArte({ modo: "aluno", aulaVersaoId: linha.aula_versao_id, missaoId });
      setEstado("pronto");
    }
    carregar();
  }, []);

  // Mesma Edge/hook do renderer web (assinar-quadrinho-assets), reaproveitados sem nenhuma lógica nova de
  // autenticação. Hook chamado incondicionalmente (regra dos hooks) — antes de estado==="pronto" o contexto
  // ainda está vazio (aulaVersaoId null) e o hook simplesmente não busca nada.
  // aoErroArte (renovação por erro de imagem) não é usado aqui de propósito: no PDF um onError já conta como
  // resolvido (libera a impressão) e não precisa disparar nova chamada à Edge — isso é um comportamento da
  // tela interativa (ComponenteAulaView.tsx), não deste fluxo de impressão.
  const { artes, consultaConcluida } = useArtesQuadrinho(contextoArte);

  // Assinaturas (chave + url) das imagens que EXISTEM agora para os quadros deste modelo — só essas precisam
  // ser aguardadas antes de liberar a impressão. Quadro sem arte nunca entra aqui (nada a esperar por ele).
  const assinaturasEsperadas = useMemo(() => {
    const conjunto = new Set<string>();
    if (!modelo) return conjunto;
    for (const componente of modelo.componentes) {
      if (componente.tipo !== "quadrinho_didatico" || !componente.id) continue;
      for (const quadro of componente.quadros) {
        const arte = artes[chaveArte(componente.id, quadro.indiceOriginal)];
        if (arte) conjunto.add(`${chaveArte(componente.id, quadro.indiceOriginal)}|${arte.url}`);
      }
    }
    return conjunto;
  }, [modelo, artes]);
  const assinaturasEsperadasChave = useMemo(() => [...assinaturasEsperadas].sort().join("\n"), [assinaturasEsperadas]);

  const [resolvidas, setResolvidas] = useState<Set<string>>(new Set());
  // Conjunto de artes mudou (renovação de URL, ou aula trocou): descarta resoluções que não correspondem mais
  // à URL atual — mas sem zerar à toa quando o conteúdo do conjunto não mudou de fato.
  useEffect(() => {
    setResolvidas((atual) => {
      const filtradas = new Set([...atual].filter((assinatura) => assinaturasEsperadas.has(assinatura)));
      return filtradas.size === atual.size ? atual : filtradas;
    });
  }, [assinaturasEsperadasChave, assinaturasEsperadas]);

  // Callback tardio de uma URL antiga carrega uma assinatura que já não bate com nenhuma entrada esperada
  // atual (a assinatura embute a própria URL) — inofensivo, nunca "resolve" a URL nova por engano.
  const aoResolverImagem = useCallback((assinatura: string) => {
    setResolvidas((atual) => (atual.has(assinatura) ? atual : new Set(atual).add(assinatura)));
  }, []);

  const todasResolvidas = [...assinaturasEsperadas].every((assinatura) => resolvidas.has(assinatura));

  // Timeout de segurança: só corre enquanto houver imagem pendente. Cancelado (via cleanup) sempre que tudo
  // resolver, o conjunto de assinaturas mudar, ou a página desmontar — nunca dispara chamada nova à Edge.
  const [timeoutVencido, setTimeoutVencido] = useState(false);
  useEffect(() => {
    if (assinaturasEsperadas.size === 0 || todasResolvidas) {
      setTimeoutVencido(false);
      return;
    }
    const temporizador = setTimeout(() => setTimeoutVencido(true), PRINT_IMAGES_TIMEOUT_MS);
    return () => clearTimeout(temporizador);
  }, [assinaturasEsperadasChave, todasResolvidas, assinaturasEsperadas]);

  // A. dados prontos; B. consulta inicial de arte concluída; C. nada para esperar, ou tudo resolvido, ou timeout.
  const printReady = estado === "pronto" && consultaConcluida && (assinaturasEsperadas.size === 0 || todasResolvidas || timeoutVencido);

  const aoClicarImprimir = useCallback(async () => {
    // Espera curta e opcional pelas fontes — nunca bloqueia a impressão se o navegador não suportar isso.
    if (typeof document !== "undefined" && document.fonts?.ready) {
      await Promise.race([
        document.fonts.ready,
        new Promise((resolve) => setTimeout(resolve, FONTS_READY_TIMEOUT_MS)),
      ]);
    }
    window.print();
  }, []);

  if (estado === "carregando") {
    return <main className="dashboard-loading"><MarcaCarregando texto="Preparando a versão para impressão..." /></main>;
  }

  if (estado === "erro" || estado === "indisponivel") {
    return (
      <main className="method-page">
        <header>
          <p className="dashboard-label">VERSÃO PARA IMPRESSÃO</p>
          <h1>Não foi possível abrir esta impressão</h1>
        </header>
        <p role="alert">{mensagemErro || "Esta aula ainda não está disponível para impressão."}</p>
        <Link className="answer-submit" href="/teoria">Voltar</Link>
      </main>
    );
  }

  return (
    <>
      <div className="impressao-barra-acoes no-imprimir">
        <Link href="/teoria">Voltar</Link>
        <button type="button" className="answer-submit" onClick={aoClicarImprimir} disabled={!printReady}>
          {printReady ? "Imprimir / Salvar como PDF" : "Preparando impressão…"}
        </button>
      </div>
      {/* window.print() não consegue desligar "Cabeçalhos e rodapés" do
          Chrome/Firefox (data/hora, título da aba, URL, numeração) — não é
          um hack que resolva isso a partir da página. Instrução só na
          tela, nunca na impressão (classe no-imprimir some em @media print). */}
      <p className="impressao-instrucao no-imprimir">
        Para gerar um PDF limpo, desative &quot;Cabeçalhos e rodapés&quot; nas opções de impressão do navegador antes de salvar.
      </p>
      {modelo && <AulaImpressao modelo={modelo} artes={artes} aoResolverImagem={aoResolverImagem} />}
    </>
  );
}
