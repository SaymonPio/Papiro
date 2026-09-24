-- TESTE DE ROLLBACK — QUADRINHO PILOTO U1 DGF (OLD -> TARGET -> REVERT -> OLD_FINAL -> ROLLBACK)
--
-- PILOTO MANUAL do componente quadrinho_didatico (v1, sem imagem) na aula
-- rascunho da Unidade 1 de Direitos e Garantias Fundamentais (aula_versao
-- 52756262-8be4-4fb2-a9f3-2f5a158ea1d4): UM quadrinho, "Pode entrar à noite?", ilustrando o
-- art. 5º, XI (inviolabilidade do domicilio), inserido IMEDIATAMENTE APOS o
-- conceito "Inviolabilidade do domicilio" (id f0614831-dbff-4c68-b7f9-b3d31425adb4, indice 4) e antes
-- de "Sigilo de correspondencia e comunicacoes" (id 2b13bd2d-8042-4575-aefe-998b3f1f7b07).
--
-- Contrato V1 (validador.mjs / QUADRINHO_LIMITES): titulo<=120; 4 quadros
-- (3 a 6); cena<=300; falas 0..3; emissor<=40; texto<=140; legenda<=160
-- (opcional; omitida nos quadros 1 e 2); fechamento<=400. Sem imagem, alt,
-- asset, url, html, fundamento, objetivo_pedagogico ou ordem. Como este e um
-- patch manual (nao saida da IA), o componente ja traz o UUID fixo
-- 1f4065f2-8fda-4f7d-8826-45955230678d, gerado uma vez e reutilizado no patch, no harness e nos
-- pos-checks; quadros e falas NAO tem id.
--
-- Conteudo juridico limitado ao que o conceito ja ensina (art. 5º, XI):
-- flagrante/desastre/socorro a qualquer hora; determinacao judicial so de
-- dia. Sem jurisprudencia, sem prazo, sem delegado, sem prova ilicita, sem
-- conceito de "dia" ou de "casa". Cenas originais (nenhuma questao real ou
-- autoral da pratica foi copiada).
--
-- Insercao via jsonb_set + jsonb_agg: os 14 componentes originais mantem os
-- mesmos valores jsonb e a mesma ordem relativa; so entra 1 elemento novo.
-- NAO altera artigos_abordados (16), schema_version, status, numero_versao;
-- NAO cria aula nem aula_versao; NAO publica.
--
-- Baseline auditado (LIVE, leitura): hash e0559b2ef5b015bb2b2cbb9c8da2b1bc, 14 componentes,
-- 16 artigos_abordados, rascunho, versao 1, sem quadrinho, 10 aulas e 12
-- aula_versoes no total.
--
-- Este arquivo E o teste de rollback: nao persiste nada (termina em
-- ROLLBACK, sem COMMIT). Ver adicionar_quadrinho_piloto_dgf_u1_domicilio.sql
-- para o apply real. NAO foi executado nesta fase.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_quadrinho_piloto on commit drop as
select av.id as aula_versao_id, av.estrutura, av.status, av.numero_versao
from public.aula_versoes av
where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

create temporary table _hash_outras_versoes_quadrinho_piloto on commit drop as
select md5(string_agg(id::text || estrutura::text, '|' order by id)) as h
from public.aula_versoes
where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

create temporary table _totais_quadrinho_piloto on commit drop as
select (select count(*) from public.aulas) as aulas, (select count(*) from public.aula_versoes) as versoes;

