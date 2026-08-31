-- Curadoria das unidades pedagogicas de Correio eletrônico
-- (curso_conteudos.id = 39), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/correio_eletronico.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 39, assunto "Correio eletrônico")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Correio eletrônico
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_correio_eletronico*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 39;
  v_unidade_1_id constant uuid := '1c682e95-da6f-43a2-8b53-6669b41a376b';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Correio eletrônico",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Correio eletrônico'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Correio eletrônico nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 39 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 39 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Correio eletrônico',
    escopo = 'Fundamentos e uso de correio eletrônico, com base nos fenômenos efetivamente observados em provas reais da Fundatec (2022-2026). Organizado em quatro eixos internos, sem fragmentação em unidades separadas (massa de 10 questões vinculáveis compatível com um único bloco coerente): EIXO 1 — PROTOCOLOS E ENDEREÇAMENTO: o protocolo IMAP mantém as mensagens armazenadas no servidor, voltado ao acesso e à manipulação da caixa postal (mailbox) com sincronização de estado entre múltiplos dispositivos (celular, tablet, notebook) — não reduzir a "IMAP simplesmente deixa tudo na internet"; o protocolo SMTP é usado para a submissão/transferência de mensagens de e-mail entre clientes e servidores (envio), NÃO sendo um protocolo de recuperação/download de mensagens da caixa postal — o recebimento é responsabilidade de POP3 ou IMAP, cada um com seu próprio modelo; POP3 não possui questão nuclear dedicada neste corpus, entrando apenas como contraste necessário para compreender IMAP: modelo tradicionalmente associado à recuperação/download de mensagens para o cliente local, sem afirmar de forma absoluta que "POP3 sempre apaga as mensagens do servidor" (isso pode depender de configuração/operação) — POP3 não deve ser registrado como prática específica vinculada, apenas como conceito de apoio comparativo; na estrutura padrão de um endereço eletrônico (parte-local@domínio), o caractere @ separa a parte local (identificador da conta) do domínio onde a conta está hospedada — usar "usuário" apenas como exemplo pedagógico da parte local, sem defini-la tecnicamente como "usuário" em qualquer contexto. EIXO 2 — CAMPOS E COMPOSIÇÃO DE MENSAGENS: ao compor uma mensagem no Gmail, o campo de destinatário é o elemento necessário para que o envio seja possível, enquanto assunto, corpo e anexo podem ser deixados vazios — este é um comportamento específico da INTERFACE do Gmail, e deve ser apresentado como tal (documentação oficial Google), e não atribuído diretamente à RFC 5322, que é fonte pertinente para a estrutura geral de mensagens/endereços eletrônicos, mas não fundamenta isoladamente essa exigência específica de UI; Cc (Cópia) envia cópia com endereço visível a todos os destinatários, enquanto Cco/BCC (Cópia Oculta) mantém o endereço do destinatário oculto dos demais — distinção a manter no nível necessário, sem complicar além disso; um rascunho é uma mensagem salva sem ter sido enviada, distinta de uma mensagem já enviada (que fica na pasta "Enviados", não em uma "caixa principal"); a mera menção às palavras "anexo"/"anexa" no corpo da mensagem não bloqueia o envio em clientes modernos como o Gmail — no máximo gera um aviso/lembrete, sem impedir a confirmação do envio pelo usuário. EIXO 3 — RECURSOS DO GMAIL: Desfazer Envio permite cancelar a transmissão de uma mensagem dentro de um período configurável (documentado no corpus como 5, 10, 20 ou 30 segundos); o Modo Confidencial permite definir data de expiração e restringir ações como encaminhar, copiar, imprimir ou baixar a mensagem/anexos — ensinar apenas as capacidades efetivamente sustentadas pelas provas/documentação (expiração, restrição de encaminhamento/cópia/impressão/download), sem apresentar isso como proteção absoluta contra captura ou reprodução da informação por outros meios (ex.: uma captura de tela) — RECORRÊNCIA: o Modo Confidencial do Gmail é o ÚNICO fenômeno deste corpus com recorrência genuína, confirmado em 2 provas de concursos efetivamente independentes; os Marcadores (Labels) do Gmail são uma ferramenta de organização de uso estritamente pessoal e local do usuário, que NÃO afeta a caixa de entrada dos destinatários das mensagens; a barra da janela "Nova Mensagem" do Gmail reúne opções como formatação de texto, anexar arquivo, inserir link, emoji, arquivo do Google Drive, foto, Modo Confidencial e assinatura — a funcionalidade "Adicionar tarefa" (Google Tasks) fica no painel lateral da tela principal, não nessa barra de composição. EIXO 4 — RECURSOS DO OUTLOOK (CLIENTE INTEGRADO): o Outlook 2016 permite nativamente, além de enviar/receber e-mail, agendar reunião, criar compromisso de calendário e definir lembrete — funcionalidades de um cliente de e-mail com PIM (gerenciador de informações pessoais) integrado, tratadas aqui como parte do escopo de "correio eletrônico" porque não há conteúdo específico de "Agenda/Outlook geral" nesta fila; o Outlook também permite recuperar mensagens excluídas da Caixa de Entrada (via pasta "Itens Excluídos"), compartilhar arquivos em nuvem (ex.: links do OneDrive) e importar contatos do Gmail via assistente de importação/exportação. OBSERVAÇÃO HISTÓRICA SOBRE O OUTLOOK (não é recorrência independente): os recursos do Outlook foram observados em dois cadernos/cargos do MESMO concurso (SUSEPE/Polícia Penal RS 01/2022) — evidência histórica relevante, mas que não deve receber o mesmo peso de um fenômeno confirmado em concursos/provas efetivamente independentes; os fatos específicos testados em cada caderno também são diferentes entre si (calendário/compromissos/lembretes em um; recuperação de itens/nuvem/contatos em outro). CAUTELA DE PRODUTO/VERSÃO: Gmail e Outlook são produtos evolutivos — sempre distinguir o FATO EFETIVAMENTE COBRADO NA ÉPOCA/VERSÃO DA PROVA do COMPORTAMENTO ATUAL DO PRODUTO, com atenção especial a tempo de desfazer envio, capacidades do Modo Confidencial, organização da interface, barra de composição, recuperação de itens e integrações de nuvem, que podem mudar com atualizações. FONTES: para os protocolos, priorizar RFC 5321 (SMTP), RFC 1939 (POP3) e a documentação técnica vigente do IMAP quando pertinente; para a estrutura geral de mensagens/endereços, RFC 5322; para o comportamento específico da interface do Gmail, documentação oficial Google (nunca atribuído à RFC 5322); para o Outlook, documentação oficial Microsoft; para os fatos históricos em si, priorizar a prova/caderno/gabarito da banca.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
