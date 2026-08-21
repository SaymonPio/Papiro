# Regras de Curadoria Pedagógica — Papiro

Este documento registra as regras já **aprovadas e aplicadas na prática** durante as curadorias reais concluídas (Lei Maria da Penha, Direitos e Garantias Fundamentais, Improbidade Administrativa, Lei de Drogas). Nenhuma regra aqui foi inventada nesta análise — cada uma é extraída de uma decisão explícita do usuário ou de um comportamento já implementado no schema/RPCs. Pontos sem uma regra explícita definida estão marcados como **DECISÃO NECESSÁRIA**.

Este documento é só registro. Nenhum código, migration ou dado foi alterado ao criá-lo.

---

## 1. Fluxo pedagógico oficial

```
Conteúdo do edital (curso_conteudos)
        ↓
Unidades pedagógicas (unidades_pedagogicas)
        ↓
Aula interativa da unidade (aulas → aula_versoes, gerada por gerar-aula, publicada por publicar_aula_versao_admin)
        ↓
10 questões da unidade (iniciar_pratica_unidade, via selecionar_candidatas_unidade_pedagogica)
        ↓
Missão Final com 30 questões (iniciar_missao_final, só libera com todas as unidades com teoria E prática concluídas)
```

`curso_conteudos` é a identidade programática (ligada ao edital); `unidades_pedagogicas` é só um recorte didático desse conteúdo — pode ser 1 (a maioria dos 93 conteúdos de Brigada Militar RS hoje) ou várias (Lei Maria da Penha: 5; Direitos e Garantias Fundamentais e Improbidade Administrativa: 2 cada).

---

## 2. Quando criar uma unidade nova (dividir em 2+)

Regra aplicada em todas as divisões reais até aqui: dividir quando **três condições coincidem**:

1. **Coerência pedagógica real** — existe um corte temático que já aparece nas próprias questões do banco (não um corte teórico imposto de fora). Exemplo: em Improbidade Administrativa, o banco já se dividia naturalmente entre "tipificação dos atos" (arts. 9º/10/11) e "sujeitos, sanções e processo" (arts. 1º-3º/8º-A/12/17/23) — a divisão só formalizou o que já existia nas questões.
2. **Massa suficiente nos dois lados** — cada unidade resultante precisa ter questões o bastante para sustentar uma prática (10 questões nominal, via `iniciar_pratica_unidade`). Nas divisões já feitas, o lado mais fraco teve 7 e 8 questões (Improbidade U2 e Direitos e Garantias Fundamentais U2, respectivamente) — ambos aceitos como "gap real do banco", não como impedimento.
3. **Normas extensas ou com mais de um "assunto jurídico" facilmente distinguível** — leis/dispositivos grandes o bastante para que uma única unidade misture temas muito diferentes.

**DECISÃO NECESSÁRIA:** nunca foi formalizado um número mínimo exato de questões abaixo do qual a divisão é proibida. Na prática, 7-8 questões por unidade foi aceito; 4 questões (cogitado para o bloco "Sisnad" da Lei de Drogas) foi considerado insuficiente e motivou a decisão de **não** dividir. Não há um limiar numérico oficial entre esses dois valores.

---

## 3. Quando manter o conteúdo em uma única unidade

Regra aplicada explicitamente na Lei de Drogas (curso_conteudo_id 66): mesmo havendo um corte temático real e coerente (crimes da lei vs. Sisnad/política pública), a divisão foi **rejeitada** porque um dos lados ficaria com **4 questões**, abaixo de qualquer precedente já aceito (mínimo anterior: 7). A regra aplicada foi:

> Evitar unidades artificiais — um corte temático coerente não é suficiente por si só; a massa de questões do lado mais fraco também precisa ser avaliada, e um valor muito abaixo dos precedentes (7-8) pesa contra a divisão, mesmo que o tema seja genuinamente separável.

