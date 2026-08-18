# Estado do Lote 2 — Lei Maria da Penha (Fase 3C fechada, checkpoint 2026-08-18)

Este diretório documenta todo o trabalho feito no Lote 2 (Fase 1, Fase 2,
Fase 3A, Fase 3B) da importação de questões novas de Lei Maria da Penha, e
o resultado final da Fase 3C — que **já foi aplicada ao Supabase**. Este
não é mais um checkpoint de trabalho pendente: descreve o estado real e
fechado desta frente.

## Onde paramos

- **Fase 3B** (redação das explicações pedagógicas): concluída para os
  **sub-lotes 1 a 5** (187 explicações). Sub-lotes 6 a 14 (333 candidatas
  restantes do pool de 520) **não foram iniciados e não estão planejados
  no momento** — ver "Próximo passo" abaixo.
- **Fase 3C** (reconciliação, harness, apply, pós-check): **concluída e
  aplicada**. Das 187 explicações prontas, 184 foram efetivamente
  importadas ao Supabase (3 eram duplicatas confirmadas de questões já
  existentes — ver abaixo). Pós-check somente leitura aprovado.
- **Fechamento adicional**: 2 questões pré-existentes de Lei Maria da
  Penha (ids 1337 e 1340, não relacionadas ao Lote 2) foram auditadas,
  classificadas como `DESATUALIZADA_TEMA_1186_STJ` e desativadas — ver
  abaixo.

## Fases concluídas

- **Fase 1** (auditoria de quantidade/dedup dos 722 candidatos originais
  extraídos dos PDFs TEC Concursos) — concluída, aprovada pelo usuário.
- **Fase 2** (auditoria jurídica sub-lote a sub-lote, 14 sub-lotes, 533
  candidatas) — concluída, aprovada pelo usuário.
- **Fase 3A** (extração + normalização das aprovadas para um pool limpo) —
  concluída, aprovada pelo usuário. Resultado inicial: 521 candidatas
  limpas (depois reduzido a 520, ver abaixo).
- **Fase 3B** (redação de explicações pedagógicas, sub-lote a sub-lote) —
  **concluída para os sub-lotes 1-5 de 14** (187 explicações). Sub-lotes
  6-14 não iniciados, sem previsão de retomada no momento.
- **Fase 3C** (reconciliação contra o Supabase, geração de SQL — harness,
  apply —, execução real e pós-check) — **concluída e aplicada**. 184
  questões novas + 766 alternativas inseridas, vinculadas ao curso
  Brigada Militar RS como banco geral.

## Números oficiais consolidados (2026-08-18, pós-fechamento)

- Pool global aprovado para importação (Fase 3A/3B): **520 candidatas**.
- Fase 3B, sub-lotes 1 a 5: **187 explicações** produzidas e validadas.
- Fase 3C — reconciliação contra o Supabase: das 187, **3 eram
  duplicatas confirmadas** de questões já existentes (excluídas da
  importação) e **184 foram efetivamente importadas**:
  - Sub-lote 1: 37 prontas (caderno 225 já excluído na própria Fase 3B)
    → **2 duplicatas** (cadernos 231, 232) → **35 importadas**
  - Sub-lote 2: 38 prontas → **1 duplicata** (caderno 303) → **37
    importadas**
  - Sub-lote 3: 38 prontas → 0 duplicatas → **38 importadas**
  - Sub-lote 4: 37 prontas → 0 duplicatas → **37 importadas**
  - Sub-lote 5: 37 prontas → 0 duplicatas → **37 importadas**
  - **Total importado: 184 questões, 766 alternativas.**
- Total de questões de Lei Maria da Penha no Supabase após a Fase 3C:
  **301** (117 pré-existentes + 184 novas).
- Após a desativação de 1337 e 1340 (ver abaixo): **295 questões ativas**
  de Lei Maria da Penha, **295/295 classificadas como
  `EXPLICACAO_COMPLETA`** — nenhuma questão ativa de Lei Maria da Penha
  fica sem explicação pedagógica completa neste momento.
- Sub-lotes 6 a 14 da Fase 3B (333 candidatas restantes do pool de 520):
  **não iniciados.**

## Questões excluídas/reclassificadas durante a Fase 3B

Estas duas reclassificações aconteceram **depois** da aprovação da Fase 3A
(521 candidatas) e já estão refletidas em todos os arquivos deste
checkpoint (manifesto, pool, conteúdo dos sub-lotes):

