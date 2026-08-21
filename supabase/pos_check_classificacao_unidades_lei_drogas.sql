-- Pós-check SOMENTE LEITURA da classificação de questões de Lei de Drogas
-- (curso_conteudos.id = 66) — a rodar depois de
-- classificar_questoes_unidades_lei_drogas.sql (a versão que termina em
-- COMMIT) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentário; qualquer divergência deve ser reportada, não corrigida aqui.

-- 1) A única unidade pedagógica do conteúdo 66, com título/escopo/artigos
--    aplicados pela curadoria. Esperado: 1 linha, ordem 1, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 66
order by ordem;

-- 2) Contagem de questões classificadas na unidade. Esperado: 15.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 66
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vínculos e questões distintas classificadas no conteúdo.
--    Esperado: total_vinculos = 15, questoes_distintas = 15.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 66;

-- 4) Questões multiunidade. Esperado: 0 linhas (impossível com 1 única
--    unidade neste conteúdo).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 66
group by qup.questao_id
having count(*) > 1;

-- 5) Questões ativas do conteúdo que ficaram SEM nenhuma classificação.
--    Esperado: exatamente 1 linha — a questão 674 (excluída de propósito,
--    ver mapa_classificacao_lei_drogas.sql).
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 10
  and q.assunto_id = 78
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 66
  );

-- 6) Confirma que nenhuma classificação vazou de/para outro conteúdo —
--    todo vínculo da unidade do conteúdo 66 aponta para questão com
--    materia_id/assunto_id compatíveis (a trigger validar_questao_unidade_
--    pedagogica já impede isso na escrita; aqui é só confirmação).
--    Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 66
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas não deveria ter mudado por esta
--    operação (comparação manual com os totais já conhecidos antes da
--    aplicação: 93 curso_conteudos, 99 unidades_pedagogicas no total do
--    sistema — SEM mudança em relação à etapa anterior, pois esta
--    curadoria NÃO cria unidade nova, só atualiza a existente —, 915
--    questões, 4330 alternativas).
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Notas de saneamento pendente (não verificadas por esta consulta, só
--    documentadas): a duplicata 143/869 (mesmo enunciado, mesmas 5
--    alternativas) permanece classificada em ambas; a questão 674
--    permanece ativa e vinculada a este assunto mas sem classificação de
--    unidade. Nenhuma das duas é um erro deste pós-check — são
--    saneamentos de banco de questões adiados para etapa separada.
