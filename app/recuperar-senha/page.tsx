"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";

export default function RecuperarSenha() {
  const [email, setEmail] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

  async function recuperar(evento: FormEvent<HTMLFormElement>) {
    evento.preventDefault();
    setCarregando(true);
    setMensagem("");

    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/login`,
    });

    setMensagem(error ? `Não foi possível enviar: ${error.message}` : "Enviamos as instruções para o seu e-mail.");
    setCarregando(false);
  }

  return (
    <main className="auth-page">
      <section className="auth-card">
        <Link className="auth-brand" href="/">PAPIRO</Link>
        <p className="auth-label">RECUPERAÇÃO DE ACESSO</p>
        <h1>Recupere sua senha</h1>
        <p className="auth-description">Informe o e-mail usado no cadastro.</p>
        <form onSubmit={recuperar}>
          <label htmlFor="email">E-mail</label>
          <input id="email" type="email" value={email} onChange={(evento) => setEmail(evento.target.value)} autoComplete="email" required />
          <button type="submit" disabled={carregando}>{carregando ? "Enviando..." : "Enviar instruções"}</button>
        </form>
        {mensagem && <p className="auth-message" role="alert">{mensagem}</p>}
        <p className="auth-footer"><Link href="/login">Voltar para o login</Link></p>
      </section>
    </main>
  );
}
