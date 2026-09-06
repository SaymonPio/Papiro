-- Reversao segura, POS-APPLY, da manutencao do campo explicacao de
-- Q147/Q148/Q149 (DH-AUT-05, cc90).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer a manutencao ja confirmada (commit) de
-- supabase/manutencao_dh_aut_05_cc90.sql, restaurando literalmente os
-- textos corrompidos que estavam em producao antes dessa manutencao.
--
-- Mecanismo de identificacao: cada UPDATE so afeta a linha se o hash
-- md5 da explicacao atual bater exatamente com o hash NOVO (pos-
-- manutencao) auditado nesta rodada. NAO usa DELETE nem UPDATE amplo
-- por materia_id/assunto_id/unidade — atinge exclusivamente as 3 linhas
-- cujo id e cujo hash de explicacao batem com o esperado.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\r\nA Declaração Universal dos Direitos Humanos de 1948 consagra formalmente em seu preâmbulo e no Artigo 1º que o reconhecimento da DIGNIDADE INERENTE a todos os membros da família humana e de seus direitos iguais e inalienáveis é o fundamento da liberdade, da justiça e da paz no mundo.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nA dignidade não depende de titulação nobiliárquica, classe social ou poder econômico.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nA dignidade humana é inerente a qualquer ser humano, sem distinção de nacionalidade.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nA dignidade é irrenunciável e não se perde por vontade individual.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\nA proteção é permanente em qualquer território.\r\n\r\nBIZU DE PROVA:\r\nDignidade da Pessoa Humana na DUDH:\r\nÉ valor axiológico UNIVERSAL e INERENTE: todo indivíduo possui dignidade pelo simples fato de existir como pessoa humana!'
  where id = 147
    and md5(explicacao) = 'b0c2c84e52e2ca7bdcbed957467fda6e';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: reversao de Q147 afetou % linha(s), esperado exatamente 1 — nao reverter as cegas', v_rows;
  end if;
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\r\nA DUDH é uma declaração formal de direitos universais adotada pela Assembleia Geral da ONU, instituindo os princípios e normas ético-jurídicas internacionais indispensáveis para salvaguardar a vida, a liberdade e a dignidade humana em todas as nações.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nA DUDH não é um tratado militar de defesa mútua.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nNão é um acordo de comércio tarifário.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nNão é um estatuto bancário internacional.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\nNão se restringe a matérias aduaneiras ou fiscais.\r\n\r\nBIZU DE PROVA:\r\nNatureza da DUDH (1948):\r\nEmbora originariamente aprovada sob a forma de Resolução da Assembleia Geral da ONU, hoje é reconhecida como norma consuetudinária internacional de valor universal (Jus Cogens).'
  where id = 148
    and md5(explicacao) = '7ac4306a25cc846e97c80a4215a553fa';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: reversao de Q148 afetou % linha(s), esperado exatamente 1 — nao reverter as cegas', v_rows;
  end if;
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes
  set explicacao = E'GABARITO: alternativa A\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\r\nA Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica, 1969) integra o SISTEMA REGIONAL INTERAMERICANO de proteção aos direitos humanos, adotada no âmbito da Organização dos Estados Americanos (OEA).\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nNão integra o sistema europeu (que possui a Convenção Europeia de Direitos Humanos).\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nNão integra o sistema africano (Carta Africana dos Direitos do Homem e dos Povos).\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nNão é um tratado privativo do sistema asiático.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\nEmbora dialogue com o sistema global da ONU, a CADH é a espinha dorsal do Sistema Interamericano (OEA).\r\n\r\nBIZU DE PROVA:\r\nSistemas de Proteção dos Direitos Humanos:\r\n- Sistema Global: ONU (DUDH, PIDCP, PIDESC).\r\n- Sistemas Regionais:\r\n  1. Interamericano (OEA / Pacto de San José);\r\n  2. Europeu (Conselho da Europa);\r\n  3. Africano (União Africana).'
  where id = 149
    and md5(explicacao) = 'd8dd965a249edbdd3f74e72919ed1fba';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: reversao de Q149 afetou % linha(s), esperado exatamente 1 — nao reverter as cegas', v_rows;
  end if;
end $$;

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes
  where id in (147,148,149)
    and md5(explicacao) in (
      '0bfa34f847975f222a5c4aa5082d285e',
      '0f9e9581325cfca6559fe775ccfc3698',
      'cb05a18d2e4480b81a13e985e1040795'
    );
  if v_cnt <> 3 then
    raise exception 'Abortado: apos reversao, esperado exatamente 3 questoes com os hashes originais, encontrado %', v_cnt;
  end if;
end $$;

commit;
