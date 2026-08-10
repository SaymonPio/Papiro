-- Importação em lote de questões (etapa 1: BM). CSV -> validação/dry-run ->
-- pré-visualização -> confirmação -> RPC transacional (app/admin/importar-questoes).
--
-- Duas RPCs, ambas SECURITY DEFINER + SET search_path TO 'public' (mesmo padrão de
-- ids_questoes_para_usuario/materias_do_curso_ativo/assuntos_do_curso_ativo já
-- existentes) e SEM GRANT/REVOKE EXECUTE explícito — mesmo padrão do restante do
-- projeto (EXECUTE padrão do Postgres para "authenticated" combinado com validação
-- interna, aqui via public.eh_admin() em vez de auth.uid()).
--
-- Importante: como são SECURITY DEFINER, as duas RPCs IGNORAM RLS por definição —
-- diferente do form manual de questão única em app/admin/page.tsx, que insere direto
-- via .from("questoes")/.from("alternativas") e depende de policy RLS com
-- eh_admin() para proteção. Aqui a checagem "if not eh_admin() then raise exception"
-- dentro do corpo da função é a ÚNICA barreira de admin — é obrigatória, não uma
-- camada extra.
--
-- questoes.dificuldade é NOT NULL com DEFAULT 'media' (confirmado no banco) — as
-- duas funções abaixo simplesmente OMITEM essa coluna dos INSERTs/validações,
-- deixando o default do banco ser aplicado. Nenhum campo de dificuldade existe no
-- CSV nem é validado aqui.
--
-- curso_questoes.prioridade (DEFAULT 1) também é omitida do INSERT pelo mesmo
-- motivo — deixa o default do banco aplicar.
--
-- Nenhuma tabela é alterada por este arquivo — só as duas funções novas.

-- ============================================================================
-- 1) importar_questoes_dry_run(p_curso_id, p_linhas) — só validação, não escreve
-- nada. Reporta TODAS as linhas com problema de uma vez (não para na primeira),
-- para alimentar a tela de pré-visualização.
--
-- p_linhas: array JSON de objetos, um por linha do CSV já parseado no navegador
-- (papaparse), com as chaves materia/assunto/banca/concurso/ano/enunciado/
-- alternativa_a..alternativa_e/gabarito/explicacao/fonte. A numeração da linha na
-- resposta vem da posição no array (jsonb_array_elements ... with ordinality), não
-- de um campo embutido em cada objeto.
--
-- materia/assunto são resolvidos por correspondência EXATA (trim, sem normalização
-- de acentos/maiúsculas) contra materias/assuntos com usuario_id is null (banco
-- global) — nunca criados automaticamente. assunto precisa pertencer à materia da
-- mesma linha.
--
-- Duplicata: mesma materia_id + assunto_id (IS NOT DISTINCT FROM, cobre null) +
-- enunciado normalizado (lower(trim(...))). Se já existe vinculada a ESTE curso via
-- curso_questoes -> status 'erro' (bloqueante). Se existe em OUTRO curso -> só aviso
-- ('alerta'), não bloqueia.
--
-- status NUNCA é inferido só pela presença de v_mensagens — cada validação que deve
-- ser bloqueante marca explicitamente v_bloqueante := true junto com a mensagem.
-- Só a duplicata cross-curso (v_dup_global) adiciona mensagem sem marcar
-- v_bloqueante, o que a torna 'alerta' em vez de 'erro'. status final:
--   v_bloqueante          -> 'erro'
--   sem bloqueante mas com mensagem -> 'alerta'
--   sem nenhuma mensagem  -> 'ok'
-- ============================================================================

