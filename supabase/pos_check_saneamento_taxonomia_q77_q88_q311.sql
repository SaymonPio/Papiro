-- Pos-check SOMENTE LEITURA do saneamento taxonomico dedicado da
-- Q77 + Q88 + Q311 (Leis de De Morgan -> Negacao de proposicoes).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO fecha a ordem 86, NAO altera a unidade de De
-- Morgan, e NAO reabre a curadoria da ordem 83.

-- 1) Estado atual de Q77/Q88/Q311: assunto_id, ativa, proveniencia.
--    Esperado: assunto_id=35 para as 3, ativa=true, proveniencia
--    inalterada.
select id, assunto_id, ativa, banca, concurso, ano
from public.questoes
where id in (77, 88, 311)
order by id;

-- 2) Vinculos das 3 questoes. Esperado: 3 linhas, todas apontando para
--    c6ccefae-14df-4760-8c1d-2822090a2a93.
select qup.questao_id, qup.unidade_pedagogica_id, u.titulo, u.curso_conteudo_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id in (77, 88, 311)
order by qup.questao_id;

-- 3) Confirma que nenhuma das 3 possui vinculo em Leis de De Morgan
--    (curso_conteudo_id = 4). Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id in (77, 88, 311) and u.curso_conteudo_id = 4;

-- 4) Vinculos totais da unidade destino (Negacao de proposicoes).
--    Esperado: 7 linhas — 77, 81, 86, 88, 311, 312, 337.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93'
order by qup.questao_id;

-- 5) Gabarito e alternativas das 3 questoes inalterados. Esperado: 5
--    linhas cada, com a correta na ordem esperada (77: ordem1 "Pedro
--    não fez a vacina ou teve febre amarela."; 88: ordem2 "Artur não
--    fez a vacina da Covid ou não fez a vacina da gripe."; 311: ordem1
--    "Não P ou não Q.").
select questao_id, ordem, texto, correta
from public.alternativas
where questao_id in (77, 88, 311)
order by questao_id, ordem;

-- 6) Confirma que as explicacoes nao foram tocadas (mesmo raciocinio de
--    De Morgan armazenado). Esperado: todas as 3 checagens = true.
select
  (select position('Regra de De Morgan para Conjunção' in explicacao) > 0 from public.questoes where id = 77) as q77_explicacao_ok,
  (select position('1ª Lei de De Morgan' in explicacao) > 0 from public.questoes where id = 88) as q88_explicacao_ok,
  (select position('Teorema de De Morgan' in explicacao) > 0 from public.questoes where id = 311) as q311_explicacao_ok;

-- 7) Candidatas LIVE remanescentes do assunto 34 (Leis de De Morgan)
--    apos o saneamento. Esperado: 0 linhas.
select id, ativa
from public.questoes
where ativa = true and assunto_id = 34;

-- 8) Confirma que a unidade de De Morgan permanece intocada: ativa,
--    0 vinculos, titulo/escopo/artigos_esperados inalterados.
select id, titulo, escopo, artigos_esperados, ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.unidade_pedagogica_id = u.id) as vinculos
from public.unidades_pedagogicas u
where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

-- 9) Confirma que Q81, Q86, Q312, Q337 (vinculos pre-existentes)
--    permanecem intactos na unidade destino. Esperado: 4 linhas, todas
--    com vinculo_neste_conteudo = 1.
select q.id,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id and qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93') as vinculo_neste_conteudo
from public.questoes q
where q.id in (81, 86, 312, 337)
order by q.id;

-- 10) Estado geral do sistema para detectar qualquer efeito colateral
--     inesperado.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
