-- Fundação da Teoria Interativa (Fase 2I): RPC de escrita segura do
-- progresso da teoria de uma missão.
--
-- public.registrar_componente_teoria_concluido(p_missao_id uuid,
--   p_aula_versao_id uuid, p_componente_id uuid)
--
-- Único ponto de escrita em public.missoes.progresso_teoria/status/
-- teoria_concluida_em a partir de agora. NÃO concede UPDATE em
-- public.missoes para authenticated (continua revogado, ver missoes.sql) —
-- toda escrita passa por esta função SECURITY DEFINER, que valida
-- explicitamente o dono da missão (não delega isso ao RLS, que esta função
-- de qualquer forma ignora por ser SECURITY DEFINER).
--
-- Auditoria feita antes de escrever este arquivo (sem alterar nada, sem
-- reabrir nenhuma migration histórica):
--   - public.missoes (missoes.sql): status text CHECK ('iniciada',
--     'teoria_concluida', 'questoes_iniciadas', 'concluida', 'abandonada'),
--     default 'iniciada'; progresso_teoria jsonb not null default '{}',
--     CHECK só jsonb_typeof=object (nenhum schema interno hoje);
--     teoria_concluida_em timestamptz null; trigger
--     missoes_marca_atualizacao já cuida de atualizado_em em qualquer
--     UPDATE — não duplicado aqui. authenticated só tem SELECT
--     (confirmado: revoke all + grant select, sem nenhuma policy de
--     UPDATE) — esta RPC é o único caminho de escrita, exatamente como
--     reservado no comentário original de missoes.sql.
--   - public.matriculas: usuario_id uuid, status text — mesmo critério já
--     usado em iniciar_ou_recuperar_missao_diaria/
--     carregar_aula_publicada_da_missao (só status = 'ativa' importa).
--   - As 5 tabelas da Fase 2E (teoria_versionada.sql): aulas.conteudo_id
--     (UNIQUE), aulas.ativa; aula_versoes.status CHECK
--     ('rascunho','publicada','arquivada'), aula_versoes.estrutura jsonb
--     (só garante ser objeto — "componentes" não é validado pelo banco).
--     Nenhuma coluna nova é adicionada a nenhuma dessas tabelas nesta fase;
--     nenhum CHECK novo é criado nelas.
--   - public.carregar_aula_publicada_da_missao (teoria_leitura_rpc.sql):
--     não é chamada nem alterada aqui — esta RPC nova refaz sua própria
--     resolução de aula/versão a partir de p_aula_versao_id, porque o
--     contrato desta função exige o cliente informar explicitamente qual
--     versão ele está concluindo (evita ambiguidade caso duas chamadas
--     peguem versões publicadas diferentes entre uma leitura e outra).
--
-- Contrato V1 de componente rastreável dentro de estrutura.componentes:
--   { "id": "<uuid>", "tipo": "<string>" }  (outros campos continuam
--   livres). O id identifica o componente DENTRO DAQUELA aula_versao — não
--   é o índice do array, não é o tipo. "id" e "tipo" são validados pelo
--   TIPO JSON real (jsonb_typeof), nunca só pela extração via ->> — um
--   valor como {"tipo": 123} nunca passaria despercebido como se fosse
--   string. Nenhuma migração de progresso antigo é necessária: não existe
--   progresso real gravado ainda.
--
-- Contrato V1 de progresso_teoria gerido pelo servidor (cliente nunca
-- envia este JSON inteiro — só p_missao_id/p_aula_versao_id/
-- p_componente_id):
--   {
--     "schema_version": 1,
--     "aula_versao_id": "<uuid>",
--     "componentes_concluidos": ["<uuid>", "..."]
--   }
-- Sem percentual, sem total, sem timestamps dentro do JSON. Um
-- progresso_teoria V1 já existente é revalidado CAMPO A CAMPO antes de ser
-- confiado (schema_version precisa ser o NÚMERO JSON 1 — não a string "1"
-- nem boolean; aula_versao_id precisa ser STRING JSON com UUID válido;
-- cada item de componentes_concluidos precisa ser STRING JSON com UUID
-- válido, existente entre os componentes válidos DESTA MESMA versão, e sem
-- duplicata). Qualquer desvio recusa o registro com uma mensagem genérica
-- — nunca "corrige" ou sobrescreve silenciosamente um progresso inválido,
-- e nunca ecoa o conteúdo do progresso_teoria atual na mensagem de erro
-- (evita vazar estado interno para o cliente).
--
-- Esta etapa NÃO implementa: frontend algum, transição para
-- 'questoes_iniciadas', transição para 'concluida', tempo de estudo,
-- id estável em versões antigas da estrutura (uma aula_versao sem
-- contrato V1 simplesmente não aceita progresso — RAISE EXCEPTION, nunca
-- grava parcial).
--
-- Atomicidade: a linha de public.missoes é travada com
-- "SELECT ... FOR UPDATE OF ms" antes de ler progresso_teoria/status —
-- leitura e escrita acontecem na mesma transação implícita da função, sob
-- o mesmo lock, o que serializa duas chamadas concorrentes na mesma missão
-- (a segunda espera a primeira commitar e enxerga o progresso já
-- atualizado antes de aplicar sua própria mesclagem idempotente). Nunca um
-- SELECT solto seguido de UPDATE independente.
--
-- Convenção de migration nova (mesmo padrão de missoes_rpc.sql/
-- teoria_leitura_rpc.sql): CREATE FUNCTION sem OR REPLACE — fail-fast se
-- já existir algo com esse nome/assinatura. Sem DROP FUNCTION. Arquivo
-- NOVO — nenhuma migration histórica (missoes.sql, missoes_rpc.sql,
-- teoria_versionada.sql, teoria_leitura_rpc.sql) é editada.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica. Este arquivo
-- NÃO é executado por esta etapa (só criado, para revisão).

