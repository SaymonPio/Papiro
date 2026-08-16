# LOTE 1 — Importação Lei Maria da Penha (TEC Concursos) — Auditoria Final

Este documento é o resumo do `lote_1_importacao_lei_maria_penha_tec.csv`. Nenhuma escrita foi feita no Supabase nesta etapa (leitura apenas, e mesmo assim só em arquivos locais — o MCP não foi usado nesta rodada). Nenhum SQL de INSERT foi criado.

## 0. AUDITORIA DE INTEGRIDADE — erro estrutural confirmado e corrigido

Um erro estrutural real foi identificado e confirmado pelo usuário no exemplo do `caderno_numero` 216: o CSV do Lote 1 tinha `tec_id = 3567138` / banca `AMEOSC`, mas o bloco 216 no PDF original termina com `tec_id = 3564240` / banca `IGEDUC`.

**Auditoria completa das 87 questões, uma a uma, direto contra os 4 PDFs originais** (não confiando em nenhum metadado do inventário anterior):

| Métrica | Resultado |
|---|---|
| Questões auditadas contra o PDF | 87/87 |
| `tudo_confere` nos metadados originais (tec_id+banca+concurso+ano+gabarito) | **0/87** |
| `tec_id` incorreto no inventário original | 86/87 |
| `banca` incorreta | 83/87 |
| `concurso` incorreto | 86/87 |
| `ano` incorreto | 3/87 |
| `gabarito` incorreto | **0/87** (gabarito sempre esteve correto) |
| Metadados não localizáveis no PDF (cauda ausente) | 1/87 (caderno 999) |

### Causa raiz confirmada

Não é um erro aleatório: é um **deslocamento sistemático de -1 posição** no pareamento entre o texto de cada questão e a metadata de origem (URL/banca/concurso) que a segue no PDF. Prova direta encontrada em pares de questões consecutivas dentro dos próprios 87:

- Linha `caderno_numero = 954`: `tec_id_pdf = 3791633`. Linha `caderno_numero = 955`: `tec_id_csv (original) = 3791633`. O valor que o inventário atribuiu à questão 955 é, na verdade, o tec_id real da questão 954.
- Mesmo padrão em `949→950` (`tec_id_pdf` de 949 = `tec_id_csv` original de 950).

Ou seja, o inventário anterior pareou a metadata de cada questão com a **questão seguinte** do PDF, não com ela mesma. Esse deslocamento é uniforme e afeta virtualmente 100% das linhas — **não é um problema isolado do Lote 1**: como o mesmo mecanismo de extração gerou as 800 linhas do inventário original (`inventario_lei_maria_penha_tec_pdfs.csv`), é muito provável que as outras 618 questões `NOVA` pendentes (e possivelmente as 95 já marcadas como duplicata/problemática/já-existe) tenham o mesmo problema de tec_id/banca/concurso/ano. **Isso precisa ser reauditado antes de qualquer uso futuro do inventário completo — recomendação registrada, fora do escopo desta correção pontual do Lote 1.**

O `enunciado`, as `alternativas` e o `gabarito` **não** foram afetados por esse bug: eles já vinham de uma extração própria desta sessão, ancorada diretamente no número da questão (não na cauda deslocada), e o gabarito é lido de uma tabela separada (grade de respostas no fim do PDF, indexada por `caderno_numero`). Por isso 0/87 gabaritos precisaram de correção.

### Correção aplicada

Para 86 das 87 questões, `tec_id`, `banca`, `concurso` e `ano` no CSV foram **substituídos** pelos valores extraídos diretamente da cauda do bloco de cada questão no PDF (a mesma técnica any-page-join já usada para o enunciado, agora também aplicada à cauda que seguia as alternativas).

A questão **999** é a última questão impressa no arquivo "800 ao 1000.pdf" — sua cauda (URL/banca/concurso) não está presente no texto extraído (provável perda de texto na borda entre a última página de questões e a página de Gabarito). Não foi possível confirmar seus metadados contra o PDF por extração de texto. **999 foi excluída deste Lote 1** e marcada para checagem visual manual direta no PDF antes de qualquer importação futura — nenhum valor foi assumido ou herdado de outra questão.

