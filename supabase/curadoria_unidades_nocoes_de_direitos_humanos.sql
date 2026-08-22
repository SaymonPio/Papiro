-- Curadoria das unidades pedagogicas de Noções de Direitos Humanos
-- (curso_conteudos.id = 81), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/nocoes_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 81, assunto "Noções de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Noções de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_nocoes_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 81;
  v_unidade_1_id constant uuid := 'df8d133f-ddd6-4b85-941d-60b4d4967c06';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Noções de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Noções de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Noções de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 81 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 81 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Noções de Direitos Humanos',
    escopo = 'Noções de Direitos Humanos: características tradicionais dos direitos humanos — universalidade e indivisibilidade, com a inter-relação entre as diferentes categorias de direitos (civis, políticos, sociais, econômicos e culturais); a dignidade da pessoa humana como fundamento e objeto de proteção dos direitos humanos; identificação de situações que configuram ou não violação de direitos humanos; e as diretrizes nacionais de promoção e defesa dos direitos humanos dos profissionais de segurança pública, incluindo saúde mental, prevenção do suicídio, acompanhamento psicossocial e condições dignas de trabalho (Lei nº 13.675/2018, arts. 42-A e 42-B, inseridos pela Lei nº 14.531/2023 — tema originalmente estabelecido pela Portaria Interministerial SEDH/MJ nº 2/2010).',
    artigos_esperados = array['art. 42-A','art. 42-B'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
