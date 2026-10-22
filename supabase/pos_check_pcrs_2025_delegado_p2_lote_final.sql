-- PC-RS 2025 Delegado de Polícia (Fundatec, concurso 991, Prova Preambular) — P2
-- (Conhecimentos Específicos, caderno tipo 1 canônico) — REGISTRO SANITIZADO do
-- lote aplicado em 2026-10-21. P2 = 77/80 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) migration 20261021120000_prova_partes + taxonomia P2 (matérias 33/34,
--      assuntos 248–268) — ver supabase/manutencao_pcrs_2025_delegado_taxonomia_p2.sql;
--   1) executor de aquisição, manifesto 10334526e510f9392d8334dc878e3f4e9def31fef18be6c5fb37a81d594662be,
--      modo BASE_GLOBAL: provas.id = 19 (hash_prova e9f7b048d7b3…),
--      prova_partes.id = 1 (codigo P2, ordem 2), prova_documentos GABARITO
--      (Ed. 06/2026, f0339d9dce0a…; número da Q73 deduzido pela posição na grade),
--      63 questões novas (ids 3171–3233), 315 alternativas, nenhum curso_questoes;
--   2) qualificação do legado TEC (script operacional com texto integral FORA do
--      repositório): ids 729, 742, 713, 738, 730, 717, 714, 732, 733, 743, 719, 720, 710, 705
--      receberam prova_id, prova_parte_id, numero_original e fonte/concurso oficiais,
--      preservando id, alternativas, gabarito, matéria, assunto, explicação, ativa,
--      vínculos e histórico; enunciado trocado pelo oficial (só espaço em branco) em
--      729, 742, 732, 733, 743, 719, 720, 710, 705.
--      738 (Q24) continua ativa = false.
--      730 (Q40): TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA — o PDF oficial tem erro
--      tipográfico; por decisão editorial explícita (só este registro) o enunciado
--      saneado do legado foi preservado (md5 igual ao de antes da qualificação).
-- Fora da prova: Q18, Q57, Q80 anuladas pela banca.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as
-- 77 questões continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, legado_qualificado, md5_enunciado_antes) as (
values
  (3171, 1, 5, 248, '2ea282e328cdcbe69658c11dde004b67', '77790fca97cfc3359067de4565b31ebc', 'B', true, 0, false, null),
  (3172, 2, 5, 248, 'a241ded21084b82c66e440ff98f3136d', 'e96240c0bb5fdf94fb7c01c8b1cb8116', 'D', true, 0, false, null),
  (3173, 3, 5, 248, '7b5b4f3e78a40966c4da03ced06c9c86', '281dcfc4b063426ce846395f2b48d353', 'B', true, 0, false, null),
  (3174, 4, 5, 248, '9b8b748da037dd76d6853b1fc8269861', '7c0d1ad29758bb3f42b5ecef06223b9b', 'A', true, 0, false, null),
  (3175, 5, 5, 249, '16511a20edfe694d12b676cb5095b2d3', '156dcb2a6cea70dbd13c8543f8ada609', 'A', true, 0, false, null),
  (3176, 6, 5, 250, '63b8696b306b81723a547664f6d99411', '8e30c39a0537a150b0706f2ff185cf42', 'B', true, 0, false, null),
  (3177, 7, 5, 251, '72b32f9bfd51f13a5efbcdc895bfc1fa', 'e96240c0bb5fdf94fb7c01c8b1cb8116', 'D', true, 0, false, null),
  (3178, 8, 5, 4, '21bb702c7129cd3053464c38a3961934', '71fbf0a388eda1c8ac5b1f9728d365d9', 'A', true, 0, false, null),
  (3179, 9, 5, 252, '98ae60aa7836eaa00584b2f7d4ea6438', '34c63a4f692d4ce8a43bb722dad378cb', 'E', true, 0, false, null),
  (3180, 10, 8, 255, '2274003ad607607b982c904ffcac5565', '9a57fc1b78c1cfbb4b42804acdab9b48', 'D', true, 0, false, null),
  (3181, 11, 8, 253, '28e01a58b78034ad41eae77fbdca09b8', '0901e65c9698a92fee38c3ca6e920ae1', 'C', true, 0, false, null),
  (3182, 12, 5, 252, '0e79ca4c951089df95285d059e6a45b7', 'd68c2cf08bbdb64e72965b048fd04cc1', 'C', true, 0, false, null),
  (3183, 13, 8, 254, '3b62669ec6aeb83c78140a75909cccdb', 'c43f2b3253a816e9bb3c17c6c2f49f9f', 'A', true, 0, false, null),
  (729, 14, 10, 68, 'ae01dd6312556df23fa464aec74252cc', '00b512d753c543cee400243414fac722', 'E', true, 1, true, '56d3684d54b513d305fecfaa5b590ee2'),
  (742, 15, 10, 78, '4d35733947cab0ae7c964e4a07ef7a11', 'f2fa1247172e5cff530f4c90056d0ff2', 'E', true, 1, true, '6825ae1fdf4a6b415995be6156bbc688'),
  (713, 16, 10, 79, 'fc6bea57b6d1fe4c2c9f3e6b2ffc9e8b', '4b04bb7691034c952b86ee7b56e6d489', 'B', true, 1, true, 'fc6bea57b6d1fe4c2c9f3e6b2ffc9e8b'),
  (3184, 17, 8, 256, 'ed910a142ae4ce19784408a8e613f95b', '3f424940e6e2a6948281bccc080e8965', 'C', true, 0, false, null),
  (3185, 19, 5, 250, '27bb302c60b1aba1289d9d87b97b4c53', 'a3b31e2a66c59631be66152c26e69757', 'C', true, 0, false, null),
  (3186, 20, 5, 249, '9d1831b7a0b05d96fc0f9f9aeff72e43', '7b1ed11e021f329b63168855eecf71e9', 'D', true, 0, false, null),
  (3187, 21, 7, 6, '7c469986764acfa0240e790dea32a0dd', '8dc49f799fd49d3a15c577950926ce6a', 'D', true, 0, false, null),
  (3188, 22, 7, 257, 'f51f6d4fa3a715d2edb1110db6a3eacb', 'a6fac297e745f17517c44ffaa2721c61', 'E', true, 0, false, null),
  (3189, 23, 7, 6, '96bd25125cb31e7c9f4a6fd1b43c8d99', '9b98a63e4764865a143012d79daccab2', 'C', true, 0, false, null),
  (738, 24, 10, 19, '3c6beb6f3b7e4fc814d703b2f172ae11', 'f2eaf36ab83aea52765cc4a651203af2', 'C', false, 1, true, '3c6beb6f3b7e4fc814d703b2f172ae11'),
  (3190, 25, 7, 7, '37c6af787586dbc97d6c5bfa28d2ee77', '5ec54192ce6e1586f9f68f4cdd88062e', 'B', true, 0, false, null),
  (3191, 26, 7, 179, 'b710f0708d67bb779d5336cf6dd4054b', '6e137c684a42146b9f1cbddccf47a335', 'E', true, 0, false, null),
  (3192, 27, 7, 257, '3335343775bd3b2b9f088e03694672e3', 'c0db2f875f391bd0bdce3aaacd8a10ec', 'B', true, 0, false, null),
  (3193, 28, 7, 179, '61cb6fb11406f4f49b7e3db2ace21d20', '7ba078cf8371a49a8423fd41afdaf90b', 'A', true, 0, false, null),
  (3194, 29, 7, 6, '1ed74fbf51a9683a27f74547af1a1a6e', '8b712e3f30e2b3b3ac7e960e2b2726f5', 'D', true, 0, false, null),
  (3195, 30, 7, 258, '1b37909e17105255ee3d74c9b530ea66', '15e43fbd820bc537f80ac89a96171e2c', 'B', true, 0, false, null),
  (3196, 31, 7, 6, '4f7349d4228c272deb3bf1077e8f8ed0', '793f82259b5a4ba2662ace3b637e684e', 'A', true, 0, false, null),
  (3197, 32, 7, 179, '899c785cd7d4b2369d1bc3cb6136f538', '4b2ae4c60fb36ec3e68ca8f4f115961b', 'C', true, 0, false, null),
  (3198, 33, 7, 257, 'd56679d2275dfc65139e2132a6397bb3', 'f1093998aa5b14db08b4de2379dabadc', 'D', true, 0, false, null),
  (3199, 34, 7, 259, '335fbabd92f9a3ce86bd20b716277402', '453105a8e9c59746d40b25a2f0ab8356', 'E', true, 0, false, null),
  (3200, 35, 7, 257, 'dba1d8c9a48a005c52800b46b2a4d85d', '23ebbd7efd582e9fd22d04a8f75f82f1', 'B', true, 0, false, null),
  (3201, 36, 8, 254, 'd6b458d86b0dfb79a2437141a68c1329', 'c63e8c44b956f4668ab31b44ab2a4792', 'D', true, 0, false, null),
  (3202, 37, 7, 179, '7c5ee776bf541e23dd3f2a06ced65344', '7a0cc405a7b310987820b5e956676123', 'C', true, 0, false, null),
  (3203, 38, 8, 253, '660bbcae434b7a880dbeb7062f3f19a6', '37a6ebd4644bddfb1c8dceb8613df8e2', 'B', true, 0, false, null),
  (3204, 39, 7, 6, 'c34a889a799f949d19e044f6a366a355', '1ff9be9bdc37ab76b506b3e1066f7876', 'A', true, 0, false, null),
  (730, 40, 10, 68, 'de62953c190c8a11b0559cfe3f32f16b', '005025446c2ec4276ac9e086e66d97e8', 'E', true, 1, true, 'de62953c190c8a11b0559cfe3f32f16b'),
  (3205, 41, 16, 260, 'cc0e4fd0802f411e658640d49193d186', 'ea809d970962f8578ab6cdee790f283e', 'E', true, 0, false, null),
  (3206, 42, 16, 261, '91ee6d82903ee4d2dd1407ad1c0c0be5', 'd8d481b05763c2e6f2dc099b68bf912b', 'B', true, 0, false, null),
  (3207, 43, 16, 180, 'a71fc3ffdff427c0fd5c01f9e9f8fa0a', '3c40353621df316d3c1ef5c310e666fd', 'C', true, 0, false, null),
  (717, 44, 10, 70, '9b52b4427b2939575caec8c2c410eec6', 'b10a3c472571b8b238237bf61409eba9', 'A', true, 1, true, '9b52b4427b2939575caec8c2c410eec6'),
  (3208, 45, 16, 262, '1ce5bbb967a1e230ff28c779dedb1124', '1cc998a70da1e0f01a926a06cd4fb8c8', 'A', true, 0, false, null),
  (3209, 46, 16, 181, '4d1b8091820fc710e7ad8d2f3df67064', '83f9f4dff04585df6513708ad8005056', 'B', true, 0, false, null),
  (714, 47, 10, 67, '55a746a23fafe2183c15d18121acdbfd', 'b321331ac7eb6ea8d75741371fbc55ee', 'E', true, 1, true, '55a746a23fafe2183c15d18121acdbfd'),
  (3210, 48, 16, 180, '35c94a0a8b8a6ffc7206083c07d227a7', 'e13fef7f8baa9f76ef94406108ece530', 'D', true, 0, false, null),
  (732, 49, 10, 64, 'b3ee0bd014d35a685ff77fcdbbf840b4', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', true, 1, true, '9c17ceb6277deebddc55e9d6bf74f54e'),
  (3211, 50, 16, 260, '1075213c02a7d134d3692134dc38b6f0', 'd102043c016e10326c3881553123d852', 'D', true, 0, false, null),
  (3212, 51, 3, 263, 'b330dec4f20100602338a179fdc5acfd', '53b08294be9635f8bd99c8a6da9a31d0', 'A', true, 0, false, null),
  (3213, 52, 3, 263, 'caad26a1795e429d3d997c31a3ba2a84', '53b08294be9635f8bd99c8a6da9a31d0', 'A', true, 0, false, null),
  (733, 53, 10, 66, 'c9b315a17bd80293d6866c667fcd3b55', 'c434f4911cb768c582ca308c59de8d8e', 'C', true, 1, true, 'de3c8c59d25528fbc438be73309863bf'),
  (3214, 54, 3, 2, '2da2a5a6f8815ebb37518f75122ca51e', '8869deb631aa47ccb2c0dde2695a54c1', 'B', true, 0, false, null),
  (743, 55, 10, 17, 'b74902fca30d0850505b4186610b02dc', '8f647c915241be5ec07d1611b051494b', 'B', true, 1, true, 'f45f40c12fd29cab098aff23c52d2a87'),
  (3215, 56, 3, 140, 'dbd0dd5968479abc44db4440961cfccd', 'dfc40a0fe7acf8598fb736d65444e2ee', 'E', true, 0, false, null),
  (3216, 58, 3, 264, '8519799d616feaf3bec66a113beb66ce', 'a1675857977dca7f25ef115ccd6b1417', 'E', true, 0, false, null),
  (719, 59, 10, 80, '891ab0532e2cdffcd40b39c3b0aadb48', 'fb3e12ba5ccca5e80efefb007afce920', 'E', true, 1, true, 'e9e944deae7ca8115c0a64f469a6a2e2'),
  (720, 60, 10, 80, 'dba4713b090a1fda4cacf312986f2c68', 'e4dcbb05613c9a9780b756549c834f5d', 'B', true, 1, true, '06bb8e2e50c5a644542c6b75f4de7650'),
  (3217, 61, 33, 266, '6f0ba8223793d5402b8a4646a00d1fcc', '70cc6a3fcdf2c91f4e31b6af5edba191', 'D', true, 0, false, null),
  (3218, 62, 33, 265, 'f3947fa77cd89d350594a8c610c91de5', '379d8159b868d16588db83be8a0bcad4', 'A', true, 0, false, null),
  (3219, 63, 33, 265, '8411c6d74a388ff579e5f32acc27e9e1', '379d8159b868d16588db83be8a0bcad4', 'A', true, 0, false, null),
  (3220, 64, 33, 265, '5d9a3d6f11804b32a75f2001a791c8b6', '357ecb55e00ca89f69cf849bdf42eb56', 'B', true, 0, false, null),
  (3221, 65, 33, 266, 'b4d6122d8ece3c07e769df451c739299', 'd8eced9f5b42dcb0e91af3488a569d8b', 'C', true, 0, false, null),
  (3222, 66, 34, 268, '26b940f00312c086ff63524da27ad5e3', 'd8749eae3e1406a8496519d2fa45465b', 'B', true, 0, false, null),
  (3223, 67, 34, 268, '1444a0bea71677ff446b312db9338de7', 'dc3620ff1a1d34ad92234eb9fb254df9', 'A', true, 0, false, null),
  (3224, 68, 11, 267, 'd368ab030794849aea26a85ef7b2e2cb', '88dcb80a211da075dafbc66b47c7db6f', 'D', true, 0, false, null),
  (3225, 69, 11, 102, 'b7428b84a6d3a036cd11f3580d08a814', 'fa7b8bb0de497f61b9588fd9f19bc8cf', 'E', true, 0, false, null),
  (3226, 70, 11, 98, 'bc7c3586e9fe3c0699b1d8cb8da829c6', 'ceec2fb85a5bb1df2dfd10ac3af818ca', 'C', true, 0, false, null),
  (3227, 71, 17, 175, 'abe970f25bcef2d50dba29a954b2c12a', '63dc9d79bc36971cbfd3c3f3db94f6e7', 'C', true, 0, false, null),
  (3228, 72, 17, 174, '4ef41a227a9c11965056cd9ef4401e91', 'bc4dcde058f6801e797c37c8af769843', 'A', true, 0, false, null),
  (3229, 73, 17, 175, '26292a1e36e0eea4e1d94484ddfb67dd', '371e5e9e5cf090532fc53b45aacc0f21', 'E', true, 0, false, null),
  (3230, 74, 17, 175, 'f32108a7b2ef7782b3a8f17b65732859', 'd0ace7dada2f0f4b159408042f5fe900', 'D', true, 0, false, null),
  (3231, 75, 17, 175, 'f3cd958802359b6509e2f337d5ae1064', '0587a62af0b86b4954674c5426bbca32', 'B', true, 0, false, null),
  (710, 76, 9, 10, '394a3e8443aaddbf828df45c9e13a252', '69b8ba1451a9b14e901fabf9e9aa8705', 'A', true, 1, true, '6a0c8eccbe0fa1fc29b7a44cd14f88b3'),
  (3232, 77, 15, 172, '19b5e5a0ac37721c00c9f153e41462b6', '844c056296024c54153035c519b0404a', 'B', true, 0, false, null),
  (705, 78, 9, 62, '575a19975480132ee122a545adadef29', 'ea877860fc1ce5bf0228659f3f60d017', 'C', true, 1, true, '2574284e98a12efc8241fadc759fc37b'),
  (3233, 79, 15, 172, '1729d57bd3fd8f7d72932bfc35ddf898', '7f9e7cf683113b85496bd1d5a95af3b1', 'E', true, 0, false, null)
),
prova as (
  select id from public.provas where hash_prova = 'e9f7b048d7b349e32dc25b1414babd3c1a7cc095add5e90a9a01fd570d479927'
),
atual as (
  select q.id, q.prova_id, q.prova_parte_id, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, q.ativa, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
         (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos
    from public.questoes q
)
select e.numero_original, e.questao_id, e.legado_qualificado,
       (a.id is not null and a.prova_id = (select id from prova) and a.prova_parte_id = 1 and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id is not distinct from e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa = e.ativa and a.vinculos = e.vinculos) as ok,
       e.legado_qualificado and e.md5_enunciado_antes <> e.md5_enunciado as enunciado_substituido,
       case when e.questao_id = 730 then 'TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA'
            when e.questao_id = 738 then 'ATIVA_FALSE_PRESERVADA' end as registro_especial
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = 'e9f7b048d7b349e32dc25b1414babd3c1a7cc095add5e90a9a01fd570d479927'
),
p2 as (
  select q.* from public.questoes q where q.prova_id = (select id from prova) and q.prova_parte_id = 1
)
select verificacao, ok from (values
  ('prova_id = 19 (hash_prova e9f7b048d7b3…; manifesto 10334526e510f939…)', (select id from prova) = 19),
  ('prova_partes.id = 1: codigo P2, ordem 2, nome oficial', exists (select 1 from public.prova_partes pp where pp.id = 1 and pp.prova_id = (select id from prova) and pp.codigo = 'P2' and pp.ordem = 2 and pp.nome = 'Prova Preambular - Segunda Parte (P2): Conhecimentos Específicos')),
  ('prova_documentos: só o GABARITO f0339d9dce0a…', (select count(*) = 1 and bool_and(d.tipo = 'GABARITO' and d.hash_sha256 = 'f0339d9dce0aba5ae9a76914e2b58f69e6b5d63462b5b7c3418a2cd6c695c26e') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('77/77 oficiais válidas na P2, números distintos', (select count(*) = 77 and count(distinct numero_original) = 77 from p2)),
  ('toda questão da prova está na P2', not exists (select 1 from public.questoes q where q.prova_id = (select id from prova) and q.prova_parte_id is distinct from 1)),
  ('63 novas = ids 3171–3233, sem curso_questoes', (select count(*) = 63 from p2 where id between 3171 and 3233)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3171 and 3233)),
  ('14 legados qualificados (prova/parte/número)', (select count(*) = 14 from p2 where (id, numero_original) in ((729, 14), (742, 15), (713, 16), (738, 24), (730, 40), (717, 44), (714, 47), (732, 49), (733, 53), (743, 55), (719, 59), (720, 60), (710, 76), (705, 78)))),
  ('anuladas 18, 57, 80 fora da P2', not exists (select 1 from p2 where numero_original in (18, 57, 80))),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from p2 where (select count(*) from public.alternativas a where a.questao_id = p2.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = p2.id and a.correta) <> 1)),
  ('738 ativa = false', exists (select 1 from p2 where id = 738 and ativa = false)),
  ('730 TEXTO_OFICIAL_DIVERGENTE_POR_ERRO_DA_BANCA: enunciado saneado preservado', exists (select 1 from p2 where id = 730 and numero_original = 40 and md5(enunciado) = 'de62953c190c8a11b0559cfe3f32f16b'))
) v(verificacao, ok);
