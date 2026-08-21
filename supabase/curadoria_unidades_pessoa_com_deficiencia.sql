-- Curadoria das unidades pedagogicas de Pessoa com deficiência
-- (curso_conteudos.id = 71), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pessoa_com_deficiencia.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 71, assunto "Pessoa com deficiência")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pessoa com deficiência
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pessoa_com_deficiencia*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 71;
  v_unidade_1_id constant uuid := '435543fe-bdc2-452a-be2d-ffa414c5e27d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pessoa com deficiência",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pessoa com deficiência'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pessoa com deficiência nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 71 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 71 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pessoa com deficiência',
    escopo = 'Pessoa com deficiência: Convenção Internacional sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo, com status de emenda constitucional no Brasil pelo rito do art. 5º, §3º, da Constituição Federal, promulgados pelo Decreto nº 6.949/2009 (ato de promulgação, cujos próprios artigos 1º-3º não se confundem com os artigos da Convenção/Protocolo aqui referidos) — definições de discriminação por motivo de deficiência, adaptação razoável e desenho universal (art. 2); igualdade e não discriminação, com garantia de adaptação razoável (art. 5); proteção contra exploração, violência e abuso, incluindo monitoramento por autoridades independentes (art. 16); proteção da integridade física e mental (art. 17); participação na vida cultural (art. 30); e, no Protocolo Facultativo (numeração própria, reiniciada), o sistema de comunicações individuais ao Comitê sobre os Direitos das Pessoas com Deficiência, incluindo competência, critérios de admissibilidade, medidas cautelares e sigilo das sessões (arts. 1, 2, 4 e 5 do Protocolo). Lei nº 7.853/1989 (diploma nacional distinto, com o art. 8º inteiramente reescrito pela Lei nº 13.146/2015 e atualizações terminológicas pontuais da Lei nº 15.155/2025) — direitos básicos assegurados pelo Poder Público, incluindo medidas na área da saúde (art. 2º, parágrafo único, II); e crimes em razão da deficiência, incluindo discriminação em ensino, concurso público, emprego, assistência à saúde, ação civil pública e planos privados de saúde (art. 8º, redação vigente pós-2015).',
    artigos_esperados = array['art. 2','art. 5, item 3','art. 16, item 1','art. 16, item 3','art. 16, item 4','art. 16, item 5','art. 17','art. 30, item 1','art. 2º, parágrafo único, II, "b"','art. 2º, parágrafo único, II, "d"','art. 2º, parágrafo único, II, "f"','art. 8º, I','art. 8º, II','art. 8º, III','art. 8º, IV','art. 8º, VI','art. 8º, §3º'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
