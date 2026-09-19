-- Reversão pós-apply de supabase/teoria_geracoes_admin_tem_response_id.sql
-- — GENUÍNA down-migration (não um teste transacional). Só existe para o
-- caso de a migration precisar ser desfeita DEPOIS de já ter sido
-- aplicada de verdade no banco LIVE.
--
-- NÃO EXECUTAR AGORA. Nada nesta fase autoriza rodar este arquivo.
--
-- Restaura EXATAMENTE a versão anterior da função (9 colunas, sem
-- tem_response_id) — mesma assinatura, mesmo corpo, mesmos GRANTs,
-- SECURITY DEFINER e search_path — byte-a-byte idêntica ao que estava em
-- supabase/teoria_geracoes_admin_contexto.sql (a migration anterior, já
-- aplicada e nunca reaberta). Nenhuma precondição de dados é necessária
-- aqui (ao contrário da lease, esta reversão nunca corrompe um trabalho
-- em andamento — é só a definição de uma função de LEITURA administrativa).

BEGIN;

drop function public.listar_geracoes_conteudo_admin(bigint);

create function public.listar_geracoes_conteudo_admin(p_conteudo_id bigint)
returns table (
  geracao_id uuid,
  status text,
  iniciado_em timestamptz,
  finalizado_em timestamptz,
  aula_versao_id uuid,
  erro text,
  prompt_version text,
  modelo text,
  contexto jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem consultar geracoes de aula';
  end if;

  return query
  select
    g.id,
    g.status,
    g.iniciado_em,
    g.finalizado_em,
    g.aula_versao_id,
    g.erro,
    g.prompt_version,
    g.modelo,
    g.contexto
  from public.aula_geracoes g
  where g.conteudo_id = p_conteudo_id
  order by g.iniciado_em desc;
end;
$function$;

revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from public;
revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from anon;
grant execute on function public.listar_geracoes_conteudo_admin(bigint) to authenticated;

COMMIT;
