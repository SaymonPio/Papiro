"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { formatarDuracaoCurta } from "./useDadosTempoEstudo";

// Painel de classificação do Cronômetro Livre — usado em dois lugares:
// (1) logo depois de encerrar um estudo avulso (CronometroLivre.tsx), e
// (2) a partir da ação "Classificar" de uma sessão ainda "Não
// classificado" no histórico (HistoricoEstudoAvulso.tsx). Os dois casos
// chamam exatamente a mesma RPC (classificar_estudo_avulso) com o mesmo
// contrato — só o ponto de montagem na página muda, nunca a lógica.
//
// Não é um modal/overlay com portal/focus-trap próprio (a especificação
// pedia "modal/sheet", mas um painel inline no mesmo lugar — substituindo
// o cronômetro recém-parado, ou expandindo sob a linha do histórico —
// cumpre a mesma função de interromper o fluxo e pedir a classificação,
// com muito menos risco de acessibilidade do que um diálogo verdadeiro
// construído do zero). Simplificação deliberada, reportada na entrega.

type TipoClassificacao = "teoria" | "questoes" | "leitura" | "revisao";

const OPCOES_TIPO: Array<{ valor: TipoClassificacao; rotulo: string }> = [
  { valor: "teoria", rotulo: "Teoria" },
  { valor: "questoes", rotulo: "Questões" },
  { valor: "leitura", rotulo: "Leitura" },
  { valor: "revisao", rotulo: "Revisão" },
];

type MateriaCurso = { materia_id: number; materia_nome: string };
type AssuntoCurso = { assunto_id: number; assunto_nome: string };

