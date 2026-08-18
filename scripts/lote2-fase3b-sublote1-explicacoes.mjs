// LOTE 2 — FASE 3B — SUB-LOTE 1: explicações pedagógicas completas para as
// 38 questões novas de Lei Maria da Penha do sub-lote 1 (cadernoNumero
// 201-252), fonte exclusiva: scratchpad/fase3b_sublote1_conteudo.json, que
// por sua vez deriva de scratchpad/lote2_fase3a_candidatas_limpas_521.json
// (já normalizado na Fase 3A — nenhum enunciado/alternativa é reescrito
// aqui, só se escreve o campo `explicacao`).
//
// Mesmo padrão pedagógico do Lote 1 (scripts/sublote1..4-lei-maria-penha-
// explicacoes.mjs): GABARITO / POR QUE A ALTERNATIVA <letra> ESTÁ
// CORRETA|INCORRETA (uma seção por letra, nunca agrupada) / BIZU DE PROVA
// para múltipla escolha; GABARITO: CERTO|ERRADO / POR QUE: / BIZU DE
// PROVA: / PEGADINHA: para Certo/Errado.
//
// Texto legal usado como fonte: Lei 11.340/2006 consolidada e vigente em
// 2026, incluindo a Lei 15.384/2026 (inciso VI do art. 7º — violência
// vicária) e a Lei 13.772/2018 (inclusão de "violação de sua intimidade"
// no rol exemplificativo do art. 7º, II, e criação do art. 216-B do CP).
//
// Ressalvas herdadas do manifesto (VALIDA_COM_RESSALVA): os registros de
// classificação da Fase 2 (lote2_sublote1/2_classificacao_final.json)
// nunca persistiram um campo `motivo` para a categoria VALIDA_COM_RESSALVA
// (só para categorias de exclusão). Por isso, a ressalva de cada uma das 4
// questões abaixo foi RE-DERIVADA/CONFIRMADA com o usuário, diretamente do
// texto de cada questão e das regras já pactuadas (Lei 15.384/2026 = 6ª
// modalidade; erro histórico de número de lei mantido no enunciado):
//   - 220 (tecId 3528682): enumeração fechada dos 5 nomes corretos da Lei,
//     anterior à Lei 15.384/2026 — ressalva sobre a 6ª modalidade (vicária),
//     gabarito não muda.
//   - 240 (tecId 3424637): "São elas: [5 itens]" fechado, mas o teste real é
//     precisão vocabular (afetiva/matrimonial/imoral como pegadinhas), não a
//     contagem — mesma ressalva da 6ª modalidade, gabarito não muda.
//   - 252 (tecId 3363055): erro histórico da banca no ENUNCIADO, que cita
//     "Lei nº 10.741/2003" (Estatuto do Idoso) como sendo a Lei Maria da
//     Penha (na verdade Lei 11.340/2006) — mantido tal como a prova
//     apresentou (não normalizado na Fase 3A), com nota corretiva na
//     explicação.
//   - 238 (tecId 3453660): CONFIRMADO pelo usuário — a ressalva original era
//     só o prefixo residual "( )" nas alternativas, já normalizado na Fase
//     3A. Não leva ressalva jurídica na explicação (fica limpa).
//   - 244 (tecId 3375655): ressalva original RECUPERADA a pedido do usuário
//     — "ridicularização" é termo literal da definição de psicológica (art.
//     7º, II), então a classificação também como MORAL não pode ser
//     automática. A explicação abaixo fundamenta moral especificamente na
//     exposição PÚBLICA da ridicularização (postagens perante terceiros =
//     ofensa à honra objetiva, difamação/injúria), distinta da ridicularização
//     em si (que é meio de psicológica).
//
// Questão 225 (tecId 3502460) REMOVIDA deste sub-lote após reauditoria
// jurídica pedida pelo usuário: comparada a alternativa D ("namorado divulga
// fotos íntimas sem consentimento") com a alternativa A (gabarito original)
// à luz do art. 7º, II, na redação vigente (que inclui "violação de sua
// intimidade" como meio de violência psicológica), concluiu-se que A e D são
// SIMULTANEAMENTE corretas para o comando "assinale a que configura
// violência psicológica" em formato de resposta única — reclassificada
// PROBLEMATICA_GABARITO_AMBIGUO e excluída da importação (ver reaudit
// completo entregue ao usuário e replicado no manifesto/pool atualizados).
// Sub-lote 1 passa de 38 para 37 questões.

