#!/usr/bin/env node
// Fase 2M — Lei de Drogas (Lei Federal nº 11.343/2006):
// Correções de explicação jurídica / ressalva Tema 506 STF (740, 742, 781, 783) e higiene de OCR (13 questões).
//
// Escopo:
//   - id 740: Ajuste da explicação ao art. 2º da Lei 11.343/06 (sem fórmula de proibição absoluta) + higiene OCR. Gabarito D preservado.
//   - id 742: Reescrita total da explicação (expurgando texto sobre Igualdade Racial e fundamentando as 4 assertivas) + higiene OCR. Gabarito E preservado.
//   - id 781: Complementação da explicação com ressalva do Tema 506/STF (natureza extrapenal da advertência para cannabis) + higiene OCR. Gabarito A preservado.
//   - id 783: Nova explicação separando literalidade da lei vs. regime do Tema 506/STF para cannabis + higiene OCR. Gabarito C preservado.
//   - ids 674, 741, 782, 803, 804, 867, 868, 869, 870: Higiene estrita de resíduos de OCR identificados. Explicações e gabaritos preservados byte-a-byte.
//   - ids 143, 269, 270: Intocados.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2m_lei_drogas_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2m_lei_drogas_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes capturados ao vivo do banco de produção antes desta migração:
const HASH_QUESTAO_ANTES = {
  674: '43bc2941a2f90cdc8b367ce373cd9056',
  740: '19d35b3cfbf0ec998b284a4df180eea1',
  741: '7c92e2d0d14b62bbed633639af38f0eb',
  742: 'd98c2e3bd0f484c8b634a2c59497d6be',
  781: '6338935c9b900249f8fc5d02cad5a365',
  782: '47fdbe2c41be9528d25aa221bb384e69',
  783: 'ad3f1463a6afc418adc6d4cc2380dab7',
  803: '667900455c55fa7d518a679c95551cbd',
  804: 'a69eed5a0c994fce34b750d34b3085a0',
  867: 'ff609499af6e528b07fa63b1d9ae2fbc',
  868: 'd2ad721021eb598ec70b86d5fa6c055f',
  869: '7f498bfc1b660a30f7ad70d582bf7029',
  870: 'e783f7f2309f5daf2422847c244a1b4f',
};

const HASH_EXPLICACAO_ANTES = {
  674: 'c30e2067e61681de0e2aced6c8849064',
  740: '93b438b82f833e7d6f6d2aef0e7c0a59',
  741: 'feba0e5fa410b8bafe1d50221caa5ef8',
  742: 'c97417868354b40990d0d9e44cde5fa1',
  781: '87796b0a55e5196be4b20db9210252c3',
  782: '3398270d73eed339110948e382c689f7',
  783: 'c4a85a02a5e327f472415ddca5267cb7',
  803: '3489cefc445861e55d3496faa0f1c2a9',
  804: 'fc68aebe7b690a40dc583a12ee23eca0',
  867: '6b8b43a471b1673ce1ed0cb9ac601ede',
  868: '50e943be8bc8a9796c5861244b386c08',
  869: '636bc42deb0765bf529b79e23756396e',
  870: '2bafe200c95b07d24c13f8dd6f65f43d',
};

// Textos novos / higienizados:
const ALT_NOVAS_674 = {
  3347: "Nos crimes de extorsão mediante sequestro, o membro do Ministério Público ou o delegado de polícia poderá requisitar, de quaisquer órgãos do Poder Público ou de empresas da iniciativa privada, dados e informações cadastrais da vítima ou de suspeitos.",
  3349: "O inquérito policial ou outro procedimento previsto em lei em curso somente poderá ser avocado ou redistribuído por superior hierárquico, mediante despacho fundamentado, por motivo de interesse público ou nas hipóteses de inobservância dos procedimentos previstos em regulamento da corporação que prejudique a eficácia da investigação.",
  3350: "Conforme jurisprudência do Supremo Tribunal Federal, é possível a deflagração da persecução penal pela chamada denúncia anônima, desde que esta seja seguida de diligências realizadas para averiguar os fatos nela noticiados antes da instauração do inquérito policial.",
  3351: "O juiz formará sua convicção pela livre apreciação da prova produzida em contraditório judicial, não podendo fundamentar sua decisão exclusivamente nos elementos informativos colhidos na investigação, ressalvadas as provas cautelares, não repetíveis e antecipadas.",
};

