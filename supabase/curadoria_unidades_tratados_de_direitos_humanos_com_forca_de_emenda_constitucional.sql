-- Curadoria das unidades pedagogicas de Tratados de Direitos Humanos com força de Emenda Constitucional
-- (curso_conteudos.id = 78), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/tratados_de_direitos_humanos_com_forca_de_emenda_constitucional.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 78, assunto "Tratados de Direitos Humanos com força de Emenda Constitucional")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Tratados de Direitos Humanos com força de Emenda Constitucional
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_tratados_de_direitos_humanos_com_forca_de_emenda_constitucional*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 78;
  v_unidade_1_id constant uuid := 'e996e440-4508-4878-8acd-c805b718b27c';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Tratados de Direitos Humanos com força de Emenda Constitucional",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Tratados de Direitos Humanos com força de Emenda Constitucional'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Tratados de Direitos Humanos com força de Emenda Constitucional nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 78 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 78 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Tratados de Direitos Humanos com força de Emenda Constitucional',
    escopo = 'Constituição Federal de 1988, art. 5º, §3º (incluído pela EC nº 45/2004): tratados internacionais de direitos humanos aprovados, em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros, equivalem às emendas constitucionais. Tratados internacionais de direitos humanos internalizados sem aprovação por esse rito qualificado possuem, segundo a jurisprudência do STF (RE 466.343/SP), status supralegal. Exemplos de instrumentos aprovados pelo rito do art. 5º, §3º: Convenção sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo (Decreto nº 6.949/2009); Tratado de Marraqueche (Decreto nº 9.522/2018); e, como atualização contextual não testada pelo banco atual de questões, a Convenção Interamericana contra o Racismo, a Discriminação Racial e Formas Correlatas de Intolerância. Em contraste, o Pacto de San José da Costa Rica e o Pacto Internacional sobre Direitos Civis e Políticos, incorporados sem esse rito qualificado, têm status supralegal, não equivalente a emenda constitucional.',
    artigos_esperados = array['art. 5º, §3º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
