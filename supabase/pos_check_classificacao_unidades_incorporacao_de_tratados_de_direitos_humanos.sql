-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Incorporacao de tratados de Direitos Humanos (curso_conteudos.id =
-- 93) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais da
-- consulta 7 foram obtidos ao vivo (leitura direta, somente SELECT)
-- porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_incorporacao_de_tratados_de_direitos_humanos.sql
-- (a versao que termina em COMMIT, escrita/revisada a parte — ver
-- README deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: CF/88 — art. 5º, §3º (Q165), art. 84, VIII e art. 49, I (Q167).
-- Q166 vinculada nominalmente ao STF, RE 466.343/SP (Rel. Min. Cezar
-- Peluso, Tribunal Pleno, julgamento concluido em 03/12/2008 — tese da
-- supralegalidade), sem artigo isolado proprio (o art. 5º, §3º
-- permanece em artigos_esperados apenas por forca da Q165). Sobreposicao
-- tematica (nao duplicata) com o conteudo 78 (Q165 aqui / Q265 la).

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 93, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, artigos_esperados com 3 itens, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 93
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 3
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 93
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 3, questoes_distintas = 3.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 93;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 93
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 101
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 93
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 93 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 93
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-22 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    98b10517-14a2-4efe-8360-960cae263ad5): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Conteudo 78 (Tratados de Direitos Humanos com forca de Emenda
--    Constitucional, ja concluido) permanece intocado por esta operacao
--    — sobreposicao apenas tematica, nao duplicata. Esperado (baseline
--    ao vivo em 2026-08-22, antes desta operacao): unidades_78=1,
--    vinculos_78=3.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 78) as unidades_78,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 78) as vinculos_78;

-- 9) Confirma exatamente os 3 artigos_esperados aprovados.
--    Esperado: contem_art5_par3=true, contem_art84_viii=true,
--    contem_art49_i=true, total=3.
select
  (artigos_esperados @> array['art. 5º, §3º']::text[]) as contem_art5_par3,
  (artigos_esperados @> array['art. 84, VIII']::text[]) as contem_art84_viii,
  (artigos_esperados @> array['art. 49, I']::text[]) as contem_art49_i,
  array_length(artigos_esperados, 1) as total_artigos_esperados
from public.unidades_pedagogicas
where curso_conteudo_id = 93;
