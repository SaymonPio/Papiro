-- Fase 2J-D: leitura segura de todas as unidades pedagógicas publicadas de
-- uma missão. A função anterior permanece disponível para compatibilidade;
-- o fluxo novo do aluno usa esta porta e recebe uma linha por unidade.
begin;

create function public.carregar_unidades_publicadas_da_missao(p_missao_id uuid)
returns table (
  missao_id uuid,
  conteudo_id bigint,
  missao_status text,
  unidade_pedagogica_id uuid,
  unidade_titulo text,
  unidade_ordem integer,
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
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  -- A missão é sempre resolvida no servidor e precisa pertencer ao usuário
  -- autenticado em uma matrícula ativa. Nenhum conteúdo/unidade é aceito do
  -- cliente, evitando leitura cruzada entre cursos ou missões.
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

  return query
  select
    v_missao_id,
    v_conteudo_id,
    v_missao_status,
    u.id,
    u.titulo,
    u.ordem,
    a.id,
    a.titulo,
    av.id,
    av.numero_versao,
    av.publicado_em,
    av.estrutura,
    coalesce(f.fontes, '[]'::jsonb)
  from public.unidades_pedagogicas u
  join public.aulas a
    on a.unidade_pedagogica_id = u.id
   and a.ativa = true
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
  where u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true
  order by u.ordem, u.id;
end;
$function$;

revoke execute on function public.carregar_unidades_publicadas_da_missao(uuid) from public;
revoke execute on function public.carregar_unidades_publicadas_da_missao(uuid) from anon;
grant execute on function public.carregar_unidades_publicadas_da_missao(uuid) to authenticated;

commit;
