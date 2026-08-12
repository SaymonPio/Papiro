-- Fundação da Teoria Interativa (Fase 2C): primeira RPC de public.missoes.
--
-- public.iniciar_ou_recuperar_missao_diaria(p_conteudo_id bigint)
--
-- Único parâmetro aceito do cliente: p_conteudo_id. usuario_id, matricula_id,
-- curso_id, data_missao e status são todos determinados/validados no
-- servidor — nunca aceitos como entrada, exatamente como pedido.
--
-- Esta RPC faz SOMENTE: conteúdo -> matrícula ativa do usuário -> criar ou
-- recuperar a missão do dia -> devolver o contexto da missão. Não atualiza
-- progresso_conteudo_matricula, não cria aula/materiais, não toca
-- sessoes_estudo, não marca teoria concluída. Isso fica para etapas
-- futuras, ainda não implementadas.
--
-- Confirmação feita antes de escrever este arquivo (pedida explicitamente):
-- public.curso_conteudos.relevante_para_preparacao e
-- public.curso_materias.relevante_para_preparacao EXISTEM no banco real
-- (ambas boolean not null default true — ver supabase/base_programatica_curso.sql,
-- seções 1 e 2). Já são usadas hoje pelas RPCs
-- public.materias_do_curso_ativo()/public.assuntos_do_curso_ativo() (ver
-- supabase/sessao_personalizada_curso.sql) para excluir matéria/conteúdo
-- marcados como não relevantes das listagens de sessão personalizada — esta
-- RPC segue exatamente o mesmo precedente: não permite iniciar/recuperar
-- missão para um conteúdo (ou a matéria à qual ele pertence) marcado como
-- não relevante para preparação.
--
-- Também confirmado antes de escrever: public.matriculas.expira_em EXISTE
-- na tabela real (ver comentário em supabase/cursos_matriculas.sql), mas
-- NENHUMA função, policy ou tela deste projeto o usa hoje como critério de
-- validade — toda checagem de "matrícula válida" existente (RLS de
-- sessoes_estudo/configuracoes_estudo, as duas RPCs acima) usa exclusivamente
-- status = 'ativa'. Por instrução explícita de não inventar comportamento
-- diferente do resto do sistema sem explicar, esta RPC reaproveita a MESMA
-- regra (só status = 'ativa') e não introduz nenhuma checagem de expira_em.
-- Se isso mudar no futuro, deve mudar de forma consistente em todos esses
-- lugares, não só aqui.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- CREATE FUNCTION sem OR REPLACE, de propósito: esta função é nova e não
-- existe hoje. Se já existir algo com esse nome/assinatura, a migration deve
-- FALHAR em vez de substituir silenciosamente algo desconhecido — mesmo
-- princípio fail-fast já usado em supabase/missoes.sql. Sem DROP FUNCTION.
create function public.iniciar_ou_recuperar_missao_diaria(p_conteudo_id bigint)
returns table (
  id uuid,
  matricula_id uuid,
  conteudo_id bigint,
  data_missao date,
  status text,
  progresso_teoria jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid;
  v_curso_id uuid;
  v_conteudo_relevante boolean;
  v_materia_relevante boolean;
  v_matricula_id uuid;
  v_data_missao date;
  v_missao_id uuid;
begin
  -- Usuário: SEMPRE de auth.uid(), nunca de parâmetro. Sem sessão válida,
  -- aborta — nenhuma missão é criada/recuperada para ninguém.
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  -- Conteúdo -> curso: curso_conteudos -> curso_materias -> curso_id.
  -- Também traz as duas flags de relevância na mesma consulta.
  select cm.curso_id, cc.relevante_para_preparacao, cm.relevante_para_preparacao
  into v_curso_id, v_conteudo_relevante, v_materia_relevante
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = p_conteudo_id;

  if v_curso_id is null then
    raise exception 'Conteudo % nao encontrado', p_conteudo_id;
  end if;

  -- Mesmo critério já usado por materias_do_curso_ativo()/
  -- assuntos_do_curso_ativo(): conteúdo ou matéria marcados como não
  -- relevantes para preparação não geram missão.
  if not v_conteudo_relevante or not v_materia_relevante then
    raise exception 'Conteudo % nao esta marcado como relevante para preparacao', p_conteudo_id;
  end if;

  -- Matrícula: do próprio usuário autenticado, para o curso derivado do
  -- conteúdo, e ativa. UNIQUE(usuario_id, curso_id) em matriculas garante no
  -- máximo uma linha aqui — não precisa de LIMIT/ORDER BY para desambiguar.
  -- Sem checagem de expira_em (ver nota no cabeçalho do arquivo).
  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    raise exception 'Nenhuma matricula ativa encontrada para este usuario neste curso';
  end if;

  -- Data de negócio em America/Sao_Paulo, nunca current_date puro nem valor
  -- vindo do cliente — mesma regra do DEFAULT de missoes.data_missao.
  v_data_missao := (timezone('America/Sao_Paulo', now()))::date;

  -- Idempotência: identidade já garantida pela UNIQUE(matricula_id,
  -- conteudo_id, data_missao) de public.missoes — constraint real confirmada
  -- no banco: missoes_matricula_id_conteudo_id_data_missao_key. Usar ON
  -- CONFLICT ON CONSTRAINT (em vez da lista de colunas) evita qualquer
  -- ambiguidade de resolução de nomes no PL/pgSQL, já que RETURNS TABLE
  -- declara matricula_id/conteudo_id/data_missao como nomes de OUT
  -- parameter, iguais aos nomes das colunas. DO NOTHING (não DO UPDATE) para
  -- nunca disparar o trigger de atualizado_em quando a missão já existe —
  -- F5/clique duplo não deve alterar NADA da missão existente (nem
  -- atualizado_em, nem iniciada_em, nem status, nem progresso_teoria). Se o
  -- INSERT não inserir (conflito), v_missao_id fica NULL e a missão
  -- existente é buscada logo abaixo, sem tocá-la.
  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, p_conteudo_id, v_data_missao)
  on conflict on constraint missoes_matricula_id_conteudo_id_data_missao_key
  do nothing
  returning missoes.id into v_missao_id;

  if v_missao_id is null then
    select ms.id into v_missao_id
    from public.missoes ms
    where ms.matricula_id = v_matricula_id
      and ms.conteudo_id = p_conteudo_id
      and ms.data_missao = v_data_missao;
  end if;

  -- Retorno explícito e pequeno — nunca "select *". Reflete exatamente o
  -- estado atual da linha (recém-criada OU já existente, sem diferença).
  return query
  select ms.id, ms.matricula_id, ms.conteudo_id, ms.data_missao, ms.status, ms.progresso_teoria
  from public.missoes ms
  where ms.id = v_missao_id;
end;
$function$;

-- Sem execução anônima. REVOKE explícito de PUBLIC e de anon, depois GRANT
-- só para authenticated — mesmo padrão de privilégio explícito já usado em
-- supabase/missoes.sql (não depender do default do schema).
revoke execute on function public.iniciar_ou_recuperar_missao_diaria(bigint) from public;
revoke execute on function public.iniciar_ou_recuperar_missao_diaria(bigint) from anon;
grant execute on function public.iniciar_ou_recuperar_missao_diaria(bigint) to authenticated;

COMMIT;
