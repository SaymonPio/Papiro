# Inventário — Caderno TEC da Lei Maria da Penha (1–200)

Fase de **extração/inventário local**, sem nenhuma escrita no Supabase (nenhum INSERT/UPDATE/DELETE/migration) e **sem comparação com o banco** — o MCP do Supabase está bloqueado nesta sessão (`SUPABASE_ACCESS_TOKEN` ainda não é herdado pelo processo do Claude Code; ver histórico da conversa). Este documento acompanha `inventario_lei_maria_penha_tec_caderno_1_200.csv` (200 linhas de dados, uma por questão).

Este é um arquivo **separado** do `inventario_lei_maria_penha_tec_pdfs.csv` (que cobre os 4 cadernos 201–1000, já revalidados contra o banco em sessão anterior). Os dois ainda **não foram mesclados** — junção fica para quando o MCP voltar e os dois lotes puderem ser comparados ao banco na mesma passada.

## 1. Arquivo-fonte

`C:\Users\User\Desktop\Concursos\PROVAS\Caderno Lei Maria da Penha - 1 ao 200.pdf` (200 questões, o 5º e último caderno TEC pendente do universo de 1.000 questões enviado).

Extração de texto com `pdftotext -layout -enc UTF-8` (xpdf 4.06), parser Node.js próprio (não OCR/visão), mesmo formato de exportação digital do TEC Concursos dos outros 4 cadernos: `tecconcursos.com.br/questoes/<TEC_ID>`, linha de banca/concurso/ano, cabeçalho de classificação do TEC com intervalo de artigos, enunciado, alternativas, e uma grade `Gabarito` única no fim do caderno (43 páginas).

## 2. Lógica de pareamento aplicada (corrigida)

Por bloco de questão, nesta ordem, sempre dentro do mesmo bloco delimitado pelas URLs consecutivas `tecconcursos.com.br/questoes/<id>`:

1. **TEC ID** — capturado da própria URL que abre o bloco.
2. **banca/concurso/ano** — capturadas da linha imediatamente após a URL do mesmo bloco (nunca de blocos vizinhos).
3. **gabarito** — casado por **número da questão** (`N) resposta`) contra a grade `Gabarito` no final do caderno, não por posição/ordem de leitura (a grade é impressa em colunas fora de ordem numérica).

Nenhum metadado de um bloco foi herdado de outro bloco.

## 3. Bugs de parsing encontrados e corrigidos nesta extração

- **Alternativa "a)" descartada silenciosamente em 78 questões**: um `trim()` aplicado antes de separar enunciado de alternativas comia a quebra de linha usada como delimitador do split, jogando a primeira alternativa dentro do texto do enunciado. Corrigido; as 78 questões foram re-extraídas com a alternativa "a)" restaurada e conferidas manualmente por amostragem.
- **Indentação de alternativas variável após quebra de página**: quando uma alternativa cai no topo de uma nova página, o `pdftotext -layout` às vezes perde os espaços de indentação (`a) texto` em vez de `       a) texto`). Regex ajustada para aceitar 0–10 espaços.
- **Form feed (`\f`) não tratado como quebra de linha**: cabeçalho de página glruda sem `\n` antes, quebrando a detecção de ruído de rodapé/cabeçalho por linha. Normalizado para `\n` antes de qualquer outra limpeza.
- **Número de página (`N/43`) colado em lugares variáveis**: ora depois de "imprimir", ora direto após a URL da questão seguinte. Regex antiga de rodapé (`imprimir\s*\d*\/\d*`) chegou a "comer" por engano o dia/mês de uma data seguinte (`15/08/2026` → `15/08` consumido). Corrigido: o rodapé "imprimir" e o número de página são removidos em duas passadas independentes, a segunda ancorada especificamente em `/43` (denominador fixo do documento).

Todas as correções foram validadas por reprocessamento completo + checagem automática (ver seção 5).

## 4. Extração

200/200 questões extraídas (numeração interna do próprio caderno, 1 a 200). 200 TEC IDs únicos, nenhum duplicado. Todas as 200 casaram com uma entrada na grade de Gabarito.

