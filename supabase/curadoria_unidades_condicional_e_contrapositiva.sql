-- Curadoria das unidades pedagogicas de Condicional e contrapositiva
-- (curso_conteudos.id = 6), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/condicional_e_contrapositiva.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 6, assunto "Condicional e contrapositiva")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Condicional e contrapositiva
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_condicional_e_contrapositiva*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 6;
  v_unidade_1_id constant uuid := '42f5f55c-350a-4fb6-904c-184cde415d1e';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Condicional e contrapositiva",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Condicional e contrapositiva'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Condicional e contrapositiva nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 6 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 6 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Condicional e contrapositiva',
    escopo = 'Condicional e contrapositiva: reconhecer e produzir a contrapositiva de uma proposição condicional, com base na única questão real observada em prova da Fundatec (2022) mais uma questão suplementar autoral. EIXO A — ESTRUTURA MÍNIMA DA CONDICIONAL: identificar o antecedente (P) e o consequente (Q) de uma sentença condicional "Se P, então Q" (P → Q) — apenas o suficiente para localizar corretamente os termos a transformar na contraposição; a condição de falsidade isolada da condicional (P→Q falsa somente quando P=V e Q=F) NÃO é o objeto desta unidade — essa competência já pertence a Proposições e conectivos, e pode no máximo ser citada como pré-requisito, nunca redesenvolvida aqui. EIXO B — CONTRAPOSITIVA: transformar corretamente P → Q em ¬Q → ¬P (inverter a ordem das proposições E negar ambas), reconhecendo que a contrapositiva é logicamente equivalente à condicional original — tanto em forma simbólica quanto em sentenças de linguagem natural que precisam ser traduzidas para P/Q antes da transformação. DISTINÇÕES OBRIGATÓRIAS (evitar confusão sistemática, tema central dos distratores do corpus real): CONTRAPOSITIVA (¬Q → ¬P) é EQUIVALENTE à condicional original; RECÍPROCA (Q → P, apenas inverte a ordem, sem negar) e INVERSA (¬P → ¬Q, apenas nega, sem inverter a ordem) NÃO são equivalentes à condicional original; a NEGAÇÃO da condicional (P ∧ ¬Q) é uma operação totalmente diferente da contraposição — negar uma sentença não é o mesmo que produzir sua contrapositiva. FRONTEIRAS PEDAGÓGICAS (mencionar sem alterar taxonomia): a equivalência disjuntiva da condicional (P→Q ≡ ¬P∨Q) pertence a Equivalências lógicas (ordem 87) — não é o objeto desta unidade, ainda que ambas sejam "equivalências lógicas" em sentido matemático amplo; a condição de falsidade isolada da condicional pertence a Proposições e conectivos (ordem 84, unidade 6683c484-74a7-4b07-9cda-1a72190e6445, que já recebeu a Q84 reclassificada por esse exato motivo). Esta unidade não aborda bicondicional, tautologias envolvendo implicação, argumentação lógica nem um catálogo completo de equivalências da condicional — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade reflete estritamente a incidência real disponível. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): a única incidência histórica REAL vem de um único evento/concurso, base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria dedicada. COBERTURA SUPLEMENTAR: a questão autoral aplica a mesma transformação de contraposição em forma puramente abstrata (sem tradução de linguagem natural), progressão de exigência cognitiva em relação à questão real, não duplicata; não sustenta incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
