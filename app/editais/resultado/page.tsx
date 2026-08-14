"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";
type Materia = { id:number; materia:string; conteudo_programatico:string[]; peso:number|null; ordem:number };
type Edital = { id:string; concurso:string|null; cargo:string|null; banca:string|null; data_prova:string|null; resumo:string|null; arquivo_nome:string; status:string; edital_materias:Materia[] };
export default function ResultadoEdital(){
  const [edital,setEdital]=useState<Edital|null>(null); const [aberta,setAberta]=useState<number|null>(null); const [carregando,setCarregando]=useState(true);
  useEffect(()=>{async function carregar(){const supabase=createClient();const {data:{user}}=await supabase.auth.getUser();if(!user){window.location.replace("/login");return}const id=new URLSearchParams(window.location.search).get("id");if(!id){window.location.replace("/editais");return}const {data}=await supabase.from("editais").select("id, concurso, cargo, banca, data_prova, resumo, arquivo_nome, status, edital_materias(id, materia, conteudo_programatico, peso, ordem)").eq("id",id).single();setEdital(data as unknown as Edital|null);setCarregando(false)}carregar()},[]);
  if(carregando)return <main className="dashboard-loading"><MarcaCarregando texto="Organizando a análise..." /></main>;
  if(!edital)return <main className="dashboard-loading"><p>Não foi possível encontrar esta análise.</p><Link href="/editais">Voltar aos editais</Link></main>;
  const materias=[...(edital.edital_materias||[])].sort((a,b)=>a.ordem-b.ordem);
  return <main className="notice-result-page"><header className="notice-result-header"><div><p className="dashboard-label">ANÁLISE CONCLUÍDA</p><h1>{edital.concurso||edital.arquivo_nome}</h1><span>{edital.cargo||"Cargo não identificado"}</span></div><Link href="/editais">Voltar aos editais</Link></header>
  <section className="notice-result-summary"><article><span>Banca</span><strong>{edital.banca||"Não informada"}</strong></article><article><span>Data da prova</span><strong>{edital.data_prova?new Date(`${edital.data_prova}T00:00:00`).toLocaleDateString("pt-BR"):"Não informada"}</strong></article><article><span>Matérias encontradas</span><strong>{materias.length}</strong></article></section>
  <section className="notice-result-layout"><div className="notice-subjects"><div className="notice-section-title"><p className="dashboard-label">CONTEÚDO PROGRAMÁTICO</p><h2>O que precisa ser estudado</h2></div>{materias.length===0?<p className="notice-empty">Nenhuma matéria foi encontrada nesta análise.</p>:materias.map((materia,indice)=><article className={aberta===materia.id?"open":""} key={materia.id}><button type="button" onClick={()=>setAberta(aberta===materia.id?null:materia.id)}><span>{String(indice+1).padStart(2,"0")}</span><strong>{materia.materia}</strong><small>{materia.conteudo_programatico?.length||0} tópicos</small><b>{aberta===materia.id?"−":"+"}</b></button>{aberta===materia.id&&<ul>{materia.conteudo_programatico.map((topico,i)=><li key={`${materia.id}-${i}`}>{topico}</li>)}</ul>}</article>)}</div>
  <aside className="notice-result-aside"><p className="dashboard-label">RESUMO DA IA</p><h2>Leitura estratégica</h2><p>{edital.resumo||"O conteúdo foi estruturado e já pode ser usado no seu plano de estudos."}</p><Link href="/cronograma">Gerar meu cronograma</Link><small>O cronograma usará estas matérias como prioridade.</small></aside></section></main>;
}
