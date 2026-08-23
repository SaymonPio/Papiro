-- SANEAMENTO DE FIDELIDADE — Q122 (curso_conteudo_id 23, Significacao das
-- palavras) — operacao independente, separada da futura classificacao
-- pedagogica.
--
-- Fonte: Fundatec, Brigada Militar RS, Soldado Nivel III, 2022. Texto
-- "Modernidade de ocasiao", de M. Medeiros. Texto e comando original
-- recuperados de reproducao publica da prova (aio.com.br), com
-- cross-check read-only contra os fragmentos ja existentes no banco em
-- Q116 e Q123 (mesma prova/mesmo texto-base) — ambos os fragmentos
-- ("os jovens renovam o vocabulario, reforcam sua superioridade sobre os
-- caqueticos e mantem a classificacao de certo e errado sob seu dominio"
-- em Q116; "Quem for diferente da sua tribo lhes parecera sem nocao" em
-- Q123) batem palavra por palavra com as linhas 26-28 e 28-29 do texto
-- recuperado, sem nenhuma divergencia material — cross-check aprovado
-- antes deste write.
--
-- As lacunas pontilhadas/sublinhadas nas linhas 01,02,04,09,10,12,20,24,
-- 30,33,34,36 pertencem editorialmente a uma OUTRA questao (provavelmente
-- de crase) do mesmo caderno, que nao foi importada para o Papiro (nenhum
-- QID ativo depende delas — verificado por busca no corpus). Foram
-- preservadas exatamente como apareciam na fonte, sem preenchimento por
-- inferencia, pois fazem parte do que o candidato original via impresso
-- no texto-base compartilhado.
--
-- Altera enunciado e explicacao da questao 122. Alternativas, gabarito,
-- banca, concurso, ano, assunto_id e ativa sao verificados como
-- inalterados nas pos-condicoes.
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
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual
    from public.questoes where id = 122;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 122 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Avalie as assertivas a seguir, relativas a determinados vocábulos utilizados no texto-base: I. “caquéticos” tem o mesmo significado que “matusaléns”, podendo um vocábulo ser utilizado em lugar do outro sem causar incorreção. II. O vocábulo “avexar” poderia ser substituído por “sujeitar”, mantendo-se o mesmo sentido e a correção gramatical. III. A expressão “à beça” significa em grande quantidade, podendo ser substituída por “à farta”. Quais estão corretas?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 122 diverge do valor esperado antes da restauracao — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e III.
- Assertiva I (Correta): no contexto figurado do texto, "caquéticos" e "matusaléns" são termos utilizados para designar pessoas muito velhas, idosas ou antiquadas, mantendo equivalência semântica e semântico-estilística.
- Assertiva III (Correta): a locução adverbial "à beça" significa em grande quantidade, com abundância, sendo sinônima perfeita de "à farta" ou "em profusão".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Aponta apenas a assertiva II, que está incorreta: "avexar" significa apressar, impacientar, apoquentar ou envergonhar (do linguajar regional e clássico), não equivalendo semanticamente a "sujeitar" (que significa submeter, subordinar).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, cuja correspondência de sentido é inadequada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva II e exclui a assertiva I.

BIZU DE PROVA:
Em questões de sinonímia contextual da Fundatec, sempre verifique se a substituição preserva não só o sentido aproximado, mas a classe gramatical e a regência no trecho original.' then
    raise exception 'Precondicao falhou: explicacao atual da questao 122 diverge do valor esperado antes da restauracao';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 122 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'Brigada Militar RS - Soldado Nível III' then
    raise exception 'Precondicao falhou: concurso da questao 122 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2022 then
    raise exception 'Precondicao falhou: ano da questao 122 diverge do esperado (2022) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 59 then
    raise exception 'Precondicao falhou: assunto_id da questao 122 diverge do esperado (59) — valor atual: %', v_assunto_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 122 and ativa = true) then
    raise exception 'Precondicao falhou: questao 122 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 122 and ordem = 4 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 122 nao e a alternativa de ordem 4 (D)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 122) then
    raise exception 'Precondicao falhou: questao 122 ja possui vinculo pedagogico (esperado: nenhum)';
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

Avalie as assertivas a seguir, relativas a determinados vocábulos utilizados no texto. I. “caquéticos” (l. 02 e 27) tem o mesmo significado que “matusaléns” (l. 07), podendo um vocábulo ser utilizado em lugar do outro sem causar incorreção aos momentos do texto em que ocorrem. II. O vocábulo “avexar” (l. 16) poderia ser substituído por “sujeitar”, mantendo-se o mesmo sentido e a correção gramatical. III. A expressão “à beça”, utilizada entre as linhas 20 e 22, significa em grande quantidade, podendo ser substituída, correta e adequadamente, por “à farta”. Quais estão corretas?',
       explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e III.
