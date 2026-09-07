-- TESTE DE ROLLBACK REAL da MICROCORRECAO FINAL Q12 (remocao do residuo
-- "ALTERNATIVA E"). Executa, dentro de UMA transacao controlada que
-- termina em ROLLBACK externo, a sequencia completa:
--   OLD (baseline, com residuo) -> APPLY -> TARGET (sem residuo, verifica)
--   -> REVERSAO REAL -> OLD (verifica, residuo restaurado)
-- O texto OLD (com o residuo) e capturado AO VIVO, byte-a-byte, direto
-- da tabela ANTES do UPDATE de apply rodar — nunca retranscrito a mao,
-- mesmo padrao ja usado na esteira anterior desta unidade.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

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

-- Captura AO VIVO do texto OLD (com o residuo), byte-a-byte, antes de
-- qualquer escrita — alimenta a reversao real mais abaixo.
create temporary table _revert_q12_alt_e on commit drop as
select id as questao_id, explicacao as explicacao_old
from public.questoes where id = 12;

-- ===================== FASE OLD =====================
do $$
declare
  v_bad_md5 int; v_bad_fp int; v_alt int; v_gab text; v_exp text;
begin
  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
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

  insert into _relatorio values ('OLD','old_md5', v_bad_md5 = 0, 'match');
  insert into _relatorio values ('OLD','fingerprint', v_bad_fp = 0, 'match');

  select count(*) into v_alt from public.alternativas where questao_id = 12;
  select chr(64+ordem) into v_gab from public.alternativas where questao_id = 12 and correta = true;
  insert into _relatorio values ('OLD','alternativas_4', v_alt = 4, v_alt::text);
  insert into _relatorio values ('OLD','gabarito_A', v_gab = 'A', v_gab);

  select explicacao into v_exp from public.questoes where id = 12;
  insert into _relatorio values ('OLD','residuo_alt_e_presente', v_exp like '%ALTERNATIVA E%', 'esperado=true');
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_q12_alt_e l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  insert into _relatorio values ('APPLY','rows_affected', v_rows = 1, v_rows::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_bad_fp int; v_bad_texto int; v_alt int; v_gab text; v_exp text;
begin
  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id = 12
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_q12_alt_e l join atual on atual.id = l.questao_id;
  insert into _relatorio values ('TARGET','fingerprint_preservado', v_bad_fp = 0, 'match');

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_q12_alt_e l join public.questoes q on q.id = l.questao_id;
  insert into _relatorio values ('TARGET','explicacao_igual_ao_pretendido', v_bad_texto = 0, 'match');

  select count(*) into v_alt from public.alternativas where questao_id = 12;
  select chr(64+ordem) into v_gab from public.alternativas where questao_id = 12 and correta = true;
  insert into _relatorio values ('TARGET','alternativas_4', v_alt = 4, v_alt::text);
  insert into _relatorio values ('TARGET','gabarito_A', v_gab = 'A', v_gab);

  select explicacao into v_exp from public.questoes where id = 12;
  insert into _relatorio values ('TARGET','residuo_alt_e_ausente', v_exp not like '%ALTERNATIVA E%', 'esperado=true');
  insert into _relatorio values ('TARGET','fundamento_art12caput_preservado',
    v_exp like '%Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997%', 'presente');
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_bad_fp int; v_bad_texto int;
begin
  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id = 12
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_q12_alt_e l join atual on atual.id = l.questao_id;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_q12_alt_e l join public.questoes q on q.id = l.questao_id;

  insert into _relatorio values ('REVERSAO_GUARD','fingerprint_pre_reversao', v_bad_fp = 0, 'match');
  insert into _relatorio values ('REVERSAO_GUARD','texto_target_pre_reversao', v_bad_texto = 0, 'match');

  if v_bad_fp <> 0 or v_bad_texto <> 0 then
    raise exception 'TESTE ABORTADO: guard pre-reversao falhou — nao reverter as cegas';
  end if;
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = r.explicacao_old
  from _revert_q12_alt_e r
  where q.id = r.questao_id;

  get diagnostics v_rows = row_count;
  insert into _relatorio values ('REVERSAO','rows_affected', v_rows = 1, v_rows::text);
end $$;

-- ===================== FASE OLD (novamente, pos-reversao) =====================
do $$
declare
  v_bad_md5 int; v_bad_fp int; v_exp text;
begin
  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
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

  insert into _relatorio values ('OLD_FINAL','old_md5_restaurado', v_bad_md5 = 0, 'match');
  insert into _relatorio values ('OLD_FINAL','fingerprint_preservado', v_bad_fp = 0, 'match');

  select explicacao into v_exp from public.questoes where id = 12;
  insert into _relatorio values ('OLD_FINAL','residuo_alt_e_restaurado', v_exp like '%ALTERNATIVA E%', 'esperado=true');
end $$;

-- ===================== RESUMO =====================
select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare
  v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LEG_HIERARQUIA_Q12_ALT_E_ROLLBACK_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
