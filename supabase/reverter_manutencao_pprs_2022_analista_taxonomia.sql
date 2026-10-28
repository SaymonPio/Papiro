-- PP-RS 2022 Analista da Polícia Penal — Direito (Fundatec, concurso 650, cargo 6) — TAXONOMIA (somente dados globais, nenhum curso).
-- Nenhuma matéria nova. Cria 1 assunto GLOBAL em matéria existente:
-- "Direito Civil" (33): Direito das coisas (posse e propriedade) (Q61 — desforço possessório).
-- Busca de equivalentes (nome e termos, normalizados sem acento, caixa e pontuação, em nome + descrição de TODOS os
-- assuntos, globais e de usuário): posse, possessório(a), possuidor, propriedade, direito(s) real(is), direito das coisas,
-- usucapião, esbulho, turbação, desforço, interdito(s), reintegração, servidão, usufruto, hipoteca. Qualquer equivalente aborta.
-- Os assuntos de Direito Civil existentes NÃO servem: 265 (parte geral), 266 (obrigações e responsabilidade civil), 302 (CDC) — posse é Livro III (Direito das Coisas).
-- Nenhum curso_materia, curso_conteudo, curso_questao, questão ou classificação de questão é alterado (assinatura antes/depois).
--
-- REVERSÃO REAL de manutencao_pprs_2022_analista_taxonomia.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar o assunto criado (reverter antes as questões classificadas nele).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _650an_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _650an_tax values
('Direito Civil', 'Direito das coisas (posse e propriedade)', array['posse', 'possessoria', 'possessorio', 'possessorias', 'possessorios', 'possuidor', 'propriedade', 'direitos reais', 'direito real', 'direito das coisas', 'usucapiao', 'esbulho', 'turbacao', 'desforco', 'interdito', 'interditos', 'reintegracao', 'servidao', 'usufruto', 'hipoteca']);

create temporary table _650an_antes on commit drop as
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
  v_refs int; v_a int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _650an_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) ao assunto criado — reverter as questões antes', v_refs; end if;
  delete from public.assuntos s using public.materias m, _650an_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 1 then raise exception 'REVERSAO: apagou % assunto(s), esperado 1', v_a; end if;
  raise notice 'REVERSAO aplicada: 1 assunto removido';
end $$;

do $$
declare
  v_destino int; v_equiv int; r record;
begin
  select count(*) into v_destino from public.materias m where m.usuario_id is null and m.ativo and m.nome = 'Direito Civil';
  if v_destino <> 1 then raise exception 'AUDITORIA-POS-REVERSAO: esperada 1 matéria global ativa "Direito Civil", encontradas %', v_destino; end if;
  if (select id from public.materias where usuario_id is null and ativo and nome = 'Direito Civil') <> 33 then raise exception 'AUDITORIA-POS-REVERSAO: matéria de destino fora do id aprovado (33)'; end if;
  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _650an_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %')) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _650an_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '% ' || k || ' %') loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA-POS-REVERSAO: % assunto(s) equivalente(s) — reauditar antes de criar', v_equiv;
  end if;
  raise notice 'AUDITORIA-POS-REVERSAO OK: matéria de destino única (33); assunto ausente; nenhum equivalente';
end $$;

commit;
