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
-- ROLLBACK-TESTADO em manutencao_uruguaiana_2023_gcm_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_uruguaiana_2023_gcm_taxonomia.sql

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
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from public.materias m where m.usuario_id is null and m.ativo and m.nome = 'Legislação Municipal';
  if v_destino <> 1 then raise exception 'AUDITORIA: esperada 1 matéria global ativa "Legislação Municipal", encontradas %', v_destino; end if;
  if (select id from public.materias where usuario_id is null and ativo and nome = 'Legislação Municipal') <> 22 then
    raise exception 'AUDITORIA: matéria de destino fora do id aprovado (22)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _744_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %')
     where a.id not in (select assunto_id from _744_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _744_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %')
     where a.id not in (select assunto_id from _744_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _744_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 11 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;
  raise notice 'AUDITORIA OK: matéria de destino 22 única; 4 assuntos ausentes; nenhum equivalente fora dos 11 homônimos aceitos';
end $$;

do $$
declare
  v_a int;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _744_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_a <> 4 then raise exception 'INSERT: % assunto(s), esperado 4', v_a; end if;
  raise notice 'INSERT aplicado: 4 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _744_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 4 then raise exception 'POSCOND: só % dos 4 assuntos na matéria correta', v_ok; end if;

  select * into a from _744_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 4 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+4)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso, questões, unidades ou classificação de questões alterada';
  end if;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _744_tax t on t.nome = s.nome and t.materia = m.nome
           where s.usuario_id is null order by 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 4 assuntos globais na matéria certa; nenhuma matéria, curso_materia, curso_conteudo, vínculo, questão, unidade ou classificação alterado';
end $$;

commit;