**Tabela completa de auditoria (87 linhas)**: `caderno_numero`, `tec_id_csv`, `tec_id_pdf`, `banca_csv`, `banca_pdf`, `gabarito_csv`, `gabarito_pdf` — ver arquivo anexo de conferência linha a linha, reproduzida abaixo por completo:

| caderno_numero | tec_id_csv (original) | tec_id_pdf | banca_csv (original) | banca_pdf | gabarito_csv | gabarito_pdf | status |
|---|---|---|---|---|---|---|---|
| 216 | 3567138 | 3564240 | AMEOSC | IGEDUC | A | A | corrigido |
| 221 | 3526989 | 3520358 | Instituto AOCP | FACAPE | E | E | corrigido |
| 260 | 3212927 | 3824093 | IDECAN | Instituto ACCESS | E | E | corrigido |
| 275 | 3140855 | 3138220 | VUNESP | IGEDUC | B | B | corrigido |
| 284 | 3181094 | 3124680 | Instituto Consulplan | FAUEL | B | B | corrigido |
| 370 | 2940236 | 2936068 | Instituto Consulplan | FGV | B | B | corrigido |
| 378 | 2922139 | 2919563 | ADM&TEC | MS (SARMENTO) | B | B | corrigido |
| 393 | 3169224 | 2718877 | CONSULPLAN | IBAM | B | B | corrigido |
| 395 | 3677814 | 3622849 | CEPS UFPA | URI | C | C | corrigido |
| 411 | 2967869 | 2925122 | ITAME | IBFC | A | A | corrigido |
| 429 | 2837114 | 2832645 | IBFC | FUNDATEC | C | C | corrigido |
| 436 | 2830569 | 2828648 | FUNDATEC | FCC | D | D | corrigido |
| 441 | 2786206 | 2769196 | FUNDEP | INSTITUTO MAIS | A | A | corrigido |
| 468 | 2585918 | 2582271 | FURB | Unifil | C | C | corrigido |
| 470 | 2582270 | 2561017 | Unifil | FUNDATEC | B | B | corrigido |
| 481 | 2504272 | 2480489 | Instituto Consulplan | Instituto ACCESS | E | E | corrigido |
| 484 | 2464145 | 2460051 | CEBRASPE (CESPE) | FUNDATEC | A | A | corrigido |
| 534 | 2967667 | 2028910 | FAURGS | CEBRASPE (CESPE) | D | D | corrigido |
| 561 | 2173152 | 3095842 | MetroCapital | EJUD PI | A | A | corrigido |
| 574 | 2222736 | 2748613 | Instituto Consulplan | IVIN | B | B | corrigido |
| 577 | 2223086 | 2505524 | FGV | FUNDATEC | B | B | corrigido |
| 606 | 1641990 | 1752622 | CONSULTEC (AIETEC) | CEBRASPE (CESPE) | A | A | corrigido |
| 619 | 1829244 | 1789562 | FAPEC | FGV | E | E | corrigido |
| 646 | 1554373 | 1256097 | CEBRASPE (CESPE) | VUNESP | Certo | Certo | corrigido |
| 653 | 1585068 | 1501575 | FAUEL | EDUCA PB | B | B | corrigido |
| 664 | 1554384 | 1479113 | CEBRASPE (CESPE) | IBADE | Certo | Certo | corrigido |
| 696 | 898016 | 908463 | FUNDATEC | CEBRASPE (CESPE) | A | A | corrigido |
| 706 | 863770 | 861698 | FGV | VUNESP | B | B | corrigido |
| 711 | 851853 | 838571 | VUNESP | IBRAE | A | A | corrigido |
| 726 | 1598120 | 1270278 | FURB | OBJETIVA CONCURSOS | C | C | corrigido |
| 728 | 1271285 | 1273091 | OBJETIVA CONCURSOS | OBJETIVA CONCURSOS | A | A | corrigido |
| 730 | 1279956 | 1284278 | OBJETIVA CONCURSOS | OBJETIVA CONCURSOS | A | A | corrigido |
| 738 | 667776 | 714814 | VUNESP | IADES | D | D | corrigido |
| 739 | 714814 | 692312 | IADES | IBADE | E | E | corrigido |
| 741 | 596468 | 612958 | CEBRASPE (CESPE) | AOCP | Errado | Errado | corrigido |
| 749 | 1459192 | 1336891 | CEV URCA | IMPARH | D | D | corrigido |
| 774 | 793011 | 1742016 | QUADRIX | EJUD PI | Errado | Errado | corrigido |
| 786 | 3680871 | 631048 | IAUPE | IESES | A | A | corrigido |
| 804 | 360340 | 581287 | CEBRASPE (CESPE) | COSEAC UFF | E | E | corrigido |
| 818 | 299201 | 301540 | VUNESP | SMA-RJ (antiga FJG) | C | C | corrigido |
| 823 | 322998 | 328682 | FGV | FCC | D | D | corrigido |
| 851 | 282167 | 972388 | FGV | FUNRIO | E | E | corrigido |
| 863 | 179821 | 215155 | CEBRASPE (CESPE) | VUNESP | Certo | Certo | corrigido |
| 864 | 215155 | 492358 | VUNESP | Com. Exam. (MPE PR) | C | C | corrigido |
| 871 | 140829 | 496087 | VUNESP | ESPP | C | C | corrigido |
| 884 | 166861 | 3500525 | CEBRASPE (CESPE) | FADURPE | C | C | corrigido |
| 889 | 106097 | 113946 | CEBRASPE (CESPE) | CEBRASPE (CESPE) | Certo | Certo | corrigido |
| 908 | 2376414 | 1569268 | FUNDEP | FCC | A | A | corrigido |
| 912 | 1299469 | 1254876 | CEBRASPE (CESPE) | CAIPIMES | Errado | Errado | corrigido |
| 921 | 139609 | 802381 | OFFICIUM | FGR | D | D | corrigido |
| 926 | 802944 | 2951436 | FGR | COPS UEL | D | D | corrigido |
| 941 | 435118 | 1714489 | UNEMAT | CCC IFCE | B | B | corrigido |
| 943 | 24973 | 686025 | FGV | FCC | B | B | corrigido |
| 945 | 288217 | 2184657 | CEBRASPE (CESPE) | VUNESP | Certo | Certo | corrigido |
| 947 | 490131 | 1060353 | CRS (PM MG) | INSTITUTO OPET | A | A | corrigido |
| 949 | 3848096 | 3803406 | CPCON UEPB | FGV | C | C | corrigido |
| 950 | 3803406 | 3818504 | FGV | FUNDATEC | C | C | corrigido |
| 954 | 3801270 | 3791633 | FUNDATEC | Instituto AOCP | B | B | corrigido |
| 955 | 3791633 | 3771993 | Instituto AOCP | Unifil | C | C | corrigido |
| 956 | 3771993 | 4042000 | Unifil | CEBRASPE (CESPE) | A | A | corrigido |
| 957 | 4042000 | 3949276 | CEBRASPE (CESPE) | IBFC | A | A | corrigido |
| 960 | 3917671 | 3803957 | Instituto Verbena | FGV | C | C | corrigido |
| 961 | 3803957 | 3475690 | FGV | CEBRASPE (CESPE) | B | B | corrigido |
| 962 | 3475690 | 3542689 | CEBRASPE (CESPE) | IBADE | C | C | corrigido |
| 964 | 3342557 | 3462034 | Instituto Consulplan | AVANÇASP | D | D | corrigido |
| 965 | 3462034 | 3606498 | AVANÇASP | CEBRASPE (CESPE) | B | B | corrigido |
| 967 | 3891844 | 3606496 | Instituto AVALIA | CEBRASPE (CESPE) | A | A | corrigido |
| 969 | 3452342 | 3605442 | FUNDATEC | Legatus | D | D | corrigido |
| 970 | 3605442 | 3719812 | Legatus | CEV URCA | E | E | corrigido |
| 971 | 3719812 | 3675819 | CEV URCA | FUNDATEC | B | B | corrigido |
| 972 | 3675819 | 3559254 | FUNDATEC | COGEPS UNIOESTE | A | A | corrigido |
| 974 | 3718860 | 3237914 | CEV URCA | CEBRASPE (CESPE) | C | C | corrigido |
| 975 | 3237914 | 3339061 | CEBRASPE (CESPE) | FAFIPA | Certo | Certo | corrigido |
| 976 | 3339061 | 3750104 | FAFIPA | FUNDATEC | E | E | corrigido |
| 980 | 3345653 | 3749202 | CEBRASPE (CESPE) | EDUCA PB | Errado | Errado | corrigido |
| 981 | 3749202 | 3500155 | EDUCA PB | CEBRASPE (CESPE) | D | D | corrigido |
| 982 | 3500155 | 3674860 | CEBRASPE (CESPE) | Marinha | Errado | Errado | corrigido |
| 983 | 3674860 | 3417035 | Marinha | VUNESP | B | B | corrigido |
| 984 | 3417035 | 3597170 | VUNESP | IBAM | D | D | corrigido |
| 985 | 3597170 | 3764647 | IBAM | CEV UECE | B | B | corrigido |
| 987 | 3416961 | 3623830 | VUNESP | FUNDATEC | D | D | corrigido |
| 989 | 3407939 | 3852897 | CEBRASPE (CESPE) | FUNDATEC | Errado | Errado | corrigido |
| 991 | 3449577 | 3399155 | Instituto AOCP | FGV | B | B | corrigido |
| 992 | 3399155 | 3559251 | FGV | COGEPS UNIOESTE | D | D | corrigido |
| 994 | 3390467 | 3364927 | Fênix Instituto | OBJETIVA CONCURSOS | B | B | corrigido |
| 995 | 3364927 | 3746930 | OBJETIVA CONCURSOS | EDUCA PB | C | C | corrigido |
| 999 | 3484028 | (não encontrado) | CPCON UEPB | (não encontrado) | B | B | ⚠️ excluída — sem dados no PDF |

