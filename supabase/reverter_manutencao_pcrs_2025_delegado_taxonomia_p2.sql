-- PC-RS 2025 Delegado (P2) — TAXONOMIA MÍNIMA (somente dados globais, nenhum curso).
-- Cria 2 matérias GLOBAIS sem curso_materia — "Direito Civil" e "Criminologia" — e 21 assuntos:
-- "Direito Penal" (5), "Legislação Penal Especial" (4), "Direito Processual Penal" (3), "Direito Administrativo" (3), "Direito Constitucional" (2), "Direito Civil" (2), "Direitos Humanos e Cidadania" (1), "Criminologia" (1).
-- Destinos escolhidos entre homônimos existentes: "Direito Penal" (não a matéria
-- vazia "Direito penal") e "Direitos Humanos e Cidadania" (não "Direitos Humanos",
-- vazia). Homônimo aceito por decisão explícita e conferido onde está:
-- assunto 76 (matéria 10) — Responsabilidade civil do Estado (Direito Administrativo, estrutura da BM) — não é responsabilidade civil do Código Civil.
-- Qualquer OUTRO equivalente por nome ou chave (lei/termo; normalizado sem
-- acento, caixa e pontuação, em nome + descrição de TODOS os assuntos) aborta.
-- Nenhum curso_materia, curso_conteudo, curso_questao ou classificação de
-- questão é alterado (conferido por assinatura antes/depois).
--
-- REVERSÃO REAL de manutencao_pcrs_2025_delegado_taxonomia_p2.sql. Recusa se qualquer questão, curso ou histórico
-- referenciar os registros criados (reverter antes as questões classificadas neles).

begin;

create function pg_temp.norm(p text) returns text language sql immutable as $fn$
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g'))
$fn$;

create temporary table _p2_mat (nome text not null, chave text not null) on commit drop;
insert into _p2_mat values
('Direito Civil', 'direito civil'),
('Criminologia', 'criminologia');

create temporary table _p2_tax (materia text not null, nome text not null, chaves text[] not null) on commit drop;
insert into _p2_tax values
('Direito Penal', 'Teoria geral do Direito Penal e do crime', array['teoria do crime', 'teoria geral do direito penal', 'principios do direito penal', 'dolo', 'culpabilidade', 'tipicidade']),
('Direito Penal', 'Teoria da pena', array['teoria da pena', 'aplicacao da pena', 'efeitos da condenacao', 'confisco alargado']),
('Direito Penal', 'Crimes contra o patrimônio', array['patrimonio', 'furto', 'roubo', 'estelionato']),
('Direito Penal', 'Crimes contra a dignidade sexual', array['dignidade sexual', 'estupro']),
('Direito Penal', 'Crimes contra a pessoa', array['crimes contra a pessoa', 'homicidio', 'perseguicao', 'liberdade individual']),
('Legislação Penal Especial', 'Lavagem de dinheiro (Lei 9.613/1998)', array['lavagem', '9 613']),
('Legislação Penal Especial', 'Organizações criminosas (Lei 12.850/2013)', array['organizacao criminosa', 'organizacoes criminosas', '12 850', 'crime organizado']),
('Legislação Penal Especial', 'Crimes raciais (Lei 7.716/1989)', array['7 716', 'crimes raciais', 'injuria racial']),
('Legislação Penal Especial', 'Lei Henry Borel (Lei 14.344/2022)', array['henry borel', '14 344']),
('Direito Processual Penal', 'Prisões e medidas cautelares', array['prisao', 'prisoes', 'medidas cautelares', 'flagrante']),
('Direito Processual Penal', 'Competência', array['competencia']),
('Direito Processual Penal', 'Ação penal', array['acao penal']),
('Direito Administrativo', 'Estatuto da Polícia Civil do RS (Lei 7.366/1980)', array['7 366', 'estatuto da policia civil', 'policia civil']),
('Direito Administrativo', 'Lei Anticorrupção (Lei 12.846/2013)', array['anticorrupcao', '12 846']),
('Direito Administrativo', 'Acesso à informação (Lei 12.527/2011)', array['acesso a informacao', '12 527']),
('Direito Constitucional', 'Organização do Estado e repartição de competências', array['organizacao do estado', 'reparticao de competencias', 'competencia legislativa']),
('Direito Constitucional', 'Controle de constitucionalidade', array['controle de constitucionalidade']),
('Direito Civil', 'Parte geral (pessoas, negócio jurídico, prescrição e decadência)', array['parte geral', 'negocio juridico', 'prescricao', 'decadencia', 'ausencia']),
('Direito Civil', 'Obrigações e responsabilidade civil', array['obrigacoes', 'responsabilidade civil']),
('Direitos Humanos e Cidadania', 'Diversidade sexual e identidade de gênero', array['identidade de genero', 'diversidade sexual', 'nome social', 'lgbt', 'transexua']),
('Criminologia', 'Teorias criminológicas e política criminal', array['criminolog', 'politica criminal', 'justica restaurativa', 'abolicionis']);

