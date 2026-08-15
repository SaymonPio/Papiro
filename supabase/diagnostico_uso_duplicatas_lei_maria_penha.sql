-- Diagnóstico READ-ONLY de USO/REFERÊNCIAS das 6 questões envolvidas nos 3
-- pares de duplicata exata confirmados (B4+B5 de
-- diagnostico_pendencias_curadoria_lei_maria_penha.sql):
--   129 / 864   133 / 865   134 / 863
--
-- SOMENTE SELECT. Nenhuma instrução deste arquivo escreve em nada — nenhum
-- INSERT/UPDATE/DELETE, nenhuma desativação, nenhuma decisão automática de
-- qual id preservar. O objetivo é só reunir os fatos (quem/quantas vezes
-- cada id foi referenciado) para a decisão humana de qual manter ativo em
-- cada par.
--
-- Tabelas reais que referenciam questao_id, mapeadas a partir dos arquivos
-- locais (nenhuma inventada):
--   - public.respostas_usuarios (usuario_id, questao_id, alternativa_id,
--     sessao_id, acertou, tempo_segundos, respondida_em) — histórico de
--     resposta por usuário; funcoes_curso_ativo.sql.
--   - public.sessao_questoes_planejadas (sessao_id, questao_id, ordem),
--     PK (sessao_id, questao_id) — lista CONGELADA de questões de uma
--     sessão (livre, de missão, ou do Modo Papiro); missao_questoes_rpc.sql.
--   - public.questao_comentarios (questao_id, usuario_id, texto, status,
--     criado_em, atualizado_em) — comunidade/comentários da questão;
--     questao_comentarios.sql.
--   - public.curso_questoes (questao_id, curso_id, prioridade) — vínculo da
--     questão a um curso (base de ids_questoes_para_usuario).
--   - public.questao_unidades_pedagogicas (questao_id,
--     unidade_pedagogica_id, classificado_por, criado_em) — classificação
--     por unidade pedagógica (Modo Papiro).
--   - public.erros_usuarios NÃO tem questao_id direto — chega-se à questão
--     via resposta_id -> respostas_usuarios.questao_id (cadeia documentada
--     em consultas_curso_ativo.sql).
--   - public.revisoes tampouco tem questao_id direto — chega-se via
--     erro_id -> erros_usuarios.id -> resposta_id ->
--     respostas_usuarios.questao_id (mesma cadeia).
--   - Não existe nenhuma tabela "simulados" separada neste projeto — sessão
--     avulsa/personalizada e sessão de missão já são ambas
--     public.sessoes_estudo, cobertas por sessao_questoes_planejadas acima.
--
-- Cole no SQL Editor do Supabase; os 2 blocos abaixo são consultas
-- independentes — rode um de cada vez (ou o script inteiro, conforme o
-- editor mostrar os resultados).

