-- OPERACAO A — Restauracao dos textos-base de Q69, Q324 e Q333
-- (curso_conteudo_id 13, Coesao textual) a partir dos cadernos originais
-- Fundatec, recuperados e validados externamente (nao reconstruidos por IA,
-- nao parafraseados). Cada linha original recebe o marcador [NN] correspondente
-- ao numero de linha do caderno original (nao a linha visual da interface).
--
-- Fontes:
--   Q69  -> Fundatec, Brigada Militar RS, Soldado de 1a Classe, 2025.
--           Caderno 976_BASE_NM_DT 14/05/2025. Texto "Quando da tragedia
--           brotam herois e licoes", por Oscar Bessi.
--   Q333 -> Fundatec, Corpo de Bombeiros Militar RS, Soldado 1a Classe, 2025.
--           Caderno 973_BASE_NM_DT 09/06/2025. Texto "Historia do surgimento
--           do Corpo de Bombeiros", por Andre Gustavo Possi Scamardi e
--           Luciana Mayumi Nanya.
--   Q324 -> Fundatec, Prefeitura de Esteio/RS, 2022. Caderno
--           642_BASE_NMT_14/2/2022. Texto sobre "O avesso da pele", de
--           Jeferson Tenorio.
--
-- Tres pequenos trechos de cada texto apresentavam artefato de decodificacao
-- de fonte no PDF (sequencias de pontos "...." no lugar de 1-2 letras), sem
-- relacao com nenhuma questao de ortografia deste pipeline (essas ficam em
-- Q66/Q68/Q329/Q330, ja armazenadas em outro lugar com seu proprio recorte).
-- Esses trechos foram reconstituidos para a grafia unica e inequivoca exigida
-- pelo contexto (ex.: "flore....er" -> "florescer", confirmado de forma
-- cruzada pela propria Q67 ja armazenada no banco, que cita o mesmo trecho
-- por extenso). Nenhuma parte relevante para as assercoes de coesao das
-- questoes 69/324/333 dependia desses trechos.
--
-- Altera SOMENTE o campo enunciado de cada questao. Alternativas, gabarito,
-- banca, concurso, ano e assunto_id sao verificados como inalterados nas
-- pos-condicoes.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';


-- ================= Questao 69 =================
do $$
declare
  v_enunciado_atual text;
begin
  select enunciado into v_enunciado_atual from public.questoes where id = 69;
  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 69 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando a coesão por referenciação, analise as afirmações a seguir: 1. Na linha 08, a palavra “seus” estabelece uma relação de posse entre “rios” e “cidades”. 2. Na linha 12, o pronome relativo “que” tem como referente o substantivo “heróis”. 3. Tanto a expressão “heróis anônimos” quanto “seres humanos iluminados” referem-se àqueles que se dedicaram a ações de solidariedade. 4. Na linha 26, o pronome “se” em “não se submete” tem como referente a palavra “homem”. O resultado da somatória dos números correspondentes às afirmações corretas é:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 69 diverge do valor esperado antes da restauracao (o texto pode ja ter sido alterado por outra operacao) — valor atual: %', v_enunciado_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 69 and ativa = true) then
    raise exception 'Precondicao falhou: questao 69 nao esta ativa=true';
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

