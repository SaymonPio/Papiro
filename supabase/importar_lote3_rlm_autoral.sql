-- Aplicacao REAL do Lote 3 (final) AUTORAL_PAPIRO de Raciocinio Logico — 29
-- questoes novas + 145 alternativas + 29 vinculos, validado pelo harness
-- supabase/importar_lote3_rlm_autoral_teste_rollback.sql (tudo_ok = true
-- confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_rlm_lote3_alvo10.json. Origem: AUTORAL_PAPIRO (banca
-- 'Papiro') em todas as 29 — nenhuma REAL, nenhum evento/concurso
-- historico fictício atribuido. Nenhuma questao para Negacao de
-- proposicoes nem Leis de De Morgan. Fecha o piso beta de 7 uteis/unidade
-- para as 10 unidades relevantes de Raciocinio Logico (deficit 29 -> 0).
--
-- Gerado programaticamente a partir do pacote JSON homologado.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION — qualquer divergencia
-- aborta a transacao inteira antes de confirmar.

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
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

create temporary table _lote_questoes (
  ordem int primary key,
  unidade_id uuid,
  assunto_id bigint,
  banca text,
  concurso text,
  ano int,
  fonte text,
  enunciado text
) on commit drop;

insert into _lote_questoes (ordem, unidade_id, assunto_id, banca, concurso, ano, fonte, enunciado) values
(1, '6683c484-74a7-4b07-9cda-1a72190e6445', 36, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Das sentenças abaixo, qual delas NÃO pode ser considerada uma proposição lógica?'),
(2, '6683c484-74a7-4b07-9cda-1a72190e6445', 36, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição composta P ↔ Q é verdadeira exatamente quando:'),
(3, '6683c484-74a7-4b07-9cda-1a72190e6445', 36, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Um edital afirma: "O candidato deve apresentar carteira de identidade ou certidão de nascimento, mas não ambos os documentos." Essa condição corresponde ao conectivo lógico de:'),
(4, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Antes de construir a tabela-verdade da proposição composta (p → q) ∨ (p ∧ ~r), quantas proposições simples DISTINTAS devem ser consideradas?'),
(5, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sobre a tabela-verdade completa da proposição composta p ∧ (q ∨ ~p), com p e q proposições simples distintas, são feitas as seguintes afirmações: I. A tabela possui 4 linhas. II. O resultado final é verdadeiro em pelo menos uma linha. III. O resultado final é sempre falso, caracterizando uma contradição. Está(ão) correta(s):'),
(6, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Um aluno construiu parte da tabela-verdade da proposição composta (p ∨ ~q) ↔ q e, na linha em que p é falso e q é falso, anotou o resultado como VERDADEIRO. Essa anotação está:'),
(7, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A tabela-verdade abaixo apresenta o resultado final de uma proposição composta B. Para p/q na ordem V/V, V/F, F/V e F/F, os valores de B são, respectivamente, F, V, V, F. A alternativa que apresenta uma fórmula logicamente equivalente a B é:'),
(8, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição "Não é verdade que o suspeito não estava no local" é logicamente equivalente a:'),
(9, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sejam p e q proposições simples. A proposição composta (p → q) ∧ (q → p) é logicamente equivalente a:'),
(10, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a condicional "Se o documento está assinado, então ele é válido." Assinale a alternativa que apresenta a INVERSA dessa condicional:'),
(11, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a condicional "Se o motor superaquece, então o veículo perde potência" e sua contrapositiva "Se o veículo não perde potência, então o motor não superaquece." É correto afirmar que essas duas proposições são:'),
(12, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a condicional "Se P, então Q." Avalie as afirmações: I. A recíproca dessa condicional é "Se Q, então P." II. A contrapositiva dessa condicional é logicamente equivalente à condicional original. III. A inversa dessa condicional é "Se não P, então não Q." Estão corretas:'),
(13, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A sentença simbólica ∃x∈U (x é par), sendo U o conjunto de números do universo considerado, traduz-se corretamente para a linguagem natural como:'),
(14, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A sentença "Existe pelo menos um servidor da corporação que atua na área administrativa" pode ser representada simbolicamente, sendo U o conjunto de servidores da corporação e A(x) o predicado "x atua na área administrativa", como:'),
(15, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A sentença "Para todo x, x > 3" é verdadeira quando o domínio é U₁ = {4, 5, 6}, mas é falsa quando o domínio é U₂ = {2, 4, 6}. Isso demonstra que:'),
(16, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere as proposições compostas: I. p ∨ ~p; II. p → p; III. p ∧ ~p; IV. p ↔ p. Quantas dessas proposições são tautologias?'),
(17, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição composta p * ~p, em que * representa um conectivo lógico a ser determinado, é uma TAUTOLOGIA quando * é substituído por:'),
(18, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que as proposições compostas A e B possuem exatamente o mesmo comportamento lógico em todas as valorações possíveis (ou seja, são logicamente equivalentes). Nessas condições, a proposição composta A ↔ B é necessariamente uma:'),
(19, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a sentença aberta 3x + 1 > 10, com universo dos números inteiros. O valor x = 4 pertence ao conjunto-verdade dessa sentença?'),
(20, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {0, 1, 2, 3, 4} e a sentença aberta x ≤ 2. O conjunto-verdade dessa sentença, em U, é:'),
(21, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {2, 4, 6, 8} e a sentença aberta "x é um número par". O conjunto-verdade dessa sentença, em U, é:'),
(22, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o argumento: "O suspeito estava em casa ou estava no trabalho no momento do crime. Ficou comprovado que ele não estava em casa. Logo, ele estava no trabalho." Esse argumento é:'),
(23, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o argumento: "Se o servidor foi promovido, então ele fez o curso de capacitação. O servidor não foi promovido. Logo, ele não fez o curso de capacitação." Esse argumento é:'),
(24, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o argumento: "Nenhum funcionário do setor financeiro trabalha aos sábados. Marcelo trabalha aos sábados. Logo, Marcelo não é funcionário do setor financeiro." Esse argumento é:'),
(25, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que os conjuntos T (candidatos que fizeram o curso teórico) e P (candidatos que fizeram o curso prático) apresentam interseção parcial. Com base SOMENTE nessa informação, NÃO é correto concluir que:'),
(26, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a afirmação: "Algum policial da unidade X possui especialização em investigação criminal." Sejam U o conjunto de policiais da unidade X e E o conjunto de pessoas com especialização em investigação criminal. Essa afirmação corresponde a qual relação entre U e E?'),
(27, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que o conjunto J (jovens aprendizes contratados) está totalmente contido no conjunto F (funcionários da empresa). Avalie as afirmações: I. Todo jovem aprendiz é funcionário da empresa. II. Todo funcionário da empresa é jovem aprendiz. III. É possível que existam funcionários que não sejam jovens aprendizes. Estão corretas:'),
(28, 'c6ccefae-14df-4760-8c1d-2822090a2a93', 35, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A negação da proposição "Se o suspeito confessar, então será liberado sob fiança" é:'),
(29, 'c6ccefae-14df-4760-8c1d-2822090a2a93', 35, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A negação da proposição "O motor liga se e somente se há combustível no tanque" é:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
"Feche a porta, por favor!" é uma ordem (frase imperativa), não uma sentença declarativa — não é possível atribuir a ela valor lógico verdadeiro ou falso. Por isso, não é uma proposição.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A), B), D) e E) são todas sentenças declarativas às quais se pode atribuir um valor lógico determinado (verdadeiro ou falso), portanto são proposições — mesmo que alguma delas fosse falsa, continuaria sendo proposição, pois falsidade não descaracteriza a proposição.

BIZU DE PROVA:
Perguntas, ordens e exclamações NUNCA são proposições — só sentenças declarativas, às quais se pode atribuir V ou F, contam como proposições.'),
(2, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Por definição, a bicondicional P↔Q é verdadeira quando P e Q têm o MESMO valor lógico — ambas verdadeiras, ou ambas falsas.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Descreve a conjunção (P∧Q), não a bicondicional — ignora o caso em que ambas são falsas.
B) Descreve a disjunção inclusiva (P∨Q).
D) Descreve exatamente a NEGAÇÃO da bicondicional (o ou exclusivo), o oposto do pedido.
E) Descreve apenas um dos quatro casos possíveis, e nesse caso a bicondicional seria FALSA (valores diferentes), não verdadeira.

BIZU DE PROVA:
Bicondicional (↔) = "mesma coisa": verdadeira quando os dois lados concordam (VV ou FF); falsa quando discordam (VF ou FV).'),
(3, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A expressão "ou..., mas não ambos" é a definição exata da disjunção EXCLUSIVA: exatamente uma das duas opções deve ser verdadeira, nunca as duas ao mesmo tempo.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) A disjunção inclusiva permitiria as duas opções simultaneamente, o que o edital proíbe explicitamente.
B) Conjunção exigiria os dois documentos ao mesmo tempo, o oposto do exigido.
D) Bicondicional não corresponde a uma escolha entre dois itens.
E) Condicional não expressa uma relação de exclusividade entre duas opções.

BIZU DE PROVA:
"Ou..., mas não ambos" / "ou..., mas não os dois" é sempre o sinal linguístico da disjunção EXCLUSIVA — diferente do "ou" cotidiano, que normalmente é inclusivo em lógica.'),
(4, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Embora "p" apareça duas vezes na fórmula (p→q) ∨ (p∧~r), ela é a MESMA proposição simples — não conta duas vezes. As proposições simples distintas são p, q e r: total de 3.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Ignora a proposição r.
C), D) e E) Contam a repetição de p como se fosse uma proposição adicional, ou incluem proposições que não existem na fórmula.

BIZU DE PROVA:
Antes de montar qualquer tabela-verdade, liste as LETRAS DISTINTAS que aparecem na fórmula — repetições da mesma letra não aumentam o número de proposições simples nem o número de linhas da tabela.'),
(5, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Construindo as 4 linhas de p∧(q∨~p): VV→(V∨F)=V,V∧V=V; VF→(F∨F)=F,V∧F=F; FV→(V∨V)=V,F∧V=F; FF→(F∨V)=V,F∧V=F. Resultado: V,F,F,F. I: a tabela tem 2 proposições simples, logo 2²=4 linhas — VERDADEIRA. II: há uma linha verdadeira (VV) — VERDADEIRA. III: não é sempre falsa (há um V), logo não é contradição — FALSA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Omite II, que também é verdadeira.
C) Inclui III, que é falsa.
D) Inclui III, que é falsa.
E) Omite I e II, que são verdadeiras.

BIZU DE PROVA:
Antes de julgar afirmações sobre uma tabela-verdade, construa a tabela completa — só assim é possível verificar com segurança quantas linhas existem e qual o padrão do resultado final.'),
(6, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Com p=F e q=F: ~q=V, então p∨~q=F∨V=V. A bicondicional (p∨~q)↔q compara esse V com q(F): V↔F=F. O valor correto é FALSO, não VERDADEIRO como o aluno anotou.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) e D) A anotação do aluno está errada; o fato de p e q terem o mesmo valor (ambos F) não torna a bicondicional inteira verdadeira, pois ela compara q com o resultado de (p∨~q), não p com q diretamente.
C) Com p e q fixados, o valor da fórmula fica totalmente determinado — não depende de mais nenhuma variável.
E) A fórmula pode e deve ser avaliada para qualquer combinação de valores de p e q, incluindo ambos falsos.

BIZU DE PROVA:
Ao verificar um resultado alegado, refaça o cálculo do zero, coluna por coluna — nunca aceite a resposta de outra pessoa sem conferir cada etapa (negações, parênteses, conectivo final).'),
(7, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
p↔q tem padrão V,F,F,V (verdadeira quando os valores coincidem). Negando essa coluna, obtemos F,V,V,F — exatamente o padrão de B. Logo, B é equivalente a ~(p↔q).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) p↔q tem padrão V,F,F,V — o oposto do pedido.
C) p∧q tem padrão V,F,F,F — não corresponde.
D) p∨q tem padrão V,V,V,F — não corresponde.
E) ~p∧~q tem padrão F,F,F,V — não corresponde.

BIZU DE PROVA:
Quando o padrão pedido é exatamente o OPOSTO (negado, linha a linha) de uma fórmula conhecida, a resposta é a negação dessa fórmula conhecida — aqui, o padrão de B é o inverso exato do padrão da bicondicional.'),
(8, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A dupla negação se cancela: ~~P ≡ P. "Não é verdade que o suspeito não estava no local" nega a negação de "o suspeito estava no local", resultando na própria afirmação original.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É a proposição negada uma única vez, não a dupla negação.
C) Introduz uma modalidade (possibilidade) que não está na proposição original, que é categórica.
D) É uma contradição (P∧~P), nunca equivalente a uma dupla negação simples.
E) A dupla negação tem valor lógico perfeitamente determinado, igual ao da proposição original.

BIZU DE PROVA:
~~P ≡ P sempre — duas negações consecutivas se cancelam e devolvem a proposição original, com o mesmo valor lógico.'),
(9, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A bicondicional p↔q é, por definição, logicamente equivalente à conjunção das duas condicionais recíprocas: (p→q)∧(q→p).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) p∧q não é equivalente: a conjunção de condicionais também é verdadeira quando p e q são ambas falsas, caso em que p∧q é falsa.
B) p∨q não captura a exigência de que as duas condicionais sejam simultaneamente verdadeiras.
D) p→q é apenas uma das duas condicionais, não a conjunção completa.
E) ~p∨~q não corresponde ao comportamento da conjunção de condicionais.

BIZU DE PROVA:
(p→q)∧(q→p) ≡ p↔q sempre — memorize essa equivalência nos dois sentidos: da bicondicional para a conjunção de condicionais, e da conjunção de condicionais de volta para a bicondicional.'),
(10, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Com P="documento assinado" e Q="válido", a original é P→Q. A inversa nega ambos os termos, sem inverter a ordem: ¬P→¬Q = "Se o documento não está assinado, então ele não é válido".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É a RECÍPROCA (Q→P): inverte a ordem, sem negar.
C) É a CONTRAPOSITIVA (¬Q→¬P): inverte e nega.
D) É a negação da condicional original (P∧¬Q).
E) É Q→¬P, uma combinação que não corresponde a nenhuma das três transformações clássicas.

BIZU DE PROVA:
Inversa = só nega, mantém a ordem (¬P→¬Q); recíproca = só inverte, sem negar (Q→P); contrapositiva = inverte E nega (¬Q→¬P) — apenas a contrapositiva é equivalente à original.'),
(11, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A contrapositiva de uma condicional é sempre logicamente equivalente à condicional original — em toda valoração possível de seus termos, as duas proposições têm exatamente o mesmo valor lógico (ambas verdadeiras ou ambas falsas simultaneamente).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Proposições logicamente equivalentes nunca têm valores opostos.
C) A relação de equivalência entre condicional e contrapositiva é uma propriedade lógica necessária, não uma coincidência independente.
D) e E) A equivalência entre condicional e contrapositiva vale universalmente, para toda valoração — não apenas em casos específicos.

BIZU DE PROVA:
A contrapositiva NUNCA é apenas "parecida" com a condicional original — ela é logicamente IDÊNTICA em valor lógico, em toda e qualquer situação, por isso pode substituir a original em qualquer raciocínio.'),
(12, E'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
I: a recíproca inverte a ordem sem negar (Q→P) — CORRETA. II: a contrapositiva (¬Q→¬P) é sempre logicamente equivalente à condicional original — CORRETA. III: a inversa nega ambos os termos sem inverter a ordem (¬P→¬Q) — CORRETA. As três afirmações estão corretas.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A), B), C) e E) descartam pelo menos uma afirmação correta — mas as três definições apresentadas (recíproca, equivalência da contrapositiva, inversa) estão todas tecnicamente corretas.

