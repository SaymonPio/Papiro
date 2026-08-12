-- Fundação da Teoria Interativa (Fase 2F): RPC de leitura segura da aula
-- publicada associada a uma missão do próprio usuário.
--
-- public.carregar_aula_publicada_da_missao(p_missao_id uuid)
--
-- Único parâmetro aceito do cliente: p_missao_id. usuario_id, matricula_id,
-- conteudo_id, aula_id e aula_versao_id são todos derivados no servidor —
-- nunca aceitos como entrada.
--
-- Auditoria feita antes de escrever este arquivo (sem alterar nada):
--   - public.missoes (missoes.sql): id uuid, matricula_id uuid (FK
--     matriculas, restrict), conteudo_id bigint (FK curso_conteudos,
--     restrict), data_missao date, status text (CHECK: iniciada |
--     teoria_concluida | questoes_iniciadas | concluida | abandonada),
--     progresso_teoria jsonb, timestamps. RLS já concede SELECT para
--     authenticated (policy "Aluno visualiza as próprias missões",
--     via matriculas.usuario_id = auth.uid()) — mas esta função é SECURITY
--     DEFINER e portanto BYPASSA essa policy; a autorização por usuario_id
--     é reimplementada explicitamente abaixo, não delegada ao RLS.
--   - public.matriculas (não versionada neste repo, "já existe"): id uuid,
--     usuario_id uuid, curso_id uuid, status text, origem, matriculado_em,
--     expira_em. Mesmo critério já usado em iniciar_ou_recuperar_missao_diaria
--     (missoes_rpc.sql): só status = 'ativa' importa, expira_em não é
--     checado em lugar nenhum do projeto hoje.
--   - As 5 tabelas da Fase 2E (teoria_versionada.sql), confirmadas linha a
--     linha: materiais(id uuid, titulo, tipo, descricao, origem, ativo,
--     ...), material_versoes(id uuid, material_id -> materiais restrict,
--     numero_versao int unique com material_id, titulo_versao,
--     conteudo_texto, arquivo_path, checksum, vigente_desde, vigente_ate),
--     aulas(id uuid, conteudo_id -> curso_conteudos restrict, titulo,
--     ativa, UNIQUE(conteudo_id) — confirmado: no máximo uma aula por
--     conteúdo), aula_versoes(id uuid, aula_id -> aulas restrict,
--     numero_versao, status CHECK rascunho|publicada|arquivada, estrutura
--     jsonb CHECK object, publicado_em, UNIQUE(aula_id,numero_versao) +
--     ÍNDICE ÚNICO PARCIAL aula_versoes_uma_publicada_idx (aula_id) WHERE
--     status='publicada' — confirmado: no máximo uma versão publicada por
--     aula), aula_versao_fontes(aula_versao_id -> aula_versoes cascade,
--     material_versao_id -> material_versoes restrict, ordem, observacao,
--     PK composta). Todas as 5 com RLS ativo e "revoke all ... from anon,
--     authenticated" sem nenhuma policy — authenticated confirmado SEM
--     SELECT direto em nenhuma delas.
--   - Padrão de RPC do projeto (missoes_rpc.sql): language plpgsql,
--     security definer, set search_path to '', tudo com public.<tabela>,
--     RETURNS TABLE explícito (nunca select *), CREATE FUNCTION sem OR
--     REPLACE (fail-fast, esta função é nova), REVOKE de public/anon +
--     GRANT só para authenticated no final.
--
-- Esta RPC é SOMENTE LEITURA: não altera missoes.status,
-- missoes.progresso_teoria, nenhum timestamp de missoes, sessoes_estudo ou
-- progresso_conteudo_matricula. Nenhuma das 5 tabelas novas é alterada.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica. Este arquivo
-- NÃO é executado por esta etapa (só criado, para revisão).

BEGIN;

