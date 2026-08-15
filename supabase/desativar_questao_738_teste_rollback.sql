-- Teste RUNTIME da desativação da questão 738 — TRANSACIONAL, tudo desfeito
-- no final (ROLLBACK). Não aplica nada de verdade — é para colar no SQL
-- Editor do Supabase, rodar, e conferir os resultados ANTES de rodar o
-- arquivo real (desativar_questao_738.sql).
--
-- Contexto: a questão 738 (materia_id=10 "Legislação Específica",
-- assunto_id=19 "Lei Maria da Penha") trata de violência doméstica contra
-- criança/adolescente — Lei 14.344/2022 (Lei Henry Borel), fora do escopo
-- do curso da Brigada Militar. Decisão de produto: NÃO criar assunto/
-- conteúdo novo para essa lei (não faz parte do edital deste curso) — só
-- desativar a questão 738, para que ela pare de aparecer como candidata na
-- curadoria e nas missões, sem apagar o registro nem alterar sua
-- classificação atual.
--
-- Este script SÓ desativa (ativa=false). Não muda materia_id, assunto_id,
-- enunciado, alternativas, nem nenhuma outra questão. Não mexe em
-- unidades_pedagogicas nem em questao_unidades_pedagogicas.

BEGIN;

create temporary table teste_738_desativar_resultados (
  chave text primary key,
  ok boolean
);

-- Snapshots completos de questoes e alternativas ANTES do UPDATE — usados
-- no final só para provar que nada além de questoes.ativa da linha 738
-- mudou em qualquer lugar do banco.
create temporary table snapshot_questoes_antes as
select id, materia_id, assunto_id, ativa, enunciado
from public.questoes;

create temporary table snapshot_alternativas_antes as
select id, questao_id, texto, ordem, correta
from public.alternativas;

do $$
declare
  v_questao_id constant bigint := 738;
  v_materia_esperada constant bigint := 10;
  v_assunto_esperado constant bigint := 19;
  v_materia_antes bigint;
  v_assunto_antes bigint;
  v_ativa_antes boolean;
  v_enunciado_antes text;
  v_encontrada_depois integer;
  v_materia_depois bigint;
  v_assunto_depois bigint;
  v_ativa_depois boolean;
  v_enunciado_depois text;
  v_outras_questoes_alteradas integer;
  v_alternativas_alteradas integer;
begin
  -- ---- ANTES: confirma o estado esperado antes de alterar qualquer coisa ----
  select materia_id, assunto_id, ativa, enunciado
  into v_materia_antes, v_assunto_antes, v_ativa_antes, v_enunciado_antes
  from public.questoes
  where id = v_questao_id
  for update;

  if v_materia_antes is null then
    raise exception 'Teste abortado: questao % nao encontrada.', v_questao_id;
  end if;
  if v_materia_antes <> v_materia_esperada then
    raise exception 'Teste abortado: questao % tem materia_id=% (esperava %) — confira antes de prosseguir.', v_questao_id, v_materia_antes, v_materia_esperada;
  end if;
  if v_assunto_antes <> v_assunto_esperado then
    raise exception 'Teste abortado: questao % tem assunto_id=% (esperava %) — confira antes de prosseguir.', v_questao_id, v_assunto_antes, v_assunto_esperado;
  end if;
  if v_ativa_antes is distinct from true then
    raise exception 'Teste abortado: questao % nao esta ativa=true antes da alteracao (ativa=%).', v_questao_id, v_ativa_antes;
  end if;

  -- ---- A ÚNICA escrita deste script ----
  update public.questoes
  set ativa = false
  where id = v_questao_id;

  -- ---- DEPOIS: confere o resultado da própria questão 738 ----
  select count(*) into v_encontrada_depois from public.questoes where id = v_questao_id;

  select materia_id, assunto_id, ativa, enunciado
  into v_materia_depois, v_assunto_depois, v_ativa_depois, v_enunciado_depois
  from public.questoes
  where id = v_questao_id;

  -- ---- Nenhuma OUTRA questão pode ter mudado (diff completo contra o snapshot) ----
  select count(*)
  into v_outras_questoes_alteradas
  from public.questoes q
  join snapshot_questoes_antes s on s.id = q.id
  where q.id <> v_questao_id
    and (
      q.materia_id is distinct from s.materia_id
      or q.assunto_id is distinct from s.assunto_id
      or q.ativa is distinct from s.ativa
      or q.enunciado is distinct from s.enunciado
    );

  -- ---- Nenhuma alternativa (de nenhuma questão, incluindo a 738) pode ter
  -- mudado — full outer join pelo id pega alteração, inserção OU remoção ----
  select count(*)
  into v_alternativas_alteradas
  from public.alternativas a
  full join snapshot_alternativas_antes s on s.id = a.id
  where a.id is null
     or s.id is null
     or a.questao_id is distinct from s.questao_id
     or a.texto is distinct from s.texto
     or a.ordem is distinct from s.ordem
     or a.correta is distinct from s.correta;

  insert into teste_738_desativar_resultados values
    ('questao_738_existia_antes', v_materia_antes is not null),
    ('materia_id_era_10_antes', v_materia_antes = v_materia_esperada),
    ('assunto_id_era_19_antes', v_assunto_antes = v_assunto_esperado),
    ('ativa_era_true_antes', v_ativa_antes = true),
    ('questao_738_continua_existindo', v_encontrada_depois = 1),
    ('materia_id_continua_10', coalesce(v_materia_depois, -1) = v_materia_esperada),
    ('assunto_id_continua_19', coalesce(v_assunto_depois, -1) = v_assunto_esperado),
    ('ativa_agora_false', v_ativa_depois = false),
    ('enunciado_nao_mudou', v_enunciado_depois is not distinct from v_enunciado_antes),
    ('nenhuma_outra_questao_alterada', v_outras_questoes_alteradas = 0),
    ('alternativas_nao_mudaram', v_alternativas_alteradas = 0);
exception when others then
  raise exception 'Teste de desativacao da questao 738 falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

select
  (select ok from teste_738_desativar_resultados where chave = 'questao_738_existia_antes') as questao_738_existia_antes,
  (select ok from teste_738_desativar_resultados where chave = 'materia_id_era_10_antes') as materia_id_era_10_antes,
  (select ok from teste_738_desativar_resultados where chave = 'assunto_id_era_19_antes') as assunto_id_era_19_antes,
  (select ok from teste_738_desativar_resultados where chave = 'ativa_era_true_antes') as ativa_era_true_antes,
  (select ok from teste_738_desativar_resultados where chave = 'questao_738_continua_existindo') as questao_738_continua_existindo,
  (select ok from teste_738_desativar_resultados where chave = 'materia_id_continua_10') as materia_id_continua_10,
  (select ok from teste_738_desativar_resultados where chave = 'assunto_id_continua_19') as assunto_id_continua_19,
  (select ok from teste_738_desativar_resultados where chave = 'ativa_agora_false') as ativa_agora_false,
  (select ok from teste_738_desativar_resultados where chave = 'enunciado_nao_mudou') as enunciado_nao_mudou,
  (select ok from teste_738_desativar_resultados where chave = 'nenhuma_outra_questao_alterada') as nenhuma_outra_questao_alterada,
  (select ok from teste_738_desativar_resultados where chave = 'alternativas_nao_mudaram') as alternativas_nao_mudaram,
  not exists (
    select 1 from teste_738_desativar_resultados where ok is distinct from true
  ) as tudo_ok;

ROLLBACK;
