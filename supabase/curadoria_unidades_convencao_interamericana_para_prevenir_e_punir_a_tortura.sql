-- Curadoria das unidades pedagogicas de Convenção Interamericana para Prevenir e Punir a Tortura
-- (curso_conteudos.id = 79), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/convencao_interamericana_para_prevenir_e_punir_a_tortura.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 79, assunto "Convenção Interamericana para Prevenir e Punir a Tortura")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Convenção Interamericana para Prevenir e Punir a Tortura
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_convencao_interamericana_para_prevenir_e_punir_a_tortura*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 79;
  v_unidade_1_id constant uuid := 'af995205-bb67-49e4-8ad1-151e339e892a';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Convenção Interamericana para Prevenir e Punir a Tortura",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Convenção Interamericana para Prevenir e Punir a Tortura'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Convenção Interamericana para Prevenir e Punir a Tortura nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 79 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 79 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Convenção Interamericana para Prevenir e Punir a Tortura',
    escopo = 'Convenção Interamericana para Prevenir e Punir a Tortura (Decreto nº 98.386/1989): definição de tortura, com exclusão condicionada de penas ou sofrimentos que sejam unicamente consequência de medidas legais, desde que não incluam os atos ou métodos vedados pelo próprio artigo (art. 2); responsabilidade do funcionário público que, podendo impedir a tortura, não o faz (art. 3, alínea a); irrelevância de ordens superiores para eximir da responsabilidade penal (art. 4); vedação a invocar circunstâncias excepcionais — estado de guerra, ameaça de guerra, estado de sítio ou emergência, comoção ou conflito interno, suspensão de garantias constitucionais, instabilidade política, periculosidade do detido ou insegurança do estabelecimento carcerário — como justificativa para a tortura (art. 5); dever dos Estados Partes de tomar medidas efetivas para prevenir e punir a tortura no âmbito de sua jurisdição (art. 6).',
    artigos_esperados = array['art. 2','art. 3, "a"','art. 4','art. 5','art. 6'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
