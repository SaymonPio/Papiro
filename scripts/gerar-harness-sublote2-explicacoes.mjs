#!/usr/bin/env node
// Gera o harness transacional (BEGIN...UPDATE...ROLLBACK) do SUB-LOTE 2 de
// explicacoes (Lei Maria da Penha, 38 questoes aplicaveis, id 1331-1370
// exceto 1337/1340 -- ver nota abaixo sobre essas duas, excluidas por
// revisao juridica: PROBLEMATICA/DESATUALIZADA, nao por erro estrutural).
// So gera o arquivo -- nao toca o
// Supabase. A aplicacao real (COMMIT) e gerada por
// scripts/gerar-apply-sublote2-explicacoes.mjs, que EXTRAI o corpo (staging
// + precondicoes + UPDATE) diretamente deste arquivo ja validado no SQL
// Editor -- nunca reescreve o texto, para garantir identidade byte a byte
// com o que foi validado.
//
// So altera public.questoes.explicacao. Nao toca enunciado, alternativas,
// fonte, banca, concurso, materia_id, assunto_id, ativa,
// questao_unidades_pedagogicas nem curso_questoes -- e prova isso com
// hashes por linha antes/depois, alem das contagens agregadas.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { explicacoes } from './sublote2-lei-maria-penha-explicacoes.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const OUT_PATH = path.join(ROOT, 'supabase/sublote2_lei_maria_penha_explicacoes_teste_rollback.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

const ids = explicacoes.map(e => e.id);
if (ids.length !== 38) throw new Error(`Esperado 38 questoes, encontrado ${ids.length}`);

const stagingRows = explicacoes
  .map(e => `  (${e.id}, ${sqlStr(e.explicacao)})`)
  .join(',\n');

const idsListaSql = ids.join(', ');

