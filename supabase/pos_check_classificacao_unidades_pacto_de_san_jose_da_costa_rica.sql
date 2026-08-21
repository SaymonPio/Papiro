-- Pos-check SOMENTE LEITURA da classificacao de questoes do Pacto de San
-- Jose da Costa Rica (curso_conteudos.id = 72) — gerado seguindo o mesmo
-- template de scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais
-- da consulta 8 foram obtidos ao vivo (leitura direta, somente SELECT)
-- porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_pacto_de_san_jose_da_costa_rica.sql (a
-- versao que termina em COMMIT, escrita/revisada a parte — ver README
-- deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: primeiro conteudo do bloco Direitos Humanos (materia_id 11).
-- Convencao Americana sobre Direitos Humanos (Pacto de San Jose da Costa
-- Rica), promulgada pelo Decreto no 678/1992. artigos_esperados usa
-- "item" (nao "§") por fidelidade a numeracao literal do tratado —
-- confirmado compativel com o parser (REGEX_ARTIGO_BASE so compara o
-- numero inicial). Q130/Q822 sao quase-duplicatas (mesmo fundamento, art.
-- 4o item 5) mantidas ambas classificadas, sem desativacao. CF art. 5o,
-- LV (distrator de Q144) documentado apenas em mapa/_nota, fora de
-- artigos_esperados. art. 26 (Q819) documentado apenas como contexto
-- estrutural, sem remissao material, fora de artigos_esperados.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 72, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, todas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 72
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 (Pacto de San José da Costa Rica) = 11
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 72
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 11, questoes_distintas = 11.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 72;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 72
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 90
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 72
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 72 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 72
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    b918b069-8364-4412-80a6-07d78b369317): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Confirma que Q130 e Q822 (quase-duplicatas) permanecem AMBAS
--    presentes, intactas e classificadas nesta unidade — nenhuma
--    desativacao ocorreu nesta curadoria. Esperado: 2 linhas, ambas
--    ativa=true.
select q.id, q.ativa, count(qup.unidade_pedagogica_id) as vinculos
from public.questoes q
left join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.id in (130, 822)
group by q.id, q.ativa
order by q.id;
