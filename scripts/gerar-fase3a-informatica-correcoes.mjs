#!/usr/bin/env node
// Fase 3A — Informática (Saneamento de Imagens, Figuras e Ícones Omitidos / Higiene de OCR)
// Universo auditado: 89 questões de Informática (materia_id = 9).
// Escopo do lote de alteração (12 questões):
//   - ID 60: Enunciado autossuficiente (Barra de Ferramentas de Acesso Rápido do Win10). Gabarito E preservado.
//   - ID 64: Enunciado autossuficiente (Botão Compartilhar do Google Drive com ícone de silhueta e sinal +). Gabarito D preservado.
//   - ID 338: Higiene de OCR no enunciado (remoção de quebras artificiais). Gabarito C preservado.
//   - ID 341: Higiene de OCR no enunciado (pode-se) e expurgo de cabeçalho estranho na Alt E (1686). Gabarito E preservado.
//   - ID 492: Enunciado com tabela de ocorrências diárias formatada em Markdown. Gabarito B preservado.
//   - ID 493: Enunciado autossuficiente (descrição de grupos e comandos da guia Inserir do Excel 2016). Gabarito A preservado.
//   - ID 494: Enunciado autossuficiente (descrição da aba Desempenho do Gerenciador de Tarefas do Win10). Gabarito B preservado.
//   - ID 495: Enunciado com matriz 3x3 do Calc em Markdown e descrição dos botões nas assertivas II/III. Gabarito D preservado.
//   - ID 496: Enunciado autossuficiente (botão Compartilhar com seta para cima/fora no Chrome). Gabarito E preservado.
//   - ID 497: Enunciado autossuficiente (botão Recarregar com seta circular no Firefox). Gabarito D preservado.
//   - ID 791: Enunciado e alternativas com descrição dos ícones dos botões do LibreOffice Writer. Gabarito B preservado.
//   - ID 831: Enunciado com lacuna e símbolo do botão Mostrar/Ocultar (¶). Gabarito B preservado.
//
// 77 questões intocadas:
//   - IDs: 11, 15, 31, 32, 33, 61, 62, 63, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 294, 339, 340, 498, 499, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 698, 699, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 768, 769, 770, 792, 830, 832, 833, 834, 835, 836.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase3a_informatica_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase3a_informatica_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes capturados ao vivo do banco de produção antes desta migração (89 questões de Informática):
const HASH_QUESTAO_ANTES = {
  11: '4e3aeb7cdd3ef4dc455e52259af2a579',
  15: 'f117002c7a2df47ae27cb8c78f9f85af',
  31: 'ef843ae0953970de7ad2cded8f79797c',
  32: '84b58d8b56cba2eae2bc33b1cef51b92',
  33: '7b30f58ed88c4e96e61d70fbf054119c',
  60: '4c869b984b37ed9c0a345de08194f0f0',
  61: '03dfc8cb627c237cd5b7da41bb22ff23',
  62: 'fdb3f282186e4151855d3f5d7e284f4f',
  63: 'e58f47083df5aa02966939435d5e4eae',
  64: '666092c70eab2d7518ed5b036f42bde1',
  91: 'cbca6e1550aa4fc88c70d5481bd4d63c',
  92: '044df8ca78f9cc922d55be4f8a817529',
  93: 'cf221e3cb80e60e76f724681d2f62553',
  94: 'eef7188484e1669d283fa44d35a66473',
  95: '379d386e9b88bc9bb94c0c4a1205851a',
  96: '29447b377c86e9db7f41d85159dbe7ef',
  97: '4eeb77615efc62bafcc64a6424cae8c4',
  98: '918de151dbddb1889836abd036fc3080',
  99: '91a16ec954c6ae3c007ebe9b44947068',
  100: '7aeaeed842e0652db24885f2679cb7f5',
  101: 'dcc4b247d7ab65f8f25f40d471607671',
  102: 'e14ef78c141fbce4d065b5a0921d8f3e',
  103: '9b19df533c974163bc00304b9fe7aa12',
  104: '22f20de454438fb2183555c605a94d04',
  105: 'b89ab7797351332a7431e5dcacd6f226',
  106: '8a07adee33e941913531fe97b559224d',
  107: '73411e2cfd74e0ca486d5b16d6dbdaf8',
  108: '004a86990e08796e729da01cf39efb71',
  109: '65872511e5b32694e74d518b5cd7ac03',
  110: 'b5eb2481e9c214d92a7298c8ce3db6ed',
  294: 'c4c088d94adcfd286e2ab17e7bf7b6c7',
  338: '77840cfdd31e67e69256177fe3b43ca2',
  339: '69a54ba500554230adabfa1d547ffce6',
  340: '8b6d94b4788569fe79813263243f4322',
  341: 'b0c036fbff041d0451456cf2c4c9915d',
  492: '0590db1b3a92d86cc6e2b9ae8f887b35',
  493: '798f863ab04a49411ef022df194eb681',
  494: 'b12ccea857d97a79aed0b76822b5bdc1',
  495: 'd7935e72d77775474199d5f8a71be65c',
  496: 'c585409cdc52d9bc22d9b7c5d44ad455',
  497: 'a86a6892e78fb496e026cfa285b2ee1f',
  498: '2a6e782d3b08452b3e5e030537fff2a8',
  499: '15b370a60938a7666ad295cc691bfdaf',
  626: 'e0a2ea0730b33a52cf59d1fc1f621f65',
  627: 'f5d17f22dc3beb0881debb1b52cfe0f9',
  628: '4a432fa3a202c53bf731fed9f7b24f34',
  629: '8094769b496019bf1294ed111592cd3b',
  630: 'c526abcc82ac37c857b5c61431c91c6b',
  631: '9fda50487b355f1fef903dd7fc4ec555',
  632: '5b6d65a5d83f2104c1d48075e8da5f25',
  633: '84035418115c2b1229298020d298a075',
  634: '05521baf796800d41091ceab36d7d60d',
  635: '54e616049521f153086fbd74ae559b86',
  636: '119b6c32a43fa0621813338098e02d3b',
  637: '68a12e6689652bc263410a9b77a39ae7',
  638: '4f150eaafbfe601fc7af988de6296cba',
  639: '09cab23deb8319579cd15d8fcde4e67d',
  640: 'fe36a8fadbcfe601764839370738dabb',
  641: 'e21502d7a1cb158adb92c10878850bd8',
  642: '79eb19246c7a33371d0e984704901121',
  643: '8d9e80920ae8fd6d6d62c7ad30a3684d',
  644: '6560dd904788c125d824d899986c7c0c',
  645: '6eb971615424cb28d2376c7a253f6d8d',
  698: 'fdcd5a3f80b33ef3fd99b6463133246c',
  699: '34d9de3e369ba6bc3989e47bbee6721a',
  700: '12120e3a757f595c2fd7baf1ee1c687d',
  701: '303daf1af83302ee0ccae8b8477f2cdc',
  702: '96799869fb573d492709eb3998209730',
  703: '903f946a5d0186440fb4c04bae1af8ea',
  704: 'd15f427206067f98e016b2069091f321',
  705: '1684aee80e82d34aad4a6027670b4231',
  706: 'ab6b85cf75393bdccc2cfe12512a6923',
  707: '0b0353101dd12a79a8c0eada726295dc',
  708: '9536d8a84c07c122d5ede47c0ba10c83',
  709: '2e46c5b0fcb6e5687d8e230cec8a3e62',
  710: '02d80ca4a6c30eb109a6b35efd1b7bd2',
  711: '830547c1cc31925701eb8fa7c49814f2',
  768: '3d15ec6886c3e6860cbd2c724bdb3478',
  769: '5596246b8929a63c9a523079db8a1d5f',
  770: 'db1f99ac895426a04e354a42882bc7b8',
  791: 'c701084d3a36827a8b3441375e831201',
  792: '00d38c88ddc6c6bad1413d434e2eff9f',
  830: 'ebe5562e9a840ddec19f73aa0d75bdab',
  831: '355d5c1b07ebde1a902ac873fcac6f12',
  832: '3c5eff3c2c2cc22f949736038f265223',
  833: 'a3ad954f4e888f1f3c2a35eb5258346c',
  834: '6362e16495dab37b6638dc807cd6aa66',
  835: '1853eee163a2d6cc0c888813229994dc',
  836: 'b48c0251ffa80af307d32ac6284a88b4'
};

