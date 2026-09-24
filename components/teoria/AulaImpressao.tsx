"use client";

import { useState, type ReactNode } from "react";
import { renderizarComDestaque } from "./ComponenteAulaView";
import { chaveArte, textoAltArte, type MapaArtes } from "./arteQuadrinho";
import type { AulaImpressaoModelo, ComponenteImpressao } from "./prepararAulaImpressao";

// Apresentação EDITORIAL (papel/PDF) da mesma aula_versao.estrutura que
// ComponenteAulaView.tsx renderiza de forma interativa na tela — nunca uma
// segunda aula, nunca texto reescrito. Os dados já chegam normalizados por
// prepararAulaImpressao.ts (função puramente estrutural, sem interpretação
// pedagógica); este arquivo só decide a FORMA impressa.
//
// Redesenho editorial (linguagem de apostila, não "tela impressa"):
// - capa própria (página cheia, sempre seguida de quebra de página);
// - fundo claro em toda a peça, dourado/verde só em títulos, réguas,
//   marcadores e boxes — nunca em grandes áreas preenchidas;
// - CONCEITO deixa de ser um card único: texto principal flui como
//   parágrafos editoriais; só EXEMPLO/BIZU/PEGADINHA viram sub-blocos
//   próprios, podendo quebrar de página entre si;
// - hierarquia tipográfica: serif (mesma família já usada em
//   .admin-page h2/.impressao-pagina, sem fonte nova) para títulos/capa,
//   sans do próprio body do site para texto corrido;
// - regras de quebra SELETIVAS (ver app/globals.css): capa sempre em
//   página própria; BIZU/PEGADINHA/JURISPRUDÊNCIA/cada RECALL preferem não
//   quebrar; enunciado+alternativas da questão não se separam entre si,
//   mas "como pensar" pode ficar em outra página; RESUMO flui livremente.
//
// Decisões técnicas registradas (não é bug, é limitação real do print do
// navegador via window.print — não há suporte confiável, entre
// navegadores, para cabeçalho/rodapé "correndo" em toda página via CSS
// Paged Media @page margin boxes):
// - SEM numeração de página própria nesta rodada (melhor não numerar do
//   que numerar errado — o navegador pode numerar via "Cabeçalhos e
//   rodapés" nas opções de impressão, fora do nosso controle);
// - o "cabeçalho editorial" e o rodapé de fechamento abaixo são ÚNICOS
//   (aparecem uma vez, não repetem em toda página impressa).

function CabecalhoInterno({ materiaNome, unidadeTitulo }: { materiaNome: string | null; unidadeTitulo: string }) {
  return (
    <p className="impressao-cabecalho-interno">
      PAPIRO <span aria-hidden="true">·</span> {materiaNome || unidadeTitulo}
    </p>
  );
}

function Capa({ modelo }: { modelo: AulaImpressaoModelo }) {
  return (
    <section className="impressao-capa">
      <div className="impressao-capa-topo">
        <p className="impressao-capa-wordmark">PAPIRO</p>
        <div className="impressao-capa-regua" aria-hidden="true" />
      </div>

      <div className="impressao-capa-corpo">
        {modelo.materiaNome && <p className="impressao-capa-materia">{modelo.materiaNome}</p>}
        <h1 className="impressao-capa-titulo">{modelo.unidadeTitulo}</h1>
        {modelo.conteudoNome && modelo.conteudoNome !== modelo.unidadeTitulo && (
          <p className="impressao-capa-conteudo">{modelo.conteudoNome}</p>
        )}
      </div>

      <div className="impressao-capa-rodape">
        <p className="impressao-capa-etiqueta">Material de estudo</p>
        <p className="impressao-capa-versao">
          Versão {modelo.numeroVersao}
          {modelo.publicadoEm ? ` · ${new Date(modelo.publicadoEm).toLocaleDateString("pt-BR")}` : ""}
        </p>
        {modelo.cursoNome && <p className="impressao-capa-curso">{modelo.cursoNome}</p>}
      </div>
    </section>
  );
}

function SubSecao({ rotulo, valor, destaque }: { rotulo: string; valor: string | null; destaque?: "bizu" | "pegadinha" }) {
  if (!valor) return null;
  return (
    <div className={`impressao-subsecao${destaque ? ` impressao-subsecao--${destaque}` : ""}`}>
      <p className="impressao-subsecao-rotulo">{rotulo}</p>
      <p className="impressao-texto">{renderizarComDestaque(valor)}</p>
    </div>
  );
}

