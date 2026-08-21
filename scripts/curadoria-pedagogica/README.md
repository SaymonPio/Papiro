# Pipeline de Curadoria Pedagógica — v1.3

Automatiza a parte **mecânica** das curadorias pedagógicas do Papiro (o mesmo processo já concluído manualmente para Lei Maria da Penha, Direitos e Garantias Fundamentais, Improbidade Administrativa e Lei de Drogas). Regras de origem: `docs/REGRAS_CURADORIA_PAPIRO.md`.

## O que este pipeline automatiza e o que ele NÃO automatiza

Automatiza: consulta ao banco, geração dos 4 arquivos `.sql` no formato já usado, cálculo de totais/contagens, validação de consistência entre arquivos.

**Não automatiza a decisão pedagógica em si.** Definir título/escopo/artigos_esperados de cada unidade e classificar cada questão (ler enunciado + todas as alternativas, decidir tema, multiunidade, confiança) continua exigindo julgamento humano — ver `docs/REGRAS_CURADORIA_PAPIRO.md`, seções 2, 3 e 4. Esse julgamento é registrado em dois arquivos de configuração (`config/<slug>.unidades.json` e `config/<slug>.mapa.json`) que o pipeline **lê como entrada já aprovada**, nunca gera sozinho.

**Não gera o apply real automaticamente.** `classificar_questoes_unidades_<slug>.sql` (a versão que termina em `COMMIT`) não é produzida por nenhum script gerador deste diretório — precisa ser escrito/revisado à parte, e sua **execução** (assim como a do teste rollback e do pós-check) passou a ser feita pelo executor local (`executar-sql.mjs`, v1.3), nunca mais copiando para o SQL Editor do Supabase Studio.

## Credenciais (`.env.curadoria`)

Copie `env.curadoria.example` para `.env.curadoria` (mesmo diretório) e preencha os valores reais. **`.env.curadoria` nunca deve ser versionado** — já é coberto pela regra `.env*` do `.gitignore` raiz do projeto (confirmado com `git check-ignore -v scripts/curadoria-pedagogica/.env.curadoria`). Se uma variável não estiver disponível (nem no arquivo, nem já exportada na sessão), o script correspondente falha com uma mensagem explícita dizendo exatamente o que falta — nunca com um erro genérico.

Duas credenciais diferentes, para dois canais diferentes:

| Variável | Usada por | Canal |
|---|---|---|
| `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` | `auditar-conteudo.mjs`, `auditar-geral.mjs`, `gerar-pos-check.mjs` | API REST (`@supabase/supabase-js`) — só `SELECT`, nunca escreve |
| `SUPABASE_DB_URL` (ou `DATABASE_URL`) | `executar-sql.mjs` | Conexão Postgres direta (`pg`/node-postgres) — a única forma de rodar `CREATE TEMPORARY TABLE`/`DO $$...$$`/`ROLLBACK`, que a API REST não suporta |

## Executor SQL local (`executar-sql.mjs`, novo na v1.3)

Antes da v1.3, teste rollback, apply real e pós-check exigiam copiar o arquivo `.sql` para o SQL Editor do Supabase Studio e rodar manualmente. Isso não é mais necessário — `executar-sql.mjs` roda qualquer arquivo de `supabase/` diretamente contra o banco real, via conexão Postgres direta (biblioteca `pg`, adicionada como dependência do projeto).

```bash
node scripts/curadoria-pedagogica/executar-sql.mjs supabase/classificar_questoes_unidades_<slug>_teste_rollback.sql
node scripts/curadoria-pedagogica/executar-sql.mjs supabase/classificar_questoes_unidades_<slug>.sql --apply
node scripts/curadoria-pedagogica/executar-sql.mjs supabase/pos_check_classificacao_unidades_<slug>.sql
node scripts/curadoria-pedagogica/executar-sql.mjs <qualquer-arquivo> --dry-run
```

### Classificação automática (nunca só pelo nome do arquivo)

O executor lê o **conteúdo** do arquivo e confere qual é a última instrução real, além do nome:

| Tipo detectado | Critério | Precisa de `--apply`? |
|---|---|---|
| `teste_rollback` | nome termina em `_teste_rollback.sql` **e** a última instrução é `rollback;` | Não |
| `pos_check` | nome começa com `pos_check_` **e** o arquivo não contém nenhuma palavra de escrita (`insert`/`update`/`delete`/`create`/`drop`/`alter`/`truncate`/`grant`/`revoke`) | Não |
| `apply` | qualquer outro arquivo cuja última instrução seja `commit;` | **Sim** |
| `teste_rollback_suspeito` / `pos_check_suspeito` / `desconhecido` | o nome sugere uma coisa, mas o conteúdo real diverge (ex.: um arquivo chamado `..._teste_rollback.sql` que na verdade termina em `commit;`) | **Sim** (tratado como escrita até prova em contrário) |

