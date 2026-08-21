-- Curadoria das unidades pedagogicas de Constituição do Estado do Rio Grande do Sul
-- (curso_conteudos.id = 50), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/constituicao_do_estado_do_rio_grande_do_sul.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 50, assunto "Constituição do Estado do Rio Grande do Sul")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Constituição do Estado do Rio Grande do Sul
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_constituicao_do_estado_do_rio_grande_do_sul*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 50;
  v_unidade_1_id constant uuid := '83636594-c69f-4de0-bf46-0e75c2ec981c';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Constituição do Estado do Rio Grande do Sul",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Constituição do Estado do Rio Grande do Sul'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Constituição do Estado do Rio Grande do Sul nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 50 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 50 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Constituição do Estado do Rio Grande do Sul',
    escopo = 'Constituição do Estado do Rio Grande do Sul: princípios fundamentais e disposições preliminares (soberania popular, símbolos e bens do Estado, hierarquia com a Constituição Federal); administração pública (princípios expressos, Conselhos Populares, publicidade e transparência, administração direta e indireta); direitos dos servidores públicos civis; segurança pública (Brigada Militar, Polícia Civil, Corpo de Bombeiros Militar, Coordenadoria-Geral de Perícias, Polícia Penal); e regime previdenciário do servidor militar (RPPS/RS).',
    artigos_esperados = array['art. 1º','art. 2º','art. 4º','art. 6º','art. 7º','art. 19','art. 21','art. 23','art. 29','art. 41','art. 46','art. 124','art. 125','art. 127','art. 128','art. 132','art. 133','art. 134'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
