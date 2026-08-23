-- MICRO-SANEAMENTO DE EXPLICACAO — Q223 (curso_conteudo_id 19,
-- Concordancia nominal) — operacao independente e minima, anterior a
-- qualquer apply de classificacao pedagogica da ordem 70 (Q223 ainda
-- nao possui vinculo pedagogico).
--
-- Motivo: a explicacao armazenada da alternativa C ("Sao necessario as
-- cautelas") atribuia erroneamente discordancia tambem ao verbo "Sao",
-- quando na verdade "Sao" concorda corretamente com o sujeito plural
-- "as cautelas" — o unico erro da alternativa C e no predicativo
-- "necessario" (deveria ser "necessarias", pois o sujeito vem
-- determinado pelo artigo "as"). Alternativas A, B, D, E revisadas e
-- confirmadas sem o mesmo problema — nao alteradas.
--
-- Altera SOMENTE o campo explicacao da questao 223. Enunciado,
-- alternativas, gabarito, banca, concurso, ano, assunto_id, ativa e
-- vinculos (0, inalterado) sao verificados como inalterados nas
-- pos-condicoes.
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_enunciado_atual text;
  v_explicacao_atual text;
  v_banca_atual text;
  v_concurso_atual text;
  v_ano_atual int;
  v_assunto_atual bigint;
  v_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual
    from public.questoes where id = 223;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 223 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Assinale a frase correta.' then
    raise exception 'Precondicao falhou: enunciado atual da questao 223 diverge do esperado — valor atual: %', v_enunciado_atual;
  end if;
  if v_explicacao_atual is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nas estruturas formadas pelo verbo "ser" + predicativo ("é bom", "é necessário", "é proibido", "é permitido"), quando o substantivo sujeito vem determinado por artigo definido ou pronome ("a cautela"), a concordância nominal do predicativo é OBRIGATÓRIA: "É necessária a cautela".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Como o substantivo vem acompanhado do artigo feminino "a", o predicativo não pode ficar no masculino neutro "necessário" (deve ser "necessária").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta discordância entre o verbo no plural "São", o adjetivo no singular "necessário" e o sujeito "as cautelas".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flexiona o predicativo no plural "necessárias" com sujeito no singular "a cautela".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o adjetivo no singular feminino com substantivo sem artigo ("cautelas"), onde a regra geral sem determinante exige o masculino neutro ("É necessário cautela").

BIZU DE PROVA:
A regra do "É NECESSÁRIO / É PROIBIDO":
- Sem artigo/determinante: fica no masculino singular invariável -> "É proibido entrada", "É necessário cautela".
- Com artigo/determinante: concorda obrigatoriamente -> "É proibida A entrada", "É necessária A cautela".' then
    raise exception 'Precondicao falhou: explicacao atual da questao 223 diverge do valor esperado antes da correcao';
  end if;
  if v_banca_atual is distinct from 'Papiro' then
    raise exception 'Precondicao falhou: banca da questao 223 diverge do esperado (Papiro) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'PAPIRO - Estilo Fundatec - BM RS' then
    raise exception 'Precondicao falhou: concurso da questao 223 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2026 then
    raise exception 'Precondicao falhou: ano da questao 223 diverge do esperado (2026) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 52 then
    raise exception 'Precondicao falhou: assunto_id da questao 223 diverge do esperado (52) — valor atual: %', v_assunto_atual;
  end if;
  if not exists (select 1 from public.questoes where id = 223 and ativa = true) then
    raise exception 'Precondicao falhou: questao 223 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 223 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: gabarito atual da questao 223 nao e a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 223;
  if v_vinculos <> 0 then
    raise exception 'Precondicao falhou: questao 223 ja possui % vinculo(s) pedagogico(s) (esperado 0, curadoria da ordem 70 ainda nao foi aplicada)', v_vinculos;
  end if;
end $$;

update public.questoes
   set explicacao = 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nas estruturas formadas pelo verbo "ser" + predicativo ("é bom", "é necessário", "é proibido", "é permitido"), quando o substantivo sujeito vem determinado por artigo definido ou pronome ("a cautela"), a concordância nominal do predicativo é OBRIGATÓRIA: "É necessária a cautela".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Como o substantivo vem acompanhado do artigo feminino "a", o predicativo não pode ficar no masculino neutro "necessário" (deve ser "necessária").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "São" concorda corretamente com o sujeito plural "as cautelas" — não há erro de concordância verbal nesta alternativa. O erro está exclusivamente no predicativo "necessário": como o sujeito "as cautelas" vem determinado pelo artigo "as", a concordância nominal do predicativo é obrigatória, devendo ser "necessárias" (a forma correta seria "São necessárias as cautelas").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flexiona o predicativo no plural "necessárias" com sujeito no singular "a cautela".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o adjetivo no singular feminino com substantivo sem artigo ("cautelas"), onde a regra geral sem determinante exige o masculino neutro ("É necessário cautela").

BIZU DE PROVA:
A regra do "É NECESSÁRIO / É PROIBIDO":
- Sem artigo/determinante: fica no masculino singular invariável -> "É proibido entrada", "É necessário cautela".
- Com artigo/determinante: concorda obrigatoriamente, tanto o verbo quanto o predicativo, com o sujeito -> "É proibida A entrada", "É necessária A cautela", "São necessárias AS cautelas".',
       atualizado_em = now()
 where id = 223;

do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_gabarito_ok boolean;
  v_total_alt int;
  v_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 223;

  if v_enunciado is distinct from 'Assinale a frase correta.' then
    raise exception 'Pos-condicao falhou: enunciado da questao 223 foi alterado indevidamente — valor atual: %', v_enunciado;
  end if;
  if v_explicacao is distinct from 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nas estruturas formadas pelo verbo "ser" + predicativo ("é bom", "é necessário", "é proibido", "é permitido"), quando o substantivo sujeito vem determinado por artigo definido ou pronome ("a cautela"), a concordância nominal do predicativo é OBRIGATÓRIA: "É necessária a cautela".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Como o substantivo vem acompanhado do artigo feminino "a", o predicativo não pode ficar no masculino neutro "necessário" (deve ser "necessária").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "São" concorda corretamente com o sujeito plural "as cautelas" — não há erro de concordância verbal nesta alternativa. O erro está exclusivamente no predicativo "necessário": como o sujeito "as cautelas" vem determinado pelo artigo "as", a concordância nominal do predicativo é obrigatória, devendo ser "necessárias" (a forma correta seria "São necessárias as cautelas").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flexiona o predicativo no plural "necessárias" com sujeito no singular "a cautela".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o adjetivo no singular feminino com substantivo sem artigo ("cautelas"), onde a regra geral sem determinante exige o masculino neutro ("É necessário cautela").

BIZU DE PROVA:
A regra do "É NECESSÁRIO / É PROIBIDO":
- Sem artigo/determinante: fica no masculino singular invariável -> "É proibido entrada", "É necessário cautela".
- Com artigo/determinante: concorda obrigatoriamente, tanto o verbo quanto o predicativo, com o sujeito -> "É proibida A entrada", "É necessária A cautela", "São necessárias AS cautelas".' then
    raise exception 'Pos-condicao falhou: explicacao da questao 223 nao corresponde a versao corrigida esperada';
  end if;
  if position('não há erro de concordância verbal' in v_explicacao) = 0 then
    raise exception 'Pos-condicao falhou: correcao da alternativa C nao esta presente na nova explicacao';
  end if;
  if position('Apresenta discordância entre o verbo no plural' in v_explicacao) > 0 then
    raise exception 'Pos-condicao falhou: texto antigo incorreto da alternativa C ainda presente na explicacao';
  end if;
  if v_banca is distinct from 'Papiro' then
    raise exception 'Pos-condicao falhou: banca da questao 223 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'PAPIRO - Estilo Fundatec - BM RS' then
    raise exception 'Pos-condicao falhou: concurso da questao 223 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2026 then
    raise exception 'Pos-condicao falhou: ano da questao 223 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 52 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 223 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 223 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 223;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 223 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select exists(select 1 from public.alternativas where questao_id = 223 and ordem = 1 and correta = true) into v_gabarito_ok;
  if not v_gabarito_ok then
    raise exception 'Pos-condicao falhou: gabarito da questao 223 nao e mais a alternativa de ordem 1 (A)';
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 223;
  if v_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: questao 223 passou a ter % vinculo(s) pedagogico(s) (esperado 0, nenhum apply de classificacao foi feito)', v_vinculos;
  end if;

  raise notice 'Pos-condicoes OK: explicacao da questao 223 corrigida (alternativa C: verbal correto, erro exclusivamente nominal no predicativo), enunciado/alternativas/gabarito/proveniencia/assunto_id/ativa/vinculos (0) inalterados.';
end $$;

commit;
