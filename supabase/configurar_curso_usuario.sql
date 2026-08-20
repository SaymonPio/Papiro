-- Passo 2 do onboarding do beta (Papiro): nova RPC de onboarding do aluno.
--
-- Transforma a escolha inicial de curso num fluxo completo e atômico:
--   usuário → perfil → matrícula → curso ativo → objetivos derivados → cronograma liberado
--
-- Hoje, app/configuracao/page.tsx grava diretamente em public.objetivos (texto
-- livre, sem FK), nunca cria public.perfis nem public.matriculas, e nunca
-- define perfis.curso_ativo_id — por isso /cronograma, /questoes,
-- /estatisticas e /caderno-de-erros ficam permanentemente em "Selecione um
-- curso ativo" para qualquer aluno novo. Esta função é o que
-- app/configuracao/page.tsx passará a chamar (ainda não alterado neste
-- passo) para fechar essa lacuna numa única chamada RPC.
--
-- Não duplica a lógica de public.sincronizar_cursos_beta (ver
-- supabase/sincronizar_cursos_beta.sql) — delega inteiramente a ela a
-- criação/cancelamento de matrícula e a sincronização de public.objetivos.
-- Esta função só adiciona, por cima: garantia de existência de perfil,
-- criação/atualização da configuração de estudo (horas_diarias) da
-- matrícula, e definição de curso_ativo_id — com a ordem e as validações
-- explicadas nos comentários dentro do corpo abaixo.
--
-- public.configuracoes_estudo (schema já existente, nunca antes preenchida
-- por nenhum código do projeto) é onde app/cronograma/page.tsx efetivamente
-- lê horas_diarias para dimensionar o plano diário — não em
-- public.objetivos. Sem este passo, o cronograma cai num fallback
-- hardcoded de 1h/dia, ignorando a escolha real do aluno.
--
-- Beta usa seleção única de curso (não múltipla): por isso a assinatura
-- recebe p_curso_id uuid (singular), e internamente chama
-- sincronizar_cursos_beta com array[p_curso_id] — um array de um único
-- elemento, já que a função reutilizada foi desenhada para múltiplos cursos
-- mas aqui sempre operamos com exatamente um.

create or replace function public.configurar_curso_usuario(p_curso_id uuid, p_horas_diarias numeric)
 returns boolean
 language plpgsql
 security definer
 set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_matricula_id uuid;
