"use client";

import { segmentarEnunciado, type MidiaQuestao } from "./midiasQuestao";

// Enunciado com as mídias na posição semântica (ver midiasQuestao.ts). Renderiza só conteúdo de frase (texto,
// <span>, <img>, <small>), então pode ficar dentro do <h1> do cartão sem mudar o layout da questão.
// Imagem: largura/altura intrínsecas como atributos (reserva o espaço) + CSS max-width:100%/height:auto —
// reduz em telas estreitas, nunca estica nem distorce.
export default function EnunciadoComMidias({ enunciado, midias, onErroImagem }: { enunciado: string; midias: MidiaQuestao[]; onErroImagem?: () => void }) {
  if (midias.length === 0) return <>{enunciado}</>;
  return (
    <>
      {segmentarEnunciado(enunciado, midias).map((segmento, indice) =>
        segmento.tipo === "texto" ? (
          <span key={`t${indice}`}>{segmento.texto}</span>
        ) : (
          <span key={`m${segmento.midia.ordem}`} className="question-media">
            {segmento.midia.url ? (
              // eslint-disable-next-line @next/next/no-img-element -- URL assinada e temporária do Storage; next/image não otimiza isso
              <img
                src={segmento.midia.url}
                width={segmento.midia.largura}
                height={segmento.midia.altura}
                alt={segmento.midia.altText}
                loading="lazy"
                decoding="async"
                onError={onErroImagem}
              />
            ) : (
              <span className="question-media-unavailable" role="img" aria-label={segmento.midia.altText}>
                Imagem indisponível no momento ({segmento.midia.altText}). Tente recarregar a questão.
              </span>
            )}
            {segmento.midia.credito ? <small className="question-media-credit">{segmento.midia.credito}</small> : null}
          </span>
        ),
      )}
    </>
  );
}
