-- Pos-check SOMENTE LEITURA do saneamento taxonomico da questao 279
-- (Reescrita de frases e textos -> Conectores). Nenhuma escrita.

-- 1) Q279: assunto_id, ativa, campos de conteudo/proveniencia.
--    Esperado: assunto_id=57, ativa=true, demais campos inalterados.
select id, assunto_id, ativa, banca, concurso, ano, fonte
from public.questoes
where id = 279;

-- 2) Enunciado e explicacao de Q279 inalterados.
select
  position('mantém o sentido de' in enunciado) > 0 as enunciado_intacto,
  position('BIZU DE PROVA' in explicacao) > 0 as explicacao_intacta
from public.questoes
where id = 279;

-- 3) Gabarito/alternativas de Q279 inalterados. Esperado: 5 alternativas,
--    ordem_correta=1.
select
  (select count(*) from public.alternativas where questao_id = 279) as total_alternativas,
  (select ordem from public.alternativas where questao_id = 279 and correta = true) as ordem_correta;

-- 4) Vinculo de Q279: exatamente 1, na unidade de Conectores.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 279;

-- 5) Q279 nao tem vinculo em Reescrita (curso_conteudo_id 21).
--    Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 279 and u.curso_conteudo_id = 21;

-- 6) Conectores: total de vinculos e questoes distintas agora 6/6,
--    incluindo os 5 antigos intactos.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 14;

select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 14
order by qup.questao_id;

-- 7) Unidade de Conectores inalterada em metadados.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 14;

-- 8) Reescrita (conteudo 21): candidatas ativas agora sao apenas Q72/Q280.
select id, assunto_id
from public.questoes
where ativa = true and materia_id = 6 and assunto_id = 49
order by id;

-- 9) Estado geral do sistema: nenhuma questao/alternativa/unidade nova,
--    vinculos cresceram exatamente 1.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
