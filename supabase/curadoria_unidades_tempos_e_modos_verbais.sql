-- Curadoria das unidades pedagogicas de Tempos e modos verbais
-- (curso_conteudos.id = 31), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/tempos_e_modos_verbais.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 31, assunto "Tempos e modos verbais")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Tempos e modos verbais
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_tempos_e_modos_verbais*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 31;
  v_unidade_1_id constant uuid := 'd54fb675-78a8-4efb-a99a-44359555d28f';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Tempos e modos verbais",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Tempos e modos verbais'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Tempos e modos verbais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 31 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 31 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Tempos e modos verbais',
    escopo = 'Tempos e modos verbais da Língua Portuguesa: sistema de tempos do modo indicativo (pretérito perfeito, pretérito imperfeito, futuro do presente, futuro do pretérito) e do modo subjuntivo (presente, pretérito imperfeito, futuro), reconhecidos pelas desinências modo-temporais (-va-/-ia- pretérito imperfeito, -ria- futuro do pretérito, -rá-/-rei- futuro do presente com limite nos radicais futuros irregulares como farão/dirão/trarão, -sse- pretérito imperfeito do subjuntivo, -r- futuro do subjuntivo) tratadas como pistas contextuais fortes e não como regras universais infalíveis, especialmente na distinção entre futuro do subjuntivo e infinitivo pessoal em verbos regulares (dependente do conectivo — quando/se versus preposição — e da função sintática da oração); correlação verbal condicional entre o pretérito imperfeito do subjuntivo e o futuro do pretérito do indicativo (se eu pudesse, viajaria); valores semânticos dos modos verbais no indicativo (fato, ocorrência, constatação assumida pelo enunciador), no subjuntivo (hipótese, possibilidade, desejo, dúvida, condição, eventualidade, avaliação, não asserção) e no imperativo (ordem, pedido, conselho, convite, orientação, instrução), sempre determinados pelo contexto da questão real, não por definição absoluta; a inexistência do tempo "futuro do pretérito" no modo subjuntivo (que possui apenas presente, pretérito imperfeito e futuro), pegadinha típica de banca; contraste entre tempo/modo verbal (formas finitas) e formas nominais do verbo (infinitivo, gerúndio, particípio), que não constituem isoladamente tempo ou modo; e verbos irregulares recorrentes no corpus, com destaque para a distinção vir × ver (virão/vêm/veem/vieram) e as formas de estar (estiveram/estejamos/estivéssemos).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
