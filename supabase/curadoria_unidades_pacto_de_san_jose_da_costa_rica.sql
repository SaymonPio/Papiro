-- Curadoria das unidades pedagogicas de Pacto de San José da Costa Rica
-- (curso_conteudos.id = 72), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pacto_de_san_jose_da_costa_rica.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 72, assunto "Pacto de San José da Costa Rica")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pacto de San José da Costa Rica
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pacto_de_san_jose_da_costa_rica*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 72;
  v_unidade_1_id constant uuid := 'b918b069-8364-4412-80a6-07d78b369317';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pacto de San José da Costa Rica",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pacto de San José da Costa Rica'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pacto de San José da Costa Rica nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 72 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 72 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pacto de San José da Costa Rica',
    escopo = 'Convenção Americana sobre Direitos Humanos — Pacto de San José da Costa Rica (Decreto nº 678/1992): direito à vida e vedações à pena de morte (art. 4º); direito à integridade pessoal, vedação à tortura e penas cruéis, finalidade das penas privativas de liberdade e separação de menores processados dos adultos (art. 5º); proibição da escravidão, servidão e trabalho forçado, com as exceções legais (art. 6º); direito à liberdade pessoal, vedação à detenção arbitrária, direito de ser informado das razões da detenção e vedação à prisão por dívida, ressalvada a obrigação alimentar (art. 7º); garantias judiciais, incluindo presunção de inocência, assistência gratuita de tradutor/intérprete, direito de defesa e vedação ao duplo julgamento pelos mesmos fatos (art. 8º); direito à indenização por erro judiciário (art. 10); liberdade de consciência e de religião, incluindo o direito dos pais de educar os filhos conforme suas convicções (art. 12); proteção da família (art. 17); direitos da criança (art. 19); direito de circulação e de residência (art. 22); e suspensão de garantias em situações de emergência, com o rol de direitos não suspensáveis (art. 27). A unidade também trabalha a distinção entre os direitos civis e políticos enumerados no Capítulo II (arts. 3º-25) e os direitos econômicos, sociais e culturais tratados de forma programática no art. 26 (Capítulo III), sem remissão material a este último quando não efetivamente cobrado.',
    artigos_esperados = array['art. 4º, item 4','art. 4º, item 5','art. 5º, item 1','art. 5º, item 2','art. 5º, item 5','art. 5º, item 6','art. 6º, item 1','art. 6º, item 3, "a"','art. 7º, item 1','art. 7º, item 3','art. 7º, item 4','art. 7º, item 7','art. 8º, item 2','art. 8º, item 2, "a"','art. 8º, item 2, "d"','art. 8º, item 4','art. 10','art. 12, item 4','art. 17, item 1','art. 19','art. 22, item 5','art. 27, item 2'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
