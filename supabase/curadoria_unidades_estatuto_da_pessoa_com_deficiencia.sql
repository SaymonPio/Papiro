-- Curadoria das unidades pedagogicas de Estatuto da Pessoa com Deficiência
-- (curso_conteudos.id = 75), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_da_pessoa_com_deficiencia.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 75, assunto "Estatuto da Pessoa com Deficiência")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto da Pessoa com Deficiência
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_da_pessoa_com_deficiencia*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 75;
  v_unidade_1_id constant uuid := '128d9183-6188-4ca1-abdb-fc5c57e78d28';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto da Pessoa com Deficiência",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto da Pessoa com Deficiência'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto da Pessoa com Deficiência nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 75 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 75 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto da Pessoa com Deficiência',
    escopo = 'Lei nº 13.146/2015 (Lei Brasileira de Inclusão da Pessoa com Deficiência / Estatuto da Pessoa com Deficiência): definição de profissional de apoio escolar — pessoa que exerce atividades de alimentação, higiene e locomoção do estudante com deficiência e atua em todas as atividades escolares nas quais se fizer necessária (art. 3º, XIII); a deficiência não afeta a plena capacidade civil da pessoa (art. 6º, caput), inclusive para casar-se e constituir união estável (art. 6º, I); a curatela como medida protetiva extraordinária, proporcional às necessidades e circunstâncias de cada caso, com duração pelo menor tempo possível (art. 84, §3º); a curatela afeta somente os atos de natureza patrimonial e negocial (art. 85, caput), não alcançando o direito ao próprio corpo, à sexualidade, ao matrimônio, à privacidade, à educação, à saúde, ao trabalho e ao voto (art. 85, §1º).',
    artigos_esperados = array['art. 3º, XIII','art. 6º, caput','art. 6º, I','art. 84, §3º','art. 85, caput','art. 85, §1º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
