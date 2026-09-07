-- SANEAMENTO TECNICO FINAL — LOB-BM (Q43, Q271, Q272), v2 — inclui
-- reclassificacao completa de assunto_id de Q272.
--
-- 2 UPDATEs em questoes.explicacao (Q43, Q271) + RECLASSIFICACAO COMPLETA
-- de Q272: (1) remove vinculo LOB-BM via RPC sancionada; (2) UPDATE
-- questoes.assunto_id 72->17, guardado (so 1 linha, so se assunto_id
-- atual = 72); (3) vincula a Seguranca publica via RPC sancionada — nessa
-- ordem exata, porque o trigger questao_unidades_pedagogicas_valida exige
-- que assunto_id ja esteja em 17 antes de aceitar o vinculo novo.
--
-- curso_questoes de Q272 (id=307, prioridade=1,
-- criado_em=2026-08-10 04:19:17.848316+00) e guardada como absolutamente imutavel —
-- nenhuma das 3 acoes a toca. questoes.atualizado_em de Q272 MUDA
-- legitimamente (efeito esperado do trigger questoes_atualizado_em) e nao
-- e guardado.
--
-- Precondicao adicional: Q272 tem 0 respostas_usuarios, 0 erros_usuarios,
-- 0 revisoes historicas — confirmado antes de reclassificar, exatamente
-- para nao deixar denormalizacao de assunto_id historica inconsistente.
--
-- NAO gera questoes. NAO altera enunciado/alternativas/gabarito de
-- nenhuma das 3. NAO usa INSERT/DELETE direto em
-- questao_unidades_pedagogicas.
--
-- ROLLBACK-TESTADO em sanear_leg_lob_bm_corpus_atual_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_saneamento_leg_lob_bm_corpus_atual.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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

-- ================= PRECONDICOES =================
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
  if v_bad_md5 <> 0 then raise exception 'PRECOND: % questao(oes) com OLD_MD5 divergente (Q43/Q271)', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'PRECOND: % questao(oes) com FINGERPRINT divergente (Q43/Q271)', v_bad_fp; end if;

  if (select chr(64+ordem) from public.alternativas where questao_id=43 and correta=true) <> 'D' then raise exception 'PRECOND: Q43 gabarito nao e D'; end if;
  if (select chr(64+ordem) from public.alternativas where questao_id=271 and correta=true) <> 'A' then raise exception 'PRECOND: Q271 gabarito nao e A'; end if;

  select q.ativa, q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_ativa, v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  if not coalesce(v_q272_ativa, false) then raise exception 'PRECOND: Q272 nao esta ativa'; end if;
  if v_q272_assunto_id <> 72 then raise exception 'PRECOND: Q272 assunto_id atual=% esperado 72', v_q272_assunto_id; end if;
  if v_q272_id272 <> '6422bdf0686092903e1222ae6645d585' then raise exception 'PRECOND: identidade (sem assunto_id) de Q272 divergente — algo alem do assunto_id foi alterado'; end if;

  select count(*) into v_respostas from public.respostas_usuarios where questao_id=272;
  select count(*) into v_erros from public.erros_usuarios where questao_id=272;
  select count(*) into v_revisoes from public.revisoes r join public.erros_usuarios eu on eu.id=r.erro_id where eu.questao_id=272;
  if v_respostas <> 0 then raise exception 'PRECOND: Q272 tem % resposta(s) historica(s) — revisar antes de reclassificar', v_respostas; end if;
  if v_erros <> 0 then raise exception 'PRECOND: Q272 tem % erro(s) historico(s) — revisar antes de reclassificar', v_erros; end if;
  if v_revisoes <> 0 then raise exception 'PRECOND: Q272 tem % revisao(oes) historica(s) — revisar antes de reclassificar', v_revisoes; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  if not v_q272_vinc_lob then raise exception 'PRECOND: Q272 nao esta vinculada a LOB-BM'; end if;
  if v_q272_vinc_segpub then raise exception 'PRECOND: Q272 ja esta vinculada a Seguranca publica — possivel reexecucao'; end if;

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  if v_cq_id <> 307 or v_cq_prioridade <> 1 or v_cq_criado_em <> '2026-08-10 04:19:17.848316+00'::timestamptz then
    raise exception 'PRECOND: curso_questoes de Q272 divergente do congelado (id=%, prioridade=%, criado_em=%)', v_cq_id, v_cq_prioridade, v_cq_criado_em;
  end if;

  raise notice 'PRECONDICOES OK: OLD_MD5/fingerprint de Q43,Q271 confirmados, gabaritos D/A confirmados, Q272 ativa/assunto_id=72/identidade preservada/0 respostas-erros-revisoes/vinculo LOB=1,SegPub=0/curso_questoes(id=307,prioridade=1) confirmados';
end $$;

-- ================= UPDATE explicacoes (Q43, Q271) =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_lob_bm l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 2 then raise exception 'UPDATE explicacoes afetou % linha(s), esperado exatamente 2', v_rows; end if;
  raise notice 'UPDATE aplicado: % linha(s) afetada(s) em questoes.explicacao (Q43, Q271)', v_rows;
