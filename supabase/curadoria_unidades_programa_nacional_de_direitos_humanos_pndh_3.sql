-- Curadoria das unidades pedagogicas de Programa Nacional de Direitos Humanos - PNDH-3
-- (curso_conteudos.id = 96), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/programa_nacional_de_direitos_humanos_pndh_3.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 96, assunto "Programa Nacional de Direitos Humanos - PNDH-3")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Programa Nacional de Direitos Humanos - PNDH-3
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_programa_nacional_de_direitos_humanos_pndh_3*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 96;
  v_unidade_1_id constant uuid := '384edb2e-1b4a-4028-99f3-c6e54b154826';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Programa Nacional de Direitos Humanos - PNDH-3",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Programa Nacional de Direitos Humanos - PNDH-3'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Programa Nacional de Direitos Humanos - PNDH-3 nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 96 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 96 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Programa Nacional de Direitos Humanos - PNDH-3',
    escopo = 'Decreto nº 7.037/2009: aprova o Programa Nacional de Direitos Humanos – PNDH-3, dedicado à promoção e proteção dos direitos humanos no Brasil (art. 1º, caput), estruturado no Anexo do Decreto em consonância com diretrizes, objetivos estratégicos e ações programáticas, organizados em 6 Eixos Orientadores (art. 2º, caput) — incluindo o Eixo III ("Universalizar direitos em um contexto de desigualdades"), cuja Diretriz 10 ("Garantia da igualdade na diversidade", art. 2º, III, "d") reconhece a diversidade como dimensão constitutiva da dignidade da pessoa humana e orienta políticas públicas intersetoriais, ações afirmativas, mecanismos de participação social e revisão de práticas estatais discriminatórias. O Decreto nº 7.177/2010 alterou pontualmente o Anexo, revogando uma ação programática específica sobre ostentação de símbolos religiosos em estabelecimentos públicos da União, dentro dessa mesma Diretriz 10, sem afetar a caracterização geral testada pelo banco atual de questões. O art. 4º do Decreto (Comitê de Acompanhamento e Monitoramento do PNDH-3) foi revogado pelo Decreto nº 10.087/2019, sem ser coberto por nenhuma questão ativa.',
    artigos_esperados = array['art. 1º, caput','art. 2º, caput','art. 2º, III, "d"'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