BIZU DE PROVA:
Memorize as três transformações em bloco: recíproca (Q→P, só inverte), inversa (¬P→¬Q, só nega), contrapositiva (¬Q→¬P, inverte e nega, e é a ÚNICA equivalente à original).'),
(13, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O símbolo ∃ é o quantificador existencial, que se traduz como "existe pelo menos um". A sentença afirma que existe pelo menos um elemento de U que é par.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) e D) Usariam o quantificador universal (∀ = "todos"), não o existencial apresentado.
C) Nega a existência, o oposto do que ∃ afirma.
E) Troca o predicado "par" por "ímpar", alterando o conteúdo da sentença.

BIZU DE PROVA:
∃ = "existe pelo menos um"; ∀ = "para todo/todos" — a tradução deve preservar exatamente o quantificador E o predicado originais.'),
(14, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Existe pelo menos um" é a marca do quantificador existencial (∃). A sentença afirma existência de um elemento de U que satisfaz A(x), representada como ∃x∈U, A(x).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Usa o quantificador universal, que exigiria "todo servidor", não apenas "existe um".
C) Combina universal com negação do predicado — sentido totalmente diferente.
D) Nega o predicado, afirmando existência de quem NÃO atua na área administrativa — o oposto do enunciado.
E) Nega a existência inteira, o oposto exato da sentença original.

