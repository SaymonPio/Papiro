-- Curadoria das unidades pedagogicas de Corte Interamericana de Direitos Humanos
-- (curso_conteudos.id = 88), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/corte_interamericana_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 88, assunto "Corte Interamericana de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Corte Interamericana de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_corte_interamericana_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 88;
  v_unidade_1_id constant uuid := '9ab2c28c-2c1d-4d15-b134-a191ff946529';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Corte Interamericana de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Corte Interamericana de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Corte Interamericana de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 88 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 88 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Corte Interamericana de Direitos Humanos',
    escopo = 'Corte Interamericana de Direitos Humanos: instituição judiciária autônoma do sistema interamericano cujo objetivo é a aplicação e a interpretação da Convenção Americana sobre Direitos Humanos — CADH/Pacto de San José da Costa Rica (Estatuto da Corte IDH, art. 1); composta por sete juízes, nacionais dos Estados membros da OEA, eleitos a título pessoal dentre juristas da mais alta autoridade moral e de reconhecida competência em matéria de direitos humanos (CADH, art. 52, item 1); sede em San José, Costa Rica (Estatuto da Corte IDH, art. 3); os Estados Partes comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes (CADH, art. 68, item 1). O Brasil reconheceu a competência obrigatória (jurisdição contenciosa) da Corte por declaração depositada em 10/12/1998, promulgada pelo Decreto nº 4.463/2002, com efeitos para fatos posteriores a essa data.',
    artigos_esperados = array['art. 52, item 1','art. 68, item 1'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
