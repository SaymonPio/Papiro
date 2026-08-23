-- Curadoria das unidades pedagogicas de Significação das palavras
-- (curso_conteudos.id = 23), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/significacao_das_palavras.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 23, assunto "Significação das palavras")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Significação das palavras
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_significacao_das_palavras*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 23;
  v_unidade_1_id constant uuid := '290650b5-0f55-49e1-871e-932003447e41';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Significação das palavras",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Significação das palavras'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Significação das palavras nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 23 nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_1_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_1_id;
  end if;

  -- Decisao aprovada: manter 1 unica unidade — nenhuma outra pode existir
  -- para este conteudo (execucao repetida nao deveria encontrar uma ordem
  -- criada por engano em outra etapa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem <> 1
  ) then
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 23 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Significação das palavras',
    escopo = 'Significação das palavras da Língua Portuguesa, com núcleo pré-edital definido pelas questões reais deste corpus: significado lexical de uma palavra dentro do seu contexto de ocorrência, e sinonímia contextual — verificar, antes de aceitar uma substituição lexical, se o sentido, o contexto específico de ocorrência, o registro/nuance de quem fala, a classe gramatical/função sintática e a correção gramatical da construção permanecem compatíveis, e se o sentido global do trecho é preservado (sinônimo de dicionário não é substituição automaticamente válida). Distinção explícita entre sinonímia contextual (equivalência aceitável dentro do contexto dado, com nuances de registro entre os termos — como "caquéticos", empregado de forma pejorativa pelos jovens, e "matusaléns", empregado de forma humorística/afetiva pelo narrador sobre os próprios pais, ambos designando "pessoas mais velhas" apenas dentro da lógica específica do texto em que ocorrem) e sinonímia absoluta (validade em qualquer contexto, que não deve ser ensinada como regra geral). Como cobertura secundária/suplementar (sustentada apenas por questão autoral, sem incidência real neste corpus): paronímia — pares de palavras com grafia/pronúncia semelhantes e significados distintos (como "eminente", que significa ilustre, elevado ou notável, e "iminente", que significa prestes a acontecer).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
