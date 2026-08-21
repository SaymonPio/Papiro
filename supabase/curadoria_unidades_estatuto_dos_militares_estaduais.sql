-- Curadoria das unidades pedagogicas de Estatuto dos Militares Estaduais
-- (curso_conteudos.id = 51), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/estatuto_dos_militares_estaduais.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 51, assunto "Estatuto dos Militares Estaduais")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Estatuto dos Militares Estaduais
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_estatuto_dos_militares_estaduais*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 51;
  v_unidade_1_id constant uuid := 'bf13f365-3dd9-4d22-9ad7-f369a298eb19';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Estatuto dos Militares Estaduais",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Estatuto dos Militares Estaduais'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Estatuto dos Militares Estaduais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 51 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 51 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Estatuto dos Militares Estaduais',
    escopo = 'Estatuto dos Militares Estaduais (Lei Complementar nº 10.990/1997): hierarquia e disciplina como base institucional da Brigada Militar (art. 12); serviço e carreira policial-militar, incluindo o regime próprio aplicável a Oficiais nomeados Juízes do Tribunal Militar do Estado e a precedência hierárquica entre servidores militares (arts. 4º, 5º, 8º, 15); direitos dos servidores militares, incluindo assistência judiciária, assistência social e médico-hospitalar, saúde/higiene/segurança do trabalho, transferência para reserva remunerada ou reforma, férias e licenças (art. 46); e violação das obrigações e dos deveres policiais-militares, incluindo a independência da responsabilidade disciplinar em relação às responsabilidades civil e penal (arts. 35-36).',
    artigos_esperados = array['art. 4º, caput','art. 5º, parágrafo único','art. 8º, parágrafo único','art. 12, caput','art. 15, caput','art. 15, §3º','art. 35, caput','art. 35, §2º','art. 35, §3º','art. 36, caput','art. 46, VII','art. 46, VIII','art. 46, XIII','art. 46, XIV','art. 46, XV'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