const HASH_EXPLICACAO_ANTES = {
  11: '051a4ea25d11c9bafe220706dfa94f20',
  15: 'dadcb215cd370d5194644fac5774c972',
  31: '6c07cead85c1b06cd7df189d067d7dd4',
  32: '65c8a66d516bff62b8c6aafe68917cc7',
  33: '422a3c43f0656492132d65ae88bc2897',
  60: 'f42b551276c42ee31d38d0b0648c388e',
  61: 'b12c8639ec815731c09ea0dc9b9e386c',
  62: '8d8dfed52b46f86ef8aa60201898db47',
  63: '7088d88bd0966a4fddf5686def666a81',
  64: 'be86d8ebe60d58711c5c7d89bc7b8679',
  91: '3d359049ce0feb70fb7080ea1eb0f2ed',
  92: 'dcd949e1024fe8b446d446e4749d3448',
  93: '8b880defbddb4a20151c44f85a0d7c67',
  94: '4ae574d898d5cc0163423a6dd39910cd',
  95: '938a02712318d130d4805f84d8c1f29e',
  96: '1772fc3affac3643a15698bb9e3dd8a0',
  97: '389581dc6b09f3ed722adc4507ab5c7f',
  98: '46b27c1c3c50d016d4f2fb131360854e',
  99: '1bc4939d04c42eea804ce01ee662badd',
  100: '5e47c395249d43ad9bd0d5b82ee900c2',
  101: 'b2e0deafdbbff255b565e01bb626ee9c',
  102: '33fe39aa769d06e7ea16ac70cf49fa79',
  103: 'f0b2b8a5a3f270e9deeaad84c9a9f2b8',
  104: '780074d1939695a8a7d796aa568a0b35',
  105: '21fa0d74f26b5ad085394dcf2b085bc4',
  106: '586d34c1888819e9d5771d502c73a8bb',
  107: '6a54a8bd1b3672759ad1e1e166f94cae',
  108: '4db646dc4b10ddc2f05aadcfffeb7fdb',
  109: '68340ee4ca957d8bfecd9fd920e1f39b',
  110: '7dcf57b53c302aeca6752a98fdb65676',
  294: 'f5a520e26bbaebae540337ca199ffaa5',
  338: 'dab289957ace083ae4a421bbfc5b80f3',
  339: '74c736fa620636774681b53bfec9e9ae',
  340: '865ae19edc79e36a18262ad45c7f79d3',
  341: '454f43a2fee6b32d57b0a3458c3d8178',
  492: '66cb56b8058df7b99fc4530b5f0d5678',
  493: 'd1c40eeff375884be9d50b4e80c8e5b7',
  494: 'c7673ba240677825597113136a56ec69',
  495: '109239919a92afed3a484a87a20ec904',
  496: '5a1af9a6bd4b46917141a1b28dacf973',
  497: '85d644e0c2832f199aa3e91cf12100d7',
  498: '1c8751f5f53cbcd48b87b926aabbced3',
  499: '7357dd37bd2e286c8d1b75601bf7f40e',
  626: '35f1dcd7834c18966f26ad6a26b07552',
  627: 'ae580f97a92d2498a9a1d6bb3aa09770',
  628: 'a0c6f18e6666ede8414db90863c891a7',
  629: 'fbcc9a8b9ee310960c0795d6ecc39cd2',
  630: '7283a6e18828073819d27c5f12a053ad',
  631: 'ab401cf2f4da3d660408f25e8be1abb3',
  632: '89b9245acb7ea75c890afeeb05ebe2de',
  633: '3eca3eed0c94efb5355d26d80bf0df8a',
  634: 'b337eea3a4633682e751a104f6e297ac',
  635: '455d5310005247cbc4dbbf09cebe68ae',
  636: 'd38b4ae74485103b99f0fb93f4ab5d17',
  637: '7f02cdaa569955aa64f4338c8394eea8',
  638: '28da3a22aa69d2a7bf2fc56fc1bf5bd0',
  639: '2423edd4b8bf111a3afebffe13da407c',
  640: '9710c2a1814023d796c0b288137efda2',
  641: 'cab213f152ba7ecad2d1f48a73830bea',
  642: 'efc3c0ad87eb0d9d01c58c8a3cc1b9a1',
  643: '9ba9c22000d901e8555da897190097bb',
  644: '446c8a92ee742e32dd5e8c3c18fe158e',
  645: 'c177615956c4dba277225f73780f7894',
  698: 'a056b2722ec4f38992ac0924185be3a4',
  699: '7a52e1dea08b9509e2907b204c1d9a67',
  700: '579465c47b30471dd0f0c273c65c39a3',
  701: '7af5acb0c70de9ea081f99855cb48a64',
  702: '93b171187ae8289636d9795fef1eab8e',
  703: '1abbb98d025b5fb6473e08b4713f1193',
  704: 'f47184f3d41d19f98e074481f437b72d',
  705: 'e60d262de69a4713d632ae79a972bac0',
  706: 'd80786d2efd6ab080cc66163d2fd6859',
  707: '6dc9482245f4647886e364889e8f3aef',
  708: '4f4c7dc8494d86c1cdc8c5f740d7d47d',
  709: '7103089b6af9a23438ffce93c835684f',
  710: '8420355bdd8a33e0ce32ff39e8ae9e6a',
  711: '930574088364cc54154ead9299a66cf2',
  768: '3e919f91bfec9dbc20231cad4a93673a',
  769: 'e50d702850e53c4560a37218e76dd38d',
  770: 'e91a3595d1ca3776579f05107670eb48',
  791: '35f07bb0f56e264298264fef159e2da6',
  792: '3ddba4077341030b9bba0fe66150aa01',
  830: '3867ed3ff80c41ef7ad8eeda7c701b52',
  831: '49915c09fb680aab36175793ef3b6e4b',
  832: '84caf59df418b7c4762093b065bceea4',
  833: 'c9d65152bb9b41cf354a8ad32c008868',
  834: 'a51f2944201de50603b351edc21174bd',
  835: '2d413add3e59f01d344e6a6dfd0136d6',
  836: '0ef2db5d84dd575fa5eaf45a59fac53d'
};

