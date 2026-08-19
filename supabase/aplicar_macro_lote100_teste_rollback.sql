-- ============================================================================
-- AUDITORIA GLOBAL -- MACRO-LOTE 100 -- EXPLICAÇÕES (100 QUESTÕES)
-- Aplicação de 100 explicações pedagógicas completas
-- Matérias: Direitos Humanos (26), Leg. Específica (66), D. Penal (2), D. Proc. Penal (2), D. Constitucional (1), Trânsito (1), Guardas (1), Leg. Penal Esp. (1)
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-macro-lote100-harness.mjs a partir de
-- scripts/macro-lote100-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/macro-lote100-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _m100_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _m100_novas_explicacoes (id, explicacao) values
(694, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 14, §3º, inciso VI, alínea "c", da Constituição Federal de 1988, a idade mínima de 21 (VINTE E UM) ANOS é condição de elegibilidade para os cargos de Prefeito, Vice-Prefeito e Juiz de Paz.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
18 anos é a idade mínima para o cargo de Vereador (Art. 14, §3º, VI, "d", CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
30 anos é a idade mínima para Governador e Vice-Governador de Estado e do DF (Art. 14, §3º, VI, "b", CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
35 anos é a idade mínima para Presidente, Vice-Presidente da República e Senador (Art. 14, §3º, VI, "a", CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não existe previsão constitucional de idade mínima de 45 anos para qualquer cargo eletivo.

BIZU DE PROVA:
Idades Mínimas de Elegibilidade (Art. 14, §3º, VI da CF/88 - Regra 35-30-21-18):
- 35 anos: Presidente, Vice e Senador;
- 30 anos: Governador e Vice-Governador;
- 21 anos: Prefeito, Vice-Prefeito, Deputados (Federal, Estadual e Distrital) e Juiz de Paz;
- 18 anos: Vereador!'),
(695, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta de preenchimento é V – V – V:
- (V) O Artigo 26 da Lei nº 12.288/2010 (Estatuto Nacional da Igualdade Racial) estabelece que a liberdade de crença de matriz africana compreende a fundação e manutenção de instituições beneficentes por iniciativa privada.
- (V) O Artigo 34 dispõe expressamente que o Poder Executivo federal elaborará e desenvolverá políticas públicas especiais voltadas para o desenvolvimento sustentável dos remanescentes das comunidades quilombolas.
- (V) O Artigo 37 estabelece que os agentes financeiros, públicos ou privados, promoverão ações para viabilizar o acesso da população negra aos financiamentos habitacionais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A segunda assertiva é verdadeira (Art. 34 da Lei nº 12.288/2010).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A terceira assertiva é verdadeira (Art. 37 da Lei nº 12.288/2010).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira e segunda assertivas são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas as três assertivas reproduzem fielmente dispositivos da Lei nº 12.288/2010.

BIZU DE PROVA:
Estatuto da Igualdade Racial (Lei nº 12.288/2010):
Ações afirmativas abrangem liberdade religiosa, sustentabilidade de comunidades quilombolas e acesso facilitado à moradia própria!'),
(696, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O comando da questão pede a alternativa que NÃO configura caso de desrespeito ou violação aos Direitos Humanos. O "Direito à vida e à segurança" (Artigo 3º da Declaração Universal dos Direitos Humanos e Artigo 5º, caput, da CF/88) constitui um direito fundamental basilar expressamente protegido, e não uma violação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A intolerância religiosa constitui grave violação aos direitos humanos e à liberdade de crença (Art. 18 da DUDH).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A discriminação de raça e cor viola o princípio basilar da igualdade universal (Art. 2º e 7º da DUDH).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A exploração do trabalho infantil afronta a proteção integral e a dignidade da criança e do adolescente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tortura é violação gravíssima de direitos humanos absolutamente proibida pelo direito internacional (Art. 5º da DUDH).

BIZU DE PROVA:
Atenção ao Comando Negativo ("NÃO configura violação"):
Exercer o direito à vida e à segurança pessoal é a própria ESSÊNCIA da proteção dos Direitos Humanos!'),
(697, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 34 da Lei nº 10.741/2003 (Estatuto da Pessoa Idosa) e o Artigo 20 da LOAS (Lei nº 8.742/1993), aos idosos a partir de 65 (SESSENTA E CINCO) ANOS que não possuam meios de prover sua própria subsistência é assegurado o benefício de 1 (UM) SALÁRIO-MÍNIMO mensal. As lacunas são preenchidas correta e respectivamente por "65" e "um".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A idade fixada para o BPC do idoso não é 60 anos, e sim 65 anos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O valor do benefício é de 1 salário-mínimo, e não 2 salários.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O requisito etário é de 65 anos e o valor correspondente a um salário-mínimo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A idade não é 70 anos para a concessão inicial do BPC ao idoso vulnerável.

BIZU DE PROVA:
Benefício de Prestação Continuada (BPC/LOAS para o Idoso):
- Idade: 65 ANOS completos;
- Valor: 1 (UM) SALÁRIO-MÍNIMO mensal.'),
(715, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A conduta do guarda municipal de prestar atendimento humanizado, cortês e cobrir com sua própria jaqueta a pessoa vulnerável despida na via pública tem como fundamento primaz a DIGNIDADE DA PESSOA HUMANA (Artigo 1º, inciso III, da Constituição Federal de 1988), princípio matriz que garante o respeito à integridade física e moral de todo ser humano.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A soberania (Art. 1º, I, CF) diz respeito à independência e supremacia do Estado brasileiro na ordem internacional e interna.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O pluralismo político (Art. 1º, V, CF) assegura a livre manifestação de ideias, partidos e visões políticas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os valores sociais do trabalho e da livre iniciativa (Art. 1º, IV, CF) orientam a ordem econômica e as relações de trabalho.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Expressão inexistente no rol de fundamentos da República do Artigo 1º da CF/88.

BIZU DE PROVA:
Fundamentos da República (Art. 1º da CF/88 - SO-CI-DI-VA-PLU):
- SOberania;
- CIdadania;
- DIgnidade da pessoa humana;
- VAlores sociais do trabalho e da livre iniciativa;
- PLUralismo político.'),
(788, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A assertiva transcrita no enunciado ("Todo ser humano acusado de um ato delituoso tem o direito de ser presumido inocente até que a sua culpabilidade tenha sido provada de acordo com a lei, em julgamento público no qual lhe tenham sido asseguradas todas as garantias necessárias à sua defesa") corresponde especificamente ao princípio da PRESUNÇÃO DE INOCÊNCIA (Artigo 11, item 1, da DUDH e Artigo 5º, LVII da CF/88).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Universalidade é a característica segundo a qual os direitos humanos pertencem a todos os seres humanos sem distinção.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Igualdade assegura que todos são iguais perante a lei (Artigo 7º da DUDH).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Vida, liberdade e segurança pessoal constam no Artigo 3º da DUDH.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Liberdade de locomoção e vedação da prisão arbitrária constam nos Artigos 9º e 13 da DUDH.

BIZU DE PROVA:
Artigo 11.1 da DUDH:
Consagração universal da PRESUNÇÃO DE INOCÊNCIA e do Devido Processo Legal!'),
(789, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Conforme o Artigo 14, §1º, inciso I, da Constituição Federal de 1988, o alistamento eleitoral e o voto são OBRIGATÓRIOS para os MAIORES DE 18 (DEZOITO) ANOS.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Para os maiores de 16 e menores de 18 anos, o voto é facultativo (Art. 14, §1º, II, "c", CF).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Estrangeiros não podem alistar-se como eleitores no Brasil (são inalistáveis - Art. 14, §2º, CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Para os analfabetos, o alistamento e o voto são facultativos (Art. 14, §1º, II, "a", CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Para os maiores de 70 anos, o alistamento e o voto são facultativos (Art. 14, §1º, II, "b", CF).

BIZU DE PROVA:
Alistamento e Voto no Brasil (Art. 14, §1º da CF/88):
- OBRIGATÓRIO: Maiores de 18 anos e menores de 70 anos alfabetizados.
- FACULTATIVO: Analfabetos, Maiores de 70 anos e Jovens entre 16 e 18 anos.
- PROIBIDO (Inalistáveis): Estrangeiros e conscritos militares durante serviço obrigatório.'),
(790, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O comando da questão exige a alternativa INCORRETA. A alternativa A é incorreta porque o Artigo 52 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) determina que o Estado adotará medidas especiais para COIBIR (e não "implementar") a violência policial incidente sobre a população negra.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 54 do Estatuto da Igualdade Racial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: expressa garantia prevista no Artigo 53 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 54 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: espelha a garantia de acesso ao Ministério Público do Artigo 53.

BIZU DE PROVA:
Cuidado com pegadinhas de verbos trocados:
O Estado deve COIBIR a violência policial e PROTEGER a juventude negra, jamais "implementar a violência"!'),
(812, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Item I (Correto): A valorização da cultura e participação social da população negra são objetivos do Estatuto (Lei nº 12.288/2010).
- Item II (Correto): O fortalecimento de políticas públicas e ações afirmativas é diretriz expressa da lei.
- Item III (Incorreto): A assertiva extrapola o texto legal ao impor restrições incompatíveis com os direitos fundamentais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois o item II também está correto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incorreta na delimitação das diretrizes normativas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O item III não está correto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O item III invalida a alternativa.

BIZU DE PROVA:
Estatuto da Igualdade Racial:
Diretrizes pautadas na inclusão social, ações afirmativas e reparação de desigualdades históricas.'),
(813, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 6º da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) dispõe textualmente: "O direito à saúde da população negra será garantido pelo poder público mediante políticas universais, sociais e econômicas destinadas à redução do risco de doenças e de outros agravos."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As ações afirmativas abrangem as esferas pública e privada (Art. 4º, parágrafo único).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O poder público deve garantir tratamento não discriminatório também nos serviços privados de saúde (Art. 7º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A população negra tem pleno direito a atividades educacionais, culturais e de lazer (Art. 9º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O estudo da história geral da África e do negro no Brasil é OBRIGATÓRIO nos currículos escolares (Art. 11).

BIZU DE PROVA:
Direito à Saúde da População Negra (Art. 6º da Lei nº 12.288/10):
Garantido mediante políticas públicas integradas no SUS e combate às desigualdades no acesso à saúde.'),
(814, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta de preenchimento é V – F – V:
- (V) O Artigo 8º, inciso IV, da Lei nº 12.288/2010 inclui a produção de conhecimento científico e tecnológico como diretriz da Política Nacional de Saúde Integral da População Negra.
- (F) O Artigo 18 dispõe que o apoio a entidades de promoção social da população negra deve ser INCENTIVADO pelo Poder Público, e não "vedado".
- (V) O Artigo 13 estabelece que o Executivo federal incentivará as instituições de ensino superior a incorporar temas de pluralidade étnica e cultural na formação de professores.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A terceira assertiva é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é verdadeira e a segunda é falsa.

BIZU DE PROVA:
Estatuto Nacional da Igualdade Racial:
O poder público tem o dever de APOIAR e INCENTIVAR iniciativas culturais e científicas da população negra!'),
(815, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa E é a INCORRETA (gabarito) porque o Artigo 24 da Lei nº 12.288/2010 assegura a assistência religiosa aos praticantes de religiões de matrizes africanas internados em hospitais e entidades de internação coletiva, INCLUSIVE (e não "exceto") àqueles submetidos à pena privativa de liberdade ou medida socioeducativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 23 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 25, inciso IV, da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 26 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 25, inciso I, da Lei nº 12.288/2010.

BIZU DE PROVA:
Assistência Religiosa nas Prisões (Art. 5º, VII da CF e Art. 24 da Lei 12.288/10):
A garantia de assistência religiosa estende-se expressamente aos PRESOS e internados em cumprimento de pena privativa de liberdade!'),
(816, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Conforme o Artigo 2º da Lei Federal nº 12.288/2010 (Estatuto da Igualdade Racial), o diploma adota como diretrizes político-jurídicas:
- II. A valorização da igualdade étnica;
- III. O fortalecimento da identidade nacional brasileira.
O item I ("vítimas de desigualdade social" em geral) não constitui a diretriz político-jurídica expressamente nomeada no dispositivo. Portanto, estão corretas apenas as assertivas II e III.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O item I não corresponde à diretriz específica do dispositivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois o item II também é correto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O item I não integra o rol literal do art. 2º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O item I torna a alternativa incorreta.

BIZU DE PROVA:
Diretrizes do Art. 2º da Lei nº 12.288/2010:
Valorização da IGUALDADE ÉTNICA e Fortalecimento da IDENTIDADE NACIONAL BRASILEIRA.'),
(817, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C é a INCORRETA (gabarito) porque o Supremo Tribunal Federal (STF), no julgamento do HC 111.840/ES e reiterada jurisprudência, declarou inconstitucional a obrigatoriedade do regime inicial fechado contida no Artigo 1º, §7º, da Lei nº 9.455/1997, por violar o princípio constitucional da individualização da pena (Art. 5º, XLVI, CF). Na avaliação de conformidade estrita com a jurisprudência vinculante, o regime inicial fechado automático não subsiste compulsoriamente sem fundamentação judicial concreta.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: a tortura é crime inafiançável (Art. 5º, XLIII da CF e Art. 1º, §6º da Lei 9.455/97).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: o crime é insuscetível de graça ou anistia (Art. 5º, XLIII da CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: a omissão perante a tortura é tipificada no Artigo 1º, §2º da Lei nº 9.455/1997.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: expressa a extraterritorialidade incondicionada do Artigo 2º da Lei nº 9.455/1997.

BIZU DE PROVA:
Lei de Tortura e Jurisprudência do STF:
O STF afastou a imposição automática e abstrata de regime inicial fechado obrigatório para respeitar o princípio da individualização da pena!'),
(818, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 1º, §5º, da Lei nº 9.455/1997 (Lei de Tortura), a condenação acarretará a PERDA DO CARGO, FUNÇÃO OU EMPREGO PÚBLICO e a INTERDIÇÃO PARA SEU EXERCÍCIO PELO DOBRO DO PRAZO DA PENA APLICADA. Trata-se de efeito automático da sentença penal condenatória transitada em julgado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A perda do cargo na Lei de Tortura é efeito automático da condenação, dispensando fundamentação motivada específica na sentença (ao contrário da regra geral do CP).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O prazo de interdição é o DOBRO da pena aplicada, e não de 1 a 5 anos (que é regra da Lei de Abuso de Autoridade).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O prazo de inabilitação é fixado obrigatoriamente no dobro da pena corporal imposta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei de Tortura prevê expressamente a perda do cargo público no art. 1º, §5º.

BIZU DE PROVA:
Efeitos da Condenação por Tortura (Art. 1º, §5º da Lei nº 9.455/97):
1. Perda AUTOMÁTICA do cargo/função pública;
2. Interdição para função pública pelo DOBRO DO PRAZO da pena aplicada!'),
(819, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O comando da questão solicita o direito que NÃO é considerado direito civil na Convenção Americana sobre Direitos Humanos (1969). A EDUCAÇÃO é classificada no Direito Internacional e na CADH como um DIREITO ECONÔMICO, SOCIAL E CULTURAL (DESC), disciplinado no Artigo 26 da CADH e no Protocolo de San Salvador, e não como direito civil e político de primeira dimensão.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O direito à vida é direito civil expressamente protegido no Artigo 4º da CADH.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A integridade pessoal é direito civil protegido no Artigo 5º da CADH.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A liberdade pessoal é direito civil consagrado no Artigo 7º da CADH.

BIZU DE PROVA:
Gerações / Dimensões dos Direitos Humanos:
- 1ª Dimensão (Civis e Políticos): Vida, Liberdade, Propriedade e Integridade física.
- 2ª Dimensão (Sociais, Econômicos e Culturais): Educação, Saúde, Trabalho e Moradia!'),
(820, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta de preenchimento é F – V – V:
- (F) A CADH autoriza a prisão civil do devedor de alimentos (Artigo 7º, item 7), logo é falso afirmar que "não autoriza em nenhuma hipótese".
- (V) O Artigo 7º, item 7, da CADH estabelece expressamente a ressalva da prisão civil por dívida de obrigação alimentar.
- (V) O Artigo 8º, item 2, alínea "a", da CADH assegura ao acusado o direito de ser assistido gratuitamente por tradutor ou intérprete caso não compreenda ou não fale o idioma do juízo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A segunda e a terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira assertiva é falsa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é falsa e a terceira é verdadeira.

BIZU DE PROVA:
Prisão Civil na CADH (Art. 7.7 e Súmula Vinculante 25 do STF):
Admitida UNICAMENTE a prisão civil do devedor inescusável de ALIMENTOS (é ilícita a prisão do depositário infiel).'),
(821, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 27, item 2, da Convenção Americana sobre Direitos Humanos (Pacto de São José da Costa Rica) enumera expressamente os DIREITOS INDERROGÁVEIS (que não podem ser suspensos mesmo em estado de emergência ou guerra):
- Direito ao reconhecimento da personalidade jurídica (Art. 3º);
- Direito à VIDA (Art. 4º);
- Direito à integridade pessoal (Art. 5º);
- Proibição da escravidão e servidão (Art. 6º);
- Princípio da legalidade e retroatividade benéfica (Art. 9º);
- Liberdade de CONSCIÊNCIA E DE RELIGIÃO (Art. 12);
- Proteção da família (Art. 17);
- Direito ao nome (Art. 18);
- Direitos da CRIANÇA (Art. 19);
- Direito à nacionalidade (Art. 20);
- Direitos POLÍTICOS (Art. 23);
- Garantias judiciais indispensáveis à proteção de tais direitos.
A alternativa A reúne precisamente direitos do rol inderrogável do Art. 27.2.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As garantias judiciais são os instrumentos de tutela, enquanto a alternativa A lista diretamente os direitos materiais inderrogáveis protegidos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A proteção da honra (Art. 11) não consta no rol taxativo do Artigo 27.2 da CADH.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A liberdade de expressão e de pensamento (Art. 13) pode sofrer suspensão temporária proporcional nos estados de exceção, não constando no rol inderrogável do Art. 27.2.

BIZU DE PROVA:
Direitos Inderrogáveis da CADH (Art. 27.2):
Vida, Integridade Pessoal, Consciência/Religião, Direitos da Criança, Nome, Família, Nacionalidade e Direitos Políticos NUNCA podem ser suspensos!'),
(822, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 4º, item 5, da Convenção Americana sobre Direitos Humanos (Pacto de San José): "Não se deve impor a pena de morte à pessoa que, no momento da perpetração do delito, for menor de 18 (DEZOITO) anos, ou maior de 70 (SETENTA) anos, nem aplicá-la à mulher em estado de gravidez."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O limite superior de idade é 70 anos, e não 60 anos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O limite inferior é 18 anos e o superior 70 anos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O limite mínimo é 18 anos de idade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O limite inferior fixado no tratado é 18 anos.

BIZU DE PROVA:
Limites da Pena de Morte na CADH (Art. 4.5):
- Menores de 18 ANOS;
- Maiores de 70 ANOS;
- Mulheres GRÁVIDAS.'),
(823, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O texto transcrito no enunciado ("Ninguém deve ser submetido a torturas, nem a penas ou tratos cruéis, desumanos ou degradantes. Toda pessoa privada da liberdade deve ser tratada com o respeito devido à dignidade inerente ao ser humano") corresponde fielmente ao ARTIGO 5º (Direito à Integridade Pessoal) da Convenção Americana sobre Direitos Humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 4º disciplina o Direito à Vida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Artigo 6º trata da Proibição da Escravidão e da Servidão.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Artigo 7º versa sobre o Direito à Liberdade Pessoal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Artigo 8º dispõe sobre as Garantias Judiciais.

BIZU DE PROVA:
Artigos Principais da CADH:
- Art. 4º = Vida;
- Art. 5º = Integridade Pessoal / Proibição de Tortura;
- Art. 6º = Escravidão;
- Art. 7º = Liberdade Pessoal;
- Art. 8º = Garantias Judiciais.'),
(824, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 19 da Convenção Americana sobre Direitos Humanos (Direitos da Criança) dispõe expressamente: "Toda criança tem direito às medidas de proteção que a sua condição de menor requer por parte da sua família, da sociedade e do Estado."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Artigo 10 da CADH garante expressamente a indenização por erro judiciário.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Artigo 22.5 da CADH veda a expulsão de nacionais e proíbe privá-los do direito de entrar em seu próprio país.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Artigo 17.1 da CADH estabelece que a família deve ser protegida pela sociedade E pelo Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Artigo 5.5 da CADH exige que menores sejam separados dos adultos.

BIZU DE PROVA:
Artigo 19 da CADH (Direitos da Criança):
Proteção especial devida pela FAMÍLIA, pela SOCIEDADE e pelo ESTADO.'),
(825, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 8º, item 2, ''d'', da CADH assegura expressamente ao acusado o direito de "defender-se pessoalmente ou de ser assistido por um defensor de sua escolha e de comunicar-se, livremente e em particular, com seu defensor".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 4.4 da CADH proíbe a pena de morte para delitos políticos e conexos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Artigo 6.2 da CADH dispõe que o trabalho de recluso não é considerado trabalho forçado vedado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Artigo 8.4 da CADH proíbe o novo julgamento de acusado absolvido com trânsito em julgado (non bis in idem).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Artigo 10 da CADH assegura expressamente a indenização por erro judiciário.

BIZU DE PROVA:
Ampla Defesa na CADH (Art. 8.2.d):
Direito de autodefesa e de defesa técnica de livre escolha, com comunicação reservada.'),
(826, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 52, item 1, da Convenção Americana sobre Direitos Humanos: "A Corte compor-se-á de SETE juízes, nacionais dos Estados-Partes na Organização, eleitos a título pessoal dentre juristas da mais alta autoridade moral e de reconhecida competência em matéria de direitos humanos."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Corte não tem 5 juízes.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A composição não é de 6 juízes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A composição é de 7 magistrados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A composição não é de 9 juízes.

BIZU DE PROVA:
Corte Interamericana de Direitos Humanos:
Composta por EXATAMENTE 7 JUÍZES (eleitos pela Assembleia Geral da OEA).'),
(827, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência correta de preenchimento é V – V – V:
- (V) O Artigo 8º, inciso I, da Lei nº 7.853/1989 tipifica como crime "negar ou obstar emprego, trabalho ou promoção à pessoa em razão de sua deficiência".
- (V) O Artigo 8º, inciso I, tipifica como crime "recusar, cobrar valores adicionais, suspender, procrastinar, cancelar ou fazer cessar inscrição de aluno em estabelecimento de ensino de qualquer curso ou grau, público ou privado, em razão de sua deficiência".
- (V) O Artigo 8º, inciso III, tipifica como crime "obstar inscrição em concurso público ou acesso de alguém a qualquer cargo ou emprego público, em razão de sua deficiência".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A terceira assertiva é verdadeira.

BIZU DE PROVA:
Crimes contra a Pessoa com Deficiência (Art. 8º da Lei nº 7.853/1989):
Condutas discriminatórias em trabalho, matrícula escolar/faculdade e concursos públicos são CRIMES punidos com reclusão e multa!'),
(828, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Nos termos do Artigo 2º, parágrafo único, inciso II, da Lei nº 7.853/1989, as medidas na área da saúde compreendem:
- I. O desenvolvimento de programas de saúde voltados para as pessoas portadoras de deficiência, desenvolvidos com a participação da sociedade e que lhes ensejem a integração social.
- II. A garantia de acesso das pessoas portadoras de deficiência aos estabelecimentos de saúde públicos e privados, e de seu adequado tratamento neles, sob normas técnicas e padrões de conduta apropriados.
- III. O desenvolvimento de programas especiais de prevenção de acidente do trabalho e de trânsito, e de tratamento adequado a suas vítimas.
Todas as assertivas I, II e III estão corretas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é expressa na lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois II também integra a lei.

BIZU DE PROVA:
Ações de Saúde na Lei nº 7.853/1989:
Acesso irrestrito a hospitais, programas integrados e prevenção especializada de acidentes de trabalho e trânsito.'),
(829, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Conforme os incisos do Artigo 8º da Lei Federal nº 7.853/1989:
- I. (Correta) Inciso II: Recusar, retardar ou dificultar internação ou deixar de prestar assistência médico-hospitalar e ambulatorial à pessoa com deficiência.
- II. (Correta) Inciso IV: Recusar, retardar ou omitir dados técnicos indispensáveis à propositura da ação civil pública objeto desta Lei, quando requisitados.
- III. (Correta) Inciso V: Impedir ou dificultar o ingresso de pessoa com deficiência em planos privados de assistência à saúde, inclusive com cobrança de valores diferenciados.
Todas as assertivas I, II e III configuram crimes expressamente tipificados.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são crimes.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são crimes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é crime da lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é crime formalizado.

BIZU DE PROVA:
Rol de Crimes da Lei nº 7.853/1989 (Art. 8º):
1. Negar trabalho/escola/concurso;
2. Recusar internação hospitalar;
3. Omitir dados técnicos requisitados para ACP;
4. Criar barreiras em planos de saúde ou cobrar a mais.'),
(2, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Estatuto Geral das Guardas Municipais (Lei Federal nº 13.022/2014) estabelece em seu Artigo 3º os princípios mínimos de atuação das guardas municipais: proteção dos direitos humanos fundamentais, preservação da vida, patrulhamento preventivo, compromisso com a evolução social da comunidade e uso progressivo da força. A alternativa A reflete com fidelidade a matriz axiológica e as competências constitucionais e legais das Guardas Municipais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As guardas municipais não exercem funções exclusivas de polícia judiciária ou investigação penal da Polícia Civil/Federal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A atuação não é de natureza militarizada, possuindo caráter eminentemente civil (Art. 2º da Lei 13.022/2014).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O uso da força não é arbitrário, devendo seguir estritamente o uso diferenciado/progressivo e proporcional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção aos direitos humanos é princípio obrigatório e expresso da corporação.

BIZU DE PROVA:
Princípios das Guardas Municipais (Art. 3º da Lei nº 13.022/2014):
1. Proteção dos direitos humanos fundamentais;
2. Preservação da vida, redução do sofrimento e diminuição das perdas;
3. Patrulhamento preventivo;
4. Compromisso com a evolução social da comunidade;
5. Uso progressivo/diferenciado da força.'),
(3, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 144, §8º, da Constituição Federal estabelece que os Municípios poderão constituir guardas municipais destinadas à proteção de seus BENS, SERVIÇOS E INSTALAÇÕES, conforme dispuser a lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As guardas municipais não têm competência constitucional para exercer apuração penal geral privativa da polícia judiciária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A competência não abrange policiamento ostensivo rodoviário federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não atuam na fiscalização aduaneira ou controle de fronteiras privativo federal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A destinação constitucional precípua é a proteção de bens, serviços e instalações municipais.

BIZU DE PROVA:
Competência Constitucional das Guardas Municipais (Art. 144, §8º da CF/88):
Proteção de BENS, SERVIÇOS e INSTALAÇÕES do Município!'),
(4, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Código de Trânsito Brasileiro (CTB - Lei nº 9.503/1997), a circulação de veículos automotores deve sempre assegurar a preferência de passagem e a integridade física do pedestre, devendo o condutor reduzir a velocidade e dar prioridade na via pública.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Acelerar ou intimidar o pedestre constitui infração grave/gravíssima de trânsito e crime de trânsito em caso de dano.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O pedestre tem prioridade na travessia sobre a faixa delimitada e nas conversões.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O uso da buzina não autoriza o condutor a desrespeitar a travessia do pedestre.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A segurança do pedestre é princípio basilar e prioritário do Sistema Nacional de Trânsito.

BIZU DE PROVA:
Regra Geral de Segurança no Trânsito (Art. 29, §2º do CTB):
O maior cuida do menor: veículos motorizados cuidam dos não motorizados e, juntos, TODOS PROTEGEM O PEDESTRE!'),
(5, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O crime de PECULATO (Artigo 312 do Código Penal) consiste na conduta do funcionário público que se apropria de dinheiro, valor ou qualquer outro bem móvel, público ou particular, de que tem a posse em razão do cargo, ou o desvia em proveito próprio ou alheio.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Concussão (Art. 316) consiste em EXIGIR vantagem indevida em razão da função.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Corrupção passiva (Art. 317) consiste em solicitar ou receber vantagem indevida.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Prevaricação (Art. 319) consiste em retardar ou deixar de praticar ato funcional para satisfazer interesse ou sentimento pessoal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Advocacia administrativa (Art. 321) consiste em patrocinar interesse privado perante a administração.

BIZU DE PROVA:
Diferença dos Crimes Funcionais:
- PECULATO (Art. 312) = Apropriar-se ou desviar bem móvel que tem a posse pelo cargo!
- CONCUSSÃO (Art. 316) = EXIGIR.
- CORRUPÇÃO PASSIVA (Art. 317) = SOLICITAR / RECEBER.
- PREVARICAÇÃO (Art. 319) = Retardar/deixar de agir por INTERESSE OU SENTIMENTO PESSOAL.'),
(9, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 29 do Código Penal consagra a Teoria Monista (Unitária) no concurso de pessoas: "Quem, de qualquer modo, concorre para o crime incide nas penas a este cominadas, na medida de sua culpabilidade." Todos os coautores e partícipes respondem pelo mesmo fato criminoso unificado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A punição não independe da culpabilidade individual de cada agente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A participação de menor importância atenua a pena de um sexto a um terço (Art. 29, §1º, CP), mas não isenta de crime.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A cooperação dolosamente distinta pune o agente pelo crime menos grave pretendido (Art. 29, §2º, CP).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O partícipe também responde pelo crime nos termos da lei penal.

BIZU DE PROVA:
Concurso de Pessoas (Art. 29 do CP):
Regra Geral = TEORIA MONISTA / UNITÁRIA (todos respondem pelo mesmo crime na medida de sua culpabilidade).'),
(7, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Inquérito Policial (Art. 4º e seguintes do Código de Processo Penal) é um procedimento administrativo pré-processual inquisitivo, informativo e preparatório, sendo DISPENSÁVEL caso o titular da ação penal (Ministério Público ou querelante) já possua elementos probatórios suficientes para oferecer a denúncia ou queixa-crime.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O inquérito policial não é obrigatório/indispensável para o ajuizamento da ação penal (Art. 12, 27 e 39, §5º do CPP).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O inquérito é inquisitivo e conduzido sem o contraditório pleno da fase processual judicial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Vícios ou irregularidades no inquérito policial não anulam a ação penal judicial subsequente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O delegado de polícia não pode arquivar o inquérito policial (Art. 17 do CPP).

BIZU DE PROVA:
Inquérito Policial é DISPENSÁVEL:
Se o Ministério Público já tiver provas suficientes de autoria e materialidade, pode oferecer a denúncia DIRETO, sem necessidade de inquérito!'),
(8, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A CADEIA DE CUSTÓDIA (Artigo 158-A do Código de Processo Penal, incluído pela Lei nº 13.964/2019) é o conjunto de todos os procedimentos utilizados para manter e documentar a história cronológica do vestígio, garantindo a sua autenticidade, integridade e a rastreabilidade probatória desde a sua identificação até o descarte.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A cadeia de custódia não serve para destruir vestígios, mas sim para preservá-los rigorosamente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se destina a dispensar a realização de perícia técnica oficial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A quebra da cadeia de custódia compromete a idoneidade da prova pericial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Aplica-se a todos os vestígios materiais da infração penal.

BIZU DE PROVA:
Cadeia de Custódia (Art. 158-A do CPP):
Garantir a HISTÓRIA CRONOLÓGICA e a RASTREABILIDADE de todo vestígio do crime!'),
(10, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, §1º, da Lei nº 13.869/2019 (Lei de Abuso de Autoridade) exige expressamente, para a caracterização dos crimes nela previstos, o dolo específico de "prejudicar outrem ou beneficiar a si mesmo ou a terceiro, ou, ainda, por mero capricho ou satisfação pessoal".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A vantagem puramente financeira não é o único móvel admitido pelo tipo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A lei não contempla figuras típicas de abuso de autoridade culposo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A simples falha procedimental sem dolo específico não constitui crime.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A divergência na interpretação de lei não configura abuso de autoridade (Art. 1º, §2º).

BIZU DE PROVA:
Dolo Específico na Lei 13.869/19 (Mnemônico P-B-C-S):
Prejudicar, Beneficiar, mero Capricho ou Satisfação pessoal!'),
(12, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 42 e Artigo 142 da Constituição Federal e a legislação militar estadual, a HIERARQUIA e a DISCIPLINA constituem as bases institucionais permanentes das corporações militares do Estado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Hierarquia e disciplina são pilares inderrogáveis da ordem militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A subordinação funcional legal é obrigatória em todas as unidades militares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A hierarquia estrutura os postos e graduações na corporação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O cumprimento das leis e normas disciplinares é dever fundamental de todo militar.

BIZU DE PROVA:
Bases Constitucionais das Forças Militares:
HIERARQUIA e DISCIPLINA constituem os pilares da estrutura militar!'),
(19, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 144, caput, da Constituição Federal estabelece que a segurança pública é exercida para a PRESERVAÇÃO DA ORDEM PÚBLICA E DA INCOLUMIDADE DAS PESSOAS E DO PATRIMÔNIO.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se restringe a fins patrimoniais, tutelando precipuamente a vida e integridade física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segurança pública é dever de todas as esferas estatais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A atuação policial subordina-se aos direitos e garantias fundamentais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É direito e responsabilidade de toda a sociedade.

BIZU DE PROVA:
Finalidade da Segurança Pública (Art. 144 da CF/88):
Preservação da ORDEM PÚBLICA e incolumidade das PESSOAS e do PATRIMÔNIO.'),
(20, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A hierarquia e a disciplina militar constituem as bases institucionais e operacionais da Brigada Militar do Estado do Rio Grande do Sul, conforme o Artigo 42 da Constituição Federal e a Lei Complementar Estadual nº 10.990/1997.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A hierarquia e a disciplina vinculam todos os servidores militares estaduais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A subordinação e o escalonamento funcional são indispensáveis à eficiência operacional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As ordens legais dos superiores devem ser rigorosamente acatadas e cumpridas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A corporação militar rege-se pelos princípios da legalidade e disciplina.

BIZU DE PROVA:
Estrutura da Brigada Militar:
Fundamentada na hierarquia e na disciplina militar, com autoridade e responsabilidade crescentes com o grau hierárquico.'),
(38, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O comando da questão solicita a alternativa INCORRETA. A alternativa D é incorreta porque o Artigo 144, §7º, da Constituição Federal de 1988 estabelece que "A LEI (lei ordinária comum) disciplinará a organização e o funcionamento dos órgãos responsáveis pela segurança pública", e NÃO lei complementar.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 144, §5º-A da CF (incluído pela EC nº 104/2019).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 144, §4º da CF sobre as competências das Polícias Civis.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 144, §5º da CF sobre as atribuições das PMs e CBMs.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 144, §8º da CF sobre as Guardas Municipais.

BIZU DE PROVA:
Pegadinha Clássica de Direito Constitucional:
Quando a Constituição exige LEI COMPLEMENTAR, ela diz expressamente "lei complementar". Se diz apenas "a lei disciplinará" (como no art. 144, §7º), trata-se de LEI ORDINÁRIA!'),
(39, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Conforme o regime previdenciário e estatutário consolidado na Constituição do Estado do Rio Grande do Sul e na legislação correlata, o servidor militar estadual (ativo, inativo e pensionista) vincula-se ao regime próprio estadual / Sistema de Proteção Social dos Militares Estaduais do RS.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os integrantes da BM e do CBM são servidores públicos MILITARES do Estado (Art. 42 da CF), e não servidores civis.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Constituição assegura a livre associação profissional dos servidores militares (é vedada apenas a sindicalização e greve - Art. 142, IV, CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Constituição Estadual admite funções de confiança e cargos específicos militares junto aos Poderes de Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A matéria é reservada a regramento estatutário próprio e regras de reprodução obrigatória.

BIZU DE PROVA:
Militares Estaduais (Art. 42 da CF):
São servidores públicos MILITARES do Estado, possuindo regime previdenciário e de proteção social próprio.'),
(41, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O comando da questão pede o órgão que NÃO integra o rol taxativo de órgãos constitucionais de segurança pública do Artigo 144 da Constituição Federal de 1988. Os CORPOS DE BOMBEIROS CIVIS (brigadistas privados / particulares) não são órgãos públicos e não constam no rol constitucional do Art. 144.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
PF, PRF e PFF constam expressamente nos incisos I, II e III do Artigo 144 da CF.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Polícias Civis constam no inciso IV do Artigo 144 da CF.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Polícias Militares constam no inciso V do Artigo 144 da CF.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Polícias Penais (federal, estaduais e distrital) constam no inciso VI do Artigo 144 da CF (EC 104/2019).

BIZU DE PROVA:
Rol dos Órgãos de Segurança Pública (Art. 144 da CF/88):
1. Polícia Federal;
2. Polícia Rodoviária Federal;
3. Polícia Ferroviária Federal;
4. Polícias Civis;
5. Polícias Militares e Corpos de Bombeiros Militares;
6. Polícias Penais.
(Bombeiro Civil NÃO é órgão público do art. 144!).'),
(42, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C reproduz expressamente a literalidade do Artigo 1º, §6º, da Lei nº 8.429/1992 (Lei de Improbidade Administrativa, incluído pela Lei nº 14.230/2021): "Estão sujeitos às sanções desta Lei os atos de improbidade praticados contra o patrimônio de entidade privada para cuja criação ou custeio o erário haja concorrido ou concorra no seu patrimônio ou receita atual, limitado o ressarcimento de prejuízos, nesse caso, à repercussão do ilícito sobre a contribuição dos cofres públicos."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 1º, §1º da LIA dispõe que o mero exercício da função sem comprovação de ato doloso AFASTA a responsabilidade por improbidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Entidades privadas que não recebem recursos públicos não se sujeitam à LIA (Art. 1º, §7º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Artigo 1º, §8º da LIA prevê que a divergência interpretativa da lei NÃO configura improbidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Artigo 2º, parágrafo único, sujeita a pessoa física OU jurídica celebrante de ajuste com o poder público.

BIZU DE PROVA:
Entidades Privadas e LIA (Art. 1º, §6º da Lei nº 8.429/92):
Se o erário concorre para criação ou custeio de entidade privada, há sujeição à LIA, limitada a reparação à parcela pública lesada!'),
(43, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Nos termos da Lei Estadual RS nº 10.991/1997 (Lei de Organização Básica da Brigada Militar), o Estado-Maior é o órgão de direção geral responsável pelo planejamento estratégico e assessoramento superior, cabendo ao Chefe do Estado-Maior a competência direta de ASSESSORAR O COMANDANTE-GERAL em todas as atividades institucionais e operacionais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A apuração correcional disciplinar cabe precipuamente à Corregedoria-Geral da corporação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A elaboração e aprovação de regulamentos gerais é competência do Comandante-Geral e do Governador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribuição específica dos órgãos de controle e investigação correcional nos termos regimentais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Competência genérica que não expressa a função estrutural precípua de assessoria estratégica do Chefe do Estado-Maior.

BIZU DE PROVA:
Chefe do Estado-Maior da Brigada Militar (Lei Estadual nº 10.991/1997):
Função precípua de ASSESSORAMENTO DIRETO ao Comandante-Geral e coordenação do planejamento estratégico da corporação!'),
(44, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O comando da questão pede o elemento que NÃO é requisito de validade do ato administrativo segundo a clássica lição doutrinária de Hely Lopes Meirelles. Os cinco requisitos essenciais de validade são: Competência, Finalidade, Forma, Motivo e Objeto (CO-FI-FO-MO-OB). A MOTIVAÇÃO (exteriorização formal das razões do ato) é elemento da forma/procedimento, e não requisito autônomo na classificação pentapartida clássica de Hely Lopes Meirelles.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Competência é requisito essencial e vinculado do ato administrativo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Objeto (ou conteúdo) é requisito essencial do ato administrativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Finalidade é requisito essencial e vinculado do ato administrativo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Forma é requisito essencial de exteriorização do ato administrativo.

BIZU DE PROVA:
Requisitos do Ato Administrativo segundo Hely Lopes Meirelles (Mnemônico CO-FI-FO-MO-OB):
- COmpetência;
- FInalidade;
- FOrma;
- MOtivo;
- OBjeto.
(A MOTIVAÇÃO não entra como requisito autônomo na lista clássica de 5 elementos!).'),
(45, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa B reproduz textualmente o conceito legal de DISCIPLINA MILITAR contido no Artigo 13 da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais): "A disciplina militar é a rigorosa observância e o acatamento integral das leis, regulamentos, normas e disposições que fundamentam o organismo policial-militar e coordenam o seu funcionamento regular e harmônico, traduzindo-se pelo cumprimento do dever por parte de todos e de cada um dos seus componentes."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A hierarquia militar não se faz "exclusivamente por postos ou graduações", havendo também a precedência funcional (Art. 12 da LC 10.990/97).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A disciplina e o respeito à hierarquia devem ser mantidos também na inatividade (reserva remunerada e reformados - Art. 13, §1º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Círculos hierárquicos são âmbitos de convivência entre militares da MESMA categoria (e não de categorias distintas - Art. 16).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A antiguidade cede passo nos casos de precedência funcional do Comandante-Geral, Subcomandante e Chefe do Estado-Maior (Art. 14, §1º).

BIZU DE PROVA:
Estatuto dos Militares do RS (LC 10.990/97):
Disciplina é o ACATAMENTO INTEGRAL das leis e regulamentos, devendo ser mantida inclusive pelos militares da RESERVA e REFORMADOS!'),
(47, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O comando da questão exige a alternativa INCORRETA. A alternativa C é incorreta porque o Artigo 136, §2º, da Constituição Federal estabelece que "O tempo de duração do estado de defesa não será superior a trinta dias, PODENDO SER PRORROGADO UMA VEZ, por igual período, se persistirem as razões que justificaram a sua decretação", sendo inconstitucional a prorrogação por "quantas vezes forem necessárias".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 136, §3º, inciso I, da Constituição Federal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: o Artigo 136, §3º, inciso IV, da CF veda expressamente a incomunicabilidade do preso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: reflete fielmente o Artigo 138 da Constituição Federal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 138, §1º da Constituição Federal.

BIZU DE PROVA:
Duração do Estado de Defesa (Art. 136, §2º da CF/88):
Prazo máximo de 30 DIAS + UMA ÚNICA PRORROGAÇÃO por mais 30 dias (total máximo de 60 dias). Não pode prorrogar indefinidamente!'),
(48, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão de acordo com o Artigo 37 da Constituição Federal apenas as situações I, III e IV:
- Situação I (Correta - Art. 37, I): Os cargos, empregos e funções públicas são acessíveis aos brasileiros e aos estrangeiros, na forma da lei.
- Situação II (Incorreta - Art. 37, II): Nem "qualquer" cargo depende de concurso público, pois a CF ressalva expressamente as nomeações para cargo em comissão declarado em lei de livre nomeação e exoneração.
- Situação III (Correta - Art. 37, V): As funções de confiança, exercidas exclusivamente por servidores ocupantes de cargo efetivo, destinam-se apenas às atribuições de direção, chefia e assessoramento.
- Situação IV (Correta - Art. 37, XII): Os vencimentos dos cargos do Poder Legislativo e do Poder Judiciário não poderão ser superiores aos pagos pelo Poder Executivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A situação II está errada (ressalva cargos em comissão).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A situação II está incorreta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação II está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A situação II invalida a assertiva geral.

BIZU DE PROVA:
Regras do Art. 37 da CF/88:
- Estrangeiro pode ter cargo público: SIM, na forma da lei;
- Cargos em comissão: dispensam concurso público;
- Funções de Confiança: EXCLUSIVAS de servidor efetivo para chefia, direção e assessoramento.'),
(49, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa E é a INCORRETA (gabarito) porque o Artigo 8º da Lei nº 8.429/1992 (LIA) dispõe expressamente que "o sucessor ou o herdeiro daquele que causar dano ao erário ou que se enriquecer ilicitamente ESTÁ SUJEITO à obrigação de repará-lo ATÉ O LIMITE DO VALOR DA HERANÇA ou do patrimônio transferido".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa verdadeira: o Art. 1º, §1º da LIA exige a comprovação do dolo específico com fim ilícito.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa verdadeira: reproduz o Art. 1º, §6º da Lei nº 8.429/1992.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa verdadeira: o terceiro que induz ou concorre dolosamente responde pela LIA (Art. 3º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa verdadeira: a autoridade que tiver ciência deve representar ao MP (Art. 14, §3º).

BIZU DE PROVA:
Responsabilidade do Herdeiro na LIA (Art. 8º da Lei nº 8.429/92):
O sucessor/herdeiro responde pelo ressarcimento do dano ao erário e pelo enriquecimento ilícito ATÉ O LIMITE DA HERANÇA recebida (não responde com patrimônio próprio!).'),
(50, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A ordem correta de preenchimento é V – V – V:
- (V) O Artigo 4º, inciso I, da Lei nº 10.826/2003 exige para aquisição de arma de fogo de uso permitido a declaração de efetiva necessidade e comprovação de idoneidade com certidões negativas criminais das Justiças Federal, Estadual, Militar e Eleitoral.
- (V) O Artigo 10, caput, estabelece que a autorização para o porte de arma de fogo de uso permitido em todo o território nacional é de competência da Polícia Federal e somente será concedida após autorização do Sinarm.
- (V) O Artigo 12 tipifica como crime a posse irregular de arma de fogo de uso permitido no interior da residência ou no local de trabalho (sendo o titular ou responsável legal da empresa).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira e a terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A segunda e a terceira assertivas são verdadeiras.

BIZU DE PROVA:
Estatuto do Desarmamento (Lei nº 10.826/2003):
- Posse Irregular (Art. 12): Dentro de casa ou no local de trabalho (do responsável).
- Porte Ilegal (Art. 14): Fora de casa (na rua, no carro) -> competência de concessão é da POLÍCIA FEDERAL!'),
(52, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Todas as assertivas I, II, III e IV estão em perfeita consonância com os Artigos 19, 21 e 22 da Constituição do Estado do Rio Grande do Sul:
- I. (Correta - Art. 19, §4º): Ação político-administrativa acompanhada por Conselhos Populares.
- II. (Correta - Art. 21): Gestão de documentação, plataformas digitais e transparência administrativa.
- III. (Correta - Art. 22): Composição da administração indireta (autarquias, SEM, empresas públicas e fundações).
- IV. (Correta - Art. 19, §2º): Direito à informação gratuita sobre registros pessoais em bancos governamentais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Todas as quatro assertivas são plenamente corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois II e IV também estão corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois III também é correta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Incompleta, pois I também é correta.

BIZU DE PROVA:
Constituição do RS - Princípios Administrativos:
Conselhos populares, transparência ativa digital e gratuidade de certidões/informações sobre a própria pessoa.'),
(53, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C é a INCORRETA (gabarito) porque o Artigo 6º, parágrafo único, da Lei Complementar Estadual RS nº 10.990/1997 (Estatuto dos Militares Estaduais) prevê expressamente que os Oficiais nomeados Juízes do Tribunal Militar do Estado são regidos pela Lei de Organização Judiciária Militar e por legislação própria da magistratura, e NÃO pelas disposições gerais de hierarquia e disciplina do Estatuto dos Militares Estaduais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 2º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 5º da LC nº 10.990/1997.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 14 da LC nº 10.990/1997.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: consagra a precedência dos militares da ativa sobre os inativos (Art. 15).

BIZU DE PROVA:
Estatuto dos Militares do RS (LC nº 10.990/97):
Juízes Militares do TJM/RS possuem estatuto próprio da magistratura, não se submetendo ao regime comum do estatuto militar estadual.'),
(54, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A alternativa B é INCORRETA (gabarito) porque o Artigo 55 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) prevê que para a apreciação judicial das lesões ou ameaças aos interesses da população negra recorrer-se-á à ação civil pública, SEM PREJUÍZO de outras ações cabíveis (como Ação Popular, Mandado de Segurança Coletivo ou ações individuais ordinárias). A assertiva erra ao afirmar que se recorrerá "exclusivamente" à ACP.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 54 do Estatuto da Igualdade Racial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: reflete expressamente o Artigo 52 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 53 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 51 da Lei nº 12.288/2010.

BIZU DE PROVA:
Cuidado com Termos Excludentes:
"EXCLUSIVAMENTE à ação civil pública" torna o item falso. A proteção judicial à igualdade racial admite qualquer instrumento processual cabível!'),
(111, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 22, inciso XI, da Constituição Federal de 1988 estabelece que compete PRIVATIVAMENTE À UNIÃO legislar sobre TRÂNSITO E TRANSPORTES.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Juntas comerciais é matéria de competência concorrente entre União, Estados e DF (Art. 24, III, CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Orçamento é matéria de competência legislativa concorrente (Art. 24, II, CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Procedimentos em matéria processual é competência concorrente (Art. 24, XI, CF - não confundir com direito processual, que é privativo da União).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Proteção à infância e à juventude é competência concorrente (Art. 24, XV, CF).

BIZU DE PROVA:
Competências Privativas da União (Art. 22 da CF/88 - Mnemônico CAPACETE DE PIMENTA):
- Trânsito e Transporte (Art. 22, XI);
- Direito Civil, Penal, Processual, Eleitoral, etc.'),
(113, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C reproduz a literalidade do Artigo 136, §3º, inciso I, da Constituição Federal de 1988: "Na vigência do estado de defesa, a prisão por crime contra o Estado, determinada pelo executor da medida, será por este comunicada imediatamente ao juiz competente, que a relaxará, se não for legal, facultado ao preso requerer exame de corpo de delito à autoridade policial."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A hipótese descrita (locais restritos e determinados, instabilidade ou calamidade de grandes proporções) autoriza o ESTADO DE DEFESA, e não estado de sítio (Art. 136, caput, CF).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
No caso de comoção grave nacional ou ineficácia do estado de defesa, o Presidente solicita autorização para decretar ESTADO DE SÍTIO, e não de defesa (Art. 137, I e II, CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Congresso Nacional decide sobre o estado de defesa por MAIORIA ABSOLUTA (Art. 136, §4º, CF), e não por 3/5.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
No estado de defesa o controle do Congresso é sucessivo/posterior (após o decreto), e o quórum de deliberação é de maioria absoluta.

BIZU DE PROVA:
Estado de Defesa vs Estado de Sítio na CF/88:
- Calamidade na natureza em locais restritos = ESTADO DE DEFESA (Art. 136).
- Comoção grave de repercussão nacional = ESTADO DE SÍTIO (Art. 137).
- Quórum do Congresso para ambos = MAIORIA ABSOLUTA!'),
(132, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta de preenchimento é V – V – F:
- (V) O Artigo 50 da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial) determina a inclusão obrigatória do quesito raça nos registros administrativos de empregadores e trabalhadores públicos e privados.
- (V) O Artigo 17 determina que nas datas comemorativas cívicas as instituições de ensino públicas insiram dados históricos da participação negra nos eventos comemorados.
- (F) O Artigo 20 da lei estadual fomenta o aprendizado e prática da CAPOEIRA (e não "Kuduro") como atividade esportiva, cultural e lúdica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira e a segunda assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é verdadeira e a terceira é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva é falsa (a lei estadual refere-se expressamente à Capoeira).

BIZU DE PROVA:
Estatuto Estadual da Igualdade Racial do RS (Lei nº 13.694/11):
O diploma estadual reconhece a CAPOEIRA como patrimônio cultural e desportivo, permitindo mestres tradicionais de capoeira nas escolas!'),
(135, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa E é a INCORRETA (gabarito) porque o Artigo 24 da Lei nº 12.288/2010 (Estatuto Nacional da Igualdade Racial) e o Artigo 5º, inciso VII da CF/88 asseguram a assistência religiosa aos praticantes de religiões internados em hospitais e entidades de internação coletiva, INCLUSIVE (e não "exceto") àqueles submetidos à pena privativa de liberdade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 23 do Estatuto da Igualdade Racial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 25, inciso IV, da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 26 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 25, inciso I, da Lei nº 12.288/2010.

BIZU DE PROVA:
Assistência Religiosa aos Presos (Art. 5º, VII CF e Art. 24 Lei 12.288/10):
A liberdade religiosa e assistência espiritual é DIREITO ASSEGURADO inclusive dentro dos presídios e penitenciárias!'),
(136, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A ordem correta é V – V – V:
- (V) O Artigo 1º, §1º, da Lei nº 13.869/2019 estabelece como elemento subjetivo especial do tipo o dolo específico de prejudicar outrem, beneficiar a si ou terceiro, ou agir por mero capricho/satisfação pessoal.
- (V) A Lei de Abuso de Autoridade não prevê modalidades culposas em nenhum de seus tipos penais.
- (V) O Artigo 1º, §2º, estabelece que a divergência na interpretação de lei ou na avaliação de fatos e provas não configura abuso de autoridade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira e a terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

BIZU DE PROVA:
Pilares da Lei de Abuso de Autoridade (Lei nº 13.869/19):
- Dolo Específico Obrigatório (Art. 1º, §1º);
- Inexistência de Crime Culposo;
- Vedação expressa ao crime de hermenêutica (Art. 1º, §2º).'),
(137, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Na situação narrada, o agente público Josué e o particular Salomão concorreram dolosamente para a utilização privada de maquinário público em obra particular. Nos termos do Artigo 10, inciso II, da Lei nº 8.429/1992 (redação dada pela Lei nº 14.230/2021), constitui ato de improbidade administrativa que causa PREJUÍZO AO ERÁRIO "permitir ou concorrer para que pessoa física ou jurídica utilize bens, rendas, verbas ou valores integrantes do patrimônio público, sem a observância das formalidades legais".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Josué praticou ato causador de prejuízo ao erário (art. 10, II), e não de enriquecimento ilícito próprio.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A tipificação legal do desvio de maquinário estatal para terceiros enquadra-se expressamente no art. 10, II (dano ao erário).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Havendo prejuízo patrimonial material tipificado no art. 10, prevalece a tipificação específica de dano ao erário.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Ambos praticaram ato doloso de improbidade administrativa, sujeitando-se às sanções da LIA.

BIZU DE PROVA:
Utilizar Bem Público em Obra/Serviço Particular (LIA):
- Se o próprio agente usa para si = Art. 9º, IV (Enriquecimento Ilícito).
- Se o agente PERMITE ou CONCORRE para que TERCEIRO use = Art. 10, II (Prejuízo ao Erário)!'),
(142, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 3º, parágrafo único, da Lei nº 10.826/2003 (Estatuto do Desarmamento), as armas de fogo de uso restrito são registradas no COMANDO DO EXÉRCITO (Sigma - Sistema de Gerenciamento Militar de Armas), na forma do regulamento desta Lei, enquanto as armas de uso permitido são cadastradas no Sinarm (Polícia Federal).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Polícia Civil não é o órgão central de registro de armas de uso restrito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Polícia Militar não é o órgão federal competente pelo registro nacional de uso restrito.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A competência legal direta é atribuída ao Comando do Exército.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Polícia Federal gerencia o Sinarm para armas de uso permitido.

BIZU DE PROVA:
Registro de Armas no Brasil:
- Armas de Uso PERMITIDO -> SINARM / POLÍCIA FEDERAL.
- Armas de Uso RESTRITO -> SIGMA / COMANDO DO EXÉRCITO!'),
(143, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O Artigo 28, inciso I, da Lei nº 11.343/2006 prevê a pena de advertência sobre os efeitos das drogas.
- Assertiva II (Correta): O Artigo 28, inciso III, prevê a medida educativa de comparecimento a programa ou curso educativo (além de prestação de serviços à comunidade no inciso II).
- Assertiva III (Incorreta): O Artigo 48, §2º, da Lei de Drogas VEDA expressamente a prisão em flagrante e a imposição de fiança ao autor de conduta do art. 28, lavrando-se apenas Termo Circunstanciado de Ocorrência (TCO) com encaminhamento imediato ao Juizado Especial Criminal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é pena prevista.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III é expressamente proibida (não há prisão em flagrante no art. 28).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III torna o item incorreto.

BIZU DE PROVA:
Penas do Usuário de Drogas (Art. 28 da Lei nº 11.343/2006):
1. Advertência sobre os efeitos das drogas;
2. Prestação de serviços à comunidade;
3. Medida educativa de comparecimento a curso/programa.
NÃO HÁ PENA PRIVATIVA DE LIBERDADE nem lavratura de prisão em flagrante!'),
(192, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, §1º, da Lei nº 13.869/2019 estabelece que as condutas descritas na Lei de Abuso de Autoridade somente constituem crime quando praticadas pelo agente público com a finalidade específica de "prejudicar outrem ou beneficiar a si mesmo ou a terceiro, ou, ainda, por mero capricho ou satisfação pessoal".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O tipo não se restringe a vantagens exclusivamente econômicas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não existe crime de abuso de autoridade culposo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A infração administrativa simples não tipifica crime de abuso de autoridade sem o dolo específico.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O crime independe de dano patrimonial material direto.

BIZU DE PROVA:
Dolo Específico na Lei 13.869/19:
Exige finalidade de: PREJUDICAR OUTREM, BENEFICIAR A SI/TERCEIRO, ou agir por MERO CAPRICHO/SATISFAÇÃO PESSOAL.'),
(193, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, §2º, da Lei nº 13.869/2019 consagra a CLÁUSULA DE SALVAGUARDA HERMENÊUTICA: "A divergência na interpretação de lei ou na avaliação de fatos e provas NÃO configura abuso de autoridade." Essa regra protege a independência funcional de juízes, promotores, delegados e agentes públicos contra o chamado "crime de hermenêutica".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A divergência jurídica legítima nunca configura crime.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A responsabilidade penal é estritamente subjetiva com dolo específico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A divergência hermenêutica também não configura improbidade administrativa (art. 1º, §8º da LIA).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não constitui ilícito penal.

BIZU DE PROVA:
Crime de Hermenêutica NÃO Existe:
Divergência de interpretação da lei ou avaliação de provas NUNCA configura abuso de autoridade!'),
(194, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 1º e 2º da Lei nº 13.869/2019, os crimes de abuso de autoridade são crimes próprios quanto ao sujeito ativo, praticados por qualquer agente público (servidor ou não, da administração direta ou indireta de qualquer Poder da União, Estados, DF e Municípios) que, no exercício de suas funções ou a pretexto de exercê-las, ABUSA DO PODER que lhe foi legalmente atribuído.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os crimes de abuso de autoridade são estritamente dolosos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Tutela bens jurídicos diversos, como a liberdade, a integridade e a administração pública.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A conduta ocorre no exercício da função ou a pretexto de exercê-la.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O conceito de agente público é amplo (Art. 2º), abrangendo agentes temporários, honoríficos e comissionados.

BIZU DE PROVA:
Sujeito Ativo da Lei de Abuso de Autoridade (Art. 2º):
Conceito amplíssimo de Agente Público: servidor efetivo, comissionado, temporário, político, militar ou honorífico (como jurado e mesário)!'),
(195, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PRINCÍPIO DA LEGALIDADE ADMINISTRATIVA (Art. 37, caput, CF/88 e Art. 2º da Lei nº 9.784/1999) estabelece que a Administração Pública só pode fazer ou deixar de fazer aquilo que a lei expressamente autoriza ou determina (Princípio da Estrita Legalidade), atuando conforme a lei e o Direito.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A regra de fazer tudo o que a lei não proíbe aplica-se aos particulares (Art. 5º, II da CF - Autonomia da Vontade), e não à Administração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Administração Pública sujeita-se a amplo controle interno, legislativo e judicial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os atos administrativos exigem motivação e finalidade pública.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Poder Executivo subordinar-se às leis aprovadas pelo Poder Legislativo.

BIZU DE PROVA:
Legalidade do Particular vs Legalidade Pública:
- Particular (Art. 5º, II): Pode fazer TUDO que a lei NÃO proíbe.
- Administração (Art. 37): Só pode fazer o que a lei AUTORIZA!'),
(196, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Integram a ADMINISTRAÇÃO PÚBLICA INDIRETA (Art. 37, XIX, da Constituição Federal e Art. 4º, II, do Decreto-Lei nº 200/1967) as seguintes entidades dotadas de personalidade jurídica própria:
1. Autarquias;
2. Fundações Públicas;
3. Empresas Públicas;
4. Sociedades de Economia Mista.
As autarquias desempenham atividades típicas de Estado sob regime jurídico de direito público.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ministérios são órgãos despersonalizados integrantes da administração direta federal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Secretarias estaduais são órgãos despersonalizados da administração direta estadual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Gabinete do prefeito é órgão da administração direta municipal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Órgãos policiais sem personalidade jurídica integram a administração direta.

BIZU DE PROVA:
Entidades da Administração Indireta (Mnemônico F-A-S-E):
- Fundações Públicas;
- Autarquias;
- Sociedades de Economia Mista;
- Empresas Públicas.'),
(197, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PRINCÍPIO DA AUTOTUTELA ADMINISTRATIVA (consagrado nas Súmulas 346 e 473 do STF e no Art. 53 da Lei nº 9.784/1999) confere à Administração Pública o poder-dever de controlar seus próprios atos:
- ANULAR os atos ilegais (efeito ex tunc / retroativo);
- REVOGAR os atos válidos e inoportunos/inconvenientes (efeito ex nunc / prospectivo).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Administração não pode revogar decisões judiciais transitadas em julgado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A criação de crimes é matéria privativa de lei em sentido formal aprovada pelo Legislativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A anulação de atos que afetem direitos de terceiros exige o devido processo legal e contraditório.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A autotutela não tem poder de alterar a Constituição Federal.

BIZU DE PROVA:
Súmula 473 do STF:
"A administração pode ANULAR seus próprios atos, quando eivados de vícios que os tornam ilegais (...) ou REVOGÁ-LOS, por motivo de conveniência ou oportunidade."'),
(198, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Súmula Vinculante nº 11 do Supremo Tribunal Federal estabelece o caráter EXCEPCIONAL do uso de algemas: "Só é lícito o uso de algemas em casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia, por parte do preso ou de terceiros, justificada a excepcionalidade por escrito."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O uso de algemas não é obrigatório em todas as prisões (a liberdade corporal é a regra).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é proibido de forma absoluta; é lícito quando presentes os requisitos da Súmula Vinculante 11.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não depende de mero arbítrio; exige justificativa por escrito sob pena de responsabilidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O uso abusivo de algemas sujeita-se a controle judicial e gera nulidade do ato processual.

BIZU DE PROVA:
Súmula Vinculante nº 11 do STF (Hipóteses de Uso de Algemas - Mnemônico P-R-F):
- Perigo à integridade física própria ou alheia;
- Resistência à prisão;
- Fundado receio de Fuga.
(Sempre JUSTIFICADO POR ESCRITO!).'),
(199, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Segundo a tese de repercussão geral firmada pelo Supremo Tribunal Federal no Tema 280 (RE 603.616/RO, Rel. Min. Gilmar Mendes): "A entrada forçada em domicílio sem mandado judicial só é lícita, mesmo em período noturno, quando amparada em fundadas razões, devidamente justificadas a posteriori, que indiquem que dentro da casa ocorre situação de flagrante delito, sob pena de responsabilidade disciplinar, civil e penal do agente ou da autoridade e de nulidade dos atos praticados."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A invasão arbitrária sem justa causa configura crime de abuso de autoridade e ilicitude probatória.

POR QUE A ALTERNativa C ESTÁ INCORRETA:
O flagrante delito autoriza a entrada tanto de dia quanto durante a noite.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A denúncia anônima isolada, sem investigações prévias preliminares, não autoriza o ingresso forçado (STF/STJ).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A entrada forçada é lícita nas hipóteses constitucionais expressas de flagrante.

BIZU DE PROVA:
Tema 280 do STF (Flagrante no Domicílio):
Exige FUNDADAS RAZÕES (justa causa / elementos objetivos prévios) justificadas por escrito a posteriori!'),
(200, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme decisão histórica do STF nas ADCs 43, 44 e 54, em consonância com o Artigo 5º, inciso LVII, da Constituição Federal e o Artigo 283 do CPP, o princípio da presunção de inocência impede a execução provisória da pena antes do esgotamento de todos os recursos (trânsito em julgado), sendo admitida a prisão anterior unicamente quando decretada em caráter cautelar fundamentado (prisão preventiva ou temporária).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A prisão em flagrante continua plenamente lícita como medida pré-cautelar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prisão preventiva devidamente fundamentada no art. 312 do CPP é plenamente válida.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A investigação policial e a instrução criminal são instrumentos regulares de apuração.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As medidas cautelares diversas da prisão (art. 319 do CPP) são aplicáveis.

BIZU DE PROVA:
Prisão e Presunção de Inocência (STF - ADCs 43, 44 e 54):
Execução da pena só após o TRÂNSITO EM JULGADO. Antes disso, prisão só se for CAUTELAR (Preventiva/Temporária)!'),
(201, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No regime jurídico dos militares estaduais, a progressão funcional e a ascensão aos postos (oficiais) e graduações (praças) devem obedecer estritamente aos requisitos objetivos, critérios de antiguidade e merecimento, cursos de formação e interstícios temporais estabelecidos na legislação específica (Estatuto dos Militares Estaduais e Lei de Promoções).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A promoção não decorre de mera vontade individual do servidor militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não existe promoção automática diária desprovida de critérios legais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A observância aos requisitos legais e regulamentares é obrigatória.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A carreira militar é orientada por critérios técnicos e impessoais de antiguidade e merecimento.

BIZU DE PROVA:
Critérios de Promoção Militar:
- Antiguidade (tempo de efetivo serviço no posto/graduação);
- Merecimento (desempenho funcional, cursos, conduta e mérito profissional).'),
(202, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O plano de carreira militar estadual tem por finalidade organizar o desenvolvimento profissional contínuo, a hierarquia de postos e graduações, a qualificação técnica, os direitos, os deveres e os critérios transparentes de progressão e promoção funcional dos integrantes da corporação militar.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não versa sobre legislação eleitoral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não trata de direito tributário arrecadatório.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A carreira militar organiza a corporação militar estadual, não o Poder Judiciário.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não rege contratos privados do direito civil.

BIZU DE PROVA:
Objetivo do Plano de Carreira Militar:
Estruturar o desenvolvimento funcional, valorização profissional e ascensão nos graus hierárquicos militares.'),
(203, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A ascensão funcional e a concessão de promoções na carreira dos militares estaduais sujeitam-se rigorosamente ao princípio da legalidade estrita e às normas da lei de fixação de efetivo e promoções da corporação militar, dependendo de vaga no quadro, tempo mínimo de interstício e aprovação em curso específico.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A promoção não é um direito incondicionado e automático.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não decorre de eleição política popular.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A carreira militar é pública e regida por estatuto de direito público.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A carreira é amplamente regulamentada pela legislação constitucional e estadual.

BIZU DE PROVA:
Requisitos de Promoção Militar:
Existência de vaga + Interstício temporal + Aptidão física/mental + Curso de aperfeiçoamento.'),
(204, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme a clássica definição do Artigo 78 do Código Tributário Nacional e da doutrina de Direito Administrativo, o PODER DE POLÍCIA é a atividade da administração pública que, limitando ou disciplinando direito, interesse ou liberdade, regula a prática de ato ou abstenção de fato, em razão de interesse público concernente à segurança, à higiene, à ordem, aos costumes, à tranquilidade pública ou ao respeito à propriedade e aos direitos individuais ou coletivos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O poder de polícia não cria crimes (princípio da reserva legal penal).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não exerce função jurisdicional de coisa julgada material.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não tem competência de poder constituinte.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atua sob regime de direito público em prol da coletividade.

BIZU DE PROVA:
Conceito de Poder de Polícia (Art. 78 do CTN):
Atividade administrativa que CONDICIONA e RESTRINGE o uso de bens, liberdades e direitos individuais em prol do INTERESSE PÚBLICO!'),
(205, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
São ATRIBUTOS clássicos do poder de polícia administrativa (Mnemônico D-A-C):
1. DISCRICIONARIEDADE: margem de liberdade do administrador para avaliar a conveniência e oportunidade da medida dentro dos limites da lei;
2. AUTOEXECUTORIEDADE: faculdade da Administração de executar diretamente suas decisões sem prévia autorização judicial;
3. COERCIBILIDADE: imposição obrigatória e imperativa das medidas administrativas, inclusive com o uso legítimo da força se houver resistência.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Vitaliciedade e inamovibilidade são garantias constitucionais da magistratura e do MP (art. 95, CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Novação é instituto de extinção de obrigações do Direito Civil.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Tipicidade, culpabilidade e ilicitude são elementos da teoria do crime penal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A autoexecutoriedade dispensa a prévia intervenção judicial ordinária.

BIZU DE PROVA:
Atributos do Poder de Polícia (Mnemônico D-A-C):
- Discricionariedade;
- Autoexecutoriedade (não precisa ir ao juiz primeiro);
- Coercibilidade (uso da força legítima para fazer cumprir).'),
(206, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O exercício do poder de polícia está subordinado aos princípios republicanos da LEGALIDADE (estrita observância da lei), da PROPORCIONALIDADE / RAZOABILIDADE (necessidade, adequação e proporcionalidade em sentido estrito, vedado o excesso) e da SUPREMACIA DO INTERESSE PÚBLICO sobre o privado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A arbitrariedade e o excesso de poder são atos ilegais nulos e puníveis.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A motivação é obrigatória no exercício do poder de polícia para viabilizar o controle de legalidade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O agente deve buscar o interesse público coletivo, vedada a persecução de interesses privados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os atos de polícia devem atender ao princípio da publicidade e transparência.

BIZU DE PROVA:
Limites do Poder de Polícia:
Proporcionalidade e Meio Menos Gravoso: A polícia administrativa deve utilizar a medida menos lesiva necessária para atingir a finalidade pública!'),
(207, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PODER HIERÁRQUICO é a prerrogativa conferida à Administração Pública para estruturar, escalonar e distribuir funções entre seus órgãos e agentes, decorrendo dele os poderes de dar ordens, fiscalizar e rever atos dos subordinados, delegar e avocar competências, e dirimir conflitos de competência interna.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O poder hierárquico é meramente administrativo interno, não criando tipos penais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não exerce função jurisdicional de julgamento de ações judiciais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não edita emendas constitucionais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O poder hierárquico incide internamente na estrutura da Administração, não se aplicando a particulares sem vínculo.

BIZU DE PROVA:
Poder Hierárquico:
Incide internamente na organização administrativa (Dar ordens, fiscalizar, delegar e avocar). NÃO há hierarquia entre a Administração e o particular!'),
(208, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PODER DISCIPLINAR é a faculdade atribuída à Administração Pública para apurar infrações e aplicar penalidades funcionais aos servidores públicos e a particulares que possuam um VÍNCULO JURÍDICO ESPECÍFICO com o Estado (como concessionários de serviços públicos, estudantes de escolas públicas ou contratados administrativos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se aplica a particulares genéricos que não possuam vínculo especial com o Estado (sobre particulares sem vínculo incide o Poder de Polícia).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A aplicação de penalidades disciplinares exige prévio processo administrativo com contraditório e ampla defesa (art. 5º, LV da CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O poder disciplinar não se confunde com o poder jurisdicional penal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A discricionariedade disciplinar é restrita aos limites das sanções fixadas em lei.

BIZU DE PROVA:
Poder Disciplinar vs Poder de Polícia:
- PODER DISCIPLINAR: Pune quem tem VÍNCULO ESPECÍFICO com a Administração (servidores, contratados).
- PODER DE POLÍCIA: Restringe e pune PARTICULARES EM GERAL (sem vínculo específico).'),
(209, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PODER REGULAMENTAR (ou Normativo), consagrado no Artigo 84, inciso IV, da Constituição Federal, é a prerrogativa conferida aos chefes do Poder Executivo para expedir decretos e regulamentos destinados à FIEL EXECUÇÃO DAS LEIS, complementando-as e explicitando seus preceitos sem inovar originariamente na ordem jurídica nem contrariar a lei regulamentada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O regulamento executivo não pode criar obrigações primárias ou crimes sem respaldo em lei formal (art. 5º, II da CF).

POR QUE A ALTERNativa C ESTÁ INCORRETA:
Decretos não podem revogar nem contrariar normas constantes de leis em sentido formal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O regulamento subordinar-se hierarquicamente à lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O decreto autônomo (art. 84, VI da CF) é restrito à organização administrativa sem aumento de despesa e extinção de cargos vagos.

BIZU DE PROVA:
Poder Regulamentar (Art. 84, IV da CF/88):
Serve para dar FIEL EXECUÇÃO À LEI (ato secundário/infralegal). Não pode inovar na ordem jurídica nem criar deveres não previstos na lei!'),
(210, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O ABUSO DE PODER é gênero de conduta ilegítima do agente público que se desdobra em duas espécies clássicas:
1. EXCESSO DE PODER: quando o agente atua fora dos limites de sua competência legal (vício de competência);
2. DESVIO DE PODER (ou Desvio de Finalidade): quando o agente, embora competente, atua buscando finalidade alheia ao interesse público ou diversa da prevista em lei para o ato (vício de finalidade).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O abuso de poder constitui ato ilícito e nulo, gerando responsabilidade administrativa, civil e penal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O excesso de poder diz respeito à incompetência/extrapolação de limites legais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O desvio de finalidade caracteriza-se pela violação ao interesse público pretendido pela norma.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O abuso de autoridade é vedado e punível em qualquer nível funcional.

BIZU DE PROVA:
Espécies de Abuso de Poder:
- EXCESSO DE PODER = Vício na COMPETÊNCIA.
- DESVIO DE FINALIDADE = Vício no OBJETIVO / FINALIDADE.'),
(211, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PRINCÍPIO DA CONTINUIDADE DO SERVIÇO PÚBLICO (Art. 22 do CDC e Art. 6º da Lei nº 8.987/1995) estabelece que os serviços públicos essenciais não devem ser interrompidos ou paralisados indevidamente, devendo ser prestados de forma contínua, regular, eficiente e segura para atender às necessidades primordiais da coletividade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A interrupção arbitrária do serviço público essencial é ilegal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A suspensão por inadimplemento exige prévio aviso ao usuário e interesse da coletividade (art. 6º, §3º da Lei 8.987/95).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A paralisação técnica programada por motivo de segurança deve ser comunicada previamente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O princípio da continuidade vincula o Estado e as concessionárias prestadoras de serviços.

BIZU DE PROVA:
Princípio da Continuidade:
O serviço público essencial NÃO PODE PARAR! A interrupção é excepcionalíssima (emergência ou aviso prévio por inadimplemento/técnico).'),
(212, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PRINCÍPIO DA MODICIDADE TARIFÁRIA (Artigo 6º, §1º, da Lei Federal nº 8.987/1995) estabelece que as tarifas e preços públicos cobrados pela prestação de serviços públicos devem ser fixados em valores razoáveis, acessíveis e suportáveis economicamente pela generalidade da população, permitindo a universalização do acesso sem inviabilizar o equilíbrio econômico-financeiro da concessão.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Tarifas abusivas que impeçam o acesso dos cidadãos de menor renda violam o princípio da modicidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A fixação da tarifa deve atender ao interesse social aliado à remuneração justa da concessionária.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A gratuidade universal desprovida de subsídio orçamentário quebre o equilíbrio contratual não é exigência geral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O valor tarifário sujeita-se à regulação e fiscalização pelo poder concedente.

BIZU DE PROVA:
Princípio da Modicidade das Tarifas:
Tarifas justas e ACESSÍVEIS a toda a população para garantir o acesso universal ao serviço público.'),
(213, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O conceito de AGENTE PÚBLICO na doutrina e no direito administrativo brasileiro é amplíssimo, compreendendo toda e qualquer pessoa física que exerça, ainda que transitoriamente ou sem remuneração, por eleição, nomeação, designação, contratação ou qualquer outra forma de investidura ou vínculo, mandato, cargo, emprego ou função na administração direta ou indireta do Estado. Classificam-se em: agentes políticos, servidores públicos, empregados públicos, agentes temporários e particulares em colaboração com o poder público (honoríficos, delegados e credenciados).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se restringe a servidores efetivos aprovados em concurso público.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Abrange agentes honoríficos não remunerados (como jurados e mesários).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Alcança agentes temporários contratados por excepcional interesse público (art. 37, IX, CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Aplica-se à administração direta e indireta (fundações, autarquias e estatais).

BIZU DE PROVA:
Conceito de Agente Público:
Toda pessoa física que exerce função pública, com ou sem remuneração, permanente ou transitória!'),
(214, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na classificação dos cargos públicos (Artigo 37, II e V, da Constituição Federal):
- Cargo EFETIVO: provido mediante aprovação prévia em concurso público de provas ou de provas e títulos, conferindo estabilidade após 3 anos de efetivo exercício e avaliação especial de desempenho (Art. 41 da CF);
- Cargo EM COMISSÃO: de livre nomeação e exoneração (ad nutum), destinado exclusivamente às atribuições de direção, chefia e assessoramento.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Cargos em comissão não conferem estabilidade funcional no serviço público.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Cargos efetivos exigem concurso público obrigatório.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Funções de confiança são exercidas exclusivamente por servidores efetivos (Art. 37, V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A estabilidade é garantia privativa dos ocupantes de cargo efetivo.

BIZU DE PROVA:
Cargo Efetivo vs Cargo em Comissão:
- EFETIVO: Exige CONCURSO PÚBLICO e gera ESTABILIDADE (após 3 anos de estágio probatório).
- EM COMISSÃO: Livre nomeação e exoneração (AD NUTUM), restrito a Direção, Chefia e Assessoramento.'),
(215, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 37, §6º, da Constituição Federal consagra a RESPONSABILIDADE CIVIL OBJETIVA do Estado na modalidade TEORIA DO RISCO ADMINISTRATIVO: "As pessoas jurídicas de direito público e as de direito privado prestadoras de serviços públicos responderão pelos danos que seus agentes, nessa qualidade, causarem a terceiros, assegurado o direito de regresso contra o responsável nos casos de dolo ou culpa." A responsabilidade independe de comprovação de culpa da Administração.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A responsabilidade estatal independe de culpa ou dolo do agente (é objetiva).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A ação regressiva contra o servidor exige comprovação de dolo ou culpa (responsabilidade subjetiva regressiva).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Estado responde objetivamente tanto na administração direta quanto nas estatais prestadoras de serviços públicos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Excludentes como culpa exclusiva da vítima ou força maior afastam o nexo causal.

BIZU DE PROVA:
Art. 37, §6º da CF/88 (Responsabilidade Civil do Estado):
- Vítima contra o Estado: RESPONSABILIDADE OBJETIVA (basta conduta + dano + nexo causal, sem precisar provar culpa).
- Estado contra o Servidor (Ação Regressiva): RESPONSABILIDADE SUBJETIVA (exige DOLO ou CULPA).'),
(267, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O crime de TRÁFICO DE DROGAS (Artigo 33, caput, da Lei nº 11.343/2006) é um tipo penal misto alternativo (de conteúdo variado), composto por 18 verbos nucleares (importar, exportar, remeter, preparar, produzir, fabricar, adquirir, vender, expor à venda, oferecer, ter em depósito, transportar, trazer consigo, guardar, prescrever, ministrar, entregar a consumo ou fornecer drogas, ainda que gratuitamente), consumando-se com a prática de qualquer das condutas sem autorização legal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O tráfico de drogas não exige a efetiva venda comercial onerosa (a entrega gratuita já consuma o delito).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A posse ou depósito de drogas para destinação a terceiros caracteriza tráfico de drogas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O tráfico é crime equiparado a hediondo (Art. 5º, XLIII da CF e Lei 8.072/90).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A pena prevista no art. 33 é de reclusão de 5 a 15 anos e pagamento de 500 a 1.500 dias-multa.

BIZU DE PROVA:
Tráfico de Drogas (Art. 33 da Lei nº 11.343/06):
Tipo Misto Alternativo (18 verbos). NÃO precisa haver venda: "guardar", "transportar" ou "fornecer gratuitamente" já é TRÁFICO CONSUMADO!'),
(268, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 33, §4º, da Lei nº 11.343/2006 consagra a causa especial de diminuição de pena do TRÁFICO PRIVILEGIADO: as penas poderão ser reduzidas de um sexto a dois terços, desde que o agente seja:
1) Primário;
2) De bons antecedentes;
3) Não se dedique a atividades criminosas; e
4) Não integre organização criminosa.
O STF e o STJ já pacificaram que o tráfico privilegiado NÃO é crime hediondo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A integração em organização criminosa impede a concessão do privilégio.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A reincidência impede o reconhecimento do tráfico privilegiado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A dedicação contumaz a atividades criminosas veda a redução da pena.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A redução de pena varia entre 1/6 e 2/3.

BIZU DE PROVA:
Requisitos Cumulativos do Tráfico Privilegiado (Art. 33, §4º):
- Primário;
- Bons antecedentes;
- NÃO se dedicar a atividades criminosas;
- NÃO integrar organização criminosa.
(NÃO é hediondo!).'),
(269, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 28 da Lei nº 11.343/2006 despenalizou a conduta de adquirir, guardar, tiver em depósito, transportar ou trazer consigo drogas para consumo pessoal, substituindo as penas privativas de liberdade por sanções exclusivamente educativas (advertência, prestação de serviços à comunidade e medida educativa de comparecimento a curso).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A posse para uso próprio não configura tráfico de drogas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A conduta permanece formalmente ilícita na legislação, sujeitando o infrator às sanções educativas do art. 28.

POR QUE A ALTERNativa D ESTÁ INCORRETA:
O porte para consumo pessoal não é crime hediondo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há cominação de pena de reclusão ou detenção para o usuário.

BIZU DE PROVA:
Artigo 28 da Lei de Drogas (Uso Pessoal):
Ocorreu DESPENALIZAÇÃO (não há prisão nem reclusão). Penas meramente educativas!'),
(270, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 28, §2º, da Lei nº 11.343/2006, para determinar se a droga destinava-se a consumo pessoal, o juiz atenderá:
- À natureza e à quantidade da substância apreendida;
- Ao local e às condições em que se desenvolveu a ação;
- Às circunstâncias sociais e pessoais;
- À conduta e aos antecedentes do agente.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A quantidade da droga não é o único critério considerado pelo julgador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A renda do agente não é o critério exclusivo de tipificação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A valoração probatória é global e não depende exclusivamente de confissão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O local isolado não define por si só a capitulação do delito.

BIZU DE PROVA:
Critérios de Distinção (Art. 28, §2º da Lei 11.343/06):
Natureza e Quantidade + Local e Condições da Ação + Circunstâncias Sociais e Pessoais + Antecedentes!'),
(271, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Lei de Organização Básica da Brigada Militar (Lei Estadual nº 10.991/1997 e alterações) disciplina a estrutura organizacional, a composição dos órgãos de direção, execução e apoio, o funcionamento institucional e as atribuições funcionais da Polícia Militar do Estado do Rio Grande do Sul.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A organização do Poder Judiciário estadual é disciplinada pelo COJE (Código de Organização Judiciária).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As eleições são regidas pelo Código Eleitoral federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A matéria tributária é regida pelo Código Tributário do Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não rege segurança privada particular.

BIZU DE PROVA:
Lei de Organização Básica da Brigada Militar (Lei nº 10.991/97):
Estrutura e órgãos da BM: Comando-Geral, Estado-Maior, Órgãos de Direção, Execução (Batalhões/Comandos Regionais) e Apoio.'),
(272, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A organização administrativa e operacional da Brigada Militar deve observar as competências institucionais, hierarquia de postos e normas regimentais definidas pela Constituição Estadual e pela legislação de segurança pública aplicável no âmbito estadual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Brigada Militar é uma instituição de âmbito estadual, regida por leis estaduais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A atuação militar subordina-se à hierarquia e às ordens do Comando-Geral, e não à vontade autônoma isolada de unidades.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os militares estaduais regem-se pelo regime estatutário militar público, e não pela CLT.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A estrutura operacional não se subordina a regras eleitorais.

BIZU DE PROVA:
Competência Institucional da Brigada Militar (Art. 144, §5º da CF e Constituição RS):
Polícia Ostensiva e Preservação da Ordem Pública em todo o território estadual.'),
(295, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Pelo Princípio da Supremacia Constitucional e da Simetria (Art. 25, caput, da CF/88), a Constituição do Estado do Rio Grande do Sul e todas as leis estaduais devem observar compulsoriamente os princípios fundamentais e normas de reprodução obrigatória da Constituição Federal de 1988.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As leis municipais são hierarquicamente inferiores à Constituição Estadual e Federal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Decretos são atos infralegais subordinados à Constituição e às leis.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Normas privadas não se sobrepõem ao ordenamento constitucional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Regulamentos internos subordinam-se à ordem constitucional.

BIZU DE PROVA:
Princípio da Simetria Constitucional (Art. 25 da CF/88):
Os Estados organizam-se e regem-se pelas Constituições e leis que adotarem, OBSERVADOS OS PRINCÍPIOS DA CONSTITUIÇÃO FEDERAL!'),
(296, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º, caput, da Constituição Federal estabelece solenemente: "A República Federativa do Brasil, formada pela união indissolúvel dos Estados e Municípios e do Distrito Federal, constitui-se em ESTADO DEMOCRÁTICO DE DIREITO."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Brasil adota a forma federativa de Estado (e não Estado unitário).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Brasil é uma federação indissolúvel, e não uma confederação de soberanias.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A forma de governo é republicana (República) e o sistema é presidencialista.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A separação dos Poderes (Executivo, Legislativo e Judiciário) é cláusula pétrea (Art. 2º e Art. 60, §4º, III da CF).

BIZU DE PROVA:
Estrutura Política do Brasil (Art. 1º e 2º da CF/88):
- Forma de Estado: FEDERAÇÃO;
- Forma de Governo: REPÚBLICA;
- Sistema de Governo: PRESIDENCIALISMO;
- Regime Político: ESTADO DEMOCRÁTICO DE DIREITO.'),
(297, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 144, caput, da Constituição Federal de 1988 prescreve: "A segurança pública, DEVER DO ESTADO, DIREITO E RESPONSABILIDADE DE TODOS, é exercida para a preservação da ordem pública e da incolumidade das pessoas e do patrimônio."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A segurança pública é dever da União, dos Estados, do Distrito Federal e dos Municípios.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segurança pública é função pública indelegável do Estado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Poder Judiciário exerce o controle e julgamento, cabendo a execução aos órgãos de segurança pública.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É direito fundamental titularizado por toda a sociedade.

BIZU DE PROVA:
Artigo 144 da CF/88:
Segurança Pública = DEVER DO ESTADO + DIREITO E RESPONSABILIDADE DE TODOS!'),
(299, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Portar, deter, adquirir, fornecer, receber, ter em depósito, transportar, ceder, emprestar, remeter, empregar, manter sob guarda ou ocultar arma de fogo, acessório ou munição de uso permitido, sem autorização e em desacordo com determinação legal ou regulamentar, configura o CRIME DO ARTIGO 14 DA LEI Nº 10.826/2003 (Porte Ilegal de Arma de Fogo de Uso Permitido), punido com pena de reclusão de 2 a 4 anos e multa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O porte ilegal é infração penal (crime doloso), e não mera infração administrativa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Trata-se de crime formal e de perigo abstrato tipificado em lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É classificado como crime (delito), e não mera contravenção penal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Possui natureza estritamente penal.

BIZU DE PROVA:
Artigo 14 da Lei nº 10.826/2003:
Porte Ilegal de Arma de Fogo de Uso Permitido = CRIME de Perigo Abstrato punido com RECLUSÃO!'),
(300, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A HIERARQUIA e a DISCIPLINA constituem as bases institucionais fundamentais das Forças Armadas e das Polícias Militares e Corpos de Bombeiros Militares dos Estados (Art. 42 e 142 da Constituição Federal e legislação estadual militar).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Possuem plena eficácia jurídica e estruturam toda a atuação militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
São princípios basilares do direito público militar.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não constituem normas tributárias.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O dever de disciplina militar é indisponível e cogente.

BIZU DE PROVA:
Bases Constitucionais das Corporações Militares:
HIERARQUIA (ordenação de postos e graduações) e DISCIPLINA (rigorosa obediência às leis e regulamentos).'),
(301, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Estatuto Estadual da Igualdade Racial do Rio Grande do Sul (Lei Estadual nº 13.694/2011) destina-se a garantir à população negra e afrodescendente a efetivação da igualdade de oportunidades, a defesa dos direitos individuais, coletivos e difusos e o combate à discriminação e demais formas de intolerância étnica no Estado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Estado não cria regime penal autônomo (competência privativa da União - art. 22, I da CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não institui isenção fiscal universal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Ao contrário, orienta a formulação e execução de políticas públicas afirmativas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Garante e estimula o pleno acesso à educação e cultura.

BIZU DE PROVA:
Estatuto da Igualdade Racial do RS (Lei nº 13.694/2011):
Foco na igualdade de oportunidades, ações afirmativas e combate intransigente ao racismo no RS.'),
(302, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Estatuto Nacional da Igualdade Racial (Lei Federal nº 12.288/2010), em seu Artigo 1º, dispõe que a lei destina-se a garantir à população negra a EFETIVAÇÃO DA IGUALDADE DE OPORTUNIDADES, a defesa dos direitos étnicos individuais, coletivos e difusos e o combate à discriminação e às demais formas de intolerância étnica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A lei não concede privilégio penal ou isenção de crimes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não prevê imunidade tributária universal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As cotas em concursos públicos visam à inclusão equitativa, sem exclusividade total de cargos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todos os cidadãos submetem-se aos deveres e obrigações legais da cidadania.

BIZU DE PROVA:
Artigo 1º da Lei nº 12.288/2010:
Efetivação da IGUALDADE MATERIAL de oportunidades e combate a qualquer discriminação étnico-racial.'),
(303, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A HIERARQUIA MILITAR é a ordenação da autoridade em níveis e graus diferentes dentro da estrutura militar, dividindo-se em POSTOS (graus privativos dos Oficiais, conferidos por ato do Governador do Estado) e GRADUAÇÕES (graus privativos das Praças, conferidos pelo Comandante-Geral da corporação).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A hierarquia estrutura e consagra os graus hierárquicos militares.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A hierarquia estabelece relação de subordinação legal e escalonamento funcional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A subordinação funcional legal é inerente à hierarquia.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A atuação militar é vinculada às ordens e regulamentos corporativos.

BIZU DE PROVA:
Posto vs Graduação na PM/BM:
- POSTO = Grau hierárquico dos OFICIAIS (conferido pelo Governador).
- GRADUAÇÃO = Grau hierárquico das PRAÇAS (conferido pelo Comandante-Geral).'),
(327, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa E é a INCORRETA (gabarito da questão) porque os estrangeiros residentes no Brasil há mais de 15 anos ininterruptos e sem condenação penal que requeiram a nacionalidade brasileira são considerados BRASILEIROS NATURALIZADOS (Naturalização Extraordinária / Quinzenária - Art. 12, II, ''b'', da CF/88), e NÃO brasileiros natos!

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: é hipótese de brasileiro nato do Art. 12, I, ''c'', primeira parte.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: consagra o critério do jus solis com a ressalva diplomática (Art. 12, I, ''a'').

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: é o critério funcional do Art. 12, I, ''b''.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: reflete o Art. 12, I, ''a'' da CF.

BIZU DE PROVA:
Naturalização Extraordinária (Art. 12, II, ''b'' da CF/88):
- Residência no Brasil há mais de 15 ANOS ininterruptos;
- SEM condenação penal;
- Requerer a nacionalidade.
(São NATURALIZADOS, NUNCA natos!).'),
(348, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A alternativa C é INCORRETA (gabarito) porque o Artigo 47, parágrafo único, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) prevê que as medidas e programas instituídos pela Lei Federal NÃO SUBSTITUEM as demais políticas adotadas nos âmbitos federal, estadual, distrital ou municipal, atuando de forma cumulativa e complementar em benefício da população negra.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 39 do Estatuto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 39, §3º da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 48 da Lei nº 12.288/2010.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 54 da Lei nº 12.288/2010.

BIZU DE PROVA:
Princípio da Não Substituição (Art. 47 da Lei 12.288/2010):
As medidas do Estatuto Nacional da Igualdade Racial SOMAM-SE e NÃO substituem as políticas municipais e estaduais já existentes!'),
(350, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A associação correta entre os conceitos do Artigo 1º, parágrafo único, da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) é exatamente 1 – 2 – 3 – 4:
- (1) Discriminação racial: toda distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que tenha por objeto anular ou restringir direitos fundamentais.
- (2) Desigualdade racial: toda situação injustificada de diferenciação de acesso e fruição de bens, serviços e oportunidades nas esferas pública e privada.
- (3) Políticas públicas: ações, iniciativas e programas adotados pelo Estado no cumprimento de suas atribuições institucionais.
- (4) Ações afirmativas: programas e medidas especiais adotados pelo Estado e pela iniciativa privada para correção das desigualdades raciais e promoção da igualdade de oportunidades.
A ordem de cima para baixo é: 1 – 2 – 3 – 4.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverteu os conceitos 3 e 4 no final.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverteu os conceitos 1 e 2 no início.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverteu 1 e 2 no início.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta ordem incorreta dos conceitos legais.

BIZU DE PROVA:
Conceitos do Art. 1º da Lei nº 12.288/2010:
- Discriminação = DISTINÇÃO/RESTRIÇÃO baseada em raça.
- Desigualdade = SITUAÇÃO INJUSTIFICADA de diferenciação no acesso.
- Políticas Públicas = AÇÕES DO ESTADO.
- Ações Afirmativas = MEDIDAS ESPECIAIS para corrigir desigualdades.');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 100 (exceto explicacao/atualizado_em).
create temporary table _m100_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (694,695,696,697,715,788,789,790,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,2,3,4,5,9,7,8,10,12,19,20,38,39,41,42,43,44,45,47,48,49,50,52,53,54,111,113,132,135,136,137,142,143,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,267,268,269,270,271,272,295,296,297,299,300,301,302,303,327,348,350);

-- 2) alternativas completas das 100.
create temporary table _m100_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (694,695,696,697,715,788,789,790,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,2,3,4,5,9,7,8,10,12,19,20,38,39,41,42,43,44,45,47,48,49,50,52,53,54,111,113,132,135,136,137,142,143,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,267,268,269,270,271,272,295,296,297,299,300,301,302,303,327,348,350)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _m100_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _m100_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _m100_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _m100_novas_explicacoes) <> 100 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 100 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _m100_novas_explicacoes);
  if v_qtd <> 100 then
    raise exception 'PRECONDICAO FALHOU: esperado 100 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _m100_novas_explicacoes s on s.id = q.id
    where q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 100 questoes nao esta ativa (ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 100.
-- ----------------------------------------------------------------------------
create temporary table _m100_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao
    from _m100_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _m100_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 100 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 100 linhas, afetou %', v_linhas;
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
  insert into _m100_asserts (descricao, ok)
  select 'exatamente 100 questoes afetadas pelo UPDATE', (select count(*) from _m100_ids_afetados) = 100;

  insert into _m100_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 100 esperados',
    (select array_agg(id order by id) from _m100_ids_afetados) = (select array_agg(id order by id) from _m100_novas_explicacoes);

  insert into _m100_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 100 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _m100_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _m100_asserts (descricao, ok)
  select 'alternativas das 100 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _m100_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _m100_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _m100_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _m100_asserts (descricao, ok) values ('as 100 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 100 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _m100_novas_explicacoes)
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
    where q.id in (select id from _m100_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _m100_asserts (descricao, ok) values ('as 100 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 100);

  insert into _m100_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _m100_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[694,695,696,697,715,788,789,790,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,2,3,4,5,9,7,8,10,12,19,20,38,39,41,42,43,44,45,47,48,49,50,52,53,54,111,113,132,135,136,137,142,143,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,267,268,269,270,271,272,295,296,297,299,300,301,302,303,327,348,350]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _m100_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _m100_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _m100_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _m100_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _m100_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _m100_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
ROLLBACK;
