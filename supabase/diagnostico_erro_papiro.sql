-- Diagnóstico do erro do Método Papiro: permite ao aluno classificar por que
-- errou uma questão, imediatamente após o erro, antes de seguir para a
-- próxima questão (app/questoes/page.tsx).
--
-- Nenhuma tabela é criada. erros_usuarios.tipo_erro já existe; só a regra de
-- validação da coluna (CHECK) e uma RPC de escrita são adicionadas aqui.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- 1) CHECK de erros_usuarios.tipo_erro — mantém os 6 valores legados já em uso
-- em registros existentes e adiciona os 4 valores novos do diagnóstico do
-- Método Papiro que ainda não existiam na lista ("interpretacao" já
-- pertencia à lista antiga e é reaproveitado, não duplicado).
--
-- Nome da constraint confirmado pelo usuário: erros_usuarios_tipo_erro_check.
-- Nenhum registro existente é alterado — só a regra de validação da coluna.
-- NULL continua permitido (registrar_resposta não define tipo_erro na
-- criação do erro; a classificação é feita depois, via classificar_erro).
-- ============================================================================

alter table public.erros_usuarios
  drop constraint if exists erros_usuarios_tipo_erro_check;

alter table public.erros_usuarios
  add constraint erros_usuarios_tipo_erro_check
  check (
    tipo_erro is null or tipo_erro in (
      'falta_conhecimento',
      'confusao_conceitos',
      'desatencao',
      'interpretacao',
      'esquecimento',
      'calculo',
      'nao_sabia',
      'duvida',
      'chute',
      'atencao'
    )
  );

-- ============================================================================
-- 2) classificar_erro(p_erro_id, p_tipo_erro) — única forma permitida do
-- aluno gravar a causa do próprio erro em erros_usuarios.tipo_erro.
--
-- O cliente NÃO recebe GRANT UPDATE direto nessa coluna
-- (supabase/erros_revisoes_policies.sql continua liberando só
-- corrigido/corrigido_em/reflexao_aluno) — esta RPC é o único caminho de
-- escrita, preservando a decisão já registrada naquele arquivo de que a
-- classificação fica sob controle de registrar_resposta/admin/RPC dedicada,
-- nunca de UPDATE livre do cliente.
--
-- Aceita apenas os 5 valores de escolha do aluno (nao_sabia, duvida, chute,
-- atencao, interpretacao) — mesmo que o CHECK da tabela também permita os 6
-- valores legados, esta RPC nunca grava um valor legado.
--
-- Reclassificação permitida: o UPDATE não checa se tipo_erro já estava
-- preenchido, por decisão explícita — o aluno pode mudar de opção antes de
-- avançar para a próxima questão.
--
-- Dono do erro validado via usuario_id = auth.uid() na cláusula WHERE; se a
-- linha não existir ou não pertencer ao usuário, "not found" dispara exceção.
--
-- SECURITY DEFINER, SET search_path TO '', sem GRANT/REVOKE EXECUTE explícito
-- — mesmo padrão de registrar_resposta e ids_questoes_para_usuario (nenhuma
-- RPC deste projeto tem GRANT/REVOKE EXECUTE próprio; todas dependem do
-- EXECUTE padrão do Postgres para "authenticated" combinado com a validação
-- interna de auth.uid()).
--
-- motivo_provavel e reflexao_aluno não são alterados por esta função.
-- ============================================================================

create or replace function public.classificar_erro(
  p_erro_id bigint,
  p_tipo_erro text
)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_tipo_erro not in ('nao_sabia', 'duvida', 'chute', 'atencao', 'interpretacao') then
    raise exception 'Tipo de erro invalido';
  end if;

  update public.erros_usuarios
  set tipo_erro = p_tipo_erro
  where id = p_erro_id
    and usuario_id = v_usuario_id;

  if not found then
    raise exception 'Erro nao encontrado ou nao pertence ao usuario';
  end if;
end;
$function$;

COMMIT;
