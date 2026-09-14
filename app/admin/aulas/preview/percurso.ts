// Resolução pura do percurso administrativo genérico (app/admin/aulas/
// preview/page.tsx) — sem JSX/React, testável com node --test puro (mesmo
// princípio de app/admin/aulas/banco-unidade.ts e de supabase/functions/
// gerar-aula/escopo.mjs: o projeto não tem infraestrutura de teste de
// React hoje e este arquivo não é motivo para adicionar uma).
//
// Nenhuma RPC nova foi criada para isto. Toda a resolução usa dados já
// retornados por public.listar_geracoes_conteudo_admin (RETURNS TABLE:
// geracao_id, status, iniciado_em, finalizado_em, aula_versao_id, erro,
// prompt_version, modelo, contexto), já ordenada por iniciado_em desc pela
// própria RPC — por isso "a primeira geração concluída cujo contexto
// aponta para esta unidade" já É a mais recente, sem precisar reordenar
// aqui. "contexto" é o mesmo objeto persistido por contextoSnapshot em
// supabase/functions/gerar-aula/index.ts, que já inclui unidade_pedagogica_id,
// conteudo, materia, concurso, cargo e banca como texto pronto para exibir
// — por isso não é necessário nenhum SELECT direto em curso_conteudos
// (tabela sem policy de SELECT para admin, só RPCs security definer) nem
// nenhuma RPC nova só para resolver o cabeçalho do percurso.

export type ContextoGeracao = {
  unidade_pedagogica_id?: string;
  unidade_pedagogica?: string;
  conteudo?: string;
  materia?: string;
  concurso?: string | null;
  cargo?: string | null;
  banca?: string | null;
} | null;

export type GeracaoResumo = {
  status: string;
  aula_versao_id: string | null;
  contexto: ContextoGeracao;
};

// A aula_versao_id "atual" de uma unidade é a da geração CONCLUÍDA mais
// recente cujo contexto aponta para essa unidade — mesmo critério que o
// admin já usa manualmente em app/admin/aulas/page.tsx (botão "Ver
// rascunho" na geração mais recente). Não distingue rascunho de
// publicada de propósito: o preview precisa mostrar as duas (ver mandato
// "rascunho deve funcionar").
export function resolverAulaVersaoDaUnidade(
  geracoes: GeracaoResumo[],
  unidadeId: string,
): string | null {
  const encontrada = geracoes.find(
    (g) => g.status === "concluida" && g.aula_versao_id && g.contexto?.unidade_pedagogica_id === unidadeId,
  );
  return encontrada?.aula_versao_id ?? null;
}

export type InfoConteudo = {
  conteudo: string | null;
  materia: string | null;
  concurso: string | null;
  cargo: string | null;
  banca: string | null;
};

// Cabeçalho do percurso ("PERCURSO PAPIRO" / nome do conteúdo): lido do
// contexto da geração mais recente que tiver essa informação. Se nenhuma
// geração já rodou para este conteúdo, devolve tudo null — quem chama
// decide o texto de fallback (ver nomeFallback em resolverTituloPercurso).
export function resolverInfoConteudo(geracoes: GeracaoResumo[]): InfoConteudo {
  const comContexto = geracoes.find((g) => g.contexto?.conteudo);
  const contexto = comContexto?.contexto ?? null;
  return {
    conteudo: contexto?.conteudo ?? null,
    materia: contexto?.materia ?? null,
    concurso: contexto?.concurso ?? null,
    cargo: contexto?.cargo ?? null,
    banca: contexto?.banca ?? null,
  };
}

// Título de exibição do percurso: prefere o nome já vindo do contexto real
// de alguma geração (fonte mais autoritativa); cai para o nome passado via
// query string (?nome=..., preenchido por quem linkou a partir de
// /admin/aulas, que já tem esse nome carregado); e só na ausência total
// dos dois usa um rótulo genérico com o id — nunca inventa um nome.
export function resolverTituloPercurso(infoConteudo: InfoConteudo, nomeFallback: string | null, conteudoId: number): string {
  return infoConteudo.conteudo || nomeFallback || `Conteúdo #${conteudoId}`;
}
