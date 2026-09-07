-- Teste transacional completo do lote DH-AUT-07: OLD -> APPLY (insercao
-- das 20 questoes/100 alternativas/20 vinculos) -> verificar TARGET ->
-- executar a logica REAL de reversao (DELETE por enunciado exato, a
-- mesma usada em supabase/reverter_dh_aut_07.sql) -> verificar OLD
-- restaurado -> ROLLBACK final.
--
-- Todos os passos sao registrados em _relatorio como insert...select em
-- vez de RAISE EXCEPTION, para que o teste inteiro rode ate o fim e
-- produza um relatorio completo mesmo se algo falhar. Termina em
-- ROLLBACK — nenhuma alteracao e persistida.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 96) as cc96_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 97) as cc97_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 98) as cc98_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 99) as cc99_uteis,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 13) as q13_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 29) as q29_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 177) as q177_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 178) as q178_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 179) as q179_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 263) as q263_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 264) as q264_hash;

create temporary table _lote_questoes (
  ordem int primary key, codigo text, unidade_id uuid, assunto_id bigint,
  cc_id int, dificuldade text, fonte text, enunciado text
) on commit drop;
insert into _lote_questoes (ordem, codigo, unidade_id, assunto_id, cc_id, dificuldade, fonte, enunciado) values
(1,'cc96-01','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'facil','PAPIRO — DH-AUT-07 — cc96-01 — Decreto 7037/2009 art.1 aprovacao do PNDH-3',
 'Conforme as disposições iniciais do Decreto nº 7.037/2009, o Programa Nacional de Direitos Humanos (PNDH-3) é:'),
(2,'cc96-02','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'media','PAPIRO — DH-AUT-07 — cc96-02 — Decreto 7037/2009 Anexo os 6 Eixos Orientadores',
 'O Programa Nacional de Direitos Humanos (PNDH-3) é estruturado a partir de Eixos Orientadores. Assinale a alternativa que apresenta de forma completa, e com a correta correspondência numérica, os seis Eixos Orientadores do Programa.'),
(3,'cc96-03','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'media','PAPIRO — DH-AUT-07 — cc96-03 — Decreto 7037/2009 Eixo III universalizar direitos',
 'O Decreto nº 7.037/2009 estrutura o Programa Nacional de Direitos Humanos (PNDH-3) de forma temática. O segmento denominado expressamente como "Universalizar direitos em um contexto de desigualdades" corresponde, na estrutura do Programa, ao:'),
(4,'cc96-04','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'media','PAPIRO — DH-AUT-07 — cc96-04 — Decreto 7037/2009 Diretriz 10 no Eixo III',
 'No âmbito do Programa Nacional de Direitos Humanos (PNDH-3), a Diretriz 10, que dispõe especificamente sobre a "Garantia da igualdade na diversidade", integra expressamente qual dos seguintes Eixos Orientadores?'),
(5,'cc96-05','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'dificil','PAPIRO — DH-AUT-07 — cc96-05 — Decreto 7177/2010 art.7 revogacao pontual',
 'O Decreto nº 7.177/2010 promoveu alterações pontuais no texto do Programa Nacional de Direitos Humanos (PNDH-3). A respeito dos efeitos jurídicos e da extensão material dessas alterações normativas na estrutura do Programa, notadamente no que tange à laicidade do Estado e à diversidade, assinale a alternativa correta.'),
(6,'cc96-06','384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid,95,96,'media','PAPIRO — DH-AUT-07 — cc96-06 — Decreto 10087/2019 revogacao do art.4',
 'O Decreto nº 10.087/2019 determinou a revogação do art. 4º do Decreto nº 7.037/2009, dispositivo que tratava expressamente do Comitê de Acompanhamento e Monitoramento do PNDH-3. Sobre a extensão dos efeitos normativos dessa revogação perante o ordenamento jurídico, é correto afirmar que ela:'),
(7,'cc97-01','9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid,98,97,'facil','PAPIRO — DH-AUT-07 — cc97-01 — Lei 12288/2010 art.11 ensino historia da Africa',
 'Nos termos estritos do art. 11 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial), o estudo da história geral da África e da história da população negra no Brasil é fixado como:'),
(8,'cc98-01','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'facil','PAPIRO — DH-AUT-07 — cc98-01 — CF art.1 III dignidade da pessoa humana',
 'A Constituição Federal de 1988 estabelece os princípios essenciais que delineiam a estrutura do Estado brasileiro. Nos termos expressos e diretos do art. 1º, inciso III, da referida Constituição, constitui um dos fundamentos da República Federativa do Brasil:'),
(9,'cc98-02','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'media','PAPIRO — DH-AUT-07 — cc98-02 — CF art.1 I a V matching dos cinco fundamentos',
 'A República Federativa do Brasil, constituída em Estado Democrático de Direito, possui fundamentos estruturantes expressamente enumerados no art. 1º da Constituição Federal. Assinale a alternativa que elenca, de forma exata e completa, o conteúdo jurídico correspondente aos cinco incisos desse artigo constitucional.'),
(10,'cc98-03','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'dificil','PAPIRO — DH-AUT-07 — cc98-03 — DUDH art.1 x CF art.1 III fonte e funcao',
 'A dignidade da pessoa humana possui reconhecimento tanto no ordenamento jurídico interno quanto no âmbito internacional dos Direitos Humanos. Comparando-se a literalidade do art. 1º da Constituição Federal de 1988 e a do art. 1º da Declaração Universal dos Direitos Humanos (DUDH), é correto afirmar, quanto à função normativa e à origem desses preceitos, que:'),
(11,'cc98-04','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'facil','PAPIRO — DH-AUT-07 — cc98-04 — DUDH art.1 segunda parte razao e fraternidade',
 'O texto do art. 1º da Declaração Universal dos Direitos Humanos (DUDH) não apenas assevera que todos os seres humanos nascem livres e iguais em dignidade e em direitos, mas também fixa outras premissas essenciais a respeito da condição humana. Segundo a disposição expressa dessa segunda parte do artigo, os seres humanos são dotados de:'),
(12,'cc98-05','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'dificil','PAPIRO — DH-AUT-07 — cc98-05 — DUDH art.1 e CF art.1 II III assertivas combinadas',
 E'Analise as assertivas abaixo acerca das normas fundamentais estruturadas na Declaração Universal dos Direitos Humanos (DUDH) e na Constituição Federal de 1988 (CF):\n\nI. O art. 1º da Declaração Universal dos Direitos Humanos expressamente estabelece, como fundamentos estruturantes da República, a dignidade da pessoa humana e a cidadania material.\n\nII. O art. 1º da Constituição Federal prevê explicitamente que todos os seres humanos nascem livres e iguais em dignidade e direitos, dotados que são de razão e de consciência.\n\nIII. Na Constituição Federal, a cidadania e a dignidade da pessoa humana estão consagradas e enumeradas expressamente como fundamentos da República Federativa do Brasil em seu art. 1º.\n\nQuais estão corretas?'),
