-- Curadoria das unidades pedagogicas de Lei de Organização Básica da Brigada Militar
-- (curso_conteudos.id = 63), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/lei_de_organizacao_basica_da_brigada_militar.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 63, assunto "Lei de Organização Básica da Brigada Militar")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Lei de Organização Básica da Brigada Militar
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_lei_de_organizacao_basica_da_brigada_militar*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 63;
  v_unidade_1_id constant uuid := '3c033d9a-5543-422a-a935-c55095bdfc86';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Lei de Organização Básica da Brigada Militar",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Lei de Organização Básica da Brigada Militar'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Lei de Organização Básica da Brigada Militar nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 63 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 63 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Lei de Organização Básica da Brigada Militar',
    escopo = 'Lei de Organização Básica da Brigada Militar: a Lei nº 10.991/1997, historicamente conhecida como Lei de Organização Básica da Brigada Militar, foi expressamente revogada pela Lei Complementar nº 16.450, de 24/12/2025 (art. 47), vigente desde 26/12/2025, que hoje disciplina a organização, a estrutura básica e o efetivo da Brigada Militar do Estado do Rio Grande do Sul. A competência do Chefe do Estado-Maior de assessorar o Comandante-Geral, testada em questão cujo enunciado cita nominalmente a lei revogada, corresponde materialmente ao art. 10 da lei sucessora (''Compete ao Chefe do Estado-Maior assessorar o Comandante-Geral nos assuntos de ordem estratégica da Instituição e coordenar, em caráter geral, as atividades dos Órgãos do Nível de Direção Setorial''). A lei também disciplina, em geral, a estrutura, a organização e o efetivo institucional da corporação.',
    artigos_esperados = array['art. 10'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
