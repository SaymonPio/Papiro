-- Pos-check SOMENTE LEITURA do saneamento taxonomico da questao 878
-- (Classes de palavras -> Implicitos e subentendidos). Nenhuma escrita.

-- 1) Q878: assunto_id, ativa, campos de conteudo/proveniencia.
--    Esperado: assunto_id=46, ativa=true, demais campos inalterados.
select id, assunto_id, ativa, banca, concurso, ano, fonte
from public.questoes
where id = 878;

-- 2) Enunciado e explicacao de Q878 inalterados.
select
  position('o adjetivo "novos" informa que' in enunciado) > 0 as enunciado_intacto,
  position('BIZU DE PROVA' in explicacao) > 0 as explicacao_intacta
from public.questoes
where id = 878;

-- 3) Gabarito/alternativas de Q878 inalterados. Esperado: 5 alternativas,
--    ordem_correta=1.
select
  (select count(*) from public.alternativas where questao_id = 878) as total_alternativas,
  (select ordem from public.alternativas where questao_id = 878 and correta = true) as ordem_correta;

-- 4) Vinculo de Q878: exatamente 1, na unidade de Implicitos e
--    subentendidos.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 878;

-- 5) Q878 nao tem vinculo em Classes de palavras (curso_conteudo_id 22).
--    Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 878 and u.curso_conteudo_id = 22;

-- 6) Implicitos e subentendidos: total de vinculos e questoes distintas
--    agora 1/1 (Q878, primeiro vinculo deste conteudo).
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25;

select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25
order by qup.questao_id;

-- 7) Unidade de Implicitos e subentendidos inalterada em metadados.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 25;

-- 8) Implicitos e subentendidos: candidatas ativas agora incluem Q878
--    junto das 3 ja conhecidas (Q234, Q235, Q236) — 4 no total, mas
--    somente Q878 tem vinculo ate a curadoria final da ordem 73 ser
--    aplicada.
select id, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where ativa = true and materia_id = 6 and assunto_id = 46
order by id;

-- 9) Classes de palavras (conteudo 22): vinculos NAO mudaram por esta
--    operacao. Esperado: 16 (baseline live confirmado antes desta
--    operacao — diverge do "17" documentado nos artefatos historicos
--    por causa da PENDENCIA_DE_CONSISTENCIA_Q684, pre-existente e fora
--    de escopo, nao esta ligada a Q878).
select count(*) as total_vinculos_classes_de_palavras
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 22;

-- 10) Achados colaterais fora de escopo permanecem exatamente como
--     estavam antes desta operacao (nenhum write foi feito sobre eles):
--     Q683 assunto_id=55 com 1 vinculo (Coesao textual, ja realocada em
--     sessao anterior — PENDENCIA_DE_CONSISTENCIA_Q683, doc orfa em
--     Classes de palavras); Q684 assunto_id=47, ativa, 0 vinculos
--     (decisao pedagogica anterior: duplicata de Q319 — PENDENCIA_DE_
--     CONSISTENCIA_Q684, mapa.json de Classes de palavras diverge do
--     live).
select id, assunto_id, ativa,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where id in (683, 684)
order by id;

-- 11) Estado geral do sistema: nenhuma questao/alternativa/unidade nova,
--     vinculos cresceram exatamente 1.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
