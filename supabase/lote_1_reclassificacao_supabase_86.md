# LOTE 1 — Revalidação contra o Supabase real (MCP restabelecido)

Esta rodada usou o MCP (read-only, `--read-only` no `.mcp.json`) para reconferir as 86 questões utilizáveis do Lote 1 (`lote_1_importacao_lei_maria_penha_tec.csv`) contra o estado **real e atual** do banco — nenhuma leitura anterior desta auditoria havia tocado o Supabase de fato. Nenhuma escrita foi feita (`INSERT`/`UPDATE`/`DELETE`/migration) e nada foi commitado.

## 1. Estado real do Supabase (revalidado)

- `curso_conteudos.id = 53` → `assunto_id = 19` ("Lei Maria da Penha", `materia_id = 10`).
- `questoes` ativas com `assunto_id = 19`: **28** (mesmo valor da rodada anterior — nada mudou no banco entre sessões).
- `unidades_pedagogicas` do conteúdo 53 e vínculos atuais em `questao_unidades_pedagogicas` (baseline, sem alteração desde o commit `d14b453`):

| Unidade | Título | Vínculos hoje |
|---|---|---|
| U1 | Fundamentos e campo de aplicação | 14 |
| U2 | Prevenção e assistência à mulher | 6 |
| U3 | Atendimento policial e providências imediatas | 9 |
| U4 | Procedimentos e medidas protetivas de urgência | 2 |
| U5 | Rede de justiça, equipe multidisciplinar e disposições finais | 0 |

Snapshot completo salvo em `supabase/banco_snapshot_lei_maria_penha_atual.json` (28 linhas: `id`, `fonte`, `enunciado`, `alternativas`).

## 2. Deduplicação determinística (Camadas A/B/C) — `scripts/dedupe-lote1-vs-supabase.js`

Rodado contra o snapshot real (não um mock). Saída automática bruta (antes da revisão manual do item 3):

| Status | Qtde |
|---|---|
| NOVA_CONFIRMADA | 83 |
| JA_EXISTE | 1 (caderno 950) |
| NEAR_DUPLICATE_REVISAR | 2 (cadernos 971, 981) |
| PROBLEMATICA | 0 |
| **Soma (86 utilizáveis)** | **86** |

(999 continua fora da contagem dos 86, tratado à parte — ver item 5.)

## 3. Revisão manual dos 3 casos sinalizados (nunca resolvido automaticamente)

### Caderno 950 (tec_id 3818504) — JA_EXISTE (Camada A) → **reclassificado para PROBLEMATICA**

Colisão de `tec_id`: o banco já tem `questoes.id = 671` com `fonte` citando exatamente `tec_id 3818504`. Só que o enunciado de 671 ("São condutas que deverão ser adotadas pela autoridade policial de imediato... EXCETO", art. 11) é **inteiramente diferente** do enunciado do caderno 950 ("diretrizes da política pública... à exceção de uma", art. 8º). Não é a mesma questão com o mesmo ID — é um `tec_id` colidindo em cima de duas questões de conteúdo totalmente distinto. Isso é sintoma residual do mesmo bug de deslocamento de metadados já documentado no item 0 do `lote_1_importacao_lei_maria_penha_tec.md`: mesmo depois da correção aplicada às 87 questões, a extração da cauda para o bloco 950 provavelmente capturou o `tec_id` de um bloco vizinho, não o seu próprio.

Consequência: **não pode virar `JA_EXISTE`** (perderia silenciosamente uma questão nova e válida) nem **`NOVA_CONFIRMADA`** (importaria com um `tec_id` não confiável, criando uma segunda colisão). Fica **`PROBLEMATICA`**, fora da importação, até checagem visual manual direta no PDF de origem (`Caderno Lei Maria da Penha - 800 ao 1000.pdf`, página 31).

### Caderno 971 (tec_id 3675819) — NEAR_DUPLICATE_REVISAR (Jaccard 0.36 vs. `questoes.id=51`) → **reclassificado para NOVA_CONFIRMADA**