(13,'cc98-06','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'media','PAPIRO — DH-AUT-07 — cc98-06 — CF art.1 polaridade invertida fundamento inexistente',
 'O art. 1º da Constituição Federal de 1988 estabelece claramente os fundamentos que sustentam a República Federativa do Brasil. Assinale a alternativa que NÃO corresponde corretamente a um desses fundamentos previstos na norma constitucional.'),
(14,'cc98-07','70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid,12,98,'media','PAPIRO — DH-AUT-07 — cc98-07 — CF art.1 IV fundamento composto unico',
 'No tocante à estrutura formal do art. 1º da Constituição Federal, que elenca os fundamentos da República Federativa do Brasil, é correto afirmar que formam, de forma conjunta, um único e mesmo fundamento expresso normativamente em um só inciso:'),
(15,'cc99-01','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'media','PAPIRO — DH-AUT-07 — cc99-01 — Convencao ONU Tortura art.2 item 2 rol exemplificativo',
 'Nos exatos termos do art. 2º, item 2, da Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes, o princípio geral é o de que nenhuma circunstância excepcional poderá ser invocada como justificação para a tortura. O texto dessa norma exemplifica, no rol de sua redação, que não servem de justificativa circunstâncias excepcionais tais como:'),
(16,'cc99-02','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'media','PAPIRO — DH-AUT-07 — cc99-02 — Convencao ONU Tortura art.2 item 3 ordem superior',
 'De acordo com o disposto expressamente no art. 2º, item 3, da Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes, é correto afirmar sobre as esferas de subordinação hierárquica que:'),
(17,'cc99-03','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'dificil','PAPIRO — DH-AUT-07 — cc99-03 — Convencao ONU Tortura art.2 itens 2 e 3 combinados',
 E'Analise as assertivas abaixo, que dispõem sobre as vedações presentes no art. 2º da Convenção da ONU contra a Tortura:\n\nI. O estado de guerra ou ameaça de guerra, bem como a instabilidade política interna, configuram circunstâncias excepcionais que, por previsão normativa, não podem ser invocadas como justificação para a tortura.\n\nII. A ordem de um funcionário superior ou de uma autoridade pública, diferentemente das circunstâncias excepcionais (como as emergências públicas), constitui causa jurídica que, embora não seja capaz de promover total justificação, admite atenuação expressa da sanção aplicável à tortura perante a Convenção.\n\nIII. Nos estritos termos convencionais vigentes, a ordem de uma autoridade pública, assim como no caso das emergências políticas internas, também não pode ser invocada como justificação para a tortura.\n\nQuais estão corretas?'),
(18,'cc99-04','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'media','PAPIRO — DH-AUT-07 — cc99-04 — OPCAT art.1 sistema de visitas regulares',
 'O Protocolo Facultativo à Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (OPCAT) tem o seu objetivo delineado de modo estrutural já no seu artigo inaugural. Conforme previsto no art. 1º, o objetivo do Protocolo consiste em:'),
(19,'cc99-05','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'facil','PAPIRO — DH-AUT-07 — cc99-05 — Lei 12847/2013 art.1 objetivo do SNPCT',
 'Nos termos expressos do art. 1º da Lei nº 12.847/2013, o Sistema Nacional de Prevenção e Combate à Tortura (SNPCT) possui atuação direcionada no cenário institucional interno. Considerando a regra do referido diploma legal, o SNPCT tem como objetivo:'),
(20,'cc99-06','1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid,26,99,'media','PAPIRO — DH-AUT-07 — cc99-06 — Lei 12847/2013 art.9 I competencia do MNPCT',
 'Conforme a delimitação expressa de competências prevista no art. 9º, inciso I, da Lei nº 12.847/2013, compete diretamente ao Mecanismo Nacional de Prevenção e Combate à Tortura (MNPCT):');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO texto oficial não estrutura o programa em "Metas de Curto Prazo estipuladas periodicamente". O PNDH-3 é formado por diretrizes, objetivos estratégicos e ações programáticas.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nO PNDH-3 não foi estabelecido como "lei federal", mas sim aprovado mediante Decreto presidencial (Decreto nº 7.037/2009). Além disso, não é estruturado em "Metas Temporais e Ações Orçamentárias".\n\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\nA afirmativa reproduz fielmente o conteúdo do art. 1º do Decreto nº 7.037/2009, segundo o qual o Programa Nacional de Direitos Humanos - PNDH-3 é aprovado em consonância com as diretrizes, os objetivos estratégicos e as ações programáticas estabelecidos, na forma do Anexo a este Decreto.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO PNDH-3 não foi aprovado no "corpo do texto principal do Decreto", mas sim na forma do Anexo. Ademais, o diploma menciona "ações programáticas", e não "ações táticas".\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nA norma expressamente determina a aprovação "na forma do Anexo" (no singular) contendo diretrizes, objetivos estratégicos e ações programáticas, não se dividindo em "anexos independentes" e "princípios orçamentários gerais" em seu artigo de aprovação.'),
