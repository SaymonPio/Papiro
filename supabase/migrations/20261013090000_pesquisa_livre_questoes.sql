-- PAPIRO — Pesquisa livre de questões (/questoes/buscar).
--
-- Cadeia NOVA e isolada, paralela a ids_questoes_para_usuario()/
-- iniciar_sessao_questoes_avulsa() — nenhuma das duas é tocada (nem a
-- assinatura, nem o corpo, nem os grants). O motor de EXECUÇÃO continua
-- sendo o mesmo: a sessão criada aqui é consumida por /questoes através de
-- ?sessaoAvulsa=<id>, que já é 100% nivel_meta-agnóstico (obter_sessao_
-- questoes_avulsa só confere usuario_id/missao_id, nunca nivel_meta) —
-- confirmado por auditoria, não é suposição.
--
-- Desenho (3 funções + 1 interna, auditoria + revisão de arquitetura
-- apresentadas antes desta migration):
--   1) questoes_elegiveis_pesquisa(...): FONTE ÚNICA DE VERDADE da
--      elegibilidade. Deriva auth.uid() -> perfis.curso_ativo_id ->
--      matrícula ativa -> curso_questoes -> questoes ativas (nunca um
--      SELECT direto em questoes sem passar por curso_questoes — RLS de
--      questoes sozinha NÃO filtra por curso, confirmado na auditoria).
--      Replica EXPLICITAMENTE, dentro do SECURITY DEFINER, a mesma
--      semântica da policy "Questoes visiveis" (q.usuario_id is null or
--      q.usuario_id = auth.uid()) — SECURITY DEFINER bypassa RLS, então
--      nunca se pode confiar que a policy "vai filtrar sozinha"; questão
--      autoral de OUTRO aluno (usuario_id preenchido, não nulo, não o
--      chamador) nunca pode aparecer nem na elegibilidade nem nas opções.
--      Aplica os 7 filtros de busca (matéria/assunto/banca/ano/
--      dificuldade/busca/status) num único WHERE, todos normalizados
--      internamente (ver bloco de normalização abaixo). Status usa LEFT
--      JOIN LATERAL na última resposta do usuário por questão (ORDER BY
--      respondida_em DESC, id DESC LIMIT 1 — determinístico, mesmo padrão
--      já usado em concluir_revisao()). Não é exposta ao authenticated —
--      só as duas RPCs abaixo a chamam.
--   2) contar_questoes_pesquisa(...): só leitura, COUNT(*) sobre a MESMA
--      função de elegibilidade. Nunca cria nada, nunca duplica o WHERE.
--   3) opcoes_pesquisa_questoes(): só leitura, devolve bancas/anos/
--      dificuldades REALMENTE existentes no curso ativo e visíveis a este
--      aluno (mesmo join curso_questoes + mesma checagem de usuario_id de
--      questoes_elegiveis_pesquisa) — nunca um enum fixo no frontend,
--      nunca valor de outro curso nem de questão privada de outro aluno.
--   4) iniciar_sessao_questoes_pesquisa(...): mesmo preâmbulo de auth/
--      curso ativo/matrícula ativa/lock/idempotência de iniciar_revisao()
--      (chave própria 'pesquisa:usuario:matricula', nunca colide com
--      'revisao:...'). Seleciona os IDs da MESMA função de elegibilidade
--      (preview = universo real da sessão, nunca dois WHERE
--      independentes). Cria a sessão com nivel_meta='pesquisa' (novo
--      valor, só alcançável por esta RPC — iniciar_sessao_questoes_
--      avulsa() rejeita qualquer nivel_meta fora de minima/normal/ideal/
--      personalizada no seu próprio IF interno, então estruturalmente
--      nunca tenta recuperar nem é recuperada por uma sessão 'pesquisa').
--
-- Ponto crítico de idempotência (auditoria solicitada antes de escrever
-- esta migration, revisada e reforçada numa segunda rodada): iniciar_
-- sessao_questoes_avulsa() hoje decide "sessão compatível" só por
-- usuario_id/matricula_id/missao_id IS NULL/status/nivel_meta/
-- materia_id/assunto_id — NUNCA banca/ano/dificuldade/busca/status/
-- quantidade (que nem existem como parâmetro dela). Não há nenhuma UNIQUE
-- constraint em sessoes_estudo além da PK(id) — a proteção contra sessão
-- duplicada hoje é 100% de aplicação (o SELECT...FOR UPDATE), sem nenhum
-- pg_advisory_xact_lock, então duplo-clique/retry concorrente PODE, em
-- tese, criar duas sessões 'personalizada' (falha já documentada no
-- comentário de 20261008120000_revisao_executavel.sql, fora do escopo
-- desta migration — não corrigida ali). Para a pesquisa livre, dois
-- problemas precisavam de solução ANTES de existir:
--   (a) a mesma falha de duplo clique — resolvida com
--       pg_advisory_xact_lock ADQUIRIDO ANTES de procurar/criar a sessão
--       (mesma ordem/padrão de iniciar_revisao()/iniciar_revisao_
--       personalizada()): resolve usuário/matrícula -> lock -> procura
--       sessão compatível -> só então cria se nenhuma existir.
--   (b) duas buscas DIFERENTES (ex.: Português+Crase+FCC+10+Acertei vs.
--       Português+Crase+FUNDATEC+50+Errei) recuperando a sessão uma da
--       outra só por bater materia_id/assunto_id — resolvida com a nova
--       coluna sessoes_estudo.filtros_pesquisa jsonb, com 8 CHAVES
--       (matéria, assunto, banca, ano, dificuldade, busca, status E
--       QUANTIDADE — quantidade também é identidade da sessão: 10
--       questões de Crase não é a mesma busca que 50 questões de Crase,
--       mesmo com todos os outros filtros iguais). A recuperação exige
--       IGUALDADE EXATA do jsonb inteiro (nunca só campos soltos). jsonb
--       em Postgres compara por valor (forma canônica interna), não por
--       ordem textual das chaves — por isso TODOS os valores persistidos
--       no jsonb são os JÁ NORMALIZADOS (ver bloco de normalização): uma
--       busca='   ' e uma busca=NULL normalizam para o mesmo NULL antes
--       de entrar no jsonb, nunca criam identidades de sessão diferentes.
--
-- Por que nivel_meta='pesquisa' (valor novo no CHECK) em vez de
-- reaproveitar 'personalizada': reaproveitar faria iniciar_sessao_
-- questoes_avulsa() (que NUNCA soube de filtros_pesquisa) poder recuperar
-- por engano uma sessão de pesquisa só porque materia_id/assunto_id
-- batem — exatamente o cenário proibido que se pediu para evitar. Com um
-- nivel_meta próprio, e o próprio IF interno de iniciar_sessao_questoes_
-- avulsa rejeitando qualquer valor fora da lista antiga, as duas cadeias
-- são estruturalmente incapazes de recuperar a sessão uma da outra, nos
-- dois sentidos — confirmado por auditoria do corpo real da função antiga
-- (não alterada por esta migration).
--
-- Por que jsonb (coluna nova) em vez de hash/fingerprint em texto: evita
-- qualquer risco de colisão por concatenação ingênua (ex.: p_busca
-- contendo o separador escolhido) e mantém a sessão auto-explicável ao
-- inspecionar sessoes_estudo diretamente — mesma categoria de coluna já
-- usada neste projeto (missoes.progresso_teoria/progresso_questoes).
-- Nullable, sem default: todo outro fluxo (meta diária, personalizada
-- antiga, missão, revisão, revisão personalizada) nunca escreve nela,
-- continua null para sempre nessas linhas — mudança 100% aditiva. Uma
-- CHECK adicional (sessoes_estudo_filtros_pesquisa_coerente) garante que
-- nenhuma sessão nivel_meta='pesquisa' consiga existir sem seus critérios
-- persistidos, sem exigir filtros_pesquisa de nenhum fluxo antigo.
--
-- Normalização canônica (idêntica nas duas funções que a aplicam —
-- questoes_elegiveis_pesquisa e iniciar_sessao_questoes_pesquisa — nunca
-- duas regras divergentes): busca/banca/dificuldade passam por
-- nullif(btrim(x), '') (string vazia ou só espaços vira NULL); status
-- passa por coalesce(status, 'todas') (NULL explícito = "não informado",
-- mesmo efeito do DEFAULT do parâmetro) seguido de btrim e validação
-- ESTRITA contra o conjunto exato {todas, nao_resolvidas, resolvidas,
-- acertei, errei} — qualquer outro valor (incluindo string vazia após
-- trim, incluindo typo) levanta exceção, nunca cai silenciosamente em
-- 'todas'; quantidade passa por greatest(1, least(100, coalesce(..,20)))
-- — mesmo teto real já usado por ids_questoes_para_usuario (LIMIT
-- greatest(1, least(p_limite,100))), nunca um limite inventado à parte.
-- materia_id/assunto_id continuam bigint (ids, sem normalização de
-- texto); ano continua integer.
--
-- Busca (enunciado, ILIKE): a identidade da sessão guarda o texto JÁ
-- normalizado (trim/nullif), nunca a versão com os caracteres de LIKE
-- escapados — o escape de % e _ (e da própria barra invertida) é uma
-- mecânica de CONSTRUÇÃO DO PADRÃO, local e exclusiva de questoes_
-- elegiveis_pesquisa, nunca persistida: sem isso, um aluno digitando
-- "50%" ou "a_b" literalmente teria esses caracteres interpretados como
-- curinga de LIKE em vez de texto literal.
--
-- Ordenação/priorização: auditada em ids_questoes_para_usuario() —
-- "ORDER BY cq.prioridade ASC, q.criado_em DESC". questoes_elegiveis_
-- pesquisa devolve prioridade/criado_em exatamente para isso; iniciar_
-- sessao_questoes_pesquisa ordena por eles na mesma direção ao aplicar
-- LIMIT v_quantidade — a política de priorização atual não é perdida nem
-- trocada por "ORDER BY id" por conveniência.
--
-- Volume avaliado antes de decidir a busca (auditoria, curso ativo
-- principal): 1325 questões ativas, 80 bancas distintas, 19 anos
-- distintos, 3 dificuldades distintas. ILIKE sem índice novo é
-- suficiente nesta escala — nenhuma extensão (pg_trgm/unaccent) ou índice
-- adicionado "por antecipação", conforme instruído.
--
-- Rollback (documentado, não executado por esta migration):
--   drop function if exists public.iniciar_sessao_questoes_pesquisa(integer, bigint, bigint, text, integer, text, text, text);
--   drop function if exists public.opcoes_pesquisa_questoes();
--   drop function if exists public.contar_questoes_pesquisa(bigint, bigint, text, integer, text, text, text);
--   drop function if exists public.questoes_elegiveis_pesquisa(bigint, bigint, text, integer, text, text, text);
--   alter table public.sessoes_estudo drop constraint if exists sessoes_estudo_filtros_pesquisa_coerente;
--   alter table public.sessoes_estudo drop column if exists filtros_pesquisa;
--   alter table public.sessoes_estudo drop constraint if exists sessoes_estudo_nivel_meta_check;
--   alter table public.sessoes_estudo add constraint sessoes_estudo_nivel_meta_check
--     check (nivel_meta in ('minima', 'normal', 'ideal', 'personalizada', 'revisao'));
--   (nenhuma linha de dado é apagada por este rollback — mas sessões de
--   pesquisa já criadas ficariam com nivel_meta inválido para o CHECK
--   restaurado; só deve ser aplicado se nenhuma sessão 'pesquisa' real
--   tiver sido criada ainda, ou após migrar/apagar essas linhas, mesmo
--   aviso já usado no rollback de 20261008120000. Confirmado por
--   auditoria ao vivo, antes desta migration: 0 linhas com nivel_meta=
--   'pesquisa' existem hoje, e as 98 linhas reais atuais usam só
--   minima/normal/ideal/personalizada/revisao — o novo CHECK é um
--   superset estrito do atual, nenhuma linha existente deixa de ser
--   válida.)