const GABARITO_ORDEM = {
  11: 1, 15: 1, 31: 1, 32: 1, 33: 1, 60: 5, 61: 3, 62: 2, 63: 1, 64: 4,
  91: 3, 92: 2, 93: 3, 94: 1, 95: 5, 96: 5, 97: 3, 98: 2, 99: 5, 100: 3,
  101: 2, 102: 4, 103: 1, 104: 4, 105: 4, 106: 3, 107: 3, 108: 5, 109: 2, 110: 1,
  294: 1, 338: 3, 339: 1, 340: 2, 341: 5, 492: 2, 493: 1, 494: 2, 495: 4, 496: 5,
  497: 4, 498: 2, 499: 4, 626: 4, 627: 4, 628: 2, 629: 1, 630: 5, 631: 2, 632: 1,
  633: 3, 634: 5, 635: 3, 636: 5, 637: 2, 638: 4, 639: 4, 640: 4, 641: 5, 642: 3,
  643: 3, 644: 1, 645: 2, 698: 4, 699: 5, 700: 1, 701: 5, 702: 4, 703: 1, 704: 2,
  705: 3, 706: 2, 707: 3, 708: 5, 709: 3, 710: 1, 711: 5, 768: 3, 769: 4, 770: 5,
  791: 2, 792: 5, 830: 1, 831: 2, 832: 3, 833: 4, 834: 3, 835: 3, 836: 2
};

