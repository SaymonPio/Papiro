-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-03 de Direitos
-- Humanos e Cidadania (22 questoes AUTORAL_PAPIRO / 110 alternativas /
-- 22 vinculos, cc82/cc83/cc84/cc85).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_03.sql.
--
-- Mecanismo de identificacao: as 22 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 22 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (vinculo -> alternativas -> questao).
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_03_enunciados (enunciado text) on commit drop;
insert into _dh_aut_03_enunciados (enunciado) values
('A proteção internacional dos direitos humanos desenvolveu-se por meio de diferentes instâncias para conferir maior efetividade aos compromissos assumidos pelos Estados. Dentre essas instâncias, operam sistemas com abrangência global e outros com escopo regional. Assinale a alternativa que indica corretamente três dos principais sistemas regionais consolidados, distinguindo-os do sistema universal gerido pela Organização das Nações Unidas (ONU).'),
('O processo de internacionalização dos direitos humanos ganhou força normativa e institucional no período pós-Segunda Guerra Mundial. No que se refere à organização arquitetônica desse complexo de proteção, o papel desempenhado pela Declaração Universal dos Direitos Humanos (DUDH) de 1948 consiste em:'),
('Um cidadão do Estado "Alfa" teve um de seus direitos fundamentais violado por agentes públicos. Insatisfeito com a resposta obtida nas vias internas de seu país, decidiu acionar um órgão de proteção do sistema regional do qual seu Estado é signatário. Ao fazê-lo, argumentou que o direito internacional deveria substituir a justiça local na apreciação do caso. Considerando a relação estrutural entre os sistemas nacional, regional e universal de proteção dos direitos humanos, a perspectiva desse cidadão está:'),
('O arranjo institucional de proteção aos direitos humanos conta com importantes diplomas normativos de diferentes escopos e vinculações territoriais. Ao se estudar a estrutura global desse arcabouço, observa-se que o Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) são instrumentos que:'),
('O desenvolvimento do Direito Internacional dos Direitos Humanos promoveu a consolidação de mecanismos de proteção que ultrapassam as fronteiras estatais, permitindo que a comunidade internacional averigue violações cometidas internamente. Com base na interação orgânica entre os planos nacional e internacional, assinale a alternativa correta.'),
(E'Considere as afirmativas a seguir a respeito da arquitetura estrutural do Sistema Internacional de Proteção dos Direitos Humanos:\n\nI. O sistema universal de proteção desenvolveu-se precipuamente no âmbito da Organização das Nações Unidas (ONU).\nII. A Declaração Universal dos Direitos Humanos (DUDH) desponta como o documento paradigmático que consolidou a gênese material desse sistema universal.\nIII. O sistema universal estabelece uma relação de hierarquia revogatória e substitutiva sobre as jurisdições nacionais, operando originariamente independentemente da atuação do Estado.\n\nEstá correto o que se afirma em:'),
('A Declaração Universal dos Direitos Humanos (DUDH) de 1948 garante valores fundamentais para a consolidação da dignidade humana no ordenamento internacional. Dentre as disposições materiais relativas à liberdade do ser humano, destaca-se a regra do artigo 4º, que consagra de forma absoluta:'),
('O princípio da igualdade constitui um dos pilares da Declaração Universal dos Direitos Humanos (DUDH). Ao estruturar o direito a não discriminação, a redação do artigo 7º do diploma não se limita a afirmar a igualdade formal de todos perante a lei, estendendo suas garantias. Assinale a alternativa que reflete corretamente o arcabouço desse dispositivo.'),
('Um cidadão decide renunciar à sua religião originária e passa a integrar uma nova comunidade de fé. Ao tentar realizar ritos abertos em uma praça com outros membros e ministrar ensinamentos aos recém-chegados, o Estado intervém. Por lei local, é permitido ter religião e cultuá-la apenas dentro de casa (modo privado), sendo expressamente proibido mudar a crença de nascimento e manifestá-la publicamente. À luz, estritamente, do artigo 18 da Declaração Universal dos Direitos Humanos (DUDH), a conduta do Estado:'),
('O Direito Internacional dos Direitos Humanos assenta-se na tutela da integridade e da dignidade física e moral do indivíduo. Refletindo essa diretriz, a Declaração Universal dos Direitos Humanos (DUDH) de 1948, em seu artigo 5º, proclama a regra de que:'),
('A compreensão da normatividade no Direito Internacional dos Direitos Humanos perpassa pela análise da natureza jurídica dos instrumentos formulados no seio da ONU. Ao analisar a força vinculante e a estrutura formal dos documentos que compõem a International Bill of Human Rights (Carta Internacional dos Direitos Humanos), conclui-se que há uma distinção basilar entre a Declaração Universal de 1948 (DUDH) e os Pactos de 1966. Essa distinção reside no fato de que:'),
('Os Pactos Internacionais de 1966 não foram idealizados em um vazio histórico; eles mantêm uma correlação umbilical com os valores universais sedimentados logo após a Segunda Guerra Mundial. Assinale a alternativa que descreve de forma fidedigna a relação normativa e histórica entre esses Pactos e a Declaração Universal dos Direitos Humanos (DUDH) de 1948.'),
('Em discussões de alto nível no âmbito da diplomacia e do Direito Internacional, frequentemente surge o debate sobre a exigibilidade jurídica das normas de direitos humanos constantes da Declaração Universal dos Direitos Humanos (DUDH) contra Estados que não são partes de nenhum tratado sobre a matéria. Levando-se em conta a formação do direito das gentes e a natureza peculiar da referida Declaração aprovada em 1948, é juridicamente correto afirmar que:'),
('O Estado soberano "Beta" é membro histórico da Organização das Nações Unidas desde a proclamação da Declaração Universal dos Direitos Humanos (DUDH) de 1948. Mais recentemente, passou pelos trâmites internos e depositou formalmente a ratificação, tornando-se Estado Parte do Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e do Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC). No tocante às responsabilidades internacionais que pesam sobre o Estado "Beta" no sistema universal, analise a diferença de densidade jurídica entre a DUDH e os Pactos e assinale a opção correta.'),
('Para traduzir os preceitos gerais da Declaração de 1948 em diplomas juridicamente vinculantes, o arcabouço da Organização das Nações Unidas aprovou, em 1966, dois grandes tratados, usualmente designados pelas siglas PIDCP e PIDESC. Assinale a alternativa que associa corretamente cada sigla à sua denominação oficial completa.'),
('Na arquitetura institucional do Direito Internacional, a origem do documento e a organização sob a qual foi adotado determinam a sua área de abrangência perante os Estados. Ao se constatar que um país ratificou o PIDCP (Pacto Internacional sobre Direitos Civis e Políticos) e o PIDESC (Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais), deve-se inferir que esses instrumentos:'),
(E'Considere as afirmativas a seguir em relação ao arcabouço global de proteção e à intersecção material entre a Declaração de 1948 e os Pactos de 1966:\n\nI. O Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) foram idealizados no âmbito da Organização das Nações Unidas (ONU).\nII. Embora tanto a Declaração de 1948 quanto os Pactos de 1966 estruturem direitos da pessoa humana, a DUDH não ostenta a forma de um tratado ratificável, ao passo que os Pactos vinculam convencionalmente os seus respectivos Estados Partes.\nIII. Em decorrência do avanço normativo na ONU, a adoção dos Pactos extinguiu as funções da DUDH, revogando o seu conteúdo ético em todo o sistema universal.\n\nEstá correto o que se afirma em:'),
('O Sistema Interamericano de Direitos Humanos fundamenta-se num mecanismo institucional de proteção, supervisão e responsabilização, operado por seus dois grandes órgãos institucionais, que mantêm relações procedimentais específicas com os Estados e com os indivíduos do continente. A respeito do acesso a esses órgãos e do alcance de suas prerrogativas sob a ótica da Convenção Americana de Direitos Humanos, assinale a opção que traça corretamente a distinção formal entre a atuação contenciosa da Corte e o recebimento de petições pela Comissão.'),
('A Corte Interamericana de Direitos Humanos, além de atuar em casos submetidos nos termos da Convenção Americana contra Estados sujeitos à sua jurisdição contenciosa, recebe do arcabouço normativo interamericano uma segunda competência de relevo para a estabilização jurisprudencial no continente. No tocante a essa competência da Corte, é correto afirmar que:'),
('Determinada pessoa, nacional de um Estado Parte da Convenção Americana sobre Direitos Humanos, alega ter sofrido violação de direito protegido pela Convenção em razão de ato de agente estatal. Desejando levar o caso à Comissão Interamericana, é advertida sobre um requisito procedimental básico de admissibilidade. Ao buscar as instâncias nacionais e examinar a legislação pátria, constata-se que não existe, no Estado em questão, o devido processo legal para a proteção do direito alegadamente violado. Sobre essa situação em face das regras de admissibilidade da Comissão Interamericana, assinale a opção correta.'),
('O Sistema Interamericano de Direitos Humanos é composto por diferentes instrumentos normativos, nem todos com natureza de tratado — é o caso da Declaração Americana dos Direitos e Deveres do Homem (1948). Assinale a alternativa que indica o tratado que constitui o instrumento central do sistema convencional interamericano de proteção dos direitos humanos, consagrando deveres jurídicos vinculantes para os Estados Partes no continente.'),
('O art. 33 da Convenção Americana sobre Direitos Humanos elenca os órgãos competentes para conhecer dos assuntos relacionados com o cumprimento dos compromissos assumidos pelos Estados Partes nessa Convenção. Assinale a alternativa que apresenta, correta e exclusivamente, o par de órgãos expressamente previsto nesse dispositivo.');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_03_enunciados);
  if v_cnt <> 22 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 22) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_03_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_03_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_03_enunciados);

commit;
