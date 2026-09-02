-- Aplicacao REAL do Lote 2 AUTORAL_PAPIRO de Raciocinio Logico — 29
-- questoes novas + 145 alternativas + 29 vinculos, validado pelo harness
-- supabase/importar_lote2_rlm_autoral_teste_rollback.sql (tudo_ok = true
-- confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_rlm_lote2_autoral.json. Origem: AUTORAL_PAPIRO (banca
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
(1, '6683c484-74a7-4b07-9cda-1a72190e6445', 36, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere as proposições simples: p: "O plantão policial começa às 18h". q: "A viatura está com o tanque cheio". Sabendo que p é verdadeira e q é falsa, o valor lógico da proposição composta (p ∧ q) ∨ ~q é:'),
(2, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Uma tabela-verdade completa, com todas as combinações possíveis de valores V/F, possui exatamente 16 linhas. Quantas proposições simples distintas compõem a proposição composta correspondente?'),
(3, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Na tabela-verdade completa da proposição composta (p ∨ ~q) ∧ r, com p, q e r proposições simples distintas, em quantas das 8 linhas o resultado final é VERDADEIRO?'),
(4, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a tabela-verdade abaixo, parcialmente preenchida, da proposição composta (p ∧ ~q) ∨ (~p ∧ q):

| Linha | p | q | ~q | ~p | p∧~q | ~p∧q | Resultado |
|---|---|---|---|---|---|---|---|
| 1 | V | V | F | F | F | F | F |
| 2 | V | F | V | F | V | F | V |
| 3 | F | V | F | V | F | V | V |
| 4 | F | F | V | V | F | F | ? |

Qual é o valor lógico do Resultado na linha 4?'),
(5, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab', 38, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Construindo a tabela-verdade completa da proposição composta (p ∨ q) → ~p, considerando as linhas para p e q na ordem V/V, V/F, F/V e F/F, a coluna do resultado final, de cima para baixo, será:'),
(6, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição "P se e somente se Q" é logicamente equivalente a:'),
(7, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que a proposição composta A, formada pelas proposições simples p e q, assume valor FALSO apenas quando p é verdadeiro e q é falso, sendo verdadeira em todos os demais casos. A proposição A é logicamente equivalente a:'),
(8, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9', 41, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A afirmação "O policial não está de plantão ou o rádio está ligado" é logicamente equivalente a qual proposição condicional?'),
(9, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Na proposição condicional "Se o suspeito confessar o crime, então o inquérito será concluído mais rapidamente", o antecedente e o consequente são, respectivamente:'),
(10, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a proposição condicional "Se chove, então a rua fica molhada". A proposição "Se a rua não fica molhada, então não chove" é classificada como a:'),
(11, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a condicional "Se um servidor é aprovado no concurso, então ele é nomeado." Assinale a alternativa que apresenta a RECÍPROCA dessa condicional:'),
(12, '42f5f55c-350a-4fb6-904c-184cde415d1e', 39, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A contrapositiva da proposição "Se o equipamento está descarregado, então ele não funciona" é:'),
(13, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição "Toda viatura da corporação possui rastreador veicular" utiliza o quantificador:'),
(14, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {segunda, terça, quarta, quinta, sexta} e as sentenças: I. ∀x∈U (x é um dia da semana). II. ∃x∈U (x = "sábado"). III. ∃x∈U (x começa com a letra "s"). Assinale a alternativa correta quanto ao valor lógico dessas sentenças:'),
(15, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {caneta, borracha, régua, lápis} e a sentença: "Existe pelo menos um objeto em U cujo nome começa com a letra L." Essa sentença é:'),
(16, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c', 33, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {2, 4, 6, 9} e a sentença: "Para todo x pertencente a U, x é um número par." Essa sentença é:'),
(17, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição composta p ∨ ~p ∨ q é classificada como:'),
(18, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição composta (p ∧ ~p) ∧ q é classificada como:'),
(19, 'ae60f2db-49d0-4326-980c-df1617a0bc35', 37, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A proposição composta p → (p ∧ q) é classificada como:'),
(20, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo dos números inteiros e a sentença aberta 2x - 5 = -11. O conjunto-verdade dessa sentença é:'),
(21, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o universo U = {-3, -2, -1, 0, 1, 2, 3} e a sentença aberta x < -1 ∨ x > 1. O conjunto-verdade dessa sentença, em U, é:'),
(22, '4ed265ff-578a-4462-bce6-d756b8ad5838', 32, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'A expressão "x + 3 é um número primo" é um exemplo de:'),
(23, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o argumento: "Algum policial é atirador de elite. Carlos é policial. Logo, Carlos é atirador de elite." Esse argumento é:'),
(24, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere o argumento: "Se o alarme está ativado, então a porta está trancada. A porta não está trancada. Logo, o alarme não está ativado." Esse argumento é:'),
(25, '5e2d5159-41da-4af7-b75d-4dc21239177d', 40, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere as premissas: "Todo agente do setor X usa colete balístico." "Marcos usa colete balístico." A partir dessas premissas, é correto afirmar que a conclusão "Marcos é agente do setor X" é:'),
(26, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Considere a afirmação: "Todo policial civil do Estado X é servidor público estadual." Sejam C o conjunto dos policiais civis do Estado X e S o conjunto dos servidores públicos estaduais do Estado X. A relação entre C e S que representa corretamente essa afirmação é:'),
(27, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Em um determinado grupo, sabe-se que os conjuntos M (pessoas que fazem musculação) e C (pessoas que fazem corrida) apresentam uma relação de interseção parcial. Com base SOMENTE nessa informação, é correto afirmar que:'),
(28, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que os conjuntos P (peças de reposição do modelo A) e Q (peças de reposição do modelo B) não possuem nenhum elemento em comum. Essa relação corresponde corretamente à seguinte afirmação categórica:'),
(29, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9', 31, 'Papiro', 'PAPIRO - Adaptada do padrão Fundatec 2025/2026', 2026, 'PAPIRO • QUESTÃO ADAPTADA DO PADRÃO RECENTE FUNDATEC 2025/2026', 'Sabe-se que o conjunto V (veículos elétricos) está totalmente contido no conjunto R (veículos registrados na frota da corporação). Com base SOMENTE nessa informação, é correto afirmar que:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Com p=V e q=F: (p∧q) = V∧F = F. ~q = ~F = V. Logo (p∧q)∨~q = F∨V = V (Verdadeiro).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Ignora o termo ~q, que é verdadeiro e já garante o resultado da disjunção.
C) Uma proposição composta com valores fixos das simples tem valor lógico determinado — nunca depende de "outros fatores".
D) Não existe essa regra para a disjunção; o valor de (p∧q)∨~q não depende de p e q terem o mesmo valor.
E) Erro clássico: considerar apenas q=F e esquecer de negar q antes de aplicar a disjunção.

BIZU DE PROVA:
Sempre resolva de dentro para fora: primeiro as negações e os parênteses, depois os conectivos externos — nunca avalie um conectivo composto "de cabeça" sem esse procedimento.'),
(2, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O número de linhas de uma tabela-verdade completa é sempre 2ⁿ, onde n é o número de proposições simples distintas. Como 2⁴=16, a proposição composta é formada por 4 proposições simples distintas.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) 2² = 4 linhas, não 16.
B) 2³ = 8 linhas, não 16.
D) 2⁵ = 32 linhas, não 16.
E) Confunde o número de linhas (16) com o número de proposições simples — são grandezas diferentes.

BIZU DE PROVA:
Sempre que o número de linhas for dado, encontre n resolvendo 2ⁿ = total de linhas — 16=2⁴, 8=2³, 4=2², 32=2⁵.'),
(3, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Construindo as 8 linhas de (p∨~q)∧r: VVV→(V∨F)∧V=V∧V=V; VVF→V∧F=F; VFV→(V∨V)∧V=V∧V=V; VFF→V∧F=F; FVV→(F∨F)∧V=F∧V=F; FVF→F∧F=F; FFV→(F∨V)∧V=V∧V=V; FFF→V∧F=F. Contando os resultados V: linhas 1, 3 e 7 — total de 3 linhas verdadeiras.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A), C), D) e E) não correspondem à contagem correta (2, 4, 5 e 8) obtida na construção sistemática das 8 linhas.

BIZU DE PROVA:
Uma conjunção (∧) só é verdadeira quando AMBOS os lados são verdadeiros — construa primeiro a coluna de p∨~q, depois combine linha a linha com a coluna de r, marcando V apenas onde as duas colunas coincidem em V.'),
(4, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na linha 4, p=F e q=F. Logo ~q=V e ~p=V (já preenchidos). p∧~q = F∧V = F (já preenchido). ~p∧q = V∧F = F (já preenchido). O Resultado é a disjunção dessas duas colunas: F∨F = F.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Inverte o valor correto.
C) e D) O resultado é totalmente determinado pelas colunas intermediárias já calculadas na própria linha — não depende de nada externo nem falta informação.
E) Coincidência aparente sem fundamento lógico: o resultado da linha 4 (F) não decorre de nenhuma relação de inversão com a linha 1 (que também é F por outro motivo).

BIZU DE PROVA:
Quando as colunas intermediárias já estão prontas, o resultado final é só aplicar o último conectivo (aqui, a disjunção) sobre elas — não reavalie p e q do zero.'),
(5, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Linha V/V: p∨q=V, ~p=F, V→F=F. Linha V/F: p∨q=V, ~p=F, V→F=F. Linha F/V: p∨q=V, ~p=V, V→V=V. Linha F/F: p∨q=F, ~p=V, F→V=V. A sequência é F, F, V, V.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A), C), D) e E) não correspondem à sequência obtida pela construção sistemática das 4 linhas, coluna por coluna (p∨q, depois ~p, depois o condicional entre elas).

BIZU DE PROVA:
Monte sempre as colunas intermediárias (aqui, p∨q e ~p) antes de aplicar o conectivo principal — nunca tente adivinhar o resultado final sem passar pelas etapas.'),
(6, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A bicondicional p↔q é logicamente equivalente à conjunção (p→q)∧(q→p) — "se P então Q" E "se Q então P", ligadas por "e" (conjunção), não por "ou".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) "P e Q" (p∧q) não é equivalente: a bicondicional também é verdadeira quando ambas são falsas, caso em que p∧q é falsa.
C) Usar "ou" entre as duas condicionais resulta em uma tautologia (sempre verdadeira), completamente diferente do comportamento da bicondicional.
D) "Nem P, nem Q" (~p∧~q) ignora o caso em que ambas são verdadeiras.
E) É a definição do OU EXCLUSIVO — exatamente a NEGAÇÃO da bicondicional, não sua equivalente.

BIZU DE PROVA:
p↔q ≡ (p→q)∧(q→p) sempre — a bicondicional exige as DUAS implicações simultaneamente, ligadas por "e".'),
(7, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O comportamento descrito (falso apenas quando p=V e q=F) é exatamente a condição de verdade da condicional p→q, que é logicamente equivalente a ~p∨q. Verificando ~p∨q nas 4 linhas: VV→F∨V=V; VF→F∨F=F; FV→V∨V=V; FF→V∨F=V — падrão V,F,V,V, idêntico ao descrito.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) p∧q só é verdadeira quando ambas são verdadeiras — comportamento totalmente diferente.
C) p∨~q é falsa apenas quando p=F e q=V — padrão invertido em relação ao pedido.
D) ~p∧~q só é verdadeira quando ambas são falsas — não corresponde.
E) q→p (a recíproca de p→q) é falsa quando q=V e p=F — padrão diferente do descrito.

BIZU DE PROVA:
"Falso só quando o primeiro é V e o segundo é F" é sempre a assinatura da condicional (→) — e toda condicional p→q tem ~p∨q como equivalente direta.'),
(8, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Seja P="o policial está de plantão" e Q="o rádio está ligado". A afirmação dada é ~P∨Q, que é logicamente equivalente a P→Q = "Se o policial está de plantão, então o rádio está ligado".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É Q→P, a RECÍPROCA de P→Q — não equivalente.
C) É a NEGAÇÃO de ~P∨Q (equivale a P∧~Q), o oposto do que foi afirmado.
D) É ~P→~Q, a INVERSA de P→Q — não equivalente.
E) É a bicondicional P↔Q, uma proposição mais forte, não equivalente à disjunção original.

BIZU DE PROVA:
Para transformar "~P ou Q" em condicional: a negação do primeiro termo vira o antecedente sem negação, e o segundo termo (sem negação) vira o consequente — sempre P→Q.'),
(9, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na estrutura "Se P, então Q", o antecedente é sempre o termo que segue "Se" e o consequente é o termo que segue "então". Aqui, antecedente = "o suspeito confessar o crime"; consequente = "o inquérito será concluído mais rapidamente".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Inverte antecedente e consequente.
C) Toda condicional bem formada "Se P, então Q" possui os dois termos.
D) Antecedente e consequente são papéis distintos dentro da condicional, nunca os dois ao mesmo tempo.
E) A estrutura "Se..., então..." identifica os dois termos de forma inequívoca.

BIZU DE PROVA:
"Se [antecedente], então [consequente]" — a ordem das palavras na frase já indica diretamente qual termo é qual.'),
(10, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Com P="chove" e Q="a rua fica molhada", a original é P→Q. A proposição dada, "Se a rua não fica molhada, então não chove", é ¬Q→¬P — exatamente a definição de CONTRAPOSITIVA (inverte a ordem e nega ambos os termos).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) A recíproca seria Q→P ("se a rua fica molhada, então chove"), sem negação.
C) A inversa seria ¬P→¬Q ("se não chove, então a rua não fica molhada"), sem inverter a ordem.
D) A negação da condicional seria P∧¬Q ("chove e a rua não fica molhada"), uma afirmação, não outra condicional.
E) A proposição dada é logicamente equivalente à original, não desconexa dela.

