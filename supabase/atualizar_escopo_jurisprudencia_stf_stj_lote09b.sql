-- ATUALIZACAO DE ESCOPO (metadata pedagogico) — unidade "Jurisprudencia do
-- STF e STJ" (BM RS), Lote09B (mandato "HUMAN SOURCE SIGNOFF + EXPANSAO
-- CONTROLADA DO ESCOPO JURISPRUDENCIAL + GERACAO DAS 12 CANDIDATAS FINAIS").
--
-- Classificacao tecnica confirmada nesta rodada: UPDATE_CANONICAL_EXISTING_SCOPE
-- (NAO e schema change/migration — unidades_pedagogicas.artigos_esperados
-- ja e text[] comparado como strings opacas por avaliarValidacaoFonte;
-- unidades_pedagogicas.escopo ja e text livre). Apenas ADICIONA 5 novos
-- identificadores jurisprudenciais ao array existente e um paragrafo ao
-- escopo textual existente — os 6 artigos_esperados e o texto de escopo
-- ANTERIORES sao INTEGRALMENTE PRESERVADOS, nada e removido.
--
-- Precedentes adicionados (aprovados humanamente, Lote09B Secao 1):
-- STF ADPF 635/RJ; STF ADPF 347/DF; STF Tema 998 RG - ARE 959.620;
-- STF Sumula 145; STJ HC 653.515/RJ.
--
-- NAO toca: questoes, alternativas, questao_unidades_pedagogicas,
-- curso_questoes, matriculas, progresso, alunos, ou qualquer outra unidade.
-- Apenas 1 UPDATE de 1 linha em unidades_pedagogicas (2 colunas: escopo,
-- artigos_esperados).
--
-- ROLLBACK-TESTADO em atualizar_escopo_jurisprudencia_stf_stj_lote09b_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_escopo_jurisprudencia_stf_stj_lote09b.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old on commit drop as
select id, titulo, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

create temporary table _contagem_total_antes on commit drop as
select count(*) as total from public.unidades_pedagogicas;

create temporary table _hash_outras_linhas_antes on commit drop as
select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id)) as h
from public.unidades_pedagogicas
where id <> '8e1d1204-1f66-431c-a95f-6403e77882dc';

-- ================= PRECONDICOES =================
do $$
declare
  v_titulo text;
  v_qtd_artigos int;
  v_tem_novo boolean;
begin
  select titulo, array_length(artigos_esperados, 1) into v_titulo, v_qtd_artigos
  from public.unidades_pedagogicas where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

  if v_titulo is null then raise exception 'PRECOND: unidade nao encontrada'; end if;
  if v_titulo <> 'Jurisprudência do STF e STJ' then raise exception 'PRECOND: titulo inesperado: %', v_titulo; end if;
  if v_qtd_artigos <> 6 then raise exception 'PRECOND: esperado 6 artigos_esperados atuais, encontrado %', v_qtd_artigos; end if;

  select 'STF ADPF 635/RJ' = any(artigos_esperados) into v_tem_novo
  from public.unidades_pedagogicas where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';
  if v_tem_novo then raise exception 'PRECOND: precedente novo ja presente antes do apply — possivel reexecucao'; end if;

  raise notice 'PRECOND OK: unidade correta, 6 artigos_esperados atuais, nenhum dos 5 novos ja presente';
end $$;

