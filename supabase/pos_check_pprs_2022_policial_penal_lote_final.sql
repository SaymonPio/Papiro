-- PP-RS 2022 Policial Penal (Fundatec, concurso 650, caderno 0650.002 — SUSEPE/RS nº 01/2022) — REGISTRO
-- SANITIZADO do lote aplicado em 2026-10-24. 75/80 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) taxonomia (assuntos 311–318) — ver supabase/manutencao_pprs_2022_taxonomia.sql;
--   1) executor de aquisição, manifesto ca5596cd5dba427cc8d0c19c0974cbc6af455e69f3d5a2d5a22adafdc12859e9,
--      modo BASE_GLOBAL: provas.id = 23 (hash_prova b1b48be41ed1…);
--      prova_documentos: GABARITO = página HTML oficial "Gabaritos Definitivos" (sha256 111fcbb72022…;
--      o TXT derivado deterministicamente para o importador, e4461e3b3c7e…, NÃO é documento oficial) e
--      RETIFICACAO = Ed. 20/2022 (954dfcacb947…, anula a Q22);
--      42 questões novas (ids 3398–3439), 210 alternativas, nenhum curso_questoes; liberações explícitas com
--      conteudo_hash: DEDUP_OK Q2 (≠761), Q18 (≠893), Q39 (≠2974), Q77 (≠78); EXTRACAO_OK Q15 e Q29;
--      Q29 com 1 mídia (questao_midias.id = 8, FIGURA 487x304, p. 9, OFICIAL_PROVA, sha256 c8836c8f02e520be3fbc04267dc1471ce656b94f94d640dbfe57f1bc8974cd83);
--   2) qualificação do legado (script operacional com texto integral FORA do repositório): 33 registros
--      receberam prova_id, numero_original e fonte/concurso oficiais, preservando id, alternativas, gabarito,
--      matéria, assunto, explicação, ativa, vínculos e histórico; enunciado trocado pelo oficial onde a diferença
--      era só de espaço ou o TEC adaptou com explicação auditada COMPATÍVEL; Q78→82 TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA
--      (aspa invertida no PDF) — enunciado correto do legado preservado; Q14→887 com débito
--      EXPLICACAO_EDITORIAL_PPRS2022_Q14_887 (explicação não editada).
-- Fora da prova: Q22 e Q24 anuladas; Q26 (figura), Q37 (REVISAO_CANONICO_PP_RS_2022_Q37) e Q75 (tabela-verdade) em revisão.
-- Registros intocados (verificação 9): 89, 92, 102, 105, 130, 133, 499, 816, 832, 836, 852, 864, 865.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 75 questões e os registros
-- intocados continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, midias, legado_qualificado, md5_enunciado_antes, md5_explicacao) as (
values
  (892, 1, 6, 53, '74c52a620f2c87873e34e53ced6012fb', '13b8ab28510e4ac21da258a6aec04958', 'C', true, 1, 0, true, '72e3dcc39c26083ac3b18a3c20dbe6df', 'dc5b90b377e574be362568ec8da6769c'),
  (3398, 2, 6, 5, '277f49af7ade1230d8bb816fbe68fd2e', '13122c0d11292b9f2d33bc4382ff0871', 'A', true, 0, 0, false, null, null),
  (3399, 3, 6, 47, 'd1a45c0ed03d906cc0a69e04574340e1', 'b6c4b67371c1ed0ca60eabc77e208707', 'E', true, 0, 0, false, null, null),
  (3400, 4, 6, 49, '853d46a82f6b74cdc7b5c9573b2131af', 'bfbd58ed0c0d3aad273045f6e0513e23', 'B', true, 0, 0, false, null, null),
  (3401, 5, 6, 51, 'b91e3988cf508835f9350c1dc51af4e4', '977ae9440060a1babbe086b7c4c92f05', 'B', true, 0, 0, false, null, null),
  (3402, 6, 6, 49, '997ead674de3501286b4ea2d5433d7c2', '45bfa82a9ecd10f8b3dadc0799612b16', 'B', true, 0, 0, false, null, null),
  (3403, 7, 6, 57, '4eb61adc97fdb7cf9ac51fd074064cb3', '5ab486aff6ac9cb4bd529f854e95584d', 'C', true, 0, 0, false, null, null),
  (3404, 8, 6, 15, 'd2345edabfc3ef7d3e128c147c8b1a5d', 'e4169ad3f8908d443145d5b9acc148ba', 'A', true, 0, 0, false, null, null),
  (3405, 9, 6, 55, '648caf6d9a975392782309c6b1028776', '7d41178faca466b79c6fcfba21780759', 'C', true, 0, 0, false, null, null),
  (3406, 10, 6, 14, '24101a2e2dd239dce6b59c3b943462a5', 'a6dbba2de4e5fe00ec7962e8a9d1d7aa', 'D', true, 0, 0, false, null, null),
  (875, 11, 6, 44, 'be2a8d73c37322009da16966871a27fc', 'ec2a9af8ac40577f7de34fa2869a2fb4', 'C', true, 1, 0, true, 'a7ed6d481d3d164d596fa297db97fafe', '8a8ce8f60dd8395280ca6dc5922057fd'),
  (879, 12, 6, 47, '45bd196b746af2e9638c6ff4752255d7', 'b6c4b67371c1ed0ca60eabc77e208707', 'E', true, 1, 0, true, '0e643d350465c9f59975446a3f228e40', '46e7b07376cda06a4c120e8e5108834a'),
  (3407, 13, 6, 48, '45183e8ee8b67902abb0fe555f4663d6', 'be64f2388fd2d639182193a9f194aad5', 'D', true, 0, 0, false, null, null),
  (887, 14, 6, 56, '109c36b08be683cca199c9c0924342db', 'fc309093f5048ae638bc024697726799', 'A', true, 1, 0, true, 'c887ef68c4d5818703b58bbf5e09bc23', '1479703a0a2a55afbb6981ab14e287b6'),
  (3408, 15, 6, 54, '55de70885b87ae70fd774090a4fbc685', '06228ed2234572ecf5a704721f4d1176', 'B', true, 0, 0, false, null, null),
  (3409, 16, 6, 59, '51dabdd2a9a47d93cf6b79f2890e8426', '48d61d95393c964567988bf2a996fcc8', 'C', true, 0, 0, false, null, null),
  (3410, 17, 6, 50, '76d0a53d96ec0b3876b23073b471e0e8', 'c6c4c4a4ed9024c072bac00a1c3a8715', 'E', true, 0, 0, false, null, null),
  (3411, 18, 6, 47, '26c53144ac0ebc060cbc690a9dfaf0a8', '58494620f577504941c124a51dbb5383', 'E', true, 0, 0, false, null, null),
  (3412, 19, 6, 15, '69d59cd05ae9d3a2b3f3b9291cef3ca6', '1ff1f37adf15020513766be88e0d9c74', 'D', true, 0, 0, false, null, null),
  (3413, 20, 6, 15, 'fef1319cc2cd7e4b8e046e4dfc99f2c3', '456dd0424de2436cfe4cc17628dd10ac', 'A', true, 0, 0, false, null, null),
  (101, 21, 9, 28, '73d6e8421ec67a6cfaf780b309a1ccb2', 'bb5344a26d1be19a16945c40efa5418b', 'B', true, 1, 0, true, '28ef4656480d17530eef879f4d9e4643', 'e10da4b1436e063b782a12dc705feab2'),
  (91, 23, 9, 61, '0c57ad7ee59d506754b7e672b44ea19e', '50787aaef6c8bd382c24a131f828c13c', 'C', true, 1, 0, true, '0c57ad7ee59d506754b7e672b44ea19e', 'aa3e9ef391960ec46263499127ac3388'),
  (93, 25, 9, 29, '94b4f4981d1b09e8712bd53dd1f60dd2', 'bcc17899075d64a141d183015e894dd0', 'C', true, 1, 0, true, '9c8ffa97599ce29b73f55390e557544b', 'e610f538bffafb42333b8abc54073361'),
  (94, 27, 9, 62, '9520666cb7928966677d60e781144bd0', 'cb74e52e1a58440bbf4fbee90bfe206d', 'A', true, 1, 0, true, '9520666cb7928966677d60e781144bd0', 'cb66693bcbab1922dc60390012ea6941'),
  (95, 28, 9, 60, '4337d33a4c1e32e44a63effa8f44ab05', '68366ffad14b441e9a405488abda53d0', 'E', true, 1, 0, true, '765eb963049af71a5d849cfd381e3ccf', 'f45246ddcfd8ddf750db17d1e60bfa3b'),
  (3414, 29, 9, 62, '568913e15aa8cd8cefd8b0a2a9b11d2e', '66163525041f1c94e364b1cdec4a0d6f', 'E', true, 0, 1, false, null, null),
  (830, 30, 9, 60, 'd7d50b06dd7bc1ec1952f0a1e1f32276', '92e45c233b699e4e994cbed76c296f29', 'A', true, 1, 0, true, '6fabace097c11651202ae6f121133118', '8662c7ed03a4f16153102822b9016550'),
  (129, 31, 10, 19, '27b0c074a6ec277f783b7a0273c610f3', 'af8832ea0c6f668cb2f00ca7876ce2ff', 'D', true, 1, 0, true, 'a4b97b5d7620daded151ee5c16758909', '9548f14d798b930200980fa4b61fa793'),
  (3415, 32, 8, 142, 'e381d8395413c7eddb7041cfd241e930', '24e4d7ad0b8b760fee3f3bc17e306fa7', 'D', true, 0, 0, false, null, null),
  (822, 33, 11, 90, '3fd2bf4c895e6b47c68fc705e861d672', '7f69b902216f0ee005ebf23de917a87c', 'B', true, 1, 0, true, '26be3ba61bfc6d7f9e2ceba5aec7be1a', '784edd5472ea6b1256edefe754ff8a31'),
  (3416, 34, 16, 181, 'a96fad24185ebe8b1ae87d3f58b9df18', 'a90824a2f2c746b055c0152c56649106', 'A', true, 0, 0, false, null, null),
  (131, 35, 11, 98, 'd601d34144a075b5899045c3915763e4', '3a1366ac2e9837e5edbd4e176c7b2227', 'D', true, 1, 0, true, '48b635c0cb940252f7546385924b3813', 'a689773ff6b4d295c10833ab72842c86'),
  (132, 36, 10, 63, '96ac02e3ef5088b516ba18d78273a43f', 'b41dd254e345d6d41a14bb15f561cf99', 'D', true, 1, 0, true, 'f1215beef87fc50f45a1ee2a01edebc5', '3c6ed790acf9a685b898b0a860ec40cd'),
  (3417, 38, 7, 257, 'd761bd0ca42e00eaa7b12b01cc1caf81', '107ef1b8058e6188cc6c345ee70856d9', 'A', true, 0, 0, false, null, null),
  (3418, 39, 25, 314, '2f37ab2efb4c7a1fe86d544d18e43c17', '779355ddff95100c35c3c84fe22e23a5', 'B', true, 0, 0, false, null, null),
  (828, 40, 11, 27, 'e91c7783be2616bcf0f26b7800620d79', 'a63824fe59aa96b8a57c589edc6608df', 'E', true, 1, 0, true, '727d14617491d3124204308264fe660b', '9717bae00c03442bcfb530f3f794b19b'),
  (3419, 41, 11, 301, '050110daf5f7bc718cfe47d0e001fc3a', 'c65847b5a6916c7c8cd9a54579737c49', 'B', true, 0, 0, false, null, null),
  (858, 42, 10, 64, '4dc61b375283583acfdb562cacca6781', '47f8bbc5ab551c540ea86043b8dcf066', 'C', true, 1, 0, true, '333f1a7911494558cacb9996c2123b2f', '8b9b0f1205f8fd621e818ad2311a8b1c'),
  (854, 43, 10, 68, '2d9c7181a68c86b3cf7285fa45f9b6eb', 'c86ed6ca3e1c3440b4fd606659733d61', 'C', true, 1, 0, true, '3fe2d569c7288f86f31d10032303584d', 'eee82e916a65c007c0ca6e0d320ed8f5'),
  (817, 44, 11, 102, 'e9b6e076ab6b20f404f6cc3180a08e09', '71b855dec363953d4ee3601de108be98', 'C', true, 1, 0, true, 'ad4586695547e509b91ae6748b380213', '326926dadde333b3b3f54573e302332c'),
  (849, 45, 10, 71, 'ea4e3ad238250c3d589440a9ca17c339', 'e0f31653f4cda16bb634de069cfa8cea', 'A', true, 0, 0, true, 'e9a7f7a6388aa94f19945756bc3c0598', '2531d2c3e49f0eb90736f309f7800411'),
  (3420, 46, 11, 317, 'dee625463450cb42c6a2f74f672d1c32', 'b414d2151b4752c96007466d0d1ad0f2', 'E', true, 0, 0, false, null, null),
  (3421, 47, 11, 318, '532645f38bce25134022cbb2266357d7', '79590619598f3d08b4524d17229091bb', 'D', true, 0, 0, false, null, null),
  (870, 48, 10, 78, '17c69b934df26d2f7ed73d82897d360e', 'a8de8f624b4bcf5e97daf912738b46b3', 'A', true, 1, 0, true, '17c69b934df26d2f7ed73d82897d360e', '420d242870c20401344fe9d9c37b726e'),
  (3422, 49, 26, 316, '89b2e622188bd7e535582b6aacabafab', '95469c528883b86702ff63e82d0ec211', 'B', true, 0, 0, false, null, null),
  (829, 50, 11, 27, '1edbcb8a7d35fd73f5da6d75bcd1c138', 'a63824fe59aa96b8a57c589edc6608df', 'E', true, 1, 0, true, 'bf9797a43288e5b8e4b8586fd34a9915', 'dc57d5a032db2b22400755c666d01f56'),
  (3423, 51, 8, 142, '73313758ef54782915ef5a02f3a5d1ab', '9f6ef209cc6b3cba2519681999137907', 'E', true, 0, 0, false, null, null),
  (866, 52, 10, 19, '63ea204ae8bc442b41fea598970d3d11', '0bcefb782794cf53bab0fbc343f11cb2', 'C', true, 1, 0, true, 'cbeb56a57bc27f1bc48e5735c6bb9a26', 'e9fbfc86ef0c4e3a04ae66ad70b0f03e'),
  (3424, 53, 7, 257, '929c0d6309731e30aefebc8b1597f564', '5a9a6e2d25d0d12c032318ed22e70b34', 'E', true, 0, 0, false, null, null),
  (3425, 54, 25, 315, '0b215be54c4710392646f7bc1480f1d0', '4653cd0eba6622b77ec20651f620a2ce', 'D', true, 0, 0, false, null, null),
  (3426, 55, 11, 301, '85fde45365a76da80a9b671f8af3af49', 'c434f4911cb768c582ca308c59de8d8e', 'C', true, 0, 0, false, null, null),
  (859, 56, 10, 64, 'b11b360e9802436ac913d79c0a4451cb', '5a674e4bbeeb42c3f0ec50979a656bc4', 'B', true, 1, 0, true, 'b11b360e9802436ac913d79c0a4451cb', '92bb9d4977cfd4d9b120321d02424b87'),
  (3427, 57, 5, 250, 'e34c6da8f9b6e54fbd3ac63f74e77d93', 'b324ec18e7175871c9e3e4fc07749de8', 'D', true, 0, 0, false, null, null),
  (818, 58, 11, 102, '1a5e11439a307582c2e97d40376e478f', 'c8c615e48026db77ab2cf2a31f848bc9', 'A', true, 1, 0, true, 'd54261a6bc9820aad72fa0e5ab32b177', '02bcc425e9f6a3e59cfc241ad4337416'),
  (855, 59, 10, 68, '6aee76fcc7a42308feea20dc33b6fec4', 'ee9307efafc3f242135a7159bad1eea5', 'A', true, 1, 0, true, '6aee76fcc7a42308feea20dc33b6fec4', '83fefb3744f3807c659c20ea34aee343'),
  (3428, 60, 5, 4, 'bd9499e678fb921f17faba7a617d81cc', '3dfe707765a7a5f3a92fe04a4fa103e7', 'D', true, 0, 0, false, null, null),
  (3429, 61, 13, 311, 'a0e961233e2b2b02d52343da489fe7f7', 'ceb4ba14c0a0b80791e3868e23619085', 'B', true, 0, 0, false, null, null),
  (3430, 62, 13, 311, '026b8541c97048b97a5e4940153db16d', 'a9739a7ceb2373db217845cb16f5de07', 'A', true, 0, 0, false, null, null),
  (3431, 63, 13, 311, 'fe10616234b8b4299e6f9d68dfe0597d', 'c496be6209be90a65cc785c770d313f8', 'A', true, 0, 0, false, null, null),
  (3432, 64, 13, 311, '72196f1b83284e5c02ec906eaa3e048c', '8a2904a1ced48762bd5ad1bcfb93d5bd', 'D', true, 0, 0, false, null, null),
  (3433, 65, 13, 313, '40ba34518340473fcf5fd1e08cdcadbc', '781aa52ad74e0109e2d711346b6d3eb6', 'C', true, 0, 0, false, null, null),
  (3434, 66, 13, 312, 'fe7acc712abcf93800acdc3d5d1d5551', '8f647c915241be5ec07d1611b051494b', 'B', true, 0, 0, false, null, null),
  (3435, 67, 13, 311, '86b7de668d95c1610fccccbd6dd2c1f9', 'd0048143aec14824bf6dbfde071df6a1', 'C', true, 0, 0, false, null, null),
  (3436, 68, 13, 311, 'ad95765fb9ef79ed7990110d8155d84c', '64c3f32e4a90002d0c151ca2faea4b8f', 'B', true, 0, 0, false, null, null),
  (3437, 69, 13, 311, '60f543f083812f9934d89c60c2445c66', 'f86d83370debbc23a8c97ac8ab71e2b3', 'E', true, 0, 0, false, null, null),
  (3438, 70, 13, 311, '5a9495423caf5b1e46851a433bc4d54b', 'bbae530424945ea9746daf95872743bf', 'E', true, 0, 0, false, null, null),
  (85, 71, 18, 37, '70b6b89a466dab21256d378a92d180b3', '0f16868d53a5b6fb9a5912312066765b', 'E', true, 1, 0, true, '70b6b89a466dab21256d378a92d180b3', 'd2ce9111afd8c1015091e55b3485b0b1'),
  (86, 72, 18, 35, '6a0a5318bf0f8c82875b570feebec3d0', '97e78ab5e90cff7bb79b5080460a03e6', 'B', true, 1, 0, true, '6a0a5318bf0f8c82875b570feebec3d0', '80a3cdb26c910c48158568ff1e479c27'),
  (87, 73, 18, 36, '427f773baf97919946de3032b8a68266', '6dbb067b33a08da59b790ffb27e1bea6', 'E', true, 1, 0, true, 'b1926f208fb65274a08c6b93cde09ecd', '33429b83ccb382303070bfbe0c203a0d'),
  (88, 74, 18, 35, '77383d2797e37837ca3eb394ab020eec', '00b1f17a96dc77c3695aca7457c9d150', 'B', true, 1, 0, true, '77383d2797e37837ca3eb394ab020eec', '1ea8ff90afb8df453715d58e9f0c8cda'),
  (90, 76, 18, 40, 'a19398aea4b3633e66792752792c2449', 'ec57075df01d8c313197e7cb6610f9dd', 'D', true, 1, 0, true, '6bb9c64106284a76e7511ae0ab730e13', '9d6b70fc3e08980a76ddd2dc8ca2b96d'),
  (3439, 77, 18, 32, '49231c6b885974232951b9d6b734b87c', 'c6941e744760dcbb75390996e7895fda', 'A', true, 0, 0, false, null, null),
  (82, 78, 18, 41, '57125cec6e0a00a32920a9bbafef38c9', 'c610187c8f02f05ddadd4ba56056611f', 'C', true, 1, 0, true, '57125cec6e0a00a32920a9bbafef38c9', 'bf11e064ba4911848e5b4f348b18a966'),
  (83, 79, 18, 33, 'e4ca25797a7ab0181eae911828fd65f1', '87032da174dd4a252290826ab870d9e9', 'A', true, 1, 0, true, 'f4d03eb44ba498c9d03905f4e560b1d8', '04d5cd5e2f9bc3bdc89407979c185128'),
  (84, 80, 18, 36, '481f3c4bfcc9f5246c133017fb70dcfb', '7fc75ec8abd7d892fc9cd34dbef3061f', 'C', true, 1, 0, true, '481f3c4bfcc9f5246c133017fb70dcfb', 'd6894fb308ec0fcb3c4852e2a74fae4b')
),
prova as (
  select id from public.provas where hash_prova = 'b1b48be41ed192944b535b3fecddf9909e87f26567b9f1546ad3515c3abde9dc'
),
atual as (
  select q.id, q.prova_id, q.prova_parte_id, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, q.ativa, md5(q.enunciado) as md5_enunciado, md5(coalesce(q.explicacao,'')) as md5_explicacao,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
         (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos,
         (select count(*) from public.questao_midias m where m.questao_id = q.id) as midias
    from public.questoes q
)
select e.numero_original, e.questao_id, e.legado_qualificado,
       (a.id is not null and a.prova_id = (select id from prova) and a.prova_parte_id is null and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id is not distinct from e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa = e.ativa and a.vinculos = e.vinculos and a.midias = e.midias
        and (not e.legado_qualificado or a.md5_explicacao = e.md5_explicacao)) as ok,
       e.legado_qualificado and e.md5_enunciado_antes <> e.md5_enunciado as enunciado_substituido
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = 'b1b48be41ed192944b535b3fecddf9909e87f26567b9f1546ad3515c3abde9dc'
),
pp as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
),
intocado (questao_id, md5_enunciado, md5_explicacao, ativa, md5_alternativas) as (
values
  (89, '3918237b5d0b9a1fa0b36f8e2daa4467', '5fa68bb6ff416057eaa070b00aaae2ce', true, '7d52ef34c62bf1843201254e21a28d96'),
  (92, '3d682c081c9c9416f0c0b94f071db15a', 'efd358309b9bf12310b24b0acece3525', true, '581823c3ce6c61144c93cc5721fa45b9'),
  (102, '33cda716efd352de7b8a8791d99f5ed8', '046ca60e322fa38d1d4843534215b44b', true, '4279381b227e150c1607ae956e7e20c4'),
  (105, '30e95339aab64a97dd3f0a8851ec571f', '6a0ad9fc98e199acc19585188bfbf3a2', true, '1c70c68570d6e0ea4f96d89f4afcd073'),
  (130, '6fbfc4594f9971ee224f13ecdd63b0ad', 'bb257514cb8c9afc52ceb2c2d843b3cf', true, '6c9a66f89ba5fe356e3337c4b5618e18'),
  (133, 'ebe5fa60ac80df5395ab24d3f413aae6', 'e38aaef648c6131cf0c492e7be698f31', true, 'aa0a0d196da5818391ad8f729fc839a1'),
  (499, '8590638297e44d6feeb3eda1c580756c', '7e02b21a378d336a87d75e299a93df32', true, '9b182ba511a6c61455a548f9264e67aa'),
  (816, 'c3be411c6b0398453dd701211aa69f90', '9651a89b1bd2f66828dc85c01c13e61a', true, '713ab7ab9158c5662268ad216cf423a2'),
  (832, '01bf9eaa928da612a8c75874d57f865b', 'ad18c11bf3113998e5261921be66662a', true, '45836e76e0e010f8a3596c7d0a9b6d57'),
  (836, 'fb0be7a0f569c8133c420f85a8ca8067', '4146fc42b2f3af403e92f3348f7712ca', true, 'dc37b443a6f4a86587d827f1ab21c9f1'),
  (852, '41f4fc2dd7ae06f02016e7ca471fadf0', '3c6ed790acf9a685b898b0a860ec40cd', true, 'fb4d3260c282701ce5938812ab48adf9'),
  (864, '64ffc68e337078074896c6fcf9f4d9a1', '9548f14d798b930200980fa4b61fa793', false, 'f7be2e3e8aa67f301c7704b020956b5a'),
  (865, 'b29f8cf4244f89892a66ee32de028cbf', 'e38aaef648c6131cf0c492e7be698f31', false, '8d98f6c4f025355f1dda846e7a521308')
)
select verificacao, ok from (values
  ('prova_id = 23 (hash_prova b1b48be41ed1…; manifesto ca5596cd5dba…)', (select id from prova) = 23),
  ('prova_documentos: GABARITO = HTML oficial 111fcbb72022… e RETIFICACAO Ed. 20/2022 954dfcacb947…', (select count(*) = 2
     and bool_or(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '111fcbb7202212317be1c88cdde9f9a5bc167ed6258a9adc0d9f12a165a545f3')
     and bool_or(d.tipo = 'RETIFICACAO' and d.ordem = 1 and d.hash_sha256 = '954dfcacb94719d0c1a2635bc1763b0050bff743b20c3dc3dfaee608e6007f46') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('provas.hash_gabarito = HTML oficial (o TXT derivado não é registrado como documento)', exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = '111fcbb7202212317be1c88cdde9f9a5bc167ed6258a9adc0d9f12a165a545f3')),
  ('75/80 oficiais na prova, números distintos, sem parte', (select count(*) = 75 and count(distinct numero_original) = 75 and bool_and(prova_parte_id is null) from pp)),
  ('42 novas = ids 3398–3439, sem curso_questoes, todas com assunto', (select count(*) = 42 and bool_and(assunto_id is not null) from pp where id between 3398 and 3439)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3398 and 3439)),
  ('33 legados qualificados (prova/número)', (select count(*) = 33 from pp where (id, numero_original) in ((892, 1), (875, 11), (879, 12), (887, 14), (101, 21), (91, 23), (93, 25), (94, 27), (95, 28), (830, 30), (129, 31), (822, 33), (131, 35), (132, 36), (828, 40), (858, 42), (854, 43), (817, 44), (849, 45), (870, 48), (829, 50), (866, 52), (859, 56), (818, 58), (855, 59), (85, 71), (86, 72), (87, 73), (88, 74), (90, 76), (82, 78), (83, 79), (84, 80)))),
  ('fora da prova: 22, 24 (anuladas), 26, 37, 75 (revisão)', not exists (select 1 from pp where numero_original in (22, 24, 26, 37, 75))),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('registros intocados (102/92, Q26/Q37/Q75, duplos não escolhidos): sem prova, enunciado/explicação/alternativas/ativa iguais', (select count(*) = 13 from intocado t join public.questoes q on q.id = t.questao_id
     where q.prova_id is null and q.numero_original is null and md5(q.enunciado) = t.md5_enunciado and md5(coalesce(q.explicacao,'')) = t.md5_explicacao and q.ativa = t.ativa
       and (select md5(string_agg(a.id::text || ':' || a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = t.md5_alternativas)),
  ('mídia só na Q29: FIGURA 487x304, p. 9, OFICIAL_PROVA, antes da legenda, sha256 c8836c8f02e5…', (select count(*) = 1 from public.questao_midias m where m.questao_id in (select id from pp))
     and exists (select 1 from public.questao_midias m where m.id = 8 and m.questao_id = 3414 and m.prova_id = (select id from prova) and m.ordem = 1 and m.tipo = 'FIGURA'
       and m.sha256 = 'c8836c8f02e520be3fbc04267dc1471ce656b94f94d640dbfe57f1bc8974cd83' and m.mime_type = 'image/png' and m.storage_path = 'questoes/c8836c8f02e520be3fbc04267dc1471ce656b94f94d640dbfe57f1bc8974cd83.png'
       and m.largura = 487 and m.altura = 304 and m.pagina_origem = 9 and md5(m.ancora_texto) = '43c896bc963ec6d06e612f6fd89cd8ca' and m.direito_uso = 'OFICIAL_PROVA')),
  ('objeto da mídia no Storage', exists (select 1 from storage.objects o where o.name = 'questoes/c8836c8f02e520be3fbc04267dc1471ce656b94f94d640dbfe57f1bc8974cd83.png'))
) v(verificacao, ok);
