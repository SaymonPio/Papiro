"use client";

import { useState, type ReactNode } from "react";

// Apresentação visual de um componente de aula da Teoria Interativa —
// ÚNICO renderer visual dos 5 tipos documentados (diagnostico, conceito,
// recall, questao_resolvida, resumo_visual). Usado tanto por
// app/teoria/page.tsx (aluno) quanto por app/admin/aulas/page.tsx (preview
// de rascunho do admin), para que as duas telas NUNCA divirjam na
// apresentação. Este arquivo não sabe nada sobre missão, progresso,
// carregamento da aula ou Supabase — só recebe um componente já carregado
// e decide como desenhá-lo.
//
// estrutura.componentes não tem nenhuma garantia de formato a nível de
// banco (só estrutura em si é validada como objeto JSON) — por isso
// ComponenteAula não presume mais nada além de `tipo`.
export type ComponenteAula = {
  tipo: string;
  [chave: string]: unknown;
};

// Só os 5 tipos documentados em teoria_versionada.sql têm rótulo definido;
// qualquer outro valor de `tipo` é exibido cru, sem inventar um nome.
const ROTULOS_TIPO_COMPONENTE: Record<string, string> = {
  diagnostico: "Diagnóstico",
  conceito: "Conceito",
  recall: "Recall",
  questao_resolvida: "Questão resolvida",
  resumo_visual: "Resumo visual",
};

function tituloComponente(tipo: string): string {
  return ROTULOS_TIPO_COMPONENTE[tipo] ?? tipo;
}

function formatarValorComponente(valor: unknown): string {
  if (valor === null || valor === undefined) return "";
  if (typeof valor === "string") return valor;
  return JSON.stringify(valor);
}

// ---------------------------------------------------------------------
// Apresentação da aula — os nomes técnicos dos campos (introducao,
// pergunta, resposta_esperada, explicacao, exemplo, ponto_de_prova,
// pegadinha, resposta, dica, raciocinio) NUNCA aparecem como texto para o
// aluno: cada tipo de componente tem seu próprio layout abaixo, com
// rótulos na identidade verbal do Papiro. O JSON/schema em si (nomes de
// campo, contrato do validador, geração) não muda — só a apresentação.
// ---------------------------------------------------------------------

function ehString(valor: unknown): valor is string {
  return typeof valor === "string" && valor.trim().length > 0;
}

// Ícones inline no mesmo estilo já usado pelo projeto (viewBox 24x24,
// stroke currentColor, sem preenchimento — ver app/questoes/page.tsx) —
// o projeto não depende de nenhuma biblioteca de ícones externa.
function IconeAlvo() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <circle cx="12" cy="12" r="8" />
      <circle cx="12" cy="12" r="4" />
      <circle cx="12" cy="12" r="0.6" fill="currentColor" stroke="none" />
    </svg>
  );
}

function IconeAlerta() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <path d="M12 4 21 20H3L12 4Z" strokeLinejoin="round" />
      <path d="M12 10v4" strokeLinecap="round" />
      <circle cx="12" cy="16.7" r="0.6" fill="currentColor" stroke="none" />
    </svg>
  );
}

function IconeCerebro() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <path d="M9 4.5c-2 0-3.5 1.5-3.5 3.3 0 .7.2 1.3.6 1.8-1 .6-1.6 1.7-1.6 2.9 0 1.4.9 2.6 2.1 3.1-.1.3-.1.6-.1.9 0 1.8 1.5 3.3 3.3 3.3H11V4.9c-.6-.3-1.3-.4-2-.4Z" />
      <path d="M13 4.9V19.8h1.2c1.8 0 3.3-1.5 3.3-3.3 0-.3 0-.6-.1-.9 1.2-.5 2.1-1.7 2.1-3.1 0-1.2-.6-2.3-1.6-2.9.4-.5.6-1.1.6-1.8 0-1.8-1.5-3.3-3.5-3.3-.7 0-1.4.1-2 .4Z" />
    </svg>
  );
}

