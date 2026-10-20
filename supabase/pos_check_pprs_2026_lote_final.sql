-- PP-RS 2026 (Fundatec, Polícia Penal RS — cargo 24 Policial Penal) — REGISTRO
-- SANITIZADO do lote de conclusão aplicado em 2026-10-20.
--
-- Operação (já aplicada pelo executor de aquisição, modo BASE_GLOBAL): 43
-- questões oficiais novas (questoes.id 2949-2991) na prova já cadastrada
-- provas.id = 12 (hash_prova f8acc43b…), manifesto aprovado de hash
-- 4e0cdcc7e76c65587ae14705a662b2bdf6fca744975c04a729ca6c87f023700c.
-- Gabarito definitivo do Edital nº 24/2026 + retificação do Edital nº 27/2026
-- (documentos já registrados em prova_documentos). Classificação nas
-- matérias/assuntos de manutencao_pprs_2026_taxonomia_prisional.sql e em
-- matérias globais existentes; nenhum vínculo de curso, nenhuma mídia.
-- Liberações explícitas revisadas: Q12 (EXTRACAO_OK/referencia_visual) e 6
-- prováveis duplicadas descartadas (Q18, Q23, Q31, Q56, Q58, Q74 — cada uma
-- presa à questao_id legada comparada). Fora do lote: Q6 (revisão manual —
-- destaque em negrito não representável) e Q15/Q17/Q75 (anuladas).
-- Staging, manifesto real e aprovacao.json ficam FORA do repositório.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto,
-- que as 43 questões continuam no estado deixado pela operação. Linhas com
-- ok = false indicam divergência.

