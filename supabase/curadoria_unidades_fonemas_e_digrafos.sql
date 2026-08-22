-- Curadoria das unidades pedagogicas de Fonemas e dígrafos
-- (curso_conteudos.id = 34), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/fonemas_e_digrafos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 34, assunto "Fonemas e dígrafos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Fonemas e dígrafos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_fonemas_e_digrafos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 34;
  v_unidade_1_id constant uuid := '61bd0288-38fe-45bc-9c1e-51c1ecc9a515';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Fonemas e dígrafos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Fonemas e dígrafos'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Fonemas e dígrafos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 34 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 34 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Fonemas e dígrafos',
    escopo = 'Fonemas e dígrafos da Língua Portuguesa: distinção entre letra (grafema) e fonema (som); conceito de dígrafo — duas letras representando um único fonema — consonantal (ch, lh, nh, rr, ss, sc, sç, xc) e vocálico/nasal (am, an, em, en, im, in, om, on, um, un), reconhecido pelo comportamento fonético e silábico, não por lista mecânica; dígrafos GU/QU apenas quando o U não tem realização fonética própria (guerra, quero), distintos dos casos em que o U soa (água); contraste entre dígrafo e encontro consonantal (cada consoante mantém seu próprio fonema), com a subclassificação em encontro consonantal perfeito/puro (mesma sílaba: claro, prato, tribo) e imperfeito/disjunto (sílabas diferentes: corpo, apto, ritmo); procedimento de contagem de fonemas (contar letras; identificar dígrafos; identificar letras sem fonema próprio, como o H mudo inicial; identificar letras que representam mais de um fonema, como o X em /ks/; contar os sons efetivos), com a fórmula letras-dígrafos tratada como regra de bolso inicial e não como definição universal; vogal epentética em encontros consonantais de articulação mais difícil na fala brasileira, sem absolutos sobre quais encontros sempre ou nunca a recebem, e distinguindo grafia de realização fonética; encontros vocálicos — ditongo (vogal+semivogal ou semivogal+vogal na mesma sílaba, crescente ou decrescente), hiato (sons vocálicos em sílabas diferentes) e tritongo (semivogal+vogal+semivogal na mesma sílaba), inclusive casos em que a própria banca discute ditongo x hiato para uma mesma sequência; e regras de separação silábica aplicando os mesmos conceitos — dígrafos inseparáveis (ch, lh, nh) x separáveis (rr, ss, sc, sç, xc), e ditongos/tritongos sempre pertencentes à mesma sílaba.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
