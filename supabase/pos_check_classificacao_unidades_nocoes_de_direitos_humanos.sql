-- Pos-check SOMENTE LEITURA da classificacao de questoes de Noções de
-- Direitos Humanos (curso_conteudos.id = 81) — gerado seguindo o mesmo
-- template de scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os
-- totais da consulta 7 foram obtidos ao vivo (leitura direta, somente
-- SELECT) porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_nocoes_de_direitos_humanos.sql (a versao
-- que termina em COMMIT, escrita/revisada a parte — ver README deste
-- pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA — EXCLUSAO INTENCIONAL POR FORA DE ESCOPO: das 7 questoes ativas
-- do assunto, apenas 5 (168, 169, 170, 623, 696) foram classificadas
-- nesta unidade. Q624 (Estatuto Nacional da Igualdade Racial, Lei
-- 12.288/2010, art. 52 — ja classificado em curso_conteudo_id 67 e 97)
-- e Q697 (Estatuto do Idoso, Lei 10.741/2003, art. 34) sao materialmente
-- incompativeis com "Nocoes de Direitos Humanos" e permanecem
-- propositalmente sem vinculo com este conteudo — nao foram desativadas,
-- nao tiveram assunto_id alterado, nao foram movidas para outro
-- curso_conteudo e nao tiveram enunciado/gabarito alterado. Sinalizadas
-- para saneamento futuro de assunto_id.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 81, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, todas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 81
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 (Noções de Direitos Humanos) = 5
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 81
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 5, questoes_distintas = 5.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 81;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 81
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 2 linhas — Q624 e Q697 (exclusao intencional, nao e falha).
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 89
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 81
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 81 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 81
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    df8d133f-ddd6-4b85-941d-60b4d4967c06): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Confirma que Q624 e Q697 permanecem ativas, intactas e sem NENHUM
--    vinculo em qualquer conteudo alem dos ja existentes (checagem
--    ampla, nao restrita ao conteudo 81). Esperado: 2 linhas, ambas
--    ativa=true.
select q.id, q.ativa, count(qup.unidade_pedagogica_id) as vinculos_totais
from public.questoes q
left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id in (624, 697)
group by q.id, q.ativa
order by q.id;
