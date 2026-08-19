-- ============================================================================
-- AUDITORIA GLOBAL -- LÍNGUA PORTUGUESA -- LOTE FINAL (12 QUESTÕES)
-- Aplicação de 12 explicações pedagógicas restantes (materia_id 6)
-- IDs: 883,884,885,886,887,888,889,890,891,892,893,894
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-portugues-lote-final-harness.mjs a partir de
-- scripts/portugues-lote-final-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/portugues-lote-final-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _lpf_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _lpf_novas_explicacoes (id, explicacao) values
(883, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O vocábulo "Possível" é um adjetivo que está no número SINGULAR. Por se encontrar no singular, não possui desinência nominal de número (que na Língua Portuguesa é caracterizada pelo morfema "-s" ou "-es" indicador de plural).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Operadores" possui a desinência nominal de número plural "-es" (operador + -es).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Nossos" possui a desinência nominal de número plural "-s" (nosso + -s).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Homens" possui a desinência nominal de número plural "-s" (homem -> homens).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Mulheres" possui a desinência nominal de número plural "-es" (mulher + -es).

BIZU DE PROVA:
Desinências Nominais:
- Gênero: morfema "-a" (marcando o feminino em oposição a "-o" ou ausência).
- Número: morfema "-s" ou "-es" (marcando o plural). Palavras no singular não trazem desinência de plural ativa (morfema zero).'),
(884, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A contagem fonética da palavra "enfraquecidos" (en-fra-que-ci-dos) resulta em exatamente 11 fonemas:
- Letras (13): e-n-f-r-a-q-u-e-c-i-d-o-s.
- Dígrafos (2):
  1) Dígrafo vocálico nasal "en" = 1 fonema (/ẽ/);
  2) Dígrafo consonantal "qu" (antes de ''e'') = 1 fonema (/k/).
- Fonemas individuais: /ẽ/ + /f/ + /r/ + /a/ + /k/ + /e/ + /s/ + /i/ + /d/ + /u/ + /s/ = 11 fonemas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A contagem de 12 fonemas esquece de descontar um dos dois dígrafos presentes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
13 é o número total de letras, e não de fonemas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há 14 fonemas (a palavra possui 13 letras e 2 dígrafos).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A palavra possui 2 dígrafos ("en" vocálico e "qu" consonantal), e não apenas 1.

BIZU DE PROVA:
Contagem Rápida: Fonemas = Letras - Dígrafos + Dífono (X=/ks/).
Na palavra ENFRAQUECIDOS: 13 letras - 2 dígrafos (en, qu) = 11 fonemas!'),
(885, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ambas as palavras são PAROXÍTONAS (possuem a penúltima sílaba tônica):
1) "Va-ci-na": sílaba tônica "-ci-" (penúltima).
2) "Au-men-to": sílaba tônica "-men-" (penúltima).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Processo" (pro-ces-so) é paroxítona, mas "industrial" (in-dus-tri-al) é OXÍTONA (última sílaba tônica "-al").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Tanto "prevenção" (pre-ven-ção) quanto "combater" (com-ba-ter) são OXÍTONAS.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Fase" (fa-se) é paroxítona, mas "final" (fi-nal) é OXÍTONA.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Eficiente" (e-fi-ci-en-te) é paroxítona, mas "técnica" (téc-ni-ca) é PROPAROXÍTONA.

