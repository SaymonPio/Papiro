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

export default function ComentariosQuestao({ questaoId }: { questaoId: number }) {
  const [aberto,setAberto]=useState(false);
  const [comentarios,setComentarios]=useState<Comentario[]>([]);
  const [texto,setTexto]=useState("");
  const [carregando,setCarregando]=useState(true);
  const [enviando,setEnviando]=useState(false);
  const [mensagem,setMensagem]=useState("");

  async function carregar() {
    const {data,error}=await createClient().rpc("listar_comentarios_questao",{p_questao_id:questaoId});
    setComentarios(error?[]:((data as Comentario[]|null)??[]));
    if(error) setMensagem("Não foi possível carregar os comentários agora.");
    setCarregando(false);
  }

  useEffect(()=>{
    let ativo=true;
    createClient().rpc("listar_comentarios_questao",{p_questao_id:questaoId}).then(({data,error})=>{
      if(!ativo) return;
      setComentarios(error?[]:((data as Comentario[]|null)??[]));
      if(error) setMensagem("Não foi possível carregar os comentários agora.");
      setCarregando(false);
    });
    return ()=>{ativo=false;};
  },[questaoId]);

  async function enviar(evento:FormEvent) {
    evento.preventDefault();
    const limpo=texto.trim();
    if(limpo.length<2||limpo.length>1000||enviando) return;
    setEnviando(true); setMensagem("");
    const {error}=await createClient().rpc("comentar_questao",{p_questao_id:questaoId,p_texto:limpo});
    setEnviando(false);
    if(error){setMensagem(error.message.includes("Aguarde")?error.message:"Não foi possível enviar seu comentário.");return;}
    setTexto(""); setMensagem("Comentário publicado."); await carregar();
  }

  async function remover(id:string) {
    const {error}=await createClient().rpc("remover_meu_comentario_questao",{p_comentario_id:id});
    if(error){setMensagem("Não foi possível remover o comentário.");return;}
    setComentarios(atuais=>atuais.filter(c=>c.comentario_id!==id));
    setMensagem("Comentário removido.");
  }

  return <section className={`questao-comentarios${aberto?" aberto":""}`}>
    <button
      type="button"
      className="questao-comentarios-toggle"
      aria-expanded={aberto}
      aria-controls={`comentarios-questao-${questaoId}`}
      onClick={()=>setAberto(valor=>!valor)}
    >
      <span><b aria-hidden="true">▣</b> Comentários da questão</span>
      <small>{carregando?"Carregando...":`${comentarios.length} comentário${comentarios.length===1?"":"s"}`}</small>
      <i aria-hidden="true">{aberto?"−":"+"}</i>
    </button>

    {aberto&&<div id={`comentarios-questao-${questaoId}`} className="questao-comentarios-conteudo">
      <p className="questao-comentarios-intro">Compartilhe dúvidas e observações sobre esta questão com outros alunos.</p>
      <div className="questao-comentarios-lista">
        {carregando?<p>Carregando comentários...</p>:comentarios.length===0?<div className="questao-comentarios-vazio"><h3>Seja o primeiro a comentar!</h3><p>A conversa desta questão ainda não começou.</p></div>:<>
          <h3>O que os alunos estão dizendo</h3>
          {comentarios.map(c=><article key={c.comentario_id}>
            <header><strong>{c.autor_nome}</strong><time dateTime={c.criado_em}>{new Date(c.criado_em).toLocaleString("pt-BR",{dateStyle:"short",timeStyle:"short"})}</time></header>
            <p>{c.texto}</p>
            {c.meu&&<button type="button" onClick={()=>remover(c.comentario_id)}>Remover meu comentário</button>}
          </article>)}
        </>}
      </div>
      <form onSubmit={enviar} className="questao-comentarios-form">
        <label htmlFor={`comentario-questao-${questaoId}`}>{comentarios.length===0?"Comece a conversa":"Participe da conversa"}</label>
        <textarea id={`comentario-questao-${questaoId}`} value={texto} onChange={e=>setTexto(e.target.value)} maxLength={1000} rows={4} placeholder="Ficou alguma dúvida ou tem um bizu para compartilhar?" />
        <div><small>{texto.length}/1000</small><button type="submit" disabled={enviando||texto.trim().length<2}>{enviando?"Publicando...":"Publicar comentário"}</button></div>
      </form>
      {mensagem&&<p className="questao-comentarios-mensagem" role="status">{mensagem}</p>}
    </div>}
  </section>;
}
