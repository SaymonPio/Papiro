-- Curadoria das unidades pedagogicas de Direitos Humanos no Mercosul
-- (curso_conteudos.id = 91), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/direitos_humanos_no_mercosul.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 91, assunto "Direitos Humanos no Mercosul")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Direitos Humanos no Mercosul
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_direitos_humanos_no_mercosul*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 91;
  v_unidade_1_id constant uuid := 'fec87f6c-c735-46f1-8bd1-7bbaf6f56e93';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Direitos Humanos no Mercosul",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Direitos Humanos no Mercosul'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Direitos Humanos no Mercosul nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 91 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 91 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Direitos Humanos no Mercosul',
    escopo = 'Direitos Humanos no Mercosul: o Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL (2005, aprovado pela Decisão CMC/DEC nº 17/05) estabelece, em seu art. 1, que a plena vigência das instituições democráticas e o respeito aos direitos humanos e às liberdades fundamentais são condições essenciais para a vigência e evolução do processo de integração entre as Partes. O art. 2 do mesmo Protocolo prevê que as Partes cooperarão mutuamente para a promoção e proteção efetiva dos direitos humanos e liberdades fundamentais por meio dos mecanismos institucionais estabelecidos no Mercosul (contexto complementar para a futura aula). A atuação institucional do bloco em direitos humanos conta ainda com a Reunião de Altas Autoridades em Direitos Humanos (RAADH, criada pela Decisão CMC/DEC nº 40/04) e o Instituto de Políticas Públicas em Direitos Humanos do Mercosul (IPPDH, criado pela Decisão CMC nº 14/09), e deve ser compreendida como complementar — e não substitutiva — às obrigações internacionais e constitucionais já assumidas pelos Estados Partes (Sistema Interamericano, Sistema Universal, Constituições nacionais). O Protocolo de Ushuaia sobre Compromisso Democrático no Mercosul (1998) integra o contexto histórico do compromisso democrático do bloco, núcleo distinto (democracia) do Protocolo de Assunção de 2005, específico sobre direitos humanos.',
    artigos_esperados = array['art. 1'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
