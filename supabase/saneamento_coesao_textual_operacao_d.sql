-- OPERACAO D — Remocao do vinculo pedagogico de Q684 no conteudo 22
-- (Classes de palavras, ja concluido), por ser DUPLICATA_EXATA_DE_Q319.
--
-- Q319 (conteudo 13, Coesao textual, assunto_id=55) e Q684 (conteudo 22,
-- Classes de palavras, assunto_id=47) sao a MESMA questao — enunciado,
-- alternativas (texto, ordem) e gabarito identicos byte a byte apos
-- normalizacao de aspas (confirmado por hash SHA-256 nesta auditoria).
-- Q319 foi definida como CANONICA (nativa do assunto/conteudo correto,
-- habilidade de referenciacao). Q684 permanece ATIVA e INTACTA (nenhuma
-- alteracao de enunciado/alternativas/gabarito/assunto_id/materia_id) —
-- apenas seu VINCULO PEDAGOGICO no conteudo 22 e removido, pois a mesma
-- questao nao deve ser usada como pratica em duas unidades diferentes.
--
-- Nao existe uma RPC administrativa para remover vinculo (apenas
-- classificar_questao_unidade_admin, que so insere). Como esta conexao
-- opera com privilegios que ja contornam RLS (mesma conexao usada em toda
-- a aplicacao deste pipeline), o DELETE e feito diretamente na tabela,
-- com pre/pos-condicoes endurecidas equivalentes as demais operacoes.
--
-- Nao existe tabela persistida "questoes_excluidas" — o registro da
-- exclusao de Q684 do conteudo 22 (motivo DUPLICATA_EXATA_DE_Q319) fica
-- documentado apenas nos arquivos de configuracao/relatorio deste
-- saneamento, nao em uma tabela do banco.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_unidade_atual uuid;
  v_conteudo_atual bigint;
  v_ativa boolean;
  v_alt_count int;
  v_alt_corretas int;
begin
  select qup.unidade_pedagogica_id into v_unidade_atual
  from public.questao_unidades_pedagogicas qup
  where qup.questao_id = 684;

  if v_unidade_atual is null then
    raise exception 'Precondicao falhou: questao 684 nao possui nenhum vinculo pedagogico — nada a remover';
  end if;
  if v_unidade_atual <> '3f215008-367b-4890-9588-525980baefc1' then
    raise exception 'Precondicao falhou: vinculo de Q684 aponta para unidade % (esperado 3f215008-367b-4890-9588-525980baefc1)', v_unidade_atual;
  end if;

  select u.curso_conteudo_id into v_conteudo_atual
  from public.unidades_pedagogicas u where u.id = v_unidade_atual;
  if v_conteudo_atual <> 22 then
    raise exception 'Precondicao falhou: vinculo de Q684 pertence ao conteudo % (esperado 22)', v_conteudo_atual;
  end if;

  select ativa into v_ativa from public.questoes where id = 684;
  if v_ativa is distinct from true then
    raise exception 'Precondicao falhou: questao 684 nao esta ativa=true';
  end if;

  select count(*), count(*) filter (where correta) into v_alt_count, v_alt_corretas
  from public.alternativas where questao_id = 684;
  if v_alt_count <> 5 or v_alt_corretas <> 1 then
    raise exception 'Precondicao falhou: questao 684 tem % alternativas (% corretas) — esperado 5 (1 correta)', v_alt_count, v_alt_corretas;
  end if;

  if not exists (select 1 from public.questoes where id = 319 and assunto_id = 55 and ativa = true) then
    raise exception 'Precondicao falhou: questao 319 (canonica) nao esta em estado esperado (ativa, assunto_id=55)';
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
 where questao_id = 684
   and unidade_pedagogica_id = '3f215008-367b-4890-9588-525980baefc1';

do $$
declare
  v_vinculos_684 int;
  v_ativa boolean;
  v_alt_count int;
  v_alt_corretas int;
  v_enunciado_len int;
begin
  select count(*) into v_vinculos_684 from public.questao_unidades_pedagogicas where questao_id = 684;
  if v_vinculos_684 <> 0 then
    raise exception 'Pos-condicao falhou: questao 684 ainda possui % vinculo(s) pedagogico(s) apos a remocao', v_vinculos_684;
  end if;

  select ativa into v_ativa from public.questoes where id = 684;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: questao 684 nao esta mais ativa=true';
  end if;

  select count(*), count(*) filter (where correta) into v_alt_count, v_alt_corretas
  from public.alternativas where questao_id = 684;
  if v_alt_count <> 5 or v_alt_corretas <> 1 then
    raise exception 'Pos-condicao falhou: alternativas da questao 684 mudaram (agora % / % corretas)', v_alt_count, v_alt_corretas;
  end if;

  select length(enunciado) into v_enunciado_len from public.questoes where id = 684;
  if v_enunciado_len is null or v_enunciado_len < 100 then
    raise exception 'Pos-condicao falhou: enunciado da questao 684 parece ter sido alterado/apagado';
  end if;

  if not exists (select 1 from public.questoes where id = 684 and assunto_id = 47 and materia_id = 6) then
    raise exception 'Pos-condicao falhou: assunto_id/materia_id da questao 684 mudaram inesperadamente';
  end if;

  -- Confirma que nenhum outro vinculo do conteudo 22 foi afetado.
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) <> 16 then
    raise exception 'Pos-condicao falhou: total de vinculos do conteudo 22 != 16 apos a remocao';
  end if;
end $$;

commit;
