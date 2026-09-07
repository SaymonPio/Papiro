-- POS-CHECK — importacao LEG-AUT-HIERARQUIA-01.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 7
-- questoes autorais na unidade "Hierarquia e disciplina". Nao corrige nada.
--
-- Esperado apos o apply: 7 linhas, todas com estrutura/vinculo/curso_questoes OK.

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
    where qup.questao_id = q.id and qup.unidade_pedagogica_id = 'cbde0aeb-3df8-4c41-a82f-91b83b529668'
  ) as ok_vinculo_unidade_correta,
  not exists(
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = q.id and qup.unidade_pedagogica_id <> 'cbde0aeb-3df8-4c41-a82f-91b83b529668'
  ) as ok_sem_vinculo_em_outra_unidade,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  'A Lei Complementar Estadual RS nº 10.990/1997 dispõe sobre o Estatuto dos Militares Estaduais da Brigada Militar. Um Soldado recém-incorporado observa que, na rotina de sua unidade, os oficiais de posto mais elevado respondem por decisões e consequências institucionais que não recaem sobre os militares de grau hierárquico inferior. Sobre o fundamento dessa organização, à luz do art. 12, caput, da referida Lei Complementar, assinale a alternativa CORRETA.',
  'Segundo o art. 12, §3º, da LC Estadual RS nº 10.990/1997, assinale a alternativa que reproduz corretamente a extensão da disciplina militar e do respeito à hierarquia prevista nesse dispositivo.',
  'Sobre os círculos hierárquicos na Brigada Militar, nos termos do art. 13 da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.',
  'Dois Capitães da Brigada Militar, ambos da ativa, possuem o mesmo grau hierárquico. Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, qual é a regra geral aplicável para fins de precedência entre eles?',
  'Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, a ressalva de precedência funcional à regra geral da antiguidade é expressamente prevista para quais funções?',
  'Em uma ocorrência policial-militar, encontram-se presentes os seguintes servidores militares da Brigada Militar, todos da ativa: Alpha, Capitão mais antigo no posto; Bravo, Capitão mais moderno no posto; Charlie, 1º Tenente; e Delta, Sargento. Considerando exclusivamente a ordenação hierárquica prevista no art. 12, §1º, da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.',
  'Sobre a hierarquia e a disciplina na Brigada Militar, considere as assertivas abaixo, à luz da LC Estadual RS nº 10.990/1997:

I. A disciplina militar traduz-se pelo cumprimento do dever por parte de todos e de cada um dos componentes da corporação.

II. Os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.

III. A disciplina militar e o respeito à hierarquia devem ser mantidos exclusivamente entre os militares da ativa.

Está(ão) correta(s):'
)
order by q.id;
