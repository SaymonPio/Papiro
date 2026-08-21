-- Curadoria das unidades pedagogicas de Poder de Polícia
-- (curso_conteudos.id = 60), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/poder_de_policia.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 60, assunto "Poder de Polícia")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Poder de Polícia
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_poder_de_policia*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 60;
  v_unidade_1_id constant uuid := '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Poder de Polícia",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Poder de Polícia'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Poder de Polícia nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 60 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 60 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Poder de Polícia',
    escopo = 'Poder de Polícia: conceito legal (Código Tributário Nacional, art. 78, caput — atividade da administração pública que limita ou disciplina direito, interesse ou liberdade, em razão do interesse público); atributos tradicionalmente associados ao poder de polícia na doutrina (discricionariedade, autoexecutoriedade e coercibilidade), cuja incidência concreta depende da natureza e do regime jurídico do ato praticado; princípios e limites gerais da atuação administrativa aplicáveis ao seu exercício, dentre os previstos no art. 2º, caput, da Lei nº 9.784/1999 (legalidade, proporcionalidade e interesse público); e exemplos de seu exercício (fiscalização sanitária, urbanística e de segurança sobre particulares), distinguindo-o do poder hierárquico, que se exerce internamente sobre subordinados da própria Administração.',
    artigos_esperados = array['art. 78, caput','art. 2º, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
