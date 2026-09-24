-- TESTE DE ROLLBACK — ATUALIZACAO DO ESCOPO FINAL (fluxo completo OLD ->
-- TARGET -> REVERT -> OLD_FINAL -> ROLLBACK; NAO aplica nada permanente;
-- ver atualizar_escopo_artigos_esperados_dgf_u2_final.sql para o apply
-- real) — unidade "Garantias Constitucionais e Remedios Constitucionais"
-- (BM RS) — curadoria completa Fase 9,
-- REVISADA na Fase 9.0.1 (mesma lista de 24 dispositivos da Fase 9 —
-- a revisao humana pediu reavaliacao por BLOCOS PEDAGOGICOS, nao por
-- numero bruto de incisos; nenhum item foi removido apos essa
-- reavaliacao, ver classificacao CORE/APOIO_DO_BLOCO abaixo).
--
-- Mandato: "PAPIRO — FASE 9.0.1 — REVISAO FINAL DA CURADORIA DGF ANTES
-- DO ROLLBACK TEST", secao 7. Classificacao tecnica:
-- UPDATE_CANONICAL_EXISTING_SCOPE (mesmo padrao ja usado em
-- atualizar_escopo_lei_tortura_art1_iii.sql e
-- atualizar_artigos_esperados_dgf_u1_inciso_viii.sql).
--
-- Diferenca desta rodada: U2 NUNCA teve aula gerada (0 aulas, 0
-- aula_versoes, 0 aula_geracoes — confirmado na Fase 9), entao este
-- ESCOPO_FINAL_U2 nao e uma correcao de conteudo ja ensinado (como os
-- patches da U1) — e a definicao do escopo que sera efetivamente usado
-- quando a aula da U2 for gerada no futuro (fora do escopo desta
-- mandato: "NAO gerar U2"). A Fase 9.0.1 tambem reafirma: nao criar 24
-- mini-aulas — a futura aula deve agrupar estes 24 dispositivos em
-- aproximadamente 6-8 componentes conceituais coerentes (nao um
-- componente por inciso). Essa decisao de AGRUPAMENTO fica registrada
-- para quando a aula for de fato gerada; nao afeta este patch (que so
-- toca a unidade_pedagogica, nao a aula).
--
-- CLASSIFICACAO POR BLOCO (relatorio completo da Fase 9.0.1, secoes M/N):
--
--   BLOCO 1 -- tratamento desumano/degradante: III (CORE, ja
--   configurado; sem questao propria remanescente na U2 apos a 775 ser
--   excluida do fluxo — ver mover_e_excluir_questoes_dgf_final.sql —
--   mas fundacional ao proprio escopo ja escrito da unidade).
--
--   BLOCO 2 -- propriedade/informacao/peticao: XXXIII (CORE — gabarito
--   real da questao 112, alem de item V/F graduado na questao 326;
--   ambas questoes hibridas destinadas a Missao Final, que NAO pode
--   introduzir materia inedita — logo o bloco precisa estar
--   efetivamente ensinado na U2 antes da Missao Final acontecer);
--   XXIV, XXVI (APOIO_DO_BLOCO — distratores fundamentados da questao
--   112, necessarios para o aluno eliminar as alternativas erradas
--   dessa mesma questao-ancora); XXV, XXXIV (APOIO_DO_BLOCO — itens
--   V/F graduados da questao 326, cuja resposta final V-F-V-F exige
--   avaliar TODOS os 4 itens, nao apenas o item de XII que pertence a
--   U1).
--
--   BLOCO 3 -- garantias penais: XXXIX, XL, XLII, XLVII (CORE —
--   garantias penais classicas/alta frequencia, XXXIX testado na
--   questao 46, XLVII gabarito real da questao 848); XLIII, XLIV, XLV,
--   XLVI (APOIO_DO_BLOCO — formam com os 4 CORE UM UNICO bloco
--   coerente "regime constitucional das penas", cada um com
--   fundamentacao textual explicita na propria explicacao da questao
--   662 — nao sao distratores isolados sem conexao, e sim a explicacao
--   INTEIRA de uma unica questao real ja selecionada).
--
--   BLOCO 4 -- direitos dos presos: XLIX, L (CORE — gabaritos/itens
--   diretos das questoes 662, 846, 849).
--
--   BLOCO 5 -- devido processo/contraditorio/ampla defesa: LV (CORE —
--   gabarito real da questao 2724); LIV (APOIO_DO_BLOCO — sem questao
--   propria nesta amostra, mas e o proprio fundamento textual que da
--   nome ao bloco "devido processo legal", ja descrito no escopo desde
--   a configuracao original da unidade).
--
--   BLOCO 6 -- aplicacao imediata: §1º (CORE — testado explicitamente
--   na questao 846, item 2).
--
--   BLOCO 7 -- remedios constitucionais: LXVIII, LXIX, LXXI, LXXII
--   (CORE — cada um e gabarito real de pelo menos uma questao entre
--   657/663/2725); LXXIII (APOIO_DO_BLOCO — distrator fundamentado da
--   questao 663, completando o conjunto usual dos 5 remedios
--   constitucionais que a propria questao real ja cobra em bloco).
--
--   REMOVER: nenhum. LXX foi avaliado e permanece fora (nem CORE nem
--   APOIO — nenhuma das 23 questoes da curadoria o exige, unico
--   sub-ponto do LXIX sem qualquer evidencia real).
--
-- Total: 10 -> 24 artigos_esperados (inalterado desde a Fase 9). Escopo
-- textual reescrito para refletir os novos blocos tematicos, mantendo a
-- exclusao expressa dos temas da Unidade 1 (agora incluindo tambem
-- "associacao" e "locomocao", que ganharam XIX e XV nesta mesma rodada
-- — ver atualizar_artigos_esperados_dgf_u1_final.sql).
--
-- NAO toca: aulas, aula_versoes, questoes, curso_conteudos, ou qualquer
-- outra unidade_pedagogica. NAO gera aula. NAO chama OpenAI.
--
-- Este arquivo E o teste de rollback (preparado nesta mesma rodada);
-- execucao contra LIVE fica para uma fase de rollback-test dedicada,
-- nao esta.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_unidade_u2_final on commit drop as
select id, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

