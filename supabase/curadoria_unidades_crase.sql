-- Curadoria das unidades pedagogicas de Crase
-- (curso_conteudos.id = 15), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/crase.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 15, assunto "Crase")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Crase
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_crase*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 15;
  v_unidade_1_id constant uuid := '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Crase",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Crase'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Crase nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 15 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 15 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Crase',
    escopo = 'Crase da Língua Portuguesa, entendida como fusão da preposição "a" (exigida por regência do termo anterior) com o artigo definido feminino "a/as" (admitido pelo termo seguinte), através do raciocínio em quatro passos: o termo anterior exige preposição "a"? o termo seguinte admite artigo "a/as"? os dois elementos coexistem? se sim, ocorre a crase (à/às) — nunca decidido por decoreba de listas isoladas. Casos de crase obrigatória por regência com substantivo feminino determinado (singular e plural) e locuções adverbiais femininas cristalizadas observadas no corpus ("à tona"); casos de ausência de crase, formulados sem absolutos: antes de palavra masculina ("em regra" não admite artigo feminino, ressalvadas construções elípticas como "à moda de"/"à maneira de"), antes de verbo no infinitivo (regra produtiva forte, confirmada nas questões reais do corpus), e entre palavras repetidas ("frente a frente", "cara a cara", "gota a gota"); o teste de substituição por equivalente masculino (se resultar "ao", forte indicação de crase) tratado explicitamente como heurística auxiliar, não como definição universal, com o limite de que não resolve sozinho locuções, nomes próprios, possessivos, casos facultativos nem construções cristalizadas ou controversas; a distinção, no caso específico de "motor à combustão" (Q328), entre regra consolidada e o entendimento adotado pela banca Fundatec em zona de variação doutrinária/normativa (fundamentado em Bechara, com Cegalla citado como fonte de facultatividade), sem universalizar a decisão específica da banca; e, como cobertura secundária (sem peso equivalente ao núcleo, por ausência no corpus real), os casos de crase facultativa (possessivo feminino, nome próprio feminino) e outras fusões com "a" (aquele/aquela/a qual/as quais).',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
