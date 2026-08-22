-- Curadoria das unidades pedagogicas de Prevenção da tortura
-- (curso_conteudos.id = 99), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/prevencao_da_tortura.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 99, assunto "Prevenção da tortura")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Prevenção da tortura
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_prevencao_da_tortura*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 99;
  v_unidade_1_id constant uuid := '1c05566b-5c71-4baa-b965-3577b8ffdc17';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Prevenção da tortura",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Prevenção da tortura'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Prevenção da tortura nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 99 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 99 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Prevenção da tortura',
    escopo = 'Prevenção da tortura: a Convenção contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (ONU, 1984) estabelece que em nenhum caso podem invocar-se circunstâncias excepcionais — incluindo ameaça ou estado de guerra, instabilidade política interna ou qualquer outra emergência pública — como justificação para a tortura (art. 2, item 2); tampouco a ordem de um funcionário superior ou de uma autoridade pública pode ser invocada como justificativa para a tortura (art. 2, item 3, contexto relevante para eliminar o distrator "ordem superior"). A proibição da tortura é, nesse sentido, absoluta e incompatível com a dignidade humana, princípio que orienta o sistema brasileiro de direitos humanos. O Protocolo Facultativo à Convenção da ONU contra a Tortura (OPCAT) estabelece um sistema de visitas regulares, por órgãos internacionais e nacionais independentes, a locais onde se encontrem pessoas privadas de liberdade, com o objetivo de prevenir a tortura, reduzindo riscos de maus-tratos e fortalecendo garantias das pessoas custodiadas (art. 1) — implementado no Brasil pela Lei nº 12.847/2013, que instituiu o Sistema Nacional de Prevenção e Combate à Tortura e o Mecanismo Nacional de Prevenção e Combate à Tortura (MNPCT).',
    artigos_esperados = array['art. 2, item 2','art. 1'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
