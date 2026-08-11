"use client";

import Link from "next/link";
import { useEffect, useMemo, useState, type ChangeEvent } from "react";
import Papa from "papaparse";
import { temResiduoImportacao } from "@/utils/higiene-questoes.mjs";
import { validarLinhaImportacao } from "@/utils/validacao-importacao.mjs";
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

type ResultadoImportacao = { importadas: number; ignoradas_por_duplicidade: number; erros: number };

// Formato retornado por validarLinhaImportacao (utils/validacao-importacao.mjs)
// — arquivo .mjs sem tipagem própria (allowJs sem checkJs neste projeto,
// mesmo padrão já usado para temResiduoImportacao), então o formato é
// declarado aqui só para tipar o resultado no lado do cliente.
type ResultadoValidacaoLocal = { bloqueante: boolean; erros: string[]; avisos: string[] };

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
  // Validação local (parsing) por linha — chave é o número da linha no CSV
  // (1-based, mesma convenção de resultadoPorLinha). Só guarda entradas que
  // tenham pelo menos um erro bloqueante ou um aviso; linhas 100% limpas não
  // entram aqui.
  const [validacaoLocal, setValidacaoLocal] = useState<Map<number, ResultadoValidacaoLocal>>(new Map());

  const [resultadoDryRun, setResultadoDryRun] = useState<ResultadoDryRun[] | null>(null);
  const [selecionadas, setSelecionadas] = useState<Set<number>>(new Set());
  const [validando, setValidando] = useState(false);
  const [mensagemValidacao, setMensagemValidacao] = useState("");

  const [importando, setImportando] = useState(false);
  const [mensagemImportacao, setMensagemImportacao] = useState("");
  const [resultadoImportacao, setResultadoImportacao] = useState<ResultadoImportacao | null>(null);

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

  const linhasBloqueadasLocalmente = useMemo(
    () => Array.from(validacaoLocal.entries()).filter(([, resultado]) => resultado.bloqueante),
    [validacaoLocal],
  );

  const linhasComAvisoLocal = useMemo(
    () =>
      Array.from(validacaoLocal.entries()).filter(
        ([, resultado]) => !resultado.bloqueante && resultado.avisos.length > 0,
      ),
    [validacaoLocal],
  );

  // Camada CSV → validação local → dry-run: só as linhas sem erro
  // bloqueante local seguem para importar_questoes_dry_run. Guarda também o
  // número de linha ORIGINAL do CSV, porque o array enviado à RPC exclui as
  // bloqueadas — a posição (ordinality) que a RPC devolve não é mais igual
  // ao número de linha original a partir daqui.
  const linhasParaDryRun = useMemo(
    () =>
      linhas
        .map((linhaCsv, indice) => ({ linhaCsv, numeroLinhaOriginal: indice + 1 }))
        .filter(({ numeroLinhaOriginal }) => !validacaoLocal.get(numeroLinhaOriginal)?.bloqueante),
    [linhas, validacaoLocal],
  );

  function selecionarArquivo(evento: ChangeEvent<HTMLInputElement>) {
    const arquivo = evento.target.files?.[0];
    setResultadoDryRun(null);
    setResultadoImportacao(null);
    setMensagemValidacao("");
    setMensagemImportacao("");
    setErroArquivo("");
    setLinhas([]);
    setValidacaoLocal(new Map());
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

        // Validação local (camada CSV → validação local → dry-run): mesma
        // regra forte usada no servidor (public.alternativa_tem_sequencia_embutida
        // em supabase/importar_questoes_lote.sql), aqui só para dar feedback
        // imediato antes de gastar uma chamada de rede — o dry-run continua
        // sendo a barreira obrigatória, isso aqui não o substitui.
        const mapaValidacaoLocal = new Map<number, ResultadoValidacaoLocal>();
        resultado.data.forEach((linhaCsv, indice) => {
          const resultadoValidacao = validarLinhaImportacao(linhaCsv) as ResultadoValidacaoLocal;
          if (resultadoValidacao.bloqueante || resultadoValidacao.avisos.length > 0) {
            mapaValidacaoLocal.set(indice + 1, resultadoValidacao);
          }
        });
        setValidacaoLocal(mapaValidacaoLocal);

        setLinhas(resultado.data);
      },
      error: (erro) => {
        setErroArquivo(`Não foi possível ler o arquivo: ${erro.message}`);
      },
    });
  }

  async function validar() {
    if (!cursoSelecionado || linhasParaDryRun.length === 0) return;
    setValidando(true);
    setMensagemValidacao("");
    setResultadoImportacao(null);
    setMensagemImportacao("");

    const { data, error } = await createClient().rpc("importar_questoes_dry_run", {
      p_curso_id: cursoSelecionado,
      p_linhas: linhasParaDryRun.map(({ linhaCsv }) => linhaCsv),
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

    // linhasParaDryRun já excluiu as linhas bloqueadas localmente, então o
    // "linha" devolvido pela RPC é a posição (ordinality) dentro desse array
    // filtrado, não o número de linha original do CSV — traduz de volta
    // para casar com a tabela de pré-visualização abaixo (indexada por
    // `linhas` completo, via numeroLinha = indice + 1).
    const resultadoBruto = (data as ResultadoDryRun[] | null) ?? [];
    const resultado = resultadoBruto.map((item) => ({
      ...item,
      linha: linhasParaDryRun[item.linha - 1]?.numeroLinhaOriginal ?? item.linha,
    }));
    setResultadoDryRun(resultado);
    // Somente linhas 'ok' entram na seleção — 'alerta' (duplicata em outro
    // curso) e 'erro' nunca são pré-selecionadas nem selecionáveis (checkbox
    // desabilitado abaixo), para que nunca façam parte do payload final.
    setSelecionadas(new Set(resultado.filter((item) => item.status === "ok").map((item) => item.linha)));
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

    // importar_questoes_lote retorna uma única linha-resumo com contagens.
    // importadas/ignoradas_por_duplicidade/erros são bigint no banco, e o
    // PostgREST serializa bigint como string no JSON — convertido aqui para
    // number, mesmo tratamento já aplicado a outros bigints vindos de RPC
    // neste projeto (ex.: app/cronograma, app/questoes).
    const linha = (data as { importadas: number | string; ignoradas_por_duplicidade: number | string; erros: number | string }[] | null)?.[0];
    const resultado: ResultadoImportacao = {
      importadas: linha ? Number(linha.importadas) : 0,
      ignoradas_por_duplicidade: linha ? Number(linha.ignoradas_por_duplicidade) : 0,
      erros: linha ? Number(linha.erros) : 0,
    };
    setResultadoImportacao(resultado);
    setMensagemImportacao(
      `Importação concluída: ${resultado.importadas} questão(ões) criada(s), ${resultado.ignoradas_por_duplicidade} ignorada(s) por duplicidade.`
    );
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

      {validacaoLocal.size > 0 && (
        <section className="import-step import-preview">
          <h2>2b. Validação local (parsing)</h2>
          {linhasBloqueadasLocalmente.length > 0 && (
            <>
              <p className="method-message" role="alert">
                {linhasBloqueadasLocalmente.length} questão(ões) precisam de correção antes da importação.
              </p>
              <div className="import-preview-table-wrap">
                <table className="import-preview-table">
                  <thead>
                    <tr>
                      <th>Linha</th>
                      <th>Matéria</th>
                      <th>Assunto</th>
                      <th>Motivo</th>
                    </tr>
                  </thead>
                  <tbody>
                    {linhasBloqueadasLocalmente.map(([numeroLinha, resultadoValidacao]) => {
                      const linhaCsv = linhas[numeroLinha - 1];
                      return (
                        <tr key={numeroLinha} className="import-row-erro">
                          <td>{numeroLinha}</td>
                          <td>{linhaCsv?.materia || "—"}</td>
                          <td>{linhaCsv?.assunto || "—"}</td>
                          <td>
                            {resultadoValidacao.erros.join("; ")} — corrija esta linha no arquivo CSV antes de
                            importar; ela não será enviada para validação no servidor.
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </>
          )}
          {linhasComAvisoLocal.length > 0 && (
            <p className="method-message" role="status">
              {linhasComAvisoLocal.length} questão(ões) com aviso (linha(s){" "}
              {linhasComAvisoLocal.map(([numeroLinha]) => numeroLinha).join(", ")}) — serão enviadas normalmente
              para validação no servidor, mas vale conferir antes de confirmar a importação.
            </p>
          )}
        </section>
      )}

      <section className="import-step">
        <h2>3. Validar</h2>
        <button
          type="button"
          className="answer-submit"
          onClick={validar}
          disabled={!cursoSelecionado || linhasParaDryRun.length === 0 || validando}
        >
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
                          disabled={item.status !== "ok"}
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
          {resultadoImportacao && (
            <p>
              Importadas: {resultadoImportacao.importadas} · Ignoradas por duplicidade: {resultadoImportacao.ignoradas_por_duplicidade} · Erros: {resultadoImportacao.erros}
            </p>
          )}
        </section>
      )}
    </main>
  );
}
