#!/usr/bin/env node
// FASE 3C — Gera o harness transacional (BEGIN...ROLLBACK) de importacao das
// questoes novas e ja explicadas da Fase 3B (sub-lotes 1-5) da Lei Maria da
// Penha. So le os arquivos-fonte do checkpoint (supabase/lote2_fase3_estado/
// e scripts/lote2-fase3b-sublote{1..5}-explicacoes.mjs) e escreve um .sql —
// nao toca o Supabase. Segue o MESMO padrao de seguranca de
// scripts/generate-lote1-import-harness.mjs: BEGIN, snapshot antes, staging,
// precondicoes revalidadas dentro da transacao, INSERTs, ASSERTS, sempre
// ROLLBACK no final.
//
// Diferencas em relacao ao harness do Lote 1:
//   - Sem classificacao por unidade pedagogica (nao pedido pelo usuario
//     nesta rodada) — as questoes entram como "banco geral" (curso_questoes
//     apenas), elegiveis a Missao Final, sem pratica de unidade dedicada.
//   - explicacao ja vai preenchida no INSERT (a Fase 3B ja escreveu as
//     explicacoes; nao ha update separado depois, como aconteceu no Lote 1).
//   - Precondicao de duplicata usa comparacao de TEXTO NORMALIZADO do
//     enunciado, nao tec_id em fonte — descobriu-se durante a reconciliacao
//     desta fase que o numero "tec_id" nao e identificador confiavel: 9 de
//     10 questoes existentes cujo fonte cita um tec_id que tambem aparece em
//     candidatas do Lote 2 sao, na verdade, questoes DIFERENTES (o mesmo
//     numero foi reciclado/atribuido a conteudos distintos em algum ponto
//     do historico dos dois lotes). Confirmar por texto evita tanto
//     falso-positivo quanto falso-negativo.
//
// Uso: node scripts/generate-lote2-fase3c-harness.mjs

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/importar_lote2_fase3c_lei_maria_penha_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/importar_lote2_fase3c_lei_maria_penha.sql');

const MATERIA_ID = 10;
const ASSUNTO_ID = 19;
const CONTEUDO_ID = 53;
const CURSO_ID = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'; // Brigada Militar do Rio Grande do Sul / Soldado de Primeira Classe / Fundatec
const ADMIN_USUARIO_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

// Duplicatas confirmadas contra o Supabase nesta reconciliacao (ver relatorio
// entregue ao usuario): comparacao robusta de enunciado + alternativas,
// nao apenas tec_id (que se mostrou nao confiavel).
const DUPLICATAS_CONFIRMADAS = new Map([
  [3299442, { cadernoNumero: 303, idExistente: 778, motivo: 'Enunciado e as 5 alternativas identicos (byte a byte, salvo espacos de OCR ja presentes nos dois lados) ao registro existente id=778.' }],
  [3486853, { cadernoNumero: 232, idExistente: 346, motivo: 'Mesmas 3 assertivas (I/II/III) e as mesmas 5 alternativas do registro existente id=346 (Fundatec, CBM RS Soldado 1a Classe 2025, Questao 56).' }],
  [3486856, { cadernoNumero: 231, idExistente: 347, motivo: 'Mesmo exercicio de associacao de colunas e as mesmas 5 alternativas do registro existente id=347 (Fundatec, CBM RS Soldado 1a Classe 2025, Questao 57).' }],
]);

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}
function sqlIntOrNull(n) {
  return Number.isFinite(n) ? String(n) : 'null';
}

// --- Carrega as 187 (conteudo Fase 3A/3B + explicacao) -------------------
async function carregarProntas() {
  const todas = [];
  for (let i = 1; i <= 5; i++) {
    const conteudo = JSON.parse(fs.readFileSync(`${SCRATCH}/fase3b_sublote${i}_conteudo.json`, 'utf8'));
    const mod = await import(`./lote2-fase3b-sublote${i}-explicacoes.mjs`);
    const explPorId = new Map(mod.explicacoes.map(e => [e.tecId, e.explicacao]));
    for (const q of conteudo) {
      const expl = explPorId.get(q.tecId);
      if (!expl) throw new Error(`tecId ${q.tecId} (sub-lote ${i}) sem explicacao -- integridade quebrada`);
      todas.push({ ...q, sublote_fase3b: i, explicacao: expl });
    }
  }
  return todas;
}

