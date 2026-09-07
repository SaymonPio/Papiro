-- MANUTENCAO GLOBAL FINAL DAS EXPLICACOES REAL DE DIREITOS HUMANOS
-- 19 corrupcoes cruzadas + Q351 (formatacao) — EXATAMENTE 20 UPDATEs em
-- public.questoes.explicacao. Nenhum outro campo, nenhuma outra tabela.
--
-- IDs: 55, 57, 58, 59, 124, 125, 126, 127, 128, 138, 140, 141, 144, 145, 146, 342, 343, 349, 812, 351
--
-- Cada linha e guardada por OLD_EXPLICACAO_MD5 (estado atual esperado) e
-- por um FINGERPRINT_IMUTAVEL amplo (id, enunciado, dificuldade,
-- materia_id, assunto_id, banca, concurso, ano, vinculos de unidade e
-- todas as alternativas com seu texto e flag 'correta') que cobre todos
-- os campos que este script jamais deve alterar. O pos-check recalcula
-- o mesmo fingerprint e exige identidade total com o valor pre-apply.
--
-- ROLLBACK-TESTADO em manutencao_dh_global_final_explicacoes_real_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_manutencao_dh_global_final_explicacoes_real.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _manut_dh_global (
  questao_id bigint primary key,
  old_md5_esperado text not null,
  fingerprint_esperado text not null,
  new_md5_esperado text not null,
  explicacao_nova text not null
) on commit drop;

