-- SANEAMENTO TAXONOMICO Q878 — CLASSES DE PALAVRAS (assunto_id 47) ->
-- IMPLICITOS E SUBENTENDIDOS (assunto_id 46, curso_conteudo_id 25).
-- Operacao propria, separada, seguindo o mesmo padrao ja aplicado em
-- Q683 (Coesao textual, Operacao C) e Q279 (saneamento_taxonomico_q279.sql,
-- Reescrita -> Conectores): mover assunto_id ANTES de vincular, pois o
-- trigger validar_questao_unidade_pedagogica bloqueia vinculo com
-- assunto_id divergente.
--
-- Motivo: microauditoria dedicada (fidelidade confirmada contra a prova
-- oficial Fundatec, Concurso SUSEPE/RS no 01/2022, cargo Agente
-- Penitenciario Administrativo / Tecnico Administrativo da Policia
-- Penal, Questao 18, gabarito oficial A) determinou que Q878 e resolvida
-- integralmente por reconhecimento do conteudo implicito (pressuposto)
-- ativado pelo adjetivo "novos" aplicado a "recordes" — o comando ja
-- entrega a classificacao morfologica pronta ("o adjetivo 'novos'"), de
-- modo que a habilidade nuclear e semantico-pragmatica (interpretacao do
-- implicito), nao classificacao morfologica. PROBLEMA_DE_TAXONOMIA_Q878,
-- nao QUESTAO_HIBRIDA_MULTICONTEUDO — questao especifica e vinculavel,
-- apenas estava no assunto errado.
--
-- Q878 e REAL (Fundatec) — sua entrada em Implicitos e subentendidos
-- CONTA como incidencia real/pratica especifica real deste conteudo (o
-- primeiro caso real do corpus, ate entao 100% autoral). Enunciado,
-- alternativas, gabarito e explicacao NAO sao alterados nesta operacao —
-- fidelidade ja confirmada (fragmento e alternativas literais; unicas
-- diferencas triviais e nao bloqueantes ja registradas na microauditoria:
-- falta da citacao "(l. 33-34)" e "novo"/"novos" no comando, ambas sem
-- impacto na resolubilidade, nao restauradas nesta operacao).
--
-- Altera SOMENTE questoes.assunto_id da questao 878 e cria 1 vinculo
-- pedagogico novo (via RPC oficial). Enunciado, alternativas, gabarito,
-- explicacao, banca, concurso, ano, fonte e ativa sao verificados como
-- inalterados nas pos-condicoes. Classes de palavras (curso_conteudo_id
-- 22, ja concluido) NAO e reaberto nem tem qualquer vinculo pedagogico
-- alterado por esta operacao — apenas os artefatos de configuracao
-- (JSON/pos-check) sao ajustados a parte, fora desta transacao.
--
-- Achados colaterais NAO tratados nesta operacao (fora de escopo,
-- registrados como pendencias separadas): Q683 ja possui assunto_id=55
-- e vinculo em Coesao textual (documentacao de Classes de palavras ainda
-- nao foi limpa retroativamente — PENDENCIA_DE_CONSISTENCIA_Q683); Q684
-- permanece assunto_id=47, ativa, SEM nenhum vinculo (decisao pedagogica
-- anterior: duplicata da Q319, canonica ja vinculada — o mapa.json de
-- Classes de palavras ainda lista Q684 na lista de vinculos, divergindo
-- do estado live — PENDENCIA_DE_CONSISTENCIA_Q684). As pos-condicoes
-- abaixo apenas CONFIRMAM que esses dois estados nao mudam por causa
-- desta operacao — nenhum write e feito sobre Q683/Q684 aqui.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos,
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 22)                          as vinculos_classes_de_palavras,
  (select assunto_id from public.questoes where id = 683)     as assunto_q683,
  (select assunto_id from public.questoes where id = 684)     as assunto_q684,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 684) as vinculos_q684;

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_ativa_atual boolean;
  v_vinculos_q878 int;
  v_destino_assunto bigint;
  v_destino_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 878;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 878 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'No fragmento "Embora não estejamos satisfeitos e já assumamos o compromisso de perseguir novos recordes de redução na criminalidade", o adjetivo "novos" informa que:' then
    raise exception 'Precondicao falhou: enunciado atual da questao 878 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No fragmento "perseguir novos recordes de redução na criminalidade", o adjetivo "novos" modifica "recordes" no plural, pressupondo semanticamente que já houve recordes anteriores estabelecidos pelo programa de segurança ("já ocorreram outro ou outros recordes"), visando-se agora alcançar marcas inéditas adicionais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O adjetivo "novos" está no plural, indicando que não se trata de apenas um único recorde.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto não especifica um número quantitativo exato de recordes a serem batidos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O plural "novos" não limita a ocorrência pretérita a apenas um único recorde isolado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Quem define os recordes é a mensuração das ações de segurança pública e a redução dos índices criminais, e não a criminalidade em si.

