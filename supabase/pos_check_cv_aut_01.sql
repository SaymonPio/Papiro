-- POS-CHECK — importacao CV-AUT-01.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 6
-- questoes autorais na unidade "Concordancia verbal". Nao corrige nada.
--
-- Esperado apos o apply: 6 linhas, todas com estrutura/vinculo/curso_questoes OK.

select
  q.id as questao_id,
  q.ativa,
  q.dificuldade,
  coalesce(lower(q.banca),'') like '%papiro%' as autoral,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
  (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
  (select chr(64+ordem) from public.alternativas where questao_id=q.id and correta=true) as gabarito,
  exists(
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = q.id and qup.unidade_pedagogica_id = '834a820d-48a7-440f-a013-be375be8a62d'
  ) as ok_vinculo_unidade_correta,
  not exists(
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = q.id and qup.unidade_pedagogica_id <> '834a820d-48a7-440f-a013-be375be8a62d'
  ) as ok_sem_vinculo_em_outra_unidade,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  'Considere as frases a seguir quanto à concordância verbal.

I. A sequência de treinamentos prepara os recrutas para a avaliação.
II. Os resultados do último simulado demonstra a evolução da turma.
III. O comandante, referência para os novos soldados, orientou a equipe.
IV. A presença dos instrutores garantem maior segurança durante a atividade.

Quais estão corretas?',
  'Assinale a alternativa que preenche corretamente as lacunas da frase a seguir:

A equipe ______ a rotina de treinamento, o novo instrutor ______ ao quartel logo cedo e os supervisores ______ autonomia para ajustar as atividades.',
  'Assinale a alternativa que preenche corretamente as lacunas da frase abaixo.

O relatório ______ dados sigilosos, enquanto os anexos ______ informações complementares.',
  'Considere a frase:

“A revisão dos procedimentos operacionais começaram na segunda-feira.”

Sem alterar o sujeito nem o tempo verbal empregado, assinale a alternativa que identifica corretamente a existência de erro de concordância verbal e, se houver, apresenta a correção necessária.',
  'Analise as afirmativas a seguir quanto à concordância verbal.

I. Naquela região, deve haver rotas alternativas para o resgate.
II. Podem existir falhas no sistema de comunicação.
III. Haviam obstáculos imprevistos durante a operação.
IV. Pode existirem soluções mais seguras para o deslocamento.

Quais afirmativas estão corretas?',
  'Assinale a alternativa que preenche corretamente as lacunas da frase: “Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente.”'
)
order by q.id;