const todas187 = await carregarProntas();
if (todas187.length !== 187) throw new Error(`Esperado 187 questoes prontas, encontrado ${todas187.length}`);
const idsUnicos187 = new Set(todas187.map(q => q.tecId));
if (idsUnicos187.size !== 187) throw new Error('tecId duplicado entre os 5 sub-lotes -- integridade quebrada');

const aprovadas = todas187.filter(q => !DUPLICATAS_CONFIRMADAS.has(q.tecId));
const excluidas = todas187.filter(q => DUPLICATAS_CONFIRMADAS.has(q.tecId));

if (excluidas.length !== DUPLICATAS_CONFIRMADAS.size) {
  throw new Error(`Esperado ${DUPLICATAS_CONFIRMADAS.size} excluidas por duplicidade, encontrado ${excluidas.length}`);
}
for (const q of excluidas) {
  const d = DUPLICATAS_CONFIRMADAS.get(q.tecId);
  if (q.cadernoNumero !== d.cadernoNumero) throw new Error(`cadernoNumero divergente para tecId ${q.tecId}`);
}

const TOTAL_APROVADAS = aprovadas.length;
console.log(`Prontas (Fase 3B, sub-lotes 1-5): ${todas187.length}`);
console.log(`Excluidas por duplicidade confirmada: ${excluidas.length} — cadernos ${excluidas.map(q => q.cadernoNumero).sort((a, b) => a - b).join(', ')}`);
console.log(`Aprovadas para importacao: ${TOTAL_APROVADAS}`);

// --- Validacao estrutural de cada aprovada antes de gerar SQL -------------
const LETRAS = 'ABCDE';
const questoesRows = [];
const alternativasRows = [];
let totalAlternativas = 0;

for (const q of aprovadas) {
  const isCertoErrado = q.alternativas.length === 2 &&
    q.alternativas.every(a => ['certo', 'errado'].includes(a.trim().toLowerCase()));

  let corretaIdx;
  if (isCertoErrado) {
    corretaIdx = q.alternativas.findIndex(a => a.trim().toLowerCase() === q.gabarito.trim().toLowerCase());
  } else {
    corretaIdx = LETRAS.indexOf(q.gabarito.trim().toUpperCase());
  }
  if (corretaIdx < 0 || corretaIdx >= q.alternativas.length) {
    throw new Error(`tecId ${q.tecId} (caderno ${q.cadernoNumero}): gabarito "${q.gabarito}" fora do range de alternativas`);
  }
  if (!q.enunciado || !q.enunciado.trim()) throw new Error(`tecId ${q.tecId}: enunciado vazio`);
  if (!q.explicacao || !q.explicacao.trim()) throw new Error(`tecId ${q.tecId}: explicacao vazia`);
  if (q.classificacao_final === 'PROBLEMATICA' || q.classificacao_final === 'DESATUALIZADA' ||
      q.classificacao_final === 'PROBLEMATICA_GABARITO_AMBIGUO' || q.classificacao_final === 'FORA_ESCOPO_LMP' ||
      q.classificacao_final === 'DADOS_INSUFICIENTES_VISUAL') {
    throw new Error(`tecId ${q.tecId}: classificacao_final=${q.classificacao_final} nao deveria estar entre as aprovadas`);
  }

  const fonte = `TEC Concursos — questão ${q.tecId} — ${q.banca} — ${q.concurso}`;

  questoesRows.push(
    `  (${q.tecId}, ${sqlStr(q.banca)}, ${sqlStr(q.concurso)}, ${sqlIntOrNull(q.ano)}, ` +
    `${sqlStr(q.enunciado)}, ${sqlStr(q.explicacao)}, ${sqlStr(fonte)})`
  );

  q.alternativas.forEach((texto, i) => {
    alternativasRows.push(`  (${q.tecId}, ${i + 1}, ${sqlStr(texto)}, ${i === corretaIdx})`);
    totalAlternativas++;
  });
}

console.log(`Alternativas: ${totalAlternativas}`);