-- ================= APPLY =================
update public.unidades_pedagogicas
set
  escopo = escopo || $ESCOPO_ADD$ Em complemento (Lote09B), o escopo desta unidade passa a incluir também: ADPF 635/RJ do STF ("ADPF das Favelas", julgamento em 03/04/2025) sobre parâmetros de redução da letalidade policial e uso da força em operações; ADPF 347/DF do STF sobre a obrigatoriedade de audiência de custódia em até 24 horas da prisão, em qualquer modalidade; Tema 998 de repercussão geral do STF (ARE 959.620/RS, tese fixada em 14/08/2025) sobre a inadmissibilidade de revista íntima vexatória de visitantes em estabelecimentos prisionais; Súmula 145 do STF, que distingue o flagrante preparado (crime impossível) do flagrante esperado; e o HC 653.515/RJ do STJ (Sexta Turma, julgado em 23/11/2021) sobre as consequências da quebra da cadeia de custódia da prova (arts. 158-A a 158-F do CPP).$ESCOPO_ADD$,
  artigos_esperados = artigos_esperados || ARRAY[
    'STF ADPF 635/RJ',
    'STF ADPF 347/DF',
    'STF Tema 998 RG - ARE 959.620',
    'STF Súmula 145',
    'STJ HC 653.515/RJ'
  ]
where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

-- ================= POSCONDICOES =================
do $$
declare
  v_qtd_artigos int;
  v_todos_antigos_presentes boolean;
  v_todos_novos_presentes boolean;
  v_sem_duplicata boolean;
  v_artigos text[];
begin
  select artigos_esperados into v_artigos
  from public.unidades_pedagogicas where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

  v_qtd_artigos := array_length(v_artigos, 1);
  if v_qtd_artigos <> 11 then raise exception 'POSCOND: esperado 11 artigos_esperados (6 antigos + 5 novos), encontrado %', v_qtd_artigos; end if;

  select
    'art. 5º, XI' = any(v_artigos) and 'art. 5º, LVII' = any(v_artigos) and
    'art. 39, §4º' = any(v_artigos) and 'art. 40, §4º-B' = any(v_artigos) and
    'art. 144, §9º' = any(v_artigos) and 'art. 283' = any(v_artigos)
  into v_todos_antigos_presentes;
  if not v_todos_antigos_presentes then raise exception 'POSCOND: um ou mais artigos_esperados antigos foram perdidos'; end if;

  select
    'STF ADPF 635/RJ' = any(v_artigos) and 'STF ADPF 347/DF' = any(v_artigos) and
    'STF Tema 998 RG - ARE 959.620' = any(v_artigos) and 'STF Súmula 145' = any(v_artigos) and
    'STJ HC 653.515/RJ' = any(v_artigos)
  into v_todos_novos_presentes;
  if not v_todos_novos_presentes then raise exception 'POSCOND: um ou mais precedentes novos nao foi adicionado corretamente'; end if;

  select (select count(*) from unnest(v_artigos) x) = (select count(distinct x) from unnest(v_artigos) x)
  into v_sem_duplicata;
  if not v_sem_duplicata then raise exception 'POSCOND: ha duplicacao textual em artigos_esperados'; end if;

  raise notice 'POSCOND OK: 11 artigos_esperados (6 antigos preservados + 5 novos adicionados), sem duplicatas';
end $$;

-- Confirma que NENHUMA outra linha/unidade foi tocada (nao ha coluna
-- updated_at nesta tabela, entao a verificacao e feita por contagem total
-- inalterada + hash de conteudo de todas as OUTRAS linhas inalterado).
do $$
declare
  v_total_depois int;
  v_total_antes int;
  v_hash_depois text;
  v_hash_antes text;
begin
  select total into v_total_antes from _contagem_total_antes;
  select count(*) into v_total_depois from public.unidades_pedagogicas;
  if v_total_depois <> v_total_antes then
    raise exception 'POSCOND: contagem total de unidades_pedagogicas mudou (antes=%, depois=%) — linha foi inserida ou removida', v_total_antes, v_total_depois;
  end if;

  select h into v_hash_antes from _hash_outras_linhas_antes;
  select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id))
  into v_hash_depois
  from public.unidades_pedagogicas
  where id <> '8e1d1204-1f66-431c-a95f-6403e77882dc';

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS linhas de unidades_pedagogicas mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'Checagem de nao-interferencia OK: contagem total inalterada (%), hash de todas as outras linhas identico ao snapshot anterior — apenas a linha alvo foi alterada', v_total_depois;
end $$;

commit;