(2, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nA alternativa apresenta a exata estrutura e a correta numeração dos seis Eixos Orientadores trazidos pelo Anexo do Decreto nº 7.037/2009. Todos os incisos correspondem às nomenclaturas oficiais do PNDH-3.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nHá erro de correspondência numérica. "Educação e Cultura em Direitos Humanos" é o Eixo V (e não o II). "Desenvolvimento e Direitos Humanos" é o Eixo II (e não o IV).\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO Eixo I denomina-se "Interação democrática entre Estado e sociedade civil", e não "Participação popular nas políticas públicas".\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO item III desta alternativa ("Garantia da igualdade na diversidade") corresponde à Diretriz 10 do PNDH-3, e não ao Eixo Orientador III, que se chama "Universalizar direitos em um contexto de desigualdades".\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO Eixo VI intitula-se "Direito à Memória e à Verdade", e não "Direito à Indenização Histórica".'),
(3, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO Eixo Orientador II denomina-se "Desenvolvimento e Direitos Humanos", e não "Universalizar direitos em um contexto de desigualdades".\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nO Eixo Orientador IV denomina-se "Segurança Pública, Acesso à Justiça e Combate à Violência".\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO Eixo Orientador V denomina-se "Educação e Cultura em Direitos Humanos".\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO Eixo Orientador VI denomina-se "Direito à Memória e à Verdade".\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nA nomenclatura "Universalizar direitos em um contexto de desigualdades" é o nome exato e oficial do Eixo Orientador III do PNDH-3, conforme previsto no Anexo do Decreto nº 7.037/2009.'),
(4, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO Eixo I abrange as Diretrizes de 1 a 3, voltadas à interação do Estado com a sociedade civil, e não a Diretriz 10.\n\nPOR QUE A ALTERNATIVA B ESTÁ CORRETA:\nNa estrutura do PNDH-3, o Eixo Orientador III ("Universalizar direitos em um contexto de desigualdades") engloba as Diretrizes 7, 8, 9 e 10. Portanto, a Diretriz 10 ("Garantia da igualdade na diversidade") é parte estrutural deste Eixo.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO Eixo IV trata da segurança pública e acesso à justiça (Diretrizes 11 a 17), não abarcando a Diretriz 10, que versa sobre diversidade.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO Eixo V dedica-se à educação e cultura em direitos humanos (Diretrizes 18 a 22), não sendo a localização temática e estrutural da Diretriz 10.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO Eixo VI lida com o direito à memória e à verdade (Diretrizes 23 a 25), não abrigando a referida diretriz sobre igualdade na diversidade.'),
(5, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO Decreto nº 7.177/2010 não promoveu a revogação integral do Eixo Orientador III. O Eixo continua plenamente vigente, e a referida norma fez apenas supressões pontuais e restritas de redação.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA Diretriz 10 também não foi revogada em sua totalidade. As ações voltadas à garantia da igualdade na diversidade permanecem. O erro está em afirmar revogação abrangente (integral).\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO PNDH-3 não foi revogado integralmente nem substituído por um novo anexo pelo Decreto nº 7.177/2010. Houve, repita-se, apenas alterações específicas em alguns incisos de ações programáticas.\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\nA afirmativa aponta com exatidão o efeito jurídico da alteração. O Decreto nº 7.177/2010 revogou pontualmente a ação programática ''c'' do Objetivo Estratégico VI (Respeito às diferentes crenças, liberdade de culto e garantia da laicidade do Estado) da Diretriz 10, que previa o desenvolvimento de mecanismos para impedir a ostentação de símbolos religiosos em estabelecimentos públicos da União.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO decreto não determinou a "obrigatoriedade" de símbolos religiosos em locais públicos, mas apenas suprimiu a ação governamental que objetivava proibi-los ou impedi-los. Não ocorreu revogação de laicidade do Eixo IV (que trata de Segurança Pública, e não do tema em questão).'),
(6, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO Decreto nº 10.087/2019 efetuou a revogação pontual do art. 4º. O Programa Nacional de Direitos Humanos (PNDH-3) não foi revogado de forma integral, mantendo vigentes os seus Eixos, Diretrizes e a maior parte de sua estrutura no Anexo.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA norma que revogou o art. 4º não operou a transferência legal dessas competências de forma exclusiva para a sociedade civil. Ela apenas extinguiu o Comitê ali previsto.\n\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\nO Decreto nº 10.087/2019 operou a revogação estrita do art. 4º do Decreto nº 7.037/2009, o que levou ao fim daquele Comitê de Acompanhamento e Monitoramento do PNDH-3 nos termos em que fora concebido. Contudo, essa revogação do colegiado não equivale à revogação de todo o Programa (que fora aprovado pelo art. 1º e detalhado no Anexo).\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA revogação produziu a extinção do dispositivo, não a "suspensão cautelar" do PNDH-3 até o advento de um comitê substituto. O programa continuou existindo juridicamente.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nNão houve a revogação integral do Eixo Orientador I. A extinção concentrou-se apenas no colegiado previsto no art. 4º, e não há nenhuma previsão sobre "subordinação militar".'),
(7, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nA norma estabelece que o ensino dessas temáticas é obrigatório, e não de caráter facultativo.\n\nPOR QUE A ALTERNATIVA B ESTÁ CORRETA:\nA alternativa reproduz o conteúdo do art. 11 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial): "Nos estabelecimentos de ensino fundamental e de ensino médio, públicos e privados, é obrigatório o estudo da história geral da África e da história da população negra no Brasil".\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA regra não está restrita à rede pública de ensino. Ela alcança, expressa e obrigatoriamente, os estabelecimentos privados.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nNão há distinção de obrigatoriedade entre rede pública e privada na lei, sendo imperativo em ambas. Além disso, abrange ensino fundamental e médio, e não "apenas nos estabelecimentos de ensino médio".\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO dispositivo não direciona a obrigatoriedade aos estabelecimentos de ensino superior (como nas licenciaturas), mas sim de forma explícita aos ensinos fundamental e médio.'),
(8, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nA soberania é o fundamento previsto no art. 1º, inciso I, da CF, e não no inciso III.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA cidadania é o fundamento previsto no art. 1º, inciso II, da CF, e não no inciso III.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO pluralismo político é o fundamento previsto no art. 1º, inciso V, da CF, e não no inciso III.\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\nO inciso III do art. 1º da Constituição Federal de 1988 elenca, expressamente, "a dignidade da pessoa humana" como um dos cinco fundamentos da República Federativa do Brasil.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nOs valores sociais do trabalho e da livre iniciativa constituem o fundamento previsto no art. 1º, inciso IV, da CF, e não no inciso III.'),
(9, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nEsta alternativa apresenta corretamente a relação entre os cinco incisos do art. 1º da Constituição Federal e seu respectivo conteúdo: I – soberania; II – cidadania; III – dignidade da pessoa humana; IV – valores sociais do trabalho e da livre iniciativa; V – pluralismo político.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nHá inversão de posições: o pluralismo político é o inciso V (não o II), e a cidadania é o inciso II (não o V).\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nHá inversão de posições: a soberania é o inciso I (não o III), e a dignidade da pessoa humana é o inciso III (não o I).\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nHá inversão de posições: os valores sociais do trabalho e da livre iniciativa constituem o inciso IV (não o V), e o pluralismo político é o inciso V (não o IV).\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nHá inversão de posições: a soberania é o inciso I (não o II), e a cidadania é o inciso II (não o I).'),
(10, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nOcorre inversão textual. Quem traz a regra de que "nascem livres e iguais" é a DUDH, e quem estabelece a dignidade como "fundamento da República" é a CF.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nAs redações não são idênticas. A CF atribui à dignidade o papel de fundamento da estrutura estatal brasileira, enquanto a DUDH a posiciona como inerente ao nascimento de todo ser humano de forma universal.\n\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\nA afirmativa diferencia adequadamente o texto das duas normas centrais: a CF adota a "dignidade da pessoa humana" no art. 1º, III, determinando que é fundamento da República Federativa do Brasil. Já o art. 1º da DUDH dispõe categoricamente: "Todos os seres humanos nascem livres e iguais em dignidade e em direitos".\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA dignidade da pessoa humana não é tratada pela Constituição Federal como um "objetivo fundamental" a ser buscado, mas sim como fundamento, previsto no art. 1º. A DUDH, por sua vez, não trata a dignidade como "único fundamento soberano dos Estados", mas a atribui a todo ser humano desde o nascimento.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO art. 1º da DUDH não restringe a dignidade a um "princípio de relações econômicas internacionais". Ao contrário, atribui-a a todos os seres humanos desde o nascimento.'),
(11, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO texto oficial da DUDH não menciona no art. 1º a necessidade de agir em espírito de "igualdade material" nem atribui dotação originária de "deveres cívicos e morais".\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA literalidade da norma fala em "consciência", não em "emoção", e determina o agir em espírito de "fraternidade", não de "cooperação econômica".\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nNão há, na redação do art. 1º da DUDH, qualquer menção a "tolerância religiosa absoluta".\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO termo "capacidade política e civil" não corresponde à redação do art. 1º da DUDH, que tampouco fala em "solidariedade internacional obrigatória".\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nEsta alternativa apresenta a redação exata do complemento do art. 1º da DUDH: "São dotados de razão e de consciência e devem agir uns para com os outros em espírito de fraternidade".'),
(12, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nA assertiva I está falsa. Houve mistura de planos normativos. Quem estabelece fundamentos de uma República é a Constituição Federal, não a DUDH, que tem caráter internacional e fala da dignidade como inata ao nascimento do ser humano.\n\nPOR QUE A ALTERNATIVA B ESTÁ CORRETA:\nA assertiva III é a única verdadeira. A CF/1988, de fato, elenca expressamente em seu art. 1º, incisos II e III, a cidadania e a dignidade da pessoa humana como fundamentos da República Federativa do Brasil. As assertivas I e II incorrem no erro de embaralhar e trocar os textos e finalidades da DUDH e da CF.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA assertiva II está falsa. Quem traz o texto "todos nascem livres e iguais em dignidade e direitos, dotados de razão e consciência" é o art. 1º da DUDH, e não o art. 1º da CF.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA assertiva II está errada pela inversão da fonte, conforme já explicado. Apenas a III é correta.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nAs proposições I e II estão equivocadas porque permutaram a literalidade e a aplicação jurídica da Constituição Federal e da DUDH, forçando confusão no plano normativo.'),
(13, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nA "soberania" é expressamente tratada como fundamento da República Federativa do Brasil (art. 1º, I, CF). Como a questão pede a afirmativa falsa, esta alternativa deve ser descartada.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA "cidadania" consta textualmente como fundamento (art. 1º, II, CF).\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA "dignidade da pessoa humana" figura explicitamente como fundamento constitucional (art. 1º, III, CF).\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\nEsta alternativa aponta um fundamento inexistente no art. 1º. A redação oficial (art. 1º, IV) consagra "os valores sociais do trabalho e da livre iniciativa", e não os "valores sociais da empresa e do livre comércio". Logo, é a alternativa incorreta requerida pelo enunciado de polaridade invertida.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO "pluralismo político" é fundamento expresso da República Federativa do Brasil (art. 1º, V, CF).'),
(14, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nA alternativa aponta de forma rigorosa a estrutura do inciso IV do art. 1º da CF. Nesse mesmo inciso, o texto constitucional reúne, em um único fundamento, "os valores sociais do trabalho e da livre iniciativa".\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA dignidade da pessoa humana encontra-se isolada no inciso III. A "livre concorrência" sequer é tratada como fundamento no art. 1º, tratando-se de princípio geral da atividade econômica.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA soberania e a cidadania não ocupam conjuntamente um único inciso. Estão dispostas em incisos distintos e separados do art. 1º (inciso I para a soberania e inciso II para a cidadania).\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA Constituição reúne os valores sociais do trabalho à "livre iniciativa", e não ao "pleno emprego", que não compõe o texto do art. 1º.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nA livre iniciativa compõe o inciso IV junto com os valores sociais do trabalho. O pluralismo político, por sua vez, está previsto em inciso autônomo (inciso V). Portanto, não formam, em um mesmo inciso, um único fundamento.'),
(15, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO texto do tratado da ONU não utiliza os termos constitucionais brasileiros "estado de sítio", nem menciona "crise econômica" ou "desobediência civil" como as figuras elencadas na redação original.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nEmbora tortura não se justifique nessas hipóteses, o rol textual do art. 2º, item 2, não expressa as categorias "estado de defesa", "rebelião prisional" e "colapso das instituições públicas".\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA norma acerca do "cumprimento de ordem emanada de autoridade pública" encontra-se prevista no item 3 do referido artigo, não compondo o rol de circunstâncias excepcionais (como fatos sociais gravosos) exposto no item 2.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA redação do tratado não traz, textualmente, a lista baseada em "calamidade pública de ordem sanitária" ou "repressão a organizações terroristas" em seu item 2.\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nEsta alternativa apresenta exatamente a literalidade do rol constante no art. 2º, item 2, da Convenção da ONU contra a Tortura: "Em nenhum caso poderão invocar-se circunstâncias excepcionais tais como o estado de guerra ou de ameaça de guerra, a instabilidade política interna ou qualquer outra emergência pública como justificação para a tortura."'),
(16, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nA Convenção da ONU não admite ressalvas quanto a ordens por escrito ou baseadas em suposta segurança nacional. A vedação ao emprego de tortura é absoluta.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA condição de "autoridade pública militar" ou a circunstância de "guerra" não constituem base legal válida sob a referida Convenção para atenuar a proibição à tortura ou salvaguardar o subordinado.\n\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\nA afirmativa estampa a literalidade da vedação explícita disposta no art. 2º, item 3, do diploma: "A ordem de um funcionário superior ou de uma autoridade pública não poderá ser invocada como justificação para a tortura".\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nO texto internacional não ampara teses baseadas em "perigo público iminente" para referendar tortura, negando a eficácia da invocação de qualquer justificativa advinda de autoridade superior.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nA Convenção não admite qualquer ressalva: a ordem de funcionário superior ou de autoridade pública não pode ser invocada como justificação para a tortura em nenhuma hipótese, independentemente de o subordinado ter ou não ciência da ilegalidade da ordem.'),
(17, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\nAs assertivas I e III estão perfeitas. A assertiva I consagra com exatidão a regra do art. 2º, item 2 (circunstâncias excepcionais não justificam). A assertiva III relata fielmente o art. 2º, item 3 (ordem de funcionário superior ou autoridade pública não serve de justificação), igualando o efeito impeditivo de justificação das situações emergenciais descritas na primeira.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nA assertiva II é falsa. O art. 2º da Convenção da ONU trata os dois cenários da mesma forma no tocante à vedação: ordem de superior simplesmente NÃO serve de justificação, não havendo ressalva, exceção ou norma sobre "atenuação expressa" aplicável por força de ordem hierárquica no texto do artigo.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nPadece do erro exposto na assertiva II, que cria exceção (atenuação pela obediência hierárquica) inexistente na norma aplicável. Além disso, exclui a I, que está juridicamente exata.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nAo afirmar que todas estão corretas, valida indevidamente a proposição II, que atribui efeito jurídico (atenuação mitigadora explícita e diferenciada na norma base) não chancelado pela Convenção nos tópicos 2.2 e 2.3.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nDesconsidera a precisão legal contida na afirmativa III, que também se afigura correta frente ao texto da norma.'),
(18, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO OPCAT não restringe as visitas a penitenciárias federais de segurança máxima; o art. 1º prevê visitas a quaisquer locais onde se encontrem pessoas privadas de liberdade, e a atuação conjunta de órgãos nacionais e internacionais independentes, não apenas nacionais.\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nHá múltiplos erros: o sistema de visitas é "regular", e não "eventual". Os órgãos são de natureza "nacional e internacional independentes", e não "unicamente órgãos nacionais subordinados ao Poder Executivo". Por fim, a finalidade é preventiva, não "punir" criminalmente.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nO OPCAT não atribui a competência de forma exclusiva a órgãos internacionais, prevendo a atuação conjunta de órgãos nacionais e internacionais independentes; tampouco tem finalidade de apurar responsabilidade individual, mas sim de prevenir a tortura.\n\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\nA assertiva contempla a exata redação do art. 1º do OPCAT. Nela visualizamos com rigor jurídico o modo ("sistema de visitas regulares"), os executores ("órgãos nacionais e internacionais independentes"), os locais ("lugares onde pessoas se encontrem privadas de sua liberdade") e o fim essencial ("com a finalidade de prevenir a tortura...").\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO art. 1º do OPCAT não restringe as visitas a centros de detenção de estrangeiros em situação migratória irregular; a norma abrange quaisquer locais onde pessoas se encontrem privadas de liberdade.'),
(19, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO SNPCT não foi concebido para deter "comando militar" ou "centralizar" a administração penitenciária dos Estados. O sistema visa promover articulação entre atores variados.\n\nPOR QUE A ALTERNATIVA B ESTÁ CORRETA:\nA afirmativa reproduz o objetivo do SNPCT previsto no art. 1º da Lei nº 12.847/2013: fortalecer a prevenção e o combate à tortura por meio da articulação e da atuação cooperativa de seus integrantes, o que inclui, entre outras formas, a troca de informações e o intercâmbio de boas práticas.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA criação e o objetivo do SNPCT não promovem a delegação compulsória de competência (avocação) à Justiça Federal para "julgar criminalmente" condutas praticadas. Sua natureza é articulatória e preventiva.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA legislação não estipula como objetivo do SNPCT a "substituição" dos Conselhos da Comunidade ou de qualquer outro órgão de fiscalização. A meta é operar mediante atuação cooperativa conjunta com órgãos que já existem.\n\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\nO objetivo primordial do SNPCT não consiste em processar ou "punir sumariamente" servidores em corregedorias, mas sim o monitoramento e o fortalecimento preventivo de modo cooperativo contra referidas práticas.'),
(20, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\nO Mecanismo Nacional (MNPCT) tem natureza focada em visitas periódicas e recomendações. Ele não é órgão de polícia judiciária e, consequentemente, carece de competência para "instaurar e presidir inquéritos policiais federais".\n\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\nNão consta entre as atribuições do MNPCT a competência de penalizar ou "punir administrativamente" (aplicar suspensão) diretores e gestores de presídios. Seu encargo baseia-se em monitoramento e verificação, expedindo recomendações aos órgãos competentes.\n\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\nA área de abrangência das visitas não é restrita aos estabelecimentos penais federais. O art. 9º, inciso I, prevê visitas a pessoas privadas de liberdade em todas as unidades da Federação.\n\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\nA lei que institui o MNPCT não atribuiu a ele a função de atuar como "órgão recursal máximo" de processos administrativos disciplinares envolvendo agentes de segurança ou servidores carcerários.\n\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\nA afirmativa reproduz o texto do art. 9º, inciso I, da Lei nº 12.847/2013, que enuncia ser competência do MNPCT: "planejar, realizar e monitorar visitas periódicas e regulares a pessoas privadas de liberdade em todas as unidades da Federação, para verificar as condições de fato e de direito a que se encontram submetidas".');

create temporary table _lote_alternativas (ordem int, ordem_alt smallint, texto text, correta boolean) on commit drop;
insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'aprovado em conformidade com as Diretrizes e as Metas de Curto Prazo estipuladas periodicamente pelo Poder Executivo.',false),
(1,2,'estabelecido como lei federal estruturada em Metas Temporais e Ações Orçamentárias.',false),
(1,3,'aprovado na forma do Anexo ao referido Decreto, em conformidade com as diretrizes, os objetivos estratégicos e as ações programáticas nele estabelecidos.',true),
(1,4,'aprovado no corpo do texto principal do Decreto, em conformidade com as diretrizes, os objetivos estratégicos e as ações táticas.',false),
(1,5,'implementado por meio de anexos independentes, em conformidade com as diretrizes normativas e os princípios orçamentários gerais.',false),
(2,1,'I — Interação democrática entre Estado e sociedade civil; II — Desenvolvimento e Direitos Humanos; III — Universalizar direitos em um contexto de desigualdades; IV — Segurança Pública, Acesso à Justiça e Combate à Violência; V — Educação e Cultura em Direitos Humanos; VI — Direito à Memória e à Verdade.',true),
(2,2,'I — Interação democrática entre Estado e sociedade civil; II — Educação e Cultura em Direitos Humanos; III — Universalizar direitos em um contexto de desigualdades; IV — Desenvolvimento e Direitos Humanos; V — Segurança Pública, Acesso à Justiça e Combate à Violência; VI — Direito à Memória e à Verdade.',false),
(2,3,'I — Participação popular nas políticas públicas; II — Desenvolvimento e Direitos Humanos; III — Universalizar direitos em um contexto de desigualdades; IV — Segurança Pública, Acesso à Justiça e Combate à Violência; V — Educação e Cultura em Direitos Humanos; VI — Direito à Memória e à Verdade.',false),
(2,4,'I — Interação democrática entre Estado e sociedade civil; II — Desenvolvimento e Direitos Humanos; III — Garantia da igualdade na diversidade; IV — Segurança Pública, Acesso à Justiça e Combate à Violência; V — Educação e Cultura em Direitos Humanos; VI — Direito à Memória e à Verdade.',false),
(2,5,'I — Interação democrática entre Estado e sociedade civil; II — Desenvolvimento e Direitos Humanos; III — Universalizar direitos em um contexto de desigualdades; IV — Segurança Pública, Acesso à Justiça e Combate à Violência; V — Educação e Cultura em Direitos Humanos; VI — Direito à Indenização Histórica.',false),
(3,1,'Eixo Orientador II.',false),
(3,2,'Eixo Orientador IV.',false),
(3,3,'Eixo Orientador V.',false),
(3,4,'Eixo Orientador VI.',false),
(3,5,'Eixo Orientador III.',true),
(4,1,'Eixo Orientador I (Interação democrática entre Estado e sociedade civil).',false),
(4,2,'Eixo Orientador III (Universalizar direitos em um contexto de desigualdades).',true),
(4,3,'Eixo Orientador IV (Segurança Pública, Acesso à Justiça e Combate à Violência).',false),
(4,4,'Eixo Orientador V (Educação e Cultura em Direitos Humanos).',false),
(4,5,'Eixo Orientador VI (Direito à Memória e à Verdade).',false),
(5,1,'O referido decreto revogou integralmente o Eixo Orientador III, tendo em vista a impossibilidade institucional de o Estado desenvolver mecanismos que afetem pautas de viés religioso.',false),
(5,2,'Houve a revogação de toda a Diretriz 10 (Garantia da igualdade na diversidade), suprimindo do texto todas as ações programáticas voltadas ao respeito às diferentes manifestações de crença.',false),
(5,3,'A alteração consistiu na revogação integral do próprio PNDH-3, substituindo-o por um novo anexo normativo que excluiu definitivamente as referências a direitos de minorias.',false),
(5,4,'A alteração revogou pontualmente a ação programática que previa o desenvolvimento de mecanismos para impedir a ostentação de símbolos religiosos em estabelecimentos públicos da União.',true),
(5,5,'O diploma normativo instituiu a obrigatoriedade de exibição de símbolos religiosos em repartições federais, revogando expressamente a diretriz de laicidade estatal prevista no Eixo IV.',false),
(6,1,'implicou a revogação integral do Programa Nacional de Direitos Humanos, extinguindo legalmente todos os seus eixos e diretrizes.',false),
(6,2,'transferiu as atribuições diretas do Comitê exclusivamente para organizações da sociedade civil, dispensando o monitoramento público sem revogar o programa.',false),
(6,3,'extinguiu a base jurídica específica do colegiado de acompanhamento e monitoramento delineado no art. 4º, mas não revogou integralmente o Programa Nacional de Direitos Humanos, que permanece em vigor.',true),
(6,4,'acarretou a suspensão cautelar de toda a estrutura do PNDH-3 até a criação e implantação de um novo Comitê Interministerial de Monitoramento de Direitos Humanos.',false),
(6,5,'revogou em sua totalidade apenas o Eixo Orientador I (Interação democrática entre Estado e sociedade civil), mantendo o Comitê em funcionamento, mas sob subordinação militar.',false),
(7,1,'facultativo nos estabelecimentos de ensino fundamental e médio, sejam eles pertencentes à rede pública ou à rede privada.',false),
(7,2,'obrigatório nos estabelecimentos de ensino fundamental e de ensino médio, públicos e privados.',true),
(7,3,'obrigatório nos estabelecimentos de ensino fundamental e médio, restrito, contudo, à rede pública de ensino, não alcançando a rede privada.',false),
(7,4,'facultativo na rede privada e obrigatório apenas nos estabelecimentos de ensino médio da rede pública municipal e estadual.',false),
(7,5,'obrigatório exclusivamente nos estabelecimentos de ensino superior, públicos e privados, que mantenham cursos de licenciatura.',false),
(8,1,'a soberania.',false),
(8,2,'a cidadania.',false),
(8,3,'o pluralismo político.',false),
(8,4,'a dignidade da pessoa humana.',true),
(8,5,'os valores sociais do trabalho e da livre iniciativa.',false),
(9,1,'I – a soberania; II – a cidadania; III – a dignidade da pessoa humana; IV – os valores sociais do trabalho e da livre iniciativa; V – o pluralismo político.',true),
(9,2,'I – a soberania; II – o pluralismo político; III – a dignidade da pessoa humana; IV – os valores sociais do trabalho e da livre iniciativa; V – a cidadania.',false),
(9,3,'I – a dignidade da pessoa humana; II – a cidadania; III – a soberania; IV – os valores sociais do trabalho e da livre iniciativa; V – o pluralismo político.',false),
(9,4,'I – a soberania; II – a cidadania; III – a dignidade da pessoa humana; IV – o pluralismo político; V – os valores sociais do trabalho e da livre iniciativa.',false),
(9,5,'I – a cidadania; II – a soberania; III – a dignidade da pessoa humana; IV – os valores sociais do trabalho e da livre iniciativa; V – o pluralismo político.',false),
(10,1,'a DUDH estabelece a dignidade como um fundamento institucional da República Federativa do Brasil, enquanto a Constituição Federal a consagra expressamente como regra geral de que todos nascem livres e iguais em dignidade.',false),
(10,2,'ambas as normativas consagram a dignidade da pessoa humana no seu art. 1º com redações idênticas, definindo-a estritamente como fundamento do Estado Democrático de Direito interno.',false),
(10,3,'na Constituição Federal (art. 1º, III), a dignidade da pessoa humana figura expressamente como um fundamento da República Federativa do Brasil, ao passo que, na DUDH (art. 1º), ela é afirmada na premissa universal de que todos os seres humanos nascem livres e iguais em dignidade e direitos.',true),
(10,4,'a Constituição Federal prevê a dignidade da pessoa humana no art. 1º como um objetivo fundamental a ser buscado pela sociedade, enquanto a DUDH a elenca no art. 1º como o único fundamento soberano dos Estados-membros da ONU.',false),
(10,5,'o art. 1º da DUDH prevê a dignidade da pessoa humana exclusivamente como um princípio que rege as relações econômicas internacionais, sendo a Constituição a única fonte que lhe atribui a função jurídica de tornar os cidadãos livres e iguais.',false),
(11,1,'deveres cívicos e morais e devem agir uns para com os outros em espírito de igualdade material.',false),
(11,2,'razão e emoção e devem agir uns para com os outros em estrito espírito de cooperação econômica.',false),
(11,3,'direitos inalienáveis e devem agir uns para com os outros em espírito de tolerância religiosa absoluta.',false),
(11,4,'capacidade política e civil e devem agir uns para com os outros em espírito de solidariedade internacional obrigatória.',false),
(11,5,'razão e consciência e devem agir uns para com os outros em espírito de fraternidade.',true),
(12,1,'Apenas I.',false),
(12,2,'Apenas III.',true),
(12,3,'Apenas I e II.',false),
(12,4,'Apenas II e III.',false),
(12,5,'I, II e III.',false),
(13,1,'A soberania.',false),
(13,2,'A cidadania.',false),
(13,3,'A dignidade da pessoa humana.',false),
(13,4,'Os valores sociais da empresa e do livre comércio.',true),
(13,5,'O pluralismo político.',false),
(14,1,'os valores sociais do trabalho e da livre iniciativa.',true),
(14,2,'a dignidade da pessoa humana e a livre concorrência.',false),
(14,3,'a soberania e a cidadania.',false),
(14,4,'os valores sociais do trabalho e o pleno emprego.',false),
(14,5,'a livre iniciativa e o pluralismo político.',false),
(15,1,'o estado de sítio decretado pelo executivo, a crise econômica nacional severa ou a desobediência civil generalizada.',false),
(15,2,'o estado de defesa, a rebelião prisional em andamento ou o risco de colapso eminente das instituições públicas.',false),
(15,3,'a instabilidade política interna, o cumprimento de ordem emanada de autoridade pública superior ou o clamor social iminente.',false),
(15,4,'a guerra externa já declarada, a calamidade pública de ordem sanitária ou a necessidade imperiosa de repressão a organizações terroristas.',false),
(15,5,'o estado de guerra ou ameaça de guerra, a instabilidade política interna ou qualquer outra emergência pública.',true),
(16,1,'a ordem emanada de funcionário superior hierárquico, caso exarada formalmente por escrito e fundamentada em lei de segurança nacional, pode ser licitamente invocada para justificar o emprego excepcional de tortura.',false),
(16,2,'a ordem emitida por uma autoridade pública militar de alto escalão, no decorrer de estado de guerra declarada, afasta, por expressa disposição da norma, a responsabilização do subordinado pelo ato de tortura.',false),
(16,3,'a ordem de um funcionário superior ou de uma autoridade pública não poderá ser invocada como justificação para a tortura.',true),
(16,4,'o cumprimento estrito de ordem de autoridade pública serve para justificar a prática da tortura unicamente se a conduta for imprescindível para evitar um perigo público iminente que ameace a coletividade.',false),
(16,5,'a ordem de um funcionário superior ou de uma autoridade pública pode justificar a prática de tortura, ressalvadas apenas as hipóteses em que o subordinado tivesse plena certeza da ilegalidade da ordem recebida.',false),
(17,1,'Apenas I e III.',true),
(17,2,'Apenas I e II.',false),
(17,3,'Apenas II e III.',false),
(17,4,'I, II e III.',false),
(17,5,'Apenas I.',false),
(18,1,'estabelecer um sistema de visitas regulares, restritas exclusivamente a penitenciárias federais de segurança máxima, conduzidas por órgãos nacionais independentes, com a finalidade de prevenir a tortura.',false),
(18,2,'estabelecer um sistema de visitas eventuais, conduzidas unicamente por órgãos nacionais subordinados ao Poder Executivo, em penitenciárias de segurança máxima, a fim de punir os atos de tortura.',false),
(18,3,'estabelecer um sistema de visitas regulares a locais de privação de liberdade, efetuadas exclusivamente por órgãos internacionais independentes, com a finalidade de investigar e apurar responsabilidade individual pela prática de tortura.',false),
(18,4,'estabelecer um sistema de visitas regulares efetuadas por órgãos nacionais e internacionais independentes a lugares onde pessoas se encontrem privadas de sua liberdade, com a finalidade de prevenir a tortura e outros tratamentos ou penas cruéis, desumanos ou degradantes.',true),
(18,5,'estabelecer um sistema de visitas regulares e específicas apenas a centros de detenção de estrangeiros em situação migratória irregular, efetuadas por órgãos nacionais e internacionais independentes, com a finalidade de prevenir a tortura.',false),
(19,1,'centralizar, sob comando militar, a gestão e a administração penitenciária de todas as unidades da Federação.',false),
(19,2,'fortalecer a prevenção e o combate à tortura, por meio da articulação e da atuação cooperativa de seus integrantes.',true),
(19,3,'avocar imediatamente para a esfera federal a competência exclusiva de processar e julgar criminalmente todos os agentes públicos acusados da prática de tortura.',false),
(19,4,'substituir estruturalmente os Conselhos da Comunidade e as Promotorias de Execução Penal nas atribuições de fiscalização carcerária diária, garantindo a autonomia dos entes federativos.',false),
(19,5,'punir de forma administrativa e sumária, no âmbito de corregedorias autônomas federais, qualquer servidor público flagrado incorrendo em atos classificados como tratamento desumano.',false),
(20,1,'instaurar e presidir inquéritos policiais federais destinados à investigação aprofundada de denúncias de tortura originadas de unidades prisionais, sejam elas de administração estadual ou federal.',false),
(20,2,'punir administrativamente, mediante suspensão temporária, os gestores ou diretores de presídios em cujas unidades forem constatadas de plano condições de fato e de direito violadoras da dignidade humana.',false),
(20,3,'realizar visitas e exames periódicos e regulares, porém restritos de forma exclusiva aos estabelecimentos penais vinculados ao Sistema Penitenciário Federal, sendo-lhe defeso adentrar em áreas estaduais.',false),
(20,4,'atuar como órgão recursal máximo e vinculativo nos trâmites de processos administrativos disciplinares movidos contra agentes de segurança suspeitos de autorizar tratamentos desumanos ou degradantes.',false),
(20,5,'planejar, realizar e monitorar visitas periódicas e regulares a pessoas privadas de liberdade em todas as unidades da Federação, para verificar as condições de fato e de direito a que se encontram submetidas.',true);

-- FASE PRECONDICAO
insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging counts',
  (select count(*) from _lote_questoes) = 20 and (select count(*) from _lote_alternativas) = 100,
  'questoes=' || (select count(*) from _lote_questoes) || ' alternativas=' || (select count(*) from _lote_alternativas);

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging distribuicao cc',
  (select count(*) from _lote_questoes where cc_id=96) = 6
  and (select count(*) from _lote_questoes where cc_id=97) = 1
  and (select count(*) from _lote_questoes where cc_id=98) = 7
  and (select count(*) from _lote_questoes where cc_id=99) = 6,
  'cc96=' || (select count(*) from _lote_questoes where cc_id=96) || ' cc97=' || (select count(*) from _lote_questoes where cc_id=97)
  || ' cc98=' || (select count(*) from _lote_questoes where cc_id=98) || ' cc99=' || (select count(*) from _lote_questoes where cc_id=99);

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging 5 alternativas e 1 correta por questao',
  (select count(*) from (select ordem, count(*) as n from _lote_alternativas group by ordem having count(*) <> 5) x) = 0
  and (select count(*) from (select ordem, count(*) filter (where correta) as n from _lote_alternativas group by ordem having count(*) filter (where correta) <> 1) x) = 0,
  'verificado por agregacao';

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'nenhum enunciado ja existe no LIVE',
  (select count(*) from _lote_questoes lq where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado)) = 0,
  'duplicatas=' || (select count(*) from _lote_questoes lq where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado));

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'unidades ativas e assunto compativel',
  (select count(*) from _lote_questoes lq where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa)) = 0
  and (select count(*) from _lote_questoes lq join public.unidades_pedagogicas u on u.id = lq.unidade_id join public.curso_conteudos cc on cc.id = u.curso_conteudo_id where cc.assunto_id is distinct from lq.assunto_id) = 0,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'baseline LIVE e manutencao anterior intacta',
  (select total_questoes from _snapshot_antes) = 1138
  and (select total_alternativas from _snapshot_antes) = 5444
  and (select total_vinculos from _snapshot_antes) = 915
  and (select cc96_uteis from _snapshot_antes) = 4
  and (select cc97_uteis from _snapshot_antes) = 9
  and (select cc98_uteis from _snapshot_antes) = 3
  and (select cc99_uteis from _snapshot_antes) = 4
  and (select dh_uteis from _snapshot_antes) = 281
  and (select q13_hash from _snapshot_antes) = 'a59aba16c3ace7f13e31886c33ea5152'
  and (select q29_hash from _snapshot_antes) = '5da6b6a430faab0aff4efe54f3ef6e30'
  and (select q177_hash from _snapshot_antes) = 'a7ffa30db36ca95478c1e429cc65eea0'
  and (select q178_hash from _snapshot_antes) = '9843efe8206346c66f628cdaa36e383d'
  and (select q179_hash from _snapshot_antes) = '8da95e4315db7f0dca91d802c75495f6'
  and (select q263_hash from _snapshot_antes) = '84b9678d3115633bd15c43c3f4bce4da'
  and (select q264_hash from _snapshot_antes) = '075f145453b7e592023d8f0c5deae5d1',
  'questoes=' || (select total_questoes from _snapshot_antes) || ' dh_uteis=' || (select dh_uteis from _snapshot_antes);

-- WRITE (identico ao apply real)
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;
do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-07 - BM RS', 2026, r.enunciado, r.dificuldade,
            (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
            r.fonte, true, true)
    returning id into v_id;
    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_id);
    insert into public.alternativas (questao_id, texto, correta, ordem)
    select v_id, la.texto, la.correta, la.ordem_alt
    from _lote_alternativas la where la.ordem = r.ordem order by la.ordem_alt;
  end loop;
end $$;

do $$
declare r record;
begin
  for r in select m.questao_id, lq.unidade_id from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
end $$;

-- FASE POSCONDICAO (estado TARGET)
insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'contagens globais +20/+100/+20',
  (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 20
  and (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 100
  and (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 20,
  'questoes=' || (select count(*) from public.questoes) || ' alternativas=' || (select count(*) from public.alternativas) || ' vinculos=' || (select count(*) from public.questao_unidades_pedagogicas);

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'todas AUTORAL_PAPIRO, ativas, materia/assunto corretos',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and coalesce(lower(banca),'') not like '%papiro%') = 0
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0
  and (select count(*) from public.questoes q join _mapa_ids m on m.questao_id=q.id join _lote_questoes lq on lq.ordem=m.ordem where q.assunto_id <> lq.assunto_id) = 0,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', '5 alternativas e 1 correta por questao nova',
  (select count(*) from public.alternativas where questao_id in (select questao_id from _mapa_ids)) = 100
  and (select count(*) from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x) = 0,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'distribuicao dificuldade 5/11/4',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil') = 5
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media') = 11
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil') = 4,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'gabaritos A=4 B=4 C=4 D=4 E=4',
  (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5) = 4,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'vinculos 20/20 corretos, sem multiunidade',
  (select count(*) from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids)) = 20
  and (select count(*) from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x) = 0
  and not exists (
    select 1 from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem
    where not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id = m.questao_id and up.curso_conteudo_id = lq.cc_id)
  ),
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'cc96-99 todas em exatamente 10 uteis',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=96) = 10
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=97) = 10
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=98) = 10
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=99) = 10,
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'DH uteis 281->301, manutencao anterior preservada',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.curso_conteudos cc on cc.id = up.curso_conteudo_id join public.assuntos a on a.id = cc.assunto_id where a.materia_id = 11) = 301
  and md5(coalesce((select explicacao from public.questoes where id=13),'')) = (select q13_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=29),'')) = (select q29_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=177),'')) = (select q177_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=178),'')) = (select q178_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=179),'')) = (select q179_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=263),'')) = (select q263_hash from _snapshot_antes)
  and md5(coalesce((select explicacao from public.questoes where id=264),'')) = (select q264_hash from _snapshot_antes),
  'dh_uteis=' || (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.curso_conteudos cc on cc.id = up.curso_conteudo_id join public.assuntos a on a.id = cc.assunto_id where a.materia_id = 11);

