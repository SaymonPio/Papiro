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

export default function ComentariosAula({ aulaId }: { aulaId: string }) {
  const [comentarios,setComentarios]=useState<Comentario[]>([]);
  const [texto,setTexto]=useState("");
  const [carregando,setCarregando]=useState(true);
  const [enviando,setEnviando]=useState(false);
  const [mensagem,setMensagem]=useState("");

  async function carregar() {
    const {data,error}=await createClient().rpc("listar_comentarios_aula",{p_aula_id:aulaId});
    setComentarios(error?[]:((data as Comentario[]|null)??[]));
    if(error) setMensagem("Não foi possível carregar os comentários agora.");
    setCarregando(false);
  }

  useEffect(()=>{ carregar(); },[aulaId]);

  async function enviar(evento:FormEvent) {
    evento.preventDefault();
    const limpo=texto.trim();
    if(limpo.length<2||limpo.length>1000||enviando) return;
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
      <div><p>COMUNIDADE PAPIRO</p><h2 id="comentarios-aula-titulo">Comentários sobre a aula</h2></div>
      <span>{comentarios.length} comentário{comentarios.length===1?"":"s"}</span>
    </div>
    <p className="teoria-comentarios-intro">Compartilhe dúvidas, observações e bizus com outros alunos. Mantenha a conversa respeitosa e dentro do tema da aula.</p>
    <form onSubmit={enviar} className="teoria-comentarios-form">
      <label htmlFor="comentario-aula">Deixe seu comentário</label>
      <textarea id="comentario-aula" value={texto} onChange={e=>setTexto(e.target.value)} maxLength={1000} rows={4} placeholder="O que você achou da aula? Ficou alguma dúvida?" />
      <div><small>{texto.length}/1000</small><button type="submit" disabled={enviando||texto.trim().length<2}>{enviando?"Publicando...":"Publicar comentário"}</button></div>
    </form>
    {mensagem&&<p className="teoria-comentarios-mensagem" role="status">{mensagem}</p>}
    <div className="teoria-comentarios-lista">
      {carregando?<p>Carregando comentários...</p>:comentarios.length===0?<p>Ainda não há comentários. Seja o primeiro a participar.</p>:comentarios.map(c=><article key={c.comentario_id}>
        <header><strong>{c.autor_nome}</strong><time dateTime={c.criado_em}>{new Date(c.criado_em).toLocaleString("pt-BR",{dateStyle:"short",timeStyle:"short"})}</time></header>
        <p>{c.texto}</p>
        {c.meu&&<button type="button" onClick={()=>remover(c.comentario_id)}>Remover meu comentário</button>}
      </article>)}
    </div>
  </section>;
}
