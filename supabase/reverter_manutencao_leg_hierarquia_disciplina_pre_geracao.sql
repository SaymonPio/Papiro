-- REVERSAO REAL da MANUTENCAO PRE-GERACAO — "Hierarquia e disciplina"
-- (Q12, Q45, Q53). NUNCA executado automaticamente. Disponivel para uso
-- manual futuro caso a manutencao precise ser desfeita.
--
-- Restaura, byte-a-byte, a explicacao ORIGINAL de cada questao — texto
-- carregado programaticamente de old_explicacoes_leg_hd_live.json
-- (capturado ao vivo do banco antes do apply, self-verificado contra o
-- MD5 ja confirmado — nunca retranscrito a mao neste arquivo).
--
-- Guards: aborta se o estado atual nao bater exatamente com o esperado
-- POS-apply (fingerprint estrutural + texto da explicacao == versao nova
-- pretendida) antes de reverter — nunca reverte as cegas.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _revert_leg_hd (
  questao_id bigint primary key,
  fingerprint_esperado text not null,
  explicacao_nova_esperada text not null,
  new_md5_esperado text not null,
  explicacao_old text not null,
  old_md5_esperado text not null
) on commit drop;

insert into _revert_leg_hd (questao_id, fingerprint_esperado, explicacao_nova_esperada, new_md5_esperado, explicacao_old, old_md5_esperado) values
(12, $FP12$5766030d70c5eb854ed1dc1e9bcafbb9$FP12$, $NOVA12$GABARITO: alternativa A

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
HIERARQUIA e DISCIPLINA constituem a BASE INSTITUCIONAL da Brigada Militar!$NOVA12$, $NMD512$2b076597a3dfcdee58664f20d2376341$NMD512$, $OLD12$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 42 e Artigo 142 da Constituição Federal e a legislação militar estadual, a HIERARQUIA e a DISCIPLINA constituem as bases institucionais permanentes das corporações militares do Estado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Hierarquia e disciplina são pilares inderrogáveis da ordem militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A subordinação funcional legal é obrigatória em todas as unidades militares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A hierarquia estrutura os postos e graduações na corporação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O cumprimento das leis e normas disciplinares é dever fundamental de todo militar.

BIZU DE PROVA:
Bases Constitucionais das Forças Militares:
HIERARQUIA e DISCIPLINA constituem os pilares da estrutura militar!$OLD12$, $OMD512$0f11ef29d8698d294dc61756ac1c3fca$OMD512$),
(45, $FP45$b7d19133afcd0d822be03f59af088f97$FP45$, $NOVA45$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa B reproduz textualmente o conceito legal de DISCIPLINA MILITAR contido no Art. 12, §2º, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais): "A disciplina militar é a rigorosa observância e o acatamento integral das leis, regulamentos, normas e disposições que fundamentam o organismo policial-militar e coordenam o seu funcionamento regular e harmônico, traduzindo-se pelo cumprimento do dever por parte de todos e de cada um dos seus componentes."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Art. 12, §1º, não define a hierarquia militar como uma ordenação "exclusivamente" por postos ou graduações: dentro de um mesmo posto ou graduação a ordenação se dá pela antiguidade, havendo ainda a precedência funcional do Comandante-Geral, do Subcomandante-Geral e do Chefe do Estado-Maior como exceção à regra geral de antiguidade (Art. 15, caput).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A disciplina e o respeito à hierarquia devem ser mantidos também na inatividade (reserva remunerada e reformados), por força da extensão prevista no Art. 12, §3º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Círculos hierárquicos são âmbitos de convivência entre militares da MESMA categoria (e não de categorias distintas), nos termos do Art. 13.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A antiguidade cede passo nos casos de precedência funcional do Comandante-Geral, do Subcomandante-Geral e do Chefe do Estado-Maior, conforme o Art. 15, caput.

