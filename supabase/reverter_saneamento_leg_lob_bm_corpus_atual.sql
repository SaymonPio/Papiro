-- REVERSAO REAL do SANEAMENTO LOB-BM (v2, com reclassificacao de
-- assunto_id de Q272). NUNCA executado automaticamente. Disponivel para
-- uso manual futuro caso o saneamento precise ser desfeito.
--
-- Restaura Q43/Q271 ao texto OLD (carregado programaticamente, self-
-- verificado contra o MD5 ja confirmado) e reverte Q272 na ordem inversa
-- da aplicacao: remove vinculo Seguranca publica -> UPDATE assunto_id
-- 17->72 (guardado) -> restaura vinculo LOB-BM. Guards abortam se o
-- estado atual nao bater com o esperado POS-apply.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _revert_lob_bm (
  questao_id bigint primary key,
  fingerprint_esperado text not null,
  explicacao_nova_esperada text not null,
  explicacao_old text not null,
  old_md5_esperado text not null
) on commit drop;

insert into _revert_lob_bm (questao_id, fingerprint_esperado, explicacao_nova_esperada, explicacao_old, old_md5_esperado) values
(43, '41f91d1830a7ff205ddc2f1fba5d50a7', $NOVA43$GABARITO: alternativa D

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
ATUAL: LC Estadual nº 16.450/2025, art. 10 — mesma competência, hoje disciplinada por essa lei sucessora.$NOVA43$, $OLD43$GABARITO: alternativa D

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
Função precípua de ASSESSORAMENTO DIRETO ao Comandante-Geral e coordenação do planejamento estratégico da corporação!$OLD43$, '57ad7247d333399042b0eed6b2c46315'),
(271, '7e07742db5a7fd43fd581c282068bb25', $NOVA271$GABARITO: alternativa A

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
Lei de Organização Básica da Brigada Militar (atualmente LC Estadual nº 16.450/2025, que revogou a Lei nº 10.991/97): disciplina a organização, a estrutura básica e o efetivo da Brigada Militar do Estado do Rio Grande do Sul.$NOVA271$, $OLD271$GABARITO: alternativa A

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
Estrutura e órgãos da BM: Comando-Geral, Estado-Maior, Órgãos de Direção, Execução (Batalhões/Comandos Regionais) e Apoio.$OLD271$, '250665a2494e1db78a7245b06532a035');

-- ================= GUARD =================
do $$
declare
  v_bad_fp int; v_bad_texto int;
  v_q272_id272 text; v_q272_assunto_id bigint;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
begin
  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _revert_lob_bm)
  )
  select count(*) filter (where atual.cur_fp <> r.fingerprint_esperado) into v_bad_fp
  from _revert_lob_bm r join atual on atual.id = r.questao_id;
  if v_bad_fp <> 0 then raise exception 'GUARD: fingerprint de Q43/Q271 divergente — abortando reversao'; end if;

  select count(*) filter (where q.explicacao is distinct from r.explicacao_nova_esperada) into v_bad_texto
  from _revert_lob_bm r join public.questoes q on q.id = r.questao_id;
  if v_bad_texto <> 0 then raise exception 'GUARD: explicacao de Q43/Q271 nao bate com a versao NOVA esperada — abortando reversao'; end if;

  select q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  if v_q272_assunto_id <> 17 then raise exception 'GUARD: Q272 assunto_id atual=% esperado 17 — abortando reversao', v_q272_assunto_id; end if;
  if v_q272_id272 <> '6422bdf0686092903e1222ae6645d585' then raise exception 'GUARD: identidade (sem assunto_id) de Q272 divergente — abortando reversao'; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  if v_q272_vinc_lob then raise exception 'GUARD: Q272 ja esta vinculada a LOB-BM — banco pode ja ter sido revertido'; end if;
  if not v_q272_vinc_segpub then raise exception 'GUARD: Q272 nao esta vinculada a Seguranca publica — estado inesperado, abortando'; end if;

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  if v_cq_id <> 307 or v_cq_prioridade <> 1 or v_cq_criado_em <> '2026-08-10 04:19:17.848316+00'::timestamptz then
    raise exception 'GUARD: curso_questoes de Q272 divergente do congelado — abortando reversao';
  end if;

  raise notice 'GUARD OK: fingerprint/texto de Q43,Q271 == versao nova esperada; Q272 assunto_id=17, identidade intacta, vinculo SegPub=1/LOB=0, curso_questoes congelada — prosseguindo';