Considerando a coesão por referenciação, analise as afirmações a seguir: 1. Na linha 08, a palavra “seus” estabelece uma relação de posse entre “rios” e “cidades”. 2. Na linha 12, o pronome relativo “que” tem como referente o substantivo “heróis”. 3. Tanto a expressão “heróis anônimos” quanto “seres humanos iluminados” referem-se àqueles que se dedicaram a ações de solidariedade. 4. Na linha 26, o pronome “se” em “não se submete” tem como referente a palavra “homem”. O resultado da somatória dos números correspondentes às afirmações corretas é:',
       atualizado_em = now()
 where id = 69;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 69;
  if position('[01]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 69', '[01]';
  end if;
  if position('[08]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 69', '[08]';
  end if;
  if position('[12]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 69', '[12]';
  end if;
  if position('[26]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 69', '[26]';
  end if;
  if position('[32]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 69', '[32]';
  end if;
end $$;


do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 69;
  select (length(v_novo) - length(replace(v_novo, 'Considerando a coesão por referenciação, analise as afirmações a seguir: 1. Na linha 08, a palavra “seus” estabelece uma relação de posse entre “rios” e “cidades”. 2. Na linha 12, o pronome relativo “que” tem como referente o substantivo “heróis”. 3. Tanto a expressão “heróis anônimos” quanto “seres humanos iluminados” referem-se àqueles que se dedicaram a ações de solidariedade. 4. Na linha 26, o pronome “se” em “não se submete” tem como referente a palavra “homem”. O resultado da somatória dos números correspondentes às afirmações corretas é:', ''))) / greatest(length('Considerando a coesão por referenciação, analise as afirmações a seguir: 1. Na linha 08, a palavra “seus” estabelece uma relação de posse entre “rios” e “cidades”. 2. Na linha 12, o pronome relativo “que” tem como referente o substantivo “heróis”. 3. Tanto a expressão “heróis anônimos” quanto “seres humanos iluminados” referem-se àqueles que se dedicaram a ações de solidariedade. 4. Na linha 26, o pronome “se” em “não se submete” tem como referente a palavra “homem”. O resultado da somatória dos números correspondentes às afirmações corretas é:'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 69 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
  end if;
end $$;


-- ================= Questao 333 =================
do $$
declare
  v_enunciado_atual text;
begin
  select enunciado into v_enunciado_atual from public.questoes where id = 333;
  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 333 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Considerando as relações de coesão referencial no texto sobre a evolução dos equipamentos de combate a incêndio, analise as assertivas a seguir:

I. O pronome relativo "que" tem como referente direto o termo antecedente "regiões".
II. O termo anafórico "Essas novas ferramentas" sintetiza e retoma as menções a "bombas de incêndio" e "primeira mangueira de combate a incêndio".
III. A especificação "alcance vertical de até 36 m" refere-se ao desempenho operacional das "bombas manuais" citadas no mesmo período.

Quais estão corretas?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 333 diverge do valor esperado antes da restauracao (o texto pode ja ter sido alterado por outra operacao) — valor atual: %', v_enunciado_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 333 and ativa = true) then
    raise exception 'Precondicao falhou: questao 333 nao esta ativa=true';
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

Considerando as relações de coesão referencial no texto sobre a evolução dos equipamentos de combate a incêndio, analise as assertivas a seguir:

I. O pronome relativo "que" tem como referente direto o termo antecedente "regiões".
II. O termo anafórico "Essas novas ferramentas" sintetiza e retoma as menções a "bombas de incêndio" e "primeira mangueira de combate a incêndio".
III. A especificação "alcance vertical de até 36 m" refere-se ao desempenho operacional das "bombas manuais" citadas no mesmo período.

Quais estão corretas?',
       atualizado_em = now()
 where id = 333;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 333;
  if position('[01]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 333', '[01]';
  end if;
  if position('[10]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 333', '[10]';
  end if;
  if position('[17]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 333', '[17]';
  end if;
  if position('[25]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 333', '[25]';
  end if;
  if position('[36]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 333', '[36]';
  end if;
end $$;


do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 333;
  select (length(v_novo) - length(replace(v_novo, 'Considerando as relações de coesão referencial no texto sobre a evolução dos equipamentos de combate a incêndio, analise as assertivas a seguir:

I. O pronome relativo "que" tem como referente direto o termo antecedente "regiões".
II. O termo anafórico "Essas novas ferramentas" sintetiza e retoma as menções a "bombas de incêndio" e "primeira mangueira de combate a incêndio".
III. A especificação "alcance vertical de até 36 m" refere-se ao desempenho operacional das "bombas manuais" citadas no mesmo período.

Quais estão corretas?', ''))) / greatest(length('Considerando as relações de coesão referencial no texto sobre a evolução dos equipamentos de combate a incêndio, analise as assertivas a seguir:

I. O pronome relativo "que" tem como referente direto o termo antecedente "regiões".
II. O termo anafórico "Essas novas ferramentas" sintetiza e retoma as menções a "bombas de incêndio" e "primeira mangueira de combate a incêndio".
III. A especificação "alcance vertical de até 36 m" refere-se ao desempenho operacional das "bombas manuais" citadas no mesmo período.

Quais estão corretas?'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 333 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
  end if;
end $$;


-- ================= Questao 324 =================
do $$
declare
  v_enunciado_atual text;
begin
  select enunciado into v_enunciado_atual from public.questoes where id = 324;
  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 324 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Com relação ao emprego de recursos de coesão referencial e pronominal, analise as assertivas a seguir:

I. A expressão anafórica "esse filho adulto" refere-se ao próprio personagem em relação aos seus pais, e não ao filho de Pedro.
II. A locução pronominal relativa "em que" pode ser substituída por "no qual" sem prejuízo da correção gramatical ou da referência estabelecida.
III. O pronome "delas" retoma anaforicamente o substantivo "suposições", que é posteriormente desdobrado em exemplos.

Quais estão corretas?' then
    raise exception 'Precondicao falhou: enunciado atual da questao 324 diverge do valor esperado antes da restauracao (o texto pode ja ter sido alterado por outra operacao) — valor atual: %', v_enunciado_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 324 and ativa = true) then
    raise exception 'Precondicao falhou: questao 324 nao esta ativa=true';
  end if;
end $$;

update public.questoes
   set enunciado = '[01] Em seu terceiro romance, O avesso da pele, publicado em 2020, Jeferson Tenório amplia
[02] suas reflexões sobre o abandono, no que se pode considerar como uma trilogia sobre o tema que
[03] se iniciou com a obra O beijo na parede (2013) e ganhou corpo (e força) em Estela sem
[04] Deus (2018). O autor trouxe em seus romances anteriores o abandono vivenciado por uma
[05] criança, João, em O Beijo na Parede, e o vivido por uma adolescente, Estela, em Estela sem
[06] Deus e, por fim, chega-se a Pedro, de O avesso da pele.
[07] O terceiro é um sujeito que se recolhe em suas lembranças, nas vivências e nas histórias
[08] que ouviu de e sobre seus pais para se entender e, quem sabe, ser capaz de lidar com o abandono
[09] que o aflige da infância ___ vida adulta e, também, o que assolou seu pai na maturidade. Pedro
[10] tem seu pai, Henrique, assassinado em uma operação policial, tal fato o leva para o recolher-se
[11] e assim poder nascer para o novo momento que irá viver.
[12] Da mesma forma como ocorre com os iniciantes no candomblé, o narrador necessitará
[13] desabrochar para essa comunidade que se apresenta para ele em sua vida adulta. Ao se perceber
[14] incompleto, Pedro dirige-se aos familiares – e aos leitores – e expõe a urgente necessidade de
[15] se recolher, porque assim conseguirá digerir todos os acontecimentos envolvidos na perda do pai
[16] e, deste modo, renascer.
[17] Quando esse filho adulto cerze os retalhos desta colcha com a linha memorialística da
[18] infância, ele consegue rasgar seu caminho, pois os vãos se transformarão em percursos possíveis
[19] para o entender-se e apresentar-se como sujeito. O porquê desta ação se justifica, tendo como
[20] base as religiões afro-brasileiras, em especial, os rituais essenciais para se tornar um adepto. Um
[21] deles é o recolhimento para a feitura de santo, que consiste em submeter o sujeito a práticas que
[22] lhe possibilitarão nascer para a comunidade religiosa em que pretende viver.
[23] No candomblé, ou na umbanda, este período de recolhimento proporciona ao abiã
[24] conhecer e aprender os dogmas, os ritos, as cerimônias, entre outras atividades necessárias para
[25] que possa caminhar nas práticas religiosas. O romance O avesso da pele também requer esse
[26] processo de aprendizagem e conhecimento humano por parte de seus leitores, que se utilizarão
[27] das fragilidades, das incertezas e dos ímpetos para se entregarem ___ literatura cirúrgica do
[28] autor. O fato que desencadeia o recolhimento do narrador é materializado de forma poética por
[29] Tenório ao resgatar o momento do assassinato do pai pela polícia.
[30] Algumas suposições para a motivação de atos truculentos como os do policial em O avesso
[31] da pele seriam a felicidade com que as vítimas levavam suas vidas? Suas brincadeiras e diversões
[32] infantis? Trabalhar e se manter? Não, nenhuma delas. A ameaça real é simplesmente a existência
[33] de pessoas negras nas ruas. Dessa forma, Pedro necessita se recolher para compreender a perda
[34] de seu pai e, enfim, poder retornar para a sociedade “civilizada” após seu re-nascer e liberar seu
[35] orúko.
[36] No romance, Jeferson Tenório trata o recolher-se de uma forma bastante sutil, porém
[37] eficaz como a que ocorre com os abiãs no candomblé, ou seja, é necessário a eles se conhecerem
[38] na essência para que evoluam social, religiosa e eticamente.
[39] Jeferson Tenório pode ser considerado como um autor de realidades reflexivas das
[40] atrocidades impelidas ___ população negra, apenas por sua existência. Recolher-se é um
[41] exercício de liberdade para que se compreenda que essa ação é o que estrutura a essência da
[42] sociedade. O avesso da Pele, de Tenório, é o toque do atabaque afro-brasileiro que conduzirá aos
[43] leitores no transe iniciático do recolher-se para se compreender como alguém capaz de pensar,
[44] refletir e agir em busca das liberdades necessárias para a população negra contemporânea.
(Texto: adaptado a partir de resenha sobre "O avesso da pele", de Jeferson Tenório. Texto adaptado especialmente para esta prova.)

Com relação ao emprego de recursos de coesão referencial e pronominal, analise as assertivas a seguir:

I. A expressão anafórica "esse filho adulto" refere-se ao próprio personagem em relação aos seus pais, e não ao filho de Pedro.
II. A locução pronominal relativa "em que" pode ser substituída por "no qual" sem prejuízo da correção gramatical ou da referência estabelecida.
III. O pronome "delas" retoma anaforicamente o substantivo "suposições", que é posteriormente desdobrado em exemplos.

Quais estão corretas?',
       atualizado_em = now()
 where id = 324;

do $$
declare
  v_novo text;
begin
  select enunciado into v_novo from public.questoes where id = 324;
  if position('[01]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[01]';
  end if;
  if position('[17]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[17]';
  end if;
  if position('[22]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[22]';
  end if;
  if position('[30]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[30]';
  end if;
  if position('[32]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[32]';
  end if;
  if position('[44]' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: marcador "%" ausente no novo enunciado da questao 324', '[44]';
  end if;
end $$;


do $$
declare
  v_novo text;
  v_count int;
begin
  select enunciado into v_novo from public.questoes where id = 324;
  select (length(v_novo) - length(replace(v_novo, 'Com relação ao emprego de recursos de coesão referencial e pronominal, analise as assertivas a seguir:

I. A expressão anafórica "esse filho adulto" refere-se ao próprio personagem em relação aos seus pais, e não ao filho de Pedro.
II. A locução pronominal relativa "em que" pode ser substituída por "no qual" sem prejuízo da correção gramatical ou da referência estabelecida.
III. O pronome "delas" retoma anaforicamente o substantivo "suposições", que é posteriormente desdobrado em exemplos.

Quais estão corretas?', ''))) / greatest(length('Com relação ao emprego de recursos de coesão referencial e pronominal, analise as assertivas a seguir:

I. A expressão anafórica "esse filho adulto" refere-se ao próprio personagem em relação aos seus pais, e não ao filho de Pedro.
II. A locução pronominal relativa "em que" pode ser substituída por "no qual" sem prejuízo da correção gramatical ou da referência estabelecida.
III. O pronome "delas" retoma anaforicamente o substantivo "suposições", que é posteriormente desdobrado em exemplos.

Quais estão corretas?'),1) into v_count;
  if v_count <> 1 then
    raise exception 'Pos-condicao falhou: comando original da questao 324 aparece % vez(es) no novo enunciado (esperado exatamente 1)', v_count;
  end if;
end $$;


rollback;
