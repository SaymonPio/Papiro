-- ============================================================================
-- TESTE — public.configurar_curso_usuario (Passo 2 do onboarding, Papiro)
-- Modo: TESTE COM ROLLBACK OBRIGATÓRIO — nenhum dado real é alterado
-- ============================================================================
--
-- Pressupõe que supabase/configurar_curso_usuario.sql (e, antes dela,
-- supabase/sincronizar_cursos_beta.sql) já foram aplicados no banco em que
-- este teste roda — este arquivo só EXERCITA a função, não a cria.
--
-- Usa um usuário real já existente no banco (id abaixo), confirmado sem
-- nenhuma linha em perfis nem em matriculas antes do início do teste — não
-- cria usuário sintético em auth.users, para não esbarrar em nenhuma FK ou
-- trigger de criação de conta. Como todo o teste roda dentro de um único
-- BEGIN...ROLLBACK, nenhuma escrita sobrevive ao fim do arquivo, mesmo
-- usando um usuário real.
--
-- auth.uid() é simulado via set_config('request.jwt.claim.sub', ..., true)
-- (GUC local à transação) — é exatamente o que auth.uid() lê nesta base,
-- conforme sua definição (auth.uid() → current_setting('request.jwt.claim.sub')
-- com fallback para request.jwt.claims->>'sub').
--
-- Atualização (configuracoes_estudo): esta versão do harness passou a
-- confirmar, em cada cenário relevante, que public.configuracoes_estudo é
-- criada/atualizada corretamente junto com perfil/matrícula/curso
-- ativo/objetivos, e adiciona um cenário novo (6) para a troca de horas
-- diárias numa matrícula já existente.

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_usuario_teste uuid := '3c10fb17-69ac-4633-91e6-e67fdb6030a4'; -- usuário real, sem perfil/matrícula (confirmado abaixo)
  v_curso_gm_alvorada uuid := '86d06052-d21d-4e2e-b7ef-d6cfab169185';
  v_curso_brigada uuid := '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4';
  v_curso_invalido uuid := '00000000-0000-0000-0000-000000000000';
  v_resultado boolean;
  v_total_perfis integer;
  v_total_matriculas integer;
  v_total_configuracoes integer;
  v_curso_ativo uuid;
  v_matricula_id uuid;
  v_horas_diarias numeric;
  v_erro text;