end $$;

-- ================= REVERSAO =================
do $$
declare
  v_rows int;
begin
  update public.questoes q set explicacao = r.explicacao_old from _revert_lob_bm r where q.id = r.questao_id;
  get diagnostics v_rows = row_count;
  if v_rows <> 2 then raise exception 'REVERSAO explicacoes afetou % linha(s), esperado 2', v_rows; end if;
  raise notice 'REVERSAO: % explicacao(oes) restaurada(s) ao texto OLD (Q43, Q271)', v_rows;
end $$;

-- Q272, ordem inversa da aplicacao: remover SegPub -> assunto_id 17->72 -> restaurar LOB
do $$
begin
  perform public.remover_classificacao_questao_unidade_admin(272::bigint, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid);
  raise notice 'REVERSAO: Q272 removida de Seguranca publica';
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes set assunto_id = 72 where id = 272 and assunto_id = 17;
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then raise exception 'REVERSAO: UPDATE assunto_id de Q272 afetou % linha(s), esperado 1', v_rows; end if;
  raise notice 'REVERSAO: Q272 assunto_id restaurado de 17 para 72';
end $$;

do $$
begin
  perform public.classificar_questao_unidade_admin(272::bigint, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid);
  raise notice 'REVERSAO: Q272 reclassificada em LOB-BM';
end $$;

-- ================= POS-CHECK DA REVERSAO =================
do $$
declare
  v_bad_md5 int; v_bad_fp int;
  v_q272_vinc_lob boolean; v_q272_vinc_segpub boolean; v_q272_assunto_id bigint; v_q272_id272 text;
  v_cq_id bigint; v_cq_prioridade int; v_cq_criado_em timestamptz;
begin
  with atual as (
    select q.id, md5(coalesce(q.explicacao,'')) as cur_md5, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _revert_lob_bm)
  )
  select count(*) filter (where atual.cur_md5 <> r.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> r.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _revert_lob_bm r join atual on atual.id = r.questao_id;
  if v_bad_md5 <> 0 then raise exception 'POSCOND: Q43/Q271 nao bateram com OLD_MD5 apos reversao'; end if;
  if v_bad_fp  <> 0 then raise exception 'POSCOND: Q43/Q271 com fingerprint alterado apos reversao'; end if;

  select q.assunto_id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) into v_q272_assunto_id, v_q272_id272 from public.questoes q where q.id = 272;
  if v_q272_assunto_id <> 72 then raise exception 'POSCOND: Q272 assunto_id apos reversao=% esperado 72', v_q272_assunto_id; end if;
  if v_q272_id272 <> '6422bdf0686092903e1222ae6645d585' then raise exception 'POSCOND: identidade de Q272 mudou apos reversao'; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') into v_q272_vinc_lob;
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580') into v_q272_vinc_segpub;
  if not v_q272_vinc_lob then raise exception 'POSCOND: Q272 nao foi revinculada a LOB-BM'; end if;
  if v_q272_vinc_segpub then raise exception 'POSCOND: Q272 ainda vinculada a Seguranca publica'; end if;

  select cq.id, cq.prioridade, cq.criado_em into v_cq_id, v_cq_prioridade, v_cq_criado_em
  from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
  if v_cq_id <> 307 or v_cq_prioridade <> 1 or v_cq_criado_em <> '2026-08-10 04:19:17.848316+00'::timestamptz then
    raise exception 'POSCOND: curso_questoes de Q272 foi alterada pela reversao';
  end if;

  raise notice 'POSCONDICOES OK: Q43/Q271 restauradas ao OLD_MD5 original; Q272 assunto_id=72 (era 17), de volta em LOB-BM, curso_questoes intacta';
end $$;

commit;