// Imagem do quadro no PDF. `loading="eager"`: o gate PRINT_READY (app/teoria/imprimir/page.tsx) já garante
// que a impressão só é liberada depois das imagens resolverem (ou de um timeout de segurança) — nada a ganhar
// esperando o navegador decidir sozinho quando carregar, e evita qualquer dúvida sobre "lazy" antes de
// window.print() entre navegadores. `onLoad` E `onError` contam como RESOLVIDA (erro nunca trava a impressão);
// em erro a imagem simplesmente some — o texto do quadro (sempre renderizado por fora) é o que garante que o
// PDF nunca fica incompleto. Nunca loga a URL.
function ArteDoQuadroImpressao({ url, alt, aoResolver }: { url: string; alt: string; aoResolver?: () => void }) {
  const [falhou, setFalhou] = useState(false);
  if (falhou) return null;
  return (
    <div className="impressao-quadrinho-arte">
      <img
        src={url}
        alt={alt}
        width={1536}
        height={1024}
        loading="eager"
        decoding="async"
        referrerPolicy="no-referrer"
        onLoad={() => aoResolver?.()}
        onError={() => {
          setFalhou(true);
          aoResolver?.();
        }}
      />
    </div>
  );
}

// Um <li> do quadrinho (Quadro N + arte opcional + cena/falas/legenda). Extraído para ser reaproveitado pelas
// duas grades em que o Q12.24 divide os quadros (cabeçalho+1ª linha / restante — ver comentário no case
// "quadrinho_didatico"), sem duplicar a lógica de casamento de arte (chave/assinatura).
function renderizarQuadroImpressao(
  quadro: Extract<ComponenteImpressao, { tipo: "quadrinho_didatico" }>["quadros"][number],
  componente: Extract<ComponenteImpressao, { tipo: "quadrinho_didatico" }>,
  artes: MapaArtes | undefined,
  aoResolverImagem: ((assinatura: string) => void) | undefined,
): ReactNode {
  // Chave da arte = id do componente + índice ORIGINAL (nunca a posição depois de descartar quadro vazio).
  // Assinatura = chave + url: identifica esta URL específica, para o gate de impressão nunca confundir uma
  // resposta tardia de URL antiga com a URL atual (Q12.21 §8).
  const chave = componente.id ? chaveArte(componente.id, quadro.indiceOriginal) : null;
  const arte = chave && artes ? artes[chave] : undefined;
  const assinatura = arte && chave ? `${chave}|${arte.url}` : null;
  return (
    <li key={quadro.numero} className="impressao-quadrinho-quadro">
      <p className="impressao-subsecao-rotulo">Quadro {quadro.numero}</p>
      {arte && assinatura && (
        <ArteDoQuadroImpressao
          url={arte.url}
          alt={textoAltArte(quadro.numero, componente.titulo)}
          aoResolver={() => aoResolverImagem?.(assinatura)}
        />
      )}
      {quadro.cena && <p className="impressao-texto">{renderizarComDestaque(quadro.cena)}</p>}
      {quadro.falas.length > 0 && (
        <dl className="impressao-quadrinho-falas">
          {quadro.falas.map((fala, i) => (
            <div key={i}>
              <dt className="impressao-quadrinho-emissor">{fala.emissor}</dt>
              <dd className="impressao-texto">{renderizarComDestaque(fala.texto)}</dd>
            </div>
          ))}
        </dl>
      )}
      {quadro.legenda && <p className="impressao-quadrinho-legenda">{renderizarComDestaque(quadro.legenda)}</p>}
    </li>
  );
}

