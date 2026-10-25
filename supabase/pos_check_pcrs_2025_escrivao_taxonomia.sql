-- PC-RS 2025 Escrivão e Inspetor de Polícia (Fundatec, concurso 993) — PÓS-CHECK da taxonomia aplicada em 2026-10-25
-- por manutencao_pcrs_2025_escrivao_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Ids REAIS (as sequências avançaram no teste de rollback; os ids do teste — 37/38, 367–380 — não existem).
-- Uma linha por entidade (ok = false indica divergência) + uma linha de totais.

with esperado (tipo, id, materia_id, nome) as (
values
  ('materia', 39, null::bigint, 'Contabilidade'),
  ('materia', 40, null, 'Estatística'),
  ('assunto', 381, 39, 'Estoques e CMV'),
  ('assunto', 382, 39, 'Depreciação'),
  ('assunto', 383, 39, 'Demonstração dos Fluxos de Caixa'),
  ('assunto', 384, 39, 'Lançamentos e balancete'),
  ('assunto', 385, 39, 'Receitas e despesas'),
  ('assunto', 386, 40, 'Estatística descritiva'),
  ('assunto', 387, 40, 'Inferência / testes de hipóteses'),
  ('assunto', 388, 40, 'Probabilidade'),
  ('assunto', 389, 40, 'Correlação e regressão'),
  ('assunto', 390, 9, 'Linux'),
  ('assunto', 391, 8, 'Crimes de trânsito'),
  ('assunto', 392, 7, 'Princípios da lei processual penal'),
  ('assunto', 393, 16, 'LGPD'),
  ('assunto', 394, 16, 'Lei Orgânica Nacional das Polícias Civis')
)
select e.tipo, e.id, e.nome,
       case e.tipo
         when 'materia' then exists (select 1 from public.materias m where m.id = e.id and m.nome = e.nome and m.usuario_id is null and m.ativo)
         else exists (select 1 from public.assuntos a where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null)
       end as ok
  from esperado e
union all
select 'totais', null, 'matérias 39/40 com exatamente os 9 assuntos novos; 16 entidades presentes',
       (select count(*) from public.assuntos where materia_id in (39, 40)) = 9
       and (select count(*) from public.materias where nome in ('Contabilidade', 'Estatística')) = 2
order by 1, 2;