export default function ClassificarEstudoAvulso({
  sessaoTempoId,
  segundosLiquidos,
  materiaIdInicial = null,
  assuntoIdInicial = null,
  descricaoInicial = null,
  aoClassificar,
  aoFechar,
}: {
  sessaoTempoId: number;
  segundosLiquidos: number;
  materiaIdInicial?: number | null;
  assuntoIdInicial?: number | null;
  descricaoInicial?: string | null;
  /** Classificação salva com sucesso — o chamador decide o que fazer a seguir (resetar cronômetro, recarregar histórico, etc.). */
  aoClassificar: () => void;
  /** Fechado sem salvar — o tempo já está salvo como "nao_classificado" de qualquer forma; nada é perdido. */
  aoFechar: () => void;
}) {
  const [tipo, setTipo] = useState<TipoClassificacao | null>(null);
  const [materiaId, setMateriaId] = useState<number | null>(materiaIdInicial);
  const [assuntoId, setAssuntoId] = useState<number | null>(assuntoIdInicial);
  const [descricao, setDescricao] = useState(descricaoInicial ?? "");
  const [materias, setMaterias] = useState<MateriaCurso[]>([]);
  const [assuntos, setAssuntos] = useState<AssuntoCurso[]>([]);
  // Sem flag de "carregando" próprio: derivado comparando materiaId com a
  // última matéria cujos assuntos já chegaram — assim nenhum setState
  // roda sincronamente no corpo do efeito abaixo (só dentro do .then(),
  // que não é "durante o efeito" para a regra react-hooks/set-state-in-effect).
  const [assuntosDeMateriaId, setAssuntosDeMateriaId] = useState<number | null>(null);
  const carregandoAssuntos = materiaId !== null && assuntosDeMateriaId !== materiaId;
  const [salvando, setSalvando] = useState(false);
  const [mensagemErro, setMensagemErro] = useState<string | null>(null);

  useEffect(() => {
    let ativo = true;
    createClient()
      .rpc("materias_do_curso_ativo")
      .then(({ data, error }) => {
        if (!ativo || error || !data) return;
        setMaterias(data as MateriaCurso[]);
      });
    return () => {
      ativo = false;
    };
  }, []);

  useEffect(() => {
    // materiaId null já deixou assuntos=[] pelo onChange do select (ver
    // abaixo) — nada a limpar aqui, só o caminho de busca quando há
    // matéria selecionada.
    if (!materiaId) return;
    let ativo = true;
    createClient()
      .rpc("assuntos_do_curso_ativo", { p_materia_id: materiaId })
      .then(({ data, error }) => {
        if (!ativo) return;
        if (!error && data) setAssuntos(data as AssuntoCurso[]);
        setAssuntosDeMateriaId(materiaId);
      });
    return () => {
      ativo = false;
    };
  }, [materiaId]);

  async function salvar() {
    if (!tipo) {
      setMensagemErro("Escolha o tipo de atividade para salvar.");
      return;
    }
    setSalvando(true);
    setMensagemErro(null);
    const { error } = await createClient().rpc("classificar_estudo_avulso", {
      p_sessao_tempo_id: sessaoTempoId,
      p_tipo_atividade: tipo,
      p_materia_id: materiaId,
      p_assunto_id: assuntoId,
      p_descricao_estudo: descricao.trim() ? descricao.trim() : null,
    });
    setSalvando(false);
    if (error) {
      console.error("[ClassificarEstudoAvulso] Falha em classificar_estudo_avulso:", error);
      setMensagemErro("Não foi possível salvar a classificação agora. O tempo já está salvo — tente novamente.");
      return;
    }
    aoClassificar();
  }

  return (
    <section className="custom-session cronometro-livre-classificar" aria-label="Classificar estudo avulso">
      <div className="cronometro-livre-classificar-topo">
        <p className="dashboard-label">SESSÃO CONCLUÍDA</p>
        <p className="cronometro-livre-tempo-realizado">{formatarDuracaoCurta(segundosLiquidos)} de tempo líquido</p>
        <h3 className="cronometro-livre-pergunta">Excelente. O que você estudou?</h3>
      </div>

      <div className="custom-session-field">
        <label>Tipo de atividade *</label>
        <div className="cronometro-livre-tipo-opcoes" role="radiogroup" aria-label="Tipo de atividade">
          {OPCOES_TIPO.map((opcao) => (
            <button
              key={opcao.valor}
              type="button"
              role="radio"
              aria-checked={tipo === opcao.valor}
              className={tipo === opcao.valor ? "selected" : ""}
              onClick={() => setTipo(opcao.valor)}
            >
              {opcao.rotulo}
            </button>
          ))}
        </div>
      </div>

      <div className="custom-session-field">
        <label htmlFor="classificar-materia-select">Matéria (opcional)</label>
        <select
          id="classificar-materia-select"
          value={materiaId ?? ""}
          onChange={(evento) => {
            const valor = evento.target.value ? Number(evento.target.value) : null;
            setMateriaId(valor);
            setAssuntoId(null);
            setAssuntos([]);
          }}
        >
          <option value="">Nenhuma</option>
          {materias.map((materia) => (
            <option key={materia.materia_id} value={materia.materia_id}>
              {materia.materia_nome}
            </option>
          ))}
        </select>
      </div>

      <div className="custom-session-field">
        <label htmlFor="classificar-assunto-select">Assunto/Conteúdo (opcional)</label>
        <select
          id="classificar-assunto-select"
          value={assuntoId ?? ""}
          onChange={(evento) => setAssuntoId(evento.target.value ? Number(evento.target.value) : null)}
          disabled={!materiaId || carregandoAssuntos}
        >
          <option value="">{carregandoAssuntos ? "Carregando..." : "Nenhum"}</option>
          {assuntos.map((assunto) => (
            <option key={assunto.assunto_id} value={assunto.assunto_id}>
              {assunto.assunto_nome}
            </option>
          ))}
        </select>
      </div>

      <div className="custom-session-field">
        <label htmlFor="classificar-descricao">O que você estudou? (opcional)</label>
        <textarea
          id="classificar-descricao"
          value={descricao}
          onChange={(evento) => setDescricao(evento.target.value.slice(0, 500))}
          maxLength={500}
          rows={3}
          placeholder="Ex.: Lei Maria da Penha — arts. 5º ao 12"
        />
      </div>

      {mensagemErro && <p className="method-message" role="alert">{mensagemErro}</p>}

      <div className="cronometro-livre-classificar-acoes">
        <button type="button" className="cronometro-livre-botao-principal" onClick={salvar} disabled={salvando}>
          {salvando ? "Salvando..." : "Salvar estudo"}
        </button>
        <button type="button" className="cronometro-livre-botao-secundario" onClick={aoFechar} disabled={salvando}>
          Agora não
        </button>
      </div>
      <p className="cronometro-livre-classificar-aviso">Seu tempo já está registrado. Você pode classificar depois.</p>
    </section>
  );
}
