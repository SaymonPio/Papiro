-- Curadoria das unidades pedagogicas de Direitos fundamentais
-- (curso_conteudos.id = 76), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/direitos_fundamentais.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 76, assunto "Direitos fundamentais")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Direitos fundamentais
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_direitos_fundamentais*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 76;
  v_unidade_1_id constant uuid := '325c5ca6-8165-472f-b02b-eb7b18c6f71d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Direitos fundamentais",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Direitos fundamentais'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Direitos fundamentais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 76 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 76 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Direitos fundamentais',
    escopo = 'Constituição Federal de 1988: objetivos fundamentais da República (art. 3º, I a IV); distinção pontual entre os objetivos fundamentais da República (art. 3º) e o princípio da autodeterminação dos povos previsto entre os princípios das relações internacionais (art. 4º, III), utilizado como contraste em questão; direitos e garantias individuais — liberdade de crença/convicção filosófica ou política, com exceção quando invocada para eximir-se de obrigação legal e recusar-se a cumprir prestação alternativa (art. 5º, VIII), inviolabilidade da intimidade, vida privada, honra e imagem (art. 5º, X), inviolabilidade domiciliar (art. 5º, XI), acesso à informação com resguardo do sigilo da fonte (art. 5º, XIV), liberdade de associação para fins lícitos, vedada a de caráter paramilitar (art. 5º, XVII), vedação à associação ou permanência associativa compulsória (art. 5º, XX), racismo como crime inafiançável e imprescritível (art. 5º, XLII), ação de grupos armados, civis ou militares, contra a ordem constitucional e o Estado Democrático como crime inafiançável e imprescritível (art. 5º, XLIV), e aplicação imediata das normas definidoras dos direitos e garantias fundamentais (art. 5º, §1º).',
    artigos_esperados = array['art. 3º, I','art. 3º, II','art. 3º, III','art. 3º, IV','art. 4º, III','art. 5º, VIII','art. 5º, X','art. 5º, XI','art. 5º, XIV','art. 5º, XVII','art. 5º, XX','art. 5º, XLII','art. 5º, XLIV','art. 5º, §1º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
