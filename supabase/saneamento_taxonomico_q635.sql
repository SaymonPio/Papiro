-- SANEAMENTO TAXONOMICO Q635 — INTERNET E NAVEGADORES (assunto_id 62) ->
-- CORREIO ELETRONICO (assunto_id 60, curso_conteudo_id 39, ordem 82,
-- AINDA PENDENTE de curadoria final). Operacao propria, separada,
-- seguindo o mesmo padrao de Q878 (saneamento_taxonomico_q878.sql) e
-- Q279 (saneamento_taxonomico_q279.sql): mover assunto_id ANTES de
-- vincular, pois o trigger validar_questao_unidade_pedagogica bloqueia
-- vinculo com assunto_id divergente.
--
-- Motivo: microauditoria da ordem 77 (Internet e navegadores) e
-- microauditoria final dedicada confirmaram que Q635 e resolvida
-- integralmente por conhecimento especifico de protocolos de correio
-- eletronico (IMAP mantem mensagens no servidor para acesso
-- multi-dispositivo; SMTP serve exclusivamente para envio, nunca
-- download; @ separa usuario de dominio) — habilidade nuclear e
-- CORREIO ELETRONICO, um conteudo proprio e distinto ja mapeado na
-- fila (curso_conteudo_id 39, ordem 82), nao o tema generico de
-- "Internet e navegadores". PROBLEMA_DE_TAXONOMIA_Q635, nao
-- QUESTAO_HIBRIDA_MULTICONTEUDO — questao especifica e vinculavel,
-- apenas estava no assunto errado.
--
-- Q635 e REAL (Fundatec, Esc Pol PC RS 2026). Fidelidade textual
-- corroborada por reproducao independente (Caderno de Treino Policia
-- Civil, 5a edicao 2026, atribuida a Fundatec/PC/RS/Escrivao/2026) —
-- tres assertivas e cinco alternativas identicas, palavra por palavra,
-- ao conteudo armazenado no Papiro. NAO e confirmacao via PDF oficial
-- da banca, e sim corroboracao por fonte terceira independente que
-- reproduz a prova. Enunciado, alternativas, gabarito e explicacao
-- (incluindo os pequenos glitches de espaco ja existentes no texto —
-- "sejamacessadas", "estahospedada", "umdispositivo" — heranca do
-- import original) NAO sao alterados nesta operacao — apenas taxonomia.
--
-- Altera SOMENTE questoes.assunto_id da questao 635 e cria 1 vinculo
-- pedagogico novo (via RPC oficial), na unidade placeholder ja
-- existente de Correio eletronico (curso_conteudo_id 39, ordem 82,
-- AINDA PENDENTE — este saneamento NAO marca a ordem 82 como
-- concluida, nem antecipa vinculo das demais 9 candidatas daquele
-- conteudo; Q635 fica como vinculo pre-existente aprovado, a ser
-- incorporado formalmente aos artefatos canonicos quando a ordem 82
-- for auditada, mesmo padrao ja usado para Q878 em Implicitos e
-- subentendidos). Internet e navegadores (curso_conteudo_id 38, ordem
-- 77, tambem AINDA PENDENTE) tambem nao e fechado por esta operacao.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos,
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 38)                          as vinculos_internet_navegadores,
  (select count(*) from public.questoes
     where ativa = true and materia_id = 9 and assunto_id = 60) as candidatas_correio_antes;

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_ativa_atual boolean;
  v_vinculos_q635 int;
  v_destino_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 635;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 635 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Sobre o uso de correio eletrônico, analise as assertivas abaixo: I. O protocolo IMAP (Internet Message Access Protocol) permite que mensagens de e-mail permaneçam armazenadas no servidor, possibilitando que sejamacessadas por múltiplos dispositivos simultaneamente. II. Em um endereço de e-mail padrão, o símbolo @ (conhecido como “arroba”) é utilizado para separar o nome da conta e o domínio onde a conta de e-mail estáhospedada. III. O protocolo SMTP (Simple Mail Transfer Protocol), além de ser utilizado para enviar mensagens de e-mail, também possibilita baixar mensagens em umdispositivo. Quais estão corretas?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 635 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O protocolo IMAP (Internet Message Access Protocol, porta padrão 993 SSL ou 143) sincroniza as pastas mantendo as mensagens originais armazenadas no servidor de correio, viabilizando o acesso simultâneo e consistente a partir de múltiplos dispositivos (celular, tablet, notebook).
