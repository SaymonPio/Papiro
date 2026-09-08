# Esteira Autoral (Fase 2A — núcleo local · Fase 2A.1 — hardening pré-OpenAI)

Núcleo determinístico, multi-curso e orientado a arquivos da futura esteira
de questões autorais por API do Papiro. **Nesta fase: zero chamada a
qualquer API de IA, zero escrita no banco.** Tudo aqui é `SELECT` no
Supabase (via o cliente de leitura já existente em
`scripts/curadoria-pedagogica/lib/comum.mjs`) + leitura/escrita de arquivos
locais em `outputs/curadoria-autoral/` (ignorado pelo git).

## Objetivo desta fase

Construir e testar, sem depender de nenhum provedor de IA, tudo que a
esteira vai precisar antes de gerar a primeira questão de verdade:
diagnóstico de cobertura multi-curso, resolução de banca, cálculo de
elegibilidade/prioridade, montagem do payload que um dia será enviado a um
modelo, e validação estrutural determinística do que esse modelo devolver.

## Por que zero write

A API de IA nunca poderá inserir questão diretamente no banco (decisão de
produto, Fase 1). Esta fase prova a hipótese central da esteira —
diagnóstico, elegibilidade e payload — sem sequer precisar da chave da
OpenAI existir em lugar nenhum. A Fase 2B (Edge Function + chamada real)
só faz sentido depois que este núcleo estiver testado e revisado.

## Comandos

```bash
# Diagnosticar cobertura de todos os cursos
node scripts/curadoria-autoral/cli/diagnosticar-cobertura.mjs --all-courses

# Diagnosticar só um curso
node scripts/curadoria-autoral/cli/diagnosticar-cobertura.mjs --curso-slug brigada-militar-rs

# Preparar (sem enviar a lugar nenhum) o payload de UMA unidade
node scripts/curadoria-autoral/cli/preparar-payload.mjs \
  --curso-slug brigada-militar-rs --unidade-id <uuid> --quantidade 3

# Validar um lote de questões candidatas (SEMPRE fixture nesta fase — nenhuma
# geração real existe ainda)
node scripts/curadoria-autoral/cli/validar-questoes.mjs --input caminho/para/candidatas.json

# Rodar os testes (não tocam o Supabase)
node --test tests/curadoria-autoral-*.test.mjs
```

Pré-requisito: `scripts/curadoria-pedagogica/.env.curadoria` preenchido
(mesmo arquivo já usado pelo pipeline de curadoria manual — nunca
versionado). Dois canais de leitura são suportados, com detecção
automática (`carregarDadosBrutosAutoDetectado`, em `context-resolver.mjs`):
`SUPABASE_URL`+`SUPABASE_SERVICE_ROLE_KEY` (canal **`REST`**, preferido/
documentado pela Fase 1, read-only por construção via PostgREST) ou, se
esses não estiverem configurados, `SUPABASE_DB_URL` (canal **`PG_READ_ONLY`**,
Postgres direto via `pg`, o mesmo canal que `executar-sql.mjs` usa — foi o
único configurado neste ambiente ao rodar o smoke test da Fase 2A, e por
isso este segundo canal existe). O CLI sempre imprime qual canal foi usado
— rótulos exatos `REST`/`PG_READ_ONLY`, nunca em minúsculas.

**Segurança do canal `PG_READ_ONLY` (Fase 2A.1, Risco 2):** até a Fase 2A
este canal só era read-only "por convenção" (o código só continha
`SELECT`, nada impedia tecnicamente uma escrita). Agora
`carregarDadosBrutosViaPg` trava a própria sessão Postgres antes de rodar
qualquer `SELECT` de dados: `SET default_transaction_read_only = on`,
seguido de uma verificação real via `SHOW transaction_read_only` — se a
verificação não confirmar `'on'`, a função lança um erro
`PG_SESSION_NOT_READ_ONLY` e ABORTA sem executar nenhuma query de dados.
O CLI imprime `transaction_read_only: on` quando esse canal é usado. As
colunas/tabelas de cada `SELECT` vêm sempre de `TABELAS_PARA_PG`, um array
interno fixo — nenhum argumento de CLI (`--curso-id`, `--unidade-id`,
`--target-bank-size` etc.) é concatenado em SQL; esses valores são usados
só como chave de busca em arrays já carregados em memória
(`resolverCurso`, `resolverUnidadeNoCurso`).

## Definições canônicas

**Questão útil** (Fase 1, confirmada contra o corpo real de
`selecionar_candidatas_unidade_pedagogica`): `questoes.ativa=true` + vínculo
em `questao_unidades_pedagogicas` para a unidade + `unidades_pedagogicas.
ativa=true` + `curso_conteudos.relevante_para_preparacao=true` +
`curso_materias.relevante_para_preparacao=true` + linha em `curso_questoes`
para o curso. Contada por `COUNT DISTINCT questao_id`.

