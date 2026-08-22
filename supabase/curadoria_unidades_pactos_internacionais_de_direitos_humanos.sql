-- Curadoria das unidades pedagogicas de Pactos Internacionais de Direitos Humanos
-- (curso_conteudos.id = 84), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/pactos_internacionais_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 84, assunto "Pactos Internacionais de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Pactos Internacionais de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_pactos_internacionais_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 84;
  v_unidade_1_id constant uuid := '7cfd81f6-49ab-4a15-b643-9a8a7b026deb';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Pactos Internacionais de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Pactos Internacionais de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Pactos Internacionais de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 84 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 84 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Pactos Internacionais de Direitos Humanos',
    escopo = 'Pactos Internacionais de Direitos Humanos: os dois grandes Pactos de 1966 — o Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) — foram adotados no âmbito da Organização das Nações Unidas; sua função doutrinária é desenvolver e tornar juridicamente vinculantes diversos direitos reconhecidos no plano internacional. A Declaração Universal dos Direitos Humanos (1948) foi proclamada por resolução da Assembleia Geral da ONU e não é um tratado internacional; os Pactos de 1966 desenvolveram os direitos nela proclamados e os positivaram em tratados juridicamente vinculantes para os respectivos Estados Partes, sem prejuízo de que determinadas normas refletidas na Declaração também possam corresponder a direito internacional costumeiro.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