create or replace function public.importar_questoes_dry_run(
  p_curso_id uuid,
  p_linhas jsonb
)
returns table (
  linha integer,
  status text,
  materia_id bigint,
  assunto_id bigint,
  duplicata_curso boolean,
  duplicata_banco_global boolean,
  mensagens text[]
)
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  v_linha jsonb;
  v_linha_numero integer;
  v_materia_id bigint;
  v_assunto_id bigint;
  v_mensagens text[];
  v_gabarito text;
  v_alternativas text[5];
  v_letras text[5] := array['A','B','C','D','E'];
  v_indice integer;
  v_dup_curso boolean;
  v_dup_global boolean;
  v_bloqueante boolean;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem validar importacao';
  end if;

  if p_curso_id is null or not exists (select 1 from public.cursos c where c.id = p_curso_id) then
    raise exception 'Curso de destino invalido';
  end if;

  for v_linha, v_linha_numero in
    select value, ordinality::integer
    from jsonb_array_elements(p_linhas) with ordinality as t(value, ordinality)
  loop
    v_mensagens := array[]::text[];
    v_materia_id := null;
    v_assunto_id := null;
    v_bloqueante := false;

    select m.id into v_materia_id
    from public.materias m
    where m.usuario_id is null and trim(m.nome) = trim(v_linha->>'materia');

    if v_materia_id is null then
      v_mensagens := array_append(v_mensagens, format('materia "%s" nao encontrada', v_linha->>'materia'));
      v_bloqueante := true;
    end if;

    if v_materia_id is not null and coalesce(trim(v_linha->>'assunto'), '') <> '' then
      select a.id into v_assunto_id
      from public.assuntos a
      where a.usuario_id is null and a.materia_id = v_materia_id and trim(a.nome) = trim(v_linha->>'assunto');

      if v_assunto_id is null then
        v_mensagens := array_append(v_mensagens, format('assunto "%s" nao encontrado ou nao pertence a materia', v_linha->>'assunto'));
        v_bloqueante := true;
      end if;
    end if;

    v_alternativas := array[
      nullif(trim(v_linha->>'alternativa_a'), ''), nullif(trim(v_linha->>'alternativa_b'), ''),
      nullif(trim(v_linha->>'alternativa_c'), ''), nullif(trim(v_linha->>'alternativa_d'), ''),
      nullif(trim(v_linha->>'alternativa_e'), '')
    ];

    if v_alternativas[1] is null or v_alternativas[2] is null or v_alternativas[3] is null or v_alternativas[4] is null then
      v_mensagens := array_append(v_mensagens, 'alternativas A-D sao obrigatorias');
      v_bloqueante := true;
    end if;

    v_gabarito := upper(trim(v_linha->>'gabarito'));
    v_indice := array_position(v_letras, v_gabarito);

    if v_indice is null then
      v_mensagens := array_append(v_mensagens, 'gabarito invalido (use A-E)');
      v_bloqueante := true;
    elsif v_alternativas[v_indice] is null then
      v_mensagens := array_append(v_mensagens, format('gabarito aponta para alternativa %s vazia', v_gabarito));
      v_bloqueante := true;
    end if;

    if coalesce(trim(v_linha->>'enunciado'), '') = '' then
      v_mensagens := array_append(v_mensagens, 'enunciado obrigatorio');
      v_bloqueante := true;
    end if;

    if coalesce(trim(v_linha->>'ano'), '') <> '' and trim(v_linha->>'ano') !~ '^\d{4}$' then
      v_mensagens := array_append(v_mensagens, 'ano deve ser um numero de 4 digitos');
      v_bloqueante := true;
    end if;

    v_dup_curso := false;
    v_dup_global := false;
    if v_materia_id is not null and coalesce(trim(v_linha->>'enunciado'), '') <> '' then
      select
        exists (
          select 1 from public.questoes q
          join public.curso_questoes cq on cq.questao_id = q.id and cq.curso_id = p_curso_id
          where q.materia_id = v_materia_id
            and q.assunto_id is not distinct from v_assunto_id
            and lower(trim(q.enunciado)) = lower(trim(v_linha->>'enunciado'))
        ),
        exists (
          select 1 from public.questoes q
          where q.materia_id = v_materia_id
            and q.assunto_id is not distinct from v_assunto_id
            and lower(trim(q.enunciado)) = lower(trim(v_linha->>'enunciado'))
            and not exists (
              select 1 from public.curso_questoes cq2
              where cq2.questao_id = q.id and cq2.curso_id = p_curso_id
            )
        )
      into v_dup_curso, v_dup_global;
    end if;

    if v_dup_curso then
      v_mensagens := array_append(v_mensagens, 'questao identica ja vinculada a este curso');
      v_bloqueante := true;
    elsif v_dup_global then
      v_mensagens := array_append(v_mensagens, 'questao identica ja existe em outro curso (nao bloqueante)');
    end if;

    linha := v_linha_numero;
    materia_id := v_materia_id;
    assunto_id := v_assunto_id;
    duplicata_curso := v_dup_curso;
    duplicata_banco_global := v_dup_global;
    mensagens := v_mensagens;
    status := case
      when v_bloqueante then 'erro'
      when array_length(v_mensagens, 1) is not null then 'alerta'
      else 'ok'
    end;
    return next;
  end loop;
end;
$function$;

-- ============================================================================
-- 2) importar_questoes_lote(p_curso_id, p_linhas) — grava de fato. Tudo-ou-nada:
-- uma chamada de função PL/pgSQL já é atômica por padrão, então qualquer RAISE
-- EXCEPTION no meio do laço desfaz tudo que essa chamada já gravou (sem precisar
-- de BEGIN/COMMIT manual, que nem seria válido aqui dentro). Por isso nenhuma
-- questão fica órfã: se uma única linha falhar, nada do lote é gravado.
--
-- Revalida tudo de novo (nunca confia só no dry-run anterior, que pode estar
-- desatualizado no momento da confirmação). Mesma resolução exata de
-- materia/assunto, mesma checagem de duplicata (agora só a bloqueante: mesma
-- questão já vinculada a este curso).
--
-- Por linha: INSERT em questoes (usuario_id = null, dificuldade omitida -> default
-- 'media' do banco) -> INSERT nas alternativas informadas (2 a 5, conforme A-E
-- preenchidas) marcando correta = true só na que bate com o gabarito -> INSERT em
-- curso_questoes (curso_id, questao_id; prioridade omitida -> default 1 do banco,
-- protegido por sua vez pelo UNIQUE(curso_id, questao_id) já existente).
-- ============================================================================

