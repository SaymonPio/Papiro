// LOTE 2 — FASE 3B — SUB-LOTE 3: explicações pedagógicas completas para as
// 38 questões novas de Lei Maria da Penha do sub-lote 3 (cadernoNumero
// 310-361), fonte exclusiva: scratchpad/fase3b_sublote3_conteudo.json,
// extraído de scratchpad/lote2_fase3a_candidatas_limpas_521.json (520
// registros, estado atualizado após sub-lotes 1 e 2).
//
// Mesmo padrão pedagógico dos sub-lotes anteriores: GABARITO / POR QUE A
// ALTERNATIVA <letra> ESTÁ CORRETA|INCORRETA / BIZU DE PROVA; para
// Certo/Errado: GABARITO: CERTO|ERRADO / POR QUE: / BIZU DE PROVA: /
// PEGADINHA:.
//
// Reaudit pedido pelo usuário: cada gabarito foi reauditado durante a
// escrita contra legislação/jurisprudência vigente em 2026. Nenhuma
// questão precisou ser removida por ambiguidade real — nenhum caso do tipo
// "225" (duas alternativas simultaneamente corretas em resposta única) foi
// encontrado neste sub-lote.
//
// Ressalvas (VALIDA_COM_RESSALVA) -- 2 questões:
//   - 319 (tecId 3392823): a fonte marcava VALIDA_COM_RESSALVA, mas na
//     releitura direta do conteúdo a única pendência identificável foi o
//     artefato de OCR "8" solto na alternativa A, já normalizado na Fase
//     3A sem resíduo (mesmo padrão do caso 238 do sub-lote 1). Não há
//     ressalva jurídica a incorporar -- explicação escrita limpa.
//   - 335 (tecId 2812702): motivo JÁ estava persistido na fonte (Fase 2,
//     auditoria original) -- reaproveitado tal como registrado: o
//     enunciado cita erroneamente "Estatuto da Criança e do Adolescente,
//     Lei nº 8.069/1990" como lei de referência quando todo o conteúdo é
//     sobre a Lei Maria da Penha (erro histórico da banca, preservado); o
//     gabarito (Errado) já era correto porque o rol do art. 7º é
//     exemplificativo ("entre outras"), não taxativo, e a Lei 15.384/2026
//     (que acrescentou o inciso VI) reforça ainda mais essa conclusão.
//
// Ponto de atenção verificado e resolvido sem necessidade de ressalva: a
// questão 359 (tecId 2966706), alternativa A, contém a expressão "violação
// de intimidAÇÃO" -- confirmada via grep no .txt bruto do caderno original
// (supabase/_lote2_txt/caderno_201 ao 400.txt, linha 2779) como texto
// GENUÍNO da banca, não artefato de parser -- portanto preservada sem
// alteração. Como "intimidação" não é o termo legal usado pelo art. 7º, II
// ("violação de sua intimidade"), e como a alternativa oferece um exemplo
// pontual em vez da definição completa pedida pelo enunciado ("define
// corretamente"), o gabarito C (definição completa e literal) permanece o
// único correto, sem ambiguidade.

