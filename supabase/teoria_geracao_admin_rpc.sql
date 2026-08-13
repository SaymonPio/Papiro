-- Fundação da Teoria Interativa (Fase 2J-A): RPCs administrativas de apoio
-- ao gerador de aulas — tudo que o admin precisa LER/ESCREVER a partir do
-- navegador (sessão do próprio usuário, nunca service_role) antes/depois
-- de acionar a Edge Function gerar-aula.
--
-- Todas as funções deste arquivo checam public.eh_admin() explicitamente
-- como primeira ação — mesmo padrão já usado em supabase/
-- importar_questoes_lote.sql e supabase/patch_protecao_parsing_importacao.
-- sql ("if not public.eh_admin() then raise exception"). Nenhuma dessas
-- checagens é delegada a RLS: são SECURITY DEFINER e, mesmo que fossem
-- INVOKER, as tabelas envolvidas (curso_conteudos, materiais,
-- material_versoes, aula_versoes, aula_versao_fontes, aula_geracoes) têm
-- RLS que não cobre "administrador arbitrário" em todos os casos
-- (confirmado por auditoria localizada: curso_conteudos só tem policy de
-- SELECT para "aluno matriculado ativo", nenhuma de SELECT para admin —
-- por isso listar_conteudos_curso_admin existe, em vez de o admin
-- consultar a tabela direto).
--
-- Auditoria localizada feita antes deste arquivo (sem reabrir auditoria
-- geral):
--   - public.cursos: SELECT já aberto para qualquer authenticated
--     (cursos_matriculas.sql, "using (true)") — não precisa de RPC.
--   - public.curso_materias: policy "Administrador gerencia matérias dos
--     cursos" é FOR ALL (cobre SELECT) com eh_admin() — não precisa de RPC.
--   - public.curso_conteudos: só tem SELECT para aluno matriculado ativo
--     (base_programatica_curso.sql); NÃO tem SELECT para admin — precisa
--     de RPC (listar_conteudos_curso_admin).
--   - public.materiais/material_versoes: RLS fechado, zero policy
--     (teoria_versionada.sql, decisão explícita de fase futura) — precisa
--     de RPC tanto para leitura quanto para escrita.
--   - public.aula_versoes/aula_versao_fontes: mesmo fechamento total —
--     RPC de leitura para o preview do rascunho (a escrita de aula/
--     aula_versao/aula_versao_fontes fica a cargo da Edge Function
--     gerar-aula via service_role, não deste arquivo).
--   - public.aula_geracoes: RLS fechado, zero policy (aula_geracoes.sql
--     desta mesma fase) — precisa de RPC de leitura.
--
-- Nenhuma migration histórica é editada. Nenhuma tabela nova é criada
-- aqui. CREATE FUNCTION sem OR REPLACE, fail-fast — nomes novos.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- 1) listar_conteudos_curso_admin — conteúdos de uma curso_materia, para o
-- seletor de conteúdo do admin. Traz o nome do assunto (mesmo padrão de
-- carregar_aula_publicada_da_missao) e relevante_para_preparacao (para o
-- admin evitar gerar aula de conteúdo marcado como não relevante).
-- ============================================================================
create function public.listar_conteudos_curso_admin(p_curso_materia_id bigint)
returns table (
  conteudo_id bigint,
  assunto_id bigint,
  nome text,
  ordem integer,
  relevante_para_preparacao boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar conteudos para geracao de aula';
  end if;

  return query
  select
    cc.id,
    cc.assunto_id,
    coalesce(a.nome, 'Conteúdo sem nome'),
    cc.ordem,
    cc.relevante_para_preparacao
  from public.curso_conteudos cc
  left join public.assuntos a on a.id = cc.assunto_id
  where cc.curso_materia_id = p_curso_materia_id
  order by cc.ordem;
end;
$function$;

revoke execute on function public.listar_conteudos_curso_admin(bigint) from public;
revoke execute on function public.listar_conteudos_curso_admin(bigint) from anon;
grant execute on function public.listar_conteudos_curso_admin(bigint) to authenticated;

-- ============================================================================
-- 2) registrar_material_pdf_admin — cria um material novo (se p_material_id
-- for null) OU adiciona uma nova versão a um material existente. Sempre
-- cria uma nova linha em material_versoes (nunca UPDATE — material_versoes
-- é, por desenho, imutável: teoria_versionada.sql). O admin já fez o
-- upload do PDF direto pro Storage antes de chamar esta RPC (bucket
-- materiais-teoria, materiais_teoria_storage.sql) — aqui só se registra o
-- caminho/checksum resultante.
--
-- Integridade de p_arquivo_path (correção pré-aplicação): o texto vindo do
-- cliente NUNCA é confiado sozinho. Antes de qualquer escrita, a função
-- confirma que existe de fato um objeto em storage.objects com
-- bucket_id='materiais-teoria' e name=p_arquivo_path — a fonte de verdade
-- é essa linha, não o parâmetro. p_arquivo_path também é recusado
-- explicitamente se parecer uma URL ("://" no valor) — só o caminho/nome
-- do objeto DENTRO do bucket é aceito, nunca uma signed URL nem uma URL
-- HTTP completa. Um caminho que só existe em OUTRO bucket nunca satisfaz
-- essa checagem (bucket_id é parte da condição), então nunca é aceito. Se
-- a validação falhar, RAISE EXCEPTION e nenhuma linha é criada em
-- materiais nem em material_versoes — a checagem acontece antes de
-- qualquer INSERT desta função.
-- ============================================================================
create function public.registrar_material_pdf_admin(
  p_material_id uuid,
  p_titulo text,
  p_tipo text,
  p_descricao text,
  p_titulo_versao text,
  p_arquivo_path text,
  p_checksum text
)
returns table (
  material_id uuid,
  material_versao_id uuid,
  numero_versao integer
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_material_id uuid;
  v_proximo_numero integer;
  v_versao_id uuid;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem registrar materiais da teoria';
  end if;

  if p_arquivo_path is null or btrim(p_arquivo_path) = '' then
    raise exception 'arquivo_path e obrigatorio';
  end if;

  -- Nunca aceita signed URL / URL HTTP completa / referencia externa —
  -- só o caminho do objeto dentro do bucket materiais-teoria.
  if p_arquivo_path like '%://%' then
    raise exception 'arquivo_path deve ser o caminho do objeto dentro do bucket materiais-teoria, nunca uma URL';
  end if;

  -- Integridade real: o objeto precisa existir de fato no bucket
  -- materiais-teoria. Um caminho que só existe em outro bucket (ou que não
  -- existe em lugar nenhum) nunca satisfaz esta condição — nenhuma escrita
  -- acontece antes desta checagem passar.
  if not exists (
    select 1 from storage.objects
    where bucket_id = 'materiais-teoria' and name = p_arquivo_path
  ) then
    raise exception 'Nenhum arquivo encontrado em materiais-teoria com o caminho informado (%); faca o upload antes de registrar o material', p_arquivo_path;
  end if;

  if p_material_id is null then
    if p_titulo is null or btrim(p_titulo) = '' then
      raise exception 'titulo e obrigatorio para criar um novo material';
    end if;
    if p_tipo is null or btrim(p_tipo) = '' then
      raise exception 'tipo e obrigatorio para criar um novo material';
    end if;

    insert into public.materiais (titulo, tipo, descricao)
    values (btrim(p_titulo), btrim(p_tipo), nullif(btrim(coalesce(p_descricao, '')), ''))
    returning id into v_material_id;
  else
    select id into v_material_id from public.materiais where id = p_material_id;
    if v_material_id is null then
      raise exception 'Material % nao encontrado', p_material_id;
    end if;
  end if;

  -- Qualificado com o alias "mv": tanto "numero_versao" quanto
  -- "material_id" colidem com nomes de OUT parameters desta função
  -- (RETURNS TABLE declara material_id/numero_versao) — sem qualificar,
  -- o Postgres não consegue decidir se a referência é a coluna da tabela
  -- ou o parâmetro OUT, e recusa a função inteira com ambiguous_column
  -- (SQLSTATE 42702).
  select coalesce(max(mv.numero_versao), 0) + 1
  into v_proximo_numero
  from public.material_versoes mv
  where mv.material_id = v_material_id;

  insert into public.material_versoes (material_id, numero_versao, titulo_versao, arquivo_path, checksum)
  values (v_material_id, v_proximo_numero, nullif(btrim(coalesce(p_titulo_versao, '')), ''), p_arquivo_path, p_checksum)
  returning id into v_versao_id;

  return query select v_material_id, v_versao_id, v_proximo_numero;
end;
$function$;

revoke execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) from public;
revoke execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) from anon;
grant execute on function public.registrar_material_pdf_admin(uuid, text, text, text, text, text, text) to authenticated;

