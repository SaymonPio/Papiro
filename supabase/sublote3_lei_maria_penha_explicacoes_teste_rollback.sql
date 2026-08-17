-- ============================================================================
-- SUB-LOTE 3 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (5 QUESTÕES)
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado por scripts/gerar-harness-sublote3-explicacoes.mjs a partir de
-- scripts/sublote3-lei-maria-penha-explicacoes.mjs (fonte da verdade dos
-- textos). As 5 explicações já passaram por
-- scripts/validar-sublote3-explicacoes.mjs (5/5 aprovadas: gabarito de
-- cada texto bate com a alternativa correta=true no banco, todas as
-- alternativas de cada questão são comentadas individualmente, estrutura
-- obrigatória completa).
--
-- Questões: 1371, 1372, 1373, 1374, 1375
-- (as últimas 5 SEM_EXPLICACAO do Lote 1 de importação, todas
-- assunto_id=19 / Lei Maria da Penha. Com este sub-lote, o Lote 1 fica
-- 100% processado: 40 + 38 + 5 = 83 aplicadas, mais 1337 e 1340
-- permanentemente excluídas como PROBLEMATICA/DESATUALIZADA.)
--
-- Texto legal usado como fonte: Lei 11.340/2006 consolidada e vigente em
-- 2026 (Câmara dos Deputados, "norma atualizada") — mesma fonte primária
-- do hotfix das emendas 2024-2026 aplicado ao sub-lote 1+2.
--
-- id 1371 contém ressalva explícita: o enunciado reproduz a redação
-- ANTIGA do critério de risco do art. 12-C ("física ou psicológica"); a
-- explicação deixa claro que a redação vigente (Lei 15.411/2026) ampliou
-- esse critério para física, sexual, psicológica, moral ou patrimonial,
-- sem que isso altere o gabarito (o item testa competência, não a
-- extensão do risco).
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam — provado abaixo por
-- hash md5 linha a linha antes/depois, não só por contagem agregada.
--
-- Nenhuma questão PROBLEMATICA (gabarito ambíguo) foi tocada — confirmado
-- na auditoria: nenhuma das 5 tem 0 ou mais de 1 alternativa correta.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash por questão (prova de que só explicacao muda) +
-- contadores agregados (prova de ausência de efeito colateral em outras
-- tabelas).
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes_questoes on commit drop as
select
  q.id,
  md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_questao,
  (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = q.id
  ) as hash_alternativas,
  (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id
  ) as hash_vinculos_unidade,
  (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = q.id
  ) as hash_vinculos_curso
from public.questoes q
where q.id in (1371, 1372, 1373, 1374, 1375);

create temporary table _snapshot_antes_agregado on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_unidade,
  (select count(*) from public.curso_questoes) as total_curso_questoes,
  (select count(*) from public.questoes where explicacao is not null) as total_com_explicacao;

-- ----------------------------------------------------------------------------
-- Staging: as 5 explicações novas.
-- ----------------------------------------------------------------------------
create temporary table _staging_explicacoes (
  questao_id bigint primary key,
  explicacao_nova text
) on commit drop;

