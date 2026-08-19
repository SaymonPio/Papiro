-- ============================================================================
-- FASE 2K — sub-lote 4: desativação das questões 1335 e 1346
-- APLICAÇÃO REAL — TERMINA EM COMMIT.
-- ============================================================================
--
-- id 1346 (QUESTAO_DESATUALIZADA): gabarito e explicação reproduzem regra
-- de custeio de dispositivos de monitoramento pelo agressor, revogada
-- pelo art. 5º da Lei 15.383/2026 (em vigor desde 10/04/2026). Nenhuma
-- das 5 alternativas descreve a regra hoje vigente.
--
-- id 1335 (RESSALVA_JURIDICA): alternativa marcada correta reproduz
-- literalmente o art. 20 da Lei ("de ofício"), mas há controvérsia real e
-- não pacificada (STJ dividido) sobre a subsistência dessa previsão após
-- a reforma do art. 311 do CPP pelo Pacote Anticrime (Lei 13.964/2019).
-- Decisão de produto: desativar em vez de manter questão controvertida
-- ativa.
--
-- Evidência completa: auditoria/fase2k_lmp_sub4_resultado.json
--
-- Em AMBOS os casos: NÃO se reescreve gabarito, explicação ou
-- alternativas — só ativa=false. Nenhuma outra questão é tocada —
-- provado abaixo por GET DIAGNOSTICS (exatamente 2 linhas) e por
-- comparação jsonb byte-a-byte de todas as demais colunas antes/depois,
-- mesmo padrão do harness de desativação de 1337/1340 e da questão 344.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — linha inteira das 2 questões-alvo (exceto ativa e
-- atualizado_em, os únicos campos autorizados a mudar).
-- ----------------------------------------------------------------------------
create temporary table _f2k4_snap_questoes on commit drop as
select id, ativa, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (1335, 1346);

create temporary table _f2k4_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (1335, 1346)
group by questao_id;

create temporary table _f2k4_snap_global on commit drop as
select
  (select count(*) from public.questoes) as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _f2k4_staging (
  questao_id bigint primary key,
  hash_questao_esperado text,
  hash_explicacao_esperado text
) on commit drop;

insert into _f2k4_staging (questao_id, hash_questao_esperado, hash_explicacao_esperado) values
  (1335, '90bfc645116e23d0798ab5d592da3e15', '4bd09b5db310002b989b434f348210c8'),
  (1346, '40f46c0021fb951c2654f8318b3cba4c', '8eebc8988f8de6d791a61e5e1e50fc72');

create temporary table _f2k4_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
  v_divergentes int;
begin
  select count(*) into v_qtd from _f2k4_staging;
  if v_qtd <> 2 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 2 questoes (tem %)', v_qtd;
  end if;

  select count(*) into v_divergentes
  from public.questoes q
  join _f2k4_staging s on s.questao_id = q.id
  where q.ativa is distinct from true
     or md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> s.hash_questao_esperado
     or md5(regexp_replace(q.explicacao, E'\r\n', E'\n', 'g')) <> s.hash_explicacao_esperado;
  if v_divergentes > 0 then
    raise exception 'PRECONDICAO FALHOU: % questao(oes) nao esta(ao) mais no estado auditado -- abortando por seguranca', v_divergentes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (única) — desativa exclusivamente as 2 questões-alvo. Gabarito,
-- enunciado, alternativas, explicação, banca, concurso, fonte: intocados.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas int;
begin
  update public.questoes
  set ativa = false, atualizado_em = now()
  where id in (1335, 1346);
  get diagnostics v_linhas = row_count;
  if v_linhas <> 2 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 2 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k4_asserts (descricao, ok)
  select '1335 e 1346 estao ativa = false',
    (select count(*) from public.questoes where id in (1335,1346) and ativa = false) = 2;

  insert into _f2k4_asserts (descricao, ok)
  select 'nenhuma coluna alem de ativa/atualizado_em mudou em 1335/1346 (comparacao jsonb byte-a-byte, inclui explicacao)',
    not exists (
      select 1 from public.questoes q
      join _f2k4_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _f2k4_asserts (descricao, ok)
  select 'alternativas de 1335/1346 (texto/ordem/correta — gabarito) continuam byte-identicas',
    not exists (
      select 1
      from _f2k4_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (1335, 1346)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  insert into _f2k4_asserts (descricao, ok)
  select 'nenhuma linha foi criada/excluida em questoes (contagem total inalterada)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k4_snap_global);

  insert into _f2k4_asserts (descricao, ok)
  select 'total global de questoes ativas caiu exatamente em 2 (nenhuma outra linha teve ativa alterado)',
    (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes - 2 from _f2k4_snap_global);

  insert into _f2k4_asserts (descricao, ok)
  select '1335 e 1346 preservam explicacao/gabarito historico da banca (nao foram reescritos)',
    (select count(*) from public.questoes q join _f2k4_staging s on s.questao_id = q.id
     where md5(regexp_replace(q.explicacao, E'\r\n', E'\n', 'g')) = s.hash_explicacao_esperado) = 2;
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k4_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 4 (desativacoes) falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Escrita real confirmada pelos asserts acima — persistida agora.
COMMIT;
