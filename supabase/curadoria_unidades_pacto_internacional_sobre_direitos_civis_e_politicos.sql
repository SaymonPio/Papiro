-- Curadoria das unidades pedagogicas de Pacto Internacional sobre Direitos Civis e Políticos
-- (curso_conteudos.id = 74), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pacto_internacional_sobre_direitos_civis_e_politicos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 74, assunto "Pacto Internacional sobre Direitos Civis e Políticos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pacto Internacional sobre Direitos Civis e Políticos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pacto_internacional_sobre_direitos_civis_e_politicos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 74;
  v_unidade_1_id constant uuid := '8d4e4b20-37ac-4df0-a7ac-57cb016c44d6';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pacto Internacional sobre Direitos Civis e Políticos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pacto Internacional sobre Direitos Civis e Políticos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pacto Internacional sobre Direitos Civis e Políticos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 74 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 74 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pacto Internacional sobre Direitos Civis e Políticos',
    escopo = 'Pacto Internacional sobre Direitos Civis e Políticos — PIDCP (Decreto nº 592/1992): direito inerente à vida, protegido por lei, com vedação à privação arbitrária (art. 6º, item 1); proibição da tortura e de penas ou tratamentos cruéis, desumanos ou degradantes, incluindo a vedação a submeter pessoa, sem seu livre consentimento, a experiências médicas ou científicas (art. 7º); direito à reparação de quem for vítima de prisão ou encarceramento ilegais (art. 9º, item 5); direito de toda pessoa privada de liberdade a tratamento humano e com respeito à dignidade inerente à pessoa humana (art. 10, item 1); vedação à prisão fundada exclusivamente na incapacidade de cumprir obrigação contratual (art. 11).',
    artigos_esperados = array['art. 6º, item 1','art. 7º','art. 9º, item 5','art. 10, item 1','art. 11'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
