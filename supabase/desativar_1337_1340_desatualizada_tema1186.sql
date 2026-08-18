-- ============================================================================
-- DESATIVACAO DE QUESTOES DESATUALIZADA_TEMA_1186_STJ — Lei Maria da Penha
-- IDs 1337 e 1340 (assunto_id = 19)
-- APLICACAO REAL — TERMINA EM COMMIT. So rodar depois que
-- supabase/desativar_1337_1340_desatualizada_tema1186_teste_rollback.sql
-- tiver rodado no SQL Editor com TODOS os asserts passando (RESUMO N/N).
-- Mantem TODOS os mesmos asserts do harness (nao removidos) — eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
-- Contexto: as questoes 1337 (CEBRASPE/CESPE — Escrivao PC BA — 2013) e 1340
-- (FGR — GM Pref Congonhas — 2012) tem gabarito historico que dependia da
-- doutrina pre-2023/pre-Tema 1186 (exigencia de motivacao de genero como
-- requisito autonomo da LMP para castigo/maus-tratos de pai/mae contra
-- filha). O art. 40-A da LMP (incluido pela Lei 14.550/2023: "aplicada...
-- independentemente da causa ou da motivacao dos atos de violencia e da
-- condicao do ofensor ou da ofendida") e o Tema Repetitivo 1186/STJ (REsp
-- 2.015.598/PA, 3a Secao, Min. Ribeiro Dantas, transito em julgado em
-- 23/10/2025, tese vinculante: "a condicao de genero feminino e suficiente
-- para atrair a aplicabilidade da Lei Maria da Penha em casos de violencia
-- domestica e familiar", prevalecendo sobre o criterio etario e sobre o
-- ECA) eliminaram essa exigencia, invertendo a resposta juridicamente
-- correta das duas:
--   - 1337 (Certo/Errado): gabarito original CERTO ("nao e da competencia
--     dos juizados"). Hoje seria ERRADO.
--   - 1340 (multipla escolha): gabarito original "Apenas I e II". A
--     assertiva II depende da mesma premissa hoje superada; o gabarito
--     consistente com o entendimento atual seria "Apenas I".
--
-- Decisao de produto (usuario, 2026-08-18, apos auditoria juridica
-- apresentada e aprovada): NAO reescrever o gabarito historico da banca,
-- NAO escrever explicacao pedagogica que o justifique como correto hoje, e
-- retirar as duas de circulacao (ativa = false), preservando integralmente
-- enunciado, alternativas, alternativa originalmente marcada como correta,
-- banca, concurso, fonte e demais metadados historicos.
--
-- Classificacao de auditoria: DESATUALIZADA_TEMA_1186_STJ. A tabela
-- public.questoes NAO possui coluna propria de classificacao/motivo
-- (conferido via information_schema.columns em 2026-08-18: id, materia_id,
-- assunto_id, usuario_id, banca, concurso, enunciado, dificuldade,
-- explicacao, fonte, ano, ativa, gerada_por_ia, criado_em, atualizado_em)
-- — por isso essa classificacao NAO e persistida em nenhuma coluna do
-- banco; vive apenas nesta documentacao e no relatorio entregue ao
-- usuario, conforme instrucao explicita ("eventual campo... se ja existir
-- no modelo").
--
-- Escopo estrito: altera SOMENTE `ativa` (+ `atualizado_em` — esta tabela
-- nao tem trigger de auto-atualizacao, por isso e setado explicitamente)
-- para exatamente os ids 1337 e 1340. Nenhuma outra coluna, nenhuma outra
-- linha, nenhuma tabela relacionada (alternativas, curso_questoes,
-- questao_unidades_pedagogicas) e tocada. Os asserts abaixo provam isso
-- por comparacao byte-a-byte de snapshot antes/depois, nao so pela leitura
-- do UPDATE em si.
--
-- Sem objetos permanentes: todo o rastreio de asserts usa apenas CREATE
-- TEMPORARY TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline (sem
-- CREATE FUNCTION/PROCEDURE), mesmo padrao adotado na Fase 3C.
--
-- Usa a MESMA simulacao de claim JWT do admin cadastrado (via "set
-- local"), restrita a esta transacao, no mesmo padrao ja usado nos
-- harnesses anteriores desta materia. Precisa rodar com um role de
-- ESCRITA (nao funciona via MCP read-only).
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — linha inteira das 2 questoes-alvo (exceto ativa e
-- atualizado_em, os unicos campos autorizados a mudar), alternativas
-- completas das 2, e contagens globais — para provar depois que nada mais
-- no banco foi tocado.
-- ----------------------------------------------------------------------------
create temporary table _desat_snap_questoes on commit drop as
select id, ativa, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (1337, 1340);

create temporary table _desat_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (1337, 1340)
group by questao_id;

create temporary table _desat_snap_global on commit drop as
select
  (select count(*) from public.questoes)               as total_questoes_antes,
  (select count(*) from public.questoes where ativa)    as total_ativas_antes;

create temporary table _desat_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes — garante que o estado auditado (SEM_EXPLICACAO, ativa,
-- assunto LMP, 297 ativas no total) ainda e o estado real antes de
-- escrever qualquer coisa.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
  v_ativas_antes int;
begin
  select count(*) into v_qtd from public.questoes where id in (1337, 1340);
  if v_qtd <> 2 then
    raise exception 'PRECONDICAO FALHOU: esperado 2 questoes (1337, 1340), encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes
    where id in (1337, 1340)
      and (assunto_id is distinct from 19 or ativa is distinct from true
           or (explicacao is not null and btrim(explicacao) <> ''))
  ) then
    raise exception 'PRECONDICAO FALHOU: 1337/1340 nao estao mais no estado auditado (assunto_id=19, ativa=true, sem explicacao)';
  end if;

  select count(*) into v_ativas_antes from public.questoes where assunto_id = 19 and ativa = true;
  if v_ativas_antes <> 297 then
    raise exception 'PRECONDICAO FALHOU: esperado 297 questoes ativas de LMP antes da desativacao, encontrado %', v_ativas_antes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (unica) — desativa exclusivamente as 2 questoes-alvo. Gabarito,
-- enunciado, alternativas, banca, concurso, fonte: intocados.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas int;
begin
  update public.questoes
  set ativa = false, atualizado_em = now()
  where id in (1337, 1340);
  get diagnostics v_linhas = row_count;
  if v_linhas <> 2 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 2 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_ativas_depois int;
  v_completas_depois int;
  v_total_depois int;
begin
  insert into _desat_asserts (descricao, ok)
  select '1337 e 1340 estao ativa = false',
    (select count(*) from public.questoes where id in (1337,1340) and ativa = false) = 2;

  insert into _desat_asserts (descricao, ok)
  select 'nenhuma coluna alem de ativa/atualizado_em mudou em 1337/1340 (comparacao jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _desat_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _desat_asserts (descricao, ok)
  select 'alternativas de 1337/1340 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _desat_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (1337, 1340)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  insert into _desat_asserts (descricao, ok)
  select 'nenhuma linha foi criada/excluida em questoes (contagem total inalterada)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _desat_snap_global);

  insert into _desat_asserts (descricao, ok)
  select 'total global de questoes ativas caiu exatamente em 2 (nenhuma outra linha teve ativa alterado)',
    (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes - 2 from _desat_snap_global);

  insert into _desat_asserts (descricao, ok)
  select '1337 e 1340 continuam sem explicacao preenchida (nenhuma explicacao pedagogica foi escrita)',
    (select count(*) from public.questoes where id in (1337,1340) and (explicacao is null or btrim(explicacao) = '')) = 2;

  select count(*) into v_ativas_depois from public.questoes where assunto_id = 19 and ativa = true;
  insert into _desat_asserts (descricao, ok) values ('assunto LMP tem exatamente 295 questoes ativas apos a desativacao', v_ativas_depois = 295);

  select count(*) into v_total_depois from public.questoes where assunto_id = 19;
  insert into _desat_asserts (descricao, ok) values ('total de questoes de LMP no banco permanece 301 (nada foi excluido)', v_total_depois = 301);

  -- Classificacao EXPLICACAO_COMPLETA das 295 ativas restantes (mesma
  -- logica de supabase/classificar_explicacoes_questoes.sql).
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.assunto_id = 19 and q.ativa = true
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.assunto_id = 19 and q.ativa = true
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas_depois from classificado;

  insert into _desat_asserts (descricao, ok) values ('as 295 questoes ativas de LMP sao 295/295 EXPLICACAO_COMPLETA', v_completas_depois = 295);
end $$;

-- Percorre os asserts na ordem em que foram inseridos, reportando cada um
-- (RAISE NOTICE) e abortando a transacao inteira no primeiro que falhar
-- (RAISE EXCEPTION). A tabela _desat_asserts desaparece sozinha ao fim da
-- transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _desat_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _desat_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Todos os asserts acima passaram (senao a transacao ja teria abortado por
-- RAISE EXCEPTION) — confirma a escrita real: 1337 e 1340 desativadas
-- (ativa=false), gabarito/enunciado/alternativas/demais metadados
-- intocados, 295 questoes ativas de LMP restantes, todas EXPLICACAO_COMPLETA.
COMMIT;
