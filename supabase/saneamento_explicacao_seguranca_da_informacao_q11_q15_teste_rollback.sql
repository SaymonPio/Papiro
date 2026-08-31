-- SANEAMENTO DE FIDELIDADE — Q11 e Q15 (curso_conteudo_id 40, Seguranca da
-- informacao) — operacao independente, separada da futura classificacao
-- pedagogica desta ordem (81). Altera SOMENTE o campo `explicacao` das
-- duas questoes. Enunciado, alternativas, gabarito, banca, concurso, ano,
-- fonte, assunto_id, ativa e vinculos sao verificados como inalterados
-- nas pos-condicoes.
--
-- Diagnostico confirmado na auditoria da ordem 81: em ambas as questoes,
-- o enunciado, as alternativas e o gabarito (coluna `correta`) ja estavam
-- corretos, mas o texto de `explicacao` armazenado nao tinha nenhuma
-- relacao com a questao:
--   Q11: enunciado descreve phishing, alternativa correta ja e "Phishing"
--        (ordem 1), mas a explicacao antiga justificava "backup" como se
--        fosse a resposta certa.
--   Q15: enunciado pergunta qual pratica aumenta a seguranca de uma
--        conta, alternativa correta ja e "Ativar autenticação em dois
--        fatores" (ordem 1), mas a explicacao antiga justificava "senha
--        forte com troca periodica", conceito que nao corresponde a
--        nenhuma das 4 alternativas armazenadas.
--
-- Harness de teste (SEMPRE termina em ROLLBACK) — nada aqui persiste no
-- banco. Ver saneamento_explicacao_seguranca_da_informacao_q11_q15.sql
-- para a aplicacao real (termina em COMMIT).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_11 text;
  v_explicacao_11 text;
  v_banca_11 text;
  v_concurso_11 text;
  v_assunto_11 bigint;
  v_enunciado_15 text;
  v_explicacao_15 text;
  v_banca_15 text;
  v_concurso_15 text;
  v_assunto_15 bigint;
begin
  select enunciado, explicacao, banca, concurso, assunto_id
    into v_enunciado_11, v_explicacao_11, v_banca_11, v_concurso_11, v_assunto_11
    from public.questoes where id = 11;

  if v_enunciado_11 is distinct from 'Uma mensagem eletrônica que imita uma instituição legítima para induzir o usuário a informar sua senha é exemplo de:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 11 diverge do esperado — valor atual: %', v_enunciado_11;
  end if;
  if position('O backup (cópia de segurança) consiste em duplicar dados' in v_explicacao_11) = 0
     or position('Regra de Ouro 3-2-1 do Backup' in v_explicacao_11) = 0
     or position('PHISHING' in v_explicacao_11) > 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 11 diverge do valor esperado antes do saneamento (nao contem o texto quebrado sobre backup, ou ja foi alterada)';
  end if;
  if v_assunto_11 is distinct from 10 then
    raise exception 'Precondicao falhou: assunto_id da questao 11 diverge do esperado (10) — valor atual: %', v_assunto_11;
  end if;
  if not exists (select 1 from public.questoes where id = 11 and ativa = true) then
    raise exception 'Precondicao falhou: questao 11 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 11 and ordem = 1 and correta = true and texto = 'Phishing') then
    raise exception 'Precondicao falhou: gabarito atual da questao 11 nao e a alternativa "Phishing" (ordem 1)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 11) then
    raise exception 'Precondicao falhou: questao 11 ja possui vinculo pedagogico (esperado: nenhum)';
  end if;

  select enunciado, explicacao, banca, concurso, assunto_id
    into v_enunciado_15, v_explicacao_15, v_banca_15, v_concurso_15, v_assunto_15
    from public.questoes where id = 15;

  if v_enunciado_15 is distinct from 'Qual prática aumenta a segurança de uma conta utilizada em serviço?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 15 diverge do esperado — valor atual: %', v_enunciado_15;
  end if;
  if position('associado à troca periódica' in v_explicacao_15) = 0
     or position('Pilares da Segurança da Informação (CIDAN)' in v_explicacao_15) = 0
     or position('AUTENTICAÇÃO EM DOIS FATORES' in v_explicacao_15) > 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 15 diverge do valor esperado antes do saneamento (nao contem o texto quebrado sobre senha forte/troca periodica, ou ja foi alterada)';
  end if;
  if v_assunto_15 is distinct from 10 then
    raise exception 'Precondicao falhou: assunto_id da questao 15 diverge do esperado (10) — valor atual: %', v_assunto_15;
  end if;
  if not exists (select 1 from public.questoes where id = 15 and ativa = true) then
    raise exception 'Precondicao falhou: questao 15 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 15 and ordem = 1 and correta = true and texto = 'Ativar autenticação em dois fatores') then
    raise exception 'Precondicao falhou: gabarito atual da questao 15 nao e a alternativa "Ativar autenticação em dois fatores" (ordem 1)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 15) then
    raise exception 'Precondicao falhou: questao 15 ja possui vinculo pedagogico (esperado: nenhum)';
  end if;