BIZU DE PROVA:
Contrapositiva = inverte E nega (¬Q→¬P); recíproca = só inverte (Q→P); inversa = só nega (¬P→¬Q) — memorize os três nomes com suas duas operações (inverter/negar) associadas.'),
(11, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Com P="aprovado no concurso" e Q="nomeado", a original é P→Q. A recíproca inverte apenas a ordem, sem negar: Q→P = "Se um servidor é nomeado, então ele foi aprovado no concurso".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É a INVERSA (¬P→¬Q): nega ambos, sem inverter a ordem.
C) É a CONTRAPOSITIVA (¬Q→¬P): inverte e nega.
D) É a NEGAÇÃO da condicional original (P∧¬Q), uma conjunção, não outra condicional.
E) É ¬P∨¬Q, uma disjunção sem relação de equivalência com a recíproca.

BIZU DE PROVA:
Recíproca troca só a ORDEM (Q→P); inversa troca só o SINAL (¬P→¬Q); contrapositiva troca os DOIS (¬Q→¬P) — apenas a contrapositiva é logicamente equivalente à original; a recíproca e a inversa, isoladamente, não são.'),
(12, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Seja P="o equipamento está descarregado" e Q="ele não funciona". A original é P→Q. A contrapositiva é ¬Q→¬P. Como Q já é uma negação ("não funciona"), ¬Q = "funciona" (dupla negação elimina a negação). E ¬P = "o equipamento não está descarregado". Logo, a contrapositiva é "Se ele funciona, então o equipamento não está descarregado".

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É ¬P→Q, uma combinação que não corresponde a nenhuma das três transformações clássicas.
C) É Q→¬P: mantém a negação de Q em vez de eliminá-la — erro de não aplicar a dupla negação corretamente.
D) É a negação da condicional original (P∧¬Q = P∧"funciona"), uma conjunção.
E) Erro de sinal: usa ¬Q→P em vez de ¬Q→¬P, esquecendo de negar P.

