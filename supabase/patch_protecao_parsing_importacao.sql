-- Patch isolado: proteção contra quebra de parsing na importação de questões
-- (mesmo defeito das questões 877/882/889/890 — ver análise de causa raiz).
--
-- Este arquivo é INDEPENDENTE de supabase/importar_questoes_lote.sql (que tem
-- alterações não commitadas de um trabalho anterior, sem relação com esta
-- proteção). As definições de importar_questoes_dry_run e importar_questoes_lote
-- abaixo foram construídas a partir do que está REALMENTE instalado hoje no
-- Supabase (confirmado via diagnóstico: RETURNS TABLE(importadas bigint,
-- ignoradas_por_duplicidade bigint, erros bigint), v_importadas/v_ignoradas,
-- duplicata tratada com "continue", retorno resumido ao final) — não do estado
-- do arquivo de trabalho local, que mistura essas mudanças de assinatura com a
-- proteção. Nenhuma assinatura, grant ou comportamento de duplicata é alterado
-- por este patch: a ÚNICA adição funcional em cada uma das duas RPCs é a
-- declaração de v_seq_idx e o loop de detecção de quebra de parsing.
--
-- BEGIN/COMMIT: nenhuma das três mudanças abaixo (criar a função auxiliar,
-- revogar EXECUTE dela, e os dois CREATE OR REPLACE) depende de DROP FUNCTION
-- — CREATE OR REPLACE preserva o ACL existente quando a assinatura não muda,
-- que é o caso aqui. A transação existe só para garantir que as três mudanças
-- apliquem juntas ou nenhuma aplique.

BEGIN;

-- ============================================================================
-- 1) alternativa_tem_sequencia_embutida(p_texto) — FONTE ÚNICA da regra de
-- deteccao de quebra de parsing (mesmo defeito das questoes 877/882/889/890):
-- um importador externo colou texto-base + comando + alternativas reais
-- dentro de um unico campo alternativa_*, e o que sobrou nos campos A-D era,
-- na verdade, itens de uma enumeracao interna do proprio texto-base. Sinal
-- forte e conservador: o campo contem, nessa ordem, os quatro marcadores
-- a) b) c) d). NAO dispara para uma unica ocorrencia isolada (ex.: "alinea
-- a)") nem por tamanho/pontuacao da alternativa — exige as quatro letras em
-- sequencia no mesmo campo, que nao tem explicacao legitima plausivel.
--
-- Usada por importar_questoes_dry_run (validacao, nao bloqueia escrita por
-- si só) E por importar_questoes_lote (grava de fato — trava obrigatoria
-- antes de qualquer INSERT, mesmo se chamada diretamente sem passar pelo
-- dry-run). O regex em si só existe AQUI.
--
-- LANGUAGE SQL (não plpgsql) + IMMUTABLE: função pura, mesmo texto sempre
-- produz o mesmo resultado, nenhuma tabela é lida ou escrita. SEM SECURITY
-- DEFINER: não precisa — não faz nada que exija privilégio elevado.
-- coalesce(p_texto, '') garante false para NULL.
-- ============================================================================

create or replace function public.alternativa_tem_sequencia_embutida(p_texto text)
returns boolean
language sql
immutable
as $$
  select coalesce(p_texto, '') ~* 'a\).*?b\).*?c\).*?d\)';
$$;

-- ============================================================================
-- 2) Função interna, não precisa virar RPC pública: por padrão o Postgres
-- concede EXECUTE a PUBLIC na criação, e o PostgREST/Supabase expõe qualquer
-- função de public com EXECUTE como endpoint RPC chamável do navegador. Não
-- há risco de segurança concreto (função pura, sem SECURITY DEFINER, sem
-- acesso a tabela), mas não há motivo para expor um detalhe de implementação
-- interno das duas RPCs como endpoint público. Revogar de PUBLIC não afeta as
-- chamadas internas feitas de dentro de importar_questoes_dry_run/
-- importar_questoes_lote: o owner das funções mantém a capacidade de
-- executar o que possui, independente de grants a PUBLIC.
-- ============================================================================

revoke execute on function public.alternativa_tem_sequencia_embutida(text) from public;

