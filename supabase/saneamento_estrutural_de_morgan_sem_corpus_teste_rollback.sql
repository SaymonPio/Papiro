-- SANEAMENTO ESTRUTURAL DEDICADO — Leis de De Morgan sem corpus proprio
-- (curso_conteudo_id=4, assunto_id=34) — operacao independente, separada
-- do saneamento taxonomico ja concluido das Q77/Q88/Q311 (commit
-- 9f7d3a8) e do fechamento documental da ordem 86 (a ser feito depois,
-- em operacao separada).
--
-- Diagnostico: SEM_CORPUS_PROPRIO_POR_SOBREPOSICAO_CURRICULAR
-- (microauditoria estrutural da ordem 86). O corpus historico (Q77,
-- Q88, Q311) foi reclassificado para Negacao de proposicoes por
-- exercitar exatamente a mesma habilidade ja consolidada la — nao por
-- falta de banco. Assunto 34 fica com 0 candidatas LIVE.
--
-- Achado central da auditoria de codigo (RPCs live via
-- pg_get_functiondef + leitura de app/cronograma/page.tsx,
-- app/teoria/page.tsx, app/admin/aulas/page.tsx e
-- supabase/functions/gerar-aula/index.ts): quem controla a oferta deste
-- conteudo ao aluno no cronograma/missao diaria e
-- curso_conteudos.relevante_para_preparacao (nao
-- unidades_pedagogicas.ativa). As duas protecoes sao complementares e
-- ja existem prontas no codigo:
--   - curso_conteudos.relevante_para_preparacao=false: bloqueia
--     app/cronograma/page.tsx (query direta com .eq(...,true)) e a RPC
--     iniciar_ou_recuperar_missao_diaria (raise exception explicito) —
--     fecha a oferta ao ALUNO.
--   - unidades_pedagogicas.ativa=false: bloqueia o dropdown de unidade
--     em app/admin/aulas/page.tsx (disabled={!u.ativa}) e a Edge
--     Function gerar-aula (checagem server-side explicita) — fecha a
--     geracao/selecao no ADMIN/UNIDADE.
-- Semantica documentada na propria decisao arquitetural do projeto
-- (supabase/base_programatica_curso.sql): relevante_para_preparacao e
-- "decisao estrategica de admin (vale estudar isso agora)", nao um
-- estado permanente — precedente real ja em uso em curso_materias
-- (Matematica id=21, Conhecimentos Gerais id=20).
--
-- Escopo: SOMENTE 2 campos, 1 linha cada. NAO altera taxonomia
-- (curso_conteudo_id, assunto_id, nome, prioridade_estrategica,
-- frequencia_historica, curso_id, materia_id) nem a unidade alem de
-- ativa (id, curso_conteudo_id, ordem, titulo, escopo,
-- artigos_esperados permanecem intactos). NAO toca questoes nem
-- vinculos — Negacao de proposicoes deve permanecer com exatamente 7
-- vinculos (Q77, Q81, Q86, Q88, Q311, Q312, Q337).
--
-- Harness de teste (SEMPRE termina em ROLLBACK) — nada aqui persiste no
-- banco. Ver saneamento_estrutural_de_morgan_sem_corpus.sql para a
-- aplicacao real (termina em COMMIT).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_assunto_id bigint;
  v_curso_materia_id bigint;
  v_relevante boolean;
  v_prioridade int;
  v_frequencia numeric;
  v_unidade_conteudo bigint;
  v_unidade_ordem int;
  v_unidade_titulo text;
  v_unidade_escopo text;
  v_unidade_artigos text[];
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
  v_candidatas_34 int;
  v_vinculos_negacao int;
  v_qids_negacao bigint[];
