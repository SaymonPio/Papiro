# Inventário — 4 cadernos TEC da Lei Maria da Penha (201–1000)

Fase de **inventário/comparação**, sem nenhuma escrita no Supabase (nenhum INSERT/UPDATE/DELETE/migration). MCP Supabase usado somente em modo leitura. Este documento acompanha `inventario_lei_maria_penha_tec_pdfs.csv` (uma linha por questão extraída, 800 linhas de dados).

## 1. Arquivos-fonte

`C:\Users\User\Desktop\Concursos\PROVAS\`:
- `Caderno Lei Maria da Penha - 201 ao 400.pdf`
- `Caderno Lei Maria da Penha - 401 ao 600.pdf`
- `Caderno Lei Maria da Penha - 601 ao 800.pdf`
- `Caderno Lei Maria da Penha - 800 ao 1000.pdf`

Extração de texto com `pdftotext -layout -enc UTF-8` (poppler-utils), parser Node.js próprio (não OCR/visão) — os PDFs são exportações digitais do TEC Concursos, com URL `tecconcursos.com.br/questoes/<TEC_ID>`, banca/concurso/ano, classificação do TEC, enunciado, alternativas e uma seção `Gabarito` única no fim de cada caderno.

## 2. Estado do banco revalidado antes da comparação

Confirmado idêntico ao descrito pelo usuário: 646 questões totais; conteúdo 53 com 5 unidades ativas; 31 vínculos / 28 questões classificadas (U1=14, U2=6, U3=9, U4=2, U5=0); multiunidade atuais 51/673/799. Nenhuma divergência.

## 3. Schema real (Etapa 4)

`public.questoes` **não tem** coluna dedicada a TEC ID/URL. A origem é registrada em `fonte` (texto livre). Parte das 646 questões já tem o padrão `"TEC Concursos — questão <ID> — <BANCA> — posição <N> no conjunto de 1.000 questões"`, o que permitiu extrair por regex os TEC IDs já importados (22 encontrados para `assunto_id=19`; 8 desses 22 caem dentro do intervalo 201–1000 coberto pelos 4 PDFs desta fase — os outros 14 pertencem ao caderno "1 ao 200", fora do escopo pedido). Não existe `tec_id` estruturado — registrado aqui como pendência de schema, **nenhuma migration foi feita**.

## 4. Extração

800 questões extraídas (200 por caderno). Todas as 800 URLs/TEC IDs do universo de 800 foram capturadas (confirmado por diff contra ocorrências brutas de `tecconcursos.com.br/questoes/<id>` no texto). Bugs de parsing corrigidos durante a extração (CRLF quebrando `$`, indentação variável de alternativas, classificação do TEC quebrando em 2 linhas, marcador de URL com espaço/rodapé de página colado) — 0 questões com "sem gabarito" ou "sem alternativas" no resultado final.

Achado estrutural do próprio material: a questão de caderno 600 (TEC 1978066) está **duplicada entre os arquivos** "401 ao 600" e "601 ao 800" (overlap de fronteira do próprio TEC) — tratada como 1 duplicata interna.

## 5. Deduplicação interna (revalidada do zero, incluindo a hipótese antiga 973/993)

- 1 duplicata por TEC ID (overlap de fronteira, acima).
- 3 pares com enunciado E alternativas idênticos (246/247, 623/624, 892/917).
- **973/993 revalidado**: mesmo enunciado, mesma banca, mesmas 4 alternativas — **mas gabarito oficial diverge (973=A, 993=C)**, confirmado na própria grade de Gabarito do PDF. Não é duplicata segura: ambas marcadas **PROBLEMATICA**, nenhuma das duas entra no pool de comparação.
- Mais 4 problemáticas de parsing achadas por varredura heurística (vírgula extraída como ponto final, fragmento de alternativa vazado): cadernos 251, 366, 870, 996.
- 1 problemática por depender de imagem ausente ("Figura 1", caderno 431).
- 1 problemática por ambiguidade estrutural de parsing (lista lettered intermediária confundida com alternativas, caderno 489).

Total problemáticas: **8**. Total duplicatas internas: **4**.

## 6. Comparação com o Supabase (camadas A/B/C)

- **Camada A** (TEC ID exato): comparado contra os 22 TEC IDs já registrados em `fonte` para `assunto_id=19`.
- **Camada B** (enunciado normalizado exato, exigindo também alternativas compatíveis — um "stub" de enunciado idêntico com alternativas totalmente diferentes NÃO é tratado como a mesma questão).
- **Camada C** (near-duplicate por similaridade de Jaccard sobre enunciado+alternativas combinados, limiar 0,35): candidatos revisados manualmente, nunca descartados automaticamente. Os 5 candidatos de maior similaridade foram lidos por completo (enunciado + todas as alternativas + gabarito): 2 confirmados como a mesma questão já existente (346, 347 — ganharam apenas uma frase de abertura no caderno novo), 3 confirmados como questões genuinamente diferentes apesar do "stub" de enunciado idêntico.

Resultado: **10 JA_EXISTE**, **73 NEAR_DUPLICATE_REVISAR** (não resolvidos automaticamente — ver seção 9).

## 7. Curadoria jurídico-pedagógica (Etapa 8) — leitura manual completa

Dada a escala (705 NOVA), a leitura individual completa (enunciado + todas as alternativas + gabarito) foi priorizada exatamente na ordem pedida — **1) U5, 2) U4, 3) U2, 4) U3, 5) U1** — usando um detector de artigos citados no texto real (não no cabeçalho do TEC) para pré-selecionar candidatas, seguido de leitura humana de cada uma:

- **49 candidatas heurísticas de U4/U5** lidas por completo → após leitura, apenas 9 confirmaram U4 e 3 confirmaram U5 (sozinhas ou em multiunidade); a maioria era falso positivo de U1 (o cabeçalho do TEC ou uma citação decorativa de artigo no enunciado não correspondia ao dispositivo realmente cobrado pela alternativa correta — exatamente o risco que a Etapa 9 do prompt mestre alertou). 5 confirmaram-se como **BANCO_GERAL/MISSÃO FINAL** (misturam dispositivos de blocos diferentes, ex.: art. 5º + art. 9º + art. 22 na mesma bateria de itens V/F).
- **38 candidatas heurísticas de U2/U3** lidas por completo → 15 U2, 8 U3, mais combinações multiunidade, 2 BANCO_GERAL, 6 reclassificadas para U1 (falso positivo), 1 para U5.
- Total: **87 questões NOVA lidas integralmente nesta fase** e classificadas com confiança real (alta/média/baixa conforme a leitura, nunca "alta" por padrão).

As **618 questões NOVA restantes** (majoritariamente U1 pelo detector heurístico de artigo/vocabulário, já que U1 domina numericamente o material do TEC) **não foram lidas individualmente nesta fase** — ficam com `uso_pedagogico=BANCO_GERAL_MISSAO_FINAL` e `confianca=baixa` no CSV, com o método heurístico registrado no campo `motivo`, para uma leitura dedicada futura (mesmo padrão da fase anterior, que tratou apenas 28 questões com rigor total). Isso é uma decisão de escopo explícita, não uma omissão silenciosa.

## 8. Validade e questões antigas (Etapas 11–12)

Nenhuma questão descartada por ser antiga. Nenhuma tentativa de "corrigir" questão de prova original. As 8 problemáticas têm motivo registrado (nunca descarte silencioso). Nenhuma revisão jurídica de redação legal desatualizada foi necessária nas 87 lidas integralmente (todas testam dispositivos ainda vigentes na redação apresentada).

## 9. Itens que exigem revisão humana antes de qualquer importação

- **8 PROBLEMATICA** (cadernos 251, 366, 431, 489, 870, 973, 993, 996) — ver `motivo` no CSV.
- **73 NEAR_DUPLICATE_REVISAR** — candidatas por similaridade (0,35–1,0) contra o banco existente, não resolvidas automaticamente; ver `questao_existente_id` e `motivo` no CSV para decidir NOVA vs. JA_EXISTE questão a questão.
- **618 NOVA classificadas só heuristicamente** (não lidas individualmente) — qualquer uma marcada `PRATICA_UNIDADE` no futuro precisa antes de leitura humana completa, seguindo o mesmo padrão rigoroso desta fase.
