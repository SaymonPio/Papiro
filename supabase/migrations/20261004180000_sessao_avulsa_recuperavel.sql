-- PAPIRO — HORAS LÍQUIDAS 1.0 — sessão de questões avulsa/personalizada
-- recuperável após F5/reabertura.
--
-- Esta migration NÃO toca em supabase/migrations/20261003120000_criar_
-- sessoes_tempo.sql (fundação de sessoes_tempo/sessoes_tempo_dias) — é
-- inteiramente aditiva, sobre a camada PEDAGÓGICA (sessoes_estudo/
-- sessao_questoes_planejadas), que já existia antes da Fase 1 de horas
-- líquidas.
--
-- Três mudanças independentes, todas aditivas:
--
-- 1) Remove a sobrecarga legada de 1 parâmetro de
--    public.ids_questoes_para_usuario, que hoje só existe no banco (não
--    em nenhum arquivo .sql deste projeto) e causa o erro PGRST203
--    "Could not choose the best candidate function" quando chamada só
--    com p_limite (fluxo de meta diária em app/questoes/page.tsx). A
--    versão de 3 parâmetros (com DEFAULT NULL em p_materia_id/
--    p_assunto_id), já em supabase/funcoes_curso_ativo.sql, cobre os
--    dois callsites existentes sem nenhuma mudança de frontend.
--
-- 2) Duas colunas novas em sessoes_estudo (materia_id, assunto_id) —
--    nullable, só preenchidas para sessões avulsas/personalizadas
--    (nunca para sessões de missão, que já têm seu próprio contexto via
--    missao_id/unidade_pedagogica_id). Sem isso não há como a RPC de
--    início/recuperação abaixo decidir se uma sessão em_andamento
--    existente é "a mesma execução" (mesmo filtro) ou uma execução
--    nova com filtro diferente.
--
-- 3) Duas RPCs novas, SECURITY DEFINER:
--    - iniciar_sessao_questoes_avulsa: cria OU recupera (idempotente)
--      a sessão avulsa/personalizada, seleciona as questões e PERSISTE
--      a lista+ordem em sessao_questoes_planejadas (a mesma tabela que
--      o fluxo de missão já usa) — hoje o ramo avulso de
--      app/questoes/page.tsx insere em sessoes_estudo direto do cliente
--      e nunca grava sessao_questoes_planejadas (ela tem RLS ativada
--      sem nenhuma policy — INSERT/SELECT direto do cliente são
--      impossíveis nela por desenho; só uma função SECURITY DEFINER
--      consegue escrever/ler).
--    - obter_sessao_questoes_avulsa: lê de volta (validando ownership
--      via auth.uid(), nunca confiando só no id da URL) tudo que é
--      necessário para reconstruir a tela depois de um F5: dados da
--      sessão + lista+ordem das questões. Respostas já dadas continuam
--      lidas direto pelo cliente via a policy de SELECT que já existe
--      em respostas_usuarios — não duplicada aqui.

-- ----------------------------------------------------------------------------
-- 1) Remove a sobrecarga legada (só existe no banco, nunca em arquivo
--    deste projeto). IF EXISTS porque este DROP é idempotente por
--    natureza — se por algum motivo já não existir, não há erro.
-- ----------------------------------------------------------------------------
drop function if exists public.ids_questoes_para_usuario(integer);

-- ----------------------------------------------------------------------------
-- 2) Contexto de matéria/assunto para sessões avulsas/personalizadas.
-- ----------------------------------------------------------------------------
alter table public.sessoes_estudo
  add column if not exists materia_id bigint references public.materias(id),
  add column if not exists assunto_id bigint references public.assuntos(id);

-- Acelera a busca de "já existe uma sessão avulsa em_andamento com este
-- exato filtro" feita por iniciar_sessao_questoes_avulsa abaixo.
create index if not exists sessoes_estudo_avulsa_em_andamento_idx
  on public.sessoes_estudo (usuario_id, nivel_meta, materia_id, assunto_id)
  where missao_id is null and status = 'em_andamento';

