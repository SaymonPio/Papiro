#!/usr/bin/env node
// Fase 2L — Estatuto do Desarmamento (Lei Federal nº 10.826/2003):
// Correções de explicação jurídica (729, 730) e higiene estrita de OCR (664, 728, 729, 730, 776, 777, 853, 855).
//
// Escopo:
//   - id 729: Correção integral da explicação jurídica (legítima defesa inicial vs. porte ilegal autônomo posterior, art. 14) + correção de palavras coladas por OCR. Gabarito E preservado.
//   - id 730: Complementação da explicação jurídica com o art. 25 da Lei 10.826/2003 (destruição/doação judicial de armas apreendidas) + arts. 158-B, III e 158-D, §1º do CPP + correção de palavras coladas por OCR. Gabarito E preservado.
//   - ids 664, 728, 776, 777, 853, 855: Higiene estrita de resíduos de OCR identificados (enunciado e/ou alternativas). Gabaritos e explicações preservados.
//   - ids 50, 142, 299, 854: NÃO TOCAR.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2l_ed_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2l_ed_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hashes (md5) capturados ao vivo do banco de produção antes desta migração:
const HASH_QUESTAO_ANTES = {
  664: '075e6660fb742b352aedd8fef9c42032',
  728: '228db18935b3b0df616afee08212ac7a',
  729: '41dcb065f8297152fc90108cd53fcb0b',
  730: 'f306a52305a7d9cf939acc512462dd67',
  776: 'f6e243efa22df2cab12216d8f49ed8da',
  777: '176f5f06618698bea8e50dcf5489cb11',
  853: '3555f17b23d8c4cd64f45b8605be729b',
  855: '6f69cbdb21ec3ee43b1768de86c3ff02',
};

const HASH_EXPLICACAO_ANTES = {
  664: '18aaefe4d8e62bad2ae6ad72895dd612',
  728: '5ee73a53e33fe5b7e1d2dcda0efaa0b3',
  729: '144379c14e8afcdd539ebcbd449f9b18',
  730: 'df3f1278634d01d2b749a3c845c0a5bd',
  776: '35c9d395cc1b1e5589bd3f243dd47a9f',
  777: '3f8279d42e6193662e9f4396e8bf0c66',
  853: 'df4ee4cc2e960731ac64da96544c2555',
  855: '0b26e6611f744ba8370c2b08bca90a10',
};

// Textos novos / higienizados:
const ENUNCIADO_NOVO_664 = "Durante cumprimento de mandado de busca domiciliar regularmente expedido, policiais civis localizaram, no interior da residência de Tício, um revólver de uso permitido, com numeração suprimida, desacompanhado de munições. Constatou-se que Tício não possuía registro nem autorização para a arma. Considerando exclusivamente o texto da Lei nº 10.826/2003, assinale a alternativa correta.";
const ALT_NOVAS_664 = {
  3297: "A conduta configura o crime de posse irregular de arma de fogo de uso permitido, previsto no art. 12, uma vez que a arma foi encontrada no interior da residência e não estava municiada.",
  3298: "A ausência de munições impede a tipificação penal, pois o Estatuto do Desarmamento exige, expressamente, que a arma esteja apta ao disparo para caracterização do delito.",
  3299: "A conduta se amolda ao crime previsto no art. 16, em razão da supressão da numeração da arma de fogo, independentemente de se tratar de arma de uso permitido e de estar desacompanhada de munições.",
  3300: "Trata-se de hipótese de porte ilegal de arma de fogo de uso permitido, tipificada no art. 14, pois a adulteração do sinal identificador desloca a conduta para esse dispositivo.",
};

const ENUNCIADO_NOVO_728 = "Um integrante da guarda municipal do Município, possuidor de todas as qualificações, registros e documentos respectivos ao porte e uso de arma de fogo, casado e com dois filhos menores de 18 anos de idade, costumava retornar do seu turno de serviço e deixar sua arma em uma caixa, na sala, próxima ao aparelho de televisão, pronta para uma eventual situação de emergência ou perigo. Ocorre que, enquanto ele dormia, um dos filhos, junto ao irmão mais novo, por curiosidade, resolveu mexer na arma do pai. Ao manuseá-la, acabou disparando e acertando acidentalmente a perna do irmão mais novo, não resultando em óbito. Procedido o atendimento médico necessário e os registros legais, o pai passou a responder pelo fato. Conforme o previsto na Lei nº 10.826/2003, que dispõe sobre o Sistema Nacional de Armas, qual foi o crime cometido pelo pai das crianças?";

