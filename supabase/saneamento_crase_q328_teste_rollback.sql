-- OPERACAO DE SANEAMENTO — Restauracao de fidelidade da Q328 (Crase)
--
-- Q328 corresponde a QUESTAO 04 do caderno original Fundatec, CBM-RS,
-- Soldado Bombeiro Militar Primeira Classe, 2025 (973_BASE_NM_DT). O
-- enunciado armazenado no Papiro continha lacunas parafraseadas
-- ("adaptadas a novas necessidades", "com relacao a prevencao",
-- "somadas a bombas manuais") que NAO correspondem ao texto real da
-- prova nas linhas 17, 19 e 28 citadas pela propria explicacao
-- armazenada. Esta operacao restaura o texto-base integral (com
-- marcadores [NN] de linha, mesmo padrao ja aprovado em Q69/Q324/Q333)
-- e o comando original da QUESTAO 04, e reescreve a explicacao para
-- fundamentar-se nos trechos reais, preservando integralmente o
-- gabarito (alternativa D, a-a-a com crase), confirmado pelo Gabarito
-- Definitivo oficial (Edital DA/DRH no SD-B 14/2025, CBMRS, publicado
-- em 15/07/2025).
--
-- Fonte do texto-base: mesmo artigo "Historia do surgimento do Corpo
-- de Bombeiros" ja recuperado e usado no saneamento de Q333 (Coesao
-- textual, commit 51e5851) — mesmo PDF original, mesmas linhas 01-36.
--
-- Altera SOMENTE enunciado e explicacao de Q328. Alternativas,
-- gabarito, banca, concurso, ano, assunto_id e ativa sao verificados
-- como inalterados nas pos-condicoes.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_ativa boolean;
  v_assunto_id bigint;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_gabarito_atual text;
  v_alt_count int;
  v_vinculos int;
begin
  select enunciado, explicacao, ativa, assunto_id, banca, concurso, ano
    into v_enunciado_atual, v_explicacao_atual, v_ativa, v_assunto_id, v_banca, v_concurso, v_ano
  from public.questoes where id = 328;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 328 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando o emprego do acento indicativo de crase segundo a norma-padrão, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos seguintes trechos:

1. "...adaptadas _____ novas necessidades..."
2. "...com relação _____ prevenção..."
3. "...somadas _____ bombas manuais..."' then
    raise exception 'Precondicao falhou: enunciado atual da questao 328 diverge do valor esperado antes da restauracao';
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O preenchimento correto das lacunas das linhas 17, 19 e 28 é "à – à – à" (todas com crase):
- Lacuna da linha 17: ocorre crase ("à") diante de substantivo feminino determinado por regência com preposição "a".
- Lacuna da linha 19: ocorre crase ("à") em locução adverbial ou prepositiva feminina que exige acento indicativo de crase.
- Lacuna da linha 28: ocorre crase ("à") por fusão da preposição "a" exigida pelo termo regente com o artigo feminino "a" do termo regido.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Omite a crase nas duas primeiras lacunas, violando as regras obrigatórias de regência e locução feminina.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Omite a crase na segunda e na terceira lacunas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite a crase na primeira e na terceira lacunas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite a crase na primeira lacuna.

