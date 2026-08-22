-- Pos-check SOMENTE LEITURA da OPERACAO D (remocao do vinculo pedagogico
-- de Q684 no conteudo 22, por DUPLICATA_EXATA_DE_Q319). Nenhuma escrita.

select id, ativa, assunto_id, materia_id, length(enunciado) as len
from public.questoes where id = 684;

select count(*) as vinculos_q684 from public.questao_unidades_pedagogicas where questao_id = 684;

select count(*) as total_alt, count(*) filter (where correta) as total_corretas
from public.alternativas where questao_id = 684;

-- Estado LIVE final esperado do conteudo 22 apos as operacoes C + D:
-- 20 candidatas ativas, 16 vinculos, 1 unidade.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) as unidades_22,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) as vinculos_22,
  (
    select count(*)
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 22
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.ativa = true and q.materia_id = cm.materia_id and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  ) as candidatas_ativas_22_live;

-- Q319 permanece intacta como canonica.
select id, ativa, assunto_id, length(enunciado) as len
from public.questoes where id = 319;

select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;