Isso significa que renomear um arquivo não basta para burlar a trava — quem decide é o conteúdo real.

### Regras de segurança implementadas

- O arquivo **precisa estar dentro de `supabase/`** — caminho fora disso é bloqueado antes de qualquer leitura de credencial.
- `.agents/`, `.claude/` e `.mcp.json` são bloqueados explicitamente por segmento de caminho, além de já estarem estruturalmente fora de `supabase/`.
- A connection string **nunca é impressa** — só um resumo não sensível (`host`, `porta`, `banco`, se há usuário/senha configurados, nunca os valores).
- Teste rollback roda automaticamente (sem `--apply`) só quando o conteúdo real termina em `ROLLBACK`.
- Qualquer coisa que termine em `COMMIT` (apply real, curadoria) **exige `--apply` explícito** — sem a flag, o executor bloqueia e explica o motivo, sem rodar nada.
- Pós-check é reconhecido como somente leitura pelo nome + ausência de palavras de escrita no conteúdo.
- Exit codes: `0` sucesso completo; `1` erro de SQL ou bloqueio de segurança; `2` — só possível numa execução real de teste rollback — o SQL rodou sem erro, mas o próprio relatório interno (`RAISE NOTICE 'tudo_ok = false'`) indicou divergência.
- Mensagens `RAISE NOTICE` (onde o relatório dos harnesses de teste rollback aparece) e o resultado de `SELECT`s (pós-check) são capturados e impressos.
- O executor nunca faz `git add`/`commit`/`push` — isso continua sendo uma etapa manual separada e aprovada.

### Modo `--dry-run`

Valida, sem abrir nenhuma conexão de rede e sem executar nenhum SQL: se o arquivo existe e está no lugar certo, qual o tipo de operação detectado, e se a credencial (`SUPABASE_DB_URL`/`DATABASE_URL`) está configurada — sempre rode `--dry-run` primeiro ao testar um arquivo novo.

## Fluxo

```
node executar-pipeline.mjs <curso_conteudo_id>
        ↓ (só leitura no Supabase)
relatorios/relatorio_auditoria_<slug>.json
        ↓ (LEITURA HUMANA OBRIGATÓRIA do enunciado + alternativas de cada questão)
config/<slug>.unidades.json   +   config/<slug>.mapa.json   (escritos por humano)
        ↓
node executar-pipeline.mjs --continuar <slug>
        ↓ (gerar-curadoria → gerar-mapa → gerar-rollback → gerar-pos-check → validar-pipeline)
supabase/curadoria_unidades_<slug>.sql
supabase/mapa_classificacao_<slug>.sql
supabase/classificar_questoes_unidades_<slug>_teste_rollback.sql
supabase/pos_check_classificacao_unidades_<slug>.sql
        ↓ (APROVAÇÃO HUMANA)
rodar teste rollback manualmente no Supabase Studio → tudo_ok = true?
        ↓ (APROVAÇÃO HUMANA)
escrever/revisar classificar_questoes_unidades_<slug>.sql (apply real, fora deste pipeline)
        ↓ (APROVAÇÃO HUMANA)
aplicar de fato → rodar pos-check → commit/push (sempre etapas separadas)
```

## Formato de `config/<slug>.unidades.json`

```json
{
  "curso_conteudo_id": 66,
  "nome_assunto": "Lei de Drogas",
  "materia_id": 10,
  "curso_id": "7543be16-4c5b-4cb6-8724-8fbdfb96f2d4",
  "unidades": [
    { "id": "uuid-explicito", "ordem": 1, "titulo": "...", "escopo": "...", "artigos_esperados": ["art. 28"] }
  ]
}
```

A unidade `ordem: 1` é obrigatória e precisa ter o `id` real já existente no banco (a unidade padrão criada pelo bootstrap genérico). Unidades adicionais (`ordem: 2, 3, ...`) recebem UUID **explícito** escolhido pelo humano (nunca `gen_random_uuid()`), para que o mapa possa referenciá-las antes de qualquer aplicação real.

## Formato de `config/<slug>.mapa.json`

```json
{
  "assunto_id": 78,
  "total_candidatas_ativas": 16,
  "questoes_excluidas": [{ "questao_id": 674, "motivo": "..." }],
  "vinculos": [
    { "questao_id": 143, "unidade_id": "uuid-da-unidade", "ordem_unidade": 1, "tema": "...", "justificativa": "...", "confianca": "alta" }
  ]
}
```