const ENUNCIADO_NOVO_740 = "Durante sua atividade de proteção ao patrimônio em um parque municipal com grande área de vegetação, um guarda municipal encontrou um canteiro, de aproximadamente 30 m², em meio às árvores, com uma plantação de maconha. A pessoa responsável pela plantação informou que dependia da planta para fins medicinais e que, além disso, usava a plantação como meio para obter recursos financeiros para sua sobrevivência. Considerando o quadro apresentado e a legislação vigente, é correto afirmar que:";
const EXPLICACAO_NOVA_740 = "GABARITO: alternativa D\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ CORRETA:\r\nO Artigo 2º, caput, da Lei nº 11.343/2006 proíbe em todo o território nacional o plantio, a cultura, a colheita e a exploração de vegetais e substratos dos quais possam ser extraídas ou produzidas drogas, ressalvada a hipótese de autorização legal ou regulamentar, bem como a possibilidade de a União autorizar o plantio para fins exclusivamente medicinais ou científicos (art. 2º, parágrafo único).\r\nNo caso concreto narrado, o plantio foi realizado em espaço público (parque municipal), sem autorização legal ou regulamentar aplicável, sendo cumulado com a venda para obtenção de renda pelo responsável, conduta que não se enquadra em nenhuma das exceções legais, sendo proibidos tanto o plantio e a venda quanto o uso da área.\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r\nO plantio de vegetais destinados à produção de drogas é proibido como regra geral pelo art. 2º da Lei nº 11.343/2006, ressalvadas as hipóteses legalmente admitidas. No caso concreto, não há autorização que legitime o cultivo realizado no parque público.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nA mera alegação de finalidade medicinal ou de dependência não autoriza o cultivo. É necessário enquadramento em hipótese de autorização legal ou regulamentar ou, para os fins previstos no parágrafo único do art. 2º, autorização da União nas condições legalmente estabelecidas.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nA dimensão da área plantada não afasta a vedação legal ao plantio não autorizado em área pública.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\nNo caso narrado, a venda não autorizada de maconha para obtenção de renda constitui conduta ilícita abrangida pela repressão penal prevista na Lei de Drogas.\r\n\r\nBIZU DE PROVA:\r\nPlantio e Cultivo de Drogas — art. 2º da Lei nº 11.343/2006:\r\nRegra: são proibidos as drogas e o plantio, cultura, colheita e exploração dos vegetais e substratos dos quais possam ser extraídas ou produzidas drogas.\r\nRessalvas: a própria lei admite hipótese de autorização legal ou regulamentar e preserva a ressalva ritualístico-religiosa mencionada no caput.\r\nAlém disso, a União pode autorizar plantio, cultura e colheita exclusivamente para fins medicinais ou científicos, em local e prazo predeterminados e mediante fiscalização.\r\nNo caso da questão, o cultivo não autorizado em parque público associado à venda para obtenção de renda não se enquadra nessas ressalvas.";

const ENUNCIADO_NOVO_741 = "Conforme a Lei nº 11.343/2006, para atender à finalidade de articular, integrar, organizar e coordenar as atividades relacionadas com a prevenção do uso indevido, a atenção e a reinserção social de usuários e dependentes de drogas, a repressão da produção não autorizada e do tráfico ilícito de drogas, o Sistema Nacional de Políticas Públicas sobre Drogas (Sisnad) também atua em articulação com os seguintes sistemas de políticas públicas:";

