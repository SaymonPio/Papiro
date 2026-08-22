-- OPERACAO C — Correcao taxonomica de Q683: assunto_id 47 -> 55.
--
-- Q683 esta hoje classificada sob assunto_id=47 ("Classes de palavras"),
-- mas sua habilidade dominante e materialmente coesao referencial
-- (reiteracao lexical de "bem comum", anafora pronominal de "Ele"). Ela
-- foi excluida (nao vinculada) do conteudo 22 (Classes de palavras, ja
-- concluido) por FORA_DE_ESCOPO_REFERENCIA_TEXTUAL, e permanece hoje sem
-- nenhum vinculo pedagogico. O trigger questao_unidades_pedagogicas_valida
-- impede vincula-la a qualquer unidade do conteudo 13 (Coesao textual,
-- assunto_id=55) enquanto assunto_id=47 — por isso a correcao taxonomica
-- e pre-requisito para a classificacao pedagogica futura, nao uma decisao
-- estetica.
--
-- Nao existe tabela persistida "questoes_excluidas" no banco (e apenas um
-- conceito documentado nos arquivos de config/mapa.json do pipeline) —
-- portanto nao ha registro de exclusao em tabela a remover como parte
-- desta operacao; a documentacao da exclusao de Q683 no conteudo 22
-- permanece apenas no historico (classes_de_palavras.mapa.json), como
-- fato historico do que foi decidido naquela auditoria.
--
-- Altera SOMENTE o campo assunto_id de Q683. Nenhum outro campo
-- (enunciado, alternativas, gabarito, banca, concurso, ano, materia_id,
-- ativa) deve mudar. Nenhum vinculo pedagogico e criado ou removido por
-- esta operacao.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_assunto_atual bigint;
  v_materia_atual bigint;
  v_vinculos int;
  v_alt_count int;
  v_alt_corretas int;
  v_len int;
begin
  select assunto_id, materia_id into v_assunto_atual, v_materia_atual
  from public.questoes where id = 683;

  if v_assunto_atual is null then
    raise exception 'Precondicao falhou: questao 683 nao encontrada';
  end if;
  if v_assunto_atual <> 47 then
    raise exception 'Precondicao falhou: assunto_id atual da questao 683 = % (esperado 47)', v_assunto_atual;
  end if;
  if v_materia_atual <> 6 then
    raise exception 'Precondicao falhou: materia_id da questao 683 = % (esperado 6)', v_materia_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 683 and ativa = true) then
    raise exception 'Precondicao falhou: questao 683 nao esta ativa=true';
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 683;
  if v_vinculos <> 0 then
    raise exception 'Precondicao falhou: questao 683 ja possui % vinculo(s) pedagogico(s) — nao deveria ter nenhum antes da correcao taxonomica', v_vinculos;
  end if;

  select count(*), count(*) filter (where correta) into v_alt_count, v_alt_corretas
  from public.alternativas where questao_id = 683;
  if v_alt_count <> 5 or v_alt_corretas <> 1 then
    raise exception 'Precondicao falhou: questao 683 tem % alternativas (% corretas) — esperado 5 (1 correta)', v_alt_count, v_alt_corretas;
  end if;

  select length(enunciado) into v_len from public.questoes where id = 683;
  if v_len <> 4598 then
    raise exception 'Precondicao falhou: tamanho do enunciado da questao 683 = % (esperado 4598) — pode ter sido alterado por outra operacao', v_len;
  end if;

  if not exists (select 1 from public.assuntos where id = 55) then
    raise exception 'Precondicao falhou: assunto_id 55 (Coesao textual) nao existe';
  end if;
end $$;

update public.questoes
   set assunto_id = 55,
       atualizado_em = now()
 where id = 683;

do $$
declare
  v_assunto_depois bigint;
  v_vinculos int;
  v_alt_count int;
  v_alt_corretas int;
  v_len int;
  v_ativa boolean;
  v_banca text;
  v_ano int;
begin
  select assunto_id, ativa, banca, ano into v_assunto_depois, v_ativa, v_banca, v_ano
  from public.questoes where id = 683;

  if v_assunto_depois <> 55 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 683 = % (esperado 55)', v_assunto_depois;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: questao 683 nao esta mais ativa=true';
  end if;
  if v_banca <> 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 683 mudou inesperadamente para %', v_banca;
  end if;
  if v_ano <> 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 683 mudou inesperadamente para %', v_ano;
  end if;

  select length(enunciado) into v_len from public.questoes where id = 683;
  if v_len <> 4598 then
    raise exception 'Pos-condicao falhou: tamanho do enunciado da questao 683 mudou para % (esperado 4598) — enunciado nao deveria ser alterado por esta operacao', v_len;
  end if;

  select count(*), count(*) filter (where correta) into v_alt_count, v_alt_corretas
  from public.alternativas where questao_id = 683;
  if v_alt_count <> 5 or v_alt_corretas <> 1 then
    raise exception 'Pos-condicao falhou: alternativas da questao 683 mudaram (agora % / % corretas)', v_alt_count, v_alt_corretas;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 683;
  if v_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: questao 683 ganhou % vinculo(s) pedagogico(s) inesperado(s) nesta operacao', v_vinculos;
  end if;

  if not exists (select 1 from public.questoes where id = 683 and assunto_id = 55 and materia_id = 6) then
    raise exception 'Pos-condicao falhou: estado final inesperado para questao 683';
  end if;
end $$;

commit;
