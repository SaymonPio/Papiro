-- Curadoria das unidades pedagogicas de Sentenças abertas e conjunto-verdade
-- (curso_conteudos.id = 9), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/sentencas_abertas_e_conjunto_verdade.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 9, assunto "Sentenças abertas e conjunto-verdade")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Sentenças abertas e conjunto-verdade
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_sentencas_abertas_e_conjunto_verdade*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 9;
  v_unidade_1_id constant uuid := '4ed265ff-578a-4462-bce6-d756b8ad5838';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Sentenças abertas e conjunto-verdade",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Sentenças abertas e conjunto-verdade'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Sentenças abertas e conjunto-verdade nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 9 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 9 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Sentenças abertas e conjunto-verdade',
    escopo = 'Sentenças abertas e conjunto-verdade: interpretar sentenças abertas e determinar seu conjunto-verdade em um domínio/universo explicitamente dado, com base na única questão real observada em prova da Fundatec (2022) mais duas questões suplementares autorais. EIXO A — SENTENÇA ABERTA: reconhecer que uma expressão contendo variável livre (equação ou inequação, como "x+2=7" ou "x>3") não possui valor lógico determinado (nem V nem F) antes de a variável receber um valor do domínio — distinta de uma proposição fechada, cujo valor lógico já está determinado. EIXO B — DOMÍNIO/UNIVERSO: identificar o universo no qual a variável está sendo considerada (conjunto finito explícito, como U={0,1,2,3,4,5}, ou conjunto numérico como os inteiros) e verificar se os valores candidatos pertencem efetivamente a esse domínio — o conjunto-verdade de uma mesma sentença pode mudar conforme o domínio considerado. EIXO C — CONJUNTO-VERDADE: determinar, por testagem sistemática dos elementos do domínio ou por resolução algébrica seguida de verificação de pertinência ao domínio, o subconjunto do universo formado pelos valores que tornam a sentença verdadeira. EIXO D — SENTENÇAS ABERTAS COMPOSTAS: quando duas sentenças abertas simples são combinadas por um conectivo (no corpus atual, apenas disjunção — P(x)∨Q(x)), o conjunto-verdade da composta corresponde à UNIÃO dos conjuntos-verdade de cada componente simples (para conjunção, seria a interseção, mas essa combinação não aparece no corpus atual e não é expandida sem evidência). FRONTEIRAS PEDAGÓGICAS OBRIGATÓRIAS (mencionar sem alterar taxonomia): resolver uma equação ou inequação (isolar a variável) é FERRAMENTA nesta unidade, nunca o objeto final — o objeto final é sempre o conjunto-verdade dentro do domínio dado; se uma questão pedisse apenas "resolva a equação", sem framing de sentença aberta/universo/conjunto-verdade, isso pertenceria a Matemática, não a este conteúdo — nenhuma candidata atual se encaixa nesse caso, pois todas emolduram a tarefa explicitamente em vocabulário de sentença aberta e conjunto-verdade. Proposições já fechadas com valor lógico determinado (avaliação de P∧Q, P∨Q, P→Q, P↔Q com valores já fornecidos) pertencem a Proposições e conectivos, não a esta unidade. Quantificadores (∀, ∃) ligam a variável, mudando a estrutura lógica — sentenças com variável ligada por quantificador pertencem a Quantificadores, não a Sentenças abertas, cujo corpus trabalha exclusivamente com variável LIVRE testada/substituída dentro de um domínio explícito. Esta unidade não aborda lógica de predicados avançada, quantificadores aninhados, funções complexas, inequações de alto grau, sistemas de equações ou teoria algébrica geral — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade reflete estritamente a incidência real disponível. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): a única incidência histórica REAL vem de uma única questão de um único evento/concurso, base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria dedicada. COBERTURA SUPLEMENTAR: as duas questões autorais praticam, respectivamente, a forma mais elementar (equação simples com um único domínio numérico) e uma inequação simples com ênfase na distinção entre desigualdade estrita e não-estrita; não sustentam incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
