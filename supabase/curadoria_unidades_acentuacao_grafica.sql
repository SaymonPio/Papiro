-- Curadoria das unidades pedagogicas de Acentuação gráfica
-- (curso_conteudos.id = 26), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/acentuacao_grafica.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 26, assunto "Acentuação gráfica")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Acentuação gráfica
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_acentuacao_grafica*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 26;
  v_unidade_1_id constant uuid := 'd100427d-d567-43e8-8ec8-81d44e5e3afe';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Acentuação gráfica",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Acentuação gráfica'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Acentuação gráfica nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 26 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 26 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Acentuação gráfica',
    escopo = 'Acentuação gráfica da Língua Portuguesa: identificação da sílaba tônica e classificação das palavras quanto à tonicidade (oxítona, paroxítona, proparoxítona, monossílabo tônico); regras produtivas de acentuação — proparoxítonas (sempre acentuadas, sem exceção), oxítonas terminadas em A/E/O (seguidas ou não de S) e em -EM/-ENS, paroxítonas terminadas em L, N, R, X, US, ditongo oral (crescente ou decrescente) — nota: para palavras como rádio, critério, história, incumbência, excelência, referências, municípios, latrocínios e feminicídios, a análise tradicional escolar as trata como paroxítonas terminadas em ditongo crescente, embora o Acordo Ortográfico também admita a categoria de proparoxítonas aparentes para essas sequências pós-tônicas — o critério da banca deve ser observado; monossílabos tônicos terminados em A, E, O; regra do hiato tônico com I/U (quando formam sílaba própria, sozinhos ou seguidos apenas de S, e não são seguidos de NH — como em rainha e moinho, que não recebem acento, nem juiz e raiz nessa configuração); manutenção do acento no plural de paroxítonas terminadas em -vel (indispensável/impecável/escalável → indispensáveis/impecáveis/escaláveis), decorrente da manutenção da sílaba tônica dentro das regras gerais; o til como sinal de nasalidade (não de tonicidade); e os efeitos da presença ou ausência do acento — mudança de tonicidade, de classe gramatical, de sentido, ou a existência/inexistência de outra forma lexical ou verbal (número × numero; vivências × vivencias; é × e; ninguém × ninguem, que não existe) — reservando o termo "acento diferencial" apenas para os pares normativos reais (pôde × pode, pôr × por, têm × tem, vêm × vem, estes últimos monossílabos tônicos cujo circunflexo marca o plural verbal).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
