-- ============================================================================
-- TESTE RUNTIME DA CORREÇÃO "BANCO GERAL NA MISSÃO FINAL" — TRANSACIONAL,
-- TUDO DESFEITO NO FINAL (ROLLBACK)
-- ============================================================================
--
-- Cobre exclusivamente a mudança de
-- supabase/corrigir_selecionar_candidatas_conteudo_banco_geral.sql
-- (CREATE OR REPLACE de public.selecionar_candidatas_conteudo). Escopo
-- deliberadamente restrito às DUAS funções de seleção
-- (selecionar_candidatas_unidade_pedagogica, inalterada, e
-- selecionar_candidatas_conteudo, alterada) — são elas que decidem quem
-- entra na prática de unidade e na Missão Final; iniciar_pratica_unidade/
-- iniciar_missao_final só orquestram em cima delas (gating de teoria
-- concluída, aula publicada etc.) e não foram tocadas por este patch, já
-- cobertas pelo harness anterior (missao_pratica_papiro_teste_rollback.sql).
--
-- Colar no SQL Editor do Supabase com um usuário com permissão de escrita
-- (este harness NÃO pode rodar via um MCP/role read-only — toda escrita,
-- inclusive dentro de uma transação destinada a ROLLBACK, é rejeitada por
-- um role com default_transaction_read_only=on). Rodar de uma vez, ler o
-- resultado (RAISE NOTICE de cada assert), nunca persistir nada — termina
-- em ROLLBACK.
--
-- Fixtures criadas só dentro desta transação, isoladas em dois conteúdos
-- fixture NOVOS (cada um com seu próprio assunto fixture novo) — nunca
-- toca o conteúdo real da Lei Maria da Penha (id=53) nem qualquer questão
-- real:
--   - Conteúdo A ("[TESTE FIX] Conteudo alvo"): unidades U1 e U5 fixture,
--     mais as questões de teste principais.
--   - Conteúdo B ("[TESTE FIX] Outro conteudo"): 1 unidade fixture + 2
--     questões fixture, usado só para provar isolamento (nunca vazam para
--     o conteúdo A e vice-versa).
--
-- Precisa de 1 matrícula ATIVA real só para herdar curso_id/usuario_id
-- válidos (mesmo requisito do harness anterior) — nenhuma linha da
-- matrícula/curso real é alterada, só lida.
--
-- Corpo do patch é aplicado ANTES das fixtures (idêntico ao arquivo, sem o
-- REVOKE final ser problema — REVOKE dentro de transação também desfaz no
-- ROLLBACK).

BEGIN;

do $$
begin
  if not exists (select 1 from public.matriculas where status = 'ativa') then
    raise exception 'Teste abortado: nenhuma matricula ativa real encontrada.';
  end if;
end $$;

-- ============================================================================
-- CORPO DO PATCH (idêntico a
-- supabase/corrigir_selecionar_candidatas_conteudo_banco_geral.sql)
-- ============================================================================

create or replace function public.selecionar_candidatas_conteudo(
  p_usuario_id uuid,
  p_conteudo_id bigint,
  p_curso_id uuid,
  p_quantidade integer,
  p_excluir bigint[],
  p_missao_id uuid default null
)
returns table (questao_id bigint)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_janela_repeticao constant interval := interval '24 hours';
  v_assunto_id bigint;
