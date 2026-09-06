-- Manutencao pos-apply DH-AUT-05: correcao do campo explicacao das
-- questoes LIVE pre-existentes Q147/Q148/Q149 (cc90 - Casos do Brasil
-- na Corte Interamericana de Direitos Humanos), cujas explicacoes
-- estavam corrompidas com conteudo de outras questoes/unidades
-- (DUDH/dignidade em Q147; natureza da DUDH/jus cogens em Q148;
-- classificacao de sistemas regionais em Q149).
--
-- Escopo estritamente estreito: altera SOMENTE public.questoes.explicacao
-- das 3 linhas identificadas por id + guarda de hash md5 do texto atual.
-- Nenhum outro campo (enunciado, alternativas, ordem, gabarito,
-- dificuldade, banca, concurso, fonte, ano, materia_id, assunto_id,
-- gerada_por_ia, ativa) e vinculo em questao_unidades_pedagogicas e
-- tocado.
--
-- Mecanismo de idempotencia/seguranca: cada UPDATE so afeta a linha se
-- o hash md5 da explicacao atual bater exatamente com o hash auditado
-- na rodada de manutencao. Row count de cada UPDATE e verificado
-- individualmente via GET DIAGNOSTICS; qualquer divergencia aborta a
-- transacao inteira antes do COMMIT.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- precondicao: hashes atuais devem bater exatamente com os auditados
do $$
declare
  v_hash_147 text;
  v_hash_148 text;
  v_hash_149 text;
begin
  select md5(explicacao) into v_hash_147 from public.questoes where id = 147;
  select md5(explicacao) into v_hash_148 from public.questoes where id = 148;
  select md5(explicacao) into v_hash_149 from public.questoes where id = 149;

  if v_hash_147 is distinct from '0bfa34f847975f222a5c4aa5082d285e' then
    raise exception 'Abortado: Q147 explicacao atual nao confere com o hash auditado (drift) — hash encontrado: %', v_hash_147;
  end if;
  if v_hash_148 is distinct from '0f9e9581325cfca6559fe775ccfc3698' then
    raise exception 'Abortado: Q148 explicacao atual nao confere com o hash auditado (drift) — hash encontrado: %', v_hash_148;
  end if;
  if v_hash_149 is distinct from 'cb05a18d2e4480b81a13e985e1040795' then
    raise exception 'Abortado: Q149 explicacao atual nao confere com o hash auditado (drift) — hash encontrado: %', v_hash_149;
  end if;
end $$;

-- update Q147
do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\n\nO Caso Ximenes Lopes vs. Brasil foi julgado pela Corte Interamericana de Direitos Humanos, com sentença de 4 de julho de 2006, sendo a primeira condenação do Estado brasileiro perante esse tribunal. O caso tratou dos maus-tratos e da morte de Damião Ximenes Lopes durante internação em instituição psiquiátrica conveniada ao SUS, em Sobral, no Ceará.\n\nAs demais alternativas apresentam casos que não correspondem a julgamentos da Corte Interamericana de Direitos Humanos envolvendo o Brasil: Marbury v. Madison (1803) é precedente da Suprema Corte dos Estados Unidos sobre controle de constitucionalidade; Brown v. Board of Education (1954) é precedente da mesma Corte sobre segregação racial no ensino; Handyside vs. Reino Unido é precedente do Tribunal Europeu de Direitos Humanos, sistema regional distinto do interamericano; e o Caso Dreyfus refere-se a um episódio da justiça militar francesa do século XIX, sem relação com a jurisdição da Corte IDH.'
  where id = 147
    and md5(explicacao) = '0bfa34f847975f222a5c4aa5082d285e';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: update de Q147 afetou % linha(s), esperado exatamente 1', v_rows;
  end if;
end $$;

-- update Q148
do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\n\nO Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil foi julgado pela Corte Interamericana de Direitos Humanos, com sentença de 24 de novembro de 2010. A responsabilização internacional do Brasil esteve relacionada aos desaparecimentos forçados de integrantes da Guerrilha do Araguaia e ao dever estatal de investigar as graves violações de direitos humanos ocorridas nesse contexto.\n\nAs demais alternativas tratam de matérias estranhas ao caso: direito tributário municipal (B), liberdade econômica de empresas estatais (C), direitos autorais (D) e regras eleitorais municipais (E) não guardam relação com os fatos ou com o objeto central do Caso Gomes Lund.'
  where id = 148
    and md5(explicacao) = '0f9e9581325cfca6559fe775ccfc3698';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: update de Q148 afetou % linha(s), esperado exatamente 1', v_rows;
  end if;
end $$;

-- update Q149
do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\n\nO Caso Herzog e outros vs. Brasil foi julgado pela Corte Interamericana de Direitos Humanos, com sentença de 15 de março de 2018. O caso trata da detenção, da tortura e da morte do jornalista Vladimir Herzog em 1975, no interior das dependências do DOI-CODI, em São Paulo, durante o regime militar brasileiro (1964-1985).\n\nAs demais alternativas referem-se a outros períodos e episódios da história brasileira sem relação com os fatos do caso: a Guerra do Paraguai (1864-1870), a Revolução Farroupilha (1835-1845), a República Velha (1889-1930) e a vigência da Constituição de 1824 são anteriores ou estranhos ao contexto histórico em que ocorreram os fatos julgados no Caso Herzog.'
  where id = 149
    and md5(explicacao) = 'cb05a18d2e4480b81a13e985e1040795';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: update de Q149 afetou % linha(s), esperado exatamente 1', v_rows;
  end if;
end $$;

-- poscondicao: exatamente 3 questoes com os novos hashes, nenhuma a mais/a menos
do $$
declare
  v_cnt int;
  v_new_147 text;
  v_new_148 text;
  v_new_149 text;
begin
  select count(*) into v_cnt from public.questoes
  where id in (147,148,149)
    and md5(explicacao) in (
      'b0c2c84e52e2ca7bdcbed957467fda6e',
      '7ac4306a25cc846e97c80a4215a553fa',
      'd8dd965a249edbdd3f74e72919ed1fba'
    );
  if v_cnt <> 3 then
    raise exception 'Abortado: esperado exatamente 3 questoes com os novos hashes, encontrado %', v_cnt;
  end if;

  select md5(explicacao) into v_new_147 from public.questoes where id = 147;
  select md5(explicacao) into v_new_148 from public.questoes where id = 148;
  select md5(explicacao) into v_new_149 from public.questoes where id = 149;

  if v_new_147 <> 'b0c2c84e52e2ca7bdcbed957467fda6e' then
    raise exception 'Abortado: hash pos-update de Q147 nao confere: %', v_new_147;
  end if;
  if v_new_148 <> '7ac4306a25cc846e97c80a4215a553fa' then
    raise exception 'Abortado: hash pos-update de Q148 nao confere: %', v_new_148;
  end if;
  if v_new_149 <> 'd8dd965a249edbdd3f74e72919ed1fba' then
    raise exception 'Abortado: hash pos-update de Q149 nao confere: %', v_new_149;
  end if;
end $$;

commit;
