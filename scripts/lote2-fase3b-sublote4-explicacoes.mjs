// LOTE 2 — FASE 3B — SUB-LOTE 4: explicações pedagógicas completas para as
// 37 questões novas de Lei Maria da Penha do sub-lote 4 (cadernoNumero
// 362-414), fonte exclusiva: scratchpad/fase3b_sublote4_conteudo.json,
// extraído de scratchpad/lote2_fase3a_candidatas_limpas_521.json (520
// registros, estado atualizado após sub-lotes 1, 2 e 3).
//
// Mesmo padrão pedagógico dos sub-lotes anteriores: GABARITO / POR QUE A
// ALTERNATIVA <letra> ESTÁ CORRETA|INCORRETA / BIZU DE PROVA; para
// Certo/Errado: GABARITO: CERTO|ERRADO / POR QUE: / BIZU DE PROVA: /
// PEGADINHA:.
//
// Reaudit pedido pelo usuário: cada gabarito foi reauditado durante a
// escrita contra legislação/jurisprudência vigente em 2026. Nenhuma
// questão precisou ser removida por ambiguidade real neste sub-lote.
//
// Achado que exigiu verificação externa antes de aceitar o gabarito
// (caderno 366, tecId 2955256): a alternativa E oferecia uma afirmação
// sobre fixação de indenização mínima por dano moral (art. 387, IV, CPP)
// que, à primeira vista, parecia tão correta quanto o gabarito D,
// arriscando uma ambiguidade real como a encontrada na questão 225 do
// sub-lote 1. Verificação (WebSearch) confirmou que o STJ, no Tema
// Repetitivo 983 (REsp 1.643.051-MS), fixou entendimento específico para
// violência doméstica: a indenização mínima é cabível com pedido expresso,
// "AINDA QUE NÃO ESPECIFICADA A QUANTIA" e "INDEPENDENTEMENTE DE INSTRUÇÃO
// PROBATÓRIA" (dano psíquico in re ipsa). A alternativa E exige o oposto
// (quantia especificada + instrução probatória), contrariando o Tema 983 —
// portanto E está errada, e D permanece a única correta. Sem necessidade
// de reclassificação.
//
// Ressalvas (VALIDA_COM_RESSALVA) -- 3 questões, todas com motivo JÁ
// persistido na fonte (Fase 2, auditorias originais dos sub-lotes 4/5) --
// reaproveitados tal como registrados:
//   - 369 (tecId 2847969): lista fechada das 5 modalidades clássicas sem
//     hedge -- nota sobre a violência vicária (Lei 15.384/2026), gabarito
//     não muda.
//   - 394 (tecId 2718877): artefato de OCR (numerais romanos II/III lidos
//     como "Il"/"llI") -- já normalizado na Fase 3A sem resíduo; sem
//     ressalva jurídica.
//   - 407 (tecId 3057596): artefato de extração "escola d" solto no
//     enunciado, antes de "violência doméstica" -- confirmado via grep no
//     .txt bruto (supabase/_lote2_txt/caderno_401 ao 600.txt, linha 112)
//     como texto genuíno extraído do PDF (provável deslocamento de
//     fragmento por erro de coluna na extração), preservado sem alteração;
//     não afeta o conteúdo jurídico nem o gabarito (E, patrimonial).
//
// Ponto de atenção resolvido sem ressalva formal: a questão 386 (Certo/
// Errado) parafraseia o art. 5º, caput, omitindo tanto "baseada no gênero"
// quanto a exigência de ocorrência em um dos três âmbitos do art. 5º. A
// omissão não introduz nenhuma afirmação falsa (não nega o critério de
// gênero nem afirma o oposto) -- é paráfrase incompleta, não errada -- por
// isso o gabarito Certo se mantém, com nota explicativa na explicação.

