-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-01 de Direitos
-- Humanos e Cidadania (31 questoes AUTORAL_PAPIRO / 155 alternativas /
-- 31 vinculos).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_01.sql.
--
-- Mecanismo de identificacao: as 31 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 31 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (alternativas -> vinculo -> questao).
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_01_enunciados (enunciado text) on commit drop;
insert into _dh_aut_01_enunciados (enunciado) values
('Nos termos da Lei nº 13.869/2019, constitui efeito da condenação por crime de abuso de autoridade:'),
('Um servidor público foi condenado pela prática de crime previsto na Lei nº 13.869/2019. Sobre a eventual decretação da perda do cargo e da inabilitação para o exercício de cargo, mandato ou função pública pelo período de 1 a 5 anos, assinale a afirmativa correta segundo a referida lei:'),
('Durante a realização de interrogatório formal em sede de inquérito policial (procedimento investigatório de infração penal), uma autoridade pública devidamente designada para conduzir o ato omitiu deliberadamente sua verdadeira identificação ao investigado preso, atribuindo a si nome fictício e função pertencente a outra carreira, com a finalidade específica de prejudicar e intimidar o preso, dissimulando sua real atribuição funcional. Diante do caso concreto e dos preceitos da Lei nº 13.869/2019, a conduta descrita:'),
('Em uma investigação de um crime violento de grande repercussão, um agente público, encarregado de colher o depoimento de uma testemunha de crimes violentos, submeteu-a sucessivas vezes a questionamentos invasivos sobre sua vida íntima e a situações vexatórias desnecessárias à elucidação dos fatos; mesmo ciente da desnecessidade dos atos, o agente prosseguiu com a finalidade específica de prejudicar e humilhar a testemunha, gerando-lhe sofrimento psíquico indevido decorrente dos atos da própria inquirição oficial. Nos termos da Lei nº 13.869/2019, é correto afirmar que:'),
('Com o propósito deliberado de responsabilizar criminalmente um desafeto que não cometeu qualquer delito, um agente estatal, antes da chegada dos peritos oficiais ao local onde ocorrera um tiroteio, posicionou intencionalmente um cartucho deflagrado nas proximidades dos pertences desse cidadão, alterando a cena dos fatos para induzir a perícia em erro. Nos termos estritos da Lei nº 13.869/2019, a conduta amolda-se ao crime de:'),
('Policiais em patrulhamento ostensivo ingressaram, sem mandado judicial e sem consentimento do morador, no pátio interno e na residência de uma família às 22h, ao escutarem gritos desesperados e constatarem fumaça densa e chamas altas originadas de um botijão de gás acidentado na cozinha, efetuando o resgate de duas crianças que estavam sozinhas no recinto. Considerando estritamente a disciplina do art. 22 e seus parágrafos da Lei nº 13.869/2019, assinale a afirmativa correta:'),
('A operadora de um plano privado de assistência à saúde impôs regras administrativas especiais que resultaram em embaraço e recusa de adesão contratual a uma pessoa em razão exclusiva de sua deficiência, estipulando ainda a cobrança de mensalidade substancialmente majorada. À luz da Lei nº 7.853/1989, a conduta descrita:'),
('Um agente público investido do dever legal de fiscalizar a custódia de presos presencia atos reiterados de violência física praticados por terceiros contra um detento, com o intuito de obter confissão. Ciente do ocorrido e dispondo de meios concretos e imediatos para agir, esse agente voluntariamente se abstém de intervir e de adotar qualquer providência posterior para apurar o delito. De acordo com a Lei nº 9.455/1997, a conduta desse agente omisso:'),
('Em território estrangeiro, um cidadão brasileiro é vítima de atos de tortura executados por agentes forâneos em razão de sua nacionalidade e atividade profissional. O crime não foi cometido no Brasil nem por agente a serviço do Estado brasileiro, mas a vítima encontrava-se em área de jurisdição externa. Em conformidade estrita com o art. 2º da Lei nº 9.455/1997, a lei aplicar-se-á ao fato:'),
('No âmbito de sua convivência matrimonial e prevalecendo-se das relações domésticas, um homem submete de modo continuado e reiterado sua esposa a agressões corporais severas e torturas psicológicas constantes, provocando-lhe intenso sofrimento físico e mental como forma de humilhação e castigo habitual, sem prejuízo de outros ilícitos penais perpetrados no mesmo período. Considerando as disposições vigentes da Lei nº 9.455/1997, a conduta descrita:'),
('Um agente penitenciário foi condenado em caráter definitivo pela prática de crime de tortura cometido no exercício de suas atribuições. A respeito dos efeitos dessa condenação e das garantias penais aplicáveis, conforme a Lei nº 9.455/1997:'),
('No que concerne às causas de aumento de pena disciplinadas na Lei nº 9.455/1997, aumenta-se a pena de um sexto até um terço se o crime de tortura:'),
('O Pacto Internacional sobre Direitos Civis e Políticos, promulgado pelo Decreto nº 592/1992, estabelece garantias essenciais relativas à liberdade e à segurança pessoais. Segundo o art. 9º, item 5, qualquer pessoa que tenha sido vítima de prisão ou detenção ilegal:'),
('No que concerne ao regime de execução das medidas de custódia e ao tratamento daqueles submetidos à restrição de locomoção, o art. 10, item 1, do PIDCP preconiza que:'),
('Um cidadão celebrou contrato de compra e venda de bens móveis com um particular. Em razão de desemprego superveniente, tornou-se inadimplente. O credor requereu em juízo a prisão do devedor para coagi-lo ao pagamento. À luz do art. 11 do PIDCP, a pretensão de prisão:'),
('O art. 6º, item 1, do PIDCP enuncia os contornos basilares da proteção internacional à vida humana. De acordo com a disciplina desse dispositivo:'),
('Sob o prisma do art. 7º do PIDCP, a proteção conferida ao indivíduo abrange a seguinte vedação expressa:'),
('Ao analisar a estrutura dos direitos de proteção à integridade e à custódia previstos no PIDCP, constata-se relação sistemática entre os arts. 7º e 10, item 1. A respeito da distinção e do alcance desses preceitos, é correto afirmar que:'),
('Considere as afirmativas: I. Qualquer pessoa vítima de prisão ou encarceramento ilegais terá direito à reparação. II. Toda pessoa privada de sua liberdade deverá ser tratada com humanidade e com respeito à dignidade inerente à pessoa humana. III. Ninguém poderá ser preso apenas por não poder cumprir com uma obrigação contratual. Está correto o que se afirma em:'),
('A Lei Brasileira de Inclusão da Pessoa com Deficiência redefiniu substancialmente o instituto da curatela. Consoante o art. 85, caput, a curatela afetará tão somente os atos relacionados aos direitos de natureza:'),
('Uma pessoa maior de idade com deficiência foi submetida judicialmente à curatela. Meses depois, manifestou vontade de se casar e de decidir sobre cuidados médicos relativos ao próprio corpo e à sexualidade. À luz do art. 85, §1º, a definição desses atos:'),
('Determinado curador, instituído para gerir os bens de um adulto com deficiência, pretendeu proibi-lo de frequentar curso educacional de sua escolha e passou a violar sua correspondência privada e suas consultas médicas, sob a alegação de que a sentença de curatela lhe conferiu representação universal sobre a vida do curatelado. Considerando o art. 85, §1º, a conduta do curador é juridicamente:'),
('No que concerne aos efeitos jurídicos da curatela sobre a cidadania da pessoa com deficiência, o art. 85, §1º, dispõe expressamente que a definição da curatela não alcança o direito:'),
('Para os fins da Lei nº 13.146/2015, o "profissional de apoio escolar" é legalmente definido como a pessoa que:'),
('Um cidadão adulto com deficiência intelectual encontra-se sujeito à curatela deferida judicialmente. Ele decide casar-se e, concomitantemente, pretende alienar um imóvel de elevado valor recebido por herança para integralizar capital em sociedade empresária. Com base na Lei nº 13.146/2015, assinale a correta:'),
('Segundo o art. 84, §3º, da Lei nº 13.146/2015, a definição de curatela de pessoa com deficiência constitui medida:'),
('Durante o dia, policiais militares receberam mandado de busca e apreensão expedido por autoridade judiciária competente para ingressar na residência de um suspeito de furto continuado. O morador recusou-se a franquear a entrada. À luz do art. 5º, XI, os agentes:'),
('Um jornalista publicou reportagem investigativa baseada em documentos recebidos de informante anônimo. Intimado a revelar a fonte sob pena de prisão, recusou-se. À luz do art. 5º, XIV, a recusa é:'),
('Uma associação de moradores exigiu compulsoriamente que todos os proprietários locais se filiassem, com sanções patrimoniais aos que pretendessem se desfiliar. Nos termos do art. 5º, XX:'),
('O art. 3º da Constituição Federal de 1988 elenca os objetivos fundamentais da República Federativa do Brasil. Constitui expressamente um objetivo fundamental previsto no art. 3º, inciso III:'),
('A Constituição Federal estabelece, no Título I, preceitos que orientam tanto a atuação estatal interna quanto a conduta do Brasil perante a comunidade internacional. A respeito da distinção sistemática entre os objetivos fundamentais da República e os princípios das relações internacionais, assinale a correta:');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_01_enunciados);
  if v_cnt <> 31 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 31) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_01_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_01_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_01_enunciados);

commit;
