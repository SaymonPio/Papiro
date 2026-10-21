-- IGP-RS 2025 (Fundatec, concurso 986, Perito Criminal — caderno único das áreas
-- 01 a 17) — REGISTRO SANITIZADO do lote aplicado em 2026-10-21.
--
-- Operações (já aplicadas):
--   1) executor de aquisição, manifesto 1b3524fd92c7e6f876396381b16ed512e08d32a974539d1e44723da8d90e83d4,
--      modo BASE_GLOBAL: provas.id = 15 (hash_prova 73718bdd0d58…),
--      prova_documentos GABARITO (Ed. 01/2026) + RETIFICACAO ordem 1 (Ed. 02/2026,
--      anula Q2 e Q58), 55 questões novas (ids 3047–3101), 275 alternativas,
--      nenhum curso_questoes;
--   2) qualificação do legado TEC (script operacional com texto integral FORA do
--      repositório): ids 726, 702, 703, 699, 706, 707 receberam prova_id,
--      numero_original e fonte/concurso oficiais, preservando id, alternativas,
--      gabarito, matéria, assunto, explicação, vínculos e histórico; enunciado
--      trocado pelo oficial (só espaço em branco) em 702, 699, 706 e 707.
-- Fora da prova por decisão: Q6 (legado 746 intocado), Q10, Q16–Q18, Q20 em
-- revisão; Q2, Q19 e Q58 anuladas.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que
-- as 61 questões continuam exatamente no estado deixado pelas operações.
-- Linhas devolvidas com ok = false indicam divergência.

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, legado_qualificado, md5_enunciado_antes) as (
values
  (3047, 1, 6, 54, '7cd32b7cd6a39e6572af6cc3947534ad', '7d41178faca466b79c6fcfba21780759', 'C', false, null),
  (3048, 3, 6, 14, '297424e74c8b6a9ad171d3174a14dc7b', 'f344e928a079b580791bcbd71045d362', 'A', false, null),
  (3049, 4, 6, 47, '55cf61e47a7001ebf1de2928e84c1b7c', '287aa621f12e68c8119529f7f05b299c', 'B', false, null),
  (3050, 5, 6, 57, 'c0ef57fc9d1901ec3766fe1e1ec43be4', 'c60d5f87bb1ff7364df07dd011f62193', 'D', false, null),
  (3051, 7, 6, 49, '9cd886d559aa11643de4523aa4563bff', '7d41178faca466b79c6fcfba21780759', 'C', false, null),
  (3052, 8, 6, 51, '25c2d0ea54e9e978384edbb4942b5cf7', 'b6d315562136a2be0503ca6478c8a273', 'D', false, null),
  (3053, 9, 6, 42, '564bd4234d0b0701a9bc44367c0b7002', '277504c80a868cc873836233b7b5fbc6', 'B', false, null),
  (726, 11, 10, 71, '2538f73cd645fe0f827c8ea5465b0d03', '3fa0ea5a27190e3bc59ae15288b9ddba', 'B', true, '2538f73cd645fe0f827c8ea5465b0d03'),
  (3054, 12, 16, 180, 'aeba0f4d6064f23d3187eeab5f17e69f', 'e58ae731547ae12bd1677a44a5404fe7', 'A', false, null),
  (3055, 13, 16, 181, '2692db1bc247197fc2cff86b0111d8b0', '73aa8d1554819db8070e18ca37fdb018', 'C', false, null),
  (3056, 14, 16, 182, '989919ff264fd426236f72d225266a14', 'cc390f90385b95ecf9b796a6649f5d4f', 'E', false, null),
  (3057, 15, 16, 182, 'bbbdbb5b5c6ec7cd89f845f4ac73025a', 'fc36d13d29f9162244677bc2a3690631', 'D', false, null),
  (3058, 21, 18, 183, 'c7203c3a9ab3d93f857b16514946e78f', '4a248bfb2475b95ccb6487a72e64c109', 'E', false, null),
  (3059, 22, 18, 33, '8432a29e4741854088e0b41402e1dc39', 'a727f84c3aef581eb886c4ec632ee251', 'C', false, null),
  (3060, 23, 18, 184, 'bd3c0434a7ee252b21f66f1fce334825', '492e08eea56122a23bb7d2c0e430605e', 'A', false, null),
  (3061, 24, 18, 34, '46d1ad822a317526e8b4b4283939f19b', 'b1544a09713a7fdbeb70b01596d1212d', 'B', false, null),
  (3062, 25, 18, 40, 'ce37ffecee966fd671f8f59c4d911840', '1134314c64816ac3d0b2ff35138deae9', 'D', false, null),
  (702, 26, 9, 62, '081b8f48b52ceeb834eb7c6f9d2aa7db', '0ba7f49f73de354fa210832ca0828fd6', 'D', true, '7591b2cf83c4ebd09fc17e4b4e4e354b'),
  (703, 27, 9, 62, 'fdb647e8b00467ba8ca0ae02a05a646d', 'b88365415485d24550dd786b32e27619', 'A', true, 'fdb647e8b00467ba8ca0ae02a05a646d'),
  (699, 28, 9, 60, 'ab3eba4aa2ef1320fb9c00844ab0ea0f', '40f39352c9a574851b2748a2dbfec2fd', 'E', true, 'bb5a5912cc6ca141a669e290fc79495a'),
  (706, 29, 9, 10, 'b6914ab2ec6f06deef5cec76e8d4fc3b', '844c056296024c54153035c519b0404a', 'B', true, 'e3af0da08a69aa255d34316397dd6664'),
  (707, 30, 9, 10, 'b113f2133b406b92aa10dbfada14d7f7', 'c2a960dc81005cbbd86de3a90ba8f2c3', 'C', true, 'a9a2575f63c40a103a3af820e726f26c'),
  (3063, 31, 15, 168, '932d4cd4b65101bc75103380c9f8ef06', '60e53d055ec0f3a1b770bf27b6f51f51', 'A', false, null),
  (3064, 32, 15, 166, '022492ea40831cc700670d0d7665c7a0', 'efffca13670cbfb370044d10811a7d69', 'C', false, null),
  (3065, 33, 15, 167, 'a76116578eb1a6a7d0d58f43da6d0eb4', '81fcebaddbbf2241194ec1067f59a7a1', 'B', false, null),
  (3066, 34, 15, 167, 'efb695a7826a0944c7e9b144a93498dd', '79153b5fa472f20a13187d01f6be9e0d', 'E', false, null),
  (3067, 35, 17, 175, '2dc33b942bfe5f571756cee5cbcba003', '3d35880f336abd5abf36299392da19e2', 'C', false, null),
  (3068, 36, 15, 170, 'dfeed6b68d6f036d1b5590540653bf05', 'dfefc9ed395f3fa38e5f3dd2b7471572', 'A', false, null),
  (3069, 37, 15, 173, '568c74cbd38525dfbb4f17c3d34bc56c', 'f1f23e2bc75f2ba8127f6ff15a3e8d90', 'C', false, null),
  (3070, 38, 15, 168, '08a94e1abba39b86b18068ab989eba4c', '0fbb29df3078450842256ad93aa6f7eb', 'E', false, null),
  (3071, 39, 15, 168, '004b96c1815303e9dde0a75429d090bc', '48ed11bfd163476b3ea327a29a9a114c', 'D', false, null),
  (3072, 40, 7, 7, '2fd5dcf33bd9f45f91ca682d07729978', 'd3c122d2f46b01b944165b6c0258b7a3', 'B', false, null),
  (3073, 41, 15, 172, '3e751947dd6bf460e41eb57f36704675', '297304494abbcaeaf45911fd8f856e9a', 'D', false, null),
  (3074, 42, 15, 166, '5862c3f5a1b23d4bb7f367dc982f212d', '864e17d6f4d3c86b6a6195a14e225887', 'E', false, null),
  (3075, 43, 15, 170, '046a07ebc14f0155f16cf260ee40ec1c', 'c979f1b4cab3cfad7978bdfdcb3ad2a4', 'C', false, null),
  (3076, 44, 15, 169, '3f724ac2ea52447b8f7ab3e14a083346', '325b02c0491b2c6c592965f58cd6f72a', 'A', false, null),
  (3077, 45, 15, 169, '73ad923aa544e40683391dc799fd909a', '47532b7edb4b5bbf21c281f485560c99', 'B', false, null),
  (3078, 46, 15, 171, '47d5ef816baf1d44d1400db21e8a7430', '468bdae18f15e98b6c20e2f3bcfab9ea', 'D', false, null),
  (3079, 47, 15, 171, '9b90e77f75d1fcef21f3b66eeba7868e', 'db09b46f492b713033d97d015a89ac8a', 'C', false, null),
  (3080, 48, 15, 171, '38f9f993c0951dae7ec16e4b33be9985', 'e4cfe2b507911652090f4da146b20344', 'E', false, null),
  (3081, 49, 15, 172, 'ebbdb496346b85d3b7605b064612fd82', '2a5915c3600b22b887ddf49c042602e0', 'A', false, null),
  (3082, 50, 17, 178, '98e071c6331a493b6dc9586efb241477', '23a9267c6604582a93f8d6d25658690b', 'D', false, null),
  (3083, 51, 15, 167, '933a8c4e78da5f505fc1ce8e8901f7a6', '132de8556725fb04482b41f0ee365d3d', 'A', false, null),
  (3084, 52, 7, 7, '234253da7caa0ff620df70945c8f76c2', 'd71f2a25e34db4009417abae79a4abb6', 'B', false, null),
  (3085, 53, 7, 179, '3d29abb983dfafdc28ea2d04d7a7148d', '3d3cb213d90992bdab9760c857c6c592', 'C', false, null),
  (3086, 54, 7, 179, '82b1121f3316aef8c82a6e6484eb1693', '9517f49db0d5ca4d0fba8cb98344f952', 'B', false, null),
  (3087, 55, 15, 166, '0d4c025261092ba12448b6156b093695', '13c73aab1be5d5f6d1bf35af8911e19b', 'E', false, null),
  (3088, 56, 15, 170, '27810c4132e778c3fc1f390c89152a41', 'ce02898946c4b58d9ddf68163337d636', 'C', false, null),
  (3089, 57, 7, 179, '3bb002f57de8c6a77f1216e08807e2c2', '768e5deb7bfe8b9debd5d2dbaae6d502', 'B', false, null),
  (3090, 59, 15, 166, 'c84317b608e5a69e0be56a1751705ffc', 'dde24df61c91b42468f82a0219ba2eac', 'D', false, null),
  (3091, 60, 15, 173, '5c0ddba68e2ca2c75da4083355a6b7ba', '576ff643eaa9099908cf38f06777d356', 'E', false, null),
  (3092, 61, 17, 175, '0b4483153b9def34ed3c2b3482c92035', '09b4089235276f23b521f8c00989ff79', 'E', false, null),
  (3093, 62, 17, 174, '4c33f20713978aae24f86a924340ddfb', '7f58881aa999d78d99c660af482dc2af', 'A', false, null),
  (3094, 63, 17, 174, '3532f74cfcb2ab91a79b19bd3edcb74a', 'de768a0ca9859e53539b73e2ac8878f8', 'C', false, null),
  (3095, 64, 17, 175, '77997966b7d3afb12e5923e181285699', '9f0a1a4cd6288d7ec086e6dfb0dd1009', 'C', false, null),
  (3096, 65, 17, 176, 'd05dc9c3532ee33a6b6f4f84a64ddfea', 'e40e5db64f6f4c5d31c3f3074d35dfed', 'D', false, null),
  (3097, 66, 17, 175, '173db7e4baaa2bd8a06577939ba8057e', 'fcbb7ce6619ae7336caf2a3aa13f7e00', 'A', false, null),
  (3098, 67, 17, 177, 'a538c612700aac35c074cfda5e1b7a03', '1f39f27d5fc831b20f0c5f8baab765a5', 'B', false, null),
  (3099, 68, 17, 177, 'bdf11fa64e2c662fb54b7bba130e1e6b', 'be17542cd2639f6e093ef640aecb9818', 'D', false, null),
  (3100, 69, 17, 175, 'a1a59b468bac3f10ae3be7707a88b866', '8a6316ee13a3b4293008f1000a714b1a', 'A', false, null),
  (3101, 70, 17, 175, '89af30e385ccd3cc08917bcc4eff2999', 'cc7f64d0ff26ae96bab384849793df43', 'B', false, null)
),
prova as (
  select id from public.provas where hash_prova = '73718bdd0d58b10a08a4e3a19cb09ca634555fa1827c4ff79a73aa38f7d82ad4'
),
atual as (
  select q.id, q.prova_id, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos
    from public.questoes q
)
select e.numero_original, e.questao_id, e.legado_qualificado,
       (a.id is not null and a.prova_id = (select id from prova) and a.numero_original = e.numero_original and a.usuario_id is null
        and a.materia_id = e.materia_id and a.assunto_id is not distinct from e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and (e.legado_qualificado or a.vinculos = 0)) as ok,
       e.legado_qualificado and e.md5_enunciado_antes <> e.md5_enunciado as enunciado_substituido
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;
