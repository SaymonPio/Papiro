-- Curadoria das unidades pedagógicas de Improbidade Administrativa
-- (curso_conteudos.id = 55), seguindo exatamente o padrão validado em
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um único curso_conteudos (id 55, assunto "Improbidade Administrativa",
-- materia_id 10, curso_materia_id 19, curso Brigada Militar RS) e dois
-- recortes pedagógicos, aprovados na etapa de análise anterior:
--   Unidade 1 (ordem 1): Atos de Improbidade Administrativa
--   Unidade 2 (ordem 2): Sujeitos, Sanções e Processo de Improbidade
--
-- Assim como Direitos e Garantias Fundamentais, este conteúdo NÃO tem
-- nenhuma aula publicada nem em rascunho hoje (0 linhas em public.aulas
-- para a unidade padrão) — não há nenhum remapeamento de aula existente a
-- fazer, só a divisão da unidade em si. Este arquivo não cria, publica nem
-- gera nenhuma aula.
--
-- Unidade 2 usa um id explícito (em vez de deixar gen_random_uuid()
-- decidir) para que este mesmo id possa ser referenciado, de forma
-- determinística, pelos arquivos de classificação de questões que dependem
-- dele (classificar_questoes_unidades_improbidade*.sql) — todos escritos e
-- revisados ANTES da aplicação real, portanto precisam de um id conhecido
-- de antemão.
--
-- Não altera nenhuma questão, alternativa ou vínculo de curso_questoes.
-- Não escreve em questao_unidades_pedagogicas — isso é feito exclusivamente
-- pelos arquivos classificar_questoes_unidades_improbidade*.sql, via a RPC
-- oficial classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 55;
  v_unidade_1_id constant uuid := '60927a85-1b4a-480a-b8da-8eb318520692';
  v_unidade_2_id constant uuid := '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84';
  v_unidade_padrao uuid;
begin
  -- Precondição: o conteúdo canônico é realmente "Improbidade
  -- Administrativa", na matéria/curso esperados (Legislação Específica,
  -- Brigada Militar RS) — mesmo princípio de verificação de Direitos e
  -- Garantias Fundamentais e da Lei Maria da Penha.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Improbidade Administrativa'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Improbidade Administrativa nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 55 nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_1_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_1_id;
  end if;

  -- Garante que nenhuma outra unidade já ocupa ordem=2 para este conteúdo
  -- (execução repetida não deveria criar duplicata silenciosa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem = 2 and id <> v_unidade_2_id
  ) then
    raise exception 'Ja existe uma unidade ordem=2 diferente da esperada para o conteudo 55';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Atos de Improbidade Administrativa',
    escopo = 'Lei 8.429/1992 (redação da Lei 14.230/2021), arts. 9º, 10 e 11: as três categorias de ato de improbidade — enriquecimento ilícito, prejuízo ao erário e atentado aos princípios da Administração — e a exigência de dolo específico como elemento subjetivo introduzida pela reforma de 2021. Não incluir sujeitos ativos/passivos e âmbito de aplicação (arts. 1º-3º), sanções (art. 12), prescrição (art. 23), responsabilidade sucessória (art. 8º-A), procedimento/representação/indisponibilidade de bens/ação de improbidade (art. 17) nem acordo de não persecução civil (art. 17-B) — já tratados na Unidade 2.',
    artigos_esperados = array['art. 9º','art. 10','art. 11','art. 1º, §1º','art. 1º, §2º','art. 1º, §3º'],
    ativa = true
  where id = v_unidade_1_id;

  insert into public.unidades_pedagogicas
    (id, curso_conteudo_id, titulo, ordem, escopo, artigos_esperados, ativa)
  values
    (v_unidade_2_id, v_conteudo_id, 'Sujeitos, Sanções e Processo de Improbidade', 2,
     'Lei 8.429/1992, arts. 1º a 3º (sujeitos ativos/passivos, âmbito de aplicação, extensão a terceiros que induzam ou concorram dolosamente), art. 8º-A (responsabilidade sucessória), art. 12 (sanções), art. 17 (representação, apuração, indisponibilidade de bens, ação de improbidade) e art. 23 (prescrição). Não incluir a tipificação detalhada dos atos de improbidade (arts. 9º, 10, 11) — já tratada na Unidade 1.',
     array['art. 1º','art. 2º','art. 3º','art. 8º-A','art. 12','art. 17','art. 23'],
     true)
  on conflict (curso_conteudo_id, ordem) do update set
    titulo = excluded.titulo,
    escopo = excluded.escopo,
    artigos_esperados = excluded.artigos_esperados,
    ativa = excluded.ativa;
end;
$$;

commit;
