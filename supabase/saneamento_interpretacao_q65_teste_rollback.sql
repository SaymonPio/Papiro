-- SANEAMENTO DE FIDELIDADE — Q65 (curso_conteudo_id 12, Interpretacao de
-- textos) — operacao independente, separada da futura classificacao
-- pedagogica.
--
-- Fonte: Fundatec, Brigada Militar RS, Soldado de 1a Classe, 2025.
-- Caderno 976_BASE_NM_DT 14/05/2025. Texto "Quando da tragedia brotam
-- herois e licoes", por Oscar Bessi — o MESMO texto ja recuperado e
-- validado externamente para Q69 (conteudo 13, commit 51e5851) e
-- reaproveitado no saneamento de Q68 (conteudo 23, commit d6901ee).
-- Cross-check read-only confirmou que os enunciados atuais de Q68 e Q69
-- sao byte a byte identicos no bloco [01]-[32] antes desta operacao —
-- nenhuma divergencia material, reaproveitamento direto aprovado.
--
-- O enunciado armazenado de Q65 continha apenas o comando/assertivas
-- (identicos a "QUESTAO 01" da prova real, ja confirmado byte a byte na
-- auditoria), mas sem nenhum texto-base. Este saneamento restaura APENAS
-- o texto-base ausente; comando, assertivas e alternativas NAO sao
-- reescritos (ja eram fieis).
--
-- Altera SOMENTE o campo enunciado da questao 65. Alternativas, gabarito,
-- explicacao (ja compativel com o texto restaurado — nao contradiz
-- nenhuma linha, preservada sem alteracao), banca, concurso, ano,
-- assunto_id e ativa sao verificados como inalterados nas pos-condicoes.
-- Q68 e Q69 tambem sao verificadas como inalteradas.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_q68_enunciado text;
  v_q69_enunciado text;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual
    from public.questoes where id = 65;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 65 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando o exposto pelo texto-base, analise as assertivas a seguir: I. Na construção do texto, o autor utiliza o primeiro parágrafo para enumerar os resultados nefastos da tragédia de maio de 2024, mas no segundo parágrafo passa a apresentar eventos positivos ocorridos em meio ao caos. II. Para o autor, a solidariedade que uniu a todos ao longo dos trágicos eventos de que trata o texto demonstrou que grandes calamidades fazem desaparecer a coragem de praticar ações que prejudiquem o próximo. III. Apesar de tudo que se perdeu ao longo dos dias de maio de 2024, o autor aponta a esperança de dias melhores, que nasceu da movimentação solidária no período, indicando que o ser humano ainda tem um lado bom. Quais estão corretas?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 65 diverge do valor esperado antes da restauracao — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As assertivas I e III estão corretas. Assertiva I (correta): o primeiro parágrafo do texto descreve os impactos devastadores das enchentes de maio de 2024, enquanto o segundo parágrafo contrasta com as ações espontâneas de ajuda mútua e resgate. Assertiva III (correta): o texto conclui resgatando a perspectiva de esperança e reconstrução calcada nos atos de altruísmo coletivo demonstrados pela população.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também reflete com exatidão o conteúdo e a mensagem central do texto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva II, que está incorreta: o autor menciona expressamente que, mesmo durante o caos, ocorreram saques e crimes, mostrando que a calamidade não eliminou a perversidade de alguns indivíduos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Deixa de incluir a assertiva I, que descreve com precisão a estrutura temática de transição entre o primeiro e o segundo parágrafos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera a assertiva II correta, contrariando o texto-base que pontua a persistência de atos reprováveis paralelamente à onda de solidariedade.

BIZU DE PROVA:
Em questões de interpretação da Fundatec com assertivas I, II e III, atente para palavras generalizantes ("desaparecer", "todos", "sempre") que costumam invalidar assertivas que extrapolam o texto.' then
    raise exception 'Precondicao falhou: explicacao atual da questao 65 diverge do valor esperado antes da restauracao';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 65 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'Brigada Militar RS - Soldado de Primeira Classe' then
    raise exception 'Precondicao falhou: concurso da questao 65 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2025 then
    raise exception 'Precondicao falhou: ano da questao 65 diverge do esperado (2025) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 15 then
    raise exception 'Precondicao falhou: assunto_id da questao 65 diverge do esperado (15) — valor atual: %', v_assunto_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 65 and ativa = true) then
    raise exception 'Precondicao falhou: questao 65 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 65 and ordem = 3 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 65 nao e a alternativa de ordem 3 (C)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 65) then
    raise exception 'Precondicao falhou: questao 65 ja possui vinculo pedagogico (esperado: nenhum)';
  end if;

  -- Cross-check: Q68 e Q69 devem permanecer com o texto-base ja saneado,
  -- para confirmar que a reutilizacao parte de uma fonte estavel.
  select enunciado into v_q68_enunciado from public.questoes where id = 68;
  select enunciado into v_q69_enunciado from public.questoes where id = 69;
  if position('[01] Ninguém seria capaz' in v_q68_enunciado) = 0 or position('[32] um jardim de heroísmo' in v_q68_enunciado) = 0 then
    raise exception 'Precondicao falhou: texto-base saneado da questao 68 nao esta no estado esperado';
  end if;
  if position('[01] Ninguém seria capaz' in v_q69_enunciado) = 0 or position('[32] um jardim de heroísmo' in v_q69_enunciado) = 0 then
    raise exception 'Precondicao falhou: texto-base saneado da questao 69 nao esta no estado esperado';
  end if;
