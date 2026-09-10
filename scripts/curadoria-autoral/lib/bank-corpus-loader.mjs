// Carregador read-only do corpus de questoes REAL para o perfil de banca
// (Fase 2C.3, Secao 7). Reaproveita a MESMA trava de sessao read-only
// (travarSessaoSomenteLeituraOuAbortar) ja endurecida em
// context-resolver.mjs (Fase 2A.1) — nunca reimplementa essa garantia de
// seguranca do zero, so estende para um conjunto de colunas maior
// (enunciado/alternativas/concurso/ano/fonte), que o loader generico da
// Fase 2A nao precisa e por isso nao carrega.
//
// So leitura. So Postgres. Zero escrita. As colunas/tabelas consultadas
// sao sempre um array interno fixo — nunca strings vindas de argumento de
// CLI (mesma disciplina da Fase 2A.1, Secao 14).

import { carregarEnvCuradoria } from "../../curadoria-pedagogica/lib/comum.mjs";
import { travarSessaoSomenteLeituraOuAbortar } from "./context-resolver.mjs";

/**
 * Carrega, via Postgres direto (canal PG_READ_ONLY, sessao travada e
 * verificada ANTES de qualquer SELECT), todas as questoes ativas de uma
 * materia — com enunciado e alternativas completos, em memoria — para o
 * perfilador de estilo calcular features localmente. NUNCA grava o texto
 * bruto em disco (isso e responsabilidade do chamador respeitar, ver
 * lib/bank-style-profiler.mjs).
 *
 * @param {{ materiaId: number }} entrada
 * @returns {Promise<{ canal: string, transactionReadOnly: string, questoes: Array<object> }>}
 */
export async function carregarCorpusMateriaViaPg({ materiaId }) {
  carregarEnvCuradoria();
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("Nem SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY nem SUPABASE_DB_URL/DATABASE_URL estao configurados.");
  }
  if (!Number.isInteger(materiaId) || materiaId <= 0) {
    throw new Error("materiaId precisa ser um inteiro positivo.");
  }

  const { Client } = await import("pg");
  const client = new Client({ connectionString });
  await client.connect();
  try {
    const transactionReadOnly = await travarSessaoSomenteLeituraOuAbortar(client);

    // `id`/`questao_id` sao bigint no Postgres — o driver `pg` os devolve
    // como STRING por padrao (bigint pode exceder Number.MAX_SAFE_INTEGER
    // em geral), o que quebraria comparacoes estritas contra os inteiros
    // JSON do manifesto de proveniencia curada (question_id: 114, um
    // numero) via Set.has(). Os ids reais de questoes.id sao pequenos o
    // bastante para caber em Number com seguranca; convertidos aqui, uma
    // unica vez, para que TODO consumidor deste loader (perfilador,
    // manifesto curado, etc.) trabalhe com numero de forma consistente.
    const { rows: questoesRaw } = await client.query(
      `select id, banca, concurso, ano, fonte, dificuldade, gerada_por_ia, ativa, materia_id, assunto_id, enunciado
       from public.questoes
       where materia_id = $1 and ativa = true`,
      [materiaId]
    );
    const questoes = questoesRaw.map((q) => ({ ...q, id: Number(q.id) }));

    const idsQuestoes = questoes.map((q) => q.id);
    let alternativasPorQuestao = new Map();
    if (idsQuestoes.length > 0) {
      const { rows: alternativas } = await client.query(
        `select questao_id, texto, correta, ordem from public.alternativas where questao_id = ANY($1::bigint[]) order by questao_id, ordem`,
        [idsQuestoes]
      );
      alternativasPorQuestao = new Map();
      for (const alt of alternativas) {
        const questaoId = Number(alt.questao_id);
        if (!alternativasPorQuestao.has(questaoId)) alternativasPorQuestao.set(questaoId, []);
        alternativasPorQuestao.get(questaoId).push(alt);
      }
    }

    const questoesComAlternativas = questoes.map((q) => ({ ...q, alternativas: alternativasPorQuestao.get(q.id) ?? [] }));

    return { canal: "PG_READ_ONLY", transactionReadOnly, questoes: questoesComAlternativas };
  } finally {
    await client.end().catch(() => {});
  }
}
