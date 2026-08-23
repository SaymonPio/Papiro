-- SANEAMENTO DE FIDELIDADE — Q120 (curso_conteudo_id 17, Regencia
-- verbal e nominal) — operacao independente, separada da curadoria ja
-- concluida (commit 6292727). NAO altera o vinculo pedagogico existente.
--
-- Fonte: Fundatec, Brigada Militar RS, Soldado Nivel III, 2022, Questao
-- 02. Texto "Modernidade de ocasiao", de M. Medeiros — o MESMO texto ja
-- recuperado e validado para Q122 (commit 1d8ad27, mesma prova). O
-- enunciado armazenado de Q120 continha fragmentos parafraseados/
-- reconstruidos ("o cenario em que nos encontramos", "as transformacoes
-- que presenciamos", "o autor cujo obra foi citada"), que NAO
-- correspondem ao texto real da prova. Cross-check read-only confirmou
-- que as linhas [04], [09] e [20] de Q122 correspondem exatamente as
-- tres lacunas do comando original ("lacunas pontilhadas das linhas 04,
-- 09 e 20"), sem divergencia material.
--
-- Altera enunciado e explicacao da questao 120. Alternativas, gabarito
-- (A), banca, concurso, ano, assunto_id, ativa e o vinculo pedagogico
-- existente sao verificados como inalterados nas pos-condicoes. Q122
-- e verificada como inalterada (fonte do texto-base reaproveitado, nao
-- alvo desta operacao).
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
  v_vinculos int;
  v_q122_enunciado text;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual
    from public.questoes where id = 120;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 120 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando o emprego dos pronomes relativos e as regras de regência da norma-padrão, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos trechos a seguir:

1. "...o cenário _____ nos encontramos..."
2. "...as transformações _____ presenciamos..."
3. "...o autor _____ obra foi citada..."' then
    raise exception 'Precondicao falhou: enunciado atual da questao 120 diverge do valor esperado antes da restauracao — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento correto das lacunas é "em que – que – cujo":
1) "em que": o termo antecedente designa lugar/situação em que algo ocorre, exigindo a preposição "em" associada ao pronome relativo ("no qual" / "em que").
2) "que": pronome relativo de uso geral, exercendo função de sujeito ou objeto direto sem exigência de preposição.
3) "cujo": pronome relativo que estabelece relação de posse entre dois substantivos ("substantivo + cujo + substantivo possuído"), sem preposição antecedente e SEM emprego de artigo após o pronome.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega a forma "cujo o", o que constitui erro gramatical grave: a norma culta proíbe expressamente o uso de artigo definido imediatamente após o pronome relativo "cujo" (não existe "cujo o", "cuja a").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Emprega a preposição "de" indevidamente na primeira ("de que") e na terceira ("de cujo") lacunas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta a construção aglutinada "cujo o qual", completamente inexistente na norma-padrão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Emprega a forma redundante "cujo qual".

BIZU DE PROVA:
Regras sagradas do pronome CUJO:
1) Fica sempre entre dois substantivos e indica posse ("autor cujo livro li").
2) NUNCA admite artigo depois de si: "cujo o", "cuja a", "cujos os" NÃO EXISTEM em português culto!' then
    raise exception 'Precondicao falhou: explicacao atual da questao 120 diverge do valor esperado antes da restauracao';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 120 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'Brigada Militar RS - Soldado Nível III' then
    raise exception 'Precondicao falhou: concurso da questao 120 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2022 then
    raise exception 'Precondicao falhou: ano da questao 120 diverge do esperado (2022) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 42 then
    raise exception 'Precondicao falhou: assunto_id da questao 120 diverge do esperado (42) — valor atual: %', v_assunto_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 120 and ativa = true) then
    raise exception 'Precondicao falhou: questao 120 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 120 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 120 nao e a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 120;
  if v_vinculos <> 1 then
    raise exception 'Precondicao falhou: questao 120 possui % vinculo(s) (esperado exatamente 1, ja existente)', v_vinculos;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 120 and unidade_pedagogica_id = '735f736a-37c0-477f-a555-dcd73d243d21') then
    raise exception 'Precondicao falhou: o vinculo existente da questao 120 nao aponta para a unidade esperada';
  end if;

  -- Cross-check: Q122 deve permanecer com o texto-base ja saneado
  -- (fonte reaproveitada), confirmando estabilidade antes do write.
  select enunciado into v_q122_enunciado from public.questoes where id = 122;
  if position('[04] Eu devia ter uns 14 anos' in v_q122_enunciado) = 0
     or position('[09] expressão' in v_q122_enunciado) = 0
     or position('[20] Minha filha considera vergonhoso' in v_q122_enunciado) = 0 then
    raise exception 'Precondicao falhou: texto-base saneado da questao 122 nao esta no estado esperado (fonte reaproveitada instavel)';
  end if;