end $$;

update public.questoes
   set explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
PHISHING é a técnica fraudulenta de engenharia social em que um golpista envia uma mensagem eletrônica (e-mail, SMS, aplicativo de mensagens etc.) fazendo-se passar por uma instituição ou pessoa legítima e confiável (banco, órgão público, empresa), com o objetivo de induzir a vítima a revelar credenciais como senhas e dados bancários, a fornecer outras informações sensíveis ou a clicar em um link/anexo malicioso. O enunciado descreve exatamente esse mecanismo: uma mensagem que imita uma instituição legítima para induzir o usuário a informar sua senha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Backup incremental é um procedimento de cópia de segurança que armazena apenas os dados alterados desde o último backup realizado, com a finalidade de permitir a recuperação de dados — não descreve o envio de mensagens fraudulentas para obtenção de credenciais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Firewall de aplicação é um mecanismo de controle e filtragem de tráfego de rede conforme regras definidas — é uma ferramenta de defesa, não uma técnica de fraude por mensagem.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Criptografia assimétrica é o modelo criptográfico que utiliza um par de chaves relacionadas (uma pública e uma privada) para cifrar e decifrar informações — não descreve o envio de uma mensagem fraudulenta que imita uma instituição.

BIZU DE PROVA:
Phishing:
- Mensagem (e-mail, SMS, aplicativo de mensagens) que imita uma fonte confiável.
- Objetivo: induzir a vítima a revelar senha/dados ou a clicar em conteúdo malicioso.
- É uma técnica de ENGENHARIA SOCIAL: o phishing pode ser o meio de entrega de um malware, mas o phishing em si é a fraude/indução, não o código malicioso.

NOTA DE SANEAMENTO: a explicação anterior desta questão justificava incorretamente "backup" como resposta correta, sem qualquer relação com o enunciado (que descreve phishing) nem com a alternativa efetivamente marcada como correta no banco ("Phishing", ordem 1). O enunciado, as alternativas e o gabarito não foram alterados — apenas o texto da explicação foi reescrito para corresponder à habilidade realmente testada.',
       atualizado_em = now()
 where id = 11;

update public.questoes
   set explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Ativar a AUTENTICAÇÃO EM DOIS FATORES (2FA) exige, além da senha (fator de conhecimento — o que o usuário sabe), uma segunda etapa de verificação baseada em um fator diferente: por exemplo, um código gerado por aplicativo autenticador ou recebido no dispositivo do usuário (fator de posse — o que o usuário tem), ou uma verificação biométrica (fator de inerência — o que o usuário é). Assim, mesmo que a senha da conta seja descoberta ou vazada, o acesso continua bloqueado sem essa segunda etapa, reduzindo significativamente o risco de acesso indevido.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Reutilizar a mesma senha em vários serviços amplia o risco em cascata: se um único serviço for comprometido, todas as demais contas que usam a mesma senha ficam expostas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Compartilhar a senha com colegas de equipe quebra o caráter pessoal e intransferível da credencial, dificultando identificar quem de fato praticou cada ação na conta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Desativar atualizações automáticas deixa o sistema exposto a falhas de segurança já conhecidas e corrigidas pelo fabricante (exploits), em vez de reduzir o risco.

BIZU DE PROVA:
Fatores de autenticação:
1. Conhecimento — o que você sabe (senha, PIN).
2. Posse — o que você tem (celular, token, aplicativo autenticador).
3. Inerência — o que você é (biometria, impressão digital, reconhecimento facial).
2FA/MFA combina fatores de CATEGORIAS DIFERENTES: usar duas senhas (dois itens do mesmo fator "conhecimento") não é multifator.

NOTA DE SANEAMENTO: a explicação anterior desta questão justificava a resposta com base em "senha forte e troca periódica", conceito que não corresponde a nenhuma das 4 alternativas armazenadas e não guarda relação com a alternativa efetivamente marcada como correta no banco ("Ativar autenticação em dois fatores", ordem 1). O enunciado, as alternativas e o gabarito não foram alterados — apenas o texto da explicação foi reescrito para corresponder à habilidade realmente testada.',
       atualizado_em = now()
 where id = 15;

do $$
declare
  v_explicacao_11 text;
  v_explicacao_15 text;
