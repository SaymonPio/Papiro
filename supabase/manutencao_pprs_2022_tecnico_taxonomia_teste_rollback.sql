-- PP-RS 2022 Técnico Administrativo (Fundatec 650, caderno 0650.001) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 3 assuntos GLOBAIS em matérias existentes, nenhuma matéria nova:
-- "Execução Penal" (2): disposições gerais/objetivos da LEP; Regras Mínimas para o Tratamento do Preso (Res. CNPCP 14/1994);
-- "Conhecimentos Gerais" (1): Geografia Geral — conhecimento permanente, NÃO atualidade.
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, de todas as matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 136 (matéria 25) — Trabalho do condenado: outro capítulo da LEP;
--   assunto 314 (matéria 25) — Classificação e identificação do condenado: outro capítulo da LEP (arts. 5º a 9º-A);
--   assunto 137 (matéria 25) — Deveres, direitos e disciplina do preso (LEP e regimento disciplinar): não é a Res. CNPCP 14/1994;
--   assunto 1 (matéria 2) — Estatuto Geral das Guardas Municipais: "municipais" contém "pais";
--   assunto 250 (matéria 5) — Crimes contra o patrimônio: direito penal, não patrimônio cultural/geografia.
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- TESTE DE ROLLBACK REAL: AUSENTE -> APPLY -> TARGET -> REVERSÃO REAL -> AUSENTE,
-- numa transação que termina em ROLLBACK. (Sequências de id avançam mesmo
-- assim — o apply real recebe ids posteriores aos consumidos aqui.)

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _tec22_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _tec22_tax values
('Execução Penal', 'Disposições gerais e objetivos da execução penal (LEP)', array['disposic', 'objetivo', 'execucao penal', '7 210', 'condenado', 'integracao social']),
('Execução Penal', 'Regras Mínimas para o Tratamento do Preso (Res. CNPCP 14/1994)', array['regras minimas', '14 1994', 'cnpcp', 'tratamento do preso', 'preso', 'mandela']),
('Conhecimentos Gerais', 'Geografia Geral', array['geografi', 'patrimonio', 'pais', 'cultura geral', 'mundial']);

create temporary table _tec22_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _tec22_homonimos values (136, 25), (314, 25), (137, 25), (1, 2), (250, 5);

create temporary table _tec22_antes on commit drop as
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
   where m.usuario_id is null and m.ativo and m.nome in ('Conhecimentos Gerais', 'Execução Penal') group by m.nome having count(*) = 1) x;
  if v_destino <> 2 then raise exception 'AUDITORIA: esperadas 2 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Conhecimentos Gerais', 'Execução Penal')) <> array[13, 25]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (13, 25)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _tec22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _tec22_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _tec22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _tec22_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _tec22_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 5 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 2 matérias de destino únicas; 3 assuntos ausentes; nenhum equivalente fora dos 5 homônimos aceitos';
end $$;

do $$
declare
  v_a int;
begin
  insert into public.assuntos (usuario_id, materia_id, nome)
  select null, m.id, t.nome from _tec22_tax t join public.materias m on m.nome = t.materia and m.usuario_id is null and m.ativo;
  get diagnostics v_a = row_count;
  if v_a <> 3 then raise exception 'INSERT: % assunto(s), esperado 3', v_a; end if;
  raise notice 'INSERT aplicado: 3 assuntos globais';
end $$;

do $$
declare
  v_ok int; a record; d record; r record;
begin
  select count(*) into v_ok from _tec22_tax t
    where (select count(*) from public.assuntos s join public.materias m on m.id = s.materia_id where s.nome = t.nome and s.usuario_id is null and m.nome = t.materia and m.usuario_id is null) = 1;
  if v_ok <> 3 then raise exception 'POSCOND: só % dos 3 assuntos na matéria correta', v_ok; end if;

  select * into a from _tec22_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos + 3 then raise exception 'POSCOND: matérias %->%, assuntos %->% (esperado +0/+3)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'POSCOND: estrutura de curso ou classificação de questões alterada';
  end if;
  for r in select s.materia_id, t.materia, s.id aid, s.nome anome from public.assuntos s join public.materias m on m.id = s.materia_id join _tec22_tax t on t.nome = s.nome and t.materia = m.nome
           order by 1, 3 loop
    raise notice 'CRIADO: matéria % "%" / assunto % "%"', r.materia_id, r.materia, r.aid, r.anome;
  end loop;
  raise notice 'POSCONDICOES OK: 3 assuntos globais nas matérias certas; nenhuma matéria, curso_materia, curso_conteudo, vínculo ou classificação alterado';
end $$;

do $$
declare
  v_refs int; v_a int;
begin
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _tec22_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _tec22_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 3 then raise exception 'REVERSAO: apagou % assunto(s), esperado 3', v_a; end if;
  raise notice 'REVERSAO aplicada: 3 assuntos removidos';
end $$;

do $$
declare
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Conhecimentos Gerais', 'Execução Penal') group by m.nome having count(*) = 1) x;
  if v_destino <> 2 then raise exception 'AUDITORIA: esperadas 2 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Conhecimentos Gerais', 'Execução Penal')) <> array[13, 25]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (13, 25)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _tec22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _tec22_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _tec22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _tec22_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _tec22_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 5 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 2 matérias de destino únicas; 3 assuntos ausentes; nenhum equivalente fora dos 5 homônimos aceitos';
end $$;

do $$
declare
  a record; d record;
begin
  select * into a from _tec22_antes;
  select (select count(*) from public.materias) materias, (select count(*) from public.assuntos) assuntos,
       (select count(*) from public.curso_materias) curso_materias, (select count(*) from public.curso_conteudos) curso_conteudos,
       (select count(*) from public.curso_questoes) curso_questoes,
       (select md5(string_agg(id::text || ':' || coalesce(materia_id::text,'') || ':' || nome || ':' || coalesce(peso::text,''), '|' order by id)) from public.curso_materias) md5_curso_materias,
       (select md5(string_agg(id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.curso_conteudos) md5_curso_conteudos,
       (select md5(string_agg(id::text || ':' || materia_id::text || ':' || coalesce(assunto_id::text,''), '|' order by id)) from public.questoes) md5_classificacao_questoes
    into d;
  if d.materias <> a.materias or d.assuntos <> a.assuntos then raise exception 'TESTE: após a reversão matérias %->%, assuntos %->% (esperado igual ao início)', a.materias, d.materias, a.assuntos, d.assuntos; end if;
  if (a.curso_materias, a.curso_conteudos, a.curso_questoes, a.md5_curso_materias, a.md5_curso_conteudos, a.md5_classificacao_questoes)
     is distinct from (d.curso_materias, d.curso_conteudos, d.curso_questoes, d.md5_curso_materias, d.md5_curso_conteudos, d.md5_classificacao_questoes) then
    raise exception 'TESTE: estrutura de curso ou classificação de questões alterada';
  end if;
  raise notice 'TESTE OK: AUSENTE -> APPLY -> TARGET -> REVERSAO -> AUSENTE; contagens e assinaturas iguais ao início';
end $$;

rollback;