begin
  select cc.assunto_id
  into v_assunto_id
  from public.curso_conteudos cc
  where cc.id = p_conteudo_id;

  return query
  select q.id
  from public.questoes q
  join public.curso_questoes cq
    on cq.questao_id = q.id
   and cq.curso_id = p_curso_id
  left join lateral (
    select
      count(*) as vezes_respondida,
      bool_or(not ru.acertou) as ja_errou,
      max(ru.respondida_em) as ultima_vez
    from public.respostas_usuarios ru
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
  ) hist on true
  left join lateral (
    select true as usada_na_missao_atual
    from public.respostas_usuarios ru
    join public.sessoes_estudo s on s.id = ru.sessao_id
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
      and p_missao_id is not null
      and s.missao_id = p_missao_id
      and s.tipo_pratica = 'unidade'
    limit 1
  ) miss on true
  where q.ativa = true
    and not (q.id = any(coalesce(p_excluir, '{}'::bigint[])))
    and (
      exists (
        select 1
        from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u
          on u.id = qup.unidade_pedagogica_id
         and u.curso_conteudo_id = p_conteudo_id
         and u.ativa = true
        where qup.questao_id = q.id
      )
      or (
        v_assunto_id is not null
        and q.assunto_id = v_assunto_id
        and not exists (
          select 1
          from public.questao_unidades_pedagogicas qup2
          join public.unidades_pedagogicas u2
            on u2.id = qup2.unidade_pedagogica_id
           and u2.curso_conteudo_id = p_conteudo_id
          where qup2.questao_id = q.id
        )
      )
    )
  order by
    (coalesce(hist.vezes_respondida, 0) = 0) desc,
    (
      coalesce(hist.vezes_respondida, 0) > 0
      and (
        coalesce(hist.ultima_vez, '-infinity'::timestamptz) >= now() - v_janela_repeticao
        or coalesce(miss.usada_na_missao_atual, false)
      )
    ) asc,
    coalesce(hist.ja_errou, false) desc,
    coalesce(hist.ultima_vez, '-infinity'::timestamptz) asc,
    cq.prioridade asc,
    random()
  limit greatest(0, p_quantidade);
end;
$function$;

revoke execute on function public.selecionar_candidatas_conteudo(uuid, bigint, uuid, integer, bigint[], uuid)
  from public, anon, authenticated;

-- ============================================================================
-- CONTEXTO E CONTADOR DE ASSERTS (tabelas de escopo desta transação — nunca
-- persistem, o ROLLBACK final desfaz até o CREATE TABLE)
-- ============================================================================

create table teste_fix_missao_final_contexto (chave text primary key, valor text);
create table teste_fix_missao_final_asserts (ordem serial primary key, descricao text, ok boolean);

-- PL/pgSQL nao permite function/procedure aninhada dentro do DECLARE de um
-- DO $$ -- por isso o helper de assert precisa ser uma procedure de nivel
-- superior (tambem desfeita pelo ROLLBACK final, como qualquer outra DDL
-- desta transacao), chamada via CALL de dentro do BLOCO 3.
create procedure teste_fix_missao_final_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_fix_missao_final_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

-- ============================================================================
-- BLOCO 1 — reaproveita matrícula/curso/usuário reais (só leitura)
-- ============================================================================

do $$
declare
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_curso_id uuid;
  v_curso_materia_id bigint;
  v_materia_id bigint;
begin
  select m.id, m.usuario_id, m.curso_id
  into v_matricula_id, v_usuario_id, v_curso_id
  from public.matriculas m
  where m.status = 'ativa'
  order by m.id
  limit 1;

  select cm.id, cm.materia_id
  into v_curso_materia_id, v_materia_id
  from public.curso_materias cm
  where cm.curso_id = v_curso_id
  order by cm.id
  limit 1;

  if v_curso_materia_id is null then
    raise exception 'Teste abortado: nenhum curso_materias encontrado para o curso da matricula de teste.';
  end if;

  insert into teste_fix_missao_final_contexto (chave, valor) values
    ('matricula_id', v_matricula_id::text),
    ('usuario_id', v_usuario_id::text),
    ('curso_id', v_curso_id::text),
    ('curso_materia_id', v_curso_materia_id::text),
    ('materia_id', v_materia_id::text);
end $$;

-- ============================================================================
-- BLOCO 2 — fixtures: 2 conteúdos isolados (A = alvo, B = "outro
-- conteúdo"), cada um com assunto fixture próprio, unidades fixture e
-- questões fixture cobrindo os 6 casos do enunciado.
-- ============================================================================

do $$
declare
  v_curso_materia_id bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'curso_materia_id');
  v_materia_id bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'materia_id');
  v_curso_id uuid := (select valor::uuid from teste_fix_missao_final_contexto where chave = 'curso_id');

  v_assunto_a bigint;
  v_assunto_b bigint;
  v_conteudo_a bigint;
  v_conteudo_b bigint;
  v_u1 uuid;
  v_u5 uuid;
  v_u_outro uuid;

  v_q_u1 bigint;
  v_q_u5 bigint;
  v_q_multi bigint;
  v_q_geral_1 bigint;
  v_q_geral_2 bigint;
  v_q_geral_inativa bigint;
  v_q_u1_inativa bigint;
  v_q_outro_vinculada bigint;
  v_q_outro_geral bigint;
