-- SANEAMENTO DE FIDELIDADE ESTRUTURAL + EXPLICACAO — Q89 (curso_conteudo_id
-- 2, Tabela-verdade) — operacao independente, separada da futura
-- classificacao pedagogica da ordem 85.
--
-- Fonte: Fundatec, SUSEPE/Policia Penal RS 01/2022, caderno Agente
-- Penitenciario, Questao 75. Confirmado por releitura caractere-a-
-- caractere do PDF original (ja em maos nesta sessao) que a tabela-
-- verdade completa da proposicao (p v q) -> (r ^ ~q) tinha 8 linhas,
-- com a ultima coluna (resultado da condicional) PREENCHIDA nas linhas
-- em que r=V (linhas 1, 3, 5, 7) e EM BRANCO nas linhas em que r=F
-- (linhas 2, 4, 6, 8) — e NAO nas "ultimas 4 linhas" (5,6,7,8) como a
-- explicacao antiga presumia incorretamente. Recalculo independente
-- (validado tambem via script) confirma os 4 valores corretos das
-- lacunas, de cima para baixo: F, F, F, V — batendo com o gabarito ja
-- armazenado (alternativa D), que permanece correto e inalterado.
--
-- Altera enunciado e explicacao da questao 89. Alternativas, gabarito,
-- banca, concurso, ano, fonte, assunto_id e ativa sao verificados como
-- inalterados nas pos-condicoes. 0 vinculos antes e depois.
--
-- Harness de teste (SEMPRE termina em ROLLBACK) — nada aqui persiste no
-- banco. Ver saneamento_tabela_verdade_q89.sql para a aplicacao real
-- (termina em COMMIT).

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
  v_ativa_atual boolean;
  v_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado_atual, v_explicacao_atual, v_banca_atual, v_concurso_atual, v_ano_atual, v_assunto_atual, v_ativa_atual
    from public.questoes where id = 89;

  if v_enunciado_atual is null then
    raise exception 'Precondicao falhou: questao 89 nao encontrada';
  end if;
  if v_enunciado_atual is distinct from 'Abaixo está apresentada a tabela-verdade, incompleta, da proposição composta (p ∨ q) → (r ∧ ~q). Para completar corretamente os quatro valores lógicos que faltam na última coluna, na ordem de cima para baixo, assinale a alternativa correta.' then
    raise exception 'Precondicao falhou: enunciado atual da questao 89 diverge do esperado antes do saneamento — valor atual: %', v_enunciado_atual;
  end if;
  if position('Linha 5 (p=F, q=V, r=V)' in v_explicacao_atual) = 0
     or position('mas na tabela-verdade do concurso' in v_explicacao_atual) = 0
     or position('linhas 2, 4, 6' in v_explicacao_atual) > 0 then
    raise exception 'Precondicao falhou: explicacao atual da questao 89 diverge do valor esperado antes do saneamento (nao contem o texto quebrado sobre linhas 5-8, ou ja foi alterada)';
  end if;
  if v_banca_atual is distinct from 'Fundatec' then
    raise exception 'Precondicao falhou: banca da questao 89 diverge do esperado (Fundatec) — valor atual: %', v_banca_atual;
  end if;
  if v_concurso_atual is distinct from 'SUSEPE RS - Agente Penitenciário' then
    raise exception 'Precondicao falhou: concurso da questao 89 diverge do esperado — valor atual: %', v_concurso_atual;
  end if;
  if v_ano_atual is distinct from 2022 then
    raise exception 'Precondicao falhou: ano da questao 89 diverge do esperado (2022) — valor atual: %', v_ano_atual;
  end if;
  if v_assunto_atual is distinct from 38 then
    raise exception 'Precondicao falhou: assunto_id da questao 89 diverge do esperado (38) — valor atual: %', v_assunto_atual;
  end if;
  if v_ativa_atual is distinct from true then
    raise exception 'Precondicao falhou: questao 89 nao esta ativa=true';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 89 and ordem = 4 and correta = true and texto = 'F – F – F – V.') then
    raise exception 'Precondicao falhou: gabarito atual da questao 89 nao e a alternativa "F – F – F – V." (ordem 4)';
  end if;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 89;
  if v_vinculos <> 0 then
    raise exception 'Precondicao falhou: questao 89 ja possui vinculo pedagogico (esperado: nenhum) — atual: %', v_vinculos;
  end if;
end $$;