const ENUNCIADO_NOVO_742 = "Segundo a Lei de Drogas (Lei nº 11.343/2006) e seus crimes, analise as assertivas abaixo: I. O crime de tráfico privilegiado (art. 33, § 4º, da referida Lei) permite a redução da pena de um a dois terços quando o agente for primário, possuir bons antecedentes, não se dedicar a atividades criminosas nem integrar organização criminosa, constituindo direito subjetivo do réu que preencha tais requisitos. II. O usuário de drogas que adquire, guarda, tem em depósito, transporta ou traz consigo drogas para consumo pessoal pratica crime punível com pena privativa de liberdade, sendo cabível a prisão em flagrante e a posterior conversão em penas alternativas. III. O crime de associação para o tráfico (art. 35 da referida Lei) exige a reunião de duas ou mais pessoas com o fim de praticar, reiteradamente ou não, qualquer dos crimes previstos nos arts. 33 a 37 da Lei, configurando-se como crime formal que se consuma independentemente da prática efetiva do tráfico. IV. A Lei de Drogas estabelece que não há crime quando o agente planta, cultiva ou colhe plantas destinadas à preparação de pequena quantidade de droga para consumo pessoal, aplicando-se as mesmas penas previstas para o usuário. Quais estão INCORRETAS?";
const EXPLICACAO_NOVA_742 = "GABARITO: alternativa E\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\r\nTodas as quatro assertivas (I, II, III e IV) estão INCORRETAS:\r\n\r\n- Assertiva I (Incorreta): O tráfico privilegiado (art. 33, § 4º da Lei nº 11.343/2006) é causa de diminuição de pena — e não crime autônomo —, prevendo redução de um sexto a dois terços (1/6 a 2/3), e não \"de um a dois terços\".\r\n- Assertiva II (Incorreta): A conduta de adquirir, guardar ou transportar drogas para consumo pessoal (art. 28) não comina pena privativa de liberdade, e o art. 48, § 2º da Lei nº 11.343/2006 veda expressamente a imposição de prisão em flagrante.\r\n- Assertiva III (Incorreta): O crime de associação para o tráfico (art. 35) exige o dolo de associação estável e permanente entre os agentes (jurisprudência pacífica do STJ) e restringe-se aos crimes previstos no art. 33, caput e § 1º, e no art. 34 da Lei (e financiamento no parágrafo único), não abrangendo indistintamente todos os delitos dos \"arts. 33 a 37\".\r\n- Assertiva IV (Incorreta): A Lei de Drogas não estabelece a fórmula textual de que \"não há crime\"; o art. 28, § 1º prescreve que o cultivo de plantas destinadas à preparação de pequena quantidade para consumo pessoal submete-se às medidas do caput. Ademais, a assertiva formula a regra para qualquer \"droga\" de forma genérica, enquanto o afastamento de efeitos penais pelo STF (Tema 506) foi restrito e específico para a Cannabis sativa, mantendo a natureza de ilícito com sanções extrapenais.\r\n\r\nPOR QUE AS ALTERNATIVAS A, B, C E D ESTÃO INCORRETAS:\r\nAs opções A, B, C e D indicam apenas parte das assertivas incorretas, ao passo que todas as quatro assertivas (I, II, III e IV) contêm erros jurídicos.\r\n\r\nBIZU DE PROVA:\r\nLei de Drogas (Lei nº 11.343/2006):\r\n1. Tráfico Privilegiado (Art. 33, §4º): Redução de 1/6 a 2/3 (causa de diminuição, não delito autônomo).\r\n2. Usuário (Art. 28 e Art. 48, §2º): Não há pena de prisão nem flagrante.\r\n3. Associação (Art. 35): Exige vínculo estável e permanente para os crimes dos arts. 33, caput/§1º e 34.\r\n4. Cultivo Pessoal (Art. 28, §1º): Submete-se às medidas do art. 28.";

const ENUNCIADO_NOVO_781 = "Ao atuar na verificação de um acidente de trânsito em via urbana, o guarda municipal encontrou junto ao acompanhante do condutor do veículo dois cigarros de maconha. Questionado sobre a situação, o carona alegou ser para consumo próprio. Por transportar essa quantidade de droga para consumo pessoal, ele poderá ser submetido a qual das penas abaixo?";
const EXPLICACAO_NOVA_781 = "GABARITO: alternativa A\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ CORRETA:\r\nConforme o Artigo 28, inciso I, da Lei nº 11.343/2006, a advertência sobre os efeitos das drogas é a medida legal aplicável a quem adquire, guarda, transporta ou traz consigo droga para consumo pessoal, sendo a única sanção prevista em lei dentre as opções apresentadas.\r\nRessalva jurídica (Tema 506/STF): Embora o enunciado histórico da questão utilize a palavra \"penas\", o Supremo Tribunal Federal, no julgamento do RE nº 635.659/SP (Tema 506), fixou que o porte de cannabis sativa para consumo pessoal não configura infração de natureza penal, mas ilícito de natureza administrativa. Desse modo, a advertência sobre os efeitos das drogas (art. 28, I) permanece plenamente aplicável, porém em procedimento de natureza não penal e sem repercussão criminal.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nA prestação de serviço militar obrigatório é dever constitucional militar, não sanção prevista na Lei de Drogas.\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nO comparecimento a programa ou curso educativo tem prazo máximo legal de 5 meses para o réu primário (art. 28, § 3º), e não 2 anos.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nA proibição de prestar concurso vestibular inexiste no ordenamento jurídico nacional.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\nA Lei de Drogas não prevê a retenção de CNH por seis meses como penalidade direta do art. 28.\r\n\r\nBIZU DE PROVA:\r\nUsuário de Drogas e Maconha (Art. 28 da Lei 11.343/2006 e Tema 506/STF):\r\n- Medida legal aplicável: Advertência sobre os efeitos das drogas (Art. 28, I).\r\n- Atualização STF (Tema 506): Para a cannabis/maconha de uso próprio, a advertência e o comparecimento a curso educativo são medidas de natureza extrapenal/administrativa, sem efeitos criminais.";

