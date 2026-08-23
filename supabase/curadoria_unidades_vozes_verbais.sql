-- Curadoria das unidades pedagogicas de Vozes verbais
-- (curso_conteudos.id = 32), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/vozes_verbais.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 32, assunto "Vozes verbais")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Vozes verbais
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_vozes_verbais*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 32;
  v_unidade_1_id constant uuid := '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Vozes verbais",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Vozes verbais'
      and cm.materia_id = 6
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Vozes verbais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 32 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 32 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Vozes verbais',
    escopo = 'Vozes verbais na análise normativa tradicional, com foco na relação entre a estrutura ativa e as construções passivas, na identificação da voz em contexto e na transposição ativa→passiva analítica. ORGANIZAÇÃO CONCEITUAL: não tratar como cinco categorias do mesmo nível ("as cinco vozes: ativa, passiva analítica, passiva sintética, reflexiva, recíproca") — a organização correta é VOZ ATIVA, VOZ PASSIVA (com duas formas: analítica e sintética/pronominal) e VOZ REFLEXIVA, com a reciprocidade tratada como valor/construção dentro da reflexiva (conforme a tradição gramatical adotada pela banca/material: "Os amigos se abraçaram" expressa ação mútua), não como uma quinta voz independente. VOZ ATIVA: evitar a definição absoluta "sujeito = agente" — na construção ativa o sujeito gramatical ocupa a posição característica da estrutura ativa em relação ao processo verbal, em oposição à organização passiva; em exemplos prototípicos de ação o sujeito costuma corresponder ao agente, mas isso não é universal (limite: "João sofreu muito" é construção ativa, mas "João" não é agente de uma ação voluntária). PASSIVA ANALÍTICA: estrutura canônica SER + particípio ("As questões foram resolvidas") — usar SER como estrutura canônica da transposição trabalhada nesta unidade; não generalizar "SER ou ESTAR + particípio" como fórmula automática, pois construções com ESTAR + particípio ("A porta está fechada") podem expressar estado/resultado/valor adjetival, sem necessariamente constituir uma passiva dinâmica equivalente. TRANSFORMAÇÃO ATIVA→PASSIVA ANALÍTICA (núcleo de Q244): (1) identificar o verbo transitivo passivizável; (2) identificar o objeto direto; (3) promover o objeto direto a sujeito paciente; (4) flexionar SER preservando adequadamente as categorias verbais relevantes da forma original (tempo e modo, não apenas "mesmo tempo" mecanicamente); (5) usar o particípio do verbo principal; (6) fazer a concordância pertinente do particípio; (7) transformar o sujeito agente da ativa em agente da passiva, quando expresso. LIMITE: não ensinar que qualquer oração ativa pode ser transformada mecanicamente em passiva — a transposição pressupõe uma estrutura que admita passivização; o modelo objeto direto→sujeito paciente é apropriado às construções passivizáveis trabalhadas aqui, não deve ser universalizado para qualquer verbo/estrutura. PASSIVA SINTÉTICA/PRONOMINAL (núcleo de Q245): estrutura prototípica verbo transitivo compatível + SE apassivador + sujeito paciente ("Vendem-se casas", "casas" é sujeito paciente e o verbo concorda com ele). CUIDADO CONTRA ALGORITMO MECÂNICO: não ensinar como fórmula absoluta "VTD+SE+substantivo = sempre partícula apassivadora" e "VTI/VI/VL+SE = sempre índice de indeterminação do sujeito" — são pistas iniciais úteis, não regras infalíveis; a análise deve considerar transitividade no uso concreto, estrutura sintática, existência de sujeito paciente, concordância, possibilidade de paráfrase passiva analítica equivalente, e eventual valor reflexivo/recíproco possível. Estratégia pedagógica (não algoritmo isolado): testar a reconstrução de uma passiva analítica semanticamente equivalente ("Vendem-se casas" → "Casas são vendidas" sustenta a leitura de SE apassivador). Índice de indeterminação do sujeito: contrastar com "Precisa-se de funcionários" (não "Funcionários são precisados") — "de funcionários" não funciona como sujeito paciente, o SE é índice de indeterminação, verbo na 3ª pessoa do singular. NORMA DE CONCURSO × USO REAL: esta análise (sobretudo a distinção apassivador × índice de indeterminação, com concordância associada) reflete a norma-padrão tradicional cobrada em concursos; no português brasileiro real há variação de uso e de concordância em construções com SE — não é necessário aprofundar em linguística variacionista, mas também não se deve afirmar que todo falante necessariamente segue essa concordância. VOZ REFLEXIVA: o participante representado pelo sujeito também é afetado pelo processo ("João se cortou") — mas a presença isolada de "se" não prova reflexividade por si só; a classificação exige analisar o contexto (o mesmo "se" pode ser apassivador, reflexivo, recíproco ou índice de indeterminação, conforme a estrutura). COBERTURA EFETIVA DO BANCO (não inflar a partir dos distratores): os núcleos efetivamente praticados hoje são apenas reconhecimento de voz ativa, transformação ativa→passiva analítica, e reconhecimento de passiva sintética com distinção de análises concorrentes. Não há questão própria cujo núcleo seja voz reflexiva, reciprocidade, classificação isolada de passiva analítica, transformação passiva→ativa, ou transformação para passiva sintética — essas permanecem como lacunas de banco (gaps de subassunto), sem criar unidade separada nem gerar questão nova agora. Fronteira com Reescrita de frases e textos (já concluído): decidida pela habilidade nuclear, não por palavras do comando — comando que determina explicitamente a transformação de voz exigida pertence aqui; comando aberto que exige descobrir/avaliar a estratégia de reescrita pertence a Reescrita. Fronteira com Transitividade Verbal e Termos Integrantes (já concluído): questões sobre a função sintática de um termo específico (agente da passiva, objeto direto/indireto) pertencem lá; questões sobre a classificação da voz da oração como um todo pertencem aqui. Toda a prática disponível nesta unidade é AUTORAL_PAPIRO, sem evidência real de incidência histórica no corpus atual.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