const IDS_INTOCADOS = [
  11, 15, 31, 32, 33, 61, 62, 63, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102,
  103, 104, 105, 106, 107, 108, 109, 110, 294, 339, 340, 498, 499, 626, 627, 628, 629, 630,
  631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 698, 699, 700,
  701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 768, 769, 770, 792, 830, 832, 833,
  834, 835, 836
];

// Textos higienizados / autossuficientes dos 12 itens do escopo:
const ENUNCIADO_NOVO_60 = "No Explorador de Arquivos do Microsoft Windows 10, em sua configuração padrão e versão em português, a Barra de Ferramentas de Acesso Rápido (localizada na parte superior esquerda da janela) permite personalizar e exibir botões com as seguintes funções, EXCETO:";

const ENUNCIADO_NOVO_64 = "No Google Drive (versão web para computador), ao selecionar um arquivo na listagem, o botão representado pelo ícone de uma silhueta de pessoa acompanhada de um sinal de adição (+) tem como função:";

const ENUNCIADO_NOVO_338 = "No Microsoft Windows 10, em sua configuração padrão e em português, como é chamado o tipo de ícone utilizado comumente para criar um link rápido para um programa, arquivo ou pasta?";

const ENUNCIADO_NOVO_341 = "No Microsoft Word 2016, versão para computador, em sua configuração padrão e em português, para riscar um texto, inserindo uma linha horizontal sobre o meio das letras, pode-se utilizar a opção de formatação de texto conhecida como:";
const ALT_NOVA_341 = {
  1686: "Tachado."
};

