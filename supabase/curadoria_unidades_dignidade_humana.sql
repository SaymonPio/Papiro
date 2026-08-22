-- Curadoria das unidades pedagogicas de Dignidade humana
-- (curso_conteudos.id = 98), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/dignidade_humana.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 98, assunto "Dignidade humana")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Dignidade humana
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_dignidade_humana*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 98;
  v_unidade_1_id constant uuid := '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Dignidade humana",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Dignidade humana'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Dignidade humana nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 98 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 98 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Dignidade humana',
    escopo = 'Dignidade humana: a Declaração Universal dos Direitos Humanos (ONU, 1948) afirma, em seu art. 1, que todos os seres humanos nascem livres e iguais em dignidade e direitos. A Constituição Federal de 1988 consagra a dignidade da pessoa humana como um dos fundamentos da República Federativa do Brasil (art. 1º, III), ao lado da soberania (I), da cidadania (II), dos valores sociais do trabalho e da livre iniciativa (IV) e do pluralismo político (V) — fundamento que orienta a atuação do Estado e de seus agentes em situações de violência ou vulnerabilidade que exponham a integridade e a honra da pessoa. A dignidade da DUDH (inerente a todo ser humano, independentemente de Estado) e a dignidade da pessoa humana da CF (fundamento constitucional do Estado brasileiro) são dispositivos distintos de diplomas distintos, que não devem ser confundidos entre si.',
    artigos_esperados = array['art. 1º, III'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
