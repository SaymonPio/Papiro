-- PC-RS 2025 Escrivão e Inspetor de Polícia (Fundatec, concurso 993; Concurso Público nº 02/2025) — REGISTRO SANITIZADO
-- do lote aplicado em 2026-10-25. Escrivão e Inspetor fazem a MESMA prova (um único registro de prova, duas partes).
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (manutencao_pcrs_2025_escrivao_taxonomia.sql): matérias 39 Contabilidade, 40 Estatística; assuntos 381–394;
--   2. executor de aquisição P1, manifesto dc6567f320b21f6459d13ed10ecd20e525438e88bc06274ac41ffbb79a1dcecf, BASE_GLOBAL:
--      provas.id = 34 (hash_prova d42fcf2635e3…), prova_partes P1 = 4, prova_documentos GABARITO = 33
--      (Edital nº 14/2026, Anexo II, sha256 e9553c4aeb30…, bloco TIPO 1); 16 novas, 80 alternativas;
--   3. executor P2, manifesto c3b893b100e4409c86606bd263648ce7d1654581867ea373ba2a4714c9148a4b (replanejado contra o banco DEPOIS da P1: prova
--      EXISTENTE, documento JA_REGISTRADO): prova_partes P2 = 5; 44 novas, 220 alternativas;
--   4. qualificação dos 30 legados TEC (script com texto integral, fora do repositório; rollback-testado): prova_id/
--      prova_parte_id/numero_original/fonte/concurso + enunciado oficial em 20 (12 só espaço, 2 aspas, 6 adaptados com
--      explicação auditada compatível); 10 idênticos só proveniência; P2 Q15→641 alternativa E do legado preservada (só o
--      ponto final do PDF); alternativas, explicações, vínculos e histórico intactos.
-- Novas: ids 3810–3869 (60), sem curso_questoes, todas com matéria e assunto. P2 Q41 = representação POSICIONAL
--   (pos_check_pcrs_2025_escrivao_decisao_leitura_q41.sql); P2 Q25 com x² (expoente reconstruído, commit 0da2265).
-- Fora da prova: P1 6, 7, 9, 12, 28, 30 (sublinhado do PDF não preservado — revisão); P2 29, 60, 62 (anuladas pelo
--   Edital nº 14/2026; o legado 665 da Q60, inativo, intocado) e 38 (midia_ausente — revisão).
-- A P1 reaplicada judicialmente (Editais 59/72, caderno diferente) NÃO faz parte deste lote.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 90 questões e a prova continuam
-- exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, parte, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito) as (
values
  (3810, 'P1', 1, 'nova', 6, 15, 'e7eda5deb1e752068fb380ad0b08d257', '6fd5786dab75b5bbcf9326d9b418b21a', 'A'),
  (688, 'P1', 2, 'legado', 6, 53, 'e21abf466004df64584f96444e38937e', '01aab55f85c3f654e5dffb85588b04d0', 'E'),
  (3811, 'P1', 3, 'nova', 6, 47, '4876a3278642066545ce1c8a009bddee', 'ee893fcb5cc70e0c7d1679b5fee69823', 'B'),
  (3812, 'P1', 4, 'nova', 6, 5, '412d01949cf6be1c3ac6f0bf7ab316d0', 'b2a0732d74a474431f9a639099e4c1d3', 'D'),
  (3813, 'P1', 5, 'nova', 6, 50, 'bd1d43c50bbf07617dd1b32f5fa61f3c', '76295f4ceced2dae44a5c581f622e9f0', 'E'),
  (3814, 'P1', 8, 'nova', 6, 49, 'd5d6869cde0e6cda6fd54d513f32debd', '2037c469b33011c59c2438ba97624826', 'A'),
  (685, 'P1', 10, 'legado', 6, 45, '4fb119eed0c05711bf76e9a273406854', 'd86ca24379c3f4d4d02a47ae9c522ea2', 'D'),
  (686, 'P1', 11, 'legado', 6, 56, '5a99bfe49adb5e2ca5c1f680d461f0f9', '4b11bf62bcef6af4b61d290d258b2eb0', 'C'),
  (682, 'P1', 13, 'legado', 6, 47, '4f50600b9ebe04958d561eec98754d90', 'd7b69af13f074d7afb50e849056b6693', 'E'),
  (3815, 'P1', 14, 'nova', 6, 14, '6631208bb37e966cc151838b9ee323aa', '978780ca9dd8b5f2cc183319ad453acc', 'C'),
  (3816, 'P1', 15, 'nova', 6, 49, '5020dddabacf4f63bda67b99069eb13d', '7d41178faca466b79c6fcfba21780759', 'C'),
  (3817, 'P1', 16, 'nova', 6, 15, '7742418f19af54374c8e7c5df102f3db', 'a90a092b4451c54acae2027cf741ea7d', 'E'),
  (679, 'P1', 17, 'legado', 6, 44, '591177f6715e7ebcfdadd9bb9cacf4da', '7b1ca7d13dde1de25c4a1a69014a2b71', 'A'),
  (3818, 'P1', 18, 'nova', 6, 55, '569d5920d69d7cb3e631e50c8a46f1f3', 'b6c4b67371c1ed0ca60eabc77e208707', 'E'),
  (3819, 'P1', 19, 'nova', 6, 51, 'f076378a057e60540b5637ae8349c805', '68d299752d331897b56fd06ebf7ebdc0', 'B'),
  (3820, 'P1', 20, 'nova', 6, 49, 'f3ca37e98b5e76923460264d2bccfda3', '4b11bf62bcef6af4b61d290d258b2eb0', 'C'),
  (3821, 'P1', 21, 'nova', 6, 45, 'fa8140a285cbfbead3fc4f0301511b40', '75a7a6987bd21f99aeddeed22385fb2b', 'D'),
  (3822, 'P1', 22, 'nova', 6, 57, '53af282c164040bb6a90fc446b47e477', '34cfcb6feb6f19f3338e4365d9fba11c', 'D'),
  (687, 'P1', 23, 'legado', 6, 56, '0a88d563ca6445a4db12d17cf8dc5c77', '76e1ae1408ebaf3485bd37acefb2aa10', 'C'),
  (692, 'P1', 24, 'legado', 6, 54, 'ea13c471001e062ebce519738df6520e', '4f43568e08c674ad3bb4cd54f0969015', 'E'),
  (3823, 'P1', 25, 'nova', 6, 57, '281618381acd5cc23f0a55c06e8fffb6', '599ff4f3e791bfac1645bbe2283c98a0', 'B'),
  (3824, 'P1', 26, 'nova', 6, 47, 'cde0790e82fc2b4ada84ed6c6125bdeb', 'be64f2388fd2d639182193a9f194aad5', 'D'),
  (3825, 'P1', 27, 'nova', 6, 50, '4fd866a4ed584ab4a1bfdfcb9ef1a715', '844c056296024c54153035c519b0404a', 'B'),
  (683, 'P1', 29, 'legado', 6, 55, '242e88bef229fe7bbd786cfa64dfb0b4', 'af8832ea0c6f668cb2f00ca7876ce2ff', 'D'),
  (630, 'P2', 1, 'legado', 9, 62, '81f05feefdac59d64d9ffcc20487eb21', '9577e7eaa5e4846c7c3be639008f792b', 'E'),
  (631, 'P2', 2, 'legado', 9, 62, 'a89bd53e471dd91917b4f9ce9851b668', '41c4b97a6491e89c8f56f7e3d89f2d8a', 'B'),
  (632, 'P2', 3, 'legado', 9, 62, '4037d1b74b0546e00cd0308b95d3191c', 'f0ce6305b96ef4ed7e604e4dfc006e85', 'A'),
  (639, 'P2', 4, 'legado', 9, 10, '36cac44e1755d15f56b8126a659b5a4b', 'ed349a220653a413ada01e06e47041e0', 'D'),
  (3826, 'P2', 5, 'nova', 9, 390, '30fe8526a1a67b6d5083d6dc1555e74c', 'c59822d82fdc13e72d4cf9b05c0b1ac3', 'A'),
  (633, 'P2', 6, 'legado', 9, 62, '063597acbeed7f7db74e3eac39f28819', '56206f89089806cff8ab5da0764f0f87', 'C'),
  (643, 'P2', 7, 'legado', 9, 28, '8de1499ae8fc94c0b6d0fc6b7c7f40ce', 'c64f56d39961f9270f6357c5688cf3a9', 'C'),
  (634, 'P2', 8, 'legado', 9, 62, 'b46a702ba313c4d200f497f5bee3cbdf', 'b21c0c82b793c4f6b93f6ccc7b3126a5', 'E'),
  (627, 'P2', 9, 'legado', 9, 61, 'af9627ca511f17dc7f7ed6fb289d3530', '12c58600c4146badbdf3a7d76216eecc', 'D'),
  (637, 'P2', 10, 'legado', 9, 29, '740c300b56b9b01ff7d27e1176915acc', 'd6374e4b30ddb9740d5af0a910f5fc27', 'B'),
  (635, 'P2', 11, 'legado', 9, 60, '9c4b4c10be1b97258cd5aa4ee8f6c95c', 'a82f6c52ea25af5b479aaca6e7bfaacc', 'C'),
  (3827, 'P2', 12, 'nova', 9, 10, 'd602cff9b534b8cfe6a92584e7d0365f', '36d96fa6bfaa3fc04d0348da7d2a8e55', 'A'),
  (640, 'P2', 13, 'legado', 9, 10, '5851ea4a38c3d4abc04414dc98d4d87c', '4441fa944f4ec6342ff735f825f9cef3', 'D'),
  (3828, 'P2', 14, 'nova', 9, 10, '207c40caf86e5a66ad961c2955e012b4', '02d49acc45c692ced351fb6187c0a4ef', 'B'),
  (641, 'P2', 15, 'legado', 9, 10, 'ae2ece608bc8bec3206d54613ccff5ff', '994c4e7e70dc23c534773b718f981b54', 'E'),
  (3829, 'P2', 16, 'nova', 18, 183, 'dbc6a63aae0377e75872555714d59bb3', '64ef69a92b0d8a43108557efe2bb9666', 'A'),
  (3830, 'P2', 17, 'nova', 18, 31, '55adab67a3b333f6818f752d6e1575a1', '861383f5fa91de17e24efc4f7401b177', 'C'),
  (3831, 'P2', 18, 'nova', 18, 36, '3a94c10eea7d0ad07104b78607787a09', 'a1727ab8ac0606c1e37bc1999a07840f', 'D'),
  (3832, 'P2', 19, 'nova', 18, 38, 'd50d0a0f6cda88aa9cf4d2facc4881f6', 'ec58456b7931f3430d817031a1df74ed', 'C'),
  (3833, 'P2', 20, 'nova', 18, 35, 'bec8a900c1d8ca3e6dbde13001ccd509', '3c09262a1258e90b82734adfb0c3e447', 'A'),
  (3834, 'P2', 21, 'nova', 18, 37, '21e251a077ade3c20ae1d6be49f53954', '341bda9756acc67eae006907affed13c', 'B'),
  (3835, 'P2', 22, 'nova', 18, 39, '6b4bd98b0cac67deead81974bf3791eb', 'f12a1cd65fa08a16ab684f71725ea572', 'E'),
  (3836, 'P2', 23, 'nova', 18, 33, 'b102ff9b9e13e981239e8209b7238615', 'b37cb780597c600388ca290d5a7098b6', 'D'),
  (3837, 'P2', 24, 'nova', 18, 36, 'e39920e978fb457350cfcc7776b69fc6', '8adb1a3acb925af1299e38331ab6dec3', 'B'),
  (3838, 'P2', 25, 'nova', 18, 32, '660ce79bd1084598d9bfa73f6dbb92b5', '4dc67f835750959350ef064be3be8a08', 'E'),
  (3839, 'P2', 26, 'nova', 39, 381, '42485509b42764c93b97f1c6c8b5e5b0', '4dc67f835750959350ef064be3be8a08', 'E'),
  (3840, 'P2', 27, 'nova', 39, 382, 'fe19b51e4713d1eab7c35eea58242061', '10bb9c1acc83e1959e1818f34bcb3848', 'D'),
  (3841, 'P2', 28, 'nova', 39, 381, 'e20e82a17a75e3b89ce7be8cba925560', '8f647c915241be5ec07d1611b051494b', 'B'),
  (3842, 'P2', 30, 'nova', 39, 383, 'cdc2b2f79b0f042abc5a73a546eb91c2', 'd317ecaec3f173e3fca137c744bfba56', 'C'),
  (3843, 'P2', 31, 'nova', 39, 384, '76ed9d32218620d9e50163e24e1b33b4', 'df3e232b61cd6f5a3d2ec66a6ca54869', 'C'),
  (3844, 'P2', 32, 'nova', 39, 385, 'c70628d41a52514102a1c7cee55ae76b', '4dc67f835750959350ef064be3be8a08', 'E'),
  (3845, 'P2', 33, 'nova', 39, 384, '58573c3274c49c405cc45d90f8a61204', '8f647c915241be5ec07d1611b051494b', 'B'),
  (3846, 'P2', 34, 'nova', 40, 386, 'a28c0983226ec3c5d780357e7469e1ef', 'a26ae2e63866c0bcfa142830eacc6399', 'A'),
  (3847, 'P2', 35, 'nova', 40, 386, 'b6f5bb7d5795ea3e091749f533d1058c', 'a0e3e0995c9bc1fac36e0aca41f5a16e', 'E'),
  (3848, 'P2', 36, 'nova', 40, 387, 'b7a9eb0e74a921e18b152cc17d908fb9', '79f384b1ab5ef0ef84017756367a6a67', 'B'),
  (3849, 'P2', 37, 'nova', 40, 386, '897732886a23bee4afa2fb80bb15ea0f', '6d7c1bafb4a319f8c29f277f34d4edd3', 'D'),
  (3850, 'P2', 39, 'nova', 40, 386, 'e560cdce258d2a17c44a248341ed06cb', 'f1f23e2bc75f2ba8127f6ff15a3e8d90', 'C'),
  (3851, 'P2', 40, 'nova', 40, 388, '08519cc4b7f4845105ddd606fb9691bb', 'dfa8072a04ff936dccb31940fc6aa3e7', 'D'),
  (3852, 'P2', 41, 'nova', 40, 389, '280987515b1cecab136a00fe587afe2c', 'f578f4d355294ad4db6a2c9a9df5b707', 'C'),
  (664, 'P2', 42, 'legado', 10, 68, '371aeb1f4309946caaf157c2dc78c6e2', 'f2a6a5b6e45d8db8d95b53c53c2288f8', 'C'),
  (3853, 'P2', 43, 'nova', 5, 248, '74200174f085b2715ce7c2532e3a5a73', 'e01db6bfdbb273b82c6ad32d2d67e6d8', 'A'),
  (3854, 'P2', 44, 'nova', 5, 4, 'fe5685a058a61eae862bd2735ba2936e', '9d79b978c49d9c6572a9f19dd0ce4c7a', 'D'),
  (3855, 'P2', 45, 'nova', 8, 391, '9785039cb72c782b40b3cafadd35193c', '145f01f41bad0515ddeebb2e4147ff89', 'B'),
  (3856, 'P2', 46, 'nova', 8, 253, 'cdd432d39e16c0b33efcf2782722a668', 'f8332b1bc295bf883d58dd76744aed43', 'E'),
  (3857, 'P2', 47, 'nova', 7, 392, 'd22f34101f56c44d5849017a94a52b88', 'eb2ba551d78d7ca262a072a6fde87208', 'A'),
  (674, 'P2', 48, 'legado', 10, 78, 'd22f34101f56c44d5849017a94a52b88', '46ae24d47b5dc584b07ed7842492a121', 'B'),
  (3858, 'P2', 49, 'nova', 7, 179, 'ccbc4b3e9c7a133f53ae05bb5da6cae4', 'd317ecaec3f173e3fca137c744bfba56', 'C'),
  (3859, 'P2', 50, 'nova', 7, 257, '0c791a16cd6d33ad318de834835e0610', '3fcf4677fb3e33b6e2e690a33e4148e2', 'D'),
  (3860, 'P2', 51, 'nova', 7, 257, 'd22f34101f56c44d5849017a94a52b88', '9f97d2044334d47f7b17e8c46171c183', 'E'),
  (647, 'P2', 52, 'legado', 10, 70, 'b22bf7e48b6bc03d30456065f2f337d4', '69f87bb00811e1d57a87136b47cccb8f', 'A'),
  (3861, 'P2', 53, 'nova', 3, 140, '832d6d005d80c4edf93868de7f380a4f', '2c2f15a6d40f616f6554c3c20b94515c', 'B'),
  (657, 'P2', 54, 'legado', 10, 71, 'b4d8955ac1f5c2a8395c1d33060ed4b6', '32021c573b5ad5c251103ce15ce7630e', 'D'),
  (675, 'P2', 55, 'legado', 10, 17, '0c4e99ed81f87a2a9db5c0156622f986', 'b6c4b67371c1ed0ca60eabc77e208707', 'E'),
  (658, 'P2', 56, 'legado', 10, 71, '4ccba20bde92ccb287d5c3381aafe3a5', '88f597c9eccc296cee32b9e19ed1715d', 'C'),
  (3862, 'P2', 57, 'nova', 16, 262, '765b369b9b70fb37655da42b01403d26', '5d0c1c937e7fa7ff4955ccd8e2582e91', 'B'),
  (3863, 'P2', 58, 'nova', 16, 393, '6ada861b88883a6bac13dd42bc417476', '92ad26ea9e3060ba7f24e6cf5d86a207', 'E'),
  (646, 'P2', 59, 'legado', 10, 67, '4db57b793d360178a6b6b976527523be', 'a4c42c9fdf76c2df2b4b07f5b58eb5d3', 'D'),
  (3864, 'P2', 61, 'nova', 16, 261, '0e9c609f68fba917a7b144baae535c31', '6331851346b1c4ec29cd0e9e659f177a', 'C'),
  (623, 'P2', 63, 'legado', 11, 89, '8269553013ac847029b393a54c993210', '79cb5cfa6b603893233209da7ec313ec', 'B'),
  (670, 'P2', 64, 'legado', 10, 66, '0961257f3182676e4f298403773572ac', '29c1b18093b4bb69c9d7c72c47d3fc4e', 'D'),
  (625, 'P2', 65, 'legado', 11, 95, '0b006ff40229abb305e6313bbf16ef41', 'ae4ed0b2a0fea8914ea0ae7e694f727e', 'C'),
  (3865, 'P2', 66, 'nova', 11, 83, '34c7255dffcff4e9f7b93bbdd87d186a', '09a26309f8e5c273ff10a0099645903a', 'B'),
  (3866, 'P2', 67, 'nova', 16, 260, 'bb8e480e98f0ef187730fa26142edf52', 'd6b2115880382bf36bc694f86a44005d', 'A'),
  (3867, 'P2', 68, 'nova', 16, 181, 'a17aa1d679b173af71642efae50b57fe', '57e744f383d264bc4a48accaecdd4239', 'B'),
  (3868, 'P2', 69, 'nova', 16, 394, '6636315d2d981dcb302a0f7e1cd91856', '21f48033a4b7e7c572ed0f46bccef49c', 'C'),
  (3869, 'P2', 70, 'nova', 16, 260, 'c826d66d446f0d02a09911e2657f737e', '4ffc12d941ddb881e35210633535b900', 'A')
),
prova as (
  select id from public.provas where hash_prova = 'd42fcf2635e3b571d8c03b60088d39f25472305224e63bab99f14d4dc8b1dba0'
),
atual as (
  select q.id, q.prova_id, pp.codigo as parte, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, q.ativa, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
         (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos
    from public.questoes q left join public.prova_partes pp on pp.id = q.prova_parte_id
)
select e.parte, e.numero_original, e.questao_id, e.origem,
       (a.id is not null and a.prova_id = (select id from prova) and a.parte = e.parte and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id = e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa
        and (e.origem = 'legado' or a.vinculos = 0)) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.parte, e.numero_original;

with prova as (
  select id from public.provas where hash_prova = 'd42fcf2635e3b571d8c03b60088d39f25472305224e63bab99f14d4dc8b1dba0'
),
pp as (
  select q.*, p.codigo as parte from public.questoes q join public.prova_partes p on p.id = q.prova_parte_id where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 34, uma só prova para Escrivão e Inspetor (hash_prova d42fcf2635e3…)', (select count(*) = 1 from public.provas where hash_prova = 'd42fcf2635e3b571d8c03b60088d39f25472305224e63bab99f14d4dc8b1dba0') and (select id from prova) = 34),
  ('prova_partes: P1 = 4 (ordem 1) e P2 = 5 (ordem 2), nenhuma outra', (select count(*) = 2 and bool_and((id = 4 and codigo = 'P1' and ordem = 1) or (id = 5 and codigo = 'P2' and ordem = 2)) from public.prova_partes where prova_id = (select id from prova))),
  ('prova_documentos: só o GABARITO do Edital nº 14/2026 (e9553c4aeb30…)', (select count(*) = 1 and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = 'e9553c4aeb30304dabddc0acaf50aaabac38e55f9466b7164bd3dfd079c33562') from public.prova_documentos d where d.prova_id = (select id from prova))
     and exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = 'e9553c4aeb30304dabddc0acaf50aaabac38e55f9466b7164bd3dfd079c33562')),
  ('P1: 24/30 (16 novas + 8 legados), fora 6, 7, 9, 12, 28, 30', (select count(*) = 24 and count(distinct numero_original) = 24 and bool_and(numero_original not in (6, 7, 9, 12, 28, 30)) from pp where parte = 'P1')),
  ('P2: 66/70 (44 novas + 22 legados), fora 29, 38, 60, 62', (select count(*) = 66 and count(distinct numero_original) = 66 and bool_and(numero_original not in (29, 38, 60, 62)) from pp where parte = 'P2')),
  ('nenhuma questão da prova sem parte', not exists (select 1 from public.questoes where prova_id = (select id from prova) and prova_parte_id is null)),
  ('60 novas = ids 3810–3869, sem curso_questoes, todas com matéria e assunto', (select count(*) = 60 and bool_and(materia_id is not null and assunto_id is not null) from public.questoes where id between 3810 and 3869 and prova_id = (select id from prova))
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3810 and 3869)),
  ('30 legados qualificados com 1 vínculo de curso cada (preservado)', (select count(*) = 30 and bool_and((select count(*) from public.curso_questoes cq where cq.questao_id = pp.id) = 1) from pp where id in (688, 685, 686, 682, 679, 687, 692, 683, 630, 631, 632, 639, 633, 643, 634, 627, 637, 635, 640, 641, 664, 674, 647, 657, 675, 658, 646, 623, 670, 625))),
  ('legado 665 (Q60 anulada) e falsos positivos 1940, 2039, 3337, 1991, 310 intocados', (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q where q.id in (665, 1940, 2039, 3337, 1991, 310)) = '8fcbdec8656e9743835b502e4079d2b7'
     and exists (select 1 from public.questoes where id = 665 and prova_id is null and ativa = false)),
  ('taxonomia 39/40 e 381–394 presente', (select count(*) = 2 from public.materias where id in (39, 40)) and (select count(*) = 14 from public.assuntos where id between 381 and 394)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pp)))
) v(verificacao, ok);
