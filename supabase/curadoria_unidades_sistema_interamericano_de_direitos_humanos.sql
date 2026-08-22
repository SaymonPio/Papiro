-- Curadoria das unidades pedagogicas de Sistema Interamericano de Direitos Humanos
-- (curso_conteudos.id = 85), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/sistema_interamericano_de_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 85, assunto "Sistema Interamericano de Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Sistema Interamericano de Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_sistema_interamericano_de_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 85;
  v_unidade_1_id constant uuid := 'd815fc1f-82d3-4411-9dc5-63dae5373d2b';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Sistema Interamericano de Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Sistema Interamericano de Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Sistema Interamericano de Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 85 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 85 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Sistema Interamericano de Direitos Humanos',
    escopo = 'Sistema Interamericano de Direitos Humanos: estrutura composta por dois órgãos competentes para conhecer dos assuntos relacionados ao cumprimento dos compromissos assumidos pelos Estados Partes — a Comissão Interamericana de Direitos Humanos e a Corte Interamericana de Direitos Humanos (CADH, art. 33); a Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica) é um dos principais tratados desse sistema; o sistema interamericano atua de forma complementar (coadjuvante) à proteção interna oferecida pelo direito interno dos Estados americanos, conforme reconhece o Preâmbulo da CADH, sem funcionar como substituto automático do Judiciário nacional e sem eximir o Estado de responsabilidade internacional quando a proteção interna falha.',
    artigos_esperados = array['art. 33'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