begin
  insert into public.assuntos (materia_id, nome) values (v_materia_id, '[TESTE FIX] Assunto A (conteudo alvo)') returning id into v_assunto_a;
  insert into public.assuntos (materia_id, nome) values (v_materia_id, '[TESTE FIX] Assunto B (outro conteudo)') returning id into v_assunto_b;

  insert into public.curso_conteudos (curso_materia_id, assunto_id, ordem)
    values (v_curso_materia_id, v_assunto_a, 9001) returning id into v_conteudo_a;
  insert into public.curso_conteudos (curso_materia_id, assunto_id, ordem)
    values (v_curso_materia_id, v_assunto_b, 9002) returning id into v_conteudo_b;

  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo)
    values (v_conteudo_a, '[TESTE FIX] U1', 1, 'Escopo de teste U1') returning id into v_u1;
  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo)
    values (v_conteudo_a, '[TESTE FIX] U5', 5, 'Escopo de teste U5') returning id into v_u5;
  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo)
    values (v_conteudo_b, '[TESTE FIX] U-outro', 1, 'Escopo de teste do outro conteudo') returning id into v_u_outro;

  -- Caso 1: questao somente U1.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao somente U1', true) returning id into v_q_u1;
  -- Caso 2: questao somente U5.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao somente U5', true) returning id into v_q_u5;
  -- Caso 3: questao multiunidade U1+U5.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao multiunidade U1+U5', true) returning id into v_q_multi;
  -- Caso 4: banco geral (sem vinculo), valida para o conteudo A -- 2 fixtures.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao banco geral 1 (sem vinculo)', true) returning id into v_q_geral_1;
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao banco geral 2 (sem vinculo)', true) returning id into v_q_geral_2;
  -- Caso 6a: banco geral, mas INATIVA -- nunca deve aparecer em nada.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao banco geral INATIVA', false) returning id into v_q_geral_inativa;
  -- Caso 6b: vinculada a U1, mas INATIVA -- nunca deve aparecer em nada.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_a, '[TESTE FIX] questao U1 INATIVA', false) returning id into v_q_u1_inativa;
  -- Caso 5a: questao de OUTRO conteudo, vinculada a unidade do conteudo B.
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_b, '[TESTE FIX] questao do OUTRO conteudo, vinculada', true) returning id into v_q_outro_vinculada;
  -- Caso 5b: questao de OUTRO conteudo, banco geral (assunto B, sem vinculo).
  insert into public.questoes (materia_id, assunto_id, enunciado, ativa)
    values (v_materia_id, v_assunto_b, '[TESTE FIX] questao do OUTRO conteudo, banco geral', true) returning id into v_q_outro_geral;

  -- Todas as 9 questoes fixture entram em curso_questoes do MESMO curso real
  -- (isolamento por curso continua sendo testado pelas duas chamadas com
  -- p_curso_id = v_curso_id -- nenhuma fixture usa outro curso porque o
  -- harness so tem 1 curso real disponivel; o isolamento por CONTEUDO,
  -- que e o que este patch de fato muda, e coberto pelos casos 5a/5b).
  insert into public.curso_questoes (curso_id, questao_id)
  select v_curso_id, q from unnest(array[
    v_q_u1, v_q_u5, v_q_multi, v_q_geral_1, v_q_geral_2,
    v_q_geral_inativa, v_q_u1_inativa, v_q_outro_vinculada, v_q_outro_geral
  ]) as q;

  insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id) values
    (v_q_u1, v_u1),
    (v_q_u5, v_u5),
    (v_q_multi, v_u1),
    (v_q_multi, v_u5),
    (v_q_u1_inativa, v_u1),
    (v_q_outro_vinculada, v_u_outro);

  insert into teste_fix_missao_final_contexto (chave, valor) values
    ('conteudo_a', v_conteudo_a::text),
    ('conteudo_b', v_conteudo_b::text),
    ('u1', v_u1::text),
    ('u5', v_u5::text),
    ('u_outro', v_u_outro::text),
    ('q_u1', v_q_u1::text),
    ('q_u5', v_q_u5::text),
    ('q_multi', v_q_multi::text),
    ('q_geral_1', v_q_geral_1::text),
    ('q_geral_2', v_q_geral_2::text),
    ('q_geral_inativa', v_q_geral_inativa::text),
    ('q_u1_inativa', v_q_u1_inativa::text),
    ('q_outro_vinculada', v_q_outro_vinculada::text),
    ('q_outro_geral', v_q_outro_geral::text);