-- ================= PRECONDICOES (e protecao contra reexecucao) =================
do $$
declare
  v_status text;
  v_numero int;
  v_qtd_comp int;
  v_qtd_art int;
  v_hash text;
  v_qtd_quadrinhos int;
  v_qtd_alvo int;
  v_pos_alvo int;
  v_id_proximo text;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes'), jsonb_array_length(estrutura->'artigos_abordados'), md5(estrutura::text)
  into v_status, v_numero, v_qtd_comp, v_qtd_art, v_hash
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_status is null then raise exception 'PRECOND: aula_versao nao encontrada'; end if;
  if v_status <> 'rascunho' then raise exception 'PRECOND: status esperado rascunho, encontrado %', v_status; end if;
  if v_numero <> 1 then raise exception 'PRECOND: numero_versao esperado 1, encontrado %', v_numero; end if;
  if v_qtd_comp <> 14 then raise exception 'PRECOND: esperado 14 componentes, encontrado % (possivel reexecucao ou alteracao concorrente)', v_qtd_comp; end if;
  if v_qtd_art <> 16 then raise exception 'PRECOND: esperado 16 artigos_abordados, encontrado %', v_qtd_art; end if;
  if v_hash <> 'e0559b2ef5b015bb2b2cbb9c8da2b1bc' then
    raise exception 'PRECOND: hash da estrutura diverge do baseline auditado — possivel alteracao concorrente/reexecucao, abortar';
  end if;

  select count(*) into v_qtd_quadrinhos
  from jsonb_array_elements((select estrutura->'componentes' from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid)) c
  where c.value->>'tipo' = 'quadrinho_didatico';
  if v_qtd_quadrinhos <> 0 then raise exception 'PRECOND: ja existe quadrinho_didatico nesta aula (%) — piloto ja aplicado?', v_qtd_quadrinhos; end if;

  if exists (
    select 1 from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
    where c.value->>'id' = '1f4065f2-8fda-4f7d-8826-45955230678d'
  ) then
    raise exception 'PRECOND: o UUID fixo do piloto ja existe em algum componente';
  end if;

  select count(*) into v_qtd_alvo
  from jsonb_array_elements((select estrutura->'componentes' from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid)) c
  where c.value->>'tipo' = 'conceito' and c.value->>'titulo' = 'Inviolabilidade do domicílio';
  if v_qtd_alvo <> 1 then raise exception 'PRECOND: esperado exatamente 1 conceito alvo, encontrado %', v_qtd_alvo; end if;

  select c.ordinality::int into v_pos_alvo
  from jsonb_array_elements((select estrutura->'componentes' from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid)) with ordinality c(value, ordinality)
  where c.value->>'id' = 'f0614831-dbff-4c68-b7f9-b3d31425adb4' and c.value->>'tipo' = 'conceito' and c.value->>'titulo' = 'Inviolabilidade do domicílio';
  if v_pos_alvo is distinct from 5 then raise exception 'PRECOND: conceito alvo deveria estar na posicao 5 (indice 4), encontrado %', v_pos_alvo; end if;

  select c.value->>'id' into v_id_proximo
  from jsonb_array_elements((select estrutura->'componentes' from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid)) with ordinality c(value, ordinality)
  where c.ordinality = v_pos_alvo + 1;
  if v_id_proximo is distinct from '2b13bd2d-8042-4575-aefe-998b3f1f7b07' then raise exception 'PRECOND: componente seguinte ao alvo divergiu (%)', v_id_proximo; end if;

  raise notice 'PRECOND OK: rascunho v1, 14 componentes, 16 artigos, hash baseline, sem quadrinho, conceito alvo unico no indice 4 seguido de Sigilo';
end $$;

-- ================= APPLY: insere SOMENTE o novo componente, logo apos o conceito alvo =================
-- jsonb_set reconstroi o array 'componentes' com os 14 elementos originais
-- (valores jsonb intactos, mesma ordem relativa) + o novo, sem tocar em
-- artigos_abordados, schema_version, status ou numero_versao.
do $$
declare
  v_linhas int;
