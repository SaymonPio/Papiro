-- Etapa 3 do isolamento de dados por curso: redesenho de ids_questoes_para_usuario e
-- registrar_resposta para respeitar exclusivamente perfis.curso_ativo_id.
--
-- ============================================================================
-- 1) ids_questoes_para_usuario — REDESENHO CONFIÁVEL
-- Baseado na definição real (obtida via pg_get_functiondef e colada pelo usuário nesta
-- conversa), portanto esta substituição é uma transformação direta do que já existe,
-- não uma reconstrução por descrição.
--
-- O que muda em relação à versão atual:
--   - Passa a considerar SOMENTE o curso ativo (perfis.curso_ativo_id), nunca a união de
--     todas as matrículas ativas do usuário.
--   - Remove por completo a cláusula "not exists (... curso_questoes ...)" que liberava
--     questões sem nenhum vínculo de curso para qualquer usuário — essa era a principal
--     violação do isolamento por curso.
--   - Se o usuário não tiver curso_ativo_id definido, ou não houver matrícula ativa
--     correspondente, o resultado é vazio (nunca cai para "mostra tudo").
--   - Ordena por curso_questoes.prioridade ascendente (menor número = maior prioridade,
--     conforme decisão adotada provisoriamente) e, em empate, pelas mais recentes.
-- ============================================================================

create or replace function public.ids_questoes_para_usuario(p_limite integer DEFAULT 10)
RETURNS TABLE(questao_id bigint)
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  select q.id
  from public.questoes q
  join public.curso_questoes cq on cq.questao_id = q.id
  join public.matriculas m
    on m.curso_id = cq.curso_id
   and m.usuario_id = auth.uid()
   and m.status = 'ativa'
  join public.perfis p
    on p.usuario_id = auth.uid()
   and p.curso_ativo_id = cq.curso_id
  where q.ativa = true
  order by cq.prioridade asc, q.criado_em desc
  limit greatest(1, least(coalesce(p_limite, 10), 100));
$function$;

-- ============================================================================
-- 2) registrar_resposta — TRANSFORMAÇÃO DIRETA DA DEFINIÇÃO LITERAL REAL
-- Base: texto literal de public.registrar_resposta colado pelo usuário nesta conversa
-- (obtido via pg_get_functiondef no Supabase). Esta não é uma reconstrução por
-- descrição — é a mesma função, com o mínimo de alterações necessárias.
--
-- O que foi preservado sem nenhuma mudança:
--   - assinatura (nomes, tipos e defaults dos parâmetros, tipo de retorno);
--   - LANGUAGE plpgsql, SECURITY DEFINER, SET search_path TO '';
--   - checagem de auth.uid() nulo;
--   - checagem alternativa → questão (mesma query, mesmas colunas, mesma condição
--     "q.usuario_id is null or q.usuario_id = v_usuario_id");
--   - INSERT em respostas_usuarios (mesmas colunas, mesmos valores);
--   - bloco de UPDATE de contadores da sessão (questoes_respondidas/acertos), mantido
--     tal como estava, inclusive o "if p_sessao_id is not null" ao redor dele — mesmo
--     esse "if" se tornando sempre verdadeiro na prática (já que p_sessao_id passa a
--     ser obrigatório mais acima), optamos por não remover essa linha para minimizar
--     a diferença em relação ao código original;
--   - criação de erros_usuarios e das 3 revisões (1/7/30 dias) quando a resposta está
--     errada, com as mesmas colunas e valores;
--   - retorno (resposta_id, acertou, explicacao, erro_id).
--
-- O que foi alterado (exatamente os itens 1-7 pedidos, nada além disso):
--   - a antiga checagem condicional "if p_sessao_id is not null and not exists (sessão
--     pertence ao usuário) then raise 'Sessao invalida'" foi REMOVIDA e substituída por
--     uma cadeia obrigatória (variáveis novas v_matricula_id, v_curso_id):
--       1. p_sessao_id nulo -> exceção "Sessao obrigatoria";
--       2. sessão não encontrada ou não pertence ao usuário -> exceção "Sessao invalida"
--          (mesma mensagem do código original, mesmo significado);
--       3. sessoes_estudo.matricula_id nulo -> exceção "Sessao sem matricula vinculada";
--       4-5. matrícula não pertence ao usuário ou status <> 'ativa' -> exceção
--            "Matricula invalida ou inativa" (a mesma consulta já obtém o curso_id,
--            item 6);
--       7. questão não associada a esse curso via curso_questoes -> exceção
--          "Questao nao pertence ao curso da matricula".
-- Essa substituição é estritamente mais restritiva que a original (que tolerava
-- p_sessao_id nulo e não validava matrícula/curso) — nenhum caminho que antes era
-- bloqueado passou a ser permitido.
-- ============================================================================