const ENUNCIADO_NOVO_782 = "A Lei nº 11.343/2006 prescreve medidas para prevenção do uso indevido, atenção e reinserção social de usuários e dependentes de drogas, estabelece normas para repressão à produção não autorizada e ao tráfico ilícito de drogas, define crimes e dá outras providências. Essa Lei instituiu o(a):";

const ENUNCIADO_NOVO_783 = "Um guarda municipal abordou uma pessoa em praça pública por perceber que seu comportamento estava incomum. Na ocasião, foi constatado que ela estava de posse de aproximadamente 100 gramas de maconha. Essa pessoa foi conduzida para a Delegacia de Polícia, onde alegou que a droga era apenas para seu consumo pessoal. A quais penas ela pode ser submetida, considerando que era primária nessa situação e não tinha autorização ou determinação legal para transportar a droga?";
const EXPLICACAO_NOVA_783 = "GABARITO: alternativa C\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA (LITERALIDADE DA LEI E GABARITO OFICIAL):\r\nA alternativa C reflete a literalidade do Artigo 28 da Lei nº 11.343/2006, que prescreve conjuntamente as seguintes medidas ao agente que conduz droga para consumo pessoal:\r\nI - Advertência sobre os efeitos das drogas;\r\nII - Prestação de serviços à comunidade;\r\nIII - Medida educativa de comparecimento a programa ou curso educativo.\r\nDentre as alternativas da prova, a C é a única que reproduz o rol de sanções previsto expressamente no texto do art. 28 da Lei de Drogas.\r\n\r\nRESSALVA JURÍDICA — REGIME ATUAL DA CANNABIS (TEMA 506/STF):\r\nO gabarito C é mantido como gabarito histórico/oficial da questão e pela literalidade cobrada pela banca, mas exige ressalva jurídica em razão do Tema 506/STF (RE nº 635.659/SP):\r\n1. Natureza extrapenal: O porte de cannabis sativa para consumo pessoal foi declarado ilícito de natureza administrativa, sem repercussão criminal.\r\n2. Sanções aplicáveis: O STF manteve aplicáveis na esfera não penal apenas as medidas dos incisos I (advertência) e III (comparecimento a curso educativo), não integrando a prestação de serviços à comunidade (inciso II) o regime fixado pelo STF para a cannabis de uso pessoal.\r\n3. Critério quantitativo: O parâmetro de 40g (ou 6 plantas-fêmeas) constitui presunção relativa de usuário. A apreensão de quantidade superior (como os 100g narrados) não caracteriza automaticamente crime de tráfico, devendo a autoridade judicial valorar a quantidade em conjunto com as demais circunstâncias fáticas do caso concreto.\r\n\r\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\r\nAs alternativas A, B, D e E contêm sanções absurdas e sem previsão legal (prisão imediata, cárcere privado, detenção sumária, admoestação verbal ou multa inalienável). O art. 48, § 2º veda expressamente a prisão em flagrante para o art. 28.\r\n\r\nBIZU DE PROVA:\r\nArtigo 28 da Lei nº 11.343/2006 vs. Tema 506/STF:\r\n- Texto da Lei: Advertência (I), Prestação de serviços à comunidade (II) e Curso educativo (III).\r\n- Atualização STF (Cannabis): Ilícito administrativo punível com Advertência (I) e Curso educativo (III). Prestação de serviços (II) afastada para uso pessoal de maconha. 40g é presunção relativa.";

const ENUNCIADO_NOVO_803 = "A Lei nº 11.343/2006 prescreve medidas para a prevenção do uso indevido, atenção e reinserção social de usuários e dependentes de drogas, estabelece normas para a repressão à produção não autorizada e ao tráfico ilícito de drogas, bem como define e dá outras providências. Segundo essa Lei, todas essas competências e atribuições competem a qual órgão de âmbito nacional?";

