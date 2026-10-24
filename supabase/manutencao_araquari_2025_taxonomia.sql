-- Araquari/SC 2025 Guarda Municipal (Fundatec 1040, caderno 1040.001) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 10 assuntos GLOBAIS em matérias existentes, nenhuma matéria nova:
-- "Legislação Municipal" (4): uma lei de Araquari por assunto — Lei Orgânica; Plano de Cargos, Carreiras e Vencimentos
--   (LC 188/2014); Regime Jurídico dos Servidores Públicos (LC 117/2011); Código de Posturas (Lei 682/1984);
-- "Direito Constitucional" (3): Administração Pública e servidores (arts. 37 a 41); Organização dos Poderes (arts. 44 a 135);
--   Ordem Social (arts. 193 a 232);
-- "Raciocínio Lógico" (1): Sequências e padrões lógicos; "Informática" (1): Inteligência artificial;
-- "Legislação de Guardas Municipais" (1): Policiamento comunitário.
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, de todas as matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 4 (matéria 5) — Crimes contra a Administração Pública: direito penal, não a organização constitucional da Administração;
--   assunto 81 (matéria 10) — Poderes da Administração Pública: poderes administrativos (Direito Administrativo), não arts. 37 a 41 da CF;
--   assunto 181 (matéria 16) — Estatuto dos Servidores Públicos Civis do RS (LC 10.098/1994): lei estadual do RS;
--   assunto 287 (matéria 22) — Previdência Municipal de Sant'Ana do Livramento — SISPREM: outro município, outra lei;
--   assunto 290 (matéria 22) — Estatuto dos Servidores Públicos de Sant'Ana do Livramento (Lei 2.620/1990): outro município;
--   assunto 286 (matéria 22) — Lei Orgânica do Município de Sant'Ana do Livramento: outro município;
--   assunto 312 (matéria 13) — Meio ambiente e biomas brasileiros: geografia/CG, não o art. 225 da CF;
--   assunto 99 (matéria 11) — Tratados de Direitos Humanos com força de Emenda Constitucional: incorporação de tratados (DH);
--   assunto 77 (matéria 10) — Plano de Carreira dos Servidores Militares: carreira militar estadual, não o PCCV de Araquari;
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- ROLLBACK-TESTADO em manutencao_araquari_2025_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_araquari_2025_taxonomia.sql

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _ara_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _ara_tax values
('Legislação Municipal', 'Lei Orgânica do Município de Araquari', array['araquari', 'lei organica']),
('Legislação Municipal', 'Plano de Cargos, Carreiras e Vencimentos de Araquari (LC 188/2014)', array['araquari', 'plano de cargos', 'plano de carreira', '188 2014', 'vencimentos']),
('Legislação Municipal', 'Regime Jurídico dos Servidores Públicos de Araquari (LC 117/2011)', array['araquari', 'regime juridico', '117 2011']),
('Legislação Municipal', 'Código de Posturas de Araquari (Lei 682/1984)', array['araquari', 'posturas', '682 1984']),
('Direito Constitucional', 'Administração Pública e servidores públicos (CF, arts. 37 a 41)', array['administracao publica', 'servidores publicos', 'servidor publico', 'estabilidade', 'regime proprio', 'previdencia']),
('Direito Constitucional', 'Organização dos Poderes (CF, arts. 44 a 135)', array['organizacao dos poderes', 'poder legislativo', 'poder executivo', 'poder judiciario', 'processo legislativo', 'emenda', 'medida provisoria', 'medidas provisorias']),
('Direito Constitucional', 'Ordem Social (CF, arts. 193 a 232)', array['ordem social', 'seguridade', 'comunicacao social', 'meio ambiente', 'previdencia social', 'assistencia social']),
('Raciocínio Lógico', 'Sequências e padrões lógicos', array['sequencia', 'padroes logicos', 'padrao logico']),
('Informática', 'Inteligência artificial', array['inteligencia artificial', 'algoritmo', 'aprendizado de maquina']),
('Legislação de Guardas Municipais', 'Policiamento comunitário', array['policiamento', 'comunitari', 'policia comunitaria']);

create temporary table _ara_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _ara_homonimos values (4, 5), (81, 10), (181, 16), (287, 22), (290, 22), (286, 22), (312, 13), (99, 11), (77, 10);

create temporary table _ara_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Direito Constitucional', 'Informática', 'Legislação Municipal', 'Legislação de Guardas Municipais', 'Raciocínio Lógico') group by m.nome having count(*) = 1) x;
  if v_destino <> 5 then raise exception 'AUDITORIA: esperadas 5 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Direito Constitucional', 'Informática', 'Legislação Municipal', 'Legislação de Guardas Municipais', 'Raciocínio Lógico')) <> array[2, 3, 9, 18, 22]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (2, 3, 9, 18, 22)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _ara_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _ara_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _ara_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _ara_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _ara_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 9 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 5 matérias de destino únicas; 10 assuntos ausentes; nenhum equivalente fora dos 9 homônimos aceitos';
end $$;

do $$
declare
  v_a int;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _ara_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_a <> 10 then raise exception 'INSERT: % assunto(s), esperado 10', v_a; end if;
  raise notice 'INSERT aplicado: 10 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _ara_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 10 then raise exception 'POSCOND: só % dos 10 assuntos na matéria correta', v_ok; end if;

  select * into a from _ara_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 10 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+10)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso ou classificação de questões alterada';
  end if;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _ara_tax t on t.nome = s.nome and t.materia = m.nome
           order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 10 assuntos globais nas matérias certas; nenhuma matéria, curso_materia, curso_conteudo, vínculo ou classificação alterado';
end $$;

commit;