function IconeCheck() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <circle cx="12" cy="12" r="9" />
      <path d="M8 12.5l2.5 2.5L16 9" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconeMapa() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <path d="M4 6l6-2 6 2 4-2v14l-4 2-6-2-6 2V6Z" strokeLinejoin="round" />
      <path d="M10 4v14M16 6v14" />
    </svg>
  );
}

function IconeGabarito() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <rect x="5" y="3.5" width="14" height="17" rx="2" />
      <path d="M9 8h6M9 12h6M9 16h3" strokeLinecap="round" />
    </svg>
  );
}

// Ícone de "cortar/eliminar alternativa" — círculo com traço diagonal
// (mesma família visual dos demais ícones: linha fina, sem preenchimento).
function IconeCortar() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <circle cx="12" cy="12" r="8" />
      <path d="M7 17 17 7" strokeLinecap="round" />
    </svg>
  );
}

// Destaque seguro dentro do texto: a IA usa **texto** para marcar o que
// precisa de negrito (conceitos-chave, exceções, prazos etc. — ver o
// reforço já adicionado ao prompt em gerar-aula/index.ts). Nunca usa
// dangerouslySetInnerHTML — só quebra a string em pedaços de texto puro e
// <strong>, então não existe caminho de HTML/script vindo da IA.
function renderizarComDestaque(valor: unknown): ReactNode {
  if (!ehString(valor)) return null;
  const partes = valor.split(/\*\*(.+?)\*\*/g);
  return partes.map((parte, indice) => (indice % 2 === 1 ? <strong key={indice}>{parte}</strong> : parte));
}

function RotuloBloco({ icone, children }: { icone?: ReactNode; children: ReactNode }) {
  return (
    <p className="teoria-bloco-kicker">
      {icone}
      {children}
    </p>
  );
}

function BlocoRevelar({ resumo, children }: { resumo: string; children: ReactNode }) {
  return (
    <details className="teoria-revelar">
      <summary>{resumo}</summary>
      <div className="teoria-revelar-conteudo">{children}</div>
    </details>
  );
}

function DiagnosticoView({ c }: { c: ComponenteAula }) {
  return (
    <>
      <RotuloBloco>DIAGNÓSTICO</RotuloBloco>
      {ehString(c.titulo) && <h3>{renderizarComDestaque(c.titulo)}</h3>}
      {ehString(c.introducao) && <p className="teoria-texto">{renderizarComDestaque(c.introducao)}</p>}
      {ehString(c.pergunta) && <p className="teoria-pergunta">{renderizarComDestaque(c.pergunta)}</p>}
      {ehString(c.resposta_esperada) && (
        <BlocoRevelar resumo="Revelar resposta esperada">
          {renderizarComDestaque(c.resposta_esperada)}
        </BlocoRevelar>
      )}
    </>
  );
}

function ConceitoView({ c }: { c: ComponenteAula }) {
  return (
    <>
      <RotuloBloco>CONCEITO</RotuloBloco>
      {ehString(c.titulo) && <h3>{renderizarComDestaque(c.titulo)}</h3>}
      {ehString(c.explicacao) && <p className="teoria-texto">{renderizarComDestaque(c.explicacao)}</p>}
      {ehString(c.exemplo) && (
        <div className="teoria-exemplo">
          <p className="teoria-subtitulo">EXEMPLO</p>
          <p className="teoria-texto">{renderizarComDestaque(c.exemplo)}</p>
        </div>
      )}
      {ehString(c.ponto_de_prova) && (
        <div className="teoria-bizu">
          <p className="teoria-subtitulo">
            <IconeAlvo />
            BIZU DE PROVA
          </p>
          <p className="teoria-texto">{renderizarComDestaque(c.ponto_de_prova)}</p>
        </div>
      )}
      {ehString(c.pegadinha) && (
        <div className="teoria-alerta">
          <p className="teoria-subtitulo">
            <IconeAlerta />
            ONDE OS BIZONHOS CAEM
          </p>
          <p className="teoria-texto">{renderizarComDestaque(c.pegadinha)}</p>
        </div>
      )}
    </>
  );
}