create temporary table _hash_outras_unidades_antes_u2_final on commit drop as
select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id)) as h
from public.unidades_pedagogicas
where id <> 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_escopo text;
  v_artigos text[];
  v_hash_escopo text;
  v_qtd int;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

  if v_escopo is null then raise exception 'PRECOND: unidade nao encontrada'; end if;

  select md5(v_escopo) into v_hash_escopo;
  if v_hash_escopo <> '2a1606af8de4c6ef4660cef2b6bb9f1e' then
    raise exception 'PRECOND: hash do escopo atual diverge do estado auditado na Fase 9 — possivel alteracao concorrente, abortar';
  end if;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 10 then raise exception 'PRECOND: esperado 10 artigos_esperados atuais, encontrado %', v_qtd; end if;
  if v_artigos <> ARRAY['art. 5º, III', 'art. 5º, XLVII', 'art. 5º, XLIX', 'art. 5º, L', 'art. 5º, LIV', 'art. 5º, LV', 'art. 5º, LXVIII', 'art. 5º, LXIX', 'art. 5º, LXXI', 'art. 5º, LXXII'] then
    raise exception 'PRECOND: artigos_esperados atual diverge do esperado (conteudo ou ordem) — abortar';
  end if;

  -- confirma que esta unidade continua sem aula (este patch NUNCA
  -- deveria rodar depois de uma geracao real ja ter comecado).
  if exists (select 1 from public.aulas where unidade_pedagogica_id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid) then
    raise exception 'PRECOND: ja existe aula para esta unidade — este patch e so para pre-geracao, abortar';
  end if;

  raise notice 'PRECOND OK: escopo identico ao estado auditado (hash confere), artigos_esperados identico ao esperado (10 itens), nenhuma aula existe ainda';
end $$;

-- ================= APPLY =================
update public.unidades_pedagogicas
set
  escopo = 'Constituição Federal de 1988, art. 5º: devido processo legal, contraditório e ampla defesa (inclusive em processo administrativo), aplicação imediata das normas definidoras dos direitos e garantias fundamentais (§1º), direito de petição e obtenção de certidões independentemente do pagamento de taxas, direito de acesso a informações dos órgãos públicos, desapropriação por necessidade ou utilidade pública ou por interesse social, requisição administrativa em caso de iminente perigo público, proteção à pequena propriedade rural trabalhada pela família contra penhora por débitos da atividade produtiva, garantias penais (legalidade e anterioridade penal, retroatividade da lei penal benéfica, imprescritibilidade do racismo e da ação de grupos armados contra a ordem constitucional, inafiançabilidade e vedação de graça/anistia ao tráfico de entorpecentes/tortura/terrorismo/crimes hediondos, individualização da pena, limite da pena à pessoa do condenado e extensão da obrigação de reparar o dano/perdimento de bens aos sucessores), direitos dos presos (integridade física e moral, condições para amamentação), vedação de penas (morte, caráter perpétuo, trabalhos forçados, banimento, cruéis) e vedação a tratamento desumano ou degradante, remédios constitucionais (habeas corpus, habeas data, mandado de segurança, mandado de injunção, ação popular). Não incluir os direitos individuais básicos já tratados na Unidade 1 (igualdade, liberdade, intimidade, domicílio, sigilo, religião, expressão, locomoção, reunião, associação).',
  artigos_esperados = ARRAY['art. 5º, III', 'art. 5º, XXIV', 'art. 5º, XXV', 'art. 5º, XXVI', 'art. 5º, XXXIII', 'art. 5º, XXXIV', 'art. 5º, XXXIX', 'art. 5º, XL', 'art. 5º, XLII', 'art. 5º, XLIII', 'art. 5º, XLIV', 'art. 5º, XLV', 'art. 5º, XLVI', 'art. 5º, XLVII', 'art. 5º, XLIX', 'art. 5º, L', 'art. 5º, LIV', 'art. 5º, LV', 'art. 5º, §1º', 'art. 5º, LXVIII', 'art. 5º, LXIX', 'art. 5º, LXXI', 'art. 5º, LXXII', 'art. 5º, LXXIII']