const ENUNCIADO_NOVO_729 = "Indivíduo A, em situação de grave ameaça à sua integridade física, saca da cintura de um segurança de centro comercial uma arma de fogo de calibre permitido e municiada. A intenção era defender-se da agressão iminente e que era oferecida, também, com o emprego de arma de fogo. Inicia-se um tiroteio, sendo que tanto agressor como o indivíduo A escapam dos disparos e correm, um para cada lado, cessando a situação de perigo. A decide manter a arma em seu poder, transportando-a habitualmente por período de dois meses até ser abordado pela polícia carregando-a na cintura. Considerando as disposições do Estatuto do Desarmamento (Lei nº 10.826/2003) e as causas de exclusão da ilicitude, assinale a alternativa correta sobre a situação descrita.";
const ALT_NOVAS_729 = {
  3622: "O agente não pratica crime algum, pois a subtração da arma ocorreu em estado de necessidade para proteção da própria vida, e a manutenção posterior da posse enquadra-se na mesma excludente, caracterizando ato único indivisível.",
  3623: "O agente pratica apenas o crime de posse irregular de arma de fogo, respondendo pelo art. 12 da Lei nº 10.826/2003, tendo em vista que a subtração da arma ocorreu acobertada por estado de necessidade, mas a manutenção posterior da posse não se justifica pela mesma excludente.",
  3624: "O agente pratica os crimes de furto de arma de fogo (art. 155, § 4º-A do CP) em concurso material com posse irregular de arma de fogo (art. 12 da Lei nº 10.826/2003), pois a excludente de ilicitude não alcança crimes patrimoniais.",
  3626: "O agente não responde pela subtração da arma ou pelos disparos feitos em legítima defesa, condutas penalmente justificáveis. No entanto, responderá pelo porte ilegal da arma de fogo de uso permitido, nos termos do art. 14 da Lei nº 10.826/2003.",
};
const EXPLICACAO_NOVA_729 = "GABARITO: alternativa E\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\r\nA conduta inicial do agente — sacar a arma do segurança e efetuar disparos para repelir agressão armada injusta e iminente à sua vida — está amparada pela excludente de ilicitude da legítima defesa (art. 23, II c/c art. 25 do Código Penal), afastando a ilicitude dos atos praticados no contexto da legítima defesa.\r\nContudo, cessada a situação de perigo, a manutenção e o transporte habitual da arma de fogo de uso permitido na cintura por dois meses, sem autorização legal ou regulamentar, configura conduta autônoma e dolosa, não mais albergada pela excludente, amoldando-se ao crime de porte ilegal de arma de fogo de uso permitido (art. 14 da Lei nº 10.826/2003).\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r\nA excludente da legítima defesa cobre apenas os atos necessários e contemporâneos à repulsa da agressão injusta. A retenção e o transporte da arma por dois meses após cessado o perigo não se comunicam à excludente inicial.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nO transporte de arma de fogo na cintura, em via pública, configura porte ilegal (art. 14), e não posse irregular (art. 12, restrita ao interior da residência ou local de trabalho).\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nO apoderamento momentâneo da arma ocorreu no contexto da reação defensiva contra agressão injusta e iminente, estando abrangido pela legítima defesa. O problema jurídico surge depois, quando, cessada a situação de perigo, o agente mantém e porta a arma sem autorização.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nA conduta posterior de portar arma em via pública por dois meses é autônoma em relação ao momento defensivo inicial, não se tratando de mera consunção de condutas.\r\n\r\nBIZU DE PROVA:\r\nA excludente de ilicitude (legítima defesa) cessa no momento em que termina a situação de perigo/agressão. Manter a arma e circular com ela na cintura após o encerramento da emergência configura porte ilegal de arma de fogo de uso permitido (art. 14 da Lei 10.826/2003).";

