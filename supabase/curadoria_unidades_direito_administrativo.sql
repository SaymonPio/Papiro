-- Curadoria das unidades pedagogicas de Direito Administrativo
-- (curso_conteudos.id = 58), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/direito_administrativo.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 58, assunto "Direito Administrativo")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Direito Administrativo
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_direito_administrativo*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 58;
  v_unidade_1_id constant uuid := '1172a885-1419-4ad8-b728-1a0c7492c133';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Direito Administrativo",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Direito Administrativo'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Direito Administrativo nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 58 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 58 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Direito Administrativo',
    escopo = 'Direito Administrativo: princípios expressos da Administração Pública (legalidade, publicidade, eficiência — Constituição Federal, art. 37, caput) e prazo de validade do concurso público (Constituição Federal, art. 37, III); organização administrativa — entidades da administração indireta (autarquias, empresas públicas, sociedades de economia mista e fundações públicas — Decreto-Lei nº 200/1967, art. 4º, II); regime jurídico dos agentes públicos (distinção doutrinária entre servidor estatutário e empregado público celetista, sem dispositivo legal específico atribuído); e autotutela administrativa (anulação e revogação de atos — art. 53, Lei nº 9.784/1999, e Súmula 473 do STF). A autotutela é instituto também testado no conteúdo "Atos administrativos" (curso_conteudo_id 54); os princípios do art. 37 também aparecem, com outros incisos e enfoque, no conteúdo "Constituição Federal de 1988" (curso_conteudo_id 57) — sobreposições temáticas conhecidas, não questões duplicadas.',
    artigos_esperados = array['art. 37, caput','art. 37, III','art. 4º, II','art. 53'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
