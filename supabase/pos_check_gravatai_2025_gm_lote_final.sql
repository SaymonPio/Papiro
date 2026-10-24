-- Gravataí/RS 2025 Guarda Municipal (Fundatec, concurso 1021, caderno 1021.018 — Prefeitura de Gravataí/RS, Concurso
-- Público nº 01/2025) — REGISTRO SANITIZADO do lote aplicado em 2026-10-24. 56/60 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) taxonomia (matéria 36 Direito Ambiental; assuntos 356–366) — ver supabase/manutencao_gravatai_2025_taxonomia.sql;
--   1) executor de aquisição, manifesto d56a35e92ca836f2173c4adfacc19181f18294a2cb6286b8d4ffceadcc39fdbd,
--      modo BASE_GLOBAL: provas.id = 29 (hash_prova 250a3e1432c2…);
--      prova_documentos: GABARITO = PDF oficial do Edital 34-K/2026 "Gabaritos Definitivos" (sha256 95238b47afdb…);
--      Q19 ANULADA pela banca (não importada);
--      39 questões novas (ids 3637–3675), 195 alternativas, nenhum curso_questoes, nenhuma mídia;
--      liberações explícitas com conteudo_hash: DEDUP_OK Q6 (≠328) e Q20 (≠27);
--   2) qualificação do legado (script operacional com texto integral FORA do repositório; lista lida de
--      reconciliacao.json): 17 registros (transcrição Fundatec e TEC) receberam prova_id, numero_original e
--      fonte/concurso oficiais, preservando id, alternativas, gabarito, matéria, assunto, explicação, ativa, vínculos e
--      histórico; enunciado trocado pelo oficial onde a diferença era de espaço/aspas ou o legado era ADAPTADO com
--      explicação auditada COMPATÍVEL (Q4, Q5, Q8, Q10, Q12, Q13, Q15, Q28, Q29, Q32, Q46); duplos: Q12→319 (684 intocado) e Q15→321 (689 intocado).
-- Fora da prova: Q19 (anulada), Q30 (legado 492 sem a Figura 1), Q31 (nova, MIDIA_OK=false — legenda "Legenda:" e crédito
-- "elaborada para esta prova"), Q48 (legado 659 inativo/corrompido — SANEAMENTO_LEGADO_GRAVATAI_Q48_659).
-- Registros intocados (verificação 9): 27 — candidato descartado da Q20 (DEDUP_OK com conteudo_hash); 328 — candidato descartado da Q6 (DEDUP_OK com conteudo_hash); 492 — legado da Q30 em revisão (sem a Figura 1); 659 — legado da Q48 em revisão (inativo/corrompido — SANEAMENTO_LEGADO_GRAVATAI_Q48_659); 684 — duplo não escolhido da Q12 (319 qualificado; equivalência 319~684); 689 — duplo não escolhido da Q15 (321 qualificado; equivalência 321~689).
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 56 questões e os registros
-- intocados continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, midias, legado_qualificado, md5_enunciado_antes, md5_explicacao) as (
values
  (3637, 1, 6, 15, '4583123dbb58060214be167f0c3d6ac0', '65a12c7b562b018758057592c86284fc', 'C', true, 0, 0, false, null, null),
  (3638, 2, 6, 46, '04aa5966ae5932882393aacc7437cc72', 'b5089ea6d9297e598d5be6cabf39ab76', 'B', true, 0, 0, false, null, null),
  (3639, 3, 6, 15, '4093c51209348ca3e47eab6b525eb6eb', '8d001cf568648c1e78b1f176cf153bb7', 'E', true, 0, 0, false, null, null),
  (316, 4, 6, 57, 'bf442734935b7b9bb4efec347c9a4dc7', 'f1f66ad00dee5be41c04b260510f77b4', 'D', true, 1, 0, true, '38da080901405a0774f26ca5e70a54fa', '7ff356e147f1f3974652f54552c8d08e'),
  (317, 5, 6, 59, '0c3df5ee89ba1e419620978f99e40cc6', '0b997c72f0f8bd5da49c8b865bc0eaba', 'C', true, 1, 0, true, '323dd0ec3b0a26c257029ad76ba985c1', '008233cecedc90de13793c9761046f6a'),
  (3640, 6, 6, 5, 'a6bde16872145b4aa5cb746a1451d3a8', '2df4d8ffb64b25bb8c07d557fa690e96', 'A', true, 0, 0, false, null, null),
  (3641, 7, 6, 48, 'cbb291fd06f47260bc4600524cf73efd', '790b151b60547de75dc8bcf8828baf59', 'A', true, 0, 0, false, null, null),
  (693, 8, 6, 54, 'efe76650dd71f0a62baf1772908d9cc3', '1cd9a28afe9f7542775ff1035286b36a', 'C', true, 1, 0, true, '952c52a27c4e97e625e6dc4a30cf8c68', '37f2465068d2c524850c36be21fb5cca'),
  (3642, 9, 6, 57, '7d2ef15b218aada98da756de84664ad2', '2397f3954c15a87b4c473cab21125f26', 'D', true, 0, 0, false, null, null),
  (318, 10, 6, 14, '54e56a94e4e16affc7f68034d7128ef2', '6ace549b199870e4d5ed0ae9050489d5', 'B', true, 1, 0, true, 'e559ba95f7366089f5e252ad8848bf0a', '7881939e46bec4750871421881e6463d'),
  (3643, 11, 6, 363, '3e270d9cf0785558d81a5d6b3eccda9c', '74ddcf0eeee2bd944258f87c827bb672', 'E', true, 0, 0, false, null, null),
  (319, 12, 6, 55, 'ca4c98926e547037ac0f2c8bea234f52', '77f263c698764bb29999e2370e15db83', 'A', true, 1, 0, true, '4b7285014f6408399fcd2e48559400ee', 'ada93860efb935cc9e6df0e645ab8254'),
  (680, 13, 6, 44, '369e5014850b133fd6c52cf14e763436', '813c40743e61c2c3950d4607400c631b', 'D', true, 1, 0, true, 'fad5b8fcd88c06cc3bbb752e7c2ee77b', 'e428064ceb8c561e584a56f4cbe6489a'),
  (320, 14, 6, 56, '3833c0145575a4940eed9dcf7ce1387c', 'eb59c58a99b125751976df43dc5383a9', 'E', true, 1, 0, true, '3833c0145575a4940eed9dcf7ce1387c', 'eb90cb6d7a06297610c68de6fce80766'),
  (321, 15, 6, 53, '4842cf4a04a670fd986e9411512d91ee', '2c2a7d279fd4d471874f2a723409553c', 'B', true, 1, 0, true, '56ebead0fea96df46a03f54f98a86996', 'bb9dfb7d887d77ad6a6a3afa1c5b2ef1'),
  (322, 16, 6, 53, 'eb7e39ba08b33045593d210b1fb8e3ef', '9481456ba3ec1d4548c644052f4cf9fc', 'D', true, 1, 0, true, 'eb7e39ba08b33045593d210b1fb8e3ef', '5bb917dad835a512ee9392995c9c548f'),
  (3644, 17, 12, 291, '2b5867dd6761be9820eaf7953d24fcb8', '72b7416090ac154f562ed9ca4909236c', 'C', true, 0, 0, false, null, null),
  (3645, 18, 12, 291, 'ddfcb621c70bd8a0a3569568f40ffd46', '95924580f5acda7f9c1dfb740b580309', 'D', true, 0, 0, false, null, null),
  (3646, 20, 12, 24, '1619af16571c6fced68ca5431a62c1eb', '2f24ba089cbe960b934bb8a484114c8a', 'E', true, 0, 0, false, null, null),
  (3647, 21, 12, 295, '17936386548f89a4a4a833d39874e694', 'fe40cddc493daea7ad34dfeb71eeea0f', 'A', true, 0, 0, false, null, null),
  (3648, 22, 12, 291, '8df59e8e020795d4ddc25ae82ee52b68', 'd28fbe0dea4a25244ce0e766df43a0bc', 'D', true, 0, 0, false, null, null),
  (3649, 23, 12, 364, 'e7160561d93561207f13de1e6d8186a6', '0c3a0432c41cdab798ccfff606f94ece', 'E', true, 0, 0, false, null, null),
  (3650, 24, 12, 13, 'f2c0d9ce0f45d44c290b0a8737f35d12', '4ebfc0f467f754dd65f36c000fb22960', 'C', true, 0, 0, false, null, null),
  (644, 25, 9, 28, 'f88da28780dbf900044e840cfe926a9c', 'd543ac1c35a301453a481f94b50be57c', 'A', true, 1, 0, true, 'f88da28780dbf900044e840cfe926a9c', 'c6c60fde2fd81cd5bf26da8ba380f673'),
  (3651, 26, 9, 343, 'b29350f78de7b412161aaaea9b8aceab', '5b1420edffe9ed7cd5bfdd64773dccbf', 'D', true, 0, 0, false, null, null),
  (3652, 27, 9, 343, '4a15bc643e78e77656b241993efa7e8f', '03c2ee6d623af7889616c4228143b9cc', 'C', true, 0, 0, false, null, null),
  (628, 28, 9, 61, '41578afeb1fde063c87e70c2b3986bb2', '26efe291f308460bc4c363b602d0aa67', 'B', true, 1, 0, true, 'aa63e4df36b144c6a3f1261e5037e22d', 'aceb8d7104fd1dbb969d2943f4f9879f'),
  (636, 29, 9, 62, '4b56a43abe01f82ed9569dc392b7d6b1', 'b1d5e23bd2fe04a7391eaa8ec1d2862c', 'E', true, 1, 0, true, '5c4378284fd8deb364bd401d502ed47f', '5b355f3018aaec6730d83b5098c8a686'),
  (626, 32, 9, 60, '547b79f0410376d964e530a06e0638dd', '75a7a6987bd21f99aeddeed22385fb2b', 'D', true, 1, 0, true, 'a876a9c8965a00d699ebcd7b3ffa1f55', 'f7147354d7fde151894fa57623ed7859'),
  (3653, 33, 22, 362, '7e08587dc351449578cda3c43af4c0e4', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', true, 0, 0, false, null, null),
  (3654, 34, 22, 362, '2c63e35676bcd99778d5fd1079cb102e', '31ae4d0998e54ac2d990eb62b520f8c2', 'A', true, 0, 0, false, null, null),
  (3655, 35, 22, 362, 'b175f17cd3d8da9f35c3e8ea7c817733', '47aab836874f9ed46088c4f01d9c2b17', 'D', true, 0, 0, false, null, null),
  (3656, 36, 22, 362, 'ea7d051773ceada88ba4c92aaf487188', 'bad6d14a6836ac3139f161b6dc8f7a7b', 'E', true, 0, 0, false, null, null),
  (3657, 37, 36, 356, '7e56d2353704ffc36a9bbd5431622b89', 'bd25ce498f2b297cbfa13c77a223087f', 'B', true, 0, 0, false, null, null),
  (3658, 38, 36, 357, 'ef69b37f7df1cc765efe345f4c98531f', '81fd0ce778419faf46349b995da286a8', 'C', true, 0, 0, false, null, null),
  (3659, 39, 36, 358, 'da99576e2819a20af91196c362dd86b9', 'aa5112f1bf9cf8210f179b0910b7f58d', 'D', true, 0, 0, false, null, null),
  (3660, 40, 8, 361, '9d2400f1331696413efd6986b93225ee', 'aaf667f17a2b793864da1811f1829d17', 'B', true, 0, 0, false, null, null),
  (3661, 41, 36, 359, 'b97b4f994d718feb72455618bfd22ca0', '6373289b10118cfec8d8f82ebc83b0f0', 'D', true, 0, 0, false, null, null),
  (3662, 42, 36, 360, '9bfed6ec815f08c6f4fbb4d7159174af', '21ae85de4f4f71dcb56488acd2cd8e8e', 'C', true, 0, 0, false, null, null),
  (3663, 43, 36, 360, 'fc59a2f842d565611f32afbd5b4ea4d3', 'b60197e87930fe37d227e1c73de20697', 'E', true, 0, 0, false, null, null),
  (3664, 44, 36, 359, 'f49a0f9d756bae7a1f4518d9568da93b', '00d6022e44f525cad318a6fff213cda3', 'A', true, 0, 0, false, null, null),
  (3665, 45, 13, 312, 'fae7eb5e099d688fe660b0efe610677c', '7630ebc8a241a7c2d7745e12ac9a74c1', 'B', true, 0, 0, false, null, null),
  (648, 46, 11, 12, '632736f9da54f22033d1233b38586ff5', '0d6aedf16234e02e06cdd0d88c42bc77', 'E', true, 1, 0, true, '7a568c99b55bc2f9caef3b0ceb070698', '112470889a20284988ac33219b8882e8'),
  (649, 47, 10, 70, 'a1a5e57c532d7b8abb315ddb50a07603', '6f109077768ace436427e6117eb24363', 'B', true, 1, 0, true, 'a1a5e57c532d7b8abb315ddb50a07603', '1beee211c49910d06c7251901211fff7'),
  (3666, 49, 3, 140, '6c13c83f9a1b75a6efc8457669b9e878', 'f8bdbfb00f4ad4326cac5d11a862c26f', 'C', true, 0, 0, false, null, null),
  (650, 50, 10, 70, '78cb1d8b56773432397cb36226e31c5b', '459dbece06ad6f01cea43031e7b15ff4', 'C', true, 1, 0, true, '78cb1d8b56773432397cb36226e31c5b', 'ee6052044887bbd466f544303c4cf6a6'),
  (3667, 51, 2, 1, 'bb959ebb12eca378bbe79cb03cc573cb', '1eb2a18e11525aecb17f95b9a9fa012b', 'D', true, 0, 0, false, null, null),
  (3668, 52, 11, 89, 'fddbd1adbdb2a3167467d80b20fa3cae', '298695b58b99de4076edd27e9420019e', 'A', true, 0, 0, false, null, null),
  (3669, 53, 11, 301, 'f1c69ca50c75c1cb9e3c7c1458c21bf6', '935e580f62db898bd1a13256b60beff3', 'D', true, 0, 0, false, null, null),
  (3670, 54, 2, 124, '4e598ed2f9218d0bfcdacd18e54418bc', '591b46e268d48dd3a96849a6197a8d2e', 'E', true, 0, 0, false, null, null),
  (3671, 55, 11, 318, 'd468049c8a3a9f4585a0118d3f43cd17', 'e6dc70205b227fa2379d4bfd2f46251c', 'A', true, 0, 0, false, null, null),
  (676, 56, 10, 17, 'a064a8da947888ef8767315fd6546228', '17fcd2ebd435dc503691d06794ba75bb', 'C', true, 1, 0, true, 'a064a8da947888ef8767315fd6546228', '1bd5cece29df904c36557f9bbca04e3f'),
  (3672, 57, 4, 3, '687040b8282e42be9f9baf3e7d5dfafa', '2475ecf558e26cbb26eb36309aa22372', 'D', true, 0, 0, false, null, null),
  (3673, 58, 4, 3, '94ffce7e880d3df62a2ea1e51901d46c', 'afd4d748c175d7620058533f16ee297c', 'E', true, 0, 0, false, null, null),
  (3674, 59, 2, 365, 'fb920e367d0f9359058e032c76046576', '3269a28823512acd847bdd3fac0df794', 'B', true, 0, 0, false, null, null),
  (3675, 60, 2, 366, '60309e1d19d99ac02768d1a8bf52ec98', '2b72e40a30855e1ec26447bc472f6369', 'B', true, 0, 0, false, null, null)
),
prova as (
  select id from public.provas where hash_prova = '250a3e1432c250d26a5b60ae6b26c8f9521e0fdf47c653fa6b216aecc8cfddaf'
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
  select id from public.provas where hash_prova = '250a3e1432c250d26a5b60ae6b26c8f9521e0fdf47c653fa6b216aecc8cfddaf'
),
pp as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
),
intocado (questao_id, md5_enunciado, md5_explicacao, ativa, md5_alternativas) as (
values
  (27, '458eb4109aa1be3ea27bdf05520c71ba', 'd6034356270745d4dcfb17edb3987582', true, 'c936aaf79755e078b2c7f18ecfc78955'),
  (328, 'f7bef32de77e100faee1b360841dd6ef', '8f41eb42dbf28ea4ffbd7c6bb42787bd', true, 'cf46384922ccbbc076872a9c72da3a99'),
  (492, '0d258edecffdfc93a5651b95ca3d195d', '93036a2c1506fd7cc3623ca179eb87fb', true, '9d09ef7c3fabf6741ab401f6c32a1ad8'),
  (659, '876ddacb974d0b559a31fc3acdd714b7', '2f97297a62d05d83a2f64d1811c74f72', false, '534abd84d57671d43cac96a52e1d9a4b'),
  (684, '6565d85f4bbee2f9aad70e739cd07bc0', '94ffb226ed0937dbd664378d948c20f2', true, '686f852edca5f6b5192b75ae1004a3a4'),
  (689, '56ebead0fea96df46a03f54f98a86996', 'f8ebb0dd709188b21325377d56d1b4d6', true, 'b4cdd916ac9513efd192d1aa5e811e21')
)
select verificacao, ok from (values
  ('prova_id = 29 (hash_prova 250a3e1432c2…; manifesto d56a35e92ca8…)', (select id from prova) = 29),
  ('prova_documentos: só o GABARITO = PDF oficial do Edital 34-K/2026 95238b47afdb…', (select count(*) = 1
     and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '95238b47afdbdaeacda491195d6dc38f998f362966957f1e869d37640b831d86') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('provas.hash_gabarito = PDF oficial do Edital 34-K/2026', exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = '95238b47afdbdaeacda491195d6dc38f998f362966957f1e869d37640b831d86')),
  ('56/60 oficiais na prova, números distintos, sem parte', (select count(*) = 56 and count(distinct numero_original) = 56 and bool_and(prova_parte_id is null) from pp)),
  ('39 novas = ids 3637–3675, sem curso_questoes, todas com assunto', (select count(*) = 39 and bool_and(assunto_id is not null) from pp where id between 3637 and 3675)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3637 and 3675)),
  ('assuntos novos: Q11 -> 363, Q23 -> 364, Q33–Q36 -> 362, Q37 -> 356, Q38 -> 357, Q39 -> 358, Q41/Q44 -> 359, Q42/Q43 -> 360, Q40 -> 361, Q59 -> 365, Q60 -> 366; matéria 36 nas ambientais', (select count(*) = 16 from pp where (numero_original, assunto_id) in ((11, 363), (23, 364), (33, 362), (34, 362), (35, 362), (36, 362), (37, 356), (38, 357), (39, 358), (41, 359), (44, 359), (42, 360), (43, 360), (40, 361), (59, 365), (60, 366)))
     and (select count(*) = 7 and bool_and(materia_id = 36) from pp where numero_original in (37, 38, 39, 41, 42, 43, 44))),
  ('17 legados qualificados (prova/número)', (select count(*) = 17 from pp where (id, numero_original) in ((316, 4), (317, 5), (693, 8), (318, 10), (319, 12), (680, 13), (320, 14), (321, 15), (322, 16), (644, 25), (628, 28), (636, 29), (626, 32), (648, 46), (649, 47), (650, 50), (676, 56)))),
  ('fora da prova: 19 (anulada), 30, 31, 48 (revisão)', not exists (select 1 from pp where numero_original in (19, 30, 31, 48))),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('registros intocados (684, 689, 492, 659, 328, 27): sem prova, enunciado/explicação/alternativas/ativa iguais', (select count(*) = 6 from intocado t join public.questoes q on q.id = t.questao_id
     where q.prova_id is null and q.numero_original is null and md5(q.enunciado) = t.md5_enunciado and md5(coalesce(q.explicacao,'')) = t.md5_explicacao and q.ativa = t.ativa
       and (select md5(string_agg(a.id::text || ':' || a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = t.md5_alternativas)),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pp)))
) v(verificacao, ok);
