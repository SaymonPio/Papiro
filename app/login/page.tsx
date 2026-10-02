"use client";

import { useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";
import { LoginForm } from "@/components/auth/LoginForm";
import { LoginShowcase } from "@/components/auth/LoginShowcase";
import styles from "./login.module.css";

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
    <main className={styles.loginPage}>
      <LoginForm
        email={email}
        senha={senha}
        mensagem={mensagem}
        carregando={carregando}
        onEmailChange={setEmail}
        onSenhaChange={setSenha}
        onSubmit={entrar}
      />
      <LoginShowcase />
    </main>
  );
}
