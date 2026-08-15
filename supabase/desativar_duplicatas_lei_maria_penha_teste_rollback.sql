-- Teste RUNTIME da desativação lógica das 3 duplicatas confirmadas da Lei
-- Maria da Penha — TRANSACIONAL, tudo desfeito no final (ROLLBACK). Não
-- aplica nada de verdade — é para colar no SQL Editor do Supabase, rodar, e
-- conferir tudo_ok=true ANTES de rodar o arquivo real
-- (desativar_duplicatas_lei_maria_penha.sql).
--
-- Contexto: B4+B5 de diagnostico_pendencias_curadoria_lei_maria_penha.sql
-- confirmaram 3 pares de duplicata EXATA entre as questões ativas do
-- conteúdo 53 (curso_conteudos.id=53, materia_id=10, assunto_id=19):
--   129 (manter) / 864 (duplicata)
--   133 (manter) / 865 (duplicata)
--   134 (manter) / 863 (duplicata)
-- diagnostico_uso_duplicatas_lei_maria_penha.sql confirmou que as 6
-- questões têm 0 respostas/sessões/comentários/erros/revisões/
-- classificações — só 1 vínculo cada em curso_questoes, todos para o mesmo
-- curso (7543be16-4c5b-4cb6-8724-8fbdfb96f2d4, brigada-militar-rs).
--
-- Decisão de curadoria: preservar 129/133/134, desativar 863/864/865
-- (ativa=false — NUNCA DELETE). Não mexe em unidades_pedagogicas,
-- questao_unidades_pedagogicas, curso_questoes, alternativas, nem em
-- nenhuma outra questão além das 3 duplicatas.
--
-- Inspeção de segurança prévia (sem alterar nada): todo fluxo que pode
-- entregar questao_id a um aluno já filtra questoes.ativa=true no servidor
-- — ids_questoes_para_usuario (funcoes_curso_ativo.sql), iniciar_questoes_
-- da_missao (missao_refazer_rpc.sql, versão viva), selecionar_candidatas_
-- unidade_pedagogica/selecionar_candidatas_conteudo (missao_pratica_papiro_
-- rpc.sql, usadas por iniciar_pratica_unidade/iniciar_missao_final) e,
-- como segunda camada, registrar_resposta também exige q.ativa antes de
-- aceitar uma resposta. Nenhum desses fluxos precisou de correção.

BEGIN;

create temporary table teste_desativar_duplicatas_resultados (
  chave text primary key,
  ok boolean
);

-- Snapshots completos ANTES do UPDATE — usados para provar que nada além de
-- questoes.ativa das 3 duplicatas mudou em qualquer lugar do banco.
create temporary table snapshot_questoes_antes as
select id, materia_id, assunto_id, ativa, enunciado
from public.questoes;

create temporary table snapshot_alternativas_antes as
select id, questao_id, texto, ordem, correta
from public.alternativas;

create temporary table snapshot_curso_questoes_antes as
select questao_id, curso_id, prioridade
from public.curso_questoes;

do $$
declare
  v_duplicatas constant bigint[] := array[863, 864, 865];
  v_canonicas constant bigint[] := array[129, 133, 134];
  v_materia_esperada constant bigint := 10;
  v_assunto_esperado constant bigint := 19;
  v_curso_esperado constant uuid := '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4';
  v_id bigint;
  v_materia bigint;
  v_assunto bigint;
  v_ativa boolean;
  v_qtd_respostas integer;
  v_qtd_sessoes integer;
  v_qtd_comentarios integer;
  v_qtd_erros integer;
  v_qtd_revisoes integer;
  v_qtd_classificacoes integer;
  v_qtd_curso_questoes integer;
  v_curso_do_vinculo uuid;
  v_linhas_afetadas integer;
  v_questoes_alteradas integer;
  v_alternativas_alteradas integer;
  v_curso_questoes_alterado integer;
