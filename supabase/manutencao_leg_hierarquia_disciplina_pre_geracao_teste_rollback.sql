-- TESTE DE ROLLBACK REAL da MANUTENCAO PRE-GERACAO — "Hierarquia e
-- disciplina" (Q12, Q45, Q53). Executa, dentro de UMA transacao
-- controlada que termina em ROLLBACK externo, a sequencia completa:
--   OLD (baseline) -> APPLY (mesma logica do apply real) -> TARGET (verifica)
--   -> REVERSAO REAL (mesma logica do reverter real) -> OLD (verifica)
-- Nao e um "BEGIN/UPDATE/ROLLBACK" simplificado: reproduz literalmente a
-- logica de apply e de reversao real, com os mesmos guards. Nenhuma linha
-- e alterada permanentemente — tudo e desfeito por ROLLBACK ao final.
--
-- Diferenca deliberada frente ao padrao anterior (manutencao DH global):
-- o texto OLD de cada explicacao NAO e retranscrito a mao neste arquivo.
-- E capturado ao vivo, byte-a-byte, direto da tabela _manut_leg_hd (via
-- "create table as select ... from public.questoes") ANTES do UPDATE de
-- apply rodar, dentro da mesma transacao — eliminando por construcao o
-- risco de divergencia de \r\n vs \n que uma retranscricao manual teria
-- introduzido (ja aconteceu nesta esteira do projeto com um corpo de
-- funcao RPC hand-typed; aqui a mesma classe de erro e estruturalmente
-- impossivel).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _manut_leg_hd (
  questao_id bigint primary key,
  old_md5_esperado text not null,
  fingerprint_esperado text not null,
  explicacao_nova text not null
) on commit drop;

insert into _manut_leg_hd (questao_id, old_md5_esperado, fingerprint_esperado, explicacao_nova) values
(12, '0f11ef29d8698d294dc61756ac1c3fca', '5766030d70c5eb854ed1dc1e9bcafbb9', $NEWQ12$GABARITO: alternativa A

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
HIERARQUIA e DISCIPLINA constituem a BASE INSTITUCIONAL da Brigada Militar!$NEWQ12$),
(45, '262518abdf858382ac891d45bfbb6764', 'b7d19133afcd0d822be03f59af088f97', $NEWQ45$GABARITO: alternativa B

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
Disciplina é o ACATAMENTO INTEGRAL das leis e regulamentos, devendo ser mantida inclusive pelos militares da RESERVA e REFORMADOS!$NEWQ45$),
(53, '98c0a2ac2b0a955151499698bc471211', '53fd9026ce63799f94c9299abbdb66aa', $NEWQ53$GABARITO: alternativa C

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
Juízes Militares do TJM/RS possuem estatuto próprio da magistratura, não se submetendo ao regime comum do estatuto militar estadual.$NEWQ53$);

-- Captura AO VIVO do texto OLD, byte-a-byte, direto da tabela — antes de
-- qualquer escrita. E este snapshot (nao um retranscrito a mao) que
-- alimenta a reversao real mais abaixo.
create temporary table _revert_leg_hd on commit drop as
select id as questao_id, explicacao as explicacao_old
from public.questoes where id in (12,45,53);

