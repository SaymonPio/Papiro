-- Curadoria das unidades pedagogicas de Reescrita de frases e textos
-- (curso_conteudos.id = 21), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/reescrita_de_frases_e_textos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 21, assunto "Reescrita de frases e textos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Reescrita de frases e textos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_reescrita_de_frases_e_textos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 21;
  v_unidade_1_id constant uuid := '5cc30e49-890f-4b83-b96f-31724024ee24';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Reescrita de frases e textos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Reescrita de frases e textos'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Reescrita de frases e textos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 21 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 21 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Reescrita de frases e textos',
    escopo = 'Reescrita de frases e textos da Língua Portuguesa, com foco em transformação estrutural preservando a equivalência de sentido — não absorvendo questões em que "reescrever/substituir" é apenas o formato usado para testar um conteúdo específico de outra unidade (ver fronteira taxonômica: Conectores para valor semântico de conectivos; Tempos e modos verbais para conjugação em outro tempo; Transitividade/Termos Integrantes para identificação de termos sintáticos). Núcleo pré-edital fundamentado na questão real deste corpus: transposição da voz ativa para a passiva analítica, preservando os papéis semânticos (quem pratica × quem sofre a ação), o tempo verbal do auxiliar "ser" (idêntico ao do verbo original) e o sentido global, inclusive em períodos com múltiplas orações coordenadas. Método de resolução: (1) identificar quem pratica a ação e quem a sofre; (2) localizar o objeto direto da oração ativa; (3) transformá-lo em sujeito paciente; (4) flexionar o verbo "ser" no tempo/modo correspondente ao verbo original; (5) formar o particípio; (6) introduzir corretamente o agente da passiva ("por/pela"); (7) verificar se os papéis semânticos permanecem os mesmos; (8) comparar o sentido final com o original. Regra de bolso: "antes de olhar as palavras, marque quem faz e quem sofre a ação" e "uma reescrita correta muda a forma, não troca os papéis da cena" — com o limite explícito de que nem toda oração admite passivização natural (a construção pressupõe estrutura verbal compatível, como verbos transitivos diretos/diretos e indiretos), não devendo ser ensinada como transformação mecânica aplicável a qualquer verbo.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