end $$;

-- ============================================================================
-- BLOCO 3 — asserts. p_quantidade = 50 em toda chamada (bem acima do total
-- de fixtures) para garantir que LIMIT nunca corta uma candidata elegível
-- e a comparação de conjunto seja exata, não uma amostra.
-- ============================================================================

do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_fix_missao_final_contexto where chave = 'usuario_id');
  v_curso_id uuid := (select valor::uuid from teste_fix_missao_final_contexto where chave = 'curso_id');
  v_conteudo_a bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'conteudo_a');
  v_conteudo_b bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'conteudo_b');
  v_u1 uuid := (select valor::uuid from teste_fix_missao_final_contexto where chave = 'u1');
  v_u5 uuid := (select valor::uuid from teste_fix_missao_final_contexto where chave = 'u5');

  v_q_u1 bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_u1');
  v_q_u5 bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_u5');
  v_q_multi bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_multi');
  v_q_geral_1 bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_geral_1');
  v_q_geral_2 bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_geral_2');
  v_q_geral_inativa bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_geral_inativa');
  v_q_u1_inativa bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_u1_inativa');
  v_q_outro_vinculada bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_outro_vinculada');
  v_q_outro_geral bigint := (select valor::bigint from teste_fix_missao_final_contexto where chave = 'q_outro_geral');

  v_unidade_u1 bigint[];
  v_unidade_u5 bigint[];
  v_conteudo_res_a bigint[];
  v_conteudo_res_b bigint[];