begin
  -- Nunca aceitar usuario_id como parâmetro: sempre derivar de auth.uid()
  -- internamente, para que esta função (SECURITY DEFINER, portanto executa
  -- ignorando RLS) jamais possa ser usada para manipular perfil/matrícula de
  -- outro usuário.
  if v_usuario_id is null then
    raise exception 'Usuário não autenticado';
  end if;

  if p_curso_id is null then
    raise exception 'Curso é obrigatório';
  end if;

  -- Mesma faixa validada dentro de sincronizar_cursos_beta (0.5 a 16). É
  -- validação redundante de propósito (defesa em profundidade / falha
  -- rápida antes de qualquer escrita, inclusive antes do upsert de perfil
  -- logo abaixo) — não é duplicação da lógica de negócio de matrícula, só
  -- do formato de entrada.
  if p_horas_diarias is null or p_horas_diarias < 0.5 or p_horas_diarias > 16 then
    raise exception 'Disponibilidade diária inválida';
  end if;

  -- 1) Garante que o usuário tem uma linha em perfis antes de qualquer outra
  -- coisa. Idempotente (ON CONFLICT DO NOTHING): se já existir, não faz
  -- nada. A RLS de perfis ("Aluno gerencia o próprio perfil", auth.uid() =
  -- usuario_id) já permitiria o próprio usuário fazer isso via client, mas
  -- concentramos aqui para que o onboarding completo aconteça numa única
  -- chamada atômica, sem depender de uma segunda ida ao banco pelo frontend.
  insert into public.perfis (usuario_id)
  values (v_usuario_id)
  on conflict (usuario_id) do nothing;

  -- 2) Delega inteiramente a criação/reativação de matrícula, o cancelamento
  -- de matrículas de cursos que saíram da seleção, e a sincronização de
  -- public.objetivos (via o trigger matricula_cria_objetivo, que dispara
  -- automaticamente a partir do INSERT/UPDATE em matriculas feito dentro de
  -- sincronizar_cursos_beta) para a função já existente e já auditada. Se o
  -- comportamento dela mudar no futuro, esta função herda a mudança
  -- automaticamente, sem precisar ser tocada.
  perform public.sincronizar_cursos_beta(array[p_curso_id], p_horas_diarias);

  -- 3) Validação de defesa + captura do id da matrícula: confirma
  -- explicitamente que existe, agora, uma matrícula ATIVA do usuário para
  -- exatamente o curso pedido, e guarda seu id em v_matricula_id — necessário
  -- no passo 4 abaixo, já que a chave primária de configuracoes_estudo é
  -- matricula_id, não usuario_id/curso_id. Isso não deveria falhar nunca —
  -- se p_curso_id fosse inválido ou não publicado, sincronizar_cursos_beta
  -- já teria levantado exceção no passo anterior, e a execução nem chegaria
  -- aqui. Existe mesmo assim como segunda camada de verificação, com
  -- mensagem de erro específica do onboarding, antes de prosseguir.
  select id into v_matricula_id
    from public.matriculas
   where usuario_id = v_usuario_id
     and curso_id = p_curso_id
     and status = 'ativa';

  if v_matricula_id is null then
    raise exception 'Falha ao confirmar matrícula ativa para o curso selecionado';
  end if;

  -- 4) Cria ou atualiza a configuração de estudo (horas_diarias) da
  -- matrícula, agora que v_matricula_id está confirmado. Upsert idempotente
  -- por natureza (ON CONFLICT DO UPDATE na PRIMARY KEY matricula_id) —
  -- chamadas repetidas com horas diferentes apenas atualizam o valor
  -- existente, nunca duplicam linha. Não é necessário setar atualizado_em
  -- aqui: a tabela já tem DEFAULT now() para INSERT e trigger própria
  -- (configuracoes_estudo_marca_atualizacao) para UPDATE.
  insert into public.configuracoes_estudo (matricula_id, horas_diarias)
  values (v_matricula_id, p_horas_diarias)
  on conflict (matricula_id) do update
    set horas_diarias = excluded.horas_diarias;

  -- 5) Só agora definimos o curso ativo — DEPOIS da matrícula já existir e
  -- estar confirmada como ativa (passo 3). A ordem é obrigatória por dois
  -- motivos:
  --
  --   a) O trigger perfis_valida_curso_ativo (função validar_curso_ativo)
  --      dispara em UPDATE de perfis e rejeita qualquer curso_ativo_id que
  --      não corresponda a uma matrícula existente do usuário — se
  --      tentássemos ativar o curso antes de chamar sincronizar_cursos_beta,
  --      essa escrita seria rejeitada pelo próprio trigger.
  --
  --   b) Se o curso que estava ativo antes desta chamada tiver sido
  --      cancelado dentro de sincronizar_cursos_beta (porque o aluno trocou
  --      de curso), o trigger matriculas_status_alterado (função
  --      limpar_curso_ativo_ao_remover_matricula) já zera
  --      perfis.curso_ativo_id automaticamente durante essa mesma chamada,
  --      na mesma transação. Se definíssemos o novo curso_ativo_id ANTES de
  --      chamar sincronizar_cursos_beta, esse trigger apagaria o valor logo
  --      em seguida — silenciosamente errado. Fazendo depois, nada mais
  --      altera curso_ativo_id no restante desta chamada.
  --
  -- perfis não tem trigger de bookkeeping de atualizado_em (diferente da
  -- maioria das outras tabelas do projeto) — por isso setamos explicitamente
  -- aqui.
  update public.perfis
     set curso_ativo_id = p_curso_id,
         atualizado_em = now()
   where usuario_id = v_usuario_id;

  return true;
end;
$function$;

-- GRANTs: somente authenticated e service_role — onboarding exige sessão já
-- criada (o fluxo começa depois de auth.signUp), então, diferente de
-- sincronizar_cursos_beta (que hoje também concede a anon), aqui restringimos
-- desde a criação, sem conceder a anon em nenhum momento.
revoke execute on function public.configurar_curso_usuario(uuid, numeric) from public;
revoke execute on function public.configurar_curso_usuario(uuid, numeric) from anon;
grant execute on function public.configurar_curso_usuario(uuid, numeric) to authenticated;
grant execute on function public.configurar_curso_usuario(uuid, numeric) to service_role;
