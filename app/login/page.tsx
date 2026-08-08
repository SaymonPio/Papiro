"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";

export default function Login() {
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

  async function entrar(evento: FormEvent<HTMLFormElement>) {
    evento.preventDefault();
    setCarregando(true);
    setMensagem("");

    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password: senha,
    });

    if (error) {
      setMensagem("E-mail ou senha incorretos.");
      setCarregando(false);
      return;
    }

    window.location.replace("/painel");
  }

  return (
    <main className="auth-page">
      <section className="auth-card">
        <Link className="auth-brand" href="/">PAPIRO</Link>
        <p className="auth-label">PREPARAÇÃO PARA CONCURSOS</p>
        <h1>Entre na sua conta</h1>
        <p className="auth-description">
          Acesse seu plano de estudos e acompanhe sua evolução.
        </p>

        <form onSubmit={entrar}>
          <label htmlFor="email">E-mail</label>
          <input id="email" type="email" value={email} onChange={(evento) => setEmail(evento.target.value)} autoComplete="email" required />

          <label htmlFor="senha">Senha</label>
          <input id="senha" type="password" value={senha} onChange={(evento) => setSenha(evento.target.value)} autoComplete="current-password" required />

          <Link className="auth-forgot" href="/recuperar-senha">Esqueci minha senha</Link>
          <button type="submit" disabled={carregando}>{carregando ? "Entrando..." : "Entrar"}</button>
        </form>

        {mensagem && <p className="auth-message" role="alert">{mensagem}</p>}
        <p className="auth-footer">Ainda não possui conta? <Link href="/cadastro">Cadastre-se</Link></p>
      </section>
    </main>
  );
}
