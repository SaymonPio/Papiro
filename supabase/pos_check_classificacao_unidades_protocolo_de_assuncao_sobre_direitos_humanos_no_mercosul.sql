-- Pos-check SOMENTE LEITURA da classificacao de questoes do Protocolo
-- de Assuncao sobre Direitos Humanos no Mercosul (curso_conteudos.id =
-- 92) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais da
-- consulta 7 foram obtidos ao vivo (leitura direta, somente SELECT)
-- porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul.sql
-- (a versao que termina em COMMIT, escrita/revisada a parte — ver
-- README deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: Protocolo de Assuncao sobre Compromisso com a Promocao e
-- Protecao dos Direitos Humanos do MERCOSUL (CMC/DEC no 17/05) — art. 1
-- (Q182). Q180/Q181 sem artigo (identificacao/classificacao do proprio
-- instrumento). Sobreposicao tematica (nao duplicata) com o conteudo 91
-- (Direitos Humanos no Mercosul, ja concluido): Q162/Q163 la usam o
-- mesmo art. 1 do mesmo diploma, para questoes diferentes.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 92, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, artigos_esperados com 1 item (art. 1), ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 92
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 3
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 92
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 3, questoes_distintas = 3.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 92;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 92
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 93
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 92
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 92 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 92
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-22 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    655700d6-b585-468f-8d98-8143090cbafb): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Conteudo 91 (Direitos Humanos no Mercosul, ja concluido) permanece
--    intocado por esta operacao — sobreposicao apenas tematica, nao
--    duplicata. Esperado (baseline ao vivo em 2026-08-22, antes desta
--    operacao): unidades_91=1, vinculos_91=3.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 91) as unidades_91,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 91) as vinculos_91;

-- 9) Confirma exatamente o artigo_esperado aprovado (art. 1) e que
--    nenhum outro artigo foi incluido.
--    Esperado: contem_art1=true, total=1.
select
  (artigos_esperados @> array['art. 1']::text[]) as contem_art1,
  array_length(artigos_esperados, 1) as total_artigos_esperados
from public.unidades_pedagogicas
where curso_conteudo_id = 92;
