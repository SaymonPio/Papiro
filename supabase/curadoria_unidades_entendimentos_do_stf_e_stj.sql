-- Curadoria das unidades pedagogicas de Entendimentos do STF e STJ
-- (curso_conteudos.id = 80), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/entendimentos_do_stf_e_stj.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 80, assunto "Entendimentos do STF e STJ")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Entendimentos do STF e STJ
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_entendimentos_do_stf_e_stj*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 80;
  v_unidade_1_id constant uuid := '572c64ec-c7bb-412e-ab3d-94435ed7df12';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Entendimentos do STF e STJ",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Entendimentos do STF e STJ'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Entendimentos do STF e STJ nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 80 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 80 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Entendimentos do STF e STJ',
    escopo = 'Entendimentos consolidados do STF e do STJ: Súmula Vinculante nº 11, STF, que restringe o uso de algemas a casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia, por parte do preso ou de terceiros, exigindo justificação da excepcionalidade por escrito, sob pena de responsabilidade disciplinar, civil e penal do agente ou da autoridade e de nulidade da prisão ou do ato processual a que se refere; e a tese fixada no Tema 280 de Repercussão Geral (RE 603.616/RO), STF, sobre a inviolabilidade domiciliar (art. 5º, XI, da CF): a entrada forçada em domicílio sem mandado judicial só é lícita, inclusive no período noturno, quando amparada em fundadas razões, devidamente justificadas a posteriori, que indiquem situação de flagrante delito no interior do imóvel — o STF fixou essa tese e o STJ a aplica e desenvolve em sua jurisprudência sobre casos concretos. A inviolabilidade domiciliar não é absoluta, mas comporta apenas as hipóteses constitucionais excepcionais (flagrante delito, desastre, prestar socorro, ou determinação judicial durante o dia), com a exigência jurisprudencial adicional de fundadas razões para o ingresso forçado especificamente fundado em flagrante.',
    artigos_esperados = array['art. 5º, XI'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
