-- Pos-check SOMENTE LEITURA da classificacao de questoes de Classes
-- de palavras (curso_conteudos.id = 22) — gerado seguindo o mesmo
-- template de scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os
-- totais da consulta 7 foram obtidos ao vivo (leitura direta, somente
-- SELECT) porque este ambiente local nao tinha
-- SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY configurados para o proprio
-- script rodar essa parte sozinho (ver .env.curadoria /
-- env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_classes_de_palavras.sql (a versao que
-- termina em COMMIT, escrita/revisada a parte — ver README deste
-- pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL para toda a unidade (metodologia nao
-- juridica). Q71 (FORA_DE_ESCOPO_SINTAXE_SUJEITO), Q325
-- (PROBLEMA_DE_DADO_TEXTO_BASE_AUSENTE) e Q683
-- (FORA_DE_ESCOPO_REFERENCIA_TEXTUAL) excluidas intencionalmente
-- — permanecem ativas, intactas e sem vinculo pedagogico.
--
-- ADENDO (2026-08-23): Q878 (antes excluida aqui como
-- FORA_DE_ESCOPO_SEMANTICA_PRESSUPOSICAO) foi REALOCADA via saneamento
-- taxonomico dedicado para assunto_id=46 (Implicitos e subentendidos,
-- curso_conteudo_id=25) — ver supabase/saneamento_taxonomico_q878.sql e
-- supabase/pos_check_saneamento_taxonomico_q878.sql. Nao pertence mais a
-- este conteudo; removida das consultas 5 e 9 abaixo e substituida pela
-- consulta 9b, que confirma explicitamente sua saida.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 22, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, artigos_esperados NULL, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 22
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 17
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 22
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 17, questoes_distintas = 17.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 22;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 22
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao
--    E NAO estao na lista de exclusoes intencionais (71, 325, 683).
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 47
  and q.id not in (71, 325, 683)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 22
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 22 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 22
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-22 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    3f215008-367b-4890-9588-525980baefc1): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Conteudo 20 (Ortografia, ja concluido) permanece intocado por
--    esta operacao — sobreposicao apenas de texto-base, nao duplicata.
--    Esperado (baseline ao vivo em 2026-08-22, antes desta operacao):
--    unidades_20=1, vinculos_20=22.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) as unidades_20,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) as vinculos_20;

-- 9) Q71, Q325, Q683 permanecem ATIVAS, INTACTAS e SEM vinculo
--    pedagogico. Esperado: todas ativa=true, vinculos=0.
select
  q.id,
  q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where q.id in (71, 325, 683)
order by q.id;

-- 9b) Q878 NAO pertence mais a este conteudo (ver ADENDO no cabecalho).
--     Esperado: assunto_id=46, ativa=true, vinculos_totais=1,
--     vinculos_neste_conteudo=0.
select
  q.id,
  q.assunto_id,
  q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos_totais,
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where qup.questao_id = q.id and u.curso_conteudo_id = 22) as vinculos_neste_conteudo
from public.questoes q
where q.id = 878;

-- 10) Confirma que artigos_esperados permanece NULL.
--    Esperado: artigos_esperados_null = true.
select
  (artigos_esperados is null) as artigos_esperados_null
from public.unidades_pedagogicas
where curso_conteudo_id = 22;
