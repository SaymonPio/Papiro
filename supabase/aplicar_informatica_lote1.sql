-- ============================================================================
-- AUDITORIA GLOBAL -- INFORMÁTICA -- LOTE 1 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 9)
-- IDs: 11,15,31,32,33,60,61,62,63,64,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,294,338,339,340,341,492,493,494,495,496,497,498,499,626,627,628,629,630,631,632
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-informatica-lote1-harness.mjs a partir de
-- scripts/informatica-lote1-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/informatica-lote1-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _inf1_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _inf1_novas_explicacoes (id, explicacao) values
(11, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O backup (cópia de segurança) consiste em duplicar dados e arquivos importantes em um suporte ou meio de armazenamento secundário (como HD externo, nuvem ou fita), com a finalidade precípua de permitir a recuperação das informações em caso de incidentes, corrupção, ataques cibernéticos ou exclusão acidental.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Otimizar o clock ou a velocidade da memória RAM é função de ajustes de hardware e do sistema operacional, não do backup.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Aumentar a resolução física do monitor é ajuste de exibição de vídeo, sem relação com cópias de dados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Excluir automaticamente arquivos duplicados do sistema não é a definição de backup (esta é uma função de utilitários de limpeza de disco).

BIZU DE PROVA:
Regra de Ouro 3-2-1 do Backup:
- 3 cópias dos dados;
- 2 tipos de mídias diferentes (ex.: local e nuvem);
- 1 cópia fora da empresa/local (off-site).'),
(15, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O uso de senhas fortes, longas e complexas (combinando letras maiúsculas, minúsculas, números e caracteres especiais) associado à troca periódica é uma das principais recomendações de segurança da informação (Cartilha de Segurança do CERT.br / NIST) para mitigar ataques de força bruta e acesso não autorizado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Utilizar a mesma senha simples em todos os serviços amplia o risco em cascata: o comprometimento de um único serviço expõe todas as demais contas do usuário.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Senhas são estritamente pessoais e intransferíveis; compartilhá-las quebra os princípios de autenticidade, confidencialidade e irretratabilidade (não repúdio).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Desativar atualizações automáticas deixa o sistema vulnerável a brechas e falhas de segurança conhecidas (exploits).

BIZU DE PROVA:
Pilares da Segurança da Informação (CIDAN):
- Confidencialidade (sigilo);
- Integridade (não alteração);
- Disponibilidade (acesso quando necessário);
- Autenticidade (identidade do autor);
- Não repúdio / Irretratabilidade (impossibilidade de negar a autoria).'),
(31, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No sistema operacional Windows, ao enviar um arquivo local para a Lixeira (por meio da tecla Delete ou arrastando), ele não é imediatamente destruído. O arquivo permanece armazenado na pasta especial da Lixeira, permitindo ao usuário restaurá-lo a qualquer momento para a sua pasta ou local de origem ("Restaurar este item").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lixeira não criptografa arquivos; o BitLocker ou o EFS é que são responsáveis por criptografia no Windows.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O envio para a nuvem ocorre via OneDrive / Google Drive, não pela Lixeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Ocultar arquivos é um atributo de arquivo (propriedades -> Oculto), e não uma ação da Lixeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mover para a Lixeira afeta apenas o disco local atual, não interferindo em backups externos ou históricos de arquivos.

BIZU DE PROVA:
Atalhos de Exclusão no Windows:
- Delete: Move para a Lixeira (permite restaurar).
- Shift + Delete: Exclui PERMANENTEMENTE sem passar pela Lixeira.'),
(32, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Autenticação em Dois Fatores (2FA / MFA - Multi-Factor Authentication) exige dois métodos distintos de verificação para conceder acesso: algo que você sabe (senha/PIN) combinado com algo que você tem (código por SMS, app autenticador, token) ou algo que você é (biometria/digital).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Compactação de arquivos (ZIP/RAR) reduz o tamanho de arquivos para economizar espaço em disco.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Navegação anônima apenas impede o registro local de histórico e cookies no navegador, não adicionando fatores de autenticação a contas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Desfragmentação de disco organiza blocos de dados contíguos em discos rígidos (HDs) para melhorar o desempenho de leitura.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Limpeza do histórico apenas remove dados de navegação prévios do computador local.

BIZU DE PROVA:
Fatores de Autenticação:
1. Conhecimento: o que você sabe (senha, PIN, pergunta secreta).
2. Posse: o que você tem (celular, token, cartão inteligente).
3. Inerência: o que você é (biometria, impressão digital, reconhecimento facial).'),
(33, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Microsoft Excel e LibreOffice Calc, o operador dois-pontos (:) representa um intervalo contínuo. A fórmula =SOMA(A1:A5) soma todos os valores numéricos contidos desde a célula A1 até a célula A5 (A1 + A2 + A3 + A4 + A5).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A contagem de células vazias é realizada pela função =CONTAR.VAZIO(intervalo).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A ordenação crescente é realizada pelo recurso de Classificar e Filtrar (A-Z), não pela função SOMA.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A remoção de valores duplicados é feita pelo recurso "Remover Duplicadas" na guia Dados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O cálculo de porcentagens requer operações aritméticas com operadores percentuais (%) ou multiplicação por decimais.

BIZU DE PROVA:
Operadores de Referência em Planilhas:
- Dois-pontos (:): intervalo contínuo ("ATÉ"). Ex: A1:A5 (de A1 até A5).
- Ponto e vírgula (;): união separada ("E"). Ex: A1;A5 (apenas a célula A1 e a célula A5).'),
(60, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na Barra de Ferramentas de Acesso Rápido do Explorador de Arquivos do Windows 10 (localizada no canto superior esquerdo da janela), o botão "Voltar" (seta para a esquerda) faz parte dos botões de navegação da Barra de Endereços, e NÃO compõe as opções padrão personalizáveis da barra de acesso rápido (que contém Propriedades, Nova Pasta, Desfazer, Refazer, Excluir).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O botão "Excluir" está disponível para inclusão na barra de acesso rápido.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O botão "Desfazer" (Ctrl+Z) está presente nativamente na barra de acesso rápido.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O botão "Criar nova pasta" (Ctrl+Shift+N) está presente por padrão na barra de acesso rápido.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O botão "Refazer" (Ctrl+Y) está presente nativamente na barra de acesso rápido.

BIZU DE PROVA:
Explorador de Arquivos (Windows 10):
- Barra de Acesso Rápido: Nova Pasta, Desfazer, Refazer, Excluir, Propriedades.
- Botões de Navegação: Voltar (Alt + Seta Esquerda), Avançar (Alt + Seta Direita), Pasta Acima (Alt + Seta Cima).'),
(61, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Word 2016, a formatação NEGRITO (atalho Ctrl+N) aplica maior espessura e peso aos traços dos caracteres em relação à fonte normal/regular, servindo para destacar visualmente termos ou trechos no documento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Sublinhado (Ctrl+S) insere uma linha horizontal abaixo do texto selecionado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Sobrescrito (Ctrl+Shift++) posiciona o caractere em tamanho reduzido acima da linha de base do texto (ex.: x²).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Tachado desenha uma linha horizontal no meio das letras (ex.: texto riscado).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Itálico (Ctrl+I) inclina as letras ligeiramente para a direita.

BIZU DE PROVA:
Atalhos de Fonte no Word (Português):
- Negrito: Ctrl + N.
- Itálico: Ctrl + I.
- Sublinhado: Ctrl + S.
- Fonte: Ctrl + D (abre a caixa de diálogo de fontes).'),
(62, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Microsoft Excel 2016, ao pressionar isoladamente a tecla TAB, o cursor de seleção avança horizontalmente para a próxima célula à direita na mesma linha.
- I. (Incorreta) A tecla ENTER move o cursor verticalmente para a próxima célula ABAIXO (para baixo).
- II. (Incorreta) A tecla INSERT alterna o modo de inserção e sobrescrita de texto, não movimentando a seleção para a direita.
- III. (Correta) A tecla TAB move o foco para a célula à direita.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva II não move o cursor para a direita.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Nem a assertiva I (move para baixo) nem a II movem para a direita.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A tecla Enter move o cursor para a célula inferior (abaixo).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apenas a assertiva III está correta.

BIZU DE PROVA:
Navegação por Teclado no Excel:
- TAB: move para a DIREITA.
- SHIFT + TAB: move para a ESQUERDA.
- ENTER: move para BAIXO.
- SHIFT + ENTER: move para CIMA.'),
(63, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Por questões estritas de privacidade e segurança do usuário, em plataformas de videoconferência como o Google Meet, um moderador/anfitrião pode desativar o vídeo e o microfone de participantes, mas NUNCA pode forçar a ATIVAÇÃO da câmera de vídeo ou do microfone de terceiros de forma remota e arbitrária (o moderador pode apenas solicitar que o participante ative).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O moderador pode baixar a mão levantada de qualquer participante.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O moderador pode desativar (mutar) o microfone dos participantes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O moderador possui permissão para moderar e excluir mensagens inadequadas no chat.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O moderador pode criar enquetes e perguntas interativas para votação.

BIZU DE PROVA:
Regra de Privacidade no Google Meet / Zoom / Teams:
O anfitrião pode DESATIVAR câmera/áudio de todos, mas NUNCA pode ATIVAR unilateralmente a câmera ou microfone de um participante sem a autorização expressa deste.'),
(64, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Google Drive, o ícone de uma silhueta de pessoa acompanhada de um sinal de adição (+) representa a função "COMPARTILHAR" (Share), permitindo adicionar pessoas e grupos por e-mail, além de configurar permissões de visualizador, comentador ou editor.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Copiar link é representado pelo ícone de elos de corrente (corrente de hiperlink).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Arquivar não é uma opção padrão de botão rápido em arquivos no Google Drive.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Baixar (Download) é representado pelo ícone de uma seta apontando para baixo sobre uma linha horizontal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Fazer uma cópia está disponível no menu de contexto (botão direito / três pontos), sem o ícone da silhueta com sinal de mais.

BIZU DE PROVA:
Ícones Clássicos do Google Workspace:
- Silhueta de pessoa com sinal (+): Compartilhar.
- Elos de corrente: Copiar Link.
- Lixeira: Remover / Excluir.
- Olho: Visualização rápida / Pré-visualizar.'),
(91, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Word 2016 (versão em português), o atalho de teclado universal para RECORTAR o conteúdo selecionado (removendo-o do local de origem e enviando-o para a Área de Transferência) é CTRL+X.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Tab avança a tabulação ou move o cursor entre células de uma tabela.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ctrl+C é o atalho utilizado para COPIAR o conteúdo selecionado para a Área de Transferência.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Shift+End seleciona o texto a partir do cursor até o final da linha atual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Shift+Enter insere uma quebra de linha manual sem criar um novo parágrafo.

BIZU DE PROVA:
Trio de Área de Transferência (Word / Windows):
- Ctrl + X: Recortar (tesoura).
- Ctrl + C: Copiar.
- Ctrl + V: Colar.'),
(92, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na caixa de diálogo "Parágrafo" do Microsoft Word 2016, configuram-se alinhamento, recuos, espaçamento antes/depois, espaçamento entrelinhas e quebras de linha/página (como "manter linhas juntas"). A opção de BORDAS e sombreamento é configurada em sua própria caixa de diálogo específica ("Bordas e Sombreamento"), e não dentro da caixa Parágrafo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Alinhamento (Esquerda, Centralizado, Direita, Justificado) é ajustável na caixa Parágrafo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Espaçamento entrelinhas (Simples, 1,5 linha, Duplo, Múltiplo) é configurado na caixa Parágrafo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Recuo esquerdo e direito é configurado na guia Recuos e Espaçamento da caixa Parágrafo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Manter linhas juntas" é opção presente na guia Quebras de Linha e de Página da caixa Parágrafo.

BIZU DE PROVA:
Caixas de Diálogo no Word:
- Caixa FONTE: Fonte, Tamanho, Cor, Estilo, Efeitos (Tachado, Sobrescrito, Subscrito).
- Caixa PARÁGRAFO: Alinhamento, Nível do Tópico, Recuos, Espaçamentos, Manter com o próximo.
- Caixa BORDAS E SOMBREAMENTO: Estilo de borda, cor, largura e preenchimento.'),
(93, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Excel 2016, um MINIGRÁFICO (Sparkline) é definido oficialmente pela Microsoft como um gráfico minúsculo em segundo plano de uma única célula da planilha que fornece uma representação visual compacta e rápida de tendências em uma série de valores (podendo ser dos tipos Linha, Coluna ou Ganho/Perda).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Gráfico dinâmico é um gráfico complexo e flutuante vinculado a uma Tabela Dinâmica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
SmartArt é um elemento gráfico de diagramas visuais (como organogramas, listas e processos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Mapa 3D (Power Map) é uma ferramenta de visualização de dados geoespaciais em globo tridimensional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Símbolo insere caracteres especiais e matemáticos no texto da célula.

BIZU DE PROVA:
Minigráfico no Excel (Guia Inserir -> Grupo Minigráficos):
- Ocupa o espaço de UMA ÚNICA CÉLULA.
- Mostra tendências em miniatura (Linha, Coluna, Ganho/Perda).'),
(94, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Google Chrome, a janela de navegação anônima (aberta via Ctrl+Shift+N) é executada em uma janela totalmente isolada e separada das janelas regulares, impedindo que o histórico de navegação, cookies, dados de sites e informações inseridas em formulários sejam salvos localmente no dispositivo após o fechamento da sessão anônima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O usuário pode perfeitamente alternar entre janelas normais e anônimas abertas ao mesmo tempo (Alt+Tab).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O histórico de navegação NÃO é salvo no computador durante a sessão anônima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O download de arquivos funciona normalmente na navegação anônima (e os arquivos baixados permanecem salvos no computador).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O usuário pode adicionar sites aos favoritos normalmente durante a navegação anônima.

BIZU DE PROVA:
Navegação Anônima (Chrome):
- O que NÃO é salvo: Histórico de páginas, Cookies, Dados de formulários, Senhas digitadas.
- O que CONTINUA visível/salvo: Arquivos baixados (downloads), Novos favoritos criados, Atividade visível para provedores de internet (ISP) e administradores de rede.'),
(95, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as quatro tarefas listadas (I, II, III e IV) são funcionalidades centrais nativas do Microsoft Outlook 2016:
- I. Agendar reunião (enviando convites com solicitação de resposta aos participantes).
- II. Criar compromissos no calendário pessoal do usuário.
- III. Definir lembretes automáticos com avisos sonoros/visuais de tarefas e reuniões.
- IV. Enviar e receber mensagens de correio eletrônico (e-mail).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois as tarefas III e IV também são executadas no Outlook.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois as tarefas I e II também são executadas no Outlook.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a tarefa IV também é própria do cliente de e-mail.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a tarefa I é suportada nativamente.

BIZU DE PROVA:
Módulos Integrados do Outlook:
1. E-mail (Mensagens);
2. Calendário (Compromissos e Reuniões);
3. Pessoas / Contatos;
4. Tarefas (To-Do e Lembretes).'),
(96, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na caixa de diálogo "Fonte" do Microsoft Word 2016, os efeitos de texto disponíveis são: Tachado, Tachado duplo, Sobrescrito, Subscrito, Pequenas maiúsculas (Versalete), Todas em maiúsculas e Oculto. A opção "Tracejado" é um estilo de linha aplicável a sublinhados ou bordas, e NÃO um efeito de fonte listado no grupo de efeitos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Sobrescrito é um efeito de fonte configurável na caixa Fonte.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Subscrito é um efeito de fonte configurável na caixa Fonte.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Tachado é um efeito de fonte configurável na caixa Fonte.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Tachado duplo é um efeito de fonte configurável na caixa Fonte.

BIZU DE PROVA:
Efeitos na Caixa "Fonte" do Word:
- Tachado;
- Tachado duplo;
- Sobrescrito;
- Subscrito;
- Versalete (Pequenas maiúsculas);
- Todas em maiúsculas;
- Oculto.'),
(97, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Excel 2016, o arquivo gerado (com extensão padrão .xlsx) é denominado PASTA DE TRABALHO (Workbook). Cada pasta de trabalho é composta por uma ou mais PLANILHAS (Worksheets / planilhas de cálculo), acessíveis pelas guias de planilhas na parte inferior da tela (Plan1, Plan2, etc.).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Célula é a interseção individual entre uma linha e uma coluna.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Fórmula é uma expressão matemática de cálculo iniciada pelo sinal de igual (=).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Planilha mestra" não é a denominação técnica do arquivo de documento no Excel.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Tabela dinâmica é uma ferramenta analítica de resumo e agregação de dados.

BIZU DE PROVA:
Hierarquia Básica do Excel:
Pasta de Trabalho (o arquivo .xlsx) -> contém Planilhas (guias/abas) -> contêm Células (interseção de Colunas e Linhas).'),
(98, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No recurso local "Limpar dados de navegação" do Google Chrome (Ctrl+Shift+Del), é possível apagar dados armazenados localmente no navegador (Histórico de navegação, Histórico de download, Cookies e dados de sites, Imagens e arquivos em cache, Senhas e outros dados de login, Dados de preenchimento automático). O "Histórico de pesquisa" é gerenciado nos servidores da conta Google ("Minha Atividade" na nuvem) e não consta como um item direto limpável pela ferramenta de cache local do navegador.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Histórico de navegação é um dos itens padrão limpáveis no Chrome.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Imagens e arquivos em cache podem ser excluídos na limpeza.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Cookies e dados de sites podem ser excluídos na limpeza.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Senhas salvas podem ser excluídas na guia avançada de limpeza de dados de navegação.

BIZU DE PROVA:
Limpar Dados de Navegação no Chrome (Ctrl + Shift + Del):
- Básico: Histórico de navegação, Cookies e outros dados do site, Imagens e arquivos armazenados em cache.
- Avançado: Senhas salvas, Preenchimento automático de formulários, Configurações do site, Dados de aplicativos hospedados.'),
(99, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência correta de preenchimento é F – V – V:
1) (F) O Outlook PERMITE recuperar mensagens excluídas: mensagens apagadas da Caixa de Entrada vão para a pasta "Itens Excluídos" (e ainda podem ser recuperadas do servidor via "Recuperar Itens Excluídos").
2) (V) O Outlook permite anexar e compartilhar links de arquivos salvos em serviços de nuvem (como OneDrive).
3) (V) O Outlook oferece assistente de importação/exportação de arquivos CSV/vCard para importar contatos do Gmail.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva é falsa pois a recuperação de e-mails excluídos é permitida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A terceira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As assertivas 2 e 3 são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é falsa.

BIZU DE PROVA:
Lixeira no Outlook:
Ao excluir um e-mail com a tecla Delete, ele vai para a pasta "Itens Excluídos", de onde pode ser restaurado a qualquer momento para a Caixa de Entrada.'),
(100, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Nos padrões de correio eletrônico (RFC 5322) e no Gmail, a única informação estritamente OBRIGATÓRIA para que um e-mail possa ser transmitido é o endereço do DESTINATÁRIO (campo "Para", "Cc" ou "Cco"). É perfeitamente possível enviar mensagens sem assunto preenchido, sem texto no corpo, sem anexo e sem assinatura.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Assunto é opcional (o Gmail emite apenas um alerta de confirmação se for deixado em branco, mas permite o envio).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Corpo da mensagem pode ser enviado em branco.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Anexos são recursos complementares e totalmente opcionais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assinatura automática ou manual é facultativa.

BIZU DE PROVA:
Campos de Destinatário de E-mail:
- Para (To): destinatário principal (obrigatório pelo menos um destinatário na mensagem).
- Cc (Cópia Carbono): destinatário que recebe cópia visível a todos.
- Cco (Cópia Oculta): destinatário cujo endereço fica oculto aos demais.'),
(101, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No sistema operacional Windows 10, o caractere de ponto de interrogação (?) é um dos caracteres especiais reservados proibidos em nomes de arquivos e pastas. Portanto, o nome "praia ou serra?.pdf" é INVÁLIDO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"programa_de_informática.docx" utiliza apenas caracteres válidos (letras, underline e acento).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"#cronograma do projeto.xlsx" é um nome válido (o caractere cerquilha # e espaços são permitidos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"lista-mercado.txt" é um nome válido (hífen é permitido).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"controle(1).exe" é um nome válido (parênteses e números são permitidos).

BIZU DE PROVA:
Mnemônico dos 9 Caracteres Proibidos no Windows:
"BASA DUPLA COM INTERROGAÇÃO NO CORAÇÃO"
\ / : * ? " < > |
(Barra, Barra invertida, Dois-pontos, Asterisco, Ponto de Interrogação, Aspas duplas, Menor que, Maior que, Pipe/Barra vertical).'),
(102, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas I e III:
- Assertiva I (Correta): É perfeitamente possível fixar aplicativos favoritos na Barra de Tarefas do Windows 10 (clicando com o botão direito no ícone e selecionando "Fixar na barra de tarefas").
- Assertiva II (Incorreta): A Lixeira fica localizada por padrão na Área de Trabalho (Desktop), não havendo atalho padrão nativo para esvaziar a lixeira na barra de tarefas.
- Assertiva III (Correta): Na área de notificação da Barra de Tarefas (canto inferior direito), o relógio exibe a data e hora do sistema operacional.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II é falsa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva II está incorreta.

BIZU DE PROVA:
Componentes da Barra de Tarefas do Windows:
1. Botão Iniciar;
2. Caixa de Pesquisa / Cortana;
3. Visão de Tarefas;
4. Aplicativos Fixados e em Execução;
5. Área de Notificação (Bandeja do Sistema com Relógio, Rede, Som e Ícones Ocultos).'),
(103, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Painel de Controle clássico do Windows 10 (exibição por Categoria), a opção para desinstalar aplicativos e softwares instalados localiza-se na categoria "PROGRAMAS" (por meio do item "Desinstalar um programa" / Programas e Recursos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Sistema e Segurança" gerencia o Firewall do Windows, ferramentas administrativas, BitLocker e status de segurança.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Aparência e Personalização" gerencia temas, barra de tarefas, fontes e opções do explorador de arquivos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Contas de Usuário" gerencia credenciais, tipos de conta e senhas de login.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Rede e Internet" gerencia conexões de rede, central de compartilhamento e opções de proxy.

BIZU DE PROVA:
Caminho Clássico: Painel de Controle -> Programas -> Programas e Recursos -> Desinstalar um programa.
Nas Configurações Modernas (Win + I): Configurações -> Aplicativos -> Aplicativos Instalados.'),
(104, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Microsoft Word 2016, o atalho universal de teclado utilizado para DESFAZER a ação imediatamente anterior realizada no documento é CTRL+Z.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A tecla Alt isolada ativa as dicas de teclas da Faixa de Opções.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Alt+F4 fecha a janela ou encerra o aplicativo em execução.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Ctrl+R no Word em português é o atalho para REFAZER / Repetir ação (ou alinhar à direita em versões em inglês).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tecla Esc cancela seleções, fecha menus ou sai de modos de exibição.

BIZU DE PROVA:
Desfazer vs Refazer:
- Desfazer: Ctrl + Z.
- Refazer / Repetir: Ctrl + R (ou Ctrl + Y / F4).'),
(105, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sintaxe canônica da função condicional no Excel é =SE(teste_lógico; valor_se_verdadeiro; valor_se_falso). Para exibir o maior número entre A2 e B2:
Se o teste A2>B2 for verdadeiro, o maior é A2; se falso, o maior é B2.
Fórmula correta: =SE(A2>B2;A2;B2).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Falta o sinal de igual (=) inicial e utiliza vírgula em vez de ponto e vírgula como separador.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Falta o sinal obrigatório de igual (=) no início da fórmula.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Utiliza dois-pontos (B2:A2) no lugar de ponto e vírgula, gerando erro de sintaxe.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Utiliza dois-pontos (A2:B2) entre os argumentos de retorno.

BIZU DE PROVA:
Estrutura da Função SE:
=SE( Condição ; Se_Verdadeiro ; Se_Falso )
Exemplo: =SE(A2>B2; A2; B2) -> se A2 for maior, mostra A2; senão, mostra B2.'),
(106, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Google Drive (assim como nos mecanismos de busca do Google), o operador para pesquisar por uma correspondência exata de frase / termos contíguos na mesma ordem é o uso de ASPAS DUPLAS (“planejamento de atividades”).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A busca sem aspas busca documentos que contenham qualquer uma das palavras, em qualquer ordem ou proximidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O uso do sinal ''+'' é operador booleano de inclusão, não forçando frase exata contígua.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O sinal de porcentagem (%) é caractere curinga em linguagem SQL, não no buscador do Drive.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O sinal de menos (-) exclui palavras da pesquisa (excluiria as palavras "de" e "atividades").

BIZU DE PROVA:
Operadores de Busca do Google e Drive:
- "termo exato": busca a frase exata entre aspas.
- -termo: exclui páginas com a palavra.
- site:url: restringe ao site especificado.
- filetype:pdf: restringe ao formato de arquivo indicado.'),
(107, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): Clicar com o botão direito do mouse em área livre da página no Firefox exibe no menu de contexto a opção nativa "Capturar tela" (Firefox Screenshots).
- Assertiva II (Correta): O atalho de teclado oficial para acionar o recurso de captura de tela no Firefox é CTRL+SHIFT+S.
- Assertiva III (Incorreta): A tecla F5 é o atalho padrão de navegação para RECARREGAR (atualizar) a página web aberta, sem relação com captura de tela.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é válida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está errada (F5 recarrega a página).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Atalhos de Captura e Atualização no Navegador:
- Firefox Screenshots: Ctrl + Shift + S.
- Recarregar página: F5 ou Ctrl + R.
- Recarregar ignorando cache: Ctrl + F5 ou Ctrl + Shift + R.'),
(108, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O estado de SUSPENSÃO (Sleep) no Windows 10 coloca o computador em um modo de baixíssimo consumo de energia elétrica, mantendo a sessão de trabalho e os programas abertos armazenados na memória RAM, o que possibilita retomar as atividades quase instantaneamente em poucos segundos exatamente de onde parou.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Adormecimento" não é uma nomenclatura oficial de gerenciamento de energia no Windows.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Desconexão" (Fazer logoff / Sair) encerra a sessão do usuário sem colocar o computador em modo de economia de energia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Desligamento completo" desliga totalmente o fornecimento de energia, fechando todos os programas e exigindo uma inicialização completa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Reinício" encerra o sistema e o inicializa novamente do zero.

BIZU DE PROVA:
Modos de Energia no Windows:
- Suspensão: Salva o estado na memória RAM (consumo mínimo, retorno imediato).
- Hibernação: Salva o estado no disco rígido (hiberfil.sys) e desliga a energia (consumo zero).'),
(109, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Microsoft Excel, a representação canônica de um intervalo contínuo de células (bloco retangular) inicia na coordenada da célula superior esquerda, seguida pelo operador dois-pontos (:), finalizando na coordenada da célula inferior direita. O intervalo que vai da coluna A linha 1 até a coluna G linha 5 é grafado como A1:G5.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O ponto e vírgula (;) seleciona apenas duas células isoladas (A1 e G5), e não o intervalo contínuo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A1:A5;G1:G5 seleciona apenas as colunas A e G de 1 a 5, omitindo as colunas intermediárias (B, C, D, E, F).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O traço (-) é operador aritmético de subtração, inválido para definir intervalos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A1-G5 representa uma operação de subtração aritmética, não uma referência de intervalo.

BIZU DE PROVA:
Intervalos no Excel:
- A1:G5 -> De A1 até G5 (engloba todas as células entre as colunas A até G e linhas 1 até 5).
- A1;G5 -> Apenas a célula A1 e a célula G5.'),
(110, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Microsoft Word (assim como no Excel e PowerPoint), a ferramenta PINCEL DE FORMATAÇÃO (Format Painter), localizada no grupo Área de Transferência da guia Página Inicial, copia todas as formatações visuais (fonte, cor, tamanho, alinhamento, espaçamento) de um texto ou objeto de origem e as aplica diretamente ao texto ou objeto de destino.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Estilos são conjuntos predefinidos de formatações aplicáveis a títulos e parágrafos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Colar Especial permite colar conteúdos sob formatos específicos (texto não formatado, imagem, HTML).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Recortar remove o conteúdo selecionado e o envia para a área de transferência.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Limpar Toda a Formatação remove todas as formatações aplicadas, retornando ao estilo padrão.

BIZU DE PROVA:
Atalhos do Pincel de Formatação no Word:
- Copiar Formatação: Ctrl + Shift + C.
- Colar Formatação: Ctrl + Shift + V.
- Duplo clique no ícone do Pincel: permite aplicar a formatação em múltiplos trechos sucessivos.'),
(294, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
PHISHING (pescaria digital) é a técnica de engenharia social e cibercrime que consiste no envio de mensagens fraudulentas (por e-mail, redes sociais, SMS ou aplicativos de mensagens) que se passam por instituições confiáveis (bancos, órgãos públicos, empresas) com o objetivo deliberado de enganar o usuário para que este forneça senhas, dados bancários, números de cartão de crédito ou clique em links maliciosos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Backup é a cópia preventiva de segurança de dados.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Firewall é um dispositivo de segurança que filtra o tráfego de rede entre uma rede confiável e uma não confiável.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Compactação é a redução de tamanho de arquivos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Desfragmentação é a reorganização dos setores de arquivos em disco rígido.

BIZU DE PROVA:
Golpes Cibernéticos Clássicos:
- Phishing: e-mails/mensagens falsas para roubar senhas e dados financeiros.
- Ransomware: malware que criptografa os arquivos da vítima e exige resgate ($).
- Spyware: software espião que monitora as atividades do usuário (ex.: Keylogger, Screenlogger).'),
(338, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Windows 10, um ATALHO (Shortcut) é um arquivo de vínculo (com extensão .lnk) representado tipicamente por um ícone contendo uma pequena seta curvada no canto inferior esquerdo, servindo como link de acesso rápido para executar um programa, abrir uma pasta ou acessar um arquivo localizado em qualquer diretório do sistema ou da rede.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Ponte" (Bridge) é termo de redes de computadores, não de ícones do sistema.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Indicador" não é a denominação técnica do link de arquivo no Windows.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ícone" é o termo genérico para qualquer representação gráfica de arquivo, pasta ou ferramenta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Ponteiro" refere-se ao cursor do mouse na tela.

BIZU DE PROVA:
Propriedades de um Atalho no Windows:
- Possui uma pequena seta no canto inferior esquerdo do ícone.
- Possui extensão oculta .LNK.
- Excluir o atalho NÃO exclui o programa ou arquivo original ao qual ele aponta.'),
(339, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na guia "Processos" do Gerenciador de Tarefas do Windows 10, são exibidos os aplicativos e processos em segundo plano com suas respectivas métricas de consumo de recursos em tempo real: CPU (Processador), Memória (RAM), Disco, Rede, GPU (Vídeo) e Consumo de Energia. A lista de usuários conectados e seus respectivos processos é exibida em uma guia separada e dedicada chamada "USUÁRIOS", e não dentro da guia Processos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A utilização de rede (Mbps) é uma coluna padrão exibida na guia Processos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A memória física em uso (MB/%) é exibida na guia Processos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A utilização do processador (%) é exibida na guia Processos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A utilização de disco (MB/s) é exibida na guia Processos.

BIZU DE PROVA:
Guias do Gerenciador de Tarefas (Ctrl + Shift + Esc):
- Processos: Consumo de CPU, Memória, Disco, Rede, GPU por programa.
- Desempenho: Gráficos em tempo real de hardware.
- Histórico de Aplicativos: Uso de recursos ao longo do tempo.
- Inicializar: Programas que iniciam com o Windows.
- Usuários: Usuários conectados e seus consumos.
- Detalhes: Lista detalhada com PID.
- Serviços: Serviços do sistema operacional.'),
(340, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta de preenchimento é F – V – V:
1) (F) Uma pasta de trabalho é que é o conjunto composto por uma ou mais planilhas (a assertiva inverteu o conceito ao dizer que uma planilha é um conjunto de pastas de trabalho).
2) (V) No Excel, toda fórmula deve obrigatoriamente iniciar com o sinal de igual (=) para que o programa reconheça a expressão como cálculo e não como texto simples.
3) (V) As colunas são dispostas verticalmente e identificadas por letras (A, B, C... XFD), enquanto as linhas são dispostas horizontalmente e identificadas por números (1, 2, 3... 1.048.576).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda e a terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é falsa e a segunda é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A primeira assertiva é falsa e a terceira é verdadeira.

BIZU DE PROVA:
Estrutura da Planilha do Excel:
- 1.048.576 Linhas (representadas por Números).
- 16.384 Colunas (representadas por Letras: de A até XFD).
- Pasta de Trabalho = o arquivo todo (.xlsx).
- Planilha = cada folha/aba da pasta.'),
(341, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No Microsoft Word 2016 (grupo Fonte da guia Página Inicial), o efeito de formatação TACHADO (Strikethrough) insere uma linha horizontal contínua que risca exatamente o meio dos caracteres do texto selecionado.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Itálico apenas inclina os caracteres para a direita.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Sobrescrito posiciona caracteres menores acima da linha de texto (ex.: 1º, x²).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Realce adiciona uma cor de fundo brilhante atrás do texto (semelhante a um marcador de texto físico).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Sublinhado desenha uma linha horizontal logo ABAIXO do texto.

BIZU DE PROVA:
Linhas no Texto (Word):
- Sublinhado: linha ABAIXO das letras (Ctrl + S).
- Tachado: linha NO MEIO das letras (riscando o texto).'),
(492, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ao arrastar a alça de preenchimento no Excel contendo fórmulas com referências relativas (sem o cifrão $), os números das linhas das referências são ajustados proporcionalmente linha por linha:
- Célula original E4: fórmula calcula a soma/valor do dia correspondente (13).
- E5 (arrastando para linha 5): calcula a fórmula relativa correspondente ao dia seguinte, resultando no valor 13.
- E6 (linha 6): calcula o valor correspondente da tabela (13).
- E7 (linha 7): calcula o valor correspondente da tabela (16).
- E8 (linha 8): calcula o valor correspondente da tabela (17).
A sequência correta resultante é: 13 – 13 – 16 – 17.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As células não assumem valores zerados pois há dados preenchidos nas colunas de origem.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não ocorre repetição constante de 15 pois a alça de preenchimento atualiza as referências de linha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A progressão aritmética 16-17-18-19 não reflete a soma dos dados da tabela.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As células são preenchidas automaticamente com os cálculos das fórmulas copiadas.

BIZU DE PROVA:
Alça de Preenchimento no Excel:
- Com fórmulas: copia e ajusta as referências relativas para as linhas/colunas seguintes.
- Com números isolados: repete o número (ou gera sequência se arrastado com Ctrl ou padrão identificado).'),
(493, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Microsoft Excel 2016, a inserção de elementos visuais externos como Tabelas, Tabelas Dinâmicas, Imagens, Formas, Ícones, Modelos 3D, Gráficos, Minigráficos e Hiperlinks localiza-se na guia INSERIR da Faixa de Opções.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A guia Revisão contém ferramentas de ortografia, dicionário de sinônimos, comentários e proteção da planilha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não existe uma guia principal chamada "Texto" na Faixa de Opções padrão do Excel.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A guia Exibir gerencia modos de exibição da pasta de trabalho, zoom, linhas de grade e congelar painéis.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os recursos de inserção de gráficos e objetos ilustrados na figura estão plenamente disponíveis no Excel.

BIZU DE PROVA:
Principais Guias do Excel 2016:
- Página Inicial: Área de Transferência, Fonte, Alinhamento, Número, Estilo, Células, Edição.
- Inserir: Tabelas, Ilustrações, Gráficos, Minigráficos, Filtros, Links, Texto, Símbolos.
- Fórmulas: Biblioteca de Funções, Nomes Definidos, Auditoria de Fórmulas.
- Dados: Obter e Transformar, Classificar e Filtrar, Ferramentas de Dados.'),
(494, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Gerenciador de Tarefas do Windows 10, a aba DESEMPENHO (Performance) apresenta gráficos e métricas de utilização em tempo real dos componentes de hardware da máquina: CPU (Processador), Memória (RAM), Disco (HD/SSD), Wi-Fi / Ethernet (Rede) e GPU (Placa de Vídeo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A aba Processos lista os programas e serviços em execução e seus consumos individuais em formato de tabela de colunas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Monitoramento" não é o nome de uma das guias do Gerenciador de Tarefas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A aba Histórico de Aplicativos mostra o consumo acumulado de recursos por apps do Windows.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A aba Detalhes lista todos os processos com seus identificadores de processo (PID) e status técnico.

BIZU DE PROVA:
Aba Desempenho do Gerenciador de Tarefas:
É a única que contém os gráficos de linha em tempo real de CPU, Memória, Disco e Rede!'),
(495, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas II e III:
- Assertiva I (Incorreta): O intervalo A1:C3 compreende todas as 9 células da matriz: (30+35+50) + (25+40+65) + (10+15+20) = 115 + 130 + 45 = 290, e NÃO 50.
- Assertiva II (Correta): O botão de formato numérico de moeda / casas decimais aplica a formatação com duas casas decimais, transformando o valor numérico 20 na exibição formatada 20,00.
- Assertiva III (Correta): O ícone com o balãozinho de texto tem como finalidade padrão no LibreOffice Calc inserir uma anotação / comentário na célula selecionada (Ctrl+Alt+C).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I traz uma soma matematicamente errada (soma real é 290).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva I está incorreta.

BIZU DE PROVA:
SOMA de Matriz no Calc / Excel:
=SOMA(A1:C3) soma TODAS as células do retângulo compreendido entre A1 (topo esquerdo) e C3 (fundo direito), totalizando 9 células.'),
(496, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na barra de ferramentas e de endereços do Google Chrome, o ícone composto por uma caixa com uma seta apontando para cima e para a direita (ou três pontos conectados) representa a ferramenta "COMPARTILHAR ESTA PÁGINA" (permitindo copiar link, enviar para outros dispositivos, gerar QR Code, transmitir mídia ou salvar página).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Adicionar página aos favoritos é representado pelo ícone de ESTRELA (Ctrl+D).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ver informações do site é representado pelo ícone de CADEADO / controles do site no início da barra de endereços.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Recarregar a página é representado por uma seta circular (F5 / Ctrl+R).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Avançar a página é representado por uma seta para a direita nos botões de navegação.

BIZU DE PROVA:
Ícones da Barra do Google Chrome:
- Estrela: Adicionar aos Favoritos (Ctrl + D).
- Seta Circular: Recarregar (F5).
- Cadeado / Controles: Ver informações de segurança e permissões do site.
- Caixa com Seta de Saída: Compartilhar esta página.'),
(497, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Mozilla Firefox, o ícone de uma seta circular localizado na barra de navegação/endereços tem como função "RECARREGAR A PÁGINA ATUAL" (Reload current page), atualizando as informações e o código da página a partir do servidor web (atalho F5 ou Ctrl+R).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Avançar página é representado por uma seta reta apontando para a direita.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Voltar página é representado por uma seta reta apontando para a esquerda (Alt + Seta Esquerda).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O painel de downloads é representado pelo ícone de uma seta apontando para baixo sobre uma bandeja.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O modo de tela inteira é acionado pela tecla de atalho F11.

BIZU DE PROVA:
Controles de Navegação no Firefox:
- Seta Esquerda: Voltar.
- Seta Direita: Avançar.
- Seta Circular: Recarregar (F5).
- X (enquanto carrega): Parar carregamento (Esc).
- Casinha (Home): Página Inicial (Alt + Home).'),
(498, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Microsoft Excel 2016 (versão em português), a função estatística que calcula a média aritmética de um conjunto de valores é =MÉDIA(intervalo) (grafada obrigatoriamente com o acento agudo na letra E). Para calcular a média das notas da célula B2 até a célula B6, utiliza-se o operador dois-pontos (:), resultando na fórmula: =MÉDIA(B2:B6).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O ponto e vírgula =MEDIA(B2;B6) calcularia apenas a média de dois números isolados (B2 e B6), além de omitir o acento da função em português.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
=MED(B2:B6) é a função mediana (valor central da amostra), e não a média aritmética.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Falta o sinal de igual (=), usa MED em vez de MÉDIA e o operador ".." não é padrão no Excel.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Falta o sinal de igual (=) e usa ponto e vírgula em vez de dois-pontos.

BIZU DE PROVA:
Diferença Crítica no Excel:
- =MÉDIA(A1:A10): Média Aritmética (soma e divide pela quantidade).
- =MED(A1:A10): Mediana (elemento central após ordenação).
- =MODO(A1:A10): Moda (valor que mais se repete).'),
(499, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Microsoft Excel, a função SE requer a estrutura =SE(teste_lógico; valor_se_verdadeiro; valor_se_falso). Para exibir o maior número entre A2 e B2, se A2 for estritamente maior que B2 (A2>B2), a fórmula retorna o valor de A2; caso contrário, retorna o valor de B2.
Fórmula correta: =SE(A2>B2;A2;B2).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Falta o sinal de igual (=) inicial e utiliza vírgula inadequada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Falta o sinal de igual (=) no início da expressão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Utiliza dois-pontos (B2:A2) no separador de argumentos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Utiliza dois-pontos (A2:B2) no retorno falso.

BIZU DE PROVA:
Toda fórmula no Excel começa OBRIGATORIAMENTE com o sinal de IGUAL (=). Argumentos de funções são sempre separados por PONTO E VÍRGULA (;).'),
(626, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O recurso "Desfazer envio" do Gmail permite ao remetente cancelar a transmissão de uma mensagem por um período configurável de 5 a 30 segundos logo após clicar no botão Enviar.
- Assertiva II (Correta): O "Modo Confidencial" do Gmail permite definir uma data de expiração para o e-mail, exigir senha por SMS para abertura e bloqueia as opções de o destinatário encaminhar, copiar, imprimir ou fazer download do conteúdo da mensagem.
- Assertiva III (Incorreta): Os Marcadores (Labels) do Gmail são uma ferramenta de organização de uso estritamente PESSOAL e local do usuário; eles NÃO são compartilhados nem afetam a caixa de entrada dos destinatários das mensagens.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Recursos do Gmail:
- Desfazer Envio: janela de cancelamento de 5 a 30 segundos.
- Modo Confidencial: impede cópia/impressão/encaminhamento e expira no prazo definido.
- Marcadores (Labels): categorização pessoal que só o próprio dono da conta enxerga.'),
(627, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Microsoft Word para Microsoft 365 / Word 2016, as configurações estruturais de página como Margens, Orientação (Retrato/Paisagem), Tamanho de papel, Quebras, Números de Linha, Hifenização e COLUNAS (divisão do texto em duas ou mais colunas verticais de estilo jornalístico) estão localizadas na guia LAYOUT da Faixa de Opções (no grupo "Configurar Página").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A guia Inserir permite incluir Páginas em branco, Tabelas, Imagens, Formas, Cabeçalho e Rodapé, mas não a divisão do texto em colunas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A guia Página Inicial gerencia Área de Transferência, Fonte, Parágrafo e Estilos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A guia Design controla Temas do documento, Formatação do Documento, Marca-d''água, Cor da Página e Bordas de Página.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A guia Exibir controla Modos de Exibição (Leitura, Layout de Impressão, Web), Zoom e Janelas.

BIZU DE PROVA:
Guia LAYOUT no Word:
Contém o grupo "Configurar Página":
- Margens;
- Orientação;
- Tamanho;
- Colunas;
- Quebras (de página e de seção);
- Hifenização.'),
(628, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Microsoft Word 2016 / 365, a BARRA DE STATUS, localizada na extremidade inferior da janela do aplicativo, exibe continuamente em tempo real informações essenciais sobre o documento aberto, tais como o número da página atual / total de páginas, a contagem total de palavras, o idioma de revisão ortográfica, atalhos de modos de exibição e controle de zoom.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Na guia Exibir (grupo Mostrar), controlam-se elementos visuais como Régua, Linhas de Grade e Painel de Navegação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A guia Revisão gerencia controle de alterações e comentários, não sendo a barra padrão de contagem instantânea de páginas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Ao lado do botão Salvar fica a Barra de Ferramentas de Acesso Rápido (no topo esquerdo).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O grupo Páginas fica na guia Inserir, não na Página Inicial.

BIZU DE PROVA:
Barra de Status do Word:
Localizada na parte inferior da tela, exibe:
- Página X de Y;
- Contagem de Palavras (clicar abre a caixa com caracteres, linhas e parágrafos);
- Idioma do Dicionário;
- Modos de Exibição e Controle deslizante de Zoom.'),
(629, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Microsoft Word, o recurso CONTROLE DE ALTERAÇÕES (Track Changes), localizado na guia Revisão (atalho Ctrl+Shift+E), registra todas as edições, exclusões, inclusões e alterações de formatação realizadas no documento, permitindo que outro usuário visualize exatamente o histórico de edições e decida individualmente por aceitar ou rejeitar cada uma das modificações propostas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Comentários apenas inserem notas explicativas nas margens laterais sem registrar alterações ativas no corpo do texto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Proteger documento restringe tipos de edição ou bloqueia acesso mediante senha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Localizar e substituir (Ctrl+U) busca e troca palavras em massa no texto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mesclagem (Mala Direta) combina um documento modelo com uma base de dados para geração de cartas ou etiquetas em lote.

BIZU DE PROVA:
Controle de Alterações no Word:
- Localização: Guia Revisão -> Grupo Controle -> Controlar Alterações.
- Atalho: Ctrl + Shift + E.
- Permite: Aceitar ou Rejeitar alterações de texto propostas.'),
(630, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A SURFACE WEB (Web de Superfície / Web Visível) é a camada da internet aberta e publicamente acessível por qualquer navegador comum sem exigência de credenciais especiais, cujos sites, portais e páginas são rastreados e indexados pelos motores de busca tradicionais (como Google, Bing e Yahoo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Dark Web é a camada oculta e criptografada da Deep Web que exige softwares e protocolos específicos (como a rede Tor) para ser acessada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Extranet é uma rede privada empresarial acessível remotamente por parceiros, clientes ou fornecedores autorizados.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Deep Web (Web Profunda) é a camada da internet que NÃO é indexada pelos motores de busca (inclui bancos de dados privados, intranets, internet banking, e-mails).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Darknet é uma rede overlay privada e descentralizada com acesso restrito a programas específicos.

BIZU DE PROVA:
Camadas da Internet:
1. Surface Web: indexada e aberta aos buscadores (Google, portais de notícias, blogs).
2. Deep Web: não indexada pelos motores de busca (sistemas bancários, e-mails, bancos de dados acadêmicos).
3. Dark Web: subcamada restrita da Deep Web que exige softwares especiais (ex.: Tor) e garante alto grau de anonimato.'),
(631, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
FINGERPRINTING (ou Device / Browser Fingerprinting) é uma técnica avançada de rastreamento e perfilamento digital que identifica unicamente um dispositivo ou navegador coletando e combinando um conjunto de características técnicas do hardware e do software (versão do sistema operacional, resolução de tela, fontes instaladas, extensões, placa gráfica, fuso horário, idioma), sem depender do armazenamento de cookies locais nem de logins em contas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Cookies são pequenos arquivos de texto gravados e armazenados localmente no dispositivo pelo navegador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Rastreamento por URL utiliza parâmetros de consulta (ex.: parâmetros UTM) anexados ao link de navegação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
ID de usuário (UID) é um identificador criado quando o usuário está autenticado em uma conta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Pixels de rastreamento (Web Beacons) são imagens invisíveis de 1x1 pixel embutidas em páginas ou e-mails.

BIZU DE PROVA:
Técnicas de Rastreamento Web:
- Cookies: arquivos salvos no disco local do usuário.
- Web Beacons / Tracking Pixels: imagens minúsculas (1x1) que disparam requisições ao servidor.
- Fingerprinting: identificação passiva por combinação única de hardware/software (sem salvar arquivos locais).'),
(632, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a 1ª parte está correta:
- 1ª parte (Correta): O DNS (Domain Name System) atua como a "lista telefônica da internet", traduzindo nomes de domínio legíveis por humanos (como www.google.com) nos respectivos endereços IP numéricos que as máquinas utilizam para comunicação.
- 2ª parte (Incorreta): O protocolo DNS opera na CAMADA DE APLICAÇÃO do modelo TCP/IP (e do modelo OSI), utilizando as portas 53 via UDP e TCP, e NÃO na camada de transporte.
- 3ª parte (Incorreta): O protocolo responsável pela atribuição e configuração automática de parâmetros de rede (IP, máscara de sub-rede, gateway e servidores DNS) aos dispositivos clientes é o DHCP (Dynamic Host Configuration Protocol), e não o DNS.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A 3ª parte descreve a atribuição automática de configurações de rede, que é função privativa do protocolo DHCP.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A 2ª parte erra ao afirmar que o DNS opera na camada de transporte (DNS opera na camada de Aplicação).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Tanto a 2ª quanto a 3ª partes contêm erros conceituais graves.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apenas a 1ª parte é verdadeira.

BIZU DE PROVA:
Protocolos de Rede e suas Camadas (TCP/IP):
- DNS (Camada de Aplicação): Traduz Nome de Domínio em Endereço IP. Porta 53 (UDP/TCP).
- DHCP (Camada de Aplicação): Configura IP, Máscara e Gateway automaticamente nos hosts. Portas 67/68 (UDP).
- Camada de Transporte: Contém apenas protocolos de transporte de pacotes (TCP e UDP).');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _inf1_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (11,15,31,32,33,60,61,62,63,64,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,294,338,339,340,341,492,493,494,495,496,497,498,499,626,627,628,629,630,631,632);

-- 2) alternativas completas das 50.
create temporary table _inf1_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (11,15,31,32,33,60,61,62,63,64,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,294,338,339,340,341,492,493,494,495,496,497,498,499,626,627,628,629,630,631,632)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _inf1_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _inf1_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _inf1_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _inf1_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _inf1_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _inf1_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 9 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id=9, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _inf1_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _inf1_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _inf1_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 50 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 50 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _inf1_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _inf1_ids_afetados) = 50;

  insert into _inf1_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _inf1_ids_afetados) = ARRAY[11,15,31,32,33,60,61,62,63,64,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,294,338,339,340,341,492,493,494,495,496,497,498,499,626,627,628,629,630,631,632]::bigint[];

  insert into _inf1_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _inf1_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _inf1_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _inf1_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _inf1_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _inf1_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _inf1_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _inf1_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _inf1_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _inf1_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _inf1_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _inf1_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[11,15,31,32,33,60,61,62,63,64,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,294,338,339,340,341,492,493,494,495,496,497,498,499,626,627,628,629,630,631,632]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _inf1_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _inf1_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _inf1_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _inf1_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _inf1_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _inf1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