Nesse caso, a unidade única recebeu escopo e `artigos_esperados` reais mesmo sem fracionar (mesmo tratamento de qualidade documental, só sem separar em duas linhas de `unidades_pedagogicas`).

Ortografia e Classes de palavras (Língua Portuguesa) também foram explicitamente decididas para não fracionar, mas por decisão direta do usuário, sem uma auditoria de massa por tema documentada da mesma forma que a Lei de Drogas.

---

## 4. Como selecionar e classificar questões

1. **Leitura humana obrigatória.** Toda classificação exige ler o enunciado **e todas as alternativas** de cada questão candidata — nunca por ID, banca, concurso, ano ou palavra-chave isolada.
2. **Escrita exclusivamente via RPC oficial** `classificar_questao_unidade_admin(p_questao_id, p_unidade_pedagogica_id)` — nunca `INSERT` direto em `questao_unidades_pedagogicas`. A RPC é `SECURITY DEFINER`, exige `eh_admin()`, e é `ON CONFLICT DO NOTHING` (idempotente).
3. **Questão multiunidade** é permitida quando a questão testa, com peso real (não superficial), mais de um tema que já pertence a unidades diferentes do mesmo conteúdo. Cada vínculo multiunidade recebe uma justificativa própria e nível de confiança (`alta`/`media`) no arquivo de mapa. Exemplos reais: questão 46 (Direitos e Garantias Fundamentais), questão 732 (Improbidade Administrativa).
4. **Trigger de integridade já existente no banco:** `validar_questao_unidade_pedagogica` (em `questao_unidades_pedagogicas.sql`) impede, a nível de banco, vincular uma questão a uma unidade de matéria/assunto diferente do dela — isso é uma trava estrutural, não uma regra de processo.
5. **Confiança declarada por vínculo:** todo mapa registra `alta` ou `media` por linha — `alta` quando o enunciado/gabarito aponta o tema de forma direta e inequívoca; `media` quando a classificação depende de interpretação (ex.: questão mistura assertivas de mais de um bloco, ou o tema não está literalmente no escopo aprovado).

**DECISÃO NECESSÁRIA:** não existe uma definição fechada de quando `media` é aceitável vs. quando deveria bloquear a curadoria até revisão humana adicional — até agora, toda classificação de confiança `media` foi aceita e aplicada normalmente.

---

## 5. Como tratar questões fora de escopo

Regra aplicada na questão 674 (Lei de Drogas): quando uma questão ativa do assunto tem enunciado/alternativas que **não pertencem de fato** ao tema do conteúdo (ex.: 674 é majoritariamente sobre extorsão mediante sequestro e inquérito policial genérico, não sobre a Lei de Drogas), ela é:

1. **Excluída do mapa de classificação** — não recebe nenhum vínculo em `questao_unidades_pedagogicas`.
2. **Documentada explicitamente** no cabeçalho do arquivo de mapa e do teste rollback/apply, com o motivo da exclusão.
3. **Verificada por precondição/pós-condição explícita** nos scripts (`mapa_nao_contem_674`, `674_permanece_nao_classificada`) — o script trava se a questão excluída acabar sendo classificada por engano.
4. **Deixada ativa no banco**, sem alteração de `assunto_id` ou `ativa` — a correção real (reclassificar o assunto da questão, ou desativá-la) é tratada como **saneamento separado**, fora do escopo da curadoria de unidades.

**DECISÃO NECESSÁRIA:** o que fazer, de fato, com uma questão fora de escopo identificada (mover de assunto? desativar? reescrever?) nunca foi decidido — só a regra de "não classificar e documentar" está firme.

### Duplicatas

Regra aplicada em dois casos reais (137/857 na Improbidade Administrativa; 143/869 na Lei de Drogas — mesmo enunciado, mesmas alternativas, ambas ativas):

> A duplicata é identificada e documentada, mas **ambas as questões permanecem classificadas normalmente** — a decisão de desativar uma delas é sempre adiada para um saneamento de banco separado, nunca decidida dentro da curadoria de unidades.

