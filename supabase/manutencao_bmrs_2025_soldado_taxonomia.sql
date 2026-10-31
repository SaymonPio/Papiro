-- BM-RS 2025 Soldado de Primeira Classe (Fundatec, concurso 976) — TAXONOMIA (somente dados globais, nenhum curso).
-- Nenhuma matéria nova. Cria 1 assunto GLOBAL em matéria existente:
-- "Matemática" (12): Equações do 1º grau (Q33 — triplo de um número menos 18 = número + 48).
-- Busca de equivalentes (nome e termos, normalizados sem acento, caixa e pontuação, em nome + descrição de TODOS os
-- assuntos, globais e de usuário): equação(ões), 1º grau, primeiro grau, incógnita(s), linear(es). Qualquer equivalente aborta.
-- Auditado à parte (somente leitura): o único assunto com álgebra/polinômios é o 294 "Polinômios e expressões algébricas"
-- (1 questão: valor numérico de P(x)); não serve — resolver equação do 1º grau não é cálculo com polinômios. Por isso esses termos não abortam.
-- Nenhum curso_materia, curso_conteudo, curso_questao, questão ou classificação de questão é alterado (assinatura antes/depois).
--
-- ROLLBACK-TESTADO em manutencao_bmrs_2025_soldado_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_bmrs_2025_soldado_taxonomia.sql

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _976bm_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _976bm_tax values
('Matemática', 'Equações do 1º grau', array['equacao', 'equacoes', '1 grau', '1o grau', 'primeiro grau', 'incognita', 'incognitas', 'linear', 'lineares']);

create temporary table _976bm_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.alternativas) alternativas, (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q) md5_questoes,
       (select md5(string_agg(to_jsonb(m)::text, '|' order by m.id)) from public.materias m) md5_materias,
       (select md5(string_agg(to_jsonb(s)::text, '|' order by s.id)) from public.assuntos s) md5_assuntos;

do $$
declare
  v_destino int; v_equiv int; r record;
begin
  select count(*) into v_destino from public.materias m where m.usuario_id is null and m.ativo and m.nome = 'Matemática';
  if v_destino <> 1 then raise exception 'AUDITORIA: esperada 1 matéria global ativa "Matemática", encontradas %', v_destino; end if;
  if (select id from public.materias where usuario_id is null and ativo and nome = 'Matemática') <> 12 then raise exception 'AUDITORIA: matéria de destino fora do id aprovado (12)'; end if;
  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _976bm_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %')) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _976bm_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %') loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) — reauditar antes de criar', v_equiv;
  end if;
  raise notice 'AUDITORIA OK: matéria de destino única (12); assunto ausente; nenhum equivalente';
end $$;

do $$
declare
  v_a int; v_id bigint;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _976bm_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo
  returning id into v_id;
  get diagnostics v_a = row_count;
  if v_a <> 1 then raise exception 'INSERT: % assunto(s), esperado 1', v_a; end if;
  raise notice 'INSERT aplicado: 1 assunto global, id %', v_id;
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _976bm_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 1 then raise exception 'POSCOND: assunto ausente ou duplicado na matéria correta (%)', v_ok; end if;

  select * into a from _976bm_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.alternativas) alternativas, (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q) md5_questoes,
       (select md5(string_agg(to_jsonb(m)::text, '|' order by m.id)) from public.materias m) md5_materias,
       (select md5(string_agg(to_jsonb(s)::text, '|' order by s.id)) from public.assuntos s
         where not (s.usuario_id is null and s.materia_id = 12 and s.nome = 'Equações do 1º grau')) md5_assuntos_sem_novo
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 1 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+1)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.alternativas, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_questoes, a.md5_materias)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.alternativas, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_questoes, d.md5_materias) then
    raise exception 'POSCOND: matérias, estrutura de curso, questões, alternativas, unidades ou classificação alterada';
  end if;
  if a.md5_assuntos is distinct from d.md5_assuntos_sem_novo then raise exception 'POSCOND: algum assunto pré-existente foi alterado'; end if;

  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _976bm_tax t on t.nome = s.nome and t.materia = m.nome
           where s.usuario_id is null order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: +1 assunto global na matéria 12; nenhuma matéria, curso_materia, curso_conteudo, vínculo, questão, alternativa, unidade ou classificação alterado';
end $$;

commit;
