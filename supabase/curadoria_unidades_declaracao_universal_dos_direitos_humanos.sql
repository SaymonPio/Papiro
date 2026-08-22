-- Curadoria das unidades pedagogicas de Declaração Universal dos Direitos Humanos
-- (curso_conteudos.id = 83), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/declaracao_universal_dos_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 83, assunto "Declaração Universal dos Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Declaração Universal dos Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_declaracao_universal_dos_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 83;
  v_unidade_1_id constant uuid := 'e7bef052-b882-4a2f-b1e6-88ce12740c26';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Declaração Universal dos Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Declaração Universal dos Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Declaração Universal dos Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 83 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 83 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Declaração Universal dos Direitos Humanos',
    escopo = 'Declaração Universal dos Direitos Humanos (proclamada pela Assembleia Geral da ONU em 10/12/1948, Resolução 217 A (III); não é tratado sujeito a ratificação/promulgação, mas marco fundamental do sistema internacional de direitos humanos): direito à igualdade em dignidade e direitos desde o nascimento (art. 1º); direito à vida, à liberdade e à segurança pessoal (art. 3º); vedação à escravidão e servidão (art. 4º); vedação à tortura e a penas ou tratamentos cruéis, desumanos ou degradantes, sem qualquer exceção (art. 5º); igualdade perante a lei (art. 7º); direito a julgamento equitativo e público por tribunal independente e imparcial (art. 10); presunção de inocência e princípio da legalidade/irretroatividade penal, sem exceções (art. 11); liberdade de pensamento, consciência e religião (art. 18); direito de participar do governo do país (art. 21); direito à instrução, com gratuidade assegurada pelo menos nos graus elementares e fundamentais, sendo o ensino superior baseado no mérito e aberto a todos em igualdade, sem garantia de gratuidade (art. 26); direito de participar da vida cultural da comunidade (art. 27); e deveres para com a comunidade (art. 29). Determinadas edições gráficas da Declaração numeram seus artigos em algarismos romanos; artigos_esperados usa representação arábica normalizada por compatibilidade com o parser, sem alteração da referência substantiva.',
    artigos_esperados = array['art. 1º','art. 3º','art. 4º','art. 5º','art. 7º','art. 10','art. 11, item 1','art. 11, item 2','art. 18','art. 21, item 1','art. 26','art. 27, item 1','art. 29, item 1'],
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