-- ============================================================================
-- 3) importar_questoes_dry_run — definição idêntica à atualmente instalada no
-- Supabase, com SOMENTE duas adições: a declaração de v_seq_idx e o loop de
-- detecção de quebra de parsing logo após a validação "alternativas A-D sao
-- obrigatorias". Assinatura, RETURNS TABLE, todas as demais validações
-- (materia/assunto/gabarito/enunciado/ano/duplicata) e a lógica de
-- status ('erro'/'alerta'/'ok') permanecem exatamente como estão hoje em
-- produção.
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
  v_seq_idx integer;
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

    -- Deteccao de quebra de parsing (mesmo defeito das questoes 877/882/889/890)
    -- — regra completa e justificativa em public.alternativa_tem_sequencia_embutida
    -- (seção 1 acima; fonte única, também usada por importar_questoes_lote).
    for v_seq_idx in 1..5 loop
      if public.alternativa_tem_sequencia_embutida(v_alternativas[v_seq_idx]) then
        v_mensagens := array_append(
          v_mensagens,
          'Possível quebra de parsing: uma alternativa contém uma nova sequência a)/b)/c)/d), indicando que texto-base e alternativas podem ter sido concatenados.'
        );
        v_bloqueante := true;
        exit;
      end if;
    end loop;

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
-- 4) importar_questoes_lote — definição idêntica à atualmente instalada no
-- Supabase (assinatura, RETURNS TABLE(importadas, ignoradas_por_duplicidade,
-- erros), tratamento de duplicata via "continue"+contador, retorno-resumo ao
-- final), com SOMENTE duas adições: a declaração de v_seq_idx e o loop de
-- detecção de quebra de parsing logo após "alternativas A-D sao obrigatorias"
-- e ANTES de qualquer validação de gabarito ou INSERT. Sem DROP FUNCTION —
-- não é necessário, a assinatura não muda — e sem GRANT explícito: CREATE OR
-- REPLACE preserva o ACL já existente da função quando a assinatura não é
-- alterada, então os grants atuais permanecem intactos.
-- ============================================================================

create or replace function public.importar_questoes_lote(
  p_curso_id uuid,
  p_linhas jsonb
)
returns table (
  importadas bigint,
  ignoradas_por_duplicidade bigint,
  erros bigint
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
  v_seq_idx integer;
  v_importadas bigint := 0;
  v_ignoradas bigint := 0;
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

    -- Trava obrigatoria ANTES de qualquer INSERT (questoes/alternativas mais
    -- abaixo neste loop): mesma regra de public.alternativa_tem_sequencia_embutida
    -- usada em importar_questoes_dry_run (ver seção 1 acima) — aqui replicada
    -- como bloqueio duro via RAISE EXCEPTION, porque esta função grava de
    -- fato e precisa se autodefender mesmo se for chamada diretamente, sem
    -- passar pelo dry-run antes. RAISE EXCEPTION aborta a chamada inteira
    -- (nenhuma questão/alternativa desta execução fica parcialmente gravada
    -- — mesma garantia de atomicidade já documentada para as demais
    -- validações desta função).
    for v_seq_idx in 1..5 loop
      if public.alternativa_tem_sequencia_embutida(v_alternativas[v_seq_idx]) then
        raise exception 'Linha %: possível quebra de parsing — a alternativa % contém uma sequência a)/b)/c)/d), indicando que texto-base e alternativas podem ter sido concatenados.', v_linha_numero, v_letras[v_seq_idx];
      end if;
    end loop;

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
      -- Defesa adicional: ignora a linha em vez de abortar o lote inteiro.
      -- Cobre duplicata pré-existente E duplicata dentro do próprio CSV (a
      -- questão de uma linha anterior deste mesmo lote, já inserida acima
      -- neste laço, também é enxergada por este EXISTS).
      v_ignoradas := v_ignoradas + 1;
      continue;
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

    v_importadas := v_importadas + 1;
  end loop;

  importadas := v_importadas;
  ignoradas_por_duplicidade := v_ignoradas;
  erros := 0;
  return next;
end;
$function$;

COMMIT;

-- Nenhuma assinatura mudou neste patch, mas o corpo de duas funções e a
-- existência de uma terceira mudaram — notifica o PostgREST para recarregar
-- o cache de schema imediatamente, em vez de esperar o ciclo automático.
-- Fora da transação de propósito: NOTIFY só é entregue após o COMMIT de
-- qualquer forma, mas mantê-lo como statement separado deixa isso explícito.
NOTIFY pgrst, 'reload schema';
