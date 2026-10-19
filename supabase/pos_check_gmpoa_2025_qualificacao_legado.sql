-- GM POA 2025 (Fundatec, CP 794 Guarda Municipal) — REGISTRO SANITIZADO da
-- qualificação do legado TEC aplicada em 2026-10-19.
--
-- Operação (já aplicada; os scripts operacionais com o texto integral ficam
-- FORA do repositório): 25 questões globais pré-existentes (origem TEC
-- Concursos), que são as questões oficiais da prova, receberam a
-- proveniência oficial — provas.id = 13 (hash_prova c07c7572…), numero_original,
-- fonte/concurso no formato do importador — preservando id, alternativas,
-- gabarito, matéria, assunto, explicação, vínculos de curso e histórico de
-- alunos. Em 15 delas o enunciado degradado foi substituído pelo oficial
-- (md5 antes <> md5 depois); nas outras 10 o enunciado foi preservado.
-- Q18 (legado 493) ficou de fora: depende de imagem.
--
-- Somente leitura: confere, por assinatura (md5) e sem reproduzir texto,
-- que os 25 registros continuam exatamente no estado deixado pela
-- operação. Linhas devolvidas com ok = false indicam divergência.

with esperado (questao_id, numero_original, md5_enunciado_antes, md5_enunciado, md5_alternativas, gabarito) as (
values
  (758, 3, '0bdbb43408b22f15106a08917ca130ae', '6fb2ded86cf55da6b36edaa8e56182f1', '45e3b215971da48173641f52d5c8242f', 'E'),
  (749, 7, '2f0471865b8a41980cc6e77bac231ef4', '939e0951986bfe50d864990d3d1dc131', 'e51952ca337d875190fa162b0a19cd64', 'A'),
  (744, 8, 'f7932c0834bf4da780468b7f6377dfbe', '498bfd5b737e3f1d93f8ce3f93215d09', '4dc67f835750959350ef064be3be8a08', 'E'),
  (718, 11, '1aedc981cdce55c0fddab270ff3fea2d', '1aedc981cdce55c0fddab270ff3fea2d', '4b11bf62bcef6af4b61d290d258b2eb0', 'C'),
  (695, 12, '5c07d85d8db634ebdef4220dff268ab9', '17f52022c5e0691e9ad4386fd070017f', '0fdb720e957990806d050fa03613e0a7', 'A'),
  (734, 13, '75877c112b3fafada3bacc2ef5b663ab', '70aa6c6cb8a40558d9b1f871daab2564', '7fa0393b0942d888b4199eaa11a2b818', 'B'),
  (731, 14, '544d4a9332476f79ca97e7b5301ae501', '544d4a9332476f79ca97e7b5301ae501', 'b6c4b67371c1ed0ca60eabc77e208707', 'E'),
  (698, 16, '326b57015b43ae04232e2de2e5172071', 'd963568c6403fa1287ae4ee913bd5bd4', '3a59a702ce904c9c7b51b03075f70b1c', 'D'),
  (701, 19, '7ffdd4e448ea7f25bc300f077db00065', '01095d2ee640c00519987dec60056a25', 'a723af60ee024bcb180e50a39a30bbbd', 'E'),
  (711, 20, 'cb1f52d8d497951407a22e418e5d8077', 'd78b127c246a1bf8b34031acac231c12', '6c013b6c3a16434aea4680f42e83b24d', 'E'),
  (715, 21, '105b1d68c2887aeaf5bdfae7ae823f8f', 'a1831b2ea7be4212398962e910e7d829', '804ded40103c1c6c1c1d097a8f045ed4', 'C'),
  (716, 22, '8ac78cfa19d517b0bd8913aa50da8af8', '8ac78cfa19d517b0bd8913aa50da8af8', '708efb83d324767093cc0c0917f88e4f', 'B'),
  (723, 23, 'a30a508bfe9914b070b3bb9b570beb0b', '4e9cfacf59976508738e11025bda3af3', '455afa328887f8cb37d1ba498a76d6c2', 'D'),
  (724, 24, 'c08c956ca313e8b2f14deae3a79d2d0c', 'c08c956ca313e8b2f14deae3a79d2d0c', '589b77769d359fadb4a308579fe4b4d7', 'C'),
  (694, 27, 'b45cd5b020d25e9ae83a1c443f853579', 'cf658a8eb2c23180bfcbcaf952f453b6', '496396cf8201a6cea1989b9cb040317e', 'B'),
  (721, 29, 'c3b82a977ba4563a339cd6ca7a3034c5', '9039f2bc8e8e9256e4cf34678802b979', '8502281d251fbb4df18feed531fd2751', 'E'),
  (740, 49, 'dbb54b7144d515721cbb662fcd9f2dc0', 'dbb54b7144d515721cbb662fcd9f2dc0', 'afec9c2880718c705c40cabc077d7e4a', 'D'),
  (741, 50, '7f08fb4b2e7404215ad6b27ffecc997f', '7f08fb4b2e7404215ad6b27ffecc997f', '23f4aa253f2c01a28d1825b7a9136c0b', 'C'),
  (735, 51, '48a663320709b054e80a393fe8ea45fd', '1869073754a5781818c6c38fac80db4d', '33df49816ed45375649d9a1a81754bb7', 'A'),
  (736, 52, '2bd81dfaab33cfe904c383a94841175b', 'f021b6f2534bbb0d082975b5f994e65d', 'db58ce717b888da35cc1fb47ecc76781', 'B'),
  (737, 53, '76a4519a80250585adc078b0032f6295', '76a4519a80250585adc078b0032f6295', 'f4508e87bbfbf0c23cd9deeece412b6a', 'C'),
  (725, 54, '5858c8afc25ac32011e8dde6b8fbb5a7', '5858c8afc25ac32011e8dde6b8fbb5a7', '38bf842865e4d3678b5a1554c3bbe205', 'B'),
  (728, 55, '55cfd068b01b075acdd3fa79ce4ae7ba', '55cfd068b01b075acdd3fa79ce4ae7ba', '54b894e54a2111c259a6f7d28e54db33', 'D'),
  (712, 56, '870aba3b71a18696de9eb5692e206b8b', 'fec75c464cd42ed240191fdf9209bbaf', '8dfce6e8a4632adf83c38ac13597ed45', 'E'),
  (696, 60, '7cc7aee401086a380264a4169d0dca67', '7cc7aee401086a380264a4169d0dca67', '892471d8046e1835e4a956759d61e403', 'C')
),
prova as (
  select id from public.provas where hash_prova = 'c07c75728e6cb219085e95c1f60a021ccfd2c3ed8c4391fd47adaa3635d38cad'
),
atual as (
  select q.id, q.prova_id, q.numero_original, q.usuario_id, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito
    from public.questoes q
)
select e.numero_original, e.questao_id,
       (a.id is not null and a.prova_id = (select id from prova) and a.numero_original = e.numero_original and a.usuario_id is null
        and a.md5_enunciado = e.md5_enunciado and a.md5_alternativas = e.md5_alternativas and a.gabarito = e.gabarito) as ok,
       e.md5_enunciado_antes <> e.md5_enunciado as enunciado_substituido
  from esperado e left join atual a on a.id = e.questao_id
 order by e.numero_original;

select count(*) as questoes_prova_13, count(distinct numero_original) as numeros_distintos,
       count(*) filter (where id in (758, 749, 744, 718, 695, 734, 731, 698, 701, 711, 715, 716, 723, 724, 694, 721, 740, 741, 735, 736, 737, 725, 728, 712, 696)) as legados_qualificados
  from public.questoes
 where prova_id = (select id from public.provas where hash_prova = 'c07c75728e6cb219085e95c1f60a021ccfd2c3ed8c4391fd47adaa3635d38cad');
