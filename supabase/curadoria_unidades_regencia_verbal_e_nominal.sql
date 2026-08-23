-- Curadoria das unidades pedagogicas de Regência verbal e nominal
-- (curso_conteudos.id = 17), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/regencia_verbal_e_nominal.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 17, assunto "Regência verbal e nominal")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Regência verbal e nominal
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_regencia_verbal_e_nominal*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 17;
  v_unidade_1_id constant uuid := '735f736a-37c0-477f-a555-dcd73d243d21';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Regência verbal e nominal",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Regência verbal e nominal'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Regência verbal e nominal nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 17 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 17 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Regência verbal e nominal',
    escopo = 'Regência verbal e nominal da Língua Portuguesa, com núcleo pré-edital fundamentado exclusivamente na questão real deste corpus (Q120): emprego correto de pronomes relativos conforme a regência do termo da oração subordinada que se relaciona com o relativo — nunca por associação mecânica tipo "em que = pronome para lugar", mas pelo procedimento de reconstruir mentalmente a oração relativa substituindo o pronome pelo antecedente, identificar qual termo rege esse antecedente reconstruído, e usar a preposição exigida + "que" (de que, em que, a que, com que, por que etc.). Regra de bolso: "retire o relativo e reconstrua a frase". CUJO tratado separadamente: estabelece relação de posse entre possuidor e coisa possuída, concorda em gênero/número com o substantivo posterior (a coisa possuída, não o possuidor), e nunca admite artigo entre si e esse substantivo ("cuja a obra", "cujo o livro" não existem). Como cobertura suplementar (sustentada apenas por questões autorais, sem incidência real neste corpus): regência verbal de verbos clássicos de concurso — assistir (ver/presenciar = VTI + "a"), aspirar (cheirar = VTD; almejar = VTI + "a" no padrão tradicional), obedecer/desobedecer (sempre VTI + "a"), visar (mirar/apor visto = VTD; almejar = VTI + "a" no padrão tradicional de concurso, com nota de que o uso contemporâneo pode divergir entre fontes), chegar/ir (regem "a" para indicar destino no padrão formal tradicional cobrado em concursos, sem que isso signifique que "chegar em" — amplamente usado na fala e em registros menos monitorados — "não existe"), e preferir (X a Y, sem construções comparativas redundantes como "mais...do que"). Distinção explícita entre regência (a preposição exigida pelo verbo) e crase (fusão dessa preposição "a" com artigo feminino "a/as", como em "obedecer às normas"). GAP_SUBASSUNTO_REGENCIA_NOMINAL: este corpus não contém nenhuma questão (real ou autoral) que cubra materialmente regência nominal (adjetivo/substantivo + preposição, como "favorável a", "aversão a", "necessidade de", "compatível com") — registrado como lacuna explícita para expansão futura, sem criar núcleo pré-edital nem cobertura suplementar sobre esse subassunto neste momento.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