end $$;

update public.questoes
   set enunciado = '[01] Ninguém seria capaz de imaginar tudo o que viveríamos naqueles dias, há exatamente
[02] um ano. O maio de 2024 ficará para sempre na memória de todos os gaúchos – e muito além
[03] de nós. O ímpeto implacável das águas, a fúria imbatível da natureza, o pavor incrédulo nas
[04] retinas. O caos, tão incontrolável quanto pavorosamente banal, numa calamidade desgovernada
[05] de assombrosas surpresas. Notícias trágicas em série, impensáveis, parecendo sair de um filme
[06] de ficção sobre o apocalipse. Cenas de desespero e dor. O ruir repentino de tudo o que
[07] julgávamos inatingível até então. Construções e pontes desabando feito frágeis castelos de
[08] cartas. Rios mudando seus cursos e devorando cidades. Morros e florestas vindo abaixo como
[09] se derretessem. Histórias e memórias e conquistas sendo apagadas como se fossem nada e
[10] nunca. Dias de medo. Dias de mortes. Dias de horror.
[11] Mas eis que, da tragédia e das lágrimas que inundam tudo sob ferozes águas barrentas,
[12] surgem almas. Braços. Barcos, abraços e corações. Surge a entrega de heróis anônimos, que
[13] brotam em abundância de um sentimento de solidariedade jamais visto. Seres humanos
[14] iluminados que largam suas vidas para se dedicar ___ ações de solidariedade e resgate. Os
[15] integrantes das forças de segurança pública de todo o estado, mesmo as centenas afetadas em
[16] suas casas e suas vidas pela tragédia, se lançam ___ missão de salvar vidas. Todas as vidas. E
[17] proteger patrimônios. Porque, infelizmente, algumas mentes podres aproveitaram o momento
[18] de desespero para roubar e depredar, para cometer violências tão absurdas que uma legislação
[19] específica deveria punir, mas de forma exemplar e irrecorrível, por ser esta uma crueldade
[20] monstruosa: aproveitar-se e explorar a fragilidade e a dor dos seus semelhantes em meio ao
[21] caos.
[22] Forças de segurança de outros estados vieram em peso ajudar os nossos. Civis, em
[23] grupos ou isoladamente, de todo o Brasil e até do exterior largaram tudo e vieram se engajar
[24] na missão de salvar vidas e proteger cidadanias. Cargas de doações incontáveis venceram
[25] estradas destruídas e chegaram onde houvesse alguém precisando. A tragédia nos ensinava que
[26] a natureza jamais se submete ao homem e pode se rebelar quando bem entender. Mas nos
[27] ensinava também que nós, humanos, ainda temos um belíssimo lado bom, que sabe ser solidário
[28] e resiliente. Que sabe ter extrema garra, coragem e bravura irmanadas a uma gigantesca e
[29] afetuosa dedicação ao próximo. Que sabe renunciar ___ tudo o que é seu apenas para que o
[30] outro possa aliviar a sua dor e sorrir. A tragédia nos arrancou pontes, levou casas e plantações,
[31] tirou vidas de entes queridos. Mas também fez florescer, no exemplo daqueles dias fatídicos,
[32] um jardim de heroísmo, amor e solidariedade jamais vistos.
(Texto: "Quando da tragédia brotam heróis e lições", por Oscar Bessi. Disponível em: correiodopovo.com.br/blogs/oscarbessi – texto adaptado especialmente para esta prova.)

