-- BM-RS 2025 Soldado de Primeira Classe (Fundatec, concurso 976; Brigada Militar RS, Edital DA/DRESA nº SD-P 01/2025) —
-- REGISTRO SANITIZADO do lote aplicado em 2026-10-28.
--
-- Fontes: caderno 0976.001 "Militar Estadual na Graduação de Soldado de Primeira Classe" (prova de 08/06/2025, 50 questões; hash_prova ffd5e3c72c55…);
-- gabarito definitivo Ed. DA/DRESA nº SD-P 17/2025 (hash 99aca048d311…): preliminar (Ed. 14/2025) → definitivo muda só a Q9 (anulada);
-- as outras 49 mantidas (Anexo Único do Ed. 17); nenhum edital posterior altera gabarito. Leituras linear, posicional e auto idênticas.
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (aplicada antes, 2026-10-28): assunto 420 "Equações do 1º grau" na matéria 12 (Matemática), usado só pela Q33;
--   2. executor de aquisição, manifesto c4ec8288285c610067a4b9e93776a9bac344c9c5dc459b13e19cf5d2875cebd0 (sha256 do JSON canônico), BASE_GLOBAL, prova NOVA:
--      provas.id = 45 (sem prova_partes); prova_documentos 50 (GABARITO ordem 0, Ed. 17/2025);
--      15 novas (ids 4119–4133: CG Q21, Q22, Q23, Q25, Q28, Q30; MAT Q31–Q34, Q36–Q40), 75 alternativas, 0 curso_questoes, 0 mídias;
--      nenhuma liberação de gate;
--   3. qualificação de 27 legados SÓ NA PROVENIÊNCIA (prova_id, numero_original, fonte, concurso; script rollback-testado fora do
--      repositório): enunciado, alternativas, gabarito, explicação, matéria/assunto, dificuldade, ativa, vínculos, unidades, sessões e
--      histórico intactos (as diferenças de texto auditadas — texto-base preenchido, trechos citados, reescrita sem figura — ficam como estão).
-- Fora da prova (8): MANTER_REVISAR Q2→66 e Q6→70 (lacunas/trechos que não estão no texto oficial) e Q35 (figura indispensável que o
-- pipeline não anexa); ADIAR_DECISAO_EDITORIAL Q24, Q26, Q27, Q29 (atualidades estritamente datadas — oficiais e válidas, só fora do lote);
-- IGNORAR Q9 (anulada, sem legado). Cobertura 42/50.
-- Contagens ao fim do lote (registro, não verificação — os totais globais mudam quando a base cresce): questoes 2006, alternativas 9743,
-- provas 15, prova_documentos 21, curso_questoes 1343 (+0), prova_partes 4, assuntos 239, questao_midias 5 (+0).
-- Métrica 5K após o lote: útil real 1735 (automático 1738), oficiais 920/2006 = 45,86%, déficit real 3265.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 42 questões, a prova, o documento e os registros
-- deixados fora do lote (em revisão: 66, 70; falsos positivos do dedup: 787, 328) continuam exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, vinculos) as (
values
  (65, 1, 'legado', 6, 15, '0c23ccd00d3bbfe0395068f29e4c3c2e', 'd317ecaec3f173e3fca137c744bfba56', 'C', 1),
  (67, 3, 'legado', 6, 57, 'b07d955fb18f69e2096743d9cce15949', '50817a5f712867adbfaad8aebf298811', 'B', 1),
  (68, 4, 'legado', 6, 59, '546cdf9213eb9662266f0f9767a9eac2', 'aee6b0de78d03cfc0f148a0c435930f5', 'C', 1),
  (69, 5, 'legado', 6, 55, 'f94763206e193fa161f4a915724ab26e', '261e7e61f336243189c7f762ac28e939', 'C', 1),
  (71, 7, 'legado', 6, 47, 'f24d4a16f318943858082e74c870a32b', 'b104d77e7392c83a70f2c138d23392ff', 'E', 1),
  (72, 8, 'legado', 6, 49, 'bb48e9681c0e1a97bb98c738b441c4c6', '824f3b1d4ac56acc6797fce338c42812', 'A', 1),
  (73, 10, 'legado', 6, 16, 'cae888b30060de8e9a82fdcc3a79d793', 'ddb187d78bf7f085a2ddee7a4ed7bbbb', 'A', 1),
  (46, 11, 'legado', 10, 71, 'd31ecd48a85878282d2f8f33e94791ea', '9f6b535aa52611c2846bfc60c65b41c2', 'A', 1),
  (47, 12, 'legado', 10, 74, 'a62a278090b6a851571b161045a07f1d', 'f772c32af4b61ccbb0f61e151d1f45a5', 'C', 1),
  (48, 13, 'legado', 10, 70, 'ed382fc17f3e9ef61c14415fa1a6ce5c', 'e40dcd885b07856ba01e7ffe9dbf534b', 'D', 1),
  (49, 14, 'legado', 10, 64, 'de24692627013221e0506e3dc5ed0e37', 'a4c6e7a45e3eaeb943dc7e520eaa8a84', 'E', 1),
  (50, 15, 'legado', 10, 68, '9a2a2fc323ca77ba7eeca053f4c1336c', 'a1b264f4ae0aa3e4f1ef21fd4a25db22', 'B', 1),
  (51, 16, 'legado', 10, 19, '3f04954aec4682f9fbc72f067e4473e6', '8655b82102f1d5958fbbb7ff648fa206', 'E', 1),
  (52, 17, 'legado', 10, 80, 'd8a554e45cc736be2b384e394e1fa18d', '9241a9af6c32b92ea1baecb8a485e116', 'A', 1),
  (53, 18, 'legado', 10, 18, 'e7c3e9aa1bd8b91b8d1b50e05e7b8402', '9b4c14da7e0f8487888410057d938b45', 'C', 1),
  (54, 19, 'legado', 10, 75, '3f46a74f950977594f902c5fec66f868', '940485327cebbcb5e44566b927771afc', 'B', 1),
  (41, 20, 'legado', 10, 17, 'f2185fe760d1226b0496de1b5936bafc', '3c2ed929b575a8df60438d7da611f0a9', 'D', 1),
  (4119, 21, 'nova', 13, 20, 'f0285a8cf862677ab163883e8c9e98cf', 'd1730ba7cbe8c9d5000c428a7ac28492', 'C', 0),
  (4120, 22, 'nova', 13, 311, '33c610b3ffa0a40bb80218b0f329f905', 'bbae530424945ea9746daf95872743bf', 'E', 0),
  (4121, 23, 'nova', 13, 313, '7d7b377304859ea4ef5f4a57400e372e', '3f35b88c768a10525b97808cd91ad693', 'B', 0),
  (4122, 25, 'nova', 13, 20, '81c0e619e6101bdf8345a53f2a48fc88', '5aaaf816857acf4d320614068d21c47d', 'A', 0),
  (4123, 28, 'nova', 13, 311, '0aaf74908a679c3da64ba1c59cf5d91e', '7c99e643e77de63efa545dcc42e99988', 'B', 0),
  (4124, 30, 'nova', 13, 20, 'ccb050d0fbfcbe5353648c1a2799387d', 'bbae530424945ea9746daf95872743bf', 'E', 0),
  (4125, 31, 'nova', 12, 24, '05ebeeda17b3000b54e32e7dbf28583e', '2356166dd7bfa19b1cc936f044f00688', 'D', 0),
  (4126, 32, 'nova', 12, 23, '84c55b19353aab20652aced4cabcffd2', 'e7da389cca58984129954897d74dd49a', 'B', 0),
  (4127, 33, 'nova', 12, 420, 'bd2575ee17a6d290e7384ebf4dee95ef', '0daf44217b0a22c7dfad138018794d1c', 'E', 0),
  (4128, 34, 'nova', 12, 291, '847b9fd8535d0b5ec87dd23335294417', 'cdce58a66b6a594e8d8b5bc68e0c0e27', 'A', 0),
  (4129, 36, 'nova', 12, 292, '0475531fea649a2cc4125335b7e80f7e', 'a0a125e807176475a33c1fe605aa4e21', 'A', 0),
  (4130, 37, 'nova', 12, 295, '198c28c80d183e52ff1efe4673fc1ee7', '44e61c20e3ca04135e952169e19d93db', 'B', 0),
  (4131, 38, 'nova', 12, 291, 'd11c4fdda14a5cadb210904b31aa3387', 'fd7148a59a2cfad03cc3cd3b44999db8', 'C', 0),
  (4132, 39, 'nova', 12, 296, '67ba5735e19068555b18a916efc5560f', 'b41c3497918ca0ff38e425615e759241', 'C', 0),
  (4133, 40, 'nova', 12, 23, '521cb6b081348e4dd32443a656b282a1', 'f89f7306f1100a36a2d564a688b53500', 'E', 0),
  (55, 41, 'legado', 11, 27, 'afb093579152c076b14547502afe2e8a', 'd075bddac2334d61e2e4b7773f627318', 'A', 1),
  (56, 42, 'legado', 11, 90, 'd65f4902e9c4bcf7ac049494bd54ca6f', '4b11bf62bcef6af4b61d290d258b2eb0', 'C', 1),
  (57, 43, 'legado', 11, 103, '663dc775b2e28469459a32d805b0aa64', '8047196ef49eb696a5be4bb50ab77e12', 'D', 1),
  (58, 44, 'legado', 11, 85, 'dd6e4031c96e696225895cd3779a00fa', '5025487a6c80014de08c07d16cbd8a7b', 'B', 1),
  (59, 45, 'legado', 11, 102, '08858e20b14af74a8584fe0a0a1345e7', 'f8a853620e9c902b7481e1cb88054cc4', 'E', 1),
  (60, 46, 'legado', 9, 28, 'eadb775e1c561a33394af0c01586e8d8', 'e4b6d0d9a10219f8177755453a30f460', 'E', 1),
  (61, 47, 'legado', 9, 61, '8d37d7fa8f6e4b96175cc1c49cc86504', '86c0e3d3098a95187810d15496905889', 'C', 1),
  (62, 48, 'legado', 9, 29, '84126cd5edec54bcba70a0104f289111', '293c29d77c8dfe1fdf90ba89983b5800', 'B', 1),
  (63, 49, 'legado', 9, 62, '0f2ff7503c0fd63a629ef88afac5abdc', 'c949ceb213972af8f3b85ad188e12dbf', 'A', 1),
  (64, 50, 'legado', 9, 62, '1f7ea199c472032aefc5c01a27ce0d68', 'fb021ede49b0cef18d320bfa6ab3ef4b', 'D', 1)
),
prova as (
  select id from public.provas where hash_prova = 'ffd5e3c72c550dbe4b9b87ef04d27aa42fbabdfb11505c72ab4a2f35d412869e'
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
  select id from public.provas where hash_prova = 'ffd5e3c72c550dbe4b9b87ef04d27aa42fbabdfb11505c72ab4a2f35d412869e'
),
pq as (
  select q.* from public.questoes q where q.prova_id = (select id from prova)
)
select verificacao, ok from (values
  ('prova_id = 45 (hash_prova ffd5e3c72c55…), uma só, Soldado de Primeira Classe, caderno 0976.001, gabarito definitivo Ed. 17, sem prova_partes', (select count(*) = 1 from public.provas where hash_prova = 'ffd5e3c72c550dbe4b9b87ef04d27aa42fbabdfb11505c72ab4a2f35d412869e') and (select id from prova) = 45
     and exists (select 1 from public.provas p where p.id = 45 and p.hash_gabarito = '99aca048d31128dffe808207af97a210b3f5fc2773919280d14a3629f207a7c2' and p.cargo = 'Soldado de Primeira Classe' and p.fonte_url like '%0976.001%')
     and not exists (select 1 from public.prova_partes where prova_id = 45)),
  ('prova_documentos da prova 45: só o GABARITO ordem 0 Ed. 17/2025 (99aca048d311…)', (select count(*) = 1 from public.prova_documentos d where d.prova_id = 45)
     and exists (select 1 from public.prova_documentos d where d.id = 50 and d.prova_id = 45 and d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = '99aca048d31128dffe808207af97a210b3f5fc2773919280d14a3629f207a7c2')),
  ('prova 45 = 42/50 (15 novas + 27 legados): Q1, Q3, Q4, Q5, Q7, Q8, Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q25, Q28, Q30, Q31, Q32, Q33, Q34, Q36, Q37, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48, Q49, Q50', (select count(*) = 42 and count(distinct numero_original) = 42 and bool_and(numero_original in (1, 3, 4, 5, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 28, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50)) from pq)),
  ('15 novas = ids 4119–4133, todas na prova 45, globais, não-IA, ativas, sem curso_questoes, com matéria e assunto', (select count(*) = 15 and bool_and(materia_id is not null and assunto_id is not null and usuario_id is null and not gerada_por_ia and ativa) from public.questoes where id between 4119 and 4133 and prova_id = 45)
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 4119 and 4133)),
  ('15 novas sem respostas, erros, sessões, comentários, unidades ou mídias', not exists (select 1 from public.respostas_usuarios r where r.questao_id between 4119 and 4133)
     and not exists (select 1 from public.erros_usuarios e where e.questao_id between 4119 and 4133) and not exists (select 1 from public.sessao_questoes_planejadas s where s.questao_id between 4119 and 4133)
     and not exists (select 1 from public.questao_comentarios c where c.questao_id between 4119 and 4133) and not exists (select 1 from public.questao_unidades_pedagogicas u where u.questao_id between 4119 and 4133)
     and not exists (select 1 from public.questao_midias m where m.questao_id between 4119 and 4133)),
  ('27 legados qualificados com fonte/concurso do executor, sem parte', (select count(*) = 27 from pq where (id, numero_original) in ((65, 1), (67, 3), (68, 4), (69, 5), (71, 7), (72, 8), (73, 10), (46, 11), (47, 12), (48, 13), (49, 14), (50, 15), (51, 16), (52, 17), (53, 18), (54, 19), (41, 20), (55, 41), (56, 42), (57, 43), (58, 44), (59, 45), (60, 46), (61, 47), (62, 48), (63, 49), (64, 50))
     and prova_parte_id is null and fonte = 'Fundatec — BM/RS - Concurso Público Edital DA/DRESA nº SD-P 01/2025 - Militar Estadual na Graduação de Soldado de Primeira Classe (Polícia Ostensiva - Carreira de Nível Médio) — Questão ' || lpad(numero_original::text, 2, '0') and concurso = 'Brigada Militar do Estado do Rio Grande do Sul - BM/RS - Soldado de Primeira Classe')),
  ('27 legados: explicação e dificuldade preservadas (md5); unidades e sessões planejadas inalteradas', (select count(*) = 27 from public.questoes q join (values
       (65, '56fbc2857206687ad9b1b8b668b31feb', 'media', 1, 0),
       (67, '21db5f2246ccead3ae5696a1f1f8a279', 'media', 1, 0),
       (68, '40d06631ec3fa3cc741f7e62f0f8ede8', 'media', 1, 0),
       (69, 'e22562dbdf695a132bc4ac94e1f17932', 'media', 1, 0),
       (71, '9dcf49dc39810d3f762b9f257a63af69', 'media', 0, 0),
       (72, '5bb6fe41b6f6dee8d33c3d0c1169800e', 'media', 1, 0),
       (73, 'a88a0b56d93d354c1cb4b838254b743a', 'media', 1, 0),
       (46, 'b5e053bbd931380ef73366dc8611bd7d', 'media', 0, 0),
       (47, '719a039634a2564277903a0bcf8663ae', 'media', 1, 0),
       (48, '2ea7f397ea620f5bf35d169a2672dbc1', 'media', 1, 0),
       (49, '858889225291fbc99696a9e2f94b641a', 'media', 1, 0),
       (50, 'a86e973ff1e268f5d399f15ee4f520ac', 'media', 1, 0),
       (51, 'bd2b385ef3e97d0729b2574b70ea144f', 'media', 2, 0),
       (52, 'f83357943a8b3f1efa7b5eb2d770d4a0', 'media', 1, 0),
       (53, 'b04a9a4141a6644c5a13cd4bbf3a0880', 'media', 1, 0),
       (54, '29aabda9fbb930416963ae0c7254fe2b', 'media', 1, 0),
       (41, 'e92eddf2dfa384d30908cbfe790e8084', 'media', 1, 0),
       (55, '0ce8fdb24699ba9f0e37ef5395021c35', 'media', 1, 0),
       (56, 'a087f9aa53e65ffe3ef1fbb8c20c8354', 'media', 1, 0),
       (57, '7683f00e4809a3c54f7606256176bbac', 'media', 1, 0),
       (58, '555e3a083b20fa48832abf38a0fca6ca', 'media', 1, 0),
       (59, 'c53a3c87560fc8e94b912bd3959998ef', 'media', 1, 1),
       (60, '749e0916f27a7a90d319882301556de7', 'media', 1, 0),
       (61, '455c5cfa244b1e0e31711c6a5adbcc54', 'media', 1, 0),
       (62, 'b93d80818d98d05da943e345ab62b5e1', 'media', 1, 0),
       (63, '650430b8ccbd3b7cecfab032754dcbf2', 'media', 1, 0),
       (64, 'bc0f967597ce3acfd450506656007754', 'media', 0, 0)
     ) e(id, md5_explicacao, dificuldade, unidades, sessoes) on e.id = q.id
     where md5(coalesce(q.explicacao, '')) = e.md5_explicacao and q.dificuldade = e.dificuldade
       and (select count(*) from public.questao_unidades_pedagogicas u where u.questao_id = q.id) = e.unidades
       and (select count(*) from public.sessao_questoes_planejadas s where s.questao_id = q.id) = e.sessoes)),
  ('27 legados sem mídia (Q3, Q46, Q47, Q50 seguem só texto)', not exists (select 1 from public.questao_midias m where m.questao_id in (65, 67, 68, 69, 71, 72, 73, 46, 47, 48, 49, 50, 51, 52, 53, 54, 41, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64))),
  ('fora da prova 45: Q2, Q6, Q35 (MANTER_REVISAR), Q24, Q26, Q27, Q29 (ADIAR_DECISAO_EDITORIAL), Q9 (IGNORAR, anulada); nenhuma questão com a fonte deste lote fora dela', not exists (select 1 from pq where numero_original in (2, 6, 9, 24, 26, 27, 29, 35))
     and not exists (select 1 from public.questoes q where q.fonte like 'Fundatec — BM/RS - Concurso Público Edital DA/DRESA nº SD-P 01/2025 - Militar Estadual na Graduação de Soldado de Primeira Classe (Polícia Ostensiva - Carreira de Nível Médio) — Questão %' and q.prova_id is distinct from 45)),
  ('em revisão (66/Q2, 70/Q6) sem proveniência e com conteúdo intocado (md5 de enunciado, alternativas e explicação; gabarito; matéria/assunto; ativa)', (select count(*) = 2 from public.questoes q join (values
       (66, 'ac9bb6639fbd458c51f47d9f59bb97b4', '894ecb4eefc68b00d4527422ec0a10a8', 'ba47316903cb136fb8f302fa6c31d687', 'E', 6, 53, true),
       (70, '76fc0177608234fa016ff4134080b9b8', 'd47c974eaf1c912b2d806ae89ef5fb82', '30f2823fc7841df94afdf612948dc772', 'D', 6, 5, true)
     ) e(id, md5_enunciado, md5_alternativas, md5_explicacao, gabarito, materia_id, assunto_id, ativa) on e.id = q.id
     where q.prova_id is null and q.numero_original is null and md5(q.enunciado) = e.md5_enunciado and md5(coalesce(q.explicacao, '')) = e.md5_explicacao and q.ativa = e.ativa
       and q.materia_id = e.materia_id and q.assunto_id = e.assunto_id
       and (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) = e.md5_alternativas
       and (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) = e.gabarito)),
  ('66, 70 (em revisão) e 787, 328 (falsos positivos do dedup para Q2/Q6) intocados: linhas inteiras = linha de base pré-apply (md5 f5d30711…)', (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.questoes q where q.id in (66, 70, 787, 328)) = 'f5d30711f1497bb71996e9058dd2f152'),
  ('assunto 420 = Matemática / Equações do 1º grau, usado só pela Q33 (4127)', exists (select 1 from public.assuntos s where s.id = 420 and s.materia_id = 12 and s.nome = 'Equações do 1º grau' and s.usuario_id is null)
     and (select count(*) = 1 from public.questoes where assunto_id = 420) and exists (select 1 from pq where id = 4127 and numero_original = 33 and materia_id = 12 and assunto_id = 420)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pq where (select count(*) from public.alternativas a where a.questao_id = pq.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pq.id and a.correta) <> 1)),
  ('nenhuma mídia na prova 45', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pq) or m.prova_id = 45))
) v(verificacao, ok);