BIZU DE PROVA:
Posição da Sílaba Tônica:
- Última = Oxítona (industrial, combater, final).
- Penúltima = Paroxítona (vacina, aumento, fase, processo).
- Antepenúltima = Proparoxítona (técnica, células, clínica).'),
(886, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A palavra "Corpo" possui 5 letras (c-o-r-p-o) e exatamente 5 fonemas (/k-o-r-p-u/). Todas as letras são pronunciadas individualmente: o encontro consonantal "rp" é perfeito e não há nenhum dígrafo. Logo, o número de letras e de fonemas é rigorosamente igual (5 letras e 5 fonemas).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Disso" tem 5 letras e 4 fonemas (o dígrafo "ss" representa 1 único som /s/).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Possível" tem 8 letras e 7 fonemas (o dígrafo "ss" representa 1 fonema).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Nosso" tem 5 letras e 4 fonemas (o dígrafo "ss" representa 1 fonema).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Bombeiros" tem 9 letras e 7 fonemas (os dígrafos vocálicos nasais "om" e "ei" / nasalidade reduzem a contagem).

BIZU DE PROVA:
Letras = Fonemas:
Para que o número de letras seja idêntico ao de fonemas, a palavra NÃO pode conter dígrafos (ss, rr, ch, nh, an, en...), NÃO pode ter letra ''h'' inicial muda e NÃO pode ter dífono (x=/ks/).'),
(887, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "simultaneamente" possui 15 letras (s-i-m-u-l-t-a-n-e-a-m-e-n-t-e) e 13 fonemas (/s-i-m-u-l-t-a-n-e-a-m-ẽ-t-i/), pois apresenta o dígrafo vocálico nasal "en" (/ẽ/) na penúltima sílaba, além de sonorizações nasais, fazendo com que a quantidade de letras seja superior à quantidade de fonemas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Simultaneamente" é formada por derivação SUFIXAL (adjetivo simultâneo + sufixo adverbial -mente), e não por prefixo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Advérbios são palavras invariáveis e NÃO possuem desinências nominais de gênero ou número.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A palavra apresenta encontros como "lt", mas a afirmativa central do enunciado recai na contagem fonética comparativa de letras e fonemas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Simultaneamente" é uma palavra derivada pelo sufixo adverbial -mente a partir de "simultâneo".

BIZU DE PROVA:
Dígrafos Nasais Reduzem Fonemas:
Palavras com terminações em "-mente" contêm o dígrafo vocálico nasal "en" (/ẽ/), possuindo sempre mais letras do que fonemas!'),
(888, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O preenchimento ortográfico correto das palavras é s – ss – z:
1) "previsão" (com S): deriva do verbo prever (visão / prever / previsão), grafada com ''s'' com som de /z/ entre vogais.
2) "ressaltar" (com SS): prefixo re- + verbo saltar (re + saltar -> ressaltar), duplicando-se o ''s'' entre vogais para preservar o fonema /s/.
3) "realizando" (com Z): gerúndio do verbo realizar (real + sufixo -izar -> realizar), grafado com ''z'' pois a palavra base "real" não possui ''s'' no radical.
Sequência correta: s – ss – z.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "resçaltar" com ç.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "resçaltar" com ç e "realisando" com s.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "previzão" com z.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra ao propor "previzão" com z, "resçaltar" com ç e "realisando" com s.

BIZU DE PROVA:
Regra de Prefixação com R e S:
Quando o prefixo termina em vogal e a palavra base começa com R ou S, DUPLICA-SE a consoante:
- re + saltar = ressaltar;
- auto + retrato = autorretrato;
- mini + saia = minissaia.'),
(889, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento ortográfico correto das lacunas é xc – c – ç:
1) "exceção" (com XC): substantivo latino exceptio, grafado com o dígrafo "xc" na primeira sílaba e "ç" na segunda (exceção).
2) "coercitivas" (com C): adjetivo derivado de coerção / coagir, grafado com ''c'' antes de ''i'' (coercitivo).
3) "alicerçada" (com Ç): particípio do verbo alicerçar (derivado do substantivo alicerce), que recebe cedilha antes da vogal ''a'' para manter o fonema /s/.
Sequência correta: xc – c – ç.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "coersitivas" com s.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "eceção" com ''c'' simples e "alicerssada" com ss.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra em todas as lacunas ("eceção", "coersitivas", "alicerssada").