begin
  update public.aula_versoes av
  set estrutura = jsonb_set(
    av.estrutura,
    '{componentes}',
    (
      select jsonb_agg(x.v order by x.o)
      from (
        select c.value as v, c.ordinality::int * 2 as o
        from jsonb_array_elements(av.estrutura->'componentes') with ordinality as c(value, ordinality)
        union all
        select $QUADRINHO$
{
  "id": "1f4065f2-8fda-4f7d-8826-45955230678d",
  "tipo": "quadrinho_didatico",
  "titulo": "Pode entrar à noite?",
  "quadros": [
    {
      "cena": "Noite. Um agente público passa diante de uma residência e ouve um pedido claro de socorro vindo de dentro.",
      "falas": [
        {
          "emissor": "Voz na casa",
          "texto": "Socorro!"
        },
        {
          "emissor": "Agente",
          "texto": "Tem alguém pedindo ajuda lá dentro."
        }
      ]
    },
    {
      "cena": "O agente está diante da entrada da residência. Um colega questiona se é possível entrar sem mandado por ser noite.",
      "falas": [
        {
          "emissor": "Colega",
          "texto": "Mas é noite. Sem mandado podemos entrar?"
        },
        {
          "emissor": "Agente",
          "texto": "Precisamos identificar qual hipótese constitucional está ocorrendo."
        }
      ]
    },
    {
      "cena": "O agente entra na residência para prestar socorro.",
      "falas": [
        {
          "emissor": "Agente",
          "texto": "É situação de socorro. Vamos entrar."
        }
      ],
      "legenda": "Socorro permite o ingresso sem consentimento, independentemente do horário."
    },
    {
      "cena": "Em outra situação, um agente segura uma ordem judicial diante de uma residência, à noite, sem flagrante, desastre ou pedido de socorro.",
      "falas": [
        {
          "emissor": "Agente",
          "texto": "Neste caso há apenas a ordem judicial."
        },
        {
          "emissor": "Colega",
          "texto": "Então o ingresso deve aguardar o período diurno."
        }
      ],
      "legenda": "Hipótese isolada: determinação judicial."
    }
  ],
  "fechamento": "Flagrante delito, desastre ou socorro permitem ingresso sem consentimento do morador, independentemente do horário. Por determinação judicial, o ingresso ocorre durante o dia."
}
$QUADRINHO$::jsonb as v,
               (select c2.ordinality::int * 2 + 1
                from jsonb_array_elements(av.estrutura->'componentes') with ordinality as c2(value, ordinality)
                where c2.value->>'id' = 'f0614831-dbff-4c68-b7f9-b3d31425adb4') as o
      ) x
    )
  )
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then raise exception 'APPLY: esperado exatamente 1 linha atualizada, atualizadas %', v_linhas; end if;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_status text;
  v_numero int;
  v_qtd_comp int;
  v_estrutura jsonb;
  v_quadrinho jsonb;
  v_pos int;
  v_quadro jsonb;
  v_fala jsonb;
  v_chave text;
  v_texto_total text;
  v_antes jsonb;
  v_depois jsonb;
  v_aulas int;
  v_versoes int;
  v_t_aulas int;
  v_t_versoes int;
