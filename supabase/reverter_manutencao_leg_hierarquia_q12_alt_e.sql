-- REVERSAO REAL da MICROCORRECAO FINAL Q12 (remocao do residuo
-- "ALTERNATIVA E"). NUNCA executado automaticamente. Disponivel para uso
-- manual futuro caso a microcorrecao precise ser desfeita.
--
-- Restaura, byte-a-byte, a explicacao ORIGINAL (com o residuo) — texto
-- carregado programaticamente de old_explicacao_q12_alt_e_live.json
-- (capturado ao vivo do banco antes do apply, self-verificado contra o
-- MD5 ja confirmado — nunca retranscrito a mao neste arquivo).
--
-- Guards: aborta se o estado atual nao bater exatamente com o esperado
-- POS-apply (fingerprint estrutural + texto da explicacao == versao nova
-- pretendida) antes de reverter — nunca reverte as cegas.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _revert_q12_alt_e (
  questao_id bigint primary key,
  fingerprint_esperado text not null,
  explicacao_nova_esperada text not null,
  new_md5_esperado text not null,
  explicacao_old text not null,
  old_md5_esperado text not null
) on commit drop;

insert into _revert_q12_alt_e (questao_id, fingerprint_esperado, explicacao_nova_esperada, new_md5_esperado, explicacao_old, old_md5_esperado) values
(12, $FP12$5766030d70c5eb854ed1dc1e9bcafbb9$FP12$, $NOVA12$GABARITO: alternativa A

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
HIERARQUIA e DISCIPLINA constituem a BASE INSTITUCIONAL da Brigada Militar!$NOVA12$, $NMD512$ff9bbd30500a33bc5786e3a99a97da7a$NMD512$, $OLD12$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais), a HIERARQUIA e a DISCIPLINA constituem a base institucional da Brigada Militar, sendo que a autoridade e a responsabilidade crescem com o grau hierárquico. Os arts. 42 e 142 da Constituição Federal oferecem o pano de fundo constitucional desse mesmo princípio, mas o fundamento normativo direto e específico cobrado pela questão é o Estatuto Estadual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Hierarquia e disciplina são pilares inderrogáveis da ordem militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A subordinação funcional legal é obrigatória em todas as unidades militares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A hierarquia estrutura os postos e graduações na corporação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O cumprimento das leis e normas disciplinares é dever fundamental de todo militar.

BIZU DE PROVA:
Estatuto dos Militares Estaduais do RS (LC 10.990/97), Art. 12, caput:
HIERARQUIA e DISCIPLINA constituem a BASE INSTITUCIONAL da Brigada Militar!$OLD12$, $OMD512$2b076597a3dfcdee58664f20d2376341$OMD512$);

-- ================= GUARD: estado atual == pos-apply esperado =================
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
  select count(*) filter (where atual.cur_fp <> r.fingerprint_esperado)
    into v_bad_fp
  from _revert_q12_alt_e r join atual on atual.id = r.questao_id;
  if v_bad_fp <> 0 then raise exception 'GUARD: fingerprint estrutural de Q12 divergente do esperado — abortando reversao'; end if;

  select count(*) filter (where q.explicacao is distinct from r.explicacao_nova_esperada)
    into v_bad_texto
  from _revert_q12_alt_e r join public.questoes q on q.id = r.questao_id;
  if v_bad_texto <> 0 then raise exception 'GUARD: explicacao de Q12 nao bate com a versao NOVA esperada — banco pode ja ter sido alterado por outra esteira; abortando reversao'; end if;

  raise notice 'GUARD OK: fingerprint intacto, explicacao == versao nova esperada — prosseguindo com a reversao';
end $$;

-- ================= REVERSAO =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = r.explicacao_old
  from _revert_q12_alt_e r
  where q.id = r.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 1 then raise exception 'REVERSAO afetou % linha(s), esperado exatamente 1 — abortando', v_rows; end if;
  raise notice 'REVERSAO aplicada: % linha restaurada ao texto OLD original (ID 12, com o residuo ALTERNATIVA E de volta)', v_rows;
end $$;

-- ================= POS-CHECK DA REVERSAO =================
do $$
declare
  v_bad_md5 int; v_bad_fp int;
begin
  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id = 12
  )
  select count(*) filter (where atual.cur_md5 <> r.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> r.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _revert_q12_alt_e r join atual on atual.id = r.questao_id;

  if v_bad_md5 <> 0 then raise exception 'POSCOND: Q12 nao bateu com OLD_MD5 apos reversao'; end if;
  if v_bad_fp  <> 0 then raise exception 'POSCOND: Q12 com fingerprint alterado apos reversao'; end if;

  raise notice 'POSCONDICOES OK: explicacao de Q12 restaurada ao OLD_MD5 original, fingerprint preservado';
end $$;

commit;