-- ============================================================================
-- 3) listar_materiais_admin — materiais existentes + a versão mais recente
-- de cada um, para o seletor de fontes do admin.
-- ============================================================================
create function public.listar_materiais_admin()
returns table (
  material_id uuid,
  titulo text,
  tipo text,
  ativo boolean,
  ultima_versao_id uuid,
  ultimo_numero_versao integer,
  ultima_versao_titulo text
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar materiais da teoria';
  end if;

  return query
  select
    m.id,
    m.titulo,
    m.tipo,
    m.ativo,
    mv.id,
    mv.numero_versao,
    mv.titulo_versao
  from public.materiais m
  -- Subconsulta qualificada com o alias "mvv": "material_id" colide com o
  -- OUT parameter material_id desta função (RETURNS TABLE) — sem
  -- qualificar, seria ambiguous_column (SQLSTATE 42702), mesmo dentro de
  -- um LATERAL. "id"/"numero_versao"/"titulo_versao" não colidem com
  -- nenhum OUT parameter aqui (os desta função são ultima_versao_id/
  -- ultimo_numero_versao/ultima_versao_titulo), mas ficam qualificados
  -- também por consistência.
  left join lateral (
    select mvv.id, mvv.numero_versao, mvv.titulo_versao
    from public.material_versoes mvv
    where mvv.material_id = m.id
    order by mvv.numero_versao desc
    limit 1
  ) mv on true
  order by m.criado_em desc;
end;
$function$;

revoke execute on function public.listar_materiais_admin() from public;
revoke execute on function public.listar_materiais_admin() from anon;
grant execute on function public.listar_materiais_admin() to authenticated;

-- ============================================================================
-- 4) listar_geracoes_conteudo_admin — histórico de gerações (aula_geracoes)
-- de um conteúdo específico, mais recente primeiro.
-- ============================================================================
create function public.listar_geracoes_conteudo_admin(p_conteudo_id bigint)
returns table (
  geracao_id uuid,
  status text,
  iniciado_em timestamptz,
  finalizado_em timestamptz,
  aula_versao_id uuid,
  erro text,
  prompt_version text,
  modelo text
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
    g.modelo
  from public.aula_geracoes g
  where g.conteudo_id = p_conteudo_id
  order by g.iniciado_em desc;
end;
$function$;

revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from public;
revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from anon;
grant execute on function public.listar_geracoes_conteudo_admin(bigint) to authenticated;

-- ============================================================================
-- 5) carregar_aula_rascunho_admin — preview administrativo de UMA
-- aula_versao, qualquer que seja o status (rascunho/publicada/arquivada) —
-- ao contrário de carregar_aula_publicada_da_missao (teoria_leitura_rpc.
-- sql), que só existe pra aluno e só mostra 'publicada'. Gate é só
-- eh_admin(), sem relação com missão/matrícula nenhuma.
-- ============================================================================
create function public.carregar_aula_rascunho_admin(p_aula_versao_id uuid)
returns table (
  aula_id uuid,
  aula_titulo text,
  aula_versao_id uuid,
  numero_versao integer,
  status text,
  estrutura jsonb,
  criado_em timestamptz,
  publicado_em timestamptz,
  fontes jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem visualizar rascunhos de aula';
  end if;

  return query
  select
    a.id,
    a.titulo,
    av.id,
    av.numero_versao,
    av.status,
    av.estrutura,
    av.criado_em,
    av.publicado_em,
    coalesce(f.fontes, '[]'::jsonb) as fontes
  from public.aula_versoes av
  join public.aulas a on a.id = av.aula_id
  left join lateral (
    select jsonb_agg(
      jsonb_build_object(
        'material_id', mv.material_id,
        'material_titulo', mat.titulo,
        'material_tipo', mat.tipo,
        'material_versao_id', mv.id,
        'numero_versao', mv.numero_versao,
        'titulo_versao', mv.titulo_versao,
        'ordem', avf.ordem,
        'observacao', avf.observacao
      )
      order by avf.ordem nulls last, mv.numero_versao, mv.id
    ) as fontes
    from public.aula_versao_fontes avf
    join public.material_versoes mv on mv.id = avf.material_versao_id
    join public.materiais mat on mat.id = mv.material_id
    where avf.aula_versao_id = av.id
  ) f on true
  where av.id = p_aula_versao_id;
end;
$function$;

revoke execute on function public.carregar_aula_rascunho_admin(uuid) from public;
revoke execute on function public.carregar_aula_rascunho_admin(uuid) from anon;
grant execute on function public.carregar_aula_rascunho_admin(uuid) to authenticated;

COMMIT;
