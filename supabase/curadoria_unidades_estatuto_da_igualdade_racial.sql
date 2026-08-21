-- Curadoria das unidades pedagogicas de Estatuto da Igualdade Racial
-- (curso_conteudos.id = 97), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_da_igualdade_racial.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 97, assunto "Estatuto da Igualdade Racial")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto da Igualdade Racial
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_da_igualdade_racial*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 97;
  v_unidade_1_id constant uuid := '9cc42871-c31c-440a-88cb-32f0d4f232ff';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto da Igualdade Racial",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto da Igualdade Racial'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto da Igualdade Racial nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 97 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 97 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto da Igualdade Racial',
    escopo = 'Estatuto da Igualdade Racial (Lei nº 12.288/2010) — abordagem sob a ótica de Direitos Humanos e Cidadania: objeto da lei e definição de discriminação racial (art. 1º); diretriz político-jurídica de inclusão das vítimas de desigualdade étnico-racial, valorização da igualdade étnica e fortalecimento da identidade nacional brasileira (art. 3º); ação afirmativa nas esferas pública e privada (art. 4º); direito à saúde da população negra e vedação à discriminação em seguros privados de saúde (art. 6º), com a produção de conhecimento científico e tecnológico em saúde da população negra como diretriz da Política Nacional de Saúde Integral da População Negra (art. 7º, II); direito de participar de atividades educacionais, culturais, esportivas e de lazer (art. 9º), apoio a entidades de promoção social e cultural da população negra (art. 10, II), estudo obrigatório da história geral da África e da população negra no Brasil (art. 11) e incentivo às instituições de ensino superior a incorporar temas de pluralidade étnica e cultural nas matrizes curriculares de formação de professores (art. 13, II); liberdade de consciência e de crença e cultos de matriz africana (arts. 23-26); remanescentes de quilombos (art. 32) e acesso a financiamentos habitacionais (art. 37); e medidas de segurança pública e acesso à Justiça para vítimas de discriminação étnica (arts. 52-53).',
    artigos_esperados = array['art. 1º, caput','art. 1º, parágrafo único, I','art. 3º, caput','art. 4º, parágrafo único','art. 6º, caput','art. 6º, §2º','art. 7º, II','art. 9º, caput','art. 10, II','art. 11, caput','art. 13, II','art. 23, caput','art. 24, II','art. 24, III','art. 24, VII','art. 25, caput','art. 26, II','art. 32, caput','art. 37, caput','art. 52, caput','art. 53, caput','art. 53, parágrafo único'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