## 1. Reconciliação dos números do inventário original

Todos os números do relatório anterior (`inventario_lei_maria_penha_tec_pdfs.md/csv`) foram reconferidos por parsing independente do CSV (parser RFC4180 próprio, não `wc -l`) e batem exatamente:

| Métrica | Valor conferido |
|---|---|
| Linhas de dados no CSV (800 PDFs) | 800 |
| `status_comparacao = NOVA` | 705 |
| `NEAR_DUPLICATE_REVISAR` | 73 |
| `JA_EXISTE` | 10 |
| `DUPLICATA_PDF` | 4 |
| `PROBLEMATICA` | 8 |
| Total não-NOVA (excluídas do universo de importação) | 95 |
| Revisadas manualmente (as 87 deste Lote 1) | 87 (100% `status_comparacao = NOVA`) |
| Restantes por heurística, fora deste lote | 618 |

Zero divergência de contagem. **Ressalva adicionada nesta rodada**: essa reconciliação valida apenas as *contagens* por `status_comparacao`; os campos `tec_id`/`banca`/`concurso`/`ano` do inventário completo de 800 estão sob suspeita do mesmo bug de deslocamento descrito no item 0, e não foram, eles próprios, reauditados nesta rodada (fora do escopo: só as 87 do Lote 1 foram auditadas contra o PDF).