BIZU DE PROVA:
Estatuto dos Militares do RS (LC 10.990/97):
Disciplina é o ACATAMENTO INTEGRAL das leis e regulamentos, devendo ser mantida inclusive pelos militares da RESERVA e REFORMADOS!$NOVA45$, $NMD545$a851fac9d449850388847b424a1f7204$NMD545$, $OLD45$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa B reproduz textualmente o conceito legal de DISCIPLINA MILITAR contido no Artigo 13 da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais): "A disciplina militar é a rigorosa observância e o acatamento integral das leis, regulamentos, normas e disposições que fundamentam o organismo policial-militar e coordenam o seu funcionamento regular e harmônico, traduzindo-se pelo cumprimento do dever por parte de todos e de cada um dos seus componentes."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A hierarquia militar não se faz "exclusivamente por postos ou graduações", havendo também a precedência funcional (Art. 12 da LC 10.990/97).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A disciplina e o respeito à hierarquia devem ser mantidos também na inatividade (reserva remunerada e reformados - Art. 13, §1º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Círculos hierárquicos são âmbitos de convivência entre militares da MESMA categoria (e não de categorias distintas - Art. 16).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A antiguidade cede passo nos casos de precedência funcional do Comandante-Geral, Subcomandante e Chefe do Estado-Maior (Art. 14, §1º).

BIZU DE PROVA:
Estatuto dos Militares do RS (LC 10.990/97):
Disciplina é o ACATAMENTO INTEGRAL das leis e regulamentos, devendo ser mantida inclusive pelos militares da RESERVA e REFORMADOS!$OLD45$, $OMD545$262518abdf858382ac891d45bfbb6764$OMD545$),
(53, $FP53$53fd9026ce63799f94c9299abbdb66aa$FP53$, $NOVA53$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C é a INCORRETA (gabarito) porque o Artigo 6º, parágrafo único, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais) prevê expressamente que os Oficiais nomeados Juízes do Tribunal Militar do Estado são regidos pela Lei de Organização Judiciária Militar e por legislação própria da magistratura, e NÃO pelas disposições gerais de hierarquia e disciplina do Estatuto dos Militares Estaduais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 2º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 5º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 15, caput, da LC nº 10.990/1997.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: consagra a precedência dos militares da ativa sobre os inativos (Art. 15).

BIZU DE PROVA:
Estatuto dos Militares do RS (LC nº 10.990/97):
Juízes Militares do TJM/RS possuem estatuto próprio da magistratura, não se submetendo ao regime comum do estatuto militar estadual.$NOVA53$, $NMD553$b04a9a4141a6644c5a13cd4bbf3a0880$NMD553$, $OLD53$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C é a INCORRETA (gabarito) porque o Artigo 6º, parágrafo único, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais) prevê expressamente que os Oficiais nomeados Juízes do Tribunal Militar do Estado são regidos pela Lei de Organização Judiciária Militar e por legislação própria da magistratura, e NÃO pelas disposições gerais de hierarquia e disciplina do Estatuto dos Militares Estaduais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 2º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 5º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 14 da LC nº 10.990/1997.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: consagra a precedência dos militares da ativa sobre os inativos (Art. 15).

BIZU DE PROVA:
Estatuto dos Militares do RS (LC nº 10.990/97):
Juízes Militares do TJM/RS possuem estatuto próprio da magistratura, não se submetendo ao regime comum do estatuto militar estadual.$OLD53$, $OMD553$98c0a2ac2b0a955151499698bc471211$OMD553$);

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
    from public.questoes q where q.id in (select questao_id from _revert_leg_hd)
  )
  select count(*) filter (where atual.cur_fp <> r.fingerprint_esperado)
    into v_bad_fp
  from _revert_leg_hd r join atual on atual.id = r.questao_id;
  if v_bad_fp <> 0 then raise exception 'GUARD: % questao(oes) com fingerprint estrutural divergente do esperado — abortando reversao', v_bad_fp; end if;

  select count(*) filter (where q.explicacao is distinct from r.explicacao_nova_esperada)
    into v_bad_texto
  from _revert_leg_hd r join public.questoes q on q.id = r.questao_id;
  if v_bad_texto <> 0 then raise exception 'GUARD: % explicacao(oes) nao batem com a versao NOVA esperada — banco pode ja ter sido alterado por outra esteira; abortando reversao', v_bad_texto; end if;

  raise notice 'GUARD OK: 3/3 fingerprint intacto, 3/3 explicacao == versao nova esperada — prosseguindo com a reversao';
end $$;

-- ================= REVERSAO =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = r.explicacao_old
  from _revert_leg_hd r
  where q.id = r.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 3 then raise exception 'REVERSAO afetou % linha(s), esperado exatamente 3 — abortando', v_rows; end if;
  raise notice 'REVERSAO aplicada: % linha(s) restauradas ao texto OLD original (IDs 12, 45, 53)', v_rows;
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
    from public.questoes q where q.id in (select questao_id from _revert_leg_hd)
  )
  select count(*) filter (where atual.cur_md5 <> r.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> r.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _revert_leg_hd r join atual on atual.id = r.questao_id;

  if v_bad_md5 <> 0 then raise exception 'POSCOND: % questao(oes) nao bateram com OLD_MD5 apos reversao', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'POSCOND: % questao(oes) com fingerprint alterado apos reversao', v_bad_fp; end if;

  raise notice 'POSCONDICOES OK: 3/3 explicacao restaurada ao OLD_MD5 original, 3/3 fingerprint preservado';
end $$;

commit;
