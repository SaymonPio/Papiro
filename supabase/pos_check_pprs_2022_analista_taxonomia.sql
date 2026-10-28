-- PP-RS 2022 Analista da Polícia Penal — Direito (Fundatec, concurso 650, cargo 6) — PÓS-CHECK da taxonomia aplicada em 2026-10-28
-- por manutencao_pprs_2022_analista_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Id REAL (a sequência avançou no teste de rollback; o id do teste — 417 — não existe).
-- Nenhuma matéria nova; 1 assunto global na matéria 33 (Direito Civil), usado pela Q61 do lote (questão 4095, provas.id = 42).
-- O assunto já existe: reexecutar a manutenção aborta na auditoria de equivalentes (nome normalizado), antes do INSERT.
-- Registro histórico (não verificado aqui): assuntos 237 -> 238 e matérias 27 -> 27 na aplicação.
-- Uma linha por entidade (ok = false indica divergência) + uma linha de totais.

with esperado (id, materia_id, nome) as (
values
  (418::bigint, 33::bigint, 'Direito das coisas (posse e propriedade)')
)
select 'assunto' as tipo, e.id, e.nome,
       exists (select 1 from public.assuntos a join public.materias m on m.id = a.materia_id
                where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null
                  and m.nome = 'Direito Civil' and m.usuario_id is null and m.ativo) as ok
  from esperado e
union all
select 'totais', null, '1 assunto novo (418) na matéria 33, único com esse nome; nenhum id do teste (417); Q61 do lote (4095) classificada nele',
       (select count(*) from public.assuntos a
         where btrim(regexp_replace(lower(translate(a.nome, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g')) = 'direito das coisas posse e propriedade') = 1
       and not exists (select 1 from public.assuntos where id = 417)
       and exists (select 1 from public.questoes q where q.id = 4095 and q.prova_id = 42 and q.numero_original = 61 and q.materia_id = 33 and q.assunto_id = 418)
order by 1, 2;
