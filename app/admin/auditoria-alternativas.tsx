"use client";

import { useState } from "react";
import {
  limparResiduoImportacao,
  temResiduoImportacao,
} from "@/utils/higiene-questoes.mjs";
import { createClient } from "@/utils/supabase/client";

type AlternativaAuditada = {
  id: number;
  questao_id: number;
  texto: string;
  ordem: number;
  questoes: { id: number; enunciado: string } | null;
};

export default function AuditoriaAlternativas() {
  const [suspeitas, setSuspeitas] = useState<AlternativaAuditada[]>([]);
  const [auditando, setAuditando] = useState(false);
  const [corrigindo, setCorrigindo] = useState(false);
  const [auditoriaRealizada, setAuditoriaRealizada] = useState(false);
  const [mensagem, setMensagem] = useState("");

  async function auditarAlternativas() {
    setAuditando(true);
    setMensagem("");

    const supabase = createClient();
    const todas: AlternativaAuditada[] = [];
    const tamanhoLote = 1000;

    for (let inicio = 0; ; inicio += tamanhoLote) {
      const { data, error } = await supabase
        .from("alternativas")
        .select("id, questao_id, texto, ordem, questoes(id, enunciado)")
        .order("id")
        .range(inicio, inicio + tamanhoLote - 1);

      if (error) {
        setMensagem(`Não foi possível auditar as alternativas: ${error.message}`);
        setAuditando(false);
        return;
      }

      const lote = (data as unknown as AlternativaAuditada[] | null) ?? [];
      todas.push(...lote);
      if (lote.length < tamanhoLote) break;
    }

    const encontradas = todas.filter((alternativa) => temResiduoImportacao(alternativa.texto));
    setSuspeitas(encontradas);
    setAuditoriaRealizada(true);
    setMensagem(
      encontradas.length === 0
        ? `Auditoria concluída: ${todas.length} alternativas verificadas e nenhum resíduo encontrado.`
        : `Auditoria concluída: ${encontradas.length} alternativa(s) com resíduo entre ${todas.length} verificadas.`,
    );
    setAuditando(false);
  }

  async function corrigirAlternativas() {
    if (suspeitas.length === 0) return;
    setCorrigindo(true);
    setMensagem("");

    const supabase = createClient();
    let corrigidas = 0;

    for (const alternativa of suspeitas) {
      const textoLimpo = limparResiduoImportacao(alternativa.texto);
      if (!textoLimpo || textoLimpo === alternativa.texto) continue;

      const { error } = await supabase
        .from("alternativas")
        .update({ texto: textoLimpo })
        .eq("id", alternativa.id);

      if (error) {
        setMensagem(
          `Foram corrigidas ${corrigidas} alternativa(s), mas a correção parou: ${error.message}`,
        );
        setCorrigindo(false);
        return;
      }

      corrigidas += 1;
    }

    setSuspeitas([]);
    setMensagem(`${corrigidas} alternativa(s) corrigida(s). Execute a auditoria novamente para confirmar.`);
    setCorrigindo(false);
  }

  return (
    <section className="admin-recent" aria-labelledby="auditoria-alternativas-titulo">
      <div className="admin-section-heading">
        <div>
          <p className="dashboard-label">QUALIDADE DO BANCO</p>
          <h2 id="auditoria-alternativas-titulo">Auditar alternativas</h2>
        </div>
        <button type="button" onClick={auditarAlternativas} disabled={auditando || corrigindo}>
          {auditando ? "Verificando..." : "Verificar resíduos"}
        </button>
      </div>

      <p>Procura rodapés e metadados de arquivos que tenham sido anexados ao texto das respostas.</p>
      {mensagem && <p className="method-message" role="status">{mensagem}</p>}

      {suspeitas.map((alternativa) => (
        <article key={alternativa.id}>
          <div>
            <strong>Questão {alternativa.questao_id} · alternativa {alternativa.ordem}</strong>
          </div>
          <p>{alternativa.questoes?.enunciado ?? "Enunciado indisponível"}</p>
          <small>Original: {alternativa.texto}</small>
          <p><strong>Sugestão limpa:</strong> {limparResiduoImportacao(alternativa.texto)}</p>
        </article>
      ))}

      {auditoriaRealizada && suspeitas.length > 0 && (
        <button type="button" onClick={corrigirAlternativas} disabled={corrigindo || auditando}>
          {corrigindo ? "Corrigindo..." : `Corrigir ${suspeitas.length} alternativa(s)`}
        </button>
      )}
    </section>
  );
}
