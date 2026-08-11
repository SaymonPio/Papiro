"use client";

import Link from "next/link";
import { useEffect, useMemo, useState, type ChangeEvent } from "react";
import Papa from "papaparse";
import { temResiduoImportacao } from "@/utils/higiene-questoes.mjs";
import { createClient } from "@/utils/supabase/client";

type Curso = { id: string; concurso: string | null; cargo: string | null };

type LinhaCsv = {
  materia: string;
  assunto: string;
  banca: string;
  concurso: string;
  ano: string;
  enunciado: string;
  alternativa_a: string;
  alternativa_b: string;
  alternativa_c: string;
  alternativa_d: string;
  alternativa_e: string;
  gabarito: string;
  explicacao: string;
  fonte: string;
};

type StatusLinha = "ok" | "alerta" | "erro";

type ResultadoDryRun = {
  linha: number;
  status: StatusLinha;
  materia_id: number | null;
  assunto_id: number | null;
  duplicata_curso: boolean;
  duplicata_banco_global: boolean;
  mensagens: string[];
};

type ResultadoImportacao = { linha: number; questao_id: number };

const CABECALHO_ESPERADO = [
  "materia", "assunto", "banca", "concurso", "ano", "enunciado",
  "alternativa_a", "alternativa_b", "alternativa_c", "alternativa_d", "alternativa_e",
  "gabarito", "explicacao", "fonte",
];

