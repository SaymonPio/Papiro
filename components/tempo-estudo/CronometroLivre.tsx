"use client";

import { useState } from "react";
import type { UseSessaoTempoResultado } from "./useSessaoTempo";
import ClassificarEstudoAvulso from "./ClassificarEstudoAvulso";
import HistoricoEstudoAvulso from "./HistoricoEstudoAvulso";

function formatarHMS(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  const s = segundos % 60;
  const dois = (n: number) => String(n).padStart(2, "0");
  return `${dois(h)}:${dois(m)}:${dois(s)}`;
}

// Aba "Cronômetro livre" de /meu-estudo — estudo feito FORA do Papiro
// (PDF, livro, videoaula, questões em outra plataforma). `sessao` é
// recebida de cima (app/meu-estudo/page.tsx, via useSessaoTempoGlobal()),
// nunca criada aqui: é a MESMA instância global de useSessaoTempo
// montada por SessaoTempoProvider (app/layout.tsx), que também alimenta
// o widget flutuante (CronometroEstudo) em QUALQUER área autenticada.
// Nunca uma segunda instância do motor.
//
// Esta rodada é SÓ apresentação (ver app/globals.css para a maior parte
// do trabalho visual) — nenhum handler/estado novo além do que já existia:
// mesmos sessao.iniciarEstudo/pausarEstudo/retomarEstudo/encerrarEstudo/
// encerrarConflitoEIniciar/voltarAoInicio de antes.
//
// A classificação (ClassificarEstudoAvulso) aparece de forma puramente
// reativa — nunca por um flag local imperativo: assim que
// encerrarEstudo() termina com sucesso, `estado` vira "encerrada" e
// `sessaoId` continua apontando para a sessão que acabou de parar, então
// a condição abaixo já mostra o painel sem nenhuma lógica extra de
// "aguardar o resultado". Se encerrarEstudo() falhar, `estado` vira
// "erro" em vez de "encerrada" — a classificação corretamente NÃO
// aparece.
//
// `key={estado}` nos blocos de status/ações (nunca no relógio): isso faz
// SÓ esses dois blocos entrarem com uma microanimação quando o estado
// realmente muda (ver .cronometro-livre-status-linha/.cronometro-livre-acoes
// em globals.css) — o relógio em si nunca é remontado, então o segundo
// a segundo nunca dispara nenhuma animação (pedido explícito desta
// rodada).
export default function CronometroLivre({ sessao }: { sessao: UseSessaoTempoResultado }) {
  const { estado, processando, segundosLiquidos, conflito, erro, sessaoId } = sessao;
  const [chaveHistorico, setChaveHistorico] = useState(0);

  function aoTerminarClassificacao() {
    sessao.voltarAoInicio();
    setChaveHistorico((valor) => valor + 1);
  }

  const mostrarClassificacao = estado === "encerrada" && sessaoId !== null;
  const contando = estado === "ativa" || estado === "pausada";

  return (
    <div className="cronometro-livre">
      <header className="cronometro-livre-cabecalho">
        <div className="cronometro-livre-cabecalho-topo">
          <p className="dashboard-label">CRONÔMETRO LIVRE</p>
          <span className="cronometro-livre-selo">
            <span className="cronometro-livre-selo-ponto" aria-hidden="true" />
            Estudo avulso
          </span>
        </div>
        <h2>
          Estude onde quiser.
          <br />
          O Papiro registra seu tempo.
        </h2>
      </header>

      <article className={`cronometro-livre-card cronometro-livre-card--${estado}`}>
        {estado === "conflito" ? (
          <div className="cronometro-livre-conflito cronometro-livre-corpo">
            <p className="cronometro-livre-conflito-titulo" role="alert">
              Você já possui um estudo em andamento
            </p>
            {conflito && <p className="cronometro-livre-conflito-tempo">{formatarHMS(conflito.segundosLiquidos)}</p>}
            <div className="cronometro-livre-acoes">
              {conflito?.linkRetomada && (
                <a className="cronometro-livre-botao-principal" href={conflito.linkRetomada}>
                  Retomar estudo
                </a>
              )}
              <button
                type="button"
                className="cronometro-livre-botao-secundario"
                onClick={() => void sessao.encerrarConflitoEIniciar()}
                disabled={processando}
              >
                Encerrar estudo anterior
              </button>
            </div>
          </div>
        ) : mostrarClassificacao ? (
          <ClassificarEstudoAvulso
            sessaoTempoId={sessaoId}
            segundosLiquidos={segundosLiquidos}
            aoClassificar={aoTerminarClassificacao}
            aoFechar={aoTerminarClassificacao}
          />
        ) : (
          <div className="cronometro-livre-corpo">
            <div className="cronometro-livre-status-linha" key={`status-${estado}`}>
              {contando && (
                <span
                  className={`cronometro-livre-ponto${estado === "ativa" ? " cronometro-livre-ponto--ativo" : ""}`}
                  aria-hidden="true"
                />
              )}
              {estado === "ativa" && <span className="cronometro-livre-status-texto">EM ESTUDO</span>}
              {estado === "pausada" && <span className="cronometro-livre-status-texto">PAUSADO</span>}
              {estado === "iniciando" && <span className="cronometro-livre-status-texto">Sincronizando...</span>}
            </div>

            <div className="cronometro-livre-mostrador">
              <span className="cronometro-livre-anel" aria-hidden="true" />
              <p className="cronometro-livre-relogio">{formatarHMS(segundosLiquidos)}</p>
            </div>

            {contando && <p className="cronometro-livre-rotulo-tempo">TEMPO LÍQUIDO</p>}

            {estado === "erro" && (
              <p className="cronometro-livre-erro" role="alert">
                {erro ?? "Não foi possível medir o tempo agora."}
              </p>
            )}

            <div className="cronometro-livre-acoes" key={`acoes-${estado}`}>
              {estado === "ociosa" && (
                <button type="button" className="cronometro-livre-botao-iniciar" onClick={sessao.iniciarEstudo} disabled={processando}>
                  Iniciar estudo
                </button>
              )}
              {estado === "ativa" && (
                <>
                  <button type="button" className="cronometro-livre-botao-secundario" onClick={sessao.pausarEstudo} disabled={processando}>
                    Pausar
                  </button>
                  <button type="button" className="cronometro-livre-botao-concluir" onClick={sessao.encerrarEstudo} disabled={processando}>
                    Finalizar
                  </button>
                </>
              )}
              {estado === "pausada" && (
                <>
                  <button type="button" className="cronometro-livre-botao-principal" onClick={sessao.retomarEstudo} disabled={processando}>
                    Retomar
                  </button>
                  <button type="button" className="cronometro-livre-botao-concluir" onClick={sessao.encerrarEstudo} disabled={processando}>
                    Finalizar
                  </button>
                </>
              )}
            </div>

            {estado === "ociosa" && <p className="cronometro-livre-dica">PDF · livros · videoaulas · questões externas</p>}
          </div>
        )}
      </article>

      <section className="stats-panel cronometro-livre-historico-painel">
        <div className="stats-title">
          <div>
            <p className="dashboard-label">HISTÓRICO</p>
            <h2>Estudos avulsos recentes</h2>
          </div>
        </div>
        <HistoricoEstudoAvulso chaveAtualizacao={chaveHistorico} />
      </section>
    </div>
  );
}
