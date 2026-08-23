-- Curadoria das unidades pedagogicas de Pontuação
-- (curso_conteudos.id = 16), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pontuacao.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 16, assunto "Pontuação")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pontuação
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pontuacao*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 16;
  v_unidade_1_id constant uuid := 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pontuação",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pontuação'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pontuação nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 16 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 16 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pontuação',
    escopo = 'Pontuação da Língua Portuguesa, com foco no uso da vírgula — sem núcleo pré-edital baseado em incidência real, pois o corpus atual deste conteúdo é integralmente autoral (COBERTURA_SUPLEMENTAR_PONTUACAO, sem evidência de recorrência histórica da banca). Eixos trabalhados: (1) oração adverbial deslocada para o início ou intercalada no período, tipicamente isolada por vírgula, com análise da posição, extensão e organização sintático-discursiva da construção específica, sem regra absoluta de obrigatoriedade/facultatividade desvinculada da estrutura; (2) oração adjetiva explicativa × restritiva, com o princípio do isolamento da explicativa (vírgula de abertura e fechamento quando no meio do período; pontuação terminal quando ao final), em contraste com a ausência de vírgula na restritiva, que delimita o referente; (3) estruturas que a vírgula não deve romper — a relação direta entre sujeito e verbo, e entre verbo e complemento — formulada com o cuidado de não se tornar regra absoluta, já que termos ou orações intercaladas legitimamente isolados por vírgula (como em "O aluno, cansado, saiu.") não rompem essa relação, apenas isolam um termo adicional. Método de resolução: identificar a estrutura sintática, os termos diretamente ligados entre si, a existência de termo/oração intercalado ou deslocamento, e se há explicação ou restrição, antes de decidir se a vírgula marca uma estrutura legítima ou rompe indevidamente uma relação sintática coesa.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
