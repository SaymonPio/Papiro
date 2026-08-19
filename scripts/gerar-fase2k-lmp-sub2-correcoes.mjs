#!/usr/bin/env node
// Fase 2K — sub-lote 2 (Lei Maria da Penha): fecha as pendencias objetivas
// confirmadas na auditoria (auditoria/fase2k_lmp_sub2_resultado.json):
//
//   - ids 1293 e 1303: CORRECAO_EXPLICACAO. O texto de apoio afirmava "5
//     formas de violencia" (art. 7º) -- desde a Lei 15.384/2026 (art. 7º,
//     VI, violencia vicaria, confirmada em fonte oficial), sao 6. Nao
//     afeta o gabarito em nenhuma das duas (nenhuma alternativa depende do
//     total de modalidades). So altera public.questoes.explicacao, e
//     SOMENTE a frase que menciona o total de modalidades -- mesmo padrao
//     ja usado nas questoes 21 e 347 do Sub-lote 1.
//   - id 1295: higiene de dado, NAO e correcao juridica. Dois residuos de
//     scraping confirmados: (a) enunciado termina com o fragmento solto
//     "17/42" (paginacao de caderno vazada para o texto); (b) a
//     alternativa de ordem 2 (a correta) tem uma URL colada ao final
//     ("https://www.tecconcursos.com.br/questoes/cadernos/100938882/imprimir").
//     Confirmado por comparacao com a questao irma 1296 (mesmo padrao de
//     enunciado, sem residuo) que a forma limpa correta e o enunciado
//     terminando em "...esta correto o que se afirma em", sem nada depois,
//     e a alternativa terminando em "I e II, apenas.", sem nada depois
//     (mesmo padrao das demais alternativas desta questao). So altera
//     public.questoes.enunciado (id 1295) e public.alternativas.texto (id
//     1295, ordem 2) -- gabarito, explicacao e as demais 3 alternativas
//     permanecem byte-identicos.
//
//   id 1292 (RESSALVA_JURIDICA) NAO esta neste harness -- fica pendente
//   para auditoria isolada, conforme decisao do usuario.
//
// Gera harness (ROLLBACK) e aplicacao real (COMMIT) do MESMO corpo, mesmo
// padrao dos hotfixes anteriores (1324, emendas2026, desativacao
// 1337/1340, Fase 2K sub-lote 1).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub2_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub2_correcoes.sql');

