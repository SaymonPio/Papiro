"use client";

import Link from "next/link";
import { useEffect, useMemo, useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";

type Materia = { id: number; nome: string };
type Assunto = { id: number; materia_id: number; nome: string };
type QuestaoResumo = {
  id: number;
  enunciado: string;
  banca: string | null;
  dificuldade: string;
  materias: { nome: string } | null;
  assuntos: { nome: string } | null;
};

export default function Admin() {
  const [verificando, setVerificando] = useState(true);
  const [admin, setAdmin] = useState(false);
  const [materias, setMaterias] = useState<Materia[]>([]);
  const [assuntos, setAssuntos] = useState<Assunto[]>([]);
  const [questoes, setQuestoes] = useState<QuestaoResumo[]>([]);
  const [mensagem, setMensagem] = useState("");
  const [salvando, setSalvando] = useState(false);

  const [materiaNome, setMateriaNome] = useState("");
  const [materiaDescricao, setMateriaDescricao] = useState("");
  const [assuntoMateria, setAssuntoMateria] = useState("");
  const [assuntoNome, setAssuntoNome] = useState("");

  const [questaoMateria, setQuestaoMateria] = useState("");
  const [questaoAssunto, setQuestaoAssunto] = useState("");
  const [banca, setBanca] = useState("");
  const [concurso, setConcurso] = useState("");
  const [dificuldade, setDificuldade] = useState("media");
  const [enunciado, setEnunciado] = useState("");
  const [explicacao, setExplicacao] = useState("");
  const [alternativas, setAlternativas] = useState(["", "", "", ""]);
  const [correta, setCorreta] = useState(0);

  const assuntosDaMateria = useMemo(
    () => assuntos.filter((assunto) => String(assunto.materia_id) === questaoMateria),
    [assuntos, questaoMateria],
  );

  useEffect(() => {
    async function verificarAcesso() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }
      const { data } = await supabase.rpc("eh_admin");
      setAdmin(Boolean(data));
      setVerificando(false);
    }
    verificarAcesso();
  }, []);

  useEffect(() => {
    if (admin) carregarDados();
  }, [admin]);

  async function carregarDados() {
    const supabase = createClient();
    const [materiasResposta, assuntosResposta, questoesResposta] = await Promise.all([
      supabase.from("materias").select("id, nome").is("usuario_id", null).order("nome"),
      supabase.from("assuntos").select("id, materia_id, nome").is("usuario_id", null).order("nome"),
      supabase.from("questoes").select("id, enunciado, banca, dificuldade, materias(nome), assuntos(nome)").is("usuario_id", null).order("criado_em", { ascending: false }).limit(12),
    ]);
    setMaterias((materiasResposta.data as Materia[] | null) ?? []);
    setAssuntos((assuntosResposta.data as Assunto[] | null) ?? []);
    setQuestoes((questoesResposta.data as unknown as QuestaoResumo[] | null) ?? []);
  }

  async function ativarPrimeiroAdmin() {
    setSalvando(true);
    setMensagem("");
    const { data, error } = await createClient().rpc("reivindicar_primeiro_admin");
    if (error || !data) setMensagem("Já existe um administrador ou não foi possível ativar o acesso.");
    else { setAdmin(true); setMensagem("Área administrativa ativada para sua conta."); }
    setSalvando(false);
  }

  async function criarMateria(evento: FormEvent) {
    evento.preventDefault();
    setSalvando(true);
    const { error } = await createClient().from("materias").insert({ usuario_id: null, nome: materiaNome.trim(), descricao: materiaDescricao.trim() || null });
    setMensagem(error ? `Erro ao criar matéria: ${error.message}` : "Matéria criada com sucesso.");
    if (!error) { setMateriaNome(""); setMateriaDescricao(""); await carregarDados(); }
    setSalvando(false);
  }

  async function criarAssunto(evento: FormEvent) {
    evento.preventDefault();
    setSalvando(true);
    const { error } = await createClient().from("assuntos").insert({ usuario_id: null, materia_id: Number(assuntoMateria), nome: assuntoNome.trim() });
    setMensagem(error ? `Erro ao criar assunto: ${error.message}` : "Assunto criado com sucesso.");
    if (!error) { setAssuntoNome(""); await carregarDados(); }
    setSalvando(false);
  }

  async function criarQuestao(evento: FormEvent) {
    evento.preventDefault();
    setSalvando(true);
    setMensagem("");
    const supabase = createClient();
    const { data: questao, error: erroQuestao } = await supabase.from("questoes").insert({
      usuario_id: null,
      materia_id: Number(questaoMateria),
      assunto_id: questaoAssunto ? Number(questaoAssunto) : null,
      banca: banca.trim() || null,
      concurso: concurso.trim() || null,
      dificuldade,
      enunciado: enunciado.trim(),
      explicacao: explicacao.trim(),
      ativa: true,
    }).select("id").single();

    if (erroQuestao || !questao) {
      setMensagem(`Erro ao criar questão: ${erroQuestao?.message ?? "dados inválidos"}`);
      setSalvando(false);
      return;
    }

    const { error: erroAlternativas } = await supabase.from("alternativas").insert(
      alternativas.map((texto, indice) => ({ questao_id: questao.id, texto: texto.trim(), ordem: indice + 1, correta: indice === correta })),
    );

    if (erroAlternativas) {
      await supabase.from("questoes").delete().eq("id", questao.id);
      setMensagem(`Erro nas alternativas: ${erroAlternativas.message}`);
      setSalvando(false);
      return;
    }

    setMensagem("Questão publicada com sucesso e já disponível nas sessões.");
    setEnunciado(""); setExplicacao(""); setBanca(""); setConcurso(""); setAlternativas(["", "", "", ""]); setCorreta(0);
    await carregarDados();
    setSalvando(false);
  }

  if (verificando) return <main className="dashboard-loading"><p>Verificando acesso administrativo...</p></main>;

  if (!admin) {
    return (
      <main className="admin-page admin-activation">
        <section>
          <p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p>
          <h1>Ative o painel do proprietário</h1>
          <p>Somente o primeiro usuário autenticado poderá realizar esta ativação. Depois disso, novos usuários não terão acesso administrativo.</p>
          <button type="button" onClick={ativarPrimeiroAdmin} disabled={salvando}>{salvando ? "Ativando..." : "Ativar minha área administrativa"}</button>
          {mensagem && <p className="method-message" role="alert">{mensagem}</p>}
          <Link href="/painel">Voltar ao painel</Link>
        </section>
      </main>
    );
  }

  return (
    <main className="admin-page">
      <header className="admin-header">
        <div><p className="dashboard-label">ADMINISTRAÇÃO PAPIRO</p><h1>Conteúdo do banco de questões</h1><span>Cadastre conteúdo real sem abrir o editor de código.</span></div>
        <Link href="/painel">Voltar ao painel</Link>
      </header>

      {mensagem && <p className="method-message" role="status">{mensagem}</p>}

      <section className="admin-foundations">
        <form onSubmit={criarMateria}>
          <h2>1. Nova matéria</h2>
          <label htmlFor="materiaNome">Nome</label>
          <input id="materiaNome" value={materiaNome} onChange={(e) => setMateriaNome(e.target.value)} placeholder="Ex.: Direito Penal" required />
          <label htmlFor="materiaDescricao">Descrição</label>
          <textarea id="materiaDescricao" value={materiaDescricao} onChange={(e) => setMateriaDescricao(e.target.value)} placeholder="Descrição opcional" />
          <button disabled={salvando}>Salvar matéria</button>
        </form>

        <form onSubmit={criarAssunto}>
          <h2>2. Novo assunto</h2>
          <label htmlFor="assuntoMateria">Matéria</label>
          <select id="assuntoMateria" value={assuntoMateria} onChange={(e) => setAssuntoMateria(e.target.value)} required>
            <option value="">Selecione</option>{materias.map((materia) => <option key={materia.id} value={materia.id}>{materia.nome}</option>)}
          </select>
          <label htmlFor="assuntoNome">Nome do assunto</label>
          <input id="assuntoNome" value={assuntoNome} onChange={(e) => setAssuntoNome(e.target.value)} placeholder="Ex.: Crimes contra a Administração" required />
          <button disabled={salvando || materias.length === 0}>Salvar assunto</button>
        </form>
      </section>

      <form className="admin-question-form" onSubmit={criarQuestao}>
        <div className="admin-section-heading"><div><p className="dashboard-label">ETAPA 3</p><h2>Publicar nova questão</h2></div><span>{questoes.length} recentes</span></div>
        <div className="admin-form-grid">
          <label>Matéria<select value={questaoMateria} onChange={(e) => { setQuestaoMateria(e.target.value); setQuestaoAssunto(""); }} required><option value="">Selecione</option>{materias.map((materia) => <option key={materia.id} value={materia.id}>{materia.nome}</option>)}</select></label>
          <label>Assunto<select value={questaoAssunto} onChange={(e) => setQuestaoAssunto(e.target.value)}><option value="">Geral</option>{assuntosDaMateria.map((assunto) => <option key={assunto.id} value={assunto.id}>{assunto.nome}</option>)}</select></label>
          <label>Banca<input value={banca} onChange={(e) => setBanca(e.target.value)} placeholder="Ex.: Fundatec" /></label>
          <label>Concurso<input value={concurso} onChange={(e) => setConcurso(e.target.value)} placeholder="Ex.: Polícia Penal RS" /></label>
          <label>Dificuldade<select value={dificuldade} onChange={(e) => setDificuldade(e.target.value)}><option value="facil">Fácil</option><option value="media">Média</option><option value="dificil">Difícil</option></select></label>
        </div>
        <label>Enunciado<textarea value={enunciado} onChange={(e) => setEnunciado(e.target.value)} rows={5} required /></label>
        <fieldset className="admin-alternatives"><legend>Alternativas — marque a correta</legend>{alternativas.map((texto, indice) => <label key={indice}><input type="radio" name="correta" checked={correta === indice} onChange={() => setCorreta(indice)} /><b>{String.fromCharCode(65 + indice)}</b><input value={texto} onChange={(e) => setAlternativas((atuais) => atuais.map((item, i) => i === indice ? e.target.value : item))} required /></label>)}</fieldset>
        <label>Explicação da resposta<textarea value={explicacao} onChange={(e) => setExplicacao(e.target.value)} rows={5} placeholder="Explique por que a alternativa está correta e as demais estão erradas." required /></label>
        <button className="admin-publish" disabled={salvando || materias.length === 0}>{salvando ? "Publicando..." : "Publicar questão"}</button>
      </form>

      <section className="admin-recent">
        <h2>Questões recentes</h2>
        {questoes.length === 0 ? <p>Nenhuma questão publicada ainda.</p> : questoes.map((questao) => <article key={questao.id}><div><strong>{questao.materias?.nome}</strong><span>{questao.assuntos?.nome ?? "Geral"}</span></div><p>{questao.enunciado}</p><small>{questao.banca ?? "Sem banca"} · {questao.dificuldade}</small></article>)}
      </section>
    </main>
  );
}
