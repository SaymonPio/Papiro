-- GM POA 2025 (Fundatec, CP 794 Guarda Municipal) — REGISTRO SANITIZADO da
-- qualificação do legado TEC questoes.id = 493 como Q18 oficial, com mídia,
-- aplicada em 2026-10-19.
--
-- Operação (já aplicada; o script operacional com o texto integral fica FORA
-- do repositório): a questão global pré-existente 493 (origem TEC Concursos,
-- enunciado reescrito sem a figura) é a Q18 oficial da prova. Em vez de criar
-- duplicata, ela recebeu a proveniência oficial — provas.id = 13 (hash_prova
-- c07c7572…), numero_original = 18, fonte/concurso no formato do importador —
-- e o enunciado oficial (md5 antes <> md5 depois), e foi associada à Figura 2
-- (questao_midias, objeto conteúdo-endereçado no bucket privado
-- questao-midias). Preservados: id, alternativas (ids 2442–2446, mesmo texto
-- e gabarito A), matéria 9 / assunto 29, explicação, vínculo de curso
-- (brigada-militar-rs), unidade pedagógica e histórico de alunos — assinatura
-- imutável conferida antes e depois dentro da transação. No momento da
-- qualificação o 493 tinha 0 respostas, 0 erros, 0 sessões e 0 comentários.
--
-- Somente leitura: confere, por assinatura (md5/sha256) e sem reproduzir
-- texto, que o 493 continua exatamente no estado deixado pela operação.
-- Colunas devolvidas com false indicam divergência.

with esperado (questao_id, prova_hash, numero_original, md5_enunciado_antes, md5_enunciado, md5_alternativas, ids_alternativas, gabarito, materia_id, assunto_id,
               midia_sha256, midia_ordem, midia_tipo, midia_largura, midia_altura, midia_pagina, midia_direito, vinculo_curso, unidade_pedagogica) as (
values (493, 'c07c75728e6cb219085e95c1f60a021ccfd2c3ed8c4391fd47adaa3635d38cad', 18, '49a13c0d7326e365dfa0946e3e93810a', '63eb8249d7dc9d7df9a60a109d1dbca4',
        '83155594806cfb6e78cd3d22fdd39dba', '2442,2443,2444,2445,2446', 'A', 9, 29,
        '65bc77c0da4a68733febc856367e9d7fe7f00597dfb71338c1b4e96ff7390260', 1, 'FIGURA', 284, 96, 8, 'OFICIAL_PROVA',
        'brigada-militar-rs', 'd7635b99-48c1-4599-a014-68e8eb9ca3c2')
),
atual as (
  select q.id, q.prova_id, q.numero_original, q.usuario_id, q.ativa, q.materia_id, q.assunto_id, md5(q.enunciado) as md5_enunciado,
         (select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem)) from public.alternativas a where a.questao_id = q.id) as md5_alternativas,
         (select string_agg(a.id::text, ',' order by a.ordem) from public.alternativas a where a.questao_id = q.id) as ids_alternativas,
         (select chr(64 + a.ordem) from public.alternativas a where a.questao_id = q.id and a.correta) as gabarito
    from public.questoes q
   where q.id = 493
)
select e.questao_id,
       (a.prova_id = (select p.id from public.provas p where p.hash_prova = e.prova_hash) and a.numero_original = e.numero_original
        and a.usuario_id is null and a.ativa) as proveniencia_oficial_ok,
       (a.md5_enunciado = e.md5_enunciado and e.md5_enunciado_antes <> e.md5_enunciado) as enunciado_oficial_ok,
       (a.md5_alternativas = e.md5_alternativas and a.ids_alternativas = e.ids_alternativas and a.gabarito = e.gabarito) as alternativas_gabarito_preservados,
       (a.materia_id = e.materia_id and a.assunto_id = e.assunto_id) as classificacao_preservada,
       exists (select 1 from public.questao_midias m
                where m.questao_id = e.questao_id and m.ordem = e.midia_ordem and m.sha256 = e.midia_sha256
                  and m.storage_path = 'questoes/' || e.midia_sha256 || '.png' and m.tipo = e.midia_tipo
                  and m.largura = e.midia_largura and m.altura = e.midia_altura and m.prova_id = a.prova_id
                  and m.pagina_origem = e.midia_pagina and m.direito_uso = e.midia_direito) as figura_2_ok,
       (select count(*) from public.questao_midias m where m.questao_id = e.questao_id) = 1 as uma_midia,
       exists (select 1 from storage.objects o where o.bucket_id = 'questao-midias' and o.name = 'questoes/' || e.midia_sha256 || '.png') as objeto_no_bucket,
       exists (select 1 from public.curso_questoes cq join public.cursos c on c.id = cq.curso_id where cq.questao_id = e.questao_id and c.slug = e.vinculo_curso) as vinculo_preservado,
       exists (select 1 from public.questao_unidades_pedagogicas x where x.questao_id = e.questao_id and x.unidade_pedagogica_id::text = e.unidade_pedagogica) as unidade_preservada,
       (select count(*) from public.questoes q where q.prova_id = a.prova_id and q.numero_original = e.numero_original) = 1 as sem_duplicata_n18
  from esperado e left join atual a on a.id = e.questao_id;
