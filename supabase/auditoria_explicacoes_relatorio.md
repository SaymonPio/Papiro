# Auditoria de `questoes.explicacao` — regra fixa de qualidade

Auditoria completa, somente leitura, via MCP contra o Supabase real (nenhum `INSERT`/`UPDATE`/`DELETE`). Números revalidados nesta sessão, não reaproveitados de rodadas anteriores. Classificador determinístico: `supabase/classificar_explicacoes_questoes.sql`. Dataset completo linha a linha: `supabase/auditoria_explicacoes_questoes.csv` (731 linhas).

## 1. Totais reais

| Métrica | Valor |
|---|---|
| Total de questões | **731** |
| Ativas | 727 |
| Inativas | 4 |
| `explicacao` NULL | 85 |
| `explicacao` string vazia (`''`) | 0 |
| Matérias distintas | 13 |
| Assuntos distintos | 107 |
| Questões Certo/Errado (2 alternativas "Certo"/"Errado") | 12 |
| Questões múltipla escolha | 719 |

## 2. Distribuição dos 5 status (classificador determinístico)

| Status | Qtde | % |
|---|---|---|
| **SEM_EXPLICACAO** | 85 | 11,6% |
| **EXPLICACAO_GENERICA** | 374 | 51,2% |
| **EXPLICACAO_INCOMPLETA** | 272 | 37,2% |
| **EXPLICACAO_COMPLETA** | 0 | 0% |
| **PROBLEMATICA** | 0 | 0% |
| **Soma** | **731** | **100%** |

`EXPLICACAO_COMPLETA = 0` é esperado: a estrutura obrigatória (GABARITO + justificativa da correta + justificativa individual de cada incorreta + BIZU DE PROVA) é uma regra nova, nunca aplicada a nenhuma questão existente até agora. `PROBLEMATICA = 0` (integridade de gabarito: nenhuma questão com 0 ou mais de 1 alternativa marcada correta) é uma boa notícia — o estoque atual não tem inconsistência estrutural de gabarito, só de texto explicativo.

**Conclusão direta: praticamente 100% do banco (731 de 731) precisa de `explicacao` reescrita para atingir `EXPLICACAO_COMPLETA`.**

## 3. Matérias afetadas

| Matéria | Total | SEM_EXPLICACAO | GENÉRICA | INCOMPLETA |
|---|---|---|---|---|
| Legislação Específica | 305 | 85 | 164 | 56 |
| Língua Portuguesa | 162 | 0 | 99 | 63 |
| Direitos Humanos e Cidadania | 126 | 0 | 47 | 79 |
| Informática | 89 | 0 | 63 | 26 |
| Raciocínio Lógico | 34 | 0 | 1 | 33 |
| Matemática | 4 | 0 | 0 | 4 |
| Conhecimentos Gerais | 3 | 0 | 0 | 3 |
| Direito Processual Penal | 2 | 0 | 0 | 2 |
| Direito Penal | 2 | 0 | 0 | 2 |
| Legislação de Guardas Municipais | 1 | 0 | 0 | 1 |
| Legislação de Trânsito | 1 | 0 | 0 | 1 |
| Legislação Penal Especial | 1 | 0 | 0 | 1 |
| Direito Constitucional | 1 | 0 | 0 | 1 |

Dentro de "Legislação Específica" (107 assuntos distintos no total do banco), o assunto **Lei Maria da Penha** concentra 117 questões: 85 SEM_EXPLICACAO (as 85 do Lote 1 importado nesta mesma sessão, que nunca receberam `explicacao`), 28 GENÉRICA, 4 INCOMPLETA — 0 COMPLETA. Outros assuntos com volume relevante de GENÉRICA: Direitos e Garantias Fundamentais (19), Improbidade Administrativa (15), Lei de Drogas (13), Constituição do RS (13), Constituição Federal (11), Estatuto do Desarmamento (10).

## 4. Exemplos reais de cada categoria

