-- Curadoria das unidades pedagogicas de Coesão textual
-- (curso_conteudos.id = 13), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/coesao_textual.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 13, assunto "Coesão textual")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Coesão textual
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_coesao_textual*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 13;
  v_unidade_1_id constant uuid := '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Coesão textual",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Coesão textual'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Coesão textual nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 13 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 13 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Coesão textual',
    escopo = 'Coesão textual da Língua Portuguesa, com eixo principal em coesão referencial: o conceito de referente e antecedente; retomada anafórica (elemento coesivo remetendo a algo já mencionado) e catáfora apenas como contraste necessário; retomada por pronome pessoal, possessivo, demonstrativo e relativo; o pronome relativo "cujo/cuja/cujos/cujas", que introduz relação possessiva retomando semanticamente o possuidor antecedente e concordando com o elemento possuído subsequente (nunca o inverso); equivalência entre "em que" e "no qual/na qual" conforme o gênero do antecedente; retomada lexical por repetição/reiteração (mecanismo legítimo de manutenção do tópico, não necessariamente defeito textual) e por expressão sintetizadora (retomando uma palavra, um sintagma, ou sintetizando mais de uma informação anterior); e procedimento para descobrir o referente de um elemento coesivo (localizar o elemento, perguntar a que ele se refere, buscar candidatos compatíveis no texto, verificar gênero/número/pessoa/sentido/estrutura sintática, testar a leitura no contexto — nunca resolver apenas por proximidade gráfica, pois o antecedente nem sempre é o substantivo imediatamente anterior). Como subtópico secundário, cobertura breve de coesão sequencial (conectivos articulando segmentos e relações lógico-semânticas), limitada ao valor conclusivo do conectivo "portanto", sem aprofundamento das demais relações (causal, condicional, concessiva, adversativa etc.), que ficam reservadas ao conteúdo dedicado de Conectores.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