BEGIN;

create function public.registrar_componente_teoria_concluido(
  p_missao_id uuid,
  p_aula_versao_id uuid,
  p_componente_id uuid
)
returns table (
  missao_id uuid,
  status text,
  aula_versao_id uuid,
  componente_id uuid,
  total_componentes integer,
  componentes_concluidos integer,
  teoria_concluida boolean,
  progresso_teoria jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_status_atual text;
  v_progresso_atual jsonb;
  v_teoria_concluida_em timestamptz;

  v_aula_versao_id_real uuid;
  v_estrutura jsonb;
  v_componentes jsonb;

  v_elem jsonb;
  v_id_texto text;
  v_id uuid;
  v_ids_validos uuid[] := '{}';
  v_total_componentes integer;

  v_progresso_aula_versao_id uuid;
  v_ids_concluidos uuid[] := '{}';
  v_total_concluidos integer;
  v_teoria_concluida boolean;

  v_novo_status text;
  v_novo_teoria_concluida_em timestamptz;
  v_novo_progresso jsonb;
begin
  -- A) Usuário SEMPRE de auth.uid(), nunca de parâmetro.
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  -- B) Missão do próprio usuário, matrícula ativa — autorização EXPLÍCITA,
  -- não delegada ao RLS (esta função é SECURITY DEFINER e o ignora).
  -- FOR UPDATE OF ms trava só a linha de missoes (não a de matriculas),
  -- pelo resto da transação da função, garantindo leitura+escrita atômica.
  select ms.id, ms.conteudo_id, ms.status, ms.progresso_teoria, ms.teoria_concluida_em
  into v_missao_id, v_conteudo_id, v_status_atual, v_progresso_atual, v_teoria_concluida_em
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  -- Missão abandonada nunca aceita novo progresso — checado cedo, antes de
  -- gastar trabalho validando a estrutura da aula.
  if v_status_atual = 'abandonada' then
    raise exception 'Esta missao esta abandonada e nao aceita novo progresso de teoria';
  end if;

  -- C) Aula ativa do MESMO conteúdo da missão + a versão publicada exata
  -- informada pelo cliente. Não usa carregar_aula_publicada_da_missao
  -- (evita reabri-la/alterá-la) — resolve direto aqui com os mesmos
  -- critérios já auditados nela.
  select av.id, av.estrutura
  into v_aula_versao_id_real, v_estrutura
  from public.aula_versoes av
  join public.aulas a on a.id = av.aula_id
  where av.id = p_aula_versao_id
    and av.status = 'publicada'
    and a.conteudo_id = v_conteudo_id
    and a.ativa = true;

  if v_aula_versao_id_real is null then
    raise exception 'Aula publicada % nao encontrada para o conteudo desta missao', p_aula_versao_id;
  end if;

  -- D) estrutura.componentes precisa ser array; cada item precisa ter "id"
  -- (STRING JSON com UUID válido) e "tipo" (STRING JSON) — verificado pelo
  -- TIPO JSON real (jsonb_typeof), nunca só pela extração via ->>, que
  -- converteria silenciosamente um número/boolean em texto. Qualquer
  -- violação recusa a versão INTEIRA para fins de progresso — nunca grava
  -- progresso parcial sobre uma estrutura inválida.
  v_componentes := v_estrutura -> 'componentes';

  if v_componentes is null or jsonb_typeof(v_componentes) <> 'array' then
    raise exception 'A versao publicada % nao possui "componentes" como array — nao segue o contrato V1 de progresso', p_aula_versao_id;
  end if;

  for v_elem in select * from jsonb_array_elements(v_componentes)
  loop
    if jsonb_typeof(v_elem) <> 'object' then
      raise exception 'Componente invalido na estrutura da versao % (nao e um objeto JSON)', p_aula_versao_id;
    end if;

    if jsonb_typeof(v_elem -> 'id') is distinct from 'string' then
      raise exception 'Componente sem "id" valido (precisa ser uma string JSON) na estrutura da versao %', p_aula_versao_id;
    end if;

    v_id_texto := v_elem ->> 'id';

    begin
      v_id := v_id_texto::uuid;
    exception when invalid_text_representation then
      raise exception 'Componente com "id" que nao e um UUID valido (%) na estrutura da versao %', v_id_texto, p_aula_versao_id;
    end;

    if jsonb_typeof(v_elem -> 'tipo') is distinct from 'string' then
      raise exception 'Componente % sem "tipo" valido (precisa ser uma string JSON) na estrutura da versao %', v_id, p_aula_versao_id;
    end if;

    if v_id = any(v_ids_validos) then
      raise exception 'Ids de componentes duplicados na estrutura da versao % (%)', p_aula_versao_id, v_id;
    end if;

    v_ids_validos := array_append(v_ids_validos, v_id);
  end loop;

  v_total_componentes := coalesce(array_length(v_ids_validos, 1), 0);

  -- E) O componente informado precisa realmente existir na versão — o
  -- cliente não pode concluir um id inexistente.
  if v_total_componentes = 0 or not (p_componente_id = any(v_ids_validos)) then
    raise exception 'Componente % nao existe na versao publicada %', p_componente_id, p_aula_versao_id;
  end if;

  -- F) progresso_teoria atual: 4 casos possíveis. Quando já é V1, valida
  -- CADA campo pelo seu tipo JSON real (não só presença de chave) antes de
  -- confiar em qualquer valor — nunca aceita as-is, nunca "corrige" ou
  -- sobrescreve silenciosamente um progresso inválido. Mensagem de erro
  -- genérica em todos os desvios desta família: nunca ecoa o JSON atual
  -- (evita vazar estado interno).
  if v_progresso_atual = '{}'::jsonb then
    -- 1) Ainda não inicializado (valor DEFAULT da tabela) — começa vazio.
    v_ids_concluidos := '{}';
  elsif jsonb_typeof(v_progresso_atual) = 'object'
    and (v_progresso_atual -> 'schema_version') = to_jsonb(1::int)
    and jsonb_typeof(v_progresso_atual -> 'aula_versao_id') = 'string'
    and jsonb_typeof(v_progresso_atual -> 'componentes_concluidos') = 'array'
  then
    -- 2/3) Formato V1 reconhecido — aula_versao_id precisa ser um UUID
    -- válido e, ainda, exatamente a MESMA versão do parâmetro atual.
    begin
      v_progresso_aula_versao_id := (v_progresso_atual ->> 'aula_versao_id')::uuid;
    exception when invalid_text_representation then
      raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
    end;

    if v_progresso_aula_versao_id is distinct from p_aula_versao_id then
      raise exception 'Esta missao ja tem progresso de teoria registrado para a versao %; nao e possivel misturar com a versao % informada agora', v_progresso_aula_versao_id, p_aula_versao_id;
    end if;

    -- Cada item de componentes_concluidos precisa ser STRING JSON com
    -- UUID válido, existir entre os componentes válidos desta MESMA
    -- versão (v_ids_validos, já calculado acima) e não se repetir.
    for v_elem in select * from jsonb_array_elements(v_progresso_atual -> 'componentes_concluidos')
    loop
      if jsonb_typeof(v_elem) is distinct from 'string' then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      begin
        v_id := (v_elem #>> '{}')::uuid;
      exception when invalid_text_representation then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end;

      if not (v_id = any(v_ids_validos)) then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      if v_id = any(v_ids_concluidos) then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      v_ids_concluidos := array_append(v_ids_concluidos, v_id);
    end loop;
  else
    -- 4) Formato desconhecido/inválido — nunca sobrescreve silenciosamente.
    raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
  end if;

  -- G) Mescla idempotente: se o componente já estava concluído, nada muda
  -- no conjunto (nem duplica, nem é erro repetir a chamada).
  if not (p_componente_id = any(v_ids_concluidos)) then
    v_ids_concluidos := array_append(v_ids_concluidos, p_componente_id);
  end if;

  -- H) Totais SEMPRE calculados no servidor — nunca aceitos do cliente.
  -- Com o progresso já validado acima (cada id concluído garantidamente
  -- existe em v_ids_validos e sem duplicata), a contagem de concluídos
  -- nunca pode ultrapassar o total de válidos — por isso a comparação de
  -- conclusão usa igualdade, não >=.
  v_total_concluidos := coalesce(array_length(v_ids_concluidos, 1), 0);
  v_teoria_concluida := v_total_concluidos = v_total_componentes;

  -- I) Máquina de estados: só avança 'iniciada' -> 'teoria_concluida' (uma
  -- vez), nunca regride um status mais avançado (teoria_concluida,
  -- questoes_iniciadas, concluida) e nunca decide 'concluida' aqui (fora
  -- de escopo desta RPC). teoria_concluida_em só é preenchido nesta
  -- transição, e só se ainda estiver null.
  v_novo_status := v_status_atual;
  v_novo_teoria_concluida_em := v_teoria_concluida_em;

  if v_teoria_concluida and v_status_atual = 'iniciada' then
    v_novo_status := 'teoria_concluida';
    if v_novo_teoria_concluida_em is null then
      v_novo_teoria_concluida_em := now();
    end if;
  end if;

  -- Novo progresso_teoria: schema_version fixo em 1, aula_versao_id do
  -- servidor (nunca o que o cliente mandaria), ids_concluidos ordenados
  -- pela ordem de conclusão, sem duplicata (garantido acima). Nada de
  -- percentual/total/timestamp dentro do JSON.
  v_novo_progresso := jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', p_aula_versao_id::text,
    'componentes_concluidos', to_jsonb(v_ids_concluidos)
  );

  -- J) Única escrita desta função. O trigger missoes_marca_atualizacao
  -- (já existente, não tocado aqui) cuida de atualizado_em sozinho.
  update public.missoes
  set progresso_teoria = v_novo_progresso,
      status = v_novo_status,
      teoria_concluida_em = v_novo_teoria_concluida_em
  where id = v_missao_id;

  -- Retorno explícito e mínimo — nunca "select *". "componentes_concluidos"
  -- aqui é a CONTAGEM (integer), não o array — mesmo nome usado dentro do
  -- JSON de progresso_teoria para o array, mas tipos diferentes por
  -- contexto; documentado aqui para não confundir quem consumir esta RPC.
  return query
  select
    v_missao_id,
    v_novo_status,
    p_aula_versao_id,
    p_componente_id,
    v_total_componentes,
    v_total_concluidos,
    v_teoria_concluida,
    v_novo_progresso;
end;
$function$;

-- Sem execução anônima. REVOKE explícito de PUBLIC e de anon, depois GRANT
-- só para authenticated — mesmo padrão já usado em todas as RPCs deste
-- projeto. NENHUM UPDATE é concedido em public.missoes para authenticated
-- — essa tabela continua com só SELECT direto (missoes.sql, não alterado
-- aqui); toda escrita de progresso passa exclusivamente por esta função.
revoke execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) from public;
revoke execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) from anon;
grant execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) to authenticated;

COMMIT;
