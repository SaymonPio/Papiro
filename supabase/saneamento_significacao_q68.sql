-- SANEAMENTO DE FIDELIDADE — Q68 (curso_conteudo_id 23, Significacao das
-- palavras) — operacao independente, separada da classificacao pedagogica
-- (que ainda NAO sera feita para Q68 — ela permanece MULTICONTEUDO, sem
-- vinculo a nenhuma unidade).
--
-- Fonte: Fundatec, Brigada Militar RS, Soldado de 1a Classe, 2025. Caderno
-- 976_BASE_NM_DT 14/05/2025. Texto "Quando da tragedia brotam herois e
-- licoes", por Oscar Bessi — o MESMO texto ja recuperado e validado
-- externamente para Q69 (saneamento_coesao_textual_operacao_a.sql,
-- conteudo 13, commit 51e5851). O enunciado armazenado de Q68 removia o
-- texto-base e a citacao "(l. 04)" do comando original, mantendo apenas o
-- comando/assertivas (identicos aos da prova real, exceto pela ausencia da
-- citacao de linha).
--
-- Altera SOMENTE o campo enunciado da questao 68. Alternativas, gabarito,
-- explicacao, banca, concurso, ano, assunto_id e ativa sao verificados
-- como inalterados nas pos-condicoes. A explicacao atual permanece correta
-- em relacao ao texto restaurado — preservada sem alteracao.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_atual text;
  v_banca_atual text;
  v_assunto_atual bigint;
begin
  select enunciado, banca, assunto_id
    into v_enunciado_atual, v_banca_atual, v_assunto_atual
    from public.questoes where id = 68;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 68 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando a palavra “calamidade”, analise as assertivas a seguir, assinalando V, se verdadeiras, ou F, se falsas. ( ) Um significado válido para a palavra, considerando sua ocorrência no texto, é “catástrofe”. ( ) A palavra é classificada morfologicamente como um adjetivo uniforme, pois não apresenta variação de gênero, existindo apenas no feminino. ( ) Trata-se de uma palavra com cinco sílabas na qual não ocorrem dígrafos nem encontros consonantais. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 68 diverge do valor esperado antes da restauracao — valor atual: %', v_enunciado_atual;
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 68 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_assunto_atual is distinct from 59 then
    raise exception 'Precondicao falhou: assunto_id da questao 68 diverge do esperado (59) — valor atual: %', v_assunto_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 68 and ativa = true) then
    raise exception 'Precondicao falhou: questao 68 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 68 and ordem = 3 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 68 nao e a alternativa de ordem 3 (C)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 68) then
    raise exception 'Precondicao falhou: questao 68 ja possui vinculo pedagogico (esperado: nenhum)';
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

Considerando a palavra “calamidade” (l. 04), analise as assertivas a seguir, assinalando V, se verdadeiras, ou F, se falsas. ( ) Um significado válido para a palavra, considerando sua ocorrência no texto, é “catástrofe”. ( ) A palavra é classificada morfologicamente como um adjetivo uniforme, pois não apresenta variação de gênero, existindo apenas no feminino. ( ) Trata-se de uma palavra com cinco sílabas na qual não ocorrem dígrafos nem encontros consonantais. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:',
       atualizado_em = now()
 where id = 68;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 68;
  if position('[01]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador [01] ausente no novo enunciado da questao 68';
  end if;
  if position('[04]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador [04] ausente no novo enunciado da questao 68';
  end if;
  if position('[32]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador [32] ausente no novo enunciado da questao 68';
  end if;
  if position('(l. 04)' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: citacao (l. 04) ausente no novo enunciado da questao 68';
  end if;
  if position('numa calamidade desgovernada' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: ocorrencia real de calamidade (linha 04) ausente no novo enunciado da questao 68';
  end if;
end $$;

do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 68;
  select (length(v_novo) - length(replace(v_novo, 'Considerando a palavra “calamidade” (l. 04), analise as assertivas a seguir, assinalando V, se verdadeiras, ou F, se falsas. ( ) Um significado válido para a palavra, considerando sua ocorrência no texto, é “catástrofe”. ( ) A palavra é classificada morfologicamente como um adjetivo uniforme, pois não apresenta variação de gênero, existindo apenas no feminino. ( ) Trata-se de uma palavra com cinco sílabas na qual não ocorrem dígrafos nem encontros consonantais. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:', ''))) / greatest(length('Considerando a palavra “calamidade” (l. 04), analise as assertivas a seguir, assinalando V, se verdadeiras, ou F, se falsas. ( ) Um significado válido para a palavra, considerando sua ocorrência no texto, é “catástrofe”. ( ) A palavra é classificada morfologicamente como um adjetivo uniforme, pois não apresenta variação de gênero, existindo apenas no feminino. ( ) Trata-se de uma palavra com cinco sílabas na qual não ocorrem dígrafos nem encontros consonantais. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 68 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
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
begin
  select explicacao, banca, concurso, ano, assunto_id, ativa
    into v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 68;

  if v_explicacao is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta de preenchimento dos parênteses é V – F – V.
- 1º parêntese (Verdadeiro): no contexto de desastre natural e cheias, "calamidade" é sinônimo perfeitamente adequado de "catástrofe", "desastre" ou "tragédia".
- 2º parêntese (Falso): morfologicamente, "calamidade" é um SUBSTANTIVO feminino (o nome de um estado/evento), e não um adjetivo uniforme.
- 3º parêntese (Verdadeiro): a separação silábica é ca-la-mi-da-de (5 sílabas = polissílaba), sendo todas sílabas simples (consoante + vogal), sem nenhum dígrafo ou encontro consonantal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o 2º parêntese como verdadeiro, mas "calamidade" não é adjetivo, e sim substantivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o 3º parêntese como falso, quando a palavra realmente tem 5 sílabas sem dígrafos nem encontros consonantais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o 1º parêntese como falso, negando a equivalência semântica evidente entre calamidade e catástrofe.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a veracidade do 1º e do 2º itens.

BIZU DE PROVA:
Atenção à morfologia vs. semântica: uma palavra que indica uma qualidade ou estado pode ser substantivo se ela nomeia o fenômeno ("a beleza", "a calamidade", "a tristeza") e só vira adjetivo quando qualifica outro termo ("situação calamitosa").' then
    raise exception 'Pos-condicao falhou: explicacao da questao 68 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 68 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'Brigada Militar RS - Soldado de Primeira Classe' then
    raise exception 'Pos-condicao falhou: concurso da questao 68 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2025 then
    raise exception 'Pos-condicao falhou: ano da questao 68 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 59 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 68 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 68 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 68;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 68 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 68 and ordem = 3 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 68 nao e mais a alternativa de ordem 3 (C)';
  end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 68) then
    raise exception 'Pos-condicao falhou: questao 68 possui vinculo pedagogico inesperado (deveria permanecer nao vinculada)';
  end if;

  raise notice 'Pos-condicoes OK: enunciado restaurado com fidelidade, alternativas/gabarito/explicacao/proveniencia/assunto_id/ativa inalterados, questao 68 permanece sem vinculo pedagogico.';
end $$;

commit;
