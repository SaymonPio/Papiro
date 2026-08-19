-- ============================================================================
-- DESATIVACAO DE QUESTAO PROBLEMATICA -- NAO_RECUPERAVEL / FONTE_NAO_CONFIRMADA
-- ID 659 -- Direitos e Garantias Fundamentais (assunto_id 71, materia_id 10)
-- APLICACAO REAL -- TERMINA EM COMMIT. So rodar depois que
-- supabase/desativar_659_nao_recuperavel_teste_rollback.sql tiver rodado no
-- SQL Editor com TODOS os asserts passando (RESUMO N/N) -- confirmado pelo
-- usuario: "Success. No rows returned".
-- Mantem TODOS os mesmos asserts do harness (nao removidos) -- eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-desativar-659-apply.mjs
-- DIRETAMENTE a partir do texto do harness ja validado -- garante por
-- construcao que o corpo transacional e byte-a-byte identico entre harness
-- e apply. NAO editar este arquivo a mao -- editar
-- supabase/desativar_659_nao_recuperavel_teste_rollback.sql, validar de
-- novo no SQL Editor, e so entao regerar este apply.
--
-- Contexto: a questao 659 tem registro real de banca/concurso "FUNDATEC —
-- GM (Pref Gravataí)/Pref Gravataí/2026" -- confirmado no proprio banco e
-- preservado sem alteracao por este apply. No momento da decisao de
-- desativar (2026-08-18), o enunciado estava truncado/corrompido e a
-- alternativa A tinha fragmento de numeracao duplicado. Uma investigacao
-- externa anterior, feita por engano contra o concurso errado ("GM
-- Araquari/2026", nao o real "GM Gravataí/2026"), NAO fundamenta esta
-- decisao -- foi descartada por nao ter checado a prova certa.
-- Classificacao operacional definida pelo usuario: PROBLEMATICA —
-- NAO_RECUPERAVEL / FONTE_NAO_CONFIRMADA. Decisao de produto: nao
-- reconstruir o enunciado, nao alterar
-- alternativas/gabarito/banca/concurso/ano/fonte, nao escrever explicacao
-- -- apenas desativar (ativa = false), preservando todo o historico
-- integralmente.
--
-- ATUALIZACAO (2026-08-18, apos a desativacao ja aplicada): uma nova
-- investigacao, desta vez contra o concurso correto (GM Gravataí/2026),
-- localizou a prova oficial e o gabarito definitivo da FUNDATEC
-- (fundatec.org.br, concurso 1021) e confirmou a Questão 48 dessa prova
-- como a fonte real: enunciado e alternativas C/D/E batem integralmente
-- com o banco, e o gabarito oficial (B) confere com o gabarito ja marcado
-- no banco -- sem divergencia. A alternativa A e o corte do enunciado tem
-- explicacao: residuo de formatacao do PDF original ("garantido(a) o(a)"
-- colado com o marcador de lista da alternativa A). Classificacao
-- corrigida para RECUPERAVEL_COM_FONTE_OFICIAL. Esta atualizacao e apenas
-- documentacao -- nenhuma correcao de texto nem reativacao foi executada a
-- partir daqui; fica para uma decisao e harness futuros, separados deste.
--
-- Escopo estrito: altera SOMENTE `ativa` (+ `atualizado_em`) para
-- exatamente o id 659. Sem objetos permanentes: apenas CREATE TEMPORARY
-- TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline.
--
-- ESTE ARQUIVO TERMINA EM COMMIT. Rodar apenas com role de ESCRITA (nao
-- funciona via MCP read-only).
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES -- linha inteira de 659 (exceto ativa/atualizado_em, os
-- unicos campos autorizados a mudar), alternativas completas, e contagens
-- globais/assunto 71.
-- ----------------------------------------------------------------------------
create temporary table _d659_snap_questao on commit drop as
select id, ativa, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id = 659;

create temporary table _d659_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id = 659
group by questao_id;

create temporary table _d659_snap_global on commit drop as
select
  (select count(*) from public.questoes)               as total_questoes_antes,
  (select count(*) from public.questoes where ativa)    as total_ativas_antes,
  (select count(*) from public.questoes where assunto_id = 71 and ativa) as assunto71_ativas_antes;

create temporary table _d659_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes -- garante que o estado auditado ainda e o estado real antes
-- de escrever qualquer coisa.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
  v_ativas_antes int;
  v_assunto71_antes int;
begin
  select count(*) into v_qtd from public.questoes where id = 659;
  if v_qtd <> 1 then
    raise exception 'PRECONDICAO FALHOU: esperado 1 questao (659), encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes
    where id = 659
      and (assunto_id is distinct from 71 or materia_id is distinct from 10 or ativa is distinct from true)
  ) then
    raise exception 'PRECONDICAO FALHOU: 659 nao esta mais no estado auditado (assunto_id=71, materia_id=10, ativa=true)';
  end if;

  select count(*) into v_ativas_antes from public.questoes where ativa = true;
  if v_ativas_antes <> 909 then
    raise exception 'PRECONDICAO FALHOU: esperado 909 questoes ativas globais antes da desativacao, encontrado %', v_ativas_antes;
  end if;

  select count(*) into v_assunto71_antes from public.questoes where assunto_id = 71 and ativa = true;
  if v_assunto71_antes <> 22 then
    raise exception 'PRECONDICAO FALHOU: esperado 22 questoes ativas no assunto 71 antes da desativacao, encontrado %', v_assunto71_antes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (unica): desativa exclusivamente a questao 659.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas int;
