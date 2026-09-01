-- Pos-check SOMENTE LEITURA do saneamento taxonomico dedicado da Q314
-- (Tabela-verdade -> Proposicoes e conectivos).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO fecha a ordem 85, NAO toca Q75/Q89, e NAO reabre
-- a curadoria da ordem 84.

-- 1) Estado atual da Q314: assunto_id, ativa, conteudo/gabarito/metadados.
--    Esperado: assunto_id=36, ativa=true, banca='Papiro', concurso=
--    'PAPIRO - Adaptada do padrão Fundatec 2025/2026', ano=2026.
select id, assunto_id, ativa, banca, concurso, ano, enunciado
from public.questoes
where id = 314;

-- 2) Vinculos da Q314. Esperado: exatamente 1 linha, apontando para
--    6683c484-74a7-4b07-9cda-1a72190e6445.
select qup.questao_id, qup.unidade_pedagogica_id, u.titulo, u.curso_conteudo_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 314;

-- 3) Confirma que Q314 NAO possui nenhum vinculo em Tabela-verdade
--    (curso_conteudo_id = 2). Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 314 and u.curso_conteudo_id = 2;

-- 4) Vinculos totais da unidade destino (Proposicoes e conectivos).
--    Esperado: 4 linhas — 74, 87, 313, 314.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445'
order by qup.questao_id;

-- 5) Gabarito e alternativas da Q314 inalterados. Esperado: 5 linhas,
--    ordem 1 com correta=true e texto='P e Q são ambas verdadeiras.'.
select ordem, texto, correta
from public.alternativas
where questao_id = 314
order by ordem;

-- 6) Confirma que a explicacao da Q314 nao foi tocada (mesmo raciocinio
--    de conjuncao). Esperado: ambas checagens = true.
select
  position('CONJUNÇÃO' in explicacao) > 0 as contem_conjuncao,
  position('V ∧ V = V' in explicacao) > 0 as contem_regra_v_e_v
from public.questoes where id = 314;

-- 7) Confirma que Q89 e Q75 permanecem intactas: ambas assunto_id=38,
--    ativas, e Q89 com 0 vinculos (curadoria final da ordem 85 ainda
--    pendente). Esperado: id 75 e 89, assunto_id=38, ativa=true,
--    vinculos=0 para ambas.
select q.id, q.assunto_id, q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as vinculos
from public.questoes q
where q.id in (75, 89)
order by q.id;

-- 8) Candidatas LIVE remanescentes do assunto 38 (Tabela-verdade) apos
--    o saneamento. Esperado: exatamente 2 linhas (75, 89).
select id, ativa
from public.questoes
where ativa = true and assunto_id = 38
order by id;

-- 9) Confirma que a ordem 84 nao foi reaberta: a unidade de Proposicoes
--    e conectivos permanece ativa e o curso_conteudo_id=1 permanece
--    associado ao assunto_id=36. Confirma tambem contagem geral do
--    sistema para detectar qualquer efeito colateral inesperado.
select
  (select ativa from public.unidades_pedagogicas where id = '6683c484-74a7-4b07-9cda-1a72190e6445') as unidade_destino_ativa,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