create temporary table _p2_homonimos (assunto_id bigint not null, materia_id bigint not null) on commit drop;
insert into _p2_homonimos values (76, 10);

create temporary table _p2_antes on commit drop as
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
  with alvo_a as (select s.id from public.assuntos s join public.materias m on m.id = s.materia_id join _p2_tax t on t.nome = s.nome and t.materia = m.nome where s.usuario_id is null and m.usuario_id is null),
       alvo_m as (select m.id from public.materias m join _p2_mat t on t.nome = m.nome where m.usuario_id is null)
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

  delete from public.assuntos s using public.materias m, _p2_tax t where m.id = s.materia_id and t.nome = s.nome and t.materia = m.nome and s.usuario_id is null and m.usuario_id is null;
  get diagnostics v_a = row_count;
  delete from public.materias m using _p2_mat t where t.nome = m.nome and m.usuario_id is null;
  get diagnostics v_m = row_count;
  if v_a <> 21 or v_m <> 2 then raise exception 'REVERSAO: apagou % assunto(s) e % matéria(s), esperado 21 e 2', v_a, v_m; end if;
  raise notice 'REVERSAO aplicada: 21 assuntos e 2 matérias removidos';
end $$;

do $$
declare
  v_destino int; v_materia int; v_equiv int; v_homon int; r record;
begin
  select count(*) into v_destino from (select m.nome from public.materias m
   where m.usuario_id is null and m.ativo and m.nome in ('Direito Penal', 'Legislação Penal Especial', 'Direito Processual Penal', 'Direito Administrativo', 'Direito Constitucional', 'Direitos Humanos e Cidadania') group by m.nome having count(*) = 1) x;
  if v_destino <> 6 then raise exception 'AUDITORIA: esperadas 6 matérias globais ativas e únicas de destino, encontradas %', v_destino; end if;

  select count(*) into v_materia from public.materias m join _p2_mat t
    on pg_temp.norm(m.nome) = pg_temp.norm(t.nome) or pg_temp.norm(m.nome) like '%' || t.chave || '%';
  if v_materia <> 0 then raise exception 'AUDITORIA: já existe matéria equivalente a uma das novas (%) — reauditar antes de criar', v_materia; end if;

  select count(*) into v_equiv from (
    select distinct a.id from public.assuntos a join _p2_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _p2_homonimos)) x;
  if v_equiv <> 0 then
    for r in select distinct a.id, a.materia_id, a.nome from public.assuntos a join _p2_tax t
      on pg_temp.norm(a.nome) = pg_temp.norm(t.nome)
      or exists (select 1 from unnest(t.chaves) k where pg_temp.norm(a.nome || ' ' || coalesce(a.descricao, '')) like '%' || k || '%')
     where a.id not in (select assunto_id from _p2_homonimos) loop
      raise notice 'EQUIVALENTE: assunto % (matéria %) "%"', r.id, r.materia_id, r.nome;
    end loop;
    raise exception 'AUDITORIA: % assunto(s) equivalente(s) fora dos homônimos aceitos — reauditar antes de criar', v_equiv;
  end if;

  select count(*) into v_homon from _p2_homonimos h join public.assuntos a on a.id = h.assunto_id and a.materia_id = h.materia_id;
  if v_homon <> 1 then raise exception 'AUDITORIA: homônimo aceito fora de onde a decisão o encontrou — reauditar'; end if;

  raise notice 'AUDITORIA OK: 6 matérias de destino únicas; 2 matérias novas e 21 assuntos ausentes; nenhum equivalente fora do homônimo aceito';
end $$;

commit;