const ENUNCIADO_NOVO_730 = "A Polícia Civil, ao comparecer a um local de homicídio, localiza uma arma de fogo com a numeração suprimida, próxima ao corpo da vítima. Assim, após os atos iniciais de investigação criminal, a arma de fogo é apreendida. Levando em consideração as previsões do Código de Processo Penal em relação à cadeia de custódia e, em relação ao destino final da arma de fogo, a Lei nº 10.826/2003 (Estatuto do Desarmamento), é correto afirmar que";
const ALT_NOVAS_730 = {
  3627: "não existe previsão legal que determine a descrição exata da arma de fogo no local do crime ou o seu acondicionamento em recipiente. A autoridade policial, após o exame pericial, providenciará a destruição da arma de fogo na própria Delegacia de Polícia.",
  3628: "deve ser descrito o local em que a arma de fogo estava e a sua posição, mas o vestígio não precisa ser acondicionado em recipiente lacrado. A arma de fogo somente pode ser destinada para destruição quando houver autorização judicial, independentemente de ter sido periciada.",
  3629: "deve ser descrito o local em que a arma de fogo estava e a sua posição, devendo o vestígio ser acondicionado em recipiente lacrado. A autoridade policial, após o exame pericial, providenciará a destruição da arma de fogo na própria Delegacia de Polícia.",
  3630: "não existe previsão legal que determine a descrição exata da arma de fogo no local do crime ou o seu acondicionamento em recipiente. A arma de fogo, se não interessar mais à persecução penal e se já houver sido periciada, poderá ser, após análise do juiz competente, destruída ou doada a órgãos de segurança pública.",
  3631: "deve ser descrito o local em que a arma de fogo estava e a sua posição, devendo o vestígio ser acondicionado em recipiente lacrado. A arma de fogo, se não interessar mais à persecução penal e se já houver sido periciada, poderá ser, após análise do juiz competente, destruída ou doada a órgãos de segurança pública.",
};
const EXPLICACAO_NOVA_730 = "GABARITO: alternativa E\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ CORRETA:\r\nA alternativa está correta e reúne dois procedimentos legais relevantes:\r\n1. Cadeia de Custódia (CPP): No local do crime, a etapa de fixação exige a descrição detalhada do vestígio e de sua posição exata na área de exames (art. 158-B, III do CPP), devendo o vestígio coletado ser embalado e acondicionado em recipiente selado com lacre numerado individualizado (art. 158-D, §1º do CPP), garantindo a integridade e idoneidade pericial.\r\n2. Destinação da Arma Apreendida (Lei nº 10.826/2003): Nos termos do art. 25, caput, do Estatuto do Desarmamento, as armas de fogo apreendidas, após elaboração do laudo pericial e juntada aos autos, quando não mais interessarem à persecução penal, serão encaminhadas pelo juiz competente ao Comando do Exército para destruição ou doação aos órgãos de segurança pública ou às Forças Armadas.\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r\nExiste expressa previsão legal de fixação e acondicionamento em recipiente lacrado (arts. 158-B e 158-D do CPP). Além disso, a autoridade policial não pode destruir a arma na delegacia.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\nO vestígio exige obrigatoriamente acondicionamento em recipiente selado com lacre (art. 158-D, §1º do CPP). Ademais, a destinação para destruição ou doação depende de prévia perícia oficial e desinteresse para a persecução (art. 25 da Lei 10.826/2003).\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r\nA autoridade policial não tem competência para providenciar a destruição da arma na delegacia — a destinação é atribuição judicial com encaminhamento ao Comando do Exército (art. 25 da Lei 10.826/2003).\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\nHá expressa previsão legal impondo a descrição do local/posição do vestígio e seu acondicionamento em recipiente lacrado (arts. 158-B e 158-D do CPP).\r\n\r\nBIZU DE PROVA:\r\nArma apreendida em local de crime:\r\n1. Cadeia de custódia (CPP, arts. 158-B, III e 158-D, §1º): Fixar posição exata e acondicionar em recipiente selado com lacre de numeração individualizada.\r\n2. Destino final (Lei 10.826/2003, art. 25): Periciada e sem interesse à persecução -> Juiz competente encaminha ao Exército para DESTRUIÇÃO ou DOAÇÃO a órgãos de segurança/Forças Armadas (nunca destruída na delegacia).";

const ENUNCIADO_NOVO_776 = "A Lei nº 10.826/2003 instituiu o Sistema Nacional de Armas (Sinarm) no Ministério da Justiça, que tem circunscrição em todo o território nacional. Segundo a referida Lei, a qual órgão compete cadastrar as transferências de propriedade, extravio, furto, roubo e outras ocorrências suscetíveis de alterar os dados cadastrais, inclusive as decorrentes de fechamento de empresas de segurança privada e de transporte de valores?";

const ENUNCIADO_NOVO_777 = "A Lei nº 10.826/2003 dispõe sobre o registro, a posse e a comercialização de armas de fogo e munição. Segundo a referida Lei, a qual órgão compete cadastrar as autorizações de porte de arma de fogo e as renovações expedidas pela Polícia Federal?";