export const explicacoes = [

{ tecId: 3324785, cadernoNumero: 310, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — texto literal reproduzido pela alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Direitos fundamentais" é conceito próximo, mas não é a expressão literal usada pelo art. 6º, que fala especificamente em "direitos humanos".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Direitos constitucionais" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Direitos difusos" é categoria de direito processual coletivo, sem relação com a formulação do art. 6º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Direitos institucionais" não é expressão usada pela Lei nem conceito jurídico correspondente ao art. 6º.

BIZU DE PROVA:
Decore a frase literal do art. 6º: "constitui uma das formas de violação dos direitos humanos" — quando a banca pede a expressão exata da Lei (não apenas um conceito próximo), só a opção com "direitos humanos" está certa.` },

{ tecId: 3083884, cadernoNumero: 311, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Limitação do direito de ir e vir é conduta expressamente listada no art. 7º, II (violência psicológica). Retenção de documentos pessoais e subtração de economias são condutas expressamente listadas no art. 7º, IV (violência patrimonial). A situação combina as duas modalidades.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de conduta sexual (art. 7º, III) — as condutas narradas são de controle (psicológica) e de bens/valores (patrimonial).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física (art. 7º, I) — nenhuma das condutas narradas ofende a integridade ou saúde corporal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria (art. 7º, V, violência moral), nem de agressão física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria — a limitação do direito de ir e vir é psicológica, não moral.

BIZU DE PROVA:
"Limitação do direito de ir e vir" = psicológica (art. 7º, II). "Retenção de documentos" e "subtração de economias/valores" = patrimonial (art. 7º, IV). Quando o relato combina as duas famílias de conduta, a resposta reconhece ambas as modalidades.` },

{ tecId: 3324796, cadernoNumero: 312, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal de violência física dada pelo art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência moral (art. 7º, V — calúnia, difamação ou injúria), não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É a definição de violência psicológica (art. 7º, II), não física.

BIZU DE PROVA:
Física é a definição mais curta e direta do art. 7º: "ofender integridade ou saúde corporal" — qualquer definição mais longa/elaborada pertence a outra modalidade.` },

{ tecId: 3338000, cadernoNumero: 314, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O marido de dona Regina retirou arbitrariamente o cartão bancário dela, impedindo-a de fazer compras — conduta que se enquadra na definição de violência patrimonial (art. 7º, IV: retenção de objetos, bens, valores ou recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão à integridade ou saúde corporal de dona Regina.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Embora a retenção do cartão também tenha um componente de controle, a conduta especificamente descrita — reter o bem que permite o acesso a recursos econômicos — se enquadra mais precisamente na definição de violência patrimonial (art. 7º, IV), que trata especificamente de retenção de objetos/valores/recursos econômicos.

BIZU DE PROVA:
Reter cartão bancário, documentos ou qualquer bem que dê acesso a recursos econômicos da vítima = patrimonial (art. 7º, IV) — mesmo quando o efeito prático também restrinja sua autonomia, a Lei classifica a conduta sobre o BEM retido como patrimonial.` },

{ tecId: 3077866, cadernoNumero: 315, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, I — unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a regra ao exigir "obrigatoriamente com vínculo familiar" — o art. 5º, I, é expresso ao dizer "com OU SEM vínculo familiar".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui à "família" a definição que, na verdade, é da unidade doméstica (art. 5º, I) — rótulo trocado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Troca "convívio permanente" por "convívio temporário" — o art. 5º, I, exige convívio permanente, não temporário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Combina dois erros: atribui à "família" a definição da unidade doméstica, e ainda exige "obrigatoriamente com vínculo familiar", invertendo a regra.

BIZU DE PROVA:
Unidade doméstica = convívio PERMANENTE, COM OU SEM vínculo familiar, inclusive esporadicamente agregadas. Família = comunidade de aparentados por laços naturais, afinidade OU vontade expressa. Bancas adoram trocar essas duas definições entre si ou inverter "com ou sem"/"permanente".` },

{ tecId: 3073912, cadernoNumero: 316, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo — incluindo o âmbito da unidade doméstica — independem de orientação sexual. A afirmativa é verdadeira mesmo formulada de modo mais específico (referida à unidade doméstica), pois essa independência vale para todos os âmbitos do art. 5º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a regra do art. 5º, I, ao exigir "desde que tenha vínculo familiar" — a Lei diz "com ou sem vínculo familiar".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Descreve a unidade doméstica com a definição de família (comunidade de pessoas com laços consanguíneos) e ainda restringe indevidamente a "laços consanguíneos" — o art. 5º, II, é mais amplo (laços naturais, afinidade ou vontade expressa).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverte a regra do art. 5º, III, ao exigir "desde que se comprove a coabitação" — a Lei diz "independentemente de coabitação".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atribui a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) ao rótulo "psicológica" — mislabeling clássico.

BIZU DE PROVA:
Toda vez que uma alternativa inverter "independentemente de" para "desde que" (coabitação, orientação sexual, vínculo familiar), ela está errada — a Lei Maria da Penha é sistematicamente mais abrangente do que essas versões restritivas sugerem.` },

{ tecId: 3392823, cadernoNumero: 319, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
As mensagens ofensivas e ameaças recebidas por Carolina após o término do relacionamento configuram violência psicológica (art. 7º, II — ameaça, dentre outras condutas). O saldo devedor decorrente do acesso do ex-companheiro à conta bancária de Carolina configura violência patrimonial (art. 7º, IV — subtração de valores/recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão física — apenas mensagens ofensivas, ameaças e movimentação indevida da conta bancária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria (art. 7º, V) — a conduta relatada quanto à conta bancária é de natureza patrimonial (subtração de valores), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Omite a violência psicológica, evidente nas mensagens ofensivas e ameaças recebidas por Carolina, e classifica erroneamente a conduta patrimonial como moral.

BIZU DE PROVA:
Mensagens ofensivas/ameaças pós-término = psicológica (art. 7º, II, "ameaça" é termo literal); acesso indevido à conta com saldo devedor = patrimonial (art. 7º, IV, "subtração... valores... recursos econômicos"). União estável encerrada não afasta a Lei — o relacionamento "tenha convivido" (art. 5º, III) já é suficiente.` },

{ tecId: 3415068, cadernoNumero: 320, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Espaço de convívio permanente de pessoas, com ou sem vínculo familiar" é a definição literal de unidade doméstica dada pelo art. 5º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Família" (art. 5º, II) é definida como comunidade formada por indivíduos que são ou se consideram aparentados por laços naturais, afinidade ou vontade expressa — não como "espaço de convívio permanente de pessoas, com ou sem vínculo familiar", que é a definição de unidade doméstica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Relação institucional" não é um dos três âmbitos do art. 5º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Relação intrafamiliar e estrutural" não é expressão usada pela Lei nem corresponde a nenhum dos três âmbitos do art. 5º.

BIZU DE PROVA:
"Convívio permanente, com ou sem vínculo familiar, inclusive esporadicamente agregadas" = sempre unidade doméstica (art. 5º, I). Não confundir com família (art. 5º, II, que exige algum tipo de parentesco/vontade expressa de constituir família).` },

{ tecId: 3072118, cadernoNumero: 321, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Paulo teve acesso às contas e senhas de Silvia, fez movimentações bancárias e, ao final, levou as joias dela e deixou a conta com saldo devedor — condutas que se enquadram na definição de violência patrimonial (art. 7º, IV: subtração de bens, valores e recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Silvia.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência institucional" não é modalidade nomeada pela Lei Maria da Penha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria — as condutas narradas envolvem bens e valores, não ataque à honra/reputação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência verbal" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
Levar joias, esvaziar conta bancária, deixar saldo devedor = patrimonial, sempre — mesmo que o agressor alegue estar "cuidando do patrimônio de ambos" (como no relato), o que importa é a conduta objetiva de subtração de bens e valores da vítima.` },

{ tecId: 3417429, cadernoNumero: 324, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 1.c, 2.a, 3.b: violência física (1) corresponde a "ofenda sua integridade ou saúde corporal" (c); violência patrimonial (2) corresponde a "retenção, subtração, destruição... objetos, instrumentos de trabalho, documentos pessoais, bens, valores" (a); violência moral (3) corresponde a "calúnia, difamação ou injúria" (b).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Associa física (1) à definição de moral ("b"), o que é trocado — física é "ofensa à integridade/saúde corporal" (c).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Associa física (1) à definição de moral ("b") e moral (3) à definição de física ("c") — as duas trocadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Associa física (1) à definição de patrimonial ("a") e patrimonial (2) à definição de moral ("b") — invertidas.

BIZU DE PROVA:
Física = corporal; patrimonial = objetos/bens/documentos; moral = calúnia/difamação/injúria. Monte essa "ficha" antes de casar as colunas — evita trocar rótulo por definição parecida.` },

{ tecId: 2759639, cadernoNumero: 325, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ivan refere-se a Maristela com palavras depreciativas e humilhantes e a isola do convívio com família e amigos — condutas expressamente listadas no art. 7º, II (humilhação, isolamento), configurando padrão de violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As palavras depreciativas são dirigidas diretamente a Maristela, sem indicação de que Ivan tenha espalhado calúnia, difamação ou injúria sobre ela perante terceiros (art. 7º, V) — o que houve foi humilhação e isolamento direcionados a ela, não ataque à sua reputação perante outras pessoas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de retenção, subtração ou destruição de bens/valores.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Há, sim, indícios claros de violência doméstica (psicológica), dado o relacionamento marital de 3 anos e o padrão de humilhação e isolamento descrito.

BIZU DE PROVA:
Humilhação e isolamento DIRECIONADOS à vítima (mudança de comportamento, afastamento de amigos e família, palavras depreciativas ditas a ela) = psicológica. Só vire "moral" quando houver uma acusação/ofensa à reputação da vítima espalhada PARA TERCEIROS (calúnia, difamação, injúria) — não é o caso aqui.` },

{ tecId: 2770925, cadernoNumero: 326, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Apenas os itens II e IV estão corretos. II reproduz literalmente o art. 6º (violação dos direitos humanos). IV reproduz o art. 9º, §1º (o juiz determinará, por prazo certo, a inclusão da mulher no cadastro de programas assistenciais do governo federal, estadual e municipal).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item I, que está errado — o texto descrito no item I ("comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa") é a definição de FAMÍLIA (art. 5º, II), não de "unidade doméstica".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui o item I (errado, pelo motivo acima) e exclui o item II (correto).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item III, que está errado — "calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item III (errado, pelo motivo acima) e exclui o item II (correto).

BIZU DE PROVA:
Dois mislabelings clássicos nesta questão: item I troca "unidade doméstica" pela definição de "família", e item III troca "psicológica" pela definição de "moral" — fique atento a esse tipo de armadilha em questões de múltiplas assertivas.` },

{ tecId: 2789972, cadernoNumero: 327, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todos os itens estão certos. O art. 5º, caput, lista exatamente essas consequências como caracterizadoras de violência doméstica e familiar quando decorrentes de ação ou omissão baseada no gênero: morte, lesão (I), sofrimento físico, sexual ou psicológico (II e IV) e dano moral ou patrimonial (III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item IV (sofrimento psicológico), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item III (dano moral), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item II (sofrimento físico), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o item I (lesão), que também consta do art. 5º, caput.

BIZU DE PROVA:
O caput do art. 5º reúne todas essas consequências em uma única frase: "morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial" — se a questão fragmentar essa frase em itens I a IV, todos tendem a estar corretos, salvo se um deles for adulterado.` },

{ tecId: 3449398, cadernoNumero: 328, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A definição do enunciado — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações, comportamentos, crenças e decisões — reproduz literalmente o art. 7º, II, que define violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física (art. 7º, I) é definida como ofensa à integridade ou saúde corporal — não corresponde ao texto do enunciado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência moral (art. 7º, V) é definida como calúnia, difamação ou injúria — não corresponde ao texto do enunciado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) é definida como retenção/subtração/destruição de bens e valores — não corresponde ao texto do enunciado.

BIZU DE PROVA:
"Dano emocional e diminuição da autoestima... degradar ou controlar ações, comportamentos, crenças e decisões" = sempre psicológica (art. 7º, II) — frase-chave para memorizar e reconhecer de imediato.` },

{ tecId: 3055885, cadernoNumero: 329, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O item I descreve corretamente, em linhas gerais, as consequências que caracterizam violência contra a mulher previstas no art. 5º, caput (morte, lesão, sofrimento físico/sexual/psicológico, dano moral/patrimonial). O item II reproduz o art. 9º, caput, segundo o qual a assistência à mulher em situação de violência será prestada de forma articulada entre profissionais, serviços e políticas públicas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item III, que é falso — a Lei Maria da Penha não se limita ao atendimento pós-violência; ela expressamente cria mecanismos para "coibir e PREVENIR" a violência doméstica (art. 1º) e prevê medidas de prevenção (art. 8º), não sendo correto afirmar que a ausência de ações preventivas seja um dos principais pontos de crítica à Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item II, mas o item I também está correto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui os itens I, II e III — o item III é falso pelo motivo já exposto.

BIZU DE PROVA:
A Lei Maria da Penha se estrutura em dois eixos que sempre andam juntos: proteção/resposta (medidas protetivas, resposta penal) E prevenção (art. 1º e art. 8º) — qualquer alternativa que diga que a Lei "só" olha para o atendimento pós-violência, sem prevenção, está errada.` },

{ tecId: 3055293, cadernoNumero: 330, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Os itens I e III reproduzem literalmente o art. 5º, I e III (âmbito da unidade doméstica e âmbito da família, respectivamente). O item II está errado, pois exige "desde que haja coabitação", quando o art. 5º, III, dispensa expressamente a coabitação para o âmbito da relação íntima de afeto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item II, que é falso pelo motivo acima, e exclui o item III, que é verdadeiro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui o item II, falso, e exclui o item I, verdadeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item II, que é falso.

BIZU DE PROVA:
"Relação íntima de afeto" é o único dos três âmbitos que menciona expressamente a dispensa de coabitação (art. 5º, III) — qualquer versão que exija coabitação para esse âmbito específico está errada.` },

{ tecId: 3050257, cadernoNumero: 332, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Maurício agrediu Paula com palavras de baixo calão, constrangendo-a e humilhando-a — condutas expressamente listadas no art. 7º, II (constrangimento, humilhação), configurando violência psicológica. O fato de o namoro (não casamento) ser a natureza da relação não afasta a Lei, pois o art. 5º, III, alcança qualquer relação íntima de afeto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha se aplica a qualquer relação íntima de afeto, não apenas ao casamento (art. 5º, III) — o namoro está incluído.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A humilhação foi dirigida diretamente a Paula, na presença de terceiros que apenas testemunharam a agressão verbal — não há relato de que Maurício tenha feito uma acusação falsa ou ofensiva à reputação dela perante os amigos (o que caracterizaria calúnia, difamação ou injúria, art. 7º, V). A presença de terceiros como testemunhas de uma humilhação direta não transforma, por si só, a conduta em violência moral — o núcleo da conduta (constranger e humilhar Paula) continua sendo psicológico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Paula — apenas agressão verbal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O próprio texto da alternativa é internamente contraditório: rotula a conduta como "psicológica", mas a justifica com "caluniou e difamou", que são, na verdade, os termos que definem violência MORAL (art. 7º, V), não psicológica. Além disso, não há relato de calúnia ou difamação no caso — apenas humilhação direta.

BIZU DE PROVA:
Humilhar/constranger a vítima diretamente, mesmo na presença de outras pessoas, é psicológica (art. 7º, II) — só vira moral quando há uma acusação/ofensa à reputação da vítima especificamente espalhada ou dirigida a terceiros (calúnia, difamação, injúria), o que é diferente de simplesmente humilhá-la "na frente" de alguém.` },

{ tecId: 3039026, cadernoNumero: 333, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência sexual (art. 7º, III) trata de constranger a ato sexual, entre outras condutas — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de bens e valores — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Calúnia, difamação e injúria (os três crimes contra a honra do Código Penal, arts. 138-140) = sempre violência moral, art. 7º, V — associação direta, cobrada com muita frequência.` },

{ tecId: 3031784, cadernoNumero: 334, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é C-E-C. O primeiro item reproduz literalmente o art. 5º, I (unidade doméstica) — certo. O segundo item descreve uma relação de trabalho, com superior hierárquico, sem qualquer relação íntima de afeto ou parentesco com a ofendida — essa situação não se enquadra em nenhum dos três âmbitos do art. 5º (não é unidade doméstica, não é família, não é relação íntima de afeto) — errado. O terceiro item reproduz literalmente o art. 5º, II (família) — certo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte o primeiro e o segundo itens — marca o item da unidade doméstica (correto) como errado e o item do ambiente de trabalho sem vínculo íntimo/familiar (que está fora do alcance dos três âmbitos) como certo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca todos os itens como certos, incluindo o segundo, que descreve uma situação sem qualquer dos três âmbitos do art. 5º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca todos os itens como errados, incluindo o primeiro e o terceiro, que reproduzem literalmente os incisos I e II do art. 5º.

BIZU DE PROVA:
Relação de trabalho com superior hierárquico, SEM relação íntima de afeto ou parentesco, não se enquadra em nenhum dos três âmbitos do art. 5º — casos assim (assédio moral/sexual no trabalho, por exemplo) são tratados por outras normas (CLT, Código Penal), não pela Lei Maria da Penha, salvo se também houver vínculo familiar ou afetivo entre agressor e vítima.` },

{ tecId: 2812702, cadernoNumero: 335, explicacao: `GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 é expresso ao dizer que "são formas de violência doméstica e familiar contra a mulher, ENTRE OUTRAS" — o rol é exemplificativo, não taxativo. A afirmativa do enunciado, ao dizer que as formas estão "taxativamente" previstas e que não pode haver medida protetiva para situações "outras senão aquelas elencadas", contraria diretamente essa característica da Lei. A própria Lei 15.384/2026, que acrescentou a violência vicária como um sexto inciso ao art. 7º, reforça essa conclusão: se o rol fosse mesmo taxativo e fechado, não seria juridicamente possível acrescentar uma nova modalidade quase 20 anos depois. (Nota: o enunciado cita, em seu preâmbulo, o "Estatuto da Criança e do Adolescente, Lei nº 8.069/1990" como lei de referência, mas todo o conteúdo tratado é da Lei Maria da Penha — erro histórico do enunciado original, preservado tal como a banca apresentou.)

BIZU DE PROVA:
"Entre outras" (art. 7º, caput) é a expressão que garante que o rol de modalidades de violência doméstica é exemplificativo, não exaustivo — sempre que uma questão afirmar que a lista é "taxativa" ou "exaustiva", desconfie.

PEGADINHA:
A perseguição contumaz por telefone/e-mail de José contra Ana, embora não seja o cerne do que a questão testa, de fato se enquadra perfeitamente em violência psicológica (art. 7º, II) — o erro do item não está em dizer que "o caso dá azo à aplicação da medida" (isso está correto), mas em afirmar que o rol do art. 7º é taxativo.` },

{ tecId: 3021691, cadernoNumero: 337, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo INDEPENDEM de orientação sexual — a alternativa inverte essa regra ao afirmar que "dependem".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, I (unidade doméstica).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, III (relação íntima de afeto, independentemente de coabitação).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, II (família).

BIZU DE PROVA:
"Independem de orientação sexual" é a redação exata do parágrafo único do art. 5º — qualquer alternativa que inverta para "dependem" está automaticamente errada.` },

{ tecId: 3014724, cadernoNumero: 338, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 2-1-3: psicológica (2) corresponde a "dano emocional e diminuição da autoestima... degradar ou controlar suas ações" (art. 7º, II); física (1) corresponde a "ofenda sua integridade ou saúde corporal" (art. 7º, I); moral (3) corresponde a "calúnia, difamação ou injúria" (art. 7º, V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência "1-3-2" atribui física ao primeiro item (deveria ser psicológica) e moral ao segundo (deveria ser física).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "2-3-1" acerta o primeiro item (psicológica), mas troca física e moral nos itens seguintes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "3-2-1" inverte totalmente a ordem correta.

BIZU DE PROVA:
Dano emocional/autoestima/controle = psicológica; integridade/saúde corporal = física; calúnia/difamação/injúria = moral. Monte essa associação antes de tentar casar a sequência numérica.` },

{ tecId: 3007260, cadernoNumero: 341, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As quatro lacunas são preenchidas, respectivamente, por psicológica (definição literal do art. 7º, II), sexual (definição literal do art. 7º, III), moral (definição literal do art. 7º, V) e patrimonial (definição literal do art. 7º, IV) — a alternativa C reproduz corretamente essa sequência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa "moral", "espiritual", "psicológica" e "parental" nessa ordem — não corresponde às definições literais apresentadas (a primeira definição, por exemplo, é de psicológica, não moral; "espiritual" e "parental" nem sequer são modalidades da Lei).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Usa termos inventados ("sentimental", "criminosa", "injuriosa", "transpessoal") que não são modalidades nomeadas pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Usa termos inventados ("virtual", "militar", "profissional", "civil") que não são modalidades nomeadas pela Lei.

BIZU DE PROVA:
Cada definição do art. 7º é bastante característica — decore as palavras-chave (emocional/autoestima=psicológica; contraceptivo/gravidez/aborto/prostituição=sexual; calúnia/difamação/injúria=moral; objetos/bens/documentos=patrimonial) para preencher lacunas com segurança, mesmo em questões longas como esta.` },

{ tecId: 3509833, cadernoNumero: 342, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Perseguição contumaz, ridicularização e manipulação são todos meios expressamente listados no art. 7º, II, como formas de violência psicológica — os três itens estão corretos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas o item I, mas os itens II e III também são meios de violência psicológica citados no art. 7º, II.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas o item III, mas os itens I e II também estão corretos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item I, que também é meio de violência psicológica citado no art. 7º, II.

BIZU DE PROVA:
O art. 7º, II, lista um rol extenso de meios (ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração, limitação do direito de ir e vir) — vale a pena memorizar essa lista inteira, pois costuma ser cobrada meio a meio.` },

{ tecId: 2826549, cadernoNumero: 345, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As asserções I e II são ambas falsas. A asserção I erra ao trocar "convívio permanente" por "convívio temporário" — o art. 5º, I, exige convívio permanente. A asserção II erra ao dizer que os laços que unem a família são "naturais, exceto por afinidade" — o art. 5º, II, inclui expressamente a afinidade e a vontade expressa como bases válidas, ao lado dos laços naturais, sem excluir nenhuma delas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera a asserção I falsa e a II verdadeira — mas a II também está errada, pelo motivo acima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera as duas verdadeiras e a II complemento da I — nenhuma das duas é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a asserção I verdadeira — mas ela é falsa, pelo motivo acima.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas verdadeiras — nenhuma das duas é verdadeira.

BIZU DE PROVA:
Unidade doméstica = convívio PERMANENTE (nunca temporário). Família = laços naturais, por afinidade OU por vontade expressa (nunca "exceto por afinidade" ou qualquer outra exclusão) — essas duas trocas de palavra são armadilhas muito recorrentes.` },

{ tecId: 2826587, cadernoNumero: 346, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, caput, combinado com o inciso III — configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, em qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — exatamente a situação de Camila e Rafael, ex-namorados que não coabitam.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não se limita a agressões físicas — o art. 7º prevê expressamente as modalidades psicológica, sexual, patrimonial e moral também.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não exige casamento legal — o art. 5º, III, alcança qualquer relação íntima de afeto, incluindo namoro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º, III, inclui expressamente quem "tenha convivido" com a ofendida — situações passadas estão cobertas, não apenas relações atuais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não se limita a violência sexual — abrange as demais modalidades do art. 7º.

BIZU DE PROVA:
Ameaças pós-término de namoro, mesmo sem coabitação, configuram violência doméstica: "conviva ou tenha convivido... independentemente de coabitação" (art. 5º, III) é a frase-chave que resolve esse tipo de questão.` },

{ tecId: 3532980, cadernoNumero: 347, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente o art. 5º, III — em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) com o rótulo errado "violência patrimonial", e ainda trata isso como um "âmbito" — calúnia/difamação/injúria é modalidade de violência, não âmbito de incidência.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui à "família" a definição de unidade doméstica (art. 5º, I: "espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas") — rótulo trocado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribui à "unidade doméstica" a definição de família (art. 5º, II: "comunidade formada por indivíduos que são ou se consideram aparentados...") — rótulo trocado, espelhando o erro da alternativa B.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mistura a definição de violência psicológica (art. 7º, II) com o rótulo errado "violência física", e trata isso como "âmbito" quando psicológica é modalidade, não âmbito.

BIZU DE PROVA:
As alternativas B e C trocam entre si as definições de "unidade doméstica" e "família" — leia com atenção redobrada quando duas opções parecerem "espelhadas": normalmente uma delas trocou os rótulos.` },

{ tecId: 3575952, cadernoNumero: 349, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não moral.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. Uma das associações mais cobradas em provas objetivas sobre a Lei Maria da Penha.` },

{ tecId: 2983066, cadernoNumero: 350, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Caluniar, difamar e injuriar Joana é exatamente a conduta definida pelo art. 7º, V, como violência moral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de retenção, subtração ou destruição de bens/valores — a conduta narrada é de ataque à honra, não patrimonial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Calúnia, difamação e injúria são especificamente tipificadas pela Lei como violência moral (art. 7º, V) — não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de agressão física.

BIZU DE PROVA:
O próprio enunciado já nomeia as três condutas que definem violência moral (calúnia, difamação, injúria) — quando isso acontece, a resposta é sempre "moral" (art. 7º, V), mesmo que a pergunta pareça simples demais.` },

{ tecId: 2983038, cadernoNumero: 351, explicacao: `GABARITO: CERTO

POR QUE:
Impedir a mulher de usar métodos contraceptivos é conduta expressamente descrita no art. 7º, III, como violência sexual. A relação entre Ana e Antônio, marido e mulher, se enquadra no âmbito da relação íntima de afeto e/ou da família (art. 5º, II e III) — a eventual proibição de Antônio configura, sim, violência doméstica e familiar contra Ana, na modalidade sexual.

BIZU DE PROVA:
"Impedir uso de método contraceptivo" é um dos exemplos mais literais e diretos do art. 7º, III — sempre que aparecer esse tema (contracepção, gravidez, aborto, prostituição forçada), pense em violência sexual.

PEGADINHA:
O caso apresenta um núcleo familiar extenso (Maria, João, Antônio, Ana, Júlio) — não se distraia com os demais personagens; o item pergunta especificamente sobre Ana e Antônio, marido e mulher entre si.` },

{ tecId: 2983032, cadernoNumero: 352, explicacao: `GABARITO: CERTO

POR QUE:
Reter e destruir os documentos pessoais de Maria é conduta expressamente descrita no art. 7º, IV, como violência patrimonial. Sendo Maria casada com João, a relação se enquadra no âmbito familiar/da relação íntima de afeto (art. 5º, II e/ou III) exigido pela Lei.

BIZU DE PROVA:
"Retenção... de documentos pessoais" é termo literal do art. 7º, IV — documento pessoal retido ou destruído por familiar/cônjuge é sempre patrimonial, independentemente do valor financeiro do documento em si.

PEGADINHA:
Assim como no item anterior sobre este mesmo caso (caderno 351), não se distraia com o núcleo familiar extenso — o item pergunta especificamente sobre Maria e João, marido e mulher entre si.` },

{ tecId: 3595916, cadernoNumero: 354, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A asserção I é verdadeira — reproduz literalmente o art. 6º (a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos). A asserção II é falsa — a Lei Maria da Penha não estabelece que os direitos das mulheres estão "acima de todos os demais direitos"; a proteção da mulher em situação de violência doméstica coexiste com os demais direitos e princípios do ordenamento jurídico, sem instituir uma hierarquia absoluta desse tipo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera a asserção I falsa — mas ela reproduz literalmente o art. 6º, sendo verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a asserção II verdadeira e ainda uma justificativa da I — a II é falsa, pelo motivo acima, e por isso não pode justificar nada.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera a asserção II verdadeira — ela é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas falsas — a I é verdadeira (art. 6º).

BIZU DE PROVA:
Cuidado com asserções do tipo "PORQUE" que generalizam de forma absoluta ("acima de todos os demais direitos", "sempre", "em qualquer hipótese") — esse tipo de afirmação extrema raramente corresponde ao texto real da Lei, mesmo quando a primeira asserção (mais moderada) está correta.` },

{ tecId: 2968027, cadernoNumero: 355, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Violência psicológica é modalidade expressamente prevista no art. 7º, II, da Lei 11.340/2006.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência imoral" não é o nome usado pela Lei — o termo correto é "violência moral" (art. 7º, V).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência matrimonial" não é modalidade nomeada pela Lei — o termo correto para bens/valores é "violência patrimonial" (art. 7º, IV).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência ortopédica" não é modalidade nomeada pela Lei nem conceito jurídico correspondente.

BIZU DE PROVA:
Termos parecidos com os nomes reais das modalidades — "imoral" (moral), "matrimonial" (patrimonial) — são pegadinha clássica de trocadilho sonoro; "ortopédica" é claramente inventado, mas serve para eliminar quem não está prestando atenção.` },

{ tecId: 3595917, cadernoNumero: 356, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O marido de Amélia quebrou o celular dela e gastou o dinheiro da conta bancária dela sem autorização — condutas que se enquadram na definição de violência patrimonial (art. 7º, IV: destruição de objeto e subtração de valores/recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência afetiva" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Embora as condutas narradas certamente causem sofrimento psicológico a Amélia, elas se enquadram mais precisamente na definição específica de violência patrimonial (destruição de objeto + subtração de valores), que é o que a Lei nomeia especificamente para esse tipo de conduta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

BIZU DE PROVA:
Quebrar objeto + gastar/subtrair dinheiro da vítima sem autorização = patrimonial, de forma bem direta — mesmo quando a narrativa é emocionalmente carregada (relato de denúncia na delegacia), identifique a conduta OBJETIVA descrita para classificar a modalidade.` },

{ tecId: 3596067, cadernoNumero: 357, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O relato descreve agressão física direta ("bateram nele", "ele estava por cima de mim, me batendo") — conduta que ofende a integridade corporal da vítima, configurando violência física (art. 7º, I).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência emocional" não é o nome usado pela Lei para nenhuma modalidade — o relato, de todo modo, descreve agressão física, não apenas dano emocional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta patrimonial (bens, objetos, valores).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência afetiva" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de conduta sexual.

BIZU DE PROVA:
Relatos com verbos de agressão corporal direta (bater, empurrar, segurar à força) = física, quase sempre a resposta mais imediata quando não há outro elemento (patrimonial, sexual) descrito.` },

{ tecId: 2966706, cadernoNumero: 359, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Reproduz, de forma completa e literal, a definição de violência psicológica do art. 7º, II: conduta que causa dano emocional e diminuição da autoestima, controla ações, comportamentos, opiniões e decisões, por meio de ameaça, constrangimento, humilhação, dentre outros.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa a expressão "violação de intimidação" (assim mesmo redigida no enunciado original, preservada sem correção), que não corresponde ao termo legal "violação de sua intimidade" do art. 7º, II. Mesmo interpretada de forma benevolente, a alternativa oferece apenas um exemplo pontual, e não a definição completa de violência psicológica pedida pelo enunciado ("define corretamente").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III — impedir uso de contraceptivo, forçar a matrimônio/gravidez/aborto/prostituição), oferecida como opção para a pergunta sobre psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV — retenção/subtração/destruição de objetos, bens, valores), oferecida como opção para a pergunta sobre psicológica.

BIZU DE PROVA:
Quando o enunciado pede a definição COMPLETA de uma modalidade ("define corretamente"), prefira sempre a alternativa que reproduz o texto integral do artigo, não um exemplo isolado ou uma conduta específica — mesmo que essa conduta específica também estivesse tecnicamente correta se bem redigida.` },

{ tecId: 3630576, cadernoNumero: 360, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 7º, III, define violência sexual como, entre outras condutas, a que force a mulher "ao matrimônio, à gravidez, AO ABORTO ou à prostituição, mediante coação, chantagem, suborno ou manipulação" — forçar Julia a abortar se enquadra literalmente nesse dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Embora a conduta cause evidente sofrimento psicológico a Julia, a Lei tipifica especificamente "forçar ao aborto" como uma das condutas de violência SEXUAL (art. 7º, III), não psicológica — é a classificação legal mais precisa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Julia por meios diversos da coação para o aborto forçado, que a Lei classifica especificamente como sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de conduta sobre bens, objetos ou valores.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

BIZU DE PROVA:
"Forçar ao matrimônio, à gravidez, ao aborto ou à prostituição" é trecho literal do art. 7º, III — mesmo em cenários emocionalmente carregados, quando a conduta se encaixar textualmente nesse trecho, a classificação legal é sempre violência sexual.` },

{ tecId: 2962308, cadernoNumero: 361, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é 3-1-1-2: calúnia/difamação/injúria (3, moral); dano emocional/diminuição da autoestima (1, psicológica); perturbar o pleno desenvolvimento/degradar ou controlar ações (1, psicológica); retenção de objetos/instrumentos de trabalho/documentos (2, patrimonial).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "1-1-2-3" atribui psicológica ao primeiro item (calúnia/difamação/injúria), quando deveria ser moral (3).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "3-1-2-3" acerta os dois primeiros itens, mas atribui patrimonial (2) ao terceiro item (que é psicológica, 1) e moral (3) ao quarto (que é patrimonial, 2).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "2-1-2-3" atribui patrimonial ao primeiro item (calúnia/difamação/injúria), quando deveria ser moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência "1-3-3-2" atribui psicológica ao primeiro item e moral ao segundo e terceiro — todos trocados em relação ao correto.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral (3); dano emocional/autoestima/degradar-controlar = psicológica (1, aparece duas vezes nesta questão, em exemplos diferentes da mesma modalidade); retenção de objetos/instrumentos/documentos = patrimonial (2). Repare que "psicológica" pode aparecer mais de uma vez na sequência, pois o art. 7º, II, tem uma definição longa com vários elementos.` },

];
