-- Curadoria das unidades pedagogicas de Denotação e conotação
-- (curso_conteudos.id = 24), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/denotacao_e_conotacao.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 24, assunto "Denotação e conotação")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Denotação e conotação
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_denotacao_e_conotacao*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 24;
  v_unidade_1_id constant uuid := 'f1377f8b-348e-4da6-9713-e901ce5ea516';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Denotação e conotação",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Denotação e conotação'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Denotação e conotação nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 24 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 24 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Denotação e conotação',
    escopo = 'Denotação e conotação, com foco na distinção entre emprego literal/referencial e emprego figurado/associativo de palavras e expressões em contexto — a classificação depende sempre do uso concreto no enunciado, não da palavra isolada (a mesma palavra pode ser denotativa em um contexto e conotativa em outro). DENOTAÇÃO: emprego literal/referencial, em que o termo designa diretamente aquilo a que se refere, sem produzir leitura figurada relevante ("sentido literal ou básico" como auxílio didático, não como definição absoluta de "significado de dicionário", já que dicionários também registram acepções figuradas). CONOTAÇÃO: emprego em que o termo adquire valor figurado, associativo, expressivo ou contextual para além da referência literal imediata — podendo envolver metáfora, expressão idiomática, associação simbólica ou outros usos figurados, sem se restringir apenas a metáfora. Método de resolução: (1) localizar a palavra/expressão relevante; (2) observar a frase inteira; (3) testar a leitura literal; (4) perguntar se essa leitura é semanticamente plausível no contexto; (5) se não for, identificar qual ideia figurada está sendo transmitida; (6) comparar as alternativas. Regra de bolso: "não pergunte o que a palavra significa sozinha; pergunte o que ela significa nessa frase" e "pergunte se aquilo poderia acontecer literalmente na situação descrita" — com o limite explícito de que a heurística "termo abstrato recebendo propriedade física" (como em "peso da responsabilidade") é apenas pista/sinal de uso figurado, não regra universal aplicável mecanicamente a qualquer combinação de abstrato com propriedade física; a decisão final depende sempre do contexto concreto. A prática disponível é integralmente autoral e suplementar (COBERTURA_SUPLEMENTAR_DENOTACAO_CONOTACAO), sem evidência de incidência real da banca no corpus atual — este conteúdo NÃO absorve o estudo amplo de sinonímia/sentido contextual (ver Significação das palavras) nem a identificação técnica de figuras de linguagem específicas (metáfora, metonímia, hipérbole, ironia etc.), limitando-se ao contraste literal × figurado.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