- 111 questões com 5 alternativas letradas.
- 81 questões com 4 alternativas letradas.
- 8 questões Certo/Errado sem alternativas letradas (formato CEBRASPE "julgue o item"), gabarito confirmado como `Certo`/`Errado` em todas — nenhuma vazia por falha de parsing.

## 5. Validação automática (parser quote-aware)

- 200 linhas de dados, 16 colunas consistentes em todas as linhas.
- `caderno_numero`: 200 valores únicos (1–200), **caderno 999 não se aplica a este arquivo** (não existe aqui).
- `tec_id`: 200 valores únicos.
- `gabarito`: nenhum vazio; conjunto de valores = {A, B, C, D, E, Certo, Errado} — nenhum lixo de parsing.
- `enunciado_resumo`: nenhum vazio.
- Checagem cruzada gabarito × alternativas: nenhuma questão com gabarito fora do conjunto de letras realmente presentes nas suas alternativas.
- Varredura por resíduo de parsing (`tecconcursos`, `imprimir`, `www.` residual, `/43`) no enunciado/alternativas de todas as 200: **0 ocorrências**.

## 6. Classificação heurística de unidade (não é leitura individual)

O caderno cobre apenas dois cabeçalhos de classificação do TEC:

- `Disposições Preliminares (arts. 1º a 4º da Lei nº 11.340/2006)`
- `Da Violência Doméstica e Familiar Contra a Mulher (arts. 5º a 7º da Lei nº 11.340/2006)`

Ambos os intervalos (1º–4º e 5º–7º) estão inteiramente contidos em **U1 (arts. 1º–7º)**. Por isso as 200 questões foram marcadas heuristicamente `unidade=U1`, `confianca=baixa`, `uso_pedagogico=BANCO_GERAL_MISSAO_FINAL` — **nenhuma foi lida individualmente nesta fase**. Mesmo padrão de cautela da fase anterior: o cabeçalho do TEC indica a seção do material, não necessariamente o dispositivo realmente cobrado pela alternativa correta (risco já registrado no inventário dos 800). Antes de qualquer uso como prática de unidade (`PRATICA_UNIDADE`), é necessária leitura humana completa, questão a questão.

## 7. Duplicata interna encontrada

**Caderno 192 (TEC 3655033) e caderno 193 (TEC 3653091)**: enunciado e as 5 alternativas idênticos, mesmo gabarito (`C`), mesma banca (CPCON UEPB), concursos municipais distintos (Pref. R. Sto Antônio vs. Pref. São Bentinho) — mesma questão reaproveitada pela banca em dois editais simultâneos. Marcada nas duas linhas do CSV (campo `motivo`); nenhuma das duas foi descartada — a decisão de manter só uma cabe à fase de deduplicação (quando o Supabase voltar a responder), não a este inventário.

Nenhuma outra duplicata interna (por TEC ID ou por enunciado normalizado) encontrada entre as 200.

## 8. O que este inventário NÃO fez (bloqueios explícitos)

- **Nenhuma comparação com o Supabase** (Camadas A/B/C) — MCP bloqueado por token não herdado. Todas as 200 linhas estão com `status_comparacao=PENDENTE_COMPARACAO_SUPABASE` e `questao_existente_id` vazio.
- **Nenhuma leitura jurídico-pedagógica individual** das 200 — classificação de unidade é heurística, `confianca=baixa` em todas.
- **Nenhuma junção com o inventário dos outros 4 cadernos** (201–1000).
- **Nenhuma importação, INSERT/UPDATE/DELETE, migration, commit ou push.**

## 9. Próximos passos (dependem do token do Supabase)

1. Destravar `SUPABASE_ACCESS_TOKEN` no processo do Claude Code.
2. Rodar Camadas A/B/C de deduplicação para estas 200 (mesmo método já aplicado às 800 anteriores), incluindo checagem específica do par 192/193 contra o banco.
3. Decidir se este inventário é então mesclado ao `inventario_lei_maria_penha_tec_pdfs.csv` (formando a base completa de 1.000 questões) ou mantido separado.
4. Só depois disso: leitura jurídico-pedagógica individual das candidatas a `PRATICA_UNIDADE`, seguindo a mesma ordem de prioridade (U5→U4→U2→U3→U1) usada na fase anterior.
