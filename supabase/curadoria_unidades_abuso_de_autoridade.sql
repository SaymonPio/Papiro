-- Curadoria das unidades pedagogicas de Abuso de Autoridade
-- (curso_conteudos.id = 62), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/abuso_de_autoridade.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 62, assunto "Abuso de Autoridade")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Abuso de Autoridade
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_abuso_de_autoridade*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 62;
  v_unidade_1_id constant uuid := '7f7298d6-c0b8-4907-8f72-1072a0796a5f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Abuso de Autoridade",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Abuso de Autoridade'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Abuso de Autoridade nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 62 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 62 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Abuso de Autoridade',
    escopo = 'Lei de Abuso de Autoridade (Lei nº 13.869/2019): elemento subjetivo geral do crime (finalidade específica de prejudicar, beneficiar ou por mero capricho; irrelevância da mera divergência de interpretação); ação penal pública incondicionada e ação privada subsidiária; efeitos da condenação (inabilitação e perda do cargo, condicionados à reincidência) e penas restritivas de direitos; independência das instâncias civil, administrativa e penal; e crimes em espécie (constranger preso ou detento, inovação artificiosa do local em investigação).',
    artigos_esperados = array['art. 1º, §1º','art. 1º, §2º','art. 3º, caput','art. 3º, §1º','art. 3º, §2º','art. 4º, III','art. 4º, parágrafo único','art. 5º, II','art. 7º, caput','art. 13','art. 13, caput','art. 13, I','art. 13, II','art. 13, III','art. 23, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