const ENUNCIADO_NOVO_492 = "Considere a seguinte planilha elaborada no Microsoft Excel 2016 para controlar a quantidade de ocorrências diárias da Guarda Municipal:\n\n| | A | B | C | D | E |\n|---|---|---|---|---|---|\n| 3 | Dia | Manhã | Tarde | Noite | Total |\n| 4 | Seg | 4 | 5 | 4 | =SOMA(B4:D4) |\n| 5 | Ter | 3 | 6 | 4 | |\n| 6 | Qua | 5 | 3 | 5 | |\n| 7 | Qui | 6 | 4 | 6 | |\n| 8 | Sex | 4 | 7 | 6 | |\n\nNa célula E4, o resultado calculado é 13. Ao selecionar a célula E4, clicar na alça de preenchimento e arrastá-la até a célula E8, quais serão os resultados apresentados, respectivamente, nas células E5, E6, E7 e E8?";

const ENUNCIADO_NOVO_493 = "No Microsoft Excel 2016 (versão em português), opções e grupos de comandos como \"Tabelas\" (Tabela Dinâmica), \"Ilustrações\" (Imagens, Formas, Ícones), \"Gráficos\" e \"Minigráficos\" estão disponíveis na guia:";

const ENUNCIADO_NOVO_494 = "No Gerenciador de Tarefas do Microsoft Windows 10, a aba que apresenta gráficos de utilização em tempo real e métricas de desempenho dos componentes de hardware da máquina (CPU, Memória, Disco, Rede e GPU) é denominada:";

const ENUNCIADO_NOVO_495 = "Considere a tabela abaixo, criada no LibreOffice Calc:\n\n| | A | B | C |\n|---|---|---|---|\n| 1 | 30 | 35 | 50 |\n| 2 | 25 | 40 | 65 |\n| 3 | 10 | 15 | 20 |\n| 4 | | | |\n\nSobre essa planilha e as ferramentas do LibreOffice Calc, analise as assertivas abaixo:\n\nI. Ao digitar a fórmula =SOMA(A1:C3) na célula C4, o resultado apresentado será 50.\nII. Considerando que a célula C3 esteja selecionada e que o usuário clique no botão \"Formato numérico: moeda\" (ou \"Adicionar casa decimal\"), o valor exibido passará a ser 20,00.\nIII. O botão \"Inserir Anotação\" (representado pelo ícone de balão de diálogo) tem como funcionalidade inserir um comentário na célula selecionada.\n\nQuais estão corretas?";

const ENUNCIADO_NOVO_496 = "Na barra de ferramentas e de endereços do navegador Google Chrome (versão para computador), o botão representado por uma caixa com uma seta apontando para cima e para fora tem como função:";

const ENUNCIADO_NOVO_497 = "Na barra de navegação e de endereços do navegador Mozilla Firefox, o botão representado por uma seta circular (acionável pelo atalho F5 ou Ctrl+R) tem como função:";

const ENUNCIADO_NOVO_791 = "Assinale a alternativa que apresenta INCORRETAMENTE a relação entre o ícone de botão e sua funcionalidade no LibreOffice Writer:";
const ALTS_NOVAS_791 = {
  3932: "Ícone do Pincel de Pintura – Clonar Formatação.",
  3933: "Ícone da Lupa com Página – Zoom.",
  3934: "Ícone de Página Partida – Inserir Quebra de Página.",
  3935: "Ícone da Prancheta com Papel – Colar.",
  3936: "Ícone da Letra Grega Ômega (Ω) – Inserir Caracteres Especiais."
};

const ENUNCIADO_NOVO_831 = "No Microsoft Word 2016, o botão ____________ (representado pelo símbolo de parágrafo ¶) liga e desliga caracteres ocultos como espaços, marcadores de parágrafo ou marcas de tabulação. Assinale a alternativa que preenche corretamente a lacuna do trecho acima.";

