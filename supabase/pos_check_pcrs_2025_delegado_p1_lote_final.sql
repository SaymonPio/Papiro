-- PC-RS 2025 Delegado de Polícia — Prova Preambular, PRIMEIRA PARTE (P1, Língua Portuguesa) (Fundatec, concurso 991; Concurso Público nº 04/2025) —
-- REGISTRO SANITIZADO do lote aplicado em 2026-10-27.
--
-- Fontes: caderno único 0991.001 (hash_prova e9f7b048d7b3…, 8 cadernos P1/P2 × tipos 1–4; tipo 1 canônico, P1 = p. 1–14);
-- gabarito definitivo Ed. 06/2026 (hash f0339d9dce0a…, já registrado como GABARITO ordem 0 da prova 19 no lote P2), bloco
-- "PROVA PREAMBULAR (P1) – TIPO 1"; anuladas Q22, Q27, Q29, Q35. Leitura POSICIONAL explícita; três textos-base independentes
-- (TB1 Q1–11, TB2 Q12–21, TB4 Q22–40), suportados desde 6e1b3fd.
--
-- Operações (já aplicadas, nesta ordem):
--   1. taxonomia (aplicada antes, 2026-10-26): assunto 416 "Adjunto adnominal" na matéria 6 (Língua Portuguesa), usado só pela Q39;
--   2. executor de aquisição, manifesto afc45d58343dcbf8bc0119859a121f03b8d85b3f3f0e8144d96f8a94f1e81b85 (sha256 do JSON canônico), BASE_GLOBAL, prova 19 reutilizada:
--      prova_partes.id = 8 (P1, ordem 1); 24 novas (ids 4048–4071), 120 alternativas, 0 curso_questoes, 0 provas, 0 prova_documentos;
--      liberações explícitas (revisão humana, presas a conteudo_hash): Q9, Q20, Q24, Q25, Q31, Q38 (trecho analisado transcrito no comando)
--      e Q10 × 893, Q24 × 243 (falsos positivos de dedup); Q26 pela leitura posicional (a linear perde as alternativas);
--   3. qualificação dos 9 legados TEC SÓ NA PROVENIÊNCIA (prova_id, prova_parte_id, numero_original, fonte, concurso; script
--      rollback-testado fora do repositório): Q1→759, Q2→750, Q3→756, Q5→745, Q6→757, Q7→764, Q17→765, Q18→754, Q28→766;
--      enunciado, alternativas, gabarito, explicação, matéria/assunto, dificuldade, ativa, vínculos, unidades e histórico intactos
--      (conteúdo legado preservado mesmo onde a fonte reescreveu o comando: 750, 756, 745, 754; 764 com dívida SANEAMENTO_TEXTO_LEGADO).
-- Fora da prova: Q15 e Q16 (visuais) e Q40 (dependência de texto incerta), em revisão; Q22, Q27, Q29, Q35 anuladas. Cobertura 33/40.
-- A parte P2 (prova_partes.id = 1, 77 questões) não foi tocada.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto, que as 33 questões e a parte P1 continuam
-- exatamente no estado deixado pela operação.
-- Consulta 1: uma linha por questão (ok = false indica divergência).
-- Consulta 2: verificações do lote (ok = false indica divergência).