insert into _manut_dh_global (questao_id, old_md5_esperado, fingerprint_esperado, new_md5_esperado, explicacao_nova) values
(55, 'b9d853e7582b79521e8aa96d9c1365a6', 'c3bfb7f87f1317ee54d735c5a1be166c', '0ce8fdb24699ba9f0e37ef5395021c35', $NEWQ55$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O enunciado pede a alternativa INCORRETA. O texto da alternativa A corresponde, na realidade, à definição de "desenho universal" prevista no art. 2 da Convenção Internacional sobre os Direitos das Pessoas com Deficiência (Decreto nº 6.949/2009), e não à definição de "adaptação razoável". A Convenção define adaptação razoável, no mesmo artigo, como as modificações e os ajustes necessários e adequados que não acarretem ônus desproporcional ou indevido, quando requeridos em cada caso, a fim de assegurar que as pessoas com deficiência possam gozar ou exercer, em igualdade de oportunidades com as demais pessoas, todos os direitos humanos e liberdades fundamentais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O texto reproduz corretamente a definição de "discriminação por motivo de deficiência" prevista no art. 2 da Convenção.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto reproduz corretamente o art. 5, item 3, da Convenção, sobre a adoção de medidas apropriadas para garantir a oferta de adaptação razoável.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O texto reproduz corretamente o art. 17 da Convenção, sobre o direito à proteção da integridade física e mental em igualdade de condições com as demais pessoas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O texto reproduz corretamente o art. 30, item 1, da Convenção, sobre o direito de participar da vida cultural em igualdade de oportunidades.$NEWQ55$),
(57, '9cb83f71b4360847d452079cee20a06b', '4911e04a702d4780d93813e0c8238bb7', '7683f00e4809a3c54f7606256176bbac', $NEWQ57$GABARITO: alternativa D

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A afirmativa está incompleta: o item I também não integra o rol de efeitos condicionados à reincidência e não automáticos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A afirmativa está incompleta: o item II também integra o rol de efeitos condicionados à reincidência e não automáticos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O item I não é um efeito condicionado à reincidência; nos termos do art. 4º, §1º, da Lei nº 13.869/2019, apenas os efeitos previstos nos incisos II e III do caput do art. 4º dependem de reincidência em crime de abuso de autoridade e não são automáticos.

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Nos termos do art. 4º, §1º, da Lei nº 13.869/2019, os efeitos previstos nos incisos II (inabilitação para o exercício de cargo, mandato ou função pública, pelo período de 1 a 5 anos) e III (perda do cargo, do mandato ou da função pública) do caput do art. 4º são condicionados à ocorrência de reincidência em crime de abuso de autoridade e não são automáticos, devendo ser declarados motivadamente na sentença. O item I (tornar certa a obrigação de indenizar) não se submete a essa condição.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O item I não está condicionado à reincidência, de modo que a afirmativa de que os três itens estão corretos é equivocada.$NEWQ57$),
(58, 'b085a336079acab0f1ce8babc5301b64', '01c89f16c6bdccc6eab4caa06923437d', '555e3a083b20fa48832abf38a0fca6ca', $NEWQ58$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O texto reproduz corretamente o art. 6, item 1, do Pacto Internacional sobre Direitos Civis e Políticos (Decreto nº 592/1992).

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O enunciado pede a alternativa INCORRETA. O art. 7 do Pacto estabelece que ninguém poderá ser submetido à tortura, nem a penas ou tratamento cruéis, desumanos ou degradantes, e que será proibido submeter uma pessoa a experiências médicas ou científicas sem seu livre consentimento. A alternativa inverte essa proibição, afirmando que tal prática "é autorizado", quando o Pacto expressamente a proíbe.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto reproduz corretamente o art. 9, item 5, do Pacto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O texto reproduz corretamente o art. 10, item 1, do Pacto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O texto reproduz corretamente o art. 11 do Pacto.$NEWQ58$),
(59, '405e1a2469c60b186d908777cad4e1fd', 'a8ab77b0b80daab07028ad649faaddae', 'c53a3c87560fc8e94b912bd3959998ef', $NEWQ59$GABARITO: alternativa E

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As situações I e II também constituem crime de tortura, o que torna a afirmativa incompleta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A situação III também constitui crime de tortura, o que torna a afirmativa incompleta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação II também constitui crime de tortura, o que torna a afirmativa incompleta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A situação I também constitui crime de tortura, o que torna a afirmativa incompleta.

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As três situações configuram crime de tortura nos termos do art. 1º da Lei nº 9.455/1997. A situação I amolda-se ao art. 1º, I, "a" (constranger com violência ou grave ameaça, causando sofrimento físico ou mental, com o fim de obter informação). A situação II amolda-se ao art. 1º, II (submeter pessoa sob guarda, poder ou autoridade a intenso sofrimento físico ou mental, como medida de caráter preventivo). A situação III amolda-se ao art. 1º, I, "b" (constranger com violência, causando sofrimento físico, com o fim de provocar ação de natureza criminosa).$NEWQ59$),
(124, 'bcd85954dbe6eb1acdcea137ee754b8f', '0840e0cd3f7ade312391dcdf6eba63e8', 'b467c4d408f45a686f30237439f4ba69', $NEWQ124$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 2 da Convenção Interamericana para Prevenir e Punir a Tortura (Decreto nº 98.386/1989) exclui do conceito de tortura as penas ou sofrimentos físicos ou mentais unicamente decorrentes de medidas legais, mas condiciona essa exclusão a que tais medidas não incluam a prática dos atos ou a aplicação dos métodos a que se refere o próprio artigo. A alternativa suprime essa condição, tornando a afirmativa absoluta e, por isso, incorreta.

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Nos termos do art. 3, "a", da Convenção, serão responsáveis pelo delito de tortura os empregados ou funcionários públicos que, podendo impedir a prática de tortura, não o fizerem.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 4 da Convenção estabelece expressamente que o fato de haver o agente agido por ordens superiores NÃO eximirá da responsabilidade penal correspondente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5 da Convenção estabelece que a periculosidade do detido ou condenado e a insegurança do estabelecimento carcerário ou penitenciário NÃO podem ser invocadas nem admitidas como justificativa do delito de tortura.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 5 da Convenção estabelece que nenhuma das circunstâncias ali elencadas, incluindo estado de guerra, ameaça de guerra, estado de sítio ou de emergência, comoção ou conflito interno, suspensão de garantias constitucionais e instabilidade política interna, poderá ser invocada nem admitida como justificativa da tortura.$NEWQ124$),
(125, 'e6d7660842777effcfbf254a6e847ef4', '9a34597f5d3c735ae9a6734b828c3f76', '27bde3630cbfc24c5d44280d41ca7875', $NEWQ125$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O texto reproduz o art. 4 do Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (Decreto nº 591/1992), segundo o qual o Estado poderá submeter os direitos assegurados pelo Pacto unicamente às limitações estabelecidas em lei, somente na medida compatível com a natureza desses direitos e exclusivamente com o objetivo de favorecer o bem-estar geral em uma sociedade democrática.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5, item 2, do Pacto estabelece o contrário: não se admitirá qualquer restrição ou suspensão dos direitos humanos fundamentais reconhecidos ou vigentes em qualquer país em virtude de leis, convenções, regulamentos ou costumes, sob pretexto de que o Pacto não os reconheça ou os reconheça em menor grau.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 6, item 2, do Pacto prevê expressamente que as medidas a serem adotadas pelos Estados para assegurar o pleno exercício do direito ao trabalho deverão incluir a orientação e a formação técnica e profissional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 9 do Pacto reconhece o direito de toda pessoa à previdência social, inclusive ao seguro social, sem a ressalva de independer de contribuição.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 15, item 1, "c", do Pacto reconhece o direito de beneficiar-se da proteção dos interesses morais e materiais decorrentes de toda produção científica, literária ou artística da qual a pessoa seja autora, e não da qual não seja autora.$NEWQ125$),
(126, '48a0bd076215311e086f217d83121e6f', '361fb785533b7e82c94ba81ecfc03152', '049f07129a6945c2066e09bfb1a72f78', $NEWQ126$GABARITO: alternativa C

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Atendente pessoal" é conceito distinto previsto no art. 3, XII, da Lei nº 13.146/2015, referente à pessoa que auxilia a pessoa com deficiência a realizar suas atividades diárias, excluídas as técnicas ou os procedimentos identificados com profissões legalmente estabelecidas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Acompanhante" não é a definição legal correspondente às atividades descritas no enunciado.

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 3, XIII, da Lei nº 13.146/2015 (Estatuto da Pessoa com Deficiência) define profissional de apoio escolar como a pessoa que exerce atividades de alimentação, higiene e locomoção do estudante com deficiência e atua em todas as atividades escolares nas quais se fizer necessária, em todos os níveis e modalidades de ensino, em instituições públicas e privadas, excluídas as técnicas ou os procedimentos identificados com profissões legalmente estabelecidas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ajudante escolar" não é a nomenclatura utilizada pela Lei nº 13.146/2015.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Professor assistente" pressupõe habilitação docente, o que não corresponde à definição legal de profissional de apoio escolar, que exclui expressamente as técnicas ou os procedimentos identificados com profissões legalmente estabelecidas.$NEWQ126$),
(127, 'e4ed2b0789471d6dba7246aa922e4352', '86f0ecfd05d40b1eb10bc906f741a5a5', '6b0838e5431521929e9cb9f996b96d22', $NEWQ127$GABARITO: alternativa D

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Tratado de Marraqueche foi aprovado pelo rito do art. 5º, §3º, da Constituição Federal (Decreto Legislativo nº 261/2015), possuindo, portanto, status de emenda constitucional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Convenção sobre os Direitos das Pessoas com Deficiência foi aprovada pelo rito do art. 5º, §3º, da Constituição Federal (Decreto Legislativo nº 186/2008), possuindo status de emenda constitucional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Protocolo Facultativo à Convenção sobre os Direitos das Pessoas com Deficiência foi aprovado conjuntamente com a Convenção pelo mesmo rito do art. 5º, §3º, da Constituição Federal, possuindo igualmente status de emenda constitucional.

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Pacto de San José da Costa Rica (Convenção Americana sobre Direitos Humanos) não foi aprovado pelo rito do art. 5º, §3º, da Constituição Federal, não possuindo status de emenda constitucional. Segundo a jurisprudência do Supremo Tribunal Federal (RE 466.343/SP), os tratados de direitos humanos incorporados sem observância desse rito possuem status supralegal, e não de emenda constitucional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Pacto Internacional sobre Direitos Civis e Políticos, por não ter sido aprovado pelo rito do art. 5º, §3º, da Constituição Federal, possui de fato status de norma supralegal, conforme a jurisprudência do STF, sendo essa afirmativa correta.$NEWQ127$),
(128, 'b159fdc707cfc67cf4cbbe405186d198', '5e6b14a86fa0fab2f314083de15ee359', 'f77afc44704c77e183c2a76ba3e0a31f', $NEWQ128$GABARITO: alternativa C

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 16 da Lei nº 13.869/2019 também tipifica a conduta de deixar de identificar-se ao preso por ocasião de sua captura ou quando o agente deva fazê-lo durante sua detenção ou prisão. Portanto, a recusa de identificação nas condições previstas no dispositivo pode configurar crime de abuso de autoridade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A identificação falsa ao preso por ocasião de sua captura está expressamente prevista como crime no art. 16 da Lei nº 13.869/2019.

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Nos termos do art. 16 da Lei nº 13.869/2019, identificar-se falsamente ao preso por ocasião de sua captura constitui crime de abuso de autoridade, com pena de detenção de 6 (seis) meses a 2 (dois) anos e multa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira premissa da alternativa está errada, pois identificar-se falsamente ao preso no momento da captura é conduta tipificada pelo caput do art. 16. O parágrafo único também pune, com a mesma pena, o responsável por interrogatório que deixe de identificar-se ao preso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O parágrafo único do art. 16 estabelece que o responsável por interrogatório que atribua a si mesmo falsa identidade, cargo ou função incorre na MESMA pena prevista no caput, e não em pena agravada.$NEWQ128$),
(138, '6e785a54703f6d33b600868e70eff139', '7cd27773cc39edcf999224798bf54eea', '4d107458e2fcab373db1a3bf99726e9d', $NEWQ138$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do art. 1º, §6º, da Lei nº 9.455/1997, o crime de tortura é inafiançável e insuscetível de graça ou anistia, reproduzindo a literalidade do art. 5º, XLIII, da Constituição Federal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei nº 9.455/1997 não inclui expressamente o indulto no rol de benefícios vedados ao crime de tortura; o texto legal e constitucional refere-se apenas a graça e anistia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O crime de tortura não é imprescritível nos termos da Lei nº 9.455/1997 nem da Constituição Federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O crime de tortura não é imprescritível, e o rol de benefícios vedados não inclui expressamente o indulto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O crime de tortura não é imprescritível e não é suscetível de graça, indulto ou anistia.$NEWQ138$),
(140, '655ff889975c8fb150359807f52df0e9', 'c9ef0280a016614c6f5df454fb78b937', 'ceac5f1921e8da83582f0dd08609bfc7', $NEWQ140$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens, conforme demonstrado na alternativa B.

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é V – F – F – V – F. O primeiro item reproduz o art. 5, item 1, da Convenção Americana sobre Direitos Humanos (V). O segundo item é falso: o art. 7, item 7, estabelece que ninguém deve ser detido por dívidas, mas que esse princípio NÃO limita os mandados expedidos em razão de inadimplemento de obrigação alimentar, ao passo que o item afirma que o princípio SE APLICA a tais mandados, invertendo o sentido da norma (F). O terceiro item é falso: o art. 7, item 4, exige que a notificação da acusação ocorra SEM DEMORA, e não "quando conveniente" (F). O quarto item reproduz o art. 6, item 1, da Convenção (V). O quinto item é falso: o art. 5, item 6, refere-se à finalidade das PENAS PRIVATIVAS DE LIBERDADE, e não das penas restritivas de direito (F).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.$NEWQ140$),
(141, 'd44b343658fc2196d3249ecd30ce2c45', 'd7ca63b9d0576d1c40981309d38cf7c2', '0084398dd8b0a96791f50783b87b6d48', $NEWQ141$GABARITO: alternativa E

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As três situações constituem crime nos termos do art. 8º da Lei nº 7.853/1989, o que torna incorreta qualquer sequência que não seja V – V – V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As três situações constituem crime nos termos do art. 8º da Lei nº 7.853/1989.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As três situações constituem crime nos termos do art. 8º da Lei nº 7.853/1989.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As três situações constituem crime nos termos do art. 8º da Lei nº 7.853/1989.

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 8º da Lei nº 7.853/1989 tipifica como crime negar ou obstar emprego, trabalho ou promoção à pessoa em razão de sua deficiência; recusar, cobrar valores adicionais, suspender, procrastinar, cancelar ou fazer cessar inscrição de aluno em razão de sua deficiência; e obstar inscrição em concurso público ou acesso a cargo ou emprego público em razão de deficiência. As três situações descritas (I, II e III) correspondem a essas condutas típicas, de modo que a sequência correta é V – V – V.$NEWQ141$),
(144, '87e687197e7ea8cc3572e9dd3d5cca45', 'e38a5a241cf1120466282b49f0cca696', '1b2e7240e6daae50d2e1e62441b679a6', $NEWQ144$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O texto reproduz corretamente o art. 8, item 2, da Convenção Americana sobre Direitos Humanos, sobre a presunção de inocência.

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O enunciado pede a alternativa INCORRETA, nos exatos termos da Convenção Americana sobre Direitos Humanos. A redação da alternativa ("aos litigantes... contraditório e ampla defesa, com os meios e recursos a ela inerentes") corresponde à literalidade do art. 5º, LV, da Constituição Federal brasileira, e não à redação da Convenção Americana, que trata as garantias judiciais de forma distinta em seu art. 8.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto reproduz corretamente o art. 7, item 1, da Convenção.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O texto reproduz corretamente o art. 7, item 3, da Convenção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O texto reproduz corretamente o art. 12, item 4, da Convenção.$NEWQ144$),
(145, 'c44a50d704a33e165a563a7fffb34389', '1a7792f83c7365045268001e2986b5ef', '8f27e9084a165d173b4be6ae78950d58', $NEWQ145$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O texto reproduz corretamente o art. 1º da Declaração Universal dos Direitos Humanos.

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O enunciado pede a alternativa INCORRETA. O art. 5º da Declaração Universal dos Direitos Humanos estabelece que ninguém será submetido a tortura, nem a tratamento ou castigo cruel, desumano ou degradante, sem prever qualquer exceção para caso de guerra. A alternativa acrescenta uma ressalva ("salvo em caso de guerra") inexistente no texto da Declaração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto reproduz corretamente o art. 3º da Declaração.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O texto reproduz corretamente o art. 4º da Declaração.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O texto reproduz corretamente o art. 7º da Declaração.$NEWQ145$),
(146, '2a33959679786dbe840427f33e3a796e', '28d83622b533f7073276bdbdb3b6d81c', '74aa28c6dd2a536d11187e7c95bbf277', $NEWQ146$GABARITO: alternativa E

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Súmula Vinculante nº 11 do STF não utiliza os termos "violência", "ação" ou "nulidade da prisão" combinados dessa forma nas lacunas indicadas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Súmula exige que a excepcionalidade, e não a ação, seja justificada por escrito, e a consequência prevista é a nulidade da prisão ou do ato processual, e não a exoneração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A primeira lacuna deve ser preenchida por "resistência", e não por "violência", e a consequência prevista é a nulidade da prisão, e não a exoneração.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A segunda lacuna deve ser preenchida por "integridade física", e não por "vida".

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A Súmula Vinculante nº 11 do STF estabelece: "Só é lícito o uso de algemas em casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia, causada pelo preso ou por terceiros, justificada a excepcionalidade por escrito, sob pena de responsabilidade disciplinar civil e penal do agente ou da autoridade e de nulidade da prisão ou do ato processual a que se refere, sem prejuízo da responsabilidade civil do Estado".$NEWQ146$),
(342, '226a3f97a81f4f0eaa4d59d8b8d5a00b', 'bf912e0a2d5521a6a74c708994026077', '627a793f408fa0c7491f0a5da529478c', $NEWQ342$GABARITO: alternativa C

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Construir uma sociedade livre, justa e solidária é objetivo fundamental previsto no art. 3º, I, da Constituição Federal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erradicar a pobreza e a marginalização e reduzir as desigualdades sociais e regionais é objetivo fundamental previsto no art. 3º, III, da Constituição Federal.

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A autodeterminação dos povos não é objetivo fundamental previsto no art. 3º da Constituição Federal; trata-se de princípio que rege a República Federativa do Brasil em suas relações internacionais, previsto no art. 4º, III, da Constituição Federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Promover o bem de todos, sem preconceitos de origem, raça, sexo, cor, idade e quaisquer outras formas de discriminação é objetivo fundamental previsto no art. 3º, IV, da Constituição Federal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Garantir o desenvolvimento nacional é objetivo fundamental previsto no art. 3º, II, da Constituição Federal.$NEWQ342$),
(343, '2cf2fba94e23ad368f475063e7f02fc3', '507e7a003fe7bd60e2232ad06f6b6608', '528a18ca9762feb92875e489a77dae02', $NEWQ343$GABARITO: alternativa E

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens, conforme demonstrado na alternativa E.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência não corresponde à análise correta dos itens.

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência correta é F – V – V – V. O primeiro item é falso: o art. 5º, VIII, da Constituição Federal estabelece que ninguém será privado de direitos por motivo de crença religiosa ou de convicção filosófica ou política, SALVO SE as invocar para eximir-se de obrigação legal a todos imposta e recusar-se a cumprir prestação alternativa fixada em lei; o item afirma o oposto, ao dizer que ninguém será privado de direitos "ainda que" as invoque para esse fim (F). O segundo item reproduz o art. 5º, XIV, da Constituição Federal (V). O terceiro item reproduz o art. 5º, XVII, da Constituição Federal (V). O quarto item reproduz o art. 5º, XX, da Constituição Federal (V).$NEWQ343$),
(349, 'c232c92d797e12a6bbb66f09d6589b5b', '894deb7adf634d43830deb7f51dc2efb', 'a9eed6ad960d50b89711a337dc59ac80', $NEWQ349$GABARITO: alternativa D

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O texto reproduz corretamente o art. 18 da Declaração Universal dos Direitos Humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O texto reproduz corretamente o art. 21, item 1, da Declaração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto reproduz corretamente o art. 27, item 1, da Declaração.

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O enunciado pede a alternativa INCORRETA. O art. 26, item 1, da Declaração Universal dos Direitos Humanos estabelece que a instrução será gratuita, pelo menos nos graus elementares e fundamentais, sendo a instrução elementar obrigatória, enquanto a instrução técnico-profissional e a instrução superior serão apenas acessíveis a todos, esta última com base no mérito, sem previsão de gratuidade em todos os graus, incluindo o superior.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O texto reproduz corretamente o art. 29, item 1, da Declaração.$NEWQ349$),
(812, 'e7955bf33cae5be87af33fb7013e10c5', '8fd03204544594e0f3f50b0040c548a5', '0eae236e764acaf756cd342d70db775a', $NEWQ812$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I também está correta, o que torna a afirmativa incompleta.

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II. A assertiva I reproduz o art. 10 da Declaração Universal dos Direitos Humanos, sobre o direito a julgamento equitativo e público por tribunal independente e imparcial. A assertiva II reproduz o art. 11, item 1, da Declaração, sobre a presunção de inocência. A assertiva III é incorreta porque o art. 11, item 2, da Declaração não prevê qualquer exceção para crime contra os direitos humanos: estabelece apenas que ninguém poderá ser culpado por ação ou omissão que, no momento, não constituía delito perante o direito nacional ou internacional, nem sofrer pena mais forte do que a aplicável no momento da prática do ato delituoso, sem ressalvas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III está incorreta, pois acrescenta ao art. 11, item 2, da Declaração uma exceção ("salvo quando se tratar de crime contra os direitos humanos") que o texto não prevê.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está incorreta, pelas razões já expostas.$NEWQ812$),
(351, '780daad14352ffb05743e2691a2949e6', '092a6d193dad1898dc28aaee29597478', 'ce34bb5e290fed8d63e14e6af7845d06', $NEWQ351$GABARITO: alternativa B

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O texto corresponde à definição de "adaptação razoável", e não de "desenho universal", prevista no art. 2 da Convenção Internacional sobre os Direitos das Pessoas com Deficiência (Decreto nº 6.949/2009).

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O texto reproduz o art. 7, item 3, da Convenção Internacional sobre os Direitos das Pessoas com Deficiência (Decreto nº 6.949/2009), segundo o qual os Estados Partes assegurarão que as crianças com deficiência tenham o direito de expressar livremente sua opinião sobre todos os assuntos que lhes disserem respeito, tenham a sua opinião devidamente valorizada de acordo com sua idade e maturidade, em igualdade de oportunidades com as demais crianças, e recebam atendimento adequado à sua deficiência e idade, para que possam exercer tal direito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A acessibilidade é expressamente prevista como um dos princípios gerais da Convenção, no art. 3, "f".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5, item 4, da Convenção estabelece que as medidas específicas necessárias para acelerar ou alcançar a efetiva igualdade das pessoas com deficiência não serão consideradas discriminatórias, e não vedadas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 2 da Convenção estabelece que a discriminação por motivo de deficiência abrange todas as formas de discriminação, inclusive a recusa de adaptação razoável, e não excetuada essa recusa.$NEWQ351$);