const dadosComentario = `-- Gerado automaticamente por scripts/generate-lote2-fase3c-harness.mjs a
-- partir de scripts/lote2-fase3b-sublote{1..5}-explicacoes.mjs e
-- supabase/lote2_fase3_estado/fase3b/fase3b_sublote{1..5}_conteudo.json.
-- NAO editar este arquivo a mao — editar a fonte e regerar.
--
-- Fase 3B concluida ate o sub-lote 5 de 14 (187 questoes com explicacao
-- pedagogica completa e validada). Sub-lotes 6-14 (333 candidatas restantes
-- do pool de 520 aprovadas na Fase 2/3A) NAO fazem parte desta importacao.
--
-- Reconciliacao contra o Supabase (assunto_id=19, 117 questoes existentes
-- antes desta importacao) feita nesta rodada, com comparacao robusta de
-- enunciado/alternativas (no minimo 3 metodos: tec_id citado no campo
-- fonte, hash exato do enunciado normalizado, e similaridade de palavras
-- Jaccard >= 0.5 com verificacao manual de cada par sinalizado):
--   - 3 duplicatas CONFIRMADAS (mesmo enunciado e mesmas alternativas de um
--     registro ja existente) — EXCLUIDAS desta importacao:
--       * caderno 303 (tec_id 3299442) = id existente 778
--       * caderno 231 (tec_id 3486856) = id existente 347
--       * caderno 232 (tec_id 3486853) = id existente 346
--   - 9 falsos-positivos identificados e descartados: questoes existentes
--     cujo campo fonte cita um tec_id que TAMBEM aparece em candidatas
--     deste lote, mas cujo enunciado/alternativas comparados na integra
--     provaram ser conteudo DIFERENTE (o numero de tec_id nao e um
--     identificador confiavel entre os dois lotes — foi reciclado/atribuido
--     a questoes distintas em algum ponto do historico). Essas ${TOTAL_APROVADAS} permanecem
--     aprovadas.
--
-- Composicao: ${TOTAL_APROVADAS} questoes novas, ${totalAlternativas} alternativas. Todas entram como
-- "banco geral" (curso_questoes apenas, sem vinculo de unidade pedagogica —
-- essa classificacao, se desejada, seria uma curadoria separada, como foi
-- feito para o Lote 1). Elegiveis a Missao Final; nao aparecem na pratica
-- de nenhuma unidade especifica.
--
-- Usa a MESMA simulacao de claim JWT do admin cadastrado (via "set local"),
-- restrita a esta transacao, no mesmo padrao ja usado nos harnesses
-- anteriores desta materia.
--
-- Precisa rodar com um role de ESCRITA (nao funciona via MCP read-only).`;

