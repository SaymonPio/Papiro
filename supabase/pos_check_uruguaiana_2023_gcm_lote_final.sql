-- Uruguaiana/RS 2023 Guarda Civil Municipal (Fundatec, concurso 744, cargo 6; Concurso Público nº 02/2023) —
-- REGISTRO SANITIZADO do lote aplicado em 2026-10-25.
--
-- Gabarito final COMPOSTO (estado_final "composto", commit b865cc5) — o gabarito definitivo do portal é bloqueado para
-- acesso externo; o estado final de cada questão foi determinado só por fontes oficiais, em ordem:
--   ordem 0 (GABARITO, base): gabarito PRELIMINAR do cargo 6 (idpub 491200, sha256 54600ea2df97…) — base, NÃO definitivo;
--   ordem 1 (RETIFICACAO): Justificativas para Manutenção/Alteração de Gabaritos Preliminares (sha256 4d1bbe306253…),
--            natureza justificativa_recursos, bloco "GUARDA MUNICIPAL" (só a seção desse cargo): Q14 A -> ANULADA;
--   ordem 2 (RETIFICACAO): Edital nº 160/2023 — retificação do gabarito definitivo (sha256 bd67b853a250…): Q9 B -> ANULADA.
--   Natureza/bloco ficam no manifesto e no relatório do executor (prova_documentos não tem essas colunas).
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (manutencao_uruguaiana_2023_gcm_taxonomia.sql): assuntos 411–414 na matéria 22 (nenhuma matéria nova);
--   2. executor de aquisição, manifesto 4e604da24029edc814999f2fd2e126aa117e8d530d1d8c33de92325e11ebe605 (sha256 do JSON canônico), BASE_GLOBAL:
--      provas.id = 39 (hash_prova 66743b6a379c…), prova_documentos = 42,43,44;
--      24 novas (ids 4000–4023), 120 alternativas, 0 curso_questoes; liberações: Q12 (falso positivo de dedup com 3653,
--      regime jurídico de Gravataí) e Q6 (oração transcrita no comando);
--   3. qualificação dos 12 legados TEC (script com texto integral, fora do repositório; rollback-testado: UPDATE 12):
--      prova_id/numero_original/fonte/concurso + enunciado oficial em 8 (6 só espaço, 1 aspas, 1 adaptado — Q3 -> 807,
--      explicação auditada compatível); 4 idênticos só proveniência; alternativas, explicações, vínculos e histórico intactos
--      (Q20 -> 799 com 2 unidades e 1 sessão planejada preservadas).
-- Fora da prova: Q4 (sublinhado) e Q10 (destaque), em revisão; Q9 e Q14 anuladas. Cobertura 36/40.
-- INTOCADOS: 808 (legado da Q9 ANULADA — guarda o gabarito preliminar; dívida, não qualificado) e 3653 (Gravataí).
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 36 questões e a prova continuam
-- exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito) as (
values
  (4000, 1, 'nova', 6, 15, '8738ba171024d778ae0990364043b6db', 'bc3c10b64577814d5ff54d0d98195636', 'E'),
  (4001, 2, 'nova', 6, 59, 'fec650cb6b4c257a2e4ca9fffc0d1266', '61e558677538a8fcc11b1ea997710dd1', 'D'),
  (807, 3, 'legado', 6, 45, '0a9baa34075b1c764b6a2640cd6cdac4', 'e4169ad3f8908d443145d5b9acc148ba', 'A'),
  (809, 5, 'legado', 6, 53, 'a993e298f0711b23009b59585124860f', '9c3a5e7707296f18dc5aa32c2e23a13a', 'C'),
  (4002, 6, 'nova', 6, 363, '3c096b569abed8195939777906c81d90', '356c94901c0d6e1638b2d8cc8a202a2b', 'B'),
  (4003, 7, 'nova', 6, 47, 'db398ea0f37e5fd17615f2c862b7365f', '0784c0eee29808c8dfab18aef9965569', 'A'),
  (4004, 8, 'nova', 6, 14, '7a2fb1ccaf1c5f64b3308db467fb7c2f', '37e3f0c1573d0e04e673b66d49790ffc', 'E'),
  (4005, 11, 'nova', 22, 411, '9e9f8ac6f4a6ddb916e1ac4c268a2132', '1c44632e38bba3cf872cc01ee094483e', 'B'),
  (4006, 12, 'nova', 22, 412, 'eb358a09ddb4177342dd3e3df1599676', '3cf15acdcf734d0088f8ccf9f75cbb71', 'D'),
  (4007, 13, 'nova', 22, 412, 'c0f1818a7e67bef58af933deb79f6657', '229160d346dd14a48af6ce81ba6aea90', 'C'),
  (4008, 15, 'nova', 22, 411, '93e130211b1d5ec8c19c20a4d12390b3', 'f8a853620e9c902b7481e1cb88054cc4', 'E'),
  (798, 16, 'legado', 10, 63, '53993c759b7fbe2df5b316165d12cc9b', '885ed1e3edfd1c6679ee64c6bcc6c6f4', 'C'),
  (795, 17, 'legado', 10, 80, '41b736794e33ed379f848447fd85a9a3', 'f12fe9a69bd676a26e1803e714c0cf1d', 'B'),
  (790, 18, 'legado', 11, 98, 'c3b2018be120882f9ab2a7ac2a99bd33', '9dcff8d8c78ca295ab17f54fa3d58e15', 'A'),
  (797, 19, 'legado', 10, 71, '5f5be6720f9d0f91be032f61389ed26b', 'b38cf69030db5b98748b8d27645b096a', 'E'),
  (799, 20, 'legado', 10, 19, 'b8d4264fca9b7a070e83dbf088c878a5', '2e564837656693b855f50c9d2df2fa12', 'D'),
  (4009, 21, 'nova', 4, 297, '0296a0c86082f50ec6d4667df5ba19a4', '30e6cf55a7084e2a9e3d36019a774449', 'C'),
  (4010, 22, 'nova', 4, 297, 'df4e5a2a48fb85673be782346b8d1000', '64df384a60dc4a38f746fc7cdea3fa55', 'B'),
  (4011, 23, 'nova', 4, 297, 'ab5a68461d28cca665c4c451837d7135', 'e03f5fa20225614606466a1d821780a4', 'E'),
  (4012, 24, 'nova', 4, 297, '28c8276e01e748507341bc8d8377749c', '406de19e0c5d5bc392eb41b9661ab420', 'A'),
  (4013, 25, 'nova', 22, 413, 'cade14332300f31870452e088c17caf9', 'a9718f56b8f458dc0986c1de85ac186d', 'D'),
  (4014, 26, 'nova', 22, 414, 'ddb7403689ad3e3fd97a56d24cf81712', 'fa54620546f3f6115f9655638f735388', 'B'),
  (4015, 27, 'nova', 2, 1, 'd5a196e655073b795537c4cb23d6357e', '31f8a0a8b96008f75967f257e979d920', 'C'),
  (4016, 28, 'nova', 2, 1, 'dbea5b8a2b2f80e393d88564859dbb90', '663410fd2aac96b0340c7d22aa3696bd', 'A'),
  (4017, 29, 'nova', 8, 144, 'cf0c1a9463ac7d518501e2c107cd6470', 'a4f930eff9a6c3c6e101cdbf2058353f', 'D'),
  (803, 30, 'legado', 10, 78, 'b64380b50b15316eb9b794b4842e21e5', '00ddd9959055ac4f46a02e9976e952a7', 'E'),
  (4018, 31, 'nova', 2, 1, '8c550cd8c5eb6d99c081f1de6a89eb8b', '267d595c83c1570e8fc293f59ae65850', 'D'),
  (800, 32, 'legado', 10, 19, '1ede3a64ecec43e5ca03d8de7050fcce', 'e647c8dbef96eeecbc2eae438f880cfa', 'B'),
  (801, 33, 'legado', 10, 19, '322b0bdf1d968bf7c69e67fff28574e7', 'cbc6c6973f016badfde64c003f2f9ef4', 'D'),
  (4019, 34, 'nova', 11, 318, '1af21c9f60fb01a96f5179a5059a5aa3', '79a191a01735c80dd25e011e5c6f027f', 'A'),
  (4020, 35, 'nova', 5, 248, '8cf54d25d2e8db38d25a972c6d1dea20', 'c8b0942684a7bdf5dcecd5fe77b823c7', 'E'),
  (4021, 36, 'nova', 5, 250, 'f9424764fa3da9b27dead69714b7db67', '3baa77817c847be874b5b0be90c5fd7b', 'D'),
  (793, 37, 'legado', 10, 79, '28f353a83c544073300450c6bffaaaae', 'f001b03d823d70b4cecbbd7c11bbea60', 'B'),
  (788, 38, 'legado', 11, 88, '7d333d05bdffa82057e19395cf41e7fd', '58dd118be54d3910bf1a93e30d36734e', 'C'),
  (4022, 39, 'nova', 11, 301, '6db65cd2eed84802ae2508f5c876a9a8', 'e3a5780f05c1b4a4c8624600958bf652', 'E'),
  (4023, 40, 'nova', 33, 302, 'e8490a7d0276d09d54bd18ce23a8311c', 'fe3bedc5b153a4223f12542dbdb08428', 'A')
),
prova as (
  select id from public.provas where hash_prova = '66743b6a379cb6aac8c0451c6d911b0791d61ca16a50fe214d2c65d6dc96e7b0'
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
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa
        and ((e.origem = 'legado' and a.vinculos = 1) or (e.origem = 'nova' and a.vinculos = 0))) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = '66743b6a379cb6aac8c0451c6d911b0791d61ca16a50fe214d2c65d6dc96e7b0'
),
pq as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 39 (hash_prova 66743b6a379c…), uma só', (select count(*) = 1 from public.provas where hash_prova = '66743b6a379cb6aac8c0451c6d911b0791d61ca16a50fe214d2c65d6dc96e7b0') and (select id from prova) = 39),
  ('nenhuma prova_parte', not exists (select 1 from public.prova_partes where prova_id = (select id from prova)) and not exists (select 1 from pq where prova_parte_id is not null)),
  ('prova_documentos: GABARITO preliminar (0) + justificativas (1) + Ed. 160/2023 (2), por hash', (select count(*) = 3 from public.prova_documentos d where d.prova_id = (select id from prova))
     and exists (select 1 from public.prova_documentos d where d.prova_id = (select id from prova) and d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '54600ea2df97807fcc25151f57003ddf3425cdc254d55fa30064f547e3db35eb')
     and exists (select 1 from public.prova_documentos d where d.prova_id = (select id from prova) and d.tipo = 'RETIFICACAO' and d.ordem = 1 and d.hash_sha256 = '4d1bbe306253cf54b05d4e1666ed6568e397e8f0eecf9e86becc36299f9c86c7')
     and exists (select 1 from public.prova_documentos d where d.prova_id = (select id from prova) and d.tipo = 'RETIFICACAO' and d.ordem = 2 and d.hash_sha256 = 'bd67b853a250311cf1ad91ea100cd79796736689c5fbcb6728cdfa55e9b692d3')
     and exists (select 1 from public.provas p where p.id = (select id from prova) and p.hash_gabarito = '54600ea2df97807fcc25151f57003ddf3425cdc254d55fa30064f547e3db35eb')),
  ('36/40 (24 novas + 12 legados), fora 4, 9, 10, 14', (select count(*) = 36 and count(distinct numero_original) = 36 and bool_and(numero_original not in (4, 9, 10, 14)) from pq)),
  ('24 novas = ids 4000–4023, sem curso_questoes, todas com matéria e assunto', (select count(*) = 24 and bool_and(materia_id is not null and assunto_id is not null) from public.questoes where id between 4000 and 4023 and prova_id = (select id from prova))
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 4000 and 4023)),
  ('12 legados qualificados com 1 vínculo de curso cada (preservado); Q20 = 799 com 2 unidades e 1 sessão', (select count(*) = 12 and bool_and((select count(*) from public.curso_questoes cq where cq.questao_id = pq.id) = 1) from pq where id in (807, 809, 798, 795, 790, 797, 799, 803, 800, 801, 793, 788))
     and (select count(*) from public.questao_unidades_pedagogicas x where x.questao_id = 799) = 2 and (select count(*) from public.sessao_questoes_planejadas s where s.questao_id = 799) = 1
     and exists (select 1 from pq where id = 799 and numero_original = 20)),
  ('808 (Q9 anulada) e 3653 (falso positivo da Q12) intocados e fora da prova', (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q where q.id in (808, 3653)) = 'e5260759dfe10bf7530b5b283bc6ded1'
     and not exists (select 1 from public.questoes where id in (808, 3653) and prova_id = (select id from prova))),
  ('taxonomia municipal: Q11/Q15 -> 411, Q12/Q13 -> 412, Q25 -> 413, Q26 -> 414 (matéria 22)', (select count(*) = 4 from public.assuntos where id between 411 and 414 and materia_id = 22)
     and (select count(*) = 6 from pq where materia_id = 22 and ((numero_original in (11, 15) and assunto_id = 411) or (numero_original in (12, 13) and assunto_id = 412) or (numero_original = 25 and assunto_id = 413) or (numero_original = 26 and assunto_id = 414)))),
  ('Q32 = B (anulação da Q32 nas justificativas é de outro cargo)', exists (select 1 from pq join public.alternativas a on a.questao_id = pq.id and a.correta where pq.numero_original = 32 and a.ordem = 2)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pq where (select count(*) from public.alternativas a where a.questao_id = pq.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pq.id and a.correta) <> 1)),
  ('nenhuma mídia na prova', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pq)))
) v(verificacao, ok);
