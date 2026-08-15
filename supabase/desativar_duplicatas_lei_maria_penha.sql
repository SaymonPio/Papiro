-- Desativa logicamente as 3 duplicatas exatas confirmadas da Lei Maria da
-- Penha (curso_conteudos.id=53): 863, 864 e 865 — mantendo as canônicas
-- 129, 133 e 134. NÃO exclui nenhum registro (ativa=false, nunca DELETE).
--
-- Origem da decisão: B4+B5 de
-- diagnostico_pendencias_curadoria_lei_maria_penha.sql (duplicata exata de
-- enunciado) + diagnostico_uso_duplicatas_lei_maria_penha.sql (as 6
-- questões nunca foram respondidas, comentadas, planejadas em sessão,
-- erradas/revisadas ou classificadas em unidade — só 1 vínculo cada em
-- curso_questoes, todos para 7543be16-4c5b-4cb6-8724-8fbdfb96f2d4,
-- brigada-militar-rs).
--
-- Não mexe em unidades_pedagogicas, questao_unidades_pedagogicas,
-- curso_questoes, alternativas, nem em nenhuma outra questão além das 3
-- duplicatas.
--
-- Testado previamente (transação com ROLLBACK) em
-- supabase/desativar_duplicatas_lei_maria_penha_teste_rollback.sql —
-- confira tudo_ok=true lá antes de rodar este arquivo de verdade.
--
-- Endurecido em 2 camadas, nesta ordem:
--   1. PRÉ-VALIDAÇÃO explícita (RAISE EXCEPTION a qualquer divergência)
--      revalidando em produção, dentro desta mesma transação e ANTES de
--      qualquer escrita, todas as precondições já confirmadas no
--      diagnóstico — para cada duplicata: existe, ativa=true, materia_id=10,
--      assunto_id=19, 0 respostas_usuarios, 0 sessao_questoes_planejadas,
--      0 questao_comentarios, 0 erros_usuarios (via respostas_usuarios),
--      0 revisoes (via erros/respostas), 0 questao_unidades_pedagogicas,
--      exatamente 1 vínculo em curso_questoes com curso_id=
--      7543be16-4c5b-4cb6-8724-8fbdfb96f2d4 e prioridade=1; e para as 3
--      canônicas: existem e ativa=true. Qualquer divergência aborta a
--      transação inteira antes do UPDATE sequer rodar.
--   2. o UPDATE só afeta cada linha se id IN (863,864,865) E materia_id=10
--      E assunto_id=19 E ativa=true simultaneamente; GET DIAGNOSTICS
--      confere que afetou exatamente 3 linhas; qualquer divergência no
--      estado FINAL (nas 3 duplicatas OU nas 3 canônicas) também aborta com
--      RAISE EXCEPTION antes de qualquer commit.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

do $$
declare
  v_duplicatas constant bigint[] := array[863, 864, 865];
  v_canonicas constant bigint[] := array[129, 133, 134];
  v_materia_esperada constant bigint := 10;
  v_assunto_esperado constant bigint := 19;
  v_curso_esperado constant uuid := '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4';
  v_prioridade_esperada constant integer := 1;
  v_linhas_afetadas integer;
  v_id bigint;
  v_materia bigint;
  v_assunto bigint;
  v_ativa boolean;
  v_qtd_respostas integer;
  v_qtd_sessoes integer;
  v_qtd_comentarios integer;
  v_qtd_erros integer;
  v_qtd_revisoes integer;
  v_qtd_classificacoes integer;
  v_qtd_curso_questoes integer;
  v_curso_do_vinculo uuid;
  v_prioridade_do_vinculo integer;
  v_ativa_depois boolean;
  v_materia_depois bigint;
  v_assunto_depois bigint;
