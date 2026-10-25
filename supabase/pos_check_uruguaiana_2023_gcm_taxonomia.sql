-- Uruguaiana/RS 2023 Guarda Civil Municipal (Fundatec, concurso 744) — PÓS-CHECK da taxonomia aplicada em 2026-10-25
-- por manutencao_uruguaiana_2023_gcm_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Ids REAIS (as sequências avançaram no teste de rollback; os ids do teste — 407–410 — não existem).
-- Nenhuma matéria nova. Uma linha por entidade (ok = false indica divergência) + uma linha de totais.

with esperado (id, materia_id, nome) as (
values
  (411::bigint, 22::bigint, 'Lei Orgânica do Município de Uruguaiana'),
  (412, 22, 'Regime Jurídico dos Servidores Públicos de Uruguaiana (LC 18/2018)'),
  (413, 22, 'Guarda Municipal de Uruguaiana (Lei 3.319/2004)'),
  (414, 22, 'Estrutura administrativa do Executivo de Uruguaiana (Lei 5.200/2021)')
)
select 'assunto' as tipo, e.id, e.nome,
       exists (select 1 from public.assuntos a where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null) as ok
  from esperado e
union all
select 'totais', null, '4 assuntos novos (411–414) na matéria 22; nenhum id do teste (407–410); 27 matérias',
       (select count(*) from public.assuntos where id between 411 and 414 and materia_id = 22) = 4
       and not exists (select 1 from public.assuntos where id between 407 and 410)
       and (select count(*) from public.materias) = 27
order by 1, 2;