BIZU DE PROVA:
Nas questões da Fundatec para a Brigada Militar e Bombeiros, verifique as 3 regras fundamentais:
1) Verbo transitivo indireto com preposição "A" + Palavra feminina com artigo "A" = CRASE (à).
2) Locuções adverbiais, prepositivas e conjuntivas femininas = SEMPRE CRASE ("à proporção que", "à noite", "à disposição").' then
    raise exception 'Precondicao falhou: explicacao atual da questao 328 diverge do valor esperado antes da restauracao';
  end if;
  if v_ativa is distinct from true then
    raise exception 'Precondicao falhou: questao 328 nao esta ativa=true';
  end if;
  if v_assunto_id is distinct from 5 then
    raise exception 'Precondicao falhou: assunto_id da questao 328 = % (esperado 5)', v_assunto_id;
  end if;
  if v_banca <> 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 328 = % (esperado Fundatec)', v_banca;
  end if;
  if v_concurso <> 'Corpo de Bombeiros Militar RS - Soldado de Primeira Classe' then
    raise exception 'Precondicao falhou: concurso da questao 328 = % (esperado Corpo de Bombeiros Militar RS - Soldado de Primeira Classe)', v_concurso;
  end if;
  if v_ano <> 2025 then
    raise exception 'Precondicao falhou: ano da questao 328 = % (esperado 2025)', v_ano;
  end if;

  select a.texto into v_gabarito_atual from public.alternativas a where a.questao_id = 328 and a.correta = true;
  if v_gabarito_atual is distinct from 'à – à – à' then
    raise exception 'Precondicao falhou: alternativa correta atual da questao 328 = % (esperado "à – à – à")', v_gabarito_atual;
  end if;

  select count(*) into v_alt_count from public.alternativas where questao_id = 328;
  if v_alt_count <> 5 then
    raise exception 'Precondicao falhou: questao 328 tem % alternativas (esperado 5)', v_alt_count;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 328;
  if v_vinculos <> 0 then
    raise exception 'Precondicao falhou: questao 328 ja possui % vinculo(s) pedagogico(s) — esperado 0', v_vinculos;
  end if;
end $$;

update public.questoes
   set enunciado = '[01] Segundo registros históricos, uma das primeiras equipes organizadas para o combate ao
[02] fogo surgiu nas cidades do Império Romano no ano 22 a.C., quando a capital foi devastada por
[03] um grande incêndio. O Imperador Otávio Augusto ficou tão atribulado com este acontecimento
[04] que, no ano 27 a.C., decidiu criar o que se pode chamar de primeiro corpo de bombeiros
[05] organizado, nomeados de “Vigiles”, sendo responsáveis pela segurança de Roma.
[06] Segundo o Corpo de Bombeiro de Goiás, com o passar dos séculos, essas organizações
[07] foram evoluindo, mas ainda eram poucas. A partir do século XVI, com o desenvolvimento da
[08] Europa, os incêndios se tornaram frequentes. Mais tarde, na metade do século XVII, os materiais
[09] utilizados para combate aos incêndios eram basicamente machados, enxadões, baldes e outros.
[10] As regiões mais desenvolvidas contavam com máquinas hidráulicas que eram conectadas a
[11] poços de vizinhos e enchiam os baldes que eram passados de mão em mão até o fogo.
[12] Por volta de 1657, o inventor alemão Hans Hautsch aperfeiçoou as bombas de incêndio
[13] existentes, que passaram a fazer ao mesmo tempo sucção e pressão, sendo que em 1672, outro
[14] inventor, um pintor holandês chamado Jan Van der Heyden, desenvolveu a primeira mangueira
[15] de combate a incêndio, confeccionada em couro e bronze nas extremidades, abrindo uma nova
[16] era na luta contra o fogo (Malutta, 2018).
[17] Essas novas ferramentas colocaram fim ___ utilização de baldes. A aparição dessas bombas
[18] de incêndio fez com que se organizasse em Paris (França) uma companhia com homens chamados
[19] de “guarda-bombas”, que eram uniformizados, recebiam salário e estavam sujeitos ___
[20] disciplina militar. Foi um dos primeiros corpos de bombeiros organizado, parecido com os atuais,
[21] e, em pouco tempo, todas as principais cidades do mundo ocidental já possuíam um, seja por
[22] disposição legal ou por iniciativa de companhias de seguros, como na Escócia e Inglaterra (Corpo
[23] de Bombeiros Militar de Goiás, 2016).
[24] No ano de 1721, o inventor inglês Richard Newsham promoveu grandes melhoramentos
[25] nas bombas manuais, que passaram a ter alcance vertical de até 36 m, fazendo com que os
[26] grupamentos pudessem trabalhar em times de 4 a 12 homens (Malutta, 2018). Ao longo dos anos,
[27] após a civilização passar por grandes evoluções, surgiu em 1905, na Inglaterra, o primeiro
[28] caminhão de combate a incêndio com motor ___ combustão, otimizando de forma indescritível o
[29] serviço de combate a incêndios (Malutta, 2018).
[30] O Corpo de Bombeiros no Brasil foi baseado em dois modelos europeus, o francês, formado
[31] por bombeiros militares, e o português, formado principalmente por bombeiros civis voluntários.
[32] Em 02 de julho de 1856, surge o primeiro serviço público de combate a incêndios, fundado pelo
[33] Imperador Dom Pedro II, por meio do Decreto Imperial nº 1775, utilizando materiais e
[34] equipamentos dos Arsenais de Guerra e da Marinha, da Repartição de Obras Públicas e da Casa
[35] de Correção, que reunidos passaram a formar o Corpo de Bombeiros Provisório da Corte (Ortiz,
[36] 2003).
(Texto: "História do surgimento do Corpo de Bombeiros", por André Gustavo Possi Scamardi e Luciana Mayumi Nanya. Texto adaptado especialmente para esta prova.)