update public.questoes
   set enunciado = 'Abaixo está apresentada a tabela-verdade, incompleta, da proposição composta (p ∨ q) → (r ∧ ~q):

| Linha | p | q | r | ~q | p ∨ q | r ∧ ~q | (p ∨ q) → (r ∧ ~q) |
|---|---|---|---|---|---|---|---|
| 1 | V | V | V | F | V | F | F |
| 2 | V | V | F | F | V | F | ? |
| 3 | V | F | V | V | V | V | V |
| 4 | V | F | F | V | V | F | ? |
| 5 | F | V | V | F | V | F | F |
| 6 | F | V | F | F | V | F | ? |
| 7 | F | F | V | V | F | V | V |
| 8 | F | F | F | V | F | F | ? |

Para completar corretamente os quatro valores lógicos que faltam na última coluna (linhas 2, 4, 6 e 8), na ordem de cima para baixo, assinale a alternativa correta.',
       explicacao = 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A tabela apresenta a proposição composta (p ∨ q) → (r ∧ ~q), já com os valores de p, q, r, ~q, p∨q e r∧~q preenchidos nas 8 linhas, faltando apenas a última coluna (o resultado da condicional) nas linhas 2, 4, 6 e 8. Calculando cada uma:
- Linha 2 (p=V, q=V, r=F): p∨q = V; ~q = F; r∧~q = F ∧ F = F. Condicional: V → F = F.
- Linha 4 (p=V, q=F, r=F): p∨q = V; ~q = V; r∧~q = F ∧ V = F. Condicional: V → F = F.
- Linha 6 (p=F, q=V, r=F): p∨q = V; ~q = F; r∧~q = F ∧ F = F. Condicional: V → F = F.
- Linha 8 (p=F, q=F, r=F): p∨q = F; ~q = V; r∧~q = F ∧ V = F. Condicional: F → F = V (uma condicional com antecedente falso é sempre verdadeira, independentemente do consequente).
Sequência correta das quatro lacunas, de cima para baixo: F – F – F – V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Apresenta valores exclusivamente verdadeiros — mas apenas a lacuna da linha 8 é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não corresponde aos valores calculados da condicional em nenhuma das quatro lacunas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta as duas primeiras lacunas (linhas 2 e 4) como verdadeiras, quando ambas são falsas (V → F = F).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta a última lacuna (linha 8) como falsa, quando na verdade é verdadeira (F → F = V, por ter antecedente falso).

BIZU DE PROVA:
Condicional (A → B):
- É FALSA apenas no caso V → F.
- É VERDADEIRA em qualquer caso com antecedente FALSO (F → V ou F → F).
Nesta tabela, as lacunas das linhas 2, 4 e 6 têm antecedente (p∨q) verdadeiro e consequente (r∧~q) falso — por isso são F. Já a lacuna da linha 8 tem antecedente (p∨q) falso — por isso é automaticamente V, independentemente do consequente.

NOTA DE SANEAMENTO: o enunciado desta questão foi restaurado a partir da prova original (Fundatec, SUSEPE/Polícia Penal RS 01/2022, caderno Agente Penitenciário, Questão 75), que apresentava uma tabela-verdade completa de 8 linhas para a proposição (p∨q)→(r∧~q), com a última coluna preenchida apenas nas linhas em que r=V (linhas 1, 3, 5 e 7) e deixada em branco nas linhas em que r=F (linhas 2, 4, 6 e 8) — e não nas "últimas 4 linhas" como a explicação anterior indicava incorretamente. A explicação anterior continha ainda uma inconsistência interna (calculava a linha correspondente a p=F, q=F, r=V como F→V=V em um trecho do raciocínio, mas reportava F no resumo final, sem reconciliar a divergência). O gabarito (alternativa D, "F – F – F – V") permanece inalterado — já era e continua sendo o correto, agora com o raciocínio corrigido e a tabela restaurada.',
       atualizado_em = now()
 where id = 89;

do $$
declare
  v_novo_enunciado text;
  v_nova_explicacao text;
