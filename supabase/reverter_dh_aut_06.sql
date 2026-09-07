-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-06 de Direitos
-- Humanos e Cidadania (22 questoes AUTORAL_PAPIRO / 110 alternativas /
-- 22 vinculos, cc92/cc93/cc94/cc95).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_06.sql.
--
-- Mecanismo de identificacao: as 22 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 22 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (vinculo -> alternativas -> questao).
-- NAO toca em Q180/Q181/Q182/Q189/Q190/Q191 (pre-existentes, apenas com
-- explicacao saneada em rodada tecnica anterior de manutencao) nem em
-- qualquer outra questao.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_06_enunciados (enunciado text) on commit drop;
insert into _dh_aut_06_enunciados (enunciado) values
('O Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul (Decreto nº 7.225/2010) estabelece diretrizes fundamentais para o bloco regional. Nos termos do artigo 2º do referido Protocolo, a atuação dos Estados Partes no âmbito da promoção e proteção efetiva dos direitos humanos fundamenta-se:'),
('Considere a hipótese de que, em um Estado Parte do Mercosul, ocorram graves e sistemáticas violações dos direitos humanos e das liberdades fundamentais, no contexto de uma crise institucional que abala a normalidade das instituições do país. Diante desse quadro fático, e considerando exclusivamente o rito estabelecido no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, a primeira providência institucional aplicável é:'),
('Durante o trâmite de verificação de violações sistemáticas a direitos fundamentais em um dos Estados Partes do Mercosul, o processo de consultas previsto no Protocolo de Assunção mostrou-se ineficaz, não resultando em qualquer mitigação das violações. Nessas circunstâncias, o artigo 4º do Protocolo estabelece que as demais Partes considerarão a natureza e o alcance das medidas a aplicar, tendo em vista a gravidade da situação. Dentre as medidas textualmente autorizadas pelo Protocolo para essa etapa, encontra-se a:'),
('Para que as medidas restritivas previstas no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul sejam validamente adotadas e entrem em vigor, deve-se obedecer ao procedimento formal descrito em seu artigo 5º. Assinale a alternativa que apresenta corretamente esse rito procedimental.'),
('Após a imposição de medidas de suspensão de direitos a um Estado Parte do Mercosul, com fundamento no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos, observa-se uma melhora significativa no cenário institucional daquele país. Segundo o regramento normativo próprio desse Protocolo, as medidas impostas cessarão:'),
('Para que os tratados internacionais tenham aplicabilidade no âmbito interno brasileiro, exige-se a observância de um rito complexo de internalização que envolve o Congresso Nacional e o Presidente da República. O Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, assinado em 2005, foi devidamente incorporado ao ordenamento jurídico brasileiro mediante a aprovação parlamentar e a posterior promulgação executiva, consubstanciadas, respectivamente, no:'),
('Em importante julgamento sobre o status normativo dos tratados internacionais de direitos humanos no Brasil, o Supremo Tribunal Federal reconheceu o caráter supralegal do Pacto de San José da Costa Rica (Convenção Americana sobre Direitos Humanos). Essa constatação jurisprudencial gerou efeitos diretos no ordenamento jurídico brasileiro, cujo maior reflexo prático foi a edição da Súmula Vinculante nº 25. Assinale a alternativa que indica corretamente o impacto jurídico da referida supralegalidade:'),
('A Emenda Constitucional nº 45/2004 inseriu o §3º no artigo 5º da Constituição Federal, criando um rito especial de aprovação para que tratados e convenções internacionais sobre direitos humanos ingressem no ordenamento brasileiro com equivalência de emendas constitucionais. No cenário brasileiro, são exemplos concretos de tratados que efetivamente passaram por esse rito e são equivalentes às emendas constitucionais:'),
('Suponha que o Estado brasileiro tenha celebrado um tratado internacional estritamente de cooperação aduaneira e redução tarifária com um país vizinho. Por considerar o acordo de suma importância econômica, as mesas diretoras da Câmara dos Deputados e do Senado Federal submeteram-no à votação em dois turnos, obtendo, em ambas as Casas, a aprovação por mais de três quintos dos votos dos seus membros. Com base na Constituição Federal, esse tratado econômico ostentará hierarquia de emenda constitucional?'),
('Em 2010, o Estado brasileiro internalizou um tratado internacional de direitos humanos valendo-se do procedimento legislativo ordinário, ou seja, aprovação por maioria simples no Congresso Nacional. Anos mais tarde, em 2018, foi promulgada uma lei federal ordinária estipulando uma regra procedimental diretamente conflitante com a norma protetiva daquele tratado. Diante desse conflito normativo e da jurisprudência consolidada do Supremo Tribunal Federal (STF), a solução aplicável é a de que a norma:'),
('O processo de internalização de tratados e convenções internacionais exige a atuação coordenada dos Poderes Executivo e Legislativo, de acordo com as atribuições outorgadas pela Constituição Federal de 1988. No que concerne à repartição de competências constitucionais para a incorporação dessas normas ao direito interno, é correto afirmar que:'),
('O Tratado de Marraqueche, em seu artigo 3º, não restringe sua proteção jurídica apenas às pessoas cegas ou com deficiência visual típica. O diploma internacional expande explicitamente o conceito de "beneficiário" para tutelar o acesso à leitura de outros grupos vulneráveis. Desta forma, enquadra-se legalmente como beneficiário do Tratado também a pessoa que:'),
('Para garantir o efetivo acesso à cultura, o Tratado de Marraqueche estabelece exceções ou limitações aos direitos de autor. Segundo o artigo 4º do diploma legal, uma entidade autorizada pode realizar a produção, obtenção e o fornecimento de exemplares em formato acessível a um beneficiário, independentemente de prévia autorização do titular dos direitos autorais. Contudo, essa faculdade está condicionada ao preenchimento cumulativo de rígidos critérios normativos, dentre os quais se destaca a necessidade de que:'),
('Na dinâmica de fomento ao acesso universal à literatura, o Tratado de Marraqueche instituiu mecanismos que extrapolam as divisas nacionais, visando otimizar recursos e acervos. Sobre o instituto do intercâmbio transfronteiriço de exemplares em formato acessível, delineado no artigo 5º do Tratado, é correto afirmar que:'),
('Para além das remessas feitas por instituições (o intercâmbio transfronteiriço), o Tratado de Marraqueche tutela a capacidade de a própria base destinatária trazer o material adaptado ao seu país. De acordo com a disciplina do artigo 6º do Tratado no que tange à importação de exemplares em formato acessível, assinale a premissa correta:'),
('O Tratado de Marraqueche foi aprovado pelo Congresso Nacional em conformidade com o quórum qualificado do art. 5º,§3º, da Constituição, por se tratar de tratado de direitos humanos. Assinale a alternativa que indica o ato normativo por meio do qual o Congresso Nacional aprovou formalmente o referido Tratado:'),
('A incorporação de um tratado internacional ao direito brasileiro envolve, em regra, duas etapas: aprovação pelo Congresso Nacional e promulgação pelo Presidente da República. Embora o Tratado de Marraqueche tenha sido aprovado pelo Congresso Nacional por meio do Decreto Legislativo nº 261/2015, sua promulgação no ordenamento jurídico interno — conferindo-lhe obrigatoriedade na jurisdição brasileira — deu-se pela via do:'),
('Considerando a disciplina do art. 11,§2º, da Lei nº 9.504/1997, com redação dada pela Lei nº 15.230/2025, sobre o momento de aferição da idade mínima exigida para candidaturas, e sem prejuízo das idades fixadas no art. 14,§3º,VI, da Constituição Federal, assinale a alternativa que descreve corretamente o momento de verificação da idade mínima para candidatos a cargos do Poder Executivo e para candidatos às Câmaras Municipais, respectivamente:'),
('Para que um cidadão adquira plenamente o direito de disputar mandatos eletivos (capacidade eleitoral passiva) na República Federativa do Brasil, ele deve reunir certos requisitos essenciais preestabelecidos pelo constituinte originário. Consoante dispõe expressamente o artigo 14,§3º, da Constituição Federal, consistem em condições cumulativas de elegibilidade:'),
('A Constituição de 1988 consagrou a soberania popular, prevendo que será exercida pelo sufrágio universal e pelo voto direto e secreto, além de outros institutos de participação direta da cidadania. Sobre o plebiscito, o referendo e a iniciativa popular, é correto afirmar que:'),
('A Constituição Federal fixa idades mínimas distintas conforme o cargo eletivo pretendido. Considerando que um cidadão brasileiro planeje candidatar-se primeiro à Câmara dos Deputados e, futuramente, ao Senado Federal, ele deverá alcançar, como condição de elegibilidade, as idades mínimas respectivas de:'),
('O exercício da democracia representativa depende da correta compreensão das dimensões ativa e passiva do sufrágio. De acordo com o sistema de direitos políticos delineado na Constituição Federal, a correta e direta distinção entre as modalidades de sufrágio expressa-se na seguinte formulação:');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_06_enunciados);
  if v_cnt <> 22 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 22) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_06_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_06_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_06_enunciados);

commit;
