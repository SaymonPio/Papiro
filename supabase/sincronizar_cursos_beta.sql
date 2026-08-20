-- Passo 1 do onboarding do beta (Papiro): versionamento retroativo de
-- public.sincronizar_cursos_beta.
--
-- Esta função já existe e está em produção no banco, mas não tinha nenhum
-- arquivo correspondente neste repositório — foi criada diretamente via
-- editor SQL do Supabase Studio, fora do controle de versão. Este arquivo
-- captura EXATAMENTE a definição e os privilégios já em vigor, obtidos ao
-- vivo via pg_get_functiondef(oid) e pg_proc.proacl. Não é uma reescrita,
-- não é uma melhoria de segurança, não muda comportamento nem search_path —
-- é uma cópia fiel do estado atual, para fechar a lacuna de auditoria antes
-- de construir a nova RPC de onboarding (configurar_curso_usuario) em cima
-- dela.
--
-- Comportamento observado e preservado neste arquivo (nada disso muda):
--   - Exige auth.uid() não nulo (usuário autenticado); senão, exceção.
--   - Exige ao menos 1 curso em p_curso_ids; senão, exceção.
--   - Exige p_horas_diarias entre 0.5 e 16; senão, exceção.
--   - Exige que cada curso em p_curso_ids exista em public.cursos com
--     publicado = true; senão, exceção "Curso inválido ou indisponível".
--   - Apaga todos os objetivos atuais do usuário (public.objetivos).
--   - Cancela (status = 'cancelada') as matrículas do usuário para cursos
--     que NÃO estão em p_curso_ids.
--   - Cria ou reativa (upsert via ON CONFLICT(usuario_id, curso_id)) uma
--     matrícula com status='ativa', origem='cortesia' para cada curso em
--     p_curso_ids.
--   - Cada INSERT/UPDATE em public.matriculas com status='ativa' dispara o
--     trigger matricula_cria_objetivo (função criar_objetivo_da_matricula),
--     que recria a linha de public.objetivos correspondente a partir dos
--     dados do curso (carreira/concurso/cargo/banca/data_prova), com
--     horas_diarias fixado em 1 nesse primeiro momento.
--   - Por isso, ao final, faz um UPDATE em public.objetivos ajustando
--     horas_diarias para o valor real recebido em p_horas_diarias, nas
--     linhas dos cursos recém-sincronizados — corrigindo o valor padrão de
--     1 que o trigger acabou de gravar.
--   - Retorna true em caso de sucesso.
--
-- SET search_path TO 'public' (não vazio) é mantido EXATAMENTE como está em
-- produção neste primeiro passo — a maioria das demais funções do projeto
-- usa search_path vazio (''), mas alinhar isso é uma melhoria de segurança
-- fora do escopo deste passo, que é só captura fiel do estado atual.

create or replace function public.sincronizar_cursos_beta(p_curso_ids uuid[], p_horas_diarias numeric)
 returns boolean
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_id uuid;
begin
  if v_usuario_id is null then
    raise exception 'Usuário não autenticado';
  end if;

  if coalesce(array_length(p_curso_ids, 1), 0) = 0 then
    raise exception 'Selecione pelo menos um concurso';
  end if;

  if p_horas_diarias is null or p_horas_diarias < 0.5 or p_horas_diarias > 16 then
    raise exception 'Disponibilidade diária inválida';
  end if;

  if exists (
    select 1 from unnest(p_curso_ids) escolhido(id)
    left join public.cursos c on c.id = escolhido.id and c.publicado = true
    where c.id is null
  ) then
    raise exception 'Curso inválido ou indisponível';
  end if;

  delete from public.objetivos where usuario_id = v_usuario_id;

  update public.matriculas
  set status = 'cancelada'
  where usuario_id = v_usuario_id
    and not (curso_id = any(p_curso_ids));

  foreach v_curso_id in array p_curso_ids loop
    insert into public.matriculas(usuario_id, curso_id, status, origem, expira_em)
    values(v_usuario_id, v_curso_id, 'ativa', 'cortesia', null)
    on conflict(usuario_id, curso_id) do update
      set status = 'ativa', origem = 'cortesia', expira_em = null;
  end loop;

  update public.objetivos
  set horas_diarias = p_horas_diarias
  where usuario_id = v_usuario_id
    and curso_id = any(p_curso_ids);

  return true;
end;
$function$;

-- GRANTs preservados exatamente como observados em produção (pg_proc.proacl):
-- postgres=X/postgres, anon=X/postgres, authenticated=X/postgres, service_role=X/postgres
-- (PUBLIC já não tinha EXECUTE hoje — não há entrada "=X/postgres" na ACL
-- observada; os REVOKE abaixo apenas tornam esse estado explícito e
-- reproduzível, sem alterar nada). anon mantido de propósito neste primeiro
-- passo — restringir isso é decisão para quando a nova RPC de onboarding for
-- criada, não para agora.
revoke execute on function public.sincronizar_cursos_beta(uuid[], numeric) from public;
grant execute on function public.sincronizar_cursos_beta(uuid[], numeric) to anon;
grant execute on function public.sincronizar_cursos_beta(uuid[], numeric) to authenticated;
grant execute on function public.sincronizar_cursos_beta(uuid[], numeric) to service_role;
