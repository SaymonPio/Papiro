-- TESTE DE ROLLBACK REAL do SANEAMENTO LOB-BM (v2, com reclassificacao de
-- assunto_id de Q272). Executa, dentro de UMA transacao controlada que
-- termina em ROLLBACK externo, a sequencia completa: OLD -> APPLY ->
-- TARGET -> REVERSAO REAL -> OLD_FINAL. Nenhuma linha e alterada
-- permanentemente.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _manut_lob_bm (
  questao_id bigint primary key,
  old_md5_esperado text not null,
  fingerprint_esperado text not null,
  explicacao_nova text not null
) on commit drop;

insert into _manut_lob_bm (questao_id, old_md5_esperado, fingerprint_esperado, explicacao_nova) values
(43, '57ad7247d333399042b0eed6b2c46315', '41f91d1830a7ff205ddc2f1fba5d50a7', $NEWQ43$GABARITO: alternativa D

CONTEXTO HISTÓRICO (PROVA 2022):
À época da aplicação desta prova (Fundatec, 2022), a Lei Estadual RS nº 10.991/1997 (Lei de Organização Básica da Brigada Militar) estava vigente e era corretamente a norma testada pela questão.

CONTEXTO ATUAL:
A Lei nº 10.991/1997 foi posteriormente revogada pela Lei Complementar Estadual RS nº 16.450/2025 (art. 47), vigente desde 26/12/2025. Segundo a base documental já confirmada nesta auditoria, o art. 10 da LC nº 16.450/2025 mantém competência correspondente: compete ao Chefe do Estado-Maior assessorar o Comandante-Geral nos assuntos de ordem estratégica da Instituição e coordenar, em caráter geral, as atividades dos Órgãos do Nível de Direção Setorial.

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Tanto à época da prova (Lei nº 10.991/1997) quanto atualmente (art. 10 da LC nº 16.450/2025), assessorar o Comandante-Geral é competência do Chefe do Estado-Maior.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A apuração correcional disciplinar cabe precipuamente à Corregedoria-Geral da corporação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A elaboração e aprovação de regulamentos gerais é competência do Comandante-Geral e do Governador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribuição específica dos órgãos de controle e investigação correcional nos termos regimentais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Competência genérica que não expressa a função estrutural precípua de assessoria estratégica do Chefe do Estado-Maior.

BIZU DE PROVA:
PROVA 2022: Lei Estadual nº 10.991/1997 — Chefe do Estado-Maior assessora o Comandante-Geral.
ATUAL: LC Estadual nº 16.450/2025, art. 10 — mesma competência, hoje disciplinada por essa lei sucessora.$NEWQ43$),
(271, '250665a2494e1db78a7245b06532a035', '7e07742db5a7fd43fd581c282068bb25', $NEWQ271$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Lei de Organização Básica da Brigada Militar — atualmente a Lei Complementar Estadual RS nº 16.450/2025, que revogou a Lei Estadual nº 10.991/1997 — disciplina a organização, a estrutura básica e o efetivo da Brigada Militar do Estado do Rio Grande do Sul.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A organização do Poder Judiciário estadual é disciplinada pelo COJE (Código de Organização Judiciária).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As eleições são regidas pelo Código Eleitoral federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A matéria tributária é regida pelo Código Tributário do Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não rege segurança privada particular.

BIZU DE PROVA:
Lei de Organização Básica da Brigada Militar (atualmente LC Estadual nº 16.450/2025, que revogou a Lei nº 10.991/97): disciplina a organização, a estrutura básica e o efetivo da Brigada Militar do Estado do Rio Grande do Sul.$NEWQ271$);

-- ===================== FASE OLD =====================
do $$
declare
  v_bad_md5 int; v_bad_fp int;
  v_q272_id272 text; v_q272_ativa boolean; v_q272_assunto_id bigint;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
  v_respostas int; v_erros int; v_revisoes int;
