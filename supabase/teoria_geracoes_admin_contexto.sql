-- Fase 2J-B — expõe aula_geracoes.contexto (que já inclui, de forma
-- aditiva, validacao_escopo — ver supabase/functions/gerar-aula/index.ts)
-- para o painel administrativo, via public.listar_geracoes_conteudo_admin.
--
-- Auditoria feita ANTES desta migration (Fase 0.2, sem alterar nada):
-- public.listar_geracoes_conteudo_admin(bigint) (teoria_geracao_admin_
-- rpc.sql) retorna hoje SOMENTE geracao_id, status, iniciado_em,
-- finalizado_em, aula_versao_id, erro, prompt_version, modelo — NÃO
-- retorna aula_geracoes.contexto. app/admin/aulas/page.tsx (tipo
-- GeracaoAdmin) reflete exatamente essas 8 colunas. Ou seja: o aviso
-- "ATENÇÃO AO ESCOPO" não pode ser implementado só no frontend hoje —
-- falta esse dado chegar ao cliente.
--
-- Por que uma migration NOVA em vez de editar teoria_geracao_admin_rpc.sql
-- diretamente: aquele arquivo já foi aplicado (migration histórica) — não
-- é reaberto/editado nesta fase, mesmo princípio já seguido em todas as
-- fases anteriores deste projeto.
--
-- Por que DROP FUNCTION + CREATE FUNCTION em vez de CREATE OR REPLACE:
-- Postgres não permite CREATE OR REPLACE FUNCTION mudar a lista de
-- colunas de um RETURNS TABLE existente (isso conta como mudança de tipo
-- de retorno — erro "cannot change return type of existing function").
-- Adicionar "contexto jsonb" exige recriar a função. Verificado antes
-- desta migration que NENHUMA outra função/RPC deste projeto chama
-- listar_geracoes_conteudo_admin (só o teste-harness em
-- teoria_geracao_teste_rollback.sql e o frontend a chamam) — o DROP é
-- seguro, nada mais quebra.
--
-- Contrato preservado: mesmo nome de função, mesma assinatura de
-- parâmetro (bigint), mesmas 8 colunas na MESMA ordem — só uma coluna
-- "contexto jsonb" é ACRESCENTADA no final. Do ponto de vista de quem já
-- chama esta RPC hoje (app/admin/aulas/page.tsx com o tipo GeracaoAdmin
-- atual, que não lê "contexto"), a mudança é aditiva: o objeto retornado
-- ganha uma chave nova, nenhuma chave existente muda de nome/posição/tipo.
-- Mesmo gate de autorização (eh_admin()) e mesmo REVOKE/GRANT de antes.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

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
