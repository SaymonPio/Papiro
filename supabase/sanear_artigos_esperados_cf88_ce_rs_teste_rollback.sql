-- Harness de teste (SEMPRE termina em ROLLBACK) do saneamento de metadados
-- de artigos_esperados das unidades pedagogicas de:
--   - Constituicao Federal de 1988 (curso_conteudos.id = 57)
--   - Constituicao do Estado do Rio Grande do Sul (curso_conteudos.id = 50)
--
-- Este saneamento altera SOMENTE a coluna artigos_esperados dessas 2
-- unidades ja existentes. Nao cria unidade nova, nao altera titulo,
-- escopo, ordem, ativa, questoes, alternativas, vinculos
-- (questao_unidades_pedagogicas) ou qualquer outra tabela. Gerado a partir
-- de config/constituicao_federal_de_1988.unidades.json e
-- config/constituicao_do_estado_do_rio_grande_do_sul.unidades.json (campo
-- artigos_esperados), apos revisao juridica de granularidade (artigo /
-- caput / inciso / paragrafo / alinea) documentada em
-- docs/REGRAS_CURADORIA_PAPIRO.md secao 4, item 6.
--
-- Termina SEMPRE em ROLLBACK — nada aqui persiste no banco.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 57)                          as classificadas_57,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 50)                          as classificadas_50;

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock deterministico das 2 linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where id in ('682804b0-2762-4aff-87f9-d7a5a81757c2', '83636594-c69f-4de0-bf46-0e75c2ec981c')
  order by id
  for update;
end $$;

-- Precondicoes: as 2 unidades existem, com titulo/escopo/ordem/ativa e
-- artigos_esperados ATUAIS (antes do saneamento) exatamente como esperado
-- — evita aplicar sobre um estado que ja mudou por outro caminho.
do $$
declare
  v_cf record;
  v_rs record;
begin
  select id, curso_conteudo_id, ordem, titulo, escopo, ativa, artigos_esperados
  into v_cf
  from public.unidades_pedagogicas
  where id = '682804b0-2762-4aff-87f9-d7a5a81757c2';

  insert into _relatorio values (
    'cf_unidade_existe_e_conteudo_57',
    v_cf.id is not null and v_cf.curso_conteudo_id = 57 and v_cf.ordem = 1 and v_cf.ativa,
    format('curso_conteudo_id=%s ordem=%s ativa=%s', v_cf.curso_conteudo_id, v_cf.ordem, v_cf.ativa)
  );
  insert into _relatorio values (
    'cf_titulo_inalterado_antes',
    v_cf.titulo = 'Constituição Federal de 1988',
    coalesce(v_cf.titulo, '(nulo)')
  );
  insert into _relatorio values (
    'cf_escopo_inalterado_antes',
    v_cf.escopo = 'Constituição Federal de 1988: princípios fundamentais da República (Título I — fundamentos do Estado Democrático de Direito, separação e harmonia entre os Poderes); organização do Estado (poder constituinte decorrente, competências privativas da União); nacionalidade (art. 12 — brasileiro nato e naturalizado); e administração pública (arts. 37 e 38 — princípios expressos, regras de investidura e servidores públicos, incluindo o exercício de mandato eletivo).',
    'confere escopo atual antes do saneamento'
  );
  insert into _relatorio values (
    'cf_artigos_esperados_antigo_confere',
    v_cf.artigos_esperados = array['art. 1º','art. 2º','art. 12','art. 22','art. 37','art. 38'],
    format('artigos_esperados atual (antes) = %s', v_cf.artigos_esperados)
  );

  select id, curso_conteudo_id, ordem, titulo, escopo, ativa, artigos_esperados
  into v_rs
  from public.unidades_pedagogicas
  where id = '83636594-c69f-4de0-bf46-0e75c2ec981c';

  insert into _relatorio values (
    'rs_unidade_existe_e_conteudo_50',
    v_rs.id is not null and v_rs.curso_conteudo_id = 50 and v_rs.ordem = 1 and v_rs.ativa,
    format('curso_conteudo_id=%s ordem=%s ativa=%s', v_rs.curso_conteudo_id, v_rs.ordem, v_rs.ativa)
  );
  insert into _relatorio values (
    'rs_titulo_inalterado_antes',
    v_rs.titulo = 'Constituição do Estado do Rio Grande do Sul',
    coalesce(v_rs.titulo, '(nulo)')
  );
  insert into _relatorio values (
    'rs_escopo_inalterado_antes',
    v_rs.escopo = 'Constituição do Estado do Rio Grande do Sul: princípios fundamentais e disposições preliminares (soberania popular, símbolos e bens do Estado, hierarquia com a Constituição Federal); administração pública (princípios expressos, Conselhos Populares, publicidade e transparência, administração direta e indireta); direitos dos servidores públicos civis; segurança pública (Brigada Militar, Polícia Civil, Corpo de Bombeiros Militar, Coordenadoria-Geral de Perícias, Polícia Penal); e regime previdenciário do servidor militar (RPPS/RS).',
    'confere escopo atual antes do saneamento'
  );
  insert into _relatorio values (
    'rs_artigos_esperados_antigo_confere',
    v_rs.artigos_esperados = array['art. 1º','art. 2º','art. 4º','art. 6º','art. 7º','art. 19','art. 21','art. 23','art. 29','art. 41','art. 46','art. 124','art. 125','art. 127','art. 128','art. 132','art. 133','art. 134'],
    format('artigos_esperados atual (antes) = %s', v_rs.artigos_esperados)
  );

  insert into _relatorio values (
    'apenas_2_unidades_ativas_nos_conteudos_alvo',
    (select count(*) from public.unidades_pedagogicas where curso_conteudo_id in (57, 50)) = 2,
    'esperado: exatamente 1 unidade por conteudo (57 e 50), nenhuma criada/removida'
  );
