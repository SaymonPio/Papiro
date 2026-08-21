-- Aplicacao REAL do saneamento de metadados de artigos_esperados das
-- unidades pedagogicas de Constituicao Federal de 1988 (curso_conteudos.id
-- = 57) e Constituicao do Estado do Rio Grande do Sul (curso_conteudos.id =
-- 50), validado pelo harness
-- sanear_artigos_esperados_cf88_ce_rs_teste_rollback.sql (tudo_ok = true
-- confirmado antes de rodar este arquivo).
--
-- Altera SOMENTE a coluna artigos_esperados dessas 2 unidades ja
-- existentes. Nao cria unidade nova, nao altera titulo, escopo, ordem,
-- ativa, questoes, alternativas, vinculos (questao_unidades_pedagogicas),
-- gabaritos ou qualquer outra tabela — nenhuma dessas e tocada por este
-- arquivo (nem sequer lida em modo de escrita).
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar.
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

-- Lock deterministico das 2 linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where id in ('682804b0-2762-4aff-87f9-d7a5a81757c2', '83636594-c69f-4de0-bf46-0e75c2ec981c')
order by id
for update;

-- Revalidacao de precondicoes — aborta a transacao em qualquer divergencia.
do $$
declare
  v_cf record;
  v_rs record;
begin
  select id, curso_conteudo_id, ordem, titulo, escopo, ativa, artigos_esperados
  into v_cf
  from public.unidades_pedagogicas
  where id = '682804b0-2762-4aff-87f9-d7a5a81757c2';

  if v_cf.id is null or v_cf.curso_conteudo_id <> 57 or v_cf.ordem <> 1 or not v_cf.ativa then
    raise exception 'Precondicao falhou: unidade CF nao confere (id/curso_conteudo_id/ordem/ativa)';
  end if;
  if v_cf.titulo <> 'Constituição Federal de 1988' then
    raise exception 'Precondicao falhou: titulo da unidade CF divergiu antes da aplicacao: %', v_cf.titulo;
  end if;
  if v_cf.escopo <> 'Constituição Federal de 1988: princípios fundamentais da República (Título I — fundamentos do Estado Democrático de Direito, separação e harmonia entre os Poderes); organização do Estado (poder constituinte decorrente, competências privativas da União); nacionalidade (art. 12 — brasileiro nato e naturalizado); e administração pública (arts. 37 e 38 — princípios expressos, regras de investidura e servidores públicos, incluindo o exercício de mandato eletivo).' then
    raise exception 'Precondicao falhou: escopo da unidade CF divergiu antes da aplicacao';
  end if;
  if v_cf.artigos_esperados <> array['art. 1º','art. 2º','art. 12','art. 22','art. 37','art. 38'] then
    raise exception 'Precondicao falhou: artigos_esperados atual da unidade CF diverge do esperado antes do saneamento: %', v_cf.artigos_esperados;
  end if;

  select id, curso_conteudo_id, ordem, titulo, escopo, ativa, artigos_esperados
  into v_rs
  from public.unidades_pedagogicas
  where id = '83636594-c69f-4de0-bf46-0e75c2ec981c';

  if v_rs.id is null or v_rs.curso_conteudo_id <> 50 or v_rs.ordem <> 1 or not v_rs.ativa then
    raise exception 'Precondicao falhou: unidade RS nao confere (id/curso_conteudo_id/ordem/ativa)';
  end if;
  if v_rs.titulo <> 'Constituição do Estado do Rio Grande do Sul' then
    raise exception 'Precondicao falhou: titulo da unidade RS divergiu antes da aplicacao: %', v_rs.titulo;
  end if;
  if v_rs.escopo <> 'Constituição do Estado do Rio Grande do Sul: princípios fundamentais e disposições preliminares (soberania popular, símbolos e bens do Estado, hierarquia com a Constituição Federal); administração pública (princípios expressos, Conselhos Populares, publicidade e transparência, administração direta e indireta); direitos dos servidores públicos civis; segurança pública (Brigada Militar, Polícia Civil, Corpo de Bombeiros Militar, Coordenadoria-Geral de Perícias, Polícia Penal); e regime previdenciário do servidor militar (RPPS/RS).' then
    raise exception 'Precondicao falhou: escopo da unidade RS divergiu antes da aplicacao';
  end if;
  if v_rs.artigos_esperados <> array['art. 1º','art. 2º','art. 4º','art. 6º','art. 7º','art. 19','art. 21','art. 23','art. 29','art. 41','art. 46','art. 124','art. 125','art. 127','art. 128','art. 132','art. 133','art. 134'] then
    raise exception 'Precondicao falhou: artigos_esperados atual da unidade RS diverge do esperado antes do saneamento: %', v_rs.artigos_esperados;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id in (57, 50)) <> 2 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade por conteudo (57 e 50)';
  end if;
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

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia — so
-- chega ao COMMIT final se passar tudo.
do $$
declare
  v_cf record;
  v_rs record;
begin
  select titulo, escopo, ordem, ativa, curso_conteudo_id, artigos_esperados
  into v_cf
  from public.unidades_pedagogicas
  where id = '682804b0-2762-4aff-87f9-d7a5a81757c2';

  if v_cf.titulo <> 'Constituição Federal de 1988' or v_cf.ordem <> 1 or not v_cf.ativa or v_cf.curso_conteudo_id <> 57 then
    raise exception 'Pos-condicao falhou: titulo/ordem/ativa/curso_conteudo_id da unidade CF mudou indevidamente';
  end if;
  if array_length(v_cf.artigos_esperados, 1) <> 27 then
    raise exception 'Pos-condicao falhou: artigos_esperados CF tem % itens (esperado 27)', array_length(v_cf.artigos_esperados, 1);
  end if;
  if not ('art. 37, §13' = any(v_cf.artigos_esperados)) then
    raise exception 'Pos-condicao falhou: artigos_esperados CF nao contem "art. 37, §13"';
  end if;

  select titulo, escopo, ordem, ativa, curso_conteudo_id, artigos_esperados
  into v_rs
  from public.unidades_pedagogicas
  where id = '83636594-c69f-4de0-bf46-0e75c2ec981c';

  if v_rs.titulo <> 'Constituição do Estado do Rio Grande do Sul' or v_rs.ordem <> 1 or not v_rs.ativa or v_rs.curso_conteudo_id <> 50 then
    raise exception 'Pos-condicao falhou: titulo/ordem/ativa/curso_conteudo_id da unidade RS mudou indevidamente';
  end if;
  if array_length(v_rs.artigos_esperados, 1) <> 37 then
    raise exception 'Pos-condicao falhou: artigos_esperados RS tem % itens (esperado 37)', array_length(v_rs.artigos_esperados, 1);
  end if;
  if not ('art. 124, III' = any(v_rs.artigos_esperados)) then
    raise exception 'Pos-condicao falhou: artigos_esperados RS nao contem "art. 124, III"';
  end if;

  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou';
  end if;
  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: total de vinculos questao-unidade mudou (nao era o alvo deste saneamento)';
  end if;
  if (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
        where u.curso_conteudo_id = 57) <> (select classificadas_57 from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: questoes classificadas no conteudo 57 mudaram';
  end if;
  if (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
        where u.curso_conteudo_id = 50) <> (select classificadas_50 from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: questoes classificadas no conteudo 50 mudaram';
  end if;

  raise notice 'Pos-condicoes OK: artigos_esperados CF=27 / RS=37, nenhuma outra tabela ou vinculo alterado.';
end $$;

commit;