-- ================= PRECONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_dh_uteis int; v_staging int; v_bad_md5 int; v_bad_fp int;
begin
  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(distinct q.id) into v_dh_uteis
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id and up.ativa = true
    where q.ativa = true and q.materia_id = 11;

  if v_questoes <> 1158 then raise exception 'PRECOND: questoes=% esperado 1158', v_questoes; end if;
  if v_alternativas <> 5544 then raise exception 'PRECOND: alternativas=% esperado 5544', v_alternativas; end if;
  if v_vinculos <> 935 then raise exception 'PRECOND: vinculos=% esperado 935', v_vinculos; end if;
  if v_dh_uteis <> 301 then raise exception 'PRECOND: DH uteis=% esperado 301', v_dh_uteis; end if;

  select count(*) into v_staging from _manut_dh_global;
  if v_staging <> 20 then raise exception 'PRECOND: staging com % linhas, esperado exatamente 20', v_staging; end if;

  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _manut_dh_global)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_dh_global l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then raise exception 'PRECOND: % questao(oes) com OLD_MD5 divergente do esperado — abortando', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'PRECOND: % questao(oes) com FINGERPRINT_IMUTAVEL divergente do esperado — abortando', v_bad_fp; end if;

  if (select count(*) from public.alternativas where questao_id = 812) <> 4 then
    raise exception 'PRECOND: Q812 nao tem exatamente 4 alternativas';
  end if;
  if (select chr(64+ordem) from public.alternativas where questao_id = 812 and correta = true) <> 'B' then
    raise exception 'PRECOND: Q812 gabarito nao e B';
  end if;
  if (select count(*) from public.alternativas where questao_id = 351) <> 5 then
    raise exception 'PRECOND: Q351 nao tem exatamente 5 alternativas';
  end if;
  if (select chr(64+ordem) from public.alternativas where questao_id = 351 and correta = true) <> 'B' then
    raise exception 'PRECOND: Q351 gabarito nao e B';
  end if;

  raise notice 'PRECONDICOES OK: baseline global intacto (questoes=%, alternativas=%, vinculos=%, DH uteis=%) | 20/20 OLD_MD5 | 20/20 FINGERPRINT_IMUTAVEL', v_questoes, v_alternativas, v_vinculos, v_dh_uteis;
