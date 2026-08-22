-- Pos-check SOMENTE LEITURA da classificacao de questoes do Pacto
-- Internacional sobre Direitos Economicos, Sociais e Culturais - PIDESC
-- (curso_conteudos.id = 77) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais da
-- consulta 7 foram obtidos ao vivo (leitura direta, somente SELECT)
-- porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_pacto_internacional_sobre_direitos_economicos_sociais_e_culturais.sql
-- (a versao que termina em COMMIT, escrita/revisada a parte — ver
-- README deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: PIDESC (Decreto no 591/1992). Art. 15, item 1, "c" mapeado com
-- redacao propria do tratado (protecao dos interesses morais e
-- materiais do autor), evitando rotular como "direito de propriedade
-- intelectual" generico.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 77, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, artigos_esperados com 7 itens, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 77
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 3
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 77
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 3, questoes_distintas = 3.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 77;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 77
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 84
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 77
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 77 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 77
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-22 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    f33221cc-f53c-4f91-88e4-a6d8440beca0): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Confirma exatamente os 7 artigos_esperados aprovados.
--    Esperado: total_artigos_esperados=7, todos os campos true.
select
  (artigos_esperados @> array['art. 4º']::text[]) as contem_art4,
  (artigos_esperados @> array['art. 5º, item 2']::text[]) as contem_art5_item2,
  (artigos_esperados @> array['art. 6º, item 1']::text[]) as contem_art6_item1,
  (artigos_esperados @> array['art. 6º, item 2']::text[]) as contem_art6_item2,
  (artigos_esperados @> array['art. 9º']::text[]) as contem_art9,
  (artigos_esperados @> array['art. 13, item 1']::text[]) as contem_art13_item1,
  (artigos_esperados @> array['art. 15, item 1, "c"']::text[]) as contem_art15_item1_c,
  array_length(artigos_esperados, 1) as total_artigos_esperados
from public.unidades_pedagogicas
where curso_conteudo_id = 77;
