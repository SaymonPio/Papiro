-- Curadoria das unidades pedagogicas de Tratado de Marraqueche
-- (curso_conteudos.id = 94), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/tratado_de_marraqueche.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 94, assunto "Tratado de Marraqueche")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Tratado de Marraqueche
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_tratado_de_marraqueche*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 94;
  v_unidade_1_id constant uuid := '389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Tratado de Marraqueche",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Tratado de Marraqueche'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Tratado de Marraqueche nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 94 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 94 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Tratado de Marraqueche',
    escopo = 'Tratado de Marraqueche para Facilitar o Acesso a Obras Publicadas às Pessoas Cegas, com Deficiência Visual ou com outras Dificuldades para Ter Acesso ao Texto Impresso (OMPI, 2013): são beneficiários, nos termos do art. 3º do Tratado, a pessoa cega; a pessoa com deficiência visual ou outra deficiência de percepção ou leitura que não possa ser corrigida para alcançar função visual substancialmente equivalente à de uma pessoa sem essa deficiência; e a pessoa que, por deficiência física, não consiga sustentar ou manipular um livro ou focar ou mover os olhos ao ponto normalmente necessário para a leitura. O Tratado busca facilitar o acesso a obras publicadas por essas pessoas, relacionando-se especialmente à garantia de acesso à cultura e à informação em formatos acessíveis — propósito operacionalizado, como contexto, pelo art. 4º do Tratado (limitações e exceções aos direitos autorais para produção e disponibilização de exemplares em formato acessível). No Brasil, foi aprovado pelo Congresso Nacional segundo o rito qualificado do art. 5º, §3º da CF/88 (Decreto Legislativo nº 261/2015), conferindo-lhe status equivalente a emenda constitucional; foi promulgado pelo Decreto nº 9.522/2018.',
    artigos_esperados = array['art. 3º','art. 5º, §3º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