end $$;

-- ================= UPDATE (unico, guardado) =================
do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_nova
  from _manut_dh_global l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 20 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 20 — abortando', v_rows;
  end if;
  raise notice 'UPDATE aplicado: % linha(s) afetada(s) em questoes.explicacao', v_rows;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_dh_uteis int; v_bad_md5 int; v_bad_fp int;
begin
  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(distinct q.id) into v_dh_uteis
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id and up.ativa = true
    where q.ativa = true and q.materia_id = 11;

  if v_questoes <> 1158 then raise exception 'POSCOND: questoes=% esperado 1158', v_questoes; end if;
  if v_alternativas <> 5544 then raise exception 'POSCOND: alternativas=% esperado 5544', v_alternativas; end if;
  if v_vinculos <> 935 then raise exception 'POSCOND: vinculos=% esperado 935', v_vinculos; end if;
  if v_dh_uteis <> 301 then raise exception 'POSCOND: DH uteis=% esperado 301', v_dh_uteis; end if;

  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _manut_dh_global)
  )
  select count(*) filter (where atual.cur_md5 <> l.new_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _manut_dh_global l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then raise exception 'POSCOND: % questao(oes) nao bateram com NEW_MD5 esperado — abortando commit', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'POSCOND: % questao(oes) com FINGERPRINT_IMUTAVEL alterado — abortando commit', v_bad_fp; end if;

  if (select count(*) from public.alternativas where questao_id = 812) <> 4 then
    raise exception 'POSCOND: Q812 perdeu a contagem de 4 alternativas';
  end if;
  if (select chr(64+ordem) from public.alternativas where questao_id = 812 and correta = true) <> 'B' then
    raise exception 'POSCOND: Q812 gabarito mudou';
  end if;
  if (select count(*) from public.alternativas where questao_id = 351) <> 5 then
    raise exception 'POSCOND: Q351 perdeu a contagem de 5 alternativas';
  end if;
  if (select chr(64+ordem) from public.alternativas where questao_id = 351 and correta = true) <> 'B' then
    raise exception 'POSCOND: Q351 gabarito mudou';
  end if;

  raise notice 'POSCONDICOES OK: globais inalterados (questoes=%, alternativas=%, vinculos=%, DH uteis=%) | 20/20 NEW_MD5 | 20/20 FINGERPRINT_IMUTAVEL preservado', v_questoes, v_alternativas, v_vinculos, v_dh_uteis;
end $$;

commit;