Considerando o emprego do acento indicativo de crase, assinale a alternativa que preenche, correta e respectivamente, as lacunas tracejadas das linhas 17, 19 e 28.',
       explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O preenchimento correto e respectivo das lacunas das linhas 17, 19 e 28 é "à – à – à" (todas com crase):

- LACUNA 1 (linha 17): "Essas novas ferramentas colocaram fim à utilização de baldes." A locução "colocar fim a" rege a preposição "a"; "utilização" é substantivo feminino que admite o artigo definido "a" ("a utilização de baldes"). Da fusão preposição + artigo resulta a crase: "à utilização".

- LACUNA 2 (linhas 19-20): "[...] estavam sujeitos à disciplina militar." O adjetivo "sujeito" rege a preposição "a"; "disciplina militar" é substantivo feminino que admite o artigo definido "a". Da fusão preposição + artigo resulta a crase: "à disciplina militar".

- LACUNA 3 (linha 28): "[...] com motor à combustão, otimizando [...]". ATENÇÃO: este caso não deve ser ensinado como regra universal. A FUNDATEC manteve, no gabarito definitivo desta prova (pós-recurso), a forma "motor à combustão", fundamentando sua decisão em referência a Evanildo Bechara, e reconhecendo que Domingos Paschoal Cegalla admite a facultatividade do acento indicativo de crase em determinadas locuções adverbiais de meio/instrumento (como em "motor a/à combustão", "fogão a/à lenha"). Trata-se, portanto, do ENTENDIMENTO ESPECÍFICO ADOTADO PELA BANCA NESTA QUESTÃO, não de uma regra normativa incontestável — há tradição gramatical (majoritária em compêndios escolares) que trata expressões desse tipo ("motor a diesel", "fogão a lenha", "avião a jato") como não cabíveis de crase, por descreverem o meio/tipo de funcionamento de forma genérica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Omite a crase nas duas primeiras lacunas, violando as regras obrigatórias de regência e locução feminina.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Omite a crase na segunda e na terceira lacunas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite a crase na primeira e na terceira lacunas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite a crase na primeira lacuna.

BIZU DE PROVA:
1) Verbo/locução transitiva indireta com preposição "a" + substantivo feminino determinado = crase (à), como em "à utilização", "à disciplina militar".
2) Locuções adverbiais de meio/instrumento com substantivo feminino ("a/à combustão", "a/à lenha", "a/à diesel") são zona de divergência doutrinária — verificar o entendimento adotado pela banca na questão específica, sem tratar como regra fechada em qualquer direção.

NOTA DE SANEAMENTO: o enunciado e a explicação desta questão foram restaurados a partir do caderno original da prova (Fundatec, CBM-RS, Soldado Bombeiro Militar Primeira Classe, 2025, caderno 973_BASE_NM_DT, QUESTÃO 04) e do gabarito definitivo oficial (Edital DA/DRH nº SD-B 14/2025, publicado em 15/07/2025, que confirma a alternativa D). O enunciado armazenado anteriormente continha lacunas parafraseadas ("adaptadas a novas necessidades", "com relação a prevenção", "somadas a bombas manuais") que não correspondiam ao texto real da prova nas linhas citadas; o gabarito (D) e as alternativas foram mantidos sem alteração.',
       atualizado_em = now()
 where id = 328;

do $$
declare
  v_novo_enunciado text;
  v_nova_explicacao text;
  v_gabarito_depois text;
  v_alt_count int;
  v_ativa boolean;
  v_assunto_id bigint;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_vinculos int;
