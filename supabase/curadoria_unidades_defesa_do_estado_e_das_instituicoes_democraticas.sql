-- Curadoria das unidades pedagogicas de Defesa do Estado e das Instituições Democráticas
-- (curso_conteudos.id = 48), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/defesa_do_estado_e_das_instituicoes_democraticas.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 48, assunto "Defesa do Estado e das Instituições Democráticas")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Defesa do Estado e das Instituições Democráticas
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_defesa_do_estado_e_das_instituicoes_democraticas*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 48;
  v_unidade_1_id constant uuid := 'ecdb1d62-ef44-4407-b899-85911402bc90';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Defesa do Estado e das Instituições Democráticas",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Defesa do Estado e das Instituições Democráticas'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Defesa do Estado e das Instituições Democráticas nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 48 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 48 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Defesa do Estado e das Instituições Democráticas',
    escopo = 'Defesa do Estado e das Instituições Democráticas na Constituição Federal: Conselho da República e Conselho de Defesa Nacional, como órgãos constitucionais de consulta do Presidente da República relacionados à defesa institucional (arts. 89-91); estado de defesa e estado de sítio, com seus pressupostos, procedimento, prazos, medidas coercitivas e garantias efetivamente cobradas (arts. 136-138); Forças Armadas, incluindo restrições constitucionais aos militares e serviço militar obrigatório (arts. 142-143); e segurança pública (art. 144, caput), tema também coberto no conteúdo específico Segurança pública.',
    artigos_esperados = array['art. 90, I','art. 90, II','art. 91, §1º, II','art. 136, caput','art. 136, §1º, I, "a"','art. 136, §2º','art. 136, §3º, I','art. 136, §3º, IV','art. 136, §4º','art. 137, I','art. 137, parágrafo único','art. 138, caput','art. 138, §2º','art. 142, §2º','art. 142, §3º, IV','art. 142, §3º, V','art. 143, §1º','art. 143, §2º','art. 144, caput'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