begin
  -- ---- ANTES: checagem individual de cada duplicata ----
  foreach v_id in array v_duplicatas loop
    select materia_id, assunto_id, ativa into v_materia, v_assunto, v_ativa
    from public.questoes where id = v_id;

    if v_materia is null then
      raise exception 'Teste abortado: questao % nao encontrada.', v_id;
    end if;

    select count(*) into v_qtd_respostas from public.respostas_usuarios where questao_id = v_id;
    select count(*) into v_qtd_sessoes from public.sessao_questoes_planejadas where questao_id = v_id;
    select count(*) into v_qtd_comentarios from public.questao_comentarios where questao_id = v_id;

    select count(*) into v_qtd_erros
    from public.erros_usuarios eu
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    where ru.questao_id = v_id;

    select count(*) into v_qtd_revisoes
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    where ru.questao_id = v_id;

    select count(*) into v_qtd_classificacoes
    from public.questao_unidades_pedagogicas where questao_id = v_id;

    select count(*) into v_qtd_curso_questoes from public.curso_questoes where questao_id = v_id;
    select curso_id into v_curso_do_vinculo from public.curso_questoes where questao_id = v_id limit 1;

    insert into teste_desativar_duplicatas_resultados values
      ('antes_' || v_id || '_existe', true),
      ('antes_' || v_id || '_ativa_true', v_ativa is true),
      ('antes_' || v_id || '_materia_10', v_materia = v_materia_esperada),
      ('antes_' || v_id || '_assunto_19', v_assunto = v_assunto_esperado),
      ('antes_' || v_id || '_sem_respostas', v_qtd_respostas = 0),
      ('antes_' || v_id || '_sem_sessoes_planejadas', v_qtd_sessoes = 0),
      ('antes_' || v_id || '_sem_comentarios', v_qtd_comentarios = 0),
      ('antes_' || v_id || '_sem_erros', v_qtd_erros = 0),
      ('antes_' || v_id || '_sem_revisoes', v_qtd_revisoes = 0),
      ('antes_' || v_id || '_sem_classificacao_unidade', v_qtd_classificacoes = 0),
      ('antes_' || v_id || '_exatamente_1_vinculo_curso', v_qtd_curso_questoes = 1),
      ('antes_' || v_id || '_vinculo_curso_esperado', v_curso_do_vinculo = v_curso_esperado);
  end loop;

  -- ---- ANTES: canônicas existem e estão ativas ----
  foreach v_id in array v_canonicas loop
    select ativa into v_ativa from public.questoes where id = v_id;
    insert into teste_desativar_duplicatas_resultados values
      ('antes_canonica_' || v_id || '_ativa_true', coalesce(v_ativa, false) is true);
  end loop;

  -- ---- A ÚNICA escrita deste script ----
  update public.questoes
  set ativa = false
  where id = any(v_duplicatas)
    and materia_id = v_materia_esperada
    and assunto_id = v_assunto_esperado
    and ativa = true;

  get diagnostics v_linhas_afetadas = row_count;
  insert into teste_desativar_duplicatas_resultados values
    ('update_afetou_exatamente_3', v_linhas_afetadas = 3);

  -- ---- DEPOIS: cada duplicata ficou false, materia/assunto preservados ----
  foreach v_id in array v_duplicatas loop
    select materia_id, assunto_id, ativa into v_materia, v_assunto, v_ativa
    from public.questoes where id = v_id;
    insert into teste_desativar_duplicatas_resultados values
      ('depois_' || v_id || '_ativa_false', v_ativa is false),
      ('depois_' || v_id || '_materia_continua_10', v_materia = v_materia_esperada),
      ('depois_' || v_id || '_assunto_continua_19', v_assunto = v_assunto_esperado);
  end loop;

  -- ---- DEPOIS: canônicas continuam ativas ----
  foreach v_id in array v_canonicas loop
    select ativa into v_ativa from public.questoes where id = v_id;
    insert into teste_desativar_duplicatas_resultados values
      ('depois_canonica_' || v_id || '_ativa_true', coalesce(v_ativa, false) is true);
  end loop;

  -- ---- Nenhuma OUTRA questão (fora as 3 duplicatas) mudou nada ----
  select count(*) into v_questoes_alteradas
  from public.questoes q
  join snapshot_questoes_antes s on s.id = q.id
  where not (q.id = any(v_duplicatas))
    and (
      q.materia_id is distinct from s.materia_id
      or q.assunto_id is distinct from s.assunto_id
      or q.ativa is distinct from s.ativa
      or q.enunciado is distinct from s.enunciado
    );
  insert into teste_desativar_duplicatas_resultados values
    ('nenhuma_outra_questao_alterada', v_questoes_alteradas = 0);

  -- ---- Enunciado das 3 duplicatas não mudou ----
  select count(*) into v_questoes_alteradas
  from public.questoes q
  join snapshot_questoes_antes s on s.id = q.id
  where q.id = any(v_duplicatas)
    and q.enunciado is distinct from s.enunciado;
  insert into teste_desativar_duplicatas_resultados values
    ('enunciados_das_duplicatas_nao_mudaram', v_questoes_alteradas = 0);

  -- ---- Nenhuma alternativa (de nenhuma questão) mudou — diff completo ----
  select count(*) into v_alternativas_alteradas
  from public.alternativas a
  full join snapshot_alternativas_antes s on s.id = a.id
  where a.id is null
     or s.id is null
     or a.questao_id is distinct from s.questao_id
     or a.texto is distinct from s.texto
     or a.ordem is distinct from s.ordem
     or a.correta is distinct from s.correta;
  insert into teste_desativar_duplicatas_resultados values
    ('alternativas_nao_mudaram', v_alternativas_alteradas = 0);

  -- ---- curso_questoes não mudou (nenhuma linha, de nenhuma questão) ----
  select count(*) into v_curso_questoes_alterado
  from public.curso_questoes cq
  full join snapshot_curso_questoes_antes s
    on s.questao_id = cq.questao_id and s.curso_id = cq.curso_id
  where cq.questao_id is null
     or s.questao_id is null
     or cq.prioridade is distinct from s.prioridade;
  insert into teste_desativar_duplicatas_resultados values
    ('curso_questoes_nao_mudou', v_curso_questoes_alterado = 0);

  -- ---- tudo_ok: AND de todas as linhas acima ----
  insert into teste_desativar_duplicatas_resultados
  select 'tudo_ok', not exists (
    select 1 from teste_desativar_duplicatas_resultados where ok is distinct from true
  );
exception when others then
  raise exception 'Teste de desativacao das duplicatas falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

select chave, ok
from teste_desativar_duplicatas_resultados
order by (chave = 'tudo_ok'), chave;

ROLLBACK;