export const explicacoes = [

{ tecId: 3627565, cadernoNumero: 201, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A definição do enunciado — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir — reproduz quase literalmente o art. 7º, II, da Lei 11.340/2006, que é a definição de violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física é definida no art. 7º, I, como conduta que ofenda a integridade ou saúde corporal — nada no enunciado descreve agressão corporal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Afetiva" não é modalidade nomeada pela Lei; a expressão "relação íntima de afeto" aparece no art. 5º, III, como âmbito de incidência, não como tipo de violência.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Emocional" não é o rótulo técnico usado pela Lei — o "dano emocional" é uma das consequências descritas dentro da própria definição de violência psicológica (art. 7º, II), mas o nome da modalidade é "psicológica".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência moral é definida no art. 7º, V, como calúnia, difamação ou injúria — o enunciado não descreve ataque à honra/reputação, e sim controle e degradação psicológica.

BIZU DE PROVA:
Ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização e limitação do direito de ir e vir = psicológica (art. 7º, II). "Emocional" e "afetiva" são pegadinhas de rótulo, não os nomes técnicos da Lei.` },

{ tecId: 3612926, cadernoNumero: 202, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, III, c/c parágrafo único, da Lei 11.340/2006 configura violência doméstica em qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — e o local da agressão (via pública, em vez de dentro de casa) é irrelevante, pois a Lei protege a relação entre as partes, não o espaço físico onde ocorre o fato.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não estabelece prazo mínimo de duração do relacionamento para caracterizar "relação íntima de afeto".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O local do fato não afasta a aplicação da Lei — o que importa é a natureza da relação entre agressor e vítima, não onde a agressão ocorreu.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há exigência de coabitação, muito menos por prazo mínimo — o art. 5º, III, dispensa expressamente a coabitação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei se aplica desde a primeira ocorrência de violência — não exige reiteração/habitualidade para incidir.

BIZU DE PROVA:
"Relação íntima de afeto" é o âmbito mais amplo do art. 5º: dispensa coabitação, dispensa tempo mínimo de relacionamento, dispensa reiteração, e o local da agressão é irrelevante.` },

{ tecId: 3607836, cadernoNumero: 203, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Destruir o celular de Carla configura violência patrimonial (art. 7º, IV — conduta que configure destruição parcial ou total de objeto da ofendida); o vínculo de ex-namorados se enquadra no art. 5º, III, que dispensa coabitação e alcança quem "tenha convivido" em relação íntima de afeto — o fim do relacionamento não afasta a Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a convivência atual — basta que o agressor "tenha convivido" com a ofendida em relação íntima de afeto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Destruir um objeto da vítima é conduta que se enquadra tecnicamente na definição de violência patrimonial (art. 7º, IV); o motivo alegado por Marcos não reclassifica o fato como violência moral, pois o ato em si foi a destruição do bem, não uma ofensa à honra.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Por se tratar de violência doméstica e familiar (art. 5º, III), o fato não se limita a mero dano civil/penal comum — atrai o regime protetivo da Lei Maria da Penha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A violência patrimonial é modalidade autônoma (art. 7º, IV) — não depende de lesão física concomitante para se configurar.

BIZU DE PROVA:
Destruir/reter/subtrair objeto, documento, instrumento de trabalho ou valor da vítima = patrimonial, independentemente do motivo alegado pelo agressor. "Ex" também é alcançado pela Lei — "tenha convivido" cobre relação já encerrada.` },

{ tecId: 3605267, cadernoNumero: 204, explicacao: `GABARITO: ERRADO

POR QUE:
A Lei Maria da Penha prevê, no art. 7º, cinco formas de violência doméstica e familiar — física, psicológica, sexual, patrimonial e moral — e, desde a Lei 15.384/2026, uma sexta modalidade, a violência vicária (art. 7º, VI). A afirmativa erra tanto no número ("três") quanto no rol (já em 2025, quando a questão foi escrita, omitia sexual e moral; hoje omitiria também a vicária).

BIZU DE PROVA:
Sempre que a banca apresentar um número fechado de modalidades ("são X formas"), confira a lista completa: física, psicológica, sexual, patrimonial, moral e, desde 2026, vicária — seis ao todo. Enumeração incompleta ou com número diferente de 6 (salvo quando o enunciado disser "entre outras") deve ser tratada com desconfiança.

PEGADINHA:
A banca cita corretamente três das modalidades (física, psicológica e patrimonial), o que passa uma falsa sensação de precisão — o erro está em dizer que são SOMENTE essas três ("são três os níveis"), quando já em 2025 eram pelo menos cinco.` },

{ tecId: 3597162, cadernoNumero: 207, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A ordem correta é 3 (psicológica) – 1 (sexual) – 2 (moral). "Impedir a mulher de sair de casa, controlar suas amizades ou telefonemas" é violência psicológica (art. 7º, II — isolamento, limitação do direito de ir e vir). "Impedir a mulher de usar contraceptivos" é violência sexual (art. 7º, III — impedir o uso de método contraceptivo). "Acusar falsamente de traição ou chamar publicamente de 'prostituta'" é violência moral (art. 7º, V — calúnia e injúria).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "3, 2, 1" inverte sexual e moral: atribuiria moral ao segundo item (impedir contraceptivos) e sexual ao terceiro (chamar de "prostituta" publicamente), invertendo as definições legais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "1, 2, 3" atribui sexual ao primeiro item (isolamento/controle de contatos), quando na verdade é psicológica; e psicológica ao terceiro (acusação pública), quando é moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "2, 3, 1" atribui moral ao primeiro item, psicológica ao segundo e sexual ao terceiro — nenhuma correspondência bate com as definições legais.

BIZU DE PROVA:
Isolamento/controle de contatos/vigilância = psicológica; impedir contracepção/constranger a ato sexual = sexual; calúnia/difamação/injúria (inclusive xingamento de cunho sexual dito publicamente, como "prostituta") = moral.` },

{ tecId: 3596630, cadernoNumero: 208, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As três modalidades citadas — psicológica (I), patrimonial (II) e moral (III) — são efetivamente formas de violência doméstica e familiar contra a mulher, previstas respectivamente nos incisos II, IV e V do art. 7º da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente a violência moral (III), também prevista no art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente a violência psicológica (I), prevista no art. 7º, II.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente a violência patrimonial (II), prevista no art. 7º, IV.

BIZU DE PROVA:
Quando a questão apenas confirma se as modalidades citadas SÃO formas de violência previstas na Lei — sem alegar que a lista é exaustiva — todas as alternativas que citarem psicológica, patrimonial, moral, física, sexual (e, desde 2026, vicária) estarão corretas; o cuidado é não excluir indevidamente nenhuma das citadas.` },

{ tecId: 3850498, cadernoNumero: 209, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A injúria de Ângela contra Raíssa, no contexto de relação íntima de afeto entre as duas, configura violência doméstica e familiar na modalidade moral (art. 7º, V — calúnia, difamação ou injúria), aplicável independentemente de orientação sexual (art. 5º, parágrafo único) e de coabitação (art. 5º, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O parágrafo único do art. 5º dispõe que as relações pessoais ali enunciadas independem de orientação sexual, e o art. 5º, III, dispensa a coabitação — a Lei é plenamente aplicável ao caso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A injúria configura especificamente violência moral (art. 7º, V), modalidade distinta e mais precisa do que a psicológica (art. 7º, II) — restringir apenas à psicológica ignora a tipificação específica dada pela Lei à calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Arma de fogo em poder do agressor pode ser objeto de apreensão imediata como medida protetiva de urgência (art. 22, I) — não há vedação a essa apreensão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Quando necessário o afastamento do local de trabalho em razão da situação de violência doméstica, o art. 9º, §2º, II, assegura a manutenção do vínculo trabalhista de Raíssa por até seis meses.

BIZU DE PROVA:
Parágrafo único do art. 5º = orientação sexual da vítima é irrelevante para a incidência da Lei. Injúria/calúnia/difamação = sempre "moral" (art. 7º, V), nunca apenas "psicológica" quando a banca oferecer a opção mais específica.` },

{ tecId: 3588587, cadernoNumero: 211, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Calúnia, difamação ou injúria contra a mulher" é a definição literal de violência moral dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Insulto, chantagem ou violação de intimidade" caracterizam violência PSICOLÓGICA (art. 7º, II), não moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Destruição parcial de objetos e documentos pessoais" caracteriza violência PATRIMONIAL (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Ofensa à integridade ou saúde corporal" caracteriza violência FÍSICA (art. 7º, I), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Impedimento para uso de métodos contraceptivos" caracteriza violência SEXUAL (art. 7º, III), não moral.

BIZU DE PROVA:
Pegadinha clássica de "definição trocada" — a banca embaralha as definições das modalidades e pede a que pertence exatamente à modalidade perguntada. Palavras-chave: física=integridade/saúde corporal; psicológica=humilhação/isolamento/vigilância/insulto/chantagem/violação de intimidade; sexual=constranger/impedir contraceptivo; patrimonial=retenção/subtração/destruição de bens; moral=calúnia/difamação/injúria.` },

{ tecId: 3586559, cadernoNumero: 212, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Os três itens reproduzem, em conjunto, o núcleo do art. 5º, caput — a violência doméstica e familiar é a ação ou omissão baseada no gênero que cause morte e/ou lesão (I), sofrimento físico, sexual ou psicológico (II) e dano moral ou patrimonial (III) — todos elementos literais do caput.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item III, também previsto no caput ("dano moral ou patrimonial").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item I, também previsto no caput ("morte, lesão").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o item II, também previsto no caput ("sofrimento físico, sexual ou psicológico").

BIZU DE PROVA:
O caput do art. 5º descreve as CONSEQUÊNCIAS da violência doméstica (morte, lesão, sofrimento físico/sexual/psicológico, dano moral/patrimonial) — não confundir com o art. 7º, que descreve as MODALIDADES/formas de violência.` },

{ tecId: 3585297, cadernoNumero: 213, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Meire sofre violência psicológica (art. 7º, II — humilhação, insulto e xingamentos reiterados: "uma inútil", palavrões) e violência patrimonial (art. 7º, IV — retenção do cartão bancário e do valor do Bolsa Família, recurso econômico destinado a satisfazer suas necessidades). A Lei também define, separadamente, a violência moral como a conduta que configure calúnia, difamação ou injúria (art. 7º, V); como "insulto" (psicológica) e "injúria" (moral) descrevem, na prática, condutas de ofensa verbal muito próximas, a banca também classificou o relato sob o rótulo moral. Entre as cinco alternativas, B é a única que reúne psicológica e patrimonial sem incluir física ou sexual, que não ocorreram.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão física — o próprio enunciado esclarece que João "nunca bateu em nenhum deles".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física nem sexual no caso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de violência sexual, e "emocional" não é modalidade nomeada pela Lei (o efeito emocional integra a definição de violência psicológica, art. 7º, II).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite a violência psicológica, claramente presente na humilhação e nos xingamentos reiterados, e inclui física, que não ocorreu.

BIZU DE PROVA:
Quando o relato combinar humilhação/xingamento com retenção de cartão/benefício, pense primeiro em psicológica + patrimonial; desconfie de alternativas que "encaixem" física ou sexual sem qualquer relato de agressão corporal ou sexual.` },

{ tecId: 3574305, cadernoNumero: 215, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 7º da Lei 11.340/2006 nomeia, "entre outras", as formas física, psicológica, sexual, patrimonial e moral de violência doméstica e familiar (incisos I a V) — exatamente o conjunto de termos corretos reunido pela alternativa B, sem inventar nem omitir nenhum dos cinco.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Emprega o termo "emocional", que não é modalidade nomeada pela Lei (o efeito emocional integra a definição da violência psicológica, mas o rótulo correto é "psicológica"), e ainda omite a violência física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra "apenas" está errada — o próprio enunciado alerta que a enumeração é "entre outras", e a Lei nomeia ao menos mais três modalidades (sexual, patrimonial, moral).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Além do "apenas" indevido, omite psicológica e patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Acrescenta "violência religiosa", modalidade que não existe no rol do art. 7º.

BIZU DE PROVA:
O enunciado usa a expressão "entre outras" — isso já avisa que a lista não é fechada. Desconfie de qualquer alternativa com "apenas" e de qualquer termo que não seja um dos nomes técnicos da Lei: física, psicológica, sexual, patrimonial, moral e, desde 2026, vicária.` },

{ tecId: 3564240, cadernoNumero: 217, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece expressamente que "a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos" — texto literal reproduzido pela alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Contraria diretamente o art. 6º, que reconhece a violência doméstica como violação de direitos humanos, e não como mero "conflito de natureza privada".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não trata a violência doméstica como questão "exclusivamente penal" — também estabelece políticas de prevenção, assistência social e educação (arts. 3º e 8º), além de vinculá-la expressamente aos direitos humanos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A violência doméstica não se limita a infração administrativa — a Lei prevê, inclusive, o afastamento da Lei 9.099/1995 (art. 41) e mecanismos processuais penais próprios.

BIZU DE PROVA:
Art. 6º é curto e direto — decore a frase inteira: "constitui uma das formas de violação dos direitos humanos". Bancas costumam testá-lo isolado, com distratores que reduzem a violência doméstica a "problema privado" ou "questão exclusivamente penal/administrativa".` },

{ tecId: 3543629, cadernoNumero: 218, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
João destruiu o celular de Maria, objeto que também servia de instrumento de trabalho dela — conduta que se enquadra literalmente na definição de violência patrimonial do art. 7º, IV (retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, bens, valores ou recursos econômicos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O transtorno decorrente de dependência etílica não é causa de exclusão de responsabilidade nas medidas protetivas da Lei Maria da Penha nem impede a punição — a Lei não prevê essa hipótese de afastamento da resposta estatal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não veda medida de privação de liberdade em razão da dependência financeira da vítima em relação ao agressor — essa dependência é fator de vulnerabilidade a ser considerado a favor da proteção da vítima, não do agressor.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flagrante de violência física não é desviado para a rede de assistência social em substituição às medidas penais e protetivas cabíveis — o encaminhamento assistencial pode ocorrer de forma complementar, mas não no lugar das providências dos arts. 10 a 12.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O vínculo trabalhista assegurado pelo art. 9º, §2º, protege o emprego da MULHER em situação de violência quando ela precisa se afastar — não o emprego do agressor afastado por medida protetiva, e essa manutenção não é condicionada a ele ser "único provedor da família".

BIZU DE PROVA:
Destruição de instrumento de trabalho/objeto pessoal = patrimonial, mesmo que o motivo alegado pelo agressor seja outro. Dependência química/mental do agressor não é excludente de responsabilidade nem de medida protetiva na Lei Maria da Penha.` },

{ tecId: 3543432, cadernoNumero: 219, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Edson espalha para família e amigos comuns que Paula "é prostituta e adúltera" — conduta que atinge a honra e a reputação de Paula perante terceiros, ou seja, violência moral (art. 7º, V — calúnia/difamação/injúria).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Constranger o cônjuge a manter relações sexuais indesejadas mediante cobrança do "dever conjugal" configura violência sexual (art. 7º, III — constranger a manter relação sexual não desejada mediante coação), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apropriar-se do cartão e trocar a senha da conta bancária, submetendo a vítima a prestar contas de gastos, configura violência patrimonial (art. 7º, IV — subtração de valores/recursos econômicos), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Impedir o uso de método contraceptivo configura violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Perseguir a ex-companheira em local de trabalho, academia, redes sociais e por ligações de números diferentes configura violência psicológica ("perseguição contumaz" é expressamente citada no art. 7º, II), não moral.

BIZU DE PROVA:
Espalhar informação vexatória/falsa sobre a vítima para terceiros (família, amigos, redes sociais) = moral; perseguir/stalkear pessoalmente a vítima = psicológica ("perseguição contumaz" é termo literal do art. 7º, II).` },

{ tecId: 3528682, cadernoNumero: 220, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As cinco formas de violência doméstica e familiar contra a mulher nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006 são física, psicológica, sexual, patrimonial e moral — exatamente o conjunto reunido pela alternativa E, sem nenhum termo inventado. (Ressalva: esta questão é de 2025, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso do art. 7º; à época os cinco incisos citados eram de fato o rol então vigente, e a alternativa E permanece a única redigida com termos tecnicamente corretos entre as opções oferecidas — nenhuma delas seria corrigida pela adição da vicária, pois nenhuma usa esse termo ou testa a completude do rol. Hoje, o rol completo do art. 7º tem seis modalidades.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa "social" e "fisiológica", termos que não correspondem a nenhuma modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Usa "econômica", "social" e "emocional" — nenhum desses é o rótulo técnico usado pelo art. 7º (o efeito "econômico" integra a definição de patrimonial; "emocional" integra a de psicológica; mas os nomes das modalidades, tal como a Lei os nomeia, não são esses).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Usa "econômica" e "verbal", que também não são as modalidades nomeadas pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Usa "econômica", "social" e "fisiológica" — mesmos termos equivocados de A e B combinados.

BIZU DE PROVA:
Memorize os cinco nomes EXATOS usados pela Lei até 2026: física, psicológica, sexual, patrimonial e moral (hoje, seis, com a vicária). Termos parecidos mas errados — "emocional", "fisiológica", "social", "econômica", "verbal" — são a pegadinha mais comum desse tipo de questão.` },

{ tecId: 3520358, cadernoNumero: 222, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Os itens I, II e IV reproduzem corretamente três âmbitos de incidência da Lei — I corresponde ao art. 5º, I (unidade doméstica); II corresponde ao art. 5º, II (família); IV corresponde ao art. 5º, III (relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui o item III, falso — o art. 5º não prevê "âmbito público"; os âmbitos legais são unidade doméstica, família e relação íntima de afeto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui os itens III e V, ambos falsos — III inventa o "âmbito público" e V inverte o parágrafo único do art. 5º, que diz que as relações pessoais INDEPENDEM (não "dependerão") da orientação sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui os itens III e V, falsos pelos motivos acima.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item V, falso pelo motivo acima, e omite o item I, verdadeiro.

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica (I), família (II) e relação íntima de afeto (III) — não existe "âmbito público" na Lei. O parágrafo único é categórico: as relações pessoais do artigo INDEPENDEM da orientação sexual.` },

{ tecId: 3517979, cadernoNumero: 223, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa que NÃO é forma de violência doméstica e familiar prevista na Lei, pedida pelo enunciado):
"Institucional" não é uma das modalidades nomeadas pelo art. 7º da Lei 11.340/2006 — o rol legal nomeia física, psicológica, sexual, patrimonial e moral (e, desde a Lei 15.384/2026, também a vicária), mas não existe modalidade batizada de "institucional".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Física é modalidade expressamente prevista no art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Sexual é modalidade expressamente prevista no art. 7º, III.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Patrimonial é modalidade expressamente prevista no art. 7º, IV.

BIZU DE PROVA:
Questões "EXCETO" pedem a alternativa que NÃO se encaixa — mesmo sem "moral" entre as opções aqui, "institucional" é claramente um nome inventado que não consta do art. 7º, então é ela a exceção.` },

{ tecId: 3500154, cadernoNumero: 227, explicacao: `GABARITO: CERTO

POR QUE:
Marcos pratica violência psicológica (art. 7º, II) ao monitorar mediante vigilância constante as mensagens de Juliana, violar sua intimidade e controlar suas ações e comportamentos mediante manipulação — condutas expressamente citadas no inciso II. Ao reter o aparelho celular de Juliana, Marcos também pratica violência patrimonial (art. 7º, IV — retenção de objeto/bem da ofendida). Como a relação é de união estável há 7 anos (âmbito da família e/ou relação íntima de afeto, art. 5º, II e III), está configurada a violência doméstica e familiar.

BIZU DE PROVA:
"Vigilância constante", "violação de intimidade" e "manipulação" são termos literais do art. 7º, II (psicológica); "retenção" de objeto é literal do art. 7º, IV (patrimonial). Quando o enunciado combina os dois tipos de conduta, a resposta certa reconhece AMBAS as modalidades.

PEGADINHA:
É fácil enxergar só a violência psicológica (vigilância, manipulação) e esquecer que reter o celular — impedir Juliana de usar seu próprio bem — também é, tecnicamente, violência patrimonial.` },

{ tecId: 3497447, cadernoNumero: 228, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria" reproduz corretamente a definição do art. 7º, V, associada ao rótulo certo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência sexual" a definição de "conduta que ofenda sua integridade ou saúde corporal" — essa é, na verdade, a definição de violência FÍSICA (art. 7º, I).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Rotula como "violência patrimonial" a definição de dano emocional/diminuição de autoestima/degradar-controlar mediante ameaça, humilhação etc. — essa é, na verdade, a definição de violência PSICOLÓGICA (art. 7º, II).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de retenção/subtração/destruição de objetos, bens e valores — essa é, na verdade, a definição de violência PATRIMONIAL (art. 7º, IV).

BIZU DE PROVA:
Essa questão testa se você decora o rótulo CERTO para cada definição — as bancas adoram trocar o nome da modalidade mantendo a definição de outra. Associe pela palavra-chave: corporal=física; emocional/autoestima/controle=psicológica; sexo/contracepção=sexual; objetos/bens/valores=patrimonial; calúnia/difamação/injúria=moral.` },

{ tecId: 3496113, cadernoNumero: 229, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Agressões psicológicas praticadas pelo esposo contra a mãe, no recinto do lar, configuram violência doméstica nos termos da Lei 11.340/2006 — o âmbito da unidade doméstica (art. 5º, I) e a modalidade psicológica (art. 7º, II) estão presentes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei rompe justamente com a ideia de que a violência doméstica seria "problema interno da família" a ser resolvido sem intervenção do Estado — o art. 6º define-a como violação de direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Pelo mesmo motivo, a Lei não trata a violência doméstica como algo "corriqueiro" ou normal dentro das relações familiares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não reduz a violência doméstica a "mero litígio social" — tem tratamento jurídico próprio, com medidas protetivas e resposta penal específica.

BIZU DE PROVA:
Qualquer alternativa que minimize a violência doméstica como "problema privado", "corriqueiro" ou "mero litígio" estará sempre errada — o art. 6º é categórico ao classificá-la como violação de direitos humanos.` },

{ tecId: 3486856, cadernoNumero: 231, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A ordem correta é 2 (psicológica) – 1 (sexual) – 4 (física) – 3 (patrimonial). "Causar dano emocional e diminuição da autoestima... degradar ou controlar suas ações" é a definição de psicológica (art. 7º, II). "Constranger a presenciar relação sexual não desejada" é a definição de sexual (art. 7º, III). "Ofender sua integridade ou saúde corporal" é a definição de física (art. 7º, I). "Destruir parcial ou totalmente seus objetos" é a definição de patrimonial (art. 7º, IV).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência "2 – 3 – 1 – 4" troca patrimonial e física nas posições 2ª e 3ª, associando erroneamente "constranger a presenciar relação sexual" à patrimonial e "ofender integridade corporal" à sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "1 – 2 – 4 – 3" associa "dano emocional/diminuição de autoestima" à sexual (deveria ser psicológica) e "constranger a presenciar relação sexual" à psicológica (deveria ser sexual).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "3 – 4 – 2 – 1" inverte quase todas as associações — patrimonial no lugar de psicológica, física no lugar de sexual, psicológica no lugar de física e sexual no lugar de patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência "4 – 2 – 3 – 1" associa física ao primeiro item (deveria ser psicológica), patrimonial ao terceiro (deveria ser física) e sexual ao quarto (deveria ser patrimonial).

BIZU DE PROVA:
Monte mentalmente a "ficha" de cada modalidade antes de casar as colunas: psicológica=emocional/autoestima/controle; sexual=constranger a ato sexual/contracepção; física=integridade/saúde corporal; patrimonial=destruir/reter objetos e bens.` },

{ tecId: 3486853, cadernoNumero: 232, explicacao: `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Apenas a assertiva III está correta — reproduz literalmente o art. 5º, I ("no âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (todas as assertivas corretas):
As assertivas I e II contêm erro, então nem todas as três podem estar corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (todas as assertivas incorretas):
A assertiva III está correta (reproduz literalmente o art. 5º, I), então nem todas as três podem estar incorretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (apenas a assertiva I):
A assertiva I acrescenta indevidamente "desde que verificada a coabitação" — o art. 5º, III, é expresso ao dispensar a coabitação para a relação íntima de afeto, tornando a assertiva I falsa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (apenas a assertiva II):
A assertiva II acrescenta indevidamente "desde que unida por laços sanguíneos" — o art. 5º, II, define família de forma mais ampla, abrangendo laços naturais, por afinidade OU por vontade expressa, não apenas sanguíneos.

BIZU DE PROVA:
Essa questão testa se você percebe pequenos acréscimos restritivos ("desde que...") que a Lei não faz. O art. 5º, III, dispensa coabitação; o art. 5º, II, não exige laço sanguíneo — memorize essas duas dispensas, pois são armadilhas recorrentes.` },

{ tecId: 3467391, cadernoNumero: 235, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria" reproduz corretamente a definição do art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte o art. 5º, III — a relação íntima de afeto exige que o agressor CONVIVA ou TENHA CONVIVIDO com a ofendida; a alternativa erra ao dizer "não conviva e/ou não tenha convivido".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 8º, caput, estabelece que a política pública se dará por conjunto articulado de ações da União, dos Estados, do Distrito Federal, dos Municípios E de ações não governamentais — a alternativa erra ao excetuar justamente as ações não governamentais, que integram a política.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atribui às violências física e psicológica a definição que, na verdade, é da violência PATRIMONIAL (art. 7º, IV — retenção/subtração/destruição de objetos, instrumentos de trabalho, bens, valores e recursos econômicos).

BIZU DE PROVA:
Art. 8º, caput — a política pública é feita por ações articuladas da União, Estados, DF, Municípios E de ações não governamentais (todos juntos). E lembre: "conviva OU tenha convivido" — não precisa ser relação atual.` },

{ tecId: 3464975, cadernoNumero: 236, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 5º, caput, admite expressamente que a violência doméstica e familiar se configure por "ação OU omissão" baseada no gênero — a alternativa reproduz corretamente essa possibilidade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Brasil não se recusou a ratificar convenções de proteção à mulher — pelo contrário, a própria ementa da Lei Maria da Penha invoca o cumprimento da Convenção sobre a Eliminação de Todas as Formas de Discriminação contra as Mulheres e da Convenção de Belém do Pará, ambas ratificadas pelo Brasil.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para configurar violência doméstica em relação íntima de afeto — não é requisito indispensável.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Ofender a saúde da mulher é justamente a definição de violência física do art. 7º, I — está, sim, entre as formas de violência doméstica e familiar.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 8º, caput, estabelece justamente um "conjunto articulado de ações" integradas — a Lei busca a integração dos órgãos e instituições, não a independência entre eles.

BIZU DE PROVA:
"Ação OU omissão" (art. 5º, caput) é pegadinha recorrente — muita gente esquece que a omissão também configura violência doméstica, não só a ação.` },

{ tecId: 3459059, cadernoNumero: 237, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (apenas I e II estão corretas):
I reproduz literalmente o art. 7º, I (violência física: conduta que ofenda integridade ou saúde corporal) e II reproduz literalmente o art. 7º, IV (violência patrimonial: retenção, subtração, destruição de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (todas incorretas):
As assertivas I e II estão corretas, então nem todas as três podem estar incorretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (todas corretas):
A assertiva III está errada — atribui à violência psicológica a definição de "calúnia, difamação ou injúria", que na verdade é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (apenas III):
A assertiva III está errada pelo motivo acima, e as assertivas I e II, que estão corretas, ficariam indevidamente excluídas.

BIZU DE PROVA:
Mais uma vez a troca de rótulo entre psicológica e moral — "calúnia, difamação ou injúria" é SEMPRE moral (art. 7º, V), nunca psicológica, mesmo que a conduta também cause sofrimento psíquico à vítima.` },

{ tecId: 3453660, cadernoNumero: 238, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A definição citada — "conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos" — reproduz literalmente o art. 7º, IV, definição de violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A definição de violência moral (art. 7º, V) é "calúnia, difamação ou injúria" — não corresponde ao texto citado no enunciado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A definição de violência física (art. 7º, I) é "conduta que ofenda sua integridade ou saúde corporal" — não corresponde ao texto citado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A definição de violência psicológica (art. 7º, II) envolve dano emocional, diminuição de autoestima e condutas como ameaça, humilhação, isolamento e vigilância — não corresponde ao texto citado, que fala em retenção/destruição de bens.

BIZU DE PROVA:
Transcrição praticamente literal do art. 7º, IV — sempre que o enunciado citar "retenção, subtração, destruição de objetos/bens/valores/recursos econômicos", a resposta é patrimonial, sem exceção.` },

{ tecId: 3424637, cadernoNumero: 240, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 7º da Lei 11.340/2006 nomeia, em seus incisos I a V, as formas física, psicológica, sexual, patrimonial e moral de violência doméstica e familiar — exatamente os termos corretos reunidos pela alternativa A. (Ressalva: esta questão é de 2025, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso do art. 7º; à época os cinco incisos citados eram de fato o rol então vigente. A alternativa A permanece a única redigida com os termos tecnicamente corretos entre as opções oferecidas — nenhuma das demais seria corrigida pela adição da vicária, pois nenhuma delas usa esse termo; o teste real desta questão é precisão vocabular, não a contagem de modalidades.)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Substitui "física" por "afetiva", termo que não é nome de nenhuma modalidade de violência da Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Substitui "moral" por "imoral", palavra inexistente no rol legal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Substitui "patrimonial" por "matrimonial" — palavra parecida, mas sem qualquer relação com a definição legal de violência patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Combina os dois erros anteriores, substituindo "patrimonial" por "matrimonial" e "moral" por "imoral".

BIZU DE PROVA:
Essa questão testa precisão de vocabulário — preste atenção em trocas sutis de palavra parecida: "afetiva" no lugar de "física", "matrimonial" no lugar de "patrimonial", "imoral" no lugar de "moral". Hoje o rol completo do art. 7º tem seis modalidades (incluindo a vicária, desde a Lei 15.384/2026), mas nenhuma alternativa desta questão testa esse ponto.` },

{ tecId: 3407936, cadernoNumero: 241, explicacao: `GABARITO: CERTO

POR QUE:
O art. 5º, III, da Lei 11.340/2006 dispõe que configura violência doméstica e familiar contra a mulher qualquer relação íntima de afeto na qual o agressor conviva OU TENHA CONVIVIDO com a ofendida, "independentemente de coabitação" — tanto a coabitação quanto a época em que a convivência ocorreu (passada ou presente) são irrelevantes para a configuração da violência doméstica nesse âmbito.

BIZU DE PROVA:
"Conviva ou tenha convivido" + "independentemente de coabitação" são os dois maiores "coringas" do art. 5º, III. Decore essa frase inteira; ela sozinha resolve boa parte das questões sobre o âmbito de incidência da Lei.

PEGADINHA:
Candidatos costumam achar que a relação precisa ser atual ou envolver coabitação para caracterizar violência doméstica — o item explora exatamente a generosidade do art. 5º, III, nesse ponto.` },

{ tecId: 3379851, cadernoNumero: 242, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Constranger Mariana a manter relações sexuais contra sua vontade mediante ameaça, e impedi-la de usar métodos contraceptivos, são condutas que se enquadram literalmente na definição de violência sexual do art. 7º, III (constranger a manter relação sexual não desejada mediante ameaça; impedir o uso de método contraceptivo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência obstétrica é categoria distinta, relacionada a maus-tratos no contexto de parto/gestação por profissionais de saúde — não é modalidade nomeada pelo art. 7º da Lei Maria da Penha, e não é o que o caso narra.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Embora haja sofrimento psicológico envolvido, as condutas descritas — constranger a ato sexual e impedir contracepção — são especificamente tipificadas como violência sexual (art. 7º, III), classificação mais precisa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão à integridade física ou à saúde corporal de Mariana.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria contra Mariana.

BIZU DE PROVA:
"Constranger a ato sexual não desejado" e "impedir uso de contraceptivo" são exemplos literais do art. 7º, III — sempre que aparecerem juntos no enunciado, a resposta é violência sexual.` },

{ tecId: 3379836, cadernoNumero: 243, explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Manipular emocionalmente, isolar de amigos e familiares, controlar ações e limitar o direito de ir e vir, além de insultar e humilhar, reproduz quase integralmente o rol de condutas do art. 7º, II — definição de violência psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência de intimidação" não é modalidade nomeada pela Lei Maria da Penha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual no caso de Carla.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência moral exige calúnia, difamação ou injúria (art. 7º, V) — ataque à honra/reputação perante terceiros; o relato de Carla descreve controle, isolamento e manipulação, que se enquadram mais precisamente como psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência de assédio" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
"Manipulação", "isolamento" e "limitação do direito de ir e vir" são termos literais do art. 7º, II — combinação típica de violência psicológica. Fique atento a nomes de modalidade "inventados" (intimidação, assédio) que soam plausíveis mas não existem no rol legal.` },

{ tecId: 3375655, cadernoNumero: 244, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Controlar as redes sociais da vítima, impedindo-a de manter contato com amigos e familiares, é violência psicológica (art. 7º, II — isolamento, limitação do direito de ir e vir, controle de suas ações e comportamentos). Quanto à violência moral (art. 7º, V — calúnia, difamação ou injúria), sua fundamentação não decorre simplesmente da palavra "ridicularizada" — tomada isoladamente, "ridicularização" é ela própria um meio expressamente listado na definição de violência PSICOLÓGICA (art. 7º, II), não moral. O que desloca esse mesmo fato também para a violência moral é a natureza PÚBLICA da exposição: ridicularizar a vítima "em postagens", perante terceiros (o público das redes sociais), é o núcleo típico da ofensa à honra objetiva — atacar sua reputação/imagem diante de outras pessoas —, que é o que caracteriza a difamação (ou a injúria, conforme o conteúdo da postagem ofenda a reputação perante terceiros ou a dignidade da própria vítima). Em suma: o controle/isolamento sustenta psicológica; a exposição pública da ridicularização — não a ridicularização em si — sustenta moral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Menciona apenas a violência psicológica, omitindo a violência moral decorrente da exposição pública da vítima ao ridículo perante terceiros (postagens).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de destruição/retenção de bens (patrimonial) nem de agressão corporal (física) — o controle descrito é sobre contatos e redes sociais, não sobre a posse do aparelho.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Menciona apenas a violência moral, omitindo a violência psicológica evidente no controle e isolamento social da vítima.

BIZU DE PROVA:
Cuidado: "ridicularização" sozinha é termo do art. 7º, II (psicológica), não do art. 7º, V (moral) — não conclua "moral" só porque a palavra "ridicularizar" apareceu. O que caracteriza moral é a ofensa à honra/reputação perante terceiros (calúnia, difamação, injúria); aqui, o elemento que sustenta "moral" é especificamente a publicização em postagens (exposição a um público), não a ridicularização em abstrato.` },

{ tecId: 3374318, cadernoNumero: 245, explicacao: `GABARITO: CERTO

POR QUE:
O art. 5º, III, da Lei 11.340/2006 estabelece que a relação íntima de afeto configura violência doméstica e familiar "independentemente de coabitação" — ou seja, a coabitação é prescindível (dispensável) para a configuração da violência doméstica nesse âmbito.

BIZU DE PROVA:
"Prescindível" = dispensável, desnecessária. Sempre que a questão perguntar se a coabitação é "necessária", "indispensável" ou "requisito" para a violência doméstica em relação íntima de afeto, a resposta é NÃO — o art. 5º, III, é expresso ao dispensá-la.

PEGADINHA:
O uso da palavra "prescindível" (em vez de "dispensável", mais comum) pode confundir quem não conhece o termo — releia com atenção: prescindível = pode-se prescindir de = não é necessário.` },

{ tecId: 3371310, cadernoNumero: 246, explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa que NÃO configura violência doméstica e familiar, pedida pelo enunciado):
Solicitar horas extras a funcionárias em razão de alto fluxo de trabalho é relação de natureza trabalhista comum, sem qualquer dos elementos do art. 5º (não há âmbito de unidade doméstica, de família ou de relação íntima de afeto entre chefe e funcionárias, nem ação/omissão baseada no gênero que cause dano) — não se trata de violência doméstica e familiar.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Impedir o uso de métodos contraceptivos pelo(a) parceiro(a) é violência sexual (art. 7º, III), praticada no âmbito de relação íntima de afeto (art. 5º, III).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Usar os filhos para colocar em risco e perpetuar violência contra a ex-companheira é exatamente o padrão da violência vicária (art. 7º, VI, incluído pela Lei 15.384/2026) — violência praticada por meio de pessoa querida pela vítima, com o fim de atingi-la.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Controlar, humilhar e isolar a própria filha, causando danos emocionais e psicológicos, configura violência psicológica (art. 7º, II) no âmbito da família (art. 5º, II); a proteção da Lei Maria da Penha alcança vítima do gênero feminino nessa relação familiar independentemente de sua idade, conforme o Tema Repetitivo 1.186 do STJ, que reconhece a incidência da Lei também quando a vítima é criança ou adolescente.

BIZU DE PROVA:
Questões "NÃO configura" pedem a única situação alheia ao gênero e aos âmbitos do art. 5º — aqui, a relação de trabalho comum (horas extras) é a única fora do alcance da Lei; todas as demais, inclusive mãe-filha e o uso dos filhos contra a ex-companheira (violência vicária), estão dentro da proteção da Lei Maria da Penha.` },

{ tecId: 3370534, cadernoNumero: 248, explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Publicar informação falsa (calúnia) de que a ex-esposa desvia os valores da pensão alimentícia em proveito próprio, quando na verdade ela os utiliza integralmente para a subsistência dos filhos, configura violência moral (art. 7º, V — conduta caluniosa, que imputa falsamente um fato ofensivo à reputação de E.).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há retenção, subtração ou destruição de bens/valores de E. por parte de G. — o que ocorre é uma acusação falsa, não uma conduta patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Embora a publicação cause sofrimento psicológico, a conduta de G. se enquadra mais precisamente na definição específica de violência moral (calúnia) do art. 7º, V — "ridicularizar" não descreve com precisão o ato de imputar falsamente um fato desonroso.

BIZU DE PROVA:
Publicar acusação falsa que atinge a reputação da vítima perante terceiros = calúnia/difamação = moral (art. 7º, V). Não confunda com patrimonial só porque o tema de fundo é dinheiro/pensão — o que importa é a NATUREZA da conduta (uma acusação falsa), não o assunto de que ela trata.` },

{ tecId: 3849975, cadernoNumero: 249, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O parágrafo único do art. 5º da Lei 11.340/2006 estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual — a alternativa reproduz corretamente essa regra.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A violência moral (calúnia, difamação ou injúria) é, sim, forma de violência doméstica e familiar prevista no art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10 determina que a autoridade policial, ao tomar conhecimento da iminência de violência doméstica, adote de imediato as providências legais cabíveis — não há vedação a essa atuação imediata.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para configurar violência doméstica em relação íntima de afeto — a ausência de coabitação não afasta a proteção da Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 3º, §1º, atribui à família, à sociedade e ao poder público a criação das condições necessárias ao efetivo exercício, entre outros, do direito ao lazer da mulher — cabe, sim, à família essa responsabilidade.

BIZU DE PROVA:
Mais uma vez o parágrafo único do art. 5º — independência de orientação sexual é um dos pontos mais cobrados da parte introdutória da Lei.` },

{ tecId: 3366976, cadernoNumero: 251, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Lei Maria da Penha aplica-se independentemente da orientação sexual da vítima (art. 5º, parágrafo único), bastando que a violência tenha ocorrido no âmbito doméstico, familiar ou de relação íntima de afeto (art. 5º, I a III) — síntese correta dos critérios de incidência da Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não exige vínculo matrimonial — abrange também relações informais e já encerradas, por força do art. 5º, III ("conviva ou tenha convivido", independentemente de coabitação).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não se limita a medidas penais — também prevê políticas de prevenção e mecanismos de assistência às vítimas (arts. 3º, 8º e 9º, entre outros).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As medidas protetivas de urgência podem ser concedidas de forma autônoma, independentemente de inquérito ou processo penal em curso (art. 19), não exigindo o início prévio de ação penal.

BIZU DE PROVA:
Três blocos para fixar sobre o alcance da Lei: (1) independe de orientação sexual; (2) não exige matrimônio nem coabitação; (3) medidas protetivas podem ser concedidas de forma autônoma, sem depender de processo penal já iniciado.` },

{ tecId: 3363055, cadernoNumero: 252, explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa que NÃO é um âmbito de incidência previsto no art. 5º, pedida pelo enunciado):
"Situação de vulnerabilidade social e econômica" não é um dos três âmbitos do art. 5º da Lei 11.340/2006 — os âmbitos legais são a unidade doméstica (I), a família (II) e a relação íntima de afeto (III); vulnerabilidade social/econômica não é, por si só, um âmbito de incidência da Lei. (Nota: o enunciado desta questão cita erroneamente a Lei Maria da Penha como "Lei nº 10.741/2003" — esse é o número do Estatuto do Idoso; a Lei Maria da Penha é a Lei nº 11.340, de 7 de agosto de 2006. O erro de citação é da banca original, mantido aqui tal como a prova apresentou, e não afeta o conteúdo cobrado, que reproduz corretamente os âmbitos do art. 5º.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, I — âmbito da unidade doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, II — âmbito da família.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, III — âmbito da relação íntima de afeto.

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica, família e relação íntima de afeto. Qualquer alternativa que fale em "vulnerabilidade social", "âmbito público" ou outro critério que não seja um desses três é sempre a exceção correta em questões desse formato. E fique atento: o número da Lei Maria da Penha é 11.340/2006 — "10.741/2003" é o Estatuto do Idoso.` },

];
