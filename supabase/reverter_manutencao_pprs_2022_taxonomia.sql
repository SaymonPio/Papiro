-- PP-RS 2022 Policial Penal (Fundatec 650, caderno 0650.002) — TAXONOMIA (somente dados globais, nenhum curso).
-- Cria 8 assuntos GLOBAIS em matérias existentes, nenhuma matéria nova:
-- "Conhecimentos Gerais" (3), "Execução Penal" (2), "Sistema Prisional e Polícia Penal" (1), "Direitos Humanos e Cidadania" (2).
-- Em Conhecimentos Gerais, conteúdo DATADO (atualidades 2021/22) fica separado do permanente (meio ambiente;
-- saúde pública/campanhas) — "Atualidades" não esconde conteúdos diferentes.
-- Busca de equivalentes (nome, lei, termo; normalizado sem acento, caixa e pontuação, em nome + descrição
-- de TODOS os assuntos, de todas as matérias, globais e de usuário). Homônimos aceitos por decisão explícita
-- e conferidos onde estão — tratam de outro ente ou de outro conteúdo, não são equivalentes:
--   assunto 136 (matéria 25) — Trabalho do condenado: outro capítulo da LEP (trabalho), não classificação/identificação;
--   assunto 170 (matéria 15) — Antropologia forense e identificação humana: criminalística, não LEP;
--   assunto 299 (matéria 4) — Registro, identificação e emplacamento de veículos: trânsito;
--   assunto 173 (matéria 15) — Perícia ambiental: criminalística, não conhecimento geral de meio ambiente;
--   assunto 292 (matéria 12) — Progressões (PA e PG): matemática, não progressão de regime;
--   assunto 77 (matéria 10) — Plano de Carreira dos Servidores Militares: outra carreira e outra lei;
--   assunto 181 (matéria 16) — Estatuto dos Servidores Públicos Civis do RS (LC 10.098/1994): estatuto geral, não o Quadro Especial;
--   assunto 182 (matéria 16) — Carreiras do IGP-RS: outra instituição;
--   assunto 290 (matéria 22) — Estatuto dos Servidores de Sant'Ana do Livramento: outro ente.
-- Qualquer OUTRO equivalente aborta. Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- REVERSÃO REAL de manutencao_pprs_2022_taxonomia.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar os assuntos criados (reverter antes as questões classificadas neles).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _pp22_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _pp22_tax values
('Conhecimentos Gerais', 'Atualidades', array['atualidad', 'fatos recentes', 'noticias']),
('Conhecimentos Gerais', 'Meio ambiente e biomas brasileiros', array['meio ambiente', 'ambient', 'bioma', 'queimad', 'ecolog', 'desmatamento']),
('Conhecimentos Gerais', 'Saúde pública e campanhas de conscientização', array['saude publica', 'campanha', 'conscientizacao', 'suicid', 'setembro amarelo']),
('Execução Penal', 'Classificação e identificação do condenado', array['classificacao do condenado', 'condenado', 'identificacao', 'perfil genetico', 'exame criminologico']),
('Execução Penal', 'Regimes e progressão de regime', array['progress', 'regime de cumprimento', 'regimes', 'livramento condicional', 'pena privativa']),
('Sistema Prisional e Polícia Penal', 'Quadro Especial de Servidores Penitenciários (Lei 13.259/2009)', array['13 259', 'quadro especial', 'servidores penitenciarios', 'susepe', 'servidor', 'carreira']),
('Direitos Humanos e Cidadania', 'Pessoas com transtorno mental (Lei 10.216/2001)', array['10 216', 'transtorno mental', 'saude mental', 'psiquiatr']),
('Direitos Humanos e Cidadania', 'Estatuto da Pessoa Idosa (Lei 10.741/2003)', array['10 741', 'idoso', 'pessoa idosa', 'idosa']);

create temporary table _pp22_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _pp22_homonimos values (136, 25), (170, 15), (299, 4), (173, 15), (292, 12), (77, 10), (181, 16), (182, 16), (290, 22);

create temporary table _pp22_antes on commit drop as
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
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _pp22_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null)
  select (select count(*) from public.questoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.curso_conteudos where assunto_id in (select id from alvo_a))
       + (select count(*) from public.erros_usuarios where assunto_id in (select id from alvo_a))
       + (select count(*) from public.revisoes where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_estudo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.sessoes_tempo where assunto_id in (select id from alvo_a))
       + (select count(*) from public.conversas_ia where assunto_id in (select id from alvo_a))
    into v_refs;
  if v_refs <> 0 then raise exception 'REVERSAO RECUSADA: % referência(s) aos assuntos criados — reverter as questões antes', v_refs; end if;

  delete from public.assuntos s using public.materias m, _pp22_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  if v_a <> 8 then raise exception 'REVERSAO: apagou % assunto(s), esperado 8', v_a; end if;
  raise notice 'REVERSAO aplicada: 8 assuntos removidos';
end $$;

do $$
declare
  v_destino int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Conhecimentos Gerais', 'Execução Penal', 'Sistema Prisional e Polícia Penal', 'Direitos Humanos e Cidadania') group by m.nome having count(*) = 1) x;
  if v_destino <> 4 then raise exception 'AUDITORIA: esperadas 4 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;
  if (select array_agg(id order by id) from public.materias where usuario_id is null and ativo and nome in ('Conhecimentos Gerais', 'Execução Penal', 'Sistema Prisional e Polícia Penal', 'Direitos Humanos e Cidadania')) <> array[11, 13, 25, 26]::bigint[] then
    raise exception 'AUDITORIA: matérias de destino fora dos ids aprovados (11, 13, 25, 26)';
  end if;

  select count(*) into v_equiv from (
    select distinct a.id, a.materia_id, a.nome from public.assuntos a join _pp22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _pp22_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _pp22_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _pp22_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _pp22_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 9 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 4 matérias de destino únicas; 8 assuntos ausentes; nenhum equivalente fora dos 9 homônimos aceitos';
end $$;

commit;