end $$;

-- Aplicacao: UPDATE restrito a artigos_esperados, nada mais.
update public.unidades_pedagogicas
set artigos_esperados = array[
  'art. 1º, caput','art. 1º, I','art. 1º, II','art. 1º, III','art. 1º, V',
  'art. 2º, caput','art. 4º, VI',
  'art. 12, I, a','art. 12, I, b','art. 12, I, c','art. 12, II, a','art. 12, II, b',
  'art. 22, XI','art. 25, caput',
  'art. 37, caput','art. 37, I','art. 37, II','art. 37, V','art. 37, §1º',
  'art. 37, §8º','art. 37, §11','art. 37, §13','art. 37, §16','art. 37, XII',
  'art. 38, IV','art. 39, §9º','art. 40, §1º, II'
]
where id = '682804b0-2762-4aff-87f9-d7a5a81757c2';

update public.unidades_pedagogicas
set artigos_esperados = array[
  'art. 1º',
  'art. 2º, caput','art. 2º, I','art. 2º, II','art. 2º, III',
  'art. 4º, caput',
  'art. 6º, caput','art. 6º, §1º',
  'art. 7º, IX',
  'art. 19, caput','art. 19, §1º','art. 19, §2º','art. 19, §3º',
  'art. 21, caput','art. 23, caput',
  'art. 29, VI','art. 29, X',
  'art. 41, caput',
  'art. 46, caput','art. 46, §2º','art. 46, §4º',
  'art. 48, caput',
  'art. 124, caput','art. 124, I','art. 124, II','art. 124, III','art. 124, IV','art. 124, V',
  'art. 125, caput','art. 125, parágrafo único',
  'art. 127, caput','art. 127, parágrafo único',
  'art. 128, I',
  'art. 132, caput',
  'art. 133, caput','art. 133, parágrafo único',
  'art. 134, parágrafo único'
]
where id = '83636594-c69f-4de0-bf46-0e75c2ec981c';