BIZU DE PROVA:
Quando o consequente já é negado, negá-lo novamente elimina a negação ("não funciona" negado vira "funciona") — sempre confira se sobrou alguma negação dupla para simplificar.'),
(13, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A palavra "Toda" introduz o quantificador universal (∀), que afirma que a propriedade vale para TODOS os elementos do domínio (todas as viaturas).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Existencial (∃) seria indicado por "existe" ou "algum", não por "toda".
C) A presença de "toda" caracteriza explicitamente um quantificador, não uma proposição simples sem quantificação.
D) "Bicondicional" é um conectivo lógico, não um quantificador.
E) Não há negação nem quantificador existencial na frase.

BIZU DE PROVA:
"Todo/todos/qualquer que seja" = universal (∀); "existe/algum/pelo menos um" = existencial (∃) — a palavra-chave da frase indica diretamente o quantificador.'),
(14, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
I: todo elemento de U é, de fato, um dia da semana — VERDADEIRA. II: "sábado" não pertence a U (U contém apenas segunda a sexta) — FALSA. III: "segunda" e "sexta" começam com a letra "s" e pertencem a U, bastando um único caso para o existencial — VERDADEIRA. Logo, apenas I e III são verdadeiras.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Omite III, que também é verdadeira.
C) Inclui II, que é falsa (sábado não está em U).
D) Omite I, que é verdadeira.
E) Inclui II, que é falsa.