- Assertiva I (Correta): no texto, "caquéticos" (l. 02 e 27) e "matusaléns" (l. 07) guardam proximidade semântica nos momentos em que ocorrem — mas com uma nuance discursiva relevante: nas linhas 02 e 27, "caquéticos" é empregado pelos jovens, em tom pejorativo, para se referir aos mais velhos em geral; já "matusaléns" (l. 07) é empregado pelo próprio narrador, em tom humorístico e afetivo, para se referir aos PRÓPRIOS pais, "beirando os 40 anos". A assertiva considera a equivalência semântica aceitável nos contextos específicos dados — não se trata de sinonímia absoluta, válida em qualquer situação, mas de sinonímia contextual (ambos os termos designam, na lógica do texto, pessoas mais velhas/ultrapassadas aos olhos de quem fala).
- Assertiva III (Correta): a expressão "à beça", usada entre as linhas 20 e 22 ("vergonhoso à beça"; "retiro um ''à beça'' do baú"), significa em grande quantidade/intensidade, podendo ser substituída, no contexto dado, por "à farta", preservando a ideia de abundância/intensidade pertinente à passagem.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Aponta apenas a assertiva II, que está incorreta: no contexto da linha 16 ("Se avexar com o comportamento de quem nos antecedeu é um costume clássico"), "avexar-se" tem o sentido de incomodar-se, impacientar-se ou envergonhar-se — e não equivale semântica nem gramaticalmente a "sujeitar" (que significa submeter, subordinar). A substituição alteraria o sentido da frase e a regência do verbo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, cuja correspondência de sentido é inadequada, pelos motivos já expostos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva II (incorreta) e exclui a assertiva I (correta).

BIZU DE PROVA:
Sinonímia contextual não é sinonímia absoluta: para substituir uma palavra em uma questão de banca, verifique (1) o significado, (2) o contexto específico em que o termo ocorre, (3) o registro/nuance de quem fala, (4) a classe gramatical e a função sintática, (5) se a construção permanece gramatical após a troca, e (6) se o sentido global do trecho é preservado. Em questões da Fundatec, isso costuma aparecer testando justamente pares que soam parecidos mas divergem em regência ou registro (como "avexar" × "sujeitar" aqui).

