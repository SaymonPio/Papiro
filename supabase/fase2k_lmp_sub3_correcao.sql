-- ============================================================================
-- FASE 2K — sub-lote 3: correção de citação na explicação da questão 1307
-- APLICAÇÃO REAL — TERMINA EM COMMIT.
-- ============================================================================
--
-- id 1307 (CORRECAO_EXPLICACAO): a explicação atribuía ao "art. 12, §1º"
-- a regra sobre registro de posse/porte de arma de fogo do agressor no
-- expediente policial. Confirmado em fonte oficial que o art. 12, §1º
-- trata de outro assunto (qualificação da ofendida/agressor, dependentes,
-- descrição do fato) — o dispositivo correto é o art. 12, VI-A (incluído
-- pela Lei 13.880/2019). Não afeta o gabarito (A).
--
-- Evidência completa: auditoria/fase2k_lmp_sub3_resultado.json
--
-- ÚNICA coluna alterada: public.questoes.explicacao, e SOMENTE nesta
-- linha. Único trecho alterado dentro do texto: "art. 12, §1º" -> "art.
-- 12, VI-A" no parágrafo "POR QUE A ALTERNATIVA C ESTÁ INCORRETA". Todo o
-- restante permanece byte-idêntico — provado abaixo por GET DIAGNOSTICS
-- (exatamente 1 linha) e por comparação jsonb byte-a-byte de todas as
-- demais colunas antes/depois, além da checagem de que o gabarito e as
-- alternativas não mudaram.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
create temporary table _f2k3_snap_1307 on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 1307;

create temporary table _f2k3_snap_alt_1307 on commit drop as
select jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id = 1307;

create temporary table _f2k3_snap_global on commit drop as
select (select count(*) from public.questoes) as total_questoes_antes;

create temporary table _f2k3_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÃO — aborta tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.questoes where id = 1307 and ativa = true
      and md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) = '220478e9501caa68056407563746f6da'
      and md5(regexp_replace(explicacao, E'\r\n', E'\n', 'g')) = 'ed991e07c465ba99a5e168791d427944') then
    raise exception 'PRECONDICAO FALHOU: questao 1307 nao esta mais no estado auditado';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA — corrige exclusivamente a explicação da questão 1307.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As situações de nervosismo e mal-estar recorrentes causados pelo ciúme e pelas discussões do genro configuram violência psicológica, definida no art. 7º, II, como qualquer conduta que cause dano emocional e diminuição da autoestima ou que prejudique a saúde psicológica da vítima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Quem concede medida protetiva de urgência é o juiz (arts. 18 e 19), não a autoridade policial. A autoridade policial encaminha o expediente ao juiz em até 48 horas (art. 12, III) e, quando necessário, requisita diretamente o exame de corpo de delito (art. 12, IV) — não é o juiz quem solicita esse exame à polícia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A informação sobre a posse de arma pelo agressor deve constar do expediente policial (art. 12, VI-A) — não há nenhum impedimento a esse registro; muito pelo contrário, é dado relevante para a análise do risco.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A prisão preventiva pode ser decretada em qualquer fase do inquérito policial ou da instrução criminal (art. 20), não apenas ao final do inquérito, e pode ser revista a qualquer tempo — não tem caráter irrevogável.

BIZU DE PROVA:
Quem concede medida protetiva de urgência é sempre o juiz — a autoridade policial instrui, requisita exames e encaminha o expediente, mas não decide em definitivo.' where id = 1307;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 1 linha (1307), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k3_asserts (descricao, ok)
  select 'nenhuma questao criada/removida (total_questoes inalterado)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k3_snap_global);

  insert into _f2k3_asserts (descricao, ok)
  select '1307: nenhuma coluna alem de explicacao/atualizado_em mudou (jsonb byte-a-byte, inclui enunciado, alternativas nao fazem parte de questoes mas sao checadas a parte, ativa, gabarito via alternativas)',
    not exists (
      select 1 from public.questoes q join _f2k3_snap_1307 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _f2k3_asserts (descricao, ok)
  select '1307: continua ativa = true',
    (select ativa from public.questoes where id = 1307) = true;

  insert into _f2k3_asserts (descricao, ok)
  select '1307: alternativas (texto/ordem/correta — gabarito) permanecem byte-identicas',
    (select jsonb_agg(to_jsonb(a) order by a.ordem) from public.alternativas a where a.questao_id = 1307)
    = (select alternativas from _f2k3_snap_alt_1307);

  insert into _f2k3_asserts (descricao, ok)
  select '1307: explicacao atualizada para o texto corrigido exato (so a citacao do art. 12 mudou)',
    (select regexp_replace(explicacao, E'\r\n', E'\n', 'g') from public.questoes where id = 1307)
    = regexp_replace('GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As situações de nervosismo e mal-estar recorrentes causados pelo ciúme e pelas discussões do genro configuram violência psicológica, definida no art. 7º, II, como qualquer conduta que cause dano emocional e diminuição da autoestima ou que prejudique a saúde psicológica da vítima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Quem concede medida protetiva de urgência é o juiz (arts. 18 e 19), não a autoridade policial. A autoridade policial encaminha o expediente ao juiz em até 48 horas (art. 12, III) e, quando necessário, requisita diretamente o exame de corpo de delito (art. 12, IV) — não é o juiz quem solicita esse exame à polícia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A informação sobre a posse de arma pelo agressor deve constar do expediente policial (art. 12, VI-A) — não há nenhum impedimento a esse registro; muito pelo contrário, é dado relevante para a análise do risco.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A prisão preventiva pode ser decretada em qualquer fase do inquérito policial ou da instrução criminal (art. 20), não apenas ao final do inquérito, e pode ser revista a qualquer tempo — não tem caráter irrevogável.

BIZU DE PROVA:
Quem concede medida protetiva de urgência é sempre o juiz — a autoridade policial instrui, requisita exames e encaminha o expediente, mas não decide em definitivo.', E'\r\n', E'\n', 'g');

  insert into _f2k3_asserts (descricao, ok)
  select '1307: explicacao nao ficou vazia',
    (select explicacao is not null and btrim(explicacao) <> '' from public.questoes where id = 1307);

  insert into _f2k3_asserts (descricao, ok)
  select '1307: explicacao nova contem "art. 12, VI-A" e nao contem mais "art. 12, §1º"',
    (select explicacao like '%art. 12, VI-A%' and explicacao not like '%art. 12, §1º%' from public.questoes where id = 1307);
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k3_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 3 falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Escrita real confirmada pelos asserts acima — persistida agora.
COMMIT;
