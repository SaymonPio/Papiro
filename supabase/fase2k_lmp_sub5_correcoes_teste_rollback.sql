-- ============================================================================
-- FASE 2K — sub-lote 5: correções de explicação (1358, 1363) e higiene de
-- dado no enunciado (1359)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- id 1358 (CORRECAO_EXPLICACAO): "art. 12-B" corrigido para "art. 12-C"
-- (autoridade policial de afastamento do agressor). Não afeta o gabarito.
--
-- id 1363 (CORRECAO_EXPLICACAO): trecho sobre "o STJ já decidiu" (de
-- ofício) suavizado para refletir a controvérsia real e não pacificada
-- (STJ dividido, Enunciado 51 FONAVID em sentido contrário). Não afeta o
-- gabarito, que depende de fundamento independente.
--
-- id 1359 (higiene de dado, NÃO é correção jurídica): as 2 únicas
-- ocorrências de "$" no enunciado (deveriam ser "§") corrigidas para
-- "§ 8º" e "§ 1º". Resto do enunciado, e a questão 1361 (citada na
-- auditoria mas EXCLUÍDA deste harness por instrução explícita do
-- usuário), permanecem intocados.
--
-- Evidência completa: auditoria/fase2k_lmp_sub5_resultado.json
--
-- ÚNICAS colunas alteradas: public.questoes.explicacao (1358, 1363) e
-- public.questoes.enunciado (1359). Nenhuma outra questão é tocada —
-- provado abaixo por GET DIAGNOSTICS (exatamente 1 linha por UPDATE) e
-- por comparação jsonb byte-a-byte de todas as demais colunas
-- antes/depois, além de checagem de que alternativas/gabarito
-- permanecem byte-idênticos nas 3.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
create temporary table _f2k5_snap_1358 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1358;

create temporary table _f2k5_snap_1363 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1363;

create temporary table _f2k5_snap_1359 on commit drop as
select id, (to_jsonb(q) - 'enunciado' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1359;

create temporary table _f2k5_snap_alt on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id in (1358, 1359, 1363) group by questao_id;

create temporary table _f2k5_snap_global on commit drop as
select (select count(*) from public.questoes) as total_questoes_antes;

create temporary table _f2k5_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.questoes where id = 1358 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '67661051124754663ffcc6cf9a05da00'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = 'f16baff34eb4deed3011be7c8929d32e') then
    raise exception 'PRECONDICAO FALHOU: questao 1358 nao esta mais no estado auditado';
  end if;

  if not exists (select 1 from public.questoes where id = 1363 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '2c34fb54b13d49de3d92597ee1626971'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = '907f7b97775d24633b66c637ca6cc379') then
    raise exception 'PRECONDICAO FALHOU: questao 1363 nao esta mais no estado auditado';
  end if;

  if not exists (select 1 from public.questoes where id = 1359 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = 'd312fc26281d982e30d1d1a136f36f35'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = 'd4386863a4f23b64578012141908db05') then
    raise exception 'PRECONDICAO FALHOU: questao 1359 nao esta mais no estado auditado (enunciado com $ esperado)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — corrige exclusivamente a explicação da questão 1358.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = 'GABARITO: alternativa E

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
As medidas protetivas de urgência são um mecanismo autônomo e urgente — não dependem de inquérito, ação penal ou boletim de ocorrência já formalizados para serem concedidas.' where id = 1358;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 1 FALHOU: esperado UPDATE de exatamente 1 linha (1358), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — corrige exclusivamente a explicação da questão 1363.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO, ao tomar conhecimento da iminência ou prática de violência doméstica — não existe, para essa hipótese, um prazo de "até 48 horas" como a alternativa inventa (o prazo de 48 horas da Lei está associado a outra situação: a remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira quanto à literalidade do art. 20, não a exceção pedida):
Reproduz o texto literal do art. 20 da Lei sobre prisão preventiva do agressor, inclusive a menção a decretação "de ofício". Ressalva importante para a prática: o art. 311 do CPP, após a Lei 13.964/2019 (Pacote Anticrime), passou a exigir sempre provocação para a prisão preventiva, e parte da jurisprudência do STJ entende que o juiz não pode decretá-la de ofício mesmo em contexto de violência doméstica — mas o tema não está pacificado: há entendimento em sentido contrário, amparado no princípio da especialidade do art. 20 (Enunciado 51 do FONAVID). A redação do art. 20 não foi atualizada, e há controvérsia real sobre se essa parte específica está superada na prática pela jurisprudência. Para fins desta questão, que cobra a literalidade do dispositivo, a alternativa foi corretamente tratada como verdadeira pela banca.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 4º sobre interpretação da Lei considerando os fins sociais e a condição peculiar da mulher em situação de violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 9º, §1º, sobre inclusão em cadastro de programas assistenciais por prazo certo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 6º sobre violação dos direitos humanos.