Ambas tratam do art. 10-A (atendimento policial especializado), daí a similaridade lexical alta. Mas testam pontos diferentes: `id=51` é um bloco amplo pedindo a alternativa INCORRETA entre vários direitos (matrícula escolar, remoção, atendimento, vedação de afastar o agressor); o caderno 971 testa especificamente as diretrizes de inquirição do §1º do art. 10-A (degravação em mídia, retirada de pertences, inquirição intermediada por profissional). Conteúdo tratado como distinto — falso positivo do limiar de similaridade por vocabulário jurídico repetitivo do mesmo artigo. Confirmado **NOVA**.

### Caderno 981 (tec_id 3500155) — NEAR_DUPLICATE_REVISAR (Jaccard 0.36 vs. `questoes.id=133`) → **reclassificado para NOVA_CONFIRMADA**

Ambas usam o molde "prazo de ___ horas" com as mesmas alternativas numéricas (12/24/36/48h), mas testam atores/dispositivos diferentes: `id=133` é o prazo do **juiz** para decidir sobre a medida protetiva (art. 18, 48h); o caderno 981 é o prazo da **autoridade policial** para remeter o expediente ao juiz (art. 12, §1º, também 48h). Mesmo gabarito numérico por coincidência (os dois prazos legais são 48h), mas pontos de direito distintos. Confirmado **NOVA**.

## 4. Classificação final dos 86 (soma exata confirmada)

| Status | Qtde | Cadernos |
|---|---|---|
| **NOVA_CONFIRMADA** | **85** | todos os 86 exceto 950 |
| JA_EXISTE | 0 | — |
| NEAR_DUPLICATE_REVISAR | 0 | — |
| **PROBLEMATICA** | **1** | 950 (colisão de tec_id, checagem manual do PDF pendente) |
| **Soma** | **86** | ✓ |

Arquivo completo linha a linha: `supabase/lote_1_reclassificacao_supabase_86.csv` (87 linhas de dados: as 86 + o caderno 999, cada uma com `status_banco`, `motivo_banco`, `revisao_manual`, `importar_agora`). Versão JSON equivalente: `supabase/lote_1_classificacao_final_86.json`.

## 5. Achado crítico — questões sem vínculo de unidade NÃO entram na Missão Final (implementação real)

Conferido diretamente em `supabase/missao_pratica_papiro_rpc.sql`, função `iniciar_missao_final` (linhas 537-724): a montagem da Missão Final usa **exclusivamente** duas fontes de candidatas —

1. `selecionar_candidatas_unidade_pedagogica` (uma chamada por unidade, tentando dividir as 30 questões entre as unidades ativas/publicadas), e
2. `selecionar_candidatas_conteudo`, usada **apenas como preenchimento** se as unidades isoladas não bastarem para completar 30.

**Ambas** fazem `INNER JOIN` obrigatório com `public.questao_unidades_pedagogicas` (`qup.questao_id = q.id`) — não existe nenhum caminho no código que puxe candidatas direto de `curso_questoes` sem esse vínculo. Não há fallback para "banco geral sem unidade": uma questão sem linha em `questao_unidades_pedagogicas` é **invisível tanto para a prática de unidade quanto para a Missão Final** deste conteúdo, mesmo estando ativa em `questoes` e vinculada em `curso_questoes`.

**Isso contradiz a suposição da auditoria anterior** (item 7 do `.md` anterior), que tratava as 9 questões "BANCO_GERAL_MISSAO_FINAL" (470, 574, 908, 926, 941, 943, 976, 441, 956) como se fossem elegíveis à Missão Final por padrão. Na implementação real elas **não entram em nenhuma prática do modo Papiro para a Lei Maria da Penha** enquanto não receberem um vínculo explícito em `questao_unidades_pedagogicas` — ficam apenas cadastradas em `questoes`/`curso_questoes`, sem uso prático neste fluxo. Ficam disponíveis, sim, para o fluxo legado de conteúdo com uma única unidade (`iniciar_questoes_da_missao`), mas esse não é o caso da Lei Maria da Penha (5 unidades).