const sql = `-- ============================================================================
-- SUB-LOTE 2 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (38 QUESTÕES)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado por scripts/gerar-harness-sublote2-explicacoes.mjs a partir de
-- scripts/sublote2-lei-maria-penha-explicacoes.mjs (fonte da verdade dos
-- textos). As 38 explicações já passaram por
-- scripts/validar-sublote2-explicacoes.mjs (38/38 aprovadas: gabarito de
-- cada texto bate com a alternativa correta=true no banco, todas as
-- alternativas de cada questão são comentadas individualmente, estrutura
-- obrigatória completa).
--
-- Questões: ${idsListaSql}
-- (as próximas 40 das 45 SEM_EXPLICACAO restantes do Lote 1 de importação,
-- todas assunto_id=19 / Lei Maria da Penha, ordenadas por id, MENOS as
-- ids 1337 e 1340 — ver exclusão documentada abaixo).
--
-- QUESTÕES EXCLUÍDAS DESTE SUB-LOTE — PROBLEMATICA/DESATUALIZADA (não
-- entram neste harness, não estão em nenhuma UPDATE abaixo, permanecem
-- SEM_EXPLICACAO em produção até decisão editorial futura):
--
--   id 1337 — banca cobrou o entendimento de que maus-tratos/violência
--   cometidos por responsável contra criança/adolescente do sexo feminino
--   no âmbito doméstico seriam tratados fora da Lei Maria da Penha
--   (competência do ECA). Esse era o entendimento predominante à época da
--   prova. O STJ, em julgamento de recurso repetitivo (Tema Repetitivo
--   1.186), fixou que a condição de sexo feminino da vítima é suficiente
--   para atrair a incidência da Lei Maria da Penha mesmo quando a vítima
--   é criança ou adolescente, e que, havendo conflito de competência, a
--   Lei Maria da Penha prevalece sobre o ECA. O gabarito histórico da
--   banca contraria esse entendimento hoje vinculante — por isso não é
--   gerada explicação que apresente o gabarito original como direito
--   atual. Questão marcada PROBLEMATICA/DESATUALIZADA, não SEM_EXPLICACAO.
--
--   id 1340 — mesma razão do id 1337: uma das assertivas do item
--   (maus-tratos de pais adotivos contra filha criança tratados pelo ECA,
--   fora dos Juizados de Violência Doméstica) foi redigida pela banca como
--   verdadeira, contrariando o Tema Repetitivo 1.186/STJ hoje vigente.
--   Mesma classificação: PROBLEMATICA/DESATUALIZADA.
--
-- Auditoria textual prévia (não bloqueante — nenhuma altera gabarito ou
-- fundamento jurídico, por isso nenhuma das 38 aplicadas foi marcada
-- PROBLEMATICA por esse motivo):
-- id 1363 tem "prisão preventivav"/"adotadará" (erros de digitação no
-- enunciado/alternativa originais); id 1367 cita "Lei nº 11.340/2008" (o
-- correto é 2006); id 1348 tem acentuação inconsistente; id 1359 e 1361 têm
-- prefixo "(PMLM/URCA 2025)" e "$8º" em vez de "§8º" (mesmo padrão OCR já
-- visto e aceito nos cadernos 971/974 da auditoria original do Lote 1).
-- ENUNCIADO E ALTERNATIVAS NÃO FORAM ALTERADOS — só registrados para
-- conferência futura contra o PDF original.
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam — provado abaixo por
-- hash md5 linha a linha antes/depois, não só por contagem agregada.
--
-- Nenhuma questão PROBLEMATICA por gabarito ambíguo (0 ou >1 alternativa
-- correta) foi tocada — confirmado na auditoria: nenhuma das 38 aplicadas
-- tem esse problema estrutural. As duas exclusões por conteúdo jurídico
-- desatualizado (1337, 1340) estão documentadas acima e ficam fora deste
-- UPDATE.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash por questão (prova de que só explicacao muda) +
-- contadores agregados (prova de ausência de efeito colateral em outras
-- tabelas).
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes_questoes on commit drop as
select
  q.id,
  md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_questao,
  (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = q.id
  ) as hash_alternativas,
  (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id
  ) as hash_vinculos_unidade,
  (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = q.id
  ) as hash_vinculos_curso
from public.questoes q
where q.id in (${idsListaSql});

create temporary table _snapshot_antes_agregado on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_unidade,
  (select count(*) from public.curso_questoes) as total_curso_questoes,
  (select count(*) from public.questoes where explicacao is not null) as total_com_explicacao;

-- ----------------------------------------------------------------------------
-- Staging: as 38 explicações novas.
-- ----------------------------------------------------------------------------
create temporary table _staging_explicacoes (
  questao_id bigint primary key,
  explicacao_nova text
) on commit drop;

insert into _staging_explicacoes (questao_id, explicacao_nova) values
${stagingRows};

-- ----------------------------------------------------------------------------
-- Revalidação de premissas dentro da própria transação, antes de qualquer
-- escrita (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_fora_do_assunto int;
  v_ja_tem_explicacao int;
  v_inativa int;
  v_gabarito_ambiguo int;
begin
  select count(*) into v_total from _staging_explicacoes;
  if v_total <> 38 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 38 questoes (tem %)', v_total;
  end if;

  select count(*) into v_fora_do_assunto
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.assunto_id <> 19;
  if v_fora_do_assunto > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging nao pertencem ao assunto Lei Maria da Penha (assunto_id=19)', v_fora_do_assunto;
  end if;

  select count(*) into v_ja_tem_explicacao
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is not null;
  if v_ja_tem_explicacao > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging ja tem explicacao preenchida (estado mudou desde a auditoria)', v_ja_tem_explicacao;
  end if;

  select count(*) into v_inativa
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where not q.ativa;
  if v_inativa > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging estao inativas', v_inativa;
  end if;

  select count(*) into v_gabarito_ambiguo
  from (
    select a.questao_id, count(*) filter (where a.correta) as n_corretas, count(*) as n_alt
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ) x
  where x.n_corretas <> 1 or x.n_alt = 0;
  if v_gabarito_ambiguo > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging tem gabarito ambiguo (PROBLEMATICA) -- nao pode ser atualizada automaticamente', v_gabarito_ambiguo;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).
-- ----------------------------------------------------------------------------
update public.questoes q
set explicacao = s.explicacao_nova
from _staging_explicacoes s
where q.id = s.questao_id;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_sublote2_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_sublote2_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_sublote2_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_antes record;
  v_total_questoes int;
  v_total_alternativas int;
  v_total_vinculos_unidade int;
  v_total_curso_questoes int;
  v_total_com_explicacao int;
  v_diferentes_enunciado_ou_metadado int;
  v_diferentes_alternativas int;
  v_diferentes_vinculo_unidade int;
  v_diferentes_vinculo_curso int;
  v_sem_explicacao_pos int;
  v_generica_ou_vazia int;
  v_incompletas int;
begin
  select * into v_antes from _snapshot_antes_agregado;

  select count(*) into v_total_questoes from public.questoes;
  select count(*) into v_total_alternativas from public.alternativas;
  select count(*) into v_total_vinculos_unidade from public.questao_unidades_pedagogicas;
  select count(*) into v_total_curso_questoes from public.curso_questoes;
  select count(*) into v_total_com_explicacao from public.questoes where explicacao is not null;

  call teste_sublote2_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_antes.total_questoes);
  call teste_sublote2_assert('nenhuma alternativa criada/removida/alterada em quantidade (total_alternativas inalterado)', v_total_alternativas = v_antes.total_alternativas);
  call teste_sublote2_assert('nenhum vinculo de unidade pedagogica criado/removido', v_total_vinculos_unidade = v_antes.total_vinculos_unidade);
  call teste_sublote2_assert('nenhum vinculo de curso_questoes criado/removido', v_total_curso_questoes = v_antes.total_curso_questoes);
  call teste_sublote2_assert('explicacao passou a existir em exatamente +38 questoes', v_total_com_explicacao = v_antes.total_com_explicacao + 38);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call teste_sublote2_assert('enunciado/fonte/banca/concurso/materia/assunto/ativa idênticos em todas as 38 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _snapshot_antes_questoes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call teste_sublote2_assert('alternativas (texto/correta/ordem) idênticas em todas as 38 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call teste_sublote2_assert('vinculos de unidade pedagogica idênticos em todas as 38 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call teste_sublote2_assert('vinculos de curso_questoes idênticos em todas as 38 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_sem_explicacao_pos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call teste_sublote2_assert('nenhuma das 38 ficou com explicacao vazia', v_sem_explicacao_pos = 0);

  select count(*) into v_generica_ou_vazia
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao ~* '^\\s*Gabarito (indicado|definitivo|oficial)|^\\s*O gabarito (definitivo|oficial)|^\\s*Quest[ãa]o original do concurso';
  call teste_sublote2_assert('nenhuma das 38 contém apenas boilerplate de gabarito/fonte', v_generica_ou_vazia = 0);

  with alt_stats as (
    select a.questao_id, count(*) as n_alt,
      bool_and(lower(btrim(a.texto)) in ('certo','errado')) and count(*) = 2 as eh_certo_errado
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ),
  reclassificado as (
    select q.id,
      case
        when st.eh_certo_errado then
          case when q.explicacao ~* 'GABARITO\\s*:\\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\\s*:' and q.explicacao ~* 'BIZU DE PROVA' then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
        else
          case when q.explicacao ~* 'GABARITO\\s*:' and q.explicacao ~* 'BIZU DE PROVA'
            and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\\s+([A-E])\\s+EST[ÁA]\\s+(CORRETA|INCORRETA)', 'gi') as m) >= st.n_alt
            then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
      end as status
    from public.questoes q
    join alt_stats st on st.questao_id = q.id
  )
  select count(*) into v_incompletas from reclassificado where status <> 'EXPLICACAO_COMPLETA';
  call teste_sublote2_assert('todas as 38 reclassificam como EXPLICACAO_COMPLETA pela mesma regra da auditoria', v_incompletas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_sublote2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
`;

fs.writeFileSync(OUT_PATH, sql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, OUT_PATH)}`);
console.log(`Questões no sub-lote: ${ids.length}`);
