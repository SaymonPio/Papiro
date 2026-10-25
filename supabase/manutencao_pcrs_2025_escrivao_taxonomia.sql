-- PC-RS 2025 Escrivão e Inspetor de Polícia (Fundatec, concurso 993) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 2 matérias GLOBAIS novas, "Contabilidade" e "Estatística" (nenhuma matéria ou assunto equivalente), e 14 assuntos GLOBAIS:
-- "Contabilidade" (5): Estoques e CMV; Depreciação; Demonstração dos Fluxos de Caixa; Lançamentos e balancete; Receitas e despesas;
-- "Estatística" (4): Estatística descritiva; Inferência / testes de hipóteses; Probabilidade; Correlação e regressão;
-- "Informática" (1): Linux;
-- "Legislação Penal Especial" (1): Crimes de trânsito;
-- "Direito Processual Penal" (1): Princípios da lei processual penal;
-- "Direito Administrativo" (2): LGPD; Lei Orgânica Nacional das Polícias Civis;
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos e matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 297 (matéria 4) — Conceitos e definições do CTB (Anexo I): conceitos do Anexo I, não crimes de trânsito;
--   assunto 298 (matéria 4) — Sinalização de trânsito: sinalização, não crimes de trânsito;
--   assunto 260 (matéria 16) — Estatuto da Polícia Civil do RS (Lei 7.366/1980): lei ESTADUAL, não a Lei Orgânica Nacional (Lei 14.735/2023);
--   assunto 286 (matéria 22) — Lei Orgânica do Município de Sant'Ana do Livramento: lei orgânica municipal;
--   assunto 335 (matéria 22) — Lei Orgânica do Município de Araquari: lei orgânica municipal;
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- ROLLBACK-TESTADO em manutencao_pcrs_2025_escrivao_taxonomia_teste_rollback.sql
-- REVERSAO REAL em reverter_manutencao_pcrs_2025_escrivao_taxonomia.sql

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _993_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _993_tax values
('Contabilidade', 'Estoques e CMV', array['estoque', 'cmv', 'custo das mercadorias']),
('Contabilidade', 'Depreciação', array['deprecia', 'imobilizado', 'amortiza']),
('Contabilidade', 'Demonstração dos Fluxos de Caixa', array['fluxo de caixa', 'fluxos de caixa', 'dfc', 'cpc 03']),
('Contabilidade', 'Lançamentos e balancete', array['lancamento', 'balancete', 'escritura', 'partidas dobradas']),
('Contabilidade', 'Receitas e despesas', array['receita', 'despesa']),
('Estatística', 'Estatística descritiva', array['estatistica descritiva', 'mediana', 'desvio padrao', 'variancia', 'medidas de posicao', 'medidas de dispersao']),
('Estatística', 'Inferência / testes de hipóteses', array['inferencia', 'hipotese', 'intervalo de confianca']),
('Estatística', 'Probabilidade', array['probabilid']),
('Estatística', 'Correlação e regressão', array['correlac', 'regressa']),
('Informática', 'Linux', array['linux', 'sistema operacional', 'sistemas operacionais', 'unix']),
('Legislação Penal Especial', 'Crimes de trânsito', array['transito', 'ctb', '9 503', 'codigo de transito']),
('Direito Processual Penal', 'Princípios da lei processual penal', array['principio', 'lei processual', 'sistemas processuais', 'sistema acusatorio', 'aplicacao da lei']),
('Direito Administrativo', 'LGPD', array['lgpd', 'protecao de dados', 'dados pessoais', '13 709']),
('Direito Administrativo', 'Lei Orgânica Nacional das Polícias Civis', array['lei organica', 'policias civis', 'policia civil', '14 735']);

create temporary table _993_mat (nome text not null, chaves text[] not null) on commit drop;
insert into _993_mat values
('Contabilidade', array['contab', 'contador', 'patrimonio liquido', 'balanco patrimonial']),
('Estatística', array['estatistic', 'probabilid', 'amostra']);

create temporary table _993_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _993_homonimos values (297, 4), (298, 4), (260, 16), (286, 22), (335, 22);

create temporary table _993_antes on commit drop as
select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes;

do $$
declare
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Informática', 'Legislação Penal Especial', 'Direito Processual Penal', 'Direito Administrativo') group by m.nome having count(*) = 1) x;
  if v_destino <> 4 then raise exception 'AUDITORIA: esperadas 4 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Informática', 'Legislação Penal Especial', 'Direito Processual Penal', 'Direito Administrativo')) <> array[7, 8, 9, 16]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (7, 8, 9, 16)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _993_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _993_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _993_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _993_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _993_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 5 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  select count(*) into v_equiv from (
    select distinct m.id, m.nome from public.materias m, _993_mat t
      where pg_temp.norm(m.nome) = pg_temp.norm(t.nome)
         or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(m.nome || ' ' || coalesce(m.descricao, '')) like '%' || k || '%')
      union
      select distinct a.id, a.nome from public.assuntos a, _993_mat t
      where exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')) x;
  if v_equiv <> 0 then
    for r in select distinct m.id, m.nome from public.materias m, _993_mat t
      where pg_temp.norm(m.nome) = pg_temp.norm(t.nome)
         or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(m.nome || ' ' || coalesce(m.descricao, '')) like '%' || k || '%')
      union
      select distinct a.id, a.nome from public.assuntos a, _993_mat t
      where exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%') loop
      raise notice 'EQUIVALENTE DE MATÉRIA: % "%"', r.id, r.nome;
    end loop;
    raise exception 'AUDITORIA: já existe matéria/assunto equivalente a Contabilidade ou Estatística — reutilizar, não criar';
  end if;
  raise notice 'AUDITORIA OK: matérias Contabilidade e Estatística ausentes (nenhuma equivalente); 4 matérias de destino únicas; 14 assuntos ausentes; nenhum equivalente fora dos 5 homônimos aceitos';
end $$;

do $$
declare
  v_a int; v_m int;
begin
  insert into public.materias (usuario_id, nome) select null, nome from _993_mat;
  get diagnostics v_m = row_count;
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _993_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_m <> 2 or v_a <> 14 then raise exception 'INSERT: % matéria(s) e % assunto(s), esperado 2 e 14', v_m, v_a; end if;
  raise notice 'INSERT aplicado: 2 matérias globais + 14 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _993_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 14 then raise exception 'POSCOND: só % dos 14 assuntos na matéria correta', v_ok; end if;

  select * into a from _993_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes, (select count(*) from public.questoes) questoes,
       (select count(*) from public.questao_unidades_pedagogicas) unidades,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias + 2 or d.assuntos <> a.assuntos + 14 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +2/+14)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.questoes, a.unidades, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.questoes, d.unidades, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso, questões, unidades ou classificação de questões alterada';
  end if;
  for r in select m.id mid, m.nome materia from public.materias m join _993_mat t on t.nome = m.nome where m.usuario_id is null order by 1 loop
    raise notice 'CRIADA: matéria % "%"', r.mid, r.materia;
  end loop;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _993_tax t on t.nome = s.nome and t.materia = m.nome
           order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 2 matérias + 14 assuntos globais nas matérias certas; nenhum curso_materia, curso_conteudo, vínculo, questão, unidade ou classificação alterado';
end $$;

commit;
