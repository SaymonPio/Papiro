-- Curadoria das unidades pedagogicas de Comissão Interamericana de Direitos Humanos
-- (curso_conteudos.id = 87), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/comissao_interamericana_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 87, assunto "Comissão Interamericana de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Comissão Interamericana de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_comissao_interamericana_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 87;
  v_unidade_1_id constant uuid := '1b84fd2f-93e4-46c1-868f-c8402e73bdf9';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Comissão Interamericana de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Comissão Interamericana de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Comissão Interamericana de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 87 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 87 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Comissão Interamericana de Direitos Humanos',
    escopo = 'Comissão Interamericana de Direitos Humanos (CADH): órgão competente, ao lado da Corte Interamericana, para conhecer dos assuntos relacionados ao cumprimento dos compromissos assumidos pelos Estados Partes na Convenção (art. 33); tem a função principal de promover a observância e a defesa dos direitos humanos (art. 41, caput); atua com respeito às petições e outras comunicações, no exercício de sua autoridade, de conformidade com os arts. 44 a 51 da Convenção (art. 41, "f"); qualquer pessoa, grupo de pessoas ou entidade não governamental legalmente reconhecida pode apresentar-lhe petições contendo denúncias ou queixas de violação da Convenção por um Estado Parte (art. 44) — sem que a Comissão possua competência para condenar criminalmente indivíduos, substituir tribunais nacionais ou exercer função jurisdicional própria da Corte.',
    artigos_esperados = array['art. 33','art. 41, caput','art. 41, "f"','art. 44'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