**Questão selecionável operacionalmente**: tudo acima + a unidade ter
`aulas.ativa=true` com pelo menos uma `aula_versoes.status='publicada'`.
Gates de progresso individual do aluno (missão/matrícula) são runtime, não
propriedade fixa da unidade — não entram no diagnóstico geral.

**Os dois "10"** (correção conceitual da Fase 1, Seção 7): `10` em
`iniciar_pratica_unidade` é o tamanho de uma sessão de prática montada (com
repetição se o banco da unidade for menor que isso). `10` como meta de
banco por unidade é uma convenção de curadoria — não uma constraint de
produto. Por isso `target_bank_size` é sempre parametrizável
(`--target-bank-size`), com `target_origin: "curadoria"` registrado no
manifesto, nunca `minimum_product_constraint`.

## Resolução de banca

Não existe tabela `bancas` nem `banca_id` hoje. A fonte primária é
`cursos.banca` (texto livre); `editais.banca` é secundária. Nunca um
substitui o outro silenciosamente. Estados possíveis: `RESOLVED`,
`REVIEW_CONFLICT` (os dois existem e divergem), `REVIEW_FALLBACK` (só o
edital tem banca), `BLOCKED_NO_BANK` (nenhum tem). Override manual
(`--banca`) sempre registra `origem_da_resolucao: "MANUAL_OVERRIDE"`.

## Contexto pedagógico x validação de fonte (Fase 2A.1 — separação obrigatória)

