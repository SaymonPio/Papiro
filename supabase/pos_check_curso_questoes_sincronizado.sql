-- POS-CHECK PERMANENTE — sincronizacao curso_questoes.
--
-- READ-ONLY. Nao corrige nada, somente detecta drift. Pensado para rodar
-- ao final de toda futura esteira de curadoria (importacao ou
-- classificacao) que toque questao_unidades_pedagogicas, em qualquer
-- curso (nao hardcoded para Brigada Militar RS) — desde a correcao de
-- 2026-09-07 em classificar_questao_unidade_admin (patch em
-- corrigir_sincronizacao_curso_questoes_bmrs.sql) que sincroniza
-- curso_questoes automaticamente a cada vinculo novo, este relatorio deve
-- retornar 0 linhas em condicoes normais; qualquer linha aqui indica uma
-- questao classificada por um caminho que nao passou por aquela RPC (ou
-- por uma execucao anterior ao patch).
--
-- Definicao de divergencia: questao ativa + vinculada a unidade ativa de
-- conteudo relevante de materia relevante de um curso, mas SEM linha
-- correspondente em curso_questoes para aquele curso.

select
  c.slug as curso,
  c.id as curso_id,
  q.id as questao_id,
  up.titulo as unidade,
  cc.id as curso_conteudo_id,
  asn.nome as conteudo,
  cm.nome as materia,
  coalesce(lower(q.banca), '') like '%papiro%' as autoral
from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id and up.ativa = true
join public.curso_conteudos cc on cc.id = up.curso_conteudo_id and cc.relevante_para_preparacao = true
join public.curso_materias cm on cm.id = cc.curso_materia_id and cm.relevante_para_preparacao = true
join public.cursos c on c.id = cm.curso_id
left join public.assuntos asn on asn.id = cc.assunto_id
where q.ativa = true
  and not exists (
    select 1 from public.curso_questoes cq
    where cq.curso_id = cm.curso_id and cq.questao_id = q.id
  )
order by c.slug, cm.nome, cc.id, q.id;
