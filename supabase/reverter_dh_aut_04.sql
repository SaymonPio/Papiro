-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-04 de Direitos
-- Humanos e Cidadania (18 questoes AUTORAL_PAPIRO / 90 alternativas /
-- 18 vinculos, cc86/cc87/cc88).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_04.sql.
--
-- Mecanismo de identificacao: as 18 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 18 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (vinculo -> alternativas -> questao).
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_04_enunciados (enunciado text) on commit drop;
insert into _dh_aut_04_enunciados (enunciado) values
('A Organização dos Estados Americanos (OEA) possui uma estrutura institucional delineada para a consecução de seus objetivos no continente. Nos termos expressos do artigo 53 de sua Carta, assinale a alternativa que indica corretamente um dos órgãos por intermédio dos quais a OEA realiza os seus fins.'),
('De acordo com o artigo 2º, alínea "a", da Carta da Organização dos Estados Americanos (OEA), a organização possui finalidades primordiais para com os seus membros. Dentre essas finalidades, destaca-se explicitamente o propósito essencial de:'),
('Ao estipular seus propósitos essenciais, a Carta da OEA traz comandos fundamentais sobre o regime político a ser incentivado e as garantias de soberania. Nesse sentido, conforme o artigo 2º, alínea "b", a Organização propõe-se a:'),
('Os propósitos da OEA não se limitam às áreas de segurança e regime político, alcançando também o plano do progresso coletivo das nações do continente. Nos termos do artigo 2º, "f", da Carta da OEA, é um dos propósitos essenciais da Organização:'),
('Ao dispor sobre a natureza jurídica e a posição da Organização dos Estados Americanos (OEA) no cenário internacional, o artigo 1º, primeiro parágrafo, da Carta da OEA estabelece uma relação institucional declarada com as Nações Unidas. Segundo esse dispositivo legal, no âmbito internacional, a OEA:'),
('A Carta da OEA define os limites de atuação da própria Organização em relação à soberania de seus membros. De acordo com o artigo 1º, segundo parágrafo do tratado, sobre as faculdades da OEA e o princípio da não-intervenção, é correto afirmar que:'),
(E'Considere as seguintes assertivas sobre a estruturação e a natureza jurídica da Organização dos Estados Americanos (OEA), à luz de sua Carta:\n\nI. A OEA constitui um organismo regional dentro do sistema das Nações Unidas.\nII. Entre seus propósitos essenciais, a OEA busca garantir a paz e a segurança continentais, bem como promover e consolidar a democracia representativa, respeitado o princípio da não-intervenção.\nIII. A institucionalização da Comissão Interamericana de Direitos Humanos decorre exclusivamente da Convenção Americana sobre Direitos Humanos, não figurando entre os órgãos elencados no art. 53 da Carta da OEA.\n\nEstá correto o que se afirma em:'),
('A Comissão Interamericana de Direitos Humanos e a Corte Interamericana desempenham papéis estruturais distintos no sistema interamericano. Sobre a atuação da Comissão e seus limites funcionais de acordo com a Convenção Americana sobre Direitos Humanos (CADH), assinale a afirmativa correta.'),
('A Convenção Americana sobre Direitos Humanos estabelece diversas atribuições para que a Comissão Interamericana realize sua missão principal. Com relação ao trâmite de denúncias de violações no continente, o artigo 41, alínea "f", da CADH estabelece expressamente que a Comissão:'),
('No âmbito do sistema regional americano, a Convenção Americana assegura o acesso aos órgãos de proteção por meio da regulação precisa da legitimidade ativa perante a Comissão Interamericana. Nos termos do artigo 44 da Convenção, têm legitimidade para apresentar petições que contenham denúncias ou queixas de violação à CADH por um Estado Parte:'),
('Uma Organização Não Governamental (ONG) legalmente constituída e reconhecida no país "Alfa", que é Estado membro da OEA, decide apresentar à Comissão Interamericana de Direitos Humanos uma petição contendo denúncias de graves violações da Convenção Americana perpetradas pelo país "Beta" (que é Estado Parte da CADH). Sabe-se, no entanto, que referida ONG não possui registro legal, sede ou reconhecimento de utilidade pública no país "Beta". Considerando estritamente as regras de legitimidade previstas no artigo 44 da Convenção Americana, a ONG requerente:'),
(E'Analise as afirmativas a seguir a respeito da atuação institucional da Comissão Interamericana de Direitos Humanos, conforme disposições da Convenção Americana:\n\nI. A função principal da Comissão é promover a observância e a defesa dos direitos humanos, funcionando como órgão do sistema interamericano na matéria.\nII. A Comissão atua a respeito das petições e outras comunicações, no exercício de sua autoridade, de conformidade com o disposto nos artigos 44 a 51 desta Convenção.\nIII. Qualquer pessoa ou grupo de pessoas, ou entidade não governamental legalmente reconhecida em um ou mais Estados membros da OEA, tem legitimidade para apresentar à Comissão petições que contenham denúncias ou queixas de violação da Convenção por um Estado Parte.\n\nNo contexto das normativas em tela, estão corretas as afirmativas:'),
('A submissão do Estado brasileiro à competência contenciosa da Corte Interamericana de Direitos Humanos obedeceu a um rito formal que gerou efeitos e parâmetros temporais bem definidos para a incidência da jurisdição desse tribunal internacional. Com relação à cronologia e aos limites do reconhecimento brasileiro do art. 62 da Convenção Americana, assinale a afirmativa correta.'),
('A Convenção Americana estabelece requisitos pessoais e profissionais para a eleição dos juízes da Corte Interamericana de Direitos Humanos. Nos termos do artigo 52.1 da Convenção, a Corte é composta por juízes eleitos dentre juristas que devem reunir o seguinte perfil:'),
('O Estatuto da Corte Interamericana de Direitos Humanos (art. 1º) traça, de modo objetivo, o perfil estrutural e a finalidade precípua do tribunal regional americano. De acordo com as diretrizes e natureza fixadas no normativo em tela, a Corte Interamericana de Direitos Humanos caracteriza-se formalmente como uma:'),
('O Estado "Delta" é Estado Parte da Convenção Americana sobre Direitos Humanos e reconheceu formalmente a jurisdição contenciosa da Corte Interamericana. Delta foi parte em um caso submetido à Corte, que proferiu decisão definitiva a seu respeito. Com base estritamente no artigo 68.1 da CADH, o Estado "Delta":'),
('A magistratura da Corte Interamericana de Direitos Humanos observa critérios estabelecidos na Convenção Americana quanto à nacionalidade e à forma de investidura de seus membros. Em relação a esses dois aspectos, o artigo 52.1 da CADH preceitua que os juízes:'),
(E'Considere as afirmações seguintes referentes ao perfil jurídico e institucional da Corte Interamericana de Direitos Humanos (Corte IDH):\n\nI. A Corte constitui-se em uma instituição judiciária autônoma, cuja sede formal se encontra estabelecida na cidade de San José (Costa Rica) e tem por finalidade objetiva a aplicação e a interpretação da CADH.\nII. A Corte é composta por sete juízes, nacionais de Estados membros da OEA, eleitos a título pessoal.\nIII. Os Estados Partes na Convenção comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes.\n\nEstá correto o que se afirma em:');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_04_enunciados);
  if v_cnt <> 18 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 18) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_04_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_04_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_04_enunciados);

commit;
