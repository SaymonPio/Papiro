"use client";

import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { createClient } from "@/utils/supabase/client";
import CronometroEstudo from "./CronometroEstudo";
import { useSessaoTempo, type UseSessaoTempoResultado } from "./useSessaoTempo";

// Horas Líquidas — Cronômetro Livre precisa ficar visível enquanto o
// aluno navega entre áreas autenticadas (/meu-estudo, /painel,
// /estatisticas, ...), nunca só dentro de /meu-estudo. A árvore de rotas
// deste projeto (app/) não tem nenhum layout.tsx compartilhado só pelas
// páginas autenticadas — app/painel/layout.tsx cobre só /painel (as
// demais, /meu-estudo, /questoes, /estatisticas, são irmãs no mesmo
// nível, fora dele). O único ancestral realmente compartilhado por TODAS
// é app/layout.tsx (raiz, que também envolve landing/login). Por isso
// este provider é montado ali: o Next App Router preserva a árvore de um
// layout entre navegações client-side via <Link> (confirmado:
// StudentAppShell usa next/link), então esta MESMA instância de
// useSessaoTempo sobrevive a /meu-estudo -> /painel -> /estatisticas sem
// recriar nada. Em páginas públicas (landing/login) fica ocioso: sem
// usuário autenticado, matriculaId nunca resolve, e o hook nunca chama
// nenhuma RPC enquanto matriculaId for null (ver useSessaoTempo.ts).
//
// Resolve sua própria matrícula ativa aqui — não reaproveita o
// protegerPagina()/matriculaId de nenhuma página individual (cada uma
// continua com seu próprio redirecionamento de login, intacto). Isto é
// uma leitura adicional, paralela e somente-SELECT, só para alimentar o
// cronômetro global; nunca substitui nem altera a proteção de rota já
// existente em cada página.
const SessaoTempoContext = createContext<UseSessaoTempoResultado | null>(null);

export function useSessaoTempoGlobal(): UseSessaoTempoResultado {
  const contexto = useContext(SessaoTempoContext);
  if (!contexto) {
    throw new Error("useSessaoTempoGlobal só pode ser usado dentro de <SessaoTempoProvider> (montado em app/layout.tsx).");
  }
  return contexto;
}

export function SessaoTempoProvider({ children }: { children: ReactNode }) {
  const [matriculaId, setMatriculaId] = useState<string | null>(null);

  useEffect(() => {
    let ativo = true;
    async function resolverMatriculaAtiva() {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!ativo || !user) return;

      const { data: perfil } = await supabase.from("perfis").select("curso_ativo_id").eq("usuario_id", user.id).maybeSingle();
      if (!ativo || !perfil?.curso_ativo_id) return;

      const { data: matricula } = await supabase
        .from("matriculas")
        .select("id")
        .eq("usuario_id", user.id)
        .eq("curso_id", perfil.curso_ativo_id)
        .eq("status", "ativa")
        .maybeSingle();
      if (ativo) setMatriculaId(matricula?.id ?? null);
    }
    resolverMatriculaAtiva();
    return () => {
      ativo = false;
    };
  }, []);

  const sessaoAvulsa = useSessaoTempo({
    origem: "estudo_avulso",
    tipoAtividade: "nao_classificado",
    matriculaId,
  });

  return (
    <SessaoTempoContext.Provider value={sessaoAvulsa}>
      {children}
      <CronometroEstudo sessao={sessaoAvulsa} contexto="Cronômetro livre" />
    </SessaoTempoContext.Provider>
  );
}