begin
  -- ==========================================================================
  -- LOCK: bloqueia as 6 linhas envolvidas (3 duplicatas + 3 canônicas) em
  -- public.questoes, em ordem determinística por id, ANTES de qualquer
  -- pré-validação — impede que outra transação concorrente altere o estado
  -- dessas questões durante a janela entre a validação e o UPDATE.
  -- ORDER BY id garante que os locks sejam adquiridos sempre na mesma
  -- ordem (evita deadlock com qualquer outra transação que também bloqueie
  -- estas linhas em ordem crescente de id). FOR UPDATE mantém o lock até o
  -- fim desta transação — liberado automaticamente no COMMIT ou ROLLBACK,
  -- sem nenhuma ação extra.
  -- ==========================================================================
  perform 1
  from public.questoes
  where id = any(v_duplicatas) or id = any(v_canonicas)
  order by id
  for update;

  -- ==========================================================================
  -- PRÉ-VALIDAÇÃO: revalida cada duplicata em produção, agora, dentro desta
  -- mesma transação — antes de qualquer escrita. Qualquer divergência aborta.
  -- ==========================================================================
  foreach v_id in array v_duplicatas loop
    select materia_id, assunto_id, ativa
    into v_materia, v_assunto, v_ativa
    from public.questoes
    where id = v_id;

    if not found then
      raise exception 'Abortado: questao % nao encontrada.', v_id;
    end if;
    if v_ativa is distinct from true then
      raise exception 'Abortado: questao % nao esta ativa=true (ativa=%).', v_id, v_ativa;
    end if;
    if v_materia is distinct from v_materia_esperada then
      raise exception 'Abortado: questao % tem materia_id=% (esperava %).', v_id, v_materia, v_materia_esperada;
    end if;
    if v_assunto is distinct from v_assunto_esperado then
      raise exception 'Abortado: questao % tem assunto_id=% (esperava %).', v_id, v_assunto, v_assunto_esperado;
    end if;

    select count(*) into v_qtd_respostas
    from public.respostas_usuarios where questao_id = v_id;
    if v_qtd_respostas <> 0 then
      raise exception 'Abortado: questao % possui % resposta(s) registrada(s) (esperava 0).', v_id, v_qtd_respostas;
    end if;

    select count(*) into v_qtd_sessoes
    from public.sessao_questoes_planejadas where questao_id = v_id;
    if v_qtd_sessoes <> 0 then
      raise exception 'Abortado: questao % possui % sessao(oes) planejada(s) (esperava 0).', v_id, v_qtd_sessoes;
    end if;

    select count(*) into v_qtd_comentarios
    from public.questao_comentarios where questao_id = v_id;
    if v_qtd_comentarios <> 0 then
      raise exception 'Abortado: questao % possui % comentario(s) (esperava 0).', v_id, v_qtd_comentarios;
    end if;

    select count(*) into v_qtd_erros
    from public.erros_usuarios eu
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    where ru.questao_id = v_id;
    if v_qtd_erros <> 0 then
      raise exception 'Abortado: questao % possui % erro(s) vinculado(s) via respostas_usuarios (esperava 0).', v_id, v_qtd_erros;
    end if;

    select count(*) into v_qtd_revisoes
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    where ru.questao_id = v_id;
    if v_qtd_revisoes <> 0 then
      raise exception 'Abortado: questao % possui % revisao(oes) vinculada(s) via erros/respostas (esperava 0).', v_id, v_qtd_revisoes;
    end if;

    select count(*) into v_qtd_classificacoes
    from public.questao_unidades_pedagogicas where questao_id = v_id;
    if v_qtd_classificacoes <> 0 then
      raise exception 'Abortado: questao % possui % classificacao(oes) em unidade pedagogica (esperava 0).', v_id, v_qtd_classificacoes;
    end if;

    select count(*) into v_qtd_curso_questoes
    from public.curso_questoes where questao_id = v_id;
    if v_qtd_curso_questoes <> 1 then
      raise exception 'Abortado: questao % possui % vinculo(s) em curso_questoes (esperava exatamente 1).', v_id, v_qtd_curso_questoes;
    end if;

    select curso_id, prioridade
    into v_curso_do_vinculo, v_prioridade_do_vinculo
    from public.curso_questoes
    where questao_id = v_id;

    if v_curso_do_vinculo is distinct from v_curso_esperado then
      raise exception 'Abortado: questao % vinculada ao curso % (esperava %).', v_id, v_curso_do_vinculo, v_curso_esperado;
    end if;
    if v_prioridade_do_vinculo is distinct from v_prioridade_esperada then
      raise exception 'Abortado: questao % tem prioridade=% em curso_questoes (esperava %).', v_id, v_prioridade_do_vinculo, v_prioridade_esperada;
    end if;
  end loop;

  -- Pré-validação das 3 canônicas: existem e continuam ativa=true.
  foreach v_id in array v_canonicas loop
    select ativa into v_ativa from public.questoes where id = v_id;
    if not found then
      raise exception 'Abortado: questao canonica % nao encontrada.', v_id;
    end if;
    if v_ativa is distinct from true then
      raise exception 'Abortado: questao canonica % nao esta ativa=true (ativa=%).', v_id, v_ativa;
    end if;
  end loop;

  -- ==========================================================================
  -- Só agora, com todas as precondições revalidadas, o UPDATE guardado.
  -- ==========================================================================
  update public.questoes
  set ativa = false
  where id = any(v_duplicatas)
    and materia_id = v_materia_esperada
    and assunto_id = v_assunto_esperado
    and ativa = true;

  get diagnostics v_linhas_afetadas = row_count;

  if v_linhas_afetadas <> 3 then
    raise exception 'Abortado: UPDATE afetou % linha(s) (esperava exatamente 3) para ids=%, materia_id=%, assunto_id=%, ativa=true — o estado no banco nao bate mais com o diagnosticado, confira antes de tentar de novo.',
      v_linhas_afetadas, v_duplicatas, v_materia_esperada, v_assunto_esperado;
  end if;

  -- Confirma, dentro do próprio bloco, o estado final das 3 duplicatas
  -- antes de deixar a transação seguir para o COMMIT.
  foreach v_id in array v_duplicatas loop
    select ativa, materia_id, assunto_id
    into v_ativa_depois, v_materia_depois, v_assunto_depois
    from public.questoes
    where id = v_id;

    if v_ativa_depois is distinct from false then
      raise exception 'Abortado: ativa da questao % nao ficou false (ativa=%).', v_id, v_ativa_depois;
    end if;
    if v_materia_depois is distinct from v_materia_esperada then
      raise exception 'Abortado: materia_id da questao % mudou inesperadamente para % (esperava %).', v_id, v_materia_depois, v_materia_esperada;
    end if;
    if v_assunto_depois is distinct from v_assunto_esperado then
      raise exception 'Abortado: assunto_id da questao % mudou inesperadamente para % (esperava %).', v_id, v_assunto_depois, v_assunto_esperado;
    end if;
  end loop;

  -- Confirma que as 3 canônicas continuam ativas (nunca tocadas pelo
  -- UPDATE acima, mas confere no próprio bloco antes do COMMIT mesmo assim).
  foreach v_id in array v_canonicas loop
    select ativa into v_ativa_depois from public.questoes where id = v_id;
    if coalesce(v_ativa_depois, false) is distinct from true then
      raise exception 'Abortado: questao canonica % nao esta mais ativa=true (ativa=%).', v_id, v_ativa_depois;
    end if;
  end loop;
end $$;

-- Conferência visual antes do COMMIT — só é alcançada se o bloco acima não
-- lançou nenhuma exception.
select id as questao_id, ativa, materia_id, assunto_id, enunciado
from public.questoes
where id in (863, 864, 865, 129, 133, 134)
order by id;

COMMIT;
