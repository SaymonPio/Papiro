-- GM Sant'Ana do Livramento 2025 (Fundatec 1023) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 17 assuntos GLOBAIS em matérias existentes, nenhuma matéria nova:
-- "Legislação Municipal" (5), "Matemática" (6), "Legislação de Trânsito" (4), "Direitos Humanos e Cidadania" (1), "Direito Civil" (1).
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, de todas as matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 32 (matéria 18 Raciocínio Lógico) — Sentenças abertas e conjunto-verdade: lógica proposicional, não conjuntos numéricos;
--   assunto 120 (matéria 22) — Estatuto dos Funcionários Públicos de Porto Alegre (LC 133/1985): outro município;
--   assunto 181 (matéria 16) — Estatuto dos Servidores Públicos Civis do RS (LC 10.098/1994): estatuto estadual.
-- "Normas de circulação" (assunto 3, Trânsito) cobre o Cap. III do CTB; sinalização (Cap. VII), registro/emplacamento
-- (Caps. XI/XII), infrações (Cap. XV) e conceitos (Anexo I) são capítulos distintos.
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- ROLLBACK-TESTADO em manutencao_gmlivramento_2025_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_gmlivramento_2025_taxonomia.sql

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _gml_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _gml_tax values
('Legislação Municipal', 'Lei Orgânica do Município de Sant''Ana do Livramento', array['livramento', 'lei organica']),
('Legislação Municipal', 'Previdência Municipal de Sant''Ana do Livramento — SISPREM (Lei 5.066/2006)', array['sisprem', '5 066', 'previdencia', 'regime proprio']),
('Legislação Municipal', 'Guarda Civil Municipal de Sant''Ana do Livramento (Lei 8.356/2025)', array['8 356', 'livramento', 'guarda civil municipal']),
('Legislação Municipal', 'Estrutura administrativa do Executivo de Sant''Ana do Livramento (Lei 7.469/2019)', array['7 469', 'estrutura organizacional', 'estrutura administrativa', 'organizacao administrativa']),
('Legislação Municipal', 'Estatuto dos Servidores Públicos de Sant''Ana do Livramento (Lei 2.620/1990)', array['2 620', 'livramento', 'estatuto dos servidores', 'estatuto dos funcionarios', 'regime juridico']),
('Matemática', 'Conjuntos numéricos e operações', array['conjuntos numericos', 'numeros inteiros', 'conjunto', 'operacoes']),
('Matemática', 'Progressões (PA e PG)', array['progress', 'aritmetica', 'geometrica']),
('Matemática', 'Funções', array['funcao', 'funcoes', 'dominio']),
('Matemática', 'Polinômios e expressões algébricas', array['polinomio', 'algebric', 'equac']),
('Matemática', 'Geometria plana', array['geometria', 'triangulo', 'angulo', 'tales', 'paralel']),
('Matemática', 'Análise combinatória', array['combinatoria', 'anagrama', 'permutac', 'arranjo', 'contagem']),
('Legislação de Trânsito', 'Conceitos e definições do CTB (Anexo I)', array['anexo i', 'conceitos e definicoes', 'definicoes']),
('Legislação de Trânsito', 'Sinalização de trânsito', array['sinalizacao', 'sinais de transito']),
('Legislação de Trânsito', 'Registro, identificação e emplacamento de veículos', array['registro de veiculo', 'emplacamento', 'placa', 'identificacao de veiculo', 'licenciamento']),
('Legislação de Trânsito', 'Infrações e penalidades', array['infrac', 'penalidade', 'multa']),
('Direitos Humanos e Cidadania', 'Estatuto da Criança e do Adolescente (Lei 8.069/1990)', array['8 069', 'estatuto da crianca', 'crianca e do adolescente', 'conselho tutelar', 'infancia']),
('Direito Civil', 'Código de Defesa do Consumidor (Lei 8.078/1990)', array['8 078', 'consumidor', 'relacao de consumo']);

create temporary table _gml_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _gml_homonimos values (32, 18), (120, 22), (181, 16);

create temporary table _gml_antes on commit drop as
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
   where m.usuario_id is null and m.ativo and m.nome in ('Legislação Municipal', 'Matemática', 'Legislação de Trânsito', 'Direitos Humanos e Cidadania', 'Direito Civil') group by m.nome having count(*) = 1) x;
  if v_destino <> 5 then raise exception 'AUDITORIA: esperadas 5 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Legislação Municipal', 'Matemática', 'Legislação de Trânsito', 'Direitos Humanos e Cidadania', 'Direito Civil')) <> array[4, 11, 12, 22, 33]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (4, 11, 12, 22, 33)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _gml_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _gml_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _gml_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _gml_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _gml_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 3 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 5 matérias de destino únicas; 17 assuntos ausentes; nenhum equivalente fora dos 3 homônimos aceitos';
end $$;

do $$
declare
  v_a int;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _gml_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_a <> 17 then raise exception 'INSERT: % assunto(s), esperado 17', v_a; end if;
  raise notice 'INSERT aplicado: 17 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _gml_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 17 then raise exception 'POSCOND: só % dos 17 assuntos na matéria correta', v_ok; end if;

  select * into a from _gml_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 17 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+17)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso ou classificação de questões alterada';
  end if;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _gml_tax t on t.nome = s.nome and t.materia = m.nome
           order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 17 assuntos globais nas matérias certas; nenhuma matéria, curso_materia, curso_conteudo, vínculo ou classificação alterado';
end $$;

commit;