const body = `BEGIN;

set local request.jwt.claim.sub = '${ADMIN_USUARIO_ID}';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — prova de ausencia de efeito colateral fora do esperado.
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) filter (where assunto_id = ${ASSUNTO_ID}) from public.questoes) as total_questoes_lmp,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

-- ----------------------------------------------------------------------------
-- Staging: ${TOTAL_APROVADAS} questoes (chave local = tec_id, nunca usado como id real —
-- o id real vem do IDENTITY de public.questoes no INSERT abaixo).
-- ----------------------------------------------------------------------------
create temporary table _l2_questoes (
  tec_id bigint primary key,
  banca text,
  concurso text,
  ano int,
  enunciado text,
  explicacao text,
  fonte text
) on commit drop;

insert into _l2_questoes (tec_id, banca, concurso, ano, enunciado, explicacao, fonte) values
${questoesRows.join(',\n')};

create temporary table _l2_alternativas (
  tec_id bigint,
  ordem smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _l2_alternativas (tec_id, ordem, texto, correta) values
${alternativasRows.join(',\n')};

-- ----------------------------------------------------------------------------
-- Revalidacao de premissas dentro da propria transacao antes de qualquer
-- escrita real (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_curso_concurso text;
begin
  if (select count(*) from _l2_questoes) <> ${TOTAL_APROVADAS} then
    raise exception 'Precondicao falhou: staging nao tem exatamente ${TOTAL_APROVADAS} questoes';
  end if;

  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = ${CONTEUDO_ID};

  if v_materia_id is distinct from ${MATERIA_ID} or v_assunto_id is distinct from ${ASSUNTO_ID} then
    raise exception 'Precondicao falhou: conteudo ${CONTEUDO_ID} materia_id=% assunto_id=% (esperado ${MATERIA_ID}/${ASSUNTO_ID})', v_materia_id, v_assunto_id;
  end if;

  select concurso into v_curso_concurso from public.cursos where id = '${CURSO_ID}'::uuid;
  if v_curso_concurso is distinct from 'Brigada Militar do Rio Grande do Sul' then
    raise exception 'Precondicao falhou: curso ${CURSO_ID} concurso=% (esperado Brigada Militar do Rio Grande do Sul)', v_curso_concurso;
  end if;

  -- Deduplicacao por TEXTO (nao por tec_id — ver comentario no cabecalho
  -- deste arquivo sobre por que tec_id nao e confiavel). Compara contra
  -- TODAS as questoes existentes, nao so assunto_id=19, por seguranca.
  if exists (
    select 1
    from _l2_questoes l
    join public.questoes q
      on lower(regexp_replace(q.enunciado, '\\s+', ' ', 'g')) = lower(regexp_replace(l.enunciado, '\\s+', ' ', 'g'))
  ) then
    raise exception 'Precondicao falhou: alguma candidata do Lote 2 tem enunciado identico a uma questao ja existente (possivel duplicata nao capturada)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — questoes (loop explicito para mapear tec_id -> id real de
-- forma inequivoca, sem depender de ordem implicita de RETURNING).
-- explicacao ja vai preenchida (Fase 3B ja escreveu o texto completo).
-- ----------------------------------------------------------------------------
create temporary table _l2_ids (tec_id bigint primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_id bigint;
begin
  for r in select * from _l2_questoes order by tec_id loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, enunciado, explicacao, fonte, ano, ativa, dificuldade, gerada_por_ia)
    values (${MATERIA_ID}, ${ASSUNTO_ID}, r.banca, r.concurso, r.enunciado, r.explicacao, r.fonte, r.ano, true, 'media', false)
    returning id into v_id;

    insert into _l2_ids (tec_id, questao_id) values (r.tec_id, v_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — alternativas.
-- ----------------------------------------------------------------------------
insert into public.alternativas (questao_id, texto, correta, ordem)
select m.questao_id, a.texto, a.correta, a.ordem
from _l2_alternativas a
join _l2_ids m using (tec_id);

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — curso_questoes (todas as ${TOTAL_APROVADAS} no curso Brigada Militar RS, como
-- banco geral — sem vinculo de unidade pedagogica nesta rodada).
-- ----------------------------------------------------------------------------
insert into public.curso_questoes (curso_id, questao_id)
select '${CURSO_ID}'::uuid, questao_id
from _l2_ids;`;

