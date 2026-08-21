-- Curadoria das unidades pedagogicas de Responsabilidade civil do Estado
-- (curso_conteudos.id = 61), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/responsabilidade_civil_do_estado.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 61, assunto "Responsabilidade civil do Estado")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Responsabilidade civil do Estado
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_responsabilidade_civil_do_estado*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 61;
  v_unidade_1_id constant uuid := 'd6f03d69-8943-4867-a2af-e37482d4ca99';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Responsabilidade civil do Estado",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Responsabilidade civil do Estado'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Responsabilidade civil do Estado nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 61 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 61 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Responsabilidade civil do Estado',
    escopo = 'Responsabilidade civil do Estado (Constituição Federal, art. 37, §6º): natureza objetiva da responsabilidade das pessoas jurídicas de direito público e das pessoas jurídicas de direito privado prestadoras de serviços públicos pelos danos causados por seus agentes, nessa qualidade, a terceiros; desnecessidade de prova de dolo ou culpa do agente na relação entre vítima e pessoa jurídica, exigidos dano e nexo causal com a atuação estatal; e direito de regresso contra o agente responsável nos casos de dolo ou culpa, conforme o Tema 940/STF (RE 1.027.633).',
    artigos_esperados = array['art. 37, §6º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
