-- ============================================================================
-- FASE 2K — LEI MARIA DA PENHA: RECONCILIAÇÃO FINAL (6 QUESTÕES)
-- APLICAÇÃO REAL — TERMINA EM COMMIT.
-- ============================================================================
--
-- Ações por questão:
--   - id 344:  Reativar (ativa = true). Nenhum outro campo muda.
--   - id 1346: Reativar (ativa = true). Nenhum outro campo muda.
--   - id 1335: Reativar (ativa = true) e atualizar explicação (Súmula 676/STJ).
--              Preserva gabarito C, enunciado, alternativas e metadados.
--   - id 1358: Manter ativa = true. Corrigir "art. 12-B" -> "art. 12-C" na explicação.
--   - id 1359: Manter ativa = true. Corrigir as 2 ocorrências "$" -> "§" no enunciado.
--   - id 1363: Manter ativa = true. Atualizar explicação (Súmula 676/STJ).
--
-- Garantias e Precondições:
--   - Validação de integridade via MD5 ao vivo antes de qualquer escrita;
--   - GET DIAGNOSTICS checando linhas afetadas em cada UPDATE;
--   - Snapshot antes/depois e asserts comparando JSONB byte-a-byte;
--   - Alternativas e gabaritos de todas as 6 questões 100% inalterados;
--   - Total global de questões = 915 inalterado;
--   - Total de ativas aumenta exatamente em 3 (344, 1335, 1346 reativadas);
--   - Todas as 6 questões finalizam com ativa = true.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- 1. SNAPSHOT ANTES
-- ----------------------------------------------------------------------------
create temporary table _f2k_rec_snap_344_1346 on commit drop as
select id, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (344, 1346);