create or replace function public.importar_questoes_lote(
  p_curso_id uuid,
  p_linhas jsonb
)
returns table (
  linha integer,
  questao_id bigint
)
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_linha jsonb;
  v_linha_numero integer;
  v_materia_id bigint;
  v_assunto_id bigint;
  v_questao_id bigint;
  v_gabarito text;
  v_alternativas text[5];
  v_letras text[5] := array['A','B','C','D','E'];
  v_indice integer;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem importar questoes';
  end if;

  if p_curso_id is null or not exists (select 1 from public.cursos c where c.id = p_curso_id) then
    raise exception 'Curso de destino invalido';
  end if;

  for v_linha, v_linha_numero in
    select value, ordinality::integer
    from jsonb_array_elements(p_linhas) with ordinality as t(value, ordinality)
  loop
    select m.id into v_materia_id
    from public.materias m
    where m.usuario_id is null and trim(m.nome) = trim(v_linha->>'materia');

    if v_materia_id is null then
      raise exception 'Linha %: materia "%" nao encontrada', v_linha_numero, v_linha->>'materia';
    end if;

    v_assunto_id := null;
    if coalesce(trim(v_linha->>'assunto'), '') <> '' then
      select a.id into v_assunto_id
      from public.assuntos a
      where a.usuario_id is null and a.materia_id = v_materia_id and trim(a.nome) = trim(v_linha->>'assunto');

      if v_assunto_id is null then
        raise exception 'Linha %: assunto "%" nao encontrado ou nao pertence a materia "%"', v_linha_numero, v_linha->>'assunto', v_linha->>'materia';
      end if;
    end if;

    v_alternativas := array[
      nullif(trim(v_linha->>'alternativa_a'), ''), nullif(trim(v_linha->>'alternativa_b'), ''),
      nullif(trim(v_linha->>'alternativa_c'), ''), nullif(trim(v_linha->>'alternativa_d'), ''),
      nullif(trim(v_linha->>'alternativa_e'), '')
    ];

    if v_alternativas[1] is null or v_alternativas[2] is null or v_alternativas[3] is null or v_alternativas[4] is null then
      raise exception 'Linha %: alternativas A-D sao obrigatorias', v_linha_numero;
    end if;

    v_gabarito := upper(trim(v_linha->>'gabarito'));
    v_indice := array_position(v_letras, v_gabarito);

    if v_indice is null then
      raise exception 'Linha %: gabarito "%" invalido (use A-E)', v_linha_numero, v_linha->>'gabarito';
    end if;

    if v_alternativas[v_indice] is null then
      raise exception 'Linha %: gabarito aponta para alternativa % vazia', v_linha_numero, v_gabarito;
    end if;

    if coalesce(trim(v_linha->>'enunciado'), '') = '' then
      raise exception 'Linha %: enunciado obrigatorio', v_linha_numero;
    end if;

    if coalesce(trim(v_linha->>'ano'), '') <> '' and trim(v_linha->>'ano') !~ '^\d{4}$' then
      raise exception 'Linha %: ano deve ser um numero de 4 digitos', v_linha_numero;
    end if;

    if exists (
      select 1 from public.questoes q
      join public.curso_questoes cq on cq.questao_id = q.id and cq.curso_id = p_curso_id
      where q.materia_id = v_materia_id
        and q.assunto_id is not distinct from v_assunto_id
        and lower(trim(q.enunciado)) = lower(trim(v_linha->>'enunciado'))
    ) then
      raise exception 'Linha %: questao duplicada ja vinculada a este curso', v_linha_numero;
    end if;

    -- dificuldade omitida: NOT NULL DEFAULT 'media' no banco cobre o valor.
    insert into public.questoes (usuario_id, materia_id, assunto_id, banca, concurso, ano, enunciado, explicacao, fonte, ativa)
    values (
      null, v_materia_id, v_assunto_id,
      nullif(trim(v_linha->>'banca'), ''), nullif(trim(v_linha->>'concurso'), ''),
      nullif(trim(v_linha->>'ano'), '')::integer,
      trim(v_linha->>'enunciado'), nullif(trim(v_linha->>'explicacao'), ''), nullif(trim(v_linha->>'fonte'), ''),
      true
    )
    returning id into v_questao_id;

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_questao_id, v_alternativas[i], i, (i = v_indice)
    from generate_series(1, 5) as i
    where v_alternativas[i] is not null;

    -- prioridade omitida: DEFAULT 1 no banco cobre o valor; UNIQUE(curso_id,
    -- questao_id) já existente protege contra vínculo duplicado.
    insert into public.curso_questoes (curso_id, questao_id)
    values (p_curso_id, v_questao_id);

    linha := v_linha_numero;
    questao_id := v_questao_id;
    return next;
  end loop;
end;
$function$;
