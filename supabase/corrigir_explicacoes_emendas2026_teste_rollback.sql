-- ============================================================================
-- HOTFIX — 10 explicações da Lei Maria da Penha desatualizadas por emendas
-- de 2024-2026 (sub-lote 1 e sub-lote 2, JÁ EM PRODUÇÃO)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Motivo: revisão contra o texto oficial consolidado da Lei 11.340/2006
-- (Câmara dos Deputados, "norma atualizada") encontrou 3 pontos citados nas
-- explicações que ficaram desatualizados:
--
--   1) "5 modalidades" de violência (art. 7º) — a Lei 15.384/2026 acrescentou
--      o inciso VI (violência vicária), hoje são 6. ids 1300, 1313, 1325,
--      1331, 1332, 1339, 1354. Em nenhum desses casos o gabarito da questão
--      dependia do número de modalidades — é só texto de apoio da
--      explicação, corrigido sem tocar no gabarito.
--
--   2) Critério de risco do art. 12-C (afastamento emergencial do agressor)
--      — a Lei 15.411/2026 ampliou de "vida ou integridade física ou
--      psicológica" para também incluir sexual, moral e patrimonial.
--      ids 1349, 1367. O gabarito de ambas as questões reproduz a redação
--      histórica (é o texto da própria alternativa do exame, que não pode
--      ser alterado) — a explicação agora deixa claro que a redação vigente
--      é mais ampla, sem contrariar a alternativa correta.
--
--   3) Pena do art. 24-A (descumprimento de medida protetiva) — a
--      Lei 14.994/2024 mudou de detenção de 3 meses a 2 anos para reclusão
--      de 2 a 5 anos e multa. id 1311. O gabarito não depende do valor exato
--      da pena (só de que descumprir configura crime) — texto de apoio
--      corrigido.
--
-- Questões: 1300, 1311, 1313, 1325, 1331, 1332, 1339, 1349, 1354, 1367
--
-- ÚNICA coluna alterada: public.questoes.explicacao, e SOMENTE nestas 10
-- linhas. Nenhuma outra questão é tocada — provado abaixo por GET
-- DIAGNOSTICS (exatamente 10 linhas afetadas pelo UPDATE) e por hash
-- antes/depois dos campos que não podem mudar (enunciado, alternativas —
-- inclui o gabarito —, fonte, banca, concurso, materia_id, assunto_id,
-- ativa, vínculos de unidade pedagógica e de curso_questoes).
--
-- Comparações de texto normalizam CRLF/LF antes de comparar (mesmo motivo
-- do hotfix da questão 1324: o valor em produção usa CRLF e o copy/paste no
-- SQL Editor pode alterar a convenção de quebra de linha do arquivo sem
-- alterar o conteúdo).
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash por questão dos campos protegidos + contador
-- agregado.
-- ----------------------------------------------------------------------------
create temporary table _hotfix2026_antes on commit drop as
select
  q.id,
  md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_questao,
  (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = q.id
  ) as hash_alternativas,
  (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id
  ) as hash_vinculos_unidade,
  (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = q.id
  ) as hash_vinculos_curso
from public.questoes q
where q.id in (1300, 1311, 1313, 1325, 1331, 1332, 1339, 1349, 1354, 1367);

create temporary table _hotfix2026_agregado_antes on commit drop as
select (select count(*) from public.questoes) as total_questoes;

-- ----------------------------------------------------------------------------
-- Staging: as 10 explicações corrigidas + hash esperado do texto atual
-- (precondição de que nada mudou desde a auditoria).
-- ----------------------------------------------------------------------------
create temporary table _staging_hotfix2026 (
  questao_id bigint primary key,
  explicacao_nova text,
  hash_esperado_antes text
) on commit drop;