// Mesmo usuario admin usado nos harnesses anteriores desta materia.
const ADMIN_USER_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hash (md5) da linha inteira de public.questoes (enunciado|fonte|banca|
// concurso|materia_id|assunto_id|ativa) e da explicacao (CRLF normalizado
// para LF), capturados AO VIVO via MCP read-only imediatamente antes de
// gerar este script -- precondicao: se o estado mudou desde a auditoria,
// a transacao inteira aborta.
const HASH_QUESTAO_ANTES = {
  1293: '36be13fcac05efca5410aa19d7be2d26',
  1295: 'a9a1f17123cb5579a9239d9e4ce50275',
  1303: 'ccd5ec086517afc97bd1284e350e62b4',
};
const HASH_ALTERNATIVAS_ANTES = {
  1295: '45f72161909d4af581b271279f3ac44f',
};

const EXPLICACAO_NOVA_1293 = "GABARITO: alternativa E\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\r\nO texto reproduz, com fidelidade, a redação do art. 7º, II, da Lei 11.340/2006, que define violência psicológica como qualquer conduta que cause dano emocional e diminuição da autoestima, ou que prejudique o pleno desenvolvimento, ou que vise degradar ou controlar as ações da mulher, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir.\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r\nEssa é a definição de violência FÍSICA (art. 7º, I) — conduta que ofende a integridade ou saúde corporal.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nEssa é a definição de violência PATRIMONIAL (art. 7º, IV) — retenção, subtração ou destruição de bens, documentos e instrumentos de trabalho.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nEssa é a definição de violência MORAL (art. 7º, V) — calúnia, difamação ou injúria.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nEssa é a definição de violência SEXUAL (art. 7º, III) — constranger a presenciar, manter ou participar de relação sexual não desejada, entre outras condutas ligadas à liberdade sexual e reprodutiva.\r\n\r\nBIZU DE PROVA:\r\nO art. 7º lista hoje 6 formas de violência (física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária) — decore o núcleo das 5 cobradas nesta questão: física = integridade/saúde corporal; psicológica = dano emocional/controle; sexual = constrangimento sexual/reprodutivo; patrimonial = bens/dinheiro; moral = calúnia/difamação/injúria. Bancas adoram trocar os rótulos entre si.";

const EXPLICACAO_NOVA_1303 = "GABARITO: alternativa A\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\r\nA alternativa sintetiza corretamente as 6 formas de violência criminalizadas pelo art. 7º (física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária) somadas às medidas de prevenção (art. 8º) e assistência às vítimas (arts. 9º e seguintes) previstas na Lei.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nNão existe obrigatoriedade de comparecimento a audiência de conciliação. Pelo contrário: o art. 41 afasta a aplicação da Lei 9.099/95 (onde existiriam institutos conciliatórios) justamente para não banalizar a violência doméstica como conflito de menor potencial ofensivo.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nNão há previsão de suspensão automática de procurações conferidas PELO agressor À ofendida. O que a Lei prevê (art. 24, III), como medida de proteção patrimonial, é o inverso: a suspensão de procurações conferidas PELA ofendida AO agressor.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nO art. 17 veda expressamente a aplicação de penas de cesta básica ou de outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa — não há incentivo a penas alternativas para reincidentes.\r\n\r\nBIZU DE PROVA:\r\nCuidado com a troca de sujeito na procuração — \"procuração da ofendida ao agressor\" é suspensa por lei; \"procuração do agressor à ofendida\" não tem previsão nenhuma. Leia com atenção quem é o outorgante.";

const ENUNCIADO_NOVO_1295 = "Considerando que a Lei Maria da Penha (Lei nº 11.340/2006) é um marco na proteção e no combate à violência doméstica e familiar contra a mulher no Brasil, analise as afirmativas a seguir. I. A Lei Maria da Penha prevê a criação de juizados especiais de violência doméstica e familiar contra a mulher, que são responsáveis por processar e julgar os casos de violência doméstica, bem como promover o atendimento multidisciplinar às vítimas. II. A Lei Maria da Penha estabelece medidas protetivas de urgência, que podem ser solicitadas pela vítima para garantir sua segurança e integridade física, como o afastamento do agressor do lar ou local de convivência com a vítima, a suspensão da posse ou restrição do porte de armas e a determinação de prestação de alimentos provisórios ou provisionais. III. A Lei Maria da Penha aplica-se a todas as formas de violência doméstica e familiar contra a mulher, incluindo violência física, psicológica, sexual, patrimonial e moral, abrangendo relações de convivência esporádica, sendo necessária a coabitação entre vítima e agressor para a caracterização da violência doméstica. Está correto o que se afirma em";

const ALTERNATIVA_2_NOVA_1295 = "I e II, apenas.";

function body(mode) {
  return `-- ============================================================================
-- FASE 2K — sub-lote 2 (Lei Maria da Penha): 2 correções de explicação
-- (1293, 1303) + 1 higiene de dado (1295)
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- ids 1293 e 1303 (CORRECAO_EXPLICACAO): o texto de apoio dizia "5 formas
-- de violência" (art. 7º) — desde a Lei 15.384/2026 (violência vicária,
-- art. 7º, VI, confirmada em fonte oficial) são 6. Não afeta o gabarito
-- em nenhuma das duas. ÚNICA coluna alterada: public.questoes.explicacao.
--
-- id 1295 (higiene de dado, NÃO é correção jurídica): remove dois
-- resíduos de scraping confirmados — "17/42" solto no final do
-- enunciado, e uma URL colada ao final da alternativa de ordem 2.
-- ÚNICAS colunas alteradas: public.questoes.enunciado e
-- public.alternativas.texto (id 1295, ordem 2). Gabarito, explicação e as
-- demais 3 alternativas permanecem byte-idênticos.
--
-- id 1292 (RESSALVA_JURIDICA) NÃO está neste harness — pendência isolada.
--
-- Evidência completa: auditoria/fase2k_lmp_sub2_resultado.json
--
-- Nenhuma outra questão é tocada — cada UPDATE tem WHERE por id único (ou
-- id+ordem, no caso da alternativa), GET DIAGNOSTICS confere exatamente 1
-- linha por escrita, e os asserts abaixo provam por comparação jsonb
-- byte-a-byte que nenhuma outra coluna/linha mudou.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = ${sqlStr(ADMIN_USER_ID)};

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
create temporary table _f2k2_snap_1293 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1293;

create temporary table _f2k2_snap_1303 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1303;

create temporary table _f2k2_snap_1295 on commit drop as
select id, explicacao, (to_jsonb(q) - 'enunciado' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1295;

create temporary table _f2k2_snap_alt_1293_1303 on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id in (1293, 1303) group by questao_id;

-- Para 1295, snapshot por alternativa individual (só a ordem 2 pode mudar).
create temporary table _f2k2_snap_alt_1295 on commit drop as
select id, ordem, texto, correta from public.alternativas where questao_id = 1295;

create temporary table _f2k2_snap_global on commit drop as
select (select count(*) from public.questoes) as total_questoes_antes,
       (select count(*) from public.alternativas) as total_alternativas_antes;

create temporary table _f2k2_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.questoes where id = 1293 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[1293])}) then
    raise exception 'PRECONDICAO FALHOU: questao 1293 nao esta mais no estado auditado';
  end if;

  if not exists (select 1 from public.questoes where id = 1303 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[1303])}) then
    raise exception 'PRECONDICAO FALHOU: questao 1303 nao esta mais no estado auditado';
  end if;

  if not exists (select 1 from public.questoes where id = 1295 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[1295])}) then
    raise exception 'PRECONDICAO FALHOU: questao 1295 nao esta mais no estado auditado (enunciado com residuo esperado)';
  end if;

  if not exists (
    select 1 from (
      select md5(string_agg(ordem::text || ':' || texto || ':' || correta::text, '|' order by ordem)) as h
      from public.alternativas where questao_id = 1295
    ) x where x.h = ${sqlStr(HASH_ALTERNATIVAS_ANTES[1295])}
  ) then
    raise exception 'PRECONDICAO FALHOU: alternativas da questao 1295 nao estao mais no estado auditado (URL residual esperada)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — corrige exclusivamente a explicação da questão 1293.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = ${sqlStr(EXPLICACAO_NOVA_1293)} where id = 1293;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 1 FALHOU: esperado UPDATE de exatamente 1 linha (1293), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — corrige exclusivamente a explicação da questão 1303.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = ${sqlStr(EXPLICACAO_NOVA_1303)} where id = 1303;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 2 FALHOU: esperado UPDATE de exatamente 1 linha (1303), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — remove o resíduo "17/42" do enunciado da questão 1295.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_1295)} where id = 1295;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 3 FALHOU: esperado UPDATE de exatamente 1 linha (1295), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 4 — remove a URL colada na alternativa de ordem 2 da questão
-- 1295. WHERE por questao_id + ordem: impossível atingir outra linha.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.alternativas set texto = ${sqlStr(ALTERNATIVA_2_NOVA_1295)}
  where questao_id = 1295 and ordem = 2;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 4 FALHOU: esperado UPDATE de exatamente 1 linha (1295/ordem2), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k2_asserts (descricao, ok)
  select 'nenhuma questao criada/removida (total_questoes inalterado)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k2_snap_global);

  insert into _f2k2_asserts (descricao, ok)
  select 'nenhuma alternativa criada/removida (total_alternativas inalterado)',
    (select count(*) from public.alternativas) = (select total_alternativas_antes from _f2k2_snap_global);

  -- 1293
  insert into _f2k2_asserts (descricao, ok)
  select '1293: nenhuma coluna alem de explicacao/atualizado_em mudou (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q join _f2k2_snap_1293 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k2_asserts (descricao, ok)
  select '1293: explicacao atualizada para o texto corrigido exato',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 1293)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_1293)}, E'\\r\\n', E'\\n', 'g');
  insert into _f2k2_asserts (descricao, ok)
  select '1293: continua ativa = true',
    (select ativa from public.questoes where id = 1293) = true;

  -- 1303
  insert into _f2k2_asserts (descricao, ok)
  select '1303: nenhuma coluna alem de explicacao/atualizado_em mudou (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q join _f2k2_snap_1303 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k2_asserts (descricao, ok)
  select '1303: explicacao atualizada para o texto corrigido exato',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 1303)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_1303)}, E'\\r\\n', E'\\n', 'g');
  insert into _f2k2_asserts (descricao, ok)
  select '1303: continua ativa = true',
    (select ativa from public.questoes where id = 1303) = true;

  -- Gabarito (alternativas texto/ordem/correta) de 1293 e 1303 intacto.
  insert into _f2k2_asserts (descricao, ok)
  select '1293 e 1303: alternativas (gabarito) permanecem byte-identicas',
    not exists (
      select 1 from _f2k2_snap_alt_1293_1303 s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a where a.questao_id in (1293, 1303) group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  -- 1295
  insert into _f2k2_asserts (descricao, ok)
  select '1295: nenhuma coluna alem de enunciado/atualizado_em mudou (jsonb byte-a-byte, inclui explicacao)',
    not exists (
      select 1 from public.questoes q join _f2k2_snap_1295 s on s.id = q.id
      where (to_jsonb(q) - 'enunciado' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k2_asserts (descricao, ok)
  select '1295: enunciado atualizado para o texto corrigido exato (residuo 17/42 removido)',
    (select enunciado from public.questoes where id = 1295) = ${sqlStr(ENUNCIADO_NOVO_1295)};
  insert into _f2k2_asserts (descricao, ok)
  select '1295: continua ativa = true',
    (select ativa from public.questoes where id = 1295) = true;
  insert into _f2k2_asserts (descricao, ok)
  select '1295: alternativas de ordem 1, 3 e 4 permanecem byte-identicas (texto/correta)',
    not exists (
      select 1 from public.alternativas a
      join _f2k2_snap_alt_1295 s on s.id = a.id
      where s.ordem <> 2 and (a.texto <> s.texto or a.correta <> s.correta or a.ordem <> s.ordem)
    );
  insert into _f2k2_asserts (descricao, ok)
  select '1295: alternativa de ordem 2 continua marcada correta=true e ordem=2',
    (select correta from public.alternativas where questao_id = 1295 and ordem = 2) = true;
  insert into _f2k2_asserts (descricao, ok)
  select '1295: alternativa de ordem 2 atualizada para o texto corrigido exato (URL removida)',
    (select texto from public.alternativas where questao_id = 1295 and ordem = 2) = ${sqlStr(ALTERNATIVA_2_NOVA_1295)};
  insert into _f2k2_asserts (descricao, ok)
  select '1295: continua com exatamente 4 alternativas e exatamente 1 correta',
    (select count(*) from public.alternativas where questao_id = 1295) = 4
    and (select count(*) from public.alternativas where questao_id = 1295 and correta) = 1;
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 2 falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada commitado: staging, UPDATEs de teste e tabelas de assert — tudo\n-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.\nROLLBACK;\n`
    : `-- Escrita real confirmada pelos asserts acima — persistida agora.\nCOMMIT;\n`}`;
}

const harnessSql = body('rollback');
const applySql = body('commit');

const harnessCore = harnessSql
  .replace('HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.', '')
  .replace(/-- Nada commitado:[\s\S]*ROLLBACK;\n$/, '');
const applyCore = applySql
  .replace('APLICAÇÃO REAL — TERMINA EM COMMIT.', '')
  .replace(/-- Escrita real confirmada[\s\S]*COMMIT;\n$/, '');
if (harnessCore !== applyCore) {
  throw new Error('Harness e apply divergem fora do bloco esperado (modo/rollback-commit) — gerar novamente.');
}

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log('Harness e apply verificados: identicos exceto pelo modo (ROLLBACK vs COMMIT).');