BIZU DE PROVA:
"Existe", "algum", "pelo menos um" → ∃; a negação do predicado (~A(x)) só deve ser usada se a sentença original mencionar explicitamente uma exclusão ou ausência.'),
(15, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Em U₁={4,5,6}, todos os elementos são maiores que 3 — a sentença é VERDADEIRA. Em U₂={2,4,6}, o elemento 2 não é maior que 3 — a sentença é FALSA (contraexemplo). O mesmo enunciado, com o mesmo predicado, muda de valor lógico apenas porque o domínio mudou.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) e C) O próprio enunciado mostra que a sentença é verdadeira em um domínio e falsa em outro — não é sempre uma coisa ou outra.
D) Contradiz diretamente o exemplo apresentado.
E) Não há erro: é perfeitamente normal e esperado que sentenças quantificadas mudem de valor lógico conforme o domínio.

BIZU DE PROVA:
Uma sentença quantificada nunca tem valor lógico "absoluto" — o valor sempre depende do domínio escolhido; mude o domínio, e o valor pode mudar junto.'),
(16, E'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
I: p∨~p é sempre verdadeira (princípio do terceiro excluído) — TAUTOLOGIA. II: p→p é sempre verdadeira (toda proposição implica a si mesma) — TAUTOLOGIA. III: p∧~p é sempre falsa (princípio da não contradição) — CONTRADIÇÃO, não tautologia. IV: p↔p é sempre verdadeira (toda proposição é equivalente a si mesma) — TAUTOLOGIA. Total: I, II e IV são tautologias = 3.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A), B), C) e E) não correspondem à contagem correta de 3 tautologias entre as 4 fórmulas apresentadas.