function RecallView({ c }: { c: ComponenteAula }) {
  return (
    <>
      <RotuloBloco icone={<IconeCerebro />}>RECALL</RotuloBloco>
      {ehString(c.titulo) && <h3>{renderizarComDestaque(c.titulo)}</h3>}
      {ehString(c.pergunta) && <p className="teoria-pergunta">{renderizarComDestaque(c.pergunta)}</p>}
      {ehString(c.dica) && <p className="teoria-dica">Dica: {renderizarComDestaque(c.dica)}</p>}
      {ehString(c.resposta) && (
        <BlocoRevelar resumo="Revelar resposta">{renderizarComDestaque(c.resposta)}</BlocoRevelar>
      )}
    </>
  );
}

// Questão interativa: estado local puro (sem Supabase, sem estatísticas,
// sem caderno de erros, sem progresso de missão — é só a interação didática
// dentro do próprio componente da aula, exigida em ambos os lugares que
// usam ComponenteAulaView, /teoria e o preview de /admin/aulas).
//
// "Cortar" uma alternativa é uma decisão do aluno (eliminar candidatas antes
// de responder) independente da seleção em si: nunca revela certo/errado
// antes da confirmação, nunca altera o JSON da aula, só existe como estado
// local (Set de letras cortadas).
function QuestaoResolvidaView({ c }: { c: ComponenteAula }) {
  const alternativasBrutas = Array.isArray(c.alternativas) ? c.alternativas : [];
  const alternativas: { letra: string; texto: string }[] = [];
  for (const bruta of alternativasBrutas) {
    if (typeof bruta !== "object" || bruta === null) continue;
    const { letra, texto } = bruta as Record<string, unknown>;
    if (!ehString(letra) || !ehString(texto)) continue;
    alternativas.push({ letra: letra.trim().toUpperCase(), texto });
  }
  const gabarito = ehString(c.gabarito) ? c.gabarito.trim().toUpperCase() : "";

  const [selecionada, setSelecionada] = useState<string | null>(null);
  const [confirmada, setConfirmada] = useState(false);
  const [cortadas, setCortadas] = useState<Set<string>>(new Set());

  function selecionarAlternativa(letra: string) {
    if (confirmada || cortadas.has(letra)) return;
    setSelecionada(letra);
  }

  function alternarCorte(letra: string) {
    if (confirmada) return;
    const estavaCortada = cortadas.has(letra);
    setCortadas((atual) => {
      const novo = new Set(atual);
      if (estavaCortada) novo.delete(letra);
      else novo.add(letra);
      return novo;
    });
    // Cortar a alternativa que estava selecionada limpa a seleção (regra 4)
    // — nunca deixa uma resposta selecionada "por baixo" de um corte.
    if (!estavaCortada && selecionada === letra) setSelecionada(null);
  }

  return (
    <>
      <RotuloBloco icone={<IconeCheck />}>QUESTÃO RESOLVIDA</RotuloBloco>
      {ehString(c.enunciado) && <p className="teoria-pergunta">{renderizarComDestaque(c.enunciado)}</p>}

      {alternativas.length > 0 && (
        <div className="teoria-alternativas">
          {alternativas.map((alternativa, indice) => {
            const cortada = cortadas.has(alternativa.letra);
            const classes = ["teoria-alternativa"];
            if (cortada) classes.push("cortada");
            if (confirmada) {
              if (alternativa.letra === gabarito) classes.push("correta");
              else if (alternativa.letra === selecionada) classes.push("incorreta");
            } else if (alternativa.letra === selecionada) {
              classes.push("selecionada");
            }
            const rotuloCorte = cortada ? `Restaurar alternativa ${alternativa.letra}` : `Cortar alternativa ${alternativa.letra}`;
            return (
              <div className={classes.join(" ")} key={indice}>
                <button
                  type="button"
                  className="teoria-alternativa-corpo"
                  disabled={confirmada || cortada}
                  aria-pressed={alternativa.letra === selecionada}
                  onClick={() => selecionarAlternativa(alternativa.letra)}
                >
                  <b>{alternativa.letra}</b>
                  <span>{renderizarComDestaque(alternativa.texto)}</span>
                </button>
                <button
                  type="button"
                  className="teoria-alternativa-cortar"
                  disabled={confirmada}
                  aria-label={rotuloCorte}
                  title={rotuloCorte}
                  onClick={(evento) => {
                    evento.stopPropagation();
                    alternarCorte(alternativa.letra);
                  }}
                >
                  <IconeCortar />
                </button>
              </div>
            );
          })}
        </div>
      )}

      {!confirmada && alternativas.length > 0 && (
        <button
          type="button"
          className="answer-submit"
          disabled={!selecionada}
          onClick={() => setConfirmada(true)}
        >
          Confirmar resposta
        </button>
      )}

      {confirmada && (
        <>
          {selecionada !== gabarito && (
            <div className="teoria-gabarito-comentado">
              <p className="teoria-subtitulo">
                <IconeGabarito />
                GABARITO COMENTADO
              </p>
              <p className="teoria-texto">
                Sua resposta: {selecionada ?? "—"}
                <br />
                Gabarito: {gabarito || "—"}
              </p>
            </div>
          )}

          {ehString(c.raciocinio) && (
            <div className="teoria-exemplo">
              <p className="teoria-subtitulo">COMO PENSAR</p>
              <p className="teoria-texto">{renderizarComDestaque(c.raciocinio)}</p>
            </div>
          )}

          {ehString(c.pegadinha) && (
            <div className="teoria-alerta">
              <p className="teoria-subtitulo">
                <IconeAlerta />
                ONDE OS BIZONHOS CAEM
              </p>
              <p className="teoria-texto">{renderizarComDestaque(c.pegadinha)}</p>
            </div>
          )}
        </>
      )}
    </>
  );
}

