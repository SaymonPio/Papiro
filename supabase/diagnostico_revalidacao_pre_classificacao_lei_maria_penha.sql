-- ETAPA 1 do PROMPT MESTRE de curadoria das unidades pedagógicas da Lei
-- Maria da Penha — revalidação do estado ANTES de qualquer classificação.
--
-- SOMENTE LEITURA. Nenhum INSERT/UPDATE/DELETE.
--
-- Confere, em produção, tudo que a fase de classificação assume como
-- verdadeiro:
--   - curso_conteudos.id = 53 existe e é mesmo a Lei Maria da Penha;
--   - as 5 unidades pedagógicas oficiais existem com id/ordem/título
--     corretos (escopo comparado por igualdade normalizada — trim +
--     minúsculas + espaços colapsados — para não falhar por diferença
--     cosmética de espaçamento/quebra de linha em relação ao texto
--     fornecido);
--   - exatamente 28 questões ativas são candidatas
--     (mesma definição de sempre: ativa=true, materia_id da questão bate
--     com a matéria real do conteúdo 53, assunto_id bate quando o
--     conteúdo tiver um definido);
--   - 738/863/864/865 continuam ativa=false;
--   - nenhuma das 28 candidatas já tem vínculo em
--     questao_unidades_pedagogicas para uma unidade do conteúdo 53.
--
-- Cole no SQL Editor do Supabase e rode. Resultado: 1 linha por
-- verificação-chave + linhas de detalhe para conferência visual.

-- ============================================================================
-- 1) curso_conteudos 53 + matéria/assunto reais.
-- ============================================================================
select
  cc.id as conteudo_id,
  cm.materia_id,
  m.nome as materia_nome,
  cc.assunto_id,
  a.nome as assunto_nome
from public.curso_conteudos cc
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.materias m on m.id = cm.materia_id
left join public.assuntos a on a.id = cc.assunto_id
where cc.id = 53;

-- ============================================================================
-- 2) As 5 unidades oficiais — id, ordem, título, escopo, artigos_esperados,
--    ativa, comparados com os valores esperados do prompt mestre.
-- ============================================================================
with esperado (unidade_id, ordem_esperada, titulo_esperado) as (
  values
    ('e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'Fundamentos e campo de aplicação'),
    ('ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'Prevenção e assistência à mulher'),
    ('4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'Atendimento policial e providências imediatas'),
    ('7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid, 4, 'Procedimentos e medidas protetivas de urgência'),
    ('53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, 5, 'Rede de justiça, equipe multidisciplinar e disposições finais')
)
select
  e.unidade_id,
  e.ordem_esperada,
  u.ordem as ordem_real,
  (u.ordem = e.ordem_esperada) as ordem_ok,
  e.titulo_esperado,
  u.titulo as titulo_real,
  (regexp_replace(lower(btrim(u.titulo)), '\s+', ' ', 'g') = regexp_replace(lower(btrim(e.titulo_esperado)), '\s+', ' ', 'g')) as titulo_ok,
  u.escopo,
  u.artigos_esperados,
  u.ativa,
  u.curso_conteudo_id,
  (u.curso_conteudo_id = 53) as pertence_ao_conteudo_53
from esperado e
left join public.unidades_pedagogicas u on u.id = e.unidade_id
order by e.ordem_esperada;

-- ============================================================================
-- 3) Total de questões ATIVAS candidatas para o conteúdo 53 — esperado 28.
-- ============================================================================
select count(*) as questoes_ativas_candidatas
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

-- ============================================================================
-- 4) 738/863/864/865 — confirma ativa=false nas 4.
-- ============================================================================
select id as questao_id, ativa, materia_id, assunto_id
from public.questoes
where id in (738, 863, 864, 865)
order by id;

-- ============================================================================
-- 5) Classificações já existentes para as 28 candidatas nas unidades do
--    conteúdo 53 — esperado 0 linhas.
-- ============================================================================
select qup.questao_id, qup.unidade_pedagogica_id, u.ordem, u.titulo
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 53
  and qup.questao_id in (
    select q.id
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 53
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );

-- ============================================================================
-- 6) RESUMO booleano — cada linha depende só dos fatos acima.
-- ============================================================================
with esperado (unidade_id, ordem_esperada, titulo_esperado) as (
  values
    ('e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'Fundamentos e campo de aplicação'),
    ('ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'Prevenção e assistência à mulher'),
    ('4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'Atendimento policial e providências imediatas'),
    ('7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid, 4, 'Procedimentos e medidas protetivas de urgência'),
    ('53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, 5, 'Rede de justiça, equipe multidisciplinar e disposições finais')
),
unidades_check as (
  select
    e.unidade_id,
    (u.id is not null) as existe,
    (u.ordem = e.ordem_esperada) as ordem_ok,
    (regexp_replace(lower(btrim(u.titulo)), '\s+', ' ', 'g') = regexp_replace(lower(btrim(e.titulo_esperado)), '\s+', ' ', 'g')) as titulo_ok,
    (u.curso_conteudo_id = 53) as conteudo_ok
  from esperado e
  left join public.unidades_pedagogicas u on u.id = e.unidade_id
),
candidatas as (
  select count(*) as total
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
),
inativas as (
  select bool_and(ativa is false) as ok
  from public.questoes
  where id in (738, 863, 864, 865)
),
classificacoes_previas as (
  select count(*) as total
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 53
    and qup.questao_id in (
      select q.id
      from public.questoes q
      join public.curso_conteudos cc on cc.id = 53
      join public.curso_materias cm on cm.id = cc.curso_materia_id
      where q.ativa = true
        and q.materia_id = cm.materia_id
        and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
    )
)
select
  (exists (select 1 from public.curso_conteudos where id = 53)) as conteudo_53_existe,
  (select bool_and(existe and ordem_ok and titulo_ok and conteudo_ok) from unidades_check) as cinco_unidades_ok,
  (select total from candidatas) = 28 as total_candidatas_e_28,
  (select ok from inativas) as inativas_738_863_864_865_ok,
  (select total from classificacoes_previas) = 0 as sem_classificacao_previa_ok,
  (
    (exists (select 1 from public.curso_conteudos where id = 53))
    and (select bool_and(existe and ordem_ok and titulo_ok and conteudo_ok) from unidades_check)
    and (select total from candidatas) = 28
    and (select ok from inativas)
    and (select total from classificacoes_previas) = 0
  ) as tudo_ok;
