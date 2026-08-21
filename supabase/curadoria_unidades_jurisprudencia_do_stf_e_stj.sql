-- Curadoria das unidades pedagogicas de Jurisprudência do STF e STJ
-- (curso_conteudos.id = 69), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/jurisprudencia_do_stf_e_stj.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 69, assunto "Jurisprudência do STF e STJ")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Jurisprudência do STF e STJ
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_jurisprudencia_do_stf_e_stj*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 69;
  v_unidade_1_id constant uuid := '8e1d1204-1f66-431c-a95f-6403e77882dc';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Jurisprudência do STF e STJ",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Jurisprudência do STF e STJ'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Jurisprudência do STF e STJ nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 69 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 69 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Jurisprudência do STF e STJ',
    escopo = 'Jurisprudência do STF e STJ aplicada à atuação policial: Súmula Vinculante nº 11 (uso excepcional e justificado de algemas); Tema 280 de repercussão geral do STF (RE 603.616) sobre entrada forçada em domicílio sem mandado judicial, interpretando o art. 5º, XI, da Constituição Federal; ADCs 43, 44 e 54 do STF (2019) sobre presunção de inocência e constitucionalidade do art. 283 do Código de Processo Penal quanto à execução da pena antes do trânsito em julgado, considerada a jurisprudência superveniente específica do Tribunal do Júri (Tema 1068); ADO 26 e MI 4733 do STF (2019) sobre a equiparação da homofobia e da transfobia ao crime de racismo (Lei nº 7.716/1989) até edição de lei específica pelo Congresso Nacional; e Tema 541 de repercussão geral do STF (ARE 654.432) sobre a vedação ao exercício do direito de greve por policiais civis, em conjunto com o regime constitucional de remuneração por subsídio (art. 39, §4º, e art. 144, §9º) e de aposentadoria especial de policiais (art. 40, §4º-B, incluído pela EC nº 103/2019).',
    artigos_esperados = array['art. 5º, XI','art. 5º, LVII','art. 39, §4º','art. 40, §4º-B','art. 144, §9º','art. 283'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
