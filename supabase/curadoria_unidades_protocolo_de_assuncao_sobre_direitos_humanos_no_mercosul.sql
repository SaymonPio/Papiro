-- Curadoria das unidades pedagogicas de Protocolo de Assunção sobre Direitos Humanos no Mercosul
-- (curso_conteudos.id = 92), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 92, assunto "Protocolo de Assunção sobre Direitos Humanos no Mercosul")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Protocolo de Assunção sobre Direitos Humanos no Mercosul
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 92;
  v_unidade_1_id constant uuid := '655700d6-b585-468f-8d98-8143090cbafb';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Protocolo de Assunção sobre Direitos Humanos no Mercosul",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Protocolo de Assunção sobre Direitos Humanos no Mercosul'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Protocolo de Assunção sobre Direitos Humanos no Mercosul nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 92 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 92 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Protocolo de Assunção sobre Direitos Humanos no Mercosul',
    escopo = 'Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL (2005, CMC/DEC nº 17/05, Decreto nº 7.225/2010): instrumento normativo do Mercosul cujo objeto é a promoção e proteção dos direitos humanos no bloco, integrando o conjunto normativo específico de direitos humanos no Mercosul (e não outras áreas do direito, como direito marítimo, penal internacional, eleitoral ou monetário). Seu art. 1 estabelece que a plena vigência das instituições democráticas e o respeito aos direitos humanos e às liberdades fundamentais são condições essenciais — não meramente incidentais — para a vigência e evolução do processo de integração regional entre as Partes.',
    artigos_esperados = array['art. 1'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
