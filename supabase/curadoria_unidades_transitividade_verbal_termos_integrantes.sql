-- Curadoria das unidades pedagogicas de Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)
-- (curso_conteudos.id = 27), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/transitividade_verbal_termos_integrantes.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 27, assunto "Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_transitividade_verbal_termos_integrantes*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 27;
  v_unidade_1_id constant uuid := '981e5d2c-3b59-48a0-a699-a53c03e500ee';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva) nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 27 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 27 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)',
    escopo = 'Transitividade verbal (verbos transitivos diretos, indiretos e diretos e indiretos) e termos integrantes da oração: objeto direto, inclusive o objeto direto preposicionado — que continua sendo objeto direto mesmo introduzido por preposição, por razões de desambiguação, estilo ou estrutura, nunca classificado automaticamente como objeto indireto apenas por haver preposição; objeto indireto, com a regra de bolso de que os pronomes o/a/os/as tipicamente substituem objeto direto e lhe/lhes tipicamente substituem objeto indireto, ressalvado o limite de que lhe/lhes podem assumir valor possessivo em certos usos normativos; agente da passiva, identificado na voz passiva analítica (sujeito paciente + verbo ser + particípio + agente introduzido tipicamente por por/pelo/pela, tratado como pista forte e não definição isolada) e sua conversão correta para a voz ativa (o agente da passiva torna-se sujeito, o sujeito paciente torna-se objeto direto correspondente, sem introdução indevida de pronome reflexivo); e, como cobertura secundária/breve (sem aprofundamento equivalente, por ausência de incidência real no corpus atual), o complemento nominal em contraste geral com o complemento verbal (o complemento nominal completa o sentido de um nome — substantivo abstrato, adjetivo ou advérbio — enquanto o complemento verbal completa o sentido do verbo).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