**DECISÃO NECESSÁRIA:** critério para quando desativar uma duplicata (qual delas manter, se reaproveitar histórico de `respostas_usuarios` da desativada) nunca foi definido.

---

## 6. Como validar a classificação (pré-condições e pós-condições)

Todo par teste-rollback/apply real segue o mesmo roteiro, nesta ordem:

**Pré-condições** (sempre antes de qualquer chamada à RPC):
- `curso_conteudo_id` pertence à matéria e ao assunto esperados (`materia_id`/`assunto_id` conferidos por valor exato).
- A(s) unidade(s) pedagógica(s) oficiais existem, com os UUIDs esperados, `ordem` esperada, `ativa = true` — quantidade exata (1 ou 2, conforme a decisão de granularidade).
- Nenhuma classificação prévia já existe para nenhuma questão do mapa (`sem_classificacao_previa`).
- O total de questões candidatas ativas do assunto bate com o valor esperado (contando inclusive as intencionalmente excluídas, como a 674).

**Validação do mapa em si** (antes de aplicar):
- Todas as questões do mapa são realmente ativas e pertencem à matéria/assunto certos.
- O mapa cobre exatamente N questões distintas (nem a mais, nem a menos).
- Nenhuma linha do mapa referencia uma unidade fora do conteúdo.
- Questões explicitamente excluídas (fora de escopo) não aparecem no mapa.

**Pós-condições** (depois do loop de `classificar_questao_unidade_admin`):
- Total de vínculos = exatamente o esperado.
- Questões distintas classificadas = exatamente o esperado.
- Nenhum vínculo existe fora do mapa aprovado (`sem_vinculo_fora_do_mapa`).
- O mapa foi aplicado integralmente (`mapa_aplicado_integralmente`).
- O conjunto de questões multiunidade é **exatamente** o esperado (nem mais, nem menos) — checagem por `array_agg`/comparação de array.
- **Contagem por unidade individual** (`u1_qtd`/`u2_qtd`) bate com o valor exato esperado — esta checagem foi adicionada depois de uma auditoria ter encontrado a ausência dela no primeiro apply de Improbidade Administrativa; desde Lei de Drogas já nasce presente em todo apply novo.
- Nenhuma outra tabela mudou de tamanho: `questoes`, `alternativas`, `curso_conteudos`, `curso_questoes`, `respostas_usuarios`, `sessoes_estudo`, `unidades_pedagogicas` (esta última só muda se a curadoria daquele conteúdo específico criou unidade nova).

---

## 7. Como funciona o teste rollback

- Sempre um arquivo separado, nomeado `classificar_questoes_unidades_<slug>_teste_rollback.sql`.
- Roda **exatamente a mesma lógica** de precondição/aplicação/pós-condição do apply real, mas cada checagem **grava um resultado booleano numa tabela temporária `_relatorio`**, em vez de abortar a transação com `RAISE EXCEPTION`.
- A chamada à RPC é envolvida em `BEGIN...EXCEPTION WHEN OTHERS` por linha — um erro numa questão não impede as demais de serem tentadas, e o erro vira uma linha `false` no relatório.
- Ao final, imprime cada linha do relatório via `RAISE NOTICE` e uma linha resumo `tudo_ok = <bool_and de tudo>`.
- **Termina sempre em `ROLLBACK`**, independentemente do resultado — nada persiste no banco, mesmo que `tudo_ok = true`.
- Locks determinísticos (`FOR UPDATE`) nas linhas de `unidades_pedagogicas` e `questoes` envolvidas são tomados antes de qualquer validação, para simular exatamente a mesma concorrência do apply real.

---

## 8. Como funciona o pós-check

