-- Curadoria da unidade pedagógica de Lei de Drogas (curso_conteudos.id =
-- 66), seguindo o padrão validado em
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql e
-- supabase/curadoria_unidades_improbidade.sql — com uma diferença
-- deliberada: decisão aprovada foi MANTER 1 UNIDADE, não dividir.
--
-- Diferente dos dois casos anteriores, este arquivo não insere nenhuma
-- unidade nova — só preenche título/escopo/artigos_esperados reais na
-- unidade padrão já existente (ordem=1), que hoje tem escopo genérico
-- (= nome do assunto). Nenhuma segunda unidade é criada.
--
-- Este conteúdo NÃO tem nenhuma aula publicada nem em rascunho hoje (0
-- linhas em public.aulas para a unidade padrão) — não há nenhum
-- remapeamento de aula existente a fazer. Este arquivo não cria, publica
-- nem gera nenhuma aula.
--
-- Não altera nenhuma questão, alternativa ou vínculo de curso_questoes.
-- Não escreve em questao_unidades_pedagogicas — isso é feito
-- exclusivamente pelos arquivos classificar_questoes_unidades_lei_drogas*.sql,
-- via a RPC oficial classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 66;
  v_unidade_id constant uuid := 'ba2341c7-0598-48f1-99dd-484692c1dfdb';
  v_unidade_padrao uuid;
begin
  -- Precondição: o conteúdo canônico é realmente "Lei de Drogas", na
  -- matéria/curso esperados (Legislação Específica, Brigada Militar RS).
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Lei de Drogas'
      and cm.materia_id = 10
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Lei de Drogas nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 66 nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_id;
  end if;

  -- Decisão aprovada: 1 única unidade — nenhuma outra pode existir para
  -- este conteúdo (execução repetida não deveria encontrar uma ordem=2
  -- criada por engano em outra etapa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem <> 1
  ) then
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 66 — decisao aprovada foi manter 1 unica unidade';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Lei de Drogas',
    escopo = 'Lei 11.343/2006: porte de drogas para consumo pessoal e critérios de diferenciação em relação ao tráfico (art. 28, caput e §§1º-2º); tráfico de drogas e figuras equiparadas, incluindo o tráfico privilegiado (art. 33, caput, §3º e §4º); associação para o tráfico (art. 35); e a estrutura do Sistema Nacional de Políticas Públicas sobre Drogas (Sisnad) — prevenção do uso indevido, atenção e reinserção social de usuários e dependentes, e disposições sobre internação (voluntária, involuntária e compulsória).',
    artigos_esperados = array['art. 28','art. 28, §1º','art. 28, §2º','art. 33','art. 33, §3º','art. 33, §4º','art. 35'],
    ativa = true
  where id = v_unidade_id;
end;
$$;

commit;
