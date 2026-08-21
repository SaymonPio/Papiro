-- Pos-check SOMENTE LEITURA da classificacao de questoes do Estatuto da
-- Igualdade Racial — materia Direitos Humanos e Cidadania
-- (curso_conteudos.id = 97) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais da consulta
-- 8 foram obtidos ao vivo (leitura direta, somente SELECT) porque este
-- ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_estatuto_da_igualdade_racial.sql (a
-- versao que termina em COMMIT, escrita/revisada a parte — ver README
-- deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: Lei no 12.288/2010, ja classificada tambem no curso_conteudo_id
-- 67 (Estatuto Nacional da Igualdade Racial, materia Legislacao
-- Especifica). Duplicatas exatas identificadas e mantidas classificadas
-- nesta curadoria, sem desativacao: Q131/Q816 (interna a este conteudo,
-- art. 3o) e Q815/Q135 (cruzada com o conteudo 67, arts. 23-26) —
-- saneamento de duplicidade sinalizado para etapa propria. Sobreposicoes
-- adicionais documentadas sem movimentacao: Q256~Q302, Q255~Q350,
-- Q790~Q54 (todos do conteudo 67). O conteudo 67 NAO foi reaberto ou
-- alterado por esta operacao.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 97, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, todas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 97
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 (Estatuto da Igualdade Racial) = 9
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 97
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 9, questoes_distintas = 9.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 97;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 97
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 98
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 97
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 97 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 97
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    9cc42871-c31c-440a-88cb-32f0d4f232ff): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Confirma que Q131 e Q816 (duplicata exata interna) permanecem AMBAS
--    ativas e classificadas, e que Q815 (duplicata exata de Q135, ja
--    classificada no conteudo 67) tambem permanece ativa e classificada
--    aqui, e que o conteudo 67 permanece com exatamente os mesmos 5
--    vinculos de antes (nao reaberto). Esperado: id 131/816 ativa=true
--    vinculos=1 cada; id 815 ativa=true vinculos=1; conteudo_67_vinculos=5.
select 'q131' as chk, q.ativa, count(qup.unidade_pedagogica_id) as vinculos
from public.questoes q left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id = 131 group by q.ativa
union all
select 'q816', q.ativa, count(qup.unidade_pedagogica_id)
from public.questoes q left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id = 816 group by q.ativa
union all
select 'q815', q.ativa, count(qup.unidade_pedagogica_id)
from public.questoes q left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id = 815 group by q.ativa
union all
select 'conteudo_67_vinculos', null, count(*)
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 67;
