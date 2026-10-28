-- PC-RS 2025 Delegado de Polícia — Prova Preambular P1 (Fundatec, concurso 991) — PÓS-CHECK da taxonomia aplicada em 2026-10-26
-- por manutencao_pcrs_2025_delegado_p1_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Id REAL (a sequência avançou no teste de rollback; o id do teste — 415 — não existe).
-- Nenhuma matéria nova; 1 assunto global na matéria 6 (Língua Portuguesa), usado pela Q39 do P1 (questão 4071, prova_partes.id = 8).
-- O assunto já existe: reexecutar a manutenção aborta na auditoria de equivalentes (nome normalizado), antes do INSERT.
-- Uma linha por entidade (ok = false indica divergência) + uma linha de totais.

with esperado (id, materia_id, nome) as (
values
  (416::bigint, 6::bigint, 'Adjunto adnominal')
)
select 'assunto' as tipo, e.id, e.nome,
       exists (select 1 from public.assuntos a join public.materias m on m.id = a.materia_id
                where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null
                  and m.nome = 'Língua Portuguesa' and m.usuario_id is null and m.ativo) as ok
  from esperado e
union all
select 'totais', null, '1 assunto novo (416) na matéria 6, único com esse nome; nenhum id do teste (415); Q39 do P1 (4071) classificada nele',
       (select count(*) from public.assuntos a
         where btrim(regexp_replace(lower(translate(a.nome, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g')) = 'adjunto adnominal') = 1
       and not exists (select 1 from public.assuntos where id = 415)
       and exists (select 1 from public.questoes q where q.id = 4071 and q.prova_parte_id = 8 and q.numero_original = 39 and q.materia_id = 6 and q.assunto_id = 416)
order by 1, 2;