Uma questão multiunidade aparece com duas entradas em `vinculos` (uma por unidade). `questoes_excluidas` documenta questões fora de escopo (padrão da questão 674 da Lei de Drogas) — nunca aparecem em `vinculos`.

Os dois arquivos `config/lei_drogas.*.json` já existem neste diretório como **fixture real** (dados idênticos à curadoria já aplicada e commitada) — servem de exemplo e de teste de regressão do próprio pipeline (ver seção "Modo de simulação" abaixo).

## Scripts

| Script | Faz | Toca o Supabase? |
|---|---|---|
| `auditar-conteudo.mjs <id>` | Levanta conteúdo/matéria/assunto/unidades/aulas/questões/classificações | Sim, só `SELECT` |
| `gerar-curadoria.mjs <slug>` | Gera `curadoria_unidades_<slug>.sql` a partir de `config/<slug>.unidades.json` | Não |
| `gerar-mapa.mjs <slug>` | Gera `mapa_classificacao_<slug>.sql` a partir de `config/<slug>.mapa.json` | Não |
| `gerar-rollback.mjs <slug>` | Gera `classificar_questoes_unidades_<slug>_teste_rollback.sql` | Não |
| `gerar-pos-check.mjs <slug>` | Gera `pos_check_classificacao_unidades_<slug>.sql`, consultando ao vivo os 4 totais de sistema da consulta 7 (desde a v1.1 — antes eram flags manuais) | Sim, só `SELECT` |
| `validar-pipeline.mjs <slug>` | Confere nomes/quantidade/consistência dos arquivos gerados | Não |
| `executar-pipeline.mjs` | Orquestra os anteriores (3 modos: auditoria, `--continuar`, `--fixture`) | Só nos modos que chamam `auditar-conteudo.mjs`/`gerar-pos-check.mjs` |
| `auditar-geral.mjs` | Audita toda a fila (`config/ordem-curadoria.json`) de uma vez, gera `relatorios/relatorio_curadoria_geral.json` | Sim, só `SELECT`, em lote |
| `status-curadoria.mjs` | Imprime o progresso da fila no terminal (✅/⬜) | Não |

Nenhum script faz `git add`/`commit`/`push`, nenhum executa migration.

## Modo de simulação (`--fixture`, novo na v1.1)

```bash
node executar-pipeline.mjs --fixture lei_drogas
```

Roda `gerar-curadoria.mjs` + `gerar-mapa.mjs` + `gerar-rollback.mjs` (nunca `gerar-pos-check.mjs`, que tocaria o Supabase) escrevendo num diretório temporário do sistema operacional (nunca em `supabase/` real — isolamento via a variável de ambiente `CURADORIA_SAIDA_DIR`, lida por `lib/comum.mjs`). Depois compara um conjunto de fatos extraídos (UUIDs, nomes das checagens de `_relatorio`, ids de questão do mapa) contra o arquivo real já commitado para o mesmo slug, e reporta `OK` ou `DIVERGENCIA` por categoria — nunca corrige nada sozinho.

Uma divergência de nomes de checagem **não é necessariamente um bug**: o gerador usa uma convenção de nomes generalizada para N unidades (ex.: `unidades_oficiais_existem`, `mapa_nao_contem_excluidas`), enquanto alguns arquivos reais mais antigos, escritos à mão especificamente para 1 unidade, usaram nomes ligeiramente diferentes (ex.: `unidade_oficial_existe`, `mapa_nao_contem_674`) ou não tinham uma checagem que o gerador agora inclui por padrão (`u1_<N>_questoes`, adicionada em todos os casos depois da lição aprendida na auditoria de Improbidade Administrativa). Interprete a saída lendo o que exatamente mudou, não só o veredito.

## A fila de curadoria (novo na v1.2)

`config/ordem-curadoria.json` é a lista dos 93 conteúdos relevantes de Brigada Militar RS, na ordem em que a curadoria pedagógica deveria ser feita. Cada item:

```json
{
  "ordem": 5,
  "curso_conteudo_id": 50,
  "nome": "Constituição do Estado do Rio Grande do Sul",
  "materia": "Legislação Específica",
  "questoes_ativas": 14,
  "prioridade": "alta",
  "status": "pendente",
  "motivo_prioridade": "norma constitucional de alta relevancia para concursos policiais"
}
```