export default function ImportarQuestoes() {
  const [verificando, setVerificando] = useState(true);
  const [admin, setAdmin] = useState(false);

  const [cursos, setCursos] = useState<Curso[]>([]);
  const [cursoSelecionado, setCursoSelecionado] = useState("");

  const [nomeArquivo, setNomeArquivo] = useState("");
  const [linhas, setLinhas] = useState<LinhaCsv[]>([]);
  const [erroArquivo, setErroArquivo] = useState("");

  const [resultadoDryRun, setResultadoDryRun] = useState<ResultadoDryRun[] | null>(null);
  const [selecionadas, setSelecionadas] = useState<Set<number>>(new Set());
  const [validando, setValidando] = useState(false);
  const [mensagemValidacao, setMensagemValidacao] = useState("");

  const [importando, setImportando] = useState(false);
  const [mensagemImportacao, setMensagemImportacao] = useState("");
  const [resultadoImportacao, setResultadoImportacao] = useState<ResultadoImportacao[] | null>(null);

  useEffect(() => {
    async function verificarAcesso() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }
      const { data } = await supabase.rpc("eh_admin");
      setAdmin(Boolean(data));
      setVerificando(false);
    }
    verificarAcesso();
  }, []);

  useEffect(() => {
    if (!admin) return;
    async function carregarCursos() {
      const { data } = await createClient().from("cursos").select("id, concurso, cargo").order("concurso");
      setCursos((data as Curso[] | null) ?? []);
    }
    carregarCursos();
  }, [admin]);

  const resultadoPorLinha = useMemo(() => {
    const mapa = new Map<number, ResultadoDryRun>();
    (resultadoDryRun ?? []).forEach((item) => mapa.set(item.linha, item));
    return mapa;
  }, [resultadoDryRun]);

  function selecionarArquivo(evento: ChangeEvent<HTMLInputElement>) {
    const arquivo = evento.target.files?.[0];
    setResultadoDryRun(null);
    setResultadoImportacao(null);
    setMensagemValidacao("");
    setMensagemImportacao("");
    setErroArquivo("");
    setLinhas([]);
    if (!arquivo) { setNomeArquivo(""); return; }

    setNomeArquivo(arquivo.name);
    Papa.parse<LinhaCsv>(arquivo, {
      header: true,
      skipEmptyLines: true,
      complete: (resultado) => {
        const cabecalho = resultado.meta.fields ?? [];
        const faltando = CABECALHO_ESPERADO.filter((coluna) => !cabecalho.includes(coluna));
        if (faltando.length > 0) {
          setErroArquivo(`Cabeçalho do CSV não confere. Faltando: ${faltando.join(", ")}.`);
          return;
        }
        if (resultado.data.length === 0) {
          setErroArquivo("O arquivo não tem nenhuma linha de dados.");
          return;
        }

        const linhasComResiduo = resultado.data.flatMap((linha, indice) =>
          Object.values(linha).some((valor) => temResiduoImportacao(valor)) ? [indice + 1] : [],
        );
        if (linhasComResiduo.length > 0) {
          setErroArquivo(
            `O arquivo contém resíduos de exportação na(s) linha(s) ${linhasComResiduo.join(", ")}. Corrija o CSV antes de validar.`,
          );
          return;
        }
        setLinhas(resultado.data);
      },
      error: (erro) => {
        setErroArquivo(`Não foi possível ler o arquivo: ${erro.message}`);
      },
    });
  }

  async function validar() {
    if (!cursoSelecionado || linhas.length === 0) return;
    setValidando(true);
    setMensagemValidacao("");
    setResultadoImportacao(null);
    setMensagemImportacao("");

    const { data, error } = await createClient().rpc("importar_questoes_dry_run", {
      p_curso_id: cursoSelecionado,
      p_linhas: linhas,
    });

    if (error) {
      console.error("importar_questoes_dry_run falhou:", {
        message: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint,
      });
      setMensagemValidacao("Não foi possível validar o arquivo.");
      setValidando(false);
      return;
    }

    const resultado = (data as ResultadoDryRun[] | null) ?? [];
    setResultadoDryRun(resultado);
    setSelecionadas(new Set(resultado.filter((item) => item.status !== "erro").map((item) => item.linha)));
    setValidando(false);
  }

  function alternarSelecao(linha: number) {
    setSelecionadas((atuais) => {
      const novo = new Set(atuais);
      if (novo.has(linha)) novo.delete(linha);
      else novo.add(linha);
      return novo;
    });
  }

  async function confirmarImportacao() {
    if (!cursoSelecionado || selecionadas.size === 0) return;
    setImportando(true);
    setMensagemImportacao("");

    const linhasConfirmadas = linhas.filter((_, indice) => selecionadas.has(indice + 1));

    const { data, error } = await createClient().rpc("importar_questoes_lote", {
      p_curso_id: cursoSelecionado,
      p_linhas: linhasConfirmadas,
    });

    if (error) {
      console.error("importar_questoes_lote falhou:", {
        message: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint,
      });
      setMensagemImportacao(`Importação não realizada: ${error.message}`);
      setImportando(false);
      return;
    }

    setResultadoImportacao((data as ResultadoImportacao[] | null) ?? []);
    setMensagemImportacao(`Importação concluída: ${(data as ResultadoImportacao[] | null)?.length ?? 0} questão(ões) criada(s).`);
    setResultadoDryRun(null);
    setLinhas([]);
    setNomeArquivo("");
    setImportando(false);
  }

  if (verificando) return <main className="dashboard-loading"><p>Verificando acesso administrativo...</p></main>;

  if (!admin) {
    return (
      <main className="admin-page admin-activation">
        <section>
          <p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p>
          <h1>Acesso restrito</h1>
          <p>Esta área é exclusiva para administradores.</p>
          <Link href="/admin">Ir para a administração</Link>
        </section>
      </main>
    );
  }

  return (
    <main className="admin-page">
      <header className="admin-header">
        <div>
          <p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p>
          <h1>Importar questões em lote</h1>
          <span>CSV com uma questão por linha — matéria e assunto precisam já existir no banco global.</span>
        </div>
        <Link href="/admin">Voltar à administração</Link>
      </header>

      <section className="import-step">
        <h2>1. Curso de destino</h2>
        <p>Todas as questões deste arquivo serão vinculadas a um único curso.</p>
        <select value={cursoSelecionado} onChange={(e) => { setCursoSelecionado(e.target.value); setResultadoDryRun(null); }}>
          <option value="">Selecione o curso</option>
          {cursos.map((curso) => (
            <option key={curso.id} value={curso.id}>{curso.concurso ?? "Sem nome"} {curso.cargo ? `— ${curso.cargo}` : ""}</option>
          ))}
        </select>
      </section>

      <section className="import-step">
        <h2>2. Arquivo CSV</h2>
        <p>Cabeçalho esperado: <code>{CABECALHO_ESPERADO.join(", ")}</code></p>
        <input type="file" accept=".csv" onChange={selecionarArquivo} />
        {nomeArquivo && <small>{nomeArquivo} — {linhas.length} linha(s) lida(s)</small>}
        {erroArquivo && <p className="method-message" role="alert">{erroArquivo}</p>}
      </section>

      <section className="import-step">
        <h2>3. Validar</h2>
        <button type="button" className="answer-submit" onClick={validar} disabled={!cursoSelecionado || linhas.length === 0 || validando}>
          {validando ? "Validando..." : "Validar arquivo"}
        </button>
        {mensagemValidacao && <p className="method-message" role="alert">{mensagemValidacao}</p>}
      </section>

      {resultadoDryRun && (
        <section className="import-step import-preview">
          <h2>4. Pré-visualização</h2>
          <p>{selecionadas.size} de {resultadoDryRun.length} linha(s) selecionada(s) para importar.</p>
          <div className="import-preview-table-wrap">
            <table className="import-preview-table">
              <thead>
                <tr>
                  <th></th>
                  <th>Linha</th>
                  <th>Status</th>
                  <th>Matéria</th>
                  <th>Assunto</th>
                  <th>Enunciado</th>
                  <th>Mensagens</th>
                </tr>
              </thead>
              <tbody>
                {linhas.map((linhaCsv, indice) => {
                  const numeroLinha = indice + 1;
                  const item = resultadoPorLinha.get(numeroLinha);
                  if (!item) return null;
                  return (
                    <tr key={numeroLinha} className={`import-row-${item.status}`}>
                      <td>
                        <input
                          type="checkbox"
                          checked={selecionadas.has(numeroLinha)}
                          disabled={item.status === "erro"}
                          onChange={() => alternarSelecao(numeroLinha)}
                        />
                      </td>
                      <td>{numeroLinha}</td>
                      <td><span className={`import-status-badge import-status-${item.status}`}>{item.status}</span></td>
                      <td>{linhaCsv.materia}</td>
                      <td>{linhaCsv.assunto || "—"}</td>
                      <td className="import-preview-enunciado">{linhaCsv.enunciado}</td>
                      <td>{item.mensagens.length > 0 ? item.mensagens.join("; ") : "—"}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </section>
      )}

      {resultadoDryRun && (
        <section className="import-step">
          <h2>5. Confirmar importação</h2>
          <button type="button" className="answer-submit" onClick={confirmarImportacao} disabled={selecionadas.size === 0 || importando}>
            {importando ? "Importando..." : `Importar ${selecionadas.size} questão(ões)`}
          </button>
          {mensagemImportacao && <p className="method-message" role="status">{mensagemImportacao}</p>}
          {resultadoImportacao && resultadoImportacao.length > 0 && (
            <p>IDs criados: {resultadoImportacao.map((item) => item.questao_id).join(", ")}</p>
          )}
        </section>
      )}
    </main>
  );
}