begin
  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_lob_bm)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_lob_bm l join atual on atual.id = l.questao_id;
  insert into _relatorio values ('OLD','old_md5_2de2_q43_q271', v_bad_md5 = 0, (2-v_bad_md5)||'/2');
  insert into _relatorio values ('OLD','fingerprint_2de2_q43_q271', v_bad_fp = 0, (2-v_bad_fp)||'/2');
  insert into _relatorio values ('OLD','q43_gabarito_D', (select chr(64+ordem) from public.alternativas where questao_id=43 and correta=true) = 'D', 'gabarito');
  insert into _relatorio values ('OLD','q271_gabarito_A', (select chr(64+ordem) from public.alternativas where questao_id=271 and correta=true) = 'A', 'gabarito');

  select q.ativa, q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_ativa, v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  insert into _relatorio values ('OLD','q272_ativa', coalesce(v_q272_ativa,false), 'ativa');
  insert into _relatorio values ('OLD','q272_assunto_id_72', v_q272_assunto_id = 72, v_q272_assunto_id::text);
  insert into _relatorio values ('OLD','q272_identidade', v_q272_id272 = '6422bdf0686092903e1222ae6645d585', 'id272');

  select count(*) into v_respostas from public.respostas_usuarios where questao_id=272;
  select count(*) into v_erros from public.erros_usuarios where questao_id=272;
  select count(*) into v_revisoes from public.revisoes r join public.erros_usuarios eu on eu.id=r.erro_id where eu.questao_id=272;
  insert into _relatorio values ('OLD','q272_respostas_0', v_respostas = 0, v_respostas::text);
  insert into _relatorio values ('OLD','q272_erros_0', v_erros = 0, v_erros::text);
  insert into _relatorio values ('OLD','q272_revisoes_0', v_revisoes = 0, v_revisoes::text);

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  insert into _relatorio values ('OLD','q272_vinc_lob_true', v_q272_vinc_lob, 'vinculo LOB');
  insert into _relatorio values ('OLD','q272_vinc_segpub_false', not v_q272_vinc_segpub, 'sem vinculo SegPub');

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  insert into _relatorio values ('OLD','curso_questoes_congelada',
    v_cq_id = 307 and v_cq_prioridade = 1 and v_cq_criado_em = '2026-08-10 04:19:17.848316+00'::timestamptz, 'id/prioridade/criado_em');
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
do $$
declare
  v_rows int;
begin
  update public.questoes q set explicacao = l.explicacao_nova from _manut_lob_bm l where q.id = l.questao_id;
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('APPLY','explicacoes_atualizadas_2', v_rows = 2, v_rows::text);
end $$;

do $$
begin
  perform public.remover_classificacao_questao_unidade_admin(272::bigint, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid);
  insert into _relatorio values ('APPLY','q272_vinculo_lob_removido', true, 'RPC executada');
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes set assunto_id = 17 where id = 272 and assunto_id = 72;
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('APPLY','q272_assunto_id_atualizado', v_rows = 1, v_rows::text);
end $$;

