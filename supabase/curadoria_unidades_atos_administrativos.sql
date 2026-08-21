-- Curadoria das unidades pedagogicas de Atos administrativos
-- (curso_conteudos.id = 54), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/atos_administrativos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 54, assunto "Atos administrativos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Atos administrativos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_atos_administrativos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 54;
  v_unidade_1_id constant uuid := '85323ce5-772b-4bf1-bc32-a79e2316158b';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Atos administrativos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Atos administrativos'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Atos administrativos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 54 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 54 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Atos administrativos',
    escopo = 'Atos administrativos: requisitos/elementos segundo a doutrina de Hely Lopes Meirelles (competência, finalidade, forma, motivo e objeto); atributos (presunção de legitimidade, imperatividade, autoexecutoriedade, coercibilidade/exigibilidade); a distinção doutrinária entre validade, eficácia e efetividade e o princípio constitucional da publicidade administrativa (art. 37, caput) — quando a publicidade/divulgação for juridicamente exigida para que determinado ato produza efeitos externos, sua ausência pode afetar sua eficácia, sem confundir publicidade com requisito universal de validade de todo ato administrativo; e extinção dos atos administrativos — anulação e revogação por autotutela administrativa (art. 53, Lei nº 9.784/1999, e Súmula 473 do STF) e convalidação de defeitos sanáveis (art. 55, Lei nº 9.784/1999).',
    artigos_esperados = array['art. 37, caput','art. 53','art. 55'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
