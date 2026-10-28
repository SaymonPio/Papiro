-- PP-RS 2022 Analista da Polícia Penal — Direito (Fundatec, concurso 650, cargo 6; SUSEPE/RS Concurso Público nº 01/2022) —
-- REGISTRO SANITIZADO do lote aplicado em 2026-10-28.
--
-- Fontes: caderno 0650.006 "Técnico Superior Penitenciário – Direito" (hash_prova 786615b05b71…, 70 questões + dissertativa);
-- gabarito definitivo do cargo 6, página oficial HTML de 18/04/2022 (hash b5b61323f983…): Q22 D→E e Q24 anulada;
-- Ed. 20/2022 retificativo do nível superior (hash 954dfcacb947…): anula a Q22. Anuladas finais: Q22, Q24.
-- O Ed. 43/2026 (anulação individual da Q77 do Policial Penal) não afeta este cargo. Leitura POSICIONAL explícita (a linear cola o
-- rodapé do cargo na alternativa E da Q50 — o gate divergencia_entre_leituras pega).
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (aplicada antes, 2026-10-28): assunto 418 "Direito das coisas (posse e propriedade)" na matéria 33 (Direito Civil), usado só pela Q61;
--   2. executor de aquisição, manifesto abb9419232e18fe76b39b70c2cd5b6dd5264953c5f0b5c8102c4ca37eb69e8b5 (sha256 do JSON canônico), BASE_GLOBAL, prova NOVA:
--      provas.id = 42 (sem prova_partes); prova_documentos 47 (GABARITO ordem 0) e 48 (RETIFICACAO ordem 1, Ed. 20/2022);
--      16 novas (ids 4088–4103, Q54–Q69), 80 alternativas, 0 curso_questoes, 0 mídias; nenhuma liberação de gate;
--   3. qualificação de 2 legados TEC SÓ NA PROVENIÊNCIA (prova_id, numero_original, fonte, concurso; script rollback-testado fora do
--      repositório): Q52→871 (idêntico), Q53→860 (difere só em quebras de linha); enunciado, alternativas, gabarito, explicação,
--      matéria/assunto, dificuldade, ativa, vínculos, unidades e histórico intactos.
-- Fora da prova:
--   46 duplicatas exatas já representadas na prova 23 (Policial Penal, mesmo bloco comum Q1–50);
--   MANTER_REVISAR: Q51→841 e Q70→839 (explicação incompatível com as alternativas oficiais), Q26→499 (figura: gate de rotação),
--   Q37→133/865 (canônico pendente na prova 23); IGNORAR: Q22 e Q24 (anuladas; legados 102/92 intocados). Cobertura 18/70 (+46 na prova 23).
-- Contagens ao fim do lote (registro, não verificação — os totais globais mudam quando a base cresce): questoes 1991, alternativas 9668,
-- provas 14, prova_documentos 20, curso_questoes 1343 (+0), prova_partes 4, assuntos 238, questao_midias 5 (+0).
-- Métrica 5K após o lote: útil real 1720 (automático 1723), oficiais 878/1991 = 44,10%, déficit real 3280.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 18 questões, a prova, os documentos e os registros
-- deixados fora do lote (em revisão) continuam exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, vinculos) as (
values
  (871, 52, 'legado', 10, 69, 'b2a767a455f3e4a480d4d984522e103e', 'ef11ef48620ceaf571886b7b1ae721c9', 'A', 1),
  (860, 53, 'legado', 10, 64, 'c6da92b0c5f5ec14c7a24731154b384f', '1c36ba7263e97692aca6e15f7dce7717', 'A', 1),
  (4088, 54, 'nova', 16, 180, '02138058be9a9676a167e4851c24e2b7', 'c209fbd4db3614ff7d4b9b6de2116aed', 'D', 0),
  (4089, 55, 'nova', 3, 340, '63171e5c75569ede5c3865b8ca7902ef', 'ea9974ef7db66db3d8b153267e01fab5', 'A', 0),
  (4090, 56, 'nova', 3, 140, 'c4aaaed9dcfd525125ff35bc44cecff7', '15103d465c08500cc4120e4b12ae35e6', 'B', 0),
  (4091, 57, 'nova', 3, 140, '453e6ffa3f51cbe37da6471a4d702f21', 'af02e87150169b79e5958bdd5f3cacee', 'C', 0),
  (4092, 58, 'nova', 3, 140, '8c1ae5b08776a46bab01bb37ad1daf46', '2cba4323512dc2165a2fd87d47cbac85', 'A', 0),
  (4093, 59, 'nova', 33, 265, 'c828626eee8f10269b406b9e5d675769', '6406d302e16ee2eeb3a657e96cd72c65', 'D', 0),
  (4094, 60, 'nova', 33, 266, '45a14017144450463f0dcd80bd0c16dd', 'ec5ed99fafca63ff50acc3b245af404b', 'B', 0),
  (4095, 61, 'nova', 33, 418, 'c0b6b6b81eeb1495f1a52ccd414ec7eb', '09595a929313ef475f484ec84489d6a6', 'B', 0),
  (4096, 62, 'nova', 5, 248, '851fa026f602b0a9e6938ec543f8fa12', 'cf29b0fa1bb2238e73348d4051b32444', 'C', 0),
  (4097, 63, 'nova', 33, 266, 'ac898331e55cb45019e32a81f5ce4d1f', '7d41178faca466b79c6fcfba21780759', 'C', 0),
  (4098, 64, 'nova', 5, 249, 'f39710428f5edaf5879b2ce2e6e34b25', '82a9cd6734ee67f28ee6d8b310173831', 'E', 0),
  (4099, 65, 'nova', 5, 248, '3bba4c3cf89042429af4b7da0dc02313', '45ad5445ad670cef89133cb6958b7246', 'E', 0),
  (4100, 66, 'nova', 5, 252, '95ddcfa0d2075e84ca73b5fc9e5cdc06', 'd86ca24379c3f4d4d02a47ae9c522ea2', 'D', 0),
  (4101, 67, 'nova', 7, 6, 'c71b6575a8a742f303da8b270784400c', '4ee203d1ec04c61091e599b76da039f4', 'E', 0),
  (4102, 68, 'nova', 8, 142, '046b0cb91fb9161a90080872bbb5f0df', 'c4306937753a8dae10f5384b10775b17', 'E', 0),
  (4103, 69, 'nova', 5, 252, 'c9c96ba49c7036c3f64e82e0b6a351bf', 'd46eb684892f227d1f6c5efe1d2ed87d', 'B', 0)
),
prova as (
  select id from public.provas where hash_prova = '786615b05b71fb341cdfb866ecd1acf105c01f2c2da14c8604f45bcb2c4fb85b'
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
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa and a.vinculos = e.vinculos) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = '786615b05b71fb341cdfb866ecd1acf105c01f2c2da14c8604f45bcb2c4fb85b'
),
pq as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 42 (hash_prova 786615b05b71…), uma só, cargo 6, gabarito definitivo do cargo 6, sem prova_partes', (select count(*) = 1 from public.provas where hash_prova = '786615b05b71fb341cdfb866ecd1acf105c01f2c2da14c8604f45bcb2c4fb85b') and (select id from prova) = 42
     and exists (select 1 from public.provas p where p.id = 42 and p.hash_gabarito = 'b5b61323f9837021ae544f9ac23227189ef1be7238372b16bd41a47b9f561167' and p.cargo = 'Analista da Polícia Penal - Direito' and p.fonte_url like '%0650.006%')
     and not exists (select 1 from public.prova_partes where prova_id = 42)),
  ('prova_documentos da prova 42: GABARITO ordem 0 (b5b61323f983…) e RETIFICACAO ordem 1 Ed. 20/2022 (954dfcacb947…), só esses', (select count(*) = 2 from public.prova_documentos d where d.prova_id = 42)
     and exists (select 1 from public.prova_documentos d where d.id = 47 and d.prova_id = 42 and d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = 'b5b61323f9837021ae544f9ac23227189ef1be7238372b16bd41a47b9f561167')
     and exists (select 1 from public.prova_documentos d where d.id = 48 and d.prova_id = 42 and d.tipo = 'RETIFICACAO' and d.ordem = 1 and d.hash_sha256 = '954dfcacb94719d0c1a2635bc1763b0050bff743b20c3dc3dfaee608e6007f46')),
  ('prova 42 = 18/70 (16 novas + 2 legados): Q52, Q53, Q54, Q55, Q56, Q57, Q58, Q59, Q60, Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68, Q69', (select count(*) = 18 and count(distinct numero_original) = 18 and bool_and(numero_original in (52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69)) from pq)),
  ('16 novas = ids 4088–4103, todas na prova 42, globais, não-IA, sem curso_questoes, com matéria e assunto', (select count(*) = 16 and bool_and(materia_id is not null and assunto_id is not null and usuario_id is null and not gerada_por_ia and ativa) from public.questoes where id between 4088 and 4103 and prova_id = 42)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 4088 and 4103)),
  ('16 novas sem respostas, erros, sessões, comentários, unidades ou mídias', not exists (select 1 from public.respostas_usuarios r where r.questao_id between 4088 and 4103)
     and not exists (select 1 from public.erros_usuarios e where e.questao_id between 4088 and 4103) and not exists (select 1 from public.sessao_questoes_planejadas s where s.questao_id between 4088 and 4103)
     and not exists (select 1 from public.questao_comentarios c where c.questao_id between 4088 and 4103) and not exists (select 1 from public.questao_unidades_pedagogicas u where u.questao_id between 4088 and 4103)
     and not exists (select 1 from public.questao_midias m where m.questao_id between 4088 and 4103)),
  ('2 legados qualificados (871/Q52, 860/Q53) com fonte/concurso do executor, sem parte', (select count(*) = 2 from pq where (id, numero_original) in ((871, 52), (860, 53))
     and prova_parte_id is null and fonte = 'Fundatec — SUSEPE/RS - Concurso Público nº 01/2022 - Analista da Polícia Penal - Direito (Técnico Superior Penitenciário - Direito) — Questão ' || lpad(numero_original::text, 2, '0') and concurso = 'Superintendência dos Serviços Penitenciários do Rio Grande do Sul - SUSEPE/RS - Analista da Polícia Penal - Direito')),
  ('Q22, Q24 (anuladas) e Q26, Q37, Q51, Q70 (revisão) fora da prova 42', not exists (select 1 from pq where numero_original in (22, 24, 26, 37, 51, 70))
     and not exists (select 1 from public.questoes q where q.fonte like 'Fundatec — SUSEPE/RS - Concurso Público nº 01/2022 - Analista da Polícia Penal - Direito (Técnico Superior Penitenciário - Direito) — Questão %' and q.prova_id is distinct from 42)),
  ('legados 871/860: explicação e dificuldade preservadas (md5)', (select count(*) = 2 from public.questoes q join (values
       (871, '468c3ae623b8b83ad0e731ceb7ab8349', 'media'), (860, 'cc3ed84cfd20d1d12b082912afcc82ca', 'media')) e(id, md5_explicacao, dificuldade)
     on e.id = q.id where md5(coalesce(q.explicacao, '')) = e.md5_explicacao and q.dificuldade = e.dificuldade)),
  ('em revisão / anuladas sem proveniência e intocados no lote: 841, 839, 499, 133, 865 (inativa), 102, 92', (select count(*) = 7 from public.questoes where id in (841, 839, 499, 133, 865, 102, 92) and prova_id is null and numero_original is null)
     and exists (select 1 from public.questoes where id = 865 and not ativa)),
  ('em revisão com conteúdo intocado (md5 de enunciado, alternativas e explicação; gabarito; matéria/assunto; ativa): 841, 839, 499, 133, 865', (select count(*) = 5 from public.questoes q join (values
       (841, '982d6bd36c86c4163275c4a8b29ab0b7', '0f7ff18522276d92964694ef431584c5', '321e2930a265a6eff137e5925a293bb4', 'C', 10, 67, true),
       (839, '85047ffe089fd65341106e83b2f37d01', 'fe0962335e9c3499bf9cc21207513bf3', '1f06d87f4b00444f3ee6a94522162888', 'D', 10, 79, true),
       (499, '8590638297e44d6feeb3eda1c580756c', '253f9e12eb95e490cbd90259efaaa52e', '7e02b21a378d336a87d75e299a93df32', 'D', 9, 29, true),
       (133, 'ebe5fa60ac80df5395ab24d3f413aae6', 'aa10c6d519bd8576ea18a684d1350028', 'e38aaef648c6131cf0c492e7be698f31', 'E', 10, 19, true),
       (865, 'b29f8cf4244f89892a66ee32de028cbf', '418ec85e62ccd8fe13a40fcb5f7cf3dc', 'e38aaef648c6131cf0c492e7be698f31', 'E', 10, 19, false)
     ) e(id, md5_enunciado, md5_alternativas, md5_explicacao, gabarito, materia_id, assunto_id, ativa) on e.id = q.id
     where md5(q.enunciado) = e.md5_enunciado and md5(coalesce(q.explicacao, '')) = e.md5_explicacao and q.ativa = e.ativa
       and q.materia_id = e.materia_id and q.assunto_id = e.assunto_id
       and (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = e.md5_alternativas
       and (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) = e.gabarito)),
  ('46 duplicatas representadas na prova 23 (Q1–50 exceto 22, 24, 26, 37)', (select count(distinct numero_original) = 46 from public.questoes where prova_id = 23 and numero_original in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 25, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50))),
  ('assunto 418 = Direito Civil / Direito das coisas (posse e propriedade), usado só pela Q61 (4095)', exists (select 1 from public.assuntos s where s.id = 418 and s.materia_id = 33 and s.nome = 'Direito das coisas (posse e propriedade)' and s.usuario_id is null)
     and (select count(*) = 1 from public.questoes where assunto_id = 418) and exists (select 1 from pq where id = 4095 and numero_original = 61 and materia_id = 33 and assunto_id = 418)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pq where (select count(*) from public.alternativas a where a.questao_id = pq.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pq.id and a.correta) <> 1)),
  ('nenhuma mídia na prova 42', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pq) or m.prova_id = 42))
) v(verificacao, ok);
