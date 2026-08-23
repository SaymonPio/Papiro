-- Curadoria das unidades pedagogicas de Interpretação de textos
-- (curso_conteudos.id = 12), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/interpretacao_de_textos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 12, assunto "Interpretação de textos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Interpretação de textos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_interpretacao_de_textos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 12;
  v_unidade_1_id constant uuid := '138aafa7-066c-40fd-9fa5-7f1b90406db2';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Interpretação de textos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Interpretação de textos'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Interpretação de textos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 12 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 12 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Interpretação de textos',
    escopo = 'Interpretação de textos da Língua Portuguesa, com núcleo pré-edital fundamentado exclusivamente na habilidade efetivamente cobrada pela questão real deste corpus: compreensão global do conteúdo textual e verificação de fidelidade ao que o texto efetivamente afirma, distinguindo informação explícita, inferência sustentada pelo texto, extrapolação (acrescentar algo que o texto não autoriza), contradição (afirmar o oposto do que o autor disse) e redução indevida (transformar afirmação nuançada em afirmação excessivamente restrita) — com atenção especial a palavras generalizantes ("desaparecer", "todos", "sempre") que costumam sinalizar extrapolação em assertivas de múltipla escolha. Método de resolução: localizar o comando, identificar exatamente o que cada assertiva/alternativa afirma, voltar ao trecho relevante do texto, verificar se a afirmação é sustentada, e só então marcar. Como cobertura suplementar (sustentada apenas por questões autorais, sem incidência real neste corpus): identificação da tese em texto dissertativo-argumentativo (distinguindo tese de tema, exemplo, argumento ou conclusão isolada) e o contraste entre inferência válida e os três erros clássicos de leitura (extrapolação, redução, contradição). Regra de bolso: "se a alternativa diz mais do que o texto permite, desconfie" — mas sem transformar isso em regra absoluta, já que nem toda inferência válida precisa estar escrita literalmente no texto.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