-- CREATE FUNCTION sem OR REPLACE, de propósito: esta função é nova e não
-- existe hoje. Fail-fast se já existir algo com esse nome/assinatura.
create function public.carregar_aula_publicada_da_missao(p_missao_id uuid)
returns table (
  missao_id uuid,
  conteudo_id bigint,
  missao_status text,
  aula_id uuid,
  aula_titulo text,
  aula_versao_id uuid,
  numero_versao integer,
  publicado_em timestamptz,
  estrutura jsonb,
  fontes jsonb
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_missao_status text;
begin
  -- Usuário: SEMPRE de auth.uid(), nunca de parâmetro.
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  -- Autorização EXPLÍCITA por usuario_id — não delega ao RLS de
  -- public.missoes, que esta função (SECURITY DEFINER) ignora por
  -- definição. Exige matrícula ATIVA (diferente de missoes.sql em si, que
  -- deliberadamente não checa isso para preservar missões históricas —
  -- aqui é uma leitura de conteúdo "ao vivo" da matrícula corrente, então
  -- ativa é exigido, como pedido explicitamente nesta fase).
  select ms.id, ms.conteudo_id, ms.status
  into v_missao_id, v_conteudo_id, v_missao_status
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa';

  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  -- A partir daqui a missão já foi validada como do próprio usuário — o
  -- restante é resolver a aula/versão publicada e as fontes exatas dela.
  -- Se não existir aula ativa para o conteúdo, ou não existir versão
  -- publicada, a consulta abaixo simplesmente não devolve nenhuma linha —
  -- NÃO é exception (missão inválida = exception; missão válida sem aula
  -- publicada = zero linhas, como pedido).
  --
  -- aulas.UNIQUE(conteudo_id) e o índice único parcial
  -- aula_versoes_uma_publicada_idx garantem, por construção do schema, no
  -- máximo 1 aula por conteúdo e no máximo 1 versão publicada por aula —
  -- esta consulta nunca pode devolver mais de 1 linha.
  return query
  select
    v_missao_id,
    v_conteudo_id,
    v_missao_status,
    a.id,
    a.titulo,
    av.id,
    av.numero_versao,
    av.publicado_em,
    av.estrutura,
    -- Fontes: SOMENTE material_versoes ligados a ESTA aula_versoes via
    -- aula_versao_fontes — nunca materiais globais fora desse vínculo.
    -- conteudo_texto é deliberadamente OMITIDO (a aula já tem `estrutura`;
    -- o texto completo da fonte fica para uma RPC específica futura, se
    -- necessário). [] quando não há fontes, nunca null (coalesce).
    coalesce(f.fontes, '[]'::jsonb) as fontes
  from public.aulas a
  join public.aula_versoes av
    on av.aula_id = a.id
   and av.status = 'publicada'
  left join lateral (
    select jsonb_agg(
      jsonb_build_object(
        'material_id', mv.material_id,
        'material_titulo', mat.titulo,
        'material_tipo', mat.tipo,
        'material_versao_id', mv.id,
        'numero_versao', mv.numero_versao,
        'titulo_versao', mv.titulo_versao,
        'arquivo_path', mv.arquivo_path,
        'checksum', mv.checksum,
        'vigente_desde', mv.vigente_desde,
        'vigente_ate', mv.vigente_ate,
        'ordem', avf.ordem,
        'observacao', avf.observacao
      )
      order by avf.ordem nulls last, mv.numero_versao, mv.id
    ) as fontes
    from public.aula_versao_fontes avf
    join public.material_versoes mv on mv.id = avf.material_versao_id
    join public.materiais mat on mat.id = mv.material_id
    where avf.aula_versao_id = av.id
  ) f on true
  where a.conteudo_id = v_conteudo_id
    and a.ativa = true;
end;
$function$;

-- Sem execução anônima. REVOKE explícito de PUBLIC e de anon, depois GRANT
-- só para authenticated — mesmo padrão de missoes_rpc.sql. Nenhuma tabela
-- ganha SELECT direto por causa desta RPC — o acesso é só através dela.
revoke execute on function public.carregar_aula_publicada_da_missao(uuid) from public;
revoke execute on function public.carregar_aula_publicada_da_missao(uuid) from anon;
grant execute on function public.carregar_aula_publicada_da_missao(uuid) to authenticated;

COMMIT;
