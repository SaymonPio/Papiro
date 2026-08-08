"use client";

import Link from "next/link";
import { ChangeEvent, DragEvent, useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type Edital = { id: string; arquivo_nome: string; status: string; concurso: string | null; banca: string | null; criado_em: string };

export default function Editais() {
  const [arquivo, setArquivo] = useState<File | null>(null);
  const [editais, setEditais] = useState<Edital[]>([]);
  const [enviando, setEnviando] = useState(false);
  const [mensagem, setMensagem] = useState("");
  const [arrastando, setArrastando] = useState(false);
  const [processandoId, setProcessandoId] = useState<string | null>(null);

  async function carregar() {
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { window.location.replace("/login"); return; }
    const { data } = await supabase.from("editais").select("id, arquivo_nome, status, concurso, banca, criado_em").order("criado_em", { ascending: false });
    setEditais((data as Edital[] | null) ?? []);
  }

  useEffect(() => { carregar(); }, []);

  function selecionar(file?: File) {
    setMensagem("");
    if (!file) return;
    if (file.type !== "application/pdf") { setMensagem("Escolha um arquivo no formato PDF."); return; }
    if (file.size > 25 * 1024 * 1024) { setMensagem("O edital deve ter no máximo 25 MB."); return; }
    setArquivo(file);
  }

  async function enviar() {
    if (!arquivo) return;
    setEnviando(true); setMensagem("");
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { window.location.replace("/login"); return; }
    const id = crypto.randomUUID();
    const caminho = `${user.id}/${id}.pdf`;
    const { error: erroArquivo } = await supabase.storage.from("editais").upload(caminho, arquivo, { contentType: "application/pdf", upsert: false });
    if (erroArquivo) { setMensagem("Não foi possível enviar o PDF. A estrutura do banco precisa ser ativada."); setEnviando(false); return; }
    const { error } = await supabase.from("editais").insert({ id, usuario_id: user.id, arquivo_nome: arquivo.name, arquivo_path: caminho, tamanho_bytes: arquivo.size, status: "aguardando_ia" });
    if (error) { await supabase.storage.from("editais").remove([caminho]); setMensagem("Não foi possível registrar o edital."); setEnviando(false); return; }
    setArquivo(null); setMensagem("Edital enviado. Iniciando a leitura pela IA..."); setEnviando(false); await analisar(id);
  }

  async function analisar(id: string) {
    setProcessandoId(id); setMensagem("A IA está lendo o edital. Isso pode levar alguns minutos.");
    const { error } = await createClient().functions.invoke("processar-edital", { body: { editalId: id } });
    setProcessandoId(null);
    setMensagem(error ? "Não foi possível concluir agora. Use o botão Analisar novamente." : "Leitura concluída. Concurso e matérias já foram organizados.");
    await carregar();
  }

  function soltar(evento: DragEvent<HTMLLabelElement>) { evento.preventDefault(); setArrastando(false); selecionar(evento.dataTransfer.files[0]); }
  function alterar(evento: ChangeEvent<HTMLInputElement>) { selecionar(evento.target.files?.[0]); }

  return <main className="notices-page">
    <header className="notices-header"><div><p className="dashboard-label">LEITURA INTELIGENTE</p><h1>Transforme seu edital em direção.</h1><span>Envie o PDF. O Papiro organizará concurso, banca, matérias e conteúdo programático.</span></div><Link href="/painel">Voltar ao painel</Link></header>
    <section className="notices-grid">
      <article className="upload-panel">
        <div className="upload-heading"><span>01</span><div><small>NOVO EDITAL</small><h2>Envie o documento oficial</h2></div></div>
        <label className={`pdf-dropzone ${arrastando ? "dragging" : ""}`} onDragOver={(e) => { e.preventDefault(); setArrastando(true); }} onDragLeave={() => setArrastando(false)} onDrop={soltar}>
          <input type="file" accept="application/pdf,.pdf" onChange={alterar} />
          <b>PDF</b><strong>{arquivo ? arquivo.name : "Arraste o edital ou clique para escolher"}</strong><span>{arquivo ? `${(arquivo.size / 1024 / 1024).toFixed(1)} MB` : "Arquivo PDF de até 25 MB"}</span>
        </label>
        <button type="button" onClick={enviar} disabled={!arquivo || enviando}>{enviando ? "Enviando edital..." : "Enviar para análise"}</button>
        {mensagem && <p className="upload-message" role="status">{mensagem}</p>}
        <div className="privacy-note"><b>Documento protegido</b><span>Cada aluno acessa somente os próprios editais.</span></div>
      </article>
      <aside className="analysis-flow"><p className="dashboard-label">O QUE A IA FARÁ</p><h2>Do PDF ao plano de estudos</h2><ol><li><b>1</b><span><strong>Ler o edital</strong>Identificar as informações oficiais.</span></li><li><b>2</b><span><strong>Organizar o conteúdo</strong>Separar matérias e assuntos.</span></li><li><b>3</b><span><strong>Gerar o plano</strong>Distribuir o estudo até a prova.</span></li></ol></aside>
    </section>
    <section className="notice-history"><div><p className="dashboard-label">SEUS EDITAIS</p><h2>Histórico de processamento</h2></div>{editais.length === 0 ? <p className="notice-empty">Seu primeiro edital aparecerá aqui após o envio.</p> : <div>{editais.map((edital) => <article key={edital.id}><span className={`notice-status ${edital.status}`}>{edital.status === "concluido" ? "Concluído" : edital.status === "erro" ? "Atenção" : edital.status === "processando" ? "Processando" : "Aguardando IA"}</span><div><strong>{edital.concurso || edital.arquivo_nome}</strong><small>{edital.banca || "Identificação pendente"} · {new Date(edital.criado_em).toLocaleDateString("pt-BR")}</small></div>{edital.status === "concluido" ? <Link href={`/editais/resultado?id=${edital.id}`}>Ver análise</Link> : <button className="notice-analyze" type="button" disabled={processandoId === edital.id} onClick={() => analisar(edital.id)}>{processandoId === edital.id ? "Analisando..." : "Analisar agora"}</button>}</article>)}</div>}</section>
  </main>;
}