BIZU DE PROVA:
Fórmulas da forma X∨~X, X→X e X↔X são sempre tautologias (refletem, respectivamente, o terceiro excluído e a reflexividade); já X∧~X é sempre uma contradição — memorize esses 4 padrões clássicos.'),
(17, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
p∨~p é sempre verdadeira (terceiro excluído) — TAUTOLOGIA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) p∧~p é sempre falsa — CONTRADIÇÃO.
B) p↔~p também é sempre falsa (p e ~p nunca têm o mesmo valor) — CONTRADIÇÃO, não tautologia.
D) p→~p: quando p=V, resulta em F; quando p=F, resulta em V — valores mistos, CONTINGÊNCIA.
E) A alternativa C efetivamente torna a proposição uma tautologia, então esta opção está incorreta.

BIZU DE PROVA:
p e ~p SEMPRE têm valores opostos — por isso p∨~p ("pelo menos um dos dois") é sempre verdadeiro, enquanto p∧~p e p↔~p (que exigem os dois "coincidirem" de alguma forma) são sempre falsos.'),
(18, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Se A e B têm sempre o mesmo valor lógico em toda valoração, então A↔B (que é verdadeira exatamente quando A e B coincidem) é verdadeira em TODAS as valorações — por definição, isso é uma TAUTOLOGIA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Uma contradição é sempre falsa — o oposto do que ocorre quando A e B sempre coincidem.
C) Uma contingência varia entre V e F — mas aqui A↔B é sempre V, sem exceção.
D) "Sentença aberta" refere-se a variável livre em domínio matemático, não a esta situação.
E) Justamente por A e B serem equivalentes, A↔B NÃO depende de valores específicos — é sempre verdadeira.

BIZU DE PROVA:
Sempre que duas fórmulas são logicamente equivalentes, a bicondicional entre elas é uma tautologia — essa é, inclusive, a própria definição formal de equivalência lógica.'),
(19, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Substituindo x=4: 3(4)+1=13. Como 13>10 é verdadeiro, x=4 satisfaz a sentença e pertence ao conjunto-verdade.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) O cálculo de 13 está correto, mas a conclusão está invertida: 13 É maior que 10.
C) Nem todo inteiro satisfaz a sentença (por exemplo, x=0 não satisfaz: 3(0)+1=1, que não é >10).
D) 4 é, sim, um número inteiro.
E) A substituição direta do valor determina imediatamente se ele pertence ou não ao conjunto-verdade — não faltam dados.

BIZU DE PROVA:
Para verificar se um valor específico pertence ao conjunto-verdade, basta substituí-lo na sentença aberta e conferir se a afirmação resultante é verdadeira — não é necessário calcular o conjunto-verdade inteiro.'),
(20, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A desigualdade ≤ (menor ou igual) INCLUI o valor de fronteira. Em U, os valores que satisfazem x≤2 são 0, 1 e 2 (o próprio 2 está incluído, pois a desigualdade não é estrita).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Exclui incorretamente o valor 2, que satisfaz a desigualdade não-estrita.
C) Exclui incorretamente o valor 0.
D) Inclui incorretamente o valor 3, que não satisfaz x≤2.
E) Considera apenas o valor de fronteira, ignorando os demais valores que também satisfazem a condição.

