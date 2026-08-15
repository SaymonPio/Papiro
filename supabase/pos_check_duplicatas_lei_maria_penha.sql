-- PÓS-CHECK DE PRODUÇÃO — desativação lógica das duplicatas da Lei Maria da
-- Penha (863, 864, 865) + confirmação de que a limpeza anterior (questão
-- 738, fora de escopo) permanece íntegra.
--
-- SOMENTE LEITURA. Nenhum INSERT/UPDATE/DELETE. Rodar DEPOIS de aplicar
-- supabase/desativar_duplicatas_lei_maria_penha.sql com sucesso.
--
-- "Candidata" = mesma definição usada em todos os diagnósticos desta fase:
-- questão ATIVA cuja materia_id bate com a matéria real do conteúdo 53 e,
-- quando o conteúdo tiver assunto_id definido, cujo assunto_id também bate.

-- ============================================================================
-- 1) Status individual das 7 questões envolvidas nesta limpeza.
--    Esperado: 738/863/864/865 = false; 129/133/134 = true.
-- ============================================================================
select id as questao_id, ativa, materia_id, assunto_id
from public.questoes
where id in (738, 863, 864, 865, 129, 133, 134)
order by id;

-- ============================================================================
-- 2) Total de questões ATIVAS candidatas para curso_conteudos.id = 53 —
--    esperado 28 (31 depois da desativação da 738, menos as 3 duplicatas).
-- ============================================================================
select count(*) as questoes_ativas_candidatas_conteudo_53
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

-- ============================================================================
-- 3) curso_questoes das 6 questões de duplicata/canônica — confirma que
--    nenhum vínculo foi alterado (esperado: 1 linha cada, mesmo curso
--    7543be16-4c5b-4cb6-8724-8fbdfb96f2d4, prioridade=1).
-- ============================================================================
select questao_id, curso_id, prioridade
from public.curso_questoes
where questao_id in (863, 864, 865, 129, 133, 134)
order by questao_id;

-- ============================================================================
-- 4) Alternativas das 7 questões — informativo (contagem por questão), para
--    conferência visual de que nada foi tocado.
-- ============================================================================
select questao_id, count(*) as qtd_alternativas, count(*) filter (where correta) as qtd_corretas
from public.alternativas
where questao_id in (738, 863, 864, 865, 129, 133, 134)
group by questao_id
order by questao_id;

-- ============================================================================
-- 5) Nenhuma classificação em unidade pedagógica foi criada como efeito
--    colateral deste processo — esperado 0 linhas.
-- ============================================================================
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id in (738, 863, 864, 865, 129, 133, 134);

-- ============================================================================
-- 6) RESUMO booleano — cada linha do resumo depende só dos fatos acima.
-- ============================================================================
with status_questoes as (
  select id, ativa, materia_id, assunto_id
  from public.questoes
  where id in (738, 863, 864, 865, 129, 133, 134)
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
vinculos_curso as (
  select questao_id, count(*) as qtd, count(*) filter (
    where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and prioridade = 1
  ) as qtd_esperado
  from public.curso_questoes
  where questao_id in (863, 864, 865, 129, 133, 134)
  group by questao_id
),
classificacoes as (
  select count(*) as total
  from public.questao_unidades_pedagogicas
  where questao_id in (738, 863, 864, 865, 129, 133, 134)
)
select
  (select bool_and(ativa is false) from status_questoes where id in (738, 863, 864, 865)) as desativadas_ok,
  (select bool_and(ativa is true) from status_questoes where id in (129, 133, 134)) as canonicas_ativas_ok,
  (select bool_and(materia_id = 10 and assunto_id = 19) from status_questoes) as materia_assunto_preservados_ok,
  (select total from candidatas) = 28 as total_candidatas_e_28,
  (select bool_and(qtd = 1 and qtd_esperado = 1) from vinculos_curso) as curso_questoes_integro_ok,
  (select total from classificacoes) = 0 as nenhuma_classificacao_unidade_ok,
  (
    (select bool_and(ativa is false) from status_questoes where id in (738, 863, 864, 865))
    and (select bool_and(ativa is true) from status_questoes where id in (129, 133, 134))
    and (select bool_and(materia_id = 10 and assunto_id = 19) from status_questoes)
    and (select total from candidatas) = 28
    and (select bool_and(qtd = 1 and qtd_esperado = 1) from vinculos_curso)
    and (select total from classificacoes) = 0
  ) as tudo_ok;
