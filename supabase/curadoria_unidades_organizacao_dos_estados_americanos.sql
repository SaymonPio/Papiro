-- Curadoria das unidades pedagogicas de Organização dos Estados Americanos
-- (curso_conteudos.id = 86), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/organizacao_dos_estados_americanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 86, assunto "Organização dos Estados Americanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Organização dos Estados Americanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_organizacao_dos_estados_americanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 86;
  v_unidade_1_id constant uuid := '7a9e1731-626a-44cc-90f0-004faed11e0f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Organização dos Estados Americanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Organização dos Estados Americanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Organização dos Estados Americanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 86 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 86 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Organização dos Estados Americanos',
    escopo = 'Organização dos Estados Americanos (Carta de Bogotá, 1948): a OEA constitui, dentro das Nações Unidas, um organismo regional (art. 1); seus propósitos essenciais incluem garantir a paz e a segurança continentais (art. 2, "a"), promover e consolidar a democracia representativa (art. 2, "b") e promover, por meio da ação cooperativa, o desenvolvimento econômico, social e cultural dos Estados membros (art. 2, "f"); a Comissão Interamericana de Direitos Humanos é um dos órgãos por meio dos quais a OEA realiza seus fins (art. 53, "e").',
    artigos_esperados = array['art. 1','art. 2, caput','art. 2, "a"','art. 2, "b"','art. 2, "f"','art. 53, "e"'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