do $$
begin
  perform public.classificar_questao_unidade_admin(272::bigint, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid);
  insert into _relatorio values ('APPLY','q272_vinculo_segpub_criado', true, 'RPC executada');
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_bad_texto int; v_bad_fp int;
  v_q272_id272 text; v_q272_assunto_id bigint;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean; v_q272_vinc_outra int;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
  v_vinculos_total int; v_curso_questoes_total int;
  v_snap record;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova) into v_bad_texto
  from _manut_lob_bm l join public.questoes q on q.id = l.questao_id;
  insert into _relatorio values ('TARGET','explicacao_igual_pretendido_2de2', v_bad_texto = 0, (2-v_bad_texto)||'/2');

  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_lob_bm)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado) into v_bad_fp
  from _manut_lob_bm l join atual on atual.id = l.questao_id;
  insert into _relatorio values ('TARGET','fingerprint_preservado_2de2', v_bad_fp = 0, (2-v_bad_fp)||'/2');
  insert into _relatorio values ('TARGET','q43_gabarito_D', (select chr(64+ordem) from public.alternativas where questao_id=43 and correta=true) = 'D', 'gabarito');
  insert into _relatorio values ('TARGET','q271_gabarito_A', (select chr(64+ordem) from public.alternativas where questao_id=271 and correta=true) = 'A', 'gabarito');

  select q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  insert into _relatorio values ('TARGET','q272_assunto_id_17', v_q272_assunto_id = 17, v_q272_assunto_id::text);
  insert into _relatorio values ('TARGET','q272_identidade_preservada', v_q272_id272 = '6422bdf0686092903e1222ae6645d585', 'id272');

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  select count(*) into v_q272_vinc_outra from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id not in ('3c033d9a-5543-422a-a935-c55095bdfc86','7cc8a187-da9b-457d-beeb-f496ddd32580');
  insert into _relatorio values ('TARGET','q272_vinc_lob_false', not v_q272_vinc_lob, 'sem vinculo LOB');
  insert into _relatorio values ('TARGET','q272_vinc_segpub_true', v_q272_vinc_segpub, 'vinculo SegPub');
  insert into _relatorio values ('TARGET','q272_sem_terceira_unidade', v_q272_vinc_outra = 0, v_q272_vinc_outra::text);

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  insert into _relatorio values ('TARGET','curso_questoes_intacta',
    v_cq_id = 307 and v_cq_prioridade = 1 and v_cq_criado_em = '2026-08-10 04:19:17.848316+00'::timestamptz, 'id/prioridade/criado_em');

  select count(*) into v_vinculos_total from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes_total from public.curso_questoes;
  insert into _relatorio values ('TARGET','vinculos_totais_inalterados', v_vinculos_total = v_snap.total_vinculos, v_vinculos_total::text);
  insert into _relatorio values ('TARGET','curso_questoes_totais_inalterados', v_curso_questoes_total = v_snap.total_curso_questoes, v_curso_questoes_total::text);
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real, ordem inversa) =====================
do $$
declare
  v_bad_fp int; v_bad_texto int;
  v_q272_vinc_segpub boolean; v_q272_assunto_id bigint;
begin
  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_lob_bm)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado) into v_bad_fp
  from _manut_lob_bm l join atual on atual.id = l.questao_id;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova) into v_bad_texto
  from _manut_lob_bm l join public.questoes q on q.id = l.questao_id;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  select assunto_id into v_q272_assunto_id from public.questoes where id = 272;

  insert into _relatorio values ('REVERSAO_GUARD','fingerprint_pre_reversao', v_bad_fp = 0, 'match');
  insert into _relatorio values ('REVERSAO_GUARD','texto_target_pre_reversao', v_bad_texto = 0, 'match');
  insert into _relatorio values ('REVERSAO_GUARD','q272_vinc_segpub_antes_reverter', v_q272_vinc_segpub, 'esperado true');
  insert into _relatorio values ('REVERSAO_GUARD','q272_assunto_id_17_antes_reverter', v_q272_assunto_id = 17, v_q272_assunto_id::text);

  if v_bad_fp <> 0 or v_bad_texto <> 0 or not v_q272_vinc_segpub or v_q272_assunto_id <> 17 then
    raise exception 'TESTE ABORTADO: guard pre-reversao falhou — nao reverter as cegas';
  end if;
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes q set explicacao = (select explicacao_old from (values
    (43, $OLDQ43$GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Nos termos da Lei Estadual RS nº 10.991/1997 (Lei de Organização Básica da Brigada Militar), o Estado-Maior é o órgão de direção geral responsável pelo planejamento estratégico e assessoramento superior, cabendo ao Chefe do Estado-Maior a competência direta de ASSESSORAR O COMANDANTE-GERAL em todas as atividades institucionais e operacionais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A apuração correcional disciplinar cabe precipuamente à Corregedoria-Geral da corporação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A elaboração e aprovação de regulamentos gerais é competência do Comandante-Geral e do Governador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribuição específica dos órgãos de controle e investigação correcional nos termos regimentais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Competência genérica que não expressa a função estrutural precípua de assessoria estratégica do Chefe do Estado-Maior.

BIZU DE PROVA:
Chefe do Estado-Maior da Brigada Militar (Lei Estadual nº 10.991/1997):
Função precípua de ASSESSORAMENTO DIRETO ao Comandante-Geral e coordenação do planejamento estratégico da corporação!$OLDQ43$),
    (271, $OLDQ271$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Lei de Organização Básica da Brigada Militar (Lei Estadual nº 10.991/1997 e alterações) disciplina a estrutura organizacional, a composição dos órgãos de direção, execução e apoio, o funcionamento institucional e as atribuições funcionais da Polícia Militar do Estado do Rio Grande do Sul.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A organização do Poder Judiciário estadual é disciplinada pelo COJE (Código de Organização Judiciária).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As eleições são regidas pelo Código Eleitoral federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A matéria tributária é regida pelo Código Tributário do Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não rege segurança privada particular.

BIZU DE PROVA:
Lei de Organização Básica da Brigada Militar (Lei nº 10.991/97):
Estrutura e órgãos da BM: Comando-Geral, Estado-Maior, Órgãos de Direção, Execução (Batalhões/Comandos Regionais) e Apoio.$OLDQ271$)
  ) as t(qid, explicacao_old) where t.qid = q.id)
  where q.id in (43, 271);
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('REVERSAO','explicacoes_restauradas_2', v_rows = 2, v_rows::text);
end $$;