-- Pos-condicoes.
do $$
declare
  v_cf record;
  v_rs record;
begin
  select titulo, escopo, ordem, ativa, curso_conteudo_id, artigos_esperados
  into v_cf
  from public.unidades_pedagogicas
  where id = '682804b0-2762-4aff-87f9-d7a5a81757c2';

  insert into _relatorio values (
    'cf_titulo_escopo_ordem_ativa_inalterados_depois',
    v_cf.titulo = 'Constituição Federal de 1988'
      and v_cf.ordem = 1 and v_cf.ativa and v_cf.curso_conteudo_id = 57,
    'titulo/ordem/ativa/curso_conteudo_id nao devem mudar'
  );
  insert into _relatorio values (
    'cf_artigos_esperados_27',
    array_length(v_cf.artigos_esperados, 1) = 27,
    format('quantidade=%s (esperado 27)', array_length(v_cf.artigos_esperados, 1))
  );
  insert into _relatorio values (
    'cf_artigos_esperados_contem_37_13',
    'art. 37, §13' = any(v_cf.artigos_esperados),
    'amostra de verificacao pontual'
  );

  select titulo, escopo, ordem, ativa, curso_conteudo_id, artigos_esperados
  into v_rs
  from public.unidades_pedagogicas
  where id = '83636594-c69f-4de0-bf46-0e75c2ec981c';

  insert into _relatorio values (
    'rs_titulo_escopo_ordem_ativa_inalterados_depois',
    v_rs.titulo = 'Constituição do Estado do Rio Grande do Sul'
      and v_rs.ordem = 1 and v_rs.ativa and v_rs.curso_conteudo_id = 50,
    'titulo/ordem/ativa/curso_conteudo_id nao devem mudar'
  );
  insert into _relatorio values (
    'rs_artigos_esperados_37',
    array_length(v_rs.artigos_esperados, 1) = 37,
    format('quantidade=%s (esperado 37)', array_length(v_rs.artigos_esperados, 1))
  );
  insert into _relatorio values (
    'rs_artigos_esperados_contem_124_III',
    'art. 124, III' = any(v_rs.artigos_esperados),
    'amostra de verificacao pontual'
  );

  -- Nenhuma outra tabela / linha deve ter mudado.
  insert into _relatorio values ('unidades_pedagogicas_inalteradas_em_qtd',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes),
    'esperado: nenhuma unidade nova/removida');
  insert into _relatorio values ('questoes_inalteradas',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes), 'contagem de questoes nao deve mudar');
  insert into _relatorio values ('alternativas_inalteradas',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes), 'contagem de alternativas nao deve mudar');
  insert into _relatorio values ('conteudos_inalterados',
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), 'contagem de curso_conteudos nao deve mudar');
  insert into _relatorio values ('curso_questoes_inalterado',
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), 'curso_questoes nao deve sofrer alteracao');
  insert into _relatorio values ('respostas_inalteradas',
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), 'historico de respostas_usuarios nao deve mudar');
  insert into _relatorio values ('sessoes_inalteradas',
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), 'sessoes_estudo nao deve mudar');
  insert into _relatorio values ('vinculos_inalterados',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes), 'nenhum vinculo questao-unidade deve mudar (nao e o alvo deste saneamento)');
  insert into _relatorio values ('classificadas_57_inalteradas',
    (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
       join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
       where u.curso_conteudo_id = 57) = (select classificadas_57 from _snapshot_antes),
    'questoes classificadas no conteudo 57 nao devem mudar');
  insert into _relatorio values ('classificadas_50_inalteradas',
    (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
       join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
       where u.curso_conteudo_id = 50) = (select classificadas_50 from _snapshot_antes),
    'questoes classificadas no conteudo 50 nao devem mudar');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (sanear_artigos_esperados_cf88_ce_rs) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
