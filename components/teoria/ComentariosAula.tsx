"use client";

import { FormEvent, useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type Comentario = {
  comentario_id: string;
  autor_nome: string;
  texto: string;
  criado_em: string;
  meu: boolean;
};

export default function ComentariosAula({ aulaId, modoPrevia=false }: { aulaId: string; modoPrevia?: boolean }) {
  const [comentarios,setComentarios]=useState<Comentario[]>([]);
  const [texto,setTexto]=useState("");
  const [carregando,setCarregando]=useState(!modoPrevia);
  const [enviando,setEnviando]=useState(false);
  const [mensagem,setMensagem]=useState("");

  async function carregar() {
    const {data,error}=await createClient().rpc("listar_comentarios_aula",{p_aula_id:aulaId});
    setComentarios(error?[]:((data as Comentario[]|null)??[]));
    if(error) setMensagem("Não foi possível carregar os comentários agora.");
    setCarregando(false);
  }

  useEffect(()=>{ if(!modoPrevia) carregar(); },[aulaId,modoPrevia]);

  async function enviar(evento:FormEvent) {
    evento.preventDefault();
    const limpo=texto.trim();
    if(modoPrevia||limpo.length<2||limpo.length>1000||enviando) return;
    setEnviando(true); setMensagem("");
    const {error}=await createClient().rpc("comentar_aula",{p_aula_id:aulaId,p_texto:limpo});
    setEnviando(false);
    if(error){setMensagem(error.message.includes("Aguarde")?error.message:"Não foi possível enviar seu comentário.");return;}
    setTexto(""); setMensagem("Comentário publicado."); await carregar();
  }

  async function remover(id:string) {
    const {error}=await createClient().rpc("remover_meu_comentario_aula",{p_comentario_id:id});
    if(error){setMensagem("Não foi possível remover o comentário.");return;}
    setComentarios(atuais=>atuais.filter(c=>c.comentario_id!==id));
    setMensagem("Comentário removido.");
  }

  return <section className="teoria-comentarios" aria-labelledby="comentarios-aula-titulo">
    <div className="teoria-comentarios-cabecalho">
      <div><p><span aria-hidden="true">▣</span> COMENTÁRIOS</p><h2 id="comentarios-aula-titulo">Conversa da comunidade</h2></div>
      <span>{comentarios.length} comentário{comentarios.length===1?"":"s"}</span>
    </div>
    <p className="teoria-comentarios-intro">Compartilhe dúvidas, observações e bizus com outros alunos. Mantenha a conversa respeitosa e dentro do tema da aula.</p>
    <div className="teoria-comentarios-lista">
      {carregando?<p>Carregando comentários...</p>:comentarios.length===0?<div className="teoria-comentarios-vazio"><h3>Seja o primeiro a comentar!</h3><p>Esta conversa ainda não começou. Compartilhe sua impressão ou uma dúvida sobre a aula.</p></div>:<>
        <h3>O que os alunos estão dizendo</h3>
        {comentarios.map(c=><article key={c.comentario_id}>
          <header><strong>{c.autor_nome}</strong><time dateTime={c.criado_em}>{new Date(c.criado_em).toLocaleString("pt-BR",{dateStyle:"short",timeStyle:"short"})}</time></header>
          <p>{c.texto}</p>
          {c.meu&&<button type="button" onClick={()=>remover(c.comentario_id)}>Remover meu comentário</button>}
        </article>)}
      </>}
    </div>
    <form onSubmit={enviar} className="teoria-comentarios-form">
      <label htmlFor="comentario-aula">{comentarios.length===0?"Comece a conversa":"Participe da conversa"}</label>
      <textarea id="comentario-aula" value={texto} onChange={e=>setTexto(e.target.value)} maxLength={1000} rows={4} disabled={modoPrevia} placeholder={modoPrevia?"A comunidade será aberta quando esta aula for publicada.":"O que você achou da aula? Ficou alguma dúvida?"} />
      <div><small>{modoPrevia?"Prévia administrativa":`${texto.length}/1000`}</small><button type="submit" disabled={modoPrevia||enviando||texto.trim().length<2}>{enviando?"Publicando...":"Publicar comentário"}</button></div>
    </form>
    {mensagem&&<p className="teoria-comentarios-mensagem" role="status">{mensagem}</p>}
  </section>;
}
