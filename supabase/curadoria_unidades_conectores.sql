-- Curadoria das unidades pedagogicas de Conectores
-- (curso_conteudos.id = 14), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/conectores.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 14, assunto "Conectores")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Conectores
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_conectores*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 14;
  v_unidade_1_id constant uuid := 'd1e31767-d27d-431b-ba59-7a2008c7473d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Conectores",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Conectores'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Conectores nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 14 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 14 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Conectores',
    escopo = 'Conectores da Língua Portuguesa: classificação semântica de conjunções coordenativas (adversativas — mas, porém, contudo, todavia, entretanto, no entanto — compartilhando valor geral de oposição/contraste, sem serem substituíveis entre si em qualquer contexto de forma absoluta, pois a substituição concreta depende de construção sintática, posição, pontuação, registro e nuance discursiva; aditivas; conclusivas) e subordinativas (causais, condicionais, concessivas, temporais), com foco na relação lógico-semântica que o conector estabelece entre os segmentos, não na memorização isolada de listas; falsos amigos frequentes em prova (conquanto — concessivo — × quando — tipicamente temporal; porquanto — tradicionalmente causal/explicativo — × portanto — conclusivo; caso — condicional — × mas — adversativo); estruturas correlativas (tão...quanto = comparação; tão...que = oração/estrutura consecutiva, expressando consequência decorrente da intensidade; mas também = valor predominantemente aditivo, podendo carregar nuance adversativa/contrastiva quando em contraste com conteúdo negativo anterior no texto); e o método de resolução (localizar o conector, ler as duas ideias conectadas, perguntar qual relação semântica existe entre elas, testar a substituição mentalmente e verificar se a relação semântica se mantém — nunca decidir apenas pela semelhança gráfica ou se a palavra "parece caber").',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