-- ============================================================================
-- 1) Uma linha por questao_id (129, 864, 133, 865, 134, 863): dados da
--    questão + contagem de referências em CADA tabela relevante + uso
--    agregado (respostas/sessões/comentários) + datas mais antiga/recente
--    de uso, quando aplicável.
-- ============================================================================
with alvo (questao_id) as (
  values (129::bigint), (864::bigint), (133::bigint), (865::bigint), (134::bigint), (863::bigint)
),
base as (
  select q.id as questao_id, q.ativa, q.banca, q.concurso, q.ano, q.criado_em, q.enunciado
  from public.questoes q
  where q.id in (select questao_id from alvo)
),
respostas as (
  select
    ru.questao_id,
    count(*) as qtd_respostas,
    count(distinct ru.usuario_id) as usuarios_distintos_que_responderam,
    min(ru.respondida_em) as primeira_resposta_em,
    max(ru.respondida_em) as ultima_resposta_em
  from public.respostas_usuarios ru
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
sessoes_planejadas as (
  select
    sqp.questao_id,
    count(*) as qtd_sessoes_planejadas,
    min(se.inicio_em) as primeira_sessao_em,
    max(se.inicio_em) as ultima_sessao_em
  from public.sessao_questoes_planejadas sqp
  join public.sessoes_estudo se on se.id = sqp.sessao_id
  where sqp.questao_id in (select questao_id from alvo)
  group by sqp.questao_id
),
comentarios as (
  select
    qc.questao_id,
    count(*) as qtd_comentarios_total,
    count(*) filter (where qc.status = 'ativo') as qtd_comentarios_ativos,
    min(qc.criado_em) as primeiro_comentario_em,
    max(qc.criado_em) as ultimo_comentario_em
  from public.questao_comentarios qc
  where qc.questao_id in (select questao_id from alvo)
  group by qc.questao_id
),
erros as (
  select
    ru.questao_id,
    count(*) as qtd_erros,
    min(eu.criado_em) as primeiro_erro_em,
    max(eu.criado_em) as ultimo_erro_em
  from public.erros_usuarios eu
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
revisoes_cte as (
  select
    ru.questao_id,
    count(*) as qtd_revisoes
  from public.revisoes rv
  join public.erros_usuarios eu on eu.id = rv.erro_id
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
cursos as (
  select cq.questao_id, count(*) as qtd_cursos_vinculados
  from public.curso_questoes cq
  where cq.questao_id in (select questao_id from alvo)
  group by cq.questao_id
),
classificacoes as (
  select qup.questao_id, count(*) as qtd_unidades_classificadas
  from public.questao_unidades_pedagogicas qup
  where qup.questao_id in (select questao_id from alvo)
  group by qup.questao_id
)
select
  b.questao_id,
  b.ativa,
  b.banca,
  b.concurso,
  b.ano,
  b.criado_em,
  b.enunciado,
  coalesce(r.qtd_respostas, 0) as qtd_respostas,
  coalesce(r.usuarios_distintos_que_responderam, 0) as usuarios_distintos_que_responderam,
  r.primeira_resposta_em,
  r.ultima_resposta_em,
  coalesce(sp.qtd_sessoes_planejadas, 0) as qtd_sessoes_planejadas,
  sp.primeira_sessao_em,
  sp.ultima_sessao_em,
  coalesce(c.qtd_comentarios_total, 0) as qtd_comentarios_total,
  coalesce(c.qtd_comentarios_ativos, 0) as qtd_comentarios_ativos,
  c.primeiro_comentario_em,
  c.ultimo_comentario_em,
  coalesce(e.qtd_erros, 0) as qtd_erros,
  e.primeiro_erro_em,
  e.ultimo_erro_em,
  coalesce(rv.qtd_revisoes, 0) as qtd_revisoes,
  coalesce(cu.qtd_cursos_vinculados, 0) as qtd_cursos_vinculados,
  coalesce(cl.qtd_unidades_classificadas, 0) as qtd_unidades_classificadas,
  (
    coalesce(r.qtd_respostas, 0) > 0
    or coalesce(sp.qtd_sessoes_planejadas, 0) > 0
    or coalesce(c.qtd_comentarios_total, 0) > 0
  ) as usada_por_algum_usuario,
  (
    coalesce(r.qtd_respostas, 0)
    + coalesce(sp.qtd_sessoes_planejadas, 0)
    + coalesce(c.qtd_comentarios_total, 0)
    + coalesce(e.qtd_erros, 0)
    + coalesce(rv.qtd_revisoes, 0)
    + coalesce(cu.qtd_cursos_vinculados, 0)
    + coalesce(cl.qtd_unidades_classificadas, 0)
  ) as total_referencias
from base b
left join respostas r on r.questao_id = b.questao_id
left join sessoes_planejadas sp on sp.questao_id = b.questao_id
left join comentarios c on c.questao_id = b.questao_id
left join erros e on e.questao_id = b.questao_id
left join revisoes_cte rv on rv.questao_id = b.questao_id
left join cursos cu on cu.questao_id = b.questao_id
left join classificacoes cl on cl.questao_id = b.questao_id
order by b.questao_id;

-- ============================================================================
-- 2) RESUMO por par — só fatos objetivos lado a lado (total_referencias =
--    soma de todas as contagens do bloco 1; qtd_respostas em destaque por
--    ser o histórico mais direto de uso real por aluno). NÃO indica qual
--    id manter — só os números para a decisão humana.
-- ============================================================================
with alvo (questao_id) as (
  values (129::bigint), (864::bigint), (133::bigint), (865::bigint), (134::bigint), (863::bigint)
),
respostas as (
  select ru.questao_id, count(*) as qtd_respostas
  from public.respostas_usuarios ru
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
sessoes_planejadas as (
  select sqp.questao_id, count(*) as qtd_sessoes_planejadas
  from public.sessao_questoes_planejadas sqp
  where sqp.questao_id in (select questao_id from alvo)
  group by sqp.questao_id
),
comentarios as (
  select qc.questao_id, count(*) as qtd_comentarios_total
  from public.questao_comentarios qc
  where qc.questao_id in (select questao_id from alvo)
  group by qc.questao_id
),
erros as (
  select ru.questao_id, count(*) as qtd_erros
  from public.erros_usuarios eu
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
revisoes_cte as (
  select ru.questao_id, count(*) as qtd_revisoes
  from public.revisoes rv
  join public.erros_usuarios eu on eu.id = rv.erro_id
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  where ru.questao_id in (select questao_id from alvo)
  group by ru.questao_id
),
cursos as (
  select cq.questao_id, count(*) as qtd_cursos_vinculados
  from public.curso_questoes cq
  where cq.questao_id in (select questao_id from alvo)
  group by cq.questao_id
),
classificacoes as (
  select qup.questao_id, count(*) as qtd_unidades_classificadas
  from public.questao_unidades_pedagogicas qup
  where qup.questao_id in (select questao_id from alvo)
  group by qup.questao_id
),
totais as (
  select
    a.questao_id,
    coalesce(r.qtd_respostas, 0) as qtd_respostas,
    (
      coalesce(r.qtd_respostas, 0)
      + coalesce(sp.qtd_sessoes_planejadas, 0)
      + coalesce(c.qtd_comentarios_total, 0)
      + coalesce(e.qtd_erros, 0)
      + coalesce(rv.qtd_revisoes, 0)
      + coalesce(cu.qtd_cursos_vinculados, 0)
      + coalesce(cl.qtd_unidades_classificadas, 0)
    ) as total_referencias
  from alvo a
  left join respostas r on r.questao_id = a.questao_id
  left join sessoes_planejadas sp on sp.questao_id = a.questao_id
  left join comentarios c on c.questao_id = a.questao_id
  left join erros e on e.questao_id = a.questao_id
  left join revisoes_cte rv on rv.questao_id = a.questao_id
  left join cursos cu on cu.questao_id = a.questao_id
  left join classificacoes cl on cl.questao_id = a.questao_id
),
pares (par, questao_a_id, questao_b_id) as (
  values (1, 129::bigint, 864::bigint), (2, 133::bigint, 865::bigint), (3, 134::bigint, 863::bigint)
)
select
  p.par,
  p.questao_a_id,
  ta.qtd_respostas as respostas_a,
  ta.total_referencias as total_referencias_a,
  p.questao_b_id,
  tb.qtd_respostas as respostas_b,
  tb.total_referencias as total_referencias_b
from pares p
join totais ta on ta.questao_id = p.questao_a_id
join totais tb on tb.questao_id = p.questao_b_id
order by p.par;
