-- Curadoria das unidades pedagogicas de Abuso de Autoridade
-- (curso_conteudos.id = 70), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/abuso_de_autoridade_direitos_humanos_70.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 70, assunto "Abuso de Autoridade")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Abuso de Autoridade
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_abuso_de_autoridade_direitos_humanos_70*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 70;
  v_unidade_1_id constant uuid := 'd4d8a1fc-4c52-4c85-879c-031d0085be88';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Abuso de Autoridade",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Abuso de Autoridade'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Abuso de Autoridade nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 70 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 70 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Abuso de Autoridade',
    escopo = 'Lei nº 13.869/2019 (Lei de Abuso de Autoridade): a divergência na interpretação da lei ou na avaliação de fatos e provas não configura abuso de autoridade por si só (art. 1º, §2º); efeitos da condenação — tornar certa a obrigação de indenizar o dano causado pelo crime, com valor mínimo fixado na sentença mediante requerimento do ofendido (art. 4º, I), inabilitação para cargo, mandato ou função pública por 1 a 5 anos (art. 4º, II) e perda do cargo, mandato ou função pública (art. 4º, III), sendo estes dois últimos condicionados à reincidência específica em crime de abuso de autoridade, não automáticos e exigindo declaração motivada na sentença (art. 4º, parágrafo único); crime de violência institucional, consistente em submeter vítima de infração penal ou testemunha de crimes violentos a procedimento repetitivo, desnecessário ou invasivo que a leve a reviver, sem estrita necessidade, a situação de violência (art. 15-A, caput); deixar de identificar-se ou identificar-se falsamente ao preso por ocasião de sua captura ou detenção, inclusive por parte do responsável por interrogatório (art. 16, caput e parágrafo único); inovar artificiosamente, no curso de diligência, o estado de lugar, coisa ou pessoa, com o fim de eximir-se ou de agravar responsabilidade de terceiro (art. 23, caput); e a exceção de não configuração do crime de invasão de imóvel quando o ingresso se dá para prestar socorro ou em razão de flagrante delito ou desastre (art. 22, §2º).',
    artigos_esperados = array['art. 1º, §2º','art. 4º, caput','art. 4º, I','art. 4º, II','art. 4º, III','art. 4º, parágrafo único','art. 15-A, caput','art. 16, caput','art. 16, parágrafo único','art. 22, §2º','art. 23, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
