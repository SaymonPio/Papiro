-- Curadoria das unidades pedagogicas de Quantificadores
-- (curso_conteudos.id = 7), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/quantificadores.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 7, assunto "Quantificadores")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Quantificadores
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_quantificadores*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 7;
  v_unidade_1_id constant uuid := 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Quantificadores",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Quantificadores'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Quantificadores nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 7 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 7 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Quantificadores',
    escopo = 'Quantificadores: reconhecer e interpretar os quantificadores lógicos universal e existencial, com base na única questão real observada em prova da Fundatec (2022) mais uma questão suplementar autoral. EIXO A — RECONHECIMENTO DE QUANTIFICADORES EM LINGUAGEM NATURAL: identificar o quantificador universal (símbolo ∀; expressões "todo", "todos", "para todo", "qualquer que seja") e o quantificador existencial (símbolo ∃; expressões "existe", "existe pelo menos um", "algum"), distinguindo-os categoricamente de conectivos lógicos (e, ou, se...então, se e somente se) — a proposição pode conter um predicado já negado (ex.: "existe ao menos um servidor que não é policial"), mas a tarefa de reconhecimento é sobre QUAL quantificador introduz a sentença, não sobre negar nada. EIXO B — INTERPRETAÇÃO SOBRE DOMÍNIO EXPLÍCITO: avaliar o valor lógico de sentenças quantificadas quando o domínio/conjunto de elementos é dado explicitamente — uma sentença universal (∀x∈D, P(x)) é verdadeira somente quando TODOS os elementos de D satisfazem P; uma sentença existencial (∃x∈D, P(x)) é verdadeira quando PELO MENOS UM elemento de D satisfaz P (basta um único caso). FRONTEIRAS PEDAGÓGICAS OBRIGATÓRIAS (mencionar sem alterar taxonomia): a NEGAÇÃO de uma sentença quantificada (¬∀x P(x) ≡ ∃x ¬P(x); ¬∃x P(x) ≡ ∀x ¬P(x)) NÃO é objeto desta unidade — essa transformação já pertence a Negação de proposições (curso_conteudo_id=3), que já cobre exatamente esse eixo (Q81, Q86, Q287); esta unidade pode no máximo mencionar que uma sentença quantificada pode conter um predicado negado, sem ensinar a operação de negar o quantificador como habilidade própria. Questões que usam "todos/algum/nenhum" apenas como quantificadores de premissas dentro de um argumento (avaliando se uma conclusão segue validamente das premissas) pertencem a Argumentação lógica, não a este conteúdo — o quantificador nessas questões é apenas parte da estrutura sobre a qual a validade do argumento é avaliada, não o objeto da pergunta. Esta unidade não aborda quantificadores aninhados, múltiplos quantificadores na mesma sentença, troca de ordem entre ∀/∃, domínios infinitos, predicados complexos ou equivalências lógicas avançadas envolvendo quantificação — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade reflete estritamente a incidência real disponível. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): a única incidência histórica REAL vem de uma única questão de um único evento/concurso, base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria dedicada. COBERTURA SUPLEMENTAR: a questão autoral pratica o reconhecimento do quantificador existencial em linguagem natural, complementando o Eixo A; não sustenta incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
