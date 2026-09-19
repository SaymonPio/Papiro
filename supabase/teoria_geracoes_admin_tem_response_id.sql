-- Correção do bloqueio circular do botão "Gerar aula" (app/admin/aulas/
-- page.tsx): a UI hoje trata QUALQUER aula_geracoes.status='processando'
-- como bloqueante, inclusive um registro legado/órfão do fluxo síncrono
-- antigo (status='processando', openai_response_id=NULL, parado há mais
-- de 10 minutos) — que o próprio backend (gerar-aula/index.ts,
-- expirarGeracoesOrfas) só consegue expirar na PRÓXIMA tentativa de
-- geração, e a UI nunca deixa essa tentativa acontecer. Para a UI
-- distinguir "geração async real em voo" de "órfão antigo" sem depender
-- só da idade (uma geração async legítima em background pode, por
-- desenho, levar mais de 10 minutos), ela precisa saber se a linha já tem
-- um openai_response_id — mas o valor BRUTO do response_id nunca deve
-- chegar ao cliente (é um dado técnico-operacional de correlação com o
-- provedor, sem motivo para existir no navegador).
--
-- Mudança: acrescenta UM booleano calculado, `tem_response_id boolean`
-- ((g.openai_response_id is not null)), como 10ª coluna de
-- public.listar_geracoes_conteudo_admin — nunca o identificador em si.
--
-- Por que uma migration NOVA em vez de editar teoria_geracoes_admin_
-- contexto.sql (a migration anterior, que acrescentou "contexto"): aquele
-- arquivo já foi aplicado e validado em produção — não é reaberto/editado
-- aqui, mesmo princípio já seguido em todas as fases anteriores deste
-- projeto.
--
-- Por que DROP FUNCTION + CREATE FUNCTION em vez de CREATE OR REPLACE:
-- Postgres não permite CREATE OR REPLACE FUNCTION mudar a lista de
-- colunas de um RETURNS TABLE existente ("cannot change return type of
-- existing function"). Acrescentar "tem_response_id boolean" exige
-- recriar a função. Confirmado (mesma auditoria já feita na migration
-- anterior, ainda válida — nenhuma função nova passou a chamar
-- listar_geracoes_conteudo_admin desde então) que só o teste-harness e o
-- frontend chamam esta RPC — o DROP é seguro.
--
-- Contrato preservado integralmente: mesmo nome de função, mesma
-- assinatura de parâmetro (p_conteudo_id bigint), mesmas 9 colunas
-- existentes na MESMA ordem/nome/tipo — só "tem_response_id boolean" é
-- ACRESCENTADA no final (10ª coluna). Mesmos LANGUAGE plpgsql, SECURITY
-- DEFINER, SET search_path TO '', e mesmo REVOKE/GRANT de antes
-- (authenticated pode executar; anon e PUBLIC não podem). Mesmo filtro
-- (g.conteudo_id = p_conteudo_id) e mesma ordenação (iniciado_em desc).
-- Nenhuma tabela, RLS, índice, Edge Function ou secret é tocado por esta
-- migration — só a definição desta única função.
--
-- openai_response_id em si CONTINUA fora do retorno desta RPC — não pode
-- ser lido em lugar nenhum a partir do cliente autenticado comum.
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
  contexto jsonb,
  tem_response_id boolean
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
    g.contexto,
    (g.openai_response_id is not null)
  from public.aula_geracoes g
  where g.conteudo_id = p_conteudo_id
  order by g.iniciado_em desc;
end;
$function$;

revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from public;
revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from anon;
grant execute on function public.listar_geracoes_conteudo_admin(bigint) to authenticated;

COMMIT;
