-- Curadoria das unidades pedagogicas de Casos do Brasil na Corte Interamericana de Direitos Humanos
-- (curso_conteudos.id = 90), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/casos_do_brasil_na_corte_interamericana_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 90, assunto "Casos do Brasil na Corte Interamericana de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Casos do Brasil na Corte Interamericana de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_casos_do_brasil_na_corte_interamericana_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 90;
  v_unidade_1_id constant uuid := '420c8c2f-6f80-422a-9e63-d64aace51465';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Casos do Brasil na Corte Interamericana de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Casos do Brasil na Corte Interamericana de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Casos do Brasil na Corte Interamericana de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 90 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 90 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Casos do Brasil na Corte Interamericana de Direitos Humanos',
    escopo = 'Casos concretos em que o Brasil foi responsabilizado pela Corte Interamericana de Direitos Humanos: (1) Caso Ximenes Lopes vs. Brasil (sentença de 04/07/2006) — primeira condenação do Brasil na Corte IDH, por maus-tratos e morte de Damião Ximenes Lopes em estabelecimento psiquiátrico; (2) Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil (sentença de 24/11/2010) — desaparecimento forçado de opositores durante o regime militar e dever estatal de investigar graves violações de direitos humanos; a Corte considerou incompatíveis com a Convenção Americana as disposições da Lei de Anistia (Lei 6.683/1979) que impeçam a investigação e punição das graves violações de direitos humanos abrangidas pelo caso, entendendo que não podem produzir efeitos jurídicos nesse sentido; (3) Caso Herzog e outros vs. Brasil (sentença de 15/03/2018) — a Corte responsabilizou internacionalmente o Brasil, entre outros pontos, pela falta de investigação, julgamento e punição dos responsáveis pela tortura e morte do jornalista Vladimir Herzog no DOI-CODI/SP em 1975, durante o regime militar brasileiro, bem como pela aplicação de obstáculos incompatíveis com as obrigações internacionais pertinentes.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
