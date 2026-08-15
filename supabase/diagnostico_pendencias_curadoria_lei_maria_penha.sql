-- Diagnóstico READ-ONLY das 2 pendências levantadas antes de classificar as
-- 32 questões candidatas da Lei Maria da Penha (curso_conteudos.id = 53) por
-- unidade pedagógica:
--   A) questão 738 — possível assunto errado (Lei 14.344/2022 / violência
--      doméstica contra criança e adolescente, não Lei Maria da Penha);
--   B) possíveis duplicatas dentro das 32 candidatas, incluindo os pares já
--      suspeitos: 129/864, 133/865, 134/863, 780/802.
--
-- SOMENTE SELECT. Nenhuma instrução deste arquivo escreve em nada — nenhum
-- INSERT/UPDATE/DELETE, nenhuma alteração de assunto_id, nenhuma questão
-- desativada, nenhuma classificação de unidade. As buscas por palavra-chave
-- abaixo (seções A2 e C) são só PISTAS VISUAIS para leitura humana — mesmo
-- princípio já usado na coluna pista_primeiro_artigo_citado de
-- diagnostico_questoes_lei_maria_penha.sql — nunca uma decisão automática.
--
-- "Candidata" = mesma definição usada nos diagnósticos anteriores desta
-- fase: questão ATIVA cuja materia_id bate com a matéria real do conteúdo
-- 53 (via curso_conteudos -> curso_materias) e, quando o conteúdo tiver
-- assunto_id definido, cujo assunto_id também bate.
--
-- Cole no SQL Editor do Supabase; cada bloco é uma consulta independente —
-- rode um de cada vez (ou o script inteiro, conforme o editor mostrar os
-- resultados).

-- ============================================================================
-- A1) Questão 738 — dados completos + matéria/assunto atuais + alternativas.
-- ============================================================================
select
  q.id as questao_id,
  q.enunciado,
  q.materia_id,
  q.assunto_id,
  m.nome as materia_nome,
  a.nome as assunto_nome_atual,
  q.banca,
  q.concurso,
  q.ano,
  q.dificuldade,
  q.ativa,
  (
    select jsonb_agg(
             jsonb_build_object('ordem', alt.ordem, 'texto', alt.texto, 'correta', alt.correta)
             order by alt.ordem
           )
    from public.alternativas alt
    where alt.questao_id = q.id
  ) as alternativas
from public.questoes q
left join public.materias m on m.id = q.materia_id
left join public.assuntos a on a.id = q.assunto_id
where q.id = 738;

-- ============================================================================
-- A2) Assuntos já cadastrados no banco cujo nome sugere Lei 14.344/2022 /
--     ECA / violência doméstica contra criança e adolescente — busca por
--     palavra-chave em TODO o cadastro de assuntos (não só na matéria do
--     conteúdo 53), só para conferência manual. Não altera a questão 738
--     nem nada mais; é só um levantamento do que já existe para escolher.
-- ============================================================================
select
  a.id as assunto_id,
  a.nome as assunto_nome,
  a.materia_id,
  m.nome as materia_nome
from public.assuntos a
join public.materias m on m.id = a.materia_id
where a.nome ilike '%14.344%'
   or a.nome ilike '%14344%'
   or a.nome ilike '%estatuto da crian%'
   or a.nome ilike '%crianca%'
   or a.nome ilike '%criança%'
   or a.nome ilike '%adolescente%'
   or a.nome ilike '%eca%'
order by m.nome, a.nome;

-- ============================================================================
-- B1) Base das 32 candidatas (com enunciado normalizado: trim + minúsculas +
--     espaços colapsados) — usada pelos blocos seguintes.
-- ============================================================================
with candidatas as (
  select
    q.id as questao_id,
    q.enunciado,
    regexp_replace(lower(btrim(q.enunciado)), '\s+', ' ', 'g') as enunciado_normalizado,
    q.banca,
    q.concurso,
    q.ano
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
)
select questao_id, banca, concurso, ano, enunciado
from candidatas
order by questao_id;

-- ============================================================================
-- B2) Grupos de duplicatas EXATAS entre as 32 candidatas — enunciado
--     idêntico depois de normalizar (trim + minúsculas + espaços
--     colapsados). Cobre TODAS as 32, não só os 4 pares já suspeitos.
-- ============================================================================
with candidatas as (
  select
    q.id as questao_id,
    q.enunciado,
    regexp_replace(lower(btrim(q.enunciado)), '\s+', ' ', 'g') as enunciado_normalizado
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
)
select
  enunciado_normalizado,
  array_agg(questao_id order by questao_id) as questao_ids_no_grupo,
  count(*) as quantidade_no_grupo
from candidatas
group by enunciado_normalizado
having count(*) > 1
order by quantidade_no_grupo desc, enunciado_normalizado;

