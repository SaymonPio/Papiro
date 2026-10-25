-- SEJUSP/MG 2022 Agente de Segurança Socioeducativo (Fundatec, concurso 687; Processo Seletivo Simplificado nº 03/2022) —
-- REGISTRO SANITIZADO do lote aplicado em 2026-10-25. Os 14 cadernos 0687.001–014 (RISP × vagas) são o MESMO arquivo; os 4 tipos
-- são rotação de blocos de 10 da mesma prova — canônico TIPO 1 (metadata.caderno, páginas 1–16; nenhuma prova_parte).
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (manutencao_sejusp_2022_agente_taxonomia.sql): assuntos 401–406 (nenhuma matéria nova); Q57 reutiliza 388;
--   2. executor de aquisição, manifesto 566662d453248dc0e0453a29451525ae8b044cba02d35b9baee73815b786d7e7, BASE_GLOBAL:
--      provas.id = 36 (hash_prova 246d879d790a…), prova_documentos GABARITO = 35
--      (Edital nº 09/2022, sha256 7ca62358e5b2…, bloco TIPO 1); 41 novas (ids 3911–3951), 164 alternativas, 0 curso_questoes;
--      texto-base de LP com linhas numeradas [01]–[45] (correção 2d5d6c8);
--   3. qualificação dos 14 legados TEC (script com texto integral, fora do repositório; rollback-testado): prova_id/
--      numero_original/fonte/concurso + enunciado oficial em 12 (8 só espaço, 4 adaptados com explicação auditada compatível);
--      2 idênticos só proveniência; Q5 -> 889 por decisão humana (o provável automático 787 é falso positivo);
--      Q21 -> 856: alternativa C com erro da banca no PDF ("ilício") — forma correta do legado preservada;
--      alternativas, explicações, vínculos e histórico intactos.
-- Fora da prova: Q14 (hachura), Q17 e Q19 (sublinhado), Q58 (midia_ausente — figura descartada pelo filtro de repetição
--   entre tipos), em revisão; Q54 anulada (Edital nº 09/2022). Cobertura 55/60.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 55 questões e a prova continuam
-- exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito) as (
values
  (3911, 1, 'nova', 6, 405, '6fc54d2c07e027abe5384e55233a316a', 'afca02db3624dcbea2de7b9c0578ffae', 'B'),
  (3912, 2, 'nova', 6, 15, 'b06f3bd68ea5e7f6d14381ada5bf49e8', '37e60b982ecbe441f46ff407b5e8f7c9', 'A'),
  (3913, 3, 'nova', 6, 406, '05619136797cb30e29e05f64e5108703', 'f59492c8a9ecaf0b924333d950f8e484', 'C'),
  (3914, 4, 'nova', 6, 5, '66d9bfcd3abb5956fbf55d7c209ac631', 'f5de05b723db5b11d157a10a15ede5ba', 'D'),
  (889, 5, 'legado', 6, 53, '35a3136a2d27ed20445c9a8dd695c8f5', '4149d417ad95f93dae8a9dd4c547bbe5', 'A'),
  (3915, 6, 'nova', 6, 59, '0fa2494568f9682db5502a3e2474ac4a', 'b7388c94c550447787b8d5052f19d31a', 'C'),
  (890, 7, 'legado', 6, 53, '2b38663cd4195fe06ee228398262202a', 'd1e8a3952c8ed565bcb64b8065adfaa2', 'C'),
  (3916, 8, 'nova', 6, 57, '670fc4715e62ec2a6c956d64cd80af31', '87e67e21c4fae4c60d63d55edc115efe', 'B'),
  (3917, 9, 'nova', 6, 47, '918e700db3e38a311baeded6d3de5509', 'a8f6d8d784454e839771f62b8b201ef5', 'D'),
  (882, 10, 'legado', 6, 45, 'a7c835edb879d843946b7840c5c10910', 'f21f5b6a2c18c6554b2326b4c87d2d74', 'B'),
  (3918, 11, 'nova', 6, 45, 'cebcbc85ce9d33ef9718189f10c2ed38', '19fc8d359753682082f719207f999bad', 'C'),
  (3919, 12, 'nova', 6, 47, '949ef886e74431f7555b078ff791d2ae', 'a7d280e38950ae95e425e866286a0eea', 'B'),
  (3920, 13, 'nova', 6, 50, '85bfb3161e92c6e8c81c3375d4a518fc', '565f064203f5d7e4ae7399ad91e53ed1', 'C'),
  (877, 15, 'legado', 6, 47, '540fb63c42893057fcc81dc0e504edcd', 'c6c19487c588c2db65408f9afb234585', 'D'),
  (3921, 16, 'nova', 6, 47, '44cc398d7d062adaee1cab5b35285355', 'c02af7c1df9f490d7cf03f837c0ce78c', 'B'),
  (3922, 18, 'nova', 6, 14, 'eed3ee0e0266799d3d2c3494b0215ad6', '565f064203f5d7e4ae7399ad91e53ed1', 'C'),
  (3923, 20, 'nova', 6, 30, '4b31bb2f82bd392c15652b0d3efbf013', '655e631ea919867b25f863f89f9d0c05', 'B'),
  (856, 21, 'legado', 10, 64, '7803dca4db75bcaa2a3f6ab88516b5e9', '5c77e3438a38a6390e37cb4be716efe8', 'B'),
  (3924, 22, 'nova', 16, 262, '050136142b6d791ceb35fb8ea0ab34d3', '3e4e3ed4cf78e3e0fb6aa5e1a242b76a', 'D'),
  (3925, 23, 'nova', 5, 4, '161e2d637bb6462885c3e01d219b737b', '1c77b9987c5d6c77d3e88289a0f12655', 'C'),
  (3926, 24, 'nova', 8, 142, '845003491e3540dfeed629360a9f97be', '566a74d209764b39ac75bac283e438fa', 'B'),
  (846, 25, 'legado', 10, 71, 'ecace4261684c059a2e7d9950036ae53', 'e7432bc47f841ea154b5fed1bfefd543', 'A'),
  (840, 26, 'legado', 10, 67, '881a90fa8110c33962ce9528996d1e8d', '70a50f1fcc9113720518c5d8afd53e72', 'A'),
  (3927, 27, 'nova', 11, 301, '99bb8c2fdd37031bd09afd7d337f272b', 'a5bb4a39207608238b4a4796fc5df6df', 'D'),
  (838, 28, 'legado', 10, 79, '0a009e377241af699e4935f79922b650', '64f3da864881cacc5b6a60674f0d518d', 'A'),
  (868, 29, 'legado', 10, 78, '6598aec6043574fb34e0a825e6cd7ff7', '28d951719a4008e0176cf24af98f28c1', 'C'),
  (3928, 30, 'nova', 3, 341, '9ac70a0c33f854761dde4427f2b670c8', '5dd1e9947970c7aeb758d0d2ba4d73eb', 'B'),
  (812, 31, 'legado', 11, 88, '6fe966c04257ff9d170dc6dd9803317e', 'ab795cd861ba5236bb603be35db14bc4', 'B'),
  (819, 32, 'legado', 11, 90, '2f2e0b688f60c094fc4accd63080f38b', 'efa294a00d9a39c10a8ca28339f4a54e', 'B'),
  (820, 33, 'legado', 11, 90, 'f1a6ee0e90f1665e88f7dac4be7b0eea', '1de624f937d931a4408edf20116ce06d', 'A'),
  (3929, 34, 'nova', 11, 83, '71a5239243f678afed2a7924e2340304', 'db8cb5906b93fe18f3b5815fbdb7c4d9', 'C'),
  (3930, 35, 'nova', 11, 83, '7d9b151818ff6caedce82755931327d2', '4c238d7a510fc4cf92858099de0c4794', 'C'),
  (3931, 36, 'nova', 11, 83, '2d44fad1549754ef863fe17f29fb56cf', 'c89bda1bb4a34081aca9d3d5dfaa4a75', 'C'),
  (821, 37, 'legado', 11, 90, '03b846353fc1feb44f1e57b475066fc9', 'cf21a645019853b94ca517dca99a817e', 'A'),
  (3932, 38, 'nova', 11, 267, 'b664c9cd2f87e767ba04c390b2bbbf9f', 'ff71a957b6dc1b0c6363b9d03aeb98c9', 'D'),
  (3933, 39, 'nova', 11, 83, 'cdc67a95eba58213b61b8c5351125a5b', 'a971195815084415da0256bb07350ab3', 'B'),
  (3934, 40, 'nova', 11, 83, '3ba7126ddb6d247c579e4cf1c7b83f27', 'fefb641d2b56e698a3191660a1d2ee9c', 'A'),
  (3935, 41, 'nova', 11, 401, '3e102515b9c0caf06f86b9b9ef2519df', 'a7fc1c396657256828af3433fbfca3d7', 'C'),
  (3936, 42, 'nova', 11, 401, 'e843ceb7a65ddb2cbf5cc18cdd3b45cb', 'aba3b8409a9a0307d240f91c2a44009f', 'B'),
  (3937, 43, 'nova', 16, 402, 'da5251e2014c71fc06a4f1c572b86cf6', 'e9693121da8d7aed0dda1db01e896074', 'D'),
  (3938, 44, 'nova', 16, 403, '6892c31e6b2d4eb9e82448ae4a1349a5', 'f1297a962c93ca22a4d25abf7af69406', 'A'),
  (3939, 45, 'nova', 11, 301, '47df27cccc0d33186b051a1b7442c98a', '73adfa90b7bc6ed610b8b7eee9b43c94', 'B'),
  (3940, 46, 'nova', 8, 254, 'ea34453d1e488452f2af9b861df6554c', '0a7938f1fc83f4e5c8a90f4e3c63bace', 'D'),
  (814, 47, 'legado', 11, 98, 'b1e336789c124c9e6f6b664db6898103', '5aeac71430baf671cb72d8637c495345', 'C'),
  (3941, 48, 'nova', 3, 404, '7436131dee7b52b909fc85e32a46365c', 'fff4e8909a1e40aa84330e71b4ae5e6a', 'A'),
  (3942, 49, 'nova', 11, 401, '0bf5cbe75d39002b2c2b4a7a7cde56ab', '64f3da864881cacc5b6a60674f0d518d', 'A'),
  (3943, 50, 'nova', 16, 403, '64ecd2803dc4842b5292e17cd12340ed', 'a51afd931ced4cfb471d6a5d8b256ac6', 'D'),
  (3944, 51, 'nova', 18, 40, 'f770d78e2039fcc96826383b78f11c8b', 'faeec5538dd8537c3a1935b151da15e6', 'B'),
  (3945, 52, 'nova', 18, 40, 'a0a29829479d7c81db27bfad8d194570', '630e87d6f9c574c646d82fba989b7990', 'C'),
  (3946, 53, 'nova', 12, 291, '32728cadf9c021c8349cf18353b3d6c3', '54663fbda685549902f90f2e9eb90cbc', 'C'),
  (3947, 55, 'nova', 12, 296, 'ecd659245e5b12812c6395c16ceb15c1', '28a1f024229378aeeabda4552d7206b4', 'B'),
  (3948, 56, 'nova', 12, 296, '30c2245336d21fd67868152ed6ca798a', 'f6ee845a6b8ca60cd95fe98a3996cb22', 'D'),
  (3949, 57, 'nova', 40, 388, '09e2448d5a211109bfc5f8f8c656ac37', '28eeb7167e25d02c98423f25fc3ec513', 'A'),
  (3950, 59, 'nova', 18, 41, '8176967145b52d95856ec753e42acd4f', '3f18ff7c430904437a83badd7b1c4e3c', 'D'),
  (3951, 60, 'nova', 18, 40, 'd265a3c4d462958144c70edc3a733dc6', 'a4cbd163225358b973976e8979a357f6', 'A')
),
prova as (
  select id from public.provas where hash_prova = '246d879d790a8d435cacfa84262c65124adfe4731f0a76605d3aa0b3b5254e44'
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
select e.numero_original, e.questao_id, e.origem,
       (a.id is not null and a.prova_id = (select id from prova) and a.prova_parte_id is null and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id = e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 4 and a.n_corretas = 1 and a.ativa
        and ((e.origem = 'legado' and a.vinculos = 1) or (e.origem = 'nova' and a.vinculos = 0))) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = '246d879d790a8d435cacfa84262c65124adfe4731f0a76605d3aa0b3b5254e44'
),
pq as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 36 (hash_prova 246d879d790a…), uma só', (select count(*) = 1 from public.provas where hash_prova = '246d879d790a8d435cacfa84262c65124adfe4731f0a76605d3aa0b3b5254e44') and (select id from prova) = 36),
  ('nenhuma prova_parte (o tipo de caderno não é parte)', not exists (select 1 from public.prova_partes where prova_id = (select id from prova)) and not exists (select 1 from pq where prova_parte_id is not null)),
  ('prova_documentos: só o GABARITO do Edital nº 09/2022 (7ca62358e5b2…)', (select count(*) = 1 and bool_and(d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '7ca62358e5b287625301717b33c3bf9839c89621faec23bd3621cf74aec5ab50') from public.prova_documentos d where d.prova_id = (select id from prova))
     and exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = '7ca62358e5b287625301717b33c3bf9839c89621faec23bd3621cf74aec5ab50')),
  ('55/60 (41 novas + 14 legados), fora 14, 17, 19, 54, 58', (select count(*) = 55 and count(distinct numero_original) = 55 and bool_and(numero_original not in (14, 17, 19, 54, 58)) from pq)),
  ('41 novas = ids 3911–3951, sem curso_questoes, todas com matéria e assunto', (select count(*) = 41 and bool_and(materia_id is not null and assunto_id is not null) from public.questoes where id between 3911 and 3951 and prova_id = (select id from prova))
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 3911 and 3951)),
  ('14 legados qualificados com 1 vínculo de curso cada (preservado); Q5 = 889', (select count(*) = 14 and bool_and((select count(*) from public.curso_questoes cq where cq.questao_id = pq.id) = 1) from pq where id in (889, 890, 882, 877, 856, 846, 840, 838, 868, 812, 819, 820, 821, 814))
     and exists (select 1 from pq where id = 889 and numero_original = 5)),
  ('falsos positivos de dedup 787, 3299, 328, 2909, 893, 784 intocados (787 = provável automático da Q5)', (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q where q.id in (787, 3299, 328, 2909, 893, 784)) = 'de234d8a036dd39b2e0c68833da8db88'
     and not exists (select 1 from public.questoes where id in (787, 3299, 328, 2909, 893, 784) and prova_id = (select id from prova))),
  ('taxonomia 401–406 presente; Q57 em 40/388', (select count(*) = 6 from public.assuntos where id between 401 and 406) and exists (select 1 from pq where numero_original = 57 and materia_id = 40 and assunto_id = 388)),
  ('4 alternativas e exatamente 1 correta em todas', not exists (select 1 from pq where (select count(*) from public.alternativas a where a.questao_id = pq.id) <> 4
     or (select count(*) from public.alternativas a where a.questao_id = pq.id and a.correta) <> 1)),
  ('texto-base de LP com linhas numeradas [01]–[45] nas questões que o citam', (select count(*) >= 15 from pq where numero_original <= 20 and enunciado ~ '\[01\] ' and enunciado ~ '\[45\] ')),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pq)))
) v(verificacao, ok);