BIZU DE PROVA:
"De imediato" (art. 10) é diferente de "em até 48 horas" (art. 12, III) — são dispositivos e momentos distintos. Bancas gostam de emprestar o prazo de um para inventar prazo em outro.' where id = 1363;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 2 FALHOU: esperado UPDATE de exatamente 1 linha (1363), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — corrige exclusivamente o enunciado da questão 1359 (2
-- ocorrências de "$" → "§").
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set enunciado = '(PMLM/URCA 2025) A lei Nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da constituição federal, da convenção sobre a eliminação de todas as formas de discriminação contra as mulheres e da convenção interamericana para prevenir, punir e erradicar a violência contra a mulher; dispõe sobre a criação dos juizados de violência doméstica e familiar contra a mulher; altera os decretos-lei Nº 3.689, de 3 de outubro de 1941 (código de processo penal), e 2.848, de 7 de dezembro de 1940 (código penal), e a lei Nº 7.210, de 11 de julho de 1984 (lei de execução penal); e dá outras providências (lei maria da penha). o capítulo III - que trata do atendimento pela autoridade policial, em seu Art. 10-a. coloca que: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores - preferencialmente do sexo feminino - previamente capacitados. (incluído pela lei nº 13.505, de 2017) em seu § 1º a inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá diretrizes, assinale abaixo, a alternativa correta:' where id = 1359;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 3 FALHOU: esperado UPDATE de exatamente 1 linha (1359), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k5_asserts (descricao, ok)
  select 'nenhuma questao criada/removida (total_questoes inalterado)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k5_snap_global);

  -- 1358
  insert into _f2k5_asserts (descricao, ok)
  select '1358: nenhuma coluna alem de explicacao/atualizado_em mudou (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q join _f2k5_snap_1358 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k5_asserts (descricao, ok)
  select '1358: explicacao atualizada para o texto corrigido exato (art. 12-C, sem mais "art. 12-B")',
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
    and (select explicacao not like '%art. 12-B%' from public.questoes where id = 1358);
  insert into _f2k5_asserts (descricao, ok)
  select '1358: continua ativa = true',
    (select ativa from public.questoes where id = 1358) = true;

  -- 1363
  insert into _f2k5_asserts (descricao, ok)
  select '1363: nenhuma coluna alem de explicacao/atualizado_em mudou (jsonb byte-a-byte)',
    not exists (
      select 1 from public.questoes q join _f2k5_snap_1363 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k5_asserts (descricao, ok)
  select '1363: explicacao atualizada para o texto corrigido exato (sem afirmar "o STJ ja decidiu")',
    (select regexp_replace(explicacao, E'\r\n', E'\n', 'g') from public.questoes where id = 1363)
    = regexp_replace('GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 10 determina que a autoridade policial adote as providências legais cabíveis DE IMEDIATO, ao tomar conhecimento da iminência ou prática de violência doméstica — não existe, para essa hipótese, um prazo de "até 48 horas" como a alternativa inventa (o prazo de 48 horas da Lei está associado a outra situação: a remessa do expediente com pedido de medidas protetivas ao juiz, art. 12, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é verdadeira quanto à literalidade do art. 20, não a exceção pedida):
Reproduz o texto literal do art. 20 da Lei sobre prisão preventiva do agressor, inclusive a menção a decretação "de ofício". Ressalva importante para a prática: o art. 311 do CPP, após a Lei 13.964/2019 (Pacote Anticrime), passou a exigir sempre provocação para a prisão preventiva, e parte da jurisprudência do STJ entende que o juiz não pode decretá-la de ofício mesmo em contexto de violência doméstica — mas o tema não está pacificado: há entendimento em sentido contrário, amparado no princípio da especialidade do art. 20 (Enunciado 51 do FONAVID). A redação do art. 20 não foi atualizada, e há controvérsia real sobre se essa parte específica está superada na prática pela jurisprudência. Para fins desta questão, que cobra a literalidade do dispositivo, a alternativa foi corretamente tratada como verdadeira pela banca.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 4º sobre interpretação da Lei considerando os fins sociais e a condição peculiar da mulher em situação de violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 9º, §1º, sobre inclusão em cadastro de programas assistenciais por prazo certo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é verdadeira, não a exceção pedida):
Reproduz o art. 6º sobre violação dos direitos humanos.

BIZU DE PROVA:
"De imediato" (art. 10) é diferente de "em até 48 horas" (art. 12, III) — são dispositivos e momentos distintos. Bancas gostam de emprestar o prazo de um para inventar prazo em outro.', E'\r\n', E'\n', 'g')
    and (select explicacao not like '%o STJ já decidiu%' from public.questoes where id = 1363);
  insert into _f2k5_asserts (descricao, ok)
  select '1363: continua ativa = true',
    (select ativa from public.questoes where id = 1363) = true;

  -- 1359
  insert into _f2k5_asserts (descricao, ok)
  select '1359: nenhuma coluna alem de enunciado/atualizado_em mudou (jsonb byte-a-byte, inclui explicacao)',
    not exists (
      select 1 from public.questoes q join _f2k5_snap_1359 s on s.id = q.id
      where (to_jsonb(q) - 'enunciado' - 'atualizado_em') <> s.dados_imutaveis
    );
  insert into _f2k5_asserts (descricao, ok)
  select '1359: enunciado atualizado para o texto corrigido exato (residuo $ removido)',
    (select enunciado from public.questoes where id = 1359) = '(PMLM/URCA 2025) A lei Nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da constituição federal, da convenção sobre a eliminação de todas as formas de discriminação contra as mulheres e da convenção interamericana para prevenir, punir e erradicar a violência contra a mulher; dispõe sobre a criação dos juizados de violência doméstica e familiar contra a mulher; altera os decretos-lei Nº 3.689, de 3 de outubro de 1941 (código de processo penal), e 2.848, de 7 de dezembro de 1940 (código penal), e a lei Nº 7.210, de 11 de julho de 1984 (lei de execução penal); e dá outras providências (lei maria da penha). o capítulo III - que trata do atendimento pela autoridade policial, em seu Art. 10-a. coloca que: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores - preferencialmente do sexo feminino - previamente capacitados. (incluído pela lei nº 13.505, de 2017) em seu § 1º a inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá diretrizes, assinale abaixo, a alternativa correta:'
    and (select enunciado not like '%$%' from public.questoes where id = 1359);
  insert into _f2k5_asserts (descricao, ok)
  select '1359: continua ativa = true',
    (select ativa from public.questoes where id = 1359) = true;

  -- Gabarito (alternativas texto/ordem/correta) das 3 questoes intacto.
  insert into _f2k5_asserts (descricao, ok)
  select '1358, 1359 e 1363: alternativas (gabarito) permanecem byte-identicas',
    not exists (
      select 1 from _f2k5_snap_alt s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a where a.questao_id in (1358, 1359, 1363) group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  -- Confirma que 1361 nao foi tocada (nao faz parte deste harness -- checagem extra de seguranca).
  insert into _f2k5_asserts (descricao, ok)
  select '1361 nao foi tocada (fora do escopo deste harness, por instrucao do usuario)',
    (select count(*) from public.questoes where id = 1361) = 1;
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k5_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 5 falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATEs de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
