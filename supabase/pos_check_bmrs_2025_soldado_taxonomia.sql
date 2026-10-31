-- BM-RS 2025 Soldado de Primeira Classe (Fundatec, concurso 976) — PÓS-CHECK da taxonomia aplicada em 2026-10-28
-- por manutencao_bmrs_2025_soldado_taxonomia.sql (rollback-testado antes). Somente leitura.
-- Id REAL (a sequência avançou no teste de rollback; o id do teste — 419 — não existe).
-- Nenhuma matéria nova; 1 assunto global na matéria 12 (Matemática), usado pela Q33 do lote (questão 4127, provas.id = 45).
-- O assunto já existe: reexecutar a manutenção aborta na auditoria de equivalentes (nome normalizado), antes do INSERT;
-- a reversão recusa enquanto a questão 4127 referenciar o assunto.
-- "Ativo" do assunto lido via to_jsonb: exigido se a coluna existir; sem a coluna, o assunto global é ativo por construção.
-- Registro histórico (não verificado aqui): assuntos 238 -> 239 e matérias 27 -> 27 na aplicação.
-- Uma linha por verificação (ok = false indica divergência).

with esperado (id, materia_id, nome) as (
values
  (420::bigint, 12::bigint, 'Equações do 1º grau')
),
norm as (
  select btrim(regexp_replace(lower(translate(p, 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc')), '[^a-z0-9]+', ' ', 'g')) as n, a.id
    from public.assuntos a, lateral (select a.nome as p) x
)
select 'assunto' as tipo, e.id, e.nome || ' (matéria 12 Matemática, global, ativo)' as verificacao,
       exists (select 1 from public.assuntos a join public.materias m on m.id = a.materia_id
                where a.id = e.id and a.nome = e.nome and a.materia_id = e.materia_id and a.usuario_id is null
                  and coalesce((to_jsonb(a) ->> 'ativo')::boolean, true)
                  and m.id = 12 and m.nome = 'Matemática' and m.usuario_id is null and m.ativo) as ok
  from esperado e
union all
select 'unicidade', null, 'nome normalizado "' || (select n from norm where id = 420) || '" único em assuntos (globais e de usuário)',
       (select count(*) from norm where n = (select n from norm where id = 420)) = 1
union all
select 'teste', 419, 'id consumido pelo teste de rollback (419) não existe',
       not exists (select 1 from public.assuntos where id = 419)
union all
select 'questao', 4127, 'Q33 da prova 45 (questão 4127) classificada em matéria 12 / assunto 420',
       exists (select 1 from public.questoes q where q.id = 4127 and q.prova_id = 45 and q.numero_original = 33 and q.materia_id = 12 and q.assunto_id = 420)
order by 1, 2;