create temporary table _f2k_rec_snap_1335 on commit drop as
select id, (to_jsonb(q) - 'ativa' - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id = 1335;

create temporary table _f2k_rec_snap_1358_1363 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (1358, 1363);

create temporary table _f2k_rec_snap_1359 on commit drop as
select id, (to_jsonb(q) - 'enunciado' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id = 1359;

create temporary table _f2k_rec_snap_alt on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (344, 1335, 1346, 1358, 1359, 1363)
group by questao_id;

create temporary table _f2k_rec_snap_global on commit drop as
select
  (select count(*) from public.questoes) as total_questoes_antes,
  (select count(*) from public.questoes where ativa = true) as total_ativas_antes;

create temporary table _f2k_rec_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- 2. PRECONDIÇÕES DE INTEGRIDADE
-- ----------------------------------------------------------------------------
do $$
begin
  -- 344: ativa = false
  if not exists (
    select 1 from public.questoes where id = 344 and ativa = false
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '4fa48a5d5ee08dd83eafcf4b3c421ebf'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = '06ee268854e60f668d91db65dcac9630'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 344 nao esta no estado auditado';
  end if;

  -- 1335: ativa = false
  if not exists (
    select 1 from public.questoes where id = 1335 and ativa = false
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '277ca5d96ef154ffb3b8ccfc747bfca4'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = '4bd09b5db310002b989b434f348210c8'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 1335 nao esta no estado auditado';
  end if;

  -- 1346: ativa = false
  if not exists (
    select 1 from public.questoes where id = 1346 and ativa = false
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = 'fede545a6ec226055ad5fe33214a4889'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = '8eebc8988f8de6d791a61e5e1e50fc72'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 1346 nao esta no estado auditado';
  end if;

  -- 1358: ativa = true
  if not exists (
    select 1 from public.questoes where id = 1358 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '67661051124754663ffcc6cf9a05da00'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = 'f16baff34eb4deed3011be7c8929d32e'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 1358 nao esta no estado auditado';
  end if;

  -- 1359: ativa = true
  if not exists (
    select 1 from public.questoes where id = 1359 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = 'd312fc26281d982e30d1d1a136f36f35'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = 'd4386863a4f23b64578012141908db05'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 1359 nao esta no estado auditado';
  end if;

  -- 1363: ativa = true
  if not exists (
    select 1 from public.questoes where id = 1363 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '2c34fb54b13d49de3d92597ee1626971'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = '907f7b97775d24633b66c637ca6cc379'
  ) then
    raise exception 'PRECONDICAO FALHOU: questao 1363 nao esta no estado auditado';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 3. ESCRITAS CONTROLADAS
-- ----------------------------------------------------------------------------

-- Escrita 1: Reativação pura de 344 e 1346
do $$
declare v_linhas int;
begin
  update public.questoes
  set ativa = true, atualizado_em = now()
  where id in (344, 1346);
  get diagnostics v_linhas = row_count;
  if v_linhas <> 2 then
    raise exception 'ESCRITA 1 FALHOU: esperado UPDATE de exatamente 2 linhas (344, 1346), afetou %', v_linhas;
  end if;
end $$;

-- Escrita 2: Reativação e atualização de explicação de 1335
do $$
declare v_linhas int;
begin
  update public.questoes
  set ativa = true, explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A destruição de instrumentos de trabalho da esposa configura violência patrimonial (art. 7º, IV). Diante disso, há hipótese de admissibilidade da prisão preventiva do agressor nos termos do art. 20 da Lei Maria da Penha, cuja redação literal prevê que caberá a prisão preventiva decretada pelo juiz, de ofício, a requerimento do Ministério Público ou mediante representação da autoridade policial.
Ressalva importante para a jurisprudência atual: com a Lei 13.964/2019 (Pacote Anticrime) e a edição da Súmula 676 do STJ ("Em razão da Lei n. 13.964/2019, não é mais possível ao juiz, de ofício, decretar ou converter prisão em flagrante em prisão preventiva"), consolidou-se a vedação à decretação de preventiva de ofício pelo magistrado. Contudo, para fins desta questão de concurso (que cobrou a literalidade do texto legal do art. 20), a alternativa C reflete o gabarito oficial da banca.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou outras de prestação pecuniária.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O ambiente familiar não afasta a aplicação da Lei — a comunidade familiar é expressamente um dos âmbitos de incidência da violência doméstica e familiar (art. 5º, II).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A violência patrimonial está expressamente prevista no art. 7º, IV — a Lei não se limita a agressões físicas, psicológicas ou morais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 21, parágrafo único, veda expressamente a entrega de intimação ou notificação pela própria ofendida ao agressor.

BIZU DE PROVA:
Destruir instrumentos de trabalho é hipótese clássica de violência patrimonial (art. 7º, IV). Para provas literais, atenção ao texto do art. 20 da LMP; para provas de jurisprudência/processo penal, lembre-se da Súmula 676 do STJ: prisão preventiva não pode ser decretada de ofício pelo juiz; exige provocação de legitimado, nos termos da legislação processual aplicável.', atualizado_em = now()
  where id = 1335;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 2 FALHOU: esperado UPDATE de exatamente 1 linha (1335), afetou %', v_linhas;
  end if;
end $$;

-- Escrita 3: Correção de explicação de 1358 ("art. 12-B" -> "art. 12-C")
do $$
declare v_linhas int;
begin
  update public.questoes
  set explicacao = 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As três assertivas estão corretas. I: o art. 12-C autoriza a autoridade policial a afastar provisoriamente o agressor do lar, mesmo sem autorização judicial prévia, em casos excepcionais de risco. II: o art. 42 da Lei alterou o art. 313 do CPP para admitir a prisão preventiva quando o crime envolver violência doméstica e familiar, para garantir a execução das medidas protetivas. III: as medidas protetivas de urgência têm natureza autônoma e podem ser concedidas independentemente de inquérito, ação penal ou cível já formalizados — o que já se viu, por exemplo, na questão sobre concessão de medida protetiva sem processo criminal em andamento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera corretas apenas a I, quando as três estão corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera correta apenas a II, quando as três estão corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera correta apenas a III, quando as três estão corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera corretas a I e a II, mas exclui a III, que também está correta.

BIZU DE PROVA:
As medidas protetivas de urgência são um mecanismo autônomo e urgente — não dependem de inquérito, ação penal ou boletim de ocorrência já formalizados para serem concedidas.', atualizado_em = now()
  where id = 1358;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 3 FALHOU: esperado UPDATE de exatamente 1 linha (1358), afetou %', v_linhas;
  end if;
end $$;

-- Escrita 4: Higiene de dado no enunciado de 1359 ("$" -> "§")
do $$
declare v_linhas int;
begin
  update public.questoes
  set enunciado = '(PMLM/URCA 2025) A lei Nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da constituição federal, da convenção sobre a eliminação de todas as formas de discriminação contra as mulheres e da convenção interamericana para prevenir, punir e erradicar a violência contra a mulher; dispõe sobre a criação dos juizados de violência doméstica e familiar contra a mulher; altera os decretos-lei Nº 3.689, de 3 de outubro de 1941 (código de processo penal), e 2.848, de 7 de dezembro de 1940 (código penal), e a lei Nº 7.210, de 11 de julho de 1984 (lei de execução penal); e dá outras providências (lei maria da penha). o capítulo III - que trata do atendimento pela autoridade policial, em seu Art. 10-a. coloca que: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores - preferencialmente do sexo feminino - previamente capacitados. (incluído pela lei nº 13.505, de 2017) em seu § 1º a inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá diretrizes, assinale abaixo, a alternativa correta:', atualizado_em = now()
  where id = 1359;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 4 FALHOU: esperado UPDATE de exatamente 1 linha (1359), afetou %', v_linhas;
  end if;
end $$;

-- Escrita 5: Correção de explicação de 1363 (Súmula 676/STJ)
do $$
declare v_linhas int;
begin
  update public.questoes
  set explicacao = 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO, ao tomar conhecimento da iminência ou prática de violência doméstica — não existe, para essa hipótese, um prazo de "até 48 horas" como a alternativa inventa (o prazo de 48 horas da Lei está associado a outra situação: a remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira quanto à literalidade do art. 20, não a exceção pedida):
Reproduz o texto literal do art. 20 da Lei Maria da Penha sobre a prisão preventiva do agressor. Ressalva jurisprudencial relevante: nos termos da Súmula 676 do STJ ("Em razão da Lei n. 13.964/2019, não é mais possível ao juiz, de ofício, decretar ou converter prisão em flagrante em prisão preventiva"), o magistrado não pode mais decretar prisão preventiva sem provocação prévia, em decorrência do sistema acusatório reforçado pelo Pacote Anticrime. Embora o texto legal do art. 20 não tenha sido formalmente reformado pelo legislador, a alternativa A foi corretamente considerada verdadeira pela banca por reproduzir a literalidade do dispositivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 4º sobre a interpretação da Lei considerando os fins sociais e as condições peculiares das mulheres em situação de violência doméstica e familiar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz literalmente o art. 9º, §1º, sobre a inclusão da mulher em programas assistenciais por prazo certo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz literalmente o art. 6º, que dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
"De imediato" (art. 10) é diferente de "em até 48 horas" (art. 12, III) — são dispositivos e momentos distintos. Lembre-se: em provas de literalidade, o art. 20 da LMP traz a redação original com "de ofício", mas no campo jurisprudencial aplica-se a Súmula 676 do STJ (vedação ao de ofício).', atualizado_em = now()
  where id = 1363;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 5 FALHOU: esperado UPDATE de exatamente 1 linha (1363), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 4. ASSERTS PÓS-ESCRITA
-- ----------------------------------------------------------------------------
do $$
begin
  -- Assert 1: Total geral de questões permanece exatamente 915 e inalterado
  insert into _f2k_rec_asserts (descricao, ok)
  select 'total_questoes permanece exatamente 915 e inalterado',
    (select count(*) from public.questoes) = 915
    and (select count(*) from public.questoes) = (select total_questoes_antes from _f2k_rec_snap_global);

  -- Assert 2: Total global de ativas subiu exatamente em 3
  insert into _f2k_rec_asserts (descricao, ok)
  select 'total_ativas aumentou exatamente em 3 (344, 1335, 1346 reativadas)',
    (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes + 3 from _f2k_rec_snap_global);

  -- Assert 3: Todas as 6 questões estão com ativa = true
  insert into _f2k_rec_asserts (descricao, ok)
  select 'todas as 6 questoes (344, 1335, 1346, 1358, 1359, 1363) estao com ativa = true',
    (select count(*) from public.questoes where id in (344, 1335, 1346, 1358, 1359, 1363) and ativa = true) = 6;

  -- Assert 4: 344 e 1346 — nenhuma coluna além de ativa e atualizado_em mudou (jsonb byte-a-byte)
  insert into _f2k_rec_asserts (descricao, ok)
  select '344 e 1346: apenas ativa/atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2k_rec_snap_344_1346 s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'atualizado_em') <> s.dados_imutaveis
    );

  -- Assert 5: 1335 — nenhuma coluna além de ativa, explicacao e atualizado_em mudou (jsonb byte-a-byte)
  insert into _f2k_rec_asserts (descricao, ok)
  select '1335: apenas ativa, explicacao e atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2k_rec_snap_1335 s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  -- Assert 6: 1358 e 1363 — nenhuma coluna além de explicacao e atualizado_em mudou (jsonb byte-a-byte)
  insert into _f2k_rec_asserts (descricao, ok)
  select '1358 e 1363: apenas explicacao e atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2k_rec_snap_1358_1363 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  -- Assert 7: 1359 — nenhuma coluna além de enunciado e atualizado_em mudou (jsonb byte-a-byte)
  insert into _f2k_rec_asserts (descricao, ok)
  select '1359: apenas enunciado e atualizado_em mudaram (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q
      join _f2k_rec_snap_1359 s on s.id = q.id
      where (to_jsonb(q) - 'enunciado' - 'atualizado_em') <> s.dados_imutaveis
    );

  -- Assert 8: Alternativas e gabaritos das 6 questões permanecem 100% byte-idênticos
  insert into _f2k_rec_asserts (descricao, ok)
  select 'alternativas/gabaritos das 6 questoes permanecem byte-identicos',
    not exists (
      select 1 from _f2k_rec_snap_alt s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (344, 1335, 1346, 1358, 1359, 1363)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  -- Assert 9: 1358 — contém "art. 12-C" no ponto corrigido e não contém mais "art. 12-B"
  insert into _f2k_rec_asserts (descricao, ok)
  select '1358: explicacao contem "art. 12-C" e nao contem mais "art. 12-B"',
    (select regexp_replace(explicacao, E'\r\n', E'\n', 'g') from public.questoes where id = 1358)
    = regexp_replace('GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As três assertivas estão corretas. I: o art. 12-C autoriza a autoridade policial a afastar provisoriamente o agressor do lar, mesmo sem autorização judicial prévia, em casos excepcionais de risco. II: o art. 42 da Lei alterou o art. 313 do CPP para admitir a prisão preventiva quando o crime envolver violência doméstica e familiar, para garantir a execução das medidas protetivas. III: as medidas protetivas de urgência têm natureza autônoma e podem ser concedidas independentemente de inquérito, ação penal ou cível já formalizados — o que já se viu, por exemplo, na questão sobre concessão de medida protetiva sem processo criminal em andamento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera corretas apenas a I, quando as três estão corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera correta apenas a II, quando as três estão corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera correta apenas a III, quando as três estão corretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera corretas a I e a II, mas exclui a III, que também está correta.

BIZU DE PROVA:
As medidas protetivas de urgência são um mecanismo autônomo e urgente — não dependem de inquérito, ação penal ou boletim de ocorrência já formalizados para serem concedidas.', E'\r\n', E'\n', 'g')
    and (select explicacao not like '%art. 12-B%' from public.questoes where id = 1358)
    and (select explicacao like '%art. 12-C%' from public.questoes where id = 1358);

  -- Assert 10: 1359 — não contém mais "$ 8º" nem "$ 1º" e contém "§ 8º" e "§ 1º"
  insert into _f2k_rec_asserts (descricao, ok)
  select '1359: enunciado nao contem mais "$" e contem "§ 8º" e "§ 1º"',
    (select enunciado from public.questoes where id = 1359) = '(PMLM/URCA 2025) A lei Nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da constituição federal, da convenção sobre a eliminação de todas as formas de discriminação contra as mulheres e da convenção interamericana para prevenir, punir e erradicar a violência contra a mulher; dispõe sobre a criação dos juizados de violência doméstica e familiar contra a mulher; altera os decretos-lei Nº 3.689, de 3 de outubro de 1941 (código de processo penal), e 2.848, de 7 de dezembro de 1940 (código penal), e a lei Nº 7.210, de 11 de julho de 1984 (lei de execução penal); e dá outras providências (lei maria da penha). o capítulo III - que trata do atendimento pela autoridade policial, em seu Art. 10-a. coloca que: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores - preferencialmente do sexo feminino - previamente capacitados. (incluído pela lei nº 13.505, de 2017) em seu § 1º a inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá diretrizes, assinale abaixo, a alternativa correta:'
    and (select enunciado not like '%$%' from public.questoes where id = 1359)
    and (select enunciado like '%§ 8º%' from public.questoes where id = 1359)
    and (select enunciado like '%§ 1º%' from public.questoes where id = 1359);

  -- Assert 11: 1335 — contém referência à Súmula 676 do STJ e texto exato de BIZU aprovado
  insert into _f2k_rec_asserts (descricao, ok)
  select '1335: explicacao contem Sumula 676 do STJ e texto exato ajustado',
    (select regexp_replace(explicacao, E'\r\n', E'\n', 'g') from public.questoes where id = 1335)
    = regexp_replace('GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A destruição de instrumentos de trabalho da esposa configura violência patrimonial (art. 7º, IV). Diante disso, há hipótese de admissibilidade da prisão preventiva do agressor nos termos do art. 20 da Lei Maria da Penha, cuja redação literal prevê que caberá a prisão preventiva decretada pelo juiz, de ofício, a requerimento do Ministério Público ou mediante representação da autoridade policial.
Ressalva importante para a jurisprudência atual: com a Lei 13.964/2019 (Pacote Anticrime) e a edição da Súmula 676 do STJ ("Em razão da Lei n. 13.964/2019, não é mais possível ao juiz, de ofício, decretar ou converter prisão em flagrante em prisão preventiva"), consolidou-se a vedação à decretação de preventiva de ofício pelo magistrado. Contudo, para fins desta questão de concurso (que cobrou a literalidade do texto legal do art. 20), a alternativa C reflete o gabarito oficial da banca.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou outras de prestação pecuniária.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O ambiente familiar não afasta a aplicação da Lei — a comunidade familiar é expressamente um dos âmbitos de incidência da violência doméstica e familiar (art. 5º, II).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A violência patrimonial está expressamente prevista no art. 7º, IV — a Lei não se limita a agressões físicas, psicológicas ou morais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 21, parágrafo único, veda expressamente a entrega de intimação ou notificação pela própria ofendida ao agressor.

BIZU DE PROVA:
Destruir instrumentos de trabalho é hipótese clássica de violência patrimonial (art. 7º, IV). Para provas literais, atenção ao texto do art. 20 da LMP; para provas de jurisprudência/processo penal, lembre-se da Súmula 676 do STJ: prisão preventiva não pode ser decretada de ofício pelo juiz; exige provocação de legitimado, nos termos da legislação processual aplicável.', E'\r\n', E'\n', 'g')
    and (select explicacao like '%Súmula 676 do STJ%' from public.questoes where id = 1335)
    and (select explicacao like '%prisão preventiva não pode ser decretada de ofício pelo juiz; exige provocação de legitimado, nos termos da legislação processual aplicável.%' from public.questoes where id = 1335);

  -- Assert 12: 1363 — contém referência à Súmula 676 do STJ e texto aprovado
  insert into _f2k_rec_asserts (descricao, ok)
  select '1363: explicacao contem Sumula 676 do STJ e texto aprovado',
    (select regexp_replace(explicacao, E'\r\n', E'\n', 'g') from public.questoes where id = 1363)
    = regexp_replace('GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO, ao tomar conhecimento da iminência ou prática de violência doméstica — não existe, para essa hipótese, um prazo de "até 48 horas" como a alternativa inventa (o prazo de 48 horas da Lei está associado a outra situação: a remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira quanto à literalidade do art. 20, não a exceção pedida):
Reproduz o texto literal do art. 20 da Lei Maria da Penha sobre a prisão preventiva do agressor. Ressalva jurisprudencial relevante: nos termos da Súmula 676 do STJ ("Em razão da Lei n. 13.964/2019, não é mais possível ao juiz, de ofício, decretar ou converter prisão em flagrante em prisão preventiva"), o magistrado não pode mais decretar prisão preventiva sem provocação prévia, em decorrência do sistema acusatório reforçado pelo Pacote Anticrime. Embora o texto legal do art. 20 não tenha sido formalmente reformado pelo legislador, a alternativa A foi corretamente considerada verdadeira pela banca por reproduzir a literalidade do dispositivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 4º sobre a interpretação da Lei considerando os fins sociais e as condições peculiares das mulheres em situação de violência doméstica e familiar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz literalmente o art. 9º, §1º, sobre a inclusão da mulher em programas assistenciais por prazo certo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz literalmente o art. 6º, que dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
"De imediato" (art. 10) é diferente de "em até 48 horas" (art. 12, III) — são dispositivos e momentos distintos. Lembre-se: em provas de literalidade, o art. 20 da LMP traz a redação original com "de ofício", mas no campo jurisprudencial aplica-se a Súmula 676 do STJ (vedação ao de ofício).', E'\r\n', E'\n', 'g')
    and (select explicacao like '%Súmula 676 do STJ%' from public.questoes where id = 1363);
end $$;

-- ----------------------------------------------------------------------------
-- 5. VALIDAÇÃO DOS ASSERTS
-- ----------------------------------------------------------------------------
do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k_rec_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K reconciliação final falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Reconciliação confirmada e validada por todos os asserts: persistência definitiva.
COMMIT;
