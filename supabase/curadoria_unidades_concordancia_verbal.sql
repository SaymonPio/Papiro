-- Curadoria das unidades pedagogicas de Concordância verbal
-- (curso_conteudos.id = 18), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/concordancia_verbal.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 18, assunto "Concordância verbal")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Concordância verbal
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_concordancia_verbal*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 18;
  v_unidade_1_id constant uuid := '834a820d-48a7-440f-a013-be375be8a62d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Concordância verbal",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Concordância verbal'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Concordância verbal nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 18 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 18 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Concordância verbal',
    escopo = 'Concordância verbal da Língua Portuguesa, com núcleo pré-edital definido pelo mecanismo geral (identificar o sujeito, seu núcleo e seu número, localizar todos os verbos que dependem dele, propagar corretamente singular/plural, reconhecendo formas com acento diferencial gráfico de número — tem/têm, vem/vêm, mantém/mantêm) e pela concordância verbal em cadeia observada nas questões reais deste corpus, quando a mudança de número do sujeito propaga-se a múltiplos verbos coordenados; distinção explícita entre concordância verbal (verbo com sujeito) e concordância nominal (artigo/demonstrativo com substantivo), que podem coexistir na mesma questão de reescrita sem se confundirem como o mesmo mecanismo; e, como cobertura secundária/suplementar (sustentada apenas por questões autorais, sem incidência real neste corpus), os verbos impessoais — haver, quando empregado com sentido de existir/ocorrer/acontecer, permanece sempre na 3ª pessoa do singular, inclusive como verbo principal de locução verbal ("deve haver", em que "deve" é o auxiliar e "haver" o infinitivo impessoal, mantendo o auxiliar no singular); existir, verbo pessoal que concorda normalmente com seu sujeito mesmo em locução ("pode existir"/"podem existir"); e fazer, impessoal apenas quando indica tempo decorrido ou fenômeno atmosférico, sem generalizar para todos os seus usos.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