-- ----------------------------------------------------------------------------
-- iniciar_sessao_questoes_avulsa: único ponto de entrada para meta
-- diária ('minima'|'normal'|'ideal') e personalizada ('personalizada')
-- — substitui o INSERT direto do cliente em sessoes_estudo que existe
-- hoje nos dois ramos avulsos de app/questoes/page.tsx.
--
-- Idempotência (seção 23 do pedido — retry/double-click/refresh/
-- StrictMode/duas chamadas concorrentes nunca duplicam): antes de criar
-- qualquer coisa, tenta recuperar uma sessão própria, em_andamento, sem
-- missão, com o MESMO nivel_meta/materia_id/assunto_id (comparação
-- NULL-safe via IS NOT DISTINCT FROM) — trava essa busca com FOR UPDATE
-- para serializar contra uma segunda chamada concorrente idêntica. Se
-- encontrar, devolve ela (recuperada=true) com a lista já persistida,
-- nunca cria uma segunda. Pedir um filtro realmente diferente (outra
-- matéria/assunto, ou outra meta) sempre cria uma execução nova — isto
-- é intencional: o aluno pode querer trocar de assunto no meio de uma
-- sessão abandonada sem ficar presa à anterior.
create or replace function public.iniciar_sessao_questoes_avulsa(
  p_nivel_meta text,
  p_quantidade integer,
  p_materia_id bigint default null,
  p_assunto_id bigint default null
)
returns table (
  sessao_id bigint,
  status text,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_matricula_id uuid;
  v_sessao_id bigint;
  v_status text;
  v_ids bigint[];
  v_total_ids integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_nivel_meta not in ('minima', 'normal', 'ideal', 'personalizada') then
    raise exception 'Nivel de meta invalido: %', p_nivel_meta;
  end if;

  -- Assunto sem matéria não tem como ser validado contra o curso —
  -- mesma regra já aplicada dentro de ids_questoes_para_usuario.
  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  join public.perfis p on p.curso_ativo_id = m.curso_id
  where p.usuario_id = v_usuario_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  limit 1;

  if v_matricula_id is null then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  -- Recuperação idempotente: mesma identidade de filtro, trava a
  -- linha encontrada para serializar contra uma segunda chamada
  -- concorrente (duplo clique, retry de rede, StrictMode).
  select s.id, s.status
  into v_sessao_id, v_status
  from public.sessoes_estudo s
  where s.usuario_id = v_usuario_id
    and s.missao_id is null
    and s.status = 'em_andamento'
    and s.nivel_meta = p_nivel_meta
    and s.materia_id is not distinct from p_materia_id
    and s.assunto_id is not distinct from p_assunto_id
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    if coalesce(cardinality(v_ids), 0) = 0 then
      raise exception 'Sessao avulsa sem lista de questoes planejadas';
    end if;

    return query select v_sessao_id, v_status, v_ids, true;
    return;
  end if;

  -- Nenhuma sessão compatível em andamento: seleciona questões e cria
  -- do zero. ids_questoes_para_usuario já valida materia/assunto contra
  -- o curso ativo internamente (nunca confia em IDs arbitrários).
  select array_agg(q.questao_id)
  into v_ids
  from public.ids_questoes_para_usuario(p_quantidade, p_materia_id, p_assunto_id) as q(questao_id);

  v_total_ids := coalesce(cardinality(v_ids), 0);
  if v_total_ids = 0 then
    raise exception 'Nao ha questoes disponiveis para este filtro';
  end if;

  insert into public.sessoes_estudo (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas,
    materia_id, assunto_id
  ) values (
    v_usuario_id, v_matricula_id, p_nivel_meta, 'em_andamento',
    clock_timestamp(), 0, v_total_ids,
    p_materia_id, p_assunto_id
  ) returning id, status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_ids, false;
end;
$function$;

revoke all on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) from public, anon;
grant execute on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) to authenticated;

-- ----------------------------------------------------------------------------
-- obter_sessao_questoes_avulsa: recuperação read-only após F5/reabertura
-- a partir de ?sessaoAvulsa=<id> na URL. Nunca confia no id sozinho —
-- usuario_id = auth.uid() é parte da própria condição de busca (não um
-- filtro aplicado depois), então uma sessão de outro usuário
-- simplesmente não é encontrada, nunca "encontrada mas rejeitada" (não
-- dá pra diferenciar "não existe" de "não é sua" do lado do cliente, e
-- não precisa).
-- ----------------------------------------------------------------------------
create or replace function public.obter_sessao_questoes_avulsa(p_sessao_id bigint)
returns table (
  sessao_id bigint,
  status text,
  nivel_meta text,
  materia_id bigint,
  assunto_id bigint,
  questoes_planejadas integer,
  questao_ids bigint[]
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_estudo%rowtype;
  v_ids bigint[];
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select s.* into v_sessao
  from public.sessoes_estudo s
  where s.id = p_sessao_id
    and s.usuario_id = v_usuario_id
    and s.missao_id is null;

  if not found then
    raise exception 'Sessao avulsa nao encontrada';
  end if;

  select array_agg(sq.questao_id order by sq.ordem)
  into v_ids
  from public.sessao_questoes_planejadas sq
  where sq.sessao_id = p_sessao_id;

  return query
  select v_sessao.id, v_sessao.status, v_sessao.nivel_meta, v_sessao.materia_id,
         v_sessao.assunto_id, v_sessao.questoes_planejadas, coalesce(v_ids, array[]::bigint[]);
end;
$function$;

revoke all on function public.obter_sessao_questoes_avulsa(bigint) from public, anon;
grant execute on function public.obter_sessao_questoes_avulsa(bigint) to authenticated;