- Assertiva II (Correta): Na estrutura padrão de e-mail (RFC 5322), o caractere @ (at/arroba) separa o nome de usuário local da identificação do servidor/domínio de hospedagem (exemplo: usuario@dominio.com.br).
- Assertiva III (Incorreta): O protocolo SMTP (Simple Mail Transfer Protocol, portas 587 / 465) é utilizado EXCLUSIVAMENTE para o ENVIO / transmissão de e-mails entre clientes e servidores; o recebimento/download é responsabilidade dos protocolos POP3 ou IMAP.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está errada (SMTP não baixa mensagens).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Mnemônico dos Protocolos de E-mail:
- SMTP = "Sua Mensagem Tá Partindo" (ENVIO).
- POP3 = Puxa do servidor para o computador local (RECEBIMENTO / Download).
- IMAP = Acesso e sincronização direta no servidor (RECEBIMENTO / Sincronização).' then
    raise exception 'Precondicao falhou: explicacao atual da questao 635 diverge do esperado';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 635 diverge do esperado — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'Esc Pol (PC RS)/PC RS/2026' then
    raise exception 'Precondicao falhou: concurso da questao 635 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2026 then
    raise exception 'Precondicao falhou: ano da questao 635 diverge do esperado (2026) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 62 then
    raise exception 'Precondicao falhou: assunto_id atual da questao 635 diverge do esperado (62) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 635 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 635 and ordem = 3 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 635 nao e a alternativa de ordem 3 (C)';
  end if;

  select count(*) into v_vinculos_q635 from public.questao_unidades_pedagogicas where questao_id = 635;
  if v_vinculos_q635 <> 0 then
    raise exception 'Precondicao falhou: questao 635 ja possui % vinculo(s) pedagogico(s) (esperado 0)', v_vinculos_q635;
  end if;

  -- Confirma estado da unidade destino (Correio eletronico).
  if not exists (
    select 1 from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = '1c682e95-da6f-43a2-8b53-6669b41a376b'
      and u.curso_conteudo_id = 39
      and u.ordem = 1
      and u.ativa
      and cc.assunto_id = 60
  ) then
    raise exception 'Precondicao falhou: unidade de Correio eletronico nao confere (id/ordem/conteudo/assunto/ativa)';
  end if;

  select count(*) into v_destino_vinculos
  from public.questao_unidades_pedagogicas
  where unidade_pedagogica_id = '1c682e95-da6f-43a2-8b53-6669b41a376b';
  if v_destino_vinculos <> 0 then
    raise exception 'Precondicao falhou: unidade de Correio eletronico ja possui % vinculo(s) (esperado 0)', v_destino_vinculos;
  end if;

  if (select candidatas_correio_antes from _snapshot_antes) <> 9 then
    raise exception 'Precondicao falhou: candidatas ativas de Correio eletronico (assunto 60) = % (esperado 9, antes desta operacao)', (select candidatas_correio_antes from _snapshot_antes);
  end if;
end $$;

-- Correcao taxonomica: move Q635 do assunto de Internet e navegadores
-- (62) para o assunto de Correio eletronico (60). Pre-requisito tecnico
-- para o trigger validar_questao_unidade_pedagogica permitir o vinculo
-- a seguir.
update public.questoes
   set assunto_id = 60,
       atualizado_em = now()
 where id = 635;

do $$
begin
  if not exists (select 1 from public.questoes where id = 635 and assunto_id = 60) then
    raise exception 'Pos-condicao (intermediaria) falhou: assunto_id da questao 635 nao foi atualizado para 60';
  end if;
end $$;

-- Criacao do vinculo pedagogico via RPC oficial (agora permitido pelo
-- trigger, pois materia_id e assunto_id conferem com a unidade).
select public.classificar_questao_unidade_admin(635, '1c682e95-da6f-43a2-8b53-6669b41a376b'::uuid);

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia —
-- so chega ao COMMIT final se passar tudo.
do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_gabarito_ok boolean;
  v_total_alt int;
  v_vinculos_q635 int;
  v_total_vinculos_correio int;
  v_vinculos_internet_navegadores_depois int;
  v_candidatas_correio_depois int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 635;

  if v_enunciado is distinct from 'Sobre o uso de correio eletrônico, analise as assertivas abaixo: I. O protocolo IMAP (Internet Message Access Protocol) permite que mensagens de e-mail permaneçam armazenadas no servidor, possibilitando que sejamacessadas por múltiplos dispositivos simultaneamente. II. Em um endereço de e-mail padrão, o símbolo @ (conhecido como “arroba”) é utilizado para separar o nome da conta e o domínio onde a conta de e-mail estáhospedada. III. O protocolo SMTP (Simple Mail Transfer Protocol), além de ser utilizado para enviar mensagens de e-mail, também possibilita baixar mensagens em umdispositivo. Quais estão corretas?' then
    raise exception 'Pos-condicao falhou: enunciado da questao 635 foi alterado indevidamente';
  end if;
  if v_explicacao is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O protocolo IMAP (Internet Message Access Protocol, porta padrão 993 SSL ou 143) sincroniza as pastas mantendo as mensagens originais armazenadas no servidor de correio, viabilizando o acesso simultâneo e consistente a partir de múltiplos dispositivos (celular, tablet, notebook).
