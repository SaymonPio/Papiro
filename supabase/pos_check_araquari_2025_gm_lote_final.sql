-- Araquari/SC 2025 Guarda Municipal (Fundatec, concurso 1040, caderno 1040.001 — Prefeitura de Araquari/SC, Concurso
-- Público nº 01/2025) — REGISTRO SANITIZADO do lote aplicado em 2026-10-24. 67/70 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) taxonomia (assuntos 335–344) — ver supabase/manutencao_araquari_2025_taxonomia.sql;
--   1) executor de aquisição, manifesto e973f1176e3ec917332cb7398bb87466b24f3f159d502d08d71f5357990a7812,
--      modo BASE_GLOBAL: provas.id = 27 (hash_prova 0cc26f885587…);
--      prova_documentos: GABARITO = PDF oficial do Edital 09/2026 "Gabaritos Definitivos" (sha256 c6eebd5c1612…);
--      sem retificação aplicável e sem anuladas;
--      40 questões novas (ids 3558–3597), 200 alternativas, nenhum curso_questoes, nenhuma mídia;
--      liberação explícita com conteudo_hash: DEDUP_OK Q4 (≠328);
--   2) qualificação do legado (script operacional com texto integral FORA do repositório; lista lida de
--      reconciliacao.json): 27 registros TEC receberam prova_id, numero_original e fonte/concurso oficiais,
--      preservando id, alternativas, gabarito, matéria, assunto, explicação, ativa, vínculos e histórico; enunciado
--      trocado pelo oficial só onde a diferença era de espaço ou de aspas (Q7, Q8, Q17, Q19, Q20, Q30, Q32, Q46, Q51, Q56);
--      TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA, decisão individual: Q9→691 (o PDF omite o artigo) — texto saneado do
--      legado preservado, só proveniência.
-- Fora da prova (novas em revisão, sem override): Q5 (grifo perdido), Q10 (linhas 04/07 sem texto-base associado),
-- Q15 (diagrama lógico sem mídia; DEBITO_PARSER_POSSE_MIDIA_ENTRE_QUESTOES).
-- Registros intocados (verificação 9): 318 — candidato descartado da Q5 (falso positivo; Q5 em revisão); 328 — candidato descartado da Q4 (DEDUP_OK com conteudo_hash); 786 — parecido com a Q7 (comando 0,89, alternativas diferentes); 1926 — candidato descartado das Q60/Q61 (falso positivo).
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 67 questões e os registros
-- intocados continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, midias, legado_qualificado, md5_enunciado_antes, md5_explicacao) as (
values
  (3558, 1, 6, 15, 'f0e4a081dbc964d44861369072d2eedf', '3a1366ac2e9837e5edbd4e176c7b2227', 'D', true, 0, 0, false, null, null),
  (3559, 2, 6, 15, '3705ed3da57bac17625f486febd77ceb', '3d4590fdadaff821f134461ca2f4290c', 'B', true, 0, 0, false, null, null),
  (3560, 3, 6, 15, '83b05cbd7c9d4745e1f9a61fc70ac50b', 'ce62207b677a46f443db1af49fbe542c', 'E', true, 0, 0, false, null, null),
  (3561, 4, 6, 5, '3d3c9adb00aa3fdba5f251e028e5b5c1', 'b2c012d7d45e17dc67f3987fd8344e39', 'D', true, 0, 0, false, null, null),
  (3562, 6, 6, 55, '051dfe505abce8fa7905fc9609c6b807', '9f79a323f9c2e246ae14d5a2dd0a430b', 'E', true, 0, 0, false, null, null),
  (690, 7, 6, 53, 'eb8d3672c2c8e62fe3aee7899c3f344b', '84efbb8012c5ca0f547e14630a944c69', 'A', true, 1, 0, true, '8c5d8668296aaa9e652625e6f1df648f', '84758cac426a424ffac51cd6e763e256'),
  (681, 8, 6, 44, '36ee81e6ca4e434fc432e3cbb93b5583', 'aad357e8bfee50422f43352f128a3480', 'D', true, 1, 0, true, '16dc8340af7cb1d867616abffad541a7', '4799390355b42aa707f2e8b7daa021a4'),
  (691, 9, 6, 53, '0a1351240ecbc0d7071bf2940c31d09b', 'e379eb656851ded561f7c4055f886e1c', 'A', true, 1, 0, true, '0a1351240ecbc0d7071bf2940c31d09b', '3333da80c504aea03a9360093c2ef098'),
  (3563, 11, 18, 342, '0849e755a6836cb8987e53e4aa908058', '1a3b30e903d3bc5e4fe2614d36b2cf93', 'D', true, 0, 0, false, null, null),
  (3564, 12, 18, 35, '76dd5c0ac9b9544835763ecde0751b8b', '4c189cf3e64d93674c604d15de54cc0d', 'E', true, 0, 0, false, null, null),
  (3565, 13, 18, 342, 'c2add97a900c1a9385a8e4fe51e2bbd7', '6220d891c9c2e5abeaba956872c9c9c5', 'B', true, 0, 0, false, null, null),
  (3566, 14, 18, 183, 'cf51779b0523e58e09ff3b148b76ebd7', 'f7e9a28e1f109eb67f4b6d67a8211d63', 'A', true, 0, 0, false, null, null),
  (645, 16, 9, 28, '9652ba8fe3b6ba42ccd80e737fe920ae', 'cfaef4b662ca22ef083dee2339a0fed7', 'B', true, 1, 0, true, '9652ba8fe3b6ba42ccd80e737fe920ae', '442246742758aff0ae86f0bb65a336a9'),
  (629, 17, 9, 61, '4349aa5a6da142df2af756f0e5f7b863', 'b2feaa44c57f79eebc5e145976e505ad', 'A', true, 1, 0, true, '6efa3880a52a4ea8ea91de61f329d26f', 'f5d5bf29ab55d59df4acb0fc60e63741'),
  (3567, 18, 9, 343, 'd5c69c687edc70de46e5c71579c50115', 'afb3633bd1d9e681d101827ef2ee932e', 'E', true, 0, 0, false, null, null),
  (638, 19, 9, 29, '2cb329e7cecf67a2e1c7f92cb8cd1644', '91d5287a5b3bc3dfbf520ce70fe459cf', 'D', true, 1, 0, true, '21e8bcbfa4c63a69d0fb8462a6ffce64', 'efa48c86776a1b2076232c61a4932982'),
  (642, 20, 9, 10, 'f1ad9a4af1ea2fe291088010559a2635', '24b2833887194f084258af63102d71b4', 'C', true, 1, 0, true, '974156a8e3a8cdaecac0d521dcc33ae6', '4e46d77ba65edbdecc289a41b57e5c51'),
  (3568, 21, 22, 335, 'c17f03f1e423e28e95a1b794adb8d02c', 'c77b306cb60a776ac9c667e88d3974c3', 'D', true, 0, 0, false, null, null),
  (3569, 22, 22, 335, 'b425926bc49143371c299bf71d9dbe03', 'cf9cf8fcb26157cbbf7fefe8a98dd239', 'E', true, 0, 0, false, null, null),
  (3570, 23, 22, 336, '0e514396e3b66662476ca76f74a4ed60', 'ff4f5329c3cb206b4d0102f7c8a23e8a', 'D', true, 0, 0, false, null, null),
  (3571, 24, 22, 336, '5f74030178a50f83e1a48790f65f0bbb', 'f3c0faec1d0e263262a368f02c75e027', 'A', true, 0, 0, false, null, null),
  (3572, 25, 22, 337, '7defe2786cc0ba1a8609be6f0f741368', '949edcb61e2c7cf5cd705de6e98e1bd9', 'B', true, 0, 0, false, null, null),
  (3573, 26, 22, 337, '5e34f2f00a1342ca992c0c06438064c3', '0d0f7512ea2d3ca16fc831dffd8fe657', 'C', true, 0, 0, false, null, null),
  (3574, 27, 22, 337, 'd1e504ce0beda24f2530f0fdabde5654', '77cabf687cd0fe04ac3419538b5825fc', 'D', true, 0, 0, false, null, null),
  (3575, 28, 22, 337, 'ef1077b537771f6cd9b5ac5e4a115c3a', '9164c254660396e53f469ef5741d9375', 'B', true, 0, 0, false, null, null),
  (3576, 29, 22, 338, '8af3937140954687686b611433331019', '591b46e268d48dd3a96849a6197a8d2e', 'E', true, 0, 0, false, null, null),
  (624, 30, 11, 89, '634210473ceacb25857aace4576fa1c5', '8f473a92d4b8d2df610e073ae2db781a', 'B', true, 1, 0, true, '0eb2feb1b5178f71cf6c08a5d1892ba9', '6bc426f3d9909e92ec844a09d68e2f48'),
  (651, 31, 10, 70, 'bf5a91f4291063c6cb1d52613009ff66', '08e8fd2e74c150a2248ca8c0fc7d488d', 'D', true, 1, 0, true, 'bf5a91f4291063c6cb1d52613009ff66', 'cc7a6131e2d01c496c5c6a3e18f4ef91'),
  (660, 32, 10, 71, 'd9c99bda1258e454af6f3d2cad0a251f', 'a36655c6dae0673398f8ba2e3f5cfc17', 'C', true, 1, 0, true, '7daedf5be3b6566d2cf8619094ee6c31', '0b9c1bd057da6601cc9b343d18644ac7'),
  (661, 33, 10, 71, '463e4d38b341703092751b193146d858', '323eca82a5395851dde4b492b312b005', 'A', true, 1, 0, true, '463e4d38b341703092751b193146d858', '124b52eec90c8295001ae5bfda45314e'),
  (662, 34, 10, 71, '9c7555c237667f4a3a7df05007a5b66b', '862ea9abb284a73dc0536519d6272c42', 'E', true, 1, 0, true, '9c7555c237667f4a3a7df05007a5b66b', '9a72d949099a245c3aa55e4e65766b20'),
  (663, 35, 10, 71, 'a5acf1db1951ddcb9e1e48218b78e3bf', '2553aeac74edde64793a3a55d7444fbe', 'B', true, 1, 0, true, 'a5acf1db1951ddcb9e1e48218b78e3bf', '77ce529ab7125bf9a61782426bca6922'),
  (3577, 36, 3, 140, '6ae88d0e5e41c297f6132d00a1055344', 'ab814b79a2750ba45528130abd7e3a3f', 'E', true, 0, 0, false, null, null),
  (3578, 37, 3, 339, '085142ef099e9848608987abd5b175f7', 'ed915ca667d0a7cf131cf8cf30525ad3', 'A', true, 0, 0, false, null, null),
  (3579, 38, 3, 140, 'f9bbe20e0f39588a56916b5fef3de161', '2a28fbadecdd79cfe2f51f0e4fd16f8d', 'C', true, 0, 0, false, null, null),
  (652, 39, 10, 70, '13623684fe6d1c185ec1fcab9cadd6b3', '5766fa195eb1f150c0fb89fec8beb9a4', 'B', true, 1, 0, true, '13623684fe6d1c185ec1fcab9cadd6b3', 'b2b51140169af2d24fd528fc3f556693'),
  (3580, 40, 3, 263, '8e1d9562ba67fa85ce761f8b38acad94', 'f1f23e2bc75f2ba8127f6ff15a3e8d90', 'C', true, 0, 0, false, null, null),
  (653, 41, 10, 70, '285ae7a334f3fc14cd7fa9b3a9404fb1', 'c20b276b0ef3550632e110faf4b1ba04', 'C', true, 1, 0, true, '285ae7a334f3fc14cd7fa9b3a9404fb1', '3a3d4f21eccb9392b805f94f2fb5a06c'),
  (3581, 42, 3, 339, '876671f50d0f64708db00f783002f46b', 'aae0af35e82543272f122aa1420707bd', 'E', true, 0, 0, false, null, null),
  (3582, 43, 3, 339, '107dbe6acb4878e62bccb39c48b8425e', '6f3cf1365e0e379679a54dc76d82655a', 'A', true, 0, 0, false, null, null),
  (3583, 44, 3, 340, '24eea743918560c724df23e3db5848ef', 'e4eb1e6ca1c14248cde729f78327e007', 'C', true, 0, 0, false, null, null),
  (3584, 45, 3, 340, 'b07af7a2aa9c85515101ca02ac03c820', '7686e12a247199d7ea8ba67e4316eed0', 'A', true, 0, 0, false, null, null),
  (654, 46, 10, 74, 'b2441bf2371e326d806aea288fd73b3a', '4816289d61ee2b579e655e3fdda7263f', 'D', true, 1, 0, true, 'd9fb6df4a444a0c9fbafb0acd6707ebd', 'ca7a58b41fdc0d4ac1800b095cf7f4fc'),
  (3585, 47, 3, 340, 'b0d4558afc0e84affb8cf6669acd5806', '3f5f35b2bcc3124d41cb5554c51b70cf', 'C', true, 0, 0, false, null, null),
  (3586, 48, 3, 340, '7a9b6b55e37b363394b8a15c148b1980', '959816889b83d64055edf513d7a0efb8', 'A', true, 0, 0, false, null, null),
  (3587, 49, 3, 339, '90131cec40f76dfd1e68f7148c01fdf9', 'e9be14eed541d152a3f6b419ea46cee7', 'B', true, 0, 0, false, null, null),
  (655, 50, 10, 74, '4f31172cabc2c629c9e4c986cf4ec07a', 'f1ca180533d68877ef5c071efcbcfc8e', 'E', true, 1, 0, true, '4f31172cabc2c629c9e4c986cf4ec07a', '5194e1cf1ea49163e13bc3e9dedc733d'),
  (656, 51, 10, 74, 'c2ecb3d62032884d1b6e8b7c8f16b95f', '26b3c20e46da0e90eacf99938e2c6ea5', 'B', true, 1, 0, true, 'e687685d9df23393c3d6bb63ecd4643e', 'e820a22c5d0a9cb2d82178b66b81f543'),
  (3588, 52, 3, 341, 'be0b0411c462f1b8de33bac2311a9c9e', 'b00e08fa3f4dc28a33ad5182816cdb7e', 'A', true, 0, 0, false, null, null),
  (3589, 53, 3, 341, '96a04e25286f9834e816ec9542f772cb', '745e43a04bed23a475ffcd717d9ecf5b', 'D', true, 0, 0, false, null, null),
  (3590, 54, 3, 341, '8c096972f1eea60a57175c3ab84a01a0', 'e9d830f8f3578266c7679bc34d8c4dd6', 'E', true, 0, 0, false, null, null),
  (666, 55, 10, 64, '64d826e1ee2c88db8607757f9939cc2d', 'a4d8c13d6f61f924ba3d87bd5a0d2c78', 'C', true, 1, 0, true, '64d826e1ee2c88db8607757f9939cc2d', '9dfb6f15ec099331a91a032d734b5f10'),
  (667, 56, 10, 64, '71f29ce65a960e704ad9bf37071aa939', '268c61bae35dfa7e2bcab6555dacd82a', 'A', true, 1, 0, true, 'd7c2666a6962ecf79b33d82a7fcc6e49', '0cf9d05e909c944f1dd6da98cc6e78d6'),
  (668, 57, 10, 64, 'b9d82cb781563e2cad33eb21eb1366b1', '5069f964eaea2e296024c0f7e0d02fe2', 'B', true, 1, 0, true, 'b9d82cb781563e2cad33eb21eb1366b1', 'f58b2e65d40fb582b4d5a7ddc064af62'),
  (669, 58, 10, 64, '8afa57e65e55dc742d985fe20516178e', 'e5cd70f9f1da69a596e9b45ce79594a9', 'D', true, 1, 0, true, '8afa57e65e55dc742d985fe20516178e', '57605eecb4dd06117d1be618440a3429'),
  (671, 59, 10, 19, '88662b01edcd83980065a1946b04c0f3', 'd8071131b88f077743a0262b64c8f733', 'C', true, 1, 0, true, '88662b01edcd83980065a1946b04c0f3', '0cefc3887ec5ef498875f88dc849ec1f'),
  (672, 60, 10, 19, '9c3098e926d988b937bae6d6d9ec5ece', '6885b47658a91f88d8d1dd93d31e4957', 'E', true, 1, 0, true, '9c3098e926d988b937bae6d6d9ec5ece', '6419565babe0f61825dd32c74de07d87'),
  (673, 61, 10, 19, '1d6d9ba16df9bd316a94223ae4bc8c4f', '8805d326faf55962f2f8128a29dd25fc', 'D', true, 1, 0, true, '1d6d9ba16df9bd316a94223ae4bc8c4f', '26cfcf071d00f678b30b19e556fdc893'),
  (677, 62, 10, 17, '49c3fb4a21d9f2eee1d8b2d74234fe6a', '9f5c7379e8f466bd04e19ee2f0fcfc9f', 'A', true, 1, 0, true, '49c3fb4a21d9f2eee1d8b2d74234fe6a', '5082f89125a41560c98b96549dfdb5e0'),
  (678, 63, 10, 17, '3452735a0a28131f6ef692325252f720', 'ab8f4a070fffd71db70ecbf0fe2c039d', 'C', true, 1, 0, true, '3452735a0a28131f6ef692325252f720', '9c86c62eee74c95111a218ff0a7c5ead'),
  (3591, 64, 2, 1, 'ae181d931930a76e46a22bf5a2a1be55', 'a05dead4e12d64a9f29e338b1c096f39', 'B', true, 0, 0, false, null, null),
  (3592, 65, 2, 1, 'ec52e20f9fa3ceeea1c1a0fcf7cefe6d', '2318033fd55055e8553add69f2babce5', 'E', true, 0, 0, false, null, null),
  (3593, 66, 2, 123, '118714a69db2c05c9739c92298fd24b6', 'f3e59901e3436a85a53fe282ad01f90c', 'E', true, 0, 0, false, null, null),
  (3594, 67, 2, 123, '9802e393cc221c76b3188479cf876ba8', '13aad621ceda1199b873beff0b97a3d5', 'D', true, 0, 0, false, null, null),
  (3595, 68, 2, 344, '1e09f916d8b5715d510ca7e60520cde2', 'ae88f2540c9fe330efb3810216f8246a', 'A', true, 0, 0, false, null, null),
  (3596, 69, 5, 248, '41f49bc73c99b1004db9c21faac6c4ba', 'f587a08aee75e71257c263065a37ac89', 'C', true, 0, 0, false, null, null),
  (3597, 70, 7, 257, '3fbc469387d12fa931b2f1ae585491b4', 'ac1b526dc713273323c6b4eafdb97170', 'E', true, 0, 0, false, null, null)
),
prova as (
  select id from public.provas where hash_prova = '0cc26f885587d4c5a7a77afd0484a491ec099cf0466ba91934f925ba93ba994e'
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
  select id from public.provas where hash_prova = '0cc26f885587d4c5a7a77afd0484a491ec099cf0466ba91934f925ba93ba994e'
),
pp as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
),
intocado (questao_id, md5_enunciado, md5_explicacao, ativa, md5_alternativas) as (
values
  (318, 'e559ba95f7366089f5e252ad8848bf0a', '7881939e46bec4750871421881e6463d', true, '0478bae24a06c3b3b6e19f77a2bbf50e'),
  (328, 'f7bef32de77e100faee1b360841dd6ef', '8f41eb42dbf28ea4ffbd7c6bb42787bd', true, 'cf46384922ccbbc076872a9c72da3a99'),
  (786, '8a5d91102fabe99a33f82d9bee5f2113', 'aed139a5305019c77664c1c1875a5375', true, '9c79568fa5062d6b168c1e55d5738b0f'),
  (1926, '276745b908f655ad1cc8c0eee0d5680c', 'f3a8041e7be182bb821b801cbdf545e7', true, '75f370fe75edb7354ca7fce7873ab68a')
)
select verificacao, ok from (values
  ('prova_id = 27 (hash_prova 0cc26f885587…; manifesto e973f1176e3e…)', (select id from prova) = 27),
  ('prova_documentos: só o GABARITO = PDF oficial do Edital 09/2026 c6eebd5c1612…', (select count(*) = 1
     and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = 'c6eebd5c1612865a9676d2aeeb1db8767f41d12f3daa6251d9aa1087a683c1c8') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('provas.hash_gabarito = PDF oficial do Edital 09/2026', exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = 'c6eebd5c1612865a9676d2aeeb1db8767f41d12f3daa6251d9aa1087a683c1c8')),
  ('67/70 oficiais na prova, números distintos, sem parte', (select count(*) = 67 and count(distinct numero_original) = 67 and bool_and(prova_parte_id is null) from pp)),
  ('40 novas = ids 3558–3597, sem curso_questoes, todas com assunto', (select count(*) = 40 and bool_and(assunto_id is not null) from pp where id between 3558 and 3597)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3558 and 3597)),
  ('assuntos novos: Q11/Q13 -> 342, Q18 -> 343, Q26/Q28 -> 337, Q68 -> 344; Q21/Q22 -> 335, Q23/Q24 -> 336, Q29 -> 338', (select count(*) = 13 from pp where (numero_original, assunto_id) in ((11, 342), (13, 342), (18, 343), (26, 337), (28, 337), (68, 344), (21, 335), (22, 335), (23, 336), (24, 336), (25, 337), (27, 337), (29, 338)))),
  ('27 legados qualificados (prova/número)', (select count(*) = 27 from pp where (id, numero_original) in ((690, 7), (681, 8), (691, 9), (645, 16), (629, 17), (638, 19), (642, 20), (624, 30), (651, 31), (660, 32), (661, 33), (662, 34), (663, 35), (652, 39), (653, 41), (654, 46), (655, 50), (656, 51), (666, 55), (667, 56), (668, 57), (669, 58), (671, 59), (672, 60), (673, 61), (677, 62), (678, 63)))),
  ('fora da prova: 5, 10, 15 (novas em revisão)', not exists (select 1 from pp where numero_original in (5, 10, 15))),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('registros intocados (328, 318, 1926, 786): sem prova, enunciado/explicação/alternativas/ativa iguais', (select count(*) = 4 from intocado t join public.questoes q on q.id = t.questao_id
     where q.prova_id is null and q.numero_original is null and md5(q.enunciado) = t.md5_enunciado and md5(coalesce(q.explicacao,'')) = t.md5_explicacao and q.ativa = t.ativa
       and (select md5(string_agg(a.id::text || ':' || a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = t.md5_alternativas)),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pp)))
) v(verificacao, ok);