- **Caderno 225 (tecId 3502460)** — reclassificada de `VALIDA` para
  `PROBLEMATICA_GABARITO_AMBIGUO` e **excluída da importação**. Motivo: a
  alternativa D ("namorado divulga fotos íntimas sem consentimento")
  também se enquadra em "violação de sua intimidade" (art. 7º, II,
  psicológica, na redação pós-Lei 13.772/2018), tornando-a simultaneamente
  correta com o gabarito original (A) em uma questão de resposta única —
  sem critério textual não arbitrário que preservasse a unicidade de A.
- **Caderno 309 (tecId 3085547)** — upgrade de `VALIDA` para
  `VALIDA_COM_RESSALVA` (**continua aprovada**, não foi excluída). Motivo:
  o enunciado parafraseia o art. 7º, caput, omitindo o "entre outras" do
  texto legal original, apresentando a lista de 5 modalidades como se
  fosse fechada — o gabarito D (moral) permanece correto e único.

## Duplicatas excluídas na reconciliação da Fase 3C

Identificadas por comparação robusta de enunciado/alternativas (hash exato
+ similaridade Jaccard ≥ 0,5, com revisão manual de cada par sinalizado —
o campo `tec_id` sozinho **não é confiável** entre os dois lotes: foi
reciclado para questões de conteúdo diferente em 9 casos verificados e
descartados como falso-positivo durante a auditoria):

- **Caderno 303 / tecId 3299442** (sub-lote 2) = questão já existente id
  778 (hash exato do enunciado normalizado).
- **Caderno 231 / tecId 3486856** (sub-lote 1) = questão já existente id
  347 (mesmo lote Fundatec/CBM-RS-Soldado-2025).
- **Caderno 232 / tecId 3486853** (sub-lote 1) = questão já existente id
  346 (mesmo lote Fundatec/CBM-RS-Soldado-2025).

## Questões desativadas após a Fase 3C (fora do escopo do Lote 2)

Durante o pós-check de cobertura de explicação pedagógica, restavam 2
questões **ativas** de Lei Maria da Penha sem explicação
(`SEM_EXPLICACAO`), pré-existentes e não relacionadas ao Lote 2:

- **ID 1337** (CEBRASPE/CESPE — Escrivão PC BA — 2013, Certo/Errado).
- **ID 1340** (FGR — GM Pref Congonhas — 2012, múltipla escolha).

Auditoria jurídica (2026-08-18): as duas dependiam da doutrina
pré-2023/pré-Tema 1186 sobre motivação de gênero em castigo/maus-tratos
parental, superada pelo art. 40-A da LMP (Lei 14.550/2023) e pelo Tema
Repetitivo 1186/STJ (REsp 2.015.598/PA, vinculante desde 23/10/2025).
Classificadas como **`DESATUALIZADA_TEMA_1186_STJ`**. Decisão de produto:
**não reescrever o gabarito histórico da banca** nem escrever explicação
pedagógica que o justifique como correto hoje — apenas desativar
(`ativa = false`). Enunciado, alternativas, gabarito original, banca,
concurso, fonte e demais metadados preservados integralmente (a tabela
`public.questoes` não tem coluna própria de classificação/motivo, por
isso essa classificação vive apenas nesta documentação).

## Ressalvas ativas nos 5 sub-lotes já escritos (15 no total)

Todas incorporadas explicitamente no texto da explicação pedagógica
correspondente, a maioria relacionada à Lei 15.384/2026 (violência
vicária, art. 7º, VI) sobre questões que enumeram as "5 modalidades
clássicas" sem a ressalva "entre outras":

- Sub-lote 1: cadernos 220, 238, 240, 244, 252
- Sub-lote 2: cadernos 253, 262, 285, 304, 309
- Sub-lote 3: cadernos 319, 335
- Sub-lote 4: cadernos 369, 394, 407
- Sub-lote 5: nenhuma

## Arquivos-fonte da verdade

- `fase1/` — auditoria original dos 722 candidatos extraídos dos PDFs
  (script `lote2-auditoria.mjs`), fingerprints das 117 questões já
  existentes no banco, classificação completa da Fase 1, e as 534
  candidatas NOVA_VALIDA resultantes (depois refinadas para 533 na
  entrada da Fase 2, com 1 candidata tratada separadamente).
