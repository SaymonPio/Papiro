"use client";

import { useEffect, useState, type FormEvent } from "react";
import { createClient } from "@/utils/supabase/client";

const supabase = createClient();

type Concurso = {
  id: string;
  carreira: string;
  concurso: string;
  cargo: string;
  banca: string;
  dataProva: string;
  dataExibicao: string;
  imagem: string;
  previsao: boolean;
};

const concursos: Concurso[] = [
  {
    id: "gm-alvorada",
    carreira: "Guarda Municipal",
    concurso: "Guarda Municipal de Alvorada",
    cargo: "Guarda Municipal",
    banca: "Fundatec",
    dataProva: "2026-11-15",
    dataExibicao: "15/11/2026",
    imagem: "/cursos/gm-alvorada.png",
    previsao: true,
  },
  {
    id: "pc-parana",
    carreira: "Polícia Civil",
    concurso: "Polícia Civil do Paraná",
    cargo: "Agente de Polícia Judiciária",
    banca: "FGV",
    dataProva: "2026-10-11",
    dataExibicao: "11/10/2026",
    imagem: "/cursos/pc-parana.png",
    previsao: false,
  },
  {
    id: "brigada-militar-rs",
    carreira: "Polícia Militar",
    concurso: "Brigada Militar do Rio Grande do Sul",
    cargo: "Soldado de Primeira Classe",
    banca: "Fundatec",
    dataProva: "2027-03-14",
    dataExibicao: "14/03/2027",
    imagem: "/cursos/brigada-militar-rs.png",
    previsao: true,
  },
];

export default function Configuracao() {
  const [selecionados, setSelecionados] = useState<string[]>([]);
  const [horasDiarias, setHorasDiarias] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

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

    setSelecionados((atuais) => {
      if (atuais.includes(id)) {
        return atuais.filter((item) => item !== id);
      }

      return [...atuais, id];
    });
  }

  async function salvarObjetivos(evento: FormEvent<HTMLFormElement>) {
    evento.preventDefault();
    setMensagem("");

    if (selecionados.length === 0) {
      setMensagem("Selecione pelo menos um concurso.");
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

    const objetivosSelecionados = concursos
      .filter((concurso) => selecionados.includes(concurso.id))
      .map((concurso) => ({
        usuario_id: user.id,
        carreira: concurso.carreira,
        concurso: concurso.concurso,
        cargo: concurso.cargo,
        banca: concurso.banca,
        data_prova: concurso.dataProva,
        horas_diarias: Number(horasDiarias),
      }));

    const { error: erroExclusao } = await supabase
      .from("objetivos")
      .delete()
      .eq("usuario_id", user.id);

    if (erroExclusao) {
      setMensagem(`Erro ao atualizar objetivos: ${erroExclusao.message}`);
      setCarregando(false);
      return;
    }

    const { error: erroSalvamento } = await supabase
      .from("objetivos")
      .insert(objetivosSelecionados);

    if (erroSalvamento) {
      setMensagem(`Erro ao salvar: ${erroSalvamento.message}`);
      setCarregando(false);
      return;
    }

    setMensagem("Concursos salvos com sucesso!");

    setTimeout(() => {
      window.location.replace("/painel");
    }, 800);
  }

  return (
    <main className="course-page">
      <header className="course-header">
        <a href="/" className="course-back">
          ← VOLTAR
        </a>

        <p>CONFIGURAÇÃO DO PLANO</p>
        <h1>ESCOLHA SEUS CONCURSOS</h1>
        <span>
          Você pode selecionar um ou mais concursos para o seu plano.
        </span>
      </header>

      <form className="course-form" onSubmit={salvarObjetivos}>
        <section>
          <div className="course-section-title">
            <h2>CURSOS DISPONÍVEIS</h2>

            <span>
              {selecionados.length} selecionado
              {selecionados.length === 1 ? "" : "s"}
            </span>
          </div>

          <div className="course-grid">
            {concursos.map((concurso) => {
              const selecionado = selecionados.includes(concurso.id);

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