export const explicacoes = [

{ tecId: 3630969, cadernoNumero: 362, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Física" é a modalidade cuja definição legal é "qualquer conduta que ofenda sua integridade ou saúde corporal" (art. 7º, I, da Lei 11.340/2006) — exatamente o texto do trecho apresentado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Espiritual" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Corporal" descreve o que é ofendido pela violência física (a saúde/integridade CORPORAL), mas não é o nome da modalidade — o nome correto é "física".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência moral (art. 7º, V) é definida como calúnia, difamação ou injúria — não como ofensa à integridade/saúde corporal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não corresponde ao trecho apresentado.

BIZU DE PROVA:
"Corporal" é uma pegadinha inteligente — soa relacionado (a definição de física menciona "saúde corporal"), mas não é o NOME da modalidade. Sempre responda com o nome oficial: física, psicológica, sexual, patrimonial, moral (ou vicária, desde 2026).` },

{ tecId: 2955765, cadernoNumero: 364, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a afirmativa INCORRETA, pedida pelo enunciado):
Atribui à violência patrimonial a definição que, na verdade, é da violência MORAL (art. 7º, V — calúnia, difamação ou injúria). A definição de violência patrimonial (art. 7º, IV) trata de retenção, subtração ou destruição de objetos, bens, valores e recursos econômicos — nada disso é mencionado na alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente a definição de violência física do art. 7º, I.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 6º da Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, caput, da Lei.

BIZU DE PROVA:
Mais uma vez o mislabeling clássico entre patrimonial e moral — sempre que "calúnia, difamação ou injúria" aparecer rotulado como "patrimonial" (ou qualquer modalidade que não seja "moral"), a alternativa está errada.` },

{ tecId: 3682521, cadernoNumero: 365, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (apenas o item IV está correto):
Maria sofre violência psicológica (o pai a insulta e humilha diariamente — art. 7º, II), violência patrimonial (o pai danifica e joga fora seu celular e material escolar — art. 7º, IV) e violência moral (o pai a difama periodicamente na vizinhança — art. 7º, V). O agressor é o pai de Maria, e a relação de parentesco (pai e filha) se enquadra no âmbito da família (art. 5º, II) — a Lei Maria da Penha se aplica a Maria mesmo sendo ela adolescente de 14 anos, pois protege vítima do gênero feminino em violência doméstica e familiar independentemente da idade (Tema Repetitivo 1.186 do STJ).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (considera apenas o item II, que é falso):
O item II está errado — o pai de Maria pratica, sim, violência doméstica e familiar, no âmbito da família (art. 5º, II: comunidade formada por indivíduos que são ou se consideram aparentados por laços naturais). Não é necessário haver "relação íntima de afeto" (art. 5º, III) quando já está configurado o âmbito da família — os três âmbitos do art. 5º são alternativos entre si, não cumulativos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (considera apenas o item III, que é falso):
O item III está errado pelo mesmo motivo: ser pai de Maria não exclui a aplicação da Lei — é justamente o vínculo de parentesco que configura o âmbito da família (art. 5º, II). O caso não se resume a "tratamento cruel ou degradante"; configura violência doméstica e familiar nos termos específicos da Lei Maria da Penha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (considera apenas o item II, que é falso pelo motivo já exposto):
Mesma razão da alternativa A.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (considera apenas o item I, que é falso):
O item I está errado ao dizer que Maria sofre EXCLUSIVAMENTE violência psicológica — ela também sofre violência patrimonial (celular e material escolar destruídos) e moral (difamação na vizinhança), como descreve corretamente o item IV.

BIZU DE PROVA:
Os três âmbitos do art. 5º (unidade doméstica, família, relação íntima de afeto) são independentes entre si — não ter "relação íntima de afeto" com o agressor não afasta a Lei quando há vínculo familiar. E a Lei Maria da Penha protege vítima do gênero feminino em violência doméstica e familiar mesmo quando ela é criança ou adolescente (Tema 1.186/STJ) — nunca conclua que a idade da vítima, por si só, afasta a aplicação da Lei.` },

{ tecId: 2955256, cadernoNumero: 366, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Lei Maria da Penha pode incidir na agressão entre irmãos, pois "família" (art. 5º, II) é definida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa — irmãos são aparentados por laços naturais, independentemente de coabitação atual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda a substituição da pena por pagamento ISOLADO de multa ou por prestação pecuniária/cesta básica, mas a afirmação de que a substituição por restritiva de direitos em geral "não é impedida" é excessivamente ampla — muitos crimes praticados em contexto de violência doméstica envolvem violência ou grave ameaça à pessoa, o que já impede a substituição por restritiva de direitos pela regra geral do art. 44, I, do Código Penal, independentemente do art. 17 da Lei Maria da Penha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para a configuração da violência doméstica em relação íntima de afeto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A competência do Juizado de Violência Doméstica não é afastada pela condição de "figura pública" da vítima — a Lei não estabelece essa exceção, e a proteção decorre da relação entre agressor e vítima (um dos âmbitos do art. 5º), não de uma análise casuística de vulnerabilidade social da ofendida.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Contraria o entendimento do STJ no Tema Repetitivo 983 (REsp 1.643.051-MS): nos casos de violência doméstica, a fixação de indenização mínima por dano moral é cabível com pedido expresso da acusação ou da ofendida, MAS dispensa tanto a instrução probatória específica quanto a especificação da quantia, por se tratar de dano psíquico in re ipsa (presumido pela própria natureza da agressão). A alternativa exige justamente o que o STJ dispensou, invertendo a regra.

BIZU DE PROVA:
"Família" (art. 5º, II) alcança qualquer parentesco por laços naturais, afinidade ou vontade expressa — inclui irmãos, pais, filhos, sogros etc., não apenas cônjuges/companheiros. E sobre indenização mínima em violência doméstica: pedido expresso é necessário, mas quantia especificada e instrução probatória são DISPENSÁVEIS (Tema 983/STJ, dano in re ipsa) — decore essa dispensa dupla, é armadilha recorrente.

Fontes: [Fixação do valor mínimo para reparação dos danos prevista no art. 387, IV, do CPP](https://buscadordizerodireito.com.br/jurisprudencia/5588/fixacao-do-valor-minimo-para-reparacao-dos-danos-prevista-no-art-387-iv-do-cpp); [STJ — Condenação por violência doméstica contra a mulher pode incluir dano moral mínimo mesmo sem prova específica](https://www.stj.jus.br/sites/portalp/Paginas/Comunicacao/Noticias-antigas/2018/2018-03-02_11-25_Condenacao-por-violencia-domestica-contra-a-mulher-pode-incluir-dano-moral-minimo-mesmo-sem-prova-especifica.aspx)` },

{ tecId: 2941057, cadernoNumero: 368, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (I e II estão incorretas):
O item I rotula como "violência física" um texto que mistura o início da definição de física ("ofenda sua integridade") com quase toda a definição de violência PSICOLÓGICA (dano emocional, diminuição da autoestima, degradar ou controlar mediante ameaça, humilhação etc., art. 7º, II) — está incorreto. O item II rotula como "violência patrimonial" a definição de violência SEXUAL (constranger a presenciar/manter relação sexual não desejada, impedir contraceptivo, forçar a matrimônio/gravidez/aborto/prostituição, art. 7º, III) — também está incorreto. O item III, por sua vez, reproduz corretamente a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) — está correto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item III como incorreto, mas ele está corretamente definido (moral = calúnia, difamação, injúria).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item III como incorreto, mas ele está correto; os itens I e II é que estão incorretos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item III como incorreto (ele está correto) e omite o item I (que está incorreto).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera os três itens incorretos, mas o item III está corretamente definido.

BIZU DE PROVA:
O item I desta questão é uma pegadinha "híbrida" rara: começa com a definição de física e termina com quase toda a definição de psicológica — leia a definição INTEIRA antes de decidir se o rótulo bate, não pare na primeira frase.` },

{ tecId: 2847969, cadernoNumero: 369, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"A psicológica, a sexual, a física, a moral e a patrimonial" são as cinco formas de violência doméstica e familiar então nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006. (Ressalva: lista fechada das 5 modalidades clássicas, sem hedge "entre outras"/"algumas" — esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a alternativa A permanece a única plausível entre as opções dadas, pois nenhuma das demais seria corrigida pela adição da vicária — todas têm defeitos independentes dessa contagem.)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Contraria diretamente o art. 6º, que reconhece a violência doméstica como uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 8º, caput, estabelece que a política pública é realizada por um conjunto articulado de ações da União, dos Estados, do Distrito Federal, dos Municípios e de ações não governamentais — não apenas pelos municípios.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atribui à violência moral a definição de violência física (ofensa à integridade física, art. 7º, I) — mislabeling clássico; moral é calúnia, difamação ou injúria (art. 7º, V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 25 da Lei estabelece que o Ministério Público intervirá, quando não for parte, nos processos que envolvam violência doméstica e familiar contra a mulher.

BIZU DE PROVA:
Memorize os cinco nomes exatos usados pela Lei até 2026: psicológica, sexual, física, moral e patrimonial (hoje, seis, com a vicária). E lembre: o MP tem papel ativo na Lei Maria da Penha, nunca é excluído dos processos.` },

