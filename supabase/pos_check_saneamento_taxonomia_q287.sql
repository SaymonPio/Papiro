-- Pos-check SOMENTE LEITURA do saneamento taxonomico dedicado da Q287
-- (Quantificadores -> Negacao de proposicoes).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO fecha a ordem 89, NAO toca Q83/Q288, e NAO reabre
-- a curadoria da ordem 83.

-- 1) Estado atual da Q287: assunto_id, ativa, proveniencia.
--    Esperado: assunto_id=35, ativa=true, banca='Papiro', concurso=
--    'PAPIRO - Adaptada do padrão Fundatec 2025/2026', ano=2026.
select id, assunto_id, ativa, banca, concurso, ano, enunciado
from public.questoes
where id = 287;

-- 2) Vinculos da Q287. Esperado: exatamente 1 linha, apontando para
--    c6ccefae-14df-4760-8c1d-2822090a2a93.
select qup.questao_id, qup.unidade_pedagogica_id, u.titulo, u.curso_conteudo_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 287;

-- 3) Confirma que Q287 NAO possui vinculo em Quantificadores
--    (curso_conteudo_id = 7). Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 287 and u.curso_conteudo_id = 7;

-- 4) Vinculos totais da unidade destino (Negacao de proposicoes).
--    Esperado: 8 linhas — 77, 81, 86, 88, 287, 311, 312, 337.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93'
order by qup.questao_id;

-- 5) Gabarito e alternativas da Q287 inalterados. Esperado: 5 linhas,
--    ordem 1 com correta=true e texto='Pelo menos um candidato não foi
--    aprovado.'.
select ordem, texto, correta
from public.alternativas
where questao_id = 287
order by ordem;

-- 6) Confirma que a explicacao da Q287 nao foi tocada (mesmo raciocinio
--    de negacao do quantificador universal). Esperado: true.
select position('Negação do TODO' in explicacao) > 0 as contem_bizu_original
from public.questoes where id = 287;

-- 7) Confirma que Q83 e Q288 permanecem intactas: ambas assunto_id=33,
--    ativas, e 0 vinculos (curadoria final da ordem 89 ainda
--    pendente). Esperado: id 83 e 288, assunto_id=33, ativa=true,
--    vinculos=0 para ambas.
select q.id, q.assunto_id, q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as vinculos
from public.questoes q
where q.id in (83, 288)
order by q.id;

-- 8) Candidatas LIVE remanescentes do assunto 33 (Quantificadores)
--    apos o saneamento. Esperado: exatamente 2 linhas (83, 288).
select id, ativa
from public.questoes
where ativa = true and assunto_id = 33
order by id;

-- 9) Confirma que a unidade da ordem 89 permanece intocada (ativa, 0
--    vinculos, titulo/escopo/artigos_esperados inalterados). Confirma
--    tambem contagem geral do sistema.
select
  (select ativa from public.unidades_pedagogicas where id = 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c') as unidade_ordem89_ativa,
  (select count(*) from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c') as vinculos_ordem89,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