begin
  update public.questoes
  set ativa = false, atualizado_em = now()
  where id = 659;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 1 linha, afetou %', v_linhas;
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
  v_assunto71_ativas_depois int;
  v_assunto71_completas_depois int;
begin
  insert into _d659_asserts (descricao, ok)
  select 'exatamente 1 questao afetada e o unico id afetado e 659 (ativa=false)',
    (select count(*) from public.questoes where id = 659 and ativa = false) = 1;

  insert into _d659_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/banca/concurso/ano/fonte/materia/assunto/explicacao preservados byte-a-byte (comparacao jsonb, exceto ativa/atualizado_em)',
    (select (to_jsonb(q) - 'ativa' - 'atualizado_em') from public.questoes q where q.id = 659)
    = (select dados_imutaveis from _d659_snap_questao);

  insert into _d659_asserts (descricao, ok)
  select 'alternativas (texto/correta/ordem = gabarito) de 659 continuam byte-identicas',
    (select jsonb_agg(to_jsonb(a) order by a.ordem) from public.alternativas a where a.questao_id = 659)
    = (select alternativas from _d659_snap_alternativas);

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _d659_asserts (descricao, ok)
  select 'nenhuma outra questao teve ativa alterada (total global de ativas caiu exatamente em 1)',
    v_ativas_depois = (select total_ativas_antes - 1 from _d659_snap_global);

  select count(*) into v_assunto71_ativas_depois from public.questoes where assunto_id = 71 and ativa = true;
  insert into _d659_asserts (descricao, ok)
  values ('assunto 71 (Direitos e Garantias Fundamentais) passa de 22 para 21 questoes ativas', v_assunto71_ativas_depois = 21);

  -- Classificacao EXPLICACAO_COMPLETA das 21 ativas restantes do assunto 71
  -- (mesma logica de supabase/classificar_explicacoes_questoes.sql).
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.assunto_id = 71 and q.ativa = true
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
    where q.assunto_id = 71 and q.ativa = true
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_assunto71_completas_depois from classificado;
  insert into _d659_asserts (descricao, ok)
  values ('as 21 ativas restantes do assunto 71 sao 21/21 EXPLICACAO_COMPLETA', v_assunto71_completas_depois = 21);

  -- Classificacao global (mesma logica, sem filtro de assunto).
  with alt_stats_g as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.ativa = true
    group by q.id
  ),
  classificado_g as (
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
    join alt_stats_g s on s.questao_id = q.id
    where q.ativa = true
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas_depois from classificado_g;

  select count(*) into v_total_depois from public.questoes;
  insert into _d659_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _d659_snap_global));

  insert into _d659_asserts (descricao, ok) values ('total global de questoes ativas passa de 909 para 908', v_ativas_depois = 908);

  insert into _d659_asserts (descricao, ok) values ('total global de EXPLICACAO_COMPLETA permanece 316', v_completas_depois = 316);

  insert into _d659_asserts (descricao, ok) values ('pendencias ativas globais (ativas - completas) passam de 593 para 592', (v_ativas_depois - v_completas_depois) = 592);
end $$;

-- Percorre os asserts na ordem em que foram inseridos, reportando cada um
-- (RAISE NOTICE) e abortando a transacao inteira no primeiro que falhar
-- (RAISE EXCEPTION). A tabela _d659_asserts desaparece sozinha ao fim da
-- transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _d659_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _d659_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Todos os asserts acima passaram (senao a transacao ja teria abortado por
-- RAISE EXCEPTION) -- confirma a escrita real: questao 659 desativada
-- (ativa=false), enunciado/alternativas/gabarito/banca/concurso/ano/fonte/
-- materia/assunto/explicacao preservados integralmente, nenhuma outra
-- questao tocada, assunto 71 com 21/21 EXPLICACAO_COMPLETA, contagens
-- globais batendo (908 ativas, 316 completas, 592 pendencias).
COMMIT;