- `fase2/` — pool de 533 candidatas com conteúdo completo
  (`lote2_fase2_pool_533.json`), os 14 pares de arquivo
  conteúdo/classificação de cada sub-lote da Fase 2 (auditoria jurídica
  original, com `motivo` preenchido para exclusões e, a partir do
  sub-lote 3, também para ressalvas), e o manifesto consolidado
  (`lote2_manifesto_fase2_533.json` e `.csv`) — **fonte de verdade sobre
  quais candidatas estão aprovadas** (`APROVADA_PARA_PROXIMA_FASE`).
- `fase3a/` — scripts de preparação e normalização
  (`fase3a-preparar-521.mjs`, `fase3a-normalizar-521.mjs`), diagnóstico
  bruto de contaminação, registros pré-normalização, e o pool final
  **`lote2_fase3a_candidatas_limpas_521.json`** — fonte de verdade do
  conteúdo completo (enunciado/alternativas/gabarito já limpos de
  artefatos de OCR/parser). *Nota: o nome do arquivo manteve "521" por
  herança histórica; o conteúdo real tem 520 registros, após a exclusão
  do caderno 225 durante a Fase 3B.*
- `fase3b/` — **`fase3b_sublotes_ids.json`**: array de 14 arrays de
  tecIds, a divisão determinística das 520 aprovadas em sub-lotes de
  ~35–40 (fonte de verdade de qual tecId pertence a qual sub-lote); os 5
  arquivos `fase3b_subloteN_conteudo.json` (N=1..5) com o conteúdo
  completo já extraído de cada sub-lote concluído; e os dois scripts que
  documentam e reproduzem as reclassificações 225 e 309
  (`fase3b-reclassificar-225.mjs`, `fase3b-reclassificar-309.mjs`).
- As explicações pedagógicas em si (o produto da Fase 3B) **não estão
  neste diretório** — ficam em
  `scripts/lote2-fase3b-sublote{1..5}-explicacoes.mjs` e seus
  validadores `scripts/validar-lote2-fase3b-sublote{1..5}.mjs`, na raiz
  do projeto. `generate-lote2-fase3c-harness.mjs` lê os dois grupos de
  arquivos (`fase3b/fase3b_subloteN_conteudo.json` +
  `scripts/lote2-fase3b-subloteN-explicacoes.mjs`) para montar o SQL da
  Fase 3C.
- O SQL da Fase 3C (harness + apply, já aplicado) e o SQL da desativação
  de 1337/1340 (harness + apply, já aplicado) ficam direto em
  `supabase/` (`importar_lote2_fase3c_lei_maria_penha*.sql`,
  `desativar_1337_1340_desatualizada_tema1186*.sql`), não dentro deste
  diretório de estado.

## Próximo passo

**Não é o Sub-lote 6.** A prioridade do projeto foi reavaliada: o próximo
macro passo é uma **auditoria das demais questões já existentes no
Papiro** (todas as matérias/assuntos, não só Lei Maria da Penha) para
garantir que todo o banco **ativo** tenha explicação pedagógica completa
(`EXPLICACAO_COMPLETA`). Os sub-lotes 6 a 14 da Fase 3B (333 candidatas
restantes do pool de 520) ficam pausados até nova decisão explícita — todo
o material-fonte para retomá-los continua preservado em
`fase3b/fase3b_sublotes_ids.json` e
`fase3a/lote2_fase3a_candidatas_limpas_521.json`.

## O que foi feito

- Fase 3B concluída para os sub-lotes 1-5 (187 explicações).
- Fase 3C aplicada ao Supabase: 184 questões + 766 alternativas
  inseridas, vinculadas ao curso Brigada Militar RS.
- 2 questões pré-existentes (1337, 1340) desativadas por estarem
  desatualizadas frente ao Tema 1186/STJ, com gabarito histórico
  preservado.
- Todo o trabalho desta frente fechado em commits nesta rodada.

## O que NÃO foi feito (não presumir o contrário)

- Sub-lotes 6 a 14 da Fase 3B (333 candidatas) não têm explicação
  escrita — nenhum novo import está planejado no momento.
- Nenhum gabarito histórico foi reescrito (nem o de 1337/1340, nem
  qualquer outro) — divergências frente à lei/jurisprudência atual são
  tratadas por desativação, nunca por edição silenciosa do gabarito
  original da banca.
- Push para o remoto: não realizado nesta rodada.
