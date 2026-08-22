-- Curadoria das unidades pedagogicas de Ortografia
-- (curso_conteudos.id = 20), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/ortografia.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 20, assunto "Ortografia")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Ortografia
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_ortografia*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 20;
  v_unidade_1_id constant uuid := 'dc6d39fb-5600-43d4-bad6-e3de2356236d';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Ortografia",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Ortografia'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Ortografia nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 20 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 20 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Ortografia',
    escopo = 'Ortografia da Língua Portuguesa, organizada em dois eixos: EIXO A — grafia e emprego de letras/dígrafos que representam o mesmo fonema (S/Z, S/SS, SC/XC, C/Ç, X/CH, G/J), com foco nos padrões mais cobrados em concursos (verbos formados com sufixo -izar/-isar; prefixos des-/es-; grafia lexical consagrada, confirmável no VOLP, para palavras como exceção, coragem, obsessão, êxtase; o par hesitar × exitar, parônimos com sentidos distintos; o contraste trás (advérbio de lugar, com S) × traz (forma do verbo trazer, com Z); e a regra de acentuação das paroxítonas terminadas em L, como lavável). EIXO B — emprego do hífen conforme o Acordo Ortográfico da Língua Portuguesa (Decreto nº 6.583/2008): Base XV (compostos com bem-/mal- diante de vogal ou H, recém-, além-, aquém-, sem-, e locuções substantivas que perderam o hífen, como "fim de semana") e Base XVI (prefixação geral — auto-, anti-, micro-, inter-, neo-, pré-/pró-/pós- tônicos, ex-, com as regras de vogal igual leva hífen/vogal diferente une sem hífen, consoante repetida leva hífen, e segundo elemento iniciado por H leva hífen).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