-- ============================================================================
-- B3) Detalhe completo (enunciado/banca/concurso/ano/alternativas) de cada
--     questão que pertence a algum grupo de duplicata exata do B2 — para
--     leitura lado a lado.
-- ============================================================================
with candidatas as (
  select
    q.id as questao_id,
    q.enunciado,
    regexp_replace(lower(btrim(q.enunciado)), '\s+', ' ', 'g') as enunciado_normalizado,
    q.banca,
    q.concurso,
    q.ano
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
),
grupos_exatos as (
  select enunciado_normalizado
  from candidatas
  group by enunciado_normalizado
  having count(*) > 1
)
select
  c.questao_id,
  c.enunciado,
  c.banca,
  c.concurso,
  c.ano,
  (
    select jsonb_agg(
             jsonb_build_object('ordem', alt.ordem, 'texto', alt.texto, 'correta', alt.correta)
             order by alt.ordem
           )
    from public.alternativas alt
    where alt.questao_id = c.questao_id
  ) as alternativas
from candidatas c
join grupos_exatos ge on ge.enunciado_normalizado = c.enunciado_normalizado
order by ge.enunciado_normalizado, c.questao_id;

-- ============================================================================
-- B4) Os 4 pares já suspeitos, lado a lado, com um booleano objetivo
--     indicando se os enunciados são EXATAMENTE iguais (depois de
--     normalizar) ou apenas semelhantes — a leitura final de "são a mesma
--     questão" continua humana; isto só automatiza a comparação de texto.
-- ============================================================================
with pares_suspeitos (par, questao_a_id, questao_b_id) as (
  values
    (1, 129::bigint, 864::bigint),
    (2, 133::bigint, 865::bigint),
    (3, 134::bigint, 863::bigint),
    (4, 780::bigint, 802::bigint)
)
select
  ps.par,
  qa.id as questao_a_id,
  qa.enunciado as questao_a_enunciado,
  qa.banca as questao_a_banca,
  qa.concurso as questao_a_concurso,
  qa.ano as questao_a_ano,
  qb.id as questao_b_id,
  qb.enunciado as questao_b_enunciado,
  qb.banca as questao_b_banca,
  qb.concurso as questao_b_concurso,
  qb.ano as questao_b_ano,
  (
    regexp_replace(lower(btrim(qa.enunciado)), '\s+', ' ', 'g')
    = regexp_replace(lower(btrim(qb.enunciado)), '\s+', ' ', 'g')
  ) as enunciados_exatamente_iguais,
  (
    select jsonb_agg(
             jsonb_build_object('ordem', alt.ordem, 'texto', alt.texto, 'correta', alt.correta)
             order by alt.ordem
           )
    from public.alternativas alt
    where alt.questao_id = qa.id
  ) as alternativas_a,
  (
    select jsonb_agg(
             jsonb_build_object('ordem', alt.ordem, 'texto', alt.texto, 'correta', alt.correta)
             order by alt.ordem
           )
    from public.alternativas alt
    where alt.questao_id = qb.id
  ) as alternativas_b
from pares_suspeitos ps
join public.questoes qa on qa.id = ps.questao_a_id
join public.questoes qb on qb.id = ps.questao_b_id
order by ps.par;

-- ============================================================================
-- B5) Possíveis duplicatas de CONTEÚDO entre TODAS as 32 candidatas — não só
--     os 4 pares já suspeitos do B4. Comparação aproximada por sobreposição
--     de palavras relevantes do enunciado, SEM depender de nenhuma extensão
--     opcional (pg_trgm/fuzzystrmatch) — só regex/funções padrão do
--     PostgreSQL. Isto é SOMENTE UMA PISTA para leitura humana, nunca uma
--     decisão automática de duplicata — mesmo princípio do A2/C.
--
--     Método (índice de Jaccard sobre palavras "relevantes" do enunciado):
--       1. minúsculas;
--       2. remove tudo que não é letra/dígito/espaço (tira pontuação);
--       3. colapsa espaços;
--       4. separa em palavras;
--       5. descarta palavras com 3 caracteres ou menos (artigos/
--          preposições/conjunções curtas: "de", "da", "em", "com" etc.);
--       6. cada questão vira um CONJUNTO (sem repetição) dessas palavras;
--       7. similaridade = |interseção| / |união| dos dois conjuntos.
--     (passo 2 depende do lc_ctype do banco classificar corretamente letra
--     acentuada como alfanumérica — no Supabase, com locale UTF-8, isso já
--     funciona; se a lista de palavras vier estranha, é o primeiro lugar a
--     checar.)
--
--     LIMIAR = 0,35 (cada par de questoes_a_id < questao_b_id só aparece se
--     a similaridade for >= a este valor) — ajuste este número (nas duas
--     ocorrências, aqui e no bloco C mais abaixo) se quiser uma rede mais
--     larga ou mais estreita; abaixo de ~0,35 o ruído de vocabulário
--     jurídico comum ("violência", "doméstica", "mulher", "medida",
--     "protetiva"...) tende a dominar sem significar duplicata de verdade.
-- ============================================================================
with candidatas as (
  select
    q.id as questao_id,
    q.enunciado,
    q.banca,
    q.concurso,
    q.ano
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
),
palavras as (
  select distinct
    c.questao_id,
    palavra
  from candidatas c
  cross join lateral regexp_split_to_table(
    regexp_replace(
      regexp_replace(lower(c.enunciado), '[^[:alnum:]\s]', ' ', 'g'),
      '\s+', ' ', 'g'
    ),
    ' '
  ) as palavra
  where length(palavra) > 3
),
totais as (
  select questao_id, count(*) as total_palavras
  from palavras
  group by questao_id
),
pares as (
  select
    pa.questao_id as questao_a_id,
    pb.questao_id as questao_b_id,
    count(*) as intersecao
  from palavras pa
  join palavras pb
    on pa.palavra = pb.palavra
   and pa.questao_id < pb.questao_id
  group by pa.questao_id, pb.questao_id
),
grupos_exatos as (
  select array_agg(questao_id order by questao_id) as questao_ids_no_grupo
  from (
    select
      questao_id,
      regexp_replace(lower(btrim(enunciado)), '\s+', ' ', 'g') as enunciado_normalizado
    from candidatas
  ) x
  group by enunciado_normalizado
  having count(*) > 1
)
select
  p.questao_a_id,
  p.questao_b_id,
  ca.enunciado as enunciado_a,
  cb.enunciado as enunciado_b,
  ca.banca as banca_a, ca.concurso as concurso_a, ca.ano as ano_a,
  cb.banca as banca_b, cb.concurso as concurso_b, cb.ano as ano_b,
  round(
    p.intersecao::numeric / nullif(ta.total_palavras + tb.total_palavras - p.intersecao, 0),
    4
  ) as similaridade_jaccard,
  exists (
    select 1 from grupos_exatos ge
    where p.questao_a_id = any(ge.questao_ids_no_grupo)
      and p.questao_b_id = any(ge.questao_ids_no_grupo)
  ) as ja_e_duplicata_exata_b2
