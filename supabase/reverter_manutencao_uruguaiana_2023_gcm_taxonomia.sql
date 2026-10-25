-- Uruguaiana/RS 2023 Guarda Civil Municipal (Fundatec, concurso 744, cargo 6) — TAXONOMIA (somente dados globais, nenhum curso).
-- Nenhuma matéria nova. Cria 4 assuntos GLOBAIS na matéria existente "Legislação Municipal" (22), no padrão dos lotes
-- municipais anteriores (um assunto por lei local):
--   Lei Orgânica do Município de Uruguaiana;
--   Regime Jurídico dos Servidores Públicos de Uruguaiana (LC 18/2018);
--   Guarda Municipal de Uruguaiana (Lei 3.319/2004);
--   Estrutura administrativa do Executivo de Uruguaiana (Lei 5.200/2021).
-- Código de Posturas NÃO é criado: a única questão sobre ele foi anulada.
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, globais e de usuário). Homônimos aceitos por decisão explícita e conferidos onde
-- estão — tratam de OUTRO ente (outro município, o Estado, a União), não são equivalentes:
--   286, 335 (matéria 22) — Lei Orgânica de Sant'Ana do Livramento / de Araquari;
--   394 (matéria 16) — Lei Orgânica Nacional das Polícias Civis;
--   120, 290, 337, 362 (matéria 22) — estatutos/regimes jurídicos de Porto Alegre, Livramento, Araquari, Gravataí;
--   181, 402 (matéria 16) — estatutos dos servidores do RS e de MG;
--   288, 289 (matéria 22) — Guarda Civil Municipal e estrutura administrativa de Sant'Ana do Livramento.
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- REVERSÃO REAL de manutencao_uruguaiana_2023_gcm_taxonomia.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar os assuntos criados (reverter antes as questões classificadas neles).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _744_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _744_tax values
('Legislação Municipal', 'Lei Orgânica do Município de Uruguaiana', array['uruguaiana', 'lei organica']),
('Legislação Municipal', 'Regime Jurídico dos Servidores Públicos de Uruguaiana (LC 18/2018)', array['uruguaiana', 'regime juridico', 'estatuto dos servidores', 'estatuto dos funcionarios', 'lc 18 2018']),
('Legislação Municipal', 'Guarda Municipal de Uruguaiana (Lei 3.319/2004)', array['uruguaiana', 'guarda municipal de', 'guarda civil municipal de', 'lei 3 319', 'lei 5 473']),
('Legislação Municipal', 'Estrutura administrativa do Executivo de Uruguaiana (Lei 5.200/2021)', array['uruguaiana', 'estrutura administrativa', 'lei 5 200']);

create temporary table _744_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _744_homonimos values (286, 22), (335, 22), (394, 16), (120, 22), (290, 22), (337, 22), (362, 22), (181, 16), (402, 16), (288, 22), (289, 22);

create temporary table _744_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_refs int; v_a int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _744_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _744_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 4 then raise exception 'REVERSAO: apagou % assunto(s), esperado 4', v_a; end if;
  raise notice 'REVERSAO aplicada: 4 assuntos removidos';
end $$;

do $$
declare
  a record; d record;
begin
  select * into a from _744_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos - 4 then raise exception 'POSCOND REVERSAO: matérias %->%, assuntos %->%', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND REVERSAO: estrutura de curso, questões, unidades ou classificação de questões alterada';
  end if;
  raise notice 'POSCOND REVERSAO OK: contagens e assinaturas conferem';
end $$;

commit;
