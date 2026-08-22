-- Pos-check SOMENTE LEITURA da OPERACAO C (correcao taxonomica de Q683,
-- assunto_id 47 -> 55). Nenhuma escrita.

select id, ativa, assunto_id, materia_id, banca, ano, length(enunciado) as len
from public.questoes where id = 683;

select count(*) as vinculos_q683 from public.questao_unidades_pedagogicas where questao_id = 683;

select count(*) as total_alt, count(*) filter (where correta) as total_corretas
from public.alternativas where questao_id = 683;

-- Estado LIVE atualizado das candidatas ativas do conteudo 22 (Classes de
-- palavras, ja concluido) apos Q683 sair do assunto 47. Esperado: 20
-- (era 21 no checkpoint historico da conclusao daquele conteudo).
select count(*) as candidatas_ativas_conteudo_22_live
from public.questoes q
join public.curso_conteudos cc on cc.id = 22
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

-- Confirma que os vinculos/unidades do conteudo 22 nao mudaram.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) as unidades_22,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) as vinculos_22;

select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;
