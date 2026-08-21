-- Curadoria das unidades pedagogicas de Estatuto do Desarmamento
-- (curso_conteudos.id = 56), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_do_desarmamento.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 56, assunto "Estatuto do Desarmamento")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto do Desarmamento
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_do_desarmamento*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 56;
  v_unidade_1_id constant uuid := 'd88a80ae-187b-4a24-a5cb-3b20ff32e26f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto do Desarmamento",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto do Desarmamento'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto do Desarmamento nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 56 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 56 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto do Desarmamento',
    escopo = 'Estatuto do Desarmamento (Lei nº 10.826/2003): disposições administrativas sobre registro, aquisição e porte de arma de fogo (Sinarm, registro de arma de uso restrito no Comando do Exército, idade mínima para aquisição); e crimes em espécie (posse irregular, porte ilegal, omissão de cautela, numeração suprimida/adulterada, causas de aumento de pena) e destino de armas apreendidas.',
    artigos_esperados = array['art. 2º, III','art. 2º, IV','art. 3º, parágrafo único','art. 4º, caput','art. 4º, I','art. 10, caput','art. 12, caput','art. 13, caput','art. 14, caput','art. 16, §1º, IV','art. 20, I','art. 25, caput','art. 28, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
