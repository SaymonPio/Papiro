-- Curadoria das unidades pedagogicas de Sistema Internacional de Proteção dos Direitos Humanos
-- (curso_conteudos.id = 82), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/sistema_internacional_de_protecao_dos_direitos_humanos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 82, assunto "Sistema Internacional de Proteção dos Direitos Humanos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Sistema Internacional de Proteção dos Direitos Humanos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_sistema_internacional_de_protecao_dos_direitos_humanos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 82;
  v_unidade_1_id constant uuid := '522f7c40-b95e-4c91-b0d6-cf4a6f012c16';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Sistema Internacional de Proteção dos Direitos Humanos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Sistema Internacional de Proteção dos Direitos Humanos'
      and cm.materia_id = 11
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Sistema Internacional de Proteção dos Direitos Humanos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 82 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 82 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Sistema Internacional de Proteção dos Direitos Humanos',
    escopo = 'Sistema Internacional de Proteção dos Direitos Humanos: (A) sistema universal, desenvolvido institucionalmente no âmbito da Organização das Nações Unidas, tendo a Declaração Universal dos Direitos Humanos de 1948 como um dos marcos centrais de sua consolidação — o Pacto Internacional sobre Direitos Civis e Políticos e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais podem ser citados como exemplos de instrumentos desse sistema, sem revisão detalhada de seu conteúdo; (B) sistemas regionais de proteção — interamericano, europeu e africano — apresentados apenas na medida necessária para diferenciá-los do sistema universal; (C) princípio da complementaridade: os sistemas universal e regionais podem coexistir e atuar de forma complementar entre si e com a proteção nacional dos direitos humanos, sem se excluírem mutuamente.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