const assertsAndRollback = `
-- ----------------------------------------------------------------------------
-- ASSERTS — tabela de apoio TEMPORARY com ON COMMIT DROP: some ao final da
-- transacao (ROLLBACK ou COMMIT), nunca persiste no schema public. Sem
-- procedure auxiliar (Postgres nao tem "procedure temporaria" — a unica
-- forma de garantir zero objeto permanente e nao criar procedure nenhuma) —
-- a logica de log/verificacao fica toda dentro dos blocos DO abaixo, que
-- ja sao, por natureza, transitorios.
-- ----------------------------------------------------------------------------
create temporary table _l2_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

do $$
declare
  v_antes record;
  v_depois record;
  v_sem_correta int;
  v_com_vinculo_unidade int;
  v_ids_novas bigint[];
  v_missao_final bigint[];
  v_novas_na_missao int;
  v_novas_vazando_u1 int;
  v_u1_id uuid;
  v_duplicata_texto int;
begin
  select * into v_antes from _snapshot_antes;
  select
    (select count(*) from public.questoes)                     as total_questoes,
    (select count(*) filter (where assunto_id = ${ASSUNTO_ID}) from public.questoes) as total_questoes_lmp,
    (select count(*) from public.alternativas)                 as total_alternativas,
    (select count(*) from public.unidades_pedagogicas)          as total_unidades,
    (select count(*) from public.curso_conteudos)               as total_conteudos,
    (select count(*) from public.curso_questoes)                as total_curso_questoes,
    (select count(*) from public.respostas_usuarios)            as total_respostas,
    (select count(*) from public.sessoes_estudo)                as total_sessoes,
    (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos
  into v_depois;

  insert into _l2_asserts (descricao, ok) values ('questoes +${TOTAL_APROVADAS}', v_depois.total_questoes = v_antes.total_questoes + ${TOTAL_APROVADAS});
  insert into _l2_asserts (descricao, ok) values ('questoes com assunto_id=${ASSUNTO_ID} (Lei Maria da Penha) +${TOTAL_APROVADAS}', v_depois.total_questoes_lmp = v_antes.total_questoes_lmp + ${TOTAL_APROVADAS});
  insert into _l2_asserts (descricao, ok) values ('alternativas +${totalAlternativas}', v_depois.total_alternativas = v_antes.total_alternativas + ${totalAlternativas});
  insert into _l2_asserts (descricao, ok) values ('curso_questoes +${TOTAL_APROVADAS}', v_depois.total_curso_questoes = v_antes.total_curso_questoes + ${TOTAL_APROVADAS});
  insert into _l2_asserts (descricao, ok) values ('unidades_pedagogicas inalterada (nenhuma unidade criada/removida)', v_depois.total_unidades = v_antes.total_unidades);
  insert into _l2_asserts (descricao, ok) values ('curso_conteudos inalterada', v_depois.total_conteudos = v_antes.total_conteudos);
  insert into _l2_asserts (descricao, ok) values ('questao_unidades_pedagogicas inalterada (banco geral, sem vinculo de unidade)', v_depois.total_vinculos = v_antes.total_vinculos);
  insert into _l2_asserts (descricao, ok) values ('respostas_usuarios inalterada', v_depois.total_respostas = v_antes.total_respostas);
  insert into _l2_asserts (descricao, ok) values ('sessoes_estudo inalterada', v_depois.total_sessoes = v_antes.total_sessoes);

  select count(*) into v_sem_correta
  from _l2_ids m
  where (select count(*) from public.alternativas a where a.questao_id = m.questao_id and a.correta) <> 1;
  insert into _l2_asserts (descricao, ok) values ('todas as ${TOTAL_APROVADAS} questoes tem exatamente 1 alternativa correta', v_sem_correta = 0);

  select count(*) into v_com_vinculo_unidade
  from _l2_ids m
  where exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  insert into _l2_asserts (descricao, ok) values ('nenhuma das ${TOTAL_APROVADAS} novas ganhou vinculo de unidade pedagogica (banco geral)', v_com_vinculo_unidade = 0);

  select count(*) into v_duplicata_texto
  from public.questoes q1
  join public.questoes q2 on q1.id < q2.id
    and lower(regexp_replace(q1.enunciado, '\\s+', ' ', 'g')) = lower(regexp_replace(q2.enunciado, '\\s+', ' ', 'g'))
  where q1.assunto_id = ${ASSUNTO_ID} and q2.assunto_id = ${ASSUNTO_ID}
    and q1.id in (select questao_id from _l2_ids);
  insert into _l2_asserts (descricao, ok) values ('nenhuma das ${TOTAL_APROVADAS} novas ficou duplicada (texto identico) com outra questao de assunto_id=${ASSUNTO_ID} apos a insercao', v_duplicata_texto = 0);

  -- Ponta a ponta: confirma que as novas (banco geral) aparecem na Missao
  -- Final via public.selecionar_candidatas_conteudo, e NAO vazam para a
  -- pratica de nenhuma unidade especifica (checagem representativa em U1).
  select array_agg(questao_id) into v_ids_novas from _l2_ids;

  select array_agg(x.questao_id) into v_missao_final
  from public.selecionar_candidatas_conteudo(
    '${ADMIN_USUARIO_ID}'::uuid, ${CONTEUDO_ID}::bigint, '${CURSO_ID}'::uuid, 1000, '{}'::bigint[], null
  ) x(questao_id);

  select count(*) into v_novas_na_missao
  from unnest(v_ids_novas) qid where qid = any(v_missao_final);

  insert into _l2_asserts (descricao, ok) values (
    'todas as ${TOTAL_APROVADAS} novas (banco geral) aparecem na Missao Final (conteudo ${CONTEUDO_ID})',
    v_novas_na_missao = ${TOTAL_APROVADAS}
  );

  select id into v_u1_id from public.unidades_pedagogicas where curso_conteudo_id = ${CONTEUDO_ID} and ativa = true order by ordem limit 1;

  select count(*) into v_novas_vazando_u1
  from unnest(v_ids_novas) qid
  where qid = any(array(
    select x.questao_id from public.selecionar_candidatas_unidade_pedagogica(
      '${ADMIN_USUARIO_ID}'::uuid, v_u1_id, '${CURSO_ID}'::uuid, 1000, '{}'::bigint[], null
    ) x(questao_id)
  ));

  insert into _l2_asserts (descricao, ok) values (
    'nenhuma das ${TOTAL_APROVADAS} novas aparece na pratica de uma unidade especifica (checagem representativa em U1)',
    v_novas_vazando_u1 = 0
  );
end $$;

-- Segundo bloco: percorre os asserts na ordem em que foram inseridos,
-- reportando cada um (RAISE NOTICE) e abortando a transacao inteira no
-- primeiro que falhar (RAISE EXCEPTION), exatamente como o CALL a uma
-- procedure faria — so que sem precisar de nenhuma procedure. A tabela
-- _l2_asserts em si desaparece sozinha ao fim da transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _l2_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _l2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;
`;
// `assertsAndRollback` termina logo apos o bloco de RESUMO (todos os
// asserts ja incluidos e ja validados). O unico ponto que difere entre
// harness e apply, por pedido explicito do usuario, e a ultima linha
// (ROLLBACK; vs COMMIT;) e o comentario imediatamente acima dela — os
// ASSERTS em si (contagens, 1-correta-por-questao, ausencia de vinculo de
// unidade, ausencia de duplicata pos-insercao, elegibilidade na Missao
// Final, nao-vazamento para pratica de unidade) permanecem IDENTICOS,
// nunca reescritos, nos dois arquivos — e nenhum objeto teste_lote2_fase3c_*
// (nem tabela, nem procedure) e criado em NENHUM dos dois: so a tabela
// TEMPORARY _l2_asserts, com ON COMMIT DROP, que some sozinha tanto no
// ROLLBACK do harness quanto no COMMIT do apply.

