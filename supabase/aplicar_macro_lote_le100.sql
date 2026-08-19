-- ============================================================================
-- AUDITORIA GLOBAL -- MACRO-LOTE LEGISLAÇÃO ESPECÍFICA (100 QUESTÕES)
-- Aplicação de 100 explicações pedagógicas completas para fechar 100% de LE
-- Matéria: Legislação Específica (materia_id = 10)
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-macro-lote-le100-harness.mjs a partir de
-- scripts/macro-lote-le100-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/macro-lote-le100-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _le100_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _le100_novas_explicacoes (id, explicacao) values
(355, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Todas as assertivas I, II, III e IV estão corretas em conformidade com o Estatuto dos Militares Estaduais do RS (LC Estadual nº 10.990/1997):
- I. O comando é a soma de autoridade, deveres e responsabilidades de que o militar estadual é investido legalmente quando conduz homens ou dirige uma organização militar (Art. 34).
- II. Os cabos e soldados são essencialmente os elementos de execução da corporação (Art. 16, §4º).
- III. A subordinação não afeta, de modo algum, a dignidade pessoal do militar estadual e decorre, exclusivamente, da estrutura hierarquizada e disciplinada da corporação (Art. 36).
- IV. O oficial é preparado, ao longo da carreira, para o exercício de comando, chefia e direção das organizações militares estaduais (Art. 35).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incorreta, pois todas as assertivas são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III e IV também são assertivas verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois I e II também estão corretas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Incompleta, pois todas as quatro assertivas são verdadeiras.

BIZU DE PROVA:
Hierarquia e Comando no Estatuto da BM (LC 10.990/97):
- Oficiais: Preparados para Comando, Chefia e Direção;
- Praças (Cabos/Soldados): Elementos de Execução;
- Subordinação: Decorre da estrutura e NUNCA afeta a dignidade do militar!'),
(356, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Todas as assertivas estão corretas conforme o Artigo 37 da Constituição Federal e a legislação administrativa:
- I. A investidura em cargo ou emprego público depende de aprovação prévia em concurso público de provas ou de provas e títulos, ressalvadas as nomeações para cargo em comissão (Art. 37, II).
- II. Os atos de improbidade administrativa importarão a suspensão dos direitos políticos, a perda da função pública, a indisponibilidade dos bens e o ressarcimento ao erário (Art. 37, §4º).
- III. A administração pública direta e indireta obedecerá aos princípios de legalidade, impessoalidade, moralidade, publicidade e eficiência (Art. 37, caput).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incorreta, pois todas as três assertivas são plenamente verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois II e III também são verdadeiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Incompleta, pois I também é verdadeira.

BIZU DE PROVA:
Artigo 37 da CF/88 (Princípios Expressos - LIMPE):
Legalidade, Impessoalidade, Moralidade, Publicidade e Eficiência regem toda a Administração Direta e Indireta!'),
(357, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Artigo 7º, inciso XIII, da Constituição Federal assegura aos trabalhadores urbanos e rurais (e extensível a servidores civis nos termos do art. 39, §3º) a "duração do trabalho normal NÃO superior a oito horas diárias e quarenta e quatro semanais, facultada a compensação de horários e a redução da jornada, mediante acordo ou convenção coletiva de trabalho".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A jornada máxima semanal constitucional é de 44 horas, e não 40 horas como limite geral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O limite diário geral é de 8 horas, e não 6 horas (jornada de 6 horas é para turnos ininterruptos de revezamento - Art. 7º, XIV).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A jornada normal diária é de até 8 horas (e 44 semanais).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há previsão constitucional ordinária de 10 horas diárias como jornada normal.

BIZU DE PROVA:
Jornada Constitucional de Trabalho (Art. 7º, XIII da CF/88):
- Limite Diário: Até 8 HORAS;
- Limite Semanal: Até 44 HORAS!'),
(358, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O atributo da PRESUNÇÃO DE LEGITIMIDADE E VERACIDADE dos atos administrativos significa que todo ato praticado pela Administração Pública presume-se editado em estrita conformidade com a lei e que os fatos alegados são verdadeiros, até que haja prova em contrário (presunção relativa / juris tantum), operando a inversão do ônus da prova em desfavor de quem contesta o ato.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A presunção é relativa (juris tantum) e admite prova em contrário, não sendo absoluta (jure et de jure).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A presunção de legitimidade não impede o controle de legalidade pelo Poder Judiciário (Art. 5º, XXXV da CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O ato vincula imediatamente os administrados sem necessidade de homologação prévia judicial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A presunção de legitimidade decorre do próprio princípio da legalidade e da supremacia do interesse público.

BIZU DE PROVA:
Presunção de Legitimidade do Ato Administrativo:
- Presunção JURIS TANTUM (relativa - cabe prova em contrário);
- Inverte o ônus da prova para o particular contestante!'),
(359, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Artigo 2º, caput, da Lei do Processo Administrativo Federal (Lei nº 9.784/1999) enumera como princípios da Administração Pública: legalidade, finalidade, motivação, razoabilidade, proporcionalidade, moralidade, ampla defesa, contraditório, segurança jurídica, interesse público e eficiência. Os princípios de MOTIVAÇÃO e SEGURANÇA JURÍDICA integram expressamente esse rol legal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A arbitrariedade e a pessoalidade violam frontalmente os princípios administrativos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O sigilo é exceção estrita, sendo a publicidade a regra geral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A informalidade absoluta e o subjetivismo não são princípios informadores do regime de direito público.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A supremacia do interesse privado inexiste no direito público.

BIZU DE PROVA:
Princípios da Lei nº 9.784/1999 (Art. 2º):
Além do LIMPE da CF/88, destacam-se: MOTIVAÇÃO, SEGURANÇA JURÍDICA, PROPORCIONALIDADE e RAZOABILIDADE!'),
(360, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II e III reproduzem fielmente as normas da Lei nº 8.429/1992 (Lei de Improbidade Administrativa, com as alterações da Lei nº 14.230/2021):
- I. O sistema de responsabilização por atos de improbidade administrativa tutela a probidade na organização do Estado e no exercício de suas funções (Art. 1º, caput).
- II. Consideram-se atos de improbidade administrativa as condutas DOLOSAS tipificadas nos arts. 9º, 10 e 11 desta Lei (Art. 1º, §1º).
- III. O mero exercício da função ou desempenho de competências públicas, sem comprovação de ato doloso com fim ilícito, afasta a responsabilidade por ato de improbidade administrativa (Art. 1º, §1º).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são assertivas verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois II também é verdadeira.

BIZU DE PROVA:
Reforma da Lei de Improbidade (Lei nº 14.230/2021):
- EXIGE DOLO ESPECÍFICO em todas as modalidades (Art. 9º, 10 e 11);
- Fim da improbidade culposa;
- Mero exercício da função sem dolo NÃO é improbidade!'),
(361, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 16, §10, da Lei nº 8.429/1992 (LIA, incluído pela Lei nº 14.230/2021), a decretação de indisponibilidade de bens "recairá sobre bens que assegurem EXCLUSIVAMENTE o integral ressarcimento do dano ao erário, SEM INCIDIR sobre os valores a serem eventualmente aplicados a título de multa civil ou sobre acréscimo patrimonial decorrente de atividade lícita".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A indisponibilidade não incide sobre o valor da multa civil (apenas sobre o dano ao erário ou enriquecimento ilícito).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não pode atingir a totalidade indiscriminada do patrimônio lícito além do valor estimado do dano.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A indisponibilidade exige a demonstração de perigo de dano irreparável ou risco ao resultado útil (Art. 16, §3º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A remuneração e a conta poupança até 40 salários mínimos são impenhoráveis e imunes à indisponibilidade (Art. 16, §13).

BIZU DE PROVA:
Indisponibilidade de Bens na Nova LIA (Art. 16, §10):
Atinge SOMENTE o valor do dano ao erário ou enriquecimento ilícito. NÃO ATINGE A MULTA CIVIL!'),
(362, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Conforme o Estatuto dos Militares Estaduais do RS (LC Estadual nº 10.990/1997), não constitui prerrogativa indiscriminada do militar ter "assistência judiciária gratuita em qualquer hipótese quando processado por ato estranho ao serviço", visto que o patrocínio estatal se restringe aos atos praticados em razão do legítimo exercício da função pública militar.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O uso de títulos, uniformes, distintivos e insígnias militares são prerrogativas legítimas dos militares estaduais da ativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O julgamento por tribunal militar nos crimes militares é garantia constitucional expressa (Art. 125, §4º da CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O porte de arma de fogo é prerrogativa inerente à condição de policial-militar nos termos da lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A prisão em flagrante ou cumprimento de ordem judicial em recinto militar próprio é prerrogativa legal da corporação.

BIZU DE PROVA:
Defesa Jurídica do Policial Militar:
O Estado presta assistência jurídica ao militar processado por atos praticados NO EXERCÍCIO DA FUNÇÃO legítima, e não em atos particulares alheios ao serviço!'),
(363, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão de acordo com as normas de regência apenas as situações I, III e IV:
- Situação I (Correta): O ingresso nos quadros de oficiais da Brigada Militar depende de concurso público e formação técnica específica.
- Situação II (Incorreta): A promoção por merecimento não independe de interstício ou avaliação formal de desempenho.
- Situação III (Correta): A antiguidade baseia-se no tempo de efetivo serviço no posto ou na graduação.
- Situação IV (Correta): A precedência hierárquica é assegurada pela antiguidade, ressalvada a precedência funcional dos cargos de Comando.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A situação II está errada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A situação II invalida o item.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação II está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A situação II invalida a totalidade.

BIZU DE PROVA:
Promoções na Brigada Militar (LC nº 10.990/97):
- Antiguidade: Tempo de serviço no posto/graduação;
- Merecimento: Avaliação funcional, cursos e méritos comprovados;
- Interstício temporal é obrigatório em ambas!'),
(364, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No quadro de acesso para promoções aos postos mais elevados da corporação militar (posto de Coronel), a legislação estadual e regulamentos militares exigem a conclusão com aproveitamento de curso de especialização superior (Curso Avançado de Administração Policial Militar / Curso Superior de Polícia Militar), além de tempo mínimo de interstício e conceito moral/profissional.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A promoção ao último posto da carreira subordina-se a requisitos rígidos de qualificação e escolha do Governador.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não decorre de eleição política entre os pares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A aprovação em curso de aperfeiçoamento e comando superior é requisito indispensável.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A inclusão em quadro de acesso por merecimento é ato regrado por critérios objetivos e comissão de promoções.

BIZU DE PROVA:
Promoção ao Posto de Coronel da Brigada Militar:
Exige Curso Superior de Polícia/Especialização + Interstício + Parecer favorável da Comissão de Promoções.'),
(365, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II e III reproduzem diretrizes e programas expressamente previstos no Estatuto Nacional da Igualdade Racial (Lei Federal nº 12.288/2010):
- I. O direito à educação e cultura da população negra abrange a inclusão da história e cultura afro-brasileira nas escolas (Art. 11).
- II. O acesso à terra e o desenvolvimento socioeconômico sustentável dos remanescentes das comunidades dos quilombos constituem dever estatal (Art. 31 e 34).
- III. O incentivo ao mercado de trabalho e às ações afirmativas para geração de emprego e renda (Art. 39).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois II também integra o Estatuto.

BIZU DE PROVA:
Estatuto da Igualdade Racial (Lei nº 12.288/2010):
Proteção integral: Ensino da História Afro-Brasileira, Titulação e Sustentabilidade Quilombola e Ações Afirmativas no Trabalho!'),
(366, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 39 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) estabelece que o poder público promoverá ações que assegurem a igualdade de oportunidades no mercado de trabalho para a população negra, inclusive mediante implementação de programas de FORMAÇÃO PROFISSIONAL, EMPREGO E GERAÇÃO DE RENDA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A lei não concede monopólio de postos de trabalho privados.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As medidas visam à integração plena e capacitação no mercado formal, e não ao isolamento corporativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A política pública afirmativa orienta-se pela inclusão produtiva qualificada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não prevê isenção de deveres contratuais e trabalhistas.

BIZU DE PROVA:
Acesso ao Trabalho (Art. 39 da Lei 12.288/10):
Programas de Qualificação e Formação Profissional + Estímulo à Geração de Emprego e Renda para a População Negra!'),
(367, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 20 da Lei Estadual RS nº 13.694/2011 (Estatuto Estadual da Igualdade Racial), nas instituições de ensino, públicas e privadas, do Rio Grande do Sul, deverá ser oportunizado o aprendizado e a prática da CAPOEIRA como atividade esportiva, cultural e lúdica, sendo facultada a participação de mestres tradicionais de capoeira como instrutores.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A lei não veda o ensino de manifestações culturais de matriz afro-brasileira; ao contrário, incentiva.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prática da capoeira não é restrita ao ambiente universitário privado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A participação de mestres populares tradicionais de capoeira é expressamente autorizada e valorizada na lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A lei estadual determina a valorização da cultura afro-gaúcha em todas as etapas da educação básica.

BIZU DE PROVA:
Capoeira no Estatuto Estadual da Igualdade Racial do RS (Lei nº 13.694/11 - Art. 20):
Ensino da CAPOEIRA incentivado nas escolas públicas e privadas com participação de mestres tradicionais!'),
(368, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A alternativa A é a INCORRETA (gabarito) porque o Regulamento Disciplinar da Brigada Militar (RDBM - Decreto Estadual nº 43.245/2004) e a legislação militar estadual dispõem que os militares na inatividade (reserva remunerada e reformados) sujeitam-se às sanções disciplinares apenas nos casos e limites especificamente tipificados para a sua condição, NÃO sendo alcançados "em qualquer hipótese" indistintamente como se em serviço ativo estivessem.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: a transgressão disciplinar é toda violação dos deveres funcionais e da disciplina militar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: o poder disciplinar é inerente à hierarquia e cadeia de comando militar.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: a aplicação de punição disciplinar deve ser precedida de processo com ampla defesa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: a autoridade deve motivar a dosimetria da sanção disciplinar militar.

BIZU DE PROVA:
Disciplina e Militares da Inatividade (RDBM):
Militares inativos respondem disciplinarmente apenas pelas faltas compatíveis com sua situação de inatividade (reserva/reforma), com limitações legais!'),
(369, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A alternativa D é a INCORRETA (gabarito) porque o Conselho de Disciplina e os processos disciplinares da Brigada Militar destinam-se a julgar a capacidade moral e funcional do militar de permanecer na ativa ou na corporação militar, e NÃO "exclusivamente para atendimento de conversão de infração em advertência".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: o Conselho de Justificação destina-se a julgar a incapacidade de Oficiais da corporação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: o Conselho de Disciplina destina-se a julgar Praças com estabilidade assegurada.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: a exclusão a bem da disciplina é sanção aplicável às praças nos termos da lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: a demissão ex officio aplica-se aos oficiais nos termos da legislação militar.

BIZU DE PROVA:
Conselhos na Brigada Militar:
- CONSELHO DE JUSTIFICAÇÃO: Julga os OFICIAIS (Tribunal de Justiça Militar decide a perda do posto e patente).
- CONSELHO DE DISCIPLINA: Julga as PRAÇAS com estabilidade (Comandante-Geral decide a exclusão a bem da disciplina).'),
(370, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 11 do Regulamento Disciplinar da Brigada Militar (RDBM), todo Militar Estadual que tiver conhecimento de um fato contrário à disciplina militar DEVE PARTICIPAR O FATO À AUTORIDADE COMPETENTE imediatamente, por escrito ou verbalmente, constituindo infração a omissão de dever de comunicação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O militar não tem a faculdade de ignorar ou ocultar a falta disciplinar de que tem ciência funcional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não pode aplicar sanção sem ter competência legal regulamentar disciplinar para tanto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A comunicação da transgressão deve ser dirigida ao superior hierárquico competente pela apuração.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A omissão em reportar falta disciplinar grave configura transgressão militar própria.

BIZU DE PROVA:
Dever de Participação Disciplinar (Art. 11 do RDBM):
Teve conhecimento de falta disciplinar -> DEVER OBRIGATÓRIO de participar à autoridade competente!'),
(646, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No plano da eficácia dos atos administrativos, a escala de serviço elaborada pela autoridade competente é VÁLIDA (pois possui todos os elementos formais de validade), mas NÃO É EFICAZ nem efetiva em relação ao servidor enquanto não for devidamente publicada ou comunicada, visto que a publicidade é requisito indispensável para o início da produção dos efeitos jurídicos externos vinculantes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O ato não é nulo de pleno direito por simples pendência de publicação interna, apenas ineficaz.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A ausência de publicação prévia impede a produção imediata de efeitos coercitivos contra o servidor.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A validade do ato não se confunde com sua eficácia no tempo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O ato administrativo perfeito e válido só se torna executável com a devida publicidade/ciência formal.

BIZU DE PROVA:
Validade vs Eficácia do Ato Administrativo:
- VALIDADE: Atendimento aos requisitos legais (CO-FI-FO-MO-OB).
- EFICÁCIA: Aptidão para produzir efeitos jurídicos concretos (depende da PUBLICIDADE/notificação)!'),
(647, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O PODER CONSTITUINTE DERIVADO DECORRENTE (Artigo 25 da CF/88 e Art. 11 do ADCT) consiste na competência atribuída aos Estados-Membros da Federação para elaborar e promulgar suas próprias Constituições Estaduais, observando compulsoriamente os princípios fundamentais e normas de reprodução obrigatória da Constituição da República Federativa do Brasil.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O poder decorrente não pertence aos Municípios (que editam Leis Orgânicas Municipais - Art. 29 da CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Poder Constituinte Originário é soberano, inicial e ilimitado (pertence à Assembleia Nacional Constituinte).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O poder reformador diz respeito à alteração da CF por meio de Emendas Constitucionais (Art. 60 da CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O poder revisor foi exercido de forma transitória após 5 anos da promulgação da CF (Art. 3º do ADCT).

BIZU DE PROVA:
Poder Constituinte Derivado Decorrente:
Competência dos ESTADOS-MEMBROS para criar suas próprias Constituições Estaduais (Art. 25 da CF/88)!'),
(649, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 2º da Constituição Federal de 1988 estabelece solenemente: "São Poderes da União, INDEPENDENTES E HARMÔNICOS entre si, o Legislativo, o Executivo e o Judiciário." A cláusula de separação dos Poderes exige independência funcional e cooperação harmônica recíproca (sistema de freios e contrapesos / checks and balances).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os Poderes não são subordinados uns aos outros (não há hierarquia entre os Poderes de Estado).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A separação não é absoluta e isolada; há harmonia e controle recíproco legítimo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Poder Executivo não é superior ao Legislativo nem ao Judiciário.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os três Poderes são estruturantes da República e protegidos por cláusula pétrea (Art. 60, §4º, III).

BIZU DE PROVA:
Artigo 2º da CF/88 (Poderes da União):
INDEPENDENTES e HARMÔNICOS entre si (Legislativo, Executivo e Judiciário)!'),
(650, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O princípio constitucional administrativo da PUBLICIDADE (Artigo 37, caput, da CF/88) determina que todos os atos da Administração Pública devem ser transparentes, divulgados e acessíveis ao conhecimento de toda a sociedade, salvo quando o sigilo for imprescindível à segurança do Estado ou à intimidade e privacidade dos indivíduos (Art. 5º, XXXIII e LX).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Legalidade exige que o administrador atue conforme a lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Impessoalidade veda favorecimentos e perseguições pessoais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Moralidade exige conduta ético-jurídica, proba e honesta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Eficiência exige rendimento funcional, economicidade e qualidade no serviço público.

BIZU DE PROVA:
Princípio da Publicidade (Art. 37 CF):
A transparência é a regra geral da Administração Pública. O sigilo é EXCEÇÃO restrita à segurança e intimidade!'),
(651, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Artigo 4º, inciso VI, da Constituição Federal de 1988 elenca a DEFESA DA PAZ como um dos princípios fundamentais que regem a República Federativa do Brasil em suas relações internacionais (juntamente com independência nacional, autodeterminação dos povos, não intervenção, igualdade entre os Estados, solução pacífica dos conflitos e repúdio ao terrorismo/racismo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Soberania é fundamento da República do Artigo 1º, inciso I da CF.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Cidadania é fundamento da República do Artigo 1º, inciso II da CF.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erradicar a pobreza é objetivo fundamental do Artigo 3º, inciso III da CF.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Promover o bem de todos é objetivo fundamental do Artigo 3º, inciso IV da CF.

BIZU DE PROVA:
Relações Internacionais (Art. 4º da CF/88 - Mnemônico IN-DE-P-CON-DE-SOL-RE-RE-A):
- Independência nacional;
- Defesa da paz (Inciso VI);
- Solução pacífica dos conflitos;
- Repúdio ao terrorismo e ao racismo;
- Asilo político.'),
(652, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 12, inciso I, alínea "b", da Constituição Federal, é BRASILEIRO NATO "o nascido no estrangeiro, de pai brasileiro ou de mãe brasileira, desde que qualquer deles esteja a serviço da República Federativa do Brasil" (Critério Funcional / Jus Sanguinis qualificado).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O filho de estrangeiros a serviço de país estrangeiro que nasce no Brasil não é brasileiro nato (Art. 12, I, "a").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O estrangeiro residente há 15 anos sem condenação penal que requer a nacionalidade é brasileiro NATURALIZADO (Art. 12, II, "b").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O originário de país de língua portuguesa com 1 ano de residência é naturalizado (Art. 12, II, "a").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A aquisição derivada de nacionalidade confere a condição de brasileiro naturalizado.

BIZU DE PROVA:
Brasileiro Nato no Exterior a Serviço do Brasil (Art. 12, I, "b" CF):
Pai ou mãe brasileira A SERVIÇO DO BRASIL no exterior -> O filho nasce BRASILEIRO NATO automaticamente!'),
(653, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Artigo 37, §8º, da Constituição Federal dispõe expressamente que a autonomia gerencial, orçamentária e financeira dos órgãos e entidades da administração direta e indireta poderá ser ampliada mediante CONTRATO, a ser firmado entre seus administradores e o poder público, que tenha por objeto a fixação de metas de desempenho para o órgão ou entidade (Contrato de Gestão / Consórcio de Desempenho).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A autonomia financeira não pode ser expandida por mera portaria sem previsão constitucional de metas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se opera por decreto sigiloso imune a fiscalização.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A ampliação da autonomia depende da celebração do contrato de desempenho previsto no art. 37, §8º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O contrato de metas vincula os gestores ao cumprimento de resultados sob controle dos órgãos competentes.

BIZU DE PROVA:
Autonomia Gerencial e Contrato de Gestão (Art. 37, §8º da CF/88):
Fixação de metas de desempenho para órgãos e entidades públicas mediante CONTRATO formal!'),
(654, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas I e III:
- I. (Correta): O direito de greve é assegurado aos servidores públicos civis e será exercido nos termos e nos limites definidos em lei específica (Art. 37, VII da CF e Mandados de Injunção 670, 708 e 712 do STF aplicando a Lei 7.783/89).
- II. (Incorreta): O militar estadual NÃO pode fazer greve nem sindicalizar-se (proibição constitucional absoluta do Art. 42, §1º e Art. 142, §3º, IV da CF).
- III. (Correta): É garantido ao servidor público civil o direito à livre associação sindical (Art. 37, VI da CF).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva II é falsa (militar não faz greve nem sindicaliza-se).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II invalida o item.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva II torna a alternativa errada.

BIZU DE PROVA:
Direitos Sindicais e de Greve no Serviço Público (CF/88):
- Servidor Público CIVIL: Tem direito de Associação Sindical (Art. 37, VI) e Direito de Greve (Art. 37, VII).
- Servidor MILITAR: PROIBIDO Sindicato e PROIBIDO Greve (Art. 142, §3º, IV)!'),
(655, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Artigo 142, §3º, inciso V, da Constituição Federal (aplicável aos militares estaduais por força do Artigo 42, §1º) prescreve taxativamente: "O militar, enquanto em serviço ativo, NÃO PODE ESTAR FILIADO A PARTIDOS POLÍTICOS." Trata-se de vedação absoluta que garante a neutralidade e a apartidarização das forças armadas e corporações militares.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O militar da ativa é absolutamente proibido de filiar-se a partido político.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A filiação partidária só é admitida ao militar da inatividade (reserva ou reformado).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Se o militar com mais de 10 anos for eleito, passará automaticamente no ato da diplomação para a inatividade (Art. 14, §8º, II, CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A vedação de filiação partidária do militar ativo é norma constitucional imperativa e expressa.

BIZU DE PROVA:
Militares da Ativa e Partidos Políticos (Art. 142, §3º, V da CF/88):
Enquanto estiver no SERVIÇO ATIVO, o militar NÃO PODE ter filiação partidária!'),
(656, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O direito constitucional de reunião em locais abertos ao público (Art. 5º, inciso XVI, da CF/88) não é absoluto e PODE SOFRER RESTRIÇÕES legítimas durante a vigência do ESTADO DE DEFESA (Art. 136, §1º, I, "a" da CF - restrição aos direitos de reunião, sigilo de correspondência e comunicação telegráfica e telefônica) e do ESTADO DE SÍTIO (Art. 139, IV da CF).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Nenhum direito fundamental é absoluto no ordenamento jurídico brasileiro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de reunião independe de autorização policial, exigindo apenas prévio aviso (Art. 5º, XVI).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A dissolução de reunião pacífica sem motivo legal legítimo configura abuso de poder.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A restrição em estado de defesa é expressamente autorizada pela Constituição Federal.

BIZU DE PROVA:
Direito de Reunião (Art. 5º, XVI da CF/88):
- É livre e INDEPENDE DE AUTORIZAÇÃO (exige apenas PRÉVIO AVISO à autoridade competente);
- Pode sofrer restrição excepcional durante o ESTADO DE DEFESA e ESTADO DE SÍTIO!'),
(664, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 16, §1º, inciso I, da Lei nº 10.826/2003 (Estatuto do Desarmamento), incorre nas mesmas penas do crime de arma de uso restrito quem "suprimir ou adulterar marca, numeração ou qualquer sinal de identificação de arma de fogo ou artefato", INDEPENDENTEMENTE de se tratar originariamente de arma de uso permitido e de estar ou não municiada (crime de perigo abstrato). A supressão do número de série qualifica a conduta no Art. 16.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A supressão do número de série desloca a conduta do Art. 12 para a figura equiparada grave do Art. 16, §1º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O crime é formal e de perigo abstrato, consumando-se mesmo que a arma esteja desmuniciada (STJ/STF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A adulteração de sinal identificador configura o crime do Art. 16, §1º, I, e não o porte simples do Art. 14.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A aptidão de disparo é presumida, bastando a existência da arma com numeração raspada sob sua guarda.

BIZU DE PROVA:
Arma de Fogo com Numeração RASPADA ou SUPRIMIDA:
Sempre se enquadra no ARTIGO 16, §1º, I da Lei nº 10.826/03, mesmo que seja arma de uso permitido e esteja desmuniciada dentro de casa!'),
(665, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A conduta do policial que deliberadamente manuseia celular apreendido sob custódia oficial para finalidades alheias ao serviço caracteriza ato de improbidade administrativa atentatório aos princípios da administração pública (Artigo 11 da Lei nº 8.429/1992, com redação da Lei nº 14.230/2021), exigindo-se a comprovação do DOLO do agente, sendo dispensável a obtenção de vantagem econômica efetiva ou dano patrimonial material.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O enriquecimento ilícito (Art. 9º) exige a efetiva percepção de vantagem patrimonial indevida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os atos atentatórios aos princípios (Art. 11) continuam puníveis e independem de dano patrimonial financeiro ao erário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei nº 14.230/2021 manteve expressamente o Artigo 11 com rol taxativo de atos que violam princípios.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O dano ao erário (Art. 10) exige a comprovação de efetivo prejuízo patrimonial material mensurável aos cofres públicos.

BIZU DE PROVA:
Atos contra os Princípios da Administração (Art. 11 da LIA):
Exigem DOLO do agente e NÃO dependem de lesão patrimonial ao erário nem de enriquecimento ilícito do servidor!'),
(666, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Nos termos do Artigo 10, inciso II, da Lei nº 8.429/1992 (Lei de Improbidade Administrativa), constitui ato de improbidade administrativa que CAUSA LESÃO AO ERÁRIO (Prejuízo ao Erário) "permitir ou concorrer para que pessoa física ou jurídica utilize bens, rendas, verbas ou valores integrantes do patrimônio público, sem a observância das formalidades legais ou regulamentares aplicáveis à espécie".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O enriquecimento ilícito (Art. 9º) tipifica a vantagem patrimonial direta auferida pelo próprio agente para si.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A concessão indevida de benefício tributário é tipificada no Artigo 10-A (revogado/incorporado na LIA).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dever de prestar contas enquadra-se no Artigo 11, VI.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Havendo prejuízo patrimonial material específico, prevalece a capitulação mais gravosa do Artigo 10 (lesão ao erário).

BIZU DE PROVA:
Veículo/Máquina Pública Cedida Indevidamente para Uso Particular:
Ato de Improbidade que CAUSA LESÃO AO ERÁRIO (Artigo 10, inciso II da Lei nº 8.429/92)!'),
(667, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O comando da questão solicita quais assertivas estão INCORRETAS como atos que causam PREJUÍZO AO ERÁRIO (Art. 10 da LIA):
- O Item I está INCORRETO como dano ao erário, pois a prática de NEPOTISMO (nomear cônjuge, companheiro ou parente até o terceiro grau) é ato de improbidade que ATENTA CONTRA OS PRINCÍPIOS DA ADMINISTRAÇÃO PÚBLICA (Artigo 11, inciso XI da Lei nº 8.429/1992, incluído pela Lei 14.230/2021 e Súmula Vinculante 13 do STF), e não ato de lesão ao erário do art. 10.
- Os Itens II e III são casos verdadeiros e expressos de prejuízo ao erário (Art. 10, V e VIII).
Portanto, está incorreto apenas o item I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O item II é caso autêntico de lesão ao erário (Art. 10, V).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O item III é caso autêntico de lesão ao erário (Art. 10, VIII).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O item II é hipótese típica do art. 10.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os itens II e III enquadram-se perfeitamente no art. 10.

BIZU DE PROVA:
Nepotismo na Lei de Improbidade (Art. 11, XI da LIA):
Nepotismo é ato que ATENTA CONTRA OS PRINCÍPIOS da Administração Pública (Artigo 11), e NÃO ato de lesão ao erário!'),
(668, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O comando da questão pede a conduta que NÃO constitui ato de enriquecimento ilícito (Art. 9º da LIA). A conduta de "revelar fato ou circunstância de que tem ciência em razão das atribuições e que deva permanecer em segredo" é tipificada como ato de improbidade atentatório aos PRINCÍPIOS DA ADMINISTRAÇÃO PÚBLICA (Artigo 11, inciso III, da Lei nº 8.429/1992), e não enriquecimento ilícito do Art. 9º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Constitui ato de enriquecimento ilícito expressamente tipificado no Artigo 9º, inciso VIII, da LIA.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Constitui ato de enriquecimento ilícito expressamente tipificado no Artigo 9º, inciso IV, da LIA.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Constitui ato de enriquecimento ilícito tipificado no Artigo 9º, inciso X, da LIA.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Constitui ato de enriquecimento ilícito expressamente tipificado no Artigo 9º, inciso V, da LIA.

BIZU DE PROVA:
Quebra de Sigilo Funcional (Art. 11, III da LIA):
Revelar segredo funcional é atentado contra os PRINCÍPIOS da Administração (Artigo 11), e NÃO enriquecimento ilícito!'),
(669, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Nos termos do Artigo 3º, §1º e §2º, da Lei nº 8.429/1992 (LIA, incluído pela Lei nº 14.230/2021), os sócios, cotistas, diretores e colaboradores de pessoa jurídica de direito privado respondem pelo ato de improbidade APENAS se comprovada sua participação e benefício DIRETO doloso, descabendo qualquer presunção de responsabilidade pelo simples fato de integrar o quadro societário. Como não há provas de participação ou benefício direto, Geovana NÃO responderá pelo ato de improbidade nas circunstâncias indicadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Benefícios indiretos genéricos desprovidos de dolo e benefício direto comprovado não autorizam a responsabilização.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A responsabilidade por improbidade é estritamente subjetiva com dolo comprovado, sendo vedada a presunção de culpa/participação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O sócio responde se houver prova cabal de sua participação dolosa e benefício direto (a isenção decorre do caso concreto específico).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei nº 14.230/2021 extinguiu expressamente qualquer modalidade culposa de improbidade administrativa.

BIZU DE PROVA:
Responsabilidade do Sócio/Cotista na Nova LIA (Art. 3º, §1º):
NÃO HÁ RESPONSABILIDADE PRESUMIDA! O sócio só responde se houver comprovação de DOLO e BENEFÍCIO DIRETO auferido!'),
(670, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Supremo Tribunal Federal (STF), no julgamento conjunto da ADO 26 e do MI 4733 (Plenário, Rel. Min. Celso de Mello), firmou tese reconhecendo a mora inconstitucional do Congresso Nacional e determinou que as condutas homofóbicas e transfóbicas, reais ou potenciais, amoldam-se aos tipos penais definidos na LEI DE RACISMO (Lei Federal nº 7.716/1989), até que sobrevenha legislação autônoma editada pelo Poder Legislativo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O crime aplica-se tanto a particulares quanto a agentes do Estado, sendo crime comum.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A matéria penal é de competência privativa da União (Art. 22, I da CF), tendo o STF reconhecido a tipicidade com base na Lei Federal nº 7.716/1989.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A liberdade de expressão não protege discursos de ódio, racismo ou incitação à violência e discriminação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os crimes da Lei nº 7.716/1989 são inafiançáveis e imprescritíveis (Art. 5º, XLII da CF), com penas de reclusão.

BIZU DE PROVA:
Homotransfobia e STF (ADO 26 / MI 4733):
Condutas homofóbicas e transfóbicas são EQUIPARADAS AO CRIME DE RACISMO (Lei nº 7.716/1989), sendo INAFIANÇÁVEIS e IMPRESCRITÍVEIS!'),
(674, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 51 da Lei nº 11.343/2006 (Lei de Drogas) estabelece prazos processuais especiais para a conclusão do inquérito policial: 30 (TRINTA) DIAS se o indiciado estiver PRESO e 90 (NOVENTA) DIAS se estiver SOLTO, podendo esses prazos ser duplicados pelo juiz, ouvido o Ministério Público, mediante pedido justificado da autoridade de polícia judiciária.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O prazo geral do CPP (10 dias preso / 30 dias solto) não se aplica à Lei de Drogas, que possui rito especial com prazos próprios.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os prazos de 30 e 90 dias podem ser duplicados mediante decisão judicial fundamentada (Art. 51, parágrafo único).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O inquérito na Lei de Drogas não tem prazo improrrogável indistinto de 15 dias.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A duplicação dos prazos depende de prévia oitiva do Ministério Público e fundamentação do Delegado de Polícia.

BIZU DE PROVA:
Prazos do Inquérito na Lei de Drogas (Art. 51 da Lei nº 11.343/06):
- Preso: 30 DIAS (duplicáveis para 60);
- Solto: 90 DIAS (duplicáveis para 180).
(A duplicação exige pedido fundamentado da autoridade policial e oitiva do MP!).'),
(675, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II e III expressam fielmente os deveres e diretrizes contidos na Lei nº 11.340/2006 (Lei Maria da Penha) e na Lei de Segurança Pública:
- I. O atendimento prioritário e especializado à mulher vítima de violência doméstica e familiar pelos órgãos policiais e de saúde.
- II. A obrigatoriedade de encaminhamento da ofendida a programas de proteção, abrigamento e assistência judiciária gratuita.
- III. O dever de preservação de provas e imediata comunicação ao Poder Judiciário para apreciação de medidas protetivas de urgência no prazo legal de 48 horas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também integra a lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois II também é expressa na lei.

BIZU DE PROVA:
Atendimento à Mulher na Lei Maria da Penha:
Prioridade de atendimento, abrigamento especializado e remessa do pedido de Medidas Protetivas ao Juiz em até 48 HORAS!'),
(676, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A instituição criada pelos Municípios com a atribuição precípua de proteger os bens, serviços e instalações municipais (Artigo 144, §8º, da CF/88) e com competência de patrulhamento preventivo comunitário (Artigo 3º e 5º da Lei Federal nº 13.022/2014) é a GUARDA MUNICIPAL.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Polícia Civil é órgão estadual de polícia judiciária e investigação (Art. 144, §4º da CF).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Polícia Militar é órgão estadual de polícia ostensiva e preservação da ordem pública (Art. 144, §5º da CF).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Polícia Federal é órgão da União com atribuições exclusivas de polícia judiciária federal e marítima (Art. 144, §1º da CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Polícia Penal exerce a segurança e vigilância dos estabelecimentos prisionais (Art. 144, §5º-A da CF).

BIZU DE PROVA:
Guarda Municipal (Art. 144, §8º CF e Lei nº 13.022/2014):
Instituição civil municipal criada para proteção de BENS, SERVIÇOS e INSTALAÇÕES do Município, atuando no policiamento preventivo comunitário!'),
(677, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 144, §1º, inciso II, da Constituição Federal dispõe expressamente que à POLÍCIA FEDERAL, instituída por lei como órgão permanente e estruturada em carreira, incumbe "prevenir e reprimir o tráfico ilícito de entorpecentes e drogas afins, o contrabando e o descaminho, sem prejuízo da ação fazendária e de outros órgãos públicos nas respectivas áreas de competência".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A competência para apurar infrações penais contra a ordem política e social é da Polícia Federal (Art. 144, §1º, I), e não de polícias municipais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O policiamento ostensivo e a preservação da ordem pública cabem às Polícias Militares (Art. 144, §5º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A polícia judiciária estadual cabe às Polícias Civis (Art. 144, §4º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A vigilância dos estabelecimentos penais cabe às Polícias Penais (Art. 144, §5º-A).

BIZU DE PROVA:
Competências Constitucionais da Polícia Federal (Art. 144, §1º da CF/88):
- Apurar crimes contra a ordem política/social e bens da União;
- Prevenir e reprimir Tráfico de Drogas, Contrabando e Descaminho;
- Exercer com exclusividade a Polícia Judiciária da União;
- Polícia marítima, aeroportuária e de fronteiras!'),
(678, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O comando da questão solicita o órgão que NÃO integra o rol taxativo de segurança pública do Artigo 144 da Constituição Federal. A "Polícia Ferroviária Estadual" não existe no texto constitucional, visto que a Constituição prevê unicamente a POLÍCIA FERROVIÁRIA FEDERAL (Artigo 144, inciso III, da CF/88).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Polícia Federal é órgão expresso do Artigo 144, inciso I da CF.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Polícia Rodoviária Federal é órgão expresso do Artigo 144, inciso II da CF.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Polícia Civil é órgão expresso do Artigo 144, inciso IV da CF.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Polícia Militar é órgão expresso do Artigo 144, inciso V da CF.

BIZU DE PROVA:
Pegadinha Clássica de Prova:
Existe Polícia Rodoviária Federal e Polícia FERROVIÁRIA FEDERAL. NÃO EXISTE Polícia Ferroviária Estadual no Art. 144 da CF!'),
(712, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A conduta do agente público que constrange o preso ou detento, mediante violência, grave ameaça ou redução de sua capacidade de resistência, a submeter-se a situação vexatória ou a constrangimento não autorizado em lei (como expor o preso indevidamente à curiosidade pública ou fotos humilhantes) configura o crime de ABUSO DE AUTORIDADE tipificado no Artigo 13, inciso I e II, da Lei nº 13.869/2019.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não se trata de infração puramente administrativa, havendo tipicidade criminal autônoma.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A tortura (Lei 9.455/97) exige a imposição de intenso sofrimento físico ou mental para fins de confissão, castigo ou discriminação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Prevaricação (Art. 319 CP) consiste em deixar de praticar ato de ofício por sentimento pessoal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Desacato é crime praticado pelo particular contra o funcionário público (Art. 331 CP).

BIZU DE PROVA:
Submeter Preso a Vexame ou Constrangimento Ilegal (Art. 13 da Lei nº 13.869/19):
Exibir a imagem do preso ou submetê-lo a situação vexatória não autorizada em lei = CRIME DE ABUSO DE AUTORIDADE!'),
(713, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 31 da Lei nº 13.869/2019 (Lei de Abuso de Autoridade), comete crime a autoridade policial que "prolongar a execução de pena privativa de liberdade, de prisão temporária, de prisão preventiva, de medida de segurança ou de internação, deixando, sem motivo justo e excepcionalíssimo, de executar o alvará de soltura imediatamente após recebido".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A conduta não é fato atípico; é crime expressamente tipificado no art. 31 da Lei 13.869/19.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não constitui mera falta disciplinar leve, havendo responsabilidade penal cumulativa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se confunde com crime militar comum praticado fora do exercício funcional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A execução da ordem de soltura judicial deve ser IMEDIATA, sob pena de crime de abuso de autoridade.

BIZU DE PROVA:
Alvará de Soltura (Art. 31 da Lei nº 13.869/19):
Recebeu ordem judicial de soltura -> Deve cumprir IMEDIATAMENTE. Reter o preso sem justificativa plausível = Crime de Abuso de Autoridade!'),
(714, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Poder Judiciário NÃO PODE revogar atos administrativos do Poder Executivo no exercício da função jurisdicional, pois a REVOGAÇÃO é ato privativo da própria Administração Pública fundado em juízo discricionário de conveniência e oportunidade (mérito administrativo). Ao Poder Judiciário cabe exclusivamente ANULAR os atos administrativos ilegais ou ilegítimos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Judiciário não revoga atos de outros Poderes por motivo de conveniência e oportunidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A revogação produz efeitos ex nunc (prospectivos), e não retroativos (ex tunc).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atos vinculados e atos consumados não podem ser revogados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A anulação é que decorre de ilegalidade com efeitos ex tunc.

BIZU DE PROVA:
Anulação vs Revogação (Súmula 473 do STF):
- ANULAÇÃO = Atos ILEGAIS -> Feita pela Administração ou pelo PODER JUDICIÁRIO (Efeitos Ex Tunc).
- REVOGAÇÃO = Atos VÁLIDOS (Inconvenientes) -> Feita EXCLUSIVAMENTE PELA ADMINISTRAÇÃO (Efeitos Ex Nunc). O Judiciário NUNCA revoga ato do Executivo!'),
(716, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 2º da Constituição Federal de 1988 estabelece a clássica tripartição de Poderes adotada no Brasil: "São Poderes da União, independentes e harmônicos entre si, o EXECUTIVO, o LEGISLATIVO e o JUDICIÁRIO."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Ministério Público é instituição permanente essencial à função jurisdicional (Art. 127 CF), não constituindo um quarto Poder de Estado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Defensoria Pública é função essencial à justiça (Art. 134 CF), não integrando a lista de Poderes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Tribunais de Contas são órgãos autônomos auxiliares do Poder Legislativo no controle externo (Art. 71 CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As Forças Armadas e órgãos de segurança pública subordinam-se ao Poder Executivo.

BIZU DE PROVA:
Tripartição de Poderes (Art. 2º da CF/88):
Apenas TRÊS Poderes: EXECUTIVO, LEGISLATIVO e JUDICIÁRIO. Ministério Público e Tribunais de Contas NÃO são Poderes autônomos!'),
(717, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 37, §13, da Constituição Federal (incluído pela Emenda Constitucional nº 103/2019) dispõe expressamente: "O servidor público titular de cargo efetivo poderá ser READAPTADO para exercício de cargo cujas atribuições e responsabilidades sejam compatíveis com a limitação que tenha sofrido em sua capacidade física ou mental, enquanto permanecer nessa condição, desde que possua a habilitação e o nível de escolaridade exigidos para o cargo de destino, mantida a remuneração do cargo de origem."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Recondução é o retorno do servidor estável ao cargo anteriormente ocupado em razão de inabilitação em estágio probatório ou reintegração do anterior ocupante.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Reintegração é a reinvestidura do servidor estável quando invalidada sua demissão por decisão judicial ou administrativa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Aproveitamento é o retorno à atividade do servidor em disponibilidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Reversão é o retorno à atividade do servidor aposentado por invalidez quando cessados os motivos da incapacidade.

BIZU DE PROVA:
Formas de Provimento Derivado (Mnemônico 4R + A + P):
- READAPTAÇÃO: Servidor que sofreu limitação física/mental compatibilizado em novo cargo;
- REINTEGRAÇÃO: Demissão anulada (volta com todos os direitos);
- RECONDUÇÃO: Volta ao cargo antigo (inabilitado no estágio ou volta do reintegrado);
- REVERSÃO: Retorno do aposentado!'),
(718, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- I. (Correta): O Artigo 40, §1º, da Constituição Federal prevê que os servidores abrangidos por regime próprio de previdência social serão aposentados por incapacidade permanente para o trabalho no cargo em que estiverem investidos.
- II. (Correta): A aposentadoria compulsória dá-se aos 70 ou 75 anos de idade, na forma de lei complementar (Art. 40, §1º, II e LC 152/2015).
- III. (Incorreta): A contagem de tempo fictício ou sem a correspondente contribuição é expressamente vedada pelo Artigo 40, §10, da Constituição Federal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III é inconstitucional (vedado tempo fictício).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III torna a opção incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III invalida o item.

BIZU DE PROVA:
Previdência do Servidor Público (Art. 40 da CF/88):
- Vedada a contagem de tempo de contribuição FICTÍCIO (Art. 40, §10);
- Aposentadoria Compulsória: Aos 75 anos (LC nº 152/15)!'),
(719, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II, III e IV estão corretas segundo os preceitos constitucionais da Administração Pública (Artigos 37 a 41 da CF/88):
- I. A proibição de acumulação remunerada de cargos públicos, ressalvadas as hipóteses constitucionais (dois de professor, um de professor com técnico/científico, dois privativos da saúde) com compatibilidade de horários (Art. 37, XVI).
- II. A estabilidade do servidor público nomeado para cargo efetivo após 3 anos de efetivo exercício (Art. 41).
- III. A avaliação especial de desempenho por comissão instituída para essa finalidade como condição de aquisição da estabilidade (Art. 41, §4º).
- IV. A perda do cargo do servidor estável mediante sentença judicial transitada em julgado, processo administrativo com ampla defesa ou procedimento de avaliação periódica (Art. 41, §1º).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois todas as assertivas são corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois III e IV também são verdadeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois I e II também estão corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Todas as quatro assertivas são disposições constitucionais expressas.

BIZU DE PROVA:
Perda do Cargo do Servidor Estável (Art. 41, §1º da CF/88):
1. Sentença Judicial Transitada em Julgado;
2. Processo Administrativo Disciplinar (PAD) com ampla defesa;
3. Avaliação Periódica de Desempenho (na forma de lei complementar);
4. Excesso de Despesas com Pessoal (Art. 169, §4º da CF).'),
(720, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e IV:
- I. (Correta): O concurso público pode ser de provas OU de provas e títulos, de acordo com a natureza e complexidade do cargo (Art. 37, II da CF).
- II. (Incorreta): O prazo de validade do concurso público é de até 2 (dois) anos, prorrogável UMA ÚNICA VEZ por igual período (Art. 37, III da CF - e não prorrogações sucessivas).
- III. (Incorreta): A criação de cargos públicos depende de LEI em sentido formal, sendo vedada por decreto autônomo (Art. 48, X e Art. 84, VI, "a" da CF).
- IV. (Correta): É garantido ao servidor público civil o direito à livre associação sindical (Art. 37, VI da CF).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva II está incorreta quanto ao prazo e prorrogação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III está errada (criação de cargo exige lei).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As assertivas II e III estão erradas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas não estão corretas devido aos erros em II e III.

BIZU DE PROVA:
Regras de Concurso Público (Art. 37 da CF/88):
- Validade: Até 2 ANOS, prorrogável UMA VEZ por igual período (máximo total de 4 anos);
- Criação de Cargos: Sempre por LEI!'),
(721, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O princípio constitucional da PUBLICIDADE (Artigo 37, caput, da CF/88 e Lei nº 12.527/2011 - LAI) assegura a transparência geral da gestão pública e o direito fundamental dos cidadãos de acessar informações oficiais, receber certidões de repartições públicas para defesa de direitos e esclarecimento de situações de interesse pessoal (Art. 5º, XXXIII e XXXIV da CF).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A legalidade refere-se à subordinação da Administração à lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A impessoalidade veda a promoção pessoal de agentes e favoritismos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A moralidade exige probidade, honestidade e boa-fé administrativa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A eficiência visa ao rendimento econômico e presteza nos serviços.

BIZU DE PROVA:
Princípio da Publicidade e Direito à Informação:
O acesso à informação pública é a REGRA; o sigilo é EXCEÇÃO excepcionalíssima!'),
(722, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O agente contratado sob o regime da Consolidação das Leis do Trabalho (CLT) para ocupar emprego público na administração direta, autárquica ou nas empresas estatais (sociedades de economia mista e empresas públicas) é classificado juridicamente como EMPREGADO PÚBLICO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Servidor público estatutário ocupa cargo público efetivo e rege-se por estatuto próprio de direito público.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Agente político ocupa cargos estruturais e diretivos da cúpula do Estado (Governador, Secretários, Magistrados).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Agente temporário é contratado por tempo determinado para atender a necessidade temporária de excepcional interesse público (Art. 37, IX).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Agente honorífico presta serviço voluntário cívico transitoriamente (como mesário e jurado).

BIZU DE PROVA:
Classificação dos Agentes Públicos:
- CARGO PÚBLICO -> Servidor Estatutário (Estatuto Próprio);
- EMPREGO PÚBLICO -> Empregado Público (Regime da CLT);
- FUNÇÃO TEMPORÁRIA -> Agente Temporário (Art. 37, IX CF).'),
(728, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Artigo 13 da Lei nº 10.826/2003 (Estatuto do Desarmamento) tipifica o crime de OMISSÃO DE CAUTELA: "Deixar de observar as cautelas necessárias para impedir que menor de 18 (dezoito) anos ou pessoa portadora de deficiência mental se apodere de arma de fogo que esteja sob sua posse ou que seja de sua propriedade." A pena é de detenção de 1 a 2 anos e multa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Posse irregular (Art. 12) consiste em possuir arma sem registro no interior da residência.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Porte ilegal (Art. 14) consiste em portar arma fora do domicílio sem autorização.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Disparo de arma de fogo (Art. 15) consiste em disparar arma em local habitado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Comércio ilegal de arma de fogo (Art. 17) consiste na venda clandestina de armas.

BIZU DE PROVA:
Omissão de Cautela (Art. 13 da Lei nº 10.826/2003):
Deixar arma de fogo ao alcance de MENOR DE 18 ANOS ou de PESSOA COM DEFICIÊNCIA MENTAL = Crime de Omissão de Cautela (Detenção de 1 a 2 anos e multa)!'),
(729, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Se o agente agiu com todas as cautelas exigíveis na guarda de sua arma de fogo legalmente registrada e foi vítima de furto ou roubo perpetrado por terceiro mediante arrombamento ou violência, NÃO responde penalmente pelos disparos ou crimes cometidos pelo terceiro com a arma subtraída, ante a ausência de dolo, culpa ou nexo de causalidade jurídico-penal (Artigo 13 do Código Penal).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A responsabilidade penal objetiva é vedada no direito penal brasileiro.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A condição de proprietário da arma furtada não transfere a autoria de crimes praticados por criminosos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há crime de omissão de cautela se a arma estava devidamente trancada e guardada com segurança.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dever de comunicar o furto/roubo da arma no prazo de 24 horas à Polícia Federal e à Polícia Civil afasta qualquer infração administrativa ou penal.

BIZU DE PROVA:
Furto da Arma de Fogo e Responsabilidade Penal:
A vítima do furto da arma NÃO responde pelos crimes do ladrão, bastando comunicar o fato à Polícia nas primeiras 24 horas!'),
(730, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Nos termos do Artigo 158-B do Código de Processo Penal (Cadeia de Custódia), no isolamento e fixação do local do crime, DEVE SER DESCRITO O LOCAL EXATO EM QUE A ARMA DE FOGO ESTAVA E A SUA POSIÇÃO ESPECÍFICA em relação ao corpo da vítima e ao cenário dos fatos, para assegurar a autenticidade e a idoneidade da perícia balística.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A arma não deve ser recolhida ou movida antes da chegada da perícia oficial, salvo risco iminente de extravio.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A alteração injustificada da cena do crime configura fraude processual (Art. 347 do CP).

POR QUE A ALTERNativa C ESTÁ INCORRETA:
O manuseio inadequado destrói impressões digitais e resíduos balísticos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A exatidão da descrição espacial é indispensável para o laudo pericial de dinâmica dos fatos.

BIZU DE PROVA:
Cadeia de Custódia e Fixação de Vestígios (Art. 158-B do CPP):
Preservar o local, NÃO mexer na arma e documentar a POSIÇÃO EXATA em que ela foi encontrada!'),
(731, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II e III reproduzem condutas tipificadas e regras consolidadas da Lei de Drogas (Lei Federal nº 11.343/2006):
- I. O crime de tráfico de drogas (Art. 33) é tipo misto alternativo com múltiplos núcleos verbais.
- II. A internação involuntária de dependente químico exige autorização médica e comunicação ao Ministério Público em até 72 horas (Art. 23-A).
- III. A destruição de drogas apreendidas por incineração após laudo definitivo e autorização judicial (Art. 50 e 50-A).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois II e III também são assertivas verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I e III também são corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois III também é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois II também integra a lei.

BIZU DE PROVA:
Internação Involuntária de Dependentes (Lei nº 11.343/06 - Art. 23-A):
- Exige laudo médico prévio;
- Realizada a pedido de familiar/responsável legal;
- Comunicação obrigatória ao Ministério Público em até 72 HORAS!'),
(732, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- I. (Correta): O Sistema Nacional de Políticas Públicas sobre Drogas (Sisnad) tem como objetivo articular ações de prevenção, atenção e reinserção social (Art. 3º da Lei 11.343/2006).
- II. (Correta): As atividades de atenção ao usuário devem pautar-se pelo respeito aos direitos humanos e promoção da saúde pública (Art. 4º).
- III. (Incorreta): O usuário de drogas NÃO é submetido a penas privativas de liberdade no Artigo 28 da Lei de Drogas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois o item II também está correto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III está errada (não há prisão para consumo próprio).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III invalida a opção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III torna a opção incorreta.

BIZU DE PROVA:
Sisnad e Princípios (Lei nº 11.343/06):
Foco na redução de danos, direitos fundamentais e reinserção social, sem criminalização com pena de prisão do usuário no Artigo 28!'),
(733, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Está correta APENAS a assertiva III:
- Assertiva I (Incorreta): A competência para legislar sobre normas gerais em matéria de drogas é privativa/concorrente da União, sendo vedado aos Municípios alterar as penas criminais.
- Assertiva II (Incorreta): A autoridade policial não pode aplicar sanções de prisão sumária sem ordem judicial.
- Assertiva III (Correta): A Lei de Drogas prevê mecanismos diferenciados de prevenção ao uso indevido e repressão qualificada às organizações criminosas dedicadas ao tráfico.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I está incorreta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II está incorreta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva I está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas as opções não estão corretas ante as falhas em I e II.

BIZU DE PROVA:
Competência Penal e Lei de Drogas:
Tipificação penal e processo penal são competências PRIVATIVAS DA UNIÃO (Art. 22, I da CF). Leis municipais não podem criar crimes nem alterar penas!'),
(740, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Artigo 243 da Constituição Federal de 1988 e o Artigo 32 da Lei nº 11.343/2006 estabelecem a PROIBIÇÃO ABSOLUTA do cultivo, plantio, venda e colheita de plantas psicotrópicas ilícitas (como a cannabis e a folha de coca) em todo o território nacional (salvo autorização expressa da União para fins exclusivamente científicos e medicinais), acarretando a EXPROPRIAÇÃO CONFISCATÓRIA imediata da propriedade rural ou urbana onde forem localizadas, sem qualquer indenização ao proprietário.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O cultivo para fins recreativos privados não é permitido na legislação brasileira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A comercialização de plantas psicotrópicas ilegais é terminantemente proibida e configura tráfico de drogas (Art. 33, §1º, II).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A tolerância a plantios sem respaldo legal específico inexiste na ordem normativa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A gleba de terra é confiscada pelo Estado e destinada à reforma agrária ou a programas sociais (Art. 243 da CF).

BIZU DE PROVA:
Artigo 243 da CF/88 (Expropriação por Cultivo de Drogas):
Terras utilizadas para cultivo ilegal de plantas psicotrópicas ou trabalho escravo serão EXPROPRIADAS SEM INDENIZAÇÃO!'),
(741, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Lei nº 11.343/2006 (com redação dada pela Lei nº 13.840/2019) dispõe que as ações de atenção e reinserção social de usuários e dependentes de drogas serão articuladas no âmbito do SISTEMA ÚNICO DE SAÚDE (SUS) e do SISTEMA ÚNICO DE ASSISTÊNCIA SOCIAL (SUAS), de forma descentralizada e integrada em todos os entes federativos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A articulação de saúde pública não se restringe a órgãos de trânsito ou previdência isolada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A reinserção social transcende a esfera puramente carcerária ou penal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O sistema educacional atua em parceria, mas a rede pública especializada de acolhimento e tratamento é composta pelo SUS e SUAS.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A rede pública de saúde e assistência social é a base do atendimento multidisciplinar do dependente.

BIZU DE PROVA:
Rede de Atenção ao Usuário de Drogas (Lei 11.343/06):
Trabalho integrado entre SUS (Saúde) e SUAS (Assistência Social) para acolhimento, tratamento e reinserção social!'),
(742, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as assertivas I, II, III e IV estão corretas:
- I. O Estatuto da Igualdade Racial adota a diversidade étnica como valor fundamental.
- II. A promoção da igualdade material através de políticas afirmativas.
- III. O dever do Estado de coibir práticas discriminatórias no serviço público e privado.
- IV. O fomento à educação e inclusão profissional das populações historicamente vulnerabilizadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois todas as assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois I, II e IV também estão corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois II e III também são corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois todas as quatro assertivas são disposições expressas.

BIZU DE PROVA:
Estatuto da Igualdade Racial:
Ações afirmativas constituem políticas públicas legítimas e constitucionais de promoção da igualdade material (STF - ADPF 186)!'),
(743, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- I. (Correta): O STF pacificou no Tema 1.256 da Repercussão Geral que as Guardas Municipais integram o Sistema de Segurança Pública, podendo exercer patrulhamento preventivo e segurança viária comunitária, sem exercer funções exclusivas de polícia judiciária.
- II. (Correta): A função investigativa da Polícia Civil tem caráter residual/subsidiário, apurando as infrações penais não reservadas à Polícia Federal ou à Polícia Militar (crimes militares) nos termos do Art. 144, §4º da CF.
- III. (Incorreta): O Artigo 144, §5º-A, da CF estabelece que as Polícias Penais cuidam da segurança dos estabelecimentos penais, cabendo a administração penitenciária aos órgãos executivos de administração penitenciária.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III está incorreta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III invalida a opção.

BIZU DE PROVA:
Competências de Segurança Pública (Art. 144 da CF/88):
- Polícia Civil: Polícia Judiciária Residual e apuração de infrações (exceto militares e da União);
- Guardas Municipais: Patrulhamento preventivo comunitário (STF);
- Polícia Penal: Segurança dos estabelecimentos penais (EC 104/19)!'),
(771, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 4º, parágrafo único, inciso I e II, da Lei nº 13.869/2019 (Lei de Abuso de Autoridade), a perda do cargo, do mandato ou da função pública é efeito secundário da condenação que:
1) É CONDICIONADO À REINCIDÊNCIA em crime de abuso de autoridade; e
2) NÃO É AUTOMÁTICO, devendo ser expressamente motivado e declarado na sentença penal pelo magistrado.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os crimes de abuso de autoridade não são hediondos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A repercussão na imagem, por si só, não autoriza a decretação de perda sem o preenchimento dos requisitos do art. 4º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A ação penal é pública incondicionada (Art. 3º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A decretação legal exige expressamente a REINCIDÊNCIA específica e fundamentação judicial.

BIZU DE PROVA:
Efeitos da Condenação na Lei de Abuso de Autoridade (Art. 4º da Lei 13.869/19):
- Perda do cargo e Inabilitação (1 a 5 anos) NÃO SÃO AUTOMÁTICOS;
- Exigem OBRIGATORIAMENTE que o agente seja REINCIDENTE e que o juiz JUSTIFIQUE na sentença!'),
(772, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Nos termos do Artigo 3º, §1º, da Lei nº 13.869/2019 e Artigo 29 do Código de Processo Penal, a AÇÃO PENAL PRIVADA SUBSIDIÁRIA DA PÚBLICA será admitida se a denúncia não for intentada no prazo legal pelo Ministério Público, devendo a queixa-crime subsidiária ser proposta pelo ofendido no prazo decadencial de 6 (SEIS) MESES a contar do esgotamento do prazo do MP. Como se passou 1 ano do fato, operou-se a decadência do direito de queixa subsidiária.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os crimes de abuso de autoridade são de ação penal pública incondicionada (Art. 3º, caput).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Constituição (Art. 5º, LIX) e a Lei 13.869/19 admitem expressamente a ação penal privada subsidiária da pública em caso de inércia do MP.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O representante legal ou herdeiros podem exercer a representação/queixa na forma da lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A conduta configura em tese crime de abuso de autoridade, mas a queixa foi rejeitada pela decadência temporal.

BIZU DE PROVA:
Ação Penal Privada Subsidiária da Pública:
- Cabe quando o Ministério Público permanece INERTE (não oferece denúncia nem arquiva no prazo legal);
- Prazo de propositura da queixa subsidiária: 6 MESES (sob pena de DECADÊNCIA)!'),
(773, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Artigo 38, inciso IV, da Constituição Federal estabelece que ao servidor público em exercício de mandato eletivo "em qualquer caso que exija o afastamento para o exercício de mandato eletivo, seu tempo de serviço será contado para todos os efeitos legais, EXCETO PARA PROMOÇÃO POR MERECIMENTO" (pois o merecimento exige desempenho e avaliação funcional efetiva nas atribuições do cargo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O tempo de serviço é contado regularmente para promoção por antiguidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O tempo é computado para fins de aposentadoria e previdência social.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O tempo conta para os demais efeitos legais de carreira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O tempo de afastamento não impede a fruição de direitos gerais assegurados em lei.

BIZU DE PROVA:
Servidor em Mandato Eletivo (Art. 38, IV da CF/88):
Tempo de serviço conta para TUDO (antiguidade, aposentadoria, etc.), EXCETO PARA PROMOÇÃO POR MERECIMENTO!'),
(774, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O princípio constitucional da EFICIÊNCIA (Artigo 37, caput, da CF/88, introduzido pela EC nº 19/1998) impõe à Administração Pública e a seus gestores o dever de buscar a excelência, o rendimento funcional produtivo, a avaliação contínua de desempenho e a otimização dos recursos públicos para a melhor prestação de serviços à sociedade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Concorrência profissional não é princípio constitucional administrativo expresso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Operacionalidade tática é conceito de planejamento operacional interno.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Pessoalidade viola o princípio da impessoalidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A publicidade visa à transparência oficial, e não à promoção pessoal ou popularidade.

BIZU DE PROVA:
Princípio da Eficiência (Art. 37 da CF/88):
Produtividade, qualidade, avaliação de metas e economicidade na execução do serviço público!'),
(776, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 2º, inciso IV, da Lei Federal nº 10.826/2003 (Estatuto do Desarmamento), compete ao Sinarm, no âmbito do DEPARTAMENTO DE POLÍCIA FEDERAL, "cadastrar as transferências de propriedade, extravio, furto, roubo e outras ocorrências suscetíveis de alterar os dados cadastrais, inclusive as decorrentes de fechamento de empresas de segurança privada e de transporte de valores".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Procuradoria-Geral da União exerce a representação judicial e consultoria jurídica da União.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Órgão inexistente na estrutura administrativa federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Comando Militar do Planalto é unidade militar do Exército Brasileiro.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Denominação fictícia inexistente no ordenamento nacional.

BIZU DE PROVA:
Competências do Sinarm / Polícia Federal (Art. 2º da Lei 10.826/03):
Cadastrar armas de uso permitido, autorizações de porte, transferências de propriedade, furtos, roubos e controle de empresas de segurança privada!'),
(777, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 2º, inciso VII, da Lei Federal nº 10.826/2003 (Estatuto do Desarmamento), compete ao SISTEMA NACIONAL DE ARMAS (SINARM), instituído no Ministério da Justiça e gerido pela Polícia Federal, "cadastrar as autorizações de porte de arma de fogo e as renovações expedidas pela Polícia Federal".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Exército Brasileiro gerencia o Sigma (Sistema de Gerenciamento Militar de Armas), restrito a armas de uso restrito e CACs.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Força Nacional é programa de cooperação de segurança pública, não órgão registrador de armas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Senasp é secretaria executiva de formulação de políticas, não o banco de dados cadastral do Sinarm.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Instituto inexistente na estrutura jurídica do desarmamento.

BIZU DE PROVA:
Sinarm vs Sigma (Lei nº 10.826/2003):
- SINARM (Polícia Federal) -> Cadastra armas de uso permitido, transferências e autorizações de porte!
- SIGMA (Comando do Exército) -> Cadastra armas de uso restrito, militares e CACs!'),
(781, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 28 da Lei nº 11.343/2006 (Lei de Drogas) prevê como pena aplicável ao indivíduo que adquire, guarda, transporta ou traz consigo droga para consumo pessoal a ADVERTÊNCIA SOBRE OS EFEITOS DAS DROGAS (Inciso I), além de prestação de serviços à comunidade (Inciso II) e medida educativa de comparecimento a programa ou curso educativo (Inciso III).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A prestação de serviço militar obrigatório é dever constitucional militar, não sanção da Lei de Drogas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O comparecimento a curso educativo tem prazo máximo de 5 meses para o réu primário (Art. 28, §3º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não existe pena de proibição de vestibular na lei penal brasileira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei de Drogas não prevê retenção de CNH por seis meses como pena direta do art. 28.

BIZU DE PROVA:
Penas do Usuário de Drogas (Art. 28 da Lei nº 11.343/06):
1. ADVERTÊNCIA sobre os efeitos das drogas;
2. Prestação de serviços à comunidade;
3. Medida educativa em curso/programa (prazo máximo de 5 meses; se reincidente, até 10 meses)!'),
(782, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Lei Federal nº 11.343/2006 (Lei de Drogas) institui expressamente em seu Artigo 3º o SISTEMA NACIONAL DE POLÍTICAS PÚBLICAS SOBRE DROGAS (SISNAD), que tem por finalidade articular, integrar, organizar e coordenar as atividades e programas relacionados com a prevenção do uso indevido, a atenção e a reinserção social de usuários e dependentes de drogas e a repressão da produção não autorizada e do tráfico ilícito.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Serviço setorial que não expressa o sistema nacional institucional criado pela lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O sistema possui abrangência nacional e federativa integrada.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Denominação fictícia alheia à estrutura da lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As atribuições policiais de repressão são distribuídas entre as Polícias Federal e Civil.

BIZU DE PROVA:
Nome do Sistema da Lei nº 11.343/2006:
SISNAD = Sistema Nacional de Políticas Públicas sobre Drogas!'),
(783, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 28 da Lei nº 11.343/2006, quem adquire, guarda, tiver em depósito, transportar ou trouxer consigo drogas para consumo pessoal será submetido às seguintes penas alternativas:
I - ADVERTÊNCIA SOBRE OS EFEITOS DAS DROGAS;
II - PRESTAÇÃO DE SERVIÇOS À COMUNIDADE;
III - MEDIDA EDUCATIVA DE COMPARECIMENTO A PROGRAMA OU CURSO EDUCATIVO.
Sendo o réu primário, as penas de prestação de serviços e medida educativa serão aplicadas pelo prazo máximo de 5 (cinco) meses (§3º).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 48, §2º da Lei de Drogas proíbe a prisão em flagrante e não há pena de prisão/cárcere para o usuário.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não existe detenção sumária para a conduta do art. 28.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A multa só pode ser aplicada subsidiariamente em caso de recusa injustificada ao cumprimento das medidas educativas anteriores (Art. 28, §6º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A multa não é pena cominada originariamente no preceito secundário do art. 28.

BIZU DE PROVA:
As Três Penas do Artigo 28 da Lei de Drogas:
1. Advertência sobre os efeitos das drogas;
2. Prestação de serviços à comunidade;
3. Comparecimento a programa/curso educativo.
(NÃO HÁ PENA DE PRISÃO!).'),
(793, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A conduta do agente público que submete o preso a constrangimento ilegal, situação humilhante, vexatória ou não autorizada por lei (como obrigá-lo a dançar, cantar ou submeter-se a deboches para diversão de agentes) tipifica o CRIME DE ABUSO DE AUTORIDADE previsto no Artigo 13, incisos I e II, da Lei nº 13.869/2019.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não constitui infração puramente administrativa, havendo responsabilidade penal expressa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A tortura (Lei 9.455/97) exige sofrimento físico ou mental grave voltado a confissão, castigo ou discriminação específica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Prevaricação (Art. 319 CP) tutela a probidade do ato de ofício por sentimento pessoal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Desacato é crime praticado por particular contra agente público, e não pelo agente contra o cidadão.

BIZU DE PROVA:
Submeter Preso a Vexame ou Constrangimento Ilegal (Art. 13 da Lei nº 13.869/19):
Constranger preso a produzir prova contra si ou expô-lo a situação vexatória não autorizada por lei = CRIME DE ABUSO DE AUTORIDADE!'),
(794, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 1º, inciso III, da Constituição Federal de 1988 estabelece a DIGNIDADE DA PESSOA HUMANA como um dos princípios e fundamentos máximos da República Federativa do Brasil, impondo o respeito intransigente à integridade física, moral e psíquica de todo cidadão.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Soberania (Art. 1º, I) expressa a supremacia do Estado no plano interno e internacional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Cidadania (Art. 1º, II) refere-se ao exercício de direitos políticos e civis na sociedade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Pluralismo político (Art. 1º, V) tutela a livre manifestação partidária e ideológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Valores sociais do trabalho e da livre iniciativa constam no Artigo 1º, inciso IV da CF.

BIZU DE PROVA:
Fundamentos da República (Art. 1º CF - SO-CI-DI-VA-PLU):
- SOberania;
- CIdadania;
- DIgnidade da pessoa humana;
- VAlores sociais do trabalho e livre iniciativa;
- PLUralismo político.'),
(795, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 144, §5º, da Constituição Federal e a Constituição Estadual do RS, incumbe à BRIGADA MILITAR (Polícia Militar do Estado do Rio Grande do Sul) a atividade de POLÍCIA OSTENSIVA E A PRESERVAÇÃO DA ORDEM PÚBLICA em todo o território estadual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
À Polícia Civil incumbe a polícia judiciária e apuração de infrações penais (Art. 144, §4º).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Às Guardas Municipais cabe a proteção dos bens, serviços e instalações do Município (Art. 144, §8º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Polícia Federal atua nos crimes federais e polícia judiciária da União (Art. 144, §1º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Polícia Rodoviária Federal atua no patrulhamento ostensivo das rodovias federais (Art. 144, §2º).

BIZU DE PROVA:
Polícia Ostensiva e Preservação da Ordem Pública no RS:
Atribuição constitucional expressa da BRIGADA MILITAR (Polícia Militar do RS)!'),
(796, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Artigo 37, inciso III, da Constituição Federal de 1988 estabelece a regra geral de validade dos concursos públicos: "O prazo de validade do concurso público será de ATÉ DOIS ANOS, PRORROGÁVEL UMA VEZ, POR IGUAL PERÍODO."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O prazo inicial pode ser de até 2 anos (e não obrigatoriamente 1 ano fixo), prorrogável uma única vez.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A prorrogação deve ser por igual período ao fixado no edital (se o edital fixou 2 anos, prorroga por mais 2).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se admite prorrogação indefinida ou por prazo superior ao limite constitucional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A prorrogação é faculdade da Administração dentro do limite constitucional de uma única renovação.

BIZU DE PROVA:
Validade do Concurso Público (Art. 37, III da CF/88):
Validade de ATÉ 2 ANOS + PRORROGÁVEL UMA VEZ por igual período!'),
(798, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Artigo 39 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial) estabelece que o poder público promoverá ações que assegurem a igualdade de oportunidades no mercado de trabalho para a população negra, inclusive mediante a implementação de POLÍTICAS E PROGRAMAS DE FORMAÇÃO PROFISSIONAL, EMPREGO E GERAÇÃO DE RENDA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A lei não concede exclusividade total em vagas privadas a qualquer etnia.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As medidas de inclusão produtiva independem de intervenção estatal no comércio exterior particular.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não prevê regime trabalhista discriminatório ou diferenciado para fins rescisórios.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A igualdade material busca capacitar e integrar os trabalhadores no mercado formal.

BIZU DE PROVA:
Mercado de Trabalho no Estatuto da Igualdade Racial (Art. 39):
O Estado deve implementar ações de FORMAÇÃO PROFISSIONAL, incentivo ao EMPREGO e GERAÇÃO DE RENDA voltadas à população negra!'),
(803, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Sistema Nacional de Políticas Públicas sobre Drogas, instituído pelo Artigo 3º da Lei Federal nº 11.343/2006, é conhecido nacionalmente pela sigla SISNAD.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Sinarm é o Sistema Nacional de Armas (Lei 10.826/2003).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Sigma é o Sistema de Gerenciamento Militar de Armas do Exército.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
SUS é o Sistema Único de Saúde.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
SUAS é o Sistema Único de Assistência Social.

BIZU DE PROVA:
Siglas da Legislação Especial:
- SISNAD -> Drogas (Lei 11.343/06);
- SINARM -> Armas de uso permitido na PF (Lei 10.826/03);
- SIGMA -> Armas no Exército Brasileiro!'),
(804, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Lei Federal nº 11.343/2006 é vulgarmente conhecida e denominada no meio jurídico e concurseiro como a LEI ANTIDROGAS (ou Lei de Drogas), regulando as normas de prevenção, atenção a dependentes e repressão penal ao tráfico de drogas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Estatuto do Desarmamento é a Lei nº 10.826/2003.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Lei de Abuso de Autoridade é a Lei nº 13.869/2019.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Lei Maria da Penha é a Lei nº 11.340/2006.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Estatuto da Igualdade Racial é a Lei nº 12.288/2010.

BIZU DE PROVA:
Mapeamento das Leis Penais Especiais:
- Lei nº 11.343/2006 = Lei de Drogas / Lei Antidrogas;
- Lei nº 10.826/2003 = Estatuto do Desarmamento;
- Lei nº 13.869/2019 = Lei de Abuso de Autoridade;
- Lei nº 11.340/2006 = Lei Maria da Penha.'),
(805, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A instituição e manutenção da Guarda Municipal subordina-se à chefia do Poder Executivo Municipal (GOVERNO MUNICIPAL / PREFEITO), nos termos do Artigo 144, §8º, da Constituição Federal e Artigo 6º da Lei nº 13.022/2014 ("A guarda municipal é subordinada ao chefe do Poder Executivo municipal").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Governo Estadual comanda a Polícia Militar e a Polícia Civil (Art. 144, §6º da CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Governo Federal comanda a Polícia Federal e as Forças Armadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Poder Judiciário exerce a jurisdição, não exercendo comando hierárquico sobre guardas municipais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Poder Legislativo exerce a fiscalização e produção de leis, não o comando administrativo da guarda.

BIZU DE PROVA:
Subordinação da Guarda Municipal (Art. 6º da Lei nº 13.022/2014):
A Guarda Municipal é subordinada DIRETA e EXCLUSIVAMENTE ao CHEFE DO PODER EXECUTIVO MUNICIPAL (Prefeito)!'),
(837, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A conduta do agente público que ingressa ou permanece, clandestina ou astuciosamente, ou à revelia da vontade do ocupante, em imóvel alheio ou suas dependências, sem determinação judicial ou fora das condições estabelecidas em lei, configura o crime de ABUSO DE AUTORIDADE tipificado no Artigo 22 da Lei nº 13.869/2019 (Invasão de Domicílio por Abuso de Autoridade).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não se trata de infração disciplinar isolada, havendo crime específico consumado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A violação de domicílio praticada por agente público no exercício de suas funções é regida pela Lei Especial de Abuso de Autoridade (Art. 22 da Lei 13.869/19).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Prevaricação (Art. 319 CP) exige a motivação de satisfazer interesse ou sentimento pessoal na omissão/retardamento de ato de ofício.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Desacato é delito do particular contra o servidor.

BIZU DE PROVA:
Invasão de Domicílio por Agente Público (Art. 22 da Lei nº 13.869/19):
Entrar em casa alheia sem mandado fora das hipóteses de flagrante = CRIME DE ABUSO DE AUTORIDADE (Pena de detenção de 1 a 4 anos e multa)!'),
(838, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- I. (Correta): O crime de abuso de autoridade é de ação penal pública incondicionada (Art. 3º da Lei 13.869/2019).
- II. (Correta): Admite-se ação penal privada subsidiária da pública se a denúncia não for intentada no prazo legal (Art. 3º, §1º).
- III. (Incorreta): O prazo para ajuizar a ação subsidiária é de 6 (SEIS) MESES a contar do esgotamento do prazo do MP, e não 2 anos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III está errada (prazo decadencial é de 6 meses).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III invalida a opção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III torna o item incorreto.

BIZU DE PROVA:
Ação Penal no Abuso de Autoridade (Art. 3º da Lei 13.869/19):
- Regra: Ação Pública INCONDICIONADA;
- Exceção (se o MP for inerte): Ação Privada SUBSIDIÁRIA no prazo decadencial de 6 MESES!'),
(839, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O crime de invasão de domicílio por abuso de autoridade (Artigo 22, caput, da Lei nº 13.869/2019) comina abstratamente as penas de DETENÇÃO, DE 1 (UM) A 4 (QUATRO) ANOS, E MULTA, SEM PREJUÍZO DA PENA COMINADA À VIOLÊNCIA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A pena prevista no art. 22 é detenção de 1 a 4 anos e multa, e não reclusão de 6 meses a 2 anos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A pena de reclusão não é a espécie cominada nos crimes da Lei 13.869/19 (que comina penas de detenção).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A pena de detenção de 6 meses a 2 anos aplica-se a tipos penais menos graves da lei (como art. 13 e 18).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sanção criminal acumula obrigatoriamente pena privativa de liberdade de detenção e multa cumulativa.

BIZU DE PROVA:
Penas da Lei de Abuso de Autoridade (Lei nº 13.869/2019):
TODOS os crimes cominam pena de DETENÇÃO (divididos em duas faixas: Detenção de 6 meses a 2 anos OU Detenção de 1 a 4 anos)!'),
(840, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 55 da Lei do Processo Administrativo (Lei Federal nº 9.784/1999) e a teoria geral do Direito Administrativo, em decisão na qual se evidencie não acarretarem lesão ao interesse público nem prejuízo a terceiros, os atos que apresentarem defeitos sanáveis poderão ser CONVALIDADOS (sanados/corrigidos retroativamente) pela própria Administração Pública.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Revogação incide sobre atos válidos e discricionários por juízo de conveniência e oportunidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Anulação extingue atos com vícios insanáveis de legalidade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Cassação extingue o ato quando o beneficiário descumpre condições supervenientes obrigatórias.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Caducidade extingue o ato em razão de norma jurídica superveniente que proíbe a atividade.

BIZU DE PROVA:
Convalidação de Atos Administrativos (Art. 55 da Lei nº 9.784/99):
- Vícios SANÁVEIS (Competência em razão da pessoa e Forma não essencial);
- Sem prejuízo a terceiros e sem lesão ao interesse público;
- Efeitos RETROATIVOS (Ex Tunc)!'),
(841, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O atributo do poder de polícia pelo qual a Administração Pública pode empregar meios diretos de coerção física e imposição imperativa da obrigação estabelecida na lei, vencendo eventuais resistências do particular, denomina-se COERCIBILIDADE (ou imperatividade).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Discricionariedade é a margem de liberdade para escolha de oportunidade e conveniência nos limites da lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Autoexecutoriedade é a faculdade de executar diretamente a decisão sem ordem judicial prévia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Tipicidade exige que o ato corresponda a figuras previamente delineadas no ordenamento.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Presunção de legitimidade diz respeito à presunção relativa de conformidade do ato com o Direito.

BIZU DE PROVA:
Atributos do Poder de Polícia:
- COERCIBILIDADE: Imposição forçada e uso da força legítima para fazer cumprir o ato;
- AUTOEXECUTORIEDADE: Execução direta sem precisar de autorização judicial prévia;
- DISCRICIONARIEDADE: Juízo de conveniência e oportunidade.'),
(842, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A alternativa D é a INCORRETA (gabarito) porque, conforme o Artigo 6º da Constituição do Estado do Rio Grande do Sul, a DATA MAGNA do Estado do Rio Grande do Sul é o dia 20 DE SETEMBRO (feriado estadual em celebração à Revolução Farroupilha), e NÃO o dia 7 de setembro (que é o feriado nacional da Independência do Brasil).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirmativa correta: o RS integra a República Federativa do Brasil com autonomia político-administrativa (Art. 1º da CE/RS).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: os Poderes do Estado são a Assembleia Legislativa, o Governador e o Tribunal de Justiça (Art. 5º da CE/RS).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: são símbolos do RS a bandeira, o hino e o brasão (Art. 6º da CE/RS).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: a cidade de Porto Alegre é a Capital do Estado (Art. 7º da CE/RS).

BIZU DE PROVA:
Constituição do RS - Data Magna Estadual (Art. 6º):
A Data Magna e Feriado do Estado do RS é o DIA 20 DE SETEMBRO (Revolução Farroupilha)!'),
(843, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O comando da questão solicita a entidade que NÃO integra a Administração Pública Indireta estatal. AS EMPRESAS PRIVADAS são pessoas jurídicas de direito privado do mercado econômico particular que NÃO integram a estrutura da Administração Pública Indireta (a qual é composta exclusivamente por autarquias, fundações públicas, empresas públicas e sociedades de economia mista nos termos do Art. 37, XIX da CF e Art. 4º do DL 200/67).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Autarquias integram expressamente a administração indireta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Fundações públicas integram a administração indireta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Empresas públicas integram a administração indireta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Sociedades de economia mista integram a administração indireta.

BIZU DE PROVA:
Administração Indireta (Mnemônico F-A-S-E):
- Fundações Públicas;
- Autarquias;
- Sociedades de Economia Mista;
- Empresas Públicas.
(Empresas Privadas comuns NÃO integram a Administração!).'),
(844, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 7º, inciso XVIII, da Constituição Federal de 1988 (aplicável aos servidores públicos civis por força do Artigo 39, §3º) assegura a "LICENÇA À GESTANTE, SEM PREJUÍZO DO EMPREGO E DA REMUNERAÇÃO, COM A DURAÇÃO DE 120 (CENTO E VINTE) DIAS".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A licença-paternidade é fixada originariamente em 5 dias na CF/ADCT, não havendo prazo ordinário constitucional irrestrito de 30 dias na regra geral do art. 7º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O aviso prévio proporcional ao tempo de serviço é direito dos trabalhadores celetistas, e não garantia inerente a servidores estatutários estáveis.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O seguro-desemprego em caso de demissão sem justa causa aplica-se a empregados regidos pela CLT.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O FGTS não é direito constitucional extensível obrigatoriamente a servidores estatutários ocupantes de cargos efetivos.

BIZU DE PROVA:
Licença à Gestante na CF/88 (Art. 7º, XVIII e Art. 39, §3º):
Duração mínima constitucional de 120 DIAS sem prejuízo da remuneração e do cargo!'),
(845, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Integram a ADMINISTRAÇÃO PÚBLICA INDIRETA (Artigo 37, inciso XIX, da Constituição Federal e Decreto-Lei nº 200/1967):
1. Autarquias;
2. Fundações Públicas;
3. Empresas Públicas;
4. Sociedades de Economia Mista.
A alternativa C relaciona com precisão entidades que compõem a Administração Indireta.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Ministérios e Secretarias são órgãos despersonalizados da administração direta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Prefeituras e Câmaras Municipais são sedes e órgãos da administração direta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Órgãos policiais sem personalidade jurídica integram a administração direta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Tribunais de Justiça integram a administração direta do Poder Judiciário.

BIZU DE PROVA:
Administração Direta vs Indireta:
- DIRETA: União, Estados, DF e Municípios (e seus órgãos internos: Ministérios, Secretarias, Departamentos);
- INDIRETA: Autarquias, Fundações, Empresas Públicas e Sociedades de Economia Mista.'),
(850, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A ordem correta é V – V – V:
- (V) O Artigo 4º da Lei nº 10.826/2003 exige comprovação de idoneidade com certidões negativas criminais para aquisição de arma de fogo.
- (V) O Artigo 6º elenca as categorias funcionais com autorização legal de porte de arma de fogo em razão do serviço.
- (V) O Artigo 10 estabelece que a autorização de porte de arma de fogo para civis é de competência da Polícia Federal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda e terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Todas as três assertivas são verdadeiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

BIZU DE PROVA:
Estatuto do Desarmamento (Lei nº 10.826/2003):
Certidões negativas, autorização federal pelo Sinarm/PF e porte funcional vinculado aos órgãos de segurança pública!'),
(851, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta de preenchimento é V – V – V:
- (V) O Artigo 12 da Lei nº 10.826/2003 tipifica a posse irregular de arma de uso permitido no interior da residência ou dependência desta.
- (V) O Artigo 14 tipifica o porte ilegal de arma de uso permitido fora da residência.
- (V) O Artigo 15 tipifica o disparo de arma de fogo em local habitado ou em sua direção.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda e terceira assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Todas as três assertivas reproduzem os tipos penais dos artigos 12, 14 e 15 da Lei nº 10.826/2003.

BIZU DE PROVA:
Crimes do Estatuto do Desarmamento:
- Art. 12 = Posse dentro de casa/trabalho (Detenção de 1 a 3 anos);
- Art. 14 = Porte na rua/carro (Reclusão de 2 a 4 anos);
- Art. 15 = Disparo em via pública/local habitado (Reclusão de 2 a 4 anos).'),
(852, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é V – V – F:
- (V) O Artigo 16 da Lei nº 10.826/2003 tipifica a posse ou porte ilegal de arma de fogo de uso restrito.
- (V) O Artigo 16, §1º, inciso I, pune nas mesmas penas a conduta de portar arma com numeração raspada ou suprimida.
- (F) A conduta de entregar arma a menor de 18 anos configura o crime do Artigo 16, §1º, inciso V (Reclusão de 3 a 6 anos), e NÃO mera contravenção penal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira e a segunda assertivas são verdadeiras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A terceira assertiva é falsa (é crime grave, e não contravenção).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A terceira assertiva é falsa.

BIZU DE PROVA:
Arma Entregue a Criança ou Adolescente:
Entregar ou fornecer arma a menor de 18 anos é CRIME DO ARTIGO 16, §1º, V da Lei 10.826/03 punido com RECLUSÃO!'),
(853, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 3º, parágrafo único, da Lei Federal nº 10.826/2003 (Estatuto do Desarmamento) prevê que as armas de fogo de uso restrito serão registradas no COMANDO DO EXÉRCITO (Sigma - Sistema de Gerenciamento Militar de Armas).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Polícia Federal registra no Sinarm as armas de uso permitido.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Polícia Militar é órgão estadual e não detém competência de registro nacional militar de uso restrito.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Polícia Civil exerce polícia judiciária estadual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Ministério da Justiça abriga o Sinarm (gerido pela PF), cabendo o registro de uso restrito ao Comando do Exército.

BIZU DE PROVA:
Registro de Armas de Fogo:
- Armas de Uso PERMITIDO -> Polícia Federal / SINARM;
- Armas de Uso RESTRITO -> COMANDO DO EXÉRCITO / SIGMA!'),
(854, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Conforme o Artigo 28 da Lei Federal nº 10.826/2003 (Estatuto do Desarmamento), o interessado na aquisição de arma de fogo de uso permitido deverá declarar a efetiva necessidade e comprovar ter a idade mínima de 25 (VINTE E CINCO) ANOS (ressalvados os integrantes dos órgãos de segurança pública e forças armadas).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
18 anos é a idade da maioridade penal/civil geral, mas não autoriza a compra civil de armas de fogo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
21 anos é idade de elegibilidade para prefeito e deputados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A lei fixa taxativamente o requisito etário em 25 anos completos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
30 anos é limite para governador de Estado.

BIZU DE PROVA:
Idade Mínima para Comprar Arma de Fogo Civil (Art. 28 da Lei nº 10.826/2003):
Mínimo de 25 ANOS de idade!'),
(855, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 19 da Lei nº 10.826/2003, nos crimes de porte e posse ilegal de arma de fogo de uso permitido ou restrito (Arts. 12, 14, 15, 16, 17 e 18), A PENA É AUMENTADA DA METADE se forem praticados por integrantes dos órgãos e empresas de segurança pública, Forças Armadas ou guardas municipais. O porte de arma com numeração suprimida classifica-se no Art. 16 (Uso Restrito/Equiparado) com aplicação da causa de AUMENTO DE PENA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A numeração suprimida desloca o fato para o art. 16, e a condição funcional incide o aumento de pena do art. 19.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não configura infração administrativa com redução de pena.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A pena é aumentada da metade (Art. 19).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tipificação penal decorre da alteração da numeração de série da arma.

BIZU DE PROVA:
Causa de Aumento do Estatuto do Desarmamento (Art. 19):
Pena AUMENTADA DE METADE (1/2) se o crime for praticado por integrante de órgão de segurança pública, Forças Armadas ou empresa de segurança privada!'),
(856, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A conduta do agente público que, dolosamente e com o fim de obter vantagem ilícita ou favorecer terceiros, frustra a licitude de concurso público ou processo seletivo (Artigo 11, inciso V, da Lei nº 8.429/1992, com redação da Lei nº 14.230/2021) ATENTA CONTRA OS PRINCÍPIOS DA ADMINISTRAÇÃO PÚBLICA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Frustrar a licitude de concurso público é ato expressamente tipificado no Artigo 11 (atentado aos princípios).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O enriquecimento ilícito (Art. 9º) exige a demonstração de acréscimo patrimonial direto recebido pelo agente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A conduta tipificada no art. 11, V independe de prejuízo financeiro material direto comprovado nos cofres.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A ação dolosa tipifica ato de improbidade administrativa sancionado pela LIA.

BIZU DE PROVA:
Fraudar Concurso Público (Art. 11, V da LIA):
Frustrar a licitude de concurso público = Ato de Improbidade que ATENTA CONTRA OS PRINCÍPIOS DA ADMINISTRAÇÃO PÚBLICA!'),
(857, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Na hipótese em que o agente público Josué permite dolosamente que seu amigo Salomão utilize máquinas públicas do Estado em construção particular particular, ambos concorreram para ato de improbidade administrativa previsto no Artigo 10, inciso II, da Lei nº 8.429/1992 (LIA), que tipifica como ato causador de PREJUÍZO AO ERÁRIO permitir ou concorrer para que pessoa física ou jurídica utilize bens ou valores do patrimônio público sem observância legal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Josué praticou ato de prejuízo ao erário (art. 10, II), e não enriquecimento ilícito próprio.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A tipificação primária do empréstimo indevido de bens públicos a terceiros é a lesão ao erário.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Havendo dano patrimonial específico tipificado no art. 10, afasta-se a aplicação genérica subsidiária do art. 11.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Ambos praticaram ato doloso sancionável pela Lei de Improbidade Administrativa.

BIZU DE PROVA:
Ceder Máquinas / Bens Públicos a Terceiros:
Conduta dolosa que CAUSA PREJUÍZO AO ERÁRIO (Artigo 10, II da Lei nº 8.429/92)!'),
(858, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Nos termos do Artigo 11, inciso VI, da Lei nº 8.429/1992 (redação dada pela Lei nº 14.230/2021), constitui ato de improbidade administrativa que ATENTA CONTRA OS PRINCÍPIOS DA ADMINISTRAÇÃO PÚBLICA "deixar de prestar contas, quando esteja obrigado a fazê-lo, desde que disponha das condições para isso, com vistas a ocultar irregularidades".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Omitir contas com o fim de ocultar irregularidades é tipificado no Artigo 11 (princípios), e não enriquecimento ilícito do Art. 9º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A tipificação do art. 11, VI tutela o princípio da publicidade/prestação de contas, prescindindo de comprovação de desfalque financeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Sem demonstração de desvio financeiro materializado, a imputação restringe-se ao atentado a princípios do art. 11.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A conduta dolosa com fim de ocultar irregularidades é ato de improbidade consumado.

BIZU DE PROVA:
Deixar de Prestar Contas para Ocultar Irregularidades (Art. 11, VI da LIA):
Ato de Improbidade que ATENTA CONTRA OS PRINCÍPIOS da Administração Pública!'),
(859, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ao aceitar 2 mil reais de familiar de detento para facilitar a entrada de aparelho celular no presídio, Roberval cometeu ato de improbidade administrativa que IMPORTA ENRIQUECIMENTO ILÍCITO (Artigo 9º, inciso I, da Lei nº 8.429/1992 - receber vantagem econômica indevida para tolerar a prática de ilícito ou omitir ato de ofício) e que atenta contra os deveres éticos da função pública.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O ato não causou prejuízo financeiro direto ao erário público, mas sim corrupção/enriquecimento ilícito do agente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A conduta configura primordialmente o enriquecimento ilícito do Artigo 9º pela percepção da propina.

POR QUE A ALTERNativa D ESTÁ INCORRETA:
A imputação de prejuízo ao erário exige perda patrimonial financeira comprovada dos cofres públicos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Roberval praticou ato gravíssimo de improbidade administrativa e crime de corrupção passiva (Art. 317 do CP).

BIZU DE PROVA:
Agente que Recebe Propina para Facilitar Entrada de Celular na Cadeia:
Ato de Improbidade por ENRIQUECIMENTO ILÍCITO (Artigo 9º, I da Lei nº 8.429/92) e Crime de Corrupção Passiva!'),
(860, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 8º-A da Lei nº 8.429/1992 (LIA, incluído pela Lei nº 14.230/2021) estabelece: "A responsabilidade sucessória de que trata o art. 8º desta Lei aplica-se também na hipótese de alteração contratual, de transformação, de incorporação, de fusão ou de cisão societária. Parágrafo único. Nas hipóteses de fusão e de incorporação, a responsabilidade da sucessora SERÁ RESTRITA À OBRIGAÇÃO DE REPARAÇÃO INTEGRAL DO DANO CAUSADO, ATÉ O LIMITE DO PATRIMÔNIO TRANSFERIDO, NÃO LHE SENDO APLICÁVEIS AS DEMAIS SANÇÕES decorrentes de atos e de fatos ocorridos antes da data da fusão ou da incorporação, EXCETO no caso de simulação ou de evidente intuito de fraude, devidamente comprovados."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A reparação do dano até o limite do patrimônio transferido opera mesmo sem fraude; a fraude autoriza aplicar as demais sanções.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A responsabilidade limita-se expressamente ao valor do patrimônio transferido na fusão/incorporação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As demais sanções (multa, proibição de contratar) NÃO são aplicáveis à sucessora lícita (salvo fraude).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A exceção exige a comprovação inequívoca de simulação ou fraude, não bastando mera suspeita.

BIZU DE PROVA:
Fusão e Incorporação na Nova LIA (Art. 8º-A da Lei nº 8.429/92):
A empresa sucessora responde APENAS pelo ressarcimento do dano até o limite do patrimônio transferido (NÃO recebe as outras sanções, salvo se comprovada FRAUDE)!'),
(867, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O cultivo ou plantio de gleba de 300 m² completamente ocupada por pés de maconha (Cannabis sativa) configura a figura típica equiparada ao tráfico de drogas do Artigo 33, §1º, inciso II, da Lei nº 11.343/2006: "Incorre nas mesmas penas quem semeia, cultiva ou faz a colheita, sem autorização ou em desacordo com determinação legal ou regulamentar, de plantas que se constituam em matéria-prima para a preparação de drogas." Trata-se do CRIME DE PLANTIO DE PLANTAS COMO MATÉRIA-PRIMA PARA PREPARAÇÃO DE DROGAS.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O plantio de substâncias entorpecentes ilegais é conduta criminosa e não atividade econômica informal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Tipificação inexistente que ignora a natureza ilícita do vegetal entorpecente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A alegação de uso próprio não descaracteriza a figura do plantio em escala de 300 m² no art. 33, §1º, II.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se trata de infração ambiental leve, mas de crime grave contra a saúde pública da Lei de Drogas.

BIZU DE PROVA:
Cultivar Plantas que são Matéria-Prima de Drogas (Art. 33, §1º, II da Lei 11.343/06):
Equiparado ao TRÁFICO DE DROGAS com pena de reclusão de 5 a 15 anos!'),
(868, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta de preenchimento é F – V – V:
- (F) O ato tem expressa previsão legal no Artigo 33, §3º, da Lei nº 11.343/2006 (Uso Compartilhado de Drogas), logo é falsa a assertiva de falta de previsão legal.
- (V) Constitui crime expressamente tipificado na Lei de Drogas (Art. 33, §3º).
- (V) O Artigo 33, §3º comina expressamente pena privativa de liberdade de DETENÇÃO de 6 (seis) meses a 1 (um) ano e pagamento de 700 a 1.500 dias-multa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva é falsa e a terceira é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira assertiva é falsa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A segunda assertiva é verdadeira.

BIZU DE PROVA:
Uso Compartilhado de Drogas (Art. 33, §3º da Lei nº 11.343/2006):
Oferecer droga, eventualmente e SEM objetivo de lucro, a pessoa de seu relacionamento para JUNTOS a consumirem = CRIME com pena de DETENÇÃO de 6 meses a 1 ano!'),
(869, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O Artigo 28, inciso I, da Lei nº 11.343/2006 prevê a pena de advertência sobre os efeitos das drogas.
- Assertiva II (Correta): O Artigo 28, inciso III, prevê a medida educativa de comparecimento a programa ou curso educativo.
- Assertiva III (Incorreta): O Artigo 48, §2º, da Lei de Drogas VEDA expressamente a prisão em flagrante e imposição de fiança ao autor de posse para consumo pessoal, lavrando-se apenas Termo Circunstanciado de Ocorrência (TCO).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é pena cominada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III é expressamente vedada na lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III invalida a opção.

BIZU DE PROVA:
Penas do Usuário de Drogas (Art. 28 da Lei nº 11.343/2006):
1. Advertência sobre os efeitos das drogas;
2. Prestação de serviços à comunidade;
3. Medida educativa em curso.
(PROIBIDA A PRISÃO EM FLAGRANTE - Art. 48, §2º)!'),
(870, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A alternativa A é a INCORRETA (gabarito) porque o Artigo 23-A, §1º, da Lei nº 11.343/2006 (incluído pela Lei nº 13.840/2019) veda expressamente a realização de qualquer modalidade de internação (voluntária ou involuntária) nas comunidades terapêuticas acolhedoras, destinando-se estas apenas ao acolhimento residencial transitório voluntário em ambiente protegido, devendo a internação médica ocorrer em unidades de saúde e hospitais gerais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa correta: reproduz fielmente o Artigo 23-A, §8º da Lei de Drogas (comunicação em até 72 horas ao MP e Defensoria).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa correta: reflete o Artigo 23-A, §2º da Lei de Drogas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa correta: reproduz o Artigo 23-A, §5º, inciso III da Lei de Drogas (prazo máximo de 90 dias).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa correta: espelha o Artigo 23-A, §4º da Lei de Drogas.

BIZU DE PROVA:
Internação de Dependentes de Drogas (Art. 23-A da Lei nº 11.343/06):
- Comunidades Terapêuticas: Acolhimento voluntário (É PROIBIDO INTERNAÇÃO médica nelas!);
- Internação Involuntária: Máximo de 90 DIAS e comunicação ao MP em até 72 HORAS!'),
(871, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O comando da questão pede o ato que NÃO representa exemplo de exercício do poder de polícia da Administração Pública. A "fiscalização de atos e comportamento dos subalternos" é manifestação clássica do PODER HIERÁRQUICO e do PODER DISCIPLINAR (que incidem internamente sobre os servidores públicos da própria estrutura administrativa), e NÃO do Poder de Polícia (que incide externamente sobre particulares em geral condicionando direitos e liberdades).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apreensão de alimentos deteriorados é exercício típico do poder de polícia sanitária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Fechamento de restaurante sem higiene é exercício do poder de polícia sanitária.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Fechamento de teatro por falta de segurança é exercício do poder de polícia de segurança e ordem pública.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Embargo de obra irregular é ato clássico de poder de polícia de construções/urbanística.

BIZU DE PROVA:
Poder de Polícia vs Poder Hierárquico/Disciplinar:
- Fiscalizar e punir SERVIDOR SUBORDINADO -> Poder Hierárquico e Disciplinar (Interno);
- Fiscalizar e interditar ESTABELECIMENTO DE PARTICULAR -> Poder de Polícia (Externo)!');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 100 (exceto explicacao/atualizado_em).
create temporary table _le100_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,646,647,649,650,651,652,653,654,655,656,664,665,666,667,668,669,670,674,675,676,677,678,712,713,714,716,717,718,719,720,721,722,728,729,730,731,732,733,740,741,742,743,771,772,773,774,776,777,781,782,783,793,794,795,796,798,803,804,805,837,838,839,840,841,842,843,844,845,850,851,852,853,854,855,856,857,858,859,860,867,868,869,870,871);

-- 2) alternativas completas das 100.
create temporary table _le100_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,646,647,649,650,651,652,653,654,655,656,664,665,666,667,668,669,670,674,675,676,677,678,712,713,714,716,717,718,719,720,721,722,728,729,730,731,732,733,740,741,742,743,771,772,773,774,776,777,781,782,783,793,794,795,796,798,803,804,805,837,838,839,840,841,842,843,844,845,850,851,852,853,854,855,856,857,858,859,860,867,868,869,870,871)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _le100_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _le100_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _le100_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _le100_novas_explicacoes) <> 100 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 100 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _le100_novas_explicacoes);
  if v_qtd <> 100 then
    raise exception 'PRECONDICAO FALHOU: esperado 100 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _le100_novas_explicacoes s on s.id = q.id
    where q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 100 questoes nao esta ativa (ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza SOMENTE explicacao das 100.
-- ----------------------------------------------------------------------------
create temporary table _le100_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao
    from _le100_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _le100_ids_afetados (id) select id from atualizado;

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
  insert into _le100_asserts (descricao, ok)
  select 'exatamente 100 questoes afetadas pelo UPDATE', (select count(*) from _le100_ids_afetados) = 100;

  insert into _le100_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 100 esperados',
    (select array_agg(id order by id) from _le100_ids_afetados) = (select array_agg(id order by id) from _le100_novas_explicacoes);

  insert into _le100_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 100 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _le100_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _le100_asserts (descricao, ok)
  select 'alternativas das 100 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _le100_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _le100_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _le100_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _le100_asserts (descricao, ok) values ('as 100 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 100 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _le100_novas_explicacoes)
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
    where q.id in (select id from _le100_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _le100_asserts (descricao, ok) values ('as 100 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 100);

  insert into _le100_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _le100_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,646,647,649,650,651,652,653,654,655,656,664,665,666,667,668,669,670,674,675,676,677,678,712,713,714,716,717,718,719,720,721,722,728,729,730,731,732,733,740,741,742,743,771,772,773,774,776,777,781,782,783,793,794,795,796,798,803,804,805,837,838,839,840,841,842,843,844,845,850,851,852,853,854,855,856,857,858,859,860,867,868,869,870,871]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _le100_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _le100_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _le100_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _le100_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _le100_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _le100_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
