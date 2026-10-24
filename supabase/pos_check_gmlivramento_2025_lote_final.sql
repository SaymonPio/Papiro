-- GM Sant'Ana do Livramento 2025 (Fundatec, concurso 1023, Guarda Civil Municipal) — REGISTRO
-- SANITIZADO do lote aplicado em 2026-10-24. 68/70 questões oficiais consolidadas.
--
-- Operações (já aplicadas):
--   0) taxonomia (assuntos 286–302) — ver supabase/manutencao_gmlivramento_2025_taxonomia.sql;
--   1) executor de aquisição, manifesto b755086d2a8732ccb2ee15d21996e113d2ff0185cac2e533c94682edb3345ccc,
--      modo BASE_GLOBAL: provas.id = 21 (hash_prova 7f7e09f7e3e1…), prova_documentos GABARITO
--      (Ed. 9/2025, definitivo, 2715df794a32…), 61 questões novas (ids 3295–3355),
--      305 alternativas, nenhum curso_questoes; liberações explícitas com conteudo_hash:
--      Q1 DEDUP_OK (≠ 328), Q12 DEDUP_OK (≠ 2878), Q13 e Q20 EXTRACAO_OK;
--      Q46 com 1 mídia (questao_midias.id = 6, FIGURA 591x383, p. 11, OFICIAL_PROVA,
--      sha256 993ed2333a9a406e1ac2568922b92c106fa931f7683aae72ffd6ef8bb2d84057);
--   2) qualificação do legado TEC (script operacional com texto integral FORA do repositório):
--      ids 739, 748, 752, 755, 761, 762, 767 receberam prova_id, numero_original e fonte/concurso oficiais,
--      preservando id, alternativas, gabarito, matéria, assunto, explicação, ativa, vínculos e
--      histórico; enunciado trocado pelo oficial em todos — 761, 767, 752, 748, 762 adaptados pelo
--      TEC (explicação auditada EXPLICACAO_COMPATIVEL), 755 e 739 degradados (espaço/aspas).
-- Fora da prova: Q49 anulada pela banca; Q63 → 697 REVISAO_EDITORIAL_PENDENTE
-- (EXPLICACAO_INCOMPATIVEL com as alternativas oficiais) — registro 697 intocado.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as
-- 68 questões continuam exatamente no estado deixado pelas operações.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa, vinculos, midias, legado_qualificado, md5_enunciado_antes, md5_explicacao) as (
values
  (3295, 1, 6, 5, '50b1bf279702fd89cf6c2cbb90bf2471', '6368ca60257662e3d6af8579ed12ebf0', 'A', true, 0, 0, false, null, null),
  (3296, 2, 6, 15, 'd2e6edc00de8d5d03fc68f4b02ac7bee', '4ca8dc4592522e089996fdfcfe5b000b', 'B', true, 0, 0, false, null, null),
  (3297, 3, 6, 15, 'ff065f06695fdc0c2681067436f41bc0', 'd6a1fffd76891a890ba810b5f47ecda1', 'A', true, 0, 0, false, null, null),
  (3298, 4, 6, 15, '046fe01bee26a83fc651bbc17ba6ece5', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', true, 0, 0, false, null, null),
  (3299, 5, 6, 15, 'bdeb345626b7f47c5af4a674d3f2eee4', '2d701970c13e10f3117bf3e2bd75106f', 'E', true, 0, 0, false, null, null),
  (761, 6, 6, 53, '563fab45b995f6da8f146ee3b0bca8b0', '1ac2930364c1dc24747e22b0c8552631', 'A', true, 1, 0, true, '502eb5aaedf5293e8998bee484e183c9', '433a58515ddf8d245cb36cf90ce97536'),
  (3300, 7, 6, 30, '7a452c6747ac496accf9cc8b6c6c9572', '679fd7b8aff3860947d6d821ca18dc7c', 'B', true, 0, 0, false, null, null),
  (3301, 8, 6, 15, '2999f37d4033f33398056721ecee6681', '1f75fc2fa44e25a52123133b79b7fffb', 'D', true, 0, 0, false, null, null),
  (3302, 9, 6, 59, 'cde50a2d7de098f20facbee70794b7cd', '11a31519a3625b574e73c508a51d4649', 'D', true, 0, 0, false, null, null),
  (3303, 10, 6, 58, '5749c676f629819dc5c25c7178b4c6e6', '5c8e957db6c0aebb7eebcfa9e2654827', 'E', true, 0, 0, false, null, null),
  (767, 11, 6, 54, '4a9b6669ef4dd64f4a757c38519075df', '814d7fd8d77979a9c03593d9e11e9eb3', 'C', true, 1, 0, true, '8179c14d9563c94f2ac2b346e226e118', 'c7543f2d9a490e59b45b444858306478'),
  (3304, 12, 6, 30, '8694a52fdfa287d16921ae640ceb7654', '9cc07c0c04908a5aa5317f784a8d0a51', 'A', true, 0, 0, false, null, null),
  (755, 13, 6, 45, '3293d140d52e81aec46e1f65af5895bc', 'd0df304200d9196b18c7edf0518db8c0', 'C', true, 1, 0, true, 'c2ca3172146c137f31df9554f04eba6c', '97c70f385c14cef7ccd22625c209748e'),
  (3305, 14, 6, 57, 'b48c6b303d184b711d834bc3ce0cf6ae', '3a23e8b7439614e3a6ce9d25ed742a33', 'E', true, 0, 0, false, null, null),
  (752, 15, 6, 47, '2c132fb2d05b0d1c5738563b9a1c5ed7', '601b9f47eabb08b0564d9c9655de5e46', 'A', true, 1, 0, true, '2d63047b20fc958742056db4bfcbf335', '41004ccc4733d32e795d2aa579d5901a'),
  (3306, 16, 6, 47, '30690f923f5a6c70ffd09eb9092bea95', '20cf51f1071b7f6dd3b6e4cf855d139e', 'B', true, 0, 0, false, null, null),
  (3307, 17, 6, 51, '56d57ef8775d810350214c3da84a7011', 'c4abff3d0bb3ad8e7443e836a2316f37', 'D', true, 0, 0, false, null, null),
  (3308, 18, 6, 30, 'f063fd08c481bd39b758e39a45a50485', '555ae0a30b3056a5faa7807eaddaa2d7', 'C', true, 0, 0, false, null, null),
  (748, 19, 6, 44, 'f920885e072eb4ee099a380603680a49', '1581aceafad9759ba0ccb483befe7b5d', 'D', true, 1, 0, true, 'a82d81019ef7ca2d0551f2738b85f035', '35508ea7cd69b58ffd445535a2702a6b'),
  (762, 20, 6, 53, '4b4cf31c6ce9debafcc311805441d2b7', 'fa9384d8dc937a7b326807e19d57a559', 'C', true, 1, 0, true, 'b00ddb177eef06d62b6f729c2fc0a4c8', 'cd4e0c71633a0ae0d19e8af05df26aff'),
  (3309, 21, 22, 286, '6aeff4e007a30bca4290666c0077abfd', '96faa98cd53065f6505e6b35a98ee7c4', 'E', true, 0, 0, false, null, null),
  (3310, 22, 22, 286, '12f97db3cc141b23c1f40fb4939a01a1', 'dcb66f336c08f4e81bd26ed89362c8d7', 'D', true, 0, 0, false, null, null),
  (3311, 23, 22, 286, '698f47097d90a13c44f95caab5169568', '8f235bd407804b920e1499073b256b79', 'D', true, 0, 0, false, null, null),
  (3312, 24, 22, 286, 'ae2b3204537e910b732cdc619f0e16d8', '7cf4062e7877d1f5f5c9d8c3813e4535', 'A', true, 0, 0, false, null, null),
  (3313, 25, 22, 286, 'e83a7767c2bc20bd306fe04c63ed9c18', '50607b6eacfad23a4320986246be7dcd', 'C', true, 0, 0, false, null, null),
  (3314, 26, 22, 287, '88ca1a476591cec7f3cc36219fd37da2', 'c5a8c2ec6d3a0898b113cf2d0ef993b9', 'D', true, 0, 0, false, null, null),
  (3315, 27, 22, 287, '11ee263ecfefb4cea2f71728e1688120', 'bc40df7cc1c32ccac27e0bbd66d42013', 'E', true, 0, 0, false, null, null),
  (3316, 28, 22, 287, '2dc56bc5a91c3f8284f82ac881af7320', 'd7cca464af6f715e8063198fa93b02ce', 'A', true, 0, 0, false, null, null),
  (3317, 29, 22, 287, '6d6afe46dce10b85ae4f0a4e4a34de3d', '992bc8ddd282a1643947bbb43e5cba0e', 'B', true, 0, 0, false, null, null),
  (3318, 30, 22, 287, '78b3a783a7af088e4f3d1381658b7c7e', '12399a77ec46790f3ebb92e9b7399d6a', 'B', true, 0, 0, false, null, null),
  (3319, 31, 22, 287, '61d36dbee6e19e7e348227e629702c60', '46a681b8c47e49608c0a37c643799077', 'D', true, 0, 0, false, null, null),
  (3320, 32, 22, 288, 'fbe36cedffbd456e130844697b4a9252', 'da217ae302b80f2c1f52729b9efe1691', 'C', true, 0, 0, false, null, null),
  (3321, 33, 22, 288, '0850bafc87304d10709f36ea79bb54ce', 'b5762a53529bb640ee12e59b4b760867', 'E', true, 0, 0, false, null, null),
  (3322, 34, 22, 288, '78fe72f5e0f358b628b7cfd95c499ecb', 'b73f66aa7976fd6b1e1c944efdc6cc07', 'B', true, 0, 0, false, null, null),
  (3323, 35, 22, 288, '2bc673e0091dc5673c6dc2c96b6e66ec', '1c2173f17a680b2ce2492de258eca0ad', 'B', true, 0, 0, false, null, null),
  (3324, 36, 22, 289, '79e4b166cca6f9e96299367b597ad02a', 'ef404696b12d40908996d443c88a5a42', 'C', true, 0, 0, false, null, null),
  (3325, 37, 22, 289, '12e7e818861050d4f6853794dd52fc80', '506232533fdc5ba569e710a86e715d38', 'E', true, 0, 0, false, null, null),
  (3326, 38, 22, 289, '4e371cf3f65954ca3cb06a9ba97b05ad', 'bf942419cd92c740421c4db99fd6225e', 'A', true, 0, 0, false, null, null),
  (3327, 39, 22, 290, '264e8b73f591a6a661b4ea78af2cd204', '40a91da9f9e6ea3d4adf1f9909e74643', 'B', true, 0, 0, false, null, null),
  (3328, 40, 22, 290, '69cf89d54195bd4b1408edcab8e4a461', 'a572297295c9269b9f69d990734a5d94', 'E', true, 0, 0, false, null, null),
  (3329, 41, 12, 291, 'fee473f34fb40504f8f4aa83dd866eb0', '9135e5a26307b18743d3fd9b3f7c2e40', 'E', true, 0, 0, false, null, null),
  (3330, 42, 12, 292, '635f1e06fa0f9bdaa151d16b7a45cb99', 'a9ae30dea1bba612add0353e2a16b35b', 'B', true, 0, 0, false, null, null),
  (3331, 43, 12, 293, 'd7f0776eaf99fc811e689a13947ea60d', '55235f0f856a8f5448de57ab97602746', 'D', true, 0, 0, false, null, null),
  (3332, 44, 12, 294, 'bf7f6913d3b23a2d5e7257ed7ed52c52', 'dfc558f22aebcb2dd12e8dc2f013eaf8', 'A', true, 0, 0, false, null, null),
  (3333, 45, 12, 295, '3f8906134d4c8defa17b04eb272c3afb', '5fb59777db606c33905967a960316145', 'C', true, 0, 0, false, null, null),
  (3334, 46, 12, 295, '018392f94f7207f73f951ef3069ad091', '19823b1347685265fb6adaa0ba9d1f53', 'E', true, 0, 1, false, null, null),
  (3335, 47, 12, 296, '243415e03408b60674b92aac9670852c', 'a0063bde687c95e253ff3b82d6a6319e', 'D', true, 0, 0, false, null, null),
  (3336, 48, 12, 24, '7da0b45a9beb1997bd54707d65a0532d', 'b3db9d80910b1ea54aafe84cf395c75c', 'B', true, 0, 0, false, null, null),
  (3337, 50, 18, 35, '02b76f0d9bf49c85b001d2969f6d5297', 'a405001046b660ee7df88692d5070767', 'A', true, 0, 0, false, null, null),
  (3338, 51, 4, 297, '9d9dd370dc629b9ba03fce55c10c3110', 'f29a06048b403f4043067578ea44447b', 'E', true, 0, 0, false, null, null),
  (3339, 52, 4, 297, 'd1e86a28aa471d74e28ac5c372f770fa', '7792131b5aaf86ffcbb47b182e017261', 'D', true, 0, 0, false, null, null),
  (3340, 53, 4, 298, '22b3a88bb673e23c07dd1dec6c9e56de', '5cae61f8f6b8b3a819abdcbc052f8428', 'E', true, 0, 0, false, null, null),
  (3341, 54, 4, 299, '1de3f46a831d50760b131f6d95b2ec8b', 'da4fbcf6839f730d58c3702f42f799bd', 'B', true, 0, 0, false, null, null),
  (3342, 55, 33, 302, 'e474571921e580235ae8fc92b9b1d1b2', 'ff64646549cb6e09a21b21b9af4178ed', 'B', true, 0, 0, false, null, null),
  (3343, 56, 8, 145, 'fdcff00e1bab5203bf3c5d29155ccbd7', 'a276e480a552ffa996e043decc7b220d', 'D', true, 0, 0, false, null, null),
  (3344, 57, 33, 302, '4adb93a995171326a9dac1d11bae161c', '5883453db369d8c11d5f0ba01e60bb3e', 'C', true, 0, 0, false, null, null),
  (3345, 58, 4, 299, '9ae31ddfcba96d912bea2198ef41d837', '714ad63ed34800ca26e5279dba1a5185', 'A', true, 0, 0, false, null, null),
  (3346, 59, 8, 144, '6a5219e4ce6e0b4d9989dcf61ff9e648', 'bbae530424945ea9746daf95872743bf', 'E', true, 0, 0, false, null, null),
  (739, 60, 10, 19, '94872f40bae5b02f70d553fa4b018695', 'd4294ddca984ef9c764d8e0a86c78280', 'C', true, 1, 0, true, 'defef46493599d9cec74980c0fdd0fb8', 'a0eafad3a4295b06c6793d5014a7acee'),
  (3347, 61, 2, 1, 'e841e29f269956e5826bfd217438626b', 'eb2377eb3d1073b745dd259cb3b6357d', 'C', true, 0, 0, false, null, null),
  (3348, 62, 2, 1, '69e4a775b5ce37a5727c35bc77400cdb', 'f15984d0d2be815ed850bd98bf3a2f02', 'B', true, 0, 0, false, null, null),
  (3349, 64, 11, 301, '6fb7f49451d7de80a3fa9a68b46446d7', '71d34d85233317150b2143d37e298257', 'D', true, 0, 0, false, null, null),
  (3350, 65, 8, 9, 'a4e1d23c048b01ff79bed075881eebfd', '050bc8b907590e1bcaec9e01a2956fe5', 'B', true, 0, 0, false, null, null),
  (3351, 66, 4, 300, 'db6bd6205c1320282815c7b812ed0850', '55c6d76bf45417040220934ced4434a4', 'A', true, 0, 0, false, null, null),
  (3352, 67, 5, 250, '62518efa278700db6d998ef08eff89fb', '632189ebc72be32b6ff84b975e3b6fc9', 'A', true, 0, 0, false, null, null),
  (3353, 68, 2, 124, '30cb71546bc9c6dbf052edb843b9f199', '69f10e3b90599cade98f1c1681451243', 'C', true, 0, 0, false, null, null),
  (3354, 69, 5, 250, '4de442b122635baceda94b8d2b304411', 'a7018dd2e737b1951b5eccb823bef9e3', 'E', true, 0, 0, false, null, null),
  (3355, 70, 8, 143, '09d48c972201e1027d9ec42cf6aa2afe', '48f93a595d83909fe32e72ae036f8ac0', 'C', true, 0, 0, false, null, null)
),
prova as (
  select id from public.provas where hash_prova = '7f7e09f7e3e10f533e82cde1a5bdbb975e6e073ec9da90a0cda2ad029affa51f'
),
atual as (
  select q.id, q.prova_id, q.prova_parte_id, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, q.ativa, md5(q.enunciado) as md5_enunciado, md5(q.explicacao) as md5_explicacao,
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
  select id from public.provas where hash_prova = '7f7e09f7e3e10f533e82cde1a5bdbb975e6e073ec9da90a0cda2ad029affa51f'
),
gm as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 21 (hash_prova 7f7e09f7e3e1…; manifesto b755086d2a87…)', (select id from prova) = 21),
  ('prova_documentos: só o GABARITO definitivo 2715df794a32…', (select count(*) = 1 and bool_and(d.tipo = 'GABARITO' and d.hash_sha256 = '2715df794a3237ed42280a6837afeeeb15f8d7f758ecb7996c6faa68ce4d6e62') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('68/70 oficiais na prova, números distintos, sem parte', (select count(*) = 68 and count(distinct numero_original) = 68 and bool_and(prova_parte_id is null) from gm)),
  ('61 novas = ids 3295–3355, sem curso_questoes', (select count(*) = 61 from gm where id between 3295 and 3355)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3295 and 3355)),
  ('7 legados qualificados (prova/número)', (select count(*) = 7 from gm where (id, numero_original) in ((739, 60), (748, 19), (752, 15), (755, 13), (761, 6), (762, 20), (767, 11)))),
  ('Q49 anulada fora da prova', not exists (select 1 from gm where numero_original = 49)),
  ('Q63 → 697 REVISAO_EDITORIAL_PENDENTE: fora da prova e intocado', not exists (select 1 from gm where numero_original = 63)
     and exists (select 1 from public.questoes q where q.id = 697 and q.prova_id is null and q.numero_original is null
       and md5(q.enunciado) = '64b05846295a09fae2d491e91aee6c66' and md5(q.explicacao) = 'fc58e745268168dacfca714c52392805'
       and (select md5(string_agg(a.id::text || ':' || a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = 697) = '0a1bb0e1c0c1d50d82ff0f84cc1cafeb')),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from gm where (select count(*) from public.alternativas a where a.questao_id = gm.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = gm.id and a.correta) <> 1)),
  ('mídia só na Q46: FIGURA 591x383, p. 11, OFICIAL_PROVA, antes das alternativas, sha256 993ed2333a9a…', (select count(*) = 1 from public.questao_midias m where m.questao_id in (select id from gm))
     and exists (select 1 from public.questao_midias m where m.id = 6 and m.questao_id = 3334 and m.prova_id = (select id from prova) and m.ordem = 1 and m.tipo = 'FIGURA'
       and m.sha256 = '993ed2333a9a406e1ac2568922b92c106fa931f7683aae72ffd6ef8bb2d84057' and m.mime_type = 'image/png' and m.storage_path = 'questoes/993ed2333a9a406e1ac2568922b92c106fa931f7683aae72ffd6ef8bb2d84057.png'
       and m.largura = 591 and m.altura = 383 and m.pagina_origem = 11 and m.ancora_texto is null and m.direito_uso = 'OFICIAL_PROVA')),
  ('objeto da mídia no Storage', exists (select 1 from storage.objects o where o.name = 'questoes/993ed2333a9a406e1ac2568922b92c106fa931f7683aae72ffd6ef8bb2d84057.png'))
) v(verificacao, ok);