function body(mode) {
  return `-- ============================================================================
-- FASE 3A — INFORMÁTICA (SANEAMENTO DE ELEMENTOS VISUAIS E HIGIENE OCR)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
-- ============================================================================

BEGIN;

-- Garante sessão em leitura e escrita para o harness/apply
SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_enunciado_check text;
  v_alt_check text;
BEGIN
  -- --------------------------------------------------------------------------
  -- 1. PRECONDIÇÕES E GUARDAS CONTRA DRIFT (ESTADO PRÉ-APPLY)
  -- --------------------------------------------------------------------------

  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Precondição falhou: totais globais divergentes. Esperado 915/907/8, obtido %/%/%',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Validação dos hashes pré-apply das 89 questões de Informática
${Object.entries(HASH_QUESTAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${id} divergiu do estado auditado.';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (12 QUESTÕES)
  -- --------------------------------------------------------------------------

  -- ID 60: Enunciado autossuficiente (Barra de Acesso Rápido)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_60)},
         atualizado_em = now()
   WHERE id = 60;

  -- ID 64: Enunciado autossuficiente (Botão Compartilhar do Google Drive)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_64)},
         atualizado_em = now()
   WHERE id = 64;

  -- ID 338: Higiene de OCR no enunciado
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_338)},
         atualizado_em = now()
   WHERE id = 338;

  -- ID 341: Higiene de OCR no enunciado e expurgo de cabeçalho na Alt E
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_341)},
         atualizado_em = now()
   WHERE id = 341;
${Object.entries(ALT_NOVA_341).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 341;`).join('\n')}

  -- ID 492: Enunciado com tabela de ocorrências diárias
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_492)},
         atualizado_em = now()
   WHERE id = 492;

  -- ID 493: Enunciado autossuficiente (guia Inserir do Excel)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_493)},
         atualizado_em = now()
   WHERE id = 493;

  -- ID 494: Enunciado autossuficiente (aba Desempenho do Gerenciador de Tarefas)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_494)},
         atualizado_em = now()
   WHERE id = 494;

  -- ID 495: Enunciado com tabela Calc em Markdown e botões descritos
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_495)},
         atualizado_em = now()
   WHERE id = 495;

  -- ID 496: Enunciado autossuficiente (botão Compartilhar no Chrome)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_496)},
         atualizado_em = now()
   WHERE id = 496;

  -- ID 497: Enunciado autossuficiente (botão Recarregar no Firefox)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_497)},
         atualizado_em = now()
   WHERE id = 497;

  -- ID 791: Enunciado e alternativas com descrição dos ícones do Writer
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_791)},
         atualizado_em = now()
   WHERE id = 791;
${Object.entries(ALTS_NOVAS_791).map(([altId, txt]) => `  UPDATE public.alternativas
     SET texto = ${sqlStr(txt)}
   WHERE id = ${altId} AND questao_id = 791;`).join('\n')}

  -- ID 831: Enunciado com lacuna e símbolo do botão Mostrar/Ocultar (¶)
  UPDATE public.questoes
     SET enunciado = ${sqlStr(ENUNCIADO_NOVO_831)},
         atualizado_em = now()
   WHERE id = 831;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados (915 total / 907 ativas / 8 inativas)
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: Nenhuma alteração de ativa no escopo (todas as 89 questões de Informática ativas)
  IF (SELECT count(*) FROM public.questoes WHERE materia_id = 9 AND ativa = true) <> 89 THEN
    RAISE EXCEPTION 'Assert 2 falhou: uma ou mais questões de Informática tiveram status ativa alterado indevidamente';
  END IF;

  -- Assert 3: Exatamente 1 alternativa correta por questão em todo o universo das 89 questões de Informática
  IF (SELECT count(DISTINCT questao_id) FROM public.alternativas a JOIN public.questoes q ON q.id = a.questao_id WHERE q.materia_id = 9) <> 89 OR
     EXISTS (
       SELECT 1
         FROM public.alternativas a
         JOIN public.questoes q ON q.id = a.questao_id
        WHERE q.materia_id = 9
        GROUP BY a.questao_id
       HAVING count(*) FILTER (WHERE a.correta = true) <> 1
     ) THEN
    RAISE EXCEPTION 'Assert 3 falhou: uma ou mais questões de Informática não possuem exatamente 1 alternativa correta';
  END IF;

  -- Assert 4: Preservação estrita dos gabaritos específicos em cada uma das 89 questões
