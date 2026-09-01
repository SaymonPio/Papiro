-- Curadoria das unidades pedagogicas de Equivalências lógicas
-- (curso_conteudos.id = 5), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/equivalencias_logicas.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 5, assunto "Equivalências lógicas")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Equivalências lógicas
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_equivalencias_logicas*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 5;
  v_unidade_1_id constant uuid := '56df08f8-0f22-48c1-a64d-df11ebfc5ae9';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Equivalências lógicas",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Equivalências lógicas'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Equivalências lógicas nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 5 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 5 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Equivalências lógicas',
    escopo = 'Equivalências lógicas: reconhecer e produzir fórmulas que apresentam o mesmo comportamento lógico (os mesmos valores de verdade em todas as valorações relevantes) que uma proposição composta dada, com base nos dois padrões efetivamente observados em provas reais da Fundatec (2022) mais uma questão suplementar autoral. EIXO A — RECONHECIMENTO DE EQUIVALÊNCIA POR COMPARAÇÃO DE COMPORTAMENTOS: dado o comportamento lógico (os valores de verdade) de uma proposição composta A em todas as valorações de suas proposições simples, testar um conjunto de fórmulas candidatas e identificar qual delas reproduz exatamente esse comportamento em todas as linhas — não apenas em um caso isolado. A tabela-verdade pode ser usada como método de verificação linha a linha, mas o objeto da tarefa é a comparação/busca pela fórmula equivalente, não a construção ou complementação da tabela de uma única expressão já dada (isso pertence ao conteúdo específico de Tabela-verdade). EIXO B — EQUIVALÊNCIA DISJUNTIVA DA CONDICIONAL: aplicar a identidade P → Q ≡ ¬P ∨ Q, tanto em forma simbólica quanto na tradução de sentenças em linguagem natural, distinguindo essa transformação de armadilhas plausíveis (manter a estrutura condicional sem transformar, usar conjunção em vez de disjunção, negar o termo errado, usar bicondicional). Esta equivalência não deve ser confundida com a NEGAÇÃO da condicional (que produz P ∧ ¬Q, uma proposição diferente — pertence a Negação de proposições) nem com a CONTRAPOSITIVA (P → Q ≡ ¬Q → ¬P, uma transformação condicional-para-condicional que fica na fronteira do conteúdo futuro de Condicional e contrapositiva, quando a habilidade nuclear for especificamente produzir/reconhecer a contrapositiva). FRONTEIRAS PEDAGÓGICAS (mencionar sem alterar taxonomia): as Leis de De Morgan também são equivalências lógicas em sentido amplo, mas não são incorporadas ao escopo desta unidade — o corpus atual não contém nenhuma questão cujo núcleo exija especificamente De Morgan como transformação central (essas questões, quando existiram no banco, foram reclassificadas para Negação de proposições por sobreposição curricular, ver ordem 86). Da mesma forma, esta unidade não aborda tautologia/contradição/contingência (classificação geral de fórmulas), comutatividade, associatividade, distributividade ou um catálogo completo de equivalências lógicas — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade desta unidade reflete estritamente a incidência real disponível, não um tratado teórico completo do tópico. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): toda a incidência histórica REAL vem de um único evento/concurso independente (2 cadernos do mesmo concurso) — base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria. COBERTURA SUPLEMENTAR: a questão autoral aplica a mesma equivalência disjuntiva da condicional em forma abstrata, sem regra fornecida no enunciado (diferente da questão real equivalente, que fornece a regra e exige tradução de linguagem natural) — progressão de exigência cognitiva, não duplicata; não sustenta incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