-- ----------------------------------------------------------------------------
-- 1) Schema aditivo em sessoes_estudo.
-- ----------------------------------------------------------------------------
alter table public.sessoes_estudo
  drop constraint if exists sessoes_estudo_nivel_meta_check;
alter table public.sessoes_estudo
  add constraint sessoes_estudo_nivel_meta_check
  check (nivel_meta in ('minima', 'normal', 'ideal', 'personalizada', 'revisao', 'pesquisa'));

alter table public.sessoes_estudo
  add column if not exists filtros_pesquisa jsonb;

-- Nenhuma sessão nivel_meta='pesquisa' pode existir sem seus critérios
-- persistidos; nenhum fluxo antigo é obrigado a preencher filtros_pesquisa
-- (NULL continua válido para todos os outros nivel_meta, inclusive os 98
-- registros reais já existentes, confirmado antes desta migration).
alter table public.sessoes_estudo
  add constraint sessoes_estudo_filtros_pesquisa_coerente
  check (nivel_meta <> 'pesquisa' or filtros_pesquisa is not null);

-- ----------------------------------------------------------------------------
-- questoes_elegiveis_pesquisa(): fonte única de verdade da elegibilidade.
-- Nunca exposta ao authenticated — só contar_questoes_pesquisa(),
-- opcoes_pesquisa_questoes() [via join equivalente] e iniciar_sessao_
-- questoes_pesquisa() a chamam/espelham.
-- ----------------------------------------------------------------------------
create or replace function public.questoes_elegiveis_pesquisa(
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_banca text default null,
  p_ano integer default null,
  p_dificuldade text default null,
  p_busca text default null,
  p_status text default 'todas'
)
returns table (
  questao_id bigint,
  prioridade integer,
  criado_em timestamptz
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_busca_normalizada text;
  v_busca_escapada text;
  v_banca_normalizada text;
  v_dificuldade_normalizada text;
  v_status_normalizado text;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
  end if;

  -- Normalização canônica (idêntica à de iniciar_sessao_questoes_pesquisa
  -- — ver cabeçalho desta migration): string vazia/só espaço vira NULL;
  -- status é validado estritamente, sem fallback silencioso.
  v_busca_normalizada := nullif(btrim(p_busca), '');
  v_banca_normalizada := nullif(btrim(p_banca), '');
  v_dificuldade_normalizada := nullif(btrim(p_dificuldade), '');
  v_status_normalizado := btrim(coalesce(p_status, 'todas'));

  if v_status_normalizado not in ('todas', 'nao_resolvidas', 'resolvidas', 'acertei', 'errei') then
    raise exception 'Status invalido: %', v_status_normalizado;
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    raise exception 'Nenhum curso ativo selecionado';
  end if;

  if not exists (
    select 1
    from public.matriculas m
    where m.usuario_id = v_usuario_id
      and m.curso_id = v_curso_ativo_id
      and m.status = 'ativa'
  ) then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  -- Mensagem de erro clara (mesmo padrão de iniciar_revisao_personalizada)
  -- quando materia_id/assunto_id não pertencem ao curso ativo — defesa em
  -- profundidade: a junção com curso_questoes abaixo já garante que NENHUMA
  -- questão de outro curso jamais aparece, mesmo sem esta checagem; ela só
  -- troca "0 resultados silenciosos" por um erro explícito.
  if p_materia_id is not null and not exists (
    select 1
    from public.curso_materias cm
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cm.relevante_para_preparacao = true
  ) then
    raise exception 'Materia nao pertence ao curso ativo';
  end if;

  if p_assunto_id is not null and not exists (
    select 1
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cc.assunto_id = p_assunto_id
      and cc.relevante_para_preparacao = true
  ) then
    raise exception 'Assunto nao pertence a materia/curso ativo';
  end if;

  -- Escape de % e _ (e da barra invertida em si, escapada primeiro para
  -- nao duplicar o escape dos dois seguintes) — pesquisa é substring
  -- LITERAL, os caracteres de curinga do LIKE digitados pelo aluno nunca
  -- devem mudar a semântica da busca. Nunca persistido — só usado aqui,
  -- localmente, para montar o padrão do ILIKE.
  if v_busca_normalizada is not null then
    v_busca_escapada := replace(replace(replace(v_busca_normalizada, '\', '\\'), '%', '\%'), '_', '\_');
  end if;

  return query
  select
    q.id,
    cq.prioridade,
    q.criado_em
  from public.questoes q
  join public.curso_questoes cq
    on cq.questao_id = q.id
   and cq.curso_id = v_curso_ativo_id
  left join lateral (
    select ru.acertou
    from public.respostas_usuarios ru
    where ru.usuario_id = v_usuario_id
      and ru.questao_id = q.id
    order by ru.respondida_em desc, ru.id desc
    limit 1
  ) ultima_resposta on true
  where q.ativa = true
    -- SECURITY DEFINER bypassa RLS — replica explicitamente a mesma
    -- semântica da policy "Questoes visiveis" (ativa AND (usuario_id IS
    -- NULL OR usuario_id = auth.uid())), nunca confia que RLS vai filtrar
    -- sozinha: questão autoral de OUTRO aluno nunca pode entrar aqui.
    and (q.usuario_id is null or q.usuario_id = v_usuario_id)
    and (p_materia_id is null or q.materia_id = p_materia_id)
    and (p_assunto_id is null or q.assunto_id = p_assunto_id)
    and (v_banca_normalizada is null or q.banca = v_banca_normalizada)
    and (p_ano is null or q.ano = p_ano)
    and (v_dificuldade_normalizada is null or q.dificuldade = v_dificuldade_normalizada)
    and (v_busca_normalizada is null or q.enunciado ilike '%' || v_busca_escapada || '%' escape '\')
    and (
      v_status_normalizado = 'todas'
      or (v_status_normalizado = 'nao_resolvidas' and ultima_resposta.acertou is null)
      or (v_status_normalizado = 'resolvidas' and ultima_resposta.acertou is not null)
      or (v_status_normalizado = 'acertei' and ultima_resposta.acertou is true)
      or (v_status_normalizado = 'errei' and ultima_resposta.acertou is false)
    );
end;
$function$;

revoke all on function public.questoes_elegiveis_pesquisa(bigint, bigint, text, integer, text, text, text) from public, anon, authenticated;

-- ----------------------------------------------------------------------------
-- contar_questoes_pesquisa(): preview só-leitura, COUNT sobre a MESMA
-- elegibilidade usada por iniciar_sessao_questoes_pesquisa() — nunca dois
-- WHERE independentes.
-- ----------------------------------------------------------------------------
create or replace function public.contar_questoes_pesquisa(
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_banca text default null,
  p_ano integer default null,
  p_dificuldade text default null,
  p_busca text default null,
  p_status text default 'todas'
)
returns bigint
language sql
stable
security definer
set search_path to ''
as $function$
  select count(*)
  from public.questoes_elegiveis_pesquisa(p_materia_id, p_assunto_id, p_banca, p_ano, p_dificuldade, p_busca, p_status);
$function$;

revoke all on function public.contar_questoes_pesquisa(bigint, bigint, text, integer, text, text, text) from public, anon;
grant execute on function public.contar_questoes_pesquisa(bigint, bigint, text, integer, text, text, text) to authenticated;

-- ----------------------------------------------------------------------------
-- opcoes_pesquisa_questoes(): bancas/anos/dificuldades REALMENTE
-- existentes e visíveis a este aluno no curso ativo (mesmo join curso_
-- questoes + mesma checagem de usuario_id de questoes_elegiveis_pesquisa)
-- — nunca um enum fixo, nunca valor de outro curso, nunca valor vindo de
-- questão privada de outro aluno. Arrays ordenados deterministicamente
-- (banca/dificuldade alfabético, ano decrescente); string vazia/só espaço
-- em banca/dificuldade é tratada como ausência (nullif+btrim), nunca vira
-- uma opção "vazia" no dropdown.
-- ----------------------------------------------------------------------------
create or replace function public.opcoes_pesquisa_questoes()
returns table (
  bancas text[],
  anos integer[],
  dificuldades text[]
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    raise exception 'Nenhum curso ativo selecionado';
  end if;

  if not exists (
    select 1
    from public.matriculas m
    where m.usuario_id = v_usuario_id
      and m.curso_id = v_curso_ativo_id
      and m.status = 'ativa'
  ) then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  return query
  with elegiveis as (
    select
      nullif(btrim(q.banca), '') as banca,
      q.ano,
      nullif(btrim(q.dificuldade), '') as dificuldade
    from public.questoes q
    join public.curso_questoes cq
      on cq.questao_id = q.id
     and cq.curso_id = v_curso_ativo_id
    where q.ativa = true
      -- Mesma checagem explícita de questoes_elegiveis_pesquisa: SECURITY
      -- DEFINER bypassa RLS, então facetas nunca podem vazar banca/ano/
      -- dificuldade de uma questão autoral privada de OUTRO aluno.
      and (q.usuario_id is null or q.usuario_id = v_usuario_id)
  )
  select
    array_agg(distinct banca order by banca) filter (where banca is not null),
    array_agg(distinct ano order by ano desc) filter (where ano is not null),
    array_agg(distinct dificuldade order by dificuldade) filter (where dificuldade is not null)
  from elegiveis;
end;
$function$;

revoke all on function public.opcoes_pesquisa_questoes() from public, anon;
grant execute on function public.opcoes_pesquisa_questoes() to authenticated;

-- ----------------------------------------------------------------------------
-- iniciar_sessao_questoes_pesquisa(): mesmo preâmbulo de auth/curso ativo/
-- matrícula ativa/lock/idempotência de iniciar_revisao() — chave de lock
-- própria ('pesquisa:...'), nunca colide com 'revisao:...'. Ordem: resolve
-- usuário/matrícula -> adquire lock -> procura sessão compatível -> só
-- então cria se nenhuma existir. Seleciona da MESMA questoes_elegiveis_
-- pesquisa() usada pelo preview. nivel_meta='pesquisa' + filtros_pesquisa
-- jsonb exato (8 chaves, já normalizadas, quantidade incluída) isolam esta
-- cadeia de iniciar_sessao_questoes_avulsa() nos dois sentidos.
-- ----------------------------------------------------------------------------
create or replace function public.iniciar_sessao_questoes_pesquisa(
  p_quantidade integer,
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_banca text default null,
  p_ano integer default null,
  p_dificuldade text default null,
  p_busca text default null,
  p_status text default 'todas'
)
returns table (
  sessao_id bigint,
  status text,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_sessao_id bigint;
  v_status text;
  v_ids bigint[];
  v_total_ids integer;
  v_quantidade integer;
  v_busca_normalizada text;
  v_banca_normalizada text;
  v_dificuldade_normalizada text;
  v_status_normalizado text;
  v_filtros jsonb;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  -- 1) Resolve usuário/matrícula/curso ativo.
  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    raise exception 'Nenhum curso ativo selecionado';
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  -- Normalização canônica — IDÊNTICA à de questoes_elegiveis_pesquisa
  -- (ver cabeçalho desta migration), aplicada ANTES de montar o jsonb de
  -- identidade: busca='   ' e busca=NULL precisam normalizar para o
  -- MESMO valor antes de entrar em filtros_pesquisa, nunca criar
  -- identidades de sessão diferentes. Quantidade também normalizada aqui
  -- (mesmo teto real de ids_questoes_para_usuario, [1,100]) porque
  -- quantidade agora É parte da identidade da sessão: 10 questões de
  -- Crase não é compatível com 50 questões de Crase.
  v_busca_normalizada := nullif(btrim(p_busca), '');
  v_banca_normalizada := nullif(btrim(p_banca), '');
  v_dificuldade_normalizada := nullif(btrim(p_dificuldade), '');
  v_status_normalizado := btrim(coalesce(p_status, 'todas'));
  v_quantidade := greatest(1, least(100, coalesce(p_quantidade, 20)));

  if v_status_normalizado not in ('todas', 'nao_resolvidas', 'resolvidas', 'acertei', 'errei') then
    raise exception 'Status invalido: %', v_status_normalizado;
  end if;

  -- Fingerprint canônico das 8 chaves (quantidade incluída) — jsonb
  -- compara por valor (forma interna canônica), não por ordem textual de
  -- serialização.
  v_filtros := jsonb_build_object(
    'materiaId', p_materia_id,
    'assuntoId', p_assunto_id,
    'banca', v_banca_normalizada,
    'ano', p_ano,
    'dificuldade', v_dificuldade_normalizada,
    'busca', v_busca_normalizada,
    'status', v_status_normalizado,
    'quantidade', v_quantidade
  );

  -- 2) Lock ANTES de procurar/criar — serializa a ABERTURA inteira (não só
  -- a recuperação de uma linha já existente), mesmo padrão de
  -- iniciar_revisao()/iniciar_revisao_personalizada(); nunca reaproveita a
  -- vulnerabilidade de duplo clique de iniciar_sessao_questoes_avulsa
  -- (que não tem nenhum lock). Chave própria 'pesquisa:...', nunca colide
  -- com 'revisao:...' nem com nenhuma outra chave deste projeto.
  perform pg_advisory_xact_lock(
    hashtextextended('pesquisa:' || v_usuario_id::text || ':' || v_matricula_id::text, 0)
  );

  -- 3) Procura sessão em_andamento compatível: mesmo usuário, mesma
  -- matrícula, missao_id nulo, nivel_meta='pesquisa', filtros_pesquisa
  -- EXATAMENTE igual (as 8 chaves, já normalizadas), com questões
  -- planejadas de fato persistidas.
  select s.id, s.status
  into v_sessao_id, v_status
  from public.sessoes_estudo s
  where s.usuario_id = v_usuario_id
    and s.matricula_id = v_matricula_id
    and s.missao_id is null
    and s.status = 'em_andamento'
    and s.nivel_meta = 'pesquisa'
    and s.filtros_pesquisa = v_filtros
    and exists (
      select 1
      from public.sessao_questoes_planejadas sq
      where sq.sessao_id = s.id
    )
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    return query select v_sessao_id, v_status, v_ids, true;
    return;
  end if;

  -- 4) Só cria se nenhuma sessão compatível foi encontrada. Seleção pela
  -- MESMA questoes_elegiveis_pesquisa() do preview, já normalizada,
  -- ordenada por prioridade/criado_em (auditado em ids_questoes_para_
  -- usuario, nunca trocado por ORDER BY id por conveniência).
  select array_agg(x.questao_id)
  into v_ids
  from (
    select questao_id
    from public.questoes_elegiveis_pesquisa(
      p_materia_id, p_assunto_id, v_banca_normalizada, p_ano,
      v_dificuldade_normalizada, v_busca_normalizada, v_status_normalizado
    )
    order by prioridade asc, criado_em desc
    limit v_quantidade
  ) x;

  v_total_ids := coalesce(cardinality(v_ids), 0);
  if v_total_ids = 0 then
    raise exception 'Nenhuma questao encontrada para os filtros selecionados';
  end if;

  insert into public.sessoes_estudo as se (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas,
    materia_id, assunto_id, filtros_pesquisa
  ) values (
    v_usuario_id, v_matricula_id, 'pesquisa', 'em_andamento',
    clock_timestamp(), 0, v_total_ids,
    p_materia_id, p_assunto_id, v_filtros
  ) returning se.id, se.status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_ids, false;
end;
$function$;

revoke all on function public.iniciar_sessao_questoes_pesquisa(integer, bigint, bigint, text, integer, text, text, text) from public, anon;
grant execute on function public.iniciar_sessao_questoes_pesquisa(integer, bigint, bigint, text, integer, text, text, text) to authenticated;