const corpoComAsserts = `${body}
${assertsAndRollback}`;

const harnessSql = `-- ============================================================================
-- LOTE 2 — FASE 3C — IMPORTACAO DAS ${TOTAL_APROVADAS} QUESTOES PRONTAS (SUB-LOTES 1-5 DA FASE 3B)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
${dadosComentario}
-- ============================================================================

${corpoComAsserts}
-- Nada commitado: staging, questoes, alternativas, curso_questoes e as
-- tabelas de assert — tudo desfeito abaixo.
ROLLBACK;
`;

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
console.log(`\nGerado: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);

// --- Apply (COMMIT) — reaproveita `corpoComAsserts` EM MEMORIA, literalmente
// a mesma string usada no harness acima (nunca reescrita, ASSERTS inclusos
// e preservados). A unica diferenca FUNCIONAL e ROLLBACK -> COMMIT; o
// cabecalho e o comentario final tambem mudam (permitido pelo usuario). ---
const applySql = `-- ============================================================================
-- LOTE 2 — FASE 3C — IMPORTACAO DAS ${TOTAL_APROVADAS} QUESTOES PRONTAS (SUB-LOTES 1-5 DA FASE 3B)
-- APLICACAO REAL — TERMINA EM COMMIT. So rodar depois que
-- supabase/importar_lote2_fase3c_lei_maria_penha_teste_rollback.sql tiver
-- rodado no SQL Editor com TODOS os asserts passando (RESUMO N/N).
-- Mantem TODOS os mesmos asserts do harness (nao removidos) — eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
${dadosComentario}
-- ============================================================================

${corpoComAsserts}
-- Todos os asserts acima passaram (senao a transacao já teria abortado por
-- RAISE EXCEPTION) — confirma as escritas: ${TOTAL_APROVADAS} questoes (com explicacao ja
-- preenchida), ${totalAlternativas} alternativas, ${TOTAL_APROVADAS} vinculos de curso_questoes (banco
-- geral, sem vinculo de unidade pedagogica).
COMMIT;
`;

fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log(`Questoes: ${TOTAL_APROVADAS} | Alternativas: ${totalAlternativas} | Excluidas por duplicidade: ${excluidas.length}`);
