// Repositório Postgres do executor de aquisição — conexão direta
// (SUPABASE_DB_URL, mesmo padrão de scripts/curadoria-pedagogica/
// executar-sql.mjs), papel postgres: ignora RLS como o service_role, e
// por isso replica explicitamente as regras de questão global
// (usuario_id IS NULL) que as RPCs admin fariam.
//
// Só SQL parametrizado. Cada execução é UMA transação (iniciar ->
// confirmar/desfazer); o dry-run abre a transação READ ONLY, então nem
// um bug no planejador conseguiria escrever.

export function criarRepositorioPg(client) {
  let aberta = false;

  return {
    async iniciar({ somenteLeitura, chaveLock = null }) {
      await client.query(somenteLeitura ? "begin transaction read only" : "begin");
      aberta = true;
      // Duas execuções concorrentes da MESMA prova serializam aqui; a
      // segunda replaneja depois do COMMIT da primeira e vê tudo como
      // já importado.
      if (!somenteLeitura && chaveLock) await client.query("select pg_advisory_xact_lock(hashtextextended($1, 0))", [`aquisicao:${chaveLock}`]);
    },

    async confirmar() {
      if (!aberta) return;
      await client.query("commit");
      aberta = false;
    },

    async desfazer() {
      if (!aberta) return;
      await client.query("rollback");
      aberta = false;
    },

    async lerContexto({ hashProva, chaveNatural, slugsCursos, alternativas }) {
      const porHash = hashProva ? (await client.query("select * from public.provas where hash_prova = $1", [hashProva])).rows[0] ?? null : null;
      const porChave =
        (
          await client.query(
            `select * from public.provas
              where lower(btrim(banca)) = lower(btrim($1)) and lower(btrim(orgao)) = lower(btrim($2))
                and lower(btrim(cargo)) = lower(btrim($3)) and ano = $4 and lower(btrim(nome)) = lower(btrim($5))`,
            [chaveNatural.banca ?? "", chaveNatural.orgao ?? "", chaveNatural.cargo ?? "", chaveNatural.ano ?? 0, chaveNatural.nome ?? ""],
          )
        ).rows[0] ?? null;

      const numerosJaImportados = new Map();
      let documentosDaProva = [];
      if (porHash) {
        const { rows } = await client.query("select id, numero_original from public.questoes where prova_id = $1", [porHash.id]);
        for (const r of rows) numerosJaImportados.set(r.numero_original, Number(r.id));
        documentosDaProva = (await client.query("select tipo, ordem, url, hash_sha256 from public.prova_documentos where prova_id = $1 order by tipo, ordem", [porHash.id])).rows;
      }

      // Dedup contra TODA questão global (ativa ou não — uma inativa
      // idêntica é sinal de algo já corrigido/desativado), exceto as da
      // própria prova, que já são tratadas por numero_original.
      // coalesce(... <> $1, true): com prova nova ($1 NULL) ou questão
      // legada (prova_id NULL) a comparação é NULL e a questão ENTRA —
      // "is distinct from" aqui excluiria o legado inteiro quando os dois
      // lados são NULL.
      const { rows: globais } = await client.query(
        `select q.id, q.enunciado,
                coalesce(json_agg(json_build_object('texto', a.texto) order by a.ordem) filter (where a.id is not null), '[]') as alternativas
           from public.questoes q
           left join public.alternativas a on a.questao_id = q.id
          where q.usuario_id is null and coalesce(q.prova_id <> $1::bigint, true)
          group by q.id`,
        [porHash?.id ?? null],
      );

      const { rows: materias } = await client.query("select id, nome, ativo from public.materias where usuario_id is null");
      const { rows: assuntos } = await client.query("select id, materia_id, nome from public.assuntos where usuario_id is null");

      const { rows: sequencia } = await client.query(
        `select x.numero, x.letra from jsonb_to_recordset($1::jsonb) as x(numero integer, letra text, texto text)
          where public.alternativa_tem_sequencia_embutida(x.texto)`,
        [JSON.stringify(alternativas)],
      );

      const cursos = [];
      if (slugsCursos.length > 0) {
        const { rows } = await client.query(
          `select c.id, c.slug, cm.materia_id, cm.nome as nome_curso, m.nome as nome_materia
             from public.cursos c
             left join public.curso_materias cm on cm.curso_id = c.id
             left join public.materias m on m.id = cm.materia_id
            where c.slug = any($1::text[])
            order by c.slug, cm.ordem, cm.id`,
          [slugsCursos],
        );
        for (const r of rows) {
          let curso = cursos.find((c) => c.id === r.id);
          if (!curso) cursos.push((curso = { id: r.id, slug: r.slug, materias: [] }));
          if (r.materia_id !== null) curso.materias.push({ materia_id: Number(r.materia_id), nome_curso: r.nome_curso, nome_materia: r.nome_materia ?? "" });
        }
      }

      return {
        provaPorHash: porHash ? { ...porHash, id: Number(porHash.id) } : null,
        provaPorChaveNatural: porChave ? { ...porChave, id: Number(porChave.id) } : null,
        numerosJaImportados,
        documentosDaProva,
        questoesGlobais: globais.map((g) => ({ id: Number(g.id), enunciado: g.enunciado, alternativas: g.alternativas })),
        materias: new Map(materias.map((m) => [Number(m.id), { id: Number(m.id), nome: m.nome, ativo: m.ativo }])),
        assuntos: new Map(assuntos.map((a) => [Number(a.id), { id: Number(a.id), materia_id: Number(a.materia_id), nome: a.nome }])),
        sequenciaEmbutida: new Set(sequencia.map((s) => `${s.numero}:${s.letra}`)),
        cursos,
      };
    },

    async inserirProva(prova) {
      const { rows } = await client.query(
        `insert into public.provas (banca, orgao, cargo, ano, nome, fonte_url, gabarito_url, hash_prova, hash_gabarito)
         values ($1, $2, $3, $4, $5, $6, $7, $8, $9) returning id`,
        [prova.banca, prova.orgao, prova.cargo, prova.ano, prova.nome, prova.fonte_url, prova.gabarito_url, prova.hash_prova, prova.hash_gabarito],
      );
      return Number(rows[0].id);
    },

    async inserirDocumento(provaId, documento) {
      await client.query("insert into public.prova_documentos (prova_id, tipo, ordem, url, hash_sha256) values ($1, $2, $3, $4, $5)", [
        provaId,
        documento.tipo,
        documento.ordem,
        documento.url,
        documento.hash_sha256,
      ]);
    },

    // Mesmas colunas que importar_questoes_lote() grava, mais a
    // proveniência; usuario_id NULL (questão global), ativa, não IA.
    async inserirQuestao(q) {
      const { rows } = await client.query(
        `insert into public.questoes (usuario_id, materia_id, assunto_id, banca, concurso, ano, enunciado, fonte, ativa, gerada_por_ia, prova_id, numero_original)
         values (null, $1, $2, $3, $4, $5, $6, $7, true, false, $8, $9) returning id`,
        [q.materia_id, q.assunto_id, q.banca, q.concurso, q.ano, q.enunciado, q.fonte, q.prova_id, q.numero_original],
      );
      return Number(rows[0].id);
    },

    async inserirAlternativas(questaoId, alternativas) {
      await client.query(
        `insert into public.alternativas (questao_id, texto, ordem, correta)
         select $1, x.texto, x.ordem, x.correta from jsonb_to_recordset($2::jsonb) as x(texto text, ordem smallint, correta boolean)`,
        [questaoId, JSON.stringify(alternativas)],
      );
    },

    async inserirVinculo(cursoId, questaoId) {
      await client.query("insert into public.curso_questoes (curso_id, questao_id) values ($1, $2)", [cursoId, questaoId]);
    },

    async lerEstadoPosCheck({ provaId, questaoIds }) {
      const prova = (await client.query("select * from public.provas where id = $1", [provaId])).rows[0] ?? null;
      const { rows: questoes } = await client.query(
        `select q.id, q.numero_original, q.enunciado, q.usuario_id,
                coalesce(json_agg(json_build_object('correta', a.correta) order by a.ordem) filter (where a.id is not null), '[]') as alternativas
           from public.questoes q
           left join public.alternativas a on a.questao_id = q.id
          where q.prova_id = $1
          group by q.id`,
        [provaId],
      );
      const { rows: vinculos } = await client.query("select curso_id, questao_id from public.curso_questoes where questao_id = any($1::bigint[])", [questaoIds]);
      const { rows: documentos } = await client.query("select tipo, ordem, hash_sha256 from public.prova_documentos where prova_id = $1", [provaId]);
      return {
        prova,
        documentos,
        questoesDaProva: questoes.map((q) => ({ ...q, id: Number(q.id) })),
        vinculos: vinculos.map((v) => ({ curso_id: v.curso_id, questao_id: Number(v.questao_id) })),
      };
    },

    // Totais das tabelas que o executor escreve — o pós-check exige que
    // cresçam EXATAMENTE o que foi inserido (nada a mais em lugar nenhum).
    async contagensMutaveis() {
      const { rows } = await client.query(
        `select
           (select count(*) from public.provas)::int as provas,
           (select count(*) from public.prova_documentos)::int as prova_documentos,
           (select count(*) from public.questoes)::int as questoes,
           (select count(*) from public.alternativas)::int as alternativas,
           (select count(*) from public.curso_questoes)::int as curso_questoes`,
      );
      return rows[0];
    },

    // Assinatura da estrutura pedagógica que o executor NUNCA pode
    // alterar — comparada antes/depois dentro da transação.
    async contagensEstruturais() {
      const { rows } = await client.query(
        `select
           (select count(*) from public.cursos)::int as cursos,
           (select count(*) from public.curso_materias)::int as curso_materias,
           (select count(*) from public.curso_conteudos)::int as curso_conteudos,
           (select coalesce(sum(peso), 0)::text from public.curso_materias) as pesos_curso_materias,
           (select count(*) from public.materias)::int as materias,
           (select count(*) from public.assuntos)::int as assuntos,
           (select count(*) from public.editais)::int as editais,
           (select count(*) from public.edital_materias)::int as edital_materias`,
      );
      return rows[0];
    },
  };
}
