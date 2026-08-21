-- Curadoria das unidades pedagogicas de Hierarquia e disciplina
-- (curso_conteudos.id = 52), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/hierarquia_e_disciplina.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 52, assunto "Hierarquia e disciplina")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Hierarquia e disciplina
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_hierarquia_e_disciplina*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 52;
  v_unidade_1_id constant uuid := 'cbde0aeb-3df8-4c41-a82f-91b83b529668';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Hierarquia e disciplina",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Hierarquia e disciplina'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Hierarquia e disciplina nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 52 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 52 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Hierarquia e disciplina',
    escopo = 'Hierarquia e disciplina no Estatuto dos Militares Estaduais (Lei Complementar nº 10.990/1997): a hierarquia e a disciplina militares como base institucional da Brigada Militar (art. 12, caput); a definição legal de hierarquia militar, como ordenação da autoridade em níveis diferentes por postos/graduações e, dentro de um mesmo posto/graduação, pela antiguidade (art. 12, §1º); a definição legal de disciplina militar, como observância rigorosa das normas que coordenam o funcionamento regular e harmônico da corporação (art. 12, §2º); a extensão da disciplina e do respeito à hierarquia aos servidores militares da reserva remunerada e reformados, além dos da ativa (art. 12, §3º); os círculos hierárquicos como âmbito de convivência entre servidores da mesma categoria (art. 13, caput); e a precedência entre servidores militares da ativa do mesmo grau hierárquico, assegurada pela antiguidade, salvo nos casos de precedência funcional do Comandante-Geral, do Subcomandante-Geral e do Chefe do Estado-Maior (art. 15, caput) — este último ponto também testado no conteúdo "Estatuto dos Militares Estaduais".',
    artigos_esperados = array['art. 12, caput','art. 12, §1º','art. 12, §2º','art. 12, §3º','art. 13, caput','art. 15, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
