-- Correção pontual — v7 (substitui a v6). v6 normalizou a trava do final
-- do enunciado (ignora diferenca de espacos: banco tem
-- "medidassocioeducativas" sem espaco). v7 fortalece só a Parte A
-- (validacao do backup): agora exige count(*) = 20 (alternativas) e
-- count(*) = 4 (questoes) — nao count(distinct id) — mais diferenca
-- simetrica com parenteses explicitos em cada lado do UNION ALL, para os
-- 20 IDs de alternativas e para os IDs 877/882/889/890 de questoes. Partes
-- B, C, D, E e F inalteradas desde a v6.
--
-- Correção pontual — v5 (substitui a v4). Dois ajustes sobre a v4: (1) a
-- trava de conferencia da questao 877 agora compara com '5.'/'6.'/'7.'/'8.'
-- (com ponto final, exatamente o que o PASSO 0.3 confirmou ter sido
-- extraido do banco — o texto gravado preserva os pontos, nada e
-- normalizado); (2) a validacao do backup (Parte A) agora exige EXATAMENTE
-- os 20 IDs de alternativas esperados e EXATAMENTE as 4 questoes
-- 877/882/889/890, sem aceitar IDs extras nem faltantes.
--
-- O PASSO 0 revelou que a v3 estava
-- incompleta: o novo enunciado NÃO é "enunciado_atual || trecho da
-- alternativa 5". A estrutura real da corrupção é:
--
--   questoes.enunciado termina em "...às seguintes medidas socioeducativas:"
--   ordem 1 = "advertência;"                          (era "a)" no texto original)
--   ordem 2 = "obrigação de reparar o dano;"           (era "b)")
--   ordem 3 = "prestação de serviços à comunidade;"    (era "c)")
--   ordem 4 = "liberdade assistida;"                   (era "d)")
--   ordem 5 = "inserção em regime de semiliberdade; f) internação em
--             estabelecimento educacional... [resto do texto-base] ...
--             [comando da questão] ... a) <opção real 1> b) <opção real 2>
--             c) <opção real 3> d) <opção real 4>"
--
-- Ou seja: o importador tratou os itens a)/b)/c)/d) de uma enumeração
-- LEGAL dentro do próprio texto-base (medidas socioeducativas do ECA) como
-- se fossem as alternativas da questão, e jogou todo o resto — continuação
-- dessa mesma enumeração (a partir de "e)", cujo marcador foi consumido
-- igual aos de a)-d|) + o comando real + as alternativas REAIS da questão —
-- dentro de uma única alternativa 5 (a "fonte").
--
-- Reconstrução (por questão):
--   novo_enunciado =
--     enunciado_atual
--     || ' a) ' || ordem1_atual   -- reinsere o marcador removido
--     || ' b) ' || ordem2_atual
--     || ' c) ' || ordem3_atual
--     || ' d) ' || ordem4_atual
--     || ' e) ' || trecho_da_ordem5_antes_da_sequencia_FINAL_a_b_c_d
--   (o "f)" já está dentro do trecho da ordem 5 — não se insere outro.)
--
-- As alternativas reais (novo ordem 1-4) são extraídas da sequência FINAL
-- a)/b)/c)/d) dentro da ordem 5 — não da primeira ocorrência (que
-- pertenceria à enumeração do texto-base, já tratada acima). Isso é feito
-- com um grupo GULOSO (.*) antes do primeiro "a)" no regex, o que força o
-- motor a casar com a ÚLTIMA sequência a)/b)/c)/d) da string, não a primeira.
--
-- Nada de texto é digitado à mão nos campos gravados — tudo vem de colunas
-- já existentes no banco (enunciado atual + textos atuais de ordem 1-4 +
-- texto da ordem 5), só recombinadas/separadas por regex. Os valores que
-- você reportou (5/6/7/8, "Movimento para dentro." etc.) são usados
-- SOMENTE como conferência: se o extraído não bater, o script aborta e
-- mostra o que encontrou.
--
-- NÃO RODAR sem antes: rodar o PASSO 0 completo (0.1 a 0.4) e conferir a
-- simulação (0.4) contra o que você já visualizou manualmente no banco.

-- ============================================================================
-- PASSO 0 — DIAGNÓSTICO E SIMULAÇÃO (só leitura, nada é gravado)
-- ============================================================================

