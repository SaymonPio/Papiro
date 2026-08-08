"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";

export default function Cadastro() {
  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

  async function cadastrar(evento: FormEvent<HTMLFormElement>) {
    evento.preventDefault();
    setCarregando(true);
    setMensagem("");

    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({
      email,
      password: senha,
      options: { data: { nome } },
    });

    if (error) {
      setMensagem(`Não foi possível criar a conta: ${error.message}`);
    } else if (data.session) {
      window.location.replace("/configuracao");
      return;
    } else {
      setMensagem("Cadastro realizado! Confira seu e-mail para confirmar a conta.");
      setNome("");
      setEmail("");
      setSenha("");
    }

    setCarregando(false);
  }

  return (
    <main className="auth-page">
      <section className="auth-card">
        <Link className="auth-brand" href="/">PAPIRO</Link>
        <p className="auth-label">PREPARAÇÃO PARA CONCURSOS</p>
        <h1>Crie sua conta</h1>
        <p className="auth-description">Comece sua preparação e receba um plano feito para o seu objetivo.</p>

        <form onSubmit={cadastrar}>
          <label htmlFor="nome">Nome</label>
          <input id="nome" type="text" value={nome} onChange={(evento) => setNome(evento.target.value)} autoComplete="name" required />
          <label htmlFor="email">E-mail</label>
          <input id="email" type="email" value={email} onChange={(evento) => setEmail(evento.target.value)} autoComplete="email" required />
          <label htmlFor="senha">Senha</label>
          <input id="senha" type="password" value={senha} onChange={(evento) => setSenha(evento.target.value)} autoComplete="new-password" minLength={6} required />
          <button type="submit" disabled={carregando}>{carregando ? "Criando conta..." : "Criar minha conta"}</button>
        </form>

        {mensagem && <p className="auth-message" role="alert">{mensagem}</p>}
        <p className="auth-footer">Já possui uma conta? <Link href="/login">Entrar</Link></p>
      </section>
    </main>
  );
}