-- FASE REVERT: exercer a logica REAL de reversao (identica a
-- supabase/reverter_dh_aut_07.sql) dentro do mesmo teste.
create temporary table _dh_aut_07_enunciados (enunciado text) on commit drop;
insert into _dh_aut_07_enunciados (enunciado)
select enunciado from _lote_questoes;

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_GUARD', '20 questoes localizadas por enunciado exato antes do delete',
  (select count(*) from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados)) = 20,
  'encontradas=' || (select count(*) from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));

do $$
declare v_rows int;
begin
  delete from public.questao_unidades_pedagogicas
  where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));
  get diagnostics v_rows = row_count;
  insert into _relatorio (fase, item, ok, detalhe) values ('REVERT_APPLY', 'delete vinculos', v_rows = 20, 'rows_affected=' || v_rows);
end $$;

do $$
declare v_rows int;
begin
  delete from public.alternativas
  where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));
  get diagnostics v_rows = row_count;
  insert into _relatorio (fase, item, ok, detalhe) values ('REVERT_APPLY', 'delete alternativas', v_rows = 100, 'rows_affected=' || v_rows);
end $$;

do $$
declare v_rows int;
begin
  delete from public.questoes
  where enunciado in (select enunciado from _dh_aut_07_enunciados);
  get diagnostics v_rows = row_count;
  insert into _relatorio (fase, item, ok, detalhe) values ('REVERT_APPLY', 'delete questoes', v_rows = 20, 'rows_affected=' || v_rows);
