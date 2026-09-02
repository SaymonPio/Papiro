-- Curadoria das unidades pedagogicas de Tautologia, contradição e contingência
-- (curso_conteudos.id = 8), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/tautologia_contradicao_contingencia.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 8, assunto "Tautologia, contradição e contingência")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Tautologia, contradição e contingência
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_tautologia_contradicao_contingencia*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 8;
  v_unidade_1_id constant uuid := 'ae60f2db-49d0-4326-980c-df1617a0bc35';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Tautologia, contradição e contingência",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Tautologia, contradição e contingência'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Tautologia, contradição e contingência nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 8 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 8 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Tautologia, contradição e contingência',
    escopo = 'Tautologia, contradição e contingência: classificar o comportamento GLOBAL de uma proposição composta em TODAS as valorações possíveis de suas proposições simples, com base nos dois padrões efetivamente observados em provas reais da Fundatec (2022) mais uma questão suplementar autoral. EIXO A — COMPORTAMENTO GLOBAL DA FÓRMULA: distinguir verdade em uma única linha (irrelevante para a classificação) de comportamento em TODAS as linhas — uma fórmula só é tautologia se for verdadeira em 100% das valorações, só é contradição se for falsa em 100% das valorações, e é contingência em qualquer outro caso (pelo menos um V e pelo menos um F). EIXO B — CLASSIFICAÇÃO: classificar proposições compostas (isoladas ou comparando múltiplas alegações de classificação sobre fórmulas diferentes) como TAUTOLOGIA, CONTRADIÇÃO ou CONTINGÊNCIA. EIXO C — VERIFICAÇÃO: usar, como ferramenta (nunca como fim em si), a avaliação dos conectivos linha a linha, a tabela-verdade completa, e simplificações lógicas elementares (como o reconhecimento de que uma disjunção de condicionais cruzadas A→B ∨ B→A é sempre tautológica) para PROVAR a classificação — o objeto final da unidade é sempre o rótulo de classificação, nunca a tabela ou a simplificação em si. FRONTEIRAS PEDAGÓGICAS OBRIGATÓRIAS (mencionar sem alterar taxonomia): se a tarefa final de uma questão for "complete/construa esta tabela-verdade", o núcleo pertence a Tabela-verdade (curso_conteudo_id=2), não a este conteúdo, mesmo que a tabela mostre depois uma coluna toda V ou toda F; se a tarefa final for "encontre uma fórmula equivalente", o núcleo pertence a Equivalências lógicas (curso_conteudo_id=5); a avaliação isolada de um único conectivo com valores fixos (sem considerar todas as valorações) pertence a Proposições e conectivos (curso_conteudo_id=1); a presença do conectivo condicional (→) numa fórmula analisada não torna a questão automaticamente sobre Condicional e contrapositiva; perguntar se uma conclusão decorre logicamente de premissas é habilidade de Argumentação lógica, não desta unidade. Esta unidade não aborda formas normais, lógica de predicados, equivalências avançadas, demonstração formal por dedução ou teoria geral de argumentos — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade reflete estritamente a incidência real disponível. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): toda a incidência histórica REAL vem de um único evento/concurso independente (2 cadernos do mesmo concurso) — base quantitativamente restrita, sem sustentar qualquer afirmação de recorrência; observa-se progressão de complexidade — de uma fórmula de 1 variável comparada com outras alegações (Q76), para uma fórmula de 2 variáveis com a mesma estrutura de alegações concorrentes (Q85), até a forma abstrata mais elementar e direta (Q315, cobertura suplementar autoral) — sem que isso configure recorrência, apenas complexidade progressiva dentro do mesmo evento REAL mais uma prática suplementar.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
