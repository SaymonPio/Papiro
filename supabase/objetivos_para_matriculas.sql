-- Etapa 2 do isolamento de dados por curso: migração objetivos -> matriculas
-- e, em seguida, horas_diarias -> configuracoes_estudo.
--
-- Este arquivo, no estado atual, é SOMENTE DIAGNÓSTICO (apenas SELECTs, nada é escrito).
-- Os dois INSERTs de migração estão comentados, claramente identificados, e não devem
-- ser executados sem autorização explícita e revisão do diagnóstico abaixo.
--
-- Critério de correspondência (exato, não heurístico):
--   - concurso é o identificador principal e é OBRIGATÓRIO nos dois lados:
--       o.concurso is not null and c.concurso is not null and trim(o.concurso) = trim(c.concurso)
--   - cargo e banca usam comparação null-safe (podem ser NULL em qualquer um dos lados):
--       trim(o.cargo) is not distinct from trim(c.cargo)
--       trim(o.banca) is not distinct from trim(c.banca)
--   - Nenhuma normalização de acento/caixa é aplicada; só trim() de espaços.
--   - Linhas de objetivos sem correspondência exata permanecem intactas (não migradas).
--
-- Tabelas: public.objetivos é somente leitura (nunca alterada/apagada);
-- public.cursos é somente leitura; public.perfis não é tocada nesta etapa;
-- public.matriculas recebe INSERT apenas de (usuario_id, curso_id) — id, status, origem,
-- matriculado_em e expira_em ficam a cargo dos defaults reais da tabela;
-- public.configuracoes_estudo (ver supabase/configuracoes_estudo.sql) recebe horas_diarias,
-- associada à matrícula correspondente, e só depois que ela já existir.

-- 1) Diagnóstico: mostra cada objetivo e o curso correspondente encontrado (ou NULL, se nenhum).
select
  o.id as objetivo_id, o.usuario_id, o.concurso, o.cargo, o.banca,
  c.id as curso_id_encontrado, c.slug
from public.objetivos o
left join public.cursos c
  on o.concurso is not null
 and c.concurso is not null
 and trim(o.concurso) = trim(c.concurso)
 and trim(o.cargo) is not distinct from trim(c.cargo)
 and trim(o.banca) is not distinct from trim(c.banca)
order by c.id nulls first;

-- 2) Verificação de unicidade: confirma que o critério de correspondência não é ambíguo em cursos.
select concurso, cargo, banca, count(*)
from public.cursos
where concurso is not null
group by concurso, cargo, banca
having count(*) > 1;
-- deve retornar 0 linhas

-- =========================================================================
-- MIGRAÇÃO 1 — objetivos -> matriculas — NÃO EXECUTAR AINDA
-- Descomentar e executar somente após revisão do diagnóstico acima e
-- autorização explícita. Idempotente (seguro reexecutar): usa NOT EXISTS
-- para nunca duplicar uma matrícula já migrada (além da UNIQUE(usuario_id, curso_id)
-- já existente na tabela real), e nunca altera/apaga
-- public.objetivos, public.cursos ou public.perfis.
-- =========================================================================

-- with candidatos as (
--   select
--     o.usuario_id,
--     c.id as curso_id,
--     row_number() over (
--       partition by o.usuario_id, c.id
--       order by o.id desc
--     ) as posicao
--   from public.objetivos o
--   join public.cursos c
--     on o.concurso is not null
--    and c.concurso is not null
--    and trim(o.concurso) = trim(c.concurso)
--    and trim(o.cargo) is not distinct from trim(c.cargo)
--    and trim(o.banca) is not distinct from trim(c.banca)
-- )
-- insert into public.matriculas (usuario_id, curso_id)
-- select cand.usuario_id, cand.curso_id
-- from candidatos cand
-- where cand.posicao = 1
--   and not exists (
--     select 1 from public.matriculas m
--     where m.usuario_id = cand.usuario_id
--       and m.curso_id = cand.curso_id
--   );

-- 3) Diagnóstico da Migração 2: mostra, para cada objetivo com curso encontrado, qual
--    matrícula ATIVA (se houver) receberia a configuração de estudo, e com qual horas_diarias.
--    Matrículas com outro status (ex.: cancelada) não aparecem aqui.
select
  o.id as objetivo_id, o.usuario_id, o.concurso,
  m.id as matricula_id, m.status, o.horas_diarias
from public.objetivos o
join public.cursos c
  on o.concurso is not null
 and c.concurso is not null
 and trim(o.concurso) = trim(c.concurso)
 and trim(o.cargo) is not distinct from trim(c.cargo)
 and trim(o.banca) is not distinct from trim(c.banca)
join public.matriculas m
  on m.usuario_id = o.usuario_id
 and m.curso_id = c.id
 and m.status = 'ativa'
order by m.id;

-- =========================================================================
-- MIGRAÇÃO 2 — horas_diarias -> configuracoes_estudo — NÃO EXECUTAR AINDA
-- Só pode rodar DEPOIS da MIGRAÇÃO 1 acima (precisa que a matrícula já exista) e
-- depois que supabase/configuracoes_estudo.sql já tiver sido aplicado.
-- Só considera matrículas com status = 'ativa' — matrículas canceladas (ou em
-- qualquer outro status) nunca recebem configuracoes_estudo por esta migração,
-- e nunca são alteradas/apagadas.
-- Idempotente via NOT EXISTS. Nunca altera/apaga public.objetivos, public.cursos
-- ou public.matriculas.
-- =========================================================================

-- with candidatos as (
--   select
--     m.id as matricula_id,
--     o.horas_diarias,
--     row_number() over (partition by m.id order by o.id desc) as posicao
--   from public.objetivos o
--   join public.cursos c
--     on o.concurso is not null
--    and c.concurso is not null
--    and trim(o.concurso) = trim(c.concurso)
--    and trim(o.cargo) is not distinct from trim(c.cargo)
--    and trim(o.banca) is not distinct from trim(c.banca)
--   join public.matriculas m
--     on m.usuario_id = o.usuario_id
--    and m.curso_id = c.id
--    and m.status = 'ativa'
-- )
-- insert into public.configuracoes_estudo (matricula_id, horas_diarias)
-- select cand.matricula_id, cand.horas_diarias
-- from candidatos cand
-- where cand.posicao = 1
--   and not exists (
--     select 1 from public.configuracoes_estudo ce
--     where ce.matricula_id = cand.matricula_id
--   );