BIZU DE PROVA:
Para o quantificador existencial (∃), basta UM elemento do domínio satisfazer a condição — sempre verifique a pertinência ao conjunto antes de avaliar a propriedade.'),
(15, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Lápis" pertence a U e começa com a letra L, o que já basta para tornar VERDADEIRA a sentença existencial (∃) — não é necessário que mais de um elemento satisfaça a condição.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Existe sim um objeto ("lápis"), então a sentença não é falsa por essa razão.
C) O quantificador é EXISTENCIAL ("existe pelo menos um"), não universal — não é necessário que TODOS satisfaçam.
D) Uma sentença existencial sobre um domínio finito e explícito tem valor lógico determinado, sem depender de "contexto".
E) "Lápis" pertence sim a U, conforme definido no enunciado.

BIZU DE PROVA:
Para confirmar um existencial (∃), basta encontrar UM elemento do domínio que satisfaça a condição — não é preciso verificar todos.'),
(16, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Uma sentença universal (∀) só é verdadeira se TODOS os elementos do domínio satisfizerem a condição. Como 9∈U é ímpar, esse único contraexemplo já torna a sentença FALSA, independentemente dos demais elementos serem pares.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Erro clássico: confundir "a maioria" com "todos" — o quantificador universal exige 100% dos elementos, não a maioria.
C) A definição de U não impõe que todos sejam pares; U foi apresentado explicitamente com o elemento 9.
D) 2, 4 e 6 são pares — não é verdade que nenhum elemento seja par.
E) O valor lógico de uma sentença quantificada sobre um conjunto não depende da ordem em que os elementos são listados.

BIZU DE PROVA:
Para refutar um "para todo", basta UM contraexemplo — não importa se é minoria; para confirmar um "para todo", é preciso checar 100% dos elementos.'),
(17, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
p∨~p já é, isoladamente, sempre verdadeira (princípio do terceiro excluído) — uma disjunção com um termo sempre verdadeiro é sempre verdadeira, independentemente do valor de q. Logo, p∨~p∨q é verdadeira em TODAS as valorações — TAUTOLOGIA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Uma contradição é sempre falsa — o oposto do que ocorre aqui.
C) Uma contingência varia entre V e F conforme a valoração — mas aqui o resultado é sempre V, nunca F.
D) O valor de q é irrelevante: p∨~p já garante o resultado, então a classificação não depende de q.
E) Não existe essa condição; a fórmula é verdadeira em qualquer combinação de p e q.

BIZU DE PROVA:
Sempre que uma fórmula contiver p∨~p (ou qualquer termo sempre verdadeiro) unido por disjunção a outra coisa, o resultado inteiro já é uma tautologia — não é preciso testar as demais variáveis.'),
(18, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
p∧~p é, isoladamente, sempre falsa (princípio da não contradição) — uma conjunção com um termo sempre falso é sempre falsa, independentemente do valor de q. Logo, (p∧~p)∧q é falsa em TODAS as valorações — CONTRADIÇÃO.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Uma tautologia é sempre verdadeira — o oposto do que ocorre aqui.
C) Uma contingência varia entre V e F — mas aqui o resultado é sempre F, nunca V.
D) O resultado é falso em TODOS os casos, inclusive quando q é verdadeiro — não apenas quando q é falso.
E) O valor de q é irrelevante: p∧~p já garante o resultado falso, então a classificação não depende de q.

