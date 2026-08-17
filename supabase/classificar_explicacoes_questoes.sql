-- Classificador determinístico de qualidade de public.questoes.explicacao —
-- SOMENTE LEITURA (um único SELECT, nenhum INSERT/UPDATE/DELETE, nenhuma
-- tabela ou função nova). Implementa a regra fixa de produto definida nesta
-- sessão: nenhuma questão pode ficar sem explicação pedagógica completa.
--
-- Classifica cada questão em exatamente uma das 5 categorias abaixo — a
-- soma das 5 sempre fecha o total de linhas de public.questoes:
--
--   SEM_EXPLICACAO      -- explicacao IS NULL ou string vazia/só espaços.
--   PROBLEMATICA        -- integridade de dados quebrada (não é problema de
--                           TEXTO da explicação): a questão não tem
--                           exatamente 1 alternativa marcada correta, ou não
--                           tem nenhuma alternativa. Nunca gerar explicação
--                           para uma questão nesta categoria -- corrigir a
--                           integridade primeiro, fora desta tarefa.
--   EXPLICACAO_GENERICA -- explicacao existe mas é só metadado/boilerplate
--                           (ex.: "Gabarito indicado no Caderno TEC
--                           enviado pelo usuário: alternativa X.",
--                           "Gabarito definitivo Fundatec: ...", "O
--                           gabarito oficial da/do ... indica..."). Nunca
--                           ensina o porquê.
--   EXPLICACAO_INCOMPLETA -- tem conteúdo real (não é boilerplate puro),
--                           mas não segue a estrutura obrigatória nova:
--                           GABARITO + justificativa da correta +
--                           justificativa individual de CADA alternativa
--                           incorreta + BIZU DE PROVA (múltipla escolha), ou
--                           GABARITO CERTO/ERRADO + POR QUE + BIZU DE PROVA
--                           (Certo/Errado).
--   EXPLICACAO_COMPLETA -- cumpre a estrutura obrigatória inteira.
--
-- Regra de tipo de questão: Certo/Errado é detectado por ter exatamente 2
-- alternativas cujo texto (normalizado) é literalmente "certo"/"errado" —
-- qualquer outra contagem/conteúdo de alternativas é tratado como múltipla
-- escolha (nunca assume commit a letras A-E fixas; usa o número real de
-- alternativas da própria questão para exigir que TODAS sejam comentadas).
--
-- Detecção deliberadamente estrutural (regex sobre marcadores obrigatórios
-- do formato, nunca um limite de tamanho isolado) -- ver PROMPT/decisão do
-- usuário: "Não crie uma regra frágil baseada apenas em tamanho mínimo.
-- Valide estrutura e conteúdo esperado."
--
-- Uso: colar no SQL Editor (ou MCP read-only, já validado assim). Resultado
-- desta rodada (sessão de auditoria): SEM_EXPLICACAO=85,
-- EXPLICACAO_GENERICA=374, EXPLICACAO_INCOMPLETA=272,
-- EXPLICACAO_COMPLETA=0, PROBLEMATICA=0 -- total 731.

with alt_stats as (
  select
    q.id as questao_id,
    count(a.id) as n_alt,
    count(a.id) filter (where a.correta) as n_corretas,
    bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
  from public.questoes q
  left join public.alternativas a on a.questao_id = q.id
  group by q.id
),
classificado as (
  select
    q.id,
    q.materia_id,
    q.assunto_id,
    q.ativa,
    s.n_alt,
    s.n_corretas,
    s.eh_certo_errado,
    case
      when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
      when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
      when s.eh_certo_errado then
        case
          when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)'
           and q.explicacao ~* 'POR QUE\s*:'
           and q.explicacao ~* 'BIZU DE PROVA'
            then 'EXPLICACAO_COMPLETA'
          when q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso'
            then 'EXPLICACAO_GENERICA'
          else 'EXPLICACAO_INCOMPLETA'
        end
      else
        case
          when q.explicacao ~* 'GABARITO\s*:'
           and q.explicacao ~* 'BIZU DE PROVA'
           and (
             select count(distinct m[1])
             from regexp_matches(
               q.explicacao,
               'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)',
               'gi'
             ) as m
           ) >= s.n_alt
            then 'EXPLICACAO_COMPLETA'
          when q.explicacao ~* '^\s*Gabarito (indicado|definitivo|oficial)|^\s*O gabarito (definitivo|oficial)|^\s*Quest[ãa]o original do concurso'
            then 'EXPLICACAO_GENERICA'
          else 'EXPLICACAO_INCOMPLETA'
        end
    end as status
  from public.questoes q
  join alt_stats s on s.questao_id = q.id
)
select c.id as questao_id, m.nome as materia, a.nome as assunto, c.ativa, c.n_alt, c.status
from classificado c
join public.materias m on m.id = c.materia_id
left join public.assuntos a on a.id = c.assunto_id
order by c.id;