begin
  select enunciado, explicacao into v_novo_enunciado, v_nova_explicacao
  from public.questoes where id = 328;

  if position('[01]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [01] ausente';
  end if;
  if position('[17]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [17] ausente';
  end if;
  if position('[19]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [19] ausente';
  end if;
  if position('[20]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [20] ausente';
  end if;
  if position('[28]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [28] ausente';
  end if;
  if position('[36]' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: marcador [36] ausente';
  end if;

  if position('colocaram fim ___ utilização' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: trecho real da linha 17 ausente no enunciado';
  end if;
  if position('estavam sujeitos ___' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: trecho real da linha 19 ausente no enunciado';
  end if;
  if position('motor ___ combustão' in v_novo_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: trecho real da linha 28 ausente no enunciado';
  end if;

  if position('adaptadas' in v_novo_enunciado) > 0 or position('com relação ___ prevenção' in v_novo_enunciado) > 0 or position('somadas ___ bombas manuais' in v_novo_enunciado) > 0 then
    raise exception 'Pos-condicao falhou: paráfrase antiga ainda presente no enunciado';
  end if;

  -- comando original deve aparecer exatamente uma vez
  if (length(v_novo_enunciado) - length(replace(v_novo_enunciado, 'Considerando o emprego do acento indicativo de crase, assinale a alternativa que preenche, correta e respectivamente, as lacunas tracejadas das linhas 17, 19 e 28.', ''))) <>
     (length('Considerando o emprego do acento indicativo de crase, assinale a alternativa que preenche, correta e respectivamente, as lacunas tracejadas das linhas 17, 19 e 28.'))
  then
    raise exception 'Pos-condicao falhou: comando original nao aparece exatamente uma vez no enunciado';
  end if;

  if position('motor à combustão' in v_nova_explicacao) = 0 then
    raise exception 'Pos-condicao falhou: explicacao nao contem a nota sobre "motor à combustão"';
  end if;
  if position('ENTENDIMENTO ESPECÍFICO ADOTADO PELA BANCA' in v_nova_explicacao) = 0 then
    raise exception 'Pos-condicao falhou: explicacao nao contem a nota de nao-universalidade sobre a lacuna 3';
  end if;
  if position('Bechara' in v_nova_explicacao) = 0 or position('Cegalla' in v_nova_explicacao) = 0 then
    raise exception 'Pos-condicao falhou: explicacao nao contem a referencia doutrinaria (Bechara/Cegalla)';
  end if;

  select a.texto into v_gabarito_depois from public.alternativas a where a.questao_id = 328 and a.correta = true;
  if v_gabarito_depois is distinct from 'à – à – à' then
    raise exception 'Pos-condicao falhou: gabarito da questao 328 mudou para %', v_gabarito_depois;
  end if;

  select count(*) into v_alt_count from public.alternativas where questao_id = 328;
  if v_alt_count <> 5 then
    raise exception 'Pos-condicao falhou: quantidade de alternativas da questao 328 mudou para %', v_alt_count;
  end if;

  select ativa, assunto_id, banca, concurso, ano into v_ativa, v_assunto_id, v_banca, v_concurso, v_ano
  from public.questoes where id = 328;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: questao 328 nao esta mais ativa=true';
  end if;
  if v_assunto_id is distinct from 5 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 328 mudou para %', v_assunto_id;
  end if;
  if v_banca <> 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 328 mudou para %', v_banca;
  end if;
  if v_concurso <> 'Corpo de Bombeiros Militar RS - Soldado de Primeira Classe' then
    raise exception 'Pos-condicao falhou: concurso da questao 328 mudou para %', v_concurso;
  end if;
  if v_ano <> 2025 then
    raise exception 'Pos-condicao falhou: ano da questao 328 mudou para %', v_ano;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 328;
  if v_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: questao 328 ganhou % vinculo(s) inesperado(s)', v_vinculos;
  end if;

  raise notice 'Pos-condicoes OK: enunciado restaurado com marcadores [01]-[36], trechos reais das linhas 17/19/20/28 presentes, parafrases antigas ausentes, comando original unico, explicacao saneada com nota Bechara/Cegalla, gabarito D/à-à-à preservado, alternativas/banca/concurso/ano/assunto_id/ativa inalterados, 0 vinculos.';
end $$;

rollback;