BIZU DE PROVA:
Sempre que uma fórmula contiver p∧~p (ou qualquer termo sempre falso) unido por conjunção a outra coisa, o resultado inteiro já é uma contradição — não é preciso testar as demais variáveis.'),
(19, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Construindo as 4 linhas: VV→(p∧q=V)→V→V=V; VF→(p∧q=F)→V→F=F; FV→(p∧q=F)→F→F=V (vacuamente); FF→(p∧q=F)→F→F=V (vacuamente). Resultado: V,F,V,V — há pelo menos uma linha V e pelo menos uma F, portanto é CONTINGÊNCIA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Não é sempre verdadeira: a linha V/F resulta em F.
B) Não é sempre falsa: três das quatro linhas resultam em V.
D) "Equivalência lógica" é uma relação ENTRE duas fórmulas, não uma categoria de classificação de uma única fórmula.
E) "Sentença aberta" pertence a outro conteúdo (variável livre em domínio matemático), não se aplica aqui.

BIZU DE PROVA:
Sempre que a tabela-verdade completa de uma fórmula tiver PELO MENOS um V e PELO MENOS um F, a classificação é contingência — nunca tautologia nem contradição.'),
(20, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Resolvendo 2x-5=-11: 2x=-11+5=-6, logo x=-3. Como -3 pertence ao domínio dos inteiros, o conjunto-verdade é {-3}.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Erro de sinal ao isolar x.
C) Corresponde a esquecer de dividir por 2 (2x=-6 tratado como x=-6-2).
D) Combina os dois erros anteriores (sinal trocado e divisão omitida).
E) O conjunto-verdade não é vazio: existe sim um valor inteiro que satisfaz a equação.

BIZU DE PROVA:
Ao isolar a variável, resolva uma operação de cada vez e confira se o resultado final pertence ao domínio declarado antes de afirmar o conjunto-verdade.'),
(21, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
x<-1 em U: {-3,-2} (note que -1 não satisfaz x<-1, pois não é estritamente menor). x>1 em U: {2,3} (note que 1 não satisfaz x>1). Como a sentença é uma disjunção, o conjunto-verdade é a UNIÃO: {-3,-2}∪{2,3} = {-3,-2,2,3}.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) É justamente o complemento do conjunto correto — os valores que NÃO satisfazem nenhuma das duas condições.
C) Inclui incorretamente -1 e 1, que não satisfazem as desigualdades estritas.
D) Não corresponde a nenhuma das duas condições isoladas nem à união delas.
E) O universo inteiro não satisfaz a sentença, pois -1, 0 e 1 não cumprem nenhuma das duas condições.

BIZU DE PROVA:
Em sentença aberta composta por disjunção (∨), o conjunto-verdade é a UNIÃO dos conjuntos-verdade individuais — inclua todo elemento que satisfaça PELO MENOS uma das condições.'),
(22, E'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A expressão contém a variável livre x, e seu valor lógico (verdadeiro ou falso) muda conforme o valor atribuído a x — por exemplo, para x=0, "3 é primo" é verdadeira; para x=1, "4 é primo" é falsa. Por não ter valor lógico fixo antes da substituição, é uma SENTENÇA ABERTA.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) e B) Uma proposição (verdadeira ou falsa) precisa ter valor lógico já determinado — o que não ocorre aqui enquanto x não for substituído.
D) Proposição composta é formada pela combinação de proposições simples por conectivos — não é o caso aqui, que é uma única expressão com variável.
E) Não há nenhum quantificador (∀ ou ∃) na expressão dada.

BIZU DE PROVA:
Sempre que uma expressão contiver uma variável livre (sem quantificador que a "amarre") e seu valor lógico mudar conforme o valor atribuído a ela, trata-se de uma sentença aberta, não de uma proposição.'),
(23, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Algum policial é atirador de elite" afirma que PELO MENOS UM policial é atirador — não todos. Carlos ser policial não garante que ele seja justamente um dos atiradores de elite. Contraexemplo: imagine 100 policiais, apenas 1 sendo atirador de elite, e Carlos sendo um dos outros 99 — as premissas seriam verdadeiras e a conclusão, falsa. Logo, o argumento é INVÁLIDO.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) A informação disponível é insuficiente para garantir a conclusão — falta saber SE Carlos está entre os policiais atiradores.
C) Não é modus ponens: modus ponens exige uma premissa universal ("Todo A é B"), não uma particular ("Algum A é B").
D) A validade do argumento não depende de a premissa ser verdadeira ou falsa no mundo real — depende apenas de a conclusão decorrer necessariamente das premissas, o que não ocorre aqui.
E) Ser policial não basta, pois nem todo policial é atirador de elite segundo a premissa dada.