BIZU DE PROVA:
Desigualdades com "≤" ou "≥" (não-estritas) SEMPRE incluem o valor exato da fronteira; desigualdades com "<" ou ">" (estritas) SEMPRE excluem esse valor — atenção redobrada a esse detalhe.'),
(21, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Todos os elementos de U (2, 4, 6 e 8) são números pares. Como todos satisfazem a sentença, o conjunto-verdade coincide com o próprio universo U.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) O conjunto-verdade não é vazio: existem elementos que satisfazem a condição — na verdade, todos.
B) e D) Excluem incorretamente elementos que também satisfazem a condição (todos os quatro são pares).
E) A verificação de paridade de cada elemento do universo é direta e determina o conjunto-verdade com segurança.

BIZU DE PROVA:
O conjunto-verdade de uma sentença aberta pode ser vazio (nenhum elemento satisfaz), um subconjunto próprio (alguns satisfazem), ou o próprio domínio inteiro (todos satisfazem) — sempre confira todos os elementos antes de concluir.'),
(22, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O argumento tem a forma P∨Q, ¬P, logo Q — o SILOGISMO DISJUNTIVO (modus tollendo ponens). Não há contraexemplo possível: se P∨Q é verdadeira e P é falsa, Q necessariamente precisa ser verdadeira para que a disjunção se mantenha verdadeira.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Mesmo com disjunção inclusiva (não exclusiva), a negação de uma das partes ainda garante a verdade da outra — a validade não depende de exclusividade.
C) Modus ponens tem a forma P→Q, P, logo Q — estrutura diferente da apresentada, que não envolve condicional.
D) A conclusão decorre necessariamente das premissas dadas — não é preciso confirmação adicional.
E) Modus tollens tem a forma P→Q, ¬Q, logo ¬P — também estrutura diferente, sem condicional nem negação do consequente.

BIZU DE PROVA:
Silogismo disjuntivo: P∨Q, ¬P ⊢ Q (ou, simetricamente, P∨Q, ¬Q ⊢ P) — sempre válido, pois eliminar uma opção de uma disjunção verdadeira obriga a outra a ser verdadeira.'),
(23, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O argumento tem a forma P→Q, ¬P, logo ¬Q — a FALÁCIA DA NEGAÇÃO DO ANTECEDENTE. Contraexemplo: o servidor pode não ter sido promovido, mas ainda assim ter feito o curso de capacitação por conta própria ou por outro motivo — as premissas seriam verdadeiras e a conclusão, falsa.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Modus tollens tem a forma P→Q, ¬Q, logo ¬P — aqui se nega o ANTECEDENTE (¬P), não o consequente, então não é modus tollens.
C) A condicional P→Q não garante nada sobre o caso em que P é falsa — Q pode ser verdadeira ou falsa nesse caso.
D) As duas premissas são perfeitamente compatíveis entre si; o problema está na conclusão, não em contradição entre as premissas.
E) Modus ponens exigiria afirmar o antecedente (P) para concluir o consequente (Q) — estrutura diferente.

BIZU DE PROVA:
Negar o antecedente (P→Q, ¬P) NUNCA permite concluir ¬Q — só negar o CONSEQUENTE (modus tollens: P→Q, ¬Q ⊢ ¬P) é válido.'),
(24, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Nenhum funcionário do financeiro trabalha aos sábados" estabelece que os dois grupos (financeiro e quem trabalha aos sábados) são disjuntos — não têm elementos em comum. Como Marcelo trabalha aos sábados, ele pertence ao segundo grupo; logo, não pode pertencer ao primeiro (financeiro). Não há contraexemplo possível.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Uma premissa universal negativa ("nenhum") permite sim conclusões válidas sobre elementos específicos, como demonstrado aqui.
C) A profissão exata de Marcelo é irrelevante — a informação de que ele trabalha aos sábados já basta para excluí-lo do setor financeiro, dada a premissa.
D) Não é modus ponens categórico (que tem a forma "Todo A é B"); aqui a premissa é uma exclusão total ("nenhum A é B").
E) Contradiz diretamente a conclusão necessária: se Marcelo fosse do financeiro, ele não poderia trabalhar aos sábados, o que contradiria a segunda premissa.

BIZU DE PROVA:
"Nenhum A é B" estabelece que A e B são conjuntos disjuntos — se um elemento pertence a B, ele necessariamente não pertence a A, e vice-versa.'),
(25, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Interseção parcial" significa, por definição, que T e P têm elementos em comum, mas NENHUM dos dois está totalmente contido no outro. Afirmar que "todo T é P" equivaleria a inclusão total (T⊆P), o que contradiz diretamente a informação de que a interseção é apenas parcial. Por isso, essa é a única alternativa que NÃO pode ser concluída.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO CORRETAS (e por isso não são a resposta):
A) Decorre diretamente da existência de interseção.
C) e D) Decorrem do fato de que nenhum dos dois conjuntos está contido no outro — cada um tem elementos exclusivos.
E) É exatamente a negação de "todo T é P", portanto verdadeira quando a interseção é apenas parcial.

BIZU DE PROVA:
"Interseção parcial" garante SIMULTANEAMENTE três coisas: existe elemento comum, existe elemento exclusivo de cada conjunto — e por isso EXCLUI qualquer relação de inclusão total entre eles.'),
(26, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Algum A é B" corresponde exatamente à existência de pelo menos um elemento na interseção A∩B — ou seja, U∩E≠∅. Essa é a única relação necessariamente garantida pela afirmação.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) e D) "Algum" não garante inclusão total em nenhuma direção — apenas existência de sobreposição.
C) Contradiz diretamente a existência afirmada por "algum".
E) "Algum" não garante que os conjuntos sejam idênticos.

