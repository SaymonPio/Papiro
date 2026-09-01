-- Curadoria das unidades pedagogicas de Tabela-verdade
-- (curso_conteudos.id = 2), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/tabela_verdade.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 2, assunto "Tabela-verdade")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Tabela-verdade
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_tabela_verdade*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 2;
  v_unidade_1_id constant uuid := 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Tabela-verdade",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Tabela-verdade'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Tabela-verdade nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 2 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 2 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Tabela-verdade',
    escopo = 'Tabela-verdade como PROCEDIMENTO SISTEMÁTICO para determinar o valor lógico de uma proposição composta em TODAS as combinações possíveis de valores de suas proposições simples, com base nos dois padrões efetivamente observados em provas reais da Fundatec (2022). PROCEDIMENTO: (1) identificar as proposições simples que compõem a expressão; (2) contar n = número de proposições simples distintas; (3) determinar o número de linhas da tabela completa, sempre 2^n (n=1 → 2 linhas; n=2 → 4 linhas; n=3 → 8 linhas etc.) — 2^n vale para o total de valorações possíveis de n proposições simples, não é uma regra mecânica a aplicar a qualquer fragmento isolado de tabela; (4) montar sistematicamente todas as combinações de V/F das proposições simples, sem omitir nenhuma; (5) calcular as negações necessárias; (6) calcular colunas intermediárias (subexpressões) na ordem correta, resolvendo parênteses e operações internas antes dos conectivos externos; (7) aplicar os conectivos restantes; (8) obter a coluna final da expressão composta; (9) interpretar o resultado (extrair o valor pedido em cada linha ou identificar o padrão geral). DIFERENÇA EM RELAÇÃO A PROPOSIÇÕES E CONECTIVOS (curso_conteudo_id=1): lá as proposições simples têm valor lógico FIXO e dado, sem necessidade de enumerar combinações — o núcleo é aplicar a condição de verdade de um conectivo isolado a um único caso; aqui o núcleo é ORGANIZAR E AVALIAR SISTEMATICAMENTE TODAS AS VALORAÇÕES POSSÍVEIS em estrutura tabular — uma questão que apenas pergunta a condição de verdade de um conectivo isolado (ex.: ''quando P e Q é verdadeira?''), sem exigir montagem/leitura de tabela, pertence a Proposições e conectivos, não a este conteúdo. A unidade retoma brevemente as condições de verdade dos 5 conectivos (¬, ∧, ∨, →, ↔) apenas como pré-requisito operacional para preencher colunas — sem refazer a unidade de Proposições e conectivos. PROGRESSÃO DE COMPLEXIDADE OBSERVADA NO CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): de uma expressão com 2 proposições simples e tabela de 4 linhas (condicional + negação) para uma expressão com 3 proposições simples e tabela de 8 linhas (disjunção + conjunção + negação + condicional, com preenchimento parcial de lacunas) — toda a incidência histórica REAL vem de um único evento/concurso independente, base quantitativamente restrita, sem sustentar qualquer afirmação de recorrência.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
