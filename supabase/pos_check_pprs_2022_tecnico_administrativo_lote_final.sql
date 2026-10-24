-- PP-RS 2022 Técnico Administrativo (Fundatec, concurso 650, caderno 0650.001 — SUSEPE/RS nº 01/2022) — REGISTRO
-- SANITIZADO do lote aplicado em 2026-10-24. 72/80 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) taxonomia (assuntos 322–324) — ver supabase/manutencao_pprs_2022_tecnico_taxonomia.sql;
--   1) executor de aquisição, manifesto 4e803c15835686f3e68a89417854981d114507fbebea77bb6f404d568932a2b4,
--      modo BASE_GLOBAL: provas.id = 25 (hash_prova c4918b974a0f…);
--      prova_documentos: GABARITO = página HTML oficial "Gabaritos Definitivos", cargo 1 (sha256 f6404c00bd01…;
--      o TXT derivado deterministicamente para o importador, 41fc8868e59f…, NÃO é documento oficial);
--      sem retificação aplicável e sem anuladas;
--      39 questões novas (ids 3479–3517), 195 alternativas, nenhum curso_questoes; liberações explícitas com
--      conteudo_hash: DEDUP_OK Q15 (≠688), Q16 (≠3400), Q34 (≠3417), Q42 (≠3420);
--      Q21 com 1 mídia (questao_midias.id = 10, FIGURA 587x298, p. 7, OFICIAL_PROVA, sha256 d8ea0e3923c72f07bd28873f90e56b721b9d1bc0cf945d2ba375110c82663ca6);
--   2) qualificação do legado (script operacional com texto integral FORA do repositório; lista lida de
--      reconciliacao.json): 33 registros receberam prova_id, numero_original e fonte/concurso oficiais,
--      preservando id, alternativas, gabarito, matéria, assunto, explicação, ativa, vínculos e histórico; enunciado
--      trocado pelo oficial onde a diferença era só de espaço ou o TEC adaptou com explicação auditada COMPATÍVEL;
--      Q44→853 (literal; 142 intocado); TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA, decisões individuais:
--      Q49→145 (alternativa E) e Q76→81 (alternativa D) — texto saneado do legado preservado, só proveniência.
-- Fora da prova: novas Q10 (grifo perdido) e Q79 (DEBITO_PARSER_POSSE_MIDIA_ENTRE_QUESTOES); legados em revisão
-- Q26, Q28, Q32 (REVISAO_CANONICO_PPRS2022_TEC_Q32), Q72, Q78, Q80.
-- Registros intocados (verificação 9): 75, 79, 135, 142, 246, 497, 498, 815, 827, 851, 857, 863, 869.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 75 questões e os registros
-- intocados continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, midias, legado_qualificado, md5_enunciado_antes, md5_explicacao) as (
values
  (891, 1, 6, 53, '7ce5d85f25d158b14426222fc227e3f8', 'c2b1ea0c7ffedc255e5a3b0f97f810ac', 'E', true, 1, 0, true, '2364858a0eea8c93da29d2e9dd98419f', '5203e983a1fce0428c57e677828ad8c0'),
  (3479, 2, 6, 14, '587f1593bcf629f96b50249258e46c78', '37ffc57605dfa772da77d7d178e5f25b', 'A', true, 0, 0, false, null, null),
  (873, 3, 6, 44, 'dd5ae2f0b340abce638c572af929aa45', '79595532ded8ee7d4287c7e53d9410a0', 'C', true, 1, 0, true, '57da647b6c87d21726a9f77c0540ff2a', 'dcbca1dd0395d23c3314fee432d63e2e'),
  (3480, 4, 6, 59, '21b2cd3233a8b14c7265f6f2639e2c2c', '9a973bc813ba4a89ff9f9a4b020a73f2', 'D', true, 0, 0, false, null, null),
  (3481, 5, 6, 57, 'c21085a6dc58a1174cb23b92402a636d', 'e22636b614d2cc85dbc7091723c0b202', 'C', true, 0, 0, false, null, null),
  (886, 6, 6, 56, 'ae127613431af76a6614d9a2a740283b', '8c93cff521f24f1c40ba11425cce9703', 'D', true, 1, 0, true, '96346fe7c8d3e3385d5cc7cbc0dc6a94', 'ac43d37b2f3356059230128d0f15f27e'),
  (883, 7, 6, 45, '68cb36972995e23e9f1838c4bb31a407', 'ec63ac97c15240f00517f54e5464aab7', 'A', true, 1, 0, true, 'ab15ddea100f76906c9b358d9c78acee', '7aaa5f0b0a9ebad3c550e9d4c4ea1efa'),
  (894, 8, 6, 54, '8bb5729747d1d2c6d229b4ced4b73504', 'fe7c510647f6f47ff1e2c3dda6b348be', 'E', true, 1, 0, true, 'e89e10d1e5fe0addefc3840b9f4f4207', '67e1c20dd24772b3c20c9ab7548b5824'),
  (3482, 9, 6, 5, '95c7d08b0420550a7849af60e0e137d6', '672e341ef5e4f753c9ddac760a86d2e4', 'C', true, 0, 0, false, null, null),
  (3483, 11, 6, 57, 'c1b01d5f4088fd865fc096e5709c9817', '30c0ed1ce7fbc92371601ed9625b6721', 'B', true, 0, 0, false, null, null),
  (3484, 12, 6, 50, '000b2c58376e7b0975e3b3bcfda74ae7', 'eccd939eda78241de263080bd3f96d1c', 'A', true, 0, 0, false, null, null),
  (3485, 13, 6, 51, '94baa1ea063ba228bdde7adfcb699122', 'f82e8efc9b8b2af10d52ef57db078b82', 'B', true, 0, 0, false, null, null),
  (3486, 14, 6, 48, 'ff873c2964305cc3e1ee4bcdddcebbf4', 'b6c4b67371c1ed0ca60eabc77e208707', 'E', true, 0, 0, false, null, null),
  (3487, 15, 6, 50, 'd3c9c24ac4e4a4732589f0897251e4b3', '1cc76f41d7aca18f506148f2e36824c2', 'E', true, 0, 0, false, null, null),
  (3488, 16, 6, 49, '95508fdf442e01f5c5de72614b45f46a', 'b6c4b67371c1ed0ca60eabc77e208707', 'E', true, 0, 0, false, null, null),
  (874, 17, 6, 44, '4aaf831307b5e61d1e1c415b47ed94d0', 'f0d8d157b3b317d5f899a633bcd6beff', 'B', true, 1, 0, true, '951bb3680ec1d190ea3c85a5018c2860', '78ce825c7d7ea7bc3488c85a8076029c'),
  (878, 18, 6, 46, '298e1c245411ddc55e4f51da7b4f3559', 'df90b2446550d1afd9d6c8379d48e226', 'A', true, 1, 0, true, 'e090097376c3cbe33cdb4f123f039f30', 'b198e4114bc2c3faa5c25f97a57f6d80'),
  (3489, 19, 6, 15, 'da71633b49056cbf00300fe6a25c14cb', '7d41178faca466b79c6fcfba21780759', 'C', true, 0, 0, false, null, null),
  (3490, 20, 6, 15, 'e7842d6a1460e7673b7f86c851373189', 'c32c408a6f242e61fb1625f3b2dcf521', 'E', true, 0, 0, false, null, null),
  (3491, 21, 9, 28, 'e602f03f2b43a41756f7880fda7991e2', '6c177cd3efc3f5b67a1f2148444aebe9', 'D', true, 0, 1, false, null, null),
  (103, 22, 9, 28, '4e43d17be4e7e031bf8410da411a1571', '055bdf83fa509e861d8149a429676408', 'A', true, 1, 0, true, '4e43d17be4e7e031bf8410da411a1571', 'b06c0e8128c3476813cf7b03f96b2816'),
  (104, 23, 9, 61, 'ef715af267c2fb24b0ba7a2010b3d53b', 'b95ca7af99aadb4c1f96315c6bb84422', 'D', true, 1, 0, true, 'ef715af267c2fb24b0ba7a2010b3d53b', '4355292554f52a24f3981e0960579bb9'),
  (96, 24, 9, 61, '2417e278504457546a445f4d38acdfd2', '42929f4f8cb95364d95f324ea55b4294', 'E', true, 1, 0, true, '2417e278504457546a445f4d38acdfd2', '3814a631d97cc3de9b5a034b529c6fdc'),
  (97, 25, 9, 29, '0cbe2b50db4a23efeeb3df12d6066424', '98785c12733108fddb4e5a388d428058', 'C', true, 1, 0, true, '64b93251a34ad27a8fed1434c11ea3df', '765e64e44ba37bbb79ddfbc48b066bd6'),
  (98, 27, 9, 62, '9621628c9a7269c86d833824d6e451b5', '11129982525e9f88c3b309910e331f8c', 'B', true, 1, 0, true, '9621628c9a7269c86d833824d6e451b5', '57e22398c209e044ac49811e8b8abb61'),
  (99, 29, 9, 60, '10f9193cdf5503c22aa87f06cc0b6148', '9970ed05088fd11cf7d0ac469f8d6f16', 'E', true, 1, 0, true, '69462dfdedea1fa23fef8792ad7333f2', '8076d46502700a4817f594ed5d936328'),
  (100, 30, 9, 60, '586799978cd3823e2605326ee3153912', '03be2074baabb22a25c144505c5dbaa1', 'C', true, 1, 0, true, '586799978cd3823e2605326ee3153912', '2e0a618bca3b9bbe93b21646c126ba21'),
  (134, 31, 10, 19, 'a35458f2cbc4a8b6d135078dc436c9aa', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', true, 1, 0, true, '0b03ec111cfaeff7e313c5be649870b5', '09c1509adc80492540bd8f4235c94c8b'),
  (136, 33, 10, 63, '6b8d44322ad255b78fe0282636bef3bb', 'b03469539ffa1f2511bd21cbc1df1a98', 'D', true, 1, 0, true, '21fae46c2f8468597653788e7c52ccd5', '35617cc7bf329edcb6faec467458993c'),
  (3492, 34, 7, 257, 'bd021b69b93198644f6691151b881aea', 'c1d1982194c6d631ccd83668452cfab7', 'B', true, 0, 0, false, null, null),
  (3493, 35, 25, 322, 'fd8625ecd403b9a6b41bba90a04e511c', '4eea58c69045f270f4e1c22e5c07bf6e', 'A', true, 0, 0, false, null, null),
  (141, 36, 11, 27, '2a4513d8330ab3aafef3ed2024fed307', 'f261a6d06677399db3ff1b84c9262abc', 'E', true, 1, 0, true, '62080a92e00eb7afaafde1c3b36c8376', '0084398dd8b0a96791f50783b87b6d48'),
  (3494, 37, 11, 301, '1dd21dbdd9908308b8a6a171c01de681', '8165051fd1026e73cc4a0c5e3a862890', 'D', true, 0, 0, false, null, null),
  (3495, 38, 8, 142, 'ea74855d3032bd3f45d619257d707e9e', 'acd1e475e433cee90ac23a3df62fa0ac', 'C', true, 0, 0, false, null, null),
  (137, 39, 10, 64, '6fed5e2609450088f20c03c9ab00bc3c', '40c29b4259616bfe4d6c998e04af3f0a', 'D', true, 1, 0, true, '6fed5e2609450088f20c03c9ab00bc3c', '96dd672ad9e80a7cf2e2846fbe0a0c9f'),
  (138, 40, 11, 102, '062c4b990dde8aa9b5f6f68f587306f9', '29e12b8af84ddd764da5d140c94c663c', 'A', true, 1, 0, true, '062c4b990dde8aa9b5f6f68f587306f9', '4d107458e2fcab373db1a3bf99726e9d'),
  (3496, 41, 16, 181, '0d5cb87e0b35c67f27bd542c183eaa77', '9bab607d78f37729aae27ea08028c9c4', 'B', true, 0, 0, false, null, null),
  (3497, 42, 11, 317, '5efc31d124aeee6e87660defa6b8ea36', '456dd0424de2436cfe4cc17628dd10ac', 'A', true, 0, 0, false, null, null),
  (3498, 43, 11, 318, '4b503967997048c3171bc7785ba2a08d', '10968978561f6225dfe2dbe3f8a9528b', 'E', true, 0, 0, false, null, null),
  (853, 44, 10, 68, '23b101dceb082fea8cd232e7a6cbe3bd', '222fa72084339271af1e2be27580b1f5', 'A', true, 1, 0, true, 'c9ed794cfb8a5b0acd33d0162e56b261', '680359f9743b65739deadbf52308f44e'),
  (143, 45, 10, 78, '4a66c938cd8c133741d667069ee6b9bc', '4b0722752cbcdaafd4674d87b257aedd', 'C', true, 1, 0, true, 'ddff41aaea69c5f8642e0160f202b4f9', 'db7a002f40ee236739f72b072b0d4b6e'),
  (3499, 46, 7, 257, '408edb7fb830fccdff44431219a60f93', 'be64f2388fd2d639182193a9f194aad5', 'D', true, 0, 0, false, null, null),
  (144, 47, 11, 90, '118ef633547f67cb6f1c5187bd0eecae', '77bf0e1745e2c0f4bbfe6ce7623a66d1', 'B', true, 1, 0, true, '118ef633547f67cb6f1c5187bd0eecae', '1b2e7240e6daae50d2e1e62441b679a6'),
  (3500, 48, 26, 316, '0dc9beca81cb545ab3bf0ebe7ebd9755', 'af8832ea0c6f668cb2f00ca7876ce2ff', 'D', true, 0, 0, false, null, null),
  (145, 49, 11, 88, '3ac5f4020736a409ca7e78ee6cb0a945', '744a50b99fe50b21b90ca6c65be09f0b', 'B', true, 1, 0, true, '3ac5f4020736a409ca7e78ee6cb0a945', '8f27e9084a165d173b4be6ae78950d58'),
  (3501, 50, 25, 137, '7c0737d576100cb318f2245f9d918870', '063b09dbf74b526e6967944240fa1076', 'E', true, 0, 0, false, null, null),
  (843, 51, 10, 80, '86d6c679e1eaf8e0ea80f7aefb4b4b5f', '5d71be92d8fc9763e38fefd4713fc062', 'C', true, 1, 0, true, '86d6c679e1eaf8e0ea80f7aefb4b4b5f', 'e9b3b3a487c1fd2ac4d84fb2d0af7a24'),
  (844, 52, 10, 80, 'dba4f337eb4de92b073db1353289cc38', 'c498b90e8b98afa47ef801b78eb9c297', 'A', true, 1, 0, true, 'dba4f337eb4de92b073db1353289cc38', '0bec93a022241aaf445e9c87caec67ca'),
  (3502, 53, 25, 323, '330ec3e94ccabe723097773463f127c6', 'b03469539ffa1f2511bd21cbc1df1a98', 'D', true, 0, 0, false, null, null),
  (3503, 54, 25, 323, 'e62a9cddcab5ea15e731e9f98a6f3d97', '852a8799b1b1e0b1bc13465c3cc51d24', 'E', true, 0, 0, false, null, null),
  (847, 55, 10, 71, '38ee91102a837899adc853fee2843568', '05757ff47a76eea621dbcdb4cf619158', 'B', true, 1, 0, true, '38ee91102a837899adc853fee2843568', 'e9f1fe42be5d6abf5b3a7bf4c687aabb'),
  (848, 56, 10, 71, '4b91fc90f56e37c95dba427494b70a79', '45a832e6ffd01f5d06272b2177fe352b', 'C', true, 1, 0, true, 'eb49b60c76420b7bfd93d47be436ba5b', '3699d09ce87babd9188425ee362edac7'),
  (3504, 57, 25, 137, '41c6c2c9d8408e9ee006103e4a0213bf', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', true, 0, 0, false, null, null),
  (3505, 58, 25, 322, '192efec208ab92b61b97f7d1c7cb2437', 'df252d7f1c9aa0b2085c62c16dce8cbc', 'B', true, 0, 0, false, null, null),
  (3506, 59, 5, 248, '1ebdef459971e0480aa74285831af5ae', '456dd0424de2436cfe4cc17628dd10ac', 'A', true, 0, 0, false, null, null),
  (3507, 60, 5, 248, 'e90fbd67f61e110b6a4e79cb6f62958a', 'daba4b9c910e58f09bb546214d523884', 'E', true, 0, 0, false, null, null),
  (3508, 61, 13, 311, 'dc835afc7004c44964cd3c1da79766e3', 'fdba98b45bce38744df8f909713128dd', 'C', true, 0, 0, false, null, null),
  (3509, 62, 13, 311, 'c3246807d884691c145e5be1cdb5c3b1', '4de226762dd058d41d6d81a0c0fb6d38', 'D', true, 0, 0, false, null, null),
  (3510, 63, 13, 311, 'd6e16a1c4e258e6317a104b3990eea1a', '50274735744a5e0f8446ee765c9bb43e', 'A', true, 0, 0, false, null, null),
  (3511, 64, 13, 313, 'f4413b1371c8e8006d7e278a5fa70c97', '5da66ea14bd9b53a41a0180fcb1166bc', 'B', true, 0, 0, false, null, null),
  (3512, 65, 13, 311, '4f18664610742b90944746723128bdf9', 'f8e8dafa98c7dba14b0ed322dfec5808', 'A', true, 0, 0, false, null, null),
  (3513, 66, 13, 311, '58b50b9c29ec361fc276f22db030ac21', '6a03dc314fb036532e7f5d3eeeeb5706', 'C', true, 0, 0, false, null, null),
  (3514, 67, 13, 311, '180801e70da38065aa42d8d8f7b21e03', '2e230cbe83ca956cd5fb04185873f727', 'B', true, 0, 0, false, null, null),
  (3515, 68, 13, 20, '8474dbe31c758544dcca4b9b87e9185c', 'ecece57520d469836c5e1842fd5df400', 'E', true, 0, 0, false, null, null),
  (3516, 69, 13, 311, '40f9a2874642ffee9f7948e2d15dc5fe', 'bbae530424945ea9746daf95872743bf', 'E', true, 0, 0, false, null, null),
  (3517, 70, 13, 324, '1bf38e03941ae7b35b9d1b66dcc094c7', 'efa9fc41275136ab3042bfa9206f7087', 'D', true, 0, 0, false, null, null),
  (74, 71, 18, 36, '0a64111f62bec3a9843813bfe5be7034', '3106aa18696265d442f97573c71c821f', 'D', true, 1, 0, true, 'd15b72708626dc6fd070a60eb3e2fec9', '2480533944c58508c02f3a20f91d97b0'),
  (76, 73, 18, 37, '949e4dc91ccf8f71fec8c82095a00827', '8c4adcfe986eaf5a6a35852a038b48c4', 'B', true, 1, 0, true, '949e4dc91ccf8f71fec8c82095a00827', '8b838acef1358e2497cbc4a39c0bb3ae'),
  (77, 74, 18, 35, '8e94aefcdd9c800a544fa28499ec1a8c', '6d8e9d30213db1a196358282f09a5bb7', 'A', true, 1, 0, true, '8e94aefcdd9c800a544fa28499ec1a8c', 'b4f0ba177db94d760454f7968adefea6'),
  (80, 75, 18, 39, '86a62b1d6c9af03c5c91834ec8963678', 'a3e863cbb38dde8bf2bd1fea937d90f0', 'D', true, 1, 0, true, '86a62b1d6c9af03c5c91834ec8963678', '5614e65608403822e3ba0f6dc362dffb'),
  (81, 76, 18, 35, 'd726b635098d2c8757f126ca97ac5d34', '1919c35fea4ba44ccfd087d030da2d6c', 'C', true, 1, 0, true, 'd726b635098d2c8757f126ca97ac5d34', 'c837d33a4ade8f2472252ab04a2e4739'),
  (78, 77, 18, 32, '3228ae937618a48c746f6e23304bf46b', 'cce819c4cc70eb86faa01c43659de4d1', 'B', true, 1, 0, true, '108c607a888259f36b47a0003c454a86', '2d727845123824117964649a708f81ea')
),
prova as (
  select id from public.provas where hash_prova = 'c4918b974a0fbf431a134dcde11eaf61f8341c1838ee56c621cef9861874a6e6'
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
  select id from public.provas where hash_prova = 'c4918b974a0fbf431a134dcde11eaf61f8341c1838ee56c621cef9861874a6e6'
),
pp as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
),
intocado (questao_id, md5_enunciado, md5_explicacao, ativa, md5_alternativas) as (
values
  (75, '2593e11d4eb3eef81676e6437d3effbc', 'fda844a30dfbd54d7d8c60134f9d89dd', true, '38fe6e7d6b478c5711c81326f6af34ed'),
  (79, '1c30d6cfc77c4cf95b09fdbc3c5de2b8', 'db1a5f935c8755bbd7ce8236560dc2d6', true, 'b8203f444f520b9335de0402c936d4c3'),
  (135, '47303b4ed6f091d6d185e984c5a4a801', 'fcff4fe9718b1ce3d27633ff323a353f', true, 'a6e6a301f06a5fc10b1afca3099f2f6c'),
  (142, '4989b8aec64366a8d8c8b0deed05a765', '88cc92680d73ec56eb4cdc243638931d', true, 'b2e5583f9a2d32dac275a4c1c359f719'),
  (246, 'd4f044c9827be2df65c5222c72454fd1', 'ef8d6595a24508e1e7df2d60643acba5', true, '5b9adf26c15a2b08e818753097a12452'),
  (497, '099d90bd6508da096fa29c6f5890538c', 'ef15d4f398eef322a30eeffef8f0fcb2', true, 'f456866197693b4350efe34f28063a48'),
  (498, '996bd0fd47159b122189ca7d8319268e', '41f594ffc83ace25b6a2a927be4f9b27', true, '47c042348c621810b9830a93d881d000'),
  (815, 'fd8dddf90904b9b6ca3cdef79f186dc6', '2ab36414e7fa43c4ea47aa0462fa9d89', true, 'b1f853d6095faf9146cf6f26b7fc9b72'),
  (827, 'f6499729e48422d9a877669d81334fdb', '10d9f144c30376a4284fdabef0c1a963', true, 'c668085ad34474a25a3668e23057c8cb'),
  (851, '63e70d36bc6fa706d44f1878bf8042b2', '35617cc7bf329edcb6faec467458993c', true, 'be868514d3218b752be74757412c9a6a'),
  (857, '6fed5e2609450088f20c03c9ab00bc3c', '96dd672ad9e80a7cf2e2846fbe0a0c9f', true, '996fef8b3b5e645f6da87f9449e08bf2'),
  (863, 'd7083005a4e917f793c66467ae28d2db', '09c1509adc80492540bd8f4235c94c8b', false, '27566ec515d17e13fa64c1a6ef4cf609'),
  (869, 'ddff41aaea69c5f8642e0160f202b4f9', 'ce68d7d7dd1ffc99d8f8db6c90cb3827', true, '20b7452bd46d0b56f2d3e5176677384b')
)
select verificacao, ok from (values
  ('prova_id = 25 (hash_prova c4918b974a0f…; manifesto 4e803c158356…)', (select id from prova) = 25),
  ('prova_documentos: só o GABARITO = HTML oficial f6404c00bd01…', (select count(*) = 1
     and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = 'f6404c00bd01eeed11684526fea704e207fca7548e774e8ceba472e402b76174') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('provas.hash_gabarito = HTML oficial (o TXT derivado não é registrado como documento)', exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = 'f6404c00bd01eeed11684526fea704e207fca7548e774e8ceba472e402b76174')),
  ('72/80 oficiais na prova, números distintos, sem parte', (select count(*) = 72 and count(distinct numero_original) = 72 and bool_and(prova_parte_id is null) from pp)),
  ('39 novas = ids 3479–3517, sem curso_questoes, todas com assunto; Q70 em Geografia Geral (324)', (select count(*) = 39 and bool_and(assunto_id is not null) and bool_or(numero_original = 70 and assunto_id = 324) from pp where id between 3479 and 3517)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3479 and 3517)),
  ('33 legados qualificados (prova/número)', (select count(*) = 33 from pp where (id, numero_original) in ((891, 1), (873, 3), (886, 6), (883, 7), (894, 8), (874, 17), (878, 18), (103, 22), (104, 23), (96, 24), (97, 25), (98, 27), (99, 29), (100, 30), (134, 31), (136, 33), (141, 36), (137, 39), (138, 40), (853, 44), (143, 45), (144, 47), (145, 49), (843, 51), (844, 52), (847, 55), (848, 56), (74, 71), (76, 73), (77, 74), (80, 75), (81, 76), (78, 77)))),
  ('fora da prova: 10, 79 (novas em revisão), 26, 28, 32, 72, 78, 80 (legados em revisão)', not exists (select 1 from pp where numero_original in (10, 26, 28, 32, 72, 78, 79, 80))),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('registros intocados (legados em revisão e duplos não escolhidos, inclusive 142): sem prova, enunciado/explicação/alternativas/ativa iguais', (select count(*) = 13 from intocado t join public.questoes q on q.id = t.questao_id
     where q.prova_id is null and q.numero_original is null and md5(q.enunciado) = t.md5_enunciado and md5(coalesce(q.explicacao,'')) = t.md5_explicacao and q.ativa = t.ativa
       and (select md5(string_agg(a.id::text || ':' || a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = t.md5_alternativas)),
  ('mídia só na Q21: FIGURA 587x298, p. 7, OFICIAL_PROVA, antes da legenda, sha256 d8ea0e3923c7…', (select count(*) = 1 from public.questao_midias m where m.questao_id in (select id from pp))
     and exists (select 1 from public.questao_midias m where m.id = 10 and m.questao_id = 3491 and m.prova_id = (select id from prova) and m.ordem = 1 and m.tipo = 'FIGURA'
       and m.sha256 = 'd8ea0e3923c72f07bd28873f90e56b721b9d1bc0cf945d2ba375110c82663ca6' and m.mime_type = 'image/png' and m.storage_path = 'questoes/d8ea0e3923c72f07bd28873f90e56b721b9d1bc0cf945d2ba375110c82663ca6.png'
       and m.largura = 587 and m.altura = 298 and m.pagina_origem = 7 and md5(m.ancora_texto) = 'fdb01dbc698ae7e84d8de829506a6c4d' and m.direito_uso = 'OFICIAL_PROVA')),
  ('objeto da mídia no Storage', exists (select 1 from storage.objects o where o.name = 'questoes/d8ea0e3923c72f07bd28873f90e56b721b9d1bc0cf945d2ba375110c82663ca6.png'))
) v(verificacao, ok);