where id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

-- ================= POSCONDICOES =================
do $$
declare
  v_artigos text[];
  v_qtd int;
  v_todos_antigos_presentes boolean;
  v_sem_duplicata boolean;
  v_escopo text;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 24 then raise exception 'POSCOND: esperado 24 artigos_esperados, encontrado %', v_qtd; end if;

  select ARRAY['art. 5º, III', 'art. 5º, XLVII', 'art. 5º, XLIX', 'art. 5º, L', 'art. 5º, LIV', 'art. 5º, LV', 'art. 5º, LXVIII', 'art. 5º, LXIX', 'art. 5º, LXXI', 'art. 5º, LXXII'] <@ v_artigos into v_todos_antigos_presentes;
  if not v_todos_antigos_presentes then raise exception 'POSCOND: um ou mais artigos_esperados antigos foram perdidos'; end if;

  select (select count(*) from unnest(v_artigos) x) = (select count(distinct x) from unnest(v_artigos) x) into v_sem_duplicata;
  if not v_sem_duplicata then raise exception 'POSCOND: ha duplicacao em artigos_esperados'; end if;

  if not ('art. 5º, §1º' = any(v_artigos)) then raise exception 'POSCOND: art. 5º, §1º nao foi adicionado'; end if;
  if not ('art. 5º, XXXIX' = any(v_artigos)) then raise exception 'POSCOND: art. 5º, XXXIX nao foi adicionado'; end if;
  if 'art. 5º, LXX' = any(v_artigos) then raise exception 'POSCOND: art. 5º, LXX NAO deveria ter sido incluido (sem incidencia real nesta curadoria)'; end if;

  if v_artigos <> ARRAY['art. 5º, III', 'art. 5º, XXIV', 'art. 5º, XXV', 'art. 5º, XXVI', 'art. 5º, XXXIII', 'art. 5º, XXXIV', 'art. 5º, XXXIX', 'art. 5º, XL', 'art. 5º, XLII', 'art. 5º, XLIII', 'art. 5º, XLIV', 'art. 5º, XLV', 'art. 5º, XLVI', 'art. 5º, XLVII', 'art. 5º, XLIX', 'art. 5º, L', 'art. 5º, LIV', 'art. 5º, LV', 'art. 5º, §1º', 'art. 5º, LXVIII', 'art. 5º, LXIX', 'art. 5º, LXXI', 'art. 5º, LXXII', 'art. 5º, LXXIII'] then
    raise exception 'POSCOND: ordem/conteudo final de artigos_esperados diverge do esperado';
  end if;

  if position('devido processo legal' in v_escopo) = 0 then raise exception 'POSCOND: escopo perdeu o tema devido processo legal'; end if;
  if position('§1º' in v_escopo) = 0 then raise exception 'POSCOND: escopo nao menciona §1º'; end if;
  if position('ação popular' in v_escopo) = 0 then raise exception 'POSCOND: escopo nao menciona acao popular'; end if;
  if position('Unidade 1' in v_escopo) = 0 then raise exception 'POSCOND: escopo perdeu a exclusao expressa dos temas da Unidade 1'; end if;

  raise notice 'POSCOND OK: 24 artigos_esperados (10 antigos preservados + 14 novos), sem duplicatas, LXX corretamente ausente, escopo textual reescrito com os novos blocos tematicos';
end $$;

-- Confirma que NENHUMA outra unidade foi tocada.
do $$
declare
  v_hash_depois text;
  v_hash_antes text;
begin
  select h into v_hash_antes from _hash_outras_unidades_antes_u2_final;
  select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id))
  into v_hash_depois
  from public.unidades_pedagogicas
  where id <> 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS unidades_pedagogicas mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'POSCOND OK: nenhuma outra unidade_pedagogica foi tocada (hash de conteudo identico)';
end $$;

-- ================= REVERT (restaura a partir do snapshot OLD) =================
update public.unidades_pedagogicas up
set
  escopo = t.escopo,
  artigos_esperados = t.artigos_esperados
from _snapshot_old_unidade_u2_final t
where up.id = t.id;

-- ================= OLD_FINAL (confirma identidade byte-a-byte com OLD) =================
do $$
declare
  v_escopo_igual boolean;
  v_artigos_igual boolean;
begin
  select (up.escopo = t.escopo), (up.artigos_esperados = t.artigos_esperados)
  into v_escopo_igual, v_artigos_igual
  from public.unidades_pedagogicas up
  join _snapshot_old_unidade_u2_final t on t.id = up.id
  where up.id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid;

  if not v_escopo_igual then raise exception 'OLD_FINAL: escopo NAO retornou identico ao original'; end if;
  if not v_artigos_igual then raise exception 'OLD_FINAL: artigos_esperados NAO retornou identico ao original'; end if;

  raise notice 'OLD_FINAL OK: escopo e artigos_esperados identicos ao estado OLD original (10 itens) — reversao comprovada';
end $$;

rollback;