-- reversao de Q272, ordem inversa da aplicacao: remover SegPub -> assunto_id 17->72 -> restaurar LOB
do $$
begin
  perform public.remover_classificacao_questao_unidade_admin(272::bigint, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid);
  insert into _relatorio values ('REVERSAO','q272_vinculo_segpub_removido', true, 'RPC executada');
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes set assunto_id = 72 where id = 272 and assunto_id = 17;
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('REVERSAO','q272_assunto_id_restaurado_72', v_rows = 1, v_rows::text);
end $$;

do $$
begin
  perform public.classificar_questao_unidade_admin(272::bigint, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid);
  insert into _relatorio values ('REVERSAO','q272_vinculo_lob_restaurado', true, 'RPC executada');
end $$;

-- ===================== FASE OLD_FINAL (pos-reversao) =====================
do $$
declare
  v_bad_md5 int; v_bad_fp int;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean; v_q272_assunto_id bigint; v_q272_id272 text;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
  v_vinculos_total int; v_curso_questoes_total int;
  v_snap record;
begin
  select * into v_snap from _snapshot_antes;

  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_lob_bm)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_lob_bm l join atual on atual.id = l.questao_id;
  insert into _relatorio values ('OLD_FINAL','old_md5_restaurado_2de2', v_bad_md5 = 0, (2-v_bad_md5)||'/2');
  insert into _relatorio values ('OLD_FINAL','fingerprint_preservado_2de2', v_bad_fp = 0, (2-v_bad_fp)||'/2');

  select q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  insert into _relatorio values ('OLD_FINAL','q272_assunto_id_72_restaurado', v_q272_assunto_id = 72, v_q272_assunto_id::text);
  insert into _relatorio values ('OLD_FINAL','q272_identidade_preservada', v_q272_id272 = '6422bdf0686092903e1222ae6645d585', 'id272');

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  insert into _relatorio values ('OLD_FINAL','q272_vinc_lob_restaurado', v_q272_vinc_lob, 'vinculo LOB');
  insert into _relatorio values ('OLD_FINAL','q272_vinc_segpub_removido', not v_q272_vinc_segpub, 'sem vinculo SegPub');

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  insert into _relatorio values ('OLD_FINAL','curso_questoes_intacta',
    v_cq_id = 307 and v_cq_prioridade = 1 and v_cq_criado_em = '2026-08-10 04:19:17.848316+00'::timestamptz, 'id/prioridade/criado_em');

  select count(*) into v_vinculos_total from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes_total from public.curso_questoes;
  insert into _relatorio values ('OLD_FINAL','vinculos_totais_restaurados', v_vinculos_total = v_snap.total_vinculos, v_vinculos_total::text);
  insert into _relatorio values ('OLD_FINAL','curso_questoes_totais_restaurados', v_curso_questoes_total = v_snap.total_curso_questoes, v_curso_questoes_total::text);
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LEG_LOB_BM_SANEAMENTO_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
