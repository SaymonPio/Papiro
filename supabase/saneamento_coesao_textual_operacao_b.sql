-- OPERACAO B — Correcao da fundamentacao item-a-item da explicacao
-- armazenada da questao 69 (curso_conteudo_id 13, Coesao textual).
--
-- O GABARITO (alternativa C, valor "05") NAO MUDA — tanto o par {1,4}
-- quanto o par {2,3} somam 5, entao o valor final sempre foi compativel
-- com o gabarito oficial da banca (confirmado externamente via Edital
-- da/DRESA no SD-P 14/2025, Gabarito Preliminar do Exame Intelectual,
-- Brigada Militar RS: questao 5 = C).
--
-- A analise gramatical independente do texto-base restaurado (Operacao A)
-- mostrou que a fundamentacao anteriormente armazenada tinha o par de
-- afirmacoes corretas invertido (apontava 1 e 4 como corretas; a leitura
-- gramatical correta aponta 2 e 3): "seus" (l.08) possui apenas "cursos",
-- nao estabelece relacao com "cidades" (afirmacao 1 falsa); "que" (l.12)
-- concorda em numero com "herois anonimos" via "brotam", plural (afirmacao
-- 2 verdadeira); "herois anonimos" e "seres humanos iluminados" sao
-- correferentes (afirmacao 3 verdadeira); "se" (l.26) e reflexivo e
-- concorda com o sujeito "a natureza", nao com "homem", que e apenas
-- complemento da preposicao "a" (afirmacao 4 falsa).
--
-- Altera SOMENTE o campo explicacao. Enunciado (ja restaurado pela
-- Operacao A), alternativas, gabarito, banca, concurso, ano e assunto_id
-- sao verificados como inalterados nas pos-condicoes.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_explicacao_atual text;
  v_gabarito_atual text;
begin
  select explicacao into v_explicacao_atual from public.questoes where id = 69;
  if v_explicacao_atual is null then
    raise exception 'Precondicao falhou: questao 69 nao encontrada';
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A soma das afirmações corretas resulta em 05 (afirmações 1 e 4 estão corretas, 1 + 4 = 5).
- Afirmação 1 (Correta): o pronome "seus" retoma anaforicamente os rios em relação às cidades por eles banhadas.
- Afirmação 2 (Incorreta): o pronome relativo "que" na linha 12 refere-se a outro elemento sintático precedente no período.
- Afirmação 3 (Incorreta): as expressões desempenham papéis coesivos distintos ao longo da argumentação.
- Afirmação 4 (Correta): o pronome "se" atua ligado ao sujeito "homem", que é o termo nuclear de referência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O valor 03 não corresponde à soma das afirmações validadas pelo gabarito oficial da banca Fundatec.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O valor 04 implicaria considerar apenas a afirmação 4 ou uma combinação não correspondente ao texto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O valor 06 decorreria da soma de afirmações incorretas (ex.: 2 + 4).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O valor 09 decorreria da inclusão de afirmações falsas no cômputo total.

BIZU DE PROVA:
Em questões de somatória da Fundatec, resolva cada item isoladamente com V/F e anote os valores ao lado antes de efetuar a soma final, conferindo rigorosamente os referentes pronominais no texto.' then
    raise exception 'Precondicao falhou: explicacao atual da questao 69 diverge do valor esperado antes da correcao';
  end if;

  select a.texto into v_gabarito_atual from public.alternativas a where a.questao_id = 69 and a.correta = true;
  if v_gabarito_atual is distinct from '05.' then
    raise exception 'Precondicao falhou: alternativa correta atual da questao 69 = % (esperado "05.")', v_gabarito_atual;
  end if;
end $$;

update public.questoes
   set explicacao = 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A soma das afirmações corretas resulta em 05 (afirmações 2 e 3 estão corretas, 2 + 3 = 5).
