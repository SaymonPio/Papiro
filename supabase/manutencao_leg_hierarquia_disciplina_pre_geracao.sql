-- MANUTENCAO PRE-GERACAO — unidade "Hierarquia e disciplina" (Legislacao
-- Especifica, curso_conteudo_id=52, curso Brigada Militar RS).
--
-- EXATAMENTE 3 UPDATEs em public.questoes.explicacao (IDs 12, 45, 53).
-- Nenhum outro campo, nenhuma outra tabela. Enunciado, alternativas,
-- gabarito, origem, dificuldade, vinculos e curso_questoes das 3 questoes
-- NAO sao tocados — guardados por fingerprint estrutural antes/depois.
--
-- Motivo: as explicacoes de Q12, Q45 e Q53 citavam artigos da LC Estadual
-- RS no 10.990/1997 (arts. 12 a 16) com numeracao incorreta. A numeracao
-- canonica foi resolvida documentalmente (ver relatorio
-- "LEG — HIERARQUIA E DISCIPLINA — RESOLUCAO DOCUMENTAL", gate
-- LEG_HIERARQUIA_DISCIPLINA_BASE_NORMATIVA_CONGELADA) por convergencia de
-- multiplas buscas independentes, incluindo indexacao dos PDFs oficiais
-- (leitura byte-a-byte do PDF nao foi possivel neste ambiente — sem
-- poppler/pdftoppm — documentado no relatorio).
--
-- Mapeamento corrigido:
--   disciplina                        -> Art. 12, §2º
--   hierarquia                        -> Art. 12, §1º
--   extensao reserva/reformados       -> Art. 12, §3º
--   circulos hierarquicos             -> Art. 13
--   precedencia funcional             -> Art. 15, caput
--
-- Guardas: cada linha e protegida por OLD_MD5 (md5(explicacao) atual,
-- capturado ao vivo antes desta escrita) e por FINGERPRINT_IMUTAVEL amplo
-- (id, enunciado, dificuldade, materia_id, assunto_id, banca, concurso,
-- ano, vinculos de unidade e todas as alternativas com texto+correta) —
-- identico ao usado na manutencao global de DH. O pos-check compara o
-- texto final da explicacao DIRETAMENTE contra o literal pretendido
-- (nao contra um MD5 recalculado a mao) — mais robusto que comparar
-- hashes hand-typed, que ja causou divergencia de \r\n vs \n numa
-- esteira anterior deste projeto.
--
-- ROLLBACK-TESTADO em manutencao_leg_hierarquia_disciplina_pre_geracao_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_manutencao_leg_hierarquia_disciplina_pre_geracao.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

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

-- ================= PRECONDICOES =================
do $$
declare
  v_staging int; v_bad_md5 int; v_bad_fp int;
  v_alt12 int; v_gab12 text; v_alt45 int; v_gab45 text; v_alt53 int; v_gab53 text;
begin
  select count(*) into v_staging from _manut_leg_hd;
  if v_staging <> 3 then raise exception 'PRECOND: staging com % linhas, esperado exatamente 3', v_staging; end if;

  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then raise exception 'PRECOND: % questao(oes) com OLD_MD5 divergente do esperado — abortando', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'PRECOND: % questao(oes) com FINGERPRINT_IMUTAVEL divergente do esperado — abortando', v_bad_fp; end if;

  select count(*) into v_alt12 from public.alternativas where questao_id = 12;
  select chr(64+ordem) into v_gab12 from public.alternativas where questao_id = 12 and correta = true;
  if v_alt12 <> 4 then raise exception 'PRECOND: Q12 nao tem exatamente 4 alternativas (tem %)', v_alt12; end if;
  if v_gab12 <> 'A' then raise exception 'PRECOND: Q12 gabarito nao e A (e %)', v_gab12; end if;

  select count(*) into v_alt45 from public.alternativas where questao_id = 45;
  select chr(64+ordem) into v_gab45 from public.alternativas where questao_id = 45 and correta = true;
  if v_alt45 <> 5 then raise exception 'PRECOND: Q45 nao tem exatamente 5 alternativas (tem %)', v_alt45; end if;
  if v_gab45 <> 'B' then raise exception 'PRECOND: Q45 gabarito nao e B (e %)', v_gab45; end if;

  select count(*) into v_alt53 from public.alternativas where questao_id = 53;
  select chr(64+ordem) into v_gab53 from public.alternativas where questao_id = 53 and correta = true;
  if v_alt53 <> 5 then raise exception 'PRECOND: Q53 nao tem exatamente 5 alternativas (tem %)', v_alt53; end if;
  if v_gab53 <> 'C' then raise exception 'PRECOND: Q53 gabarito nao e C (e %)', v_gab53; end if;

  raise notice 'PRECONDICOES OK: 3/3 OLD_MD5, 3/3 FINGERPRINT_IMUTAVEL, gabaritos A/B/C confirmados (Q12/Q45/Q53)';
end $$;

