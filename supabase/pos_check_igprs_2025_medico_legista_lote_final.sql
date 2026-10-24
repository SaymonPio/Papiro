-- IGP-RS 2025 Perito Médico-Legista (Fundatec, concurso 986, caderno 0986.013 — cabeçalho "13 E 14", o mesmo do Perito
-- Médico-Legista Psiquiatra 0986.014: NÃO importar o 014 como prova nova) — REGISTRO SANITIZADO do lote aplicado em 2026-10-24.
--
-- Operação (já aplicada): executor de aquisição, manifesto bb4d365912a8a0a3c5eaf5fe943206000d59f1359a59bf2108cfce60d7da1d4f,
--   modo BASE_GLOBAL: provas.id = 31 (hash_prova 167814014fca…);
--   prova_documentos: GABARITO = PDF oficial do Edital 01/2026 (sha256 6bcf5b3ee9e2…, o mesmo documento da
--   prova 15), bloco "13 - Perito Médico - Legista"; a retificação do Edital 02/2026 não altera este cargo além da Q2;
--   37 questões novas, SÓ do bloco específico (Q31–Q70; ids 3713–3749), 185 alternativas, nenhum curso_questoes,
--   nenhuma mídia, nenhuma liberação, nenhum assunto novo (assuntos forenses existentes 166–179, 7, 251, 252).
-- Bloco comum Q1–Q30 = o mesmo do Perito Criminal (prova 15): as 22 já oficiais lá NÃO foram copiadas; Q6 (legado 746),
-- Q10 (segurada), Q16, Q17, Q18 e Q20 (Língua Inglesa sem matéria) seguem em revisão. Anuladas: 2, 19, 43, 52, 62 (ignoradas).
-- Grafias atípicas da fonte oficial PRESERVADAS (GRAFIA_ATIPICA_PRESERVADA_DA_FONTE_OFICIAL, observação editorial):
-- Q37 ("Wernick"), Q51 ("esquetizado"), Q63 ("ipsis literis") — conferidas pelo md5 do enunciado/alternativas abaixo.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 37 questões e a prova 15 continuam
-- exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, ativa) as (
values
  (3713, 31, 17, 175, '1107f58938c2dd50e9fc3ecf819475cf', 'cfb2508f9f4a35473e39ec28c6eefaa5', 'D', true),
  (3714, 32, 15, 167, 'f87d10b4866baf0c8a061be9748257e6', 'e061a87468db264f9981bb185e9f6fab', 'A', true),
  (3715, 33, 17, 175, '3fb3efdebc30a3e38bbdc4886594efff', '28e0b1c02025457880fc424b2660a263', 'D', true),
  (3716, 34, 17, 175, '9caeb5e9f763b58a07135d5c46404b1c', 'e94a39cc9b5a1e944199d7990628988a', 'C', true),
  (3717, 35, 17, 175, '55280757524497217a5be8f315766bfe', '60630e2c7f61cad5ec324b72ae9b44a9', 'C', true),
  (3718, 36, 17, 175, 'b8df7b86435497a9f84adb3b6364ac22', 'a034a2f28037beca3825d81f3ed2af0a', 'D', true),
  (3719, 37, 17, 177, '3e2addb0847fe938d1c4e4a0d32daa4d', '8df73f767b153aec1199a5c08830b93b', 'B', true),
  (3720, 38, 17, 177, '82fe52f7ad88f0a4760b726497250b4a', '163981ef78ce5643875be30798fb63cc', 'B', true),
  (3721, 39, 17, 177, '926d48c22ab683303b770a4ee892c6ff', 'd241eb400d3531bcc9341d18e3f98156', 'B', true),
  (3722, 40, 17, 174, 'da4a288b391a7ee34b2ce8e97941c11e', '526a31191351e4b68b54209445a5939c', 'E', true),
  (3723, 41, 17, 174, '972f29354d194692b55c8228db4065c8', '96d4c51b6ee31cfb8a0ebdeef356f505', 'C', true),
  (3724, 42, 17, 178, '405679ff934b71108922a3431451ef1e', 'd565c9648732dd917e5a9bd0994e783f', 'D', true),
  (3725, 44, 15, 170, '3d9caa5f9444cb0e87eb74dd936d5f21', 'fc11016ce5625f4a015cba3a14620f71', 'E', true),
  (3726, 45, 15, 170, '9e65e45a3c312ad3ea939aaa3306ddd5', '1e379f789f38961a6b18c9b5f57a695a', 'D', true),
  (3727, 46, 17, 176, '4903387f8ffea9bbe061132d91579cb3', '2d86fbc6efe6ce750e04c9e732bc46da', 'C', true),
  (3728, 47, 5, 251, '31677040bf23134cb826e1ab21f570c1', '7ac262a366db0eff9790fabc9764f610', 'E', true),
  (3729, 48, 17, 176, '7d3639f53259229e4bc4e57b63c197a7', '714df7f70f1ed833ef003f576158b352', 'D', true),
  (3730, 49, 5, 252, '3db0f9516b4c6de8ed93431b0d6f0477', 'ccc7eccd345ae0db637ff06f9ca1df09', 'A', true),
  (3731, 50, 15, 168, '6d00817c3a5f8af6ca392054b9e68540', 'c2d81fb3509ede15140578a7c02fc59e', 'B', true),
  (3732, 51, 15, 168, '8127328061e3c1e8c663941fd35be44d', '0ca985ae58990af8062d802f6f2df58c', 'B', true),
  (3733, 53, 17, 174, 'ef450691c0258211d5e633095a5c7e0a', 'd606db5838ea618bf9c047726280d321', 'E', true),
  (3734, 54, 17, 175, 'd6d7bd9746d75bfe4b5928e2e096858e', '6110d138aa14ee721bf05494ad76b896', 'D', true),
  (3735, 55, 17, 174, '814466bb21e8b4fc72737c82e7e0a206', '0c7c54dcc9d5acb528403c1495cb1491', 'A', true),
  (3736, 56, 17, 175, 'c240a3746a45c04a4ac4eab2c837c371', 'e5d8ee6cada5b67e16b73356346d9027', 'C', true),
  (3737, 57, 17, 175, '59c9b172343a0201c3cde0f4dfa13df2', '8f160840a23b2f9ec8a0075f6e63bd9d', 'A', true),
  (3738, 58, 17, 175, 'e7ec535f58624ad8d6ad04f3b457360e', '96c2238ec3ebc494835fdf44e24e959b', 'C', true),
  (3739, 59, 5, 252, '9a3b98a89c3caf78d0f2f9615dd7bf49', '55a71b444d3426e752f7af17442b65ba', 'B', true),
  (3740, 60, 5, 252, '5c86916062930c8336b9bb070befe352', '47ed0e35dd31ffd2afb46f51acba980e', 'E', true),
  (3741, 61, 15, 166, 'df4dcfff40422851b922a937d09749d7', '97a6a02cae5d978f688ef69284dfb97a', 'B', true),
  (3742, 63, 7, 7, '5cbd562b49cafb0c6344cf15cd59e02b', '357111c4d72da2b99dadabe74b3e1d8b', 'D', true),
  (3743, 64, 15, 166, '76947be932fbde7b14c16e1b19c11e55', '78db3beef89d1c2d05c8bffb6984e852', 'A', true),
  (3744, 65, 15, 166, '822b13d0683b63db2bb75fe25623f6d0', 'efea61aa6c4550c3dfa36ce308e636b3', 'C', true),
  (3745, 66, 15, 166, 'ecf73ed05491d5e124c805d4fd454370', 'f3b08e6c6e39116c521e65bf97015228', 'E', true),
  (3746, 67, 15, 170, '38bc0a1f403969f8c91f461d5b265130', '8bd928ccb39d73348027ae44d4867fd8', 'C', true),
  (3747, 68, 7, 179, '471f3914db0ea6afa05f61477d4470b8', 'bbb51aae875e64460a6d2f4be5136595', 'B', true),
  (3748, 69, 15, 166, '4e60c1083e7953a148321a76ea200638', 'b62079055c96c62135792287b8e39b9f', 'A', true),
  (3749, 70, 7, 7, '880f7cab99da29b2fafba2a8e970a2d0', 'b84bb739ae1971cc4c65b70fc2d26a32', 'D', true)
),
prova as (
  select id from public.provas where hash_prova = '167814014fcacb900e5da859147826d2cae6645e2f14ef5c7cf81ed2a7fe6650'
),
atual as (
  select q.id, q.prova_id, q.prova_parte_id, q.numero_original, q.usuario_id, q.materia_id, q.assunto_id, q.ativa, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
         (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos,
         (select count(*) from public.questao_midias m where m.questao_id = q.id) as midias
    from public.questoes q
)
select e.numero_original, e.questao_id,
       (a.id is not null and a.prova_id = (select id from prova) and a.prova_parte_id is null and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id = e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa = e.ativa and a.vinculos = 0 and a.midias = 0) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = '167814014fcacb900e5da859147826d2cae6645e2f14ef5c7cf81ed2a7fe6650'
),
pp as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 31 (hash_prova 167814014fca…; manifesto bb4d365912a8…), cargo Perito Médico-Legista', (select id from prova) = 31
     and exists (select 1 from public.provas p where p.id = 31 and p.cargo = 'Perito Médico-Legista')),
  ('prova_documentos: só o GABARITO = PDF oficial do Edital 01/2026 6bcf5b3ee9e2…', (select count(*) = 1
     and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '6bcf5b3ee9e2e2e9a6696e04a524378fb3ca433616e76a65acd54d01b6f66841') from public.prova_documentos d where d.prova_id = (select id from prova))),
  ('provas.hash_gabarito = PDF oficial do Edital 01/2026', exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = '6bcf5b3ee9e2e2e9a6696e04a524378fb3ca433616e76a65acd54d01b6f66841')),
  ('37/70 oficiais na prova, todas do bloco específico Q31–Q70, números distintos, sem parte', (select count(*) = 37 and count(distinct numero_original) = 37
     and bool_and(numero_original between 31 and 70) and bool_and(prova_parte_id is null) from pp)),
  ('37 novas = ids 3713–3749, sem curso_questoes, todas com matéria e assunto', (select count(*) = 37 and bool_and(materia_id is not null and assunto_id is not null) from pp where id between 3713 and 3749)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3713 and 3749)),
  ('assuntos só existentes (forenses 166–179, 7, 251, 252)', not exists (select 1 from pp where assunto_id not in (7, 166, 167, 168, 170, 174, 175, 176, 177, 178, 179, 251, 252))),
  ('fora da prova: anuladas 2, 19, 43, 52, 62 e todo o bloco comum Q1–Q30', not exists (select 1 from pp where numero_original in (2, 19, 43, 52, 62) or numero_original <= 30)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pp where (select count(*) from public.alternativas a where a.questao_id = pp.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pp.id and a.correta) <> 1)),
  ('prova 15 (Perito Criminal, bloco comum) intocada: 61 questões, assinatura 60cebdaba523…', (select count(*) = 61 and md5(string_agg(q.id::text || ':' || coalesce(q.numero_original::text,'') || ':' || md5(q.enunciado) || ':' ||
      (select md5(string_agg(a.id::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id), '|' order by q.id)) = '60cebdaba5231c49876e3d5da483596b'
      from public.questoes q where q.prova_id = 15)),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pp)))
) v(verificacao, ok);