end $$;

update public.questoes
   set enunciado = '[01] Refleti cinco minutos sobre a questão e cheguei ... conclusão óbvia: na dificuldade de
[02] serem menos _________, os jovens reforçam sua superioridade sobre os caquéticos e mantêm
[03] a classificação de certo e errado sob seu domínio.
[04] Eu devia ter uns 14 anos e estava numa festa ......... meus pais também estavam. Até
[05] que tocou uma música. Percebi que era da banda preferida deles. Então olhei para o meio do
[06] salão e, ato contínuo, tapei os olhos, abrindo uma fresta entre os dedos para ter certeza: eles
[07] estavam dançando. Meu pai, minha mãe. Dois matusaléns beirando os 40 anos, parecendo um
[08] casal de travoltas. Que mico. Aliás, naquela época não se dizia "que mico". Não lembro a
[09] expressão ......... se usava para a sensação de querer cavar um buraco e sumir. Será que minhas
[10] amigas estavam percebendo o "tio" e a "tia" jogando a cabeça para ____ e os braços para o
[11] alto? Acho que não, elas deviam estar chocadas com os próprios pais, que também combatiam
[12] ... morte ao som dos Bee Gees. Hoje esse constrangimento adolescente tem nome: cringe.
[13] É uma gíria americana que está sendo utilizada para determinar algo que nos faz sentir
[14] vergonha alheia. Crítica sumária aos mais velhos, tipo ver a prima de 26 anos postando uma
[15] dancinha do Tik Tok ou sua mãe escrevendo "tipo" em vez de "como".
[16] Mais essa para o museu de grandes novidades. Se avexar com o comportamento de quem
[17] nos antecedeu é um costume clássico. O tribunal do mundo e seu júri impiedoso: olha a coitada
[18] que ainda mantém um perfil no Face, olha a calça skinny daquela grandona, olha essa gente que
[19] ainda é fã do Harry Potter, olha a millennial viciada em café. Cringe.
[20] Minha filha considera vergonhoso à beça usar palavras em inglês ........ vocábulo
[21] equivalente está disponível em nosso dicionário. E a outra filha desmaia cada vez que retiro um
[22] "à beça" do baú. As duas ficaram um tanto preocupadas quando comentei que estava pensando
[23] em escrever sobre esse assunto.
[24] Ninguém escapa. Você também será cringe por usar a roupa errada, assistir ... série
[25] errada, defender a causa errada, nascer no ano errado. Refleti mais cinco minutos sobre a
[26] questão e me deparei com a conclusão óbvia: na dificuldade de serem menos cruéis, os jovens
[27] renovam o vocabulário, reforçam sua superioridade sobre os caquéticos e mantêm a classificação
[28] de certo e errado sob seu domínio. Quem for diferente da sua tribo lhes parecerá sem noção e
[29] os envergonhará, e suas próprias manias e esquisitices envergonharão os que vierem logo
[30] depois. E assim caminha a humanidade, com as gerações indefinidamente __________ umas às
[31] outras.
[32] Nós, os maduros de 50 e tantos, os coroas de 60+, observamos, a uma distância segura,
[33] esses recursos linguísticos pretensamente modernos, porém fadados ao desgaste e ...
[34] substituição, e ... vezes até adotamos a mesma linguagem, pegando uma carona no frescor
[35] juvenil. Mas nada como a atemporal liberdade de expressão em suas variadas formas: se a
[36] música é boa e o amanhã não existe, é nós na pista, jogando a cabeça para onde __________ e
[37] os braços para o alto, pensem o que pensarem.
(Texto: "Modernidade de ocasião", de M. Medeiros — adaptado para esta prova.)

Considerando o uso dos pronomes relativos e os aspectos próprios da regência, assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas das linhas 04, 09 e 20.',
       explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento correto das lacunas é "em que – que – cujo":