insert into _staging_explicacoes (questao_id, explicacao_nova) values
  (1371, 'GABARITO: ERRADO

POR QUE:
O art. 12-C da Lei estabelece uma cadeia de competência para o afastamento imediato do agressor do lar diante de risco à vida ou à integridade da mulher — e essa competência NÃO é exclusiva da autoridade judicial. A ordem é: (1) a autoridade judicial, sempre; (2) o delegado de polícia, quando o Município não for sede de comarca; ou (3) o próprio policial, quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia. Nas hipóteses de atuação do delegado ou do policial, o juiz é comunicado no prazo de 24 (vinte e quatro) horas e decide, em igual prazo, sobre a manutenção ou a revogação da medida, dando ciência ao Ministério Público.

Ressalva sobre a redação do critério de risco: o enunciado reproduz a redação ANTIGA do art. 12-C ("integridade física ou psicológica"). A redação vigente da Lei, desde a Lei nº 15.411/2026, ampliou esse critério para risco atual ou iminente à vida ou à integridade física, sexual, psicológica, moral ou patrimonial da mulher em situação de violência doméstica e familiar, ou de seus dependentes. Essa diferença de redação não muda o gabarito deste item — o que está sendo testado é a competência para o afastamento (nunca exclusiva do juiz), não a extensão do risco —, mas é importante reconhecer que a redação atual do dispositivo é mais ampla do que a reproduzida no enunciado.

PEGADINHA:
A afirmação tenta transformar em regra exclusiva do juiz uma competência que a própria Lei distribui em três níveis — desconfie sempre de "exclusiva"/"somente"/"apenas" quando o tema é a cadeia de competência do art. 12-C.

BIZU DE PROVA:
Cadeia de competência do art. 12-C: juiz (sempre) → delegado (se o Município não é sede de comarca) → policial (se o Município não é sede de comarca E não há delegado disponível no momento da denúncia). E memorize a redação vigente do critério de risco: vida ou integridade física, sexual, psicológica, moral ou patrimonial — 5 dimensões, não só física/psicológica.'),
  (1372, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 9º, §2º, I, da Lei assegura à mulher em situação de violência doméstica e familiar, quando servidora pública integrante da administração direta ou indireta, acesso PRIORITÁRIO À REMOÇÃO — exatamente a hipótese de Ana Paula, que quer se mudar para outro município do mesmo Estado, onde moram familiares.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não existe previsão de licença remunerada por 12 meses. O que o art. 9º, §2º, II, assegura é a MANUTENÇÃO DO VÍNCULO TRABALHISTA quando necessário o afastamento do local de trabalho, por até 6 (seis) meses — um direito diferente, com prazo bem menor.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 9º, §2º, não prevê acesso a benefícios previdenciários de natureza indenizatória como direito assegurado pelo juiz nessa hipótese.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte a regra do art. 9º, §2º, II: o afastamento do local de trabalho por até 6 meses (não 36) ocorre COM manutenção do vínculo trabalhista — não como afastamento "sem remuneração". A alternativa erra tanto no prazo quanto na natureza do direito.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O instituto previsto no art. 9º, §2º, I, é a REMOÇÃO (deslocamento da servidora dentro do mesmo órgão ou entidade), não a REDISTRIBUIÇÃO (deslocamento do próprio cargo entre órgãos ou entidades diferentes) — são institutos distintos do direito administrativo, e a Lei emprega apenas o primeiro.

BIZU DE PROVA:
No art. 9º, §2º, decore os três incisos por natureza e prazo: I — remoção PRIORITÁRIA (servidora pública, sem prazo fixado); II — manutenção do vínculo trabalhista por até 6 MESES quando precisar se afastar do trabalho; III — encaminhamento à assistência judiciária. Bancas adoram trocar "remoção" por "redistribuição" e inflar o prazo de 6 meses para outros números (12, 36...).'),
  (1373, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 9º, §7º, da Lei assegura à mulher em situação de violência doméstica e familiar prioridade para matricular seus dependentes em instituição de educação básica mais próxima de seu domicílio, ou para transferi-los para essa instituição, mediante apresentação dos documentos comprobatórios do registro da ocorrência ou do processo em curso — exatamente o direito de Ruth diante da falta de vaga na escola mais próxima.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não impõe essa obrigação às escolas PRIVADAS, nem prevê "receber até haver vaga definitiva" — o direito é de prioridade de matrícula/transferência, dirigido à rede pública.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há previsão de obrigatoriedade de a rede PRIVADA de educação suprir a falta de vagas na rede pública.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Descreve uma matrícula genérica "onde houver vaga", com oferta de transporte pela Prefeitura — mas o direito da Lei é mais forte que isso: é prioridade de matrícula na instituição MAIS PRÓXIMA do domicílio, não em qualquer unidade com vaga disponível.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Contraria diretamente o direito do art. 9º, §7º — a ausência de vaga não encerra a proteção; a mulher tem prioridade para matricular ou transferir os dependentes para a instituição mais próxima do domicílio.

BIZU DE PROVA:
O art. 9º, §7º trata da PRIORIDADE de matrícula/transferência na escola mais próxima do domicílio, mediante documentos comprobatórios. Não confunda com o art. 23, V, que trata de matrícula como MEDIDA PROTETIVA determinada pelo juiz — essa sim expressamente "independentemente da existência de vaga". São dois dispositivos parecidos, mas com finalidades distintas: um é direito de assistência (art. 9º), o outro é medida protetiva judicial (art. 23).'),
  (1374, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado "EXCETO"):
O art. 8º, VIII, fala em programas educacionais que disseminem valores éticos de IRRESTRITO respeito à dignidade da pessoa humana, com a perspectiva de gênero e de raça ou etnia — a alternativa troca "irrestrito" por "restrito", invertendo o sentido do dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma diretriz verdadeira, não a exceção pedida):
Reproduz o art. 8º, IV — a implementação de atendimento policial especializado para as mulheres, em particular nas Delegacias de Atendimento à Mulher, é diretriz expressa da política pública de prevenção.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma diretriz verdadeira, não a exceção pedida):
Reproduz o art. 8º, IX — o destaque, nos currículos escolares de todos os níveis de ensino, para os conteúdos relativos aos direitos humanos, à equidade de gênero e de raça ou etnia e ao problema da violência doméstica e familiar contra a mulher.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma diretriz verdadeira, não a exceção pedida):
Reproduz o art. 8º, V — a promoção e a realização de campanhas educativas de prevenção da violência doméstica e familiar contra a mulher, voltadas ao público escolar e à sociedade em geral, e a difusão desta Lei e dos instrumentos de proteção aos direitos humanos das mulheres.