**SEM_EXPLICACAO** (questão 1303, Lei Maria da Penha — uma das 85 do Lote 1):
> `explicacao` = `NULL`. Enunciado: "De acordo com o disposto na Lei Maria da Penha (Lei nº 11.340/2006), a proteção e os direitos das mulheres em situação de violência doméstica e familiar incluem:"

**EXPLICACAO_GENERICA** (questão 838):
> "Gabarito indicado no Caderno TEC enviado pelo usuário: alternativa A." (69 caracteres — este é o padrão dominante, 280 das 374 genéricas são exatamente esta frase variando só a letra)

**EXPLICACAO_GENERICA**, variante (questão 366):
> "Gabarito definitivo Fundatec: alternativa B. Questão original do concurso do CBMRS 2025." (88 caracteres)

**EXPLICACAO_INCOMPLETA** (questão 4, Legislação de Trânsito):
> "Fundamento legal: art. 70 do Código de Trânsito Brasileiro (Lei nº 9.503/1997). O pedestre que estiver atravessando na faixa delimitada tem prioridade de passagem, salvo nos locais com sinalização semafórica. Assim, o condutor deve reduzir a velocidade e conceder passagem, tornando correta a primeira alternativa." — tem conteúdo real e cita o fundamento legal, mas não comenta as demais alternativas individualmente nem tem BIZU DE PROVA.

**PROBLEMATICA**: nenhum exemplo — 0 questões nesta categoria nesta auditoria.

**EXPLICACAO_COMPLETA**: nenhum exemplo — 0 questões, regra nova.

## 5. Quantidade que precisa ser reescrita

**731 de 731** (100%) para chegar em `EXPLICACAO_COMPLETA` sob a regra nova — incluindo as 272 já "INCOMPLETA" com conteúdo real aproveitável (podem ser enriquecidas, não descartadas) e as 374 "GENÉRICA" que precisam ser escritas do zero.

Este é um esforço de geração de conteúdo pedagógico-jurídico em escala de centenas de questões, cobrindo 13 matérias e 107 assuntos distintos — não é uma correção mecânica. Exige conhecimento técnico real por assunto (direito penal, processual penal, administrativo, constitucional, português, informática, raciocínio lógico, etc.) para não fabricar fundamento.

## 6. Estratégia de processamento em lotes

- **Lote 1 proposto: Lei Maria da Penha (117 questões)** — é o único assunto onde já validei article-by-article (U1–U5, arts. 1º–46) ao longo desta sessão inteira (classificação de unidades, importação do Lote 1, prévia admin). É o lote de maior confiança técnica possível agora, e fecha 100% de um assunto inteiro de uma vez (as 85 SEM_EXPLICACAO + 28 GENÉRICA + 4 INCOMPLETA).
- Tamanho por sub-lote dentro da Lei Maria da Penha: 40–50 questões (dentro da faixa sugerida de 50–100, mais conservador pela exigência de precisão jurídica individual por alternativa).
- Depois de fechar Lei Maria da Penha: priorizar por volume dentro de "Legislação Específica" (mesma matéria, mesmo tipo de exigência jurídica) antes de migrar para Língua Portuguesa/Direitos Humanos/Informática/Raciocínio Lógico (matérias diferentes, exigem calibração de "BIZU DE PROVA" e estrutura de justificativa adaptada ao tipo de conteúdo — ex.: uma questão de informática não tem "artigo/dispositivo" para citar).
- Cada sub-lote segue o pipeline pedido: diagnóstico → geração das explicações → validação estrutural (mesmo classificador acima, aplicado às explicações NOVAS antes de qualquer escrita) → harness transacional com `BEGIN`/`UPDATE`/asserts/`ROLLBACK` → só depois SQL de aplicação real → pós-check.
- Nenhuma questão PROBLEMATICA seria atualizada automaticamente (não há nenhuma nesta rodada, mas a regra fica valendo para lotes futuros se aparecer).
