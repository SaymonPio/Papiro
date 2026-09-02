-- Curadoria das unidades pedagogicas de Argumentação lógica
-- (curso_conteudos.id = 10), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/argumentacao_logica.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 10, assunto "Argumentação lógica")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Argumentação lógica
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_argumentacao_logica*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 10;
  v_unidade_1_id constant uuid := '5e2d5159-41da-4af7-b75d-4dc21239177d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Argumentação lógica",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Argumentação lógica'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Argumentação lógica nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 10 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 10 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Argumentação lógica',
    escopo = 'Argumentação lógica: determinar se uma conclusão decorre necessariamente de um conjunto de premissas, com base na única questão real observada em prova da Fundatec (2022) mais duas questões suplementares autorais. EIXO A — PREMISSAS E CONCLUSÃO: identificar as informações fornecidas pelas premissas, a conclusão proposta, e as relações entre classes/categorias envolvidas (ex.: "Todo A é B" → A⊆B; "Nenhum A é B" → A∩B=∅; "Algum A é B" → existe ao menos um elemento em A∩B) — essas relações são ferramentas para avaliar a inferência, não um catálogo geral de quantificadores a ser ensinado por si. EIXO B — CONSEQUÊNCIA NECESSÁRIA: determinar se a conclusão é obrigatoriamente verdadeira em TODO cenário compatível com as premissas dadas, distinguindo rigorosamente NECESSÁRIO de APENAS POSSÍVEL — uma conclusão apenas compatível com as premissas, mas não garantida por elas, não torna o argumento válido. EIXO C — VALIDADE POR MODELO/CONTRAEXEMPLO: verificar a validade de um argumento buscando um contraexemplo (um cenário em que todas as premissas sejam verdadeiras e a conclusão proposta seja falsa) — se tal cenário existir, a conclusão não decorre necessariamente e o argumento é inválido; se for logicamente impossível construir esse cenário, o argumento é válido. Reconhecer falácias recorrentes no corpus (afirmação do consequente, termo médio não distribuído) e formas válidas clássicas (modus ponens categórico, silogismo de exclusão por transitividade de inclusão/disjunção de conjuntos). FRONTEIRAS PEDAGÓGICAS OBRIGATÓRIAS (mencionar sem alterar taxonomia): diagramas de conjuntos podem ser usados como ferramenta de verificação mental ou gráfica, mas NÃO são o objeto final desta unidade — uma questão cujo ponto de partida seja um diagrama já dado, pedindo a tradução correta da relação gráfica para texto, pertence a Diagramas lógicos, não a esta unidade (fronteira confirmada por contraste direto com questão real daquele conteúdo). A presença de "todo/algum/nenhum" nas premissas não torna a questão automaticamente de Quantificadores — aqui essas palavras são insumo para a inferência, nunca o objeto de reconhecimento/classificação em si (isso pertence a Quantificadores, já concluído). A validade formal de um argumento proposicional pode ser representada como uma implicação (premissas)→(conclusão) e testada por tautologia, mas essa é apenas uma ferramenta formal possível — o corpus atual não pede classificação de fórmula como tautologia/contradição/contingência (isso pertence àquele conteúdo, já concluído). Avaliar conectivos isolados com valores já fornecidos pertence a Proposições e conectivos; aqui há uma camada inferencial adicional (relação entre premissas e conclusão) que aquele conteúdo não cobre. Esta unidade não aborda lógica formal de provas, regras completas de dedução natural, catálogo obrigatório de falácias ou lógica de predicados avançada — nenhuma dessas identidades aparece como núcleo de nenhuma questão do corpus atual; a profundidade reflete estritamente a incidência real disponível. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): a única incidência histórica REAL vem de uma única questão de um único evento/concurso, base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria dedicada. COBERTURA SUPLEMENTAR: as duas questões autorais praticam, respectivamente, um silogismo categórico direto e simples (modus ponens, sem exigir detecção de falácia) e um silogismo de exclusão com três categorias (A, B, C); não sustentam incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
