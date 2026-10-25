-- SEJUSP/MG 2022 Agente de Segurança Socioeducativo (Fundatec, concurso 687) — PÓS-CHECK da taxonomia aplicada em 2026-10-25
-- por manutencao_sejusp_2022_agente_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Ids REAIS (as sequências avançaram no teste de rollback; os ids do teste — 395–400 — não existem).
-- Nenhuma matéria nova; a Q57 reutiliza o assunto 388 (Probabilidade, matéria 40).
-- Uma linha por entidade (ok = false indica divergência) + uma linha de totais.

with esperado (id, materia_id, nome) as (
values
  (401::bigint, 11::bigint, 'SINASE (Lei 12.594/2012 e Resolução Conanda 119/2006)'),
  (402, 16, 'Estatuto dos Servidores Públicos Civis de MG (Lei 869/1952)'),
  (403, 16, 'Código de Conduta Ética do Agente Público de MG (Decreto 46.644/2014)'),
  (404, 3, 'Crimes de responsabilidade (Lei 1.079/1950)'),
  (405, 6, 'Funções da linguagem'),
  (406, 6, 'Tipologia textual'),
  (388, 40, 'Probabilidade')
)
select 'assunto' as tipo, e.id, e.nome,
       exists (select 1 from public.assuntos a where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null) as ok
  from esperado e
union all
select 'totais', null, '6 assuntos novos (401–406) e nenhum outro com id > 400; nenhum id do teste (395–400); 27 matérias',
       (select count(*) from public.assuntos where id > 400) = 6
       and not exists (select 1 from public.assuntos where id between 395 and 400)
       and (select count(*) from public.materias) = 27
order by 1, 2;
