-- IMPORTACAO LOTE09A_LEGISLACAO_ESPECIFICA — 17 questoes autorais para 4
-- unidades de Legislacao Especifica (curso Brigada Militar RS): Poderes da
-- Administracao Publica (+4), Poder de Policia (+6), Estatuto Nacional da
-- Igualdade Racial (+5), Direito Administrativo (+2).
--
-- Human sign-off explicito, revisao final unica (mandato "PAPIRO — LOTE 09A —
-- HUMAN REVIEW FINAL — 2 CORRECOES DOCUMENTAIS + FREEZE 17 + IMPORTACAO +
-- POS-CHECK + COMMIT/PUSH"). 17 SELECTED. 5 APPROVED_RESERVE (PA-05, PA-06,
-- ER-12, DA-06, DA-07) — NAO importadas nesta fase. 2 REJECTED_PRE_AUDIT
-- (PP-14, PP-16 — lacuna do regex de diploma para nomes populares de codigo,
-- TECH_DEBT_NORMATIVE_REFERENCE_CODE_NAME_REGEX, nao corrigida neste lote).
-- 24 candidatas V1 REJECTED_PROCESS_BUG_PROMPT_CONFLICT — apenas audit trail.
--
-- Correcoes humanas obrigatorias aplicadas antes do freeze:
-- ER-09: fundamento.referencia corrigido de "art.39,§1º" para "art.39,caput"
--   (o texto testado e do caput; par.1o trata de outra regra — formacao
--   profissional/emprego/renda). Enunciado/alternativas/gabarito mantidos.
-- ER-12 (reserva, NAO importada): alternativa C e explicacao reescritas para
--   remover afirmacao de dever de adaptar legislacao/procedimentos, sem
--   correspondencia no art.58 real. Gabarito C mantido.
-- Fonte reconciliada: bmrs-legislacao-estatuto-nacional-igualdade-racial.json
--   (art.39 caput/§1º relabeled corretamente; clausula fabricada removida do
--   texto_consolidado do art.58; campo PEDAGOGICAL_METADATA_ARTICLE_MAPPING_NOTE
--   adicionado). covers_articles preservado sem alteracao (exigido pelo
--   source validator).
--
-- Padrao identico aos lotes precedentes: staging de questoes/explicacoes/
-- alternativas, insercao por INSERT direto em questoes/alternativas (nunca
-- em questao_unidades_pedagogicas), vinculo exclusivamente via
-- classificar_questao_unidade_admin (RPC que sincroniza curso_questoes
-- automaticamente).
--
-- NAO altera nenhuma questao existente nas 4 unidades.
-- NAO altera unidades/conteudos/materias/aulas. NAO cria migration/schema.
--
-- Texto final persistido em
-- outputs/curadoria-autoral/review/LOTE09A-LEGISLACAO-HUMAN-REVIEW-V2.md,
-- congelado em outputs/curadoria-autoral/review/LOTE09A-FROZEN-17.json
-- (corpus_hash d47a92d97c1e8596103438035c5a725b8f31350d9870dd05eb65dca2ecf2f37a).
--
-- ROLLBACK-TESTADO em importar_lote09a_legislacao_especifica_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_lote09a_legislacao_especifica.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;