{ tecId: 2932376, cadernoNumero: 372, explicacao: `GABARITO: ERRADO

POR QUE:
A Lei Maria da Penha não se limita a mulheres legalmente casadas ou em união estável. O art. 5º, III, estende a proteção a qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — abrangendo namoro, relacionamentos informais e até relações já encerradas.

BIZU DE PROVA:
"Relação íntima de afeto" (art. 5º, III) é o âmbito mais amplo da Lei — não exige casamento, união estável, coabitação ou relação atual.

PEGADINHA:
A palavra "somente" costuma ser a pista de que a afirmativa está restringindo indevidamente o alcance da Lei — sempre que aparecer, verifique se a Lei realmente impõe essa restrição (quase nunca impõe).` },

{ tecId: 2932194, cadernoNumero: 373, explicacao: `GABARITO: ERRADO

POR QUE:
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual. A jurisprudência do STJ e do STF confirma a aplicação da Lei também a relações homoafetivas, entre mulheres ou entre homens.

BIZU DE PROVA:
"Independem de orientação sexual" (parágrafo único do art. 5º) é um dos pontos mais cobrados da parte introdutória da Lei — qualquer afirmativa que restrinja a proteção a relações heterossexuais está errada.

PEGADINHA:
A palavra "exclusiva" segue o mesmo padrão de "somente"/"apenas" — sinaliza uma restrição indevida ao alcance da Lei.` },

{ tecId: 2932188, cadernoNumero: 374, explicacao: `GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 reconhece expressamente cinco formas de violência doméstica e familiar (física, psicológica, sexual, patrimonial e moral) e, desde a Lei 15.384/2026, uma sexta (vicária) — a violência física é apenas uma delas, não a única.

BIZU DE PROVA:
Sempre que uma afirmativa disser que apenas UMA modalidade é "reconhecida legalmente", desconfie — a Lei nomeia, no mínimo, cinco (hoje, seis).

PEGADINHA:
"A única forma" é a expressão-chave que denuncia o erro — a Lei Maria da Penha é conhecida justamente por reconhecer múltiplas formas de violência, não só a física.` },

{ tecId: 2847886, cadernoNumero: 375, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Violência sexual é modalidade expressamente prevista no art. 7º, III, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência procedimental" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência amiga" não é modalidade nomeada pela Lei nem expressão jurídica reconhecida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência governamental" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência institucional" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
Entre nomes inventados e o único nome real oferecido (sexual), a resposta é sempre o nome real — memorizar os seis nomes oficiais (física, psicológica, sexual, patrimonial, moral, vicária) é a defesa mais segura contra esse tipo de pegadinha.` },

{ tecId: 2924320, cadernoNumero: 376, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Camila proferiu palavras de baixo calão contra Ana, humilhando-a verbalmente — conduta que se enquadra no art. 7º, II (humilhação, insulto), configurando violência psicológica. A relação homoafetiva entre Ana e Camila está plenamente abrangida pela Lei, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ/STF.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O fato de o casal ser homoafetivo não afasta a caracterização de violência contra a mulher — o parágrafo único do art. 5º garante expressamente essa aplicação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A "mera altercação verbal" pode, sim, constituir violência doméstica — humilhação e insulto são meios expressamente listados no art. 7º, II, independentemente de agressão física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A embriaguez voluntária (Camila estava "em estado alterado de consciência" por ter bebido) não é causa de exclusão da responsabilidade no direito penal brasileiro — o art. 28, II, do Código Penal é expresso ao dizer que a embriaguez voluntária ou culposa pelo álcool não exclui a imputabilidade penal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A dependência do álcool, por si só, não torna a pessoa incapaz para todos os efeitos de direito — a incapacidade civil exige processo específico (interdição) com base em critérios próprios do Código Civil, não decorrendo automaticamente do alcoolismo.

BIZU DE PROVA:
Embriaguez voluntária NUNCA exclui a responsabilidade penal no Brasil (art. 28, II, CP) — só a embriaguez completamente fortuita/acidental, que retire por completo a capacidade de entendimento, pode ter efeito diferente, e mesmo assim depende de laudo específico. Não confunda "estava bêbado(a)" com "não teve culpa".` },