create or replace function public.registrar_resposta(
  p_questao_id bigint,
  p_alternativa_id bigint,
  p_sessao_id bigint DEFAULT NULL::bigint,
  p_tempo_segundos integer DEFAULT NULL::integer
)
RETURNS TABLE(
  resposta_id bigint,
  acertou boolean,
  explicacao text,
  erro_id bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
declare
  v_usuario_id uuid := auth.uid();
  v_correta boolean;
  v_assunto_id bigint;
  v_explicacao text;
  v_resposta_id bigint;
  v_erro_id bigint;
  v_matricula_id uuid;
  v_curso_id uuid;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select a.correta, q.assunto_id, q.explicacao
  into v_correta, v_assunto_id, v_explicacao
  from public.alternativas a
  join public.questoes q on q.id = a.questao_id
  where a.id = p_alternativa_id
    and a.questao_id = p_questao_id
    and q.ativa
    and (q.usuario_id is null or q.usuario_id = v_usuario_id);

  if not found then
    raise exception 'Questao ou alternativa invalida';
  end if;

  if p_sessao_id is null then
    raise exception 'Sessao obrigatoria';
  end if;

  select s.matricula_id
  into v_matricula_id
  from public.sessoes_estudo s
  where s.id = p_sessao_id
    and s.usuario_id = v_usuario_id;

  if not found then
    raise exception 'Sessao invalida';
  end if;

  if v_matricula_id is null then
    raise exception 'Sessao sem matricula vinculada';
  end if;

  select m.curso_id
  into v_curso_id
  from public.matriculas m
  where m.id = v_matricula_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa';

  if not found then
    raise exception 'Matricula invalida ou inativa';
  end if;

  if not exists (
    select 1
    from public.curso_questoes cq
    where cq.questao_id = p_questao_id
      and cq.curso_id = v_curso_id
  ) then
    raise exception 'Questao nao pertence ao curso da matricula';
  end if;

  insert into public.respostas_usuarios (
    usuario_id,
    questao_id,
    alternativa_id,
    sessao_id,
    acertou,
    tempo_segundos
  ) values (
    v_usuario_id,
    p_questao_id,
    p_alternativa_id,
    p_sessao_id,
    v_correta,
    p_tempo_segundos
  )
  returning id into v_resposta_id;

  if p_sessao_id is not null then
    update public.sessoes_estudo
    set
      questoes_respondidas = questoes_respondidas + 1,
      acertos = acertos + case when v_correta then 1 else 0 end
    where id = p_sessao_id
      and usuario_id = v_usuario_id;
  end if;

  if not v_correta then
    insert into public.erros_usuarios (
      usuario_id,
      resposta_id,
      questao_id,
      assunto_id
    ) values (
      v_usuario_id,
      v_resposta_id,
      p_questao_id,
      v_assunto_id
    )
    returning id into v_erro_id;

    insert into public.revisoes (
      usuario_id,
      erro_id,
      assunto_id,
      ordem,
      intervalo_dias,
      agendada_para
    ) values
      (v_usuario_id, v_erro_id, v_assunto_id, 1, 1, current_date + 1),
      (v_usuario_id, v_erro_id, v_assunto_id, 2, 7, current_date + 7),
      (v_usuario_id, v_erro_id, v_assunto_id, 3, 30, current_date + 30);
  end if;

  return query
  select v_resposta_id, v_correta, v_explicacao, v_erro_id;
end;
$function$;