BEGIN
  -- --------------------------------------------------------------------------
  -- PRECONDIÇÃO: usuário de teste realmente sem perfil e sem matrícula
  -- --------------------------------------------------------------------------
  IF EXISTS (SELECT 1 FROM public.perfis WHERE usuario_id = v_usuario_teste) THEN
    RAISE EXCEPTION 'Precondição falhou: usuário de teste já possui perfil antes do cenário 1 — escolha outro usuário de teste';
  END IF;
  IF EXISTS (SELECT 1 FROM public.matriculas WHERE usuario_id = v_usuario_teste) THEN
    RAISE EXCEPTION 'Precondição falhou: usuário de teste já possui matrícula antes do cenário 1 — escolha outro usuário de teste';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.cursos WHERE id = v_curso_gm_alvorada AND slug = 'gm-alvorada' AND publicado = true) THEN
    RAISE EXCEPTION 'Precondição falhou: curso gm-alvorada não encontrado/publicado com o id esperado';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.cursos WHERE id = v_curso_brigada AND slug = 'brigada-militar-rs' AND publicado = true) THEN
    RAISE EXCEPTION 'Precondição falhou: curso brigada-militar-rs não encontrado/publicado com o id esperado';
  END IF;

  -- Simula o usuário de teste autenticado para o restante da transação
  PERFORM set_config('request.jwt.claim.sub', v_usuario_teste::text, true);

  -- --------------------------------------------------------------------------
  -- CENÁRIO 1: usuário sem perfil e sem matrícula, escolhe 3 horas
  -- Espera-se: RPC executa, cria perfil, cria matrícula ativa, define curso
  -- ativo, cria configuracoes_estudo com horas_diarias = 3
  -- --------------------------------------------------------------------------
  SELECT public.configurar_curso_usuario(v_curso_gm_alvorada, 3) INTO v_resultado;

  IF v_resultado IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'Cenário 1 falhou: RPC não retornou true';
  END IF;

  SELECT count(*) INTO v_total_perfis FROM public.perfis WHERE usuario_id = v_usuario_teste;
  IF v_total_perfis <> 1 THEN
    RAISE EXCEPTION 'Cenário 1 falhou: perfil não foi criado (esperado 1, obtido %)', v_total_perfis;
  END IF;

  SELECT id INTO v_matricula_id
    FROM public.matriculas
   WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada AND status = 'ativa';
  IF v_matricula_id IS NULL THEN
    RAISE EXCEPTION 'Cenário 1 falhou: matrícula ativa não foi criada';
  END IF;

  SELECT curso_ativo_id INTO v_curso_ativo FROM public.perfis WHERE usuario_id = v_usuario_teste;
  IF v_curso_ativo IS DISTINCT FROM v_curso_gm_alvorada THEN
    RAISE EXCEPTION 'Cenário 1 falhou: curso_ativo_id não foi definido corretamente (esperado %, obtido %)', v_curso_gm_alvorada, v_curso_ativo;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.objetivos
     WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada
  ) THEN
    RAISE EXCEPTION 'Cenário 1 falhou: nenhuma linha de objetivos foi criada';
  END IF;

  SELECT count(*), max(horas_diarias) INTO v_total_configuracoes, v_horas_diarias
    FROM public.configuracoes_estudo
   WHERE matricula_id = v_matricula_id;
  IF v_total_configuracoes <> 1 THEN
    RAISE EXCEPTION 'Cenário 1 falhou: configuracoes_estudo não foi criada (esperado 1 linha, obtido %)', v_total_configuracoes;
  END IF;
  IF v_horas_diarias IS DISTINCT FROM 3 THEN
    RAISE EXCEPTION 'Cenário 1 falhou: horas_diarias em configuracoes_estudo incorreto (esperado 3, obtido %)', v_horas_diarias;
  END IF;

  RAISE NOTICE 'Cenário 1 (usuário novo, 3h: perfil + matrícula + curso ativo + objetivos + configuracoes_estudo) passou.';

  -- --------------------------------------------------------------------------
  -- CENÁRIO 2: chamada duplicada — mesmo curso, mesmas 3 horas, de novo
  -- Espera-se: sucesso, sem duplicar perfil, matrícula nem configuracoes_estudo
  -- --------------------------------------------------------------------------
  SELECT public.configurar_curso_usuario(v_curso_gm_alvorada, 3) INTO v_resultado;

  IF v_resultado IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'Cenário 2 falhou: RPC não retornou true na chamada duplicada';
  END IF;

  SELECT count(*) INTO v_total_matriculas
    FROM public.matriculas
   WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada;
  IF v_total_matriculas <> 1 THEN
    RAISE EXCEPTION 'Cenário 2 falhou: matrícula foi duplicada (esperado 1 linha total, obtido %)', v_total_matriculas;
  END IF;

  SELECT count(*) INTO v_total_perfis FROM public.perfis WHERE usuario_id = v_usuario_teste;
  IF v_total_perfis <> 1 THEN
    RAISE EXCEPTION 'Cenário 2 falhou: perfil foi duplicado (esperado 1, obtido %)', v_total_perfis;
  END IF;

  SELECT count(*), max(horas_diarias) INTO v_total_configuracoes, v_horas_diarias
    FROM public.configuracoes_estudo
   WHERE matricula_id = v_matricula_id;
  IF v_total_configuracoes <> 1 THEN
    RAISE EXCEPTION 'Cenário 2 falhou: configuracoes_estudo foi duplicada (esperado 1 linha, obtido %)', v_total_configuracoes;
  END IF;
  IF v_horas_diarias IS DISTINCT FROM 3 THEN
    RAISE EXCEPTION 'Cenário 2 falhou: horas_diarias mudou indevidamente na chamada duplicada (esperado continuar 3, obtido %)', v_horas_diarias;
  END IF;

  RAISE NOTICE 'Cenário 2 (chamada duplicada / idempotência, incluindo configuracoes_estudo) passou.';

  -- --------------------------------------------------------------------------
  -- CENÁRIO 3: curso inválido — deve falhar e não persistir nada além do
  -- que já existia dos cenários 1/2
  -- --------------------------------------------------------------------------
  BEGIN
    PERFORM public.configurar_curso_usuario(v_curso_invalido, 3);
    RAISE EXCEPTION 'Cenário 3 falhou: RPC deveria ter levantado exceção para curso inválido, mas não levantou';
  EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_erro = MESSAGE_TEXT;
      IF v_erro NOT ILIKE '%Curso inválido ou indisponível%' THEN
        RAISE EXCEPTION 'Cenário 3 falhou: mensagem de erro inesperada: %', v_erro;
      END IF;
  END;

  SELECT count(*) INTO v_total_matriculas FROM public.matriculas WHERE usuario_id = v_usuario_teste;
  IF v_total_matriculas <> 1 THEN
    RAISE EXCEPTION 'Cenário 3 falhou: número de matrículas do usuário mudou após falha esperada (esperado continuar 1, obtido %)', v_total_matriculas;
  END IF;

  SELECT curso_ativo_id INTO v_curso_ativo FROM public.perfis WHERE usuario_id = v_usuario_teste;
  IF v_curso_ativo IS DISTINCT FROM v_curso_gm_alvorada THEN
    RAISE EXCEPTION 'Cenário 3 falhou: curso_ativo_id foi alterado indevidamente após falha esperada';
  END IF;

  SELECT count(*) INTO v_total_configuracoes FROM public.configuracoes_estudo WHERE matricula_id = v_matricula_id;
  IF v_total_configuracoes <> 1 THEN
    RAISE EXCEPTION 'Cenário 3 falhou: número de linhas em configuracoes_estudo mudou após falha esperada (esperado continuar 1, obtido %)', v_total_configuracoes;
  END IF;

  RAISE NOTICE 'Cenário 3 (curso inválido) passou — rollback completo do cenário confirmado, incluindo configuracoes_estudo.';

  -- --------------------------------------------------------------------------
  -- CENÁRIO 4: horas_diarias inválidas (fora de 0.5–16) — deve falhar e não
  -- persistir nada
  -- --------------------------------------------------------------------------
  BEGIN
    PERFORM public.configurar_curso_usuario(v_curso_brigada, 20);
    RAISE EXCEPTION 'Cenário 4 falhou: RPC deveria ter levantado exceção para horas_diarias inválidas, mas não levantou';
  EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS v_erro = MESSAGE_TEXT;
      IF v_erro NOT ILIKE '%Disponibilidade diária inválida%' THEN
        RAISE EXCEPTION 'Cenário 4 falhou: mensagem de erro inesperada: %', v_erro;
      END IF;
  END;

  SELECT count(*) INTO v_total_matriculas
    FROM public.matriculas
   WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_brigada;
  IF v_total_matriculas <> 0 THEN
    RAISE EXCEPTION 'Cenário 4 falhou: matrícula de brigada-militar-rs foi criada indevidamente após falha esperada';
  END IF;

  SELECT curso_ativo_id INTO v_curso_ativo FROM public.perfis WHERE usuario_id = v_usuario_teste;
  IF v_curso_ativo IS DISTINCT FROM v_curso_gm_alvorada THEN
    RAISE EXCEPTION 'Cenário 4 falhou: curso_ativo_id foi alterado indevidamente após falha esperada (deveria continuar gm-alvorada)';
  END IF;

  SELECT count(*) INTO v_total_configuracoes FROM public.configuracoes_estudo WHERE matricula_id = v_matricula_id;
  IF v_total_configuracoes <> 1 THEN
    RAISE EXCEPTION 'Cenário 4 falhou: número de linhas em configuracoes_estudo mudou após falha esperada (esperado continuar 1, obtido %)', v_total_configuracoes;
  END IF;

  RAISE NOTICE 'Cenário 4 (horas_diarias inválidas) passou — rollback completo do cenário confirmado, incluindo configuracoes_estudo.';

  -- --------------------------------------------------------------------------
  -- CENÁRIO 5: objetivos continuam sendo criados pelo trigger de matriculas
  -- (matricula_cria_objetivo), e com o horas_diarias correto
  -- --------------------------------------------------------------------------
  IF NOT EXISTS (
    SELECT 1 FROM public.objetivos
     WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada AND horas_diarias = 3
  ) THEN
    RAISE EXCEPTION 'Cenário 5 falhou: horas_diarias em objetivos não reflete o valor passado à RPC (esperado 3)';
  END IF;

  RAISE NOTICE 'Cenário 5 (objetivos derivados pelo trigger, com horas_diarias correto) passou.';

  -- --------------------------------------------------------------------------
  -- CENÁRIO 6: aluno troca de 3h para 5h no mesmo curso já matriculado
  -- Espera-se: configuracoes_estudo é ATUALIZADA (mesma linha, mesmo
  -- matricula_id), não duplicada; matrícula continua única; objetivos
  -- também reflete o novo valor (efeito de sincronizar_cursos_beta)
  -- --------------------------------------------------------------------------
  SELECT public.configurar_curso_usuario(v_curso_gm_alvorada, 5) INTO v_resultado;

  IF v_resultado IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'Cenário 6 falhou: RPC não retornou true na troca de horas';
  END IF;

  SELECT count(*) INTO v_total_matriculas
    FROM public.matriculas
   WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada;
  IF v_total_matriculas <> 1 THEN
    RAISE EXCEPTION 'Cenário 6 falhou: matrícula foi duplicada ao trocar horas (esperado 1 linha total, obtido %)', v_total_matriculas;
  END IF;

  SELECT count(*), max(horas_diarias) INTO v_total_configuracoes, v_horas_diarias
    FROM public.configuracoes_estudo
   WHERE matricula_id = v_matricula_id;
  IF v_total_configuracoes <> 1 THEN
    RAISE EXCEPTION 'Cenário 6 falhou: configuracoes_estudo foi duplicada em vez de atualizada (esperado 1 linha, obtido %)', v_total_configuracoes;
  END IF;
  IF v_horas_diarias IS DISTINCT FROM 5 THEN
    RAISE EXCEPTION 'Cenário 6 falhou: horas_diarias em configuracoes_estudo não foi atualizado para 5 (obtido %)', v_horas_diarias;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.objetivos
     WHERE usuario_id = v_usuario_teste AND curso_id = v_curso_gm_alvorada AND horas_diarias = 5
  ) THEN
    RAISE EXCEPTION 'Cenário 6 falhou: horas_diarias em objetivos não foi atualizado para 5';
  END IF;

  RAISE NOTICE 'Cenário 6 (troca de 3h para 5h atualiza configuracoes_estudo sem duplicar) passou.';

  RAISE NOTICE 'TODOS OS CENÁRIOS DE TESTE DE configurar_curso_usuario PASSARAM COM SUCESSO!';
END $$;

ROLLBACK;