BIZU DE PROVA:
Palavras com dígrafo XC:
Exceção, excepcional, exceder, excedente, excelente, excelência, excêntrico, excitar.'),
(890, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "Maleducado" está com o hífen suprimido INCORRETAMENTE. Pela regra ortográfica, o advérbio "mal" exige OBRIGATORIAMENTE hífen diante de palavras iniciadas por VOGAL ou pela letra H. Logo, a grafia correta é "mal-educado" (com hífen).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Contrassenso" está grafada corretamente sem hífen e com duplicação do ''s'' (contra + senso -> contrassenso).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Autoimagem" está grafada corretamente sem hífen, pois o prefixo termina em vogal ("o") e a palavra seguinte começa com vogal diferente ("i") (auto + imagem -> autoimagem).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Reescrita" está grafada corretamente sem hífen (o prefixo "re-" junta-se diretamente mesmo diante da vogal ''e'': reescrever, reedição, reeleição).

BIZU DE PROVA:
Regra Geral do "MAL":
- MAL + VOGAL/H = COM HÍFEN (mal-educado, mal-estar, mal-humorado).
- MAL + CONSOANTE = SEM HÍFEN (malcriado, malfeito, malvisto).'),
(891, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O preenchimento correto e harmônico das lacunas do texto é:
1) "consecutivo": adjetivo grafado com ''s'' simples (con-se-cu-ti-vo, do latim consecutivus).
2) "homicídios": substantivo proparoxítono aparente / paroxítono em ditongo, grafado com ''i'' tônico acentuado ("-cídios", elemento compositivo latino -cidium).
3) "hesitaram": forma da 3ª pessoa do plural do pretérito perfeito do verbo hesitar (com H inicial e ''s'' medial: he-si-tar).
Sequência correta: consecutivo – homicídios – hesitaram.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra na ortografia de "concecutivo" (com c) e "exitaram" (com x, do verbo exitar / ter êxito, de sentido incompatível com ficar em dúvida/vacilar).

POR QUE A ALTERNativa B ESTÁ INCORRETA:
Apresenta "homicídeos" com terminação incorreta em "-eos".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta "exitaram" com x.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta "concecutivo" com c, "homicídeos" com e e "hezitaram" com z.

BIZU DE PROVA:
Homófonos Hesitar vs Exitar:
- HESITAR (com H e S): ficar em dúvida, vacilar, titubear ("não hesitaram um segundo").
- EXITAR (com E e X): obter êxito, ter sucesso ("o projeto exitou").'),
(892, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O preenchimento correto e adequado das lacunas tracejadas é:
1) "enxurrada" (com X): a regra ortográfica determina o uso de ''x'' após a sílaba inicial "en-" (enxurrada, enxame, enxoval).
2) "rupturas" (com P mudo): grafado com consoante muda ''p'' (rup-tu-ra), sem vogal epentética ''i''.
3) "reduzi-lo": forma do verbo reduzir unida ao pronome enclítico "lo" (reduzir -> reduzi + lo). As formas verbais oxítonas terminadas em ''i'' (quando não formam hiato com vogal anterior) NÃO recebem acento gráfico (reduzi-lo, parti-lo, dividi-lo).
Sequência exata: enxurrada – rupturas – reduzi.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "enchurrada" com ch e "reduzí-lo" com acento indevido.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra com "enchurrada" (ch) e "rupituras" (com vogal ''i'' indevida).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra com "enchurrada" com ch.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra com "rupituras" e "reduzí-lo" com acento agudo.

