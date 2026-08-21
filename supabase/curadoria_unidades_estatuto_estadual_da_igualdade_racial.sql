-- Curadoria das unidades pedagogicas de Estatuto Estadual da Igualdade Racial
-- (curso_conteudos.id = 68), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_estadual_da_igualdade_racial.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 68, assunto "Estatuto Estadual da Igualdade Racial")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto Estadual da Igualdade Racial
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_estadual_da_igualdade_racial*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 68;
  v_unidade_1_id constant uuid := 'f0f6bae6-df70-450a-b4ee-3d9747962c2e';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto Estadual da Igualdade Racial",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto Estadual da Igualdade Racial'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto Estadual da Igualdade Racial nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 68 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 68 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto Estadual da Igualdade Racial',
    escopo = 'Estatuto Estadual da Igualdade Racial (Lei Estadual RS nº 13.694/2011): objeto da lei e definição de discriminação racial; mercado de trabalho (acesso a cargos públicos, iniciativa privada, formação profissional, emprego e geração de renda); saúde da população negra e de remanescentes de quilombos; educação e cultura (quesito raça em registros administrativos, datas comemorativas cívicas, capoeira, acesso ao ensino gratuito e a atividades esportivas, diversidade racial em debates, literatura negra, cultura Hip-Hop, pesquisa em pós-graduação); e campanhas publicitárias do Poder Público.',
    artigos_esperados = array['art. 1º, caput','art. 1º, §1º','art. 4º, caput','art. 5º, parágrafo único','art. 7º, II','art. 10, caput','art. 11, caput','art. 12, caput','art. 13, caput','art. 14, caput','art. 15, caput','art. 16, caput','art. 17, caput','art. 17, parágrafo único','art. 18, caput','art. 20, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
