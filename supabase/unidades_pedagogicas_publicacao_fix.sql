-- Corrige ambiguidade entre os OUT parameters aula_id/status da RPC e as
-- colunas de public.aula_versoes. A versão anterior falhava somente em
-- runtime, no primeiro UPDATE, sem publicar nada.
begin;

create or replace function public.publicar_aula_versao_admin(p_aula_versao_id uuid)
returns table (aula_versao_id uuid, aula_id uuid, unidade_pedagogica_id uuid,
  numero_versao integer, status text, publicado_em timestamptz)
language plpgsql security definer set search_path to '' as $$
declare
  v_aula_id uuid;
  v_unidade_id uuid;
  v_numero integer;
  v_status text;
  v_publicado_em timestamptz;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem publicar aulas';
  end if;

  select av.aula_id, a.unidade_pedagogica_id, av.numero_versao, av.status
  into v_aula_id, v_unidade_id, v_numero, v_status
  from public.aula_versoes av
  join public.aulas a on a.id=av.aula_id
  join public.unidades_pedagogicas u on u.id=a.unidade_pedagogica_id
  where av.id=p_aula_versao_id and a.ativa and u.ativa
  for update of av;

  if v_aula_id is null then
    raise exception 'Versao, aula ou unidade ativa nao encontrada';
  end if;
  if v_status <> 'rascunho' then
    raise exception 'Somente uma versao em rascunho pode ser publicada';
  end if;

  update public.aula_versoes as versao_anterior
  set status='arquivada'
  where versao_anterior.aula_id=v_aula_id
    and versao_anterior.status='publicada';

  v_publicado_em := now();
  update public.aula_versoes as versao_revisada
  set status='publicada', publicado_em=v_publicado_em
  where versao_revisada.id=p_aula_versao_id;

  return query select p_aula_versao_id, v_aula_id, v_unidade_id,
    v_numero, 'publicada'::text, v_publicado_em;
end;
$$;

revoke execute on function public.publicar_aula_versao_admin(uuid) from public, anon;
grant execute on function public.publicar_aula_versao_admin(uuid) to authenticated;

commit;