-- ================= UPDATE (unico, guardado) =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_leg_hd l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 3 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 3 — abortando', v_rows;
  end if;
  raise notice 'UPDATE aplicado: % linha(s) afetada(s) em questoes.explicacao (IDs 12, 45, 53)', v_rows;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_bad_fp int; v_bad_texto int;
  v_gab12 text; v_gab45 text; v_gab53 text;
  v_exp12 text; v_exp45 text; v_exp53 text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes <> v_snap.total_questoes then raise exception 'POSCOND: total de questoes mudou (% -> %)', v_snap.total_questoes, v_questoes; end if;
  if v_alternativas <> v_snap.total_alternativas then raise exception 'POSCOND: total de alternativas mudou (% -> %)', v_snap.total_alternativas, v_alternativas; end if;
  if v_vinculos <> v_snap.total_vinculos then raise exception 'POSCOND: total de vinculos mudou (% -> %)', v_snap.total_vinculos, v_vinculos; end if;
  if v_curso_questoes <> v_snap.total_curso_questoes then raise exception 'POSCOND: total de curso_questoes mudou (% -> %)', v_snap.total_curso_questoes, v_curso_questoes; end if;

  -- fingerprint estrutural (enunciado/alternativas/gabarito/origem) preservado
  with atual as (
    select q.id,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _manut_leg_hd)
  )
  select count(*) filter (where atual.cur_fp <> l.fingerprint_esperado)
    into v_bad_fp
  from _manut_leg_hd l join atual on atual.id = l.questao_id;
  if v_bad_fp <> 0 then raise exception 'POSCOND: % questao(oes) com FINGERPRINT_IMUTAVEL alterado — enunciado/alternativas/gabarito/origem foram tocados', v_bad_fp; end if;

  -- texto final da explicacao comparado DIRETAMENTE contra o literal pretendido
  select count(*) filter (where q.explicacao is distinct from l.explicacao_nova)
    into v_bad_texto
  from _manut_leg_hd l join public.questoes q on q.id = l.questao_id;
  if v_bad_texto <> 0 then raise exception 'POSCOND: % explicacao(oes) nao bateram byte-a-byte com o texto pretendido — abortando commit', v_bad_texto; end if;

  select chr(64+ordem) into v_gab12 from public.alternativas where questao_id = 12 and correta = true;
  select chr(64+ordem) into v_gab45 from public.alternativas where questao_id = 45 and correta = true;
  select chr(64+ordem) into v_gab53 from public.alternativas where questao_id = 53 and correta = true;
  if v_gab12 <> 'A' then raise exception 'POSCOND: Q12 gabarito mudou (e %)', v_gab12; end if;
  if v_gab45 <> 'B' then raise exception 'POSCOND: Q45 gabarito mudou (e %)', v_gab45; end if;
  if v_gab53 <> 'C' then raise exception 'POSCOND: Q53 gabarito mudou (e %)', v_gab53; end if;

  select explicacao into v_exp12 from public.questoes where id = 12;
  select explicacao into v_exp45 from public.questoes where id = 45;
  select explicacao into v_exp53 from public.questoes where id = 53;

  if v_exp12 not like '%Art. 12, caput, da Lei Complementar Estadual RS nº 10.990/1997%' then
    raise exception 'POSCOND: Q12 nao contem o fundamento direto esperado (Art. 12, caput)';
  end if;
  if v_exp12 not like '%arts. 42 e 142 da Constituição Federal%' then
    raise exception 'POSCOND: Q12 perdeu a mencao da CF como pano de fundo';
  end if;

  if v_exp45 like '%Artigo 13 da Lei Complementar%' then raise exception 'POSCOND: Q45 ainda contem a citacao errada Art.13 para disciplina'; end if;
  if v_exp45 like '%Art. 13, §1º%' then raise exception 'POSCOND: Q45 ainda contem a citacao errada Art.13,§1º para reserva/reformados'; end if;
  if v_exp45 like '%Art. 16%' then raise exception 'POSCOND: Q45 ainda contem a citacao errada Art.16 para circulos'; end if;
  if v_exp45 like '%Art. 14%' then raise exception 'POSCOND: Q45 ainda contem a citacao errada Art.14 para precedencia funcional'; end if;
  if v_exp45 not like '%Art. 12, §2º%' then raise exception 'POSCOND: Q45 nao contem Art.12,§2º (disciplina)'; end if;
  if v_exp45 not like '%Art. 12, §1º%' then raise exception 'POSCOND: Q45 nao contem Art.12,§1º (hierarquia)'; end if;
  if v_exp45 not like '%Art. 12, §3º%' then raise exception 'POSCOND: Q45 nao contem Art.12,§3º (reserva/reformados)'; end if;
  if v_exp45 not like '%nos termos do Art. 13.%' then raise exception 'POSCOND: Q45 nao contem Art.13 (circulos hierarquicos)'; end if;
  if (select count(*) from regexp_matches(v_exp45, 'Art\. 15, caput', 'g')) <> 2 then
    raise exception 'POSCOND: Q45 nao contem exatamente 2 ocorrencias de Art.15,caput (precedencia funcional em A e E)';
  end if;

  if v_exp53 like '%espelha o Artigo 14%' then raise exception 'POSCOND: Q53 ainda contem a citacao errada Artigo 14 na alternativa D'; end if;
  if v_exp53 not like '%espelha o Artigo 15, caput, da LC nº 10.990/1997.%' then raise exception 'POSCOND: Q53 nao contem a citacao corrigida Artigo 15, caput na alternativa D'; end if;
  if v_exp53 not like '%consagra a precedência dos militares da ativa sobre os inativos (Art. 15).%' then
    raise exception 'POSCOND: Q53 alternativa E foi alterada indevidamente';
  end if;

  raise notice 'POSCONDICOES OK: globais inalterados, 3/3 FINGERPRINT_IMUTAVEL preservado, 3/3 explicacao = texto pretendido byte-a-byte, gabaritos A/B/C preservados, Q12 com fundamento LC art.12caput, Q45 com 5 citacoes corrigidas, Q53 alternativa D corrigida e alternativa E intocada';
end $$;

commit;
