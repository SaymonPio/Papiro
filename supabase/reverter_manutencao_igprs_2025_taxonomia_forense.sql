-- IGP-RS 2025 (Perito Criminal) — TAXONOMIA FORENSE MÍNIMA (somente dados globais, nenhum curso).
-- Nenhuma matéria nova. Cria 19 assuntos GLOBAIS em 5 matérias globais já existentes:
-- "Criminalística" (8), "Medicina Legal" (5), "Direito Processual Penal" (1), "Direito Administrativo" (3), "Raciocínio Lógico" (2).
-- "Criminalística" e "Medicina Legal" existiam sem nenhum assunto. Qualquer
-- assunto equivalente por nome ou por chave (lei/termo técnico; chaves
-- normalizadas sem acento, caixa e pontuação, em nome + descrição de TODOS os
-- assuntos, globais ou de usuário) aborta. "Cadeia de custódia" (matéria
-- Direito Processual Penal) já existe e é reaproveitada, não recriada.
-- Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- APLICADO em 2026-10-21: assuntos ids 166-184 (Criminalística 166-173,
-- Medicina Legal 174-178, Direito Processual Penal 179, Direito
-- Administrativo 180-182, Raciocínio Lógico 183-184). Reexecutar o apply ou
-- o teste de rollback agora ABORTA na AUDITORIA (registros já existem).
--
-- REVERSÃO REAL de manutencao_igprs_2025_taxonomia_forense.sql. Recusa se qualquer questão, curso ou
-- histórico referenciar os assuntos criados (as questões da IGP-RS
-- classificadas neles precisam ser revertidas antes).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

-- chaves: cada uma é procurada em nome + descrição de assuntos de TODAS as matérias
create temporary table _igp_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _igp_tax values
('Criminalística', 'Fundamentos da Criminalística e local de crime', array['fundamentos da criminalistica', 'local de crime', 'locais de crime', 'postulados']),
('Criminalística', 'Balística forense', array['balistica']),
('Criminalística', 'Genética forense', array['genetica', 'dna']),
('Criminalística', 'Química e toxicologia forense', array['quimica forense', 'toxicologia']),
('Criminalística', 'Antropologia forense e identificação humana', array['antropologia', 'identificacao humana', 'identificacao de vitimas', 'entomologia']),
('Criminalística', 'Engenharia legal e de avaliações', array['engenharia legal', 'engenharia de avaliac']),
('Criminalística', 'Computação forense e crimes cibernéticos', array['computacao forense', 'cibernetic', 'crimes informaticos', '12 737']),
('Criminalística', 'Perícia ambiental', array['pericia ambiental', 'crimes ambientais', '9 605']),
('Medicina Legal', 'Tanatologia forense', array['tanatologia', 'cronotanatognose', 'fenomenos cadavericos']),
('Medicina Legal', 'Traumatologia forense', array['traumatologia', 'energias de ordem']),
('Medicina Legal', 'Sexologia e obstetrícia forense', array['sexologia', 'obstetricia']),
('Medicina Legal', 'Toxicologia forense', array['toxicologia']),
('Medicina Legal', 'Psicopatologia forense', array['psicopatologia', 'psiquiatria forense', 'imputabilidade']),
('Direito Processual Penal', 'Provas e perícias no processo penal (CPP)', array['provas no processo penal', 'prova pericial', 'pericias', 'corpo de delito']),
('Direito Administrativo', 'Licitações e contratos (Lei 14.133/2021)', array['licitac', '14 133', 'contratos administrativos']),
('Direito Administrativo', 'Estatuto dos Servidores Públicos Civis do RS (LC 10.098/1994)', array['10 098', 'servidores publicos civis', 'regime juridico unico']),
('Direito Administrativo', 'Carreiras do IGP-RS (Leis 11.770/2002 e 14.519/2014)', array['igp', '11 770', '14 519', 'instituto geral de pericias']),
('Raciocínio Lógico', 'Associação lógica', array['associacao logica', 'associacoes logicas', 'correlacionamento']),
('Raciocínio Lógico', 'Problemas de calendário', array['calendario']);

create temporary table _igp_tax_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_refs int; v_a int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _igp_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _igp_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 19 then raise exception 'REVERSAO: apagou % assunto(s), esperado 19', v_a; end if;
  raise notice 'REVERSAO aplicada: 19 assuntos removidos';
end $$;

do $$
declare
  v_destino int; v_equiv int; v_custodia int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m join (select distinct materia from _igp_tax) t on t.materia = m.nome
   where m.usuario_id is null and m.ativo group by m.nome having count(*) = 1) x;
  if v_destino <> 5 then raise exception 'AUDITORIA: esperadas 5 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;

  select count(*) into v_custodia from public.assuntos s join public.materias m on m.id = s.materia_id
   where s.usuario_id is null and m.usuario_id is null and m.nome = 'Direito Processual Penal' and s.nome = 'Cadeia de custódia';
  if v_custodia <> 1 then raise exception 'AUDITORIA: assunto reaproveitado "Cadeia de custódia" (Direito Processual Penal) encontrado % vez(es), esperado 1', v_custodia; end if;

  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _igp_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _igp_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%') loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) já existente(s) — reauditar antes de criar', v_equiv;
  end if;

  raise notice 'AUDITORIA OK: 5 matérias de destino existem; 19 assuntos ausentes; nenhum equivalente';
end $$;

commit;