- Sempre um arquivo separado, nomeado `pos_check_classificacao_unidades_<slug>.sql`.
- **100% somente leitura** — só `SELECT`, nenhuma escrita.
- Roda **depois** da aplicação real ter sido confirmada (nunca substitui o apply, nunca "corrige" nada).
- Cada consulta tem o valor esperado escrito em comentário logo acima — divergência deve ser **reportada**, nunca corrigida pelo próprio pós-check.
- Consultas padrão: (1) unidades do conteúdo com título/escopo/artigos; (2) questões classificadas por unidade; (3) total de vínculos e questões distintas; (4) questões multiunidade; (5) questões ativas sem nenhuma classificação (esperado: só as intencionalmente excluídas, se houver); (6) vazamento de classificação para questão de matéria/assunto errado (trigger já impede na escrita, aqui é confirmação); (7) totais estruturais do sistema inteiro (`curso_conteudos`, `unidades_pedagogicas`, `questoes`, `alternativas`) para checar que nada fora do escopo mudou; (8) notas documentais sobre saneamentos pendentes (duplicatas, questões fora de escopo).

---

## 9. Versionamento (Git)

- Cada curadoria gera exatamente 5 arquivos em `supabase/`, com convenção de nome fixa:
  - `curadoria_unidades_<slug>.sql`
  - `mapa_classificacao_<slug>.sql` (ou `mapa_classificacao_unidades_<slug>.sql`)
  - `classificar_questoes_unidades_<slug>_teste_rollback.sql`
  - `classificar_questoes_unidades_<slug>.sql`
  - `pos_check_classificacao_unidades_<slug>.sql`
- **Nada é aplicado no Supabase sem aprovação explícita** para aquela ação específica — geração de arquivo, teste rollback, apply real e commit são sempre etapas aprovadas uma a uma, nunca em lote.
- `git add` sempre nomeia os arquivos exatos daquela etapa — nunca `git add -A`/`git add .`.
- Nunca versionar `.agents/`, `.claude/`, `.mcp.json`.
- Mensagem de commit no padrão Conventional Commits, em português, ex.: `fix(curadoria): fecha unidades de <nome>` ou `feat(pedagogia): fecha curadoria e classificacao da <nome>`.
- Unidades novas recebem um UUID **explícito** no arquivo de curadoria (em vez de `gen_random_uuid()`), justamente para que os arquivos de mapa/classificação — escritos e revisados antes de qualquer aplicação real — possam referenciar esse id de forma determinística.

---

## 10. Regras da Missão Final

Extraídas diretamente de `iniciar_missao_final` (`supabase/missao_pratica_papiro_rpc.sql`):

1. **Só libera quando todas as unidades ativas com aula publicada** do conteúdo já têm **teoria concluída E prática concluída** (checagem de contagem: `total_teoria_concluida = total_unidades` e `total_praticadas = total_unidades`). Isso não se aplica quando `p_refazer = true` (missão já concluída sendo refeita).
2. **30 questões** (`v_quantidade constant integer := 30`), com distribuição **não igualitária** entre as unidades: a cada unidade (em ordem de `ordem`), calcula `ceil(restante / unidades_ainda_não_visitadas)` e busca essa quantidade via `selecionar_candidatas_unidade_pedagogica` — uma unidade com banco mais fraco simplesmente contribui menos, sem travar a montagem.
3. **Fallback de conteúdo inteiro:** se, mesmo somando todas as unidades, não houver 30 questões, o restante é completado por `selecionar_candidatas_conteudo` (mesma lógica de repetição inteligente, mas sem segmentar por unidade).
4. **Idempotência:** se já existe uma sessão `tipo_pratica = 'missao_final'` para a missão (e, em caso de refazer, `status = 'em_andamento'`), a lista de questões planejada é recuperada, não recriada.
5. **Encerramento:** só `concluir_missao_final` marca a missão como `concluida` — exige que todas as questões planejadas da sessão de Missão Final já tenham resposta registrada em `respostas_usuarios`.

---

