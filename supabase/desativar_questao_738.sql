-- Desativa a questão 738: trata de violência doméstica contra criança e
-- adolescente (Lei 14.344/2022, Lei Henry Borel), fora do escopo do curso
-- da Brigada Militar (edital não cobre essa lei). Decisão de produto: não
-- criar assunto/conteúdo novo para ela — só desativar, para que pare de
-- aparecer como candidata na curadoria da Lei Maria da Penha e em qualquer
-- missão, sem apagar o registro nem alterar sua classificação atual
-- (materia_id=10, assunto_id=19 continuam os mesmos).
--
-- Não mexe em unidades_pedagogicas, questao_unidades_pedagogicas, nem em
-- nenhuma outra questão.
--
-- Testado previamente (transação com ROLLBACK) em
-- supabase/desativar_questao_738_teste_rollback.sql — 12/12 true,
-- tudo_ok=true.
--
-- Endurecido para só prosseguir se o banco ainda estiver EXATAMENTE no
-- estado diagnosticado: o UPDATE só afeta a linha se id=738 E materia_id=10
-- E assunto_id=19 E ativa=true simultaneamente; GET DIAGNOSTICS confere que
-- afetou exatamente 1 linha (nem 0 — já desativada/estado mudou — nem mais
-- de 1, o que aqui é impossível por chave primária, mas fica explícito);
-- qualquer divergência aborta com RAISE EXCEPTION antes de qualquer commit.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

do $$
declare
  v_questao_id constant bigint := 738;
  v_materia_esperada constant bigint := 10;
  v_assunto_esperado constant bigint := 19;
  v_linhas_afetadas integer;
  v_id_depois bigint;
  v_materia_depois bigint;
  v_assunto_depois bigint;
  v_ativa_depois boolean;
begin
  update public.questoes
  set ativa = false
  where id = v_questao_id
    and materia_id = v_materia_esperada
    and assunto_id = v_assunto_esperado
    and ativa = true;

  get diagnostics v_linhas_afetadas = row_count;

  if v_linhas_afetadas <> 1 then
    raise exception 'Abortado: UPDATE afetou % linha(s) (esperava exatamente 1) para questao_id=%, materia_id=%, assunto_id=%, ativa=true — o estado no banco nao bate mais com o diagnosticado, confira antes de tentar de novo.',
      v_linhas_afetadas, v_questao_id, v_materia_esperada, v_assunto_esperado;
  end if;

  -- Confirma, dentro do próprio bloco, o estado final da linha alterada
  -- antes de deixar a transação seguir para o COMMIT.
  select id, materia_id, assunto_id, ativa
  into v_id_depois, v_materia_depois, v_assunto_depois, v_ativa_depois
  from public.questoes
  where id = v_questao_id;

  if v_id_depois is distinct from v_questao_id then
    raise exception 'Abortado: id da questao mudou inesperadamente para %.', v_id_depois;
  end if;
  if v_materia_depois is distinct from v_materia_esperada then
    raise exception 'Abortado: materia_id da questao % mudou inesperadamente para % (esperava %).', v_questao_id, v_materia_depois, v_materia_esperada;
  end if;
  if v_assunto_depois is distinct from v_assunto_esperado then
    raise exception 'Abortado: assunto_id da questao % mudou inesperadamente para % (esperava %).', v_questao_id, v_assunto_depois, v_assunto_esperado;
  end if;
  if v_ativa_depois is distinct from false then
    raise exception 'Abortado: ativa da questao % nao ficou false (ativa=%).', v_questao_id, v_ativa_depois;
  end if;
end $$;

-- Conferência visual antes do COMMIT — só é alcançada se o bloco acima não
-- lançou nenhuma exception.
select id as questao_id, ativa, materia_id, assunto_id, enunciado
from public.questoes
where id = 738;

COMMIT;