{ tecId: 2919563, cadernoNumero: 379, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz de forma completa e corretamente rotulada a definição de violência sexual do art. 7º, III — a única alternativa em que o nome da modalidade corresponde à sua definição legal real.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência física" a definição completa de violência PSICOLÓGICA (dano emocional, diminuição da autoestima, degradar/controlar mediante ameaça, humilhação, isolamento etc., art. 7º, II).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de violência FÍSICA (ofender integridade ou saúde corporal, art. 7º, I) — invertendo o erro da alternativa A.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Rotula como "violência patrimonial" a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Rotula como "violência moral" a definição de violência PATRIMONIAL (retenção, subtração, destruição de objetos, bens, valores e recursos econômicos, art. 7º, IV).

BIZU DE PROVA:
Todas as cinco alternativas trazem definições REAIS da Lei, mas quatro delas com o rótulo TROCADO — e as trocas nem sempre são "vizinhas" (física↔psicológica, moral↔patrimonial). Leia a definição inteira e identifique a qual modalidade ela pertence ANTES de olhar o rótulo proposto.` },

{ tecId: 2910137, cadernoNumero: 380, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Carlos publica nas redes sociais acusações contra Paula (gastar o salário em bares, voltar bêbada), buscando expor negativamente sua imagem perante terceiros após o fim do casamento — conduta que se enquadra na definição de violência moral (art. 7º, V), especificamente na modalidade de difamação (imputar fato ofensivo à reputação perante outras pessoas).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O texto é internamente inconsistente: rotula a conduta como "psicológica", mas a caracteriza como "calúnia" — calúnia é termo que define violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência virtual" não é modalidade nomeada pela Lei Maria da Penha — o meio pelo qual a violência ocorre (redes sociais) não altera sua classificação legal como uma das modalidades do art. 7º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Carlos não está retendo, subtraindo ou destruindo bens/valores de Paula — está fazendo uma acusação pública sobre o uso que ela faz do próprio salário, o que configura ataque à reputação (moral), não controle patrimonial efetivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência de gênero" é o conceito sociológico mais amplo que fundamenta toda a Lei, não uma das modalidades específicas do art. 7º; e a conduta de Carlos não é primariamente uma violação de privacidade, mas sim uma exposição pública com conteúdo ofensivo à reputação de Paula.

BIZU DE PROVA:
Publicar em redes sociais acusações que expõem negativamente a reputação da ex-companheira/ex-cônjuge perante terceiros = moral, na forma de difamação (art. 7º, V) — o meio (redes sociais) não muda a modalidade legal, apenas o contexto fático.` },

{ tecId: 2904890, cadernoNumero: 381, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência sexual (art. 7º, III) tem definição própria, sem relação com calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de bens e valores — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência familiar" não é modalidade nomeada pela Lei — "família" é um dos âmbitos de incidência (art. 5º, II), não uma modalidade do art. 7º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. Cuidado para não confundir "família" (âmbito, art. 5º) com uma modalidade de violência (art. 7º) — são conceitos de artigos diferentes.` },

{ tecId: 2898378, cadernoNumero: 383, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a exceção pedida pelo enunciado):
Um prestador de serviço que vai à residência executar um serviço específico e pontual não integra o "espaço de convívio permanente de pessoas" do art. 5º, I — não há vínculo pessoal, familiar ou afetivo entre ele e os moradores, apenas uma relação comercial/profissional eventual, alheia aos três âmbitos de incidência da Lei (unidade doméstica, família, relação íntima de afeto).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um hóspede, mesmo por curto período, se enquadra no conceito de "esporadicamente agregadas" do art. 5º, I — a Lei inclui expressamente essas pessoas no âmbito da unidade doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um irmão que não mais reside na casa continua sendo parente por laços naturais — o âmbito da família (art. 5º, II) não exige coabitação, apenas o vínculo de parentesco.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um ex-companheiro que não mais reside na casa se enquadra no âmbito da relação íntima de afeto (art. 5º, III), que alcança expressamente quem "tenha convivido" com a ofendida, independentemente de coabitação atual.

BIZU DE PROVA:
O critério que distingue a exceção das demais opções é o VÍNCULO PESSOAL: hóspede, irmão e ex-companheiro têm algum tipo de vínculo social, familiar ou afetivo com a vítima (mesmo que não morem mais juntos); o prestador de serviço tem apenas um vínculo comercial pontual, sem qualquer relação pessoal — por isso fica de fora dos três âmbitos do art. 5º.` },

{ tecId: 2842551, cadernoNumero: 384, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
I. Insultar publicamente a esposa, visando causar-lhe humilhação e ridicularização, é violência psicológica (art. 7º, II — insulto, humilhação, ridicularização são meios expressamente listados). II. Difamar a esposa nas mesas de bares é violência moral (art. 7º, V — difamação, imputação de fato ofensivo à reputação perante terceiros). III. Impedir o uso de métodos contraceptivos é violência sexual (art. 7º, III). IV. Reter o cartão de movimentação bancária é violência patrimonial (art. 7º, IV).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência religiosa" não é modalidade nomeada pela Lei — o item I, embora motivado pela religião da vítima, configura violência psicológica pela NATUREZA da conduta (insulto/humilhação), não pelo MOTIVO que a inspirou.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte os itens I e II (psicológica e moral trocadas) e erra o item III, atribuindo-lhe violência física em vez de sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra o item I (deveria ser psicológica, não física) e repete "física" também no item III, quando deveria ser sexual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Repete "psicológica" nos itens I e II (o item II deveria ser moral) e erra o item IV, atribuindo-lhe violência moral em vez de patrimonial.

BIZU DE PROVA:
Insultar/humilhar DIRETAMENTE a vítima = psicológica (mesmo que "publicamente" e mesmo que motivado por preconceito religioso — o motivo não muda a modalidade). Espalhar informação difamatória PARA TERCEIROS (nas mesas de bares, por exemplo) = moral. Essa distinção entre "insulto direto" e "difamação para terceiros" é a chave de várias questões deste tipo.` },