-- 0.1 — enunciado atual das 4 questões.
select id, length(enunciado) as tamanho_enunciado, enunciado, explicacao, banca, concurso, ano, ativa, dificuldade
from public.questoes
where id in (877, 882, 889, 890)
order by id;

-- 0.2 — todas as alternativas atuais (1 a 5) das 4 questões.
select id, questao_id, ordem, correta, texto
from public.alternativas
where questao_id in (877, 882, 889, 890)
order by questao_id, ordem;

-- 0.3 — pré-visualização da extração da SEQUÊNCIA FINAL a)/b)/c)/d) dentro
-- da ordem 5 (grupo 1 guloso = pega a última ocorrência, não a primeira).
with fonte as (
  select
    a.questao_id,
    a.id as alternativa_fonte_id,
    a.texto as texto_fonte,
    regexp_match(a.texto, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is') as partes
  from public.alternativas a
  where a.id in (4356, 4381, 4416, 4421)
)
select
  questao_id,
  alternativa_fonte_id,
  (partes is not null) as marcadores_encontrados,
  regexp_replace(coalesce(partes[1], ''), '^\s+|\s+$', '', 'g') as trecho_continuacao_ordem5,
  regexp_replace(coalesce(partes[2], ''), '^\s+|\s+$', '', 'g') as alternativa_1_real,
  regexp_replace(coalesce(partes[3], ''), '^\s+|\s+$', '', 'g') as alternativa_2_real,
  regexp_replace(coalesce(partes[4], ''), '^\s+|\s+$', '', 'g') as alternativa_3_real,
  regexp_replace(regexp_replace(coalesce(partes[5], ''), '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g') as alternativa_4_real
from fonte
order by questao_id;

-- 0.4 — SIMULAÇÃO COMPLETA: tamanho atual/novo do enunciado, final do novo
-- enunciado (últimos 160 caracteres) e as 4 alternativas reais + gabarito,
-- exatamente como ficariam após o PASSO 1 — sem gravar nada.
with fonte as (
  select
    q.id as questao_id,
    q.enunciado as enunciado_atual,
    length(q.enunciado) as tamanho_enunciado_atual,
    o1.texto as ordem1_atual,
    o2.texto as ordem2_atual,
    o3.texto as ordem3_atual,
    o4.texto as ordem4_atual,
    o5.texto as ordem5_atual
  from public.questoes q
  join public.alternativas o1 on o1.questao_id = q.id and o1.ordem = 1
  join public.alternativas o2 on o2.questao_id = q.id and o2.ordem = 2
  join public.alternativas o3 on o3.questao_id = q.id and o3.ordem = 3
  join public.alternativas o4 on o4.questao_id = q.id and o4.ordem = 4
  join public.alternativas o5 on o5.questao_id = q.id and o5.ordem = 5
  where q.id in (877, 882, 889, 890)
),
extraido as (
  select
    *,
    regexp_match(ordem5_atual, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is') as partes
  from fonte
),
montado as (
  select
    *,
    (
      enunciado_atual
      || ' a) ' || ordem1_atual
      || ' b) ' || ordem2_atual
      || ' c) ' || ordem3_atual
      || ' d) ' || ordem4_atual
      || ' e) ' || regexp_replace(coalesce(partes[1], ''), '^\s+|\s+$', '', 'g')
    ) as novo_enunciado,
    regexp_replace(coalesce(partes[2], ''), '^\s+|\s+$', '', 'g') as alternativa_1,
    regexp_replace(coalesce(partes[3], ''), '^\s+|\s+$', '', 'g') as alternativa_2,
    regexp_replace(coalesce(partes[4], ''), '^\s+|\s+$', '', 'g') as alternativa_3,
    regexp_replace(regexp_replace(coalesce(partes[5], ''), '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g') as alternativa_4
  from extraido
)
select
  questao_id,
  tamanho_enunciado_atual,
  length(novo_enunciado) as tamanho_novo_enunciado,
  right(novo_enunciado, 160) as final_do_novo_enunciado,
  alternativa_1,
  alternativa_2,
  alternativa_3,
  alternativa_4,
  case questao_id when 877 then 4 when 882 then 2 when 889 then 1 when 890 then 3 end as gabarito_ordem
from montado
order by questao_id;

-- ============================================================================
-- PASSO 1 (transação única — A a G nesta ordem)
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- Guarda 0 — os 20 IDs conhecidos precisam bater exatamente com
-- (questao_id, ordem) reais no banco ANTES de qualquer escrita.
-- ---------------------------------------------------------------------------
do $$
declare
  v_divergentes integer;
begin
  with esperado(id, questao_id, ordem) as (
    values
      (4352, 877, 1), (4353, 877, 2), (4354, 877, 3), (4355, 877, 4), (4356, 877, 5),
      (4377, 882, 1), (4378, 882, 2), (4379, 882, 3), (4380, 882, 4), (4381, 882, 5),
      (4412, 889, 1), (4413, 889, 2), (4414, 889, 3), (4415, 889, 4), (4416, 889, 5),
      (4417, 890, 1), (4418, 890, 2), (4419, 890, 3), (4420, 890, 4), (4421, 890, 5)
  )
  select count(*) into v_divergentes
  from esperado e
  join public.alternativas a on a.id = e.id
  where a.questao_id <> e.questao_id or a.ordem <> e.ordem;

  if v_divergentes <> 0 or (
    select count(*) from public.alternativas
    where id in (4352,4353,4354,4355,4356,4377,4378,4379,4380,4381,
                 4412,4413,4414,4415,4416,4417,4418,4419,4420,4421)
  ) <> 20 then
    raise exception 'Abortado: os IDs conhecidos nao batem com (questao_id, ordem) reais no banco. Confira o PASSO 0 antes de repetir.';
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- A) Backup do ESTADO ORIGINAL — 4 questões e 20 alternativas — antes de
-- qualquer UPDATE, dentro da mesma transação.
-- ---------------------------------------------------------------------------
create table if not exists public._backup_questoes_877_882_889_890 as
select now() as _backup_em, q.*
from public.questoes q
where q.id in (877, 882, 889, 890);

create table if not exists public._backup_alternativas_877_882_889_890 as
select now() as _backup_em, a.*
from public.alternativas a
where a.questao_id in (877, 882, 889, 890);

alter table public._backup_questoes_877_882_889_890 enable row level security;
alter table public._backup_alternativas_877_882_889_890 enable row level security;

do $$
declare
  v_divergentes integer;
begin
  -- Exige EXATAMENTE 20 linhas no backup de alternativas — nem a mais, nem
  -- a menos (backup incompleto ou de uma execucao anterior parcial).
  if (select count(*) from public._backup_alternativas_877_882_889_890) <> 20 then
    raise exception 'Abortado: backup de alternativas nao tem exatamente 20 linhas.';
  end if;

  -- Exige EXATAMENTE os 20 IDs esperados (diferenca simetrica com
  -- parenteses explicitos em cada lado antes do UNION ALL).
  with esperado(id) as (
    values (4352),(4353),(4354),(4355),(4356),
           (4377),(4378),(4379),(4380),(4381),
           (4412),(4413),(4414),(4415),(4416),
           (4417),(4418),(4419),(4420),(4421)
  )
  select count(*) into v_divergentes
  from (
    (
      select id from esperado
      except
      select id from public._backup_alternativas_877_882_889_890
    )
    union all
    (
      select id from public._backup_alternativas_877_882_889_890
      except
      select id from esperado
    )
  ) t;

  if v_divergentes <> 0 then
    raise exception 'Abortado: backup de alternativas nao contem exatamente os 20 IDs esperados (877/882/889/890). Verifique public._backup_alternativas_877_882_889_890 antes de repetir.';
  end if;

  -- Exige EXATAMENTE 4 linhas no backup de questoes (count(*), nao
  -- count(distinct id) — nao aceita linhas duplicadas do mesmo id).
  if (select count(*) from public._backup_questoes_877_882_889_890) <> 4 then
    raise exception 'Abortado: backup de questoes nao tem exatamente 4 linhas.';
  end if;

  -- Exige EXATAMENTE os IDs 877, 882, 889, 890 (mesma diferenca simetrica
  -- com parenteses explicitos).
  with esperado(id) as (
    values (877),(882),(889),(890)
  )
  select count(*) into v_divergentes
  from (
    (
      select id from esperado
      except
      select id from public._backup_questoes_877_882_889_890
    )
    union all
    (
      select id from public._backup_questoes_877_882_889_890
      except
      select id from esperado
    )
  ) t;

  if v_divergentes <> 0 then
    raise exception 'Abortado: backup de questoes nao contem exatamente as 4 questoes esperadas (877, 882, 889, 890). Verifique public._backup_questoes_877_882_889_890 antes de repetir.';
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- B) + C) por questão: valida as travas prévias (enunciado e ordem 1-4no
-- estado exatamente esperado), reconstrói o enunciado reinserindo os
-- marcadores a)/b)/c)/d)/e), extrai a sequência FINAL a)/b)/c)/d) da
-- ordem 5 (grupo 1 guloso = ignora ocorrências anteriores), confere contra
-- o texto reportado e só então grava. Nada é digitado — tudo vem das
-- variáveis lidas do banco no início do bloco.
-- ---------------------------------------------------------------------------

