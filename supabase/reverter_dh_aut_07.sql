-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-07 de Direitos
-- Humanos e Cidadania (ultimo lote: 20 questoes AUTORAL_PAPIRO / 100
-- alternativas / 20 vinculos, cc96/cc97/cc98/cc99).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_07.sql.
--
-- Mecanismo de identificacao: as 20 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 20 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (vinculo -> alternativas ->
-- questao). NAO toca em Q13/Q29/Q177/Q178/Q179/Q263/Q264 (pre-
-- existentes, apenas com explicacao saneada em rodada tecnica anterior
-- de manutencao pre-manifesto) nem em qualquer outra questao.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_07_enunciados (enunciado text) on commit drop;
insert into _dh_aut_07_enunciados (enunciado) values
('Conforme as disposições iniciais do Decreto nº 7.037/2009, o Programa Nacional de Direitos Humanos (PNDH-3) é:'),
('O Programa Nacional de Direitos Humanos (PNDH-3) é estruturado a partir de Eixos Orientadores. Assinale a alternativa que apresenta de forma completa, e com a correta correspondência numérica, os seis Eixos Orientadores do Programa.'),
('O Decreto nº 7.037/2009 estrutura o Programa Nacional de Direitos Humanos (PNDH-3) de forma temática. O segmento denominado expressamente como "Universalizar direitos em um contexto de desigualdades" corresponde, na estrutura do Programa, ao:'),
('No âmbito do Programa Nacional de Direitos Humanos (PNDH-3), a Diretriz 10, que dispõe especificamente sobre a "Garantia da igualdade na diversidade", integra expressamente qual dos seguintes Eixos Orientadores?'),
('O Decreto nº 7.177/2010 promoveu alterações pontuais no texto do Programa Nacional de Direitos Humanos (PNDH-3). A respeito dos efeitos jurídicos e da extensão material dessas alterações normativas na estrutura do Programa, notadamente no que tange à laicidade do Estado e à diversidade, assinale a alternativa correta.'),
('O Decreto nº 10.087/2019 determinou a revogação do art. 4º do Decreto nº 7.037/2009, dispositivo que tratava expressamente do Comitê de Acompanhamento e Monitoramento do PNDH-3. Sobre a extensão dos efeitos normativos dessa revogação perante o ordenamento jurídico, é correto afirmar que ela:'),
('Nos termos estritos do art. 11 da Lei nº 12.288/2010 (Estatuto da Igualdade Racial), o estudo da história geral da África e da história da população negra no Brasil é fixado como:'),
('A Constituição Federal de 1988 estabelece os princípios essenciais que delineiam a estrutura do Estado brasileiro. Nos termos expressos e diretos do art. 1º, inciso III, da referida Constituição, constitui um dos fundamentos da República Federativa do Brasil:'),
('A República Federativa do Brasil, constituída em Estado Democrático de Direito, possui fundamentos estruturantes expressamente enumerados no art. 1º da Constituição Federal. Assinale a alternativa que elenca, de forma exata e completa, o conteúdo jurídico correspondente aos cinco incisos desse artigo constitucional.'),
('A dignidade da pessoa humana possui reconhecimento tanto no ordenamento jurídico interno quanto no âmbito internacional dos Direitos Humanos. Comparando-se a literalidade do art. 1º da Constituição Federal de 1988 e a do art. 1º da Declaração Universal dos Direitos Humanos (DUDH), é correto afirmar, quanto à função normativa e à origem desses preceitos, que:'),
('O texto do art. 1º da Declaração Universal dos Direitos Humanos (DUDH) não apenas assevera que todos os seres humanos nascem livres e iguais em dignidade e em direitos, mas também fixa outras premissas essenciais a respeito da condição humana. Segundo a disposição expressa dessa segunda parte do artigo, os seres humanos são dotados de:'),
(E'Analise as assertivas abaixo acerca das normas fundamentais estruturadas na Declaração Universal dos Direitos Humanos (DUDH) e na Constituição Federal de 1988 (CF):

I. O art. 1º da Declaração Universal dos Direitos Humanos expressamente estabelece, como fundamentos estruturantes da República, a dignidade da pessoa humana e a cidadania material.

II. O art. 1º da Constituição Federal prevê explicitamente que todos os seres humanos nascem livres e iguais em dignidade e direitos, dotados que são de razão e de consciência.

III. Na Constituição Federal, a cidadania e a dignidade da pessoa humana estão consagradas e enumeradas expressamente como fundamentos da República Federativa do Brasil em seu art. 1º.

Quais estão corretas?'),
('O art. 1º da Constituição Federal de 1988 estabelece claramente os fundamentos que sustentam a República Federativa do Brasil. Assinale a alternativa que NÃO corresponde corretamente a um desses fundamentos previstos na norma constitucional.'),
('No tocante à estrutura formal do art. 1º da Constituição Federal, que elenca os fundamentos da República Federativa do Brasil, é correto afirmar que formam, de forma conjunta, um único e mesmo fundamento expresso normativamente em um só inciso:'),
('Nos exatos termos do art. 2º, item 2, da Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes, o princípio geral é o de que nenhuma circunstância excepcional poderá ser invocada como justificação para a tortura. O texto dessa norma exemplifica, no rol de sua redação, que não servem de justificativa circunstâncias excepcionais tais como:'),
('De acordo com o disposto expressamente no art. 2º, item 3, da Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes, é correto afirmar sobre as esferas de subordinação hierárquica que:'),
(E'Analise as assertivas abaixo, que dispõem sobre as vedações presentes no art. 2º da Convenção da ONU contra a Tortura:

I. O estado de guerra ou ameaça de guerra, bem como a instabilidade política interna, configuram circunstâncias excepcionais que, por previsão normativa, não podem ser invocadas como justificação para a tortura.

II. A ordem de um funcionário superior ou de uma autoridade pública, diferentemente das circunstâncias excepcionais (como as emergências públicas), constitui causa jurídica que, embora não seja capaz de promover total justificação, admite atenuação expressa da sanção aplicável à tortura perante a Convenção.

III. Nos estritos termos convencionais vigentes, a ordem de uma autoridade pública, assim como no caso das emergências políticas internas, também não pode ser invocada como justificação para a tortura.

Quais estão corretas?'),
('O Protocolo Facultativo à Convenção da ONU contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (OPCAT) tem o seu objetivo delineado de modo estrutural já no seu artigo inaugural. Conforme previsto no art. 1º, o objetivo do Protocolo consiste em:'),
('Nos termos expressos do art. 1º da Lei nº 12.847/2013, o Sistema Nacional de Prevenção e Combate à Tortura (SNPCT) possui atuação direcionada no cenário institucional interno. Considerando a regra do referido diploma legal, o SNPCT tem como objetivo:'),
('Conforme a delimitação expressa de competências prevista no art. 9º, inciso I, da Lei nº 12.847/2013, compete diretamente ao Mecanismo Nacional de Prevenção e Combate à Tortura (MNPCT):');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados);
  if v_cnt <> 20 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 20) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_07_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_07_enunciados);

commit;