## 2. As 8 questões problemáticas — confirmadas excluídas

IDs (caderno_numero): 251, 366, 431, 489, 870, 973, 993, 996. Nenhuma aparece nas 87. Motivos (do próprio inventário, reconferidos linha a linha no CSV de 800):

- **251, 366, 870, 996**: corrupção sistemática de texto na extração do PDF (vírgula extraída como ponto final, fragmento vazado entre alternativas). Não confiável sem checagem manual contra o PDF original.
- **431**: depende de uma "Figura 1" (imagem/recorte) não disponível em texto.
- **489**: parser confundiu uma lista lettered intermediária do enunciado com as alternativas finais.
- **973 x 993 (conflito de gabarito)**: mesmo enunciado e mesmas alternativas (TEC 3559254 vs TEC 3559251), mas gabarito divergente — 973 = A, 993 = C. Não há como saber qual está correto sem consultar a fonte oficial do concurso; **nenhum gabarito foi escolhido arbitrariamente** — ambas ficam de fora até confirmação externa.

## 3. Situação jurídica — resultado da revisão manual completa (0 desatualizadas)

O primeiro filtro automático (regex por número de artigo alterado entre 2024-2026) sinalizou **31 das 87** questões para revisão manual, por citarem artigos com alterações legislativas recentes:

| Dispositivo alterado | Lei | Nº de questões sinalizadas |
|---|---|---|
| art. 9º, caput (prioridade SUS/SUSP) | Lei 14.887/2024 | 13 |
| art. 11, § único (novo, dever de comunicar trabalho análogo à escravidão) | Lei 15.455/2026 | 8 |
| art. 12-C (afastamento do agressor — ampliação dos tipos de risco) | Lei 15.411/2026 | 7 |
| art. 22 (nova hipótese VIII — monitoração eletrônica; novo §10 — título executivo) | Lei 15.383/2026 e Lei 15.412/2026 | 2 (284, 370; 956 já contado em art.12-C) |
| art. 24-A (crime de descumprimento de medida protetiva) | Lei 14.994/2024 (pena) + Lei 15.383/2026 (§4º) | 1 |

Cada uma das 31 foi lida por inteiro (enunciado + todas as alternativas + gabarito), extraído diretamente do PDF original, e comparada com o texto **atual** de cada dispositivo (levantado via busca externa, já que o planalto.gov.br não respondeu a fetch direto em algumas tentativas — `ECONNRESET` — mitigado com fontes secundárias confiáveis: Câmara dos Deputados, Senado, sites jurídicos especializados, e nesta rodada também via fetch direto bem-sucedido a `camara.leg.br`). Conclusão, dispositivo por dispositivo:

- **art. 9º (13 questões)**: todas testam §1º, §2º ou §3º (vínculo trabalhista por 6 meses, remoção prioritária de servidora pública, benefícios científico-tecnológicos/DST, matrícula escolar prioritária) — nenhuma testa a cláusula do *caput* alterada pela Lei 14.887/2024 ("caráter prioritário no SUS/SUSP"). **ATUAL.**
- **art. 11, § único (8 questões)**: o novo parágrafo trata exclusivamente do dever de comunicar ao Ministério do Trabalho casos de trabalho análogo à escravidão de empregada doméstica — nenhuma das 8 questões menciona esse cenário; todas testam os incisos originais do *caput* (encaminhar ao IML/hospital, informar direitos, colher provas, ouvir a ofendida). **ATUAL.**
- **art. 12-C (7 questões)**: a Lei 15.411/2026 ampliou os *tipos de risco* que justificam o afastamento (incluiu sexual, moral e patrimonial, além de física/psicológica) — mas **não** alterou a cascata de autoridade (juiz → delegado, se não sede de comarca → policial, se delegado indisponível), que é exatamente o que as 7 questões testam. Nenhuma alternativa afirma que a lista de riscos é exaustiva, então nenhuma se torna falsa pela ampliação. **ATUAL.**
- **art. 22 (2 questões, 284 e 370)**: a nova hipótese VIII (monitoração eletrônica) e o novo §10 (título executivo judicial) foram **adicionados**, não substituíram nada. As duas questões citam medidas protetivas "como" (exemplos, não lista fechada) afastamento/porte de armas — permanecem verdadeiras. **ATUAL.**
- **art. 24-A (1 questão, 619, item V) — CORRIGIDO NESTA RODADA**: a afirmação anterior de que este artigo "não foi alterado" estava **errada** e foi corrigida. O art. 24-A **foi**, sim, alterado: (a) a pena foi elevada para reclusão de 2 a 5 anos pela Lei 14.994/2024; (b) um novo §4º foi incluído pela Lei 15.383/2026, prevendo aumento de 1/3 até metade quando o descumprimento envolver rompimento de perímetro de monitoração eletrônica ou violação/alteração do dispositivo. Reavaliado o conteúdo concreto da questão 619: o item V afirma apenas que "é crime a conduta de descumprir decisão judicial que defere medidas protetivas de urgência previstas na Lei 11.340/06" — não menciona valor de pena, nem monitoração eletrônica, nem o §4º. Essa proposição genérica (a existência do crime) continua **integralmente verdadeira** hoje. **Mantida ATUAL** — nenhuma das duas alterações contradiz o que a questão efetivamente testa.