1) linha 04 ("Eu devia ter uns 14 anos e estava numa festa ___ meus pais também estavam"): reconstruindo a oração relativa a partir do antecedente ("festa"), tem-se "meus pais também estavam NA festa" — o verbo "estar", nesse sentido de localização, rege a preposição "em", logo "em que".
2) linha 09 ("Não lembro a expressão ___ se usava para a sensação de querer cavar um buraco e sumir"): reconstruindo, "usava-se A expressão" — o verbo "usar" é transitivo direto nesse contexto (toma "a expressão" como objeto direto, sem preposição), logo apenas "que".
3) linha 20 ("...usar palavras em inglês ___ vocábulo equivalente está disponível em nosso dicionário"): "cujo" relaciona o antecedente ("palavras em inglês") ao substantivo posterior ("vocábulo equivalente"), concordando em gênero e número com este último — "vocábulo" é masculino singular, logo "cujo vocábulo"; a norma culta proíbe o uso de artigo entre "cujo" e o substantivo posterior.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega a forma "cujo o", o que constitui erro gramatical grave: a norma culta proíbe expressamente o uso de artigo definido imediatamente após o pronome relativo "cujo" (não existe "cujo o", "cuja a").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Emprega a preposição "de" indevidamente na primeira ("de que") e na terceira ("de cujo") lacunas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta a construção aglutinada "cujo o qual", completamente inexistente na norma-padrão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Emprega a forma redundante "cujo qual".

BIZU DE PROVA:
Regras sagradas do pronome CUJO:
1) Fica sempre entre dois substantivos e indica posse/relação ("palavras em inglês cujo vocábulo equivalente...").
2) NUNCA admite artigo depois de si: "cujo o", "cuja a", "cujos os" NÃO EXISTEM em português culto!
3) Concorda em gênero e número com o substantivo POSTERIOR (não com o antecedente) — aqui "vocábulo" (masculino singular) exige "cujo"; se o substantivo posterior fosse feminino (ex.: "obra"), a forma correta seria "cuja obra".