BIZU DE PROVA:
Acentuação de Formas Verbais com Pronomes:
- Verbos em -AR (oxítonas em A): levam acento -> cantá-lo, amá-la.
- Verbos em -ER (oxítonas em E): levam acento -> vendê-lo, fazê-la.
- Verbos em -IR (oxítonas em I): NÃO levam acento -> parti-lo, reduzi-lo, dividi-lo (exceto hiato tônico como atraí-lo, construí-lo).'),
(893, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta de preenchimento é F – F – V – V:
1) (F) "Trabalhando" é uma forma nominal do verbo (gerúndio), e NÃO um verbo conjugado em tempo do modo indicativo ou subjuntivo (pretérito).
2) (F) "Trabalhando" deriva da palavra primitiva "trabalho" (radical trabalh-), não possuindo prefixo.
3) (V) Apresenta o dígrafo consonantal "lh" (tra-ba-lhan-do), no qual duas letras representam um único fonema palatal /ʎ/, além do dígrafo vocálico nasal "an".
4) (V) "Trabalhando" é um verbo na forma nominal de GERÚNDIO (caracterizado pelo sufixo flexional "-ndo").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A primeira assertiva é falsa (gerúndio não é pretérito) e a quarta é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A segunda assertiva é falsa (não há prefixo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira assertiva é falsa e a terceira é verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A segunda assertiva é falsa e a terceira é verdadeira.

BIZU DE PROVA:
Formas Nominais do Verbo:
- Infinitivo: terminação em -R (trabalhar, correr, partir).
- Gerúndio: terminação em -NDO (trabalhando, correndo, partindo).
- Particípio: terminação em -DO (trabalhado, corrido, partido).'),
(894, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
1) Na locução conjuntiva concessiva "Embora não estejamos", a forma verbal "estejamos" pertence ao PRESENTE DO SUBJUNTIVO (que eu esteja, que nós estejamos).
2) Flexionando o verbo no pretérito imperfeito do mesmo modo (Modo Subjuntivo), obtém-se a forma "ESTIVÉSSEMOS" (se eu estivesse, se nós estivéssemos).
Preenchimento correto: presente do subjuntivo – estivéssemos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Estejamos" pertence ao modo subjuntivo (e não indicativo) e "estaremos" está no futuro do presente do indicativo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Estejamos" não está no pretérito perfeito e "estivéramos" é mais-que-perfeito do indicativo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Estejamos" não pertence ao futuro do presente do indicativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Estaríamos" pertence ao futuro do pretérito do modo indicativo.

BIZU DE PROVA:
Tempos do Modo Subjuntivo (Verbo Estar):
- Presente do Subjuntivo: que nós ESTEJAMOS.
- Pretérito Imperfeito do Subjuntivo: se nós ESTIVÉSSEMOS (-sse).
- Futuro do Subjuntivo: quando nós ESTIVERMOS.');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 12 (exceto explicacao/atualizado_em).
create temporary table _lpf_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (883,884,885,886,887,888,889,890,891,892,893,894);

-- 2) alternativas completas das 12.
create temporary table _lpf_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (883,884,885,886,887,888,889,890,891,892,893,894)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _lpf_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _lpf_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _lpf_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _lpf_novas_explicacoes) <> 12 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 12 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _lpf_novas_explicacoes);
  if v_qtd <> 12 then
    raise exception 'PRECONDICAO FALHOU: esperado 12 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _lpf_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 6 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 12 nao esta mais no estado auditado (materia_id=6, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 12.
-- ----------------------------------------------------------------------------
create temporary table _lpf_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _lpf_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _lpf_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 12 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 12 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _lpf_asserts (descricao, ok)
  select 'exatamente 12 questoes afetadas pelo UPDATE', (select count(*) from _lpf_ids_afetados) = 12;

  insert into _lpf_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 12 esperados',
    (select array_agg(id order by id) from _lpf_ids_afetados) = ARRAY[883,884,885,886,887,888,889,890,891,892,893,894]::bigint[];

  insert into _lpf_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 12 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _lpf_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _lpf_asserts (descricao, ok)
  select 'alternativas das 12 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _lpf_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _lpf_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _lpf_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _lpf_asserts (descricao, ok) values ('as 12 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 12 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _lpf_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _lpf_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _lpf_asserts (descricao, ok) values ('as 12 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 12);

  insert into _lpf_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _lpf_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[883,884,885,886,887,888,889,890,891,892,893,894]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _lpf_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _lpf_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _lpf_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _lpf_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _lpf_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _lpf_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
ROLLBACK;