BIZU DE PROVA:
"Algum A é B" garante SOMENTE que A∩B≠∅ — isso é compatível até mesmo com inclusão total (se A⊆B, "algum A é B" também seria verdadeira); a garantia de "algum" é sempre a mais fraca e mínima possível: apenas existência de interseção.'),
(27, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
I: "Todo jovem aprendiz é funcionário" é exatamente a definição de J⊆F — VERDADEIRA. II: "Todo funcionário é jovem aprendiz" seria F⊆J, a INVERSÃO da relação dada, que não é garantida — FALSA. III: como a relação dada não afirma que F=J, é logicamente possível (não excluído pelas premissas) que existam funcionários fora de J — VERDADEIRA. Logo, apenas I e III estão corretas.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Omite III, que também é verdadeira.
B) e D) Incluem II, que inverte indevidamente a relação dada.
E) Omite I, que é a restatement direta e correta da relação J⊆F.

BIZU DE PROVA:
"A está contido em B" nunca garante "B está contido em A" — sempre trate a direção da inclusão com cuidado, e lembre-se de que a não-garantia de igualdade torna "possível" (não obrigatório) que B tenha elementos fora de A.'),
(28, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A negação de P→Q é P∧¬Q (nunca outra condicional). Com P="confessar" e Q="ser liberado sob fiança", a negação é "O suspeito confessou e NÃO foi liberado sob fiança".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É a própria proposição original reescrita (P→Q ≡ ¬P∨Q), não sua negação — um erro clássico de confundir a proposição com sua negação.
C) É a inversa da condicional original, uma transformação totalmente diferente da negação.
D) Nega os dois termos (¬P∧¬Q), quando a negação correta preserva P e nega apenas Q.
E) É uma disjunção que não corresponde à negação da condicional.

BIZU DE PROVA:
A negação de "Se P, então Q" NUNCA é outra condicional — é sempre a conjunção "P e não Q" (o único cenário que torna a condicional original falsa).'),
(29, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A negação de P↔Q corresponde ao "ou exclusivo" entre P e Q: verdadeira exatamente quando P e Q têm valores DIFERENTES. Isso se expressa como (P e não Q) ou (não P e Q) — "o motor liga sem combustível" OU "o motor não liga havendo combustível".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É P∧Q, apenas um dos dois casos em que a bicondicional original é verdadeira — não é a negação.
C) É ¬P∧¬Q, o outro caso em que a original é verdadeira — também não é a negação.
D) É exatamente a expansão da proposição ORIGINAL (P↔Q ≡ (P∧Q)∨(¬P∧¬Q)), não de sua negação.
E) A negação de qualquer bicondicional é sempre determinável a partir dos próprios termos P e Q, sem necessidade de informação adicional.