const ENUNCIADO_NOVO_853 = "A Lei Federal nº 10.826/2003 dispõe sobre registro, posse e comercialização de armas de fogo e munição, sobre o Sistema Nacional de Armas – SINARM, define crimes e determina ser obrigatório o registro de arma de fogo no órgão competente, além de estipular que as armas de fogo de uso restrito serão registradas no(a) ____________________, na forma do regulamento desta Lei. Assinale a alternativa que preenche corretamente a lacuna do trecho acima.";

const ENUNCIADO_NOVO_855 = "Genésio, integrante do quadro efetivo de agente prisional, recebeu voz de prisão em flagrante, ao ser surpreendido portando uma arma de fogo de uso permitido com munição sobressalente. Ao chegar à Delegacia, foi constatado que a arma se encontrava com a numeração de série adulterada, fato sabido por Genésio. Com base no Estatuto do Desarmamento e no caso narrado, Genésio deverá responder por porte ilegal de arma de fogo de uso:";

function body(mode) {
  return `-- ============================================================================
-- FASE 2L — ESTATUTO DO DESARMAMENTO: CORREÇÕES JURÍDICAS E HIGIENE DE OCR
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- Escopo:
--   - id 729: Correção integral da explicação jurídica (legítima defesa inicial vs. porte ilegal autônomo posterior, art. 14) + correção de palavras coladas por OCR. Gabarito E preservado.
--   - id 730: Complementação da explicação jurídica com o art. 25 da Lei 10.826/2003 (destruição/doação judicial de armas apreendidas) + arts. 158-B, III e 158-D, §1º do CPP + correção de palavras coladas por OCR. Gabarito E preservado.
--   - ids 664, 728, 776, 777, 853, 855: Higiene estrita de resíduos de OCR identificados (enunciado e/ou alternativas). Gabaritos e explicações preservados.
--   - ids 50, 142, 299, 854: NÃO TOCAR.
--
-- Garantias e Precondições:
--   - Validação de integridade via MD5 ao vivo antes de qualquer escrita;
--   - GET DIAGNOSTICS checando linhas afetadas em cada UPDATE;
--   - Snapshot antes/depois e asserts comparando JSONB byte-a-byte;
--   - Gabaritos e integridade estrutural das alternativas 100% preservados;
--   - Total global de questões = 915 inalterado;
--   - Total de ativas = 908 inalterado;
--   - Todas as 8 questões continuam com ativa = true.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. SNAPSHOT ANTES
-- ----------------------------------------------------------------------------
create temporary table _f2l_snap_questoes on commit drop as
select id, ativa,
  (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') as dados_imutaveis_geral,
  (to_jsonb(q) - 'enunciado' - 'atualizado_em') as dados_imutaveis_ocr_puro,
  (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') as dados_imutaveis_729_730
from public.questoes q
where q.id in (664, 728, 729, 730, 776, 777, 853, 855);

create temporary table _f2l_snap_alt on commit drop as
select id, questao_id, ordem, correta, (to_jsonb(a) - 'texto') as dados_imutaveis_alt
from public.alternativas a
where a.questao_id in (664, 728, 729, 730, 776, 777, 853, 855);

create temporary table _f2l_snap_global on commit drop as
select
  (select count(*) from public.questoes) as total_questoes_antes,
  (select count(*) from public.questoes where ativa = true) as total_ativas_antes;

create temporary table _f2l_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- 2. PRECONDIÇÕES DE INTEGRIDADE
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from public.questoes where id = 664 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[664])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[664])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 664 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 728 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[728])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[728])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 728 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 729 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[729])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[729])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 729 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 730 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[730])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[730])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 730 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 776 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[776])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[776])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 776 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 777 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[777])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[777])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 777 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 853 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[853])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[853])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 853 nao esta no estado esperado';
  end if;

  if not exists (
    select 1 from public.questoes where id = 855 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = ${sqlStr(HASH_QUESTAO_ANTES[855])}
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[855])}
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 855 nao esta no estado esperado';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 3. ESCRITAS CONTROLADAS
-- ----------------------------------------------------------------------------

-- ID 664: Enunciado e Alternativas (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_664)}, atualizado_em = now() where id = 664;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 664 (enunciado) afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_664[3297])} where id = 3297 and questao_id = 664;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3297 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_664[3298])} where id = 3298 and questao_id = 664;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3298 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_664[3299])} where id = 3299 and questao_id = 664;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3299 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_664[3300])} where id = 3300 and questao_id = 664;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3300 afetou % linhas', v_linhas; end if;
end $$;

-- ID 728: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_728)}, atualizado_em = now() where id = 728;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 728 (enunciado) afetou % linhas', v_linhas; end if;
end $$;

-- ID 729: Enunciado, Explicação e Alternativas (Correção Jurídica + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_729)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_729)}, atualizado_em = now()
  where id = 729;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 729 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_729[3622])} where id = 3622 and questao_id = 729;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3622 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_729[3623])} where id = 3623 and questao_id = 729;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3623 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_729[3624])} where id = 3624 and questao_id = 729;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3624 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_729[3626])} where id = 3626 and questao_id = 729;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3626 afetou % linhas', v_linhas; end if;
end $$;

-- ID 730: Enunciado, Explicação e Alternativas (Correção Jurídica + OCR)
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = ${sqlStr(ENUNCIADO_NOVO_730)}, explicacao = ${sqlStr(EXPLICACAO_NOVA_730)}, atualizado_em = now()
  where id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 730 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_730[3627])} where id = 3627 and questao_id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3627 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_730[3628])} where id = 3628 and questao_id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3628 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_730[3629])} where id = 3629 and questao_id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3629 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_730[3630])} where id = 3630 and questao_id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3630 afetou % linhas', v_linhas; end if;

  update public.alternativas set texto = ${sqlStr(ALT_NOVAS_730[3631])} where id = 3631 and questao_id = 730;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE alternativa 3631 afetou % linhas', v_linhas; end if;
end $$;

-- ID 776: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_776)}, atualizado_em = now() where id = 776;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 776 (enunciado) afetou % linhas', v_linhas; end if;
end $$;

-- ID 777: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_777)}, atualizado_em = now() where id = 777;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 777 (enunciado) afetou % linhas', v_linhas; end if;
end $$;

-- ID 853: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_853)}, atualizado_em = now() where id = 853;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 853 (enunciado) afetou % linhas', v_linhas; end if;
end $$;

-- ID 855: Enunciado (OCR)
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = ${sqlStr(ENUNCIADO_NOVO_855)}, atualizado_em = now() where id = 855;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'UPDATE 855 (enunciado) afetou % linhas', v_linhas; end if;
end $$;

-- ----------------------------------------------------------------------------
-- 4. ASSERTS PÓS-ESCRITA
-- ----------------------------------------------------------------------------
do $$
begin
  -- Assert 1: Total geral de questões permanece exatamente 915 e inalterado
  insert into _f2l_asserts (descricao, ok)
  select 'total_questoes permanece exatamente 915',
    (select count(*) from public.questoes) = 915
    and (select count(*) from public.questoes) = (select total_questoes_antes from _f2l_snap_global);

  -- Assert 2: Total global de ativas permanece exatamente 908
  insert into _f2l_asserts (descricao, ok)
  select 'total_ativas permanece exatamente 908',
    (select count(*) from public.questoes where ativa = true) = 908
    and (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes from _f2l_snap_global);

  -- Assert 3: Todas as 8 questões continuam com ativa = true
  insert into _f2l_asserts (descricao, ok)
  select 'todas as 8 questoes continuam ativa = true',
    (select count(*) from public.questoes where id in (664, 728, 729, 730, 776, 777, 853, 855) and ativa = true) = 8;

  -- Assert 4: IDs com OCR puro (664, 728, 776, 777, 853, 855) — nenhuma coluna além de enunciado e atualizado_em mudou
  insert into _f2l_asserts (descricao, ok)
  select 'OCR puro: apenas enunciado/atualizado_em mudaram em questoes (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2l_snap_questoes s on s.id = q.id
      where q.id in (664, 728, 776, 777, 853, 855)
        and (to_jsonb(q) - 'enunciado' - 'atualizado_em') <> s.dados_imutaveis_ocr_puro
    );

  -- Assert 5: 729 e 730 — nenhuma coluna além de enunciado, explicacao e atualizado_em mudou
  insert into _f2l_asserts (descricao, ok)
  select '729 e 730: apenas enunciado, explicacao e atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2l_snap_questoes s on s.id = q.id
      where q.id in (729, 730)
        and (to_jsonb(q) - 'enunciado' - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis_729_730
    );

  -- Assert 6: Alternativas — gabaritos (ordem, correta, ids) 100% preservados
  insert into _f2l_asserts (descricao, ok)
  select 'alternativas: metadados, ordem e gabarito (correta) permanecem byte-identicos',
    not exists (
      select 1 from public.alternativas a
      join _f2l_snap_alt s on s.id = a.id
      where (to_jsonb(a) - 'texto') <> s.dados_imutaveis_alt
    );

  -- Assert 7: Correção jurídica 729 — nova explicação aplicada, sem citação de furto de proprietário
  insert into _f2l_asserts (descricao, ok)
  select '729: explicacao atualizada com legitima defesa e porte ilegal autonomo art. 14, sem mencao a proprietario vitima de furto',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 729)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_729)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao not like '%vítima de furto ou roubo perpetrado por terceiro%' from public.questoes where id = 729)
    and (select explicacao like '%legítima defesa%' and explicacao like '%art. 14%' from public.questoes where id = 729);

  -- Assert 8: Correção jurídica 730 — nova explicação aplicada, contendo art. 25 Lei 10.826 e arts. 158-B/D CPP
  insert into _f2l_asserts (descricao, ok)
  select '730: explicacao atualizada contendo art. 25 Lei 10.826/03 e arts. 158-B/D CPP',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 730)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_730)}, E'\\r\\n', E'\\n', 'g')
    and (select explicacao like '%art. 25%' and explicacao like '%158-B%' and explicacao like '%Comando do Exército%' from public.questoes where id = 730);

  -- Assert 9: Higiene de OCR — verificação de ausência de palavras coladas
  insert into _f2l_asserts (descricao, ok)
  select 'OCR 664: sem palavras coladas no enunciado e alternativas',
    (select enunciado not like '%usopermitido%' and enunciado not like '%Considerandoexclusivamente%' from public.questoes where id = 664)
    and (select texto not like '%daresidência%' from public.alternativas where id = 3297)
    and (select texto not like '%paracaracterização%' from public.alternativas where id = 3298)
    and (select texto not like '%usopermitido%' from public.alternativas where id = 3299)
    and (select texto not like '%essedispositivo%' from public.alternativas where id = 3300);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 728: sem palavras coladas no enunciado',
    (select enunciado not like '%ecom%' and enunciado not like '%televisão,pronta%' and enunciado not like '%mexerna%' and enunciado not like '%médiconecessário%' and enunciado not like '%foio%' from public.questoes where id = 728);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 729: sem palavras coladas no enunciado e alternativas',
    (select enunciado not like '%emuniciada%' and enunciado not like '%tantoagressor%' and enunciado not like '%transportando-ahabitualmente%' and enunciado not like '%nº10.826/2003%' from public.questoes where id = 729)
    and (select texto not like '%daposse%' from public.alternativas where id = 3622)
    and (select texto not like '%armaocorreu%' from public.alternativas where id = 3623)
    and (select texto not like '%nº10.826/2003%' from public.alternativas where id = 3624)
    and (select texto not like '%peloporte%' from public.alternativas where id = 3626);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 730: sem palavras coladas no enunciado e alternativas',
    (select enunciado not like '%atosiniciais%' and enunciado not like '%e,em%' from public.questoes where id = 730)
    and (select texto not like '%policial,após%' from public.alternativas where id = 3627)
    and (select texto not like '%fogosomente%' from public.alternativas where id = 3628)
    and (select texto not like '%apóso%' from public.alternativas where id = 3629)
    and (select texto not like '%nãointeressar%' from public.alternativas where id = 3630)
    and (select texto not like '%nãointeressar%' from public.alternativas where id = 3631);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 776: sem palavras coladas no enunciado',
    (select enunciado not like '%Segundo areferida%' and enunciado not like '%cadastrais,inclusive%' from public.questoes where id = 776);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 777: sem palavras coladas no enunciado',
    (select enunciado not like '%asautorizações%' from public.questoes where id = 777);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 853: sem palavras coladas no enunciado',
    (select enunciado not like '%definecrimes%' from public.questoes where id = 853);

  insert into _f2l_asserts (descricao, ok)
  select 'OCR 855: sem palavras coladas no enunciado',
    (select enunciado not like '%permitidocom%' and enunciado not like '%baseno%' from public.questoes where id = 855);
end $$;

-- ----------------------------------------------------------------------------
-- 5. VALIDAÇÃO DOS ASSERTS
-- ----------------------------------------------------------------------------
do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2l_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2L (Estatuto do Desarmamento) falhou: nem todos os asserts passaram (ver RESUMO acima).';
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
