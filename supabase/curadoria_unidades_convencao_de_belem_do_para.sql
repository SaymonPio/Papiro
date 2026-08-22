-- Curadoria das unidades pedagogicas de Convenção de Belém do Pará
-- (curso_conteudos.id = 89), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/convencao_de_belem_do_para.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 89, assunto "Convenção de Belém do Pará")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Convenção de Belém do Pará
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_convencao_de_belem_do_para*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 89;
  v_unidade_1_id constant uuid := 'a2d8b683-1a53-451e-9072-525a147fed01';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Convenção de Belém do Pará",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Convenção de Belém do Pará'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Convenção de Belém do Pará nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 89 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 89 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Convenção de Belém do Pará',
    escopo = 'Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher ("Convenção de Belém do Pará", Decreto nº 1.973/1996): define violência contra a mulher como qualquer ato ou conduta baseada no gênero que cause morte, dano ou sofrimento físico, sexual ou psicológico à mulher, tanto na esfera pública como na esfera privada (art. 1); os Estados Partes condenam todas as formas de violência contra a mulher e convêm em adotar, por todos os meios apropriados e sem demora, políticas destinadas a prevenir, punir e erradicar tal violência (art. 7, caput). A Convenção integra o Sistema Interamericano de Proteção dos Direitos Humanos, adotada no âmbito da Organização dos Estados Americanos, prevendo mecanismos interamericanos de proteção (Capítulo IV) — parecer consultivo da Corte Interamericana de Direitos Humanos (art. 11) e petições à Comissão Interamericana de Direitos Humanos por violação do art. 7 (art. 12), citados aqui apenas como contexto institucional, sem que seu conteúdo específico (procedimento de petições, competência consultiva) seja cobrado pelas questões desta unidade.',
    artigos_esperados = array['art. 1','art. 7, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