**Recomendação registrada, fora do escopo de execução desta rodada** (só leitura): antes de considerar essas 9 questões "prontas", decidir se (a) alguma delas na verdade cabe numa unidade específica após leitura completa (curadoria adicional, mesma regra de nunca vincular por citação genérica), ou (b) o algoritmo da Missão Final precisa de um terceiro tier que também aceite `curso_questoes` sem vínculo de unidade como preenchimento de último recurso.

## 6. Cobertura real U1-U5, recomputada só com questões válidas

Baseline atual (item 1) + vínculos das 85 `NOVA_CONFIRMADA` que têm campo `unidades` preenchido no CSV (76 questões; as outras 9 são banco geral, sem vínculo — ver item 5):

| Unidade | Baseline | + Lote 1 (revalidado, 85 NOVA) | Total projetado | Mínimo 10? |
|---|---|---|---|---|
| U1 | 14 | +37 | 51 | ✅ |
| U2 | 6 | +18 | 24 | ✅ |
| U3 | 9 | +16 | 25 | ✅ |
| U4 | 2 | +9 | 11 | ✅ (margem apertada) |
| U5 | 0 | +4 | 4 | ❌ ainda abaixo de 10 |

Diferença vs. a projeção da rodada anterior: **U2 caiu de +19/25 para +18/24** — o caderno 950 (U2) saiu da contagem por ter sido reclassificado de `NOVA_CONFIRMADA` para `PROBLEMATICA` nesta revalidação (item 3). As demais unidades não mudaram porque nenhuma das duas reclassificações de NEAR_DUPLICATE→NOVA (971, 981) trocou de unidade — ambas já eram U3 e permanecem U3.

**U5 continua o gargalo real do banco**: mesmo após este lote, só 4 questões (577, 606, 730, 284 — as duas últimas multiunidade) cobrem juizados especializados/equipe multidisciplinar. Não é um problema deste lote — é limitação do universo de 800 PDFs já extraído.

8 questões seguem multiunidade (284, 378, 534, 619, 728, 730, 970, 984) — nenhuma delas é 950, 971 ou 981, então a lista e o motivo de cada uma (já documentados no `.md` anterior, item 4) continuam válidos sem alteração.

## 7. Arquivo final de pré-importação

`supabase/lote_1_reclassificacao_supabase_86.csv` é o arquivo validado desta rodada — mesmas 15 colunas do Lote 1 original, mais `status_banco`, `motivo_banco`, `revisao_manual`, `importar_agora`. Uso recomendado no próximo passo (fora do escopo desta rodada, que é só leitura):

- **`importar_agora = sim`** (85 linhas, todas `NOVA_CONFIRMADA`): candidatas a `INSERT` em `questoes`/`alternativas`; das 85, 76 já têm `unidades` preenchido e podem receber vínculo direto em `questao_unidades_pedagogicas` na mesma operação; as outras 9 entram só em `questoes`/`curso_questoes` (banco geral) e, pelo achado do item 5, **não aparecerão em nenhuma prática do modo Papiro** até receberem vínculo de unidade ou até o algoritmo da Missão Final mudar.
- **`importar_agora = nao`** (2 linhas): caderno 950 (`PROBLEMATICA`, colisão de tec_id) e caderno 999 (excluído desde a rodada anterior, sem metadados confirmáveis no PDF) — ambas seguem fora de qualquer importação até checagem manual do PDF original.

## 8. Nada foi escrito no banco

Toda esta rodada rodou com o servidor MCP em modo `--read-only` (`.mcp.json`). Nenhum `INSERT`/`UPDATE`/`DELETE` foi executado, nenhuma migration foi aplicada, e nada foi commitado ou enviado ao repositório remoto — os arquivos gerados (`lote_1_reclassificacao_supabase_86.csv/.md`, `lote_1_classificacao_final_86.json`, `banco_snapshot_lei_maria_penha_atual.json`) estão apenas no working tree local.
