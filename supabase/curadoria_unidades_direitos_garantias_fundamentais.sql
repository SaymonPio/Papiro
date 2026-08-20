-- Curadoria das unidades pedagógicas de Direitos e Garantias Fundamentais
-- (curso_conteudos.id = 47), seguindo exatamente o padrão validado em
-- supabase/curadoria_unidades_lei_maria_penha.sql.
--
-- Um único curso_conteudos (id 47, assunto "Direitos e Garantias
-- Fundamentais", materia_id 10, curso_materia_id 19, curso Brigada Militar
-- RS) e dois recortes pedagógicos, aprovados na etapa de análise anterior:
--   Unidade 1 (ordem 1): Direitos Individuais e Coletivos Fundamentais
--   Unidade 2 (ordem 2): Garantias Constitucionais e Remédios Constitucionais
--
-- Diferente da Lei Maria da Penha, este conteúdo NÃO tem nenhuma aula
-- publicada nem em rascunho hoje (0 linhas em public.aulas para
-- unidade_pedagogica_id desta unidade) — não há nenhum remapeamento de aula
-- existente a fazer, só a divisão da unidade em si.
--
-- Unidade 2 usa um id explícito (em vez de deixar gen_random_uuid() decidir)
-- para que este mesmo id possa ser referenciado, de forma determinística,
-- pelos arquivos de classificação de questões que dependem dele
-- (classificar_questoes_unidades_direitos_garantias_fundamentais*.sql) —
-- todos escritos e revisados ANTES da aplicação real, portanto precisam de
-- um id conhecido de antemão.
--
-- Não publica nem gera aulas automaticamente. Não altera nenhuma questão,
-- alternativa ou vínculo de curso_questoes.

begin;

do $$
declare
  v_conteudo_id constant bigint := 47;
  v_unidade_1_id constant uuid := '0c5d1d64-0cae-406e-be19-b03d387bee8a';
  v_unidade_2_id constant uuid := 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63';
  v_unidade_padrao uuid;
begin
  -- Precondição: o conteúdo canônico é realmente "Direitos e Garantias
  -- Fundamentais", na matéria/curso esperados (Legislação Específica,
  -- Brigada Militar RS) — mesmo princípio de verificação da LMP.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Direitos e Garantias Fundamentais'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Direitos e Garantias Fundamentais nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 47 nao encontrada';
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
    raise exception 'Ja existe uma unidade ordem=2 diferente da esperada para o conteudo 47';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Direitos Individuais e Coletivos Fundamentais',
    escopo = 'Constituição Federal de 1988, art. 5º: igualdade, liberdade, intimidade, vida privada, honra e imagem, inviolabilidade do domicílio, sigilo de correspondência e comunicações, liberdade religiosa (incluindo assistência religiosa), liberdade de expressão e manifestação do pensamento, direito de reunião, liberdade de associação (criação, vedação de caráter paramilitar, legitimidade das associações para representar seus filiados). Não incluir remédios constitucionais (habeas corpus, habeas data, mandado de segurança, mandado de injunção), garantias penais (legalidade penal, vedação de penas) nem devido processo legal/contraditório/ampla defesa.',
    artigos_esperados = array['art. 5º, caput','art. 5º, I','art. 5º, IV','art. 5º, VI','art. 5º, VII','art. 5º, IX','art. 5º, X','art. 5º, XI','art. 5º, XII','art. 5º, XVI','art. 5º, XVII','art. 5º, XVIII','art. 5º, XXI'],
    ativa = true
  where id = v_unidade_1_id;

  insert into public.unidades_pedagogicas
    (id, curso_conteudo_id, titulo, ordem, escopo, artigos_esperados, ativa)
  values
    (v_unidade_2_id, v_conteudo_id, 'Garantias Constitucionais e Remédios Constitucionais', 2,
     'Constituição Federal de 1988, art. 5º: devido processo legal, contraditório e ampla defesa, direitos dos presos (integridade física e moral, condições para amamentação), vedação de penas (morte, caráter perpétuo, trabalhos forçados, banimento, cruéis) e vedação a tratamento desumano ou degradante, remédios constitucionais (habeas corpus, habeas data, mandado de segurança, mandado de injunção). Não incluir os direitos individuais básicos já tratados na Unidade 1 (igualdade, liberdade, intimidade, domicílio, sigilo, religião, expressão, reunião).',
     array['art. 5º, III','art. 5º, XLVII','art. 5º, XLIX','art. 5º, L','art. 5º, LIV','art. 5º, LV','art. 5º, LXVIII','art. 5º, LXIX','art. 5º, LXXI','art. 5º, LXXII'],
     true)
  on conflict (curso_conteudo_id, ordem) do update set
    titulo = excluded.titulo,
    escopo = excluded.escopo,
    artigos_esperados = excluded.artigos_esperados,
    ativa = excluded.ativa;
end;
$$;

commit;