**Resultado final: 87/87 = ATUAL. 0 REVISAO_JURIDICA_NECESSARIA. 0 DESATUALIZADA_NAO_IMPORTAR.** Nenhuma questão foi alterada para caber na lei atual — todas foram avaliadas como estão, no texto original extraído do PDF.

## 4. Prova de multiunidade (nunca por citação genérica)

8 das 87 questões (9,2%) recebem vínculo com mais de uma unidade, sempre porque a **resposta correta exige combinar blocos de artigos distintos** (não porque o enunciado apenas menciona "Lei Maria da Penha" genericamente):

| caderno_numero | tec_id (corrigido) | unidades | motivo |
|---|---|---|---|
| 284 | 3124680 | U4+U5 | combina juizados+equipe multidisciplinar (art. 14/29) com medida protetiva de urgência (art. 22) num único bloco verdadeiro |
| 378 | 2919563 | U1+U2 | combina violação de DH (art. 6º) com política pública articulada (art. 8º) num único bloco |
| 534 | 2028910 | U1+U2 | combina definição do art. 5º com política pública do art. 8º |
| 619 | 1789562 | U1+U4 | combina tipos de violência (art. 7º) com o crime de descumprimento de medida protetiva (art. 24-A) |
| 728 | 1273091 | U1+U3 | combina definição de violência física (art. 7º, I) com providência policial de encaminhar ao IML (art. 11, II) |
| 730 | 1284278 | U1+U5 | exige corrigir duas partes: definição de violência psicológica (art. 7º) e equipe multidisciplinar dos juizados (art. 29) |
| 970 | 3719812 | U3+U4 | combina afastamento pelo policial (art. 12-C) com prisão preventiva/independência das medidas protetivas (arts. 20/19) |
| 984 | 3597170 | U2+U3 | ressarcimento ao SUS (art. 9º) é a resposta certa, mas os distratores pesam substancialmente em art. 10-A/11/12-C |

Como cada questão multiunidade soma 1 vínculo a cada unidade envolvida, o total de vínculos é maior que o número de questões únicas com unidade — a diferença é exatamente o número de questões multiunidade (8, após o ajuste do item 8).

Nenhuma das 618 questões pendentes (fora deste lote) foi tocada — a regra de não usar multiunidade "só porque cita genericamente Lei Maria da Penha" só foi aplicada às 87 revisadas manualmente.

## 5. Confirmação de exclusões (duplicatas e problemáticas)

Confirmado por filtro direto no CSV de 800: as 87 têm interseção **zero** com as 73 `NEAR_DUPLICATE_REVISAR`, as 10 `JA_EXISTE`, as 4 `DUPLICATA_PDF` e as 8 `PROBLEMATICA`. As 87 são um subconjunto puro das 705 `NOVA`.

## 6. Par 973/993 — conflito de gabarito

Confirmado: mesmo enunciado e mesmas alternativas (TEC 3559254 e TEC 3559251, conforme identificados pelo inventário original — sujeitos, como todo o resto do inventário de 800, ao mesmo risco de deslocamento do item 0, mas o *conflito em si* — dois blocos de texto idênticos com gabaritos diferentes — é uma observação sobre o conteúdo, não sobre a metadata, e permanece válida). Gabarito divergente (973 = A, 993 = C). Nenhum dos dois foi escolhido arbitrariamente — ambos ficam de fora do Lote 1 e de qualquer lote futuro até que o gabarito oficial seja confirmado na fonte do concurso.

