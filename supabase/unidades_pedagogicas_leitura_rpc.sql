-- Fase 2J-C: adapta a porta de leitura do aluno ao novo vínculo canônico.
-- A assinatura permanece idêntica. Nesta fase a missão abre a primeira
-- unidade ativa publicada; navegação entre unidades será a próxima fatia.
begin;

create or replace function public.carregar_aula_publicada_da_missao(p_missao_id uuid)
returns table (
  missao_id uuid, conteudo_id bigint, missao_status text, aula_id uuid,
  aula_titulo text, aula_versao_id uuid, numero_versao integer,
  publicado_em timestamptz, estrutura jsonb, fontes jsonb
)
language plpgsql stable security definer set search_path to '' as $$
declare v_usuario_id uuid; v_missao_id uuid; v_conteudo_id bigint; v_missao_status text;
begin
  v_usuario_id := auth.uid();
  if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;
  select ms.id, ms.conteudo_id, ms.status into v_missao_id, v_conteudo_id, v_missao_status
  from public.missoes ms join public.matriculas m on m.id=ms.matricula_id
  where ms.id=p_missao_id and m.usuario_id=v_usuario_id and m.status='ativa';
  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  return query
  select v_missao_id, v_conteudo_id, v_missao_status, a.id, a.titulo,
    av.id, av.numero_versao, av.publicado_em, av.estrutura,
    coalesce(f.fontes, '[]'::jsonb)
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id=u.id and a.ativa
  join public.aula_versoes av on av.aula_id=a.id and av.status='publicada'
  left join lateral (
    select jsonb_agg(jsonb_build_object(
      'material_id',mv.material_id,'material_titulo',mat.titulo,
      'material_tipo',mat.tipo,'material_versao_id',mv.id,
      'numero_versao',mv.numero_versao,'titulo_versao',mv.titulo_versao,
      'arquivo_path',mv.arquivo_path,'checksum',mv.checksum,
      'vigente_desde',mv.vigente_desde,'vigente_ate',mv.vigente_ate,
      'ordem',avf.ordem,'observacao',avf.observacao)
      order by avf.ordem nulls last, mv.numero_versao, mv.id) fontes
    from public.aula_versao_fontes avf
    join public.material_versoes mv on mv.id=avf.material_versao_id
    join public.materiais mat on mat.id=mv.material_id
    where avf.aula_versao_id=av.id
  ) f on true
  where u.curso_conteudo_id=v_conteudo_id and u.ativa
  order by u.ordem
  limit 1;
end;
$$;

revoke execute on function public.carregar_aula_publicada_da_missao(uuid) from public, anon;
grant execute on function public.carregar_aula_publicada_da_missao(uuid) to authenticated;
commit;