begin
  select estrutura, status, numero_versao into v_estrutura, v_status, v_numero
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;
  v_qtd_comp := jsonb_array_length(v_estrutura->'componentes');

  if v_status <> 'rascunho' then raise exception 'POSCOND: status mudou para %', v_status; end if;
  if v_numero <> 1 then raise exception 'POSCOND: numero_versao mudou para %', v_numero; end if;
  if v_qtd_comp <> 15 then raise exception 'POSCOND: esperado 15 componentes, encontrado %', v_qtd_comp; end if;
  if jsonb_array_length(v_estrutura->'artigos_abordados') <> 16 then raise exception 'POSCOND: artigos_abordados deveria continuar com 16'; end if;

  if (select count(*) from jsonb_array_elements(v_estrutura->'componentes') c where c.value->>'tipo' = 'quadrinho_didatico') <> 1 then
    raise exception 'POSCOND: esperado exatamente 1 quadrinho_didatico';
  end if;

  select c.value, c.ordinality::int into v_quadrinho, v_pos
  from jsonb_array_elements(v_estrutura->'componentes') with ordinality c(value, ordinality)
  where c.value->>'tipo' = 'quadrinho_didatico';

  if v_quadrinho->>'id' <> '1f4065f2-8fda-4f7d-8826-45955230678d' then raise exception 'POSCOND: UUID do quadrinho diverge do fixo'; end if;
  if v_pos <> 6 then raise exception 'POSCOND: quadrinho deveria estar na posicao 6 (indice 5), esta em %', v_pos; end if;
  if (v_estrutura->'componentes'->4->>'id') <> 'f0614831-dbff-4c68-b7f9-b3d31425adb4' then raise exception 'POSCOND: o componente imediatamente antes do quadrinho nao e o conceito de domicilio'; end if;
  if (v_estrutura->'componentes'->6->>'id') <> '2b13bd2d-8042-4575-aefe-998b3f1f7b07' then raise exception 'POSCOND: o componente imediatamente depois do quadrinho deveria ser o Sigilo'; end if;

  -- contrato V1 (espelha o validador backend): campos, limites, quantidades
  for v_chave in select jsonb_object_keys(v_quadrinho) loop
    if v_chave not in ('id', 'tipo', 'titulo', 'quadros', 'fechamento') then raise exception 'POSCOND: campo nao permitido no quadrinho: %', v_chave; end if;
  end loop;
  if length(trim(v_quadrinho->>'titulo')) = 0 or length(v_quadrinho->>'titulo') > 120 then raise exception 'POSCOND: titulo invalido'; end if;
  if jsonb_typeof(v_quadrinho->'quadros') <> 'array' or jsonb_array_length(v_quadrinho->'quadros') <> 4 then raise exception 'POSCOND: esperado exatamente 4 quadros'; end if;
  if length(trim(v_quadrinho->>'fechamento')) = 0 or length(v_quadrinho->>'fechamento') > 400 then raise exception 'POSCOND: fechamento invalido'; end if;

  for v_quadro in select value from jsonb_array_elements(v_quadrinho->'quadros') loop
    for v_chave in select jsonb_object_keys(v_quadro) loop
      if v_chave not in ('cena', 'falas', 'legenda') then raise exception 'POSCOND: campo nao permitido no quadro: %', v_chave; end if;
    end loop;
    if length(trim(v_quadro->>'cena')) = 0 or length(v_quadro->>'cena') > 300 then raise exception 'POSCOND: cena invalida'; end if;
    if jsonb_typeof(v_quadro->'falas') <> 'array' or jsonb_array_length(v_quadro->'falas') > 3 then raise exception 'POSCOND: falas invalidas (array, maximo 3)'; end if;
    if v_quadro ? 'legenda' and (length(trim(v_quadro->>'legenda')) = 0 or length(v_quadro->>'legenda') > 160) then raise exception 'POSCOND: legenda invalida'; end if;
    for v_fala in select value from jsonb_array_elements(v_quadro->'falas') loop
      for v_chave in select jsonb_object_keys(v_fala) loop
        if v_chave not in ('emissor', 'texto') then raise exception 'POSCOND: campo nao permitido na fala: %', v_chave; end if;
      end loop;
      if length(trim(v_fala->>'emissor')) = 0 or length(v_fala->>'emissor') > 40 then raise exception 'POSCOND: emissor invalido'; end if;
      if length(trim(v_fala->>'texto')) = 0 or length(v_fala->>'texto') > 140 then raise exception 'POSCOND: texto de fala invalido'; end if;
    end loop;
  end loop;

  -- roteiro: cada quadro cumpre o papel pedagogico previsto
  if position('pedido claro de socorro' in (v_quadrinho->'quadros'->0->>'cena')) = 0 or position('Noite' in (v_quadrinho->'quadros'->0->>'cena')) = 0 then raise exception 'POSCOND: quadro 1 (situacao noturna + pedido de socorro)'; end if;
  if position('mandado' in (v_quadrinho->'quadros'->1->>'cena')) = 0 or position('noite' in (v_quadrinho->'quadros'->1->>'cena')) = 0 then raise exception 'POSCOND: quadro 2 (duvida sobre entrada noturna sem mandado)'; end if;
  if position('prestar socorro' in (v_quadrinho->'quadros'->2->>'cena')) = 0 then raise exception 'POSCOND: quadro 3 (entrada para prestar socorro)'; end if;
  if position('ordem judicial' in (v_quadrinho->'quadros'->3->>'cena')) = 0 or position('à noite' in (v_quadrinho->'quadros'->3->>'cena')) = 0 or position('sem flagrante, desastre ou pedido de socorro' in (v_quadrinho->'quadros'->3->>'cena')) = 0 then raise exception 'POSCOND: quadro 4 (ordem judicial isolada durante a noite)'; end if;

  foreach v_texto_total in array array['flagrante', 'desastre', 'socorro', 'independentemente do horário', 'determinação judicial', 'durante o dia'] loop
    if position(lower(v_texto_total) in lower(v_quadrinho->>'fechamento')) = 0 then raise exception 'POSCOND: fechamento sem "%"', v_texto_total; end if;
  end loop;

  -- nenhuma imagem/HTML/asset em lugar nenhum do quadrinho
  v_texto_total := lower(v_quadrinho::text);
  if v_texto_total ~ '"(imagem|alt|asset_id|asset|url|html|fundamento|objetivo_pedagogico|ordem)"' then raise exception 'POSCOND: campo reservado/imagem encontrado no quadrinho'; end if;
  if v_texto_total ~ '<[a-z/]' then raise exception 'POSCOND: possivel HTML no quadrinho'; end if;

  -- os 14 componentes originais: identicos (jsonb) e na mesma ordem relativa
  select jsonb_agg(x.value order by x.ordinality) into v_antes
  from _snapshot_old_quadrinho_piloto t, jsonb_array_elements(t.estrutura->'componentes') with ordinality x(value, ordinality);
  select jsonb_agg(x.value order by x.ordinality) into v_depois
  from jsonb_array_elements(v_estrutura->'componentes') with ordinality x(value, ordinality)
  where x.value->>'id' <> '1f4065f2-8fda-4f7d-8826-45955230678d';
  if v_antes is distinct from v_depois then raise exception 'POSCOND: os 14 componentes originais nao estao identicos/na mesma ordem'; end if;

  -- resto da estrutura intacto
  if (v_estrutura - 'componentes') is distinct from ((select estrutura from _snapshot_old_quadrinho_piloto) - 'componentes') then
    raise exception 'POSCOND: campos fora de componentes (artigos_abordados/schema_version) mudaram';
  end if;

  select count(*) into v_aulas from public.aulas;
  select count(*) into v_versoes from public.aula_versoes;
  select aulas, versoes into v_t_aulas, v_t_versoes from _totais_quadrinho_piloto;
  if v_aulas <> v_t_aulas then raise exception 'POSCOND: total de aulas mudou'; end if;
  if v_versoes <> v_t_versoes then raise exception 'POSCOND: total de aula_versoes mudou'; end if;

  raise notice 'POSCOND OK: 15 componentes, 1 quadrinho (UUID fixo) no indice 5 entre o conceito e o Sigilo, 4 quadros dentro dos limites V1, 14 originais intactos';