BIZU DE PROVA:
Uma premissa particular ("algum A é B") NUNCA garante, sozinha, que um elemento específico de A também seja B — sempre desconfie de conclusões que tratam "algum" como se fosse "todo".'),
(24, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O argumento tem a forma P→Q, ¬Q, logo ¬P — o MODUS TOLLENS. Não há contraexemplo possível: se o alarme estivesse ativado (P verdadeiro), a premissa P→Q obrigaria a porta a estar trancada (Q verdadeiro), o que contradiria a segunda premissa. Logo, o alarme necessariamente não está ativado — argumento VÁLIDO.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Negar o consequente (¬Q) para concluir a negação do antecedente (¬P) é exatamente a forma válida do modus tollens, não uma falácia.
C) Modus ponens tem a forma P→Q, P, logo Q — estrutura diferente da apresentada.
D) Modus tollens não exige afirmar o antecedente; a negação do consequente já é suficiente e válida para negar o antecedente.
E) Não há contradição entre as premissas: a primeira estabelece uma condicional, e a segunda simplesmente informa que o consequente é falso — situação perfeitamente coerente.

BIZU DE PROVA:
Modus ponens: afirma o antecedente, conclui o consequente (P→Q, P ⊢ Q). Modus tollens: nega o consequente, conclui a negação do antecedente (P→Q, ¬Q ⊢ ¬P). Ambos são válidos; nunca é válido afirmar o consequente ou negar o antecedente para concluir algo sobre o outro termo.'),
(25, E'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A premissa afirma "Todo agente do setor X usa colete" (Setor X ⊆ usa-colete), não o inverso. Marcos usar colete o coloca no conjunto "usa colete", que é maior ou igual ao conjunto "agentes do setor X" — mas ele pode usar colete por pertencer a outro setor ou função, sem ser do setor X. A conclusão é apenas POSSÍVEL, nunca garantida pelas premissas.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
A) Não decorre necessariamente: existe cenário em que as premissas são verdadeiras e a conclusão é falsa (Marcos usa colete sem ser do setor X).
C) A conclusão não contradiz as premissas — ela é compatível com elas, apenas não é garantida por elas.
D) Modus ponens exigiria afirmar "Marcos é do setor X" para concluir "Marcos usa colete" — o argumento dado faz o caminho inverso (afirma o consequente), o que é uma falácia, não modus ponens.
E) Essa relação de implicação não foi estabelecida pela premissa, que só afirma uma direção (setor X → usa colete).

BIZU DE PROVA:
Dada "Todo A é B" e "x é B", NUNCA se pode concluir necessariamente que "x é A" — essa é a falácia clássica da afirmação do consequente; a conclusão fica apenas no campo do possível.'),
(26, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Todo C é S" corresponde exatamente à relação de inclusão total C⊆S ("C está totalmente contido em S") — todo elemento de C também está em S.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Inverte a relação: a afirmação não garante que todo servidor seja policial civil.
C) Contradiz diretamente a afirmação, que estabelece inclusão, não exclusão.
D) A afirmação não garante que os dois conjuntos sejam idênticos — pode haver servidores que não são policiais civis.
E) A afirmação estabelece uma inclusão total, não uma interseção parcial.

BIZU DE PROVA:
"Todo A é B" sempre corresponde a A⊆B (A contido em B) — nunca o inverso, e nunca presuma automaticamente igualdade entre os conjuntos.'),
(27, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Interseção parcial" significa, por definição, que M∩C ≠ ∅ (existe pelo menos um elemento comum), mas também que nem todo M está em C, nem todo C está em M. Logo, existir pessoas que praticam as duas atividades é exatamente o que a interseção parcial garante.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) "Toda pessoa que faz musculação também faz corrida" seria inclusão total (M⊆C), o que contradiz a interseção ser apenas parcial.
C) Contradiz diretamente a existência de interseção.
D) Inclusão total de M em C não é compatível com interseção meramente parcial.
E) M e C sem elemento comum seria disjunção total (M∩C=∅), o oposto de interseção parcial.

BIZU DE PROVA:
"Interseção parcial" garante, ao mesmo tempo, três coisas: existe elemento comum, existe elemento só em um dos conjuntos, e existe elemento só no outro — nenhum dos dois conjuntos está contido no outro.'),
(28, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
P∩Q=∅ (nenhum elemento em comum) corresponde exatamente à proposição categórica "Nenhuma peça do modelo A é peça do modelo B" — a definição direta de disjunção total.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) e D) "Toda peça de um é do outro" implicaria inclusão, algo incompatível com conjuntos disjuntos (sem nenhum elemento comum).
C) "Alguma peça...é" implicaria existência de interseção — o oposto da disjunção total afirmada.
E) Contradiz diretamente a informação de que não há nenhum elemento em comum.

BIZU DE PROVA:
"Nenhum A é B" corresponde sempre a A∩B=∅ (conjuntos disjuntos) — nessa relação, nenhuma das outras quatro leituras categóricas (todo, algum, existe interseção) é compatível.'),
(29, E'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
V⊆R garante apenas que todo elemento de V está em R — não garante o inverso. Logo, é necessariamente verdadeiro que "nem todo veículo de R é necessariamente elétrico" (podem existir veículos de R fora de V).

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
B) Inverte a relação: presume R⊆V, o que a premissa não garante — erro clássico de inversão.
C) Contradiz diretamente a inclusão V⊆R, que exige que todo elemento de V esteja em R.
D) V⊆R não implica igualdade entre os conjuntos; R pode ser estritamente maior que V.
E) Presume V vazio, o que a relação de inclusão, isoladamente, não garante nem nega.

