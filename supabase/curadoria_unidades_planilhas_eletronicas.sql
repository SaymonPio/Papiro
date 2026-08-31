-- Curadoria das unidades pedagogicas de Planilhas eletrônicas
-- (curso_conteudos.id = 37), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/planilhas_eletronicas.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 37, assunto "Planilhas eletrônicas")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Planilhas eletrônicas
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_planilhas_eletronicas*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 37;
  v_unidade_1_id constant uuid := 'd7635b99-48c1-4599-a014-68e8eb9ca3c2';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Planilhas eletrônicas",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Planilhas eletrônicas'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Planilhas eletrônicas nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 37 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 37 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Planilhas eletrônicas',
    escopo = 'Fundamentos e uso de planilhas eletrônicas, com prática atualmente concentrada em Microsoft Excel (versões 2013, 2016, 2019 e Microsoft 365) e orientada pelos fenômenos efetivamente observados em provas reais da Fundatec (2022-2026). Organizado em quatro eixos internos, sem fragmentação em unidades separadas (massa de 13 questões vinculáveis compatível com um único bloco coerente): EIXO 1 — CONCEITOS FUNDAMENTAIS: hierarquia Pasta de Trabalho (o arquivo, ex. .xlsx) → Planilha (cada aba/guia dentro da pasta) → Célula (interseção de coluna e linha) — não inverter a relação (uma planilha NÃO é um conjunto de pastas de trabalho; é o contrário); colunas identificadas por letras, linhas por números; toda fórmula inicia obrigatoriamente com o sinal de igual (=); Minigráfico (Sparkline) é um pequeno gráfico posicionado em uma única célula, distinto de Gráfico Dinâmico, SmartArt, Mapa 3D e Símbolo; guia INSERIR concentra Tabelas, Tabela Dinâmica, Ilustrações (Imagens, Formas, Ícones), Gráficos e Minigráficos — mencionar esses nomes de grupo não exige reconhecimento visual de nenhum ícone específico, apenas localização conceitual do recurso na guia correta. RECORRÊNCIA: a distinção Pasta de Trabalho×Planilha é fenômeno RECORRENTE NESTE CORPUS, observado em 2 provas/cadernos independentes; recursos gráficos e da guia Inserir foram OBSERVADOS EM MAIS DE UMA PROVA INDEPENDENTE deste corpus (Minigráfico e guia Inserir) — a recorrência é do eixo conceitual, não do mesmo comando individual (não escrever que "minigráficos caíram duas vezes"). EIXO 2 — REFERÊNCIAS E INTERVALOS DE CÉLULAS: o operador dois-pontos (:) representa um intervalo contínuo de células (ex.: A1:G5 engloba todas as células entre as colunas A e G, linhas 1 a 5); o ponto e vírgula (;), na sintaxe localizada em português do Excel/Calc, pode funcionar como separador de argumentos de função ou como união de referências isoladas, dependendo da expressão/função em que aparece — evitar ensinar "; = união" como regra universal isolada de contexto; navegação por teclado: a tecla Tab move o cursor para a célula à direita, Enter move para a célula abaixo, Insert não move a seleção (apenas alterna modo de inserção/sobrescrita de texto). EIXO 3 — FÓRMULAS E FUNÇÕES: sintaxe de =SOMA(intervalo) para somar um intervalo contínuo (a função aceita tanto referências de intervalo quanto constantes, como em =SOMA(A1:B5;10)); sintaxe de =MÉDIA(intervalo) para calcular a média aritmética (distinta de =MED, que calcula a mediana); sintaxe de =SE(teste_lógico;valor_se_verdadeiro;valor_se_falso) para retornar um valor condicionalmente (ex.: =SE(A2>B2;A2;B2) retorna o maior valor entre A2 e B2); PROCV pertence à categoria de funções de Pesquisa e Referência do Excel, e NÃO à categoria de Funções Lógicas (que inclui SE, E, OU, NÃO) — o contraste com E/OU/SE/NÃO deve ser explicado quando necessário ao distrator, sem expandir automaticamente para um curso completo sobre PROCV, já que o corpus não exige esse aprofundamento. RECORRÊNCIA: a notação de intervalo (:) associada à função SOMA é fenômeno RECORRENTE NESTE CORPUS, observado em 3 provas/cadernos independentes, sem afirmar que exatamente a mesma fórmula caiu três vezes (são contextos/funções relacionados pelo mesmo operador de intervalo, não a mesma questão repetida). EIXO 4 — PREENCHIMENTO E REFERÊNCIAS RELATIVAS: ao selecionar uma célula com fórmula e arrastar a alça de preenchimento, as referências relativas (sem o cifrão $) se ajustam proporcionalmente linha a linha (ou coluna a coluna) — ensinar por meio da demonstração explícita dessa transformação (ex.: célula original com =SOMA(B4:D4), ao arrastar para a linha seguinte a fórmula se torna =SOMA(B5:D5), e assim sucessivamente), nunca apenas por macete sem demonstração; o corpus não possui prática específica de referência absoluta ($A$1) ou mista (A$1, $A1) — não afirmar que esse contraste é praticado neste corpus além do necessário para situar o conceito de referência relativa. PRODUTO: a prática vinculada atualmente está concentrada em Microsoft Excel — isso NÃO deve ser apresentado como definição conceitual ("Planilhas eletrônicas = Excel"), mas apenas como reflexo de que o banco utilizável desta unidade hoje está concentrado nesse produto; o corpus registra também incidência histórica real do LibreOffice Calc (Q495), mas a questão disponível está bloqueada para prática devido à perda de fidelidade dos ícones gráficos do original. CAUTELA DE PRODUTO/VERSÃO: há evidência de Excel 2013, 2016, 2019 e Excel para Microsoft 365 no corpus — sempre distinguir o FATO EFETIVAMENTE COBRADO NA VERSÃO/ÉPOCA DA PROVA do COMPORTAMENTO ATUAL DO PRODUTO; as fórmulas centrais desta unidade (SOMA, MÉDIA, SE, notação de intervalo) são estáveis entre as versões auditadas, sem contradição a registrar. FONTES: para Microsoft Excel, priorizar a documentação oficial da Microsoft; para LibreOffice Calc (quando a fidelidade permitir uso futuro), a documentação oficial do LibreOffice; para os fatos históricos em si, priorizar a prova/caderno/gabarito da banca — já usado nesta curadoria para confirmar via fonte primária tanto a limitação de Q495 quanto a origem comum de Q105/Q499. LIMITAÇÕES REGISTRADAS: (1) Q33 é AUTORAL (banca="Papiro - estilo Fundatec", ano=NULL) — PROBLEMA_DE_QUALIDADE_METADADOS_Q33 registrado, sinalizado mas não corrigido nesta curadoria; serve como cobertura suplementar de prática sobre SOMA, sem contar para incidência histórica, recorrência, frequência Fundatec ou recência; (2) Q495 é REAL (Fundatec, Guarda Municipal de Imbé/RS, 2023) mas está com PROBLEMA_DE_FIDELIDADE_IMAGEM_Q495 CONFIRMADO POR FONTE PRIMÁRIA (Questão 17 do caderno de Informática) — as assertivas II e III dependiam de ícones gráficos sem rótulo que o Papiro substituiu por descrições textuais, alterando a habilidade nuclear de reconhecimento visual para associação de função a ícone já descrito; Q495 permanece ATIVA, INTACTA e SEM vínculo, não reconstruída, servindo como evidência de INCIDÊNCIA REAL histórica (LibreOffice Calc), mas não como prática vinculada; (3) Q499 é duplicata de fonte reformulada de Q105 — a fonte primária (Fundatec, SUSEPE/Polícia Penal RS 01/2022, Questão 26) confirmou que ambas derivam da MESMA questão-fonte (mesmas 5 alternativas idênticas, mesmo gabarito D, mesma tarefa cognitiva de retornar o maior valor entre A2 e B2 via =SE), com Q499 preservando literalmente a moldura original ("A Figura 1 abaixo apresenta uma planilha...", com a figura efetivamente ausente no Papiro) e Q105 sendo uma reformulação autossuficiente que removeu essa referência pendente — Q105 é a questão canônica vinculada; Q499 permanece ATIVA, INTACTA e SEM vínculo, excluída como DUPLICATA_DE_FONTE_REFORMULADA (canônica Q105), não editada nem transformada em nova questão nesta operação. A exclusão de Q499 tem como razão principal a duplicata; a pendência de fidelidade da Figura 1 ausente é uma observação adicional, não uma segunda razão de exclusão somada à primeira. (4) Q498 possui PENDENCIA_DE_FIDELIDADE_VISUAL_Q498 (não bloqueante): o enunciado menciona "Figura 2 abaixo apresenta uma planilha" sem que nenhuma figura esteja presente no Papiro, mas a fórmula correta (=MÉDIA(B2:B6)) depende apenas da referência de intervalo fornecida textualmente, não dos valores visuais das células — Q498 permanece vinculada, com o registro desta pendência preservado para eventual recuperação futura da prova/figura original, sem afirmar que a fidelidade visual foi confirmada.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