${Object.entries(GABARITO_ORDEM).map(([id, ord]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${id} AND ordem = ${ord} AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: divergência no gabarito oficial da questão ${id} de Informática';
  END IF;`).join('\n')}

  -- Assert 5: 77 questões intocadas mantiveram seus hashes integrais
${IDS_INTOCADOS.map(id => `  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${id}) <> '${HASH_QUESTAO_ANTES[id]}' OR
     (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${HASH_EXPLICACAO_ANTES[id]}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: questão ${id} (intocada) foi modificada indevidamente';
  END IF;`).join('\n')}

  -- Assert 6: Explicações de todas as 89 questões de Informática preservadas byte a byte
${Object.entries(HASH_EXPLICACAO_ANTES).map(([id, hash]) => `  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 6 falhou: explicação da questão ${id} foi alterada indevidamente';
  END IF;`).join('\n')}

  -- Assert 7: Validações específicas de conteúdo higienizado
  -- ID 60: Acesso Rápido presente e sem 'Figura 1 abaixo'
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 60;
  IF v_enunciado_check NOT ILIKE '%Barra de Ferramentas de Acesso Rápido%' OR v_enunciado_check ILIKE '%Figura 1 abaixo%' THEN
    RAISE EXCEPTION 'Assert 7a falhou: enunciado da questão 60 não contém a descrição da Barra de Acesso Rápido';
  END IF;

  -- ID 64: Ícone com silhueta e sinal + presente e sem 'imagem abaixo'
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 64;
  IF v_enunciado_check NOT ILIKE '%silhueta de pessoa acompanhada de um sinal de adição (+)%' OR v_enunciado_check ILIKE '%imagem abaixo%' THEN
    RAISE EXCEPTION 'Assert 7b falhou: enunciado da questão 64 não contém a descrição do botão de compartilhar';
  END IF;

  -- ID 341: Alt E limpa sem 'CONHECIMENTOS ESPECÍFICOS'
  SELECT texto INTO v_alt_check FROM public.alternativas WHERE id = 1686 AND questao_id = 341;
  IF v_alt_check <> 'Tachado.' THEN
    RAISE EXCEPTION 'Assert 7c falhou: alternativa E da questão 341 ainda contém resíduo de cabeçalho';
  END IF;

  -- ID 492: Tabela de ocorrências formatada
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 492;
  IF v_enunciado_check NOT ILIKE '%=SOMA(B4:D4)%' OR v_enunciado_check ILIKE '%Figura 1 abaixo%' THEN
    RAISE EXCEPTION 'Assert 7d falhou: enunciado da questão 492 não contém a tabela formatada';
  END IF;

  -- ID 495: Tabela Calc e botões descritos
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 495;
  IF v_enunciado_check NOT ILIKE '%Formato numérico: moeda%' OR v_enunciado_check NOT ILIKE '%Inserir Anotação%' THEN
    RAISE EXCEPTION 'Assert 7e falhou: enunciado da questão 495 não contém a descrição dos botões';
  END IF;

  -- ID 791: Alternativas com nomes de ícones
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 791 AND texto LIKE '– %') > 0 THEN
    RAISE EXCEPTION 'Assert 7f falhou: alternativas da questão 791 ainda contêm travessão isolado sem ícone';
  END IF;

  -- ID 831: Símbolo de parágrafo ¶ presente
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 831;
  IF v_enunciado_check NOT ILIKE '%¶%' OR v_enunciado_check NOT ILIKE '%____________%' THEN
    RAISE EXCEPTION 'Assert 7g falhou: enunciado da questão 831 não contém a lacuna ou o símbolo ¶';
  END IF;

  -- Assert 8: Ausência de resíduos colados de OCR nos enunciados de linha única (60, 64, 338, 341, 493, 494, 496, 497, 791, 831)
  IF (SELECT count(*) FROM public.questoes WHERE id IN (60, 64, 338, 341, 493, 494, 496, 497, 791, 831) AND (
        position(E'\\n' in enunciado) > 0 OR
        position('\\n' in enunciado) > 0 OR
        enunciado LIKE '%pode -se%'
     )) > 0 THEN
    RAISE EXCEPTION 'Assert 8 falhou: quebras de linha ou resíduos de OCR ainda detectados em enunciados';
  END IF;

  RAISE NOTICE 'TODOS OS 8 ASSERTS DA FASE 3A (INFORMÁTICA) PASSARAM COM SUCESSO!';
END $$;

${mode === 'rollback' ? 'ROLLBACK;' : 'COMMIT;'}`;
}

const harnessSql = body('rollback');
const applySql = body('apply');

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Arquivos gerados com sucesso:`);
console.log(` - ${HARNESS_OUT_PATH}`);
console.log(` - ${APPLY_OUT_PATH}`);
