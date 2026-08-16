-- ETAPA 2 do PROMPT MESTRE de curadoria das unidades pedagógicas da Lei
-- Maria da Penha — extração COMPLETA das 28 questões candidatas, para
-- leitura e classificação semântica (Etapa 3, feita por leitura humana do
-- enunciado + de TODAS as alternativas — nunca por palavra-chave/título/
-- banca/concurso isolados).
--
-- SOMENTE LEITURA. Nenhum INSERT/UPDATE/DELETE.
--
-- Uma linha por questão candidata (mesma definição de sempre: ativa=true,
-- materia_id bate com a matéria real do conteúdo 53, assunto_id bate quando
-- o conteúdo tiver um definido), com:
--   - enunciado completo;
--   - banca/concurso/ano/dificuldade;
--   - matéria/assunto (nome);
--   - TODAS as alternativas em ordem, cada uma com o texto completo e se é
--     a correta;
--   - classificações já existentes em unidade pedagógica (esperado: [] para
--     todas as 28, conforme confirmado em
--     diagnostico_revalidacao_pre_classificacao_lei_maria_penha.sql).
--
-- Cole no SQL Editor do Supabase, rode, e use o resultado completo (as 28
-- linhas, com todas as alternativas) como insumo real da classificação —
-- nunca a lista de hipóteses do prompt mestre isoladamente.

select
  q.id as questao_id,
  q.enunciado,
  q.banca,
  q.concurso,
  q.ano,
  q.dificuldade,
  m.nome as materia_nome,
  a.nome as assunto_nome,
  (
    select jsonb_agg(
             jsonb_build_object('ordem', alt.ordem, 'texto', alt.texto, 'correta', alt.correta)
             order by alt.ordem
           )
    from public.alternativas alt
    where alt.questao_id = q.id
  ) as alternativas,
  (
    select jsonb_agg(
             jsonb_build_object('unidade_id', u.id, 'ordem', u.ordem, 'titulo', u.titulo)
             order by u.ordem
           )
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id
      and u.curso_conteudo_id = 53
  ) as classificacoes_existentes
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
left join public.materias m on m.id = q.materia_id
left join public.assuntos a on a.id = q.assunto_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
order by q.id;