const ENUNCIADO_NOVO_804 = "Qual a base legal, além do Código Penal Brasileiro, para a atuação do Guarda Municipal que constatar que uma pessoa está vendendo substância tóxica entorpecente para outras pessoas em uma praça municipal?";

const ENUNCIADO_NOVO_867 = "Um morador das proximidades de uma escola pública municipal informou ao Guarda Municipal do local que estava desconfiado sobre os vegetais que um morador, há poucos meses na localidade, estava plantando numa propriedade rural próxima da sua residência. De fato, o GM encontrou uma plantação em um terreno que estava vazio, com cerca de 300 m², mas cuidado por um zelador particular, contratado para evitar ocupação irregular, completamente ocupado com plantas de maconha. Ao ser questionado, alegou ser usuário de drogas. Como deve ser tipificada essa situação?";

const ENUNCIADO_NOVO_868 = "Com base na Lei de Drogas, Lei nº 11.343/2006, analise as assertivas abaixo, assinalando V, se verdadeiras, ou F, se falsas. Quem oferece droga, eventualmente e sem objetivo de lucro, à pessoa de seu relacionamento, para juntos a consumirem: ( ) Não pratica crime por falta de previsão legal. ( ) Pratica crime previsto na Lei de Drogas. ( ) Pode ser penalizado com detenção. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:";

const ENUNCIADO_NOVO_869 = "Nos termos da Lei nº 11.343/2006, quem adquirir, guardar, tiver em depósito, transportar ou trouxer consigo, para consumo pessoal, drogas sem autorização ou em desacordo com determinação legal ou regulamentar será submetido às seguintes penas: I. Advertência sobre os efeitos das drogas. II. Medida educativa de comparecimento a programa ou curso educativo. III. Lavratura de prisão em flagrante. Quais estão corretas?";

const ALT_NOVAS_870 = {
  4318: "Todas as internações e altas de que trata esta lei deverão ser informadas, em, no máximo, de 72 horas, ao Ministério Público, à Defensoria Pública e a outros órgãos de fiscalização, por meio de sistema informatizado único.",
  4320: "A internação involuntária perdurará apenas pelo tempo necessário à desintoxicação, no prazo máximo de 90 dias, tendo seu término determinado pelo médico responsável.",
};

