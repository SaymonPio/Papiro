-- Curadoria das unidades pedagogicas de Diagramas lógicos
-- (curso_conteudos.id = 11), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/diagramas_logicos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 11, assunto "Diagramas lógicos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Diagramas lógicos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_diagramas_logicos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 11;
  v_unidade_1_id constant uuid := '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Diagramas lógicos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Diagramas lógicos'
      and cm.materia_id = 18
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Diagramas lógicos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 11 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 11 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Diagramas lógicos',
    escopo = 'Diagramas lógicos: representar e interpretar relações entre classes/conjuntos por meio de diagramas lógicos (tipo Euler/Venn), com base em uma questão real de prova da Fundatec (2022) mais duas questões suplementares autorais. EIXO A — RELAÇÕES ENTRE CLASSES: traduzir proposições categóricas em relações entre conjuntos/classes — "Todo A é B" corresponde a A contido em B; "Nenhum A é B" corresponde a A e B sem interseção; "Algum A é B" corresponde à existência de ao menos um elemento na interseção A∩B; "Algum A não é B" corresponde à existência de um elemento de A fora de B — sempre que sustentado pelo corpus real disponível. EIXO B — REPRESENTAÇÃO DIAGRAMÁTICA: identificar a disposição adequada entre classes dada uma relação (inclusão total ou disjunção, conforme o corpus atual). EIXO C — LEITURA DO DIAGRAMA: interpretar corretamente o que uma configuração dada representa — o que ela entrega necessariamente e o que NÃO entrega — evitando os erros clássicos de inverter a relação (concluir B⊆A a partir de A⊆B), presumir existência de elementos exclusivos de uma classe quando isso não é garantido, presumir vazio sem base, ou extrapolar a conclusão para além do universo dado. Rigor com existência: nunca registrar como verdade lógica absoluta que "Todo A é B" implica a existência de elementos de A — a existência só é afirmada quando uma premissa realmente a sustenta (nenhuma questão do corpus atual introduz importação existencial indevida). FRONTEIRAS PEDAGÓGICAS OBRIGATÓRIAS (mencionar sem alterar taxonomia): a entrega final desta unidade é a representação/interpretação de UMA relação categórica dada entre classes — não a conclusão inferencial obtida por encadeamento de múltiplas premissas (isso pertence a Argumentação lógica, já concluída; fronteira confirmada por contraste direto entre Q246 e Q90/Q285/Q286: lá, o núcleo é combinar ≥2 premissas para derivar uma conclusão nova; aqui, há sempre uma única relação dada, e a tarefa é interpretar corretamente seus limites). As palavras "todo/algum/nenhum" podem aparecer nas sentenças categóricas de origem, mas o objetivo desta unidade não é classificar quantificadores (∀/∃) nem negá-los (isso pertence a Quantificadores, já concluído) — aqui essas palavras são apenas o insumo textual traduzido para a relação entre classes. Inclusão/interseção/exclusão são usadas como linguagem para representar relações lógicas entre classes categóricas, não como álgebra geral de conjuntos — esta unidade não aborda operações algébricas extensas, cardinalidade, produto cartesiano, relações/funções ou leis gerais de conjuntos, nem diagramas complexos de múltiplas categorias, combinatória ou probabilidade; a profundidade reflete estritamente a incidência real disponível no corpus (pré-edital). Também não se reduz à leitura de frases declarativas isoladas com valores lógicos já fornecidos (isso pertence a Proposições e conectivos, já concluído) — a habilidade adicional aqui é converter relações categóricas em estrutura de classes e interpretar essa estrutura. Não se sobrepõe a Sentenças abertas e conjunto-verdade (já concluída), que trabalha com domínios finitos enumeráveis e teste de elementos individuais contra um predicado, uma tarefa estruturalmente distinta da interpretação de uma relação categórica entre duas classes nomeadas. PADRÕES OBSERVADOS NESTE CORPUS (não usar os termos "recorrente" nem "mais cobrado pela banca"): a única incidência histórica REAL vem de uma única questão de um único evento/concurso, base quantitativamente restrita (GAP_DE_PRATICA), consistente com a prioridade baixa já documentada, mas com identidade pedagógica própria confirmada por auditoria dedicada. COBERTURA SUPLEMENTAR: as duas questões autorais praticam, respectivamente, uma relação de inclusão total entre duas classes (progressão pedagógica próxima da questão real) e uma relação de disjunção total entre duas classes (tipo de relação categórica adicional, ampliando a diversidade do corpus); não sustentam incidência histórica, recorrência, frequência ou recência da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