end $$;

-- ================= RECLASSIFICACAO COMPLETA DE Q272 (ordem exata) =================
-- 1) remover vinculo LOB-BM (writer sancionado)
do $$
begin
  perform public.remover_classificacao_questao_unidade_admin(272::bigint, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid);
  raise notice 'Q272: vinculo LOB-BM removido';
end $$;

-- 2) UPDATE assunto_id 72 -> 17, guardado
do $$
declare
  v_rows int;
begin
  update public.questoes
  set assunto_id = 17
  where id = 272 and assunto_id = 72;

  get diagnostics v_rows = row_count;
  if v_rows <> 1 then raise exception 'UPDATE assunto_id de Q272 afetou % linha(s), esperado exatamente 1 (guard assunto_id=72 pode ter falhado)', v_rows; end if;
  raise notice 'Q272: assunto_id atualizado de 72 para 17';
end $$;

-- 3) vincular a Seguranca publica (writer sancionado — so passa porque assunto_id ja e 17)
do $$
begin
  perform public.classificar_questao_unidade_admin(272::bigint, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid);
  raise notice 'Q272: vinculada a Seguranca publica';
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_bad_texto int; v_bad_fp int;
  v_q272_id272 text; v_q272_assunto_id bigint;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean; v_q272_vinc_outra int;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
  v_snap record;
  v_vinculos_total int; v_curso_questoes_total int;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_lob_bm l join public.questoes q on q.id = l.questao_id;
  if v_bad_texto <> 0 then raise exception 'POSCOND: % explicacao(oes) nao bateram byte-a-byte com o texto pretendido (Q43/Q271)', v_bad_texto; end if;

  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_lob_bm)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado) into v_bad_fp
  from _manut_lob_bm l join atual on atual.id = l.questao_id;
  if v_bad_fp <> 0 then raise exception 'POSCOND: fingerprint de Q43/Q271 alterado — enunciado/alternativas/gabarito/origem foram tocados'; end if;

  if (select chr(64+ordem) from public.alternativas where questao_id=43 and correta=true) <> 'D' then raise exception 'POSCOND: Q43 gabarito mudou'; end if;
  if (select chr(64+ordem) from public.alternativas where questao_id=271 and correta=true) <> 'A' then raise exception 'POSCOND: Q271 gabarito mudou'; end if;

  select q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  if v_q272_assunto_id <> 17 then raise exception 'POSCOND: Q272 assunto_id=% esperado 17', v_q272_assunto_id; end if;
  if v_q272_id272 <> '6422bdf0686092903e1222ae6645d585' then raise exception 'POSCOND: identidade (sem assunto_id) de Q272 mudou — algo alem do assunto_id foi alterado indevidamente'; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  select count(*) into v_q272_vinc_outra from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id not in ('3c033d9a-5543-422a-a935-c55095bdfc86','7cc8a187-da9b-457d-beeb-f496ddd32580');
  if v_q272_vinc_lob then raise exception 'POSCOND: Q272 ainda vinculada a LOB-BM'; end if;
  if not v_q272_vinc_segpub then raise exception 'POSCOND: Q272 nao foi vinculada a Seguranca publica'; end if;
  if v_q272_vinc_outra <> 0 then raise exception 'POSCOND: Q272 tem vinculo em % unidade(s) alem de Seguranca publica', v_q272_vinc_outra; end if;

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  if v_cq_id <> 307 or v_cq_prioridade <> 1 or v_cq_criado_em <> '2026-08-10 04:19:17.848316+00'::timestamptz then
    raise exception 'POSCOND: curso_questoes de Q272 foi alterada (id=%, prioridade=%, criado_em=%) — esperado id=307,prioridade=1,criado_em=2026-08-10 04:19:17.848316+00', v_cq_id, v_cq_prioridade, v_cq_criado_em;
  end if;

  select count(*) into v_vinculos_total from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes_total from public.curso_questoes;
  if v_vinculos_total <> v_snap.total_vinculos then raise exception 'POSCOND: total global de vinculos mudou (% -> %), esperado igual (1 removido + 1 criado)', v_snap.total_vinculos, v_vinculos_total; end if;
  if v_curso_questoes_total <> v_snap.total_curso_questoes then raise exception 'POSCOND: total global de curso_questoes mudou (% -> %), esperado 0 delta', v_snap.total_curso_questoes, v_curso_questoes_total; end if;

  raise notice 'POSCONDICOES OK: Q43/Q271 explicacao=texto pretendido+fingerprint preservado+gabaritos D/A preservados; Q272 assunto_id=17 (era 72), identidade preservada, vinculo LOB=0/SegPub=1/nenhuma outra unidade, curso_questoes(id=307,prioridade=1,criado_em) intacta; totais globais de vinculos e curso_questoes inalterados';
end $$;

commit;