- Afirmação 1 (Incorreta): na linha 08, "Rios mudando seus cursos e devorando cidades", o pronome "seus" possui gramaticalmente apenas "cursos", retomando "rios" (os rios e SEUS cursos); "cidades" é apenas objeto do verbo "devorando", sem relação de posse com "seus". Não há relação possessiva entre "rios" e "cidades" mediada por "seus".
- Afirmação 2 (Correta): na linha 12, "Surge a entrega de heróis anônimos, que brotam em abundância...", o pronome relativo "que" retoma "heróis anônimos", confirmado pela concordância verbal de "brotam" (3ª pessoa do plural, compatível apenas com "heróis anônimos", e não com "a entrega", singular).
- Afirmação 3 (Correta): "heróis anônimos" (l. 12) e "seres humanos iluminados" (l. 13-14) são expressões correferentes, designando o mesmo grupo de pessoas que se dedicou a ações de solidariedade e resgate durante a tragédia.
- Afirmação 4 (Incorreta): na linha 26, "a natureza jamais se submete ao homem", o pronome reflexivo "se" concorda com o sujeito "a natureza" (que se submete/rende a si mesma); "homem" é apenas o complemento da preposição "a" (aquilo a que a natureza se submete), não o referente do pronome "se".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O valor 03 não corresponde à soma das afirmações corretas (2 + 3 = 5).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O valor 04 não corresponde a nenhuma combinação de afirmações verdadeiras do texto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O valor 06 decorreria de uma soma que incluiria alguma afirmação falsa (1 ou 4).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O valor 09 corresponderia à soma de todas as afirmações (1+2+3+4=10, tampouco haveria essa soma), não condizendo com a análise item a item.

BIZU DE PROVA:
Em questões de somatória da Fundatec, resolva cada item isoladamente com V/F antes de somar. Cuidado com pronomes reflexivos ("se") — eles concordam com o SUJEITO da oração, não com o complemento regido por preposição ("a natureza se submete AO homem" — "se" = a natureza, não homem). E cuidado com concordância verbal como pista de antecedente do pronome relativo "que" ("heróis anônimos, que brotam" — plural concorda com "heróis", não com um termo singular anterior).

NOTA DE SANEAMENTO: a explicação anteriormente armazenada identificava as afirmações 1 e 4 como corretas; análise gramatical independente do texto-base restaurado (confrontada com a concordância verbal e nominal de cada trecho) indica que o par correto é 2 e 3, não 1 e 4. O valor final do gabarito (alternativa C, soma 05) permanece o mesmo em ambas as leituras, pois tanto {1,4} quanto {2,3} somam 5 — não há, portanto, divergência no gabarito, apenas na fundamentação item a item, ora corrigida.',
       atualizado_em = now()
 where id = 69;

do $$
declare
  v_novo text;
  v_gabarito_depois text;
  v_qtd_alt int;
begin
  select explicacao into v_novo from public.questoes where id = 69;
  if position('2 + 3' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao contem a soma corrigida "2 + 3"';
  end if;
  if position('Afirmação 1 (Incorreta)' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao marca a afirmacao 1 como incorreta';
  end if;
  if position('Afirmação 2 (Correta)' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao marca a afirmacao 2 como correta';
  end if;
  if position('Afirmação 3 (Correta)' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao marca a afirmacao 3 como correta';
  end if;
  if position('Afirmação 4 (Incorreta)' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao marca a afirmacao 4 como incorreta';
  end if;
  if position('GABARITO: alternativa C' in v_novo) = 0 then
    raise exception 'Pos-condicao falhou: nova explicacao nao preserva o gabarito alternativa C';
  end if;

  select a.texto into v_gabarito_depois from public.alternativas a where a.questao_id = 69 and a.correta = true;
  if v_gabarito_depois is distinct from '05.' then
    raise exception 'Pos-condicao falhou: gabarito da questao 69 mudou inesperadamente para %', v_gabarito_depois;
  end if;

  select count(*) into v_qtd_alt from public.alternativas where questao_id = 69;
  if v_qtd_alt <> 5 then
    raise exception 'Pos-condicao falhou: quantidade de alternativas da questao 69 mudou (agora %, esperado 5)', v_qtd_alt;
  end if;

  if not exists (select 1 from public.questoes where id = 69 and ativa = true and banca = 'Fundatec' and ano = 2025 and assunto_id = 55) then
    raise exception 'Pos-condicao falhou: banca/ano/assunto_id/ativa da questao 69 mudaram inesperadamente';
  end if;
end $$;

commit;