begin
  select assunto_id, curso_materia_id, relevante_para_preparacao, prioridade_estrategica, frequencia_historica
    into v_assunto_id, v_curso_materia_id, v_relevante, v_prioridade, v_frequencia
    from public.curso_conteudos where id = 4;

  if v_assunto_id is distinct from 34 or v_curso_materia_id is distinct from 24 then
    raise exception 'Precondicao falhou: curso_conteudo 4 diverge do esperado (assunto_id=%, curso_materia_id=%)', v_assunto_id, v_curso_materia_id;
  end if;
  if v_relevante is distinct from true then
    raise exception 'Precondicao falhou: curso_conteudo 4 ja esta com relevante_para_preparacao=% (esperado true)', v_relevante;
  end if;
  if v_prioridade is distinct from 5 then
    raise exception 'Precondicao falhou: prioridade_estrategica do conteudo 4 diverge do esperado (5) — atual: %', v_prioridade;
  end if;
  if v_frequencia is not null then
    raise exception 'Precondicao falhou: frequencia_historica do conteudo 4 diverge do esperado (NULL) — atual: %', v_frequencia;
  end if;

  select curso_conteudo_id, ordem, titulo, escopo, artigos_esperados, ativa
    into v_unidade_conteudo, v_unidade_ordem, v_unidade_titulo, v_unidade_escopo, v_unidade_artigos, v_unidade_ativa
    from public.unidades_pedagogicas where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

  if v_unidade_conteudo is distinct from 4 or v_unidade_ordem is distinct from 1
     or v_unidade_titulo is distinct from 'Leis de De Morgan' or v_unidade_escopo is distinct from 'Leis de De Morgan' then
    raise exception 'Precondicao falhou: unidade de De Morgan diverge do esperado (conteudo=%, ordem=%, titulo=%, escopo=%)', v_unidade_conteudo, v_unidade_ordem, v_unidade_titulo, v_unidade_escopo;
  end if;
  if v_unidade_artigos is not null then
    raise exception 'Precondicao falhou: artigos_esperados da unidade de De Morgan diverge do esperado (NULL)';
  end if;
  if v_unidade_ativa is distinct from true then
    raise exception 'Precondicao falhou: unidade de De Morgan ja esta com ativa=% (esperado true)', v_unidade_ativa;
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  if v_vinculos_unidade <> 0 then
    raise exception 'Precondicao falhou: unidade de De Morgan ja possui vinculo (esperado 0) — atual: %', v_vinculos_unidade;
  end if;

  select count(*) into v_candidatas_34 from public.questoes where ativa = true and assunto_id = 34;
  if v_candidatas_34 <> 0 then
    raise exception 'Precondicao falhou: assunto 34 possui candidatas ativas (esperado 0) — atual: %', v_candidatas_34;
  end if;

  select count(*) into v_vinculos_negacao from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_negacao <> 7 then
    raise exception 'Precondicao falhou: unidade de Negacao nao possui 7 vinculos antes do saneamento — atual: %', v_vinculos_negacao;
  end if;
  select array_agg(questao_id order by questao_id) into v_qids_negacao
    from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_qids_negacao is distinct from array[77,81,86,88,311,312,337]::bigint[] then
    raise exception 'Precondicao falhou: QIDs de Negacao antes do saneamento divergem do esperado — atual: %', v_qids_negacao;
  end if;
end $$;

update public.curso_conteudos
   set relevante_para_preparacao = false,
       atualizado_em = now()
 where id = 4;

update public.unidades_pedagogicas
   set ativa = false,
       atualizado_em = now()
 where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

do $$
declare
  v_assunto_id bigint;
  v_curso_materia_id bigint;
  v_relevante boolean;
  v_prioridade int;
  v_frequencia numeric;
  v_unidade_conteudo bigint;
  v_unidade_ordem int;
  v_unidade_titulo text;
  v_unidade_escopo text;
  v_unidade_artigos text[];
  v_unidade_ativa boolean;
  v_vinculos_unidade int;
  v_candidatas_34 int;
  v_vinculos_negacao int;
  v_qids_negacao bigint[];
  v_passa_filtro_cronograma boolean;
