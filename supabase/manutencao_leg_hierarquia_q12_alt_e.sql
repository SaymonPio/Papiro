-- MICROCORRECAO FINAL Q12 — remove o residuo editorial "ALTERNATIVA E"
-- da explicacao de Q12 (unidade "Hierarquia e disciplina"). Q12 so tem
-- 4 alternativas (A-D); a explicacao, herdada da manutencao anterior,
-- ainda continha um paragrafo "POR QUE A ALTERNATIVA E ESTA INCORRETA"
-- analisando uma 5a alternativa inexistente.
--
-- EXATAMENTE 1 UPDATE em public.questoes.explicacao (ID 12). Nenhum
-- outro campo, nenhuma outra tabela. Enunciado, 4 alternativas,
-- gabarito A, origem e o fundamento ja corrigido (Art. 12, caput, LC
-- 10.990/1997) permanecem intocados — a unica mudanca e a remocao do
-- paragrafo da alternativa E e da linha em branco que o precedia.
--
-- ROLLBACK-TESTADO em manutencao_leg_hierarquia_q12_alt_e_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_manutencao_leg_hierarquia_q12_alt_e.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _manut_q12_alt_e (
  questao_id bigint primary key,
  old_md5_esperado text not null,
  fingerprint_esperado text not null,
  explicacao_nova text not null
) on commit drop;

insert into _manut_q12_alt_e (questao_id, old_md5_esperado, fingerprint_esperado, explicacao_nova) values
(12, '2b076597a3dfcdee58664f20d2376341', '5766030d70c5eb854ed1dc1e9bcafbb9', $NEWQ12$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais), a HIERARQUIA e a DISCIPLINA constituem a base institucional da Brigada Militar, sendo que a autoridade e a responsabilidade crescem com o grau hierárquico. Os arts. 42 e 142 da Constituição Federal oferecem o pano de fundo constitucional desse mesmo princípio, mas o fundamento normativo direto e específico cobrado pela questão é o Estatuto Estadual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Hierarquia e disciplina são pilares inderrogáveis da ordem militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A subordinação funcional legal é obrigatória em todas as unidades militares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A hierarquia estrutura os postos e graduações na corporação.

BIZU DE PROVA:
Estatuto dos Militares Estaduais do RS (LC 10.990/97), Art. 12, caput:
HIERARQUIA e DISCIPLINA constituem a BASE INSTITUCIONAL da Brigada Militar!$NEWQ12$);

-- ================= PRECONDICOES =================
do $$
declare
  v_bad_md5 int; v_bad_fp int; v_alt int; v_gab text;
begin
  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id = 12
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_q12_alt_e l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then raise exception 'PRECOND: OLD_MD5 de Q12 divergente do esperado — abortando'; end if;
  if v_bad_fp  <> 0 then raise exception 'PRECOND: FINGERPRINT_IMUTAVEL de Q12 divergente do esperado — abortando'; end if;

  select count(*) into v_alt from public.alternativas where questao_id = 12;
  select chr(64+ordem) into v_gab from public.alternativas where questao_id = 12 and correta = true;
  if v_alt <> 4 then raise exception 'PRECOND: Q12 nao tem exatamente 4 alternativas (tem %)', v_alt; end if;
  if v_gab <> 'A' then raise exception 'PRECOND: Q12 gabarito nao e A (e %)', v_gab; end if;

  raise notice 'PRECONDICOES OK: OLD_MD5 confirmado, FINGERPRINT_IMUTAVEL confirmado, 4 alternativas, gabarito A';
end $$;

-- ================= UPDATE (unico, guardado) =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_q12_alt_e l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 1 — abortando', v_rows;
  end if;
  raise notice 'UPDATE aplicado: % linha afetada em questoes.explicacao (ID 12)', v_rows;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_bad_fp int; v_bad_texto int; v_alt int; v_gab text; v_exp text;
begin
  with atual as (
    select q.id,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id = 12
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_q12_alt_e l join atual on atual.id = l.questao_id;
  if v_bad_fp <> 0 then raise exception 'POSCOND: FINGERPRINT_IMUTAVEL de Q12 alterado — enunciado/alternativas/gabarito/origem foram tocados'; end if;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_q12_alt_e l join public.questoes q on q.id = l.questao_id;
  if v_bad_texto <> 0 then raise exception 'POSCOND: explicacao de Q12 nao bateu byte-a-byte com o texto pretendido — abortando commit'; end if;

  select count(*) into v_alt from public.alternativas where questao_id = 12;
  select chr(64+ordem) into v_gab from public.alternativas where questao_id = 12 and correta = true;
  if v_alt <> 4 then raise exception 'POSCOND: Q12 perdeu a contagem de 4 alternativas (tem %)', v_alt; end if;
  if v_gab <> 'A' then raise exception 'POSCOND: Q12 gabarito mudou (e %)', v_gab; end if;

  select explicacao into v_exp from public.questoes where id = 12;
  if v_exp like '%ALTERNATIVA E%' then raise exception 'POSCOND: ainda ha referencia a ALTERNATIVA E na explicacao de Q12'; end if;
  if v_exp not like '%Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997%' then
    raise exception 'POSCOND: Q12 perdeu o fundamento LC art.12 caput';
  end if;

  raise notice 'POSCONDICOES OK: FINGERPRINT_IMUTAVEL preservado, explicacao = texto pretendido byte-a-byte, 4 alternativas, gabarito A, 0 referencias a ALTERNATIVA E, fundamento LC art.12caput preservado';
end $$;

commit;
