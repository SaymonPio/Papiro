-- PP-RS 2026 — TAXONOMIA PRISIONAL MÍNIMA (somente dados globais, nenhum curso).
-- Cria 2 matérias GLOBAIS sem curso_materia — "Execução Penal" (2 assuntos)
-- e "Sistema Prisional e Polícia Penal" (2 assuntos) — e 7 assuntos em
-- matérias globais já existentes: "Direito Constitucional" (2),
-- "Legislação Penal Especial" (4) e "Direito Administrativo" (1).
-- A matéria "Legislação Específica" (estrutura da BM) NÃO é tocada nem usada.
-- Homônimos já existentes FORA da matéria de destino são aceitos por decisão
-- explícita (Lei de Drogas 78, Estatuto do Desarmamento 68, Lei Maria da
-- Penha 19, Constituição do RS 80, Direitos e Garantias Fundamentais 71,
-- Improbidade 64 — matéria 10; Direitos fundamentais 25 — matéria 11) e
-- conferidos pela auditoria (continuam exatamente onde estavam). Qualquer
-- OUTRO equivalente por nome ou por lei (chaves normalizadas sem acento,
-- caixa e pontuação, em nome + descrição de TODAS as matérias) aborta.
-- Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- APLICADO em 2026-10-20: matérias ids 25 (Execução Penal) e 26 (Sistema
-- Prisional e Polícia Penal), assuntos ids 136-146. Reexecutar o apply ou o
-- teste de rollback agora ABORTA na AUDITORIA (registros já existem).
--
-- REVERSÃO REAL de manutencao_pprs_2026_taxonomia_prisional.sql. Recusa se
-- qualquer questão, curso ou histórico referenciar os registros criados
-- (as questões da PP-RS classificadas nela precisam ser revertidas antes).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _pprs_mat (nome text not null, chave text not null) on commit drop;
insert into _pprs_mat values
('Execução Penal', 'execucao penal'),
('Sistema Prisional e Polícia Penal', 'prisional');

-- chaves: cada uma é procurada em nome + descrição de assuntos de TODAS as matérias
create temporary table _pprs_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _pprs_tax values
('Execução Penal', 'Trabalho do condenado', array['trabalho do condenado', 'trabalho do preso']),
('Execução Penal', 'Deveres, direitos e disciplina do preso', array['disciplina do preso', 'execucao penal', '7 210']),
('Sistema Prisional e Polícia Penal', 'Estatuto da Polícia Penal do RS (LC 16.449/2025)', array['policia penal', '16 449']),
('Sistema Prisional e Polícia Penal', 'Visitas e televisitas no sistema prisional do RS (IN 014/2023 e IN 001/2025 GAB/SUP)', array['visita', 'televisita', '014 2023', '001 2025']),
('Direito Constitucional', 'Direitos e garantias fundamentais (CF/88)', array['garantias fundamentais', 'direitos fundamentais']),
('Direito Constitucional', 'Constituição do Estado do Rio Grande do Sul', array['constituicao do estado', 'constituicao estadual']),
('Legislação Penal Especial', 'Crimes hediondos (Lei 8.072/1990)', array['hediond', '8 072']),
('Legislação Penal Especial', 'Estatuto do Desarmamento (Lei 10.826/2003)', array['desarmamento', '10 826']),
('Legislação Penal Especial', 'Lei de Drogas (Lei 11.343/2006)', array['drogas', '11 343']),
('Legislação Penal Especial', 'Lei Maria da Penha (Lei 11.340/2006)', array['maria da penha', '11 340']),
('Direito Administrativo', 'Improbidade administrativa (Lei 8.429/1992)', array['improbidade', '8 429']);

-- homônimos aceitos (fora da matéria de destino): id -> matéria onde precisam continuar
create temporary table _pprs_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _pprs_homonimos values (78, 10), (68, 10), (19, 10), (80, 10), (71, 10), (64, 10), (25, 11);

create temporary table _pprs_tax_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_refs int; v_a int; v_m int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _pprs_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null),
       alvo_m as (select m.id from public.materias m join _pprs_mat t on t.nome = m.nome where m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a) or materia_id in (select id from alvo_m))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_materias where materia_id in (select id from alvo_m))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a) or materia_id in (select id from alvo_m))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a) or materia_id in (select id from alvo_m))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a) or materia_id in (select id from alvo_m))
       + (select count(*) from public.assuntos where materia_id in (select id from alvo_m) and id not in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos registros criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _pprs_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  delete from public.materias m using _pprs_mat t where t.nome = m.nome and m.usuario_id is null;
  get diagnostics v_m = row_count;
  if v_a <> 11 or v_m <> 2 then raise exception 'REVERSAO: apagou % assunto(s) e % matéria(s), esperado 11 e 2', v_a, v_m; end if;
  raise notice 'REVERSAO aplicada: 11 assuntos e 2 matérias removidos';
end $$;

do $$
declare
  v_destino int; v_materia int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from public.materias
   where usuario_id is null and ativo and nome in ('Direito Constitucional', 'Legislação Penal Especial', 'Direito Administrativo');
  if v_destino <> 3 then raise exception 'AUDITORIA: esperadas 3 matérias globais ativas de destino (Direito Constitucional, Legislação Penal Especial, Direito Administrativo), encontradas %', v_destino; end if;

  select count(*) into v_materia from public.materias m join _pprs_mat t
    on pg_temp.norm(m.nome) = pg_temp.norm(t.nome) or pg_temp.norm(m.nome) like '%' || t.chave || '%';
  if v_materia <> 0 then raise exception 'AUDITORIA: já existe matéria equivalente a uma das novas (%) — reauditar antes de criar', v_materia; end if;

  -- equivalência por nome exato normalizado OU por chave (nome/lei) em qualquer matéria,
  -- exceto os homônimos aceitos
  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _pprs_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _pprs_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _pprs_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _pprs_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora da lista de homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _pprs_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 7 then raise exception 'AUDITORIA: só % dos 7 homônimos aceitos estão onde a decisão os encontrou — reauditar', v_homon; end if;

  raise notice 'AUDITORIA OK: 3 matérias de destino existem; 2 matérias novas e 11 assuntos ausentes; nenhum equivalente fora dos 7 homônimos aceitos';
end $$;

commit;