BIZU DE PROVA:
"Irrestrito" virar "restrito" é uma troca clássica de uma única palavra que inverte o sentido inteiro do art. 8º, VIII — releia sempre com atenção redobrada quando a alternativa parecer "quase certa demais", especialmente em questões EXCETO.'),
  (1375, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado "EXCETO"):
"Profilaxia da Trombose" não consta do rol do art. 9º, §3º, da Lei — é um serviço sem previsão legal nesse dispositivo, inventado pela banca como distrator.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é um serviço previsto, não a exceção pedida):
A contracepção de emergência está expressamente prevista no art. 9º, §3º, entre os benefícios de assistência à mulher em situação de violência doméstica e familiar decorrentes do desenvolvimento científico e tecnológico.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é um serviço previsto, não a exceção pedida):
A profilaxia das Doenças Sexualmente Transmissíveis (DST) está expressamente prevista no art. 9º, §3º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é um serviço previsto, não a exceção pedida):
A profilaxia da Síndrome da Imunodeficiência Adquirida (AIDS) está expressamente prevista no art. 9º, §3º.

BIZU DE PROVA:
O art. 9º, §3º, lista 3 serviços ligados aos casos de violência sexual: contracepção de emergência, profilaxia de DST e profilaxia de AIDS (mais "outros procedimentos médicos necessários e cabíveis", cláusula aberta — mas que não abrange itens fantasiosos como "trombose", sem qualquer relação com violência sexual).');

-- ----------------------------------------------------------------------------
-- Revalidação de premissas dentro da própria transação, antes de qualquer
-- escrita (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_fora_do_assunto int;
  v_ja_tem_explicacao int;
  v_inativa int;
  v_gabarito_ambiguo int;
begin
  select count(*) into v_total from _staging_explicacoes;
  if v_total <> 5 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 5 questoes (tem %)', v_total;
  end if;

  select count(*) into v_fora_do_assunto
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.assunto_id <> 19;
  if v_fora_do_assunto > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging nao pertencem ao assunto Lei Maria da Penha (assunto_id=19)', v_fora_do_assunto;
  end if;

  select count(*) into v_ja_tem_explicacao
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is not null;
  if v_ja_tem_explicacao > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging ja tem explicacao preenchida (estado mudou desde a auditoria)', v_ja_tem_explicacao;
  end if;

  select count(*) into v_inativa
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where not q.ativa;
  if v_inativa > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging estao inativas', v_inativa;
  end if;

  select count(*) into v_gabarito_ambiguo
  from (
    select a.questao_id, count(*) filter (where a.correta) as n_corretas, count(*) as n_alt
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ) x
  where x.n_corretas <> 1 or x.n_alt = 0;
  if v_gabarito_ambiguo > 0 then
    raise exception 'Precondicao falhou: % questao(oes) do staging tem gabarito ambiguo (PROBLEMATICA) -- nao pode ser atualizada automaticamente', v_gabarito_ambiguo;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).
