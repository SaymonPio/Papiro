-- POS-CHECK — importacao LOTE06_PORTUGUES_AUTORAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 6
-- questoes autorais na unidade Redação oficial. Nao corrige nada.

select
  q.id as questao_id,
  q.ativa,
  q.dificuldade,
  coalesce(lower(q.banca),'') like '%papiro%' as autoral,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
  (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
  (select chr(64+ordem) from public.alternativas where questao_id=q.id and correta=true) as gabarito,
  (select a.texto from public.alternativas a where a.questao_id=q.id and a.ordem=4) as alternativa_d_texto,
  q.explicacao as explicacao,
  (select up.titulo from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id = q.id limit 1) as unidade_vinculada,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as n_vinculos_totais,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  $PC1$Ao redigir um ofício da Brigada Militar destinado à Secretaria de Segurança Pública, um servidor deve preencher o campo assunto para informar, de modo sintético, o teor da comunicação. Assinale a alternativa que apresenta a formatação adequada desse campo, conforme o Manual de Redação da Presidência da República.$PC1$,
  $PC2$O Comandante de uma unidade da Brigada Militar encaminhará ofício ao Presidente da República. Considerando as regras do Manual de Redação da Presidência da República quanto ao fecho e à identificação do signatário, assinale a alternativa que apresenta o encerramento corretamente redigido.$PC2$,
  $PC3$Uma unidade administrativa da Brigada Militar pretende divulgar orientações sobre o acesso a um serviço eletrônico e, simultaneamente, encaminhar informações técnicas a outro órgão público. Considerando a definição de comunicação administrativa e o princípio da impessoalidade, assinale a alternativa correta.$PC3$,
  $PC4$Em uma capacitação sobre redação oficial, um servidor afirmou que o mnemônico “C-P-O-C-I” — clareza, precisão, objetividade, concisão e impessoalidade — esgota todos os atributos exigidos para a elaboração de comunicações oficiais. À luz do Manual de Redação da Presidência da República, assinale a alternativa correta.$PC4$,
  $PC5$Considerando exclusivamente a disciplina do Decreto nº 9.758/2019, assinale a alternativa correta acerca das comunicações escritas dirigidas a agentes públicos da administração pública federal direta e indireta.$PC5$,
  $PC6$À luz do Decreto nº 9.758/2019, que disciplina as comunicações com agentes públicos da administração pública federal, assinale a alternativa que apresenta formas incompatíveis com o padrão de tratamento instituído pelo decreto.$PC6$
)
order by q.id;