-- ===================== FASE OLD =====================
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
    from public.questoes q where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;

  insert into _relatorio values ('OLD','old_md5_3de3', v_bad_md5 = 0, (3-v_bad_md5)||'/3');
  insert into _relatorio values ('OLD','fingerprint_3de3', v_bad_fp = 0, (3-v_bad_fp)||'/3');

  insert into _relatorio values ('OLD','q12_gabarito_A',
    (select chr(64+ordem) from public.alternativas where questao_id=12 and correta=true) = 'A', 'gabarito');
  insert into _relatorio values ('OLD','q45_gabarito_B',
    (select chr(64+ordem) from public.alternativas where questao_id=45 and correta=true) = 'B', 'gabarito');
  insert into _relatorio values ('OLD','q53_gabarito_C',
    (select chr(64+ordem) from public.alternativas where questao_id=53 and correta=true) = 'C', 'gabarito');
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_leg_hd l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  insert into _relatorio values ('APPLY','rows_affected', v_rows = 3, v_rows::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_bad_fp int; v_bad_texto int;
  v_exp12 text; v_exp45 text; v_exp53 text;
begin
  with atual as (
    select q.id, md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;
  insert into _relatorio values ('TARGET','fingerprint_preservado_3de3', v_bad_fp = 0, (3-v_bad_fp)||'/3');

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_leg_hd l join public.questoes q on q.id = l.questao_id;
  insert into _relatorio values ('TARGET','explicacao_igual_ao_pretendido_3de3', v_bad_texto = 0, (3-v_bad_texto)||'/3');

  insert into _relatorio values ('TARGET','q12_gabarito_A',
    (select chr(64+ordem) from public.alternativas where questao_id=12 and correta=true) = 'A', 'gabarito');
  insert into _relatorio values ('TARGET','q45_gabarito_B',
    (select chr(64+ordem) from public.alternativas where questao_id=45 and correta=true) = 'B', 'gabarito');
  insert into _relatorio values ('TARGET','q53_gabarito_C',
    (select chr(64+ordem) from public.alternativas where questao_id=53 and correta=true) = 'C', 'gabarito');

  select explicacao into v_exp12 from public.questoes where id = 12;
  select explicacao into v_exp45 from public.questoes where id = 45;
  select explicacao into v_exp53 from public.questoes where id = 53;

  insert into _relatorio values ('TARGET','q12_fundamento_lc_art12caput',
    v_exp12 like '%Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997%', 'presente');
  insert into _relatorio values ('TARGET','q12_cf_como_pano_de_fundo',
    v_exp12 like '%arts. 42 e 142 da Constituição Federal%', 'presente');

  insert into _relatorio values ('TARGET','q45_sem_art13_disciplina', v_exp45 not like '%Artigo 13 da Lei Complementar%', 'ausente');
  insert into _relatorio values ('TARGET','q45_sem_art13_par1_reserva', v_exp45 not like '%Art. 13, §1º%', 'ausente');
  insert into _relatorio values ('TARGET','q45_sem_art16_circulos', v_exp45 not like '%Art. 16%', 'ausente');
  insert into _relatorio values ('TARGET','q45_sem_art14_precedencia', v_exp45 not like '%Art. 14%', 'ausente');
  insert into _relatorio values ('TARGET','q45_com_art12par2_disciplina', v_exp45 like '%Art. 12, §2º%', 'presente');
  insert into _relatorio values ('TARGET','q45_com_art12par1_hierarquia', v_exp45 like '%Art. 12, §1º%', 'presente');
  insert into _relatorio values ('TARGET','q45_com_art12par3_reserva', v_exp45 like '%Art. 12, §3º%', 'presente');
  insert into _relatorio values ('TARGET','q45_com_art13_circulos', v_exp45 like '%nos termos do Art. 13.%', 'presente');
  insert into _relatorio values ('TARGET','q45_com_art15_caput_2x',
    (select count(*) from regexp_matches(v_exp45, 'Art\. 15, caput', 'g')) = 2, 'ocorrencias');

  insert into _relatorio values ('TARGET','q53_sem_artigo14_alt_d', v_exp53 not like '%espelha o Artigo 14%', 'ausente');
  insert into _relatorio values ('TARGET','q53_com_artigo15caput_alt_d', v_exp53 like '%espelha o Artigo 15, caput, da LC nº 10.990/1997.%', 'presente');
  insert into _relatorio values ('TARGET','q53_alt_e_intocada',
    v_exp53 like '%consagra a precedência dos militares da ativa sobre os inativos (Art. 15).%', 'presente');
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
    from public.questoes q where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;

  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_leg_hd l join public.questoes q on q.id = l.questao_id;

  insert into _relatorio values ('REVERSAO_GUARD','fingerprint_pre_reversao_3de3', v_bad_fp = 0, (3-v_bad_fp)||'/3');
  insert into _relatorio values ('REVERSAO_GUARD','texto_target_pre_reversao_3de3', v_bad_texto = 0, (3-v_bad_texto)||'/3');

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
  from _revert_leg_hd r
  where q.id = r.questao_id;

  get diagnostics v_rows = row_count;
  insert into _relatorio values ('REVERSAO','rows_affected', v_rows = 3, v_rows::text);
end $$;

-- ===================== FASE OLD (novamente, pos-reversao) =====================
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
    from public.questoes q where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;

  insert into _relatorio values ('OLD_FINAL','old_md5_restaurado_3de3', v_bad_md5 = 0, (3-v_bad_md5)||'/3');
  insert into _relatorio values ('OLD_FINAL','fingerprint_preservado_3de3', v_bad_fp = 0, (3-v_bad_fp)||'/3');
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LEG_HIERARQUIA_DISCIPLINA_MANUTENCAO_ROLLBACK_APROVADA', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