-- ----------------------------------------------------------------------------
update public.questoes q
set explicacao = s.explicacao_nova
from _staging_explicacoes s
where q.id = s.questao_id;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_sublote3_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_sublote3_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_sublote3_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_antes record;
  v_total_questoes int;
  v_total_alternativas int;
  v_total_vinculos_unidade int;
  v_total_curso_questoes int;
  v_total_com_explicacao int;
  v_diferentes_enunciado_ou_metadado int;
  v_diferentes_alternativas int;
  v_diferentes_vinculo_unidade int;
  v_diferentes_vinculo_curso int;
  v_sem_explicacao_pos int;
  v_generica_ou_vazia int;
  v_incompletas int;
begin
  select * into v_antes from _snapshot_antes_agregado;

  select count(*) into v_total_questoes from public.questoes;
  select count(*) into v_total_alternativas from public.alternativas;
  select count(*) into v_total_vinculos_unidade from public.questao_unidades_pedagogicas;
  select count(*) into v_total_curso_questoes from public.curso_questoes;
  select count(*) into v_total_com_explicacao from public.questoes where explicacao is not null;

  call teste_sublote3_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_antes.total_questoes);
  call teste_sublote3_assert('nenhuma alternativa criada/removida/alterada em quantidade (total_alternativas inalterado)', v_total_alternativas = v_antes.total_alternativas);
  call teste_sublote3_assert('nenhum vinculo de unidade pedagogica criado/removido', v_total_vinculos_unidade = v_antes.total_vinculos_unidade);
  call teste_sublote3_assert('nenhum vinculo de curso_questoes criado/removido', v_total_curso_questoes = v_antes.total_curso_questoes);
  call teste_sublote3_assert('explicacao passou a existir em exatamente +5 questoes', v_total_com_explicacao = v_antes.total_com_explicacao + 5);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _snapshot_antes_questoes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call teste_sublote3_assert('enunciado/fonte/banca/concurso/materia/assunto/ativa idênticos em todas as 5 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _snapshot_antes_questoes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call teste_sublote3_assert('alternativas (texto/correta/ordem) idênticas em todas as 5 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call teste_sublote3_assert('vinculos de unidade pedagogica idênticos em todas as 5 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _snapshot_antes_questoes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call teste_sublote3_assert('vinculos de curso_questoes idênticos em todas as 5 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_sem_explicacao_pos
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call teste_sublote3_assert('nenhuma das 5 ficou com explicacao vazia', v_sem_explicacao_pos = 0);

  select count(*) into v_generica_ou_vazia
  from public.questoes q
  join _staging_explicacoes s on s.questao_id = q.id
  where q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso';
  call teste_sublote3_assert('nenhuma das 5 contém apenas boilerplate de gabarito/fonte', v_generica_ou_vazia = 0);

  with alt_stats as (
    select a.questao_id, count(*) as n_alt,
      bool_and(lower(btrim(a.texto)) in ('certo','errado')) and count(*) = 2 as eh_certo_errado
    from public.alternativas a
    join _staging_explicacoes s on s.questao_id = a.questao_id
    group by a.questao_id
  ),
  reclassificado as (
    select q.id,
      case
        when st.eh_certo_errado then
          case when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA' then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
        else
          case when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
            and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= st.n_alt
            then 'EXPLICACAO_COMPLETA' else 'NAO_COMPLETA' end
      end as status
    from public.questoes q
    join alt_stats st on st.questao_id = q.id
  )
  select count(*) into v_incompletas from reclassificado where status <> 'EXPLICACAO_COMPLETA';
  call teste_sublote3_assert('todas as 5 reclassificam como EXPLICACAO_COMPLETA pela mesma regra da auditoria', v_incompletas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_sublote3_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo
-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.
ROLLBACK;
