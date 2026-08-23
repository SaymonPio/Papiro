-- Curadoria das unidades pedagogicas de Colocação pronominal
-- (curso_conteudos.id = 29), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/colocacao_pronominal.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 29, assunto "Colocação pronominal")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Colocação pronominal
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_colocacao_pronominal*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 29;
  v_unidade_1_id constant uuid := 'c03b4993-601a-4c1e-b24d-c9e09d01db84';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Colocação pronominal",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Colocação pronominal'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Colocação pronominal nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 29 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 29 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Colocação pronominal',
    escopo = 'Colocação pronominal na norma-padrão tradicional cobrada em concursos, com prática atualmente concentrada em próclise. As questões disponíveis trabalham a atração proclítica por elementos negativos ("não", "jamais") e por estrutura subordinativa ("quando"). Mesóclise e ênclise integram o mapa conceitual necessário à compreensão do tema e aparecem como contraste/distrator, mas ainda não possuem questões próprias cujo gabarito dependa especificamente delas. Método de resolução: (1) identificar o verbo e o pronome átono; (2) verificar se existe elemento anterior que condiciona a próclise (palavra de sentido negativo, conjunção subordinativa, pronome relativo/indefinido/demonstrativo, advérbio sem pausa, interpretados sempre no contexto concreto da frase, nunca como lista mecânica de palavras mágicas); (3) se não houver fator de próclise, verificar se o verbo está em futuro sintético tradicional (fará, diria, entregará — não perífrases como "vai fazer"/"iria dizer", que têm análise própria); havendo fator de próclise, a próclise prevalece mesmo com o verbo no futuro ("Nunca me dirá", não "Nunca dir-me-á"); (4) na ausência de qualquer fator de próclise, com futuro sintético tradicional, a colocação tradicional de concurso é mesoclítica ("dar-me-á", "dir-lhe-ia"); (5) ênclise (pronome após o verbo) é usada em determinados contextos previstos pela norma tradicional quando não há fator de próclise nem futuro sintético sem atrativo — não é simplesmente a posição "residual" default. CAUTELA NORMATIVA IMPORTANTE: a restrição a iniciar oração/período com pronome oblíquo átono (preferindo "Disseram-me..." a "Me disseram...") é convenção da norma-padrão tradicional cobrada em concursos, não descrição absoluta da língua — "Me disseram..." é construção amplamente corrente no português brasileiro real; a aula deve distinguir norma prescritiva de concurso × uso efetivo da língua, sem ensinar a segunda como se não existisse. Regra de bolso: "primeiro procure o fator de próclise; depois olhe o tempo verbal" e "não decore apenas a posição do pronome — descubra o que está puxando essa posição", com o limite explícito de que macetes não substituem a análise da estrutura concreta. Cobertura real do banco (distinta do mapa conceitual acima): hoje a prática vinculável cobre apenas próclise por elemento negativo ("não", "jamais") e por conjunção subordinativa ("quando") — mesóclise e ênclise não têm questão própria como núcleo de gabarito, apenas como contraste nos distratores das 3 questões existentes. Toda a prática disponível é AUTORAL_PAPIRO, sem evidência real de incidência da banca no corpus atual.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