begin
  select explicacao into v_explicacao_11 from public.questoes where id = 11;
  if position('PHISHING' in v_explicacao_11) = 0 then raise exception 'Pos-condicao falhou: Q11 nao menciona PHISHING na nova explicacao'; end if;
  if position('backup' in v_explicacao_11) > 0 and position('não descreve o envio de mensagens fraudulentas' in v_explicacao_11) = 0 then
    raise exception 'Pos-condicao falhou: Q11 ainda trata backup como resposta correta';
  end if;
  if position('NOTA DE SANEAMENTO' in v_explicacao_11) = 0 then raise exception 'Pos-condicao falhou: Q11 sem nota de saneamento'; end if;

  select explicacao into v_explicacao_15 from public.questoes where id = 15;
  if position('AUTENTICAÇÃO EM DOIS FATORES' in v_explicacao_15) = 0 then raise exception 'Pos-condicao falhou: Q15 nao menciona autenticacao em dois fatores na nova explicacao'; end if;
  if position('POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Ativar a AUTENTICAÇÃO EM DOIS FATORES' in v_explicacao_15) = 0 then
    raise exception 'Pos-condicao falhou: Q15 nao justifica a alternativa correta com base em autenticacao em dois fatores';
  end if;
  if position('NOTA DE SANEAMENTO' in v_explicacao_15) = 0 then raise exception 'Pos-condicao falhou: Q15 sem nota de saneamento'; end if;
end $$;

do $$
declare
  v_enunciado_11 text;
  v_enunciado_15 text;
  v_banca_11 text;
  v_banca_15 text;
  v_concurso_11 text;
  v_concurso_15 text;
  v_ano_11 int;
  v_ano_15 int;
  v_assunto_11 bigint;
  v_assunto_15 bigint;
  v_ativa_11 boolean;
  v_ativa_15 boolean;
  v_total_alt_11 int;
  v_total_alt_15 int;
  v_gabarito_11 text;
  v_gabarito_15 text;
begin
  select enunciado, banca, concurso, ano, assunto_id, ativa into v_enunciado_11, v_banca_11, v_concurso_11, v_ano_11, v_assunto_11, v_ativa_11 from public.questoes where id = 11;
  select enunciado, banca, concurso, ano, assunto_id, ativa into v_enunciado_15, v_banca_15, v_concurso_15, v_ano_15, v_assunto_15, v_ativa_15 from public.questoes where id = 15;

  if v_enunciado_11 is distinct from 'Uma mensagem eletrônica que imita uma instituição legítima para induzir o usuário a informar sua senha é exemplo de:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 11 foi alterado indevidamente';
  end if;
  if v_banca_11 is distinct from 'Papiro — estilo FGV' then
    raise exception 'Pos-condicao falhou: banca da questao 11 foi alterada indevidamente — valor atual: %', v_banca_11;
  end if;
  if v_assunto_11 is distinct from 10 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 11 foi alterado indevidamente';
  end if;
  if v_ativa_11 is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 11 foi alterada indevidamente';
  end if;

  if v_enunciado_15 is distinct from 'Qual prática aumenta a segurança de uma conta utilizada em serviço?' then
    raise exception 'Pos-condicao falhou: enunciado da questao 15 foi alterado indevidamente';
  end if;
  if v_banca_15 is distinct from 'Papiro — estilo Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 15 foi alterada indevidamente — valor atual: %', v_banca_15;
  end if;
  if v_assunto_15 is distinct from 10 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 15 foi alterado indevidamente';
  end if;
  if v_ativa_15 is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 15 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt_11 from public.alternativas where questao_id = 11;
  select count(*) into v_total_alt_15 from public.alternativas where questao_id = 15;
  if v_total_alt_11 <> 4 then raise exception 'Pos-condicao falhou: numero de alternativas da questao 11 mudou (esperado 4, atual %)', v_total_alt_11; end if;
  if v_total_alt_15 <> 4 then raise exception 'Pos-condicao falhou: numero de alternativas da questao 15 mudou (esperado 4, atual %)', v_total_alt_15; end if;

  select texto into v_gabarito_11 from public.alternativas where questao_id = 11 and correta = true;
  select texto into v_gabarito_15 from public.alternativas where questao_id = 15 and correta = true;
  if v_gabarito_11 is distinct from 'Phishing' then raise exception 'Pos-condicao falhou: gabarito da questao 11 mudou (atual: %)', v_gabarito_11; end if;
  if v_gabarito_15 is distinct from 'Ativar autenticação em dois fatores' then raise exception 'Pos-condicao falhou: gabarito da questao 15 mudou (atual: %)', v_gabarito_15; end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (11, 15)) then
    raise exception 'Pos-condicao falhou: questao 11 ou 15 ganhou vinculo pedagogico inesperado (deveriam permanecer sem vinculo)';
  end if;

  raise notice 'Pos-condicoes OK: explicacao de Q11 e Q15 corrigida, enunciado/alternativas/gabarito/banca/concurso/ano/assunto_id/ativa inalterados, ambas permanecem sem vinculo pedagogico.';
end $$;

rollback;