NOTA DE SANEAMENTO: o enunciado desta questão foi restaurado a partir do caderno original da prova (Fundatec, Brigada Militar RS, Soldado Nível III, 2022, Questão 02), reaproveitando o mesmo texto-base "Modernidade de ocasião" (M. Medeiros) já recuperado e validado para a Q122 (mesma prova), incluindo os marcadores de linha [01]-[37] e a citação das linhas 04, 09 e 20 no comando original, anteriormente ausentes na versão armazenada (que continha fragmentos parafraseados: "o cenário em que nos encontramos", "as transformações que presenciamos", "o autor cujo obra foi citada"). Gabarito (A) e alternativas permanecem inalterados.',
       atualizado_em = now()
 where id = 120;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 120;
  if position('[01]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [01] ausente'; end if;
  if position('[04]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [04] ausente'; end if;
  if position('[09]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [09] ausente'; end if;
  if position('[20]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [20] ausente'; end if;
  if position('[37]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [37] ausente'; end if;
  if position('linhas 04, 09 e 20' in v_novo) = 0 then raise exception 'Pos-condicao falhou: citacao "linhas 04, 09 e 20" ausente'; end if;
  if position('o cenário' in v_novo) > 0 then raise exception 'Pos-condicao falhou: fragmento artificial antigo ("o cenário") ainda presente'; end if;
  if position('as transformações' in v_novo) > 0 then raise exception 'Pos-condicao falhou: fragmento artificial antigo ("as transformações") ainda presente'; end if;
  if position('o autor' in v_novo) > 0 then raise exception 'Pos-condicao falhou: fragmento artificial antigo ("o autor") ainda presente'; end if;
  if position('obra foi citada' in v_novo) > 0 then raise exception 'Pos-condicao falhou: fragmento artificial antigo ("obra foi citada") ainda presente'; end if;
end $$;

do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 120;
  select (length(v_novo) - length(replace(v_novo, 'Considerando o uso dos pronomes relativos e os aspectos próprios da regência, assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas das linhas 04, 09 e 20.', ''))) / greatest(length('Considerando o uso dos pronomes relativos e os aspectos próprios da regência, assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas das linhas 04, 09 e 20.'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 120 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
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
  v_vinculos int;
  v_q122_enunciado text;
begin
  select explicacao, banca, concurso, ano, assunto_id, ativa
    into v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 120;

  if v_explicacao is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento correto das lacunas é "em que – que – cujo":
1) linha 04 ("Eu devia ter uns 14 anos e estava numa festa ___ meus pais também estavam"): reconstruindo a oração relativa a partir do antecedente ("festa"), tem-se "meus pais também estavam NA festa" — o verbo "estar", nesse sentido de localização, rege a preposição "em", logo "em que".
2) linha 09 ("Não lembro a expressão ___ se usava para a sensação de querer cavar um buraco e sumir"): reconstruindo, "usava-se A expressão" — o verbo "usar" é transitivo direto nesse contexto (toma "a expressão" como objeto direto, sem preposição), logo apenas "que".
3) linha 20 ("...usar palavras em inglês ___ vocábulo equivalente está disponível em nosso dicionário"): "cujo" relaciona o antecedente ("palavras em inglês") ao substantivo posterior ("vocábulo equivalente"), concordando em gênero e número com este último — "vocábulo" é masculino singular, logo "cujo vocábulo"; a norma culta proíbe o uso de artigo entre "cujo" e o substantivo posterior.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega a forma "cujo o", o que constitui erro gramatical grave: a norma culta proíbe expressamente o uso de artigo definido imediatamente após o pronome relativo "cujo" (não existe "cujo o", "cuja a").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Emprega a preposição "de" indevidamente na primeira ("de que") e na terceira ("de cujo") lacunas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta a construção aglutinada "cujo o qual", completamente inexistente na norma-padrão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Emprega a forma redundante "cujo qual".

BIZU DE PROVA:
Regras sagradas do pronome CUJO:
1) Fica sempre entre dois substantivos e indica posse/relação ("palavras em inglês cujo vocábulo equivalente...").
2) NUNCA admite artigo depois de si: "cujo o", "cuja a", "cujos os" NÃO EXISTEM em português culto!
3) Concorda em gênero e número com o substantivo POSTERIOR (não com o antecedente) — aqui "vocábulo" (masculino singular) exige "cujo"; se o substantivo posterior fosse feminino (ex.: "obra"), a forma correta seria "cuja obra".

NOTA DE SANEAMENTO: o enunciado desta questão foi restaurado a partir do caderno original da prova (Fundatec, Brigada Militar RS, Soldado Nível III, 2022, Questão 02), reaproveitando o mesmo texto-base "Modernidade de ocasião" (M. Medeiros) já recuperado e validado para a Q122 (mesma prova), incluindo os marcadores de linha [01]-[37] e a citação das linhas 04, 09 e 20 no comando original, anteriormente ausentes na versão armazenada (que continha fragmentos parafraseados: "o cenário em que nos encontramos", "as transformações que presenciamos", "o autor cujo obra foi citada"). Gabarito (A) e alternativas permanecem inalterados.' then
    raise exception 'Pos-condicao falhou: explicacao da questao 120 nao corresponde a versao revisada esperada';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 120 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'Brigada Militar RS - Soldado Nível III' then
    raise exception 'Pos-condicao falhou: concurso da questao 120 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2022 then
    raise exception 'Pos-condicao falhou: ano da questao 120 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 42 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 120 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 120 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 120;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 120 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 120 and ordem = 1 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 120 nao e mais a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 120;
  if v_vinculos <> 1 then
    raise exception 'Pos-condicao falhou: questao 120 possui % vinculo(s) (esperado exatamente 1, preservado)', v_vinculos;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 120 and unidade_pedagogica_id = '735f736a-37c0-477f-a555-dcd73d243d21') then
    raise exception 'Pos-condicao falhou: o vinculo da questao 120 nao aponta mais para a unidade esperada';
  end if;

  -- Confirma que Q122 (fonte reaproveitada) nao foi alterada por este apply.
  select enunciado into v_q122_enunciado from public.questoes where id = 122;
  if position('[04] Eu devia ter uns 14 anos' in v_q122_enunciado) = 0
     or position('[37] os braços para o alto' in v_q122_enunciado) = 0 then
    raise exception 'Pos-condicao falhou: texto-base da questao 122 foi alterado indevidamente por este apply';
  end if;

  raise notice 'Pos-condicoes OK: enunciado e explicacao da questao 120 restaurados com fidelidade (texto-base [01]-[37] + comando com citacao das linhas 04/09/20), alternativas/gabarito/proveniencia/assunto_id/ativa/vinculo inalterados, questao 122 (fonte reaproveitada) permanece intacta.';
end $$;

rollback;
