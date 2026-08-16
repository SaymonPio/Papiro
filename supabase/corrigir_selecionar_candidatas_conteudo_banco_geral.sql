-- ============================================================================
-- CORREÇÃO — Missão Final deve alcançar questões "banco geral" (sem vínculo
-- de unidade pedagógica) do mesmo conteúdo/assunto/curso.
-- ============================================================================
--
-- CAUSA RAIZ (diagnóstico completo, revalidado nesta rodada contra
-- supabase/missao_pratica_papiro_rpc.sql):
--
-- public.iniciar_missao_final monta as 30 questões da Missão Final em duas
-- etapas:
--   1) um laço por unidade pedagógica ativa/publicada, chamando
--      public.selecionar_candidatas_unidade_pedagogica uma vez por unidade
--      (distribuição não igual, "ceil do restante");
--   2) SE ainda faltar completar 30 depois do laço, um preenchimento único
--      chamando public.selecionar_candidatas_conteudo somando TODAS as
--      unidades do conteúdo.
--
-- Nenhuma das duas funções de seleção aceita questão sem vínculo:
--   - selecionar_candidatas_unidade_pedagogica faz
--     `join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
--      and qup.unidade_pedagogica_id = p_unidade_pedagogica_id` — correto,
--     é usada também por iniciar_pratica_unidade e DEVE continuar exigindo
--     vínculo explícito com a unidade praticada. NÃO ALTERADA por este
--     patch.
--   - selecionar_candidatas_conteudo faz
--     `join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
--      join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
--      and u.curso_conteudo_id = p_conteudo_id` — MESMO JOIN obrigatório,
--     mas esta função só é chamada pela Missão Final, nunca pela prática de
--     unidade. É aqui, e só aqui, que está o bug: uma questão sem nenhuma
--     linha em questao_unidades_pedagogicas nunca aparece nem no laço por
--     unidade (não tem vínculo) nem no preenchimento por conteúdo (mesmo
--     JOIN obrigatório) — fica permanentemente inatingível pelo Modo
--     Papiro deste conteúdo, mesmo estando ativa em questoes e vinculada em
--     curso_questoes. Contradiz a regra pedagógica oficial: questões
--     amplas/mistas válidas devem poder ficar em BANCO_GERAL_MISSAO_FINAL
--     sem vínculo artificial com uma unidade.
--
-- CORREÇÃO — menor mudança arquitetural possível: só
-- public.selecionar_candidatas_conteudo muda. Passa a aceitar DOIS
-- conjuntos de candidatas (união, nunca interseção):
--   (a) vinculada a alguma unidade ATIVA deste conteúdo (comportamento
--       anterior, inalterado);
--   (b) SEM nenhum vínculo com nenhuma unidade deste conteúdo, mas com
--       questoes.assunto_id igual ao assunto_id do curso_conteudos alvo
--       (mesmo critério de pertencimento já usado pela trigger
--       validar_questao_unidade_pedagogica em
--       supabase/questao_unidades_pedagogicas.sql — não é um critério novo,
--       é o mesmo já estabelecido neste projeto para "questão pertence a
--       este conteúdo").
--
-- Isolamento preservado: (a) continua restrita a unidades cujo
-- curso_conteudo_id = p_conteudo_id (nenhuma unidade de outro conteúdo
-- entra); (b) exige v_assunto_id = questoes.assunto_id, onde v_assunto_id
-- vem de curso_conteudos.assunto_id do PRÓPRIO p_conteudo_id — uma questão
-- de outro assunto/conteúdo nunca casa. O join com curso_questoes
-- (cq.curso_id = p_curso_id) permanece obrigatório nos dois casos —
-- isolamento por curso inalterado. q.ativa = true permanece obrigatório —
-- questão inativa nunca entra, em nenhum dos dois casos. Toda a lógica de
-- Tiers A/B/C (inédita/erro/recência/missão atual) e o desempate por
-- cq.prioridade/random() são copiados exatamente como estavam — nenhuma
-- regra de repetição foi alterada.
--
-- selecionar_candidatas_unidade_pedagogica, iniciar_pratica_unidade,
-- iniciar_missao_final, concluir_pratica_unidade e concluir_missao_final
-- NÃO são tocadas por este patch — a mudança fica inteiramente contida na
-- função abaixo, chamada apenas pela Missão Final.
--
-- Segurança: mesmas REVOKE/GRANT já existentes (função interna, chamada só
-- de dentro de iniciar_missao_final). Nenhum parâmetro novo, nenhuma
-- mudança de assinatura — CREATE OR REPLACE é seguro para produção sem
-- quebrar chamadores existentes.
-- ============================================================================

create or replace function public.selecionar_candidatas_conteudo(
  p_usuario_id uuid,
  p_conteudo_id bigint,
  p_curso_id uuid,
  p_quantidade integer,
  p_excluir bigint[],
  p_missao_id uuid default null
)
returns table (questao_id bigint)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_janela_repeticao constant interval := interval '24 hours';
  v_assunto_id bigint;
begin
  select cc.assunto_id
  into v_assunto_id
  from public.curso_conteudos cc
  where cc.id = p_conteudo_id;

  return query
  select q.id
  from public.questoes q
  join public.curso_questoes cq
    on cq.questao_id = q.id
   and cq.curso_id = p_curso_id
  left join lateral (
    select
      count(*) as vezes_respondida,
      bool_or(not ru.acertou) as ja_errou,
      max(ru.respondida_em) as ultima_vez
    from public.respostas_usuarios ru
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
  ) hist on true
  left join lateral (
    select true as usada_na_missao_atual
    from public.respostas_usuarios ru
    join public.sessoes_estudo s on s.id = ru.sessao_id
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
      and p_missao_id is not null
      and s.missao_id = p_missao_id
      and s.tipo_pratica = 'unidade'
    limit 1
  ) miss on true
  where q.ativa = true
    and not (q.id = any(coalesce(p_excluir, '{}'::bigint[])))
    and (
      -- (a) vinculada a alguma unidade ATIVA deste conteudo -- comportamento
      -- ja existente, inalterado.
      exists (
        select 1
        from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u
          on u.id = qup.unidade_pedagogica_id
         and u.curso_conteudo_id = p_conteudo_id
         and u.ativa = true
        where qup.questao_id = q.id
      )
      or (
        -- (b) banco geral -- mesmo assunto do conteudo alvo, mas SEM
        -- nenhum vinculo com nenhuma unidade deste conteudo. So elegivel
        -- aqui (Missao Final); selecionar_candidatas_unidade_pedagogica
        -- continua exigindo o vinculo explicito, entao esta questao nunca
        -- aparece na pratica de unidade.
        v_assunto_id is not null
        and q.assunto_id = v_assunto_id
        and not exists (
          select 1
          from public.questao_unidades_pedagogicas qup2
          join public.unidades_pedagogicas u2
            on u2.id = qup2.unidade_pedagogica_id
           and u2.curso_conteudo_id = p_conteudo_id
          where qup2.questao_id = q.id
        )
      )
    )
  order by
    (coalesce(hist.vezes_respondida, 0) = 0) desc,
    (
      coalesce(hist.vezes_respondida, 0) > 0
      and (
        coalesce(hist.ultima_vez, '-infinity'::timestamptz) >= now() - v_janela_repeticao
        or coalesce(miss.usada_na_missao_atual, false)
      )
    ) asc,
    coalesce(hist.ja_errou, false) desc,
    coalesce(hist.ultima_vez, '-infinity'::timestamptz) asc,
    cq.prioridade asc,
    random()
  limit greatest(0, p_quantidade);
end;
$function$;

revoke execute on function public.selecionar_candidatas_conteudo(uuid, bigint, uuid, integer, bigint[], uuid)
  from public, anon, authenticated;
