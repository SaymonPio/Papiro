-- Curadoria das unidades pedagogicas de Proposições e conectivos
-- (curso_conteudos.id = 1), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/proposicoes_e_conectivos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 1, assunto "Proposições e conectivos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Proposições e conectivos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_proposicoes_e_conectivos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 1;
  v_unidade_1_id constant uuid := '6683c484-74a7-4b07-9cda-1a72190e6445';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Proposições e conectivos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Proposições e conectivos'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Proposições e conectivos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 1 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 1 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Proposições e conectivos',
    escopo = 'Fundamentos de proposições e conectivos lógicos, com base nos padrões efetivamente observados em provas reais da Fundatec (2022) mais uma questão suplementar autoral. EIXO A — DEFINIÇÃO E IDENTIFICAÇÃO DE CONECTIVOS: PROPOSIÇÃO é toda sentença declarativa suscetível de valor lógico verdadeiro ou falso — distinta de pergunta, ordem, exclamação ou sentença sem valor lógico determinado; uma proposição FALSA continua sendo proposição (falsidade não descaracteriza a proposição). PROPOSIÇÃO SIMPLES não resulta da combinação lógica de proposições menores por conectivos; PROPOSIÇÃO COMPOSTA resulta da combinação/modificação de proposições por conectivos lógicos — a classificação nunca é feita pela quantidade de palavras ou tamanho da frase, mas pela estrutura lógica concreta. Os 5 conectivos e suas condições básicas de verdade: NEGAÇÃO (¬P, inverte o valor lógico); CONJUNÇÃO (P∧Q, verdadeira apenas quando P=V e Q=V, falsa em qualquer outro caso); DISJUNÇÃO (P∨Q, na lógica proposicional clássica é o OU INCLUSIVO, falsa apenas quando P=F e Q=F — não presumir automaticamente exclusividade); CONDICIONAL (P→Q, falsa somente no caso P=V e Q=F, verdadeira em todos os demais — distinguir antecedente de consequente, sem exigir relação causal entre eles como condição da lógica proposicional); BICONDICIONAL (P↔Q, verdadeira quando P e Q têm o mesmo valor lógico, falsa quando têm valores diferentes, distinta da condicional simples). A profundidade de cada conectivo nesta unidade respeita o corpus disponível — esta unidade não substitui os conteúdos futuros específicos (negação, tabela-verdade, equivalências lógicas, condicional/contrapositiva) que serão tratados separadamente com sua própria profundidade. EIXO B — AVALIAÇÃO DE PROPOSIÇÕES COMPOSTAS: dado o valor lógico de proposições simples (fixo, sem necessidade de enumerar todas as combinações possíveis — isso pertence ao conteúdo específico de Tabela-verdade), avaliar o valor lógico de expressões compostas por substituição direta, seguindo o procedimento: (1) identificar os valores das proposições simples; (2) resolver as negações; (3) resolver expressões internas/parênteses; (4) aplicar os conectivos restantes; (5) obter o valor final — sem vender esse procedimento como uma regra universal de "precedência matemática" alheia à estrutura lógica e aos parênteses da expressão concreta. Proposições simples podem depender de fatos do mundo real (como a veracidade de uma afirmação sobre cargo político) — nesses casos, o núcleo da questão é lógico (avaliar a composta a partir do valor V/F já determinado da simples), não o fato em si, que não precisa virar conteúdo pedagógico à parte. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): toda a incidência histórica REAL vem de um único evento/concurso independente (2 cadernos do mesmo concurso) — base quantitativamente restrita, sem sustentar qualquer afirmação de recorrência. COBERTURA SUPLEMENTAR: a questão autoral (identificação do conectivo da disjunção) complementa a prática do Eixo A, sem sustentar incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