function body(mode) {
  return `-- ============================================================================
-- FASE 2M — LEI DE DROGAS: CORREÇÕES JURÍDICAS, TEMA 506/STF E HIGIENE DE OCR
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- Escopo:
--   - id 740: Ajuste da explicação ao art. 2º da Lei 11.343/06 (sem fórmula de proibição absoluta) + higiene OCR. Gabarito D preservado.
--   - id 742: Reescrita total da explicação (expurgando texto sobre Igualdade Racial e fundamentando as 4 assertivas) + higiene OCR. Gabarito E preservado.
--   - id 781: Complementação da explicação com ressalva do Tema 506/STF (natureza extrapenal da advertência para cannabis) + higiene OCR. Gabarito A preservado.
--   - id 783: Nova explicação separando literalidade da lei vs. regime do Tema 506/STF para cannabis + higiene OCR. Gabarito C preservado.
--   - ids 674, 741, 782, 803, 804, 867, 868, 869, 870: Higiene estrita de resíduos de OCR identificados. Explicações e gabaritos preservados byte-a-byte.
--   - ids 143, 269, 270: Intocados.
--
-- Garantias e Precondições:
--   - Validação de integridade via MD5 ao vivo antes de qualquer escrita;
--   - GET DIAGNOSTICS checando linhas afetadas em cada UPDATE;
--   - Snapshot antes/depois e asserts comparando JSONB byte-a-byte;
--   - Gabaritos e integridade estrutural das alternativas 100% preservados;
--   - Total global de questões = 915 inalterado;
--   - Total de ativas = 908 inalterado;
--   - Todas as 13 questões continuam com ativa = true.
-- ============================================================================

BEGIN;
SET TRANSACTION READ WRITE;

-- ----------------------------------------------------------------------------
-- 1. SNAPSHOT ANTES
-- ----------------------------------------------------------------------------
create temporary table _f2m_snap_questoes on commit drop as
select id, ativa,
  (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') as dados_imutaveis_geral,
  (to_jsonb(q) - 'enunciado' - 'atualizado_em') as dados_imutaveis_ocr_puro,
  (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') as dados_imutaveis_exp
from public.questoes q
where q.id in (674, 740, 741, 742, 781, 782, 783, 803, 804, 867, 868, 869, 870);

create temporary table _f2m_snap_alt on commit drop as
select id, questao_id, ordem, correta, (to_jsonb(a) - 'texto') as dados_imutaveis_alt
from public.alternativas a
where a.questao_id in (674, 740, 741, 742, 781, 782, 783, 803, 804, 867, 868, 869, 870);

create temporary table _f2m_snap_global on commit drop as
select
  (select count(*) from public.questoes) as total_questoes_antes,
  (select count(*) from public.questoes where ativa = true) as total_ativas_antes;

create temporary table _f2m_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- 2. PRECONDIÇÕES DE INTEGRIDADE
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from public.questoes where id = 674 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[674])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[674])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 674 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 740 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[740])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[740])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 740 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 741 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[741])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[741])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 741 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 742 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[742])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[742])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 742 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 781 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[781])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[781])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 781 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 782 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[782])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[782])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 782 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 783 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[783])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[783])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 783 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 803 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[803])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[803])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 803 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 804 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[804])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[804])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 804 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 867 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[867])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[867])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 867 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 868 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[868])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[868])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 868 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 869 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[869])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[869])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 869 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 870 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[870])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[870])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 870 nao esta no estado esperado';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 3. ESCRITAS CONTROLADAS
-- ----------------------------------------------------------------------------

-- ID 674: Alternativas (OCR)
do $$
declare v_linhas int;
begin
  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_674[3347])} where id = 3347 and questao_id = 674;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3347 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_674[3349])} where id = 3349 and questao_id = 674;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3349 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_674[3350])} where id = 3350 and questao_id = 674;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3350 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_674[3351])} where id = 3351 and questao_id = 674;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3351 afetou % linhas', v_linhas; end if;
end $$;

-- ID 740: Enunciado e Explicação (Correção de Explicação + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_740)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_740)}, atualizado_em = now()
  where id = 740;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 740 afetou % linhas', v_linhas; end if;
end $$;

-- ID 741: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_741)}, atualizado_em = now() where id = 741;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 741 afetou % linhas', v_linhas; end if;
end $$;

-- ID 742: Enunciado e Explicação (Reescrita Jurídica + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_742)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_742)}, atualizado_em = now()
  where id = 742;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 742 afetou % linhas', v_linhas; end if;
end $$;

-- ID 781: Enunciado e Explicação (Ressalva Tema 506 + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_781)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_781)}, atualizado_em = now()
  where id = 781;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 781 afetou % linhas', v_linhas; end if;
end $$;

-- ID 782: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_782)}, atualizado_em = now() where id = 782;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 782 afetou % linhas', v_linhas; end if;
end $$;

-- ID 783: Enunciado e Explicação (Ressalva Tema 506 + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_783)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_783)}, atualizado_em = now()
  where id = 783;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 783 afetou % linhas', v_linhas; end if;
end $$;

-- ID 803: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_803)}, atualizado_em = now() where id = 803;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 803 afetou % linhas', v_linhas; end if;
end $$;

-- ID 804: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_804)}, atualizado_em = now() where id = 804;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 804 afetou % linhas', v_linhas; end if;
end $$;

-- ID 867: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_867)}, atualizado_em = now() where id = 867;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 867 afetou % linhas', v_linhas; end if;
end $$;

-- ID 868: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_868)}, atualizado_em = now() where id = 868;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 868 afetou % linhas', v_linhas; end if;
end $$;

-- ID 869: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_869)}, atualizado_em = now() where id = 869;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 869 afetou % linhas', v_linhas; end if;
end $$;

-- ID 870: Alternativas (OCR)
do $$
declare v_linhas int;
begin
  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_870[4318])} where id = 4318 and questao_id = 870;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 4318 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_870[4320])} where id = 4320 and questao_id = 870;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 4320 afetou % linhas', v_linhas; end if;
end $$;

-- ----------------------------------------------------------------------------
-- 4. ASSERTS PÓS-ESCRITA
-- ----------------------------------------------------------------------------
do $$
begin
  -- Assert 1: Total global de questões permanece 915
  insert into _f2m_asserts (descricao, ok)
  select 'total_questoes permanece exatamente 915',
    (select count(*) from public.questoes) = 915
    and (select count(*) from public.questoes) = (select total_questoes_antes from _f2m_snap_global);

  -- Assert 2: Total global de ativas permanece 908
  insert into _f2m_asserts (descricao, ok)
  select 'total_ativas permanece exatamente 908',
    (select count(*) from public.questoes where ativa = true) = 908
    and (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes from _f2m_snap_global);

  -- Assert 3: Todas as 13 questões continuam com ativa = true
  insert into _f2m_asserts (descricao, ok)
  select 'todas as 13 questoes continuam ativa = true',
    (select count(*) from public.questoes where id in (674, 740, 741, 742, 781, 782, 783, 803, 804, 867, 868, 869, 870) and ativa = true) = 13;

  -- Assert 4: IDs com OCR puro — nenhuma coluna além de enunciado/alternativa e atualizado_em mudou
  insert into _f2m_asserts (descricao, ok)
  select 'OCR puro: apenas enunciado/alternativas/atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2m_snap_questoes s on s.id = q.id
      where q.id in (674, 741, 782, 803, 804, 867, 868, 869, 870)
        and (to_jsonb(q) - 'enunciado' - 'atualizado_em') <> s.dados_imutaveis_ocr_puro
    );

  -- Assert 5: 740, 742, 781, 783 — apenas enunciado, explicacao e atualizado_em mudaram
  insert into _f2m_asserts (descricao, ok)
  select '740, 742, 781, 783: apenas enunciado, explicacao e atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2m_snap_questoes s on s.id = q.id
      where q.id in (740, 742, 781, 783)
        and (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis_exp
    );

  -- Assert 6: Alternativas — gabaritos (ordem, correta, ids) 100% preservados
  insert into _f2m_asserts (descricao, ok)
  select 'alternativas: metadados, ordem e gabarito (correta) permanecem byte-identicos',
    not exists (
      select 1 from public.alternativas a
      join _f2m_snap_alt s on s.id = a.id
      where (to_jsonb(a) - 'texto') <> s.dados_imutaveis_alt
    );

  -- Assert 7: Exatamente 1 alternativa correta por questão
  insert into _f2m_asserts (descricao, ok)
  select 'todas as 13 questoes possuem exatamente 1 alternativa correta',
    not exists (
      select q.id from public.questoes q
      where q.id in (674, 740, 741, 742, 781, 782, 783, 803, 804, 867, 868, 869, 870)
        and (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta = true) <> 1
    );

  -- Assert 8: Questões 143, 269 e 270 intocadas
  insert into _f2m_asserts (descricao, ok)
  select '143, 269 e 270 permanecem intocadas',
    (select count(*) from public.questoes where id in (143, 269, 270) and atualizado_em = '2026-08-19 05:25:36.591468+00') = 3;

  -- Assert 9: Semântica 740 — contém art. 2º e ressalvas, sem 'ilicitude absoluta'
  insert into _f2m_asserts (descricao, ok)
  select '740: explicacao contem art. 2º caput e paragrafo unico, sem ilicitude absoluta',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 740)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_740)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao like '%Artigo 2º, caput%' and explicacao like '%parágrafo único%' from public.questoes where id = 740)
    and (select explicacao not ilike '%ilicitude absoluta%' and explicacao not ilike '%proibição absoluta%' from public.questoes where id = 740)
    and (select explicacao like '%sem autorização legal ou regulamentar aplicável%' from public.questoes where id = 740)
    and (select explicacao like '%ressalva ritualístico-religiosa%' from public.questoes where id = 740);

  -- Assert 10: Semântica 742 — explicacao sem Igualdade Racial e com fundamentos das 4 assertivas
  insert into _f2m_asserts (descricao, ok)
  select '742: explicacao sem mencao a Igualdade Racial e com fundamentos das 4 assertivas',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 742)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_742)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao not ilike '%Igualdade Racial%' and explicacao not ilike '%ADPF 186%' from public.questoes where id = 742)
    and (select explicacao like '%um sexto a dois terços%' and explicacao like '%art. 48, § 2º%' and explicacao like '%art. 35%' and explicacao like '%art. 28, § 1º%' from public.questoes where id = 742);

  -- Assert 11: Semântica 781 — ressalva Tema 506 com natureza administrativa da advertencia
  insert into _f2m_asserts (descricao, ok)
  select '781: explicacao contem ressalva Tema 506 e natureza administrativa da advertencia',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 781)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_781)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao like '%Tema 506%' and explicacao like '%natureza administrativa%' and explicacao like '%Artigo 28, inciso I%' from public.questoes where id = 781);

  -- Assert 12: Semântica 783 — explicacao separa literalidade vs. regime Tema 506
  insert into _f2m_asserts (descricao, ok)
  select '783: explicacao separa literalidade vs. regime Tema 506 e contem texto de ressalva explicita',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 783)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_783)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao ilike '%gabarito C é mantido como gabarito histórico/oficial da questão%' from public.questoes where id = 783)
    and (select explicacao ilike '%literalidade cobrada pela banca%' from public.questoes where id = 783)
    and (select explicacao ilike '%exige ressalva jurídica em razão do Tema 506/STF%' from public.questoes where id = 783)
    and (select explicacao ilike '%RE nº 635.659/SP%' from public.questoes where id = 783)
    and (select explicacao ilike '%presunção relativa%' and explicacao ilike '%prestação de serviços à comunidade%' from public.questoes where id = 783);

  -- Assert 13: Higiene de OCR — verificacao de ausencia de palavras coladas
  insert into _f2m_asserts (descricao, ok)
  select 'OCR 674: alternativas limpas',
    (select texto not like '%Público oude%' from public.alternativas where id = 3347)
    and (select texto not like '%despachofundamentado%' and texto not like '%aeficácia%' from public.alternativas where id = 3349)
    and (select texto not like '%sejaseguida%' from public.alternativas where id = 3350)
    and (select texto not like '%noselementos%' from public.alternativas where id = 3351);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 740: enunciado limpo',
    (select enunciado not like '%deaproximadamente%' and enunciado not like '%finsmedicinais%' and enunciado not like '%legislaçãovigente%' from public.questoes where id = 740);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 741: enunciado limpo',
    (select enunciado not like '%indevido,a%' and enunciado not like '%dePolíticas%' from public.questoes where id = 741);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 742: enunciado limpo',
    (select enunciado not like '%bonsantecedentes%' and enunciado not like '%privativade%' and enunciado not like '%qualquerdos%' and enunciado not like '%paraconsumo%' from public.questoes where id = 742);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 781: enunciado limpo',
    (select enunciado not like '%demaconha%' and enunciado not like '%sersubmetido%' from public.questoes where id = 781);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 782: enunciado limpo',
    (select enunciado not like '%normaspara%' from public.questoes where id = 782);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 783: enunciado limpo',
    (select enunciado not like '%deposse%' and enunciado not like '%consumopessoal%' from public.questoes where id = 783);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 803: enunciado limpo',
    (select enunciado not like '%normaspara%' and enunciado not like '%eatribuições%' from public.questoes where id = 803);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 804: enunciado limpo',
    (select enunciado not like '%tóxicaentorpecente%' from public.questoes where id = 804);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 867: enunciado limpo',
    (select enunciado not like '%morador,há%' and enunciado not like '%estavavazio%' and enunciado not like '%serquestionado%' from public.questoes where id = 867);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 868: enunciado limpo',
    (select enunciado not like '%eventualmente esem%' from public.questoes where id = 868);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 869: enunciado limpo',
    (select enunciado not like '%11343/2006%' and enunciado not like '%emdesacordo%' from public.questoes where id = 869);

  insert into _f2m_asserts (descricao, ok)
  select 'OCR 870: alternativas limpas',
    (select texto not like '%outrosórgãos%' from public.alternativas where id = 4318)
    and (select texto not like '%médicoresponsável%' from public.alternativas where id = 4320);
end $$;

-- ----------------------------------------------------------------------------
-- 5. VALIDAÇÃO DOS ASSERTS
-- ----------------------------------------------------------------------------
do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2m_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2M (Lei de Drogas) falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada persistido em produção: ROLLBACK obrigatório do harness de teste.\nROLLBACK;\n`
    : `-- Reconciliação confirmada e validada por todos os asserts: persistência definitiva.\nCOMMIT;\n`}`;
}

const harnessSql = body('rollback');
const applySql = body('commit');

const harnessCore = harnessSql
  .replace('HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.', '')
  .replace(/-- Nada persistido em produção[\s\S]*ROLLBACK;\n$/, '');
const applyCore = applySql
  .replace('APLICAÇÃO REAL — TERMINA EM COMMIT.', '')
  .replace(/-- Reconciliação confirmada[\s\S]*COMMIT;\n$/, '');

if (harnessCore !== applyCore) {
  throw new Error('Harness e apply divergem fora do bloco esperado (modo/rollback-commit) — verificar gerador.');
}

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Gerado com sucesso: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);
console.log(`Gerado com sucesso: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log('Harness e Apply 100% verificados: idênticos exceto pelo modo (ROLLBACK vs COMMIT).');