function renderizarComponente(
  componente: ComponenteImpressao,
  indice: number,
  artes?: MapaArtes,
  aoResolverImagem?: (assinatura: string) => void,
): ReactNode {
  switch (componente.tipo) {
    case "diagnostico":
      return (
        <section key={indice} className="impressao-secao impressao-secao--diagnostico">
          <p className="impressao-secao-kicker">Diagnóstico</p>
          {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
          {componente.introducao && <p className="impressao-texto">{renderizarComDestaque(componente.introducao)}</p>}
          {componente.pergunta && <p className="impressao-pergunta">{renderizarComDestaque(componente.pergunta)}</p>}
          <SubSecao rotulo="Resposta esperada" valor={componente.respostaEsperada} />
        </section>
      );

    case "conceito":
      return (
        <section key={indice} className="impressao-secao impressao-secao--conceito">
          <p className="impressao-secao-kicker">Conceito</p>
          {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
          {componente.explicacao && <p className="impressao-texto impressao-texto--corrido">{renderizarComDestaque(componente.explicacao)}</p>}
          {componente.exemplo && (
            <div className="impressao-citacao">
              <p className="impressao-subsecao-rotulo">Exemplo</p>
              <p className="impressao-texto">{renderizarComDestaque(componente.exemplo)}</p>
            </div>
          )}
          <SubSecao rotulo="Bizu de prova" valor={componente.pontoDeProva} destaque="bizu" />
          <SubSecao rotulo="Onde os bizonhos caem" valor={componente.pegadinha} destaque="pegadinha" />
        </section>
      );

    case "jurisprudencia_essencial":
      return (
        <section key={indice} className="impressao-secao impressao-jurisprudencia">
          <p className="impressao-secao-kicker impressao-secao-kicker--jurisprudencia">Jurisprudência essencial</p>
          {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
          {(componente.tribunal || componente.identificacaoPrecedente || componente.dispositivoRelacionado) && (
            <p className="impressao-jurisprudencia-meta">
              {componente.tribunal && <span><strong>Tribunal:</strong> {componente.tribunal}</span>}
              {componente.identificacaoPrecedente && <span><strong>Precedente:</strong> {componente.identificacaoPrecedente}</span>}
              {componente.dispositivoRelacionado && <span><strong>Dispositivo:</strong> {componente.dispositivoRelacionado}</span>}
            </p>
          )}
          {componente.entendimento && (
            <div className="impressao-subsecao">
              <p className="impressao-subsecao-rotulo">Entendimento</p>
              <p className="impressao-texto">{renderizarComDestaque(componente.entendimento)}</p>
            </div>
          )}
          {componente.comoCaiNaProva && (
            <div className="impressao-subsecao">
              <p className="impressao-subsecao-rotulo">Como cai na prova</p>
              <p className="impressao-texto">{renderizarComDestaque(componente.comoCaiNaProva)}</p>
            </div>
          )}
          {componente.fonte && <p className="impressao-jurisprudencia-fonte">Fonte: {renderizarComDestaque(componente.fonte)}</p>}
        </section>
      );

    case "recall":
      return (
        <section key={indice} className="impressao-secao impressao-secao--recall">
          <p className="impressao-secao-kicker">Recall</p>
          {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
          <div className="impressao-recall">
            {componente.pergunta && (
              <div className="impressao-recall-linha">
                <p className="impressao-subsecao-rotulo">Pergunta</p>
                <p className="impressao-texto">{renderizarComDestaque(componente.pergunta)}</p>
              </div>
            )}
            {componente.dica && (
              <div className="impressao-recall-linha impressao-recall-linha--dica">
                <p className="impressao-subsecao-rotulo">Dica</p>
                <p className="impressao-texto">{renderizarComDestaque(componente.dica)}</p>
              </div>
            )}
            {componente.resposta && (
              <div className="impressao-recall-linha impressao-recall-linha--resposta">
                <p className="impressao-subsecao-rotulo">Resposta</p>
                <p className="impressao-texto">{renderizarComDestaque(componente.resposta)}</p>
              </div>
            )}
          </div>
        </section>
      );

    case "questao_resolvida":
      return (
        <section key={indice} className="impressao-secao">
          <p className="impressao-secao-kicker">Questão resolvida</p>
          <div className="impressao-questao-corpo">
            {componente.enunciado && <p className="impressao-pergunta">{renderizarComDestaque(componente.enunciado)}</p>}
            {componente.alternativas.length > 0 && (
              <div className="impressao-alternativas">
                {componente.alternativas.map((alt) => (
                  <p key={alt.letra} className={`impressao-alternativa${alt.correta ? " impressao-alternativa--correta" : ""}`}>
                    <b>{alt.letra})</b> {renderizarComDestaque(alt.texto)}
                    {alt.correta && <span className="impressao-gabarito-marca"> ✓ gabarito</span>}
                  </p>
                ))}
              </div>
            )}
          </div>
          <SubSecao rotulo="Como pensar" valor={componente.raciocinio} />
          <SubSecao rotulo="Onde os bizonhos caem" valor={componente.pegadinha} destaque="pegadinha" />
        </section>
      );

    case "resumo_visual":
      return (
        <section key={indice} className="impressao-secao impressao-secao--resumo">
          <p className="impressao-secao-kicker">Resumo da aula</p>
          {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
          {componente.pontos.length > 0 && (
            <ul className="impressao-resumo-lista">
              {componente.pontos.map((ponto, i) => (
                <li key={i}>{renderizarComDestaque(ponto)}</li>
              ))}
            </ul>
          )}
        </section>
      );

    // Exemplo visual (quadrinho didático) no papel: sequência simples de
    // blocos numerados (sem estética de HQ), cada quadro sem quebrar no meio.
    case "quadrinho_didatico": {
      // Q12.24: o cabeçalho (kicker + título) nunca pode ficar sozinho no fim de uma página, com a grade
      // inteira indo para a seguinte. Corrige-se agrupando o cabeçalho com a PRIMEIRA LINHA da grade (mesma
      // quantidade de colunas que o CSS usa para este total de quadros — ver .impressao-quadrinho-quadros[data-
      // quadros] em app/globals.css) num wrapper .impressao-quadrinho-cabecalho com break-inside: avoid. O
      // restante dos quadros continua numa segunda grade (mesmas classes/data-quadros, mesmas colunas —
      // visualmente uma única grade contínua) SEM essa restrição: só o cabeçalho+1ª linha é indivisível, nunca
      // os 4 quadros inteiros (evitar página em branco grande é mais importante que juntar tudo).
      const colunasGrade = [4, 5, 6].includes(componente.quadros.length) ? 2 : 1;
      const primeiraLinha = componente.quadros.slice(0, colunasGrade);
      const restante = componente.quadros.slice(colunasGrade);
      return (
        <section key={indice} className="impressao-secao impressao-secao--quadrinho">
          <div className="impressao-quadrinho-cabecalho">
            <p className="impressao-secao-kicker">Exemplo visual</p>
            {componente.titulo && <h2 className="impressao-secao-titulo">{renderizarComDestaque(componente.titulo)}</h2>}
            {primeiraLinha.length > 0 && (
              <ol className="impressao-quadrinho-quadros impressao-quadrinho-quadros--inicio" data-quadros={componente.quadros.length}>
                {primeiraLinha.map((quadro) => renderizarQuadroImpressao(quadro, componente, artes, aoResolverImagem))}
              </ol>
            )}
          </div>
          {restante.length > 0 && (
            <ol className="impressao-quadrinho-quadros" data-quadros={componente.quadros.length}>
              {restante.map((quadro) => renderizarQuadroImpressao(quadro, componente, artes, aoResolverImagem))}
            </ol>
          )}
          <SubSecao rotulo="Regra de prova" valor={componente.fechamento} destaque="bizu" />
        </section>
      );
    }

    // Nenhum tipo desaparece silenciosamente: componente com tipo não
    // reconhecido pelo contrato atual ainda aparece, rotulado com o nome
    // bruto do tipo e os campos que tinha, em vez de sumir do PDF.
    case "desconhecido":
      return (
        <section key={indice} className="impressao-secao impressao-subsecao">
          <p className="impressao-secao-kicker">{componente.rotulo}</p>
          {componente.campos.length > 0 && (
            <dl className="impressao-campos-genericos">
              {componente.campos.map((campo) => (
                <div key={campo.chave}>
                  <dt>{campo.chave}</dt>
                  <dd>{campo.valor}</dd>
                </div>
              ))}
            </dl>
          )}
        </section>
      );
  }
}

// `artes`/`aoResolverImagem` são opcionais: sem eles (ou sem entrada correspondente no mapa), o PDF sai
// exatamente como antes da Q12.21 — só texto. `aoResolverImagem` é chamado uma vez por imagem, em onLoad OU
// onError (a página de impressão usa isso para saber quando liberar window.print()).
export default function AulaImpressao({
  modelo,
  artes,
  aoResolverImagem,
}: {
  modelo: AulaImpressaoModelo;
  artes?: MapaArtes;
  aoResolverImagem?: (assinatura: string) => void;
}) {
  return (
    <div className="impressao-pagina">
      <Capa modelo={modelo} />

      <div className="impressao-miolo">
        <CabecalhoInterno materiaNome={modelo.materiaNome} unidadeTitulo={modelo.unidadeTitulo} />

        <main className="impressao-conteudo-principal">
          {modelo.componentes.map((componente, indice) => renderizarComponente(componente, indice, artes, aoResolverImagem))}
        </main>

        {modelo.fontes.length > 0 && (
          <footer className="impressao-fontes">
            <p className="impressao-subsecao-rotulo">Fontes utilizadas nesta aula</p>
            <ul>
              {modelo.fontes.map((fonte, indice) => (
                <li key={indice}>
                  {fonte.titulo}
                  {fonte.tituloVersao ? ` — ${fonte.tituloVersao}` : ""}
                </li>
              ))}
            </ul>
          </footer>
        )}

        <p className="impressao-rodape-fechamento">
          PAPIRO · Material de estudo{modelo.unidadeTitulo ? ` · ${modelo.unidadeTitulo}` : ""} · versão {modelo.numeroVersao}
        </p>
      </div>
    </div>
  );
}
