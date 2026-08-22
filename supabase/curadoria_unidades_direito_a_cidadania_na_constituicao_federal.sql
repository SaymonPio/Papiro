-- Curadoria das unidades pedagogicas de Direito à cidadania na Constituição Federal
-- (curso_conteudos.id = 95), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/direito_a_cidadania_na_constituicao_federal.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 95, assunto "Direito à cidadania na Constituição Federal")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Direito à cidadania na Constituição Federal
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_direito_a_cidadania_na_constituicao_federal*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 95;
  v_unidade_1_id constant uuid := 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Direito à cidadania na Constituição Federal",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Direito à cidadania na Constituição Federal'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Direito à cidadania na Constituição Federal nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 95 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 95 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Direito à cidadania na Constituição Federal',
    escopo = 'Constituição Federal de 1988: a cidadania como fundamento da República Federativa do Brasil (art. 1º, II); soberania popular exercida pelo sufrágio universal e pelo voto direto e secreto, com valor igual para todos, mediante plebiscito, referendo e iniciativa popular (art. 14, caput, I, II e III); direito de votar como manifestação central dos direitos políticos; alistamento eleitoral e voto obrigatórios para os maiores de dezoito anos (art. 14, §1º, I); idade mínima de 21 anos como condição de elegibilidade para Prefeito (art. 14, §3º, VI, "c"). A Lei nº 15.230/2025 alterou o momento de aferição da idade mínima na legislação eleitoral (Lei nº 9.504/1997), sem modificar as idades previstas no art. 14, §3º, VI da Constituição.',
    artigos_esperados = array['art. 1º, II','art. 14, caput','art. 14, I','art. 14, II','art. 14, III','art. 14, §1º, I','art. 14, §3º, VI, "c"'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
