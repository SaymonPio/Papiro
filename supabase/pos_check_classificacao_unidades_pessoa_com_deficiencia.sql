-- Pos-check SOMENTE LEITURA da classificacao de questoes de Pessoa com
-- deficiencia (curso_conteudos.id = 71) — gerado seguindo o mesmo
-- template de scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os
-- totais da consulta 8 foram obtidos ao vivo (leitura direta, somente
-- SELECT) porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_pessoa_com_deficiencia.sql (a versao que
-- termina em COMMIT, escrita/revisada a parte — ver README deste
-- pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: dois diplomas na mesma unidade — Convencao Internacional sobre
-- os Direitos das Pessoas com Deficiencia/Protocolo Facultativo (Decreto
-- 6.949/2009) e Lei no 7.853/1989 (art. 8o reescrito pela Lei 13.146/2015;
-- art. 2o com atualizacao terminologica pontual da Lei 15.155/2025, sem
-- alteracao substantiva nos direitos testados). Nenhum artigo do
-- Protocolo Facultativo entra em artigos_esperados (ambiguidade de
-- numeracao com a Convencao) — Q353 documentada apenas em escopo/mapa.
-- Q141/Q827 (quase-duplicatas) mantidas ambas classificadas.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 71, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, todas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 71
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 (Pessoa com deficiência) = 8
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 71
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 8, questoes_distintas = 8.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 71;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 71
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 27
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 71
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 71 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 71
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    435543fe-bdc2-452a-be2d-ffa414c5e27d): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Confirma que Q141 e Q827 (quase-duplicatas) permanecem AMBAS
--    ativas e classificadas, com enunciado e gabarito intactos.
--    Esperado: 2 linhas, ambas ativa=true, vinculos=1 cada.
select q.id, q.ativa, count(qup.unidade_pedagogica_id) as vinculos
from public.questoes q
left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id in (141, 827)
group by q.id, q.ativa
order by q.id;