function ResumoVisualView({ c }: { c: ComponenteAula }) {
  const pontos = Array.isArray(c.pontos) ? c.pontos.filter(ehString) : [];
  return (
    <>
      <RotuloBloco icone={<IconeMapa />}>RESUMO DA MISSÃO</RotuloBloco>
      {ehString(c.titulo) && <h3>{renderizarComDestaque(c.titulo)}</h3>}
      {pontos.length > 0 && (
        <div className="teoria-resumo-lista">
          {pontos.map((ponto, indice) => (
            <div className="teoria-resumo-item" key={indice}>
              <IconeCheck />
              <span>{renderizarComDestaque(ponto)}</span>
            </div>
          ))}
        </div>
      )}
    </>
  );
}

// Fallback genérico: só usado para um `tipo` fora dos 5 documentados —
// nunca presume o significado de um campo desconhecido, mostra a chave
// crua mesmo.
function ComponenteGenericoView({ componente }: { componente: ComponenteAula }) {
  const { tipo, ...outrosCampos } = componente;
  const chaves = Object.keys(outrosCampos);
  return (
    <>
      <RotuloBloco>{tituloComponente(String(tipo)).toUpperCase()}</RotuloBloco>
      {chaves.length > 0 && (
        <dl>
          {chaves.map((chave) => (
            <div key={chave}>
              <dt>{chave}</dt>
              <dd>{formatarValorComponente(outrosCampos[chave])}</dd>
            </div>
          ))}
        </dl>
      )}
    </>
  );
}

const VIEWS_POR_TIPO: Record<string, (props: { c: ComponenteAula }) => ReactNode> = {
  diagnostico: DiagnosticoView,
  conceito: ConceitoView,
  recall: RecallView,
  questao_resolvida: QuestaoResolvidaView,
  resumo_visual: ResumoVisualView,
};

export default function ComponenteAulaView({ componente }: { componente: ComponenteAula }) {
  const Vista = VIEWS_POR_TIPO[componente.tipo];
  return (
    <article className={`teoria-bloco teoria-bloco--${componente.tipo}`}>
      {Vista ? <Vista c={componente} /> : <ComponenteGenericoView componente={componente} />}
    </article>
  );
}