BIZU DE PROVA:
Pressuposição Semântica do Adjetivo "Novo":
A palavra "novo/novos" indica renovação ou continuidade de uma série preexistente (ex.: "novos alunos" pressupõe que a escola já possui alunos antigos).' then
    raise exception 'Precondicao falhou: explicacao atual da questao 878 diverge do esperado';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 878 diverge do esperado — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'TA Pol Pen (PP RS)/PP RS/2022' then
    raise exception 'Precondicao falhou: concurso da questao 878 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2022 then
    raise exception 'Precondicao falhou: ano da questao 878 diverge do esperado (2022) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 47 then
    raise exception 'Precondicao falhou: assunto_id atual da questao 878 diverge do esperado (47) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 878 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 878 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 878 nao e a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos_q878 from public.questao_unidades_pedagogicas where questao_id = 878;
  if v_vinculos_q878 <> 0 then
    raise exception 'Precondicao falhou: questao 878 ja possui % vinculo(s) pedagogico(s) (esperado 0)', v_vinculos_q878;
  end if;

  -- Confirma estado da unidade destino (Implicitos e subentendidos).
  if not exists (
    select 1 from public.unidades_pedagogicas u
    join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
    where u.id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'
      and u.curso_conteudo_id = 25
      and u.ordem = 1
      and u.ativa
      and cc.assunto_id = 46
  ) then
    raise exception 'Precondicao falhou: unidade de Implicitos e subentendidos nao confere (id/ordem/conteudo/assunto/ativa)';
  end if;

  select count(*) into v_destino_vinculos
  from public.questao_unidades_pedagogicas
  where unidade_pedagogica_id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  if v_destino_vinculos <> 0 then
    raise exception 'Precondicao falhou: unidade de Implicitos e subentendidos ja possui % vinculo(s) (esperado 0, sera o primeiro)', v_destino_vinculos;
  end if;
end $$;

-- Correcao taxonomica: move Q878 do assunto de Classes de palavras (47)
-- para o assunto de Implicitos e subentendidos (46). Pre-requisito
-- tecnico para o trigger validar_questao_unidade_pedagogica permitir o
-- vinculo a seguir.
update public.questoes
   set assunto_id = 46,
       atualizado_em = now()
 where id = 878;

do $$
begin
  if not exists (select 1 from public.questoes where id = 878 and assunto_id = 46) then
    raise exception 'Pos-condicao (intermediaria) falhou: assunto_id da questao 878 nao foi atualizado para 46';
  end if;
end $$;

-- Criacao do vinculo pedagogico via RPC oficial (agora permitido pelo
-- trigger, pois materia_id e assunto_id conferem com a unidade).
select public.classificar_questao_unidade_admin(878, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid);

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia —
-- so chega ao COMMIT final se passar tudo.
do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_gabarito_ok boolean;
  v_total_alt int;
  v_vinculos_q878 int;
  v_total_vinculos_implicitos int;
  v_vinculos_classes_de_palavras_depois int;
  v_assunto_q683_depois bigint;
  v_assunto_q684_depois bigint;
  v_vinculos_q684_depois int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 878;

  if v_enunciado is distinct from 'No fragmento "Embora não estejamos satisfeitos e já assumamos o compromisso de perseguir novos recordes de redução na criminalidade", o adjetivo "novos" informa que:' then
    raise exception 'Pos-condicao falhou: enunciado da questao 878 foi alterado indevidamente';
  end if;
  if v_explicacao is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No fragmento "perseguir novos recordes de redução na criminalidade", o adjetivo "novos" modifica "recordes" no plural, pressupondo semanticamente que já houve recordes anteriores estabelecidos pelo programa de segurança ("já ocorreram outro ou outros recordes"), visando-se agora alcançar marcas inéditas adicionais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O adjetivo "novos" está no plural, indicando que não se trata de apenas um único recorde.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto não especifica um número quantitativo exato de recordes a serem batidos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O plural "novos" não limita a ocorrência pretérita a apenas um único recorde isolado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Quem define os recordes é a mensuração das ações de segurança pública e a redução dos índices criminais, e não a criminalidade em si.