-- Questão 877 (fonte = alternativa id 4356)
do $$
declare
  v_enunciado text;
  v_o1 text; v_o2 text; v_o3 text; v_o4 text; v_o5 text;
  v_partes text[];
  v_trecho text;
  v_a text; v_b text; v_c text; v_d text;
  v_novo_enunciado text;
begin
  select enunciado into v_enunciado from public.questoes where id = 877;
  select texto into v_o1 from public.alternativas where id = 4352;
  select texto into v_o2 from public.alternativas where id = 4353;
  select texto into v_o3 from public.alternativas where id = 4354;
  select texto into v_o4 from public.alternativas where id = 4355;
  select texto into v_o5 from public.alternativas where id = 4356;

  -- Travas prévias (antes de qualquer escrita)
  if length(v_enunciado) <> 497 then
    raise exception 'Abortado (questao 877): tamanho do enunciado atual (%) diferente do esperado (497).', length(v_enunciado);
  end if;
  if coalesce(lower(regexp_replace(rtrim(v_enunciado), '\s+', '', 'g')), '') not like '%àsseguintesmedidassocioeducativas:' then
    raise exception 'Abortado (questao 877): final inesperado do enunciado: [%]', right(v_enunciado, 100);
  end if;
  if v_o1 not like '%advertência;%' then
    raise exception 'Abortado (questao 877): ordem 1 nao contem "advertencia;". Encontrado: [%]', v_o1;
  end if;
  if v_o2 not like '%obrigação de reparar o dano;%' then
    raise exception 'Abortado (questao 877): ordem 2 nao contem "obrigacao de reparar o dano;". Encontrado: [%]', v_o2;
  end if;
  if v_o3 not like '%prestação de serviços à comunidade;%' then
    raise exception 'Abortado (questao 877): ordem 3 nao contem "prestacao de servicos a comunidade;". Encontrado: [%]', v_o3;
  end if;
  if v_o4 not like '%liberdade assistida;%' then
    raise exception 'Abortado (questao 877): ordem 4 nao contem "liberdade assistida;". Encontrado: [%]', v_o4;
  end if;

  -- Extração da sequência FINAL a)/b)/c)/d) em ordem 5
  v_partes := regexp_match(v_o5, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is');
  if v_partes is null then
    raise exception 'Abortado (questao 877): sequencia final a)/b)/c)/d) nao encontrada em ordem 5 (id 4356).';
  end if;

  v_trecho := regexp_replace(v_partes[1], '^\s+|\s+$', '', 'g');
  v_a := regexp_replace(v_partes[2], '^\s+|\s+$', '', 'g');
  v_b := regexp_replace(v_partes[3], '^\s+|\s+$', '', 'g');
  v_c := regexp_replace(v_partes[4], '^\s+|\s+$', '', 'g');
  v_d := regexp_replace(regexp_replace(v_partes[5], '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g');

  if lower(v_a) <> lower('5.') or lower(v_b) <> lower('6.') or lower(v_c) <> lower('7.') or lower(v_d) <> lower('8.') then
    raise exception 'Abortado (questao 877): alternativas reais extraidas nao batem com o esperado. Extraido: a=[%] b=[%] c=[%] d=[%]', v_a, v_b, v_c, v_d;
  end if;

  v_novo_enunciado := v_enunciado
    || ' a) ' || v_o1
    || ' b) ' || v_o2
    || ' c) ' || v_o3
    || ' d) ' || v_o4
    || ' e) ' || v_trecho;

  update public.questoes set enunciado = v_novo_enunciado where id = 877;
  update public.alternativas set texto = v_a where id = 4352;
  update public.alternativas set texto = v_b where id = 4353;
  update public.alternativas set texto = v_c where id = 4354;
  update public.alternativas set texto = v_d where id = 4355;
end $$;

-- Questão 882 (fonte = alternativa id 4381)
do $$
declare
  v_enunciado text;
  v_o1 text; v_o2 text; v_o3 text; v_o4 text; v_o5 text;
  v_partes text[];
  v_trecho text;
  v_a text; v_b text; v_c text; v_d text;
  v_novo_enunciado text;
begin
  select enunciado into v_enunciado from public.questoes where id = 882;
  select texto into v_o1 from public.alternativas where id = 4377;
  select texto into v_o2 from public.alternativas where id = 4378;
  select texto into v_o3 from public.alternativas where id = 4379;
  select texto into v_o4 from public.alternativas where id = 4380;
  select texto into v_o5 from public.alternativas where id = 4381;

  if length(v_enunciado) <> 497 then
    raise exception 'Abortado (questao 882): tamanho do enunciado atual (%) diferente do esperado (497).', length(v_enunciado);
  end if;
  if coalesce(lower(regexp_replace(rtrim(v_enunciado), '\s+', '', 'g')), '') not like '%àsseguintesmedidassocioeducativas:' then
    raise exception 'Abortado (questao 882): final inesperado do enunciado: [%]', right(v_enunciado, 100);
  end if;
  if v_o1 not like '%advertência;%' then
    raise exception 'Abortado (questao 882): ordem 1 nao contem "advertencia;". Encontrado: [%]', v_o1;
  end if;
  if v_o2 not like '%obrigação de reparar o dano;%' then
    raise exception 'Abortado (questao 882): ordem 2 nao contem "obrigacao de reparar o dano;". Encontrado: [%]', v_o2;
  end if;
  if v_o3 not like '%prestação de serviços à comunidade;%' then
    raise exception 'Abortado (questao 882): ordem 3 nao contem "prestacao de servicos a comunidade;". Encontrado: [%]', v_o3;
  end if;
  if v_o4 not like '%liberdade assistida;%' then
    raise exception 'Abortado (questao 882): ordem 4 nao contem "liberdade assistida;". Encontrado: [%]', v_o4;
  end if;

  v_partes := regexp_match(v_o5, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is');
  if v_partes is null then
    raise exception 'Abortado (questao 882): sequencia final a)/b)/c)/d) nao encontrada em ordem 5 (id 4381).';
  end if;

  v_trecho := regexp_replace(v_partes[1], '^\s+|\s+$', '', 'g');
  v_a := regexp_replace(v_partes[2], '^\s+|\s+$', '', 'g');
  v_b := regexp_replace(v_partes[3], '^\s+|\s+$', '', 'g');
  v_c := regexp_replace(v_partes[4], '^\s+|\s+$', '', 'g');
  v_d := regexp_replace(regexp_replace(v_partes[5], '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g');

  if lower(v_a) <> lower('Movimento para dentro.') or lower(v_b) <> lower('Negação.')
     or lower(v_c) <> lower('Separação.') or lower(v_d) <> lower('Concomitância.') then
    raise exception 'Abortado (questao 882): alternativas reais extraidas nao batem com o esperado. Extraido: a=[%] b=[%] c=[%] d=[%]', v_a, v_b, v_c, v_d;
  end if;

  v_novo_enunciado := v_enunciado
    || ' a) ' || v_o1
    || ' b) ' || v_o2
    || ' c) ' || v_o3
    || ' d) ' || v_o4
    || ' e) ' || v_trecho;

  update public.questoes set enunciado = v_novo_enunciado where id = 882;
  update public.alternativas set texto = v_a where id = 4377;
  update public.alternativas set texto = v_b where id = 4378;
  update public.alternativas set texto = v_c where id = 4379;
  update public.alternativas set texto = v_d where id = 4380;
end $$;

-- Questão 889 (fonte = alternativa id 4416)
do $$
declare
  v_enunciado text;
  v_o1 text; v_o2 text; v_o3 text; v_o4 text; v_o5 text;
  v_partes text[];
  v_trecho text;
  v_a text; v_b text; v_c text; v_d text;
  v_novo_enunciado text;
begin
  select enunciado into v_enunciado from public.questoes where id = 889;
  select texto into v_o1 from public.alternativas where id = 4412;
  select texto into v_o2 from public.alternativas where id = 4413;
  select texto into v_o3 from public.alternativas where id = 4414;
  select texto into v_o4 from public.alternativas where id = 4415;
  select texto into v_o5 from public.alternativas where id = 4416;

  if length(v_enunciado) <> 498 then
    raise exception 'Abortado (questao 889): tamanho do enunciado atual (%) diferente do esperado (498).', length(v_enunciado);
  end if;
  if coalesce(lower(regexp_replace(rtrim(v_enunciado), '\s+', '', 'g')), '') not like '%àsseguintesmedidassocioeducativas:' then
    raise exception 'Abortado (questao 889): final inesperado do enunciado: [%]', right(v_enunciado, 100);
  end if;
  if v_o1 not like '%advertência;%' then
    raise exception 'Abortado (questao 889): ordem 1 nao contem "advertencia;". Encontrado: [%]', v_o1;
  end if;
  if v_o2 not like '%obrigação de reparar o dano;%' then
    raise exception 'Abortado (questao 889): ordem 2 nao contem "obrigacao de reparar o dano;". Encontrado: [%]', v_o2;
  end if;
  if v_o3 not like '%prestação de serviços à comunidade;%' then
    raise exception 'Abortado (questao 889): ordem 3 nao contem "prestacao de servicos a comunidade;". Encontrado: [%]', v_o3;
  end if;
  if v_o4 not like '%liberdade assistida;%' then
    raise exception 'Abortado (questao 889): ordem 4 nao contem "liberdade assistida;". Encontrado: [%]', v_o4;
  end if;

  -- Nota: as lacunas do tipo "e...eção", "coer...itivas", "alicer...ada"
  -- fazem parte do enunciado real da questão 889 (ortografia) e não são
  -- tocadas por nenhuma normalização — só trim de espaços nas bordas.
  v_partes := regexp_match(v_o5, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is');
  if v_partes is null then
    raise exception 'Abortado (questao 889): sequencia final a)/b)/c)/d) nao encontrada em ordem 5 (id 4416).';
  end if;

  v_trecho := regexp_replace(v_partes[1], '^\s+|\s+$', '', 'g');
  v_a := regexp_replace(v_partes[2], '^\s+|\s+$', '', 'g');
  v_b := regexp_replace(v_partes[3], '^\s+|\s+$', '', 'g');
  v_c := regexp_replace(v_partes[4], '^\s+|\s+$', '', 'g');
  v_d := regexp_replace(regexp_replace(v_partes[5], '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g');

  if lower(v_a) <> lower('xc – c – ç') or lower(v_b) <> lower('xc – s – ç')
     or lower(v_c) <> lower('c – c – ss') or lower(v_d) <> lower('c – s – ss') then
    raise exception 'Abortado (questao 889): alternativas reais extraidas nao batem com o esperado. Extraido: a=[%] b=[%] c=[%] d=[%]', v_a, v_b, v_c, v_d;
  end if;

  v_novo_enunciado := v_enunciado
    || ' a) ' || v_o1
    || ' b) ' || v_o2
    || ' c) ' || v_o3
    || ' d) ' || v_o4
    || ' e) ' || v_trecho;

  update public.questoes set enunciado = v_novo_enunciado where id = 889;
  update public.alternativas set texto = v_a where id = 4412;
  update public.alternativas set texto = v_b where id = 4413;
  update public.alternativas set texto = v_c where id = 4414;
  update public.alternativas set texto = v_d where id = 4415;
end $$;

-- Questão 890 (fonte = alternativa id 4421)
do $$
declare
  v_enunciado text;
  v_o1 text; v_o2 text; v_o3 text; v_o4 text; v_o5 text;
  v_partes text[];
  v_trecho text;
  v_a text; v_b text; v_c text; v_d text;
  v_novo_enunciado text;
begin
  select enunciado into v_enunciado from public.questoes where id = 890;
  select texto into v_o1 from public.alternativas where id = 4417;
  select texto into v_o2 from public.alternativas where id = 4418;
  select texto into v_o3 from public.alternativas where id = 4419;
  select texto into v_o4 from public.alternativas where id = 4420;
  select texto into v_o5 from public.alternativas where id = 4421;

  if length(v_enunciado) <> 497 then
    raise exception 'Abortado (questao 890): tamanho do enunciado atual (%) diferente do esperado (497).', length(v_enunciado);
  end if;
  if coalesce(lower(regexp_replace(rtrim(v_enunciado), '\s+', '', 'g')), '') not like '%àsseguintesmedidassocioeducativas:' then
    raise exception 'Abortado (questao 890): final inesperado do enunciado: [%]', right(v_enunciado, 100);
  end if;
  if v_o1 not like '%advertência;%' then
    raise exception 'Abortado (questao 890): ordem 1 nao contem "advertencia;". Encontrado: [%]', v_o1;
  end if;
  if v_o2 not like '%obrigação de reparar o dano;%' then
    raise exception 'Abortado (questao 890): ordem 2 nao contem "obrigacao de reparar o dano;". Encontrado: [%]', v_o2;
  end if;
  if v_o3 not like '%prestação de serviços à comunidade;%' then
    raise exception 'Abortado (questao 890): ordem 3 nao contem "prestacao de servicos a comunidade;". Encontrado: [%]', v_o3;
  end if;
  if v_o4 not like '%liberdade assistida;%' then
    raise exception 'Abortado (questao 890): ordem 4 nao contem "liberdade assistida;". Encontrado: [%]', v_o4;
  end if;

  v_partes := regexp_match(v_o5, '^(.*)a\)\s*(.*?)b\)\s*(.*?)c\)\s*(.*?)d\)\s*(.*)$', 'is');
  if v_partes is null then
    raise exception 'Abortado (questao 890): sequencia final a)/b)/c)/d) nao encontrada em ordem 5 (id 4421).';
  end if;

  v_trecho := regexp_replace(v_partes[1], '^\s+|\s+$', '', 'g');
  v_a := regexp_replace(v_partes[2], '^\s+|\s+$', '', 'g');
  v_b := regexp_replace(v_partes[3], '^\s+|\s+$', '', 'g');
  v_c := regexp_replace(v_partes[4], '^\s+|\s+$', '', 'g');
  v_d := regexp_replace(regexp_replace(v_partes[5], '\s+\d+_BASE_[A-Z0-9_]+\y.*$', '', 'is'), '^\s+|\s+$', '', 'g');

  if lower(v_a) <> lower('Contrassenso.') or lower(v_b) <> lower('Autoimagem.')
     or lower(v_c) <> lower('Maleducado.') or lower(v_d) <> lower('Reescrita.') then
    raise exception 'Abortado (questao 890): alternativas reais extraidas nao batem com o esperado. Extraido: a=[%] b=[%] c=[%] d=[%]', v_a, v_b, v_c, v_d;
  end if;

  v_novo_enunciado := v_enunciado
    || ' a) ' || v_o1
    || ' b) ' || v_o2
    || ' c) ' || v_o3
    || ' d) ' || v_o4
    || ' e) ' || v_trecho;

  update public.questoes set enunciado = v_novo_enunciado where id = 890;
  update public.alternativas set texto = v_a where id = 4417;
  update public.alternativas set texto = v_b where id = 4418;
  update public.alternativas set texto = v_c where id = 4419;
  update public.alternativas set texto = v_d where id = 4420;
end $$;

-- ---------------------------------------------------------------------------
-- D) Gabarito: exatamente uma alternativa correta por questão, na ordem
-- informada. Zera as demais primeiro para nunca deixar duas "corretas".
-- ---------------------------------------------------------------------------

update public.alternativas set correta = false where questao_id in (877,882,889,890) and ordem <= 4;

update public.alternativas set correta = true where id = 4355; -- 877, ordem 4
update public.alternativas set correta = true where id = 4378; -- 882, ordem 2
update public.alternativas set correta = true where id = 4412; -- 889, ordem 1
update public.alternativas set correta = true where id = 4419; -- 890, ordem 3

-- ---------------------------------------------------------------------------
-- E) Validação de que as 4 questões estão completas ANTES de apagar a
-- fonte (alternativa 5). Aborta (rollback total) se qualquer checagem falhar.
-- ---------------------------------------------------------------------------

do $$
declare
  v_problema integer;
begin
  select count(*) into v_problema
  from (
    select questao_id from public.alternativas
    where questao_id in (877,882,889,890)
    group by questao_id
    having count(*) <> 5
  ) t;
  if v_problema <> 0 then
    raise exception 'Abortado (validacao E): uma das questoes nao tem mais 5 alternativas neste ponto.';
  end if;

  select count(*) into v_problema
  from (
    select questao_id from public.alternativas
    where questao_id in (877,882,889,890) and ordem <= 4
    group by questao_id
    having count(*) filter (where correta) <> 1
  ) t;
  if v_problema <> 0 then
    raise exception 'Abortado (validacao E): gabarito nao tem exatamente 1 alternativa correta entre ordem 1-4 em uma das questoes.';
  end if;

  if exists (
    select 1 from public.alternativas
    where questao_id in (877,882,889,890) and ordem <= 4
      and (texto is null or trim(texto) = '')
  ) then
    raise exception 'Abortado (validacao E): alguma alternativa 1-4 ficou com texto vazio apos a correcao.';
  end if;

  if exists (
    select 1 from public.questoes
    where id in (877,882,889,890) and (enunciado is null or trim(enunciado) = '')
  ) then
    raise exception 'Abortado (validacao E): enunciado vazio em uma das questoes.';
  end if;

  -- o novo enunciado precisa ser maior que o truncado original — sinal de
  -- que a reconstrucao (Parte B) realmente rodou para as 4 questoes.
  if exists (
    select 1 from public.questoes
    where id = 877 and length(enunciado) <= 497
       or id = 882 and length(enunciado) <= 497
       or id = 889 and length(enunciado) <= 498
       or id = 890 and length(enunciado) <= 497
  ) then
    raise exception 'Abortado (validacao E): o enunciado de uma das questoes nao cresceu em relacao ao tamanho truncado original.';
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- F) DELETE exclusivamente dos 4 IDs artificiais (guarda extra: só apaga
-- se id, questao_id e ordem baterem exatamente com o esperado).
-- ---------------------------------------------------------------------------

delete from public.alternativas
where id in (4356, 4381, 4416, 4421)
  and (id, questao_id, ordem) in (
    (4356, 877, 5), (4381, 882, 5), (4416, 889, 5), (4421, 890, 5)
  );

do $$
begin
  if (select count(*) from public.alternativas where id in (4356,4381,4416,4421)) <> 0 then
    raise exception 'Abortado (validacao F): pelo menos um dos IDs artificiais nao foi removido — guarda de id/questao_id/ordem nao bateu.';
  end if;
  if exists (
    select 1 from public.alternativas
    where questao_id in (877,882,889,890)
    group by questao_id
    having count(*) <> 4
  ) then
    raise exception 'Abortado (validacao F): uma das questoes nao ficou com exatamente 4 alternativas apos o DELETE.';
  end if;
end $$;

commit;

-- ============================================================================
-- G) VALIDAÇÃO FINAL — rodar depois do COMMIT
-- ============================================================================

-- G.1 — as 4 questões completas, com enunciado reconstruído e as 4 alternativas cada.
select
  q.id as questao_id,
  q.enunciado,
  a.ordem,
  a.correta,
  a.texto
from public.questoes q
join public.alternativas a on a.questao_id = q.id
where q.id in (877, 882, 889, 890)
order by q.id, a.ordem;

-- G.2 — relatório resumido no formato pedido.
select
  q.id as questao_id,
  count(a.id) as quantidade_de_alternativas,
  max(a.ordem) filter (where a.correta) as alternativa_correta_ordem,
  max(a.texto) filter (where a.correta) as alternativa_correta_texto,
  case when count(a.id) = 4 and count(*) filter (where a.correta) = 1 then 'OK' else 'REVISAR' end as status
from public.questoes q
left join public.alternativas a on a.questao_id = q.id
where q.id in (877, 882, 889, 890)
group by q.id
order by q.id;

-- ============================================================================
-- ROLLBACK MANUAL (se algo for descoberto errado DEPOIS do COMMIT)
-- Restaura questoes e alternativas ao ESTADO ORIGINAL salvo no PASSO 1-A.
-- ============================================================================
-- begin;
-- delete from public.alternativas where questao_id in (877,882,889,890);
-- insert into public.alternativas (id, questao_id, texto, ordem, correta)
-- select id, questao_id, texto, ordem, correta
-- from public._backup_alternativas_877_882_889_890;
--
-- update public.questoes q
-- set enunciado = b.enunciado, explicacao = b.explicacao
-- from public._backup_questoes_877_882_889_890 b
-- where q.id = b.id;
-- commit;