end $$;

do $$
declare
  v_depois text;
  v_antes text;
begin
  select h into v_antes from _hash_outras_versoes_quadrinho_piloto;
  select md5(string_agg(id::text || estrutura::text, '|' order by id)) into v_depois
  from public.aula_versoes where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;
  if v_depois is distinct from v_antes then raise exception 'POSCOND: outras aula_versoes mudaram — vazamento do UPDATE'; end if;
  raise notice 'POSCOND OK: nenhuma outra aula_versao foi tocada';
end $$;

-- ================= REVERT (restaura a partir do snapshot OLD) =================
update public.aula_versoes av
set estrutura = t.estrutura, status = t.status, numero_versao = t.numero_versao
from _snapshot_old_quadrinho_piloto t
where av.id = t.aula_versao_id;

-- ================= OLD_FINAL (identidade byte-a-byte com OLD) =================
do $$
declare
  v_estrutura text;
  v_hash text;
  v_status text;
  v_numero int;
begin
  select av.estrutura::text, md5(av.estrutura::text), av.status, av.numero_versao
  into v_estrutura, v_hash, v_status, v_numero
  from public.aula_versoes av where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_estrutura is distinct from (select estrutura::text from _snapshot_old_quadrinho_piloto) then raise exception 'OLD_FINAL: estrutura NAO retornou identica a original'; end if;
  if v_hash <> 'e0559b2ef5b015bb2b2cbb9c8da2b1bc' then raise exception 'OLD_FINAL: hash difere do baseline (%)', v_hash; end if;
  if v_status <> 'rascunho' or v_numero <> 1 then raise exception 'OLD_FINAL: status/numero_versao divergem'; end if;

  if jsonb_array_length((select estrutura->'componentes' from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid)) <> 14 then raise exception 'OLD_FINAL: componentes deveriam voltar a 14'; end if;
  if exists (
    select 1 from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
    where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid and c.value->>'tipo' = 'quadrinho_didatico'
  ) then raise exception 'OLD_FINAL: ainda existe quadrinho_didatico'; end if;

  raise notice 'OLD_FINAL OK: estrutura, hash, status e versao identicos ao OLD; 14 componentes; nenhum quadrinho — reversao comprovada';
end $$;

rollback;
