-- REVISAO FINAL DE VINCULOS — curadoria Fase 9.0.1. SUBSTITUI o patch
-- da Fase 9 (mover_questoes_hibridas_dgf_missao_final.sql, removido
-- nesta rodada).
--
-- Mandato: "PAPIRO — FASE 9.0.1 — REVISAO FINAL DA CURADORIA DGF ANTES
-- DO ROLLBACK TEST", secoes 2/3/5/6/9/10/11-D/E/F/H.
--
-- DUAS familias de acao, por motivos DIFERENTES (nao confundir):
--
--   (I) DESVINCULO de questao_unidades_pedagogicas -- para questoes
--   HIBRIDAS cujo conteudo necessario ja e/sera ensinado por este
--   conteudo (47), so que espalhado entre U1 e U2 -- ficam elegiveis
--   somente ao "banco geral" da Missao Final (mecanismo real,
--   confirmado por leitura de codigo na Fase 9: selecionar_candidatas_
--   conteudo aceita UNIAO de vinculo direto OU banco geral do mesmo
--   assunto_id; selecionar_candidatas_unidade_pedagogica sempre exige
--   vinculo direto, entao desvincular basta para tirar da pratica de
--   unidade sem tirar da Missao Final):
--     46  -- 3 dos 4 itens V/F (X, XVI, XIX-adjacente) sao U1; o 4º
--     (XXXIX) e garantia penal pura, tema U2. Remove os DOIS vinculos
--     (U1 e U2).
--     112 -- gabarito real = XXXIII (U2); distratores cobrem XII/XVI
--     (U1) e XXIV/XXVI (U2). Remove o vinculo com U1 (nunca teve
--     vinculo com U2).
--     326 -- RECLASSIFICADA nesta revisao (a Fase 9 a marcou erradamente
--     como "nao hibrida porque o gabarito e de uma unica unidade" --
--     mas e questao V/F com sequencia final: TODOS os 4 itens entram no
--     gabarito, nao so o "correto"). Item 1 = XII (U1); itens 2/3/4 =
--     XXV/XXXIII/XXXIV (U2, todos ja no escopo revisado da U2). Remove
--     o vinculo com U1 (nunca teve vinculo com U2).
--
--   (II) EXCLUSAO DO FLUXO BM-RS via remocao de curso_questoes (NAO
--   apenas desvinculo de unidade) -- para questoes cujo pre-requisito
--   real NAO e ensinado em NENHUMA unidade deste conteudo nem de
--   nenhum outro conteudo do curso BM-RS ainda (0 aulas em qualquer
--   candidato). Confirmado por leitura de codigo (Fase 9.0.1): tanto
--   selecionar_candidatas_unidade_pedagogica quanto selecionar_
--   candidatas_conteudo (banco geral da Missao Final) exigem
--   OBRIGATORIAMENTE `join curso_questoes cq on cq.questao_id=q.id and
--   cq.curso_id=p_curso_id` -- remover a linha de curso_questoes para
--   o curso BM-RS torna a questao INATINGIVEL por QUALQUER caminho
--   deste curso (pratica de unidade E Missao Final), sem apagar a
--   questao de public.questoes (permanece intacta, reutilizavel em
--   outro curso ou, se um dia o pre-requisito for ensinado aqui, basta
--   reinserir a linha de curso_questoes e o vinculo de unidade). Este e
--   o mecanismo "curso-especifico mais seguro" pedido pelo mandato --
--   nenhuma tabela nova, nenhuma alteracao em questoes/alternativas.
--     775 -- gabarito real depende de art. 1º, III (dignidade da
--     pessoa humana, Titulo I, fora de QUALQUER unidade "art. 5º"
--     deste conteudo). Existe unidade "Dignidade humana" (id
--     70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f, curso_conteudo_id=98,
--     MESMO curso) com artigos_esperados=['art. 1º, III'] -- mas
--     materia_id=11 ("Direitos Humanos e Cidadania"), enquanto a
--     questao 775 e a propria unidade 47 tem materia_id=10
--     ("Legislacao Especifica"). O trigger validar_questao_unidade_
--     pedagogica (questao_unidades_pedagogicas.sql) exige MESMA
--     materia_id -- um INSERT vinculando 775 a essa unidade seria
--     REJEITADO pelo proprio banco. Confirmado: QUESTAO_775_PODE_IR_
--     PARA_DIGNIDADE_HUMANA = NAO. Alem disso, essa unidade tambem
--     nunca teve aula gerada (0 aulas) -- o pre-requisito nao esta
--     ensinado em lugar nenhum do curso hoje, mesmo que a materia
--     batesse.
--     849 -- itens II/III/IV citam literalmente a Declaracao Universal
--     dos Direitos Humanos (nao a CF/88). Existe unidade dedicada
--     "Declaracao Universal dos Direitos Humanos" (id
--     e7bef052-b882-4a2f-b1e6-88ce12740c26, curso_conteudo_id=83,
--     MESMO curso, materia "Direitos Humanos e Cidadania") -- mas
--     tambem tem 0 aulas geradas, e seus artigos_esperados nem sequer
--     cobrem os dispositivos exatos citados pelos itens III/IV da
--     questao (art. 16(2) e art. 23(3) da DUDH, ausentes da lista
--     cadastrada). DUDH NAO foi efetivamente ensinada em lugar nenhum
--     do curso ainda (nenhuma aula, publicada ou rascunho, em qualquer
--     unidade candidata). Regra do mandato: so pode ir para Missao
--     Final se TODO o conhecimento necessario ja foi ensinado antes;
--     caso contrario, fora do fluxo POR ENQUANTO. Rejeitada tambem a
--     justificativa "reconhece pelo estilo" como base pedagogica
--     suficiente (o aluno deve resolver por conhecimento, nao por
--     heuristica de estilo).
--
-- NAO cria nenhum vinculo novo. NAO altera questoes, alternativas,
-- gabaritos. NAO deleta nenhuma questao de public.questoes -- 775 e 849
-- continuam existindo, ativas, disponiveis para reclassificacao futura
-- (basta reinserir a linha de curso_questoes + vinculo de unidade,
-- quando o pre-requisito de cada uma for efetivamente ensinado).
--
-- ROLLBACK-TESTADO em mover_e_excluir_questoes_dgf_final_teste_rollback.sql
-- (preparado nesta mesma rodada; execucao contra LIVE fica para uma
-- fase de rollback-test dedicada, nao esta).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_vinculos_dgf_final on commit drop as
select questao_id, unidade_pedagogica_id, classificado_por, criado_em
from public.questao_unidades_pedagogicas
where (questao_id, unidade_pedagogica_id) in (
  (46, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (46, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid)
);

create temporary table _hash_outros_vinculos_antes_dgf_final on commit drop as
select md5(string_agg(questao_id::text || ':' || unidade_pedagogica_id::text, '|' order by questao_id, unidade_pedagogica_id)) as h
from public.questao_unidades_pedagogicas
where not ((questao_id, unidade_pedagogica_id) in (
  (46, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (46, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid)
));

create temporary table _snapshot_old_curso_questoes_dgf_final on commit drop as
select questao_id, curso_id, prioridade
from public.curso_questoes
where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid
  and questao_id in (775, 849);

create temporary table _hash_outras_curso_questoes_antes_dgf_final on commit drop as
select md5(string_agg(questao_id::text || ':' || curso_id::text || ':' || prioridade::text, '|' order by questao_id, curso_id)) as h
from public.curso_questoes
where not (curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid and questao_id in (775, 849));

-- ================= PRECONDICOES =================
do $$
declare
  v_qtd_vinculos int;
  v_qtd_curso_questoes int;
begin
  select count(*) into v_qtd_vinculos from _snapshot_old_vinculos_dgf_final;
  if v_qtd_vinculos <> 6 then
    raise exception 'PRECOND: esperado exatamente 6 vinculos a remover (46xU1,46xU2,112xU1,326xU1,775xU2,849xU2), encontrado % — possivel alteracao concorrente ou reexecucao, abortar', v_qtd_vinculos;
  end if;

  select count(*) into v_qtd_curso_questoes from _snapshot_old_curso_questoes_dgf_final;
  if v_qtd_curso_questoes <> 2 then
    raise exception 'PRECOND: esperado exatamente 2 linhas de curso_questoes a remover (775, 849), encontrado % — possivel alteracao concorrente ou reexecucao, abortar', v_qtd_curso_questoes;
  end if;

  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=46 and unidade_pedagogica_id='0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid) then
    raise exception 'PRECOND: vinculo 46xU1 nao encontrado';
  end if;
  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=46 and unidade_pedagogica_id='f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid) then
    raise exception 'PRECOND: vinculo 46xU2 nao encontrado';
  end if;
  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=112 and unidade_pedagogica_id='0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid) then
    raise exception 'PRECOND: vinculo 112xU1 nao encontrado';
  end if;
  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=326 and unidade_pedagogica_id='0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid) then
    raise exception 'PRECOND: vinculo 326xU1 nao encontrado';
  end if;
  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=775 and unidade_pedagogica_id='f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid) then
    raise exception 'PRECOND: vinculo 775xU2 nao encontrado';
  end if;
  if not exists (select 1 from _snapshot_old_vinculos_dgf_final where questao_id=849 and unidade_pedagogica_id='f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid) then
    raise exception 'PRECOND: vinculo 849xU2 nao encontrado';
  end if;

  raise notice 'PRECOND OK: os 6 vinculos-alvo e as 2 linhas de curso_questoes-alvo existem exatamente como auditado na Fase 9.0.1';
end $$;

-- ================= APPLY =================
delete from public.questao_unidades_pedagogicas
where (questao_id, unidade_pedagogica_id) in (
  (46, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (46, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
  (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid)
);

delete from public.curso_questoes
where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid
  and questao_id in (775, 849);

-- ================= POSCONDICOES =================
do $$
declare
  v_qtd_vinculos_restantes int;
  v_qtd_cq_restantes int;
  v_total_u1 int;
  v_total_u2 int;
  v_questoes_ativas_775 boolean;
  v_questoes_ativas_849 boolean;
begin
  select count(*) into v_qtd_vinculos_restantes
  from public.questao_unidades_pedagogicas
  where (questao_id, unidade_pedagogica_id) in (
    (46, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (46, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
    (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
    (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid)
  );
  if v_qtd_vinculos_restantes <> 0 then raise exception 'POSCOND: ainda existem vinculos que deveriam ter sido removidos (%)', v_qtd_vinculos_restantes; end if;

  select count(*) into v_qtd_cq_restantes
  from public.curso_questoes
  where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid and questao_id in (775, 849);
  if v_qtd_cq_restantes <> 0 then raise exception 'POSCOND: ainda existem linhas de curso_questoes que deveriam ter sido removidas (%)', v_qtd_cq_restantes; end if;

  select count(*) into v_total_u1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;
  select count(*) into v_total_u2 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;
  if v_total_u1 <> 11 then raise exception 'POSCOND: esperado 11 questoes restantes vinculadas a U1 (14 - 46 - 112 - 326), encontrado %', v_total_u1; end if;
  if v_total_u2 <> 7 then raise exception 'POSCOND: esperado 7 questoes restantes vinculadas a U2 (10 - 46 - 775 - 849), encontrado %', v_total_u2; end if;

  -- confirma que 775 e 849 continuam existindo/ativas em public.questoes
  -- (nunca deletadas -- so removidas do fluxo deste curso).
  select ativa into v_questoes_ativas_775 from public.questoes where id = 775;
  select ativa into v_questoes_ativas_849 from public.questoes where id = 849;
  if v_questoes_ativas_775 is null then raise exception 'POSCOND: questao 775 foi apagada de public.questoes — NUNCA deveria acontecer'; end if;
  if v_questoes_ativas_849 is null then raise exception 'POSCOND: questao 849 foi apagada de public.questoes — NUNCA deveria acontecer'; end if;
  if v_questoes_ativas_775 is distinct from true then raise exception 'POSCOND: questao 775 teve seu campo ativa alterado — este patch nunca deveria toca-lo'; end if;
  if v_questoes_ativas_849 is distinct from true then raise exception 'POSCOND: questao 849 teve seu campo ativa alterado — este patch nunca deveria toca-lo'; end if;

  raise notice 'POSCOND OK: os 6 vinculos e as 2 linhas de curso_questoes-alvo foram removidos; 775 e 849 continuam intactas em public.questoes; U1 com 11 questoes, U2 com 7 questoes restantes';
end $$;

-- Confirma isolamento: nenhum outro vinculo, nenhuma outra linha de
-- curso_questoes (nem deste nem de outro curso) foi tocada.
do $$
declare
  v_hash_vinculos_depois text;
  v_hash_vinculos_antes text;
  v_hash_cq_depois text;
  v_hash_cq_antes text;
begin
  select h into v_hash_vinculos_antes from _hash_outros_vinculos_antes_dgf_final;
  select md5(string_agg(questao_id::text || ':' || unidade_pedagogica_id::text, '|' order by questao_id, unidade_pedagogica_id))
  into v_hash_vinculos_depois
  from public.questao_unidades_pedagogicas
  where not ((questao_id, unidade_pedagogica_id) in (
    (46, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (46, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
    (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid),
    (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
    (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid)
  ));
  if v_hash_vinculos_depois is distinct from v_hash_vinculos_antes then
    raise exception 'POSCOND: outros vinculos questao_unidades_pedagogicas mudaram — vazamento do DELETE';
  end if;

  select h into v_hash_cq_antes from _hash_outras_curso_questoes_antes_dgf_final;
  select md5(string_agg(questao_id::text || ':' || curso_id::text || ':' || prioridade::text, '|' order by questao_id, curso_id))
  into v_hash_cq_depois
  from public.curso_questoes
  where not (curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid and questao_id in (775, 849));
  if v_hash_cq_depois is distinct from v_hash_cq_antes then
    raise exception 'POSCOND: outras linhas de curso_questoes mudaram — vazamento do DELETE (inclusive de outros cursos)';
  end if;

  raise notice 'POSCOND OK: nenhum outro vinculo e nenhuma outra linha de curso_questoes (deste ou de outro curso) foi tocada';
end $$;

commit;