from pares p
join candidatas ca on ca.questao_id = p.questao_a_id
join candidatas cb on cb.questao_id = p.questao_b_id
join totais ta on ta.questao_id = p.questao_a_id
join totais tb on tb.questao_id = p.questao_b_id
where (p.intersecao::numeric / nullif(ta.total_palavras + tb.total_palavras - p.intersecao, 0)) >= 0.35
order by similaridade_jaccard desc, p.questao_a_id, p.questao_b_id;

-- ============================================================================
-- C) RESUMO — total de candidatas, pista de assunto incorreto (keyword,
--    nunca decisão automática), grupos de duplicata EXATA (B2) e pares
--    suspeitos de duplicata por SIMILARIDADE de conteúdo (B5) — contados
--    SEPARADAMENTE: um grupo exato pode conter 2+ questões (1 grupo), já
--    pares_suspeitos_similares_encontrados conta PARES (a mesma questão
--    pode aparecer em mais de um par). Um número não substitui o outro.
-- ============================================================================
with candidatas as (
  select
    q.id as questao_id,
    q.enunciado,
    regexp_replace(lower(btrim(q.enunciado)), '\s+', ' ', 'g') as enunciado_normalizado
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
),
sinalizadas as (
  select
    c.questao_id,
    (
      c.enunciado ilike '%14.344%'
      or c.enunciado ilike '%14344%'
      or c.enunciado ilike '%estatuto da crian%'
      or c.enunciado ilike '%crianca%'
      or c.enunciado ilike '%criança%'
      or c.enunciado ilike '%adolescente%'
    ) as pista_fora_do_escopo
  from candidatas c
),
grupos_exatos as (
  select enunciado_normalizado
  from candidatas
  group by enunciado_normalizado
  having count(*) > 1
),
palavras as (
  select distinct
    c.questao_id,
    palavra
  from candidatas c
  cross join lateral regexp_split_to_table(
    regexp_replace(
      regexp_replace(lower(c.enunciado), '[^[:alnum:]\s]', ' ', 'g'),
      '\s+', ' ', 'g'
    ),
    ' '
  ) as palavra
  where length(palavra) > 3
),
totais as (
  select questao_id, count(*) as total_palavras
  from palavras
  group by questao_id
),
pares_similares as (
  select
    pa.questao_id as questao_a_id,
    pb.questao_id as questao_b_id,
    count(*) as intersecao
  from palavras pa
  join palavras pb
    on pa.palavra = pb.palavra
   and pa.questao_id < pb.questao_id
  group by pa.questao_id, pb.questao_id
),
pares_acima_do_limiar as (
  select ps.questao_a_id, ps.questao_b_id
  from pares_similares ps
  join totais ta on ta.questao_id = ps.questao_a_id
  join totais tb on tb.questao_id = ps.questao_b_id
  where (ps.intersecao::numeric / nullif(ta.total_palavras + tb.total_palavras - ps.intersecao, 0)) >= 0.35
)
select
  (select count(*) from candidatas) as total_candidatas,
  (select count(*) from sinalizadas where not pista_fora_do_escopo) as aparentemente_validas_lei_maria_da_penha,
  (select count(*) from sinalizadas where pista_fora_do_escopo) as suspeitas_assunto_incorreto_pista,
  (select count(*) from grupos_exatos) as grupos_de_duplicata_exata,
  (select count(*) from pares_acima_do_limiar) as pares_suspeitos_similares_encontrados;
