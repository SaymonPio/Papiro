-- Curadoria das unidades pedagogicas de Classes de palavras
-- (curso_conteudos.id = 22), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/classes_de_palavras.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 22, assunto "Classes de palavras")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Classes de palavras
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_classes_de_palavras*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 22;
  v_unidade_1_id constant uuid := '3f215008-367b-4890-9588-525980baefc1';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Classes de palavras",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Classes de palavras'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Classes de palavras nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 22 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 22 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Classes de palavras',
    escopo = 'Classes de palavras da Língua Portuguesa, organizadas em três eixos: EIXO A — pronomes, artigos e palavras homônimas: distinção entre pronome demonstrativo, pronome relativo (e sua diferença frente à conjunção integrante), pronome oblíquo átono e artigo definido (inclusive em contrações com preposições, como do/da/no/na/ao), e a regra do pronome relativo possessivo "cujo" (retoma o possuidor antecedente, concorda com o elemento possuído). EIXO B — advérbios: classificação morfológica (invariabilidade) e circunstâncias (tempo, lugar, modo, intensidade, dúvida), incluindo o contraste entre "bastante" advérbio (invariável) e "bastante(s)" pronome indefinido (variável). EIXO C — substantivo, adjetivo e formação de palavras: reconhecimento de substantivo e adjetivo conforme a função no sintagma, flexões nominais (gênero e número, em oposição às flexões verbais de tempo/modo/pessoa), adjetivos uniformes quanto ao gênero, e formação de palavras por derivação (palavra primitiva × derivada, prefixação).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