NOTA DE SANEAMENTO: o enunciado desta questão foi restaurado a partir do caderno original da prova (Fundatec, Brigada Militar RS, Soldado Nível III, 2022 — texto "Modernidade de ocasião", de M. Medeiros), incluindo o texto-base integral com marcadores de linha [01]-[37] e as referências de linha citadas no comando original ("l. 02 e 27", "l. 07", "l. 16", "linhas 20 e 22"), anteriormente ausentes na versão armazenada. Gabarito (D) e alternativas permanecem inalterados.',
       atualizado_em = now()
 where id = 122;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 122;
  if position('[01]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [01] ausente'; end if;
  if position('[02]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [02] ausente'; end if;
  if position('[07]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [07] ausente'; end if;
  if position('[16]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [16] ausente'; end if;
  if position('[20]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [20] ausente'; end if;
  if position('[21]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [21] ausente'; end if;
  if position('[22]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [22] ausente'; end if;
  if position('[27]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [27] ausente'; end if;
  if position('[37]' in v_novo) = 0 then raise exception 'Pos-condicao falhou: marcador [37] ausente'; end if;
  if position('caquéticos' in v_novo) = 0 then raise exception 'Pos-condicao falhou: "caquéticos" ausente'; end if;
  if position('matusaléns' in v_novo) = 0 then raise exception 'Pos-condicao falhou: "matusaléns" ausente'; end if;
  if position('avexar' in v_novo) = 0 then raise exception 'Pos-condicao falhou: "avexar" ausente'; end if;
  if position('à beça' in v_novo) = 0 then raise exception 'Pos-condicao falhou: "à beça" ausente'; end if;
  if position('(l. 02 e 27)' in v_novo) = 0 then raise exception 'Pos-condicao falhou: referencia de linha (l. 02 e 27) ausente'; end if;
  if position('(l. 07)' in v_novo) = 0 then raise exception 'Pos-condicao falhou: referencia de linha (l. 07) ausente'; end if;
  if position('(l. 16)' in v_novo) = 0 then raise exception 'Pos-condicao falhou: referencia de linha (l. 16) ausente'; end if;
  if position('entre as linhas 20 e 22' in v_novo) = 0 then raise exception 'Pos-condicao falhou: referencia de linha 20-22 ausente'; end if;
  if position('utilizados no texto-base' in v_novo) > 0 then raise exception 'Pos-condicao falhou: redacao reduzida antiga ("no texto-base") ainda presente'; end if;
end $$;

do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 122;
  select (length(v_novo) - length(replace(v_novo, 'Avalie as assertivas a seguir, relativas a determinados vocábulos utilizados no texto. I. “caquéticos” (l. 02 e 27) tem o mesmo significado que “matusaléns” (l. 07), podendo um vocábulo ser utilizado em lugar do outro sem causar incorreção aos momentos do texto em que ocorrem. II. O vocábulo “avexar” (l. 16) poderia ser substituído por “sujeitar”, mantendo-se o mesmo sentido e a correção gramatical. III. A expressão “à beça”, utilizada entre as linhas 20 e 22, significa em grande quantidade, podendo ser substituída, correta e adequadamente, por “à farta”. Quais estão corretas?', ''))) / greatest(length('Avalie as assertivas a seguir, relativas a determinados vocábulos utilizados no texto. I. “caquéticos” (l. 02 e 27) tem o mesmo significado que “matusaléns” (l. 07), podendo um vocábulo ser utilizado em lugar do outro sem causar incorreção aos momentos do texto em que ocorrem. II. O vocábulo “avexar” (l. 16) poderia ser substituído por “sujeitar”, mantendo-se o mesmo sentido e a correção gramatical. III. A expressão “à beça”, utilizada entre as linhas 20 e 22, significa em grande quantidade, podendo ser substituída, correta e adequadamente, por “à farta”. Quais estão corretas?'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 122 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
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
    from public.questoes where id = 122;

  if v_explicacao is distinct from 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e III.
- Assertiva I (Correta): no texto, "caquéticos" (l. 02 e 27) e "matusaléns" (l. 07) guardam proximidade semântica nos momentos em que ocorrem — mas com uma nuance discursiva relevante: nas linhas 02 e 27, "caquéticos" é empregado pelos jovens, em tom pejorativo, para se referir aos mais velhos em geral; já "matusaléns" (l. 07) é empregado pelo próprio narrador, em tom humorístico e afetivo, para se referir aos PRÓPRIOS pais, "beirando os 40 anos". A assertiva considera a equivalência semântica aceitável nos contextos específicos dados — não se trata de sinonímia absoluta, válida em qualquer situação, mas de sinonímia contextual (ambos os termos designam, na lógica do texto, pessoas mais velhas/ultrapassadas aos olhos de quem fala).
- Assertiva III (Correta): a expressão "à beça", usada entre as linhas 20 e 22 ("vergonhoso à beça"; "retiro um ''à beça'' do baú"), significa em grande quantidade/intensidade, podendo ser substituída, no contexto dado, por "à farta", preservando a ideia de abundância/intensidade pertinente à passagem.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Aponta apenas a assertiva II, que está incorreta: no contexto da linha 16 ("Se avexar com o comportamento de quem nos antecedeu é um costume clássico"), "avexar-se" tem o sentido de incomodar-se, impacientar-se ou envergonhar-se — e não equivale semântica nem gramaticalmente a "sujeitar" (que significa submeter, subordinar). A substituição alteraria o sentido da frase e a regência do verbo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, cuja correspondência de sentido é inadequada, pelos motivos já expostos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva II (incorreta) e exclui a assertiva I (correta).

BIZU DE PROVA:
Sinonímia contextual não é sinonímia absoluta: para substituir uma palavra em uma questão de banca, verifique (1) o significado, (2) o contexto específico em que o termo ocorre, (3) o registro/nuance de quem fala, (4) a classe gramatical e a função sintática, (5) se a construção permanece gramatical após a troca, e (6) se o sentido global do trecho é preservado. Em questões da Fundatec, isso costuma aparecer testando justamente pares que soam parecidos mas divergem em regência ou registro (como "avexar" × "sujeitar" aqui).

NOTA DE SANEAMENTO: o enunciado desta questão foi restaurado a partir do caderno original da prova (Fundatec, Brigada Militar RS, Soldado Nível III, 2022 — texto "Modernidade de ocasião", de M. Medeiros), incluindo o texto-base integral com marcadores de linha [01]-[37] e as referências de linha citadas no comando original ("l. 02 e 27", "l. 07", "l. 16", "linhas 20 e 22"), anteriormente ausentes na versão armazenada. Gabarito (D) e alternativas permanecem inalterados.' then
    raise exception 'Pos-condicao falhou: explicacao da questao 122 nao corresponde a versao revisada esperada';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 122 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'Brigada Militar RS - Soldado Nível III' then
    raise exception 'Pos-condicao falhou: concurso da questao 122 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2022 then
    raise exception 'Pos-condicao falhou: ano da questao 122 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 59 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 122 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 122 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 122;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 122 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 122 and ordem = 4 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 122 nao e mais a alternativa de ordem 4 (D)';
  end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 122) then
    raise exception 'Pos-condicao falhou: questao 122 possui vinculo pedagogico inesperado (deveria permanecer nao vinculada)';
  end if;

  raise notice 'Pos-condicoes OK: enunciado e explicacao restaurados com fidelidade, alternativas/gabarito/proveniencia/assunto_id/ativa inalterados, questao 122 permanece sem vinculo pedagogico.';
end $$;

commit;