{ tecId: 2859577, cadernoNumero: 385, explicacao: `GABARITO: CERTO

POR QUE:
A afirmativa combina corretamente as consequências do art. 5º, caput (sofrimento psicológico, lesão, morte, dano moral ou patrimonial) com os três âmbitos de incidência dos incisos I a III (unidade doméstica, família, relação íntima de afeto), e ainda reforça corretamente que a violência doméstica "não se limita ao ambiente físico" — reconhecendo, portanto, outras formas de violência além da física.

BIZU DE PROVA:
Esta é uma das raras questões que reúne, de forma completa e correta, TODOS os elementos centrais do art. 5º em uma única frase — útil para revisar a estrutura inteira do artigo de uma vez.

PEGADINHA:
Não há pegadinha aqui — é uma afirmativa completa e tecnicamente correta, mas fique atento: questões parecidas costumam inserir pequenas restrições indevidas (como exigir coabitação ou vínculo de casamento) que não aparecem neste item.` },

{ tecId: 2859690, cadernoNumero: 386, explicacao: `GABARITO: CERTO

POR QUE:
A afirmativa reproduz, de forma resumida, o núcleo do art. 5º, caput: considera-se violência doméstica e familiar contra a mulher qualquer ação ou omissão que cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Embora a frase omita a exigência de que a conduta seja "baseada no gênero" e a ocorrência dentro de um dos três âmbitos do art. 5º (incisos I a III), essa omissão não introduz nenhuma afirmação falsa — o item não nega o critério de gênero nem afirma que a Lei se aplica independentemente dele; apenas não o menciona. Por isso, o item é considerado tecnicamente correto, ainda que incompleto.

BIZU DE PROVA:
Em itens Certo/Errado, uma afirmação INCOMPLETA (que omite elementos, sem afirmar nada de errado em seu lugar) geralmente continua sendo classificada como Certa — reserve o "Errado" para quando a banca afirmar algo que contraria a Lei. Mas fique atento: se uma questão FUTURA testar exatamente o elemento omitido aqui (a exigência de que a conduta seja "baseada no gênero", ou a necessidade de ocorrer em um dos três âmbitos do art. 5º), a resposta pode mudar — vale memorizar que esses dois elementos também são parte da definição completa.

PEGADINHA:
Esta afirmativa é uma paráfrase incompleta do art. 5º, caput — omite "baseada no gênero" e a exigência do âmbito (unidade doméstica, família ou relação íntima de afeto). Não confunda "incompleto" com "errado": por não afirmar nada de falso, o item permanece Certo, mas fique atento a variações da mesma questão que insiram uma restrição INDEVIDA nesses pontos — aí sim passaria a Errado.` },

{ tecId: 2861901, cadernoNumero: 387, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral, dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria, centrada em dano emocional/diminuição de autoestima — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência emocional" não é modalidade nomeada pela Lei — o efeito "dano emocional" integra a definição de violência psicológica, mas o nome da modalidade é "psicológica".

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. "Emocional" nunca é o nome de uma modalidade — é apenas um dos EFEITOS mencionados na definição de psicológica.` },

{ tecId: 2890074, cadernoNumero: 389, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente o art. 5º, I — no âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Descreve uma situação "sem qualquer relação de afeto" ao mesmo tempo em que menciona convivência entre agressor e ofendida — descrição incoerente que não corresponde a nenhum dos três âmbitos do art. 5º, que exigem justamente algum vínculo (doméstico, familiar ou afetivo).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Âmbito externo familiar" e "comunidade de vizinhos unidos por laços geográficos" não correspondem a nenhum dos três âmbitos do art. 5º — mera proximidade geográfica entre vizinhos não gera, por si só, a incidência da Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Ambiente de trabalho" não é um dos três âmbitos do art. 5º — relações de trabalho sem vínculo familiar ou afetivo entre as partes não se enquadram na Lei Maria da Penha (podem configurar outras figuras, como assédio moral/sexual no trabalho, tratadas por normas distintas).

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica, família e relação íntima de afeto. "Vizinhança" e "ambiente de trabalho", isoladamente, nunca configuram, por si só, nenhum dos três.` },

