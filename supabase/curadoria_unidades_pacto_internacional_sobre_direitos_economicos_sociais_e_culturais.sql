-- Curadoria das unidades pedagogicas de Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais
-- (curso_conteudos.id = 77), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pacto_internacional_sobre_direitos_economicos_sociais_e_culturais.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 77, assunto "Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pacto_internacional_sobre_direitos_economicos_sociais_e_culturais*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 77;
  v_unidade_1_id constant uuid := 'f33221cc-f53c-4f91-88e4-a6d8440beca0';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 77 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 77 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais',
    escopo = 'Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais — PIDESC (Decreto nº 591/1992): limites admissíveis ao exercício dos direitos assegurados, restritos aos estabelecidos em lei, na medida compatível com a natureza desses direitos e exclusivamente para favorecer o bem-estar geral em sociedade democrática (art. 4º); vedação a restringir ou suspender direitos humanos fundamentais já reconhecidos ou vigentes sob pretexto de o Pacto não os reconhecer ou reconhecê-los em menor grau (art. 5º, item 2); direito ao trabalho, compreendendo a possibilidade de ganhar a vida mediante trabalho livremente escolhido ou aceito, com previsão expressa de medidas incluindo orientação e formação técnica e profissional (art. 6º, itens 1 e 2); direito de toda pessoa à previdência social, inclusive ao seguro social (art. 9º); direito de toda pessoa à educação (art. 13, item 1); direito de beneficiar-se da proteção dos interesses morais e materiais decorrentes de produção científica, literária ou artística de que a pessoa seja autora (art. 15, item 1, alínea c).',
    artigos_esperados = array['art. 4º','art. 5º, item 2','art. 6º, item 1','art. 6º, item 2','art. 9º','art. 13, item 1','art. 15, item 1, "c"'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
