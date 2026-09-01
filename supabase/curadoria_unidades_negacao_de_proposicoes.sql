-- Curadoria das unidades pedagogicas de Negação de proposições
-- (curso_conteudos.id = 3), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/negacao_de_proposicoes.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 3, assunto "Negação de proposições")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Negação de proposições
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_negacao_de_proposicoes*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 3;
  v_unidade_1_id constant uuid := 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Negação de proposições",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Negação de proposições'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Negação de proposições nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 3 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 3 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Negação de proposições',
    escopo = 'Negação de proposições simples e compostas, com base nos padrões efetivamente observados em provas reais da Fundatec (2022-2025) mais uma questão suplementar autoral. Estrutura pedagógica: conceito → formalização → transformação → linguagem natural → armadilha → questão, evitando basear o ensino apenas em frases decoradas. EIXO A — NEGAÇÃO DE PROPOSIÇÕES QUANTIFICADAS: negação do quantificador universal — ¬∀x P(x) ≡ ∃x ¬P(x) — "Todos são P" nega-se para "Existe pelo menos um que não é P" (NUNCA para "Nenhum é P", que é uma afirmação mais forte e contrária, não a simples negação lógica do universal: se 1 elemento não for P e os demais forem, "todos são P" já é falso, sem que "nenhum é P" precise ser verdadeiro); negação do quantificador existencial — ¬∃x P(x) ≡ ∀x ¬P(x) — "Existe pelo menos um que é P" nega-se para "Nenhum é P" ou, de forma equivalente no contexto, "Todos não são P", mantendo cuidado com qual formulação natural é semanticamente adequada à sentença original. EIXO B — NEGAÇÃO DE CONJUNÇÃO E DISJUNÇÃO: negação da conjunção — ¬(P∧Q) ≡ ¬P∨¬Q — nega-se cada proposição simples e troca-se o conectivo "e" por "ou"; negação da disjunção — ¬(P∨Q) ≡ ¬P∧¬Q — nega-se cada proposição simples e troca-se o conectivo "ou" por "e"; quando um dos termos originais já estiver negado, aplicar dupla negação (a negação de "não-Q" retorna à forma afirmativa "Q"), explicitando pedagogicamente os passos (trocar o conectivo; negar cada termo; resolver dupla negação quando aplicável) em vez de ensinar apenas como macete mecânico. FRONTEIRAS PEDAGÓGICAS (mencionar sem alterar taxonomia): negações de conjunções/disjunções aplicam as Leis de De Morgan; negações de universais/existenciais envolvem o aparato de quantificadores — essas conexões podem ser citadas na aula, mas a taxonomia primária das questões desta unidade já foi decidida por teste contrafactual de habilidade nuclear (não pelo texto do comando) e permanece nesta unidade; a fronteira específica com os conteúdos dedicados (Leis de De Morgan, Quantificadores) será resolvida quando aquelas ordens forem alcançadas, não aqui. PADRÕES OBSERVADOS NESTE CORPUS (não usar o termo "recorrente" nem "mais cobrado pela banca" para nenhum deles): negação de universal (1 evento), negação de existencial (1 evento), negação de disjunção com termo negado (1 evento) — 3 padrões REAL distintos, cada um com incidência pontual, sem repetição do mesmo padrão em eventos/concursos independentes. COBERTURA SUPLEMENTAR: a questão autoral (negação de conjunção) complementa a prática do Eixo B, sem sustentar incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
