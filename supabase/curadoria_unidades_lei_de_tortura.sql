-- Curadoria das unidades pedagogicas de Lei de Tortura
-- (curso_conteudos.id = 73), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/lei_de_tortura.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 73, assunto "Lei de Tortura")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Lei de Tortura
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_lei_de_tortura*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 73;
  v_unidade_1_id constant uuid := '392fd9fe-a3d2-4062-b912-0a299b414429';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Lei de Tortura",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Lei de Tortura'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Lei de Tortura nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 73 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 73 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Lei de Tortura',
    escopo = 'Lei nº 9.455/1997 (define os crimes de tortura): constranger alguém, com violência ou grave ameaça, causando sofrimento físico ou mental, para obter informação, declaração ou confissão da vítima ou de terceiro (art. 1º, I, "a"), ou para provocar ação ou omissão de natureza criminosa (art. 1º, I, "b"); submeter pessoa sob guarda, poder ou autoridade, com violência ou grave ameaça, a intenso sofrimento físico ou mental, como castigo pessoal ou medida de caráter preventivo (art. 1º, II); omissão de quem tinha o dever de evitar ou apurar essas condutas (art. 1º, §2º); causas de aumento de pena, inclusive quando o crime é cometido por agente público (art. 1º, §4º, I); perda do cargo, função ou emprego público, com interdição para seu exercício pelo dobro do prazo da pena aplicada (art. 1º, §5º); inafiançabilidade e vedação a graça ou anistia (art. 1º, §6º); regime inicial fechado, ressalvada a hipótese do §2º — texto literal ainda vigente, temperado pelo entendimento do STJ/STF (HC 111.840) que afasta sua obrigatoriedade absoluta, devendo a fixação do regime observar os critérios gerais aplicáveis ao caso (art. 1º, §7º); e extraterritorialidade da lei quando a vítima é brasileira ou o agente se encontra em local sob jurisdição brasileira (art. 2º, caput). A Lei nº 15.410/2026 acrescentou ao art. 1º o inciso III (tortura por submissão reiterada da mulher a intenso sofrimento físico ou mental no contexto de violência doméstica e familiar), não coberto pelas questões atuais.',
    artigos_esperados = array['art. 1º, I, "a"','art. 1º, I, "b"','art. 1º, II','art. 1º, §2º','art. 1º, §4º, I','art. 1º, §5º','art. 1º, §6º','art. 1º, §7º','art. 2º, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