- `status` só aceita `"concluido"` ou `"pendente"` (ver `STATUS_VALIDOS_ORDEM_CURADORIA` em `lib/comum.mjs`).
- `prioridade` (`"alta"`/`"media"`/`"baixa"`) foi calculada por matéria + quantidade de questões ativas, seguindo os mesmos critérios do levantamento completo já feito (peso da matéria, massa de questões, importância para concurso policial) — não é um campo livre para preencher à mão sem critério.
- `motivo_prioridade` (desde a v1.2, ajuste pontual) é a justificativa curta e legível de por que aquele item recebeu aquela `prioridade` — não recalcula nem substitui `prioridade`, só documenta em texto o raciocínio já usado (ex.: `"norma constitucional de alta relevancia para concursos policiais"`, `"lei especial de grande volume de questoes e alta incidencia em concursos policiais"`, `"conteudo tecnico de menor peso"`). Itens já `"concluido"` têm um motivo específico registrando por que aquele conteúdo foi um dos 4 primeiros feitos manualmente, antes deste pipeline existir.
- `ordem` e `curso_conteudo_id` precisam ser únicos em toda a lista (ver Tarefa 5 / validações abaixo).

### Como atualizar o status de um conteúdo

Não existe script de escrita para isso de propósito — é edição manual do JSON (o arquivo é pequeno e legível, e mudar o status de "pendente" para "concluido" é uma decisão humana, não um cálculo). Depois de terminar uma curadoria (mesmo fluxo de sempre: `executar-pipeline.mjs <id>` → `config/<slug>.*.json` → `--continuar <slug>` → teste rollback → apply real → pós-check → commit), edite o item correspondente em `config/ordem-curadoria.json` trocando `"status": "pendente"` para `"status": "concluido"`. Rode `node status-curadoria.mjs` depois para conferir que o progresso mudou.

### Como executar a auditoria geral

```bash
node auditar-geral.mjs
```

Lê `config/ordem-curadoria.json`, valida a fila localmente (Tarefa 5), depois consulta o Supabase **em lote** (nunca 1 consulta por conteúdo) para: existência real de cada `curso_conteudo_id` (erro se algum não existir), quantidade de questões ativas, quantidade de `unidades_pedagogicas` e quantidade de questões já classificadas em `questao_unidades_pedagogicas` — de cada um dos 93. Escreve `relatorios/relatorio_curadoria_geral.json`. Precisa de `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (ver `.env.curadoria` acima).

### Como interpretar `relatorio_curadoria_geral.json`

```json
{
  "curso": "Brigada Militar RS",
  "gerado_em": "2026-...",
  "total_conteudos": 93,
  "concluidos": 4,
  "pendentes": 89,
  "percentual_conclusao": 4.3,
  "conteudos": [
    { "curso_conteudo_id": 53, "nome": "Lei Maria da Penha", "materia": "Legislação Específica",
      "status": "concluido", "prioridade": "alta",
      "questoes_ativas": 295, "unidades_pedagogicas": 5, "questoes_classificadas": 104 }
  ]
}
```

`questoes_ativas`/`unidades_pedagogicas`/`questoes_classificadas` são o estado **real, ao vivo** do banco no momento da geração — podem divergir do `questoes_ativas` estático em `ordem-curadoria.json` (que é uma foto de quando a fila foi criada) se o banco de questões mudar depois. `questoes_classificadas < questoes_ativas` é esperado e normal mesmo em conteúdos concluídos (ex.: Lei Maria da Penha, 104/295 — gap conhecido e documentado em `docs/REGRAS_CURADORIA_PAPIRO.md`).

### Como ver o progresso rapidamente

```bash
node status-curadoria.mjs
```

100% local (não toca o Supabase, ao contrário de `auditar-geral.mjs`) — lê só `config/ordem-curadoria.json` e imprime `✅`/`⬜` por conteúdo na ordem da fila, mais o total e o percentual.

### Validações da fila (Tarefa 5)

`lib/comum.mjs#validarOrdemCuradoria` (chamada por `auditar-geral.mjs` e `status-curadoria.mjs` antes de qualquer outra coisa) gera erro e interrompe a execução se:
- houver `curso_conteudo_id` duplicado;
- houver `ordem` duplicada;
- houver `status` fora de `"concluido"`/`"pendente"`.

A quarta validação — **conteúdo inexistente** — exige consultar o banco, então só é feita dentro de `auditar-geral.mjs` (não em `status-curadoria.mjs`, que é local): se algum `curso_conteudo_id` da fila não existir em `public.curso_conteudos`, a auditoria geral para com erro em vez de ignorar silenciosamente.
