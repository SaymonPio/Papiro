-- SEJUSP/MG 2022 Agente de Segurança Socioeducativo (Fundatec, concurso 687) — TAXONOMIA (somente dados globais, nenhum curso).
-- Nenhuma matéria nova. Cria 6 assuntos GLOBAIS em matérias existentes:
-- "Direitos Humanos e Cidadania" (11): SINASE (Lei 12.594/2012 e Resolução Conanda 119/2006);
-- "Direito Administrativo" (16): Estatuto dos Servidores Públicos Civis de MG (Lei 869/1952);
--                                Código de Conduta Ética do Agente Público de MG (Decreto 46.644/2014);
-- "Direito Constitucional" (3): Crimes de responsabilidade (Lei 1.079/1950);
-- "Língua Portuguesa" (6): Funções da linguagem; Tipologia textual.
-- "Probabilidade" NÃO é criado: já existe (assunto 388, matéria 40 Estatística).
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, globais e de usuário). Nenhum homônimo aceito: qualquer equivalente aborta.
-- Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de questão é alterado (conferido por
-- assinatura antes/depois).
--
-- ROLLBACK-TESTADO em manutencao_sejusp_2022_agente_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_sejusp_2022_agente_taxonomia.sql

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _687_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _687_tax values
('Direitos Humanos e Cidadania', 'SINASE (Lei 12.594/2012 e Resolução Conanda 119/2006)', array['sinase', 'socioeducativ', '12 594', 'conanda']),
('Direito Administrativo', 'Estatuto dos Servidores Públicos Civis de MG (Lei 869/1952)', array['869 1952', 'minas gerais', ' de mg ']),
('Direito Administrativo', 'Código de Conduta Ética do Agente Público de MG (Decreto 46.644/2014)', array['conduta etica', 'codigo de conduta', 'codigo de etica', '46 644', 'alta administracao']),
('Direito Constitucional', 'Crimes de responsabilidade (Lei 1.079/1950)', array['crimes de responsabilidade', 'crime de responsabilidade', '1 079', 'impeachment']),
('Língua Portuguesa', 'Funções da linguagem', array['funcoes da linguagem', 'funcao da linguagem', 'jakobson', 'funcao referencial', 'funcao emotiva', 'funcao poetica', 'funcao apelativa']),
('Língua Portuguesa', 'Tipologia textual', array['tipologia', 'tipos textuais', 'tipo textual', 'tipos de texto', 'texto narrativo', 'texto dissertativo', 'texto expositivo', 'texto descritivo']);

create temporary table _687_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_destino int; v_equiv int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Direitos Humanos e Cidadania', 'Direito Administrativo', 'Direito Constitucional', 'Língua Portuguesa') group by m.nome having count(*) = 1) x;
  if v_destino <> 4 then raise exception 'AUDITORIA: esperadas 4 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Direitos Humanos e Cidadania', 'Direito Administrativo', 'Direito Constitucional', 'Língua Portuguesa')) <> array[3, 6, 11, 16]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (3, 6, 11, 16)';
  end if;
  if not exists (select 1 from public.assuntos where id = 388 and materia_id = 40 and nome = 'Probabilidade' and usuario_id is null) then
    raise exception 'AUDITORIA: assunto 388 Probabilidade (matéria 40) não encontrado — a Q57 dependia dele';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _687_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '%' || k || '%')) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _687_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where ' ' || pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) || ' ' like '%' || k || '%') loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) — reauditar antes de criar', v_equiv;
  end if;
  raise notice 'AUDITORIA OK: 4 matérias de destino únicas (3, 6, 11, 16); 388 Probabilidade presente; 6 assuntos ausentes; nenhum equivalente';
end $$;

do $$
declare
  v_a int;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _687_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_a <> 6 then raise exception 'INSERT: % assunto(s), esperado 6', v_a; end if;
  raise notice 'INSERT aplicado: 6 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _687_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 6 then raise exception 'POSCOND: só % dos 6 assuntos na matéria correta', v_ok; end if;

  select * into a from _687_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 6 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+6)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso, questões, unidades ou classificação de questões alterada';
  end if;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _687_tax t on t.nome = s.nome and t.materia = m.nome
           where s.usuario_id is null order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 6 assuntos globais nas matérias certas; nenhuma matéria, curso_materia, curso_conteudo, vínculo, questão, unidade ou classificação alterado';
end $$;

commit;
