-- ============================================================================
-- AUDITORIA GLOBAL -- INFORMÁTICA -- LOTE FINAL (39 QUESTÕES)
-- Aplicação de 39 explicações pedagógicas restantes (materia_id 9)
-- IDs: 633,634,635,636,637,638,639,640,641,642,643,644,645,698,699,700,701,702,703,704,705,706,707,708,709,710,711,768,769,770,791,792,830,831,832,833,834,835,836
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-informatica-lote-final-harness.mjs a partir de
-- scripts/informatica-lote-final-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/informatica-lote-final-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _inff_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _inff_novas_explicacoes (id, explicacao) values
(633, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e III:
- Assertiva I (Correta): As nuvens públicas (como AWS, Microsoft Azure, Google Cloud) pertencem a provedores terceirizados, que gerenciam toda a infraestrutura física e lógica disponibilizada a múltiplos clientes pela internet.
- Assertiva II (Incorreta): O IaaS (Infraestrutura como Serviço) é o modelo MAIS BÁSICO da nuvem (fornecendo apenas hardware, virtualização, rede e armazenamento). O modelo mais abrangente e completo para o usuário final é o SaaS (Software como Serviço), enquanto o PaaS fornece a plataforma de desenvolvimento.
- Assertiva III (Correta): A nuvem substitui o modelo tradicional de alto custo de capital inicial em data centers (CapEx) por despesas operacionais flexíveis baseadas no consumo sob demanda (OpEx / Pay-as-you-go).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II é falsa (IaaS é o modelo mais básico, não o mais completo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva II está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva II está incorreta.

BIZU DE PROVA:
Modelos de Serviço em Nuvem (da base ao topo):
1. IaaS (Infraestrutura): servidores, rede, armazenamento (ex.: AWS EC2, Azure VM).
2. PaaS (Plataforma): ambiente de desenvolvimento e banco de dados (ex.: Heroku, Google App Engine).
3. SaaS (Software): aplicativo pronto para uso final (ex.: Google Workspace, Microsoft 365).'),
(634, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No Microsoft Teams, é possível iniciar uma reunião instantânea diretamente a partir de qualquer chat de grupo ou canal clicando no botão "Reunir agora" (ícone de câmera de vídeo no cabeçalho da conversa), sem necessidade de agendamento prévio no calendário.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Dependendo das configurações de lobby da reunião, outros participantes ou representantes da organização podem ingressar e iniciar a sessão.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Novos participantes podem ser convidados ou adicionados a qualquer momento durante a reunião em andamento pelo painel "Pessoas".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Teams permite ingressar em uma mesma reunião com dois dispositivos logados na mesma conta (ex.: computador para vídeo e smartphone como microfone/painel auxiliar).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É perfeitamente possível agendar reuniões com apenas dois participantes (ou até reuniões individuais para testes/gravações).

BIZU DE PROVA:
Reuniões no Microsoft Teams:
- Reunir Agora: inicia chamada instantânea a partir de chats, canais ou calendário.
- Agendar Reunião: cria compromisso futuro integrado ao calendário do Outlook.'),
(635, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O protocolo IMAP (Internet Message Access Protocol, porta padrão 993 SSL ou 143) sincroniza as pastas mantendo as mensagens originais armazenadas no servidor de correio, viabilizando o acesso simultâneo e consistente a partir de múltiplos dispositivos (celular, tablet, notebook).
- Assertiva II (Correta): Na estrutura padrão de e-mail (RFC 5322), o caractere @ (at/arroba) separa o nome de usuário local da identificação do servidor/domínio de hospedagem (exemplo: usuario@dominio.com.br).
- Assertiva III (Incorreta): O protocolo SMTP (Simple Mail Transfer Protocol, portas 587 / 465) é utilizado EXCLUSIVAMENTE para o ENVIO / transmissão de e-mails entre clientes e servidores; o recebimento/download é responsabilidade dos protocolos POP3 ou IMAP.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está errada (SMTP não baixa mensagens).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Mnemônico dos Protocolos de E-mail:
- SMTP = "Sua Mensagem Tá Partindo" (ENVIO).
- POP3 = Puxa do servidor para o computador local (RECEBIMENTO / Download).
- IMAP = Acesso e sincronização direta no servidor (RECEBIMENTO / Sincronização).'),
(636, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No Mozilla Firefox:
1) "Abas contêiner" (Multi-Account Containers) é o recurso nativo/extensão oficial que isola identidades de navegação (cookies, sessões e logins) por contexto de cores (ex.: Pessoal, Trabalho, Compras, Bancos).
2) "Fixar aba" (Pin Tab) fixa a aba como um ícone compacto no canto esquerdo da barra de abas, mantendo o site sempre aberto e protegido contra fechamentos acidentais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Navegação privada abre janela temporária e Modo leitor remove elementos visuais para facilitar a leitura.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Histórico lista páginas visitadas e Favoritos salva links de interesse.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Extensões e temas modificam aparência e funcionalidades gerais do navegador.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Downloads e Biblioteca gerenciam arquivos baixados e marcadores salvos.

BIZU DE PROVA:
Gerenciamento de Abas no Firefox:
- Fixar Aba: reduz a aba ao ícone no canto esquerdo e abre automaticamente com o navegador.
- Abas Contêiner: permite logar em múltiplas contas do mesmo site sem misturar cookies.'),
(637, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A função PROCV (Pesquisa Vertical) pertence à categoria de funções de "PESQUISA E REFERÊNCIA" do Excel (utilizada para localizar um valor em uma coluna e retornar o valor de uma coluna correspondente na mesma linha), e NÃO à categoria de Funções Lógicas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
E é uma função lógica nativa (retorna VERDADEIRO se todos os testes forem verdadeiros).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
SE é a principal função lógica condicional do Excel.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
NÃO é uma função lógica que inverte o valor booleano do argumento.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
OU é uma função lógica nativa (retorna VERDADEIRO se ao menos um teste for verdadeiro).

BIZU DE PROVA:
Categorias de Funções no Excel (Guia Fórmulas):
- Lógicas: SE, E, OU, NÃO, SEERRO, SES, PARAOX (XOR).
- Pesquisa e Referência: PROCV, PROCH, PROCX, ÍNDICE, CORRESP, INDIRETO.'),
(638, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Microsoft Excel, a função padrão para adição de valores é =SOMA(intervalo). Para somar de forma contínua todas as células da coluna A compreendidas entre a linha 1 e a linha 5, utiliza-se o operador dois-pontos (:), resultando na expressão canônica: =SOMA(A1:A5).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A função chama-se SOMA (e não SOMAR) e o ponto e vírgula somaria apenas A1 e A5.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O hífen (-) é operador aritmético de subtração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra "ATÉ" não é operador sintático reconhecido em fórmulas de planilha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"TOTAL" não é a função nativa de soma de intervalos no Excel em português.

BIZU DE PROVA:
Sintaxe de Soma:
=SOMA(A1:A5) -> soma de A1 até A5.
Toda fórmula inicia com ''='' e intervalos contínuos usam '':''.'),
(639, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
SPOOFING (mascaramento / falsificação) é a técnica de segurança ofensiva em que um atacante forja ou adultera cabeçalhos e identidades de dados para se passar por uma fonte, dispositivo ou entidade confiável e legítima (como IP Spoofing, DNS Spoofing, E-mail Spoofing, ARP Spoofing), visando ludibriar defesas de rede ou induzir usuários a erro.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A tentativa e erro exaustiva para adivinhar senhas define o ataque de FORÇA BRUTA (Brute Force).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Software malicioso autorreplicável pela rede sem hospedeiro define o WORM (Verme).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Ataque coordenado de sobrecarga distribuída define o ataque DDoS (Distributed Denial of Service).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Malware que criptografa arquivos e extorque resgate define o RANSOMWARE.

BIZU DE PROVA:
Termos Fundamentais de Segurança:
- Spoofing: falsificação de identidade/endereço (IP, E-mail, DNS).
- Sniffing: interceptação/escuta passiva de tráfego de rede.
- Phishing: engenharia social por mensagens fraudulentas.
- Brute Force: adivinhação de senhas por tentativa e erro.'),
(640, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
É INCORRETO afirmar que o primeiro fator deva ser obrigatoriamente uma senha tradicional. Sistemas modernos de MFA (como login Passwordless / FIDO2 / Passkeys / WebAuthn) permitem autenticações iniciando diretamente por dados biométricos (fator de inerência) ou chaves físicas de segurança de hardware (fator de posse), sem a exigência prévia de senha digitada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Descreve perfeitamente o conceito de MFA ao combinar dois ou mais fatores distintos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta sobre a camada adicional de proteção do MFA.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: fatores de categorias diferentes (ex.: senha + biometria) são muito mais seguros do que fatores da mesma categoria (duas senhas).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: códigos OTP enviados por SMS/e-mail atuam como fator de posse (posse do canal/aparelho).

BIZU DE PROVA:
Pilares da Autenticação Multifator (MFA):
1. O que você sabe (senha, PIN).
2. O que você tem (smartphone, token, smartcard).
3. O que você é (impressão digital, face, íris).'),
(641, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A criptografia SIMÉTRICA (também chamada de criptografia de chave secreta / chave única) é o modelo criptográfico no qual a mesmíssima chave secreta compartilhada é empregada tanto para cifrar (codificar) o texto claro quanto para decifrar (descodificar) o criptograma (exemplos clássicos: AES, DES, 3DES, RC4).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A criptografia Assimétrica (chave pública) utiliza um par de chaves matemáticas distintas: uma chave pública (para cifrar) e uma chave privada (para decifrar).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Chave pública é um dos componentes da criptografia assimétrica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Central" não é uma modalidade técnica de chave criptográfica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Principal" não é denominação formal de categoria de algoritmos de cifragem.

BIZU DE PROVA:
Simétrica vs Assimétrica:
- SIMÉTRICA (1 chave): mesma chave secreta para cifrar e decifrar (mais rápida, ex.: AES).
- ASSIMÉTRICA (2 chaves): chave pública cifra / chave privada decifra (ex.: RSA, ECC).'),
(642, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Lentidão severa e repentina do sistema operacional somada à abertura involuntária e espontânea de janelas de navegador / pop-ups com anúncios e redirecionamentos (adware / trojan / malware) são sintomas clássicos de infecção do dispositivo por códigos maliciosos (malwares).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Atualizações oficiais do sistema ocorrem em segundo plano ou em horários agendados e não abrem janelas pop-up invasivas de internet.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Arquivos compactados (.zip/.rar) ficam estáticos em disco e não executam janelas de forma autônoma.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Embora a escassez de memória RAM gere lentidão, ela não causa abertura espontânea de janelas de navegação na web.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Programas oficiais em operação normal não disparam janelas não solicitadas na internet.

BIZU DE PROVA:
Sintomas Comuns de Malware:
- Pop-ups invasivos e redirecionamento de buscas (Adware/Hijacker);
- Lentidão súbita e uso de 100% de CPU/Disco (Mineradores/Trojans);
- Arquivos bloqueados com extensões estranhas (Ransomware).'),
(643, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta de preenchimento é V – V – F:
1) (V) O "Histórico da Área de Transferência" do Windows 10/11 (acionado pelo atalho Tecla Windows + V) armazena múltiplos itens recentes de textos e imagens copiados ou recortados.
2) (V) O atalho universal Ctrl+C copia o texto selecionado para a Área de Transferência.
3) (F) A Área de Transferência suporta perfeitamente arquivos de imagem (como capturas de tela via Print Screen, Win+Shift+S ou cópia de arquivos gráficos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira e a segunda assertivas são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva é falsa.

BIZU DE PROVA:
Área de Transferência no Windows 10/11:
- Ctrl + C: Copiar.
- Ctrl + V: Colar o último item copiado.
- Win + V: Abre o painel do HISTÓRICO da Área de Transferência (textos, imagens e emojis).'),
(644, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Um atalho no Windows (.lnk) é apenas um ponteiro lógico que contém o caminho de referência para o arquivo, executável ou pasta de destino original. Para que o atalho funcione ao ser acionado pelo usuário, é indispensável que o arquivo original referenciado permaneça existindo, íntegro e acessível no mesmo diretório (se o original for movido ou excluído, o atalho torna-se inválido/"quebrado").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O atalho pode manter exatamente o mesmo nome sugerido no momento de sua criação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Se o original estiver na Lixeira, o atalho não conseguirá abrir o programa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Podem existir múltiplos atalhos diferentes apontando para o mesmo arquivo original.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atalhos funcionam sem qualquer exigência de criptografia.

BIZU DE PROVA:
Natureza do Atalho (.LNK):
O atalho não contém o código do programa, apenas um ponteiro de endereço. Excluir o atalho não apaga o original; mas apagar o original quebra o atalho.'),
(645, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Windows 10 e Windows 11, o caractere dois-pontos (:) é um caractere reservado do sistema de arquivos (utilizado para identificar unidades de disco como C: e fluxos de dados NTFS), sendo expressamente PROIBIDO na nomeação de pastas e arquivos. Portanto, o nome "Araquari:GuardaMunicipal" NÃO pode ser utilizado.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"gUARDA_2026" contém caracteres perfeitamente válidos (letras, números e sublinhado).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Prova-Guarda Municipal" é válido (hífen e espaço são permitidos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Concurso Município Araquari" é válido (letras com acento e espaços são permitidos).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Guarda123" é um nome perfeitamente válido.

BIZU DE PROVA:
Caracteres Proibidos em Arquivos e Pastas no Windows:
\ / : * ? " < > |
Dois-pontos (:) e barras são sempre inválidos!'),
(698, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O MODO CONFIDENCIAL do Gmail é o recurso nativo de segurança e privacidade que permite definir uma data limite de expiração para as mensagens de e-mail enviadas, revogar o acesso a qualquer momento, exigir código de acesso por SMS e bloquear as funcionalidades de copiar, colar, baixar, imprimir e encaminhar a mensagem e seus anexos por parte dos destinatários.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Agendamento de envio apenas programa a data e hora futuras para disparo do e-mail.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Alta prioridade apenas sinaliza importância visual na caixa de entrada.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Modo restrito" não é a denominação da ferramenta de e-mail confidencial do Gmail.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Mensagens privadas" não é o nome da função no ecossistema Google Workspace.

BIZU DE PROVA:
Modo Confidencial do Gmail:
- Ícone: Cadeado com relógio na barra inferior de composição.
- Funções: Bloqueia encaminhar, copiar, imprimir e baixar; permite definir data de expiração e senha via SMS.'),
(699, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Em clientes de correio eletrônico, o campo Cco (Cópia Carbono Oculta / Blind Carbon Copy - BCC) é utilizado quando se deseja enviar uma cópia da mensagem a um ou mais destinatários mantendo seus respectivos endereços de e-mail estritamente OCULTOS e invisíveis para os demais participantes da mensagem.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Occ" é uma sigla incorreta/invertida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O campo Cc (Cópia Carbono) envia cópias com os endereços de e-mail VISÍVEIS para todos os destinatários.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Ooc" não é uma sigla válida de cabeçalho de correio eletrônico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Oc" não é a sigla padrão.

BIZU DE PROVA:
Campos de Destinatários de E-mail:
- Para (To): destinatário principal.
- Cc (Cópia): cópia visível a todos.
- Cco (Cópia Oculta): cópia secreta (ninguém vê quem está no Cco, exceto o remetente).'),
(700, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a 1ª parte está correta:
- 1ª parte (Correta): Um rascunho é exatamente uma mensagem que foi salva automática ou manualmente no cliente de e-mail sem ter sido enviada.
- 2ª parte (Incorreta): Quando uma mensagem é enviada, ela é movida e armazenada na pasta "ITENS ENVIADOS" (ou "Enviados"), e não na caixa principal (Caixa de Entrada).
- 3ª parte (Incorreta): Embora clientes modernos como o Gmail exibam um aviso popup de lembrete se você citar a palavra "anexo" sem anexar arquivo, o aplicativo NÃO bloqueia de forma absoluta o envio, permitindo que o usuário confirme o envio sem anexo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A 3ª parte está incorreta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A 2ª parte está errada (vai para pasta Enviados).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A 2ª e a 3ª partes estão erradas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apenas a 1ª parte é verdadeira.

BIZU DE PROVA:
Pastas Padrão de Correio Eletrônico:
- Caixa de Entrada: mensagens recebidas.
- Rascunhos: mensagens em edição não enviadas.
- Enviados (Itens Enviados): mensagens despachadas com sucesso.
- Caixa de Saída: mensagens em fila aguardando envio.'),
(701, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No Microsoft Word 2016 (guia Layout -> grupo Configurar Página -> botão Quebras), todas as três opções descritas são modalidades oficiais de QUEBRAS DE SEÇÃO:
- I. (Correta) Próxima Página: insere a quebra de seção e posiciona o cursor no início da página imediatamente seguinte.
- II. (Correta) Página Par: insere a quebra de seção e inicia a seção subsequente na próxima página de numeração par.
- III. (Correta) Contínuo: insere a quebra de seção e inicia a nova seção no mesmo documento/página sem criar salto de página.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são quebras de seção válidas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são opções reais no Word.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois I e II também estão disponíveis.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a quebra de página par (II) também existe nativamente.

BIZU DE PROVA:
Tipos de Quebras de Seção no Word:
1. Próxima Página;
2. Contínuo;
3. Página Par;
4. Página Ímpar.'),
(702, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Um endereço IPv4 (Internet Protocol versão 4) é formado por 32 bits, representados convencionalmente no formato decimal por EXATAMENTE 4 OCTETOS (4 blocos numéricos separados por pontos), onde cada octeto pode variar numericamente entre 0 e 255. O formato "192.168.1.102" atende com perfeição à estrutura de 4 blocos decimais válidos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Apresenta apenas 1 bloco numérico (incompleto).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apresenta apenas 2 blocos numéricos (incompleto).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta apenas 3 blocos numéricos (incompleto).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta 5 blocos numéricos (excede a estrutura de 4 octetos do IPv4).

BIZU DE PROVA:
Estrutura de Endereçamento IP:
- IPv4: 32 bits = 4 blocos decimais (0 a 255) separados por pontos (ex.: 192.168.1.1).
- IPv6: 128 bits = 8 grupos hexadecimais de 4 dígitos separados por dois-pontos (ex.: 2001:0db8::1).'),
(703, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Computação em Nuvem (Cloud Computing) é o modelo que provê acesso remoto e sob demanda, via rede/internet, a um pool compartilhado de recursos computacionais configuráveis (servidores, armazenamento, bancos de dados, redes e aplicativos de software).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A nuvem opera sob o Modelo de Responsabilidade Compartilhada: a segurança DA nuvem é do provedor, mas a segurança DOS dados, acessos e configurações DENTRO da nuvem é de responsabilidade do cliente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O acesso aos serviços de nuvem depende fundamentalmente de conectividade com a rede/internet.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os maiores provedores de nuvem (Google Cloud Vertex AI, AWS SageMaker, Azure AI) oferecem plataformas completas de Inteligência Artificial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A nuvem utiliza criptografia de ponta a ponta, certificações ISO/SOC e defesas avançadas contra ameaças.

BIZU DE PROVA:
Computação em Nuvem (NIST):
- Acesso amplo pela rede (internet);
- Autosserviço sob demanda;
- Elasticidade rápida;
- Pool de recursos compartilhados;
- Serviço mensurável (pague pelo que usar).'),
(704, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
URL (Uniform Resource Locator - Localizador Uniforme de Recursos) é a cadeia de caracteres padronizada que especifica o endereço global e único de um recurso na World Wide Web (como páginas web, documentos ou imagens), indicando o protocolo, o domínio e o caminho do arquivo (ex.: https://www.exemplo.com.br/pasta/pagina.html).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
HTTP é o protocolo de transferência de hipertexto, e não o endereço completo do recurso.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Storage é o termo genérico em inglês para armazenamento de dados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
VPN (Virtual Private Network) é uma rede privada virtual que estabelece um túnel criptografado de comunicação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
WWW (World Wide Web) é o sistema global de documentos em hipertexto interconectados.

BIZU DE PROVA:
Anatomia de uma URL:
http:// (protocolo) + www.site.com (domínio/host) + :80 (porta) + /pasta/arquivo.html (caminho do recurso).'),
(705, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as partes 1ª e 2ª:
- 1ª parte (Correta): Tanto a Deep Web quanto a Dark Web consistem em conteúdos não indexados pelos motores de busca abertos convencionais.
- 2ª parte (Correta): A Deep Web engloba sistemas comuns (e-mails, extratos bancários, intranets) que são perfeitamente acessados através de navegadores comuns (Chrome, Firefox, Edge) mediante login e senha.
- 3ª parte (Incorreta): A Dark Web exige navegadores/softwares voltados a redes anônimas criptografadas como o TOR BROWSER (ou redes I2P/Freenet). O "Autopsy" é uma ferramenta forense digital de análise pós-incidente, e NÃO um software de acesso à Dark Web.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a 2ª parte também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A 3ª parte cita incorretamente o software Autopsy como navegador da Dark Web.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A 3ª parte está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A 3ª parte está incorreta.

BIZU DE PROVA:
Navegação na Dark Web:
O principal navegador/software utilizado para acessar sites da rede Tor (.onion) na Dark Web é o TOR Browser (The Onion Router).'),
(706, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Apenas a assertiva II está correta:
- Assertiva I (Incorreta): A proteção baseada em sigilo e controle de acesso a indivíduos autorizados define o princípio da CONFIDENCIALIDADE (a autenticidade garante a autoria/identidade da fonte).
- Assertiva II (Correta): A INTEGRIDADE assegura que a informação seja preservada em seu estado exato e original, imune a alterações, adulterações ou destruições não autorizadas ou acidentais.
- Assertiva III (Incorreta): A garantia de que a informação esteja acessível e operacional sempre que solicitada por usuários autorizados define a DISPONIBILIDADE (e não conformidade).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I confunde confidencialidade com autenticidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva I está incorreta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III confunde disponibilidade com conformidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apenas a assertiva II é verdadeira.

BIZU DE PROVA:
Tríade CIA da Segurança da Informação:
- C = Confidencialidade (Sigilo / Apenas autorizados acessam).
- I = Integridade (Exatidão / Não modificação dos dados).
- A = Disponibilidade (Acessível quando requisitado).'),
(707, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas a 1ª e a 3ª partes:
- 1ª parte (Correta): Malwares são códigos maliciosos largamente empregados para execução de fraudes, interceptação de senhas, criação de redes zumbis (botnets) e disparo de spam em massa.
- 2ª parte (Incorreta): NÃO é "sempre possível" reverter ações ou recuperar dados: incidentes de vazamento irreversível de dados sigilosos ou ataques de ransomware destrutivos (wiper) podem resultar em perdas definitivas e irrecuperáveis.
- 3ª parte (Correta): Softwares antivírus/antimalware utilizam verificação heurística, assinaturas e análise comportamental para prevenir infecções, detectar e remover ameaças digitais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a 3ª parte também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A 2ª parte é falsa (não é sempre possível recuperar dados vazados ou destruídos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A 2ª parte está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A 2ª parte torna a assertiva globalmente incorreta.

BIZU DE PROVA:
Cuidado com termos absolutos em provas de TI:
Palavras como "SEMPRE possível", "INFALÍVEL" ou "100% SEGURO" quase sempre tornam o item FALSO!'),
(708, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O WORM (Verme da rede) é o tipo de código malicioso caracterizado por possuir capacidade de autorreplicação autônoma através de redes de computadores, explorando vulnerabilidades ativas em protocolos e serviços para enviar cópias de si mesmo de dispositivo para dispositivo sem a necessidade de hospedeiro (diferente dos vírus comuns) e sem intervenção humana.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Spam é o envio em massa de mensagens não solicitadas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Adware é um software focado na exibição de propagandas e anúncios indesejados.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Keylogger é um tipo de spyware que captura tudo o que o usuário digita no teclado físico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Spyware é o termo genérico para softwares espiões de monitoramento de dados do usuário.

BIZU DE PROVA:
Vírus vs Worm:
- VÍRUS: Precisa de um arquivo HOSPEDEIRO e de EXECUÇÃO humana para se propagar.
- WORM: É AUTÔNOMO (independente), propaga-se sozinho pela REDE explorando falhas de segurança.'),
(709, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
BACKUP (cópia de segurança) é o procedimento preventivo sistemático de duplicar dados, arquivos e sistemas operacionais em uma mídia ou local independente (como nuvem, fitas magnéticas ou unidades de disco externas), viabilizando sua restauração integral em cenários de falhas de hardware, ataques de ransomware, corrupção lógica ou exclusão humana acidental.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Criptografia é a técnica de codificação de dados para garantir confidencialidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restore (Restauração) é a etapa posterior de RECUPERAÇÃO dos dados a partir do backup realizado previamente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Storage é o equipamento/servidor de armazenamento físico de dados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Antivírus é a ferramenta de detecção e erradicação de códigos maliciosos.

BIZU DE PROVA:
Backup vs Restore:
- Backup: FAZER a cópia de segurança.
- Restore: RESTAURAR os dados da cópia de segurança quando ocorre a perda.'),
(710, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O HASH criptográfico (como SHA-256, SHA-512 ou MD5) é uma função matemática unidirecional que converte uma quantidade arbitrária de dados em uma cadeia de caracteres alfanuméricos de comprimento fixo (resumo criptográfico / "impressão digital digital"), sendo a ferramenta padrão em computação forense e no Judiciário para assegurar e comprovar a INTEGRIDADE e a cadeia de custódia da evidência digital (qualquer alteração de 1 bit no arquivo original modifica radicalmente o hash gerado).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mixer (ou Tumbler) é uma ferramenta utilizada em criptomoedas para embaralhar transações visando anonimato.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Log de auditoria é um registro cronológico de eventos e acessos ao sistema.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Chave simétrica é utilizada para cifragem/decifragem de textos, não atuando como função de resumo de integridade forense.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Proxy é um servidor intermediário entre clientes e a internet.

BIZU DE PROVA:
Função Hash (Resumo Criptográfico):
- Unidirecional (não dá para voltar do hash para o texto original).
- Tamanho Fixo.
- Efeito Avalanche: mudar uma letra altera todo o hash.
- Principal finalidade: Provar a INTEGRIDADE do arquivo.'),
(711, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A correlação exata entre a Coluna 1 e a Coluna 2 é 3 – 2 – 1:
- (3) Gerenciador de Tarefas: Ferramenta que permite visualizar e gerenciar processos ativos e o desempenho em tempo real do sistema.
- (2) Área de Trabalho (Desktop): Interface gráfica principal onde os ícones de programas, pastas e arquivos são exibidos para acesso rápido.
- (1) Painel de Controle: Central clássica para ajustes e configurações do sistema operacional, como adicionar ou remover programas.
Sequência correta: 3 – 2 – 1.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência 1 – 2 – 3 inverte as definições de Painel de Controle e Gerenciador de Tarefas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência 1 – 3 – 2 está incorreta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência 2 – 3 – 1 está incorreta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência 3 – 1 – 2 associa erroneamente Painel de Controle à Área de Trabalho.

BIZU DE PROVA:
Elementos do Windows 10:
- Gerenciador de Tarefas (Ctrl + Shift + Esc): gerencia processos e desempenho de hardware.
- Área de Trabalho: tela inicial de trabalho com ícones e atalhos.
- Painel de Controle: configurações globais do sistema e programas.'),
(768, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Na barra inferior de ferramentas da janela de composição "Nova Mensagem" do Gmail no computador, estão presentes opções como: Formatação de texto, Anexar arquivos, Inserir link, Inserir emoji, Inserir arquivos com o Google Drive, Inserir foto, Alternar modo confidencial e Inserir assinatura. A funcionalidade "ADICIONAR TAREFA" (Google Tasks) localiza-se no painel lateral direito da tela principal do Gmail, e NÃO na barra inferior da janela de nova mensagem.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Inserir emoji" é um botão nativo com ícone de carinha feliz na barra da janela.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Inserir foto" é um botão nativo com ícone de fotografia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Inserir assinatura" é um botão nativo com ícone de caneta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Opções de formatação" é o primeiro botão representado pela letra ''A'' sublinhada.

BIZU DE PROVA:
Barra da Janela "Nova Mensagem" no Gmail:
- Botão Enviar;
- Formatação (''A'');
- Anexar arquivo (Clips);
- Inserir Link;
- Emoji;
- Google Drive;
- Inserir Foto;
- Modo Confidencial (Cadeado);
- Inserir Assinatura (Caneta).'),
(769, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No Microsoft Word 2016, a ferramenta INSERIR NOTA DE RODAPÉ (atalho Alt+Ctrl+F), que adiciona referências bibliográficas ou notas explicativas numeradas na margem inferior da página atual, está localizada na guia REFERÊNCIAS da Faixa de Opções (no grupo "Notas de Rodapé").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A guia Página Inicial gerencia formatações de fontes, parágrafos e estilos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A guia Revisão gerencia verificação ortográfica, controle de alterações e comentários.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A guia Inserir permite incluir Rodapé padrão de página (repetido em todas as páginas), mas a "Nota de Rodapé" específica de citação fica na guia Referências.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A guia Exibir controla modos de visualização e zoom do documento.

BIZU DE PROVA:
Rodapé vs Nota de Rodapé no Word:
- Inserir RODAPÉ (Cabeçalho e Rodapé): Guia INSERIR (repete-se no fim de todas as páginas da seção).
- Inserir NOTA DE RODAPÉ (citação/referência): Guia REFERÊNCIAS (inserida no final da página da citação específica).'),
(770, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No Google Chrome para computador, o Painel Lateral (Side Panel), acessível no canto superior direito da janela do navegador, disponibiliza as opções de:
- I. (Correta) Lista de leitura (artigos salvos para leitura posterior offline/online).
- II. (Correta) Histórico de navegação recente e abas de outros dispositivos.
- III. (Correta) Favoritos / Marcadores organizados em pastas para acesso rápido sem ocupar a barra principal.
Todas as assertivas I, II e III estão corretas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois Histórico e Favoritos também constam no painel lateral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois Lista de leitura e Favoritos também fazem parte do painel.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois Lista de leitura e Histórico também estão presentes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a assertiva I também está correta.

BIZU DE PROVA:
Recursos do Painel Lateral do Google Chrome:
1. Lista de Leitura;
2. Favoritos;
3. Histórico de Navegação;
4. Pesquisa do Google integrada.'),
(791, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa apresenta INCORRETAMENTE a funcionalidade do botão associado a "Zoom". No LibreOffice Writer, o ícone de LUPA com página geralmente representa a "Visualização de Impressão" (Ctrl+Shift+O) ou Localizar e Substituir (Ctrl+H), sendo o controle de Zoom gerenciado na barra de status inferior ou menu Exibir -> Zoom.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O ícone do pincel de pintura representa corretamente a função "Clonar Formatação".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O ícone de página partida representa corretamente "Inserir Quebra de Página" (Ctrl+Enter).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O ícone da prancheta com folha representa corretamente a função "Colar" (Ctrl+V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O ícone com a letra grega ômega (Ω) representa corretamente "Inserir Caracteres Especiais".

BIZU DE PROVA:
Ícones Clássicos do LibreOffice Writer:
- Pincel: Clonar Formatação (Ctrl + Shift + C no Word).
- Letra Ômega (Ω): Inserir Caracteres Especiais / Símbolos.
- Prancheta: Colar.'),
(792, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as quatro assertivas (I, II, III e IV) são funcionalidades verdadeiras presentes no Google Chrome e no Mozilla Firefox:
- I. (Correta) Ambos permitem salvar páginas como favoritos (atalho Ctrl+D).
- II. (Correta) O Firefox possui modo de Navegação Privativa (Ctrl+Shift+P).
- III. (Correta) O Chrome permite fixar e adicionar sites como atalhos na página inicial e na área de trabalho.
- IV. (Correta) Ambos operam com interface de múltiplas abas/separadores simultâneos na mesma janela.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois as assertivas III e IV também são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois as assertivas I e IV também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois as assertivas I e II também são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é correta.

BIZU DE PROVA:
Atalhos de Navegação Privada nos Navegadores:
- Google Chrome: Ctrl + Shift + N (Nova Janela Anônima).
- Mozilla Firefox: Ctrl + Shift + P (Nova Janela Privativa).
- Microsoft Edge: Ctrl + Shift + N (Janela InPrivate).'),
(830, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nas configurações gerais do Gmail na web, a opção "Cancelar envio" permite ao usuário escolher exclusivamente entre quatro valores temporais no menu suspenso do campo "Período de cancelamento de envio": 5, 10, 20 ou 30 SEGUNDOS (5s, 10s, 20s ou 30s).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A escala de tempo é em segundos, e não em minutos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não existem opções em minutos para cancelamento de envio no Gmail.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não existem opções em horas (o cancelamento é uma retenção temporária breve no servidor).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As opções não são contínuas de 1 a 5 segundos (são os saltos fixos de 5, 10, 20 ou 30 segundos).

BIZU DE PROVA:
Configuração de Cancelar Envio no Gmail:
Valores possíveis: 5, 10, 20 ou 30 SEGUNDOS. O valor padrão inicial configurado pelo Google é de 5 segundos.'),
(831, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Microsoft Word 2016 (grupo Parágrafo da guia Página Inicial), o botão MOSTRAR/OCULTAR (representado pelo símbolo de parágrafo / pilcrow ¶, atalho Ctrl+*) alterna a visibilidade de caracteres de formatação não imprimíveis, como marcas de parágrafo (¶), espaços entre palavras (pontos médios) e marcas de tabulação (setas horizontais).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Estrutura de Tópicos" é um modo de exibição de hierarquia de títulos na guia Exibir.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Mostrar Marcações" controla a visualização de revisões na guia Revisão.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Painel de Navegação" (Ctrl+F) localiza títulos, páginas e palavras no documento.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Pincel de Formatação" copia e cola estilos de formatação.

BIZU DE PROVA:
Botão Mostrar/Ocultar (¶):
- Símbolo: Pilcrow (¶).
- Atalho: Ctrl + * (ou Ctrl + Shift + 8).
- Finalidade: Visualizar caracteres ocultos que não saem na impressão (espaços, tabs, parágrafos, quebras).'),
(832, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No Microsoft Word 2016, o atalho universal de teclado utilizado para RECORTAR o texto ou objeto selecionado (enviando-o para a Área de Transferência e excluindo-o do ponto original) é CTRL+X.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A tecla Tab insere espaçamento de tabulação ou navega entre células de tabelas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ctrl+C é o atalho para COPIAR o conteúdo sem removê-lo do local original.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Shift+End estende a seleção até o fim da linha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Shift+Enter insere uma quebra de linha simples sem iniciar um novo parágrafo.

BIZU DE PROVA:
Atalhos Básicos de Edição (Windows / Office):
- Ctrl + X: Recortar.
- Ctrl + C: Copiar.
- Ctrl + V: Colar.
- Ctrl + Z: Desfazer.'),
(833, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas II e III:
- Assertiva I (Incorreta): O Mozilla Firefox permite sim instalar livremente milhares de extensões e complementos (Add-ons) através de sua loja oficial (Firefox Browser Add-ons).
- Assertiva II (Correta): O serviço "Firefox Sync" (via Conta Firefox) sincroniza de forma criptografada favoritos, abas abertas, senhas, histórico de navegação e extensões entre computadores, celulares e tablets.
- Assertiva III (Correta): A barra de endereços inteligente do Firefox (Awesome Bar) sugere termos dinâmicos baseando-se no histórico pessoal, marcadores salvos e buscas populares na web.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I está incorreta (extensões são suportadas).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva I está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva I está incorreta.

BIZU DE PROVA:
Firefox Sync e Complementos:
- Extensões / Complementos: personalizam e adicionam funções ao Firefox (atalho Ctrl + Shift + A).
- Firefox Sync: sincroniza abas, favoritos, logins e senhas entre múltiplos aparelhos.'),
(834, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A função SOMA no Excel aceita tanto referências de intervalo contínuo (usando dois-pontos) quanto valores constantes separados por ponto e vírgula. A expressão =SOMA(A1:B5;10) é perfeitamente válida e correta: calcula a soma de todas as células da matriz retangular de A1 até B5 e adiciona a constante 10 ao resultado final.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Utiliza vírgula (A1,A5) em vez do separador padrão ponto e vírgula (;) do Excel em português.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O caractere pipe (|) não é um operador de referência válido no Excel.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Utiliza vírgulas separando argumentos em vez de pontos e vírgulas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mistura vírgulas indevidas com ponto e vírgula na lista de argumentos.

BIZU DE PROVA:
Sintaxe no Excel (Versão em Português):
- Separador de argumentos: PONTO E VÍRGULA (;).
- Operador de intervalo: DOIS-PONTOS (:).
- Separador decimal: VÍRGULA (,).'),
(835, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Na aba "Geral" da caixa de diálogo Propriedades de um arquivo no Explorador de Arquivos do Windows 10, são exibidas: Nome do arquivo, Tipo de arquivo (.extensão), Abre com (programa padrão), Local (caminho), Tamanho, Tamanho em disco, Criado (data/hora), Modificado (data/hora), Acessado (data do último acesso) e Atributos (Somente leitura e Oculto). O sistema NÃO contabiliza nem exibe um contador de "NÚMERO DE ACESSOS" ao arquivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Tipo de arquivo" é uma das primeiras informações da aba Geral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Tamanho do arquivo" e "Tamanho em disco" são exibidos na aba Geral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Local do arquivo" é exibido na aba Geral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Data e hora de criação" é exibido no bloco de datas da aba Geral.

BIZU DE PROVA:
Propriedades de Arquivo no Windows (Alt + Enter):
Aba Geral contém:
- Tipo de arquivo;
- Abre com;
- Localização;
- Tamanho e Tamanho em disco;
- Criado em, Modificado em, Acessado em;
- Atributos (Somente leitura, Oculto).
NÃO existe contador de quantas vezes o arquivo foi aberto/acessado!'),
(836, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No sistema operacional Windows 10, o caractere de ponto de interrogação (?) é um dos caracteres especiais reservados do sistema proibidos em nomes de arquivos e pastas. Portanto, o nome "praia ou serra?.pdf" é INVÁLIDO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"programa_de_informática.docx" utiliza caracteres válidos (letras, underline e acentos).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"#cronograma do projeto.xlsx" é um nome válido (cerquilha e espaços são aceitos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"lista-mercado.txt" é um nome válido (hífen é permitido).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"controle(1).exe" é um nome válido (parênteses e números são permitidos).

BIZU DE PROVA:
Mnemônico dos 9 Caracteres Proibidos no Windows:
"BASA DUPLA COM INTERROGAÇÃO NO CORAÇÃO"
\ / : * ? " < > |
(Barra, Barra invertida, Dois-pontos, Asterisco, Ponto de Interrogação, Aspas duplas, Menor que, Maior que, Pipe).');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 39 (exceto explicacao/atualizado_em).
create temporary table _inff_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (633,634,635,636,637,638,639,640,641,642,643,644,645,698,699,700,701,702,703,704,705,706,707,708,709,710,711,768,769,770,791,792,830,831,832,833,834,835,836);

-- 2) alternativas completas das 39.
create temporary table _inff_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (633,634,635,636,637,638,639,640,641,642,643,644,645,698,699,700,701,702,703,704,705,706,707,708,709,710,711,768,769,770,791,792,830,831,832,833,834,835,836)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _inff_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _inff_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _inff_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _inff_novas_explicacoes) <> 39 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 39 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _inff_novas_explicacoes);
  if v_qtd <> 39 then
    raise exception 'PRECONDICAO FALHOU: esperado 39 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _inff_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 9 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 39 nao esta mais no estado auditado (materia_id=9, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 39.
-- ----------------------------------------------------------------------------
create temporary table _inff_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _inff_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _inff_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 39 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 39 linhas, afetou %', v_linhas;
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
  insert into _inff_asserts (descricao, ok)
  select 'exatamente 39 questoes afetadas pelo UPDATE', (select count(*) from _inff_ids_afetados) = 39;

  insert into _inff_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 39 esperados',
    (select array_agg(id order by id) from _inff_ids_afetados) = ARRAY[633,634,635,636,637,638,639,640,641,642,643,644,645,698,699,700,701,702,703,704,705,706,707,708,709,710,711,768,769,770,791,792,830,831,832,833,834,835,836]::bigint[];

  insert into _inff_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 39 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _inff_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _inff_asserts (descricao, ok)
  select 'alternativas das 39 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _inff_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _inff_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _inff_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _inff_asserts (descricao, ok) values ('as 39 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 39 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _inff_novas_explicacoes)
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
    where q.id in (select id from _inff_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _inff_asserts (descricao, ok) values ('as 39 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 39);

  insert into _inff_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _inff_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[633,634,635,636,637,638,639,640,641,642,643,644,645,698,699,700,701,702,703,704,705,706,707,708,709,710,711,768,769,770,791,792,830,831,832,833,834,835,836]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _inff_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _inff_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _inff_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _inff_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _inff_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _inff_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