insert into _lote_questoes (ordem, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 59, $D1$media$D1$, $FONTE1$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PA-07$FONTE1$, $ENUN1$Uma lei federal disciplinou a concessão de determinado benefício administrativo e estabeleceu, de forma exaustiva, os requisitos para sua obtenção. Posteriormente, decreto presidencial editado para regulamentar a lei passou a exigir do interessado a apresentação de certidão adicional e a comprovação de condição não prevista no texto legal, sob pena de indeferimento do pedido. À luz do poder regulamentar, assinale a alternativa correta.$ENUN1$),
(2, 59, $D2$media$D2$, $FONTE2$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PA-08$FONTE2$, $ENUN2$A lei que organiza determinado órgão público atribui expressamente ao Secretário da Pasta a competência para aplicar a sanção administrativa de suspensão a empresas contratadas pelo Poder Público. Durante a ausência temporária do Secretário, um diretor do órgão, sem delegação e sem previsão legal que lhe atribua essa competência, aplica diretamente a sanção a uma empresa. Nessa situação, o ato praticado pelo diretor caracteriza$ENUN2$),
(3, 59, $D3$media$D3$, $FONTE3$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PA-09$FONTE3$, $ENUN3$Um prefeito determinou a remoção de um servidor para outra unidade administrativa. Embora a remoção estivesse formalmente dentro de sua esfera de atribuições, ficou comprovado que a medida foi adotada exclusivamente como retaliação às críticas feitas pelo servidor à gestão municipal, e não para atender a qualquer necessidade do serviço público. Nessa situação, o ato administrativo apresenta$ENUN3$),
(4, 59, $D4$media$D4$, $FONTE4$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PA-10$FONTE4$, $ENUN4$Após a edição de uma lei federal que estabelece normas gerais sobre determinada atividade administrativa, pretende-se expedir decreto para detalhar os procedimentos necessários à sua fiel execução, sem inovar autonomamente na ordem jurídica. Nos termos da Constituição Federal, a competência para expedir esse decreto regulamentar é do$ENUN4$),
(5, 60, $D5$media$D5$, $FONTE5$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-09$FONTE5$, $ENUN5$Nos termos do Código Tributário Nacional, uma atuação administrativa será considerada exercício regular do poder de polícia quando$ENUN5$),
(6, 60, $D6$media$D6$, $FONTE6$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-10$FONTE6$, $ENUN6$De acordo com o conceito legal de poder de polícia previsto no Código Tributário Nacional, a limitação ou disciplina de direito, interesse ou liberdade pode ocorrer, entre outros motivos de interesse público, em razão de$ENUN6$),
(7, 60, $D7$media$D7$, $FONTE7$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-11$FONTE7$, $ENUN7$No exercício de fiscalização administrativa de segurança, um agente público constata irregularidade em estabelecimento particular. Embora possa instaurar o procedimento cabível, afirma ao responsável que deixará de registrar a ocorrência caso receba vantagem pessoal. À luz dos princípios aplicáveis à atuação administrativa, assinale a alternativa correta.$ENUN7$),
(8, 60, $D8$media$D8$, $FONTE8$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-12$FONTE8$, $ENUN8$Durante fiscalização urbanística, a Administração verifica que um comércio instalou uma placa em desacordo com exigência administrativa, mas a irregularidade pode ser corrigida mediante simples adequação do equipamento. Sem examinar medidas menos gravosas, a autoridade determina o fechamento integral e imediato do estabelecimento por prazo indeterminado. Considerando o princípio da proporcionalidade no exercício do poder de polícia, assinale a alternativa correta.$ENUN8$),
(9, 60, $D9$media$D9$, $FONTE9$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-13$FONTE9$, $ENUN9$Durante fiscalização de segurança em estabelecimento particular, a autoridade administrativa determinou a suspensão imediata de uma atividade, limitando-se a registrar que a medida era “necessária ao interesse público”, sem apontar as circunstâncias verificadas nem a base jurídica da decisão. À luz do princípio da motivação, a conduta é$ENUN9$),
(10, 60, $D10$media$D10$, $FONTE10$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — PP-15$FONTE10$, $ENUN10$No planejamento de fiscalizações de segurança em estabelecimentos privados, a Administração dispõe de equipes limitadas e identifica locais com maior fluxo de pessoas e histórico de irregularidades. À luz do princípio da eficiência, a conduta mais adequada é:$ENUN10$),
(11, 67, $D11$media$D11$, $FONTE11$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — ER-09$FONTE11$, $ENUN11$Nos termos do Estatuto da Igualdade Racial, assinale a alternativa correta acerca da promoção da igualdade de oportunidades no mercado de trabalho.$ENUN11$),
(12, 67, $D12$media$D12$, $FONTE12$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — ER-10$FONTE12$, $ENUN12$De acordo com o Estatuto da Igualdade Racial, o Poder Executivo federal poderá implementar critérios para o provimento de cargos em comissão e funções de confiança com a finalidade de ampliar a participação de negros. Para tanto, tais critérios devem observar:$ENUN12$),
(13, 67, $D13$media$D13$, $FONTE13$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — ER-11$FONTE13$, $ENUN13$No âmbito da organização institucional da Política Nacional de Promoção da Igualdade Racial (PNPIR), assinale a alternativa correta acerca da elaboração das diretrizes das políticas nacional e regional de promoção da igualdade étnica.$ENUN13$),
(14, 67, $D14$media$D14$, $FONTE14$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — ER-13$FONTE14$, $ENUN14$Nos termos do Estatuto Nacional da Igualdade Racial, assinale a alternativa correta acerca dos critérios para o provimento de cargos em comissão e funções de confiança.$ENUN14$),
(15, 67, $D15$media$D15$, $FONTE15$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — ER-14$FONTE15$, $ENUN15$A respeito da relação entre as medidas previstas no Estatuto Nacional da Igualdade Racial e outras iniciativas estatais de promoção da igualdade racial, assinale a alternativa correta.$ENUN15$),
(16, 58, $D16$media$D16$, $FONTE16$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — DA-05$FONTE16$, $ENUN16$Durante a análise de um pedido administrativo, a autoridade competente observa todos os requisitos formais previstos e pratica ato que, em tese, está dentro de sua competência. Contudo, fica demonstrado que ela conduziu o procedimento com a intenção de prejudicar o requerente em razão de desavença pessoal antiga, valendo-se de justificativas apenas aparentes. Nessa situação, a conduta contraria principalmente o princípio da$ENUN16$),
(17, 58, $D17$media$D17$, $FONTE17$PAPIRO — LOTE09A_LEGISLACAO_ESPECIFICA — DA-08$FONTE17$, $ENUN17$Um gestor público determina que requerimentos administrativos de cidadãos identificados como opositores políticos de sua gestão sejam analisados somente depois dos requerimentos apresentados por seus apoiadores, embora todos preencham os mesmos requisitos e tenham sido protocolados na mesma data. Considerando a distinção entre impessoalidade e moralidade administrativa, assinale a alternativa correta.$ENUN17$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$O poder regulamentar permite a expedição de decretos e regulamentos para viabilizar a fiel execução da lei, não para criar requisitos, obrigações ou restrições materiais que o legislador não estabeleceu. No caso, a exigência de condição adicional para a obtenção do benefício extrapola o conteúdo legal. A alternativa A erra ao admitir complementação livre da lei; C erra porque a natureza procedimental do tema não autoriza inovação normativa; D desloca indevidamente a discussão para competência hierárquica; e E contraria o limite legal da atuação administrativa.

FUNDAMENTO: Constituição Federal, art. 84, IV. — Compete privativamente ao Presidente da República expedir decretos e regulamentos para a fiel execução das leis. Assim, o regulamento não pode inovar criando restrição ou requisito material não previsto na lei regulamentada.$EXPL1$),
(2, $EXPL2$O diretor praticou ato para o qual não possuía competência legal, nem recebeu delegação. Trata-se de incompetência, vício associado ao excesso de poder, que torna nulo o ato administrativo. A alternativa A está errada porque desvio de finalidade pressupõe finalidade diversa da prevista, hipótese não narrada. C trata de poder regulamentar, estranho ao caso. D erra porque a vinculação ao mesmo órgão não supre a competência legal. E é incorreta, pois a ausência temporária do titular não transfere automaticamente competências a outro agente.

FUNDAMENTO: Lei nº 4.717/1965, art. 2º, parágrafo único, alínea a. — A incompetência é caracterizada quando o ato não se inclui nas atribuições legais do agente que o praticou e constitui vício que acarreta a nulidade do ato administrativo.$EXPL2$),
(3, $EXPL3$Há desvio de finalidade quando o agente competente pratica o ato para alcançar objetivo diverso daquele que justificaria o exercício da competência. No caso, a remoção foi empregada como retaliação pessoal, e não em atendimento ao interesse público e às necessidades do serviço. A alternativa B está errada porque não há incompetência da autoridade, mas uso da competência para finalidade indevida. As alternativas C e D desconsideram que o vício de finalidade torna o ato nulo. A alternativa E trata de revogação, que incide sobre ato válido por razões de conveniência e oportunidade, o que não corresponde ao caso.

FUNDAMENTO: Lei nº 4.717/1965, art. 2º, parágrafo único, alínea "e". — Considera-se desvio de finalidade o ato praticado visando a fim diverso daquele previsto, explícita ou implicitamente, na regra de competência.$EXPL3$),
(4, $EXPL4$Compete privativamente ao Presidente da República expedir decretos e regulamentos para a fiel execução das leis. O decreto regulamentar pressupõe lei preexistente e deve atuar de modo subordinado a ela, viabilizando sua execução, sem substituí-la. O Congresso Nacional edita leis e decretos legislativos, mas não exerce essa competência regulamentar presidencial. Ministros de Estado não detêm, por si sós, a competência constitucional indicada no enunciado, e tampouco ela cabe ao Supremo Tribunal Federal ou ao Presidente do Senado Federal.

FUNDAMENTO: Constituição Federal, art. 84, inciso IV. — Compete privativamente ao Presidente da República sancionar, promulgar e fazer publicar as leis, bem como expedir decretos e regulamentos para sua fiel execução.$EXPL4$),
(5, $EXPL5$O exercício do poder de polícia é regular quando realizado pelo órgão competente, dentro dos limites da lei aplicável e com observância do processo legal. Além disso, nas atividades que a lei qualificar como discricionárias, não pode haver abuso nem desvio de poder. A alternativa A erra ao ignorar a exigência de competência do órgão e os demais requisitos legais. A C admite atuação por órgão incompetente, o que contraria o dispositivo. A D afasta indevidamente o processo legal. A E desconsidera que a atuação administrativa deve respeitar os limites legais.

FUNDAMENTO: Código Tributário Nacional (Lei nº 5.172/1966), art. 78, parágrafo único. — Considera-se regular o exercício do poder de polícia quando desempenhado pelo órgão competente, nos limites da lei aplicável, com observância do processo legal e, em atividade discricionária, sem abuso ou desvio de poder.$EXPL5$),
(6, $EXPL6$O art. 78 do CTN inclui, entre os motivos de interesse público que legitimam o poder de polícia, a segurança, a higiene, a ordem, os costumes e a disciplina da produção e do mercado. A alternativa B introduz elementos que não compõem a enumeração legal. A C inclui arrecadação tributária e conveniência política, que não são os motivos listados no dispositivo. A D trata de aspectos próprios da organização interna administrativa e do poder hierárquico. A E contradiz a possibilidade de limitação administrativa fundada no interesse público.

FUNDAMENTO: Código Tributário Nacional (Lei nº 5.172/1966), art. 78, caput. — O conceito legal de poder de polícia abrange a atividade administrativa que limita ou disciplina direitos, interesses ou liberdades em razão de interesse público concernente, entre outros, à segurança, à higiene, à ordem, aos costumes e à disciplina da produção e do mercado.$EXPL6$),
(7, $EXPL7$A alternativa B está correta. A moralidade é princípio expresso da atuação administrativa e impede que o agente utilize a atividade de polícia para obter benefício particular. A fiscalização deve ser conduzida em atenção à finalidade pública. A alternativa A é incorreta porque eventual margem de atuação não autoriza desvio ético ou busca de proveito pessoal. A C erra ao relacionar o caso exclusivamente à proporcionalidade e ao afirmar que a interdição é obrigatória em toda situação. A D é falsa, pois a anuência do particular não legitima vantagem pessoal ao agente. A E é incorreta porque o poder hierárquico incide internamente sobre subordinados da Administração, não fundamentando tratativas dessa natureza com particulares.

FUNDAMENTO: Lei nº 9.784/1999, art. 2º, caput. — O dispositivo determina que a Administração Pública observe, entre outros, o princípio da moralidade em sua atuação.$EXPL7$),
(8, $EXPL8$A alternativa C está correta. No exercício do poder de polícia, a Administração deve adequar os meios aos fins e não impor restrição mais intensa do que a estritamente necessária para proteger o interesse público. No caso, se a irregularidade é corrigível por providência menos gravosa, o fechamento integral e por prazo indeterminado, sem essa avaliação, pode ser desproporcional. A alternativa A erra porque a autoexecutoriedade, quando incidente, não elimina os limites legais e proporcionais da atuação. A B é falsa porque a prática de infração não autoriza automaticamente qualquer medida restritiva. A D é incorreta, pois o poder de polícia não depende sempre de prévia autorização judicial. A E confunde poder de polícia, incidente sobre particulares, com poder hierárquico, exercido internamente sobre subordinados da Administração.

FUNDAMENTO: Lei nº 9.784/1999, art. 2º, caput e parágrafo único, inciso VI. — A Administração deve observar o princípio da proporcionalidade, sendo vedada a imposição de obrigações, restrições e sanções em medida superior à estritamente necessária ao atendimento do interesse público.$EXPL8$),
(9, $EXPL9$A motivação exige que a Administração exponha os fatos apurados e os fundamentos jurídicos que justificam a decisão. A mera referência abstrata ao interesse público não permite identificar as razões concretas da suspensão. A competência do agente não elimina o dever de motivar (alternativa C), nem há prazo mínimo para que esse dever exista (D). A discricionariedade, quando presente, não afasta a motivação (E), e o interesse público deve ser concretamente demonstrado no ato, não apenas mencionado de modo genérico (A).

FUNDAMENTO: Lei nº 9.784/1999, art. 2º, caput e parágrafo único, inciso VII. — A Administração deve observar, entre outros, o princípio da motivação, com indicação dos pressupostos de fato e de direito que determinam a decisão.$EXPL9$),
(10, $EXPL10$O princípio da eficiência exige atuação administrativa orientada à obtenção de resultados adequados, com racionalização dos recursos disponíveis e organização do serviço público. Assim, é compatível com esse princípio priorizar fiscalizações segundo critérios objetivos relacionados ao risco, desde que sejam respeitados a legalidade, a proporcionalidade e os demais limites da atuação administrativa. A alternativa B estabelece discriminação sem critério pertinente; a C pretende afastar a legalidade; a D desconsidera a proporcionalidade; e a E elimina indevidamente a própria atividade de polícia.

FUNDAMENTO: Lei nº 9.784/1999, art. 2º, caput. — A Administração Pública obedecerá, entre outros, ao princípio da eficiência, aplicável ao exercício de suas atividades, inclusive às medidas de poder de polícia.$EXPL10$),
(11, $EXPL11$A alternativa B reproduz o comando legal: o Poder Público deve promover ações para assegurar a igualdade de oportunidades no mercado de trabalho, abrangendo as contratações do setor público e o incentivo a medidas semelhantes no setor privado. A está errada porque a lei não restringe as ações à reserva de vagas nem proíbe incentivos ao setor privado. C indevidamente limita a proteção a determinado vínculo com a Administração. D atribui à lei uma imposição geral e uniforme às empresas privadas, quando o dispositivo prevê incentivo à adoção de medidas similares. E cria condição não prevista na norma.

FUNDAMENTO: Lei nº 12.288/2010 (Estatuto da Igualdade Racial), art. 39, caput. — O Poder Público promoverá ações que assegurem a igualdade de oportunidades no mercado de trabalho, inclusive nas contratações do setor público e mediante incentivo à adoção de medidas similares nas empresas e organizações privadas.$EXPL11$),
(12, $EXPL12$A alternativa B está correta, pois a lei autoriza o Poder Executivo federal a implementar critérios para ampliar a participação de negros em cargos em comissão e funções de confiança, buscando reproduzir a estrutura da distribuição étnica nacional ou, conforme o caso, estadual, com observância dos dados demográficos oficiais. A reduz indevidamente o parâmetro às inscrições em concurso. C prevê recorte municipal não indicado no dispositivo. D cria percentual único obrigatório, o que não consta da norma. E afasta justamente a exigência legal de observância dos dados demográficos oficiais.

FUNDAMENTO: Lei nº 12.288/2010 (Estatuto da Igualdade Racial), art. 42, caput. — O Poder Executivo federal poderá implementar critérios para provimento de cargos em comissão e funções de confiança destinados a ampliar a participação de negros, buscando reproduzir a estrutura da distribuição étnica nacional ou, quando for o caso, estadual, observados os dados demográficos oficiais.$EXPL12$),
(13, $EXPL13$A alternativa B está correta, pois a Lei nº 12.288/2010 determina que as diretrizes das políticas nacional e regional de promoção da igualdade étnica sejam elaboradas por órgão colegiado que assegure a participação da sociedade civil. As demais alternativas criam formas de elaboração não previstas no dispositivo, como exclusividade do Poder Executivo, atuação do Poder Legislativo, comissões apenas governamentais ou delegação a entidade privada.

FUNDAMENTO: Lei nº 12.288/2010, art. 49, § 3º. — As diretrizes das políticas nacional e regional de promoção da igualdade étnica serão elaboradas por órgão colegiado que assegure a participação da sociedade civil.$EXPL13$),
(14, $EXPL14$A alternativa B está correta, pois o Estatuto confere ao Poder Público uma faculdade: poderá implementar critérios para o provimento de cargos em comissão e funções de confiança, visando ampliar a participação de negros. Esses critérios devem buscar reproduzir a distribuição étnica nacional ou, quando cabível, a estadual, observados os dados demográficos oficiais. A alternativa A erra ao transformar a medida em dever e ao prever percentual fixo e periodicidade não estabelecidos na lei. A C restringe indevidamente o parâmetro ao Município. A D exclui cargos em comissão e funções de confiança, que são justamente os previstos no dispositivo. A E erra ao afirmar obrigatoriedade absoluta e ao afastar a possibilidade de consideração da distribuição étnica estadual.

FUNDAMENTO: Lei nº 12.288/2010 (Estatuto Nacional da Igualdade Racial), art. 42, caput. — Autoriza o Poder Público a implementar critérios para o provimento de cargos em comissão e funções de confiança, a fim de ampliar a participação de negros, considerando a distribuição étnica nacional ou, quando for o caso, estadual, com base em dados demográficos oficiais.$EXPL14$),
(15, $EXPL15$A alternativa C reproduz o sentido do Estatuto: as medidas por ele instituídas não afastam outras medidas em prol da população negra, tanto as já adotadas quanto as que venham a ser adotadas pelo Poder Público. Portanto, o Estatuto não funciona como rol exaustivo nem impede iniciativas complementares. A alternativa A afirma precisamente o oposto. A B cria exigência de autorização federal não prevista no dispositivo. A D confunde complementariedade com substituição. A E restringe indevidamente a regra a medidas futuras, embora a lei também contemple as que já tenham sido adotadas.

FUNDAMENTO: Lei nº 12.288/2010 (Estatuto Nacional da Igualdade Racial), art. 58, caput. — Estabelece que as medidas instituídas pela Lei não excluem outras, em prol da população negra, que tenham sido ou venham a ser adotadas pelo Poder Público.$EXPL15$),
(16, $EXPL16$A alternativa A está correta. O princípio da moralidade exige que a atuação administrativa seja compatível com padrões de ética, boa-fé, lealdade e probidade. Assim, a observância meramente formal de competência e procedimento não legitima um ato praticado com finalidade pessoal de prejudicar o administrado. A publicidade (B) refere-se à divulgação e à transparência dos atos, não sendo o ponto central do caso. A eficiência (C) não fixa, no art. 37, caput, prazo geral de cinco dias úteis para decisões administrativas. A autotutela (D) permite à própria Administração controlar seus atos, não dependendo necessariamente de autorização judicial. A continuidade do serviço público (E) não é o princípio diretamente relacionado à finalidade antiética descrita.

FUNDAMENTO: Constituição Federal de 1988, art. 37, caput. — O dispositivo estabelece que a Administração Pública deve obedecer, entre outros, ao princípio da moralidade.$EXPL16$),
(17, $EXPL17$A alternativa A está correta. A impessoalidade exige que a Administração atue em função do interesse público, sem privilegiar ou prejudicar administrados por razões pessoais, políticas ou similares. A postergação dirigida aos opositores caracteriza tratamento personalizado e incompatível com esse princípio. A moralidade é princípio distinto: relaciona-se à exigência de comportamento ético, probo e de boa-fé. A alternativa B restringe indevidamente a impessoalidade; C e E tentam legitimar um critério pessoal de preferência incompatível com a finalidade pública; e D inverte os conteúdos próprios dos princípios.

FUNDAMENTO: Constituição Federal de 1988, art. 37, caput. — O dispositivo estabelece a impessoalidade e a moralidade como princípios expressos da Administração Pública. A impessoalidade veda a atuação orientada por favoritismo ou perseguição pessoal, impondo direcionamento à finalidade pública.$EXPL17$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$O decreto é válido, pois o Poder Executivo pode complementar livremente a lei sempre que pretender aperfeiçoar sua aplicação.$ALT1_1$, false),
(1, 2, $ALT1_2$O decreto é inválido na parte em que cria exigências materiais não previstas em lei, pois o poder regulamentar destina-se à fiel execução da lei.$ALT1_2$, true),
(1, 3, $ALT1_3$O decreto é válido, pois todo regulamento pode inovar na ordem jurídica desde que trate de procedimento administrativo.$ALT1_3$, false),
(1, 4, $ALT1_4$O decreto é inválido apenas se tiver sido editado por autoridade sem competência hierárquica sobre os agentes que analisarão os pedidos.$ALT1_4$, false),
(1, 5, $ALT1_5$O decreto é válido, porque a Administração Pública pode impor restrições aos particulares ainda que não exista previsão legal específica.$ALT1_5$, false),
(2, 1, $ALT2_1$desvio de finalidade, pois a sanção foi aplicada por agente público no exercício de suas funções.$ALT2_1$, false),
(2, 2, $ALT2_2$excesso de poder, por incompetência do agente que praticou ato fora de sua atribuição legal.$ALT2_2$, true),
(2, 3, $ALT2_3$regular exercício do poder regulamentar, pois a Administração pode detalhar a aplicação das sanções previstas em lei.$ALT2_3$, false),
(2, 4, $ALT2_4$mera irregularidade sem repercussão sobre a validade do ato, pois o diretor integra o mesmo órgão do Secretário.$ALT2_4$, false),
(2, 5, $ALT2_5$convalidação automática do ato, pois a ausência temporária do titular transfere todas as suas competências ao subordinado imediato.$ALT2_5$, false),
(3, 1, $ALT3_1$desvio de finalidade, pois foi praticado visando a fim diverso daquele previsto na regra de competência.$ALT3_1$, true),
(3, 2, $ALT3_2$excesso de poder, pois a autoridade praticou ato fora de sua competência legal.$ALT3_2$, false),
(3, 3, $ALT3_3$mera irregularidade formal, que não compromete a validade do ato.$ALT3_3$, false),
(3, 4, $ALT3_4$convalidação automática, pois a autoridade possuía competência para determinar a remoção.$ALT3_4$, false),
(3, 5, $ALT3_5$revogação obrigatória, por motivo de conveniência administrativa.$ALT3_5$, false),
(4, 1, $ALT4_1$Presidente da República.$ALT4_1$, true),
(4, 2, $ALT4_2$Congresso Nacional, mediante decreto legislativo.$ALT4_2$, false),
(4, 3, $ALT4_3$Supremo Tribunal Federal, mediante resolução administrativa.$ALT4_3$, false),
(4, 4, $ALT4_4$Ministro de Estado da área competente, independentemente de delegação ou previsão legal.$ALT4_4$, false),
(4, 5, $ALT4_5$Presidente do Senado Federal, por se tratar de norma federal.$ALT4_5$, false),
(5, 1, $ALT5_1$for praticada por qualquer agente público, desde que voltada à proteção do interesse coletivo.$ALT5_1$, false),
(5, 2, $ALT5_2$for desempenhada pelo órgão competente, nos limites da lei aplicável, com observância do processo legal e, se a atividade for discricionária, sem abuso ou desvio de poder.$ALT5_2$, true),
(5, 3, $ALT5_3$resultar em benefício à coletividade, ainda que o órgão atuante não detenha competência legal específica.$ALT5_3$, false),
(5, 4, $ALT5_4$decorrer de atividade discricionária, sendo dispensável a observância do processo legal diante da urgência administrativa.$ALT5_4$, false),
(5, 5, $ALT5_5$for executada diretamente pela Administração, independentemente dos limites estabelecidos na legislação aplicável.$ALT5_5$, false),
(6, 1, $ALT6_1$segurança, higiene, ordem, costumes e disciplina da produção e do mercado.$ALT6_1$, true),
(6, 2, $ALT6_2$segurança, eficiência administrativa, liberdade econômica e disciplina partidária.$ALT6_2$, false),
(6, 3, $ALT6_3$higiene, arrecadação tributária, conveniência política e proteção patrimonial do Estado.$ALT6_3$, false),
(6, 4, $ALT6_4$ordem, supremacia hierárquica, disciplina funcional e organização interna dos órgãos públicos.$ALT6_4$, false),
(6, 5, $ALT6_5$costumes, autonomia privada absoluta, livre iniciativa irrestrita e interesse exclusivo do particular.$ALT6_5$, false),
(7, 1, $ALT7_1$A conduta é regular, pois o poder de polícia permite ao agente avaliar livremente a conveniência de formalizar a ocorrência.$ALT7_1$, false),
(7, 2, $ALT7_2$A conduta viola o princípio da moralidade, pois o exercício da função administrativa deve observar padrões éticos e ser orientado à finalidade pública, e não ao interesse pessoal do agente.$ALT7_2$, true),
(7, 3, $ALT7_3$A conduta viola exclusivamente o princípio da proporcionalidade, pois toda fiscalização deve resultar na interdição imediata do estabelecimento.$ALT7_3$, false),
(7, 4, $ALT7_4$A conduta é admitida se o estabelecimento concordar com a vantagem, pois se trata de relação entre particular e Administração.$ALT7_4$, false),
(7, 5, $ALT7_5$A conduta decorre do poder hierárquico, que autoriza o agente a negociar a solução da irregularidade com o administrado.$ALT7_5$, false),
(8, 1, $ALT8_1$A medida é necessariamente válida, pois a autoexecutoriedade permite à Administração impor qualquer restrição que considere conveniente.$ALT8_1$, false),
(8, 2, $ALT8_2$A medida é adequada, pois a existência de infração administrativa sempre autoriza o fechamento integral do estabelecimento.$ALT8_2$, false),
(8, 3, $ALT8_3$A medida pode afrontar a proporcionalidade, pois devem ser escolhidos meios adequados ao fim público, vedada a imposição de restrição superior à estritamente necessária.$ALT8_3$, true),
(8, 4, $ALT8_4$A medida é inválida exclusivamente porque o poder de polícia somente pode ser exercido após autorização judicial.$ALT8_4$, false),
(8, 5, $ALT8_5$A medida caracteriza exercício do poder hierárquico, pois a Administração controla a atividade de particulares sujeitos à fiscalização.$ALT8_5$, false),
(9, 1, $ALT9_1$regular, pois a invocação genérica do interesse público supre a indicação das razões do ato de polícia.$ALT9_1$, false),
(9, 2, $ALT9_2$irregular, pois a decisão deve indicar os pressupostos de fato e de direito que a determinaram.$ALT9_2$, true),
(9, 3, $ALT9_3$regular, desde que a medida seja praticada por agente competente, sendo dispensável a exposição de fundamentos.$ALT9_3$, false),
(9, 4, $ALT9_4$irregular apenas se a suspensão tiver duração superior a trinta dias, hipótese em que surge o dever de motivar.$ALT9_4$, false),
(9, 5, $ALT9_5$regular, pois atos de polícia administrativa são discricionários e, por isso, não comportam motivação.$ALT9_5$, false),
(10, 1, $ALT10_1$concentrar as fiscalizações nos locais previamente selecionados, com critérios objetivos de prioridade e emprego racional das equipes, sem afastar os demais princípios aplicáveis.$ALT10_1$, true),
(10, 2, $ALT10_2$fiscalizar exclusivamente os estabelecimentos de maior porte, ainda que não apresentem risco ou indícios de irregularidade.$ALT10_2$, false),
(10, 3, $ALT10_3$deixar de observar exigências legais para tornar a fiscalização mais rápida e ampliar o número de vistorias.$ALT10_3$, false),
(10, 4, $ALT10_4$aplicar a medida mais gravosa disponível em toda irregularidade, como forma de aumentar a produtividade administrativa.$ALT10_4$, false),
(10, 5, $ALT10_5$substituir a atuação fiscalizatória por orientações informais, pois a eficiência impede a prática de atos administrativos.$ALT10_5$, false),
(11, 1, $ALT11_1$O Poder Público deve limitar suas ações à reserva de vagas em concursos públicos, sendo vedado incentivar iniciativas adotadas por empresas privadas.$ALT11_1$, false),
(11, 2, $ALT11_2$O Poder Público promoverá ações que assegurem a igualdade de oportunidades no mercado de trabalho, inclusive nas contratações do setor público e mediante incentivo à adoção de medidas similares nas empresas e organizações privadas.$ALT11_2$, true),
(11, 3, $ALT11_3$A igualdade de oportunidades no mercado de trabalho é assegurada exclusivamente aos trabalhadores negros contratados pela administração pública direta.$ALT11_3$, false),
(11, 4, $ALT11_4$As empresas privadas são obrigadas a adotar critérios uniformes de contratação definidos previamente pelo Poder Executivo federal.$ALT11_4$, false),
(11, 5, $ALT11_5$As ações de igualdade no mercado de trabalho dependem de prévia declaração individual de discriminação racial pelo trabalhador interessado.$ALT11_5$, false),
(12, 1, $ALT12_1$a proporção de candidatos negros inscritos no último concurso público federal.$ALT12_1$, false),
(12, 2, $ALT12_2$a estrutura da distribuição étnica nacional ou, quando for o caso, estadual, observados os dados demográficos oficiais.$ALT12_2$, true),
(12, 3, $ALT12_3$exclusivamente a distribuição étnica do Município em que estiver sediado o órgão público.$ALT12_3$, false),
(12, 4, $ALT12_4$percentual fixo e uniforme para todos os órgãos e entidades da Administração Pública brasileira.$ALT12_4$, false),
(12, 5, $ALT12_5$a autodeclaração dos ocupantes dos cargos, dispensada qualquer referência a dados demográficos.$ALT12_5$, false),
(13, 1, $ALT13_1$Serão elaboradas exclusivamente pelo órgão central da Administração Pública federal, dispensada a participação social.$ALT13_1$, false),
(13, 2, $ALT13_2$Serão elaboradas por órgão colegiado que assegure a participação da sociedade civil.$ALT13_2$, true),
(13, 3, $ALT13_3$Serão definidas pelo Poder Legislativo federal, após consulta obrigatória aos Estados e Municípios.$ALT13_3$, false),
(13, 4, $ALT13_4$Serão estabelecidas por comissões temporárias compostas apenas por representantes dos entes federativos.$ALT13_4$, false),
(13, 5, $ALT13_5$Serão elaboradas por entidade privada credenciada pelo Poder Executivo, com posterior homologação ministerial.$ALT13_5$, false),
(14, 1, $ALT14_1$O Poder Público deverá reservar percentual fixo de cargos em comissão para pessoas negras, conforme censo realizado a cada quatro anos.$ALT14_1$, false),
(14, 2, $ALT14_2$O Poder Público poderá implementar critérios destinados a ampliar a participação de negros, buscando reproduzir a estrutura da distribuição étnica nacional ou, quando for o caso, estadual, com observância dos dados demográficos oficiais.$ALT14_2$, true),
(14, 3, $ALT14_3$Os critérios de participação de negros em cargos em comissão dependem exclusivamente da distribuição étnica do Município em que estiver sediado o órgão público.$ALT14_3$, false),
(14, 4, $ALT14_4$A ampliação da participação de negros aplica-se somente aos cargos efetivos providos mediante concurso público.$ALT14_4$, false),
(14, 5, $ALT14_5$A adoção de critérios para cargos em comissão exige a reprodução obrigatória e integral da distribuição étnica nacional, sem considerar dados estaduais.$ALT14_5$, false),
(15, 1, $ALT15_1$As medidas instituídas pelo Estatuto excluem a adoção de outras ações em favor da população negra, para assegurar uniformidade nacional.$ALT15_1$, false),
(15, 2, $ALT15_2$Estados, Distrito Federal e Municípios somente podem instituir medidas de promoção da igualdade racial após autorização expressa da União.$ALT15_2$, false),
(15, 3, $ALT15_3$As medidas instituídas pelo Estatuto não excluem outras, em prol da população negra, que tenham sido ou venham a ser adotadas pelo Poder Público.$ALT15_3$, true),
(15, 4, $ALT15_4$A adoção de medidas locais em prol da população negra depende da substituição integral das medidas previstas no Estatuto.$ALT15_4$, false),
(15, 5, $ALT15_5$Somente medidas posteriores à vigência do Estatuto podem ser adotadas pelo Poder Público em favor da população negra.$ALT15_5$, false),
(16, 1, $ALT16_1$moralidade administrativa, pois a atuação estatal deve observar padrões éticos, de lealdade e de boa-fé, além da aparência de regularidade formal.$ALT16_1$, true),
(16, 2, $ALT16_2$publicidade, pois todo ato administrativo deve ser divulgado individualmente em meio oficial, ainda que não produza efeitos externos.$ALT16_2$, false),
(16, 3, $ALT16_3$eficiência, pois a Administração é obrigada a decidir todos os requerimentos no prazo máximo de cinco dias úteis.$ALT16_3$, false),
(16, 4, $ALT16_4$autotutela, pois a Administração somente pode rever seus atos mediante autorização judicial.$ALT16_4$, false),
(16, 5, $ALT16_5$continuidade do serviço público, pois é vedada qualquer alteração na motivação dos atos administrativos.$ALT16_5$, false),
(17, 1, $ALT17_1$A medida viola predominantemente a impessoalidade, pois estabelece favorecimento e perseguição fundados em vínculo político, em vez de orientar a atuação pela finalidade pública; a moralidade possui conteúdo próprio, ligado à ética e à boa-fé administrativas.$ALT17_1$, true),
(17, 2, $ALT17_2$A medida viola apenas a moralidade, pois a impessoalidade impede exclusivamente a divulgação do nome do agente público.$ALT17_2$, false),
(17, 3, $ALT17_3$Não há violação à impessoalidade, porque o gestor pode definir livremente a ordem de análise dos requerimentos segundo suas preferências pessoais.$ALT17_3$, false),
(17, 4, $ALT17_4$A impessoalidade exige que todo agente público atue com boa-fé, enquanto a moralidade se limita à proibição de favoritismos e perseguições.$ALT17_4$, false),
(17, 5, $ALT17_5$A medida é compatível com a impessoalidade, desde que os requerimentos sejam posteriormente apreciados e não sejam formalmente indeferidos.$ALT17_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 4, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid),
(5, 10, '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid),
(11, 15, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid),
(16, 17, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid);

-- ================= PRECONDICOES =================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
  r record;
begin
  for r in select unidade_pedagogica_id, ordem_min, ordem_max from _unidades_ordem loop
    select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
    into v_unidade_ok
    from public.unidades_pedagogicas up
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where up.id = r.unidade_pedagogica_id;
    if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade % nao esta ativa/relevante conforme esperado', r.unidade_pedagogica_id; end if;

    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
           count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
      into v_real, v_autoral
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(*) into v_gap
    from (
      select distinct q.id from public.questoes q
      join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa
      and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
    ) g;
    if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes na unidade %=% esperado 0', r.unidade_pedagogica_id, v_gap; end if;

    raise notice 'PRECOND unidade % OK: uteis=% real=% autoral=% gap=%', r.unidade_pedagogica_id, v_uteis, v_real, v_autoral, v_gap;
  end loop;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Uma lei federal disciplinou a concessão de determinado benefício administrativo e estabeleceu, de forma exaustiva, os requisitos para sua obtenção. Posteriormente, decreto presidencial editado para regulamentar a lei passou a exigir do interessado a apresentação de certidão adicional e a comprovação de condição não prevista no texto legal, sob pena de indeferimento do pedido. À luz do poder regulamentar, assinale a alternativa correta.$DUP1$),
  lower($DUP2$A lei que organiza determinado órgão público atribui expressamente ao Secretário da Pasta a competência para aplicar a sanção administrativa de suspensão a empresas contratadas pelo Poder Público. Durante a ausência temporária do Secretário, um diretor do órgão, sem delegação e sem previsão legal que lhe atribua essa competência, aplica diretamente a sanção a uma empresa. Nessa situação, o ato praticado pelo diretor caracteriza$DUP2$),
  lower($DUP3$Um prefeito determinou a remoção de um servidor para outra unidade administrativa. Embora a remoção estivesse formalmente dentro de sua esfera de atribuições, ficou comprovado que a medida foi adotada exclusivamente como retaliação às críticas feitas pelo servidor à gestão municipal, e não para atender a qualquer necessidade do serviço público. Nessa situação, o ato administrativo apresenta$DUP3$),
  lower($DUP4$Após a edição de uma lei federal que estabelece normas gerais sobre determinada atividade administrativa, pretende-se expedir decreto para detalhar os procedimentos necessários à sua fiel execução, sem inovar autonomamente na ordem jurídica. Nos termos da Constituição Federal, a competência para expedir esse decreto regulamentar é do$DUP4$),
  lower($DUP5$Nos termos do Código Tributário Nacional, uma atuação administrativa será considerada exercício regular do poder de polícia quando$DUP5$),
  lower($DUP6$De acordo com o conceito legal de poder de polícia previsto no Código Tributário Nacional, a limitação ou disciplina de direito, interesse ou liberdade pode ocorrer, entre outros motivos de interesse público, em razão de$DUP6$),
  lower($DUP7$No exercício de fiscalização administrativa de segurança, um agente público constata irregularidade em estabelecimento particular. Embora possa instaurar o procedimento cabível, afirma ao responsável que deixará de registrar a ocorrência caso receba vantagem pessoal. À luz dos princípios aplicáveis à atuação administrativa, assinale a alternativa correta.$DUP7$),
  lower($DUP8$Durante fiscalização urbanística, a Administração verifica que um comércio instalou uma placa em desacordo com exigência administrativa, mas a irregularidade pode ser corrigida mediante simples adequação do equipamento. Sem examinar medidas menos gravosas, a autoridade determina o fechamento integral e imediato do estabelecimento por prazo indeterminado. Considerando o princípio da proporcionalidade no exercício do poder de polícia, assinale a alternativa correta.$DUP8$),
  lower($DUP9$Durante fiscalização de segurança em estabelecimento particular, a autoridade administrativa determinou a suspensão imediata de uma atividade, limitando-se a registrar que a medida era “necessária ao interesse público”, sem apontar as circunstâncias verificadas nem a base jurídica da decisão. À luz do princípio da motivação, a conduta é$DUP9$),
  lower($DUP10$No planejamento de fiscalizações de segurança em estabelecimentos privados, a Administração dispõe de equipes limitadas e identifica locais com maior fluxo de pessoas e histórico de irregularidades. À luz do princípio da eficiência, a conduta mais adequada é:$DUP10$),
  lower($DUP11$Nos termos do Estatuto da Igualdade Racial, assinale a alternativa correta acerca da promoção da igualdade de oportunidades no mercado de trabalho.$DUP11$),
  lower($DUP12$De acordo com o Estatuto da Igualdade Racial, o Poder Executivo federal poderá implementar critérios para o provimento de cargos em comissão e funções de confiança com a finalidade de ampliar a participação de negros. Para tanto, tais critérios devem observar:$DUP12$),
  lower($DUP13$No âmbito da organização institucional da Política Nacional de Promoção da Igualdade Racial (PNPIR), assinale a alternativa correta acerca da elaboração das diretrizes das políticas nacional e regional de promoção da igualdade étnica.$DUP13$),
  lower($DUP14$Nos termos do Estatuto Nacional da Igualdade Racial, assinale a alternativa correta acerca dos critérios para o provimento de cargos em comissão e funções de confiança.$DUP14$),
  lower($DUP15$A respeito da relação entre as medidas previstas no Estatuto Nacional da Igualdade Racial e outras iniciativas estatais de promoção da igualdade racial, assinale a alternativa correta.$DUP15$),
  lower($DUP16$Durante a análise de um pedido administrativo, a autoridade competente observa todos os requisitos formais previstos e pratica ato que, em tese, está dentro de sua competência. Contudo, fica demonstrado que ela conduziu o procedimento com a intenção de prejudicar o requerente em razão de desavença pessoal antiga, valendo-se de justificativas apenas aparentes. Nessa situação, a conduta contraria principalmente o princípio da$DUP16$),
  lower($DUP17$Um gestor público determina que requerimentos administrativos de cidadãos identificados como opositores políticos de sua gestão sejam analisados somente depois dos requerimentos apresentados por seus apoiadores, embora todos preencham os mesmos requisitos e tenham sido protocolados na mesma data. Considerando a distinção entre impessoalidade e moralidade administrativa, assinale a alternativa correta.$DUP17$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 17';
end $$;

-- ================= INSERT das 17 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_uid uuid;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    select unidade_pedagogica_id into v_uid from _unidades_ordem where r.ordem between ordem_min and ordem_max;

    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE09A_LEGISLACAO_ESPECIFICA - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = (select curso_conteudo_id from _lote_questoes where ordem = r.ordem)
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id, unidade_pedagogica_id) values (r.ordem, v_novo_id, v_uid);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;
  end loop;