with esperado (questao_id, numero_original, materia_id, assunto_id, md5_enunciado, md5_alternativas, gabarito) as (
values
  (2949, 12, 6, null, 'af96ded5b0bf746d61dad9bd3c33d89a', '66cf8b79b78fb1c9ea6281dd9a08fa26', 'A'),
  (2950, 18, 6, 15, 'b04203a29dc707dad89284f59354782c', 'e4e45b369d6644992b55b98f8ebf5f28', 'E'),
  (2951, 23, 9, 61, '83495d1837e111e221eb1652853a23f7', '7b2b659b78e0810abbf38b26516153bb', 'A'),
  (2952, 31, 18, 34, 'f7da30a1eab9a73cdc0b9b3f827ddad2', '6cf45f5446a8b661f2a0bbc1404bed46', 'E'),
  (2953, 41, 25, 136, '9a83cce602653e64e3997f4d50f64871', '268c61bae35dfa7e2bcab6555dacd82a', 'A'),
  (2954, 42, 25, 136, 'c58269d2a9455622a522eb0d7be50aec', '6b0714c1bca9c204b95c196015fcc4ba', 'D'),
  (2955, 43, 25, 137, 'dfe58faba91e5a60ef53503503570463', 'b861dda65a78e44be46a048f804c0ceb', 'A'),
  (2956, 44, 26, 138, '6305894594925e9feb71e1cdc68be481', '9a7c96f449bda71a86b34517babe2712', 'D'),
  (2957, 45, 26, 138, 'ab69ee36e4a5ac198a8e84b9ca43cebd', 'a82f6c52ea25af5b479aaca6e7bfaacc', 'C'),
  (2958, 46, 26, 138, '561d43f5b9a542387a01692925822a85', 'a723af60ee024bcb180e50a39a30bbbd', 'E'),
  (2959, 47, 26, 139, '9cce617ef1b19e8d2029328846af664f', 'd4e7768d0c382c656f108ddabbc871f2', 'E'),
  (2960, 48, 26, 139, 'e75714b8cc43230920fd645285991caf', '4b11bf62bcef6af4b61d290d258b2eb0', 'C'),
  (2961, 49, 26, 139, '6068b383d3f36139d91d8f71189dea0e', '5fb64abe30e620fb13e4fa42f0e17dac', 'B'),
  (2962, 50, 26, 139, '578d74b649f30e7a8f93b1b5a2ed2dbf', '7777c9b931c8b227ee6ee307309ea648', 'B'),
  (2963, 51, 3, 141, '36f384d20ee8f3ab537339097c34f1f5', 'bad6d14a6836ac3139f161b6dc8f7a7b', 'E'),
  (2964, 52, 3, 141, '4f9f730e343af8d44e681c0e9a3beead', '35935a5ad308751bc4ba7dec8088ec93', 'A'),
  (2965, 53, 3, 141, '18ba92da26e6473eb25c1ad6a3f74fba', '1fd1e2b7b246eb5f2312788b361d7682', 'E'),
  (2966, 54, 3, 140, '7ff092a4beec9d4891a30c462f852cce', '30dfea3342a3060da4b7481da188fcf4', 'C'),
  (2967, 55, 3, 140, 'a52755fc4239f2f62a768ad575dd7a22', '9de3d27ac11ba4c7787e5c0f82149912', 'A'),
  (2968, 56, 3, 2, '52bdebf9b86702725d11d2eee4584319', '47aab836874f9ed46088c4f01d9c2b17', 'D'),
  (2969, 57, 3, null, '4b201b50a64f8199930540bac3304815', 'fafe2291f329824be31f2ebf897f13a7', 'B'),
  (2970, 58, 16, 146, '8bb508be2c64b5a79b2963deeb015c67', '75bc1c629adcca41026d0caaf35d6b8d', 'C'),
  (2971, 59, 25, 137, 'a63b3487037f3df8bca498bf23c3df32', '75a7a6987bd21f99aeddeed22385fb2b', 'D'),
  (2972, 60, 25, null, 'a952b60f56bf79063752a4d69e95ba18', '9a7c96f449bda71a86b34517babe2712', 'D'),
  (2973, 61, 25, 137, 'd5dd92f9eb3183d9964704ed6e680428', '908942aaf3fb31da36e793989e3fce8f', 'B'),
  (2974, 62, 25, 137, 'ac608d7249baaaa4b52e151eabb68a22', '6307c0f06103ebd43565629c06e4ee5e', 'A'),
  (2975, 63, 25, 137, '2b12cba29616c573110127d39b846c29', 'c3a8bd4c5900014a019c738b2eeb20de', 'B'),
  (2976, 64, 5, null, '3a18f3ef230f6be736507990577a02b8', 'c1b8fededa75afefabbe35f6a49b1a23', 'C'),
  (2977, 65, 5, null, 'c3b6c9f810d6c940dcd415c255d32fde', '5aa748e9ee3b5c8d27cb6c0cf12c4a6c', 'A'),
  (2978, 66, 5, null, 'eb16a8da25e86f8268c80b8e17a91f26', 'd317ecaec3f173e3fca137c744bfba56', 'C'),
  (2979, 67, 5, 8, '90aa0a280fb3e04dc33a7864955b60c8', '9a7c96f449bda71a86b34517babe2712', 'D'),
  (2980, 68, 8, 142, '42fca61e82b9dd89b6c677a0de4fde30', '26f89bfad96cc219762f9a6162defc04', 'E'),
  (2981, 69, 8, 142, 'a9834a26bbbbdf2895ebcc565ac732d1', '8452c7fb0ec3b808c47723731e5b9aab', 'A'),
  (2982, 70, 8, 142, 'cbb022db3dd9ef63570a648bc9d3c78f', 'aebf3aed99db326a01f172473a9b7f51', 'C'),
  (2983, 71, 8, 143, '7f8fb66638037a64bb3bccd611b53ba4', 'f8a16b14bcfce1e490d9a2260cc5c6bb', 'C'),
  (2984, 72, 8, 143, 'aa39691c2e51821425ce98a1aa614ab6', '4dc67f835750959350ef064be3be8a08', 'E'),
  (2985, 73, 8, 144, 'f10297ad8d6637b246f0008bf03d7894', 'aa33c6d6f6a4890139785fd3384f8a92', 'E'),
  (2986, 74, 11, 102, '02de553f1ebbdc49491c4b5b9d532a3a', 'c127e54ce13050ab1bff77db5970dd9b', 'D'),
  (2987, 76, 8, 145, '3d99a0a1455ec78f8a3a9d7aea68c686', 'bbae530424945ea9746daf95872743bf', 'E'),
  (2988, 77, 8, 145, 'd38b317ac076e2cba3fbcf38b14ec8ed', 'd898a9b9bf062ecdf7007882def34abf', 'C'),
  (2989, 78, 8, 145, '5e5dc96bc904c92c1487bb62d61b96ba', '74dd25d7578f67a14eb6eb782f39022c', 'A'),
  (2990, 79, 8, 145, '383ff0145790476bf521f283dbb557c2', '6d9d26769f6c3adf256cc4e5d67baaa9', 'D'),
  (2991, 80, 11, 90, '312f3379169c1c41bd532dda22dc5419', '890ae7e8ef7ea510e3347660a432af7a', 'B')
),
prova as (
  select id from public.provas where hash_prova = 'f8acc43be8aa1822690f5d604844af2138d3739a1a8992202b9b1ebd003f6adc'
),
atual as (
  select q.id, q.prova_id, q.numero_original, q.usuario_id, q.ativa, q.materia_id, q.assunto_id, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito,
         (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
         (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as corretas,
         (select count(*) from public.curso_questoes cq where cq.questao_id = q.id) as vinculos,
         (select count(*) from public.questao_midias m where m.questao_id = q.id) as midias
    from public.questoes q
)
select e.numero_original, e.questao_id,
       (a.id is not null and a.prova_id = (select id from prova) and a.numero_original = e.numero_original and a.usuario_id is null and a.ativa
        and a.materia_id = e.materia_id and a.assunto_id is not distinct from e.assunto_id
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito
        and a.total_alternativas = 5 and a.corretas = 1 and a.vinculos = 0 and a.midias = 0) as ok
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

select count(*) as questoes_prova_12,
       count(distinct numero_original) as numeros_distintos,
       count(*) filter (where id between 2949 and 2991) as lote_conclusao,
       (select string_agg(n::text, ',' order by n) from generate_series(1, 80) n
         where n not in (select numero_original from public.questoes where prova_id = (select id from public.provas where hash_prova = 'f8acc43be8aa1822690f5d604844af2138d3739a1a8992202b9b1ebd003f6adc'))) as fora_da_base,
       (select count(*) from public.curso_questoes where questao_id in (2949, 2950, 2951, 2952, 2953, 2954, 2955, 2956, 2957, 2958, 2959, 2960, 2961, 2962, 2963, 2964, 2965, 2966, 2967, 2968, 2969, 2970, 2971, 2972, 2973, 2974, 2975, 2976, 2977, 2978, 2979, 2980, 2981, 2982, 2983, 2984, 2985, 2986, 2987, 2988, 2989, 2990, 2991)) as vinculos_do_lote
  from public.questoes
 where prova_id = (select id from public.provas where hash_prova = 'f8acc43be8aa1822690f5d604844af2138d3739a1a8992202b9b1ebd003f6adc');
-- esperado: 76 | 76 | 43 | 6,15,17,75 | 0
