-- GM POA 2025 — TAXONOMIA MÍNIMA (somente dados globais, nenhum curso).
-- Cria a matéria GLOBAL "Legislação Municipal" (sem curso_materia) com 3 assuntos
-- de legislação de Porto Alegre (Q30-Q35, Q41-Q42), e 2 assuntos na matéria
-- já existente "Legislação de Guardas Municipais" (Q59 SUSP, Q58 videomonitoramento).
-- A matéria "Legislação Específica" (estrutura da BM) NÃO é tocada.
-- Auditoria anti-duplicação dentro do script: nomes normalizados (sem
-- acento, caixa e pontuação) + chaves (133/1985, 992/2023, 874/2020, SUSP,
-- videomonitoramento) em TODAS as matérias.
-- Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- APLICADO em 2026-10-19: matéria id 22, assuntos ids 120-124. Reexecutar
-- o apply ou o teste de rollback agora ABORTA na AUDITORIA (registros já
-- existem) — nenhuma segunda alteração equivalente é possível.
--
-- TESTE DE ROLLBACK REAL: AUSENTE -> APPLY -> TARGET -> REVERSÃO REAL -> AUSENTE,
-- numa transação que termina em ROLLBACK.

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _gmpoa_tax (materia text not null, nome text not null, chave text not null) on commit drop;
insert into _gmpoa_tax values
('Legislação Municipal', 'Estatuto dos Funcionários Públicos de Porto Alegre (LC 133/1985)', '133 1985'),
('Legislação Municipal', 'Processo Administrativo Municipal de Porto Alegre (LC 992/2023)', '992 2023'),
('Legislação Municipal', 'Guardadores Autônomos de Veículos em Porto Alegre (LC 874/2020)', '874 2020'),
('Legislação de Guardas Municipais', 'Sistema Único de Segurança Pública – SUSP (Lei 13.675/2018)', 'susp'),
('Legislação de Guardas Municipais', 'Videomonitoramento e Gestão Integrada de Segurança Urbana', 'videomonitoramento');

create temporary table _gmpoa_tax_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_guardas int; v_materia int; v_equiv int;
begin
  select count(*) into v_guardas from public.materias where nome = 'Legislação de Guardas Municipais' and usuario_id is null and ativo;
  if v_guardas <> 1 then raise exception 'AUDITORIA: matéria global "Legislação de Guardas Municipais" ativa não encontrada exatamente 1 vez (%)', v_guardas; end if;

  select count(*) into v_materia from public.materias where pg_temp.norm(nome) = pg_temp.norm('Legislação Municipal');
  if v_materia <> 0 then raise exception 'AUDITORIA: já existe matéria equivalente a "Legislação Municipal" (%) — reauditar antes de criar', v_materia; end if;

  select count(*) into v_equiv from public.assuntos a join _gmpoa_tax t on pg_temp.norm(a.nome) like '%' || t.chave || '%';
  if v_equiv <> 0 then raise exception 'AUDITORIA: % assunto(s) equivalente(s) já existem em alguma matéria — reauditar antes de criar', v_equiv; end if;

  raise notice 'AUDITORIA OK: "Legislação de Guardas Municipais" existe; "Legislação Municipal" e os 5 assuntos estão ausentes (nenhum equivalente em outra matéria)';
end $$;

do $$
declare
  v_m int; v_a int;
begin
  insert into public.materias (usuario_id, nome) values (null, 'Legislação Municipal');
  get diagnostics v_m = row_count;
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _gmpoa_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_m <> 1 or v_a <> 5 then raise exception 'INSERT: % matéria(s) e % assunto(s), esperado 1 e 5', v_m, v_a; end if;
  raise notice 'INSERT aplicado: 1 matéria global + 5 assuntos globais';
end $$;

do $$
declare
  v_m int; v_ok int; a record; d record;
begin
  select count(*) into v_m from public.materias where nome = 'Legislação Municipal' and usuario_id is null and ativo;
  if v_m <> 1 then raise exception 'POSCOND: matéria "Legislação Municipal" global ativa encontrada % vez(es)', v_m; end if;
  select count(*) into v_ok from _gmpoa_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 5 then raise exception 'POSCOND: só % dos 5 assuntos na matéria correta', v_ok; end if;

  select * into a from _gmpoa_tax_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
         (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
         (select count(*) from public.curso_questoes) curso_questoes,
         (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
         (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
         (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias + 1 or d.assuntos <> a.assuntos + 5 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +1/+5)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso ou classificação de questões alterada';
  end if;
  raise notice 'POSCONDICOES OK: "Legislação Municipal" (global, sem curso) + 5 assuntos nas matérias certas; nenhum curso_materia/curso_conteudo/vínculo/classificação alterado';
end $$;

do $$
declare
  v_refs int; v_a int; v_m int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _gmpoa_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null),
       alvo_m as (select id from public.materias where nome = 'Legislação Municipal' and usuario_id is null)
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

  delete from public.assuntos s using public.materias m, _gmpoa_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null;
  get diagnostics v_a = row_count;
  delete from public.materias where nome = 'Legislação Municipal' and usuario_id is null;
  get diagnostics v_m = row_count;
  if v_a <> 5 or v_m <> 1 then raise exception 'REVERSAO: apagou % assunto(s) e % matéria(s), esperado 5 e 1', v_a, v_m; end if;
  raise notice 'REVERSAO aplicada: 5 assuntos e a matéria "Legislação Municipal" removidos';
end $$;

do $$
declare
  v_guardas int; v_materia int; v_equiv int;
begin
  select count(*) into v_guardas from public.materias where nome = 'Legislação de Guardas Municipais' and usuario_id is null and ativo;
  if v_guardas <> 1 then raise exception 'AUDITORIA: matéria global "Legislação de Guardas Municipais" ativa não encontrada exatamente 1 vez (%)', v_guardas; end if;

  select count(*) into v_materia from public.materias where pg_temp.norm(nome) = pg_temp.norm('Legislação Municipal');
  if v_materia <> 0 then raise exception 'AUDITORIA: já existe matéria equivalente a "Legislação Municipal" (%) — reauditar antes de criar', v_materia; end if;

  select count(*) into v_equiv from public.assuntos a join _gmpoa_tax t on pg_temp.norm(a.nome) like '%' || t.chave || '%';
  if v_equiv <> 0 then raise exception 'AUDITORIA: % assunto(s) equivalente(s) já existem em alguma matéria — reauditar antes de criar', v_equiv; end if;

  raise notice 'AUDITORIA OK: "Legislação de Guardas Municipais" existe; "Legislação Municipal" e os 5 assuntos estão ausentes (nenhum equivalente em outra matéria)';
end $$;

do $$ begin raise notice 'TESTE DE ROLLBACK: AUSENTE -> APPLY -> TARGET -> REVERSAO -> AUSENTE — GMPOA_2025_TAXONOMIA_MINIMA_ROLLBACK_APROVADO'; end $$;

rollback;
