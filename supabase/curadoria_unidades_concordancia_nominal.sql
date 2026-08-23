-- Curadoria das unidades pedagogicas de Concordância nominal
-- (curso_conteudos.id = 19), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/concordancia_nominal.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 19, assunto "Concordância nominal")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Concordância nominal
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_concordancia_nominal*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 19;
  v_unidade_1_id constant uuid := '9a4936e1-a9a6-452c-9385-d5a5899ae5c5';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Concordância nominal",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Concordância nominal'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Concordância nominal nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 19 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 19 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Concordância nominal',
    escopo = 'Concordância nominal da Língua Portuguesa. EVIDÊNCIA REAL HISTÓRICA (sem vínculo nesta unidade): nas duas questões reais do corpus (Q116 e Q318, já classificadas em Concordância verbal), a concordância nominal apareceu integrada a transformações de número, exigindo ajuste de determinantes — artigo ("os"→"o") e demonstrativo ("esse"→"esses") — ao substantivo; essas duas ocorrências não sustentam afirmação de recorrência ou padrão predominante da banca. PRÁTICA ESPECÍFICA DISPONÍVEL (única questão vinculada, autoral): concordância do predicativo em estruturas com verbo de ligação e sujeito determinado ou não por artigo/pronome — com determinante, o predicativo concorda obrigatoriamente em gênero e número ("É necessária a cautela"); sem determinante, a construção é tradicionalmente apresentada no masculino singular invariável ("É necessário cautela") — regra tradicional de concurso, não algoritmo universal cego, a ser analisada sempre pela estrutura concreta da frase. COBERTURA INTEGRADA AUTORAL (fenômenos nominais presentes em questões que dependem também de concordância verbal independente, por isso sem vínculo e sem contagem como prática específica): a variação do adjetivo "anexo" (concordando em gênero e número com o substantivo referido, como em "seguem anexas as certidões"), em contraste com a locução adverbial invariável "em anexo"; e a invariabilidade do advérbio de intensidade "meio" (equivalente a "um pouco", como em "meio cansadas"), em contraste com a variabilidade de "meia" como numeral fracionário ou substantivo.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