{ tecId: 2862259, cadernoNumero: 390, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece que a violência contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Direitos políticos" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Direitos penais" não é a expressão usada pelo art. 6º nem categoria jurídica correspondente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Direitos trabalhistas" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Direitos econômicos" não é a expressão usada pelo art. 6º.

BIZU DE PROVA:
Art. 6º: "constitui uma das formas de violação dos direitos humanos" — frase literal, curta e muito cobrada isoladamente.` },

{ tecId: 2840121, cadernoNumero: 391, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é 2-3-1: família (2) corresponde a "comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa" (art. 5º, II); relação íntima de afeto (3) corresponde a "qualquer convivência entre vítima e agressor, independentemente de coabitação" (a expressão "independentemente de coabitação" é a marca distintiva do art. 5º, III); unidade doméstica (1) corresponde a "espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas" (art. 5º, I).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "1-2-3" atribui unidade doméstica à definição de família e família à definição de relação íntima de afeto — nenhuma das duas associações está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência "1-3-2" acerta a segunda posição (relação íntima de afeto), mas erra a primeira e a terceira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "2-1-3" acerta a primeira posição (família), mas troca unidade doméstica e relação íntima de afeto nas posições seguintes.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência "3-2-1" inverte completamente família e relação íntima de afeto nas duas primeiras posições.

BIZU DE PROVA:
"Independentemente de coabitação" é a expressão-chave exclusiva da relação íntima de afeto (art. 5º, III) — sempre que aparecer, associe a essa modalidade, mesmo que a palavra "afeto" não seja repetida na paráfrase.` },

{ tecId: 2877475, cadernoNumero: 392, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Juliana pratica violência psicológica ao perseguir Clarice no local de trabalho (perseguição contumaz, art. 7º, II) e violência moral ao acusá-la falsamente, nas redes sociais, de fazer programas sexuais por dinheiro (imputação de fato ofensivo à reputação perante terceiros, configurando difamação/injúria, art. 7º, V) — as duas modalidades estão claramente presentes e identificáveis no relato.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As relações homoafetivas são, sim, objeto da Lei Maria da Penha, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ e do STF.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, alcança quem "tenha convivido" com a ofendida — o fim do relacionamento não afasta a Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Acerta ao identificar a perseguição (stalking) como presente, mas erra ao classificar a acusação falsa como "violência sexual" — a conduta de acusar falsamente alguém de exercer atividade sexual mediante pagamento é ataque à reputação perante terceiros (violência moral, art. 7º, V), não uma das condutas específicas do art. 7º, III (que trata de constranger a ato sexual, impedir contracepção, forçar matrimônio/gravidez/aborto/prostituição, ou limitar direitos sexuais e reprodutivos).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de pena de cesta básica ou outra prestação pecuniária isolada nos casos de violência doméstica e familiar contra a mulher.

BIZU DE PROVA:
Perseguir a vítima pessoalmente (local de trabalho, redes sociais, ligações) = psicológica ("perseguição contumaz", art. 7º, II). Fazer acusação falsa/ofensiva sobre a vida da vítima para expô-la perante terceiros = moral (difamação/injúria, art. 7º, V) — mesmo quando a acusação tem conteúdo sexual, a classificação legal correta é moral, não sexual, pois o que a Lei chama de "violência sexual" (art. 7º, III) trata de coagir a própria vítima a atos/decisões sexuais, não de fazer afirmações sobre sua vida sexual para terceiros.` },

{ tecId: 2718877, cadernoNumero: 394, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Os itens I, II e III reproduzem literalmente os três âmbitos do art. 5º: I corresponde ao inciso I (unidade doméstica), II corresponde ao inciso II (família), III corresponde ao inciso III (relação íntima de afeto) — todos os três estão corretos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item I, que reproduz corretamente o art. 5º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item III, que reproduz corretamente o art. 5º, III.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item II, que reproduz corretamente o art. 5º, II.

BIZU DE PROVA:
Quando uma questão apresentar os três âmbitos do art. 5º como itens separados, sem nenhuma alteração ao texto legal, o gabarito normalmente confirma todos os três como corretos — os três incisos são alternativos entre si (qualquer um configura violência doméstica), não é preciso que ocorram simultaneamente.` },

{ tecId: 3622849, cadernoNumero: 396, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A primeira lacuna ("espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas") corresponde à unidade doméstica (art. 5º, I). A segunda lacuna ("comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa") corresponde à família (art. 5º, II).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a ordem, atribuindo "família" à primeira lacuna (que é unidade doméstica) e "íntima relação" à segunda (que é família).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui "íntima relação" à primeira lacuna e "unidade doméstica" à segunda — nenhuma das duas corresponde às definições apresentadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte a ordem correta, atribuindo "família" à primeira lacuna e "unidade doméstica" à segunda.

BIZU DE PROVA:
"Convívio permanente, com ou sem vínculo familiar" = unidade doméstica. "Comunidade de aparentados por laços naturais/afinidade/vontade expressa" = família. Essas duas definições costumam ser trocadas entre si — leia com atenção qual delas exige parentesco (família) e qual não exige (unidade doméstica).` },

{ tecId: 3603257, cadernoNumero: 399, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Alan diminui Fernanda perante os amigos ("tola, frágil, sem discernimento"), buscando reduzir seu valor social e desencorajar o interesse de terceiros nela — conduta que a constrange e humilha, levando-a a se isolar do convívio social. Isso se enquadra na definição de violência psicológica do art. 7º, II: dano emocional e diminuição da autoestima, mediante constrangimento e humilhação, que resulta em isolamento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os comentários de Alan são caracterizações depreciativas ditas na presença de amigos com o objetivo de controlar/diminuir Fernanda, não uma acusação falsa ou ofensiva à sua reputação especificamente destinada a expô-la perante terceiros (o que configuraria calúnia, difamação ou injúria — moral, art. 7º, V). O núcleo da conduta é o controle e a diminuição da autoestima de Fernanda, típicos da violência psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Comportamento inadequado" não é categoria da Lei Maria da Penha — a conduta narrada se enquadra especificamente como violência psicológica, com todas as consequências jurídicas e protetivas previstas na Lei.

BIZU DE PROVA:
Diminuir a autoestima e a autoconfiança da vítima diante de outras pessoas, com o objetivo de mantê-la isolada e dependente, é psicológica (art. 7º, II) — mesmo quando dito "com carinho" ou disfarçado de preocupação/ciúme, como no caso de Alan.` },

