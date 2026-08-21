-- Curadoria das unidades pedagogicas de Plano de Carreira dos Servidores Militares
-- (curso_conteudos.id = 65), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/plano_de_carreira_dos_servidores_militares.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 65, assunto "Plano de Carreira dos Servidores Militares")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Plano de Carreira dos Servidores Militares
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_plano_de_carreira_dos_servidores_militares*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 65;
  v_unidade_1_id constant uuid := '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Plano de Carreira dos Servidores Militares",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Plano de Carreira dos Servidores Militares'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Plano de Carreira dos Servidores Militares nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 65 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 65 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Plano de Carreira dos Servidores Militares',
    escopo = 'Plano de Carreira dos Servidores Militares (Lei Complementar Estadual nº 10.992/1997): estrutura da carreira dos Servidores Militares Estaduais de Nível Superior, por meio do Quadro de Oficiais de Estado Maior (QOEM) e do Quadro de Oficiais Especialistas em Saúde (QOES) — ingresso no QOEM mediante concurso público de provas e títulos com exigência de diplomação no Curso de Ciências Jurídicas e Sociais e aprovação no Curso Superior de Polícia Militar (art. 3º); possibilidade de recusa, pelo servidor, da inclusão no quadro de acesso à promoção ao posto de Coronel (art. 2º, §2º); e requisitos para promoção aos postos de Major (Curso Avançado de Administração Policial Militar) e de Coronel (Curso de Especialização em Políticas e Gestão de Segurança Pública) (art. 5º). Progressão funcional e promoção, em geral, sujeitam-se aos requisitos e critérios estabelecidos nesta legislação específica.',
    artigos_esperados = array['art. 2º, §2º','art. 3º, §1º','art. 3º, §2º','art. 5º, §1º','art. 5º, §2º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