end $$;

-- ================= VINCULO via RPC sancionada =================
do $$
declare
  r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_snap record;
  v_uteis int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes - v_snap.total_questoes <> 17 then raise exception 'POSCOND: questoes criadas=% esperado 17', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 85 then raise exception 'POSCOND: alternativas criadas=% esperado 85', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 17 then raise exception 'POSCOND: vinculos criados=% esperado 17', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 17 then raise exception 'POSCOND: curso_questoes criadas=% esperado 17', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='8cb82a8e-e0f4-4d46-a4a5-7443f31912a4' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 8 then raise exception 'POSCOND: uteis unidade Poderes da Administracao Publica=% esperado 8', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4';
  if v_gabaritos <> 'BBAA' then raise exception 'POSCOND: gabaritos unidade Poderes da Administracao Publica=% esperado BBAA', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='2f0d3b9c-fe22-4173-a712-cfb9e1060b8c' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Poder de Policia=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c';
  if v_gabaritos <> 'BABCBA' then raise exception 'POSCOND: gabaritos unidade Poder de Policia=% esperado BABCBA', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='5bf890e1-8e09-4f7a-9410-7f5e5168d9c4' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Estatuto Nacional da Igualdade Racial=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4';
  if v_gabaritos <> 'BBBBC' then raise exception 'POSCOND: gabaritos unidade Estatuto Nacional da Igualdade Racial=% esperado BBBBC', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1172a885-1419-4ad8-b728-1a0c7492c133' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Direito Administrativo=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '1172a885-1419-4ad8-b728-1a0c7492c133';
  if v_gabaritos <> 'AA' then raise exception 'POSCOND: gabaritos unidade Direito Administrativo=% esperado AA', v_gabaritos; end if;


  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  if v_vinc_ok <> 17 then raise exception 'POSCOND: %/17 vinculos corretos (unidade unica) confirmados', v_vinc_ok; end if;

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 17 then raise exception 'POSCOND: %/17 curso_questoes novas confirmadas', v_cq_ok; end if;

  raise notice 'POSCONDICOES OK: +17 questoes, +85 alternativas, +17 vinculos, +17 curso_questoes; 4 unidades com gabaritos e contagens confirmadas';
end $$;

commit;