begin
  select array_agg(x.questao_id) into v_unidade_u1
  from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_u1, v_curso_id, 50, '{}'::bigint[], null) x(questao_id);

  select array_agg(x.questao_id) into v_unidade_u5
  from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_u5, v_curso_id, 50, '{}'::bigint[], null) x(questao_id);

  select array_agg(x.questao_id) into v_conteudo_res_a
  from public.selecionar_candidatas_conteudo(v_usuario_id, v_conteudo_a, v_curso_id, 50, '{}'::bigint[], null) x(questao_id);

  select array_agg(x.questao_id) into v_conteudo_res_b
  from public.selecionar_candidatas_conteudo(v_usuario_id, v_conteudo_b, v_curso_id, 50, '{}'::bigint[], null) x(questao_id);

  -- Caso 1: questao somente U1 -> pratica U1 sim, pratica U5 nao, Missao Final (conteudo A) sim.
  call teste_fix_missao_final_assert('questao so-U1 aparece na pratica de U1', v_q_u1 = any(v_unidade_u1));
  call teste_fix_missao_final_assert('questao so-U1 NAO aparece na pratica de U5', not (v_q_u1 = any(v_unidade_u5)));
  call teste_fix_missao_final_assert('questao so-U1 aparece na Missao Final (conteudo A)', v_q_u1 = any(v_conteudo_res_a));

  -- Caso 2: questao somente U5 -> pratica U5 sim, pratica U1 nao, Missao Final sim.
  call teste_fix_missao_final_assert('questao so-U5 aparece na pratica de U5', v_q_u5 = any(v_unidade_u5));
  call teste_fix_missao_final_assert('questao so-U5 NAO aparece na pratica de U1', not (v_q_u5 = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('questao so-U5 aparece na Missao Final (conteudo A)', v_q_u5 = any(v_conteudo_res_a));

  -- Caso 3: questao multiunidade U1+U5 -> aparece nas duas praticas e na Missao Final.
  call teste_fix_missao_final_assert('questao multiunidade aparece na pratica de U1', v_q_multi = any(v_unidade_u1));
  call teste_fix_missao_final_assert('questao multiunidade aparece na pratica de U5', v_q_multi = any(v_unidade_u5));
  call teste_fix_missao_final_assert('questao multiunidade aparece na Missao Final (conteudo A)', v_q_multi = any(v_conteudo_res_a));

  -- Caso 4: questao sem unidade, valida para o conteudo -> NAO pratica de unidade, SIM Missao Final.
  call teste_fix_missao_final_assert('banco geral 1 NAO aparece na pratica de U1', not (v_q_geral_1 = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('banco geral 1 NAO aparece na pratica de U5', not (v_q_geral_1 = any(v_unidade_u5)));
  call teste_fix_missao_final_assert('banco geral 1 aparece na Missao Final (conteudo A) -- o bug corrigido', v_q_geral_1 = any(v_conteudo_res_a));
  call teste_fix_missao_final_assert('banco geral 2 NAO aparece na pratica de U1', not (v_q_geral_2 = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('banco geral 2 NAO aparece na pratica de U5', not (v_q_geral_2 = any(v_unidade_u5)));
  call teste_fix_missao_final_assert('banco geral 2 aparece na Missao Final (conteudo A) -- o bug corrigido', v_q_geral_2 = any(v_conteudo_res_a));

  -- Caso 5: questao de outro conteudo -> nunca entra no conteudo A, em nenhuma forma (vinculada ou banco geral); isolamento simetrico no conteudo B.
  call teste_fix_missao_final_assert('questao vinculada ao OUTRO conteudo NAO aparece na pratica de U1', not (v_q_outro_vinculada = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('questao vinculada ao OUTRO conteudo NAO aparece na pratica de U5', not (v_q_outro_vinculada = any(v_unidade_u5)));
  call teste_fix_missao_final_assert('questao vinculada ao OUTRO conteudo NAO aparece na Missao Final do conteudo A', not (v_q_outro_vinculada = any(v_conteudo_res_a)));
  call teste_fix_missao_final_assert('questao banco geral do OUTRO conteudo NAO aparece na Missao Final do conteudo A', not (v_q_outro_geral = any(v_conteudo_res_a)));
  call teste_fix_missao_final_assert('questao vinculada ao OUTRO conteudo aparece na Missao Final do PROPRIO conteudo B (isolamento simetrico)', v_q_outro_vinculada = any(v_conteudo_res_b));
  call teste_fix_missao_final_assert('questao banco geral do OUTRO conteudo aparece na Missao Final do PROPRIO conteudo B (isolamento simetrico)', v_q_outro_geral = any(v_conteudo_res_b));
  call teste_fix_missao_final_assert('nenhuma fixture do conteudo A vaza para a Missao Final do conteudo B', not (v_q_u1 = any(v_conteudo_res_b) or v_q_u5 = any(v_conteudo_res_b) or v_q_multi = any(v_conteudo_res_b) or v_q_geral_1 = any(v_conteudo_res_b) or v_q_geral_2 = any(v_conteudo_res_b)));

  -- Caso 6: questao inativa -> nunca entra em nada, vinculada ou banco geral.
  call teste_fix_missao_final_assert('questao banco geral INATIVA NAO aparece na pratica de U1', not (v_q_geral_inativa = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('questao banco geral INATIVA NAO aparece na pratica de U5', not (v_q_geral_inativa = any(v_unidade_u5)));
  call teste_fix_missao_final_assert('questao banco geral INATIVA NAO aparece na Missao Final (conteudo A)', not (v_q_geral_inativa = any(v_conteudo_res_a)));
  call teste_fix_missao_final_assert('questao U1 INATIVA NAO aparece na pratica de U1', not (v_q_u1_inativa = any(v_unidade_u1)));
  call teste_fix_missao_final_assert('questao U1 INATIVA NAO aparece na Missao Final (conteudo A)', not (v_q_u1_inativa = any(v_conteudo_res_a)));
end $$;

-- ============================================================================
-- BLOCO 4 — resumo e confirmação de zero persistência
-- ============================================================================

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_fix_missao_final_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: tudo (patch de selecionar_candidatas_conteudo, fixtures,
-- tabelas de contexto/contador) criado só dentro desta transação.
ROLLBACK;
