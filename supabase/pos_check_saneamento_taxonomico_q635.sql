-- Pos-check SOMENTE LEITURA do saneamento taxonomico da questao 635
-- (Internet e navegadores -> Correio eletronico). Nenhuma escrita.

-- 1) Q635: assunto_id, ativa, campos de conteudo/proveniencia.
--    Esperado: assunto_id=60, ativa=true, demais campos inalterados.
select id, assunto_id, ativa, banca, concurso, ano, fonte
from public.questoes
where id = 635;

-- 2) Enunciado e explicacao de Q635 inalterados.
select
  position('IMAP' in enunciado) > 0 as enunciado_intacto,
  position('Mnemônico dos Protocolos' in explicacao) > 0 as explicacao_intacta
from public.questoes
where id = 635;

-- 3) Gabarito/alternativas de Q635 inalterados. Esperado: 5 alternativas,
--    ordem_correta=3 (C).
select
  (select count(*) from public.alternativas where questao_id = 635) as total_alternativas,
  (select ordem from public.alternativas where questao_id = 635 and correta = true) as ordem_correta;

-- 4) Vinculo de Q635: exatamente 1, na unidade de Correio eletronico.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 635;

-- 5) Q635 nao tem vinculo em Internet e navegadores (curso_conteudo_id
--    38). Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 635 and u.curso_conteudo_id = 38;

-- 6) Correio eletronico: total de vinculos e questoes distintas agora
--    1/1 (Q635, primeiro vinculo deste conteudo).
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 39;

-- 7) Unidade de Correio eletronico inalterada em metadados.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 39;

-- 8) Correio eletronico: candidatas ativas agora sao 10 (as 9 antigas +
--    Q635), mas somente Q635 tem vinculo ate a curadoria final da
--    ordem 82 ser aplicada.
select id, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where ativa = true and materia_id = 9 and assunto_id = 60
order by id;

-- 9) Internet e navegadores (curso_conteudo_id 38, ainda pendente):
--    vinculos NAO mudaram por esta operacao. Esperado: 0 (nenhuma
--    curadoria final foi aplicada la ainda).
select count(*) as total_vinculos_internet_navegadores
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 38;

-- 10) Confirma que Q635 nao aparece mais entre as candidatas ativas do
--     assunto 62 (Internet e navegadores). Esperado: 0 linhas.
select id from public.questoes
where id = 635 and ativa = true and materia_id = 9 and assunto_id = 62;

-- 11) Estado geral do sistema: nenhuma questao/alternativa/unidade
--     nova, vinculos cresceram exatamente 1.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