insert into _staging_hotfix2026 (questao_id, explicacao_nova, hash_esperado_antes) values
  (1300, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 dispõe expressamente que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O dever da autoridade policial não se restringe a ouvir a vítima e lavrar boletim de ocorrência. Os arts. 11 e 12 preveem um rol muito mais amplo de providências: garantir proteção policial, encaminhar ao IML, fornecer transporte, colher provas, requisitar exames periciais, ouvir agressor e testemunhas, entre outras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A atribuição da autoridade policial (ou guarda municipal, quando aplicável) não se limita a fornecer transporte — esse é apenas um dos itens do rol amplo do art. 11.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não se restringe à proteção contra violência sexual — o art. 7º prevê 6 modalidades de violência doméstica (física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária).

BIZU DE PROVA:
Cuidado com alternativas que usam "somente"/"exclusivamente"/"apenas" para descrever as atribuições da autoridade policial — a Lei sempre prevê um rol amplo e não taxativo ("entre outras providências").', '37d45bb65a862d61c25f0d01c64527d1'),
  (1311, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A Súmula 542 do Superior Tribunal de Justiça estabelece que a ação penal relativa ao crime de lesão corporal resultante de violência doméstica contra a mulher é pública incondicionada, ou seja, não depende de representação da vítima.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de penas de cesta básica ou de outras de prestação pecuniária, além da substituição de pena que implique pagamento isolado de multa — não há admissão irrestrita de substituição por "quaisquer" penas restritivas de direitos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A coabitação, atual ou pretérita, não é exigida — o art. 5º, III, fala em relação íntima de afeto independentemente de coabitação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei se aplica também a relações homoafetivas entre duas mulheres, conforme o parágrafo único do art. 5º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O descumprimento de medida protetiva de urgência é crime autônomo desde a Lei 13.641/2018 (art. 24-A da Lei 11.340/2006), atualmente com pena de reclusão de 2 a 5 anos e multa (redação dada pela Lei 14.994/2024 — a pena original de 2018 era menor, detenção de 3 meses a 2 anos).

BIZU DE PROVA:
Súmula 542/STJ — lesão corporal decorrente de violência doméstica é ação penal pública incondicionada, mesmo quando a lesão é leve (que, fora desse contexto, normalmente seria condicionada).', '40fab55ae405f04e5b909e65214acebd'),
  (1313, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As assertivas I, IV e V estão corretas. I reproduz corretamente 5 das formas de violência do art. 7º, usando a expressão "entre outras" — por isso continua verdadeira mesmo após a Lei 15.384/2026 ter acrescentado a violência vicária (art. 7º, VI): a assertiva nunca afirmou que só existem essas 5. IV reproduz a definição de violência patrimonial (art. 7º, IV). V reproduz o crime autônomo de descumprimento de medida protetiva (art. 24-A).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa: a definição apresentada ("calúnia, difamação ou injúria") é de violência MORAL (art. 7º, V), não física.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa: a definição apresentada ("ofenda integridade ou saúde corporal") é de violência FÍSICA (art. 7º, I), não patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, que é falsa pelo mesmo motivo acima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva III, que é falsa pelo mesmo motivo acima.

BIZU DE PROVA:
Essa questão troca os rótulos das definições (física vira patrimonial, moral vira física) — sempre releia a definição e confirme com qual das modalidades do art. 7º ela realmente corresponde (hoje são 6, já contando a violência vicária acrescentada pela Lei 15.384/2026).', '915a5ab3c7f2e309536a43b10984eb27'),
  (1325, 'GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 prevê taxativamente 5 formas de violência doméstica: física, psicológica, sexual, patrimonial e moral. Não existe a categoria "violência simbólica" no rol legal — trata-se de conceito sociológico, não de uma modalidade jurídica prevista na Lei. Além disso, os fatos narrados (insultos constantes, ofensas, questionamento da paternidade dos filhos) descrevem principalmente violência psicológica (art. 7º, II) e, a depender da conduta, moral (art. 7º, V), não uma suposta "violência patrimonial classificada como simbólica".

PEGADINHA:
A banca usa um termo que parece jurídico ("violência simbólica") para testar se o candidato confunde teoria sociológica sobre gênero com o rol do art. 7º da Lei.

BIZU DE PROVA:
Memorize as modalidades do art. 7º — física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária. Qualquer outro nome ("simbólica", "institucional" etc.) não está na letra da lei.', 'e4a4f49adaae8f11cc6239f8294c3f04'),
  (1331, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Ser constantemente insultada, difamada e humilhada pelo marido, com diminuição progressiva da autoestima, é a definição legal de violência psicológica (art. 7º, II, da Lei 11.340/2006). A Lei se aplica independentemente da idade da vítima ou do agressor — não há exceção etária que afaste sua incidência quando presente a relação conjugal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Abandono" não é uma das modalidades de violência doméstica do art. 7º da Lei Maria da Penha (é conceito mais associado ao Estatuto do Idoso, lei diversa da que a questão pede).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Maus tratos" não é o termo técnico usado pelo art. 7º para descrever o relato apresentado; o enquadramento correto, dentro da Lei Maria da Penha, é violência psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação não trata de vulnerabilidade socioeconômica — o relato descreve insultos e humilhações reiterados, não privação material.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência emocional" não é o termo empregado pelo art. 7º da Lei — o termo legal correto é violência psicológica (art. 7º, II).

BIZU DE PROVA:
A Lei Maria da Penha não tem exceção etária: protege a mulher em situação de violência doméstica independentemente de sua idade ou da idade do agressor. E fique atento a sinônimos que a banca usa no lugar dos termos técnicos do art. 7º (física, psicológica, sexual, patrimonial, moral e, desde 2026, violência vicária) — "violência emocional" e "maus tratos" não são esses termos.', 'bd9242c988594beb65d076493b8a5d2b'),
  (1332, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todos os 5 itens descrevem formas de violência doméstica previstas no art. 7º da Lei: I (difamação por mídia virtual) é violência moral/psicológica praticada por qualquer meio, inclusive virtual; II (proibição de usar métodos contraceptivos) é violência sexual (art. 7º, III); III (destruição de documentos pessoais) é violência patrimonial (art. 7º, IV); IV (cárcere privado) é violência física, por ofender a liberdade e a integridade da vítima; V (agressão física por companheira em relação homoafetiva) está abrangida porque o art. 5º, parágrafo único, dispensa orientação sexual como requisito.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente a resposta a apenas um item (II), quando os 5 itens estão corretos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui os itens III e V, que também estão corretos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui os itens II e IV, que também estão corretos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui os itens I, II e III, que também estão corretos.

BIZU DE PROVA:
O art. 7º é um rol amplo — quase qualquer conduta que prejudique a mulher no âmbito doméstico/familiar/afetivo (inclusive por meio virtual, e inclusive entre parceiras do mesmo sexo) se enquadra em alguma das modalidades (hoje 6, desde que a Lei 15.384/2026 acrescentou a violência vicária). Desconfie de alternativas que excluem itens sem uma razão jurídica clara para isso.', '43ae8a808dc07ac12e80d019eb5381c8'),
  (1339, 'GABARITO: ERRADO

POR QUE:
O art. 7º, IV, da Lei 11.340/2006 prevê expressamente a violência patrimonial como uma das formas de violência doméstica e familiar contra a mulher (retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos). O item erra ao afirmar que dano patrimonial não pode caracterizar violência doméstica.

PEGADINHA:
A afirmação tenta restringir a violência doméstica só à lesão corporal — mas a Lei reconhece 6 modalidades (física, psicológica, sexual, patrimonial, moral e, desde a Lei 15.384/2026, a violência vicária), não apenas a física.

BIZU DE PROVA:
Sempre que uma questão tentar "reduzir" a violência doméstica a um único tipo de dano (só físico, só corporal), desconfie — o art. 7º reconhece hoje 6 modalidades, todas igualmente reconhecidas.', '22854d30551d72c18028d24c601224fa'),
  (1349, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 22, II, combinado com o art. 12-C, autoriza o afastamento do agressor do lar quando verificado risco atual ou iminente à vida ou à integridade física ou psicológica da mulher ou de seus dependentes — critério reproduzido pela alternativa. A redação vigente do art. 12-C (desde a Lei 15.411/2026) ampliou ainda mais esse rol de riscos, incluindo também a integridade sexual, moral e patrimonial — a alternativa cobre parte do critério atual, sem contrariá-lo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restringe indevidamente a hipótese só ao risco "iminente", excluindo o risco "atual", que também autoriza a medida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Restringe indevidamente a hipótese à integridade patrimonial de forma EXCLUSIVA — o afastamento cabe diante de risco à vida ou a qualquer das dimensões de integridade da mulher (física e psicológica; a redação vigente do art. 12-C, desde a Lei 15.411/2026, inclui também sexual, moral e patrimonial), nunca de um único critério isolado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o risco psicológico e os dependentes da mulher, que também estão contemplados pela norma.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Exclui indevidamente a própria mulher, tratando a hipótese como se só protegesse os dependentes.

BIZU DE PROVA:
A hipótese de afastamento por risco é ampla: vida ou qualquer dimensão da integridade da mulher (a redação atual do art. 12-C, desde 2026, inclui física, sexual, psicológica, moral e patrimonial), da mulher ou de seus dependentes — qualquer alternativa que restrinja essa amplitude a um único critério isolado está errada.', '1e06a92f66a2359bd02ff3f0ccf12edd'),
  (1354, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 10 determina que, na iminência ou na prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência adote, de imediato, as providências legais cabíveis.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência estrutural" não é uma das modalidades do art. 7º da Lei; a definição apresentada ("ofenda sua integridade ou saúde corporal") corresponde à violência FÍSICA (art. 7º, I).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A definição apresentada ("calúnia, difamação ou injúria") é, na verdade, a definição de violência MORAL (art. 7º, V) — não de violência psicológica e patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A política pública de combate à violência doméstica não se faz exclusivamente por ações da União — o art. 8º, caput, exige ação articulada entre União, Estados, Distrito Federal, Municípios e ações não governamentais.

BIZU DE PROVA:
Fique atento a nomes "quase certos" para as modalidades de violência ("violência estrutural", "violência simbólica", "violência emocional") — nenhum desses é um dos 5 termos técnicos do art. 7º.', 'a017ec6c355ab9670b983205308f6a1b'),
  (1367, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 12-C, III, autoriza o afastamento imediato do agressor pelo próprio policial quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia, diante de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher ou de seus dependentes — critério reproduzido pela alternativa; a redação vigente do art. 12-C (desde a Lei 15.411/2026) ampliou esse rol de riscos, incluindo também sexual, moral e patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Quando há risco à integridade da ofendida ou à efetividade da medida protetiva de urgência, a lógica da Lei é de reforço da restrição de liberdade do agressor (inclusive por prisão preventiva), não de concessão de liberdade provisória.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Laudos e prontuários médicos são admitidos como meio de prova — não há vedação dessa natureza na Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O prazo para a autoridade policial remeter o expediente com pedido de medidas protetivas é de 48 horas (art. 12, III), não 24 horas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 17 veda a aplicação de penas de cesta básica ou de prestação pecuniária, mesmo em casos considerados "leves".

BIZU DE PROVA:
A cadeia de competência do art. 12-C (juiz → delegado quando não sede de comarca → policial quando não sede de comarca e sem delegado disponível) é o dispositivo mais recorrente nas provas mais recentes deste sub-lote — decore essa ordem.', '58f8c3375c45c30f94339f8c2f669199');

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo (RAISE EXCEPTION) antes de qualquer escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_divergentes int;
begin
  select count(*) into v_total from _staging_hotfix2026;
  if v_total <> 10 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 10 questoes (tem %)', v_total;
  end if;

  select count(*) into v_divergentes
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where md5(regexp_replace(q.explicacao, E'\r\n', E'\n', 'g')) <> s.hash_esperado_antes;
  if v_divergentes > 0 then
    raise exception 'Precondicao falhou: % questao(oes) tem explicacao atual diferente do esperado -- pode ter mudado desde a auditoria. Hotfix abortado por seguranca.', v_divergentes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA — altera SOMENTE explicacao, SOMENTE nas 10 linhas do staging.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas_afetadas int;
begin
  update public.questoes q
  set explicacao = s.explicacao_nova
  from _staging_hotfix2026 s
  where q.id = s.questao_id;

  get diagnostics v_linhas_afetadas = row_count;
  if v_linhas_afetadas <> 10 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 10 -- abortando', v_linhas_afetadas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table hotfix_2026_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure hotfix_2026_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into hotfix_2026_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_agregado_antes record;
  v_total_questoes int;
  v_diferentes_enunciado_ou_metadado int;
  v_diferentes_alternativas int;
  v_diferentes_vinculo_unidade int;
  v_diferentes_vinculo_curso int;
  v_nao_atualizadas int;
  v_vazia int;
begin
  select * into v_agregado_antes from _hotfix2026_agregado_antes;

  select count(*) into v_total_questoes from public.questoes;
  call hotfix_2026_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_agregado_antes.total_questoes);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _hotfix2026_antes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call hotfix_2026_assert('enunciado/fonte/banca/concurso/materia_id/assunto_id/ativa idênticos nas 10 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _hotfix2026_antes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call hotfix_2026_assert('alternativas (texto/correta/ordem, ou seja, o gabarito) idênticas nas 10 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _hotfix2026_antes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call hotfix_2026_assert('vinculos de unidade pedagogica idênticos nas 10 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _hotfix2026_antes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call hotfix_2026_assert('vinculos de curso_questoes idênticos nas 10 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_vazia
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call hotfix_2026_assert('nenhuma das 10 ficou com explicacao vazia', v_vazia = 0);

  select count(*) into v_nao_atualizadas
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where regexp_replace(q.explicacao, E'\r\n', E'\n', 'g') <> regexp_replace(s.explicacao_nova, E'\r\n', E'\n', 'g');
  call hotfix_2026_assert('todas as 10 explicacoes foram atualizadas para o texto corrigido exato', v_nao_atualizadas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from hotfix_2026_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Hotfix falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert -- tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
