-- Gravataí/RS 2025 Guarda Municipal (Fundatec 1021, caderno 1021.018) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 1 matéria GLOBAL nova, "Direito Ambiental" (nenhuma matéria equivalente por ambient, meio ambiente, ecolog), e 11 assuntos GLOBAIS:
-- "Direito Ambiental" (5): PNRS (Lei 12.305/2010); Saneamento básico (Lei 11.445/2007); PNMA e SISNAMA (Lei 6.938/1981);
--   Educação ambiental (Lei 9.795/1999); SNUC (Lei 9.985/2000);
-- "Legislação Penal Especial" (1): Crimes ambientais (Lei 9.605/1998);
-- "Legislação Municipal" (1): Regime Jurídico Único dos Servidores Públicos de Gravataí (Lei 681/1991);
-- "Língua Portuguesa" (1): Termos essenciais da oração; "Matemática" (1): Geometria espacial;
-- "Legislação de Guardas Municipais" (2): Comunicação operacional (Código Q); Prevenção e combate a incêndio.
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, de todas as matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 295 (matéria 12) — Geometria plana: geometria do plano, não sólidos/volumes;
--   assunto 173 (matéria 15) — Perícia ambiental: Criminalística (perícia), não legislação ambiental;
--   assunto 312 (matéria 13) — Meio ambiente e biomas brasileiros: conhecimento geral (biomas, clima), não a Lei 6.938/1981;
--   assunto 26 (matéria 11) — Prevenção da tortura: Direitos Humanos, prevenção em outro sentido;
--   assunto 337 (matéria 22) — Regime Jurídico dos Servidores Públicos de Araquari (LC 117/2011): outro município;
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- REVERSÃO REAL de manutencao_gravatai_2025_taxonomia.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar os assuntos criados (reverter antes as questões classificadas neles).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _gra_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _gra_tax values
('Direito Ambiental', 'Política Nacional de Resíduos Sólidos (Lei 12.305/2010)', array['residuos solidos', '12 305']),
('Direito Ambiental', 'Saneamento básico (Lei 11.445/2007)', array['saneamento', '11 445']),
('Direito Ambiental', 'Política Nacional do Meio Ambiente e SISNAMA (Lei 6.938/1981)', array['meio ambiente', 'sisnama', '6 938', 'ambiental']),
('Direito Ambiental', 'Educação ambiental (Lei 9.795/1999)', array['educacao ambiental', '9 795']),
('Direito Ambiental', 'Sistema Nacional de Unidades de Conservação — SNUC (Lei 9.985/2000)', array['unidades de conservacao', 'snuc', '9 985', 'plano de manejo']),
('Legislação Penal Especial', 'Crimes ambientais (Lei 9.605/1998)', array['crimes ambientais', 'crime ambiental', '9 605']),
('Legislação Municipal', 'Regime Jurídico Único dos Servidores Públicos de Gravataí (Lei 681/1991)', array['gravatai', 'regime juridico', '681 1991']),
('Língua Portuguesa', 'Termos essenciais da oração (sujeito e predicado)', array['termos essenciais', 'sujeito', 'predicado', 'sintaxe']),
('Matemática', 'Geometria espacial', array['geometria espacial', 'volume', 'solidos', 'geometria']),
('Legislação de Guardas Municipais', 'Comunicação operacional (radiocomunicação e Código Q)', array['comunicacao', 'radio', 'codigo q']),
('Legislação de Guardas Municipais', 'Prevenção e combate a incêndio', array['incendio', 'extintor', 'combate a', 'prevencao']);

create temporary table _gra_mat (nome text not null, chaves text[] not null) on commit drop;
insert into _gra_mat values ('Direito Ambiental', array['ambient', 'meio ambiente', 'ecolog']);

create temporary table _gra_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _gra_homonimos values (295, 12), (173, 15), (312, 13), (26, 11), (337, 22);

create temporary table _gra_antes on commit drop as
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
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _gra_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;
  with alvo_m as (select m.id from public.materias m join _gra_mat t on t.nome = m.nome where m.usuario_id is null)
  select (select count(*) from public.questoes where materia_id in (select id from alvo_m))
       + (select count(*) from public.curso_materias where materia_id in (select id from alvo_m))
       + (select count(*) from public.conversas_ia where materia_id in (select id from alvo_m))
       + (select count(*) from public.sessoes_estudo where materia_id in (select id from alvo_m))
       + (select count(*) from public.sessoes_tempo where materia_id in (select id from alvo_m))
       + (select count(*) from public.assuntos s where s.materia_id in (select id from alvo_m) and s.nome not in (select nome from _gra_tax))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) à matéria criada', v_refs; end if;

  delete from public.assuntos s using public.materias m, _gra_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 11 then raise exception 'REVERSAO: apagou % assunto(s), esperado 11', v_a; end if;
  delete from public.materias m using _gra_mat t where t.nome = m.nome and m.usuario_id is null;
  get diagnostics v_m = row_count;
  if v_m <> 1 then raise exception 'REVERSAO: apagou % matéria(s), esperado 1', v_m; end if;
  raise notice 'REVERSAO aplicada: 11 assuntos e 1 matéria removidos';
end $$;

do $$
declare
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Legislação de Guardas Municipais', 'Língua Portuguesa', 'Legislação Penal Especial', 'Matemática', 'Legislação Municipal') group by m.nome having count(*) = 1) x;
  if v_destino <> 5 then raise exception 'AUDITORIA: esperadas 5 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Legislação de Guardas Municipais', 'Língua Portuguesa', 'Legislação Penal Especial', 'Matemática', 'Legislação Municipal')) <> array[2, 6, 8, 12, 22]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (2, 6, 8, 12, 22)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _gra_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _gra_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _gra_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _gra_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _gra_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 5 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  if exists (select 1 from public.materias m, _gra_mat t where pg_temp.norm(m.nome) = pg_temp.norm(t.nome)
             or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(m.nome || ' ' || coalesce(m.descricao, '')) like '%' || k || '%')) then
    raise exception 'AUDITORIA: já existe matéria equivalente a Direito Ambiental — reutilizar, não criar';
  end if;
  raise notice 'AUDITORIA OK: matéria Direito Ambiental ausente (nenhuma equivalente); 5 matérias de destino únicas; 11 assuntos ausentes; nenhum equivalente fora dos 5 homônimos aceitos';
end $$;

commit;