begin
  select assunto_id, curso_materia_id, relevante_para_preparacao, prioridade_estrategica, frequencia_historica
    into v_assunto_id, v_curso_materia_id, v_relevante, v_prioridade, v_frequencia
    from public.curso_conteudos where id = 4;

  if v_relevante is distinct from false then
    raise exception 'Pos-condicao falhou: relevante_para_preparacao do conteudo 4 nao foi atualizado para false — atual: %', v_relevante;
  end if;
  if v_assunto_id is distinct from 34 or v_curso_materia_id is distinct from 24 or v_prioridade is distinct from 5 or v_frequencia is not null then
    raise exception 'Pos-condicao falhou: taxonomia do conteudo 4 foi alterada indevidamente (assunto=%, curso_materia=%, prioridade=%, frequencia=%)', v_assunto_id, v_curso_materia_id, v_prioridade, v_frequencia;
  end if;

  select curso_conteudo_id, ordem, titulo, escopo, artigos_esperados, ativa
    into v_unidade_conteudo, v_unidade_ordem, v_unidade_titulo, v_unidade_escopo, v_unidade_artigos, v_unidade_ativa
    from public.unidades_pedagogicas where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

  if v_unidade_ativa is distinct from false then
    raise exception 'Pos-condicao falhou: ativa da unidade de De Morgan nao foi atualizado para false — atual: %', v_unidade_ativa;
  end if;
  if v_unidade_conteudo is distinct from 4 or v_unidade_ordem is distinct from 1
     or v_unidade_titulo is distinct from 'Leis de De Morgan' or v_unidade_escopo is distinct from 'Leis de De Morgan'
     or v_unidade_artigos is not null then
    raise exception 'Pos-condicao falhou: campos da unidade de De Morgan alem de ativa foram alterados indevidamente';
  end if;

  select count(*) into v_vinculos_unidade from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076';
  if v_vinculos_unidade <> 0 then
    raise exception 'Pos-condicao falhou: unidade de De Morgan ganhou vinculo (esperado 0) — atual: %', v_vinculos_unidade;
  end if;

  select count(*) into v_candidatas_34 from public.questoes where ativa = true and assunto_id = 34;
  if v_candidatas_34 <> 0 then
    raise exception 'Pos-condicao falhou: assunto 34 passou a ter candidatas ativas (esperado 0) — atual: %', v_candidatas_34;
  end if;

  select count(*) into v_vinculos_negacao from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  select array_agg(questao_id order by questao_id) into v_qids_negacao
    from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_vinculos_negacao <> 7 or v_qids_negacao is distinct from array[77,81,86,88,311,312,337]::bigint[] then
    raise exception 'Pos-condicao falhou: unidade de Negacao foi alterada indevidamente (vinculos=%, qids=%)', v_vinculos_negacao, v_qids_negacao;
  end if;

  -- Checagem semantica: simula exatamente o filtro usado pelo
  -- cronograma (app/cronograma/page.tsx) e por
  -- iniciar_ou_recuperar_missao_diaria — confirma que o conteudo 4 NAO
  -- passaria mais nesse filtro, sem criar nenhuma missao real.
  select exists (
    select 1 from public.curso_conteudos where id = 4 and relevante_para_preparacao = true
  ) into v_passa_filtro_cronograma;
  if v_passa_filtro_cronograma then
    raise exception 'Pos-condicao falhou: conteudo 4 ainda passaria no filtro relevante_para_preparacao=true do cronograma';
  end if;

  raise notice 'tudo_ok = true — curso_conteudo 4 (Leis de De Morgan) com relevante_para_preparacao=false, unidade 5ad41c42-25b4-4853-b328-b562a9fc8076 com ativa=false, 0 vinculos, taxonomia/titulo/escopo/artigos_esperados inalterados, assunto 34 com 0 candidatas, Negacao de proposicoes com 7 vinculos intactos, conteudo 4 nao passa mais no filtro do cronograma.';
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
