-- Curadoria da base programática: vincula public.curso_materias.materia_id às
-- 17 correspondências exatas já confirmadas no diagnóstico, e cria + vincula as
-- 6 matérias globais novas (nenhuma delas unificada por heurística com matéria
-- global já existente — em especial, "Direitos Humanos" permanece distinta de
-- "Direitos Humanos e Cidadania" por decisão explícita).
--
-- Nenhum nome/peso/ordem das 23 curso_materias é alterado. Nenhuma curso_conteudos
-- é criada aqui. Nenhum matching por nome é usado nos UPDATEs — os 17 pares são
-- hardcoded conforme o diagnóstico aprovado, e os 6 novos usam os ids capturados
-- via RETURNING no momento da criação, não um SELECT por nome no momento do UPDATE.
--
-- Idempotente por construção: os INSERTs só ocorrem se uma matéria com aquele nome
-- exato ainda não existir (evita duplicar matéria em reexecução); todos os UPDATEs
-- só afetam linhas com materia_id ainda nulo (evita sobrescrever qualquer vínculo
-- já existente, inclusive um definido manualmente fora deste script).
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- B) 17 correspondências exatas — pares fixos (curso_materia_id -> materia_id)
-- conforme diagnóstico aprovado. Cada UPDATE só age se materia_id ainda for nulo.
-- ============================================================================
update public.curso_materias set materia_id = 13, atualizado_em = now() where id = 20 and materia_id is null; -- Conhecimentos Gerais
update public.curso_materias set materia_id = 11, atualizado_em = now() where id = 22 and materia_id is null; -- Direitos Humanos e Cidadania
update public.curso_materias set materia_id = 9,  atualizado_em = now() where id = 23 and materia_id is null; -- Informática
update public.curso_materias set materia_id = 10, atualizado_em = now() where id = 19 and materia_id is null; -- Legislação Específica
update public.curso_materias set materia_id = 6,  atualizado_em = now() where id = 18 and materia_id is null; -- Língua Portuguesa
update public.curso_materias set materia_id = 12, atualizado_em = now() where id = 21 and materia_id is null; -- Matemática
update public.curso_materias set materia_id = 3,  atualizado_em = now() where id = 3  and materia_id is null; -- Direito Constitucional
update public.curso_materias set materia_id = 5,  atualizado_em = now() where id = 4  and materia_id is null; -- Direito Penal
update public.curso_materias set materia_id = 2,  atualizado_em = now() where id = 2  and materia_id is null; -- Legislação de Guardas Municipais
update public.curso_materias set materia_id = 4,  atualizado_em = now() where id = 6  and materia_id is null; -- Legislação de Trânsito
update public.curso_materias set materia_id = 6,  atualizado_em = now() where id = 1  and materia_id is null; -- Língua Portuguesa
update public.curso_materias set materia_id = 3,  atualizado_em = now() where id = 11 and materia_id is null; -- Direito Constitucional
update public.curso_materias set materia_id = 5,  atualizado_em = now() where id = 13 and materia_id is null; -- Direito Penal
update public.curso_materias set materia_id = 7,  atualizado_em = now() where id = 14 and materia_id is null; -- Direito Processual Penal
update public.curso_materias set materia_id = 9,  atualizado_em = now() where id = 10 and materia_id is null; -- Informática
update public.curso_materias set materia_id = 8,  atualizado_em = now() where id = 15 and materia_id is null; -- Legislação Penal Especial
update public.curso_materias set materia_id = 6,  atualizado_em = now() where id = 8  and materia_id is null; -- Língua Portuguesa

-- ============================================================================
-- A) + C) Criação das 6 matérias globais novas + vínculo às 6 curso_materias
-- restantes, usando os ids capturados no momento da criação (sem novo matching
-- por nome no UPDATE).
-- ============================================================================
do $$
declare
  v_id_alvorada bigint;
  v_id_criminalistica bigint;
  v_id_dir_administrativo bigint;
  v_id_medicina_legal bigint;
  v_id_raciocinio_logico bigint;
  v_id_direitos_humanos bigint;
begin
  -- Conhecimentos sobre Alvorada
  select id into v_id_alvorada from public.materias where trim(nome) = 'Conhecimentos sobre Alvorada';
  if v_id_alvorada is null then
    insert into public.materias (nome, usuario_id) values ('Conhecimentos sobre Alvorada', null)
    returning id into v_id_alvorada;
  end if;

  -- Criminalística
  select id into v_id_criminalistica from public.materias where trim(nome) = 'Criminalística';
  if v_id_criminalistica is null then
    insert into public.materias (nome, usuario_id) values ('Criminalística', null)
    returning id into v_id_criminalistica;
  end if;

  -- Direito Administrativo
  select id into v_id_dir_administrativo from public.materias where trim(nome) = 'Direito Administrativo';
  if v_id_dir_administrativo is null then
    insert into public.materias (nome, usuario_id) values ('Direito Administrativo', null)
    returning id into v_id_dir_administrativo;
  end if;

  -- Medicina Legal
  select id into v_id_medicina_legal from public.materias where trim(nome) = 'Medicina Legal';
  if v_id_medicina_legal is null then
    insert into public.materias (nome, usuario_id) values ('Medicina Legal', null)
    returning id into v_id_medicina_legal;
  end if;

  -- Raciocínio Lógico
  select id into v_id_raciocinio_logico from public.materias where trim(nome) = 'Raciocínio Lógico';
  if v_id_raciocinio_logico is null then
    insert into public.materias (nome, usuario_id) values ('Raciocínio Lógico', null)
    returning id into v_id_raciocinio_logico;
  end if;

  -- Direitos Humanos (mantida distinta de "Direitos Humanos e Cidadania" por decisão explícita)
  select id into v_id_direitos_humanos from public.materias where trim(nome) = 'Direitos Humanos';
  if v_id_direitos_humanos is null then
    insert into public.materias (nome, usuario_id) values ('Direitos Humanos', null)
    returning id into v_id_direitos_humanos;
  end if;

  -- Vínculos, usando diretamente as variáveis capturadas acima.
  update public.curso_materias set materia_id = v_id_alvorada, atualizado_em = now()
    where id = 7 and materia_id is null; -- Conhecimentos sobre Alvorada

  update public.curso_materias set materia_id = v_id_direitos_humanos, atualizado_em = now()
    where id = 5 and materia_id is null; -- Direitos Humanos

  update public.curso_materias set materia_id = v_id_criminalistica, atualizado_em = now()
    where id = 16 and materia_id is null; -- Criminalística

  update public.curso_materias set materia_id = v_id_dir_administrativo, atualizado_em = now()
    where id = 12 and materia_id is null; -- Direito Administrativo

  update public.curso_materias set materia_id = v_id_medicina_legal, atualizado_em = now()
    where id = 17 and materia_id is null; -- Medicina Legal

  update public.curso_materias set materia_id = v_id_raciocinio_logico, atualizado_em = now()
    where id = 9 and materia_id is null; -- Raciocínio Lógico
end;
$$;

COMMIT;