BIZU DE PROVA:
A negação da bicondicional é sempre o "ou exclusivo" entre os dois termos — verdadeira quando eles DIVERGEM, nunca quando coincidem (o oposto exato da bicondicional original).');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'O sol é uma estrela.',false),
(1,2,'7 é um número primo.',false),
(1,3,'Feche a porta, por favor!',true),
(1,4,'Porto Alegre fica no Rio Grande do Sul.',false),
(1,5,'Todo número par é divisível por 2.',false),
(2,1,'P e Q são ambas verdadeiras.',false),
(2,2,'Pelo menos uma das duas é verdadeira.',false),
(2,3,'P e Q têm o mesmo valor lógico (ambas verdadeiras ou ambas falsas).',true),
(2,4,'Apenas uma das duas é verdadeira.',false),
(2,5,'P é verdadeira e Q é falsa.',false),
(3,1,'Disjunção inclusiva.',false),
(3,2,'Conjunção.',false),
(3,3,'Disjunção exclusiva.',true),
(3,4,'Bicondicional.',false),
(3,5,'Condicional.',false),
(4,1,'2',false),
(4,2,'3',true),
(4,3,'4',false),
(4,4,'5',false),
(4,5,'6',false),
(5,1,'Apenas I.',false),
(5,2,'Apenas I e II.',true),
(5,3,'Apenas II e III.',false),
(5,4,'I, II e III.',false),
(5,5,'Apenas III.',false),
(6,1,'Correta.',false),
(6,2,'Incorreta; o valor correto é FALSO.',true),
(6,3,'Incorreta; o valor correto depende de outra variável não apresentada.',false),
(6,4,'Correta, pois p e q têm o mesmo valor lógico.',false),
(6,5,'Incorreta; a fórmula não pode ser avaliada com p e q ambos falsos.',false),
(7,1,'p ↔ q',false),
(7,2,'~(p ↔ q)',true),
(7,3,'p ∧ q',false),
(7,4,'p ∨ q',false),
(7,5,'~p ∧ ~q',false),
(8,1,'O suspeito estava no local.',true),
(8,2,'O suspeito não estava no local.',false),
(8,3,'É possível que o suspeito estivesse no local.',false),
(8,4,'O suspeito estava e não estava no local.',false),
(8,5,'Não se pode afirmar nada sobre o suspeito.',false),
(9,1,'p ∧ q',false),
(9,2,'p ∨ q',false),
(9,3,'p ↔ q',true),
(9,4,'p → q',false),
(9,5,'~p ∨ ~q',false),
(10,1,'Se o documento não está assinado, então ele não é válido.',true),
(10,2,'Se o documento é válido, então ele está assinado.',false),
(10,3,'Se ele não é válido, então o documento não está assinado.',false),
(10,4,'O documento está assinado e não é válido.',false),
(10,5,'Se ele é válido, então o documento não está assinado.',false),
(11,1,'Logicamente equivalentes — sempre têm o mesmo valor lógico.',true),
(11,2,'Logicamente opostas — sempre têm valores lógicos diferentes.',false),
(11,3,'Independentes — seus valores lógicos não têm relação necessária.',false),
(11,4,'Equivalentes apenas quando o motor superaquece.',false),
(11,5,'Opostas apenas quando o veículo perde potência.',false),
(12,1,'Apenas I.',false),
(12,2,'Apenas I e II.',false),
(12,3,'Apenas II e III.',false),
(12,4,'I, II e III.',true),
(12,5,'Nenhuma está correta.',false),
(13,1,'Todos os números de U são pares.',false),
(13,2,'Existe pelo menos um número par em U.',true),
(13,3,'Nenhum número de U é par.',false),
(13,4,'Todos os números de U são ímpares.',false),
(13,5,'Existe pelo menos um número ímpar em U.',false),
(14,1,'∀x∈U, A(x)',false),
(14,2,'∃x∈U, A(x)',true),
(14,3,'∀x∈U, ~A(x)',false),
(14,4,'∃x∈U, ~A(x)',false),
(14,5,'~∃x∈U, A(x)',false),
(15,1,'O valor lógico de uma sentença quantificada pode depender do domínio considerado.',true),
(15,2,'A sentença é sempre verdadeira, independentemente do domínio.',false),
(15,3,'A sentença é sempre falsa, independentemente do domínio.',false),
(15,4,'Sentenças quantificadas nunca dependem do domínio.',false),
(15,5,'Há um erro na sentença, pois ela não pode ter valores diferentes.',false),
(16,1,'Nenhuma.',false),
(16,2,'1',false),
(16,3,'2',false),
(16,4,'3',true),
(16,5,'4',false),
(17,1,'∧ (conjunção)',false),
(17,2,'↔ (bicondicional)',false),
(17,3,'∨ (disjunção)',true),
(17,4,'→ (condicional, com p como antecedente)',false),
(17,5,'Nenhuma opção torna a proposição uma tautologia.',false),
(18,1,'Tautologia.',true),
(18,2,'Contradição.',false),
(18,3,'Contingência.',false),
(18,4,'Sentença aberta.',false),
(18,5,'Depende dos valores específicos de A e B.',false),
(19,1,'Sim, pois 3(4)+1=13, que é maior que 10.',true),
(19,2,'Não, pois 3(4)+1=13, que não é maior que 10.',false),
(19,3,'Sim, pois todo número inteiro satisfaz a sentença.',false),
(19,4,'Não, pois x=4 não é um número inteiro.',false),
(19,5,'Não é possível determinar sem mais informações.',false),
(20,1,'{0, 1}',false),
(20,2,'{0, 1, 2}',true),
(20,3,'{1, 2}',false),
(20,4,'{0, 1, 2, 3}',false),
(20,5,'{2}',false),
(21,1,'{ } (conjunto vazio)',false),
(21,2,'{2, 4}',false),
(21,3,'{2, 4, 6, 8} (o próprio universo)',true),
(21,4,'{6, 8}',false),
(21,5,'Não é possível determinar.',false),
(22,1,'Válido, pela forma de raciocínio conhecida como silogismo disjuntivo.',true),
(22,2,'Inválido, pois a primeira premissa não garante que apenas uma das opções seja verdadeira.',false),
(22,3,'Válido, por modus ponens.',false),
(22,4,'Inválido, pois seria necessário confirmar diretamente que ele estava no trabalho.',false),
(22,5,'Válido, por modus tollens.',false),
(23,1,'Válido, por modus tollens.',false),
(23,2,'Inválido, pois nega o antecedente para concluir a negação do consequente — o servidor pode ter feito o curso por outro motivo, mesmo sem ser promovido.',true),
(23,3,'Válido, pois decorre diretamente da condicional.',false),
(23,4,'Inválido, pois as premissas são contraditórias entre si.',false),
(23,5,'Válido, por modus ponens.',false),
(24,1,'Válido — se ninguém do setor financeiro trabalha aos sábados e Marcelo trabalha aos sábados, ele não pode ser do setor financeiro.',true),
(24,2,'Inválido, pois a premissa "nenhum" não permite nenhuma conclusão.',false),
(24,3,'Inválido, pois seria necessário saber a profissão exata de Marcelo.',false),
(24,4,'Válido, por modus ponens categórico direto.',false),
(24,5,'Inválido, pois Marcelo poderia ser do setor financeiro mesmo assim.',false),
(25,1,'Existem candidatos que fizeram ambos os cursos.',false),
(25,2,'Todo candidato que fez o curso teórico também fez o curso prático.',true),
(25,3,'Existem candidatos que fizeram apenas o curso teórico, sem o prático.',false),
(25,4,'Existem candidatos que fizeram apenas o curso prático, sem o teórico.',false),
(25,5,'Nem todo candidato do curso teórico fez o curso prático.',false),
(26,1,'U ∩ E ≠ ∅ (existe pelo menos um elemento em comum).',true),
(26,2,'U ⊆ E (todo policial da unidade X tem a especialização).',false),
(26,3,'U ∩ E = ∅ (não há nenhum elemento em comum).',false),
(26,4,'E ⊆ U (toda pessoa especializada é policial da unidade X).',false),
(26,5,'U = E (os dois conjuntos são idênticos).',false),
(27,1,'Apenas I.',false),
(27,2,'Apenas I e II.',false),
(27,3,'Apenas I e III.',true),
(27,4,'I, II e III.',false),
(27,5,'Apenas II e III.',false),
(28,1,'O suspeito confessou e não foi liberado sob fiança.',true),
(28,2,'O suspeito não confessou ou foi liberado sob fiança.',false),
(28,3,'Se o suspeito não confessar, então não será liberado sob fiança.',false),
(28,4,'O suspeito não confessou e não foi liberado sob fiança.',false),
(28,5,'O suspeito confessou ou foi liberado sob fiança.',false),
(29,1,'(O motor liga e não há combustível no tanque) ou (o motor não liga e há combustível no tanque).',true),
(29,2,'O motor liga e há combustível no tanque.',false),
(29,3,'O motor não liga e não há combustível no tanque.',false),
(29,4,'O motor liga e há combustível, ou o motor não liga e não há combustível.',false),
(29,5,'Não é possível determinar a negação sem mais informações.',false);