{ tecId: 3534524, cadernoNumero: 401, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O confisco de documentos pessoais da ofendida pelo agressor é conduta expressamente prevista no art. 7º, IV, como violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, I, admite expressamente a configuração de violência doméstica "com ou sem vínculo familiar" — não é necessário vínculo familiar ou amoroso para a aplicação da Lei, bastando um dos três âmbitos do art. 5º (que incluem, por exemplo, a unidade doméstica mesmo sem parentesco).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Dano emocional e diminuição de autoestima" é a definição de violência PSICOLÓGICA (art. 7º, II), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Calúnia, injúria ou difamação" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei Maria da Penha se aplica, sim, a relações homoafetivas entre mulheres, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ e do STF.

BIZU DE PROVA:
"Confisco/retenção de documentos pessoais" é termo literal do art. 7º, IV — sempre patrimonial, independentemente do valor financeiro do documento retido em si.` },

{ tecId: 3260966, cadernoNumero: 402, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão listados no art. 7º da Lei 11.340/2006 os itens I (física), II (psicológica), III (sexual) e IV (patrimonial) — todas modalidades expressamente nomeadas pelos incisos I a IV. O item V ("violência virtual") não é modalidade nomeada pelo art. 7º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item V (violência virtual), que não é modalidade nomeada pela Lei — o meio virtual pode ser instrumento de diversas modalidades já existentes (psicológica, moral etc.), mas não constitui, por si só, uma modalidade autônoma no art. 7º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item III (violência sexual), que é modalidade expressamente prevista no art. 7º, III, e inclui o item V, que não é.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui os itens II e IV (psicológica e patrimonial), ambas modalidades expressamente previstas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Exclui os itens III e IV (sexual e patrimonial), ambas modalidades expressamente previstas, e inclui o item V, que não é.

BIZU DE PROVA:
"Violência virtual" não é um dos nomes oficiais das modalidades do art. 7º — o ambiente digital é apenas o MEIO pelo qual outras modalidades (psicológica, moral, e, se envolver conteúdo íntimo não consentido, também aspectos ligados à violação de intimidade) podem se manifestar.` },

{ tecId: 3169677, cadernoNumero: 403, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Cause dano emocional e diminuição da autoestima" é o início da definição literal de violência psicológica dada pelo art. 7º, II.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Limite ou anule o exercício de seus direitos sexuais e reprodutivos" integra a definição de violência SEXUAL (art. 7º, III), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Configure calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ofenda sua integridade ou saúde corporal" é a definição de violência FÍSICA (art. 7º, I), não psicológica.

BIZU DE PROVA:
Cada alternativa desta questão é um trecho REAL de uma definição diferente da Lei — a habilidade testada é reconhecer a qual modalidade cada trecho pertence e escolher apenas o que corresponde à psicológica.` },

{ tecId: 3093006, cadernoNumero: 404, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Reproduz de forma completa e corretamente rotulada a definição de violência sexual do art. 7º, III — a única alternativa em que o rótulo corresponde à definição legal real.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência física" a definição de violência PATRIMONIAL (retenção, subtração, destruição de objetos, bens, valores e recursos econômicos, art. 7º, IV).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Rotula como "violência patrimonial" um trecho truncado da definição de violência PSICOLÓGICA ("qualquer conduta que lhe cause dano emocional", art. 7º, II).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Rotula como "violência moral" a definição de violência FÍSICA (ofender integridade ou saúde corporal, art. 7º, I).

BIZU DE PROVA:
Nenhuma das cinco alternativas desta questão usa o rótulo "sexual" incorretamente — a sexual é a única cuja definição completa está corretamente identificada; as outras quatro trocam rótulos entre si sistematicamente.` },

{ tecId: 3062789, cadernoNumero: 406, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 7º, III, define violência sexual como, entre outras condutas, a que force a mulher "ao matrimônio, à gravidez, AO ABORTO ou à prostituição, mediante coação, chantagem, suborno ou manipulação" — forçar uma mulher ao aborto se enquadra literalmente nesse dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Ofensas verbais de cunho sexual em público podem, sim, configurar violência doméstica — dependendo do conteúdo, podem se enquadrar como violência psicológica (humilhação, constrangimento, art. 7º, II) ou moral (calúnia, difamação, injúria, art. 7º, V); a Lei não as exclui.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A ausência de suporte emocional, por si só, é vaga demais para configurar automaticamente uma das modalidades específicas do art. 7º, mas isso não significa que a Lei "não reconheça" formas de violência por omissão — o art. 5º, caput, admite expressamente que a violência doméstica se configure por ação OU omissão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 7º, III, trata especificamente de FORÇAR a mulher ao aborto (contra sua vontade de manter a gravidez) e de impedir o uso de métodos contraceptivos — não trata de impedir a realização de um aborto já desejado pela mulher, que é regulado por outras normas (Código Penal, arts. 124 a 128, sobre as hipóteses em que o aborto é ou não punível no Brasil).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 7º, III, é expresso ao incluir, entre as condutas de violência sexual, impedir a mulher de usar qualquer método contraceptivo — omitir deliberadamente informações sobre métodos contraceptivos, como forma de limitar sua autonomia reprodutiva, também se relaciona a essa mesma proteção (direitos sexuais e reprodutivos), de modo que a Lei não deixa esse tipo de conduta fora de sua proteção.

BIZU DE PROVA:
"Forçar ao matrimônio, à gravidez, ao aborto ou à prostituição" é trecho literal do art. 7º, III — sempre que a conduta narrada for FORÇAR (contra a vontade da mulher) uma dessas quatro situações, a classificação é violência sexual.` },

{ tecId: 3057596, cadernoNumero: 407, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O companheiro de Janice retinha o salário dela para pagar as próprias despesas com bebida alcoólica — conduta que se enquadra na definição de violência patrimonial (art. 7º, IV: retenção de valores/recursos econômicos destinados a satisfazer as necessidades da ofendida).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de dano emocional específico, degradação ou controle de comportamento além da retenção do salário — a conduta central e objetivamente descrita é a apropriação do dinheiro de Janice, que a Lei classifica especificamente como patrimonial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Janice.

BIZU DE PROVA:
Reter o salário/dinheiro da vítima para gastar com as próprias despesas (inclusive vícios, como no caso do bar) é violência patrimonial, mesmo que o relato também sugira sofrimento — a Lei classifica pela NATUREZA objetiva da conduta (apropriação de recursos econômicos), não apenas pelo sofrimento emocional que ela também pode causar.` },