begin
  select enunciado into v_novo_enunciado from public.questoes where id = 89;
  if position('| 1 | V | V | V | F | V | F | F |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 1 da tabela ausente ou incorreta'; end if;
  if position('| 2 | V | V | F | F | V | F | ? |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 2 (lacuna) ausente ou incorreta'; end if;
  if position('| 3 | V | F | V | V | V | V | V |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 3 da tabela ausente ou incorreta'; end if;
  if position('| 4 | V | F | F | V | V | F | ? |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 4 (lacuna) ausente ou incorreta'; end if;
  if position('| 5 | F | V | V | F | V | F | F |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 5 da tabela ausente ou incorreta'; end if;
  if position('| 6 | F | V | F | F | V | F | ? |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 6 (lacuna) ausente ou incorreta'; end if;
  if position('| 7 | F | F | V | V | F | V | V |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 7 da tabela ausente ou incorreta'; end if;
  if position('| 8 | F | F | F | V | F | F | ? |' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: linha 8 (lacuna) ausente ou incorreta'; end if;
  if position('linhas 2, 4, 6 e 8' in v_novo_enunciado) = 0 then raise exception 'Pos-condicao falhou: enunciado nao identifica explicitamente as linhas com lacuna'; end if;
  -- Garante que o enunciado NAO vaza a resposta: nenhuma ocorrencia de
  -- "F – F – F – V" ou variantes soltas fora da tabela com "?".
  if position('F – F – F – V' in v_novo_enunciado) > 0 then
    raise exception 'Pos-condicao falhou: enunciado vaza a sequencia de resposta F-F-F-V';
  end if;

  select explicacao into v_nova_explicacao from public.questoes where id = 89;
  if position('linhas 2, 4, 6 e 8' in v_nova_explicacao) = 0 then raise exception 'Pos-condicao falhou: explicacao nao identifica corretamente as linhas 2,4,6,8 como lacunas'; end if;
  if position('Linha 5 (p=F, q=V, r=V)' in v_nova_explicacao) > 0 then raise exception 'Pos-condicao falhou: explicacao ainda contem o raciocinio antigo (linhas 5-8)'; end if;
  if position('F – F – F – V' in v_nova_explicacao) = 0 then raise exception 'Pos-condicao falhou: explicacao nao conclui com a sequencia correta F-F-F-V'; end if;
  if position('NOTA DE SANEAMENTO' in v_nova_explicacao) = 0 then raise exception 'Pos-condicao falhou: explicacao sem nota de saneamento'; end if;
end $$;

do $$
declare
  v_enunciado text;
  v_explicacao text;
  v_banca text;
  v_concurso text;
  v_ano int;
  v_assunto bigint;
  v_ativa boolean;
  v_total_alt int;
  v_gabarito_texto text;
  v_gabarito_ordem int;
  v_vinculos int;
begin
  select enunciado, explicacao, banca, concurso, ano, assunto_id, ativa
    into v_enunciado, v_explicacao, v_banca, v_concurso, v_ano, v_assunto, v_ativa
    from public.questoes where id = 89;

  if v_banca is distinct from 'Fundatec' then
    raise exception 'Pos-condicao falhou: banca da questao 89 foi alterada indevidamente — valor atual: %', v_banca;
  end if;
  if v_concurso is distinct from 'SUSEPE RS - Agente Penitenciário' then
    raise exception 'Pos-condicao falhou: concurso da questao 89 foi alterado indevidamente — valor atual: %', v_concurso;
  end if;
  if v_ano is distinct from 2022 then
    raise exception 'Pos-condicao falhou: ano da questao 89 foi alterado indevidamente — valor atual: %', v_ano;
  end if;
  if v_assunto is distinct from 38 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 89 foi alterado indevidamente — valor atual: %', v_assunto;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa da questao 89 foi alterada indevidamente';
  end if;

  select count(*) into v_total_alt from public.alternativas where questao_id = 89;
  if v_total_alt <> 5 then
    raise exception 'Pos-condicao falhou: numero de alternativas da questao 89 mudou (esperado 5, atual %)', v_total_alt;
  end if;

  select ordem, texto into v_gabarito_ordem, v_gabarito_texto from public.alternativas where questao_id = 89 and correta = true;
  if v_gabarito_ordem is distinct from 4 or v_gabarito_texto is distinct from 'F – F – F – V.' then
    raise exception 'Pos-condicao falhou: gabarito da questao 89 mudou (ordem=%, texto=%)', v_gabarito_ordem, v_gabarito_texto;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 89;
  if v_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: questao 89 ganhou vinculo pedagogico inesperado (deveria permanecer sem vinculo) — atual: %', v_vinculos;
  end if;

  raise notice 'Pos-condicoes OK: enunciado e explicacao de Q89 restaurados com fidelidade, alternativas/gabarito/proveniencia/assunto_id/ativa inalterados, 0 vinculos.';
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