end $$;

-- FASE REVERT_VERIFY: confirmar retorno integral ao OLD
insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', 'contagens globais de volta ao baseline',
  (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes)
  and (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes)
  and (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes),
  'questoes=' || (select count(*) from public.questoes) || ' alternativas=' || (select count(*) from public.alternativas) || ' vinculos=' || (select count(*) from public.questao_unidades_pedagogicas);

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', 'cc96-99 de volta ao baseline (4/9/3/4) e DH uteis 281',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=96) = (select cc96_uteis from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=97) = (select cc97_uteis from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=98) = (select cc98_uteis from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=99) = (select cc99_uteis from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.curso_conteudos cc on cc.id = up.curso_conteudo_id join public.assuntos a on a.id = cc.assunto_id where a.materia_id = 11) = (select dh_uteis from _snapshot_antes),
  'verificado';

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', 'nenhum enunciado das 20 remanesce no banco',
  (select count(*) from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados)) = 0,
  'remanescentes=' || (select count(*) from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));

-- RESUMO FINAL
select
  bool_and(ok) as tudo_ok,
  count(*) as total_checks,
  count(*) filter (where ok) as checks_ok,
  count(*) filter (where not ok) as checks_falhos
from _relatorio;

select fase, item, ok, detalhe from _relatorio order by
  case fase
    when 'PRECONDICAO' then 1
    when 'POSCONDICAO' then 2
    when 'REVERT_GUARD' then 3
    when 'REVERT_APPLY' then 4
    when 'REVERT_VERIFY' then 5
  end, item;

rollback;
