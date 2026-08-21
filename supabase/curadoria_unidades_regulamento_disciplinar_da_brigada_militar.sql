-- Curadoria das unidades pedagogicas de Regulamento Disciplinar da Brigada Militar
-- (curso_conteudos.id = 64), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/regulamento_disciplinar_da_brigada_militar.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 64, assunto "Regulamento Disciplinar da Brigada Militar")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Regulamento Disciplinar da Brigada Militar
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_regulamento_disciplinar_da_brigada_militar*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 64;
  v_unidade_1_id constant uuid := '454f8501-7818-4dc4-b22a-337247678c58';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Regulamento Disciplinar da Brigada Militar",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Regulamento Disciplinar da Brigada Militar'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Regulamento Disciplinar da Brigada Militar nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 64 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 64 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Regulamento Disciplinar da Brigada Militar',
    escopo = 'Regulamento Disciplinar da Brigada Militar do Estado do Rio Grande do Sul (Decreto Estadual nº 43.245/2004, aprovado com base no art. 35 da Lei Complementar Estadual nº 10.990/1997): finalidade do regulamento (art. 1º, caput); camaradagem, harmonia entre superior e subordinado, civilidade, cortesia e urbanidade (art. 1º, §1º a §3º); âmbito de aplicação, inclusive as hipóteses restritas de incidência sobre militares inativos (art. 2º, §1º); hierarquia e disciplina como base institucional (art. 3º); classificação e enumeração das sanções disciplinares — advertência, repreensão, detenção, prisão, licenciamento e exclusão a bem da disciplina (art. 9º) — e as definições específicas de advertência (art. 10), repreensão (art. 11), detenção (art. 12, caput) e o instituto da prisão administrativa (art. 13); e processo administrativo disciplinar militar — dever de comunicar fato contrário à disciplina (art. 26), devido processo/ampla defesa e princípios do processo (art. 28, caput e parágrafo único) e autoridades competentes para instauração, procedimento e julgamento (art. 29, caput).',
    artigos_esperados = array['art. 1º, caput','art. 1º, §1º','art. 1º, §2º','art. 1º, §3º','art. 2º, §1º','art. 3º','art. 9º, V','art. 9º, VI','art. 10','art. 11','art. 12, caput','art. 13','art. 26','art. 28, caput','art. 28, parágrafo único','art. 29, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
