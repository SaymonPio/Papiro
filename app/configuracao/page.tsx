"use client";

import { useEffect, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { cursosDisponiveis } from "@/lib/cursos";
import { createClient } from "@/utils/supabase/client";

const supabase = createClient();

export default function Configuracao() {
  const router = useRouter();
  const [cursoSelecionado, setCursoSelecionado] = useState<string | null>(null);
  const [horasDiarias, setHorasDiarias] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);
  const horasInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    async function verificarUsuario() {
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session) {
        window.location.replace("/login");
      }
    }

    verificarUsuario();
  }, []);

  function selecionarConcurso(id: string) {
    setMensagem("");
    setCursoSelecionado(id);

    window.requestAnimationFrame(() => {
      const campoHoras = horasInputRef.current;

      if (!campoHoras) {
        return;
      }

      const reduzirMovimento = window.matchMedia(
        "(prefers-reduced-motion: reduce)",
      ).matches;

      campoHoras.scrollIntoView({
        behavior: reduzirMovimento ? "auto" : "smooth",
        block: "center",
      });
      campoHoras.focus({ preventScroll: true });
    });
  }

  async function salvarObjetivos(evento: FormEvent<HTMLFormElement>) {
    evento.preventDefault();
    setMensagem("");

    if (!cursoSelecionado) {
      setMensagem("Selecione um concurso.");
      return;
    }

    setCarregando(true);

    const {
      data: { user },
      error: erroUsuario,
    } = await supabase.auth.getUser();

    if (erroUsuario || !user) {
      setMensagem("Sua sessão expirou. Entre novamente.");
      setCarregando(false);
      window.location.replace("/login");
      return;
    }

    const { error } = await supabase.rpc("configurar_curso_usuario", {
      p_curso_id: cursoSelecionado,
      p_horas_diarias: Number(horasDiarias),
    });

    if (error) {
      setMensagem(`Erro ao salvar: ${error.message}`);
      setCarregando(false);
      return;
    }

    setMensagem("Concurso configurado com sucesso!");

    setTimeout(() => {
      router.push("/cronograma");
    }, 800);
  }

  return (
    <main className="course-page">
      <header className="course-header">
        <a href="/" className="course-back">
          ← VOLTAR
        </a>

        <p>CONFIGURAÇÃO DO PLANO</p>
        <h1>ESCOLHA SEU CONCURSO</h1>
        <span>
          Escolha o concurso do seu plano de estudos.
        </span>
      </header>

      <form className="course-form" onSubmit={salvarObjetivos}>
        <section>
          <div className="course-section-title">
            <h2>CURSOS DISPONÍVEIS</h2>

            <span>{cursoSelecionado ? "1 selecionado" : "Nenhum selecionado"}</span>
          </div>

          <div className="course-grid">
            {cursosDisponiveis.map((concurso) => {
              const selecionado = concurso.id === cursoSelecionado;

              return (
                <button
                  type="button"
                  key={concurso.id}
                  className={`course-card ${
                    selecionado ? "course-card-selected" : ""
                  }`}
                  onClick={() => selecionarConcurso(concurso.id)}
                  aria-pressed={selecionado}
                >
                  <img
                    src={concurso.imagem}
                    alt={`Capa do curso ${concurso.concurso}`}
                  />

                  <span className="course-card-check">
                    {selecionado ? "✓ SELECIONADO" : "+ SELECIONAR"}
                  </span>

                  <span className="course-card-information">
                    <strong>{concurso.concurso}</strong>
                    <small>{concurso.cargo}</small>
                    <small>Banca: {concurso.banca}</small>

                    <small>
                      {concurso.previsao ? "Data prevista: " : "Data: "}
                      {concurso.dataExibicao}
                    </small>
                  </span>
                </button>
              );
            })}
          </div>
        </section>

        <section className="course-hours">
          <label htmlFor="horasDiarias">
            Quantas horas você pode estudar por dia?
          </label>

          <input
            ref={horasInputRef}
            id="horasDiarias"
            type="number"
            min="0.5"
            max="16"
            step="0.5"
            placeholder="Ex.: 3"
            value={horasDiarias}
            onChange={(evento) => setHorasDiarias(evento.target.value)}
            required
          />

          <button
            className="course-save"
            type="submit"
            disabled={carregando}
          >
            {carregando ? "SALVANDO..." : "MONTAR MEU PLANO"}
          </button>

          {mensagem && (
            <p className="course-message" role="alert">
              {mensagem}
            </p>
          )}
        </section>
      </form>
    </main>
  );
}
