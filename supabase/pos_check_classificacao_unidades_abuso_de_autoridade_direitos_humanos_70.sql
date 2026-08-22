-- Pos-check SOMENTE LEITURA da classificacao de questoes de Abuso de
-- Autoridade (curso_conteudos.id = 70, materia_id 11/Direitos Humanos e
-- Cidadania) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs. Os totais da
-- consulta 7 foram obtidos ao vivo (leitura direta, somente SELECT)
-- porque este ambiente local não tinha SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY
-- configurados para o próprio script rodar essa parte sozinho (ver
-- .env.curadoria / env.curadoria.example). A rodar depois de
-- classificar_questoes_unidades_abuso_de_autoridade_direitos_humanos_70.sql
-- (a versao que termina em COMMIT, escrita/revisada a parte — ver
-- README deste pipeline) ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: NAO confundir com curso_conteudo_id 62 (mesmo nome "Abuso de
-- Autoridade", materia_id 10/Legislacao Especifica, ja concluido,
-- arquivos com slug abuso_de_autoridade sem sufixo). Lei no 13.869/2019.
-- Q354/situacao II: o dispositivo correto para "inovar artificiosamente"
-- e o art. 23, caput; o artigo do projeto de lei original que
-- numericamente antecederia este foi integralmente vetado no processo
-- legislativo e nao possui texto vigente, por isso nao serve de
-- fundamento (consulta 9 abaixo confirma ausencia dessa referencia nos
-- artigos_esperados aplicados). Q291 e quase-duplicata de Q193 (conteudo
-- 62, ja concluido) — documentado apenas, nenhuma acao sobre Q193.

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 70, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, id d4d8a1fc-4c52-4c85-879c-031d0085be88, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 70
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 (Abuso de Autoridade) = 4
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 70
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 4, questoes_distintas = 4.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 70;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 70
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 11
  and q.assunto_id = 103
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 70
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 70 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 70
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta,
--    ver nota no cabecalho), com unidades_pedagogicas ja ajustado por 0
--    unidade(s) que esta curadoria ainda vai criar (0 porque esta curadoria
--    NAO cria unidade nova — so reutiliza a unidade padrao ja existente
--    d4d8a1fc-4c52-4c85-879c-031d0085be88): curso_conteudos=93,
--    unidades_pedagogicas=99 (ao vivo: 99),
--    questoes=915, alternativas=4330.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

-- 8) Conteudo 62 (Abuso de Autoridade, Legislacao Especifica, ja
--    concluido) permanece intocado por esta operacao — mesmo nome, mesmo
--    diploma, mas curso_conteudo_id/materia_id distintos, nunca deve ser
--    alterado por esta curadoria. Esperado (baseline ao vivo em
--    2026-08-21, antes desta operacao): unidades_conteudo_62=1,
--    vinculos_conteudo_62=11.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 62) as unidades_conteudo_62,
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 62) as vinculos_conteudo_62;

-- 9) Confirma que o artigos_esperados aplicado no conteudo 70 NAO contem
--    o dispositivo vetado (o artigo do projeto de lei original que
--    numericamente antecederia o art. 23) e CONTEM art. 23, caput.
--    Esperado: contem_art23=true, contem_dispositivo_vetado=false.
select
  (artigos_esperados @> array['art. 23, caput']::text[]) as contem_art23,
  exists (
    select 1 from unnest(artigos_esperados) as a(v)
    where a.v ilike '%art. 17%'
  ) as contem_dispositivo_vetado
from public.unidades_pedagogicas
where curso_conteudo_id = 70;