- Assertiva II (Correta): Na estrutura padrão de e-mail (RFC 5322), o caractere @ (at/arroba) separa o nome de usuário local da identificação do servidor/domínio de hospedagem (exemplo: usuario@dominio.com.br).
- Assertiva III (Incorreta): O protocolo SMTP (Simple Mail Transfer Protocol, portas 587 / 465) é utilizado EXCLUSIVAMENTE para o ENVIO / transmissão de e-mails entre clientes e servidores; o recebimento/download é responsabilidade dos protocolos POP3 ou IMAP.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está errada (SMTP não baixa mensagens).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Mnemônico dos Protocolos de E-mail:
- SMTP = "Sua Mensagem Tá Partindo" (ENVIO).
- POP3 = Puxa do servidor para o computador local (RECEBIMENTO / Download).
- IMAP = Acesso e sincronização direta no servidor (RECEBIMENTO / Sincronização).' then
    raise exception 'Pos-condicao falhou: explicacao da questao 635 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 635 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'Esc Pol (PC RS)/PC RS/2026' then
    raise exception 'Pos-condicao falhou: concurso da questao 635 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 635 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 60 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 635 nao e 60 (esperado apos correcao taxonomica) — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 635 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 635;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 635 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 635 and ordem = 3 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 635 nao e mais a alternativa de ordem 3 (C)';
  end if;

  select count(*) into v_vinculos_q635 from public.questao_unidades_pedagogicas where questao_id = 635;
  if v_vinculos_q635 <> 1 then
    raise exception 'Pos-condicao falhou: questao 635 possui % vinculo(s) (esperado exatamente 1)', v_vinculos_q635;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 635 and unidade_pedagogica_id = '1c682e95-da6f-43a2-8b53-6669b41a376b') then
    raise exception 'Pos-condicao falhou: o vinculo da questao 635 nao aponta para a unidade de Correio eletronico';
  end if;
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 635 and u.curso_conteudo_id = 38
  ) then
    raise exception 'Pos-condicao falhou: a questao 635 ainda possui vinculo em Internet e navegadores (38)';
  end if;

  select count(*) into v_total_vinculos_correio
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 39;
  if v_total_vinculos_correio <> 1 then
    raise exception 'Pos-condicao falhou: total de vinculos de Correio eletronico=% (esperado 1)', v_total_vinculos_correio;
  end if;

  -- Internet e navegadores (conteudo 38, AINDA PENDENTE) nao pode ter
  -- sido afetado por esta operacao alem da saida da propria Q635.
  select count(*) into v_vinculos_internet_navegadores_depois
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 38;
  if v_vinculos_internet_navegadores_depois <> (select vinculos_internet_navegadores from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: vinculos de Internet e navegadores (38) mudaram — antes % agora %', (select vinculos_internet_navegadores from _snapshot_antes), v_vinculos_internet_navegadores_depois;
  end if;

  -- Candidatas ativas de Correio eletronico devem ter crescido de 9
  -- para 10 (Q635 entrou no assunto 60).
  select count(*) into v_candidatas_correio_depois
  from public.questoes
  where ativa = true and materia_id = 9 and assunto_id = 60;
  if v_candidatas_correio_depois <> 10 then
    raise exception 'Pos-condicao falhou: candidatas ativas de Correio eletronico (assunto 60) = % (esperado 10, apos esta operacao)', v_candidatas_correio_depois;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 39) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 39 mudou (deveria continuar 1)';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou (nenhuma unidade nova deveria ter sido criada)';
  end if;
  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos do sistema nao cresceu exatamente 1';
  end if;

  raise notice 'Pos-condicoes OK: questao 635 movida para assunto_id=60 (Correio eletronico), vinculada exatamente 1 vez a unidade 1c682e95-da6f-43a2-8b53-6669b41a376b, sem vinculo remanescente em Internet e navegadores, candidatas de Correio eletronico 9->10, enunciado/explicacao/alternativas/gabarito/proveniencia/ativa inalterados.';
end $$;

commit;