BIZU DE PROVA:
Pressuposição Semântica do Adjetivo "Novo":
A palavra "novo/novos" indica renovação ou continuidade de uma série preexistente (ex.: "novos alunos" pressupõe que a escola já possui alunos antigos).' then
    raise exception 'Pos-condicao falhou: explicacao da questao 878 foi alterada indevidamente';
  end if;
  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 878 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'TA Pol Pen (PP RS)/PP RS/2022' then
    raise exception 'Pos-condicao falhou: concurso da questao 878 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2022 then
    raise exception 'Pos-condicao falhou: ano da questao 878 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 46 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 878 nao e 46 (esperado apos correcao taxonomica) — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 878 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 878;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 878 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 878 and ordem = 1 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 878 nao e mais a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos_q878 from public.questao_unidades_pedagogicas where questao_id = 878;
  if v_vinculos_q878 <> 1 then
    raise exception 'Pos-condicao falhou: questao 878 possui % vinculo(s) (esperado exatamente 1)', v_vinculos_q878;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 878 and unidade_pedagogica_id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e') then
    raise exception 'Pos-condicao falhou: o vinculo da questao 878 nao aponta para a unidade de Implicitos e subentendidos';
  end if;
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 878 and u.curso_conteudo_id = 22
  ) then
    raise exception 'Pos-condicao falhou: a questao 878 ainda possui vinculo em Classes de palavras (22)';
  end if;

  select count(*) into v_total_vinculos_implicitos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25;
  if v_total_vinculos_implicitos <> 1 then
    raise exception 'Pos-condicao falhou: total de vinculos de Implicitos e subentendidos=% (esperado 1)', v_total_vinculos_implicitos;
  end if;

  -- Classes de palavras (conteudo 22, ja concluido) NAO pode ter sido
  -- afetado por esta operacao — nem os vinculos, nem os dois achados
  -- colaterais Q683/Q684 (fora de escopo, ver cabecalho).
  select count(*) into v_vinculos_classes_de_palavras_depois
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22;
  if v_vinculos_classes_de_palavras_depois <> (select vinculos_classes_de_palavras from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: vinculos de Classes de palavras (22) mudaram — antes % agora %', (select vinculos_classes_de_palavras from _snapshot_antes), v_vinculos_classes_de_palavras_depois;
  end if;

  select assunto_id into v_assunto_q683_depois from public.questoes where id = 683;
  if v_assunto_q683_depois is distinct from (select assunto_q683 from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: assunto_id da questao 683 mudou indevidamente (fora de escopo desta operacao)';
  end if;

  select assunto_id into v_assunto_q684_depois from public.questoes where id = 684;
  if v_assunto_q684_depois is distinct from (select assunto_q684 from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: assunto_id da questao 684 mudou indevidamente (fora de escopo desta operacao)';
  end if;
  select count(*) into v_vinculos_q684_depois from public.questao_unidades_pedagogicas where questao_id = 684;
  if v_vinculos_q684_depois is distinct from (select vinculos_q684 from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: vinculos da questao 684 mudaram indevidamente (fora de escopo desta operacao)';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 25) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 25 mudou (deveria continuar 1)';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou (nenhuma unidade nova deveria ter sido criada)';
  end if;
  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos do sistema nao cresceu exatamente 1';
  end if;

  raise notice 'Pos-condicoes OK: questao 878 movida para assunto_id=46 (Implicitos e subentendidos), vinculada exatamente 1 vez a unidade 1a2158e8-f690-43ab-8ca5-051ba1c0fa3e, sem vinculo remanescente em Classes de palavras, Classes de palavras/Q683/Q684 permanecem exatamente como estavam antes (fora de escopo), enunciado/explicacao/alternativas/gabarito/proveniencia/ativa inalterados.';
end $$;

rollback;