{ tecId: 3000783, cadernoNumero: 408, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz de forma completa e literal a definição de violência psicológica do art. 7º, II — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações/comportamentos/crenças/decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura o início da definição de violência MORAL ("calúnia, difamação, injúria") com o final da definição de psicológica ("qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação") — composição incorreta, que não corresponde à definição real de nenhuma das duas modalidades.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mistura o início da definição de violência FÍSICA ("ofenda sua integridade, saúde corporal") com o final da definição de psicológica — mesma composição incorreta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Mistura o início da definição de violência PATRIMONIAL ("retenção, subtração, destruição... objetos... bens... recursos econômicos") com o final da definição de psicológica — mesma composição incorreta.

BIZU DE PROVA:
Três das quatro alternativas desta questão criam "definições Frankenstein", colando o início de uma modalidade com o final de outra — só a definição INTEIRA e genuína de psicológica (alternativa D) está correta. Desconfie de opções que pareçam "certas demais" no início, mas continuem com um trecho de outra modalidade.` },

{ tecId: 2976888, cadernoNumero: 410, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA (é a que NÃO é forma de violência prevista, pedida pelo enunciado):
"Violência racial" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006 — questões de discriminação racial são tratadas por legislação específica (Lei 7.716/1989 e o crime de injúria racial do Código Penal), não pela Lei Maria da Penha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência patrimonial é modalidade expressamente prevista no art. 7º, IV.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência física é modalidade expressamente prevista no art. 7º, I.

BIZU DE PROVA:
Embora a interseção entre raça e gênero seja uma dimensão social real e relevante da violência contra a mulher, a Lei Maria da Penha não nomeia "violência racial" como uma de suas modalidades específicas no art. 7º — não confunda a relevância social de um tema com a classificação técnica-legal pedida pela questão.` },

{ tecId: 2925122, cadernoNumero: 412, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal de violência física dada pelo art. 7º, I.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Reproduz boa parte dos MEIOS listados na definição de violência PSICOLÓGICA (constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, limitação do direito de ir e vir, art. 7º, II) — não corresponde à violência física.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Constranja a presenciar... relação sexual não desejada" é parte da definição de violência SEXUAL (art. 7º, III), não física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Dano emocional e diminuição da autoestima... pleno desenvolvimento" é o início da definição de violência PSICOLÓGICA (art. 7º, II), não física.

BIZU DE PROVA:
Física é a definição mais curta e objetiva do art. 7º — "ofender integridade ou saúde corporal". As alternativas A e E, juntas, formam quase a definição inteira de psicológica dividida em duas partes — mas nenhuma delas, isoladamente, corresponde à física.` },

{ tecId: 2891542, cadernoNumero: 413, explicacao: `GABARITO: CERTO

POR QUE:
O art. 6º da Lei 11.340/2006 estabelece expressamente que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
Frase literal do art. 6º — uma das mais cobradas isoladamente em itens Certo/Errado, justamente por ser curta e direta.

PEGADINHA:
Não há pegadinha nesta questão — é uma transcrição fiel e completa do art. 6º.` },

{ tecId: 2890917, cadernoNumero: 414, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Reproduz literalmente o art. 6º — a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte a regra do art. 5º, I, ao exigir "desde que haja vínculo familiar" — a Lei diz "com ou sem vínculo familiar".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não prevê essa restrição — a agressora pode ser de qualquer gênero, desde que a vítima seja mulher e a conduta se baseie no gênero, dentro de um dos três âmbitos do art. 5º (como reconhecido pela jurisprudência em relações homoafetivas).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Restringe indevidamente o conceito de família a "obrigatoriamente aparentados... por laços naturais" — o art. 5º, II, admite também aparentamento por afinidade ou por vontade expressa, sem exigir que seja "obrigatório" apenas por laços naturais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a regra do art. 5º, III, ao exigir coabitação "obrigatória" — a Lei diz "independentemente de coabitação".

BIZU DE PROVA:
Um padrão que se repete nesta e em várias outras questões: a alternativa correta costuma ser a transcrição literal e fiel de um dos artigos (aqui, o art. 6º), enquanto as demais introduzem pequenas restrições ("desde que", "obrigatoriamente", "apenas") que a Lei não faz.` },

];