## 7. Banco Geral / Missão Final — sem vínculo artificial

9 das 87 questões entram como `BANCO_GERAL_MISSAO_FINAL`, sem vínculo de unidade específica:

- 7 já vinham assim classificadas no inventário original: 470, 574, 908, 926, 941, 943, 976.
- 2 foram **movidas** para este grupo nesta auditoria (ver item 8): 441 e 956, que tinham confiança **baixa** e vínculo de unidade discutível — pela regra de "nunca forçar classificação de baixa confiança", o vínculo de unidade foi removido e a questão foi reclassificada como banco geral em vez de manter um vínculo artificial só para aumentar a cobertura de U1/U2/U4.

Nenhuma das 9 recebeu vínculo forçado com U1-U5. A questão 999, apesar de originalmente listada como U2, está **fora da contagem de cobertura** por estar excluída deste lote (item 0).

## 8. Ajuste de confiança baixa, exclusão de 999, e recomputação de cobertura U1-U5

Duas questões tinham `confianca = baixa` com vínculo de unidade e foram movidas para banco geral (ver item 7): **441** (U1+U2) e **956** (U4).

A questão **999** (U2, confiança alta, juridicamente ATUAL) foi excluída do lote por falta de metadados confirmáveis no PDF (item 0) — seu vínculo original com U2 não entra na contagem final deste lote.

**Cobertura U1-U5, recomputada usando somente NOVA + revisada manualmente + juridicamente ATUAL + sem vínculo forçado de baixa confiança + sem a questão 999 (excluída por integridade de dados):**

| Unidade | Baseline atual | + Novos vínculos (Lote 1, corrigido) | Total projetado | Mínimo 10 atingido? |
|---|---|---|---|---|
| U1 | 14 | +37 | 51 | ✅ sim |
| U2 | 6 | +19 | 25 | ✅ sim |
| U3 | 9 | +16 | 25 | ✅ sim |
| U4 | 2 | +9 | 11 | ✅ sim (margem apertada) |
| U5 | 0 | +4 | 4 | ❌ **não** — ainda abaixo de 10 |

**U5 continua sendo o gargalo do curso**: mesmo após este lote, apenas 4 questões ficam disponíveis (577, 606, 730, 284 — as duas últimas multiunidade), longe do mínimo de 10 por unidade. Isso não é um problema deste lote — é uma limitação do próprio universo de 800 questões extraídas dos PDFs (poucas tratam de juizados especializados/equipe multidisciplinar, art. 14-32). Recomendo tratar isso como um item de atenção separado antes de fechar a curadoria completa da Lei Maria da Penha.

## 9. Arquivos gerados/atualizados

- `supabase/lote_1_importacao_lei_maria_penha_tec.csv` — 87 linhas de dados, 15 colunas, **reescrito nesta rodada** com `tec_id`/`banca`/`concurso`/`ano` corrigidos a partir do PDF original (86 linhas corrigidas; a linha 999 mantém o metadado antigo apenas para registro, mas está marcada em `observacao` para **não ser importada** até checagem manual).
- Este arquivo (`.md`), com a seção 0 (auditoria de integridade) adicionada e a seção 3 (art. 24-A) corrigida.

## 10. Recomendação para além do Lote 1

O mesmo bug de deslocamento (item 0) provavelmente afeta as 618 questões `NOVA` pendentes e as 95 já classificadas como duplicata/já-existe/problemática no inventário completo de 800. Antes de processar qualquer lote futuro, recomendo repetir esta mesma auditoria (extração da cauda de cada bloco no PDF, comparação campo a campo) para o restante do inventário — não apenas confiar nos metadados já registrados.

**Nenhum SQL de INSERT foi criado. Nenhuma escrita foi feita no Supabase (nem leitura via MCP nesta rodada). Nada foi commitado nem enviado ao repositório remoto.**
