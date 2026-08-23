-- Curadoria das unidades pedagogicas de Coordenação e subordinação
-- (curso_conteudos.id = 28), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/coordenacao_e_subordinacao.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 28, assunto "Coordenação e subordinação")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Coordenação e subordinação
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_coordenacao_e_subordinacao*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 28;
  v_unidade_1_id constant uuid := 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Coordenação e subordinação",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Coordenação e subordinação'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Coordenação e subordinação nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 28 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 28 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Coordenação e subordinação',
    escopo = 'Coordenação e subordinação no período composto, com foco na identificação da relação sintática entre orações e na classificação contextual dos tipos efetivamente representados no banco atual. Método de resolução: (1) delimitar as orações do período; (2) identificar a relação sintática entre elas — coordenação (orações sintaticamente independentes entre si) ou subordinação (uma oração integra sintaticamente a estrutura da outra); (3) localizar o conectivo, quando houver; (4) interpretar seu valor no contexto concreto da frase, não apenas decorado isoladamente; (5) classificar a oração pelo nome correspondente. Regra de bolso: "primeiro descubra a relação entre as orações; depois dê o nome" e "conectivo é pista, não sentença" — o aluno não deve memorizar mecanicamente "mas = adversativa", "quando = temporal", "embora = concessiva" como algoritmo suficiente para qualquer contexto, sem analisar o período; dependendo da construção, conectivos podem assumir valores contextuais menos prototípicos. CAUTELA CONCEITUAL: orações coordenadas não exercem função sintática uma em relação à outra (independência sintática), mas isso não significa que sejam totalmente independentes de sentido — podem manter forte relação semântica, discursiva e argumentativa entre si. A prática disponível cobre hoje apenas três eixos: EIXO 1 — coordenação sindética adversativa (conectivos como "mas", "porém", "contudo", "todavia", "entretanto", "no entanto": ensinar em duas etapas — reconhecer a relação de coordenação, e então o valor semântico de oposição/contraste introduzido pelo conectivo, não apenas o algoritmo "viu MAS = adversativa"). EIXO 2 — subordinação adverbial temporal (a oração subordinada expressa a circunstância de tempo em relação à principal). EIXO 3 — subordinação adverbial concessiva (a oração subordinada introduz um obstáculo/ressalva que NÃO impede a realização do fato expresso na principal — distinguir de causa, que explica por que o fato ocorreu, enquanto concessão apresenta uma circunstância que poderia contrariar o esperado sem impedi-lo). GAPS DE SUBASSUNTO (lacunas de banco, não delimitação de escopo): coordenação aditiva, alternativa, conclusiva, explicativa e assindética; subordinação adverbial causal, comparativa, condicional, conformativa, consecutiva, final e proporcional; subordinação substantiva (subjetiva, objetiva direta, objetiva indireta, completiva nominal, predicativa, apositiva) e subordinação adjetiva (restritiva/explicativa) — nenhuma dessas é excluída conceitualmente desta unidade; a ausência reflete apenas falta de candidata real ou autoral no corpus atual. Fronteira com Conectores (conteúdo já concluído): Conectores foca no valor lógico-semântico da palavra/locução conectiva (equivalência, substituição, reescrita); esta unidade foca na classificação da oração como um todo dentro do período composto — a mesma frase-exemplo pode servir aos dois propósitos sem configurar duplicata. Fronteira com Transitividade Verbal e Termos Integrantes (conteúdo já concluído) e com Pontuação (conteúdo já concluído): uma futura questão sobre subordinada substantiva pertence aqui apenas se sua habilidade nuclear for classificar o tipo da oração subordinada; se o núcleo for função de complemento/objeto/termo integrante/regência, o destino é o conteúdo sintático correspondente. Uma futura questão sobre subordinada adjetiva pertence aqui se o núcleo for classificá-la como restritiva ou explicativa; se o núcleo for o uso da vírgula nessa distinção, o destino é Pontuação. Toda a prática disponível nesta unidade é AUTORAL_PAPIRO e, portanto, suplementar — não sustenta afirmação de recorrência, frequência ou padrão típico da Fundatec.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