BIZU DE PROVA:
De "A está contido em B", a única conclusão sempre garantida é sobre os elementos de A (todos estão em B) — nunca inverta a relação nem presuma nada sobre elementos de B que não estejam também em A.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'Falso.',false),
(1,2,'Verdadeiro.',true),
(1,3,'Indeterminado, pois depende de outros fatores externos.',false),
(1,4,'Verdadeiro apenas se p e q tiverem o mesmo valor lógico.',false),
(1,5,'Falso, pois q é falsa e aparece na proposição.',false),
(2,1,'2',false),
(2,2,'3',false),
(2,3,'4',true),
(2,4,'5',false),
(2,5,'16',false),
(3,1,'2',false),
(3,2,'3',true),
(3,3,'4',false),
(3,4,'5',false),
(3,5,'8',false),
(4,1,'Verdadeiro (V).',false),
(4,2,'Falso (F).',true),
(4,3,'Depende do valor de outra proposição não apresentada.',false),
(4,4,'Indeterminado, pois faltam dados na tabela.',false),
(4,5,'Igual ao resultado da linha 1, mas invertido.',false),
(5,1,'V, V, F, F',false),
(5,2,'F, F, V, V',true),
(5,3,'V, F, V, F',false),
(5,4,'F, V, F, V',false),
(5,5,'V, V, V, F',false),
(6,1,'P e Q.',false),
(6,2,'Se P, então Q; e se Q, então P.',true),
(6,3,'Se P, então Q; ou se Q, então P.',false),
(6,4,'Nem P, nem Q.',false),
(6,5,'P ou Q, mas não ambas.',false),
(7,1,'p ∧ q',false),
(7,2,'~p ∨ q',true),
(7,3,'p ∨ ~q',false),
(7,4,'~p ∧ ~q',false),
(7,5,'q → p',false),
(8,1,'Se o policial está de plantão, então o rádio está ligado.',true),
(8,2,'Se o rádio está ligado, então o policial está de plantão.',false),
(8,3,'O policial está de plantão e o rádio não está ligado.',false),
(8,4,'Se o policial não está de plantão, então o rádio não está ligado.',false),
(8,5,'O policial está de plantão se e somente se o rádio está ligado.',false),
(9,1,'"O suspeito confessar o crime" e "o inquérito será concluído mais rapidamente".',true),
(9,2,'"O inquérito será concluído mais rapidamente" e "o suspeito confessar o crime".',false),
(9,3,'Apenas "o suspeito confessar o crime" é o antecedente; não há consequente.',false),
(9,4,'Os dois termos são o antecedente, pois a frase inteira é uma condição.',false),
(9,5,'Não é possível identificar antecedente e consequente nesta frase.',false),
(10,1,'Contrapositiva da condicional original.',true),
(10,2,'Recíproca da condicional original.',false),
(10,3,'Inversa da condicional original.',false),
(10,4,'Negação da condicional original.',false),
(10,5,'Proposição sem relação lógica com a original.',false),
(11,1,'Se um servidor é nomeado, então ele foi aprovado no concurso.',true),
(11,2,'Se um servidor não é aprovado no concurso, então ele não é nomeado.',false),
(11,3,'Se um servidor não é nomeado, então ele não foi aprovado no concurso.',false),
(11,4,'Um servidor é aprovado no concurso e não é nomeado.',false),
(11,5,'Um servidor não é aprovado no concurso ou não é nomeado.',false),
(12,1,'Se ele funciona, então o equipamento não está descarregado.',true),
(12,2,'Se o equipamento não está descarregado, então ele funciona.',false),
(12,3,'Se ele não funciona, então o equipamento não está descarregado.',false),
(12,4,'O equipamento está descarregado e ele funciona.',false),
(12,5,'Se ele funciona, então o equipamento está descarregado.',false),
(13,1,'Existencial (∃).',false),
(13,2,'Universal (∀).',true),
(13,3,'Nenhum quantificador; é uma proposição simples.',false),
(13,4,'Bicondicional.',false),
(13,5,'Existencial negado.',false),
(14,1,'Apenas I é verdadeira.',false),
(14,2,'Apenas I e III são verdadeiras.',true),
(14,3,'Apenas II e III são verdadeiras.',false),
(14,4,'Apenas III é verdadeira.',false),
(14,5,'I, II e III são verdadeiras.',false),
(15,1,'Verdadeira, pois "lápis" pertence a U e começa com a letra L.',true),
(15,2,'Falsa, pois nenhum objeto de U começa com a letra L.',false),
(15,3,'Verdadeira, pois todos os objetos de U começam com a letra L.',false),
(15,4,'Indeterminada, pois depende do contexto.',false),
(15,5,'Falsa, pois "lápis" não pertence a U.',false),
(16,1,'Verdadeira, pois a maioria dos elementos de U é par.',false),
(16,2,'Falsa, pois 9 é ímpar e pertence a U.',true),
(16,3,'Verdadeira, pois U foi definido com números pares.',false),
(16,4,'Falsa, pois nenhum elemento de U é par.',false),
(16,5,'Indeterminada, pois depende da ordem dos elementos.',false),
(17,1,'Tautologia.',true),
(17,2,'Contradição.',false),
(17,3,'Contingência.',false),
(17,4,'Não é possível classificar sem saber o valor de q.',false),
(17,5,'Verdadeira apenas quando p e q têm o mesmo valor lógico.',false),
(18,1,'Tautologia.',false),
(18,2,'Contradição.',true),
(18,3,'Contingência.',false),
(18,4,'Verdadeira apenas quando q é falso.',false),
(18,5,'Depende do valor de q para ser classificada.',false),
(19,1,'Tautologia.',false),
(19,2,'Contradição.',false),
(19,3,'Contingência.',true),
(19,4,'Equivalência lógica.',false),
(19,5,'Sentença aberta.',false),
(20,1,'{-3}',true),
(20,2,'{3}',false),
(20,3,'{-8}',false),
(20,4,'{8}',false),
(20,5,'∅ (conjunto vazio)',false),
(21,1,'{-3, -2, 2, 3}',true),
(21,2,'{-1, 0, 1}',false),
(21,3,'{-3, -2, -1, 1, 2, 3}',false),
(21,4,'{-2, -1, 0, 1, 2}',false),
(21,5,'U (o próprio universo)',false),
(22,1,'Proposição verdadeira.',false),
(22,2,'Proposição falsa.',false),
(22,3,'Sentença aberta, pois seu valor lógico depende do valor atribuído a x.',true),
(22,4,'Proposição composta.',false),
(22,5,'Quantificador existencial.',false),
(23,1,'Válido, pois toda a informação necessária está nas premissas.',false),
(23,2,'Inválido, pois é possível que Carlos não seja um dos policiais que são atiradores de elite.',true),
(23,3,'Válido, por modus ponens.',false),
(23,4,'Inválido, pois a premissa "Algum policial é atirador de elite" é falsa.',false),
(23,5,'Válido, pois Carlos é policial e isso já basta para a conclusão.',false),
(24,1,'Válido, pela forma de raciocínio conhecida como modus tollens.',true),
(24,2,'Inválido, pois nega o consequente sem informação suficiente.',false),
(24,3,'Válido, pela forma de raciocínio conhecida como modus ponens.',false),
(24,4,'Inválido, pois seria necessário afirmar o antecedente, não negar o consequente.',false),
(24,5,'Inválido, pois a premissa "a porta não está trancada" contradiz a primeira premissa.',false),
(25,1,'Necessária, pois decorre logicamente das premissas.',false),
(25,2,'Apenas possível, não necessária — Marcos pode usar colete balístico por outro motivo, sem pertencer ao setor X.',true),
(25,3,'Impossível, pois contradiz as premissas.',false),
(25,4,'Necessária, por modus ponens.',false),
(25,5,'Necessária, pois usar colete balístico implica pertencer ao setor X.',false),
(26,1,'C está totalmente contido em S.',true),
(26,2,'S está totalmente contido em C.',false),
(26,3,'C e S não possuem elementos em comum.',false),
(26,4,'C e S são o mesmo conjunto.',false),
(26,5,'C e S têm interseção parcial, mas nenhum é subconjunto do outro.',false),
(27,1,'Existem pessoas que praticam musculação e corrida simultaneamente.',true),
(27,2,'Toda pessoa que faz musculação também faz corrida.',false),
(27,3,'Nenhuma pessoa pratica as duas atividades ao mesmo tempo.',false),
(27,4,'M está totalmente contido em C.',false),
(27,5,'M e C não possuem nenhum elemento em comum.',false),
(28,1,'Nenhuma peça do modelo A é peça do modelo B.',true),
(28,2,'Toda peça do modelo A é peça do modelo B.',false),
(28,3,'Alguma peça do modelo A é peça do modelo B.',false),
(28,4,'Toda peça do modelo B é peça do modelo A.',false),
(28,5,'Existe pelo menos uma peça comum aos dois modelos.',false),
(29,1,'Nem todo veículo registrado na frota é necessariamente elétrico.',true),
(29,2,'Todo veículo registrado na frota é elétrico.',false),
(29,3,'Nenhum veículo elétrico está registrado na frota.',false),
(29,4,'Os conjuntos V e R são idênticos.',false),
(29,5,'Não existem veículos elétricos na frota.',false);

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
  if v_qtd_cc1 <> 1 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 1 recebeu % vinculos novos (esperado 1)', v_qtd_cc1;
  end if;

  select count(*) into v_qtd_cc2
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc2 <> 4 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 2 recebeu % vinculos novos (esperado 4)', v_qtd_cc2;
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
  if v_qtd_cc6 <> 4 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 6 recebeu % vinculos novos (esperado 4)', v_qtd_cc6;
  end if;

  select count(*) into v_qtd_cc7
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 7 and qup.questao_id in (select questao_id from _mapa_ids);
  if v_qtd_cc7 <> 4 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 7 recebeu % vinculos novos (esperado 4)', v_qtd_cc7;
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
  if v_qtd_cc11 <> 4 then
    raise exception 'Pos-condicao falhou: curso_conteudo_id 11 recebeu % vinculos novos (esperado 4)', v_qtd_cc11;
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
