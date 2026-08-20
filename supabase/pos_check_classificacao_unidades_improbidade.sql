-- Pós-check SOMENTE LEITURA da classificação de questões de Improbidade
-- Administrativa (curso_conteudos.id = 55) — a rodar depois de
-- classificar_questoes_unidades_improbidade.sql (a versão que termina em
-- COMMIT) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentário; qualquer divergência deve ser reportada, não corrigida aqui.

-- 1) As 2 unidades pedagógicas do conteúdo 55, com título/escopo/artigos
--    aplicados pela curadoria. Esperado: 2 linhas, ordem 1 e 2, ambas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 55
order by ordem;

-- 2) Contagem de questões classificadas por unidade. Esperado:
--    ordem 1 (Atos de Improbidade Administrativa) = 9
--    ordem 2 (Sujeitos, Sanções e Processo de Improbidade) = 7
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 55
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vínculos e questões distintas classificadas no conteúdo.
--    Esperado: total_vinculos = 16, questoes_distintas = 15.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 55;

-- 4) Questões multiunidade (vinculadas a mais de uma unidade do conteúdo).
--    Esperado: apenas a questão 732.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 55
group by qup.questao_id
having count(*) > 1;

-- 5) Questões ativas do conteúdo que ficaram SEM nenhuma classificação.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 10
  and q.assunto_id = 64
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 55
  );

-- 6) Confirma que nenhuma classificação vazou de/para outro conteúdo —
--    todo vínculo de uma unidade do conteúdo 55 aponta para questão com
--    materia_id/assunto_id compatíveis (a trigger validar_questao_unidade_
--    pedagogica já impede isso na escrita; aqui é só confirmação).
--    Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 55
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas não deveria ter mudado por esta
--    operação (comparação manual com os totais já conhecidos antes da
--    aplicação: 93 curso_conteudos, 99 unidades_pedagogicas no total do
--    sistema após a curadoria de Improbidade Administrativa — 98 já
--    existentes com a unidade 2 de Direitos e Garantias Fundamentais + 1
--    nova desta curadoria —, 915 questões, 4330 alternativas).
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Nota de saneamento pendente (não verificada por esta consulta, só
--    documentada): a duplicata 137/857 (mesmo enunciado, mesmas 5
--    alternativas) permanece classificada em ambas nesta etapa, por
--    decisão explícita — não é um erro deste pós-check, é um saneamento
--    de banco de questões adiado para uma etapa separada.
