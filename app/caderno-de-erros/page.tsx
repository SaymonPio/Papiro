"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type ErroAluno = {
  id: number;
  tipo_erro: string | null;
  motivo_provavel: string | null;
  corrigido: boolean;
  criado_em: string;
  enunciado: string | null;
  materia_nome: string | null;
  assunto_nome: string | null;
  revisoes: { agendada_para: string; ordem: number; status: string }[];
};

export default function CadernoDeErros() {
  const [erros, setErros] = useState<ErroAluno[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [mensagem, setMensagem] = useState("");
  const [semContexto, setSemContexto] = useState(false);

  useEffect(() => {
    async function carregarErros() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      const { data: perfil } = await supabase
        .from("perfis")
        .select("curso_ativo_id")
        .eq("usuario_id", user.id)
        .maybeSingle();

      if (!perfil?.curso_ativo_id) {
        setMensagem("Selecione um curso ativo para ver seu caderno de erros.");
        setSemContexto(true);
        setCarregando(false);
        return;
      }

      const { data: matricula } = await supabase
        .from("matriculas")
        .select("id")
        .eq("usuario_id", user.id)
        .eq("curso_id", perfil.curso_ativo_id)
        .eq("status", "ativa")
        .maybeSingle();

      if (!matricula) {
        setMensagem("Sua matrícula no curso ativo não está disponível no momento.");
        setSemContexto(true);
        setCarregando(false);
        return;
      }

      const { data, error } = await supabase.rpc("erros_do_curso_ativo");

      if (error) {
        console.error("erros_do_curso_ativo falhou:", {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint,
        });
        setMensagem("Não foi possível carregar seu caderno de erros.");
      } else {
        setErros((data as ErroAluno[] | null) ?? []);
      }
      setCarregando(false);
    }
    carregarErros();
  }, []);

  if (carregando) return <main className="dashboard-loading"><p>Abrindo seu caderno...</p></main>;

  return (
    <main className="method-page error-notebook">
      <header className="method-header">
        <Link href="/painel">← Voltar ao painel</Link>
        <p className="dashboard-label">CADERNO DE ERROS</p>
        <h1>Todo erro vira revisão.</h1>
        <span>Entenda o motivo, corrija a falha e consolide o assunto.</span>
      </header>
      {semContexto ? (
        <p className="method-message" role="alert">{mensagem}</p>
      ) : (
        <>
          {mensagem && <p className="method-message" role="alert">{mensagem}</p>}
          {erros.length === 0 ? (
            <section className="empty-method-state"><h2>Nenhum erro registrado</h2><p>Quando você errar uma questão, ela aparecerá aqui com as revisões programadas.</p><Link href="/questoes">Iniciar sessão</Link></section>
          ) : (
            <section className="error-list">
              {erros.map((erro) => (
                <article key={erro.id}>
                  <div className="error-heading"><span>{erro.materia_nome ?? "Matéria geral"}</span><small>{new Date(erro.criado_em).toLocaleDateString("pt-BR")}</small></div>
                  <h2>{erro.assunto_nome ?? "Assunto geral"}</h2>
                  <p>{erro.enunciado}</p>
                  <div className="review-dates">
                    {[...erro.revisoes].sort((a, b) => a.ordem - b.ordem).map((revisao) => <span key={revisao.ordem}>{revisao.ordem}ª revisão <strong>{new Date(`${revisao.agendada_para}T00:00:00`).toLocaleDateString("pt-BR")}</strong></span>)}
                  </div>
                  <small className="error-type">{erro.tipo_erro ? erro.tipo_erro.replaceAll("_", " ") : "Tipo de erro ainda não classificado"}</small>
                </article>
              ))}
            </section>
          )}
        </>
      )}
    </main>
  );
}