A Fase 2A original tinha um único `STATUS_FONTE`, inferido de
`unidades_pedagogicas.escopo`/`artigos_esperados`. Isso era um bug
semântico: escopo/artigos_esperados são **metadado pedagógico** ("sabemos
o que ensinar?"), nunca prova de que a informação factual/normativa foi
**documentalmente validada por um humano**. Uma unidade com 15
`artigos_esperados` bem escritos podia virar `SOURCE_VALIDATED` mesmo que
ninguém nunca tivesse confirmado o texto legal real (caso descoberto nesta
sessão: a lei citada por uma unidade estava revogada, e só um artigo da
lei sucessora havia sido confirmado).

Agora existem duas avaliações independentes:

- **`avaliarContextoPedagogico`** (`lib/eligibility.mjs`) → um de
  `PEDAGOGICAL_CONTEXT_COMPLETE` / `_PARTIAL` / `_INSUFFICIENT`. Olha só
  escopo, `artigos_esperados`, `teoria_escopos_conteudo` e existência de
  material anexado.
- **`avaliarValidacaoFonte`** (`lib/source-manifest.mjs`) → um de
  `SOURCE_VALIDATED` / `SOURCE_PARTIAL` / `SOURCE_REQUIRES_HUMAN_VALIDATION`
  / `SOURCE_MISSING`. Olha **só** o manifesto local de fontes (próxima
  seção) — nunca escopo/artigos_esperados.

`materiaPareceNormativa(escopo)` (heurística por texto — "art.", "lei n.",
"decreto", "constituição", "súmula" — nunca `materia_id` hardcoded) decide
se a falta de fonte validada deve **bloquear** (`BLOCKED` com motivo
`LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDADA`, para conteúdo normativo/jurídico)
(`LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED`) ou apenas **avisar** (warning,
para Português/RLM/Informática etc.).

## Manifesto local de fontes (`sources/*.json`)

Único lugar que pode produzir `SOURCE_VALIDATED`. Cada arquivo é um
registro JSON versionado no git (schema em `lib/schemas.mjs`:
`CHAVES_FONTE_MANIFESTO`/`SOURCE_MANIFEST_SCHEMA_VERSION`):
`schema_version`, `source_key`, `type` (`official_law`/`official_document`/
`lesson_material`/`technical_documentation`/`pedagogical_reference`/
`other`), `title`, `reference`, `content`, `content_hash`,
`applies_to_unit_ids` (quais unidades este registro valida),
`covers_articles` (opcional — permite `SOURCE_PARTIAL` quando a fonte
validada não cobre todos os `artigos_esperados`), `validated` (**boolean
explícito, NUNCA inferido** — só um humano escrevendo `true` de propósito
promove um registro), `validated_by`, `validated_at`, `notes`.

Hoje o diretório tem 2 registros, ambos **rascunho (`validated: false`)**,
refletindo pesquisa via WebSearch desta sessão (convergente, mas nunca
leitura byte-a-byte do texto oficial primário) — para a unidade "Lei de
Organização Básica da Brigada Militar" (LC 16.450/2025, art. 10) e para a
unidade "Estatuto dos Militares Estaduais" (LC 10.990/1997, distinção
art.14/art.15). Nenhum dos dois é promovível a `SOURCE_VALIDATED`
automaticamente — exige edição humana deliberada do arquivo.

## Elegibilidade

Uma unidade só é `ELIGIBLE_FOR_GENERATION` quando: está ativa, tem
`faltantes > 0`, o contexto pedagógico não é `PEDAGOGICAL_CONTEXT_INSUFFICIENT`,
a banca está `RESOLVED`, (se uma quantidade foi pedida) ela cabe dentro do
déficit, e — só quando `materiaPareceNormativa` é verdadeiro — a fonte está
`SOURCE_VALIDATED`. **Aula publicada NUNCA bloqueia geração** — só gera o
warning `LESSON_NOT_PUBLISHED`.

## Artefatos

Cada execução cria `outputs/curadoria-autoral/<run_id>/` (ignorado pelo
git — confirmado via `git check-ignore`; `relatorios/` na raiz do projeto
**não** está ignorado, por isso não foi usado). Nesta fase, só
`manifest.json`, `cobertura.json`, `cobertura.md` e `payloads/*.json` são
gerados de verdade — `questoes_geradas.json`/`aprovadas.json`/
`revisar.json`/`rejeitadas.json`/`relatorio_auditoria.md` são formato
documentado (Fase 1) mas só passam a existir a partir da Fase 2B, quando
houver geração real para classificar.

## Política de segurança

Nenhuma chamada de rede a `api.openai.com` (ou qualquer outro provedor)
acontece em nenhum arquivo deste diretório. Nenhuma variável de ambiente
de IA é lida, exibida ou logada. `tests/curadoria-autoral-payload.test.mjs`
varre o payload serializado por uma lista de chaves proibidas
(`usuario_id`, `email`, `respostas_usuarios`, `matricula`, etc.) para
garantir isso automaticamente.

## Como ativar a Fase 2B (não implementada ainda)

1. Migration nova `supabase/questao_geracoes.sql`, clonando quase
   literalmente `supabase/aula_geracoes.sql` (mesmo `status` check
   `processando|concluida|erro`, mesmo índice único parcial por
   `unidade_pedagogica_id` `WHERE status='processando'`).
2. Nova Edge Function `supabase/functions/gerar-questoes/`, clone
   estrutural de `supabase/functions/gerar-aula/index.ts`: mesmo padrão de
   segurança (chave só em `Deno.env`, admin-check com client do próprio
   usuário, `service_role` só depois), mesma única tentativa de correção
   quando o validador reprova.
3. `validador-questoes.mjs`/`audit-classifier.mjs` já existem e podem ser
   importados diretamente pela Edge Function (mesmo princípio de
   `supabase/functions/gerar-aula/validador.mjs`: puro, sem I/O,
   importável tanto por Deno quanto pelos testes Node).
4. `escopo.mjs` de `gerar-aula` é reaproveitável sem alteração para a
   auditoria de artigos abordados x esperados.
5. Só depois disso, decidir entre o padrão de esteira SQL (usado a sessão
   inteira de curadoria manual) ou a tela `app/admin/importar-questoes/`
   já existente (CSV + `importar_questoes_dry_run` + `importar_questoes_
   lote`) para a importação final — ambos exigem aprovação humana antes de
   qualquer escrita.

## Estrutura

```
scripts/curadoria-autoral/
  lib/
    coverage-scanner.mjs     — cálculo puro de útil/selecionável/déficit
    context-resolver.mjs     — único ponto de leitura no Supabase (REST/PG_READ_ONLY)
    banca-resolver.mjs       — resolução de banca sem migration
    eligibility.mjs          — contexto pedagógico, elegibilidade, prioridade (puro)
    source-manifest.mjs      — leitor/avaliador do manifesto local de fontes (puro)
    payload-builder.mjs      — monta o payload canônico (puro)
    schemas.mjs              — constantes/formas de referência
    validador-questoes.mjs   — hard gates estruturais (puro)
    audit-contract.mjs       — forma do resultado de auditoria futura
    audit-classifier.mjs     — REJEITADA/REVISAR/STRUCTURALLY_VALID (puro)
    duplicate-utils.mjs      — normalização/hash/Jaccard (puro)
    artifact-writer.mjs      — escrita segura de arquivos (write-temp+rename)
    run-manifest.mjs         — manifesto do run (só módulo que chama `git`)
  sources/
    *.json                   — manifesto local de fontes, versionado (nunca outputs/)
  cli/
    diagnosticar-cobertura.mjs
    preparar-payload.mjs
    validar-questoes.mjs
```
