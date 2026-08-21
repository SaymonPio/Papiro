-- Curadoria das unidades pedagogicas de Constituição Federal de 1988
-- (curso_conteudos.id = 57), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/constituicao_federal_de_1988.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 57, assunto "Constituição Federal de 1988")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Constituição Federal de 1988
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_constituicao_federal_de_1988*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 57;
  v_unidade_1_id constant uuid := '682804b0-2762-4aff-87f9-d7a5a81757c2';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Constituição Federal de 1988",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Constituição Federal de 1988'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Constituição Federal de 1988 nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 57 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 57 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Constituição Federal de 1988',
    escopo = 'Constituição Federal de 1988: princípios fundamentais da República (Título I — fundamentos do Estado Democrático de Direito, separação e harmonia entre os Poderes); organização do Estado (poder constituinte decorrente, competências privativas da União); nacionalidade (art. 12 — brasileiro nato e naturalizado); e administração pública (arts. 37 e 38 — princípios expressos, regras de investidura e servidores públicos, incluindo o exercício de mandato eletivo).',
    artigos_esperados = array['art. 1º','art. 2º','art. 12','art. 22','art. 37','art. 38'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