do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 29 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 29)', v_cnt;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % enunciado(s) identicos ja existem no banco', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % unidade(s)-alvo inexistente(s) ou inativa(s)', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  join public.unidades_pedagogicas u on u.id = lq.unidade_id
  join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
  where cc.assunto_id is distinct from lq.assunto_id;
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % linha(s) com assunto_id divergente da unidade-alvo', v_dup;
  end if;
end $$;

create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (18, r.assunto_id, r.banca, r.concurso, r.ano, r.enunciado, 'media',
            (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
            r.fonte, true, false)
    returning id into v_id;
    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_id);

    insert into public.alternativas (questao_id, texto, correta, ordem)
    select v_id, la.texto, la.correta, la.ordem_alt
    from _lote_alternativas la
    where la.ordem = r.ordem
    order by la.ordem_alt;
  end loop;
end $$;

do $$
declare r record;
begin
  for r in select m.questao_id, lq.unidade_id from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
end $$;

do $$
declare
  v_novas_questoes int;
  v_novas_alternativas int;
  v_sem_1_correta int;
  v_novos_vinculos int;
  v_multiunidade int;
  v_nao_ativas int;
  v_nao_autoral int;
  v_sem_explicacao int;
  v_qtd_cc1 int;
  v_qtd_cc2 int;
  v_qtd_cc3 int;
  v_qtd_cc5 int;
  v_qtd_cc6 int;
  v_qtd_cc7 int;
  v_qtd_cc8 int;
  v_qtd_cc9 int;
  v_qtd_cc10 int;
  v_qtd_cc11 int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 29 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 29)', v_novas_questoes;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 145 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 145)', v_novas_alternativas;
  end if;

  select count(*) into v_sem_1_correta
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_sem_1_correta <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_sem_1_correta;
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 29 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 29)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  select count(*) into v_nao_ativas from public.questoes where id in (select questao_id from _mapa_ids) and ativa <> true;
  if v_nao_ativas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) nao ativas', v_nao_ativas;
  end if;

  select count(*) into v_nao_autoral from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) not like '%papiro%';
  if v_nao_autoral <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca != papiro (esperado 0, todas autoral)', v_nao_autoral;
  end if;

  select count(*) into v_sem_explicacao from public.questoes where id in (select questao_id from _mapa_ids) and (explicacao is null or length(trim(explicacao)) = 0);
  if v_sem_explicacao <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem explicacao', v_sem_explicacao;
  end if;

  select count(*) into v_qtd_cc1
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 1 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc1 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 1 recebeu % vinculos novos (esperado 3)', v_qtd_cc1;
  end if;

  select count(*) into v_qtd_cc2
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc2 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 2 recebeu % vinculos novos (esperado 3)', v_qtd_cc2;
  end if;

  select count(*) into v_qtd_cc3
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 3 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc3 <> 2 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 3 recebeu % vinculos novos (esperado 2)', v_qtd_cc3;
  end if;

  select count(*) into v_qtd_cc5
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 5 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc5 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 5 recebeu % vinculos novos (esperado 3)', v_qtd_cc5;
  end if;

  select count(*) into v_qtd_cc6
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 6 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc6 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 6 recebeu % vinculos novos (esperado 3)', v_qtd_cc6;
  end if;

  select count(*) into v_qtd_cc7
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 7 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc7 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 7 recebeu % vinculos novos (esperado 3)', v_qtd_cc7;
  end if;

  select count(*) into v_qtd_cc8
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 8 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc8 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 8 recebeu % vinculos novos (esperado 3)', v_qtd_cc8;
  end if;

  select count(*) into v_qtd_cc9
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 9 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc9 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 9 recebeu % vinculos novos (esperado 3)', v_qtd_cc9;
  end if;

  select count(*) into v_qtd_cc10
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 10 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc10 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 10 recebeu % vinculos novos (esperado 3)', v_qtd_cc10;
  end if;

  select count(*) into v_qtd_cc11
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 11 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc11 <> 3 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 11 recebeu % vinculos novos (esperado 3)', v_qtd_cc11;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 29 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 29';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 145 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 145';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 29 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 29';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou';
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

  raise notice 'Pos-condicoes OK: 29 questoes AUTORAL_PAPIRO novas / 145 alternativas / 29 vinculos / 0 multiunidade / distribuicao por conteudo conferida / banca Papiro em todas.';
end $$;

commit;
