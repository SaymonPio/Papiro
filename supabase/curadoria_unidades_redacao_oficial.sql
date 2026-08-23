-- Curadoria das unidades pedagogicas de Redação oficial
-- (curso_conteudos.id = 30), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/redacao_oficial.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 30, assunto "Redação oficial")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Redação oficial
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_redacao_oficial*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 30;
  v_unidade_1_id constant uuid := '29bfb433-4013-4164-85de-fd847963199d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Redação oficial",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Redação oficial'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Redação oficial nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 30 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 30 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Redação oficial',
    escopo = 'Redação oficial da Língua Portuguesa segundo o Manual de Redação da Presidência da República (MRPR, 3ª edição, 2018) e o Manual de Redação Oficial do Poder Executivo do Estado do Rio Grande do Sul, com núcleo pré-edital definido pelas questões reais deste corpus: (1) estrutura e formatação do documento padrão ofício (campo assunto, introdução, desenvolvimento/conclusão quando pertinente, fecho e identificação do signatário), com atenção especial à polaridade de questões que pedem a alternativa INCORRETA; (2) definição da comunicação administrativa e seus polos — quem comunica é sempre o serviço público, o que se comunica decorre das atribuições do órgão, e a quem se comunica pode ser o público, uma instituição privada ou outro órgão público — e o princípio da impessoalidade, exclusivo da esfera pública, sem extrapolar além da fonte normativa; (3) vocativos e pronomes de tratamento para autoridades, com atenção ao registro normativo aplicável: para o Presidente da República e demais Chefes de Poder, o MRPR e o Manual RS prescrevem "Excelentíssimo(a) Senhor(a) + cargo" no vocativo e "Vossa Excelência" no tratamento no texto — o Decreto Federal nº 9.758/2019 disciplina as formas de tratamento nas comunicações com agentes públicos da administração pública federal e estabelece hipóteses específicas de não aplicação; o Manual de Redação Oficial do Poder Executivo do RS destaca esse regime federal, preserva a autonomia normativa dos demais entes federativos nos casos não abrangidos, e continua utilizando, em seus próprios quadros de tratamento protocolar, as formas previstas pelo MRPR — por isso, para comunicações originadas de órgãos do Estado do Rio Grande do Sul (como a Brigada Militar) dirigidas ao Presidente da República, as formas do MRPR permanecem as normativamente aplicáveis, sem contradição com o decreto federal. Como cobertura secundária/suplementar (fenômeno também presente na questão autoral, mas não restrito a ela): os atributos gerais da redação oficial — clareza, precisão, objetividade, concisão, coesão, coerência, impessoalidade, formalidade, padronização e uso da norma-padrão — dos quais o mnemônico "C-P-O-C-I" (Clareza, Precisão, Objetividade, Concisão, Impessoalidade) cobre apenas parte, devendo ser ensinado como mnemônico parcial e não como lista exaustiva.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