## 11. Regras de repetição inteligente

Extraídas de `selecionar_candidatas_unidade_pedagogica` (`supabase/questao_unidades_pedagogicas.sql`/`missao_pratica_papiro_rpc.sql`) — a mesma lógica de 3 níveis (Tiers) vale tanto para a prática de 10 questões por unidade quanto, via `selecionar_candidatas_conteudo`, para o fallback da Missão Final:

- **Tier A — nunca respondida** pelo usuário: sempre priorizada primeiro.
- **Tier B — já respondida, mas fora da janela de repetição** (mais de 24h desde a última resposta) **e não usada na missão atual**: dentro deste tier, prioriza primeiro quem **já errou** (`ja_errou desc`), depois a resposta mais antiga, depois `curso_questoes.prioridade`, depois aleatório.
- **Tier C — respondida recentemente** (dentro de 24h) **ou já usada nesta mesma missão**: só entra depois que A e B se esgotarem — é o último recurso para completar a quantidade pedida.
- **Janela de repetição fixa em 24 horas** (`v_janela_repeticao constant interval := interval '24 hours'`).
- Uma questão só é candidata a uma unidade se já estiver classificada em `questao_unidades_pedagogicas` para aquela unidade **e** vinculada ao curso via `curso_questoes` — não há nenhum fallback implícito para questão não classificada.

Este mecanismo é inteiramente **local ao histórico de respostas do próprio usuário** (`respostas_usuarios`). Ele é **desacoplado** do sistema de revisão espaçada mais amplo do produto (`public.revisoes`, chaveado em `erro_id` + `assunto_id`, alimentando o caderno de erros e os bônus de revisão do cronograma) — os dois sistemas de "repetição inteligente" coexistem, mas não compartilham lógica nem granularidade.

**DECISÃO NECESSÁRIA:** se/quando o sistema de revisão espaçada (`revisoes`) deve passar a operar por `unidade_pedagogica_id` em vez de só por `assunto_id` — isso foi mencionado anteriormente como uma evolução futura possível ("Unidade 6 — Revisão Inteligente Papiro"), nunca como regra decidida.

---

## 12. Pontos sem regra definida (registro consolidado)

| # | Ponto | Status |
|---|---|---|
| 1 | Limiar numérico exato de questões mínimas por unidade para autorizar divisão | **DECISÃO NECESSÁRIA** |
| 2 | O que fazer, na prática, com uma questão identificada como fora de escopo (674) | **DECISÃO NECESSÁRIA** |
| 3 | Critério para desativar/mesclar duplicatas (137/857, 143/869) | **DECISÃO NECESSÁRIA** |
| 4 | Quando uma classificação de confiança `media` deve bloquear a curadoria em vez de ser aceita | **DECISÃO NECESSÁRIA** |
| 5 | Obrigatoriedade (ou não) de `artigos_esperados` para matérias não jurídicas (Português, Raciocínio Lógico, Informática) | **DECISÃO NECESSÁRIA** |
| 6 | Futuro de `teoria_escopos_conteudo` (tabela existente, 0 linhas, substituída na prática por `unidades_pedagogicas.escopo`) — manter, usar ou remover | **DECISÃO NECESSÁRIA** |
| 7 | Conectar `registrar_componente_teoria_concluido` ao frontend (hoje código órfão — só `registrar_unidade_teoria_concluida`, por unidade inteira, é usado) | **DECISÃO NECESSÁRIA** |
| 8 | Granularidade da revisão espaçada (`revisoes`) por unidade pedagógica em vez de só por assunto | **DECISÃO NECESSÁRIA** (evolução futura mencionada, não decidida) |

---

*Documento gerado por auditoria somente leitura da arquitetura real (schema, RPCs, Edge Functions e os 4 processos de curadoria já concluídos). Nenhuma regra aqui foi inferida além do que já está implementado em código ou explicitamente decidido pelo usuário em sessões anteriores.*
