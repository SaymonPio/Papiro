-- Curadoria das unidades pedagogicas de Editor de textos
-- (curso_conteudos.id = 36), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/editor_de_textos.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 36, assunto "Editor de textos")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Editor de textos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_editor_de_textos*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 36;
  v_unidade_1_id constant uuid := '71df17f6-18a9-49c8-a8da-025329e43bc7';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Editor de textos",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Editor de textos'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Editor de textos nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 36 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 36 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Editor de textos',
    escopo = 'Uso de editores de texto, com prática atualmente concentrada em Microsoft Word (versões 2013, 2016 e Microsoft 365) e orientada pelos fenômenos efetivamente observados em provas reais da Fundatec (2022-2026). Organizado em quatro eixos internos, sem fragmentação em unidades separadas (massa de 13 questões vinculáveis compatível com um único bloco coerente de "edição e formatação de documentos de texto"): EIXO 1 — FORMATAÇÃO DE CARACTERE/FONTE: Negrito (aumenta a espessura das letras, Ctrl+N), Tachado (linha horizontal no meio das letras, distinta do Sublinhado, que traça a linha abaixo do texto) e demais efeitos disponíveis na caixa de diálogo "Fonte" (Tachado, Tachado duplo, Sobrescrito, Subscrito, Versalete/Pequenas maiúsculas, Todas em maiúsculas, Oculto — "Tracejado" NÃO é um desses efeitos, sendo estilo de linha aplicável a sublinhados/bordas). RECORRÊNCIA: formatação de fonte/caractere é fenômeno RECORRENTE NESTE CORPUS, observado em 3 provas/cadernos independentes, sem elevar essa constatação a "um dos assuntos mais cobrados pela Fundatec" sem uma análise comparativa global entre todos os conteúdos. EIXO 2 — PARÁGRAFO E PÁGINA: caixa de diálogo "Parágrafo" (alinhamento, recuos, espaçamento entrelinhas, quebras de linha/página — Bordas e Sombreamento é configurado em caixa própria, distinta e NÃO disponível dentro da caixa Parágrafo); guia LAYOUT da Faixa de Opções, grupo "Configurar Página" (Margens, Orientação, Tamanho, Colunas, Quebras, Hifenização) — Colunas divide o texto em duas ou mais colunas verticais; Quebras de seção incluem ao menos Próxima Página, Contínuo e Página Par (demais tipos, como Página Ímpar, tratados apenas como mapa conceitual quando pedagogicamente necessário, sem inflar cobertura só porque existem no produto). RECORRÊNCIA: recursos da guia Layout foram OBSERVADOS EM MAIS DE UMA PROVA INDEPENDENTE deste corpus (Colunas e Quebras) — a recorrência é do EIXO/GUIA da interface, não de um único comando individual; não escrever que "o mesmo recurso caiu duas vezes", já que Colunas e Quebras são recursos funcionalmente diferentes dentro da mesma guia. EIXO 3 — EDIÇÃO E ÁREA DE TRANSFERÊNCIA: atalhos de teclado do Word — Ctrl+X (recortar) e Ctrl+Z (desfazer) — RECORRÊNCIA: atalhos de teclado do Word são RECORRENTES NESTE CORPUS, observados em 2 provas/cadernos independentes; CAUTELA: validar sempre o atalho na versão/localização correta do Word, sem misturar atalhos de Windows, navegador, Word e LibreOffice entre si; Pincel de Formatação (grupo Área de Transferência da guia Página Inicial, Word 2013) — copia toda a formatação visual de um objeto de origem e aplica a um objeto de destino, sem copiar o conteúdo — distinto de Colar, Colar Especial e Estilos. EIXO 4 — REVISÃO, REFERÊNCIAS E STATUS DO DOCUMENTO: Barra de Status (extremidade inferior da janela, exibe número de página atual/total e contagem de palavras, entre outras informações); Controle de Alterações (guia Revisão, atalho Ctrl+Shift+E) — registra edições, exclusões e inclusões para posterior revisão, aceitação ou rejeição por outro usuário, distinto de Comentários (apenas notas explicativas nas margens, sem registrar alterações ativas no corpo do texto); Nota de Rodapé (guia Referências, atalho Alt+Ctrl+F) — recurso de referência/citação numerada no rodapé da página da citação específica, distinto do Rodapé de página (guia Inserir), que é a área estrutural repetida no fim de todas as páginas da seção — não deixar o aluno confundir os dois apenas pela palavra "rodapé"; botão Mostrar/Ocultar (símbolo ¶/pilcrow, atalho Ctrl+*) — alterna a visibilidade de caracteres de formatação não imprimíveis (marcas de parágrafo, espaços, marcas de tabulação); o símbolo ¶ é reproduzido textualmente no próprio enunciado da questão que testa este fenômeno, não dependendo de imagem/screenshot externo. INCIDÊNCIA PONTUAL (observada em apenas 1 prova independente cada, não chamar recorrente): caixa de diálogo Parágrafo, Pincel de Formatação, Barra de Status, Controle de Alterações, Nota de Rodapé, Mostrar/Ocultar. PRODUTO: o corpus histórico contém 14 rows sobre Microsoft Word e 1 sobre LibreOffice Writer (Q791, ver limitação abaixo); a prática vinculada atualmente está concentrada exclusivamente em Microsoft Word — isso NÃO deve ser apresentado como definição conceitual ("Editor de textos = apenas Word"), mas apenas como reflexo de que o banco utilizável desta unidade hoje está concentrado nesse produto; o corpus contém também evidência histórica real de cobrança do LibreOffice Writer pela Fundatec, ainda que a questão disponível esteja bloqueada para prática. CAUTELA DE PRODUTO/VERSÃO: as questões abrangem majoritariamente Word 2016, além de Word 2013 (Q110) e Word para Microsoft 365 (Q627, mesma interface do 2016 para os recursos testados) — sempre distinguir o FATO EFETIVAMENTE COBRADO NA VERSÃO/ÉPOCA DA PROVA do COMPORTAMENTO ATUAL DO PRODUTO, sem converter a localização histórica de um botão, guia ou comando em regra eterna válida para qualquer versão futura. FONTES: para Microsoft Word, priorizar a documentação oficial da Microsoft; para LibreOffice, a documentação oficial do LibreOffice (quando a fidelidade permitir uso futuro); para os fatos históricos em si, priorizar a prova/caderno/gabarito da banca — já usado nesta curadoria para confirmar via fonte primária a limitação de Q791. MAPA × PRÁTICA: a futura aula pode explicar recursos necessários para contextualizar o Word, mas não deve confundir "recurso existente no Word" (mapa conceitual, incluindo distratores) com "recurso coberto por questão" (prática efetivamente vinculada) — um distrator mencionado numa explicação não vira automaticamente subassunto praticado. LIMITAÇÕES REGISTRADAS: (1) Q791 é REAL (Fundatec, Guarda Municipal de Imbé/RS, 2023) mas está com PROBLEMA_DE_FIDELIDADE_IMAGEM_Q791 CONFIRMADO POR FONTE PRIMÁRIA — a prova original (Questão 16 do caderno de Informática, PDF oficial) apresentava, em cada alternativa, um ícone gráfico real do LibreOffice Writer seguido do nome da função, com o comando dizendo "o botão apresentado"; o Papiro substituiu cada ícone por descrição textual (ex.: "Ícone do Pincel de Pintura"), alterando a habilidade nuclear de reconhecimento visual do ícone para associação de função a um ícone já nomeado — Q791 permanece ATIVA, INTACTA e SEM vínculo, não reconstruída nesta operação; serve como evidência de INCIDÊNCIA REAL histórica (LibreOffice Writer e reconhecimento de ícones foram cobrados pela Fundatec), mas não como prática vinculada; (2) Q832 é duplicata textual de Q91 (mesmo enunciado, mesmas 5 alternativas, mesmo gabarito, mesmo evento SUSEPE/Polícia Penal RS 01/2022, com glitch "área detransferência" sem espaço) — Q91 é a questão canônica vinculada; Q832 permanece ATIVA, INTACTA e SEM vínculo, excluída como DUPLICATA_Q832, sem correção do glitch textual nesta operação e sem ser contabilizada como uma segunda incidência independente do fenômeno de atalhos de recortar.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
