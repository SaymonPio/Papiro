-- Curadoria das unidades pedagogicas de Estatuto Nacional da Igualdade Racial
-- (curso_conteudos.id = 67), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_nacional_da_igualdade_racial.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 67, assunto "Estatuto Nacional da Igualdade Racial")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto Nacional da Igualdade Racial
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_nacional_da_igualdade_racial*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 67;
  v_unidade_1_id constant uuid := '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto Nacional da Igualdade Racial",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto Nacional da Igualdade Racial'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto Nacional da Igualdade Racial nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 67 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 67 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto Nacional da Igualdade Racial',
    escopo = 'Estatuto Nacional da Igualdade Racial (Lei nº 12.288/2010): objeto da lei e definições de discriminação racial, desigualdade racial, políticas públicas e ações afirmativas (art. 1º); liberdade de consciência e de crença e livre exercício dos cultos religiosos de matriz africana, incluindo assistência religiosa em hospitais e instituições de internação coletiva e combate à intolerância religiosa (arts. 23-26); igualdade de oportunidades no mercado de trabalho e critérios para cargos em comissão visando ampliar a participação de negros (arts. 39, 42); organização institucional da Política Nacional de Promoção da Igualdade Racial — PNPIR (art. 49); acesso à justiça, Ouvidorias Permanentes, combate à violência policial, ressocialização da juventude negra e combate à discriminação por servidores públicos (arts. 52-55); e não exclusão de outras medidas de promoção da igualdade racial adotadas pela União, Estados, Distrito Federal ou Municípios (art. 58).',
    artigos_esperados = array['art. 1º, caput','art. 1º, parágrafo único, I','art. 1º, parágrafo único, II','art. 1º, parágrafo único, V','art. 1º, parágrafo único, VI','art. 23, caput','art. 24, II','art. 24, VII','art. 25, caput','art. 26, II','art. 39, §1º','art. 42, caput','art. 49, §3º','art. 52, caput','art. 53, caput','art. 53, parágrafo único','art. 54, caput','art. 55, caput','art. 58, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
