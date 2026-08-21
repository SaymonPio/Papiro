-- Curadoria das unidades pedagogicas de Poderes da Administração Pública
-- (curso_conteudos.id = 59), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/poderes_da_administracao_publica.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 59, assunto "Poderes da Administração Pública")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Poderes da Administração Pública
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_poderes_da_administracao_publica*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 59;
  v_unidade_1_id constant uuid := '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Poderes da Administração Pública",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Poderes da Administração Pública'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Poderes da Administração Pública nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 59 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 59 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Poderes da Administração Pública',
    escopo = 'Poderes da Administração Pública: poder hierárquico e poder disciplinar, tratados em sua dimensão doutrinária geral, sem dispositivo legal específico atribuído; poder regulamentar (Constituição Federal, art. 84, IV — expedição de decretos e regulamentos para fiel execução da lei); e abuso de poder em suas duas modalidades — incompetência, associada pela doutrina ao chamado "excesso de poder" (Lei nº 4.717/1965, art. 2º, parágrafo único, "a"), e desvio de finalidade ou desvio de poder (Lei nº 4.717/1965, art. 2º, parágrafo único, "e") —, como defeitos que tornam nulo o ato administrativo.',
    artigos_esperados = array['art. 84, IV','art. 2º, parágrafo único, "a"','art. 2º, parágrafo único, "e"'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