Considerando o exposto pelo texto-base, analise as assertivas a seguir: I. Na construção do texto, o autor utiliza o primeiro parágrafo para enumerar os resultados nefastos da tragédia de maio de 2024, mas no segundo parágrafo passa a apresentar eventos positivos ocorridos em meio ao caos. II. Para o autor, a solidariedade que uniu a todos ao longo dos trágicos eventos de que trata o texto demonstrou que grandes calamidades fazem desaparecer a coragem de praticar ações que prejudiquem o próximo. III. Apesar de tudo que se perdeu ao longo dos dias de maio de 2024, o autor aponta a esperança de dias melhores, que nasceu da movimentação solidária no período, indicando que o ser humano ainda tem um lado bom. Quais estão corretas?',
       atualizado_em = now()
 where id = 65;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 65;
  if position('[01]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [01] ausente'; end if;
  if position('[10]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [10] ausente'; end if;
  if position('[11]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [11] ausente'; end if;
  if position('[17]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [17] ausente'; end if;
  if position('[26]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [26] ausente'; end if;
  if position('[32]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [32] ausente'; end if;
end $$;

do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 65;
  select (length(v_novo) - length(replace(v_novo, 'Considerando o exposto pelo texto-base, analise as assertivas a seguir: I. Na construção do texto, o autor utiliza o primeiro parágrafo para enumerar os resultados nefastos da tragédia de maio de 2024, mas no segundo parágrafo passa a apresentar eventos positivos ocorridos em meio ao caos. II. Para o autor, a solidariedade que uniu a todos ao longo dos trágicos eventos de que trata o texto demonstrou que grandes calamidades fazem desaparecer a coragem de praticar ações que prejudiquem o próximo. III. Apesar de tudo que se perdeu ao longo dos dias de maio de 2024, o autor aponta a esperança de dias melhores, que nasceu da movimentação solidária no período, indicando que o ser humano ainda tem um lado bom. Quais estão corretas?', ''))) / greatest(length('Considerando o exposto pelo texto-base, analise as assertivas a seguir: I. Na construção do texto, o autor utiliza o primeiro parágrafo para enumerar os resultados nefastos da tragédia de maio de 2024, mas no segundo parágrafo passa a apresentar eventos positivos ocorridos em meio ao caos. II. Para o autor, a solidariedade que uniu a todos ao longo dos trágicos eventos de que trata o texto demonstrou que grandes calamidades fazem desaparecer a coragem de praticar ações que prejudiquem o próximo. III. Apesar de tudo que se perdeu ao longo dos dias de maio de 2024, o autor aponta a esperança de dias melhores, que nasceu da movimentação solidária no período, indicando que o ser humano ainda tem um lado bom. Quais estão corretas?'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 65 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
  end if;
end $$;

do $$
declare
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_gabarito_ok boolean;
  v_total_alt int;
  v_q68_enunciado text;
  v_q69_enunciado text;
begin
  select explicacao, banca, concurso, ano, assunto_id, ativa
    into v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 65;

  if v_explicacao is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As assertivas I e III estão corretas. Assertiva I (correta): o primeiro parágrafo do texto descreve os impactos devastadores das enchentes de maio de 2024, enquanto o segundo parágrafo contrasta com as ações espontâneas de ajuda mútua e resgate. Assertiva III (correta): o texto conclui resgatando a perspectiva de esperança e reconstrução calcada nos atos de altruísmo coletivo demonstrados pela população.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também reflete com exatidão o conteúdo e a mensagem central do texto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva II, que está incorreta: o autor menciona expressamente que, mesmo durante o caos, ocorreram saques e crimes, mostrando que a calamidade não eliminou a perversidade de alguns indivíduos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Deixa de incluir a assertiva I, que descreve com precisão a estrutura temática de transição entre o primeiro e o segundo parágrafos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera a assertiva II correta, contrariando o texto-base que pontua a persistência de atos reprováveis paralelamente à onda de solidariedade.

BIZU DE PROVA:
Em questões de interpretação da Fundatec com assertivas I, II e III, atente para palavras generalizantes ("desaparecer", "todos", "sempre") que costumam invalidar assertivas que extrapolam o texto.' then
    raise exception 'Pos-condicao falhou: explicacao da questao 65 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 65 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'Brigada Militar RS - Soldado de Primeira Classe' then
    raise exception 'Pos-condicao falhou: concurso da questao 65 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2025 then
    raise exception 'Pos-condicao falhou: ano da questao 65 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 15 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 65 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 65 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 65;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 65 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 65 and ordem = 3 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 65 nao e mais a alternativa de ordem 3 (C)';
  end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 65) then
    raise exception 'Pos-condicao falhou: questao 65 possui vinculo pedagogico inesperado (deveria permanecer nao vinculada)';
  end if;

  -- Confirma que Q68 e Q69 nao foram alteradas por este apply.
  select enunciado into v_q68_enunciado from public.questoes where id = 68;
  select enunciado into v_q69_enunciado from public.questoes where id = 69;
  if position('[01] Ninguém seria capaz' in v_q68_enunciado) = 0 or position('[32] um jardim de heroísmo' in v_q68_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: texto-base da questao 68 foi alterado indevidamente por este apply';
  end if;
  if position('[01] Ninguém seria capaz' in v_q69_enunciado) = 0 or position('[32] um jardim de heroísmo' in v_q69_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: texto-base da questao 69 foi alterado indevidamente por este apply';
  end if;

  raise notice 'Pos-condicoes OK: enunciado da questao 65 restaurado com fidelidade (texto-base [01]-[32] + comando original preservado), alternativas/gabarito/explicacao/proveniencia/assunto_id/ativa inalterados, questao 65 permanece sem vinculo pedagogico, Q68/Q69 inalteradas.';
end $$;

rollback;
