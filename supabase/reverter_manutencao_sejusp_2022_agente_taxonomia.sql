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
-- REVERSÃO REAL de manutencao_sejusp_2022_agente_taxonomia.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar os assuntos criados (reverter antes as questões classificadas neles).

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
  v_refs int; v_a int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _687_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _687_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 6 then raise exception 'REVERSAO: apagou % assunto(s), esperado 6', v_a; end if;
  raise notice 'REVERSAO aplicada: 6 assuntos removidos';
end $$;

do $$
declare
  a record; d record;
begin
  select * into a from _687_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos - 6 then raise exception 'POSCOND REVERSAO: matérias %->%, assuntos %->%', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND REVERSAO: estrutura de curso, questões, unidades ou classificação de questões alterada';
  end if;
  raise notice 'POSCOND REVERSAO OK: contagens e assinaturas conferem';
end $$;

commit;
