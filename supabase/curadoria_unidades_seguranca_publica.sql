-- Curadoria das unidades pedagogicas de Segurança pública
-- (curso_conteudos.id = 49), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/seguranca_publica.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 49, assunto "Segurança pública")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Segurança pública
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_seguranca_publica*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 49;
  v_unidade_1_id constant uuid := '7cc8a187-da9b-457d-beeb-f496ddd32580';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Segurança pública",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Segurança pública'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Segurança pública nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 49 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 49 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Segurança pública',
    escopo = 'Segurança pública na Constituição Federal (art. 144): dever do Estado e responsabilidade de todos; órgãos de segurança pública (polícia federal, rodoviária federal, ferroviária federal, polícias civis, polícias militares e corpos de bombeiros militares, polícias penais); atribuições de cada órgão; subordinação aos Governadores; guardas municipais; e jurisprudência do STF/STJ sobre o caráter não taxativo do rol de órgãos e a competência residual da polícia civil. Inclui também, pontualmente, a participação da sociedade nos Conselhos de Defesa e Segurança da Comunidade prevista na Constituição do Estado do Rio Grande do Sul (art. 126, caput) — os demais 15 dispositivos listados em artigos_esperados são da Constituição Federal; apenas o art. 126 é da Constituição Estadual.',
    artigos_esperados = array['art. 144, caput','art. 144, I','art. 144, II','art. 144, III','art. 144, IV','art. 144, V','art. 144, VI','art. 144, §1º, II','art. 144, §1º, IV','art. 144, §4º','art. 144, §5º','art. 144, §5º-A','art. 144, §6º','art. 144, §7º','art. 144, §8º','art. 126, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