with esperado (questao_id, numero_original, origem, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito, vinculos) as (
values
  (759, 1, 'legado', 6, 53, '70cc31b83a502e19a754a69cc01c2f18', 'b76d721ca72f8021f0aa578aa1df3b11', 'E', 1),
  (750, 2, 'legado', 6, 47, '19440fa47e0e986fc48c8d550067b09e', '75a7a6987bd21f99aeddeed22385fb2b', 'D', 1),
  (756, 3, 'legado', 6, 56, '33ab9d1e3271897eb87aa35546fb7c7f', '7d41178faca466b79c6fcfba21780759', 'C', 1),
  (4048, 4, 'nova', 6, 57, 'b485a2c8470e44088ef66971a0ad1eef', '04a8dbfae31bef5a0a453faa64915ff8', 'A', 0),
  (745, 5, 'legado', 6, 44, 'e1d6d20f396af781c4a531b8584fee59', 'deb6394fa47db55bb29ca361195e59f0', 'B', 1),
  (757, 6, 'legado', 6, 56, '861f5eca21764892931ff175057149cc', 'e385614e26fcaadc66078e2a2e109cde', 'E', 1),
  (764, 7, 'legado', 6, 54, '4e754028b5a54c4bff3e9be310c3fe7f', '6fbcd70e2961972299d592835f3f3728', 'E', 1),
  (4049, 8, 'nova', 6, 15, '11917c75f5da1657e8b150b50425b199', '5fc2ef023514c2030be48efc369dbb92', 'B', 0),
  (4050, 9, 'nova', 6, 14, 'b5249246cdb2b387dd1a5abe9d108a3c', 'e4169ad3f8908d443145d5b9acc148ba', 'A', 0),
  (4051, 10, 'nova', 6, 59, '4ef774f00cd8c58d1d4f5956f89e6e70', 'c390004e6e94eb5be411d72b6cae2378', 'A', 0),
  (4052, 11, 'nova', 6, 55, '9984d837024a08085a27b17ed20dd18f', '7d41178faca466b79c6fcfba21780759', 'C', 0),
  (4053, 12, 'nova', 6, 15, '36cec514f6e1854b3cbabefca16e76fb', 'e4169ad3f8908d443145d5b9acc148ba', 'A', 0),
  (4054, 13, 'nova', 6, 59, '441f340af35d45cecca1b2a1e4f51404', 'de223613ccc43329e7cfde0eab4f7716', 'B', 0),
  (4055, 14, 'nova', 6, 43, '8ca19ff3f762fd86b2d35974a4aa034f', '7d41178faca466b79c6fcfba21780759', 'C', 0),
  (765, 17, 'legado', 6, 54, 'd895d516074394f3234301205313df7e', '6382d457cb4708940adc7c358c8beae7', 'E', 1),
  (754, 18, 'legado', 6, 45, 'ddcb0acacad5f69a5828fa75b99003df', 'd317ecaec3f173e3fca137c744bfba56', 'C', 1),
  (4056, 19, 'nova', 6, 48, '4f2b12169afc6898a3f6c551a6bc4756', '9ae27f36da8fd537882ab143fc73903d', 'A', 0),
  (4057, 20, 'nova', 6, 50, 'b9984c464e9456d1085d5bae659cc61c', '22cb4c9f66c03a0b316abec9a9ff2612', 'B', 0),
  (4058, 21, 'nova', 6, 59, '3bdfa72ff5d4cb3704b324cd887dd2b0', '85e3bafad81ac788c842a50b24f93e2a', 'B', 0),
  (4059, 23, 'nova', 6, 55, '683b1f9d3407c330b64e88f54dcce6ff', 'e7d43b2c80f4980005ca2bdcbff85ef0', 'E', 0),
  (4060, 24, 'nova', 6, 51, '232c508c24a3249272f65b32209d167a', 'e5b1353266be4a276bb15ac44670ab34', 'C', 0),
  (4061, 25, 'nova', 6, 47, '6e832519cdf1ca28d8430b1b34d78f05', 'ed6e11c0e686224a161a439fa1e3b0a1', 'E', 0),
  (4062, 26, 'nova', 6, 59, '566788574ffd084ccd90f2aa51a7b955', '7d41178faca466b79c6fcfba21780759', 'C', 0),
  (766, 28, 'legado', 6, 54, '8d061a41ce5dda80bcf463b4909522a8', 'ef41599870b9455984a838398e3c0fa7', 'D', 1),
  (4063, 30, 'nova', 6, 50, 'f695e830a1276c1cfac9bd469a9cbd0e', '4dfd5247772ef60543b99f63825b059e', 'A', 0),
  (4064, 31, 'nova', 6, 5, '53fe0cd7550abd39c80cd94453d81122', 'a63824fe59aa96b8a57c589edc6608df', 'E', 0),
  (4065, 32, 'nova', 6, 55, '128fa84db18e0587a46f9114ec46ee40', 'b4b51294d2fb8c73250ec9883c5c49d2', 'E', 0),
  (4066, 33, 'nova', 6, 30, '36cdaba3c33ce421ed49c9111d9c9fba', '028e1eab64c3cdbfab718e2905f8ab9a', 'C', 0),
  (4067, 34, 'nova', 6, 14, '875004d439ce55378fb938798babd5e4', 'b71f06cf03cab68839b5161ddf13362f', 'D', 0),
  (4068, 36, 'nova', 6, 59, 'ee5144128d3b95cbeb1c5cc6d9097642', 'b87266dbc5da1db335399a57d998a9bb', 'D', 0),
  (4069, 37, 'nova', 6, 49, 'bd3249ac700176a270f09854eaca9f46', '0e985c2e8c67ac3a0f3d10aa04272028', 'D', 0),
  (4070, 38, 'nova', 6, 49, '3e6070d1a19c75fd0244605c230e67fa', '08815ba7e2ee0dd20c8287905f0cab29', 'A', 0),
  (4071, 39, 'nova', 6, 416, 'be6e60f41368fb6624837a36bb015923', '97842824f3b0d5d2d4e8f731ce7076e0', 'C', 0)
),
prova as (
  select id from public.provas where hash_prova = 'e9f7b048d7b349e32dc25b1414babd3c1a7cc095add5e90a9a01fd570d479927'
),
parte as (
  select pp.id from public.prova_partes pp where pp.prova_id = (select id from prova) and pp.codigo = 'P1' and pp.ordem = 1
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
       (a.id is not null and a.prova_id = (select id from prova) and a.prova_parte_id = (select id from parte) and a.numero_original = e.numero_original
        and a.usuario_id is null and a.materia_id = e.materia_id and a.assunto_id = e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.n_alternativas = 5 and a.n_corretas = 1 and a.ativa and a.vinculos = e.vinculos) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

with prova as (
  select id from public.provas where hash_prova = 'e9f7b048d7b349e32dc25b1414babd3c1a7cc095add5e90a9a01fd570d479927'
),
parte as (
  select pp.id from public.prova_partes pp where pp.prova_id = (select id from prova) and pp.codigo = 'P1' and pp.ordem = 1
),
pq as (
  select q.* from public.questoes q where q.prova_parte_id = (select id from parte)
)
select verificacao, ok from (values
  ('prova_id = 19 (hash_prova e9f7b048d7b3…), uma só, gabarito Ed. 06/2026', (select count(*) = 1 from public.provas where hash_prova = 'e9f7b048d7b349e32dc25b1414babd3c1a7cc095add5e90a9a01fd570d479927') and (select id from prova) = 19
     and exists (select 1 from public.provas p where p.id = 19 and p.hash_gabarito = 'f0339d9dce0aba5ae9a76914e2b58f69e6b5d63462b5b7c3418a2cd6c695c26e')),
  ('prova_partes da prova 19: P1 = id 8 (ordem 1) e P2 = id 1 (ordem 2), só essas', (select count(*) = 2 from public.prova_partes where prova_id = 19)
     and (select id from parte) = 8 and exists (select 1 from public.prova_partes where id = 1 and prova_id = 19 and codigo = 'P2' and ordem = 2)),
  ('prova_documentos da prova 19: só o GABARITO ordem 0 (Ed. 06/2026), sem documento novo', (select count(*) = 1 from public.prova_documentos d where d.prova_id = 19)
     and exists (select 1 from public.prova_documentos d where d.prova_id = 19 and d.tipo = 'GABARITO' and d.ordem = 0 and d.hash_sha256 = 'f0339d9dce0aba5ae9a76914e2b58f69e6b5d63462b5b7c3418a2cd6c695c26e')),
  ('P1 = 33/40 (24 novas + 9 legados), fora 15, 16, 22, 27, 29, 35, 40', (select count(*) = 33 and count(distinct numero_original) = 33 and bool_and(numero_original between 1 and 40 and numero_original not in (15, 16, 22, 27, 29, 35, 40)) and bool_and(prova_id = 19) from pq)),
  ('24 novas = ids 4048–4071, todas na P1, sem curso_questoes, matéria 6 com assunto', (select count(*) = 24 and bool_and(materia_id = 6 and assunto_id is not null and usuario_id is null and not gerada_por_ia) from public.questoes where id between 4048 and 4071 and prova_parte_id = (select id from parte))
     and not exists (select 1 from public.curso_questoes cq where cq.questao_id between 4048 and 4071)),
  ('24 novas sem respostas, erros, sessões, comentários, unidades ou mídias', not exists (select 1 from public.respostas_usuarios r where r.questao_id between 4048 and 4071)
     and not exists (select 1 from public.erros_usuarios e where e.questao_id between 4048 and 4071) and not exists (select 1 from public.sessao_questoes_planejadas s where s.questao_id between 4048 and 4071)
     and not exists (select 1 from public.questao_comentarios c where c.questao_id between 4048 and 4071) and not exists (select 1 from public.questao_unidades_pedagogicas u where u.questao_id between 4048 and 4071)
     and not exists (select 1 from public.questao_midias m where m.questao_id between 4048 and 4071)),
  ('9 legados qualificados na P1 com fonte/concurso do executor', (select count(*) = 9 from pq where (id, numero_original) in ((759, 1), (750, 2), (756, 3), (745, 5), (757, 6), (764, 7), (765, 17), (754, 18), (766, 28))
     and fonte = 'Fundatec — PC-RS - Concurso Público nº 04/2025 - Delegado de Polícia - Prova Preambular — Questão ' || lpad(numero_original::text, 2, '0')
     and concurso = 'Polícia Civil do Estado do Rio Grande do Sul - Delegado de Polícia')),
  ('Q15, Q16 e Q40 (revisão) e Q22, Q27, Q29, Q35 (anuladas) fora do banco como questões da P1', not exists (select 1 from public.questoes q where q.prova_id = 19 and q.prova_parte_id = (select id from parte) and q.numero_original in (15, 16, 22, 27, 29, 35, 40))
     and not exists (select 1 from public.questoes q where q.fonte like 'Fundatec — PC-RS - Concurso Público nº 04/2025 - Delegado de Polícia - Prova Preambular — Questão %' and q.prova_parte_id is distinct from 1 and q.prova_parte_id is distinct from (select id from parte))),
  ('Q26 = leitura posicional aprovada (md5 do enunciado e das 5 alternativas)', exists (select 1 from pq where numero_original = 26 and md5(enunciado) = '566788574ffd084ccd90f2aa51a7b955'
     and (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = pq.id) = '7d41178faca466b79c6fcfba21780759')),
  ('assunto 416 = Língua Portuguesa / Adjunto adnominal, usado só pela Q39', exists (select 1 from public.assuntos s join public.materias m on m.id = s.materia_id where s.id = 416 and s.materia_id = 6 and s.nome = 'Adjunto adnominal')
     and (select count(*) = 1 from public.questoes where assunto_id = 416) and exists (select 1 from pq where numero_original = 39 and assunto_id = 416)),
  ('parte P2 intacta: 77 questões na prova_partes.id = 1', (select count(*) = 77 from public.questoes where prova_parte_id = 1 and prova_id = 19)),
  ('5 alternativas e exatamente 1 correta em todas', not exists (select 1 from pq where (select count(*) from public.alternativas a where a.questao_id = pq.id) <> 5
     or (select count(*) from public.alternativas a where a.questao_id = pq.id and a.correta) <> 1)),
  ('nenhuma mídia na P1', not exists (select 1 from public.questao_midias m where m.questao_id in (select id from pq)))
) v(verificacao, ok);
