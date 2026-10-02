"use client";

import Link from "next/link";
import { useId, useState, type ChangeEvent, type FormEvent } from "react";
import { Eye, EyeOff } from "lucide-react";
import styles from "../../app/login/login.module.css";

type LoginFormProps = {
  email: string;
  senha: string;
  mensagem: string;
  carregando: boolean;
  onEmailChange: (value: string) => void;
  onSenhaChange: (value: string) => void;
  onSubmit: (evento: FormEvent<HTMLFormElement>) => void;
};

// Puramente apresentacional — toda a lógica de autenticação (estado de email/senha,
// chamada ao Supabase, redirect) continua em app/login/page.tsx e chega aqui via props,
// sem nenhuma alteração. O único estado local daqui é mostrar/ocultar a senha, que é
// só de UI e não afeta o fluxo de login.
export function LoginForm({
  email,
  senha,
  mensagem,
  carregando,
  onEmailChange,
  onSenhaChange,
  onSubmit,
}: LoginFormProps) {
  const [showPassword, setShowPassword] = useState(false);
  const mensagemId = useId();

  return (
    <div className={styles.formColumn}>
      <div className={styles.formInner}>
        <Link className={styles.brand} href="/">PAPIRO</Link>
        <p className={styles.eyebrow}>PREPARAÇÃO PARA CONCURSOS</p>

        <h1 className={styles.heading}>Entre na sua conta</h1>
        <p className={styles.subtext}>
          Acesse seu plano de estudos e acompanhe sua evolução.
        </p>

        <form className={styles.form} onSubmit={onSubmit} noValidate={false}>
          <div className={styles.field}>
            <label htmlFor="email">E-mail</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(evento: ChangeEvent<HTMLInputElement>) => onEmailChange(evento.target.value)}
              autoComplete="email"
              aria-describedby={mensagem ? mensagemId : undefined}
              required
            />
          </div>

          <div className={styles.field}>
            <label htmlFor="senha">Senha</label>
            <div className={styles.passwordWrap}>
              <input
                id="senha"
                type={showPassword ? "text" : "password"}
                value={senha}
                onChange={(evento: ChangeEvent<HTMLInputElement>) => onSenhaChange(evento.target.value)}
                autoComplete="current-password"
                aria-describedby={mensagem ? mensagemId : undefined}
                required
              />
              <button
                type="button"
                className={styles.passwordToggle}
                onClick={() => setShowPassword((value) => !value)}
                aria-label={showPassword ? "Ocultar senha" : "Mostrar senha"}
              >
                {showPassword ? <EyeOff size={18} aria-hidden="true" /> : <Eye size={18} aria-hidden="true" />}
              </button>
            </div>
          </div>

          <Link className={styles.forgot} href="/recuperar-senha">Esqueci minha senha</Link>

          <button type="submit" className={styles.submit} disabled={carregando}>
            {carregando ? "Entrando..." : "Entrar"}
          </button>
        </form>

        {mensagem && (
          <p id={mensagemId} className={styles.message} role="alert">
            {mensagem}
          </p>
        )}

        <p className={styles.footer}>
          Ainda não possui conta? <Link href="/cadastro">Cadastre-se</Link>
        </p>
      </div>
    </div>
  );
}
