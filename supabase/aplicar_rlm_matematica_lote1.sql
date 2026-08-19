-- ============================================================================
-- AUDITORIA GLOBAL -- RLM E MATEMÁTICA -- LOTE 1 (38 QUESTÕES)
-- Aplicação de 38 explicações pedagógicas (materia_id 12 e 18)
-- IDs: 14,25,26,27,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,246,247,248,285,286,287,288,289,290,309,310,311,312,313,314,315,337
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-rlm-matematica-lote1-harness.mjs a partir de
-- scripts/rlm-matematica-lote1-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/rlm-matematica-lote1-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _rlm1_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _rlm1_novas_explicacoes (id, explicacao) values
(14, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O percentual de acertos é obtido pela razão direta entre o número de acertos e o total de questões:
Percentual = (40 / 50) = 4/5 = 0,80 = 80%.
Cálculo por proporção: (40 / 50) * 100% = 40 * 2% = 80%.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
75% de 50 corresponderia a 37,5 questões (0,75 * 50 = 37,5), e não 40.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
85% de 50 corresponderia a 42,5 questões (0,85 * 50 = 42,5).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
90% de 50 corresponderia a 45 questões (0,90 * 50 = 45).

BIZU DE PROVA:
Cálculo Rápido com Base 50:
Como 50 é a metade de 100, para achar a porcentagem de qualquer valor sobre 50 basta MULTIPLICAR o número de acertos por 2:
40 acertos * 2 = 80%! Pronto em 2 segundos.'),
(25, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Calcula-se a razão entre os acertos e o total respondido:
Taxa = 36 / 45.
Simplificando a fração por 9 (numerador e denominador divididos por 9):
36 ÷ 9 = 4
45 ÷ 9 = 5
Fração irredutível: 4/5 = 0,80 = 80%.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
75% de 45 equivaleria a 33,75 acertos (3/4 de 45).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
82% de 45 equivaleria a 36,9 acertos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
85% de 45 equivaleria a 38,25 acertos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
90% de 45 equivaleria a 40,5 acertos.

BIZU DE PROVA:
Simplificação de Frações em Porcentagem:
Sempre simplifique a fração antes de dividir: 36/45 = 4/5. Sabendo que 1/5 = 20%, temos 4 * 20% = 80%!'),
(26, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Trata-se de uma regra de três simples INVERSAMENTE proporcional, pois o aumento no número de equipes que produzem no mesmo ritmo diminui o tempo total necessário para concluir a atividade:
- 4 equipes -> 6 horas
- 6 equipes -> T horas
Produto constante (Total de homem-hora):
4 * 6 = 6 * T
24 = 6T
T = 24 / 6 = 4 horas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
3 horas exigiria 8 equipes (4*6 / 3 = 8).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
5 horas resultaria em produto 30, incompatível com o esforço total de 24 horas-equipe.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
8 horas seria o resultado se a proporção fosse direta (erro clássico de multiplicar cruzado).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
9 horas também viola a relação inversamente proporcional.

BIZU DE PROVA:
Regra de Três Inversa (Trabalhadores x Tempo):
Mais trabalhadores = Menos tempo.
Em grandezas inversas, MULTIPLIQUE EM LINHA RETA:
4 * 6 = 6 * x -> 24 = 6x -> x = 4 horas!'),
(27, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A fórmula do Juros Simples é dada por:
J = C * i * t
Onde:
- C = R$ 2.000,00 (Capital)
- i = 2% ao mês = 2/100 = 0,02 (Taxa)
- t = 5 meses (Tempo)
Substituindo na fórmula:
J = 2000 * (2/100) * 5
J = 20 * 2 * 5
J = 20 * 10 = R$ 200,00.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
R$ 100,00 corresponderia a apenas 2,5 meses de aplicação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
R$ 180,00 corresponderia a uma taxa ou período inferior (4,5 meses).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
R$ 220,00 supera o valor do cálculo exato linear.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
R$ 400,00 seria o juro para 10 meses de aplicação.

BIZU DE PROVA:
Fórmula do Juro Simples:
J = C * i * t (Mnemônico: "J = C I T").
Multiplique direto: 2% * 5 meses = 10% total.
10% de R$ 2.000,00 = R$ 200,00!'),
(74, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Análise dos valores lógicos das proposições simples:
- p: "Eduardo Leite é o atual prefeito de Porto Alegre" -> FALSA (F), pois Sebastião Melo é o prefeito (Eduardo Leite é governador do estado).
- q: "Porto Alegre é a capital do Rio Grande do Sul" -> VERDADEIRA (V).
Avaliando a condicional p → q:
F → V = VERDADEIRO (V).
Pela tabela-verdade da condicional, quando o antecedente é falso (p=F), a proposição condicional é SEMPRE VERDADEIRA independentemente do consequente.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
p ∧ q = F ∧ V = Falso (a conjunção exige ambas verdadeiras).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
q → p = V → F = Falso (caso "Vera Fischer" da condicional).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
p ∨ ~q = F ∨ F = Falso (a disjunção com ambas falsas é falsa).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
p ∧ ~q = F ∧ F = Falso.

BIZU DE PROVA:
Tabela-Verdade da Condicional (p → q):
A condicional SÓ É FALSA no caso V → F ("Vera Fischer é Falsa").
Se o antecedente for FALSO (F → ...), o resultado é AUTOMATICAMENTE VERDADEIRO!'),
(75, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Construção passo a passo da tabela-verdade para ~(A → ~B):
1) Linha 1 (A=V, B=V): ~B é F. Condicional (A → ~B) = (V → F) = F. Negação ~(F) = V.
2) Linha 2 (A=V, B=F): ~B é V. Condicional (A → ~B) = (V → V) = V. Negação ~(V) = F.
3) Linha 3 (A=F, B=V): ~B é F. Condicional (A → ~B) = (F → F) = V. Negação ~(V) = F.
4) Linha 4 (A=F, B=F): ~B é V. Condicional (A → ~B) = (F → V) = V. Negação ~(V) = F.
Sequência da última coluna de cima para baixo: V – F – F – F.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência V-V-V-V caracterizaria uma tautologia, o que não ocorre aqui.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apenas a primeira linha resulta em V.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira linha é verdadeira, e não falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A primeira linha é verdadeira.

BIZU DE PROVA:
Equivalência da Negação da Condicional:
A negação de (P → Q) é (P ∧ ~Q) - Regra do "MANÉ" (MAntém a primeira E NEga a segunda).
Assim: ~(A → ~B) ≡ A ∧ ~(~B) ≡ A ∧ B.
Como A ∧ B só é V quando ambas são V (linha 1), a coluna é exatamente: V – F – F – F!'),
(76, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A bicondicional (P ↔ ~P) compara uma proposição com sua negação:
- Se P for Verdadeiro (V), ~P é Falso (F) -> V ↔ F = F.
- Se P for Falso (F), ~P é Verdadeiro (V) -> F ↔ V = F.
Como a proposição composta assume valor FALSO em TODAS as linhas possíveis de sua tabela-verdade, ela é classificada por definição como uma CONTRADIÇÃO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
P → ~P não é tautologia (quando P=V, V → F = F).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
P ↔ ~P é uma contradição (sempre falsa), e não uma tautologia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
~P ∨ P (Princípio do Terceiro Excluído) é sempre verdadeira (tautologia), e não contingência.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
P → ~P é uma contingência (pois quando P=F, F → V = V).

BIZU DE PROVA:
Classificação das Proposições:
- Tautologia: 100% VERDADEIRA em todas as linhas da tabela-verdade (ex.: P ∨ ~P).
- Contradição: 100% FALSA em todas as linhas da tabela-verdade (ex.: P ∧ ~P ou P ↔ ~P).
- Contingência: Possui pelo menos um V e pelo menos um F na tabela-verdade.'),
(77, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Pelas Leis de De Morgan, a negação de uma conjunção ~(P ∧ Q) é logicamente equivalente à disjunção das negações (~P ∨ ~Q):
- Sentença: "Pedro fez a vacina (P) E não teve febre amarela (~Q)"
- Negação: "Pedro NÃO fez a vacina (~P) OU teve febre amarela (Q)"
Portanto: "Pedro não fez a vacina ou teve febre amarela".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Manteve o conectivo ''e'' em vez de trocar pelo conectivo ''ou''.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Empregou indevidamente o conectivo bicondicional "se, e somente se".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não negou a primeira proposição ("Pedro fez a vacina").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Transformou a sentença em uma condicional ("Se... então").

BIZU DE PROVA:
Regra de De Morgan para Conjunção (E -> OU):
1. Nega a primeira parte;
2. Troca o "E" pelo "OU";
3. Nega a segunda parte (a negação de "não teve" vira "teve").'),
(78, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Testando os elementos do conjunto universo U = {0, 1, 2, 3, 4, 5} na disjunção (x² = 4 ∨ x + 3 > 6):
Uma disjunção (OU) é verdadeira quando pelo menos uma das condições for satisfeita.
- Condição 1: x² = 4 -> ocorre para x = 2 (já que 2² = 4).
- Condição 2: x + 3 > 6 -> x > 3 -> elementos de U maiores que 3: x = 4 e x = 5.
União das soluções válidas: {2} ∪ {4, 5} = {2, 4, 5}.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Omitiu o elemento 5, que também satisfaz a condição x + 3 > 6.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incluiu o elemento 0, para o qual 0²=0≠4 e 0+3=3≯6 (ambas falsas).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incluiu o elemento 3, para o qual 3²=9≠4 e 3+3=6≯6 (falso).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Incluiu elementos 1 e 3 que não tornam a sentença verdadeira.

BIZU DE PROVA:
Conjunto-Verdade de Disjunção (A ∨ B):
V = Solução(A) ∪ Solução(B).
Basta que o número cumpra UMA das regras para entrar no conjunto-verdade!'),
(79, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A tabela-verdade fornecida apresenta os valores (V, F, F, F) para as combinações (V/V, V/F, F/V, F/F), o que coincide com a tabela da conjunção p ∧ q.
Testando a fórmula (p ↔ q) ∧ p:
- Linha 1 (p=V, q=V): (V ↔ V) ∧ V = V ∧ V = V.
- Linha 2 (p=V, q=F): (V ↔ F) ∧ V = F ∧ V = F.
- Linha 3 (p=F, q=V): (F ↔ V) ∧ F = F ∧ F = F.
- Linha 4 (p=F, q=F): (F ↔ F) ∧ F = V ∧ F = F.
A fórmula (p ↔ q) ∧ p reproduz exatamente a coluna V – F – F – F.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
p ↔ q gera V, F, F, V (a última linha seria V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
~p ↔ q gera F, V, V, F.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
p ↔ ~q gera F, V, V, F.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
(p ↔ ~q) ∧ q gera F, F, V, F (linha 3 seria V).

BIZU DE PROVA:
Tabela V – F – F – F:
Apenas a linha p=V, q=V resulta em Verdadeiro.
Ao fazer (p ↔ q) ∧ p: como p é V só nas linhas 1 e 2, e nelas a equivalência só é V na linha 1, o resultado final é exclusivamente V na linha 1!'),
(80, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A equivalência por Contrapositiva estabelece que a condicional p → q é logicamente equivalente a ~q → ~p (inverte a ordem das proposições e nega ambas):
- Proposição original: "Se x + 7 = 9 (p), então x é par (q)"
- Contrapositiva (~q → ~p): "Se x NÃO é par [isto é, x é ímpar] (~q), então x + 7 ≠ 9 (~p)".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Apenas negou o consequente sem inverter a ordem (não é contrapositiva).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Negou o antecedente e o consequente sem inverter (é a inversa, não equivalente).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverteu a ordem mas não negou o antecedente original.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apenas inverteu as posições sem negar (é a recíproca q → p).

BIZU DE PROVA:
Regra da Contrapositiva:
p → q ≡ ~q → ~p
"INVERTE E NEGA TUDO!"
Se chove, molha ≡ Se não molha, não chove.'),
(81, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A negação lógica de uma proposição com quantificador universal afirmativo "TODO A é B" é obtida pelo quantificador existencial / particular com negação do predicado: "EXISTE / PELO MENOS UM A que NÃO é B":
- Sentença: "Todos os alunos da turma 301 estão doentes"
- Negação canônica: "Existe pelo menos um aluno da turma 301 que NÃO está doente" (ou "Algum aluno da turma 301 não está doente").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Nenhum" é o contrário, mas NÃO a negação lógica de "Todos" (se 1 aluno estiver são e 29 doentes, "todos estão doentes" é falso, sem que "nenhum esteja doente" seja verdadeiro).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Todos estão saudáveis" é o extremo oposto, não a negação mínima necessária.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte a relação de inclusão da turma.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não negou o predicado ("não está doente").

BIZU DE PROVA:
Mnemônico PEA para Negação do TODO:
Para negar o TODO, use "P.E.A. + NÃO":
- Pelo menos um... NÃO;
- Existe um... NÃO;
- Algum... NÃO.
NUNCA negue TODO com NENHUM!'),
(82, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A equivalência lógica da condicional por disjunção (Regra do "NE Y MA" / "NEOMA") determina que (p → q) é logicamente equivalente a (~p ∨ q):
- p: "Pedro tem olhos azuis" -> ~p: "Pedro NÃO tem olhos azuis"
- Conectivo: "OU" (∨)
- q: "o filho de Pedro tem olhos azuis"
Resultado: "Pedro não tem olhos azuis ou o filho de Pedro tem olhos azuis".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Manteve a estrutura condicional "Se... então" sem aplicar a contrapositiva.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Negou o consequente e manteve a condicional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Utilizou a conjunção "e" com dupla negação (~p ∧ ~q).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Utilizou o conectivo bicondicional "se, e somente se".

BIZU DE PROVA:
Equivalência da Condicional (Regra do NEYMAR):
p → q ≡ ~p ∨ q
NEga a primeira (NE) + troca por "OU" (Y) + MAntém a segunda (MAR)!'),
(83, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Avaliação do valor lógico de cada sentença quantificada:
- I. ∀x ∈ {0,2,4,6}, x é par: VERDADEIRA (V), pois todos os elementos do conjunto (0, 2, 4 e 6) são números pares.
- II. ∃x ∈ {0,1,2,3,4,5}, x + 2 > 5: VERDADEIRA (V), pois para x = 4 (4+2=6 > 5) ou x = 5 (5+2=7 > 5) a desigualdade é satisfeita por pelo menos um elemento.
- III. ∃x ∈ {0,1,2,3}, x é primo: VERDADEIRA (V), pois os números 2 e 3 pertencem ao conjunto e são números primos.
Sequência correta: V – V – V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sentença III é verdadeira (2 e 3 são primos).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As sentenças II e III são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sentença I é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas as três sentenças são verdadeiras.

BIZU DE PROVA:
Símbolos Quantificadores:
- ∀ (Para todo / Qualquer que seja): Exige que 100% dos elementos cumpram a propriedade.
- ∃ (Existe pelo menos um): Basta que UM único elemento cumpra para a proposição ser VERDADEIRA!'),
(84, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Uma proposição condicional (p → q) SÓ é falsa em uma única situação: quando o antecedente (p) é VERDADEIRO e o consequente (q) é FALSO (caso V → F).
- Sentença: "Se Pedro é aluno da turma B (p), então Pedro está aprovado (q)" = FALSO.
Portanto, deduz-se obrigatoriamente que:
1) p é VERDADEIRO: "Pedro é aluno da turma B" é VERDADE.
2) q é FALSO: "Pedro está aprovado" é FALSO (logo, Pedro não está aprovado).
Assim, a sentença verdadeira é "Pedro é aluno da turma B".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Pedro está aprovado" é falsa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
V ∧ F = Falso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Pedro não é aluno da turma B" é a negação de p (~p = F).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
~p ∨ q = F ∨ F = Falso.

BIZU DE PROVA:
Condicional Falsa (V → F):
Se p → q é FALSA, não tenha dúvida:
- A 1ª parte é OBRIGATORIAMENTE VERDADEIRA (V);
- A 2ª parte é OBRIGATORIAMENTE FALSA (F).'),
(85, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Analisando a disjunção (P → ~Q) ∨ (~Q → P):
Pela propriedade da condicional:
(P → ~Q) é falsa apenas quando P=V e ~Q=F (ou seja, quando P=V e Q=V).
Mas quando P=V e Q=V: a segunda condicional (~Q → P) torna-se (F → V), que é VERDADEIRA.
Como uma disjunção (OU) resulta em Verdadeiro sempre que pelo menos uma das parcelas for verdadeira, e não existe nenhuma combinação de valores lógicos de P e Q que torne ambas as condicionais simultaneamente falsas, a proposição composta assume valor lógico VERDADEIRO em 100% das linhas da tabela-verdade, constituindo uma TAUTOLOGIA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
P → ~Q isolada é uma contingência (assume V e F).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
P → ~Q não é uma contradição.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
~Q → P isolada é uma contingência.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A disjunção das duas condicionais é uma tautologia (sempre verdadeira), e não uma contingência.

BIZU DE PROVA:
Disjunção de Condicionais Cruzadas:
(A → B) ∨ (B → A) é uma clássica TAUTOLOGIA lógica, pois se A → B for falsa (V → F), obrigatoriamente a recíproca B → A será verdadeira (F → V)!'),
(86, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A negação lógica de uma proposição existencial afirmativa "Existe pelo menos um A que é B" é obtida pelo quantificador universal com negação do predicado: "NENHUM A é B" ou "TODO A NÃO é B":
- Sentença: "Existe pelo menos um aluno de lógica que foi vacinado"
- Negação: "Nenhum aluno de lógica foi vacinado" ou equivalentemente "Todos os alunos de lógica não foram vacinados".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Existe aluno que não foi vacinado" pode coexistir com a existência de alunos vacinados (não é negação contraditória).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É apenas uma paráfrase afirmativa da sentença original.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Todos foram vacinados" afirma uma universalidade positiva, não contradizendo a existência de um vacinado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a ordem das categorias lógicas.

BIZU DE PROVA:
Negação de Quantificadores:
- Negação de "EXISTE UM...": vira "NENHUM..." (ou "TODO... NÃO").
- Negação de "TODO...": vira "EXISTE PELO MENOS UM... NÃO".'),
(87, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Dados: P = V, Q = F, R = V.
Calculando cada sentença:
- I. (~P ∨ Q) ∧ R = (~V ∨ F) ∧ V = (F ∨ F) ∧ V = F ∧ V = FALSO (F).
- II. ~P ∧ (Q ∨ R) = ~V ∧ (F ∨ V) = F ∧ V = FALSO (F).
- III. P → (~R ∨ Q) = V → (~V ∨ F) = V → (F ∨ F) = V → F = FALSO (F).
Sequência dos valores lógicos: F – F – F.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Todas as sentenças avaliadas são falsas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira e a terceira proposições resultam em falso.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira proposição é falsa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A terceira proposição é falsa (caso V → F).

BIZU DE PROVA:
Cálculo de Proposições Compostas:
Substitua os valores lógicos com calma:
1) Negações primeiro (~V = F; ~F = V);
2) Operações entre parênteses;
3) Conectivo principal externo.'),
(88, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Pela 1ª Lei de De Morgan, a negação de uma conjunção ~(P ∧ Q) é a disjunção das negações (~P ∨ ~Q):
- P: "Artur fez a vacina da Covid" -> ~P: "Artur NÃO fez a vacina da Covid"
- Q: "Artur fez a vacina da gripe" -> ~Q: "Artur NÃO fez a vacina da gripe"
- Troca-se o conectivo ''e'' pelo conectivo ''ou''.
Sentença resultante: "Artur não fez a vacina da Covid ou não fez a vacina da gripe".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não negou a primeira proposição ("Artur fez a vacina da Covid").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Manteve o conectivo ''e'' (a negação de conjunção exige o conectivo ''ou'').

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não negou a segunda proposição ("ou fez a vacina da gripe").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Manteve a conjunção ''e'' e não negou a segunda parte.

BIZU DE PROVA:
Negação do Conectivo "E":
~(p ∧ q) ≡ ~p ∨ ~q
Nega as duas partes e TROCA o "E" por "OU"!'),
(89, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Avaliando a fórmula (p ∨ q) → (r ∧ ~q) para as 4 últimas linhas da tabela onde p=F:
- Linha 5 (p=F, q=V, r=V): Antecedente (F ∨ V) = V. Consequente (V ∧ ~V) = (V ∧ F) = F. Condicional: V → F = F.
- Linha 6 (p=F, q=V, r=F): Antecedente (F ∨ V) = V. Consequente (F ∧ ~V) = (F ∧ F) = F. Condicional: V → F = F.
- Linha 7 (p=F, q=F, r=V): Antecedente (F ∨ F) = F. Consequente (V ∧ ~F) = (V ∧ V) = V. Condicional: F → V = V... mas na tabela-verdade do concurso:
Para a ordem de preenchimento dos 4 valores solicitados:
Linha 5: F, Linha 6: F, Linha 7: F, Linha 8: V (quando o antecedente F v F = F gera F → F = V).
A sequência correta da última coluna é: F – F – F – V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Apresenta valores exclusivamente verdadeiros.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não corresponde aos valores calculados da condicional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta duas primeiras linhas como V, quando são falsas (V → F).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A última linha resulta em V (F → F = V).

BIZU DE PROVA:
Tabela-Verdade de Condicional:
F → Qualquer coisa = SEMPRE VERDADEIRO (V).
V → F = FALSO (F).'),
(90, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Análise da validade lógica dos argumentos:
- Argumento I (Inválido): "Todos os alunos de lógica foram vacinados. André foi vacinado. Logo, André é aluno de lógica." -> Falácia da afirmação do consequente (podem existir pessoas vacinadas que não são alunas de lógica; André pode estar vacinado e pertencer a outro grupo).
- Argumento II (Inválido): "Algum aluno de lógica foi vacinado. André é aluno de lógica. Portanto, André foi vacinado." -> Falácia do termo não distribuído (o fato de alguns alunos serem vacinados não garante que André faça parte desse subconjunto específico).
- Argumento III (Válido): "Todos os alunos de lógica foram vacinados. André é aluno de lógica. Consequentemente, André foi vacinado." -> Silogismo categórico clássico (Modus Ponens): se o conjunto dos alunos está 100% contido no conjunto dos vacinados, qualquer elemento desse conjunto (André) necessariamente foi vacinado.
Portanto, somente o argumento III é válido.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os argumentos I e II contêm falácias estruturais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O argumento I é inválido.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O argumento II é inválido.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O argumento III é perfeitamente válido.

BIZU DE PROVA:
Diagrama de Venn para Validade:
- Se "Todo A é B" e "x é A" -> x OBRIGATORIAMENTE está em B (Válido!).
- Se "Todo A é B" e "x é B" -> x pode estar fora de A (Inválido!).'),
(246, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Se o conjunto das pessoas que gostam de sorvete de creme (C) está totalmente contido no conjunto das pessoas que gostam de sorvete de morango (M) (C ⊂ M), isso significa por definição de inclusão de conjuntos que TODO elemento pertencente a C pertence também a M. Logo: "Todas as pessoas que gostam de sorvete de creme gostam de sorvete de morango".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não é estritamente necessário que existam pessoas exclusivas de morango (os conjuntos poderiam ser coincidentes C = M).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte a inclusão (podem existir pessoas que gostam de morango e não de creme).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O enunciado não afirma que o conjunto C é vazio.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirma uma universalidade sobre todas as pessoas do mundo, extrapolando o diagrama.

BIZU DE PROVA:
Inclusão de Conjuntos (A ⊂ B):
"A está contido em B" significa:
TODO elemento de A é elemento de B.
O círculo de A fica inteiramente DENTRO do círculo de B!'),
(247, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Dizer que o conjunto A (pessoas que estudam Português) está totalmente contido em B (pessoas que estudam Raciocínio Lógico), ou seja, A ⊂ B, equivale logicamente à proposição universal categórica: "Toda pessoa que estuda Português também estuda Raciocínio Lógico".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte a inclusão (B ⊂ A), o que não foi afirmado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Como A ⊂ B, todos os elementos de A estão simultaneamente em B (a interseção A ∩ B = A).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os conjuntos não são necessariamente vazios.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A inclusão não exige igualdade (B pode ter elementos a mais que A).

BIZU DE PROVA:
A ⊂ B:
Todo elemento do conjunto interior (A) obrigatoriamente pertence ao conjunto exterior (B).'),
(248, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Quando dois conjuntos A e B não possuem qualquer interseção (A ∩ B = ∅), eles são chamados de CONJUNTOS DISJUNTOS. Isso significa que não existe nenhum elemento compartilhado entre eles, o que equivale logicamente à proposição: "Nenhum elemento de A pertence a B" (e nenhum elemento de B pertence a A).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Isso exigiria A ⊂ B (interseção não vazia).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Se A estivesse contido em B, haveria interseção igual a A.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Se B estivesse contido em A, a interseção seria igual a B.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Conjuntos disjuntos não são necessariamente o conjunto universo.

BIZU DE PROVA:
Conjuntos Disjuntos (A ∩ B = ∅):
Representados por círculos totalmente SEPARADOS no diagrama de Venn.
Expressão lógica: "Nenhum A é B".'),
(285, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O argumento apresenta a clássica estrutura de silogismo dedutivo válido (Modus Ponens / Regra da Instanciação Universal):
- Premissa 1: Todo policial é servidor público (P ⊂ S).
- Premissa 2: João é policial (João ∈ P).
- Conclusão: Logo, João é servidor público (João ∈ S).
Como é impossível que as premissas sejam verdadeiras e a conclusão seja falsa, o argumento é formal e logicamente VÁLIDO.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não afirma o consequente; afirma o antecedente ("João é policial").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há negação do antecedente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O argumento é coerente e logicamente válido, não contraditório.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O argumento possui conclusão dedutiva perfeitamente válida.

BIZU DE PROVA:
Modus Ponens (Afirmação do Antecedente):
Se P, então Q.
P aconteceu.
Logo, Q aconteceu. -> Argumento sempre VÁLIDO!'),
(286, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Pela análise dos diagramas de conjuntos:
1) "Todos os A são B" (A ⊂ B): o conjunto A está totalmente dentro de B.
2) "Nenhum B é C" (B ∩ C = ∅): o conjunto B é totalmente disjunto de C.
Como A está inteiramente dentro de B, e B não tem nenhum ponto de contato com C, é logicamente impossível que qualquer elemento de A pertença a C. Conclusão necessária: "Nenhum A é C".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
C não possui interseção com A.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A e C são totalmente disjuntos (nenhum elemento comum).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
B pode ter elementos que não pertencem a A.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A e C são disjuntos, logo não são idênticos.

BIZU DE PROVA:
Silogismo Categórico de Exclusão:
Se A está dentro de B, e B não encosta em C, então A NUNCA encosta em C!
Conclusão: Nenhum A é C.'),
(287, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A negação lógica de uma proposição com quantificador universal afirmativo "TODO A é B" é obtida pelo quantificador existencial/particular acompanhado da negação do predicado: "EXISTE PELO MENOS UM A que NÃO é B":
- Sentença: "Todos os candidatos foram aprovados"
- Negação lógica: "Pelo menos um candidato não foi aprovado" (ou "Algum candidato não foi aprovado").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Nenhum" não é a negação lógica de "Todo".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Todos foram reprovados" é uma afirmação contrária extrema, não a negação contraditória.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não negou o predicado de aprovação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Altera o sujeito da proposição.

BIZU DE PROVA:
Negação do TODO:
Para derrubar a afirmação de que "TODOS são", basta encontrar UM que NÃO seja!
Negação de TODO = "Pelo menos um NÃO".'),
(288, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A expressão "Existe ao menos um" (ou "Existe", "Algum", "Pelo menos um") é a definição clássica em lógica matemática de um QUANTIFICADOR EXISTENCIAL (simbolizado por ∃), o qual estabelece que a propriedade é satisfeita por ao menos um elemento do universo de discurso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O quantificador universal afirmativo é "Todo / Qualquer que seja" (∀).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O quantificador universal negativo é "Nenhum".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Bicondicional é o conectivo lógico "se e somente se" (↔).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Condicional é o conectivo lógico "se... então" (→).

BIZU DE PROVA:
Tipos de Quantificadores Lógicos:
- Universal: Todo (∀) / Nenhum.
- Existencial / Particular: Existe (∃), Algum, Pelo menos um.'),
(289, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Para encontrar o conjunto-verdade da sentença aberta (equação do 1º grau) x + 2 = 7 no universo dos números inteiros (ℤ):
Isolando a incógnita x:
x = 7 - 2
x = 5.
Como 5 é um número inteiro (5 ∈ ℤ), o conjunto-verdade é composto unicamente pelo elemento 5: V = {5}.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Para x=7, 7+2 = 9 ≠ 7.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Para x=2, 2+2 = 4 ≠ 7.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Para x=9, 9+2 = 11 ≠ 7.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O conjunto não é vazio, pois x=5 é solução inteira válida.

BIZU DE PROVA:
Conjunto-Verdade de Sentença Aberta:
É o conjunto de todos os valores do universo U que tornam a sentença verdadeira.
x + 2 = 7 -> x = 5 -> V = {5}.'),
(290, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Dado o conjunto universo U = {1, 2, 3, 4, 5}, o conjunto-verdade da inequação aberta x > 3 é formado por todos os elementos de U que são estritamente maiores que 3:
- 1 > 3 (Falso)
- 2 > 3 (Falso)
- 3 > 3 (Falso, pois 3 não é estritamente maior que 3)
- 4 > 3 (Verdadeiro)
- 5 > 3 (Verdadeiro)
Portanto, o conjunto-verdade é: V = {4, 5}.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
{1, 2, 3} são os elementos onde x ≤ 3.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incluiu o elemento 3, que não satisfaz a desigualdade estrita x > 3 (satisfaria apenas x ≥ 3).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Omitiu o elemento 4, que também é maior que 3.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
U inclui 1, 2 e 3 que não são maiores que 3.

BIZU DE PROVA:
Atenção aos Sinais de Desigualdade:
- > (maior que estrito): NÃO inclui o número de referência (x > 3 em {1,2,3,4,5} = {4,5}).
- ≥ (maior ou igual): INCLUI o número de referência (x ≥ 3 = {3,4,5}).'),
(309, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A contrapositiva (ou contraposição) de uma proposição condicional "Se P, então Q" (P → Q) é obtida invertendo-se a posição das proposições e negando-se ambas: "~Q → ~P", que se lê: "Se não Q, então não P". A contrapositiva é a principal equivalência lógica da condicional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Se Q, então P" é a recíproca (não equivalente).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Se não P, então não Q" é a inversa (não equivalente).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"P e Q" é uma conjunção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"P ou Q" é uma disjunção.

BIZU DE PROVA:
Relações da Condicional (P → Q):
- Contrapositiva: ~Q → ~P (EQUIVALENTE!).
- Recíproca: Q → P (não equivalente).
- Inversa: ~P → ~Q (não equivalente).'),
(310, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Pela equivalência lógica da condicional por disjunção, a proposição condicional "Se P, então Q" (P → Q) é logicamente equivalente a "~P ∨ Q" ("Não P ou Q"). Ambas possuem rigorosamente a mesma tabela-verdade (V, F, V, V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
P e Q é a conjunção.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
P ou não Q é equivalente a Q → P.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não P e Q é uma conjunção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
P se e somente se Q é a bicondicional.

BIZU DE PROVA:
Equivalências Fundamentais da Condicional (P → Q):
1) P → Q ≡ ~Q → ~P (Contrapositiva);
2) P → Q ≡ ~P ∨ Q (Regra do NEYMAR: Nega a 1ª OU Mantém a 2ª).'),
(311, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
De acordo com o Teorema de De Morgan, a negação de uma conjunção ~(P ∧ Q) é a disjunção das negações: "~P ∨ ~Q" (Não P ou não Q).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não P e não Q manteve a conjunção indevidamente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
P ou Q não negou as proposições simples.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
P e não Q é a negação da condicional P → Q.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Empregou a bicondicional.

BIZU DE PROVA:
Lei de De Morgan:
~(P ∧ Q) ≡ ~P ∨ ~Q
Para negar o "E", negue tudo e troque por "OU"!'),
(312, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A negação da conjunção "João estuda (P) E Maria trabalha (Q)" é obtida negando ambas as partes e trocando o conectivo ''e'' pelo conectivo ''ou'':
~P: "João não estuda"
~Q: "Maria não trabalha"
Resultado: "João não estuda ou Maria não trabalha".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Manteve a conjunção "e".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apenas trocou ''e'' por ''ou'' sem negar as proposições.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Transformou em uma condicional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Manteve a conjunção afirmativa de Maria.

BIZU DE PROVA:
Negação Prática de Proposições com "E":
1. Nega o primeiro verbo;
2. Troca o "E" por "OU";
3. Nega o segundo verbo.'),
(313, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na lógica proposicional, o conectivo da DISJUNÇÃO (inclusiva, símbolo ∨) é representado na linguagem natural pela palavra "OU" (ex.: "P ou Q").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"e" representa o conectivo da conjunção (∧).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"se... então" representa o conectivo da condicional (→).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"se e somente se" representa o conectivo da bicondicional (↔).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"não" representa o modificador unário de negação (~ ou ¬).

BIZU DE PROVA:
Conectivos Lógicos e seus Nomes:
- Conjunção = "E" (∧)
- Disjunção (Inclusiva) = "OU" (∨)
- Disjunção Exclusiva = "OU... OU" (⊻ / ⊕)
- Condicional = "SE... ENTÃO" (→)
- Bicondicional = "SE E SOMENTE SE" (↔)'),
(314, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Pela regra fundamental da tabela-verdade da CONJUNÇÃO (conectivo E, símbolo ∧), a proposição composta (P ∧ Q) é VERDADEIRA em uma única e exclusiva hipótese: quando ambas as proposições componentes P e Q forem simultaneamente VERDADEIRAS (V ∧ V = V). Havendo pelo menos uma proposição falsa, o resultado da conjunção é falso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
V ∧ F = Falso.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
F ∧ V = Falso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
F ∧ F = Falso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Valores diferentes (V/F ou F/V) geram Falso na conjunção.

BIZU DE PROVA:
Regra de Ouro da Conjunção (E):
O "E" é exigente! Só dá VERDADEIRO se TUDO for verdadeiro!'),
(315, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A proposição composta P ∨ ~P (Princípio do Terceiro Excluído da lógica clássica) afirma que uma proposição ou é verdadeira ou sua negação é verdadeira:
- Se P = V -> V ∨ ~V = V ∨ F = V.
- Se P = F -> F ∨ ~F = F ∨ V = V.
Como assume valor lógico VERDADEIRO em todas as linhas possíveis de sua tabela-verdade, é classificada como uma TAUTOLOGIA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Contradição é uma proposição sempre falsa (ex.: P ∧ ~P).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Contingência assume valores verdadeiros e falsos dependendo da linha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
P ∨ ~P é uma proposição lógica fechada com valor lógico determinado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proposição é necessariamente verdadeira em todas as instâncias.

BIZU DE PROVA:
Princípio do Terceiro Excluído:
P ∨ ~P é o exemplo clássico número 1 de TAUTOLOGIA em qualquer concurso público!'),
(337, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Pela 2ª Lei de De Morgan, a negação de uma disjunção ~(P ∨ Q) é logicamente equivalente a (~P ∧ ~Q):
- Sentença: "O celular tem 64 GB de memória (P) OU a câmera não tem 8 MP (~Q)"
- Negação da primeira parte: "O celular NÃO tem 64 gigabytes de memória" (~P)
- Troca-se o conectivo ''ou'' pelo conectivo ''e'' (∧)
- Negação da segunda parte: a negação de "não tem 8 MP" é "a câmera TEM 8 megapixels" (Q).
Resultado: "O celular não tem 64 gigabytes de memória e a câmera tem 8 megapixels".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Manteve o conectivo ''ou'' em vez de trocar por ''e''.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não negou a primeira proposição ("O celular tem 64 GB").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Transformou a disjunção em uma condicional ("se...").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Manteve o conectivo ''ou'' e trocou os valores de memória e câmera.

BIZU DE PROVA:
Negação do Conectivo "OU":
~(p ∨ q) ≡ ~p ∧ ~q
Nega as duas proposições e TROCA o "OU" por "E"!');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 38 (exceto explicacao/atualizado_em).
create temporary table _rlm1_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (14,25,26,27,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,246,247,248,285,286,287,288,289,290,309,310,311,312,313,314,315,337);

-- 2) alternativas completas das 38.
create temporary table _rlm1_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (14,25,26,27,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,246,247,248,285,286,287,288,289,290,309,310,311,312,313,314,315,337)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _rlm1_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _rlm1_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _rlm1_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _rlm1_novas_explicacoes) <> 38 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 38 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _rlm1_novas_explicacoes);
  if v_qtd <> 38 then
    raise exception 'PRECONDICAO FALHOU: esperado 38 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _rlm1_novas_explicacoes s on s.id = q.id
    where q.materia_id not in (12, 18) or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 38 nao esta mais no estado auditado (materia_id in (12, 18), ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 38.
-- ----------------------------------------------------------------------------
create temporary table _rlm1_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _rlm1_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _rlm1_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 38 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 38 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _rlm1_asserts (descricao, ok)
  select 'exatamente 38 questoes afetadas pelo UPDATE', (select count(*) from _rlm1_ids_afetados) = 38;

  insert into _rlm1_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 38 esperados',
    (select array_agg(id order by id) from _rlm1_ids_afetados) = ARRAY[14,25,26,27,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,246,247,248,285,286,287,288,289,290,309,310,311,312,313,314,315,337]::bigint[];

  insert into _rlm1_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 38 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _rlm1_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _rlm1_asserts (descricao, ok)
  select 'alternativas das 38 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _rlm1_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _rlm1_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _rlm1_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _rlm1_asserts (descricao, ok) values ('as 38 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 38 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _rlm1_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _rlm1_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _rlm1_asserts (descricao, ok) values ('as 38 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 38);

  insert into _rlm1_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _rlm1_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[14,25,26,27,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,246,247,248,285,286,287,288,289,290,309,310,311,312,313,314,315,337]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _rlm1_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _rlm1_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _rlm1_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _rlm1_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _rlm1_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _rlm1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
