-- Curadoria das unidades pedagogicas de Implícitos e subentendidos
-- (curso_conteudos.id = 25), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/implicitos_e_subentendidos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 25, assunto "Implícitos e subentendidos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Implícitos e subentendidos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_implicitos_e_subentendidos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 25;
  v_unidade_1_id constant uuid := '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Implícitos e subentendidos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Implícitos e subentendidos'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Implícitos e subentendidos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 25 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 25 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Implícitos e subentendidos',
    escopo = 'Reconhecimento de conteúdo implícito em enunciados, organizado em quatro eixos conforme o tipo de gatilho linguístico envolvido. EIXO 1 — Efeito/leitura escalar: operadores de escala ("até", "inclusive", "mesmo") introduzem uma escala contextual e sinalizam que o elemento destacado ocupa uma posição de menor expectativa (ex.: "Até João acertou a questão" → o acerto de João era pouco esperado); considerar também, quando pertinente à questão, a dimensão inclusiva do operador (indica que outros também satisfazem o predicado, não exclusividade). Tratar esse efeito preferencialmente como CONTEÚDO IMPLÍCITO ESCALAR/IMPLICATURA, não rotular de modo simplista e uniforme como "pressuposição" — a cautela é terminológica, não deve virar aula acadêmica de pragmática: o objetivo é ensinar o efeito necessário para resolver a questão. EIXO 2 — Pressuposto por mudança de estado: verbos como "parar de", "deixar de", "cessar", "começar a" ativam pressuposto sobre a situação imediatamente anterior (ex.: "Pedro parou de fumar" pressupõe que Pedro fumava antes); regra de bolso "PARAR DE X pressupõe, na construção concreta, que X ocorria antes", sem extrapolar frequência, motivo, duração ou resultado posterior não informados. EIXO 3 — Pressuposto de retomada: locuções aspectuais como "voltar a" ativam pressuposto de descontinuidade e retomada (ex.: "Maria voltou a estudar" pressupõe que ela estudava antes, interrompeu, e retomou), sem extrapolar aprovação, motivo da interrupção, frequência ou duração. EIXO 4 — Pressuposto/gatilho lexical seriado (REAL, Fundatec): adjetivos que indicam renovação ou continuidade de uma série (ex.: "novos" aplicado a "recordes") ativam, no contexto concreto, a leitura de que já havia item(ns) anterior(es) da mesma série; formulação segura: "o emprego de ''novos'' aplicado a um substantivo que designa itens de uma série (recordes) autoriza a leitura de que já havia outro ou outros anteriormente" — NÃO ensinar como regra universal ("''novo'' sempre pressupõe algo anterior"); a interpretação depende sempre da construção concreta (contraste: "carro novo" tipicamente indica apenas "não usado", sem pressupor série). DISTINÇÃO PRESSUPOSTO × SUBENTENDIDO: pressuposto é conteúdo implícito associado de maneira relativamente estável a elementos ou estruturas linguísticas explícitas (sobrevive à negação da frase); subentendido é conteúdo inferido pragmaticamente a partir da situação/contexto, sem o mesmo tipo de gatilho lexical ou estrutural dedicado — mas isso não torna o subentendido "opinião subjetiva": a inferência pragmática continua limitada pelo contexto e pelas condições comunicativas partilhadas pelos falantes. GAP identificado: nenhuma questão do corpus atual testa especificamente subentendido pragmático puro (todas as 4 disponíveis dependem de marca linguística explícita) — registrado como lacuna de subassunto, sem criar unidade separada nem gerar questão agora. Método de resolução: (1) localizar a palavra/estrutura que produz conteúdo implícito; (2) separar o que está explicitamente afirmado; (3) perguntar o que precisa ser assumido/inferido para a construção fazer sentido; (4) verificar se essa informação vem de gatilho lexical/gramatical, escala, mudança de estado, retomada ou contexto pragmático; (5) rejeitar extrapolações não sustentadas pelo texto. Regra de bolso geral: "Pergunte: o texto disse isso diretamente, ou a própria construção me obriga/sugere a recuperar essa informação?". Núcleo real observado (amostra de 1 questão real, Fundatec): conteúdo implícito extraído de marca lexical seriada ("novos recordes" → existência de recorde(s) anterior(es)) — não generalizar para "a Fundatec prioriza adjetivos como gatilho".',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
