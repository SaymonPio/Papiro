-- Curadoria das unidades pedagogicas de Estrutura e formação de palavras
-- (curso_conteudos.id = 33), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estrutura_e_formacao_de_palavras.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 33, assunto "Estrutura e formação de palavras")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estrutura e formação de palavras
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estrutura_e_formacao_de_palavras*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 33;
  v_unidade_1_id constant uuid := '1a6bb75c-23d7-4110-be96-8803cbd85331';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estrutura e formação de palavras",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estrutura e formação de palavras'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estrutura e formação de palavras nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 33 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 33 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estrutura e formação de palavras',
    escopo = 'Estrutura e formação de palavras da Língua Portuguesa: elementos estruturais da palavra (radical/base, afixos — prefixo e sufixo —, e desinências) e processos de formação de palavras por derivação (prefixal, sufixal e parassintética, esta última exigindo o acréscimo simultâneo de prefixo e sufixo cuja retirada isolada de qualquer um deles destrói a formação lexical considerada, sem aplicar o teste mecanicamente) e por composição (justaposição — união de radicais ou palavras autônomas sem perda fonética, como matéria-prima e guarda-chuva — com contraste breve, de cobertura secundária, para a aglutinação, união com perda ou fusão fonética); distinção entre palavra primitiva e derivada; reconhecimento de prefixos reais de valor semântico produtivo (in-/im- de negação, com atenção à assimilação fonológica do N ao M em contextos como "imaterial" = in- + material; anti- de oposição; sub- de posição inferior) em contraste com falsos prefixos — segmentos iniciais graficamente semelhantes a um prefixo mas que integram o radical primitivo latino (indicado, início, incitando, importância, investir, importante) — reconhecidos não apenas por semelhança gráfica, mas por base, significado, relação semântica e produtividade do processo, usando a remoção do segmento inicial apenas como heurística auxiliar (a existência de uma base residual não comprova sozinha a prefixação); elementos de composição eruditos gregos e latinos frequentes em concurso (miso- = ódio/aversão, -logia/-logo = estudo/especialista); o sufixo -mente como formador produtivo de muitos advérbios (sobretudo de modo), sem regra absoluta sobre passagem ao feminino quando o adjetivo já é uniforme nos dois gêneros; o sufixo nominal -ando/-endo/-indo (designando pessoa em processo ou preparação, como vestibulando, doutorando, graduando), distinto da terminação de gerúndio verbal; e a desinência nominal de número (-s/-es), reconhecendo que o singular frequentemente apresenta morfema zero de número e o plural apresenta marca morfológica cuja realização pode variar conforme a estrutura da palavra, sempre que a análise for exigida pela banca em contraste com o critério gramatical eventualmente divergente.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
