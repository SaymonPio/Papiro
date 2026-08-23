# Papiro — direção visual e foundations

> Status: proposta inicial da Fase Visual 0. Nenhum token, fonte ou componente descrito aqui foi aplicado ao produto.

## 1. Objetivo da direção visual

Criar uma interface dark, moderna, premium, séria e altamente legível para estudo prolongado. A experiência deve ser compacta, orientada a ação e reconhecível como Papiro sem recorrer a estética tática, excesso de dourado ou composição genérica de dashboard.

O mundo visual proposto é o de uma **biblioteca de estudo contemporânea**: documentos organizados, marcações precisas, progressão clara, camadas discretas e foco no conteúdo. O nome Papiro pode inspirar ritmo editorial, índice, trilha e registro — sem imitar papel antigo ou usar ornamentos históricos.

## 2. Princípios visuais

### Conteúdo antes da moldura

Superfícies devem organizar informação, não decorar cada grupo. Divisores, alinhamento e espaço substituem cards aninhados sempre que possível.

### Uma ação dominante por região

Cada seção deve possuir no máximo uma ação primária evidente. Ações secundárias usam menor peso visual.

### Contraste controlado

Texto e controles devem manter contraste alto. Cor viva é reservada para interação, foco e progresso; não deve preencher grandes áreas sem necessidade.

### Densidade respirável

Headers operacionais são compactos. Métricas ocupam pouco espaço. Conteúdo de teoria mantém measure e line-height confortáveis.

### Profundidade por hierarquia

Priorizar mudança de surface e border. Sombras ficam restritas a overlays, menus e elementos realmente elevados.

### Motion com propósito

Animação confirma mudança, continuidade ou entrada/saída. Não existe para demonstrar tecnologia.

## 3. Arquitetura visual incremental

### Estado futuro

- Foundations como fonte única de verdade.
- Componentes canônicos do Papiro.
- `StudentAppShell` compartilhado, sem exigir mudança imediata de rotas.
- Estilos de domínio próximos dos respectivos componentes.
- `globals.css` legado migrado por tela, sem reescrita integral.

### Estratégia de escopo

Tokens e componentes da nova linguagem devem ser inicialmente isolados sob um escopo como `.papiro-next` ou equivalente. Somente a tela-modelo recebe o escopo na primeira implementação. Isso evita que novas variáveis alterem páginas legadas por cascata acidental.

Não mover rotas para `app/(aluno)` antes da aprovação da tela-modelo.

## 4. Tipografia

### Famílias candidatas

A decisão tipográfica definitiva será visual. A primeira implementação do painel deve permitir comparar a mesma composição entre:

- **A. Geist**, já presente no projeto;
- **B. IBM Plex Sans**, em versão variável ou nos pesos estritamente necessários.

Geist oferece continuidade técnica com a base atual e boa eficiência em UI. IBM Plex Sans oferece personalidade mais editorial e técnica, boa diferenciação de caracteres e numerais e suporte adequado ao português. Nenhuma das duas está aprovada como escolha definitiva.

### Comparação controlada

- Uma única árvore de componentes, um único conteúdo e uma única folha de layout.
- A troca altera somente a família resolvida por um token como `--papiro-font-ui`.
- Tamanho, line-height, peso, tracking, spacing, largura de container e conteúdo permanecem idênticos.
- O mecanismo de comparação deve ficar restrito à tela-modelo e não alterar páginas legadas.
- A escolha final depende de inspeção nos mesmos viewports e nos mesmos estados.
- O mecanismo temporário de comparação deve ser removido ou convertido em configuração explícita depois da decisão.

### Família secundária

Não adotar família secundária, ornamental ou serif na Fase Visual 1. A teoria deve ser testada futuramente com a família principal escolhida, usando measure e line-height adequados.

### Fallback conceitual

`var(--papiro-font-ui), "Segoe UI", system-ui, sans-serif`

O fallback não autoriza manter Arial como escolha deliberada.

### Pesos

- 400: texto de leitura e descrições.
- 500: labels de interface, metadados e ênfase moderada.
- 600: botões, títulos de componentes e navegação ativa.
- 700: títulos principais e números críticos.
- 800/900: evitar; reservar somente para situação excepcional de marca.

### Escala proposta

| Token | Tamanho / line-height | Uso |
|---|---:|---|
| `text-xs` | 12 / 16 px | metadados auxiliares; nunca conteúdo crítico isolado |
| `text-sm` | 13 / 18 px | labels, badges e navegação compacta |
| `text-ui` | 14 / 20 px | botões, campos e controles |
| `text-base` | 15 / 22 px | corpo padrão da aplicação |
| `text-reading` | 17 / 29 px | teoria e explicações longas |
| `text-lg` | 18 / 26 px | introduções e títulos de bloco |
| `heading-sm` | 20 / 28 px | títulos de card ou seção |
| `heading-md` | 24 / 32 px | títulos de página secundários |
| `heading-lg` | 32 / 40 px | título principal de página desktop |
| `display` | 40 / 48 px | marketing ou momento excepcional; não usar em UI operacional comum |
| `metric` | 28 / 32 px | KPI compacto |

Em mobile, `heading-lg` deve cair para 28 / 36 px. Não usar títulos de 5 rem na área operacional.

### Tracking

- Corpo: `0`.
- Títulos grandes: entre `-0.01em` e `-0.025em`.
- Labels: até `0.06em` quando uppercase for realmente necessário.
- Evitar o padrão atual de `0.15em`–`0.20em` aplicado amplamente.

### Conteúdo longo de teoria

- Tamanho inicial: 17 px.
- Line-height: 1.65–1.72.
- Measure: 68–75 caracteres.
- Parágrafos com ritmo vertical previsível.
- Negrito para conceitos, não para frases inteiras.
- Callouts devem interromper a leitura somente quando mudam a compreensão ou a ação.

### Numerais e KPIs

- Usar `font-variant-numeric: tabular-nums` onde alinhamento importa.
- Evitar fonte mono apenas para criar aparência técnica.
- Unidade e contexto permanecem próximos do número.

## 5. Cores

### Princípio

Verde profundo forma o ambiente. Verde vivo identifica interação, foco e progresso. Dourado é assinatura de marca e conquista pontual, não a cor de todo CTA e estado.

Os valores abaixo são uma proposta inicial. Eles devem ser verificados no navegador e por contraste antes da implementação.

### Canvas e surfaces

| Token | Valor | Uso |
|---|---|---|
| `color-canvas` | `#06110D` | fundo principal |
| `color-canvas-subtle` | `#091812` | faixa ou região secundária |
| `color-surface-1` | `#0D1F17` | superfície base |
| `color-surface-2` | `#12281E` | superfície elevada ou interativa |
| `color-surface-3` | `#183329` | estado selecionado discreto |
| `color-border-subtle` | `#213B30` | separadores e bordas padrão |
| `color-border-strong` | `#315346` | borda de ênfase semântica |

Surfaces devem ser sólidas. Transparência e backdrop blur não fazem parte da linguagem padrão.

### Texto

| Token | Valor | Contraste aproximado no canvas |
|---|---|---:|
| `color-text-primary` | `#F3F7F5` | 17,77:1 |
| `color-text-secondary` | `#BCCAC3` | 11,31:1 |
| `color-text-subtle` | `#879990` | 6,39:1 |
| `color-text-disabled` | `#5D7067` | uso não crítico e acompanhado de estado |

`text-subtle` continua acima de 4,5:1 nas três surfaces propostas.

### Interação e marca

| Token | Valor | Uso |
|---|---|---|
| `color-action` | `#4DDB8B` | CTA primário e progresso acionável |
| `color-action-hover` | `#63E89D` | hover |
| `color-action-pressed` | `#37C979` | active/pressed |
| `color-on-action` | `#04100A` | texto/ícone sobre ação |
| `color-brand-gold` | `#C6A15B` | marca, marco ou conquista pontual |
| `color-focus` | `#92E6BB` | focus ring |

### Semânticas

| Token | Valor | Uso |
|---|---|---|
| `color-success` | `#3DCB82` | operação concluída e estado positivo |
| `color-warning` | `#E0A04B` | atenção ou atraso recuperável |
| `color-danger` | `#F06E78` | erro e ação destrutiva |
| `color-info` | `#61A8F8` | informação neutra ou processamento |

Cada semântica precisa de tokens derivados para fundo discreto e borda; não reutilizar a cor de marca como warning.

## 6. Spacing

Escala base de 4 px com incrementos intermediários apenas quando necessários:

| Token | Valor |
|---|---:|
| `space-0` | 0 |
| `space-0.5` | 2 px |
| `space-1` | 4 px |
| `space-1.5` | 6 px |
| `space-2` | 8 px |
| `space-3` | 12 px |
| `space-4` | 16 px |
| `space-5` | 20 px |
| `space-6` | 24 px |
| `space-8` | 32 px |
| `space-10` | 40 px |
| `space-12` | 48 px |
| `space-16` | 64 px |

Regras:

- controles compactos usam 8–12 px de gap;
- regiões da página usam 24–32 px;
- seções maiores usam 40–48 px;
- 64 px é limite comum na área operacional;
- padding não deve compensar falta de hierarquia.

## 7. Radius

| Token | Valor | Uso |
|---|---:|---|
| `radius-xs` | 4 px | badges e pequenos controles |
| `radius-sm` | 6 px | inputs e botões |
| `radius-md` | 8 px | surfaces e cards |
| `radius-lg` | 12 px | dialogs e regiões excepcionais |
| `radius-full` | 999 px | avatar, indicador circular e poucos status |

Não usar pill como forma padrão de navegação, botão ou container.

## 8. Shadows

O estado padrão de Surface não possui sombra.

| Token | Valor conceitual | Uso |
|---|---|---|
| `shadow-none` | nenhuma | conteúdo no fluxo |
| `shadow-sm` | `0 1px 2px rgba(0,0,0,.24)` | controle elevado discreto |
| `shadow-md` | `0 8px 24px rgba(0,0,0,.28)` | menu ou popover |
| `shadow-lg` | `0 20px 60px rgba(0,0,0,.40)` | dialog/drawer |

Proibido usar box-shadow como glow colorido em componentes comuns.

## 9. Iconografia

### Contrato

- Uma única família outline.
- Stroke entre 1,75 e 2 px.
- Tamanhos canônicos: 16, 18, 20 e 24 px.
- Ícones herdam `currentColor`.
- Ícone decorativo usa `aria-hidden="true"`.
- IconButton exige nome acessível.
- Não misturar emojis, glifos Unicode e SVGs como equivalentes.

### Alternativas em avaliação

- **Lucide:** melhor candidata a família canônica por cobertura, consistência outline, manutenção ativa e baixo custo de composição. Exige auditoria de bundle, API e acessibilidade antes de instalação.
- **SVG próprio mínimo:** adequado para marca e símbolos pedagógicos específicos, mas inadequado como família geral porque transfere manutenção, consistência e cobertura para o projeto.
- **Outra biblioteca:** somente se demonstrar vantagem objetiva sobre Lucide em cobertura, acessibilidade, bundle ou aderência visual.

Recomendação inicial: usar Lucide futuramente para ícones funcionais e reservar SVG próprio para marca ou conceitos exclusivos do Papiro. Nenhuma biblioteca será instalada no Gate A; a estrutura visual base não depende dessa decisão.

## 10. Motion

| Token | Duração | Uso |
|---|---:|---|
| `motion-instant` | 80 ms | feedback imediato muito pequeno |
| `motion-fast` | 120 ms | hover, pressed e foco visual |
| `motion-base` | 180 ms | seleção, expansão curta e troca de estado |
| `motion-slow` | 240 ms | drawer, dialog e reorganização maior |

Curva padrão: `cubic-bezier(0.2, 0.8, 0.2, 1)`.

Regras:

- Sem bounce, elastic ou overshoot.
- Não animar grandes backgrounds.
- Não atrasar ação para exibir animação.
- Preferir opacity e transform quando necessário.
- `prefers-reduced-motion: reduce` remove movimento não essencial e reduz transições.

## 11. Breakpoints e adaptação

| Token | Largura | Intenção |
|---|---:|---|
| `bp-xs` | 360 px | telefone estreito |
| `bp-sm` | 480 px | telefone amplo |
| `bp-md` | 768 px | tablet/refluxo de layout |
| `bp-lg` | 1024 px | mudança do app shell |
| `bp-xl` | 1280 px | desktop padrão |
| `bp-2xl` | 1440 px | desktop amplo |

Breakpoints são gatilhos de composição, não de dispositivo. O layout deve permanecer correto entre eles.

### Comportamento futuro do shell

- `>= 1024`: sidebar/rail persistente com rótulos acessíveis e estado ativo.
- `768–1023`: rail compacto ou drawer conforme teste da tela-modelo.
- `< 768`: header compacto e drawer; nunca renderizar toda a navegação acima do conteúdo.

## 12. Button — contrato conceitual

### API futura

Propriedades conceituais:

- `variant`: `primary | secondary | outline | ghost | danger | icon`;
- `size`: `sm | md | lg`;
- `loading`;
- `disabled`;
- `leadingIcon`;
- `trailingIcon`;
- `fullWidth`;
- `type` explícito em formulários.

O componente deve aceitar `button` e, quando necessário, um adapter seguro para link sem duplicar os estilos.

### Tamanhos

| Tamanho | Altura | Padding horizontal | Texto | Ícone |
|---|---:|---:|---:|---:|
| `sm` | 32 px | 12 px | 13 px | 16 px |
| `md` | 40 px | 16 px | 14 px | 18 px |
| `lg` | 48 px | 20 px | 15 px | 20 px |

`sm` é permitido em interfaces densas de desktop. Ações primárias e controles de toque devem usar `md` ou `lg`, com alvo efetivo adequado.

### Variantes

#### Primary

- Fundo `color-action`.
- Texto `color-on-action`.
- Uma por região de decisão.
- Não usa dourado como padrão.

#### Secondary

- Fundo `surface-2`.
- Borda discreta.
- Texto primário.

#### Outline

- Fundo transparente.
- Borda default/strong conforme contexto.
- Texto primário ou action.

#### Ghost

- Sem borda no default.
- Hover cria apenas surface discreta.
- Ações de menor prioridade.

#### Danger

- Cor danger.
- Ação destrutiva explícita.
- Não usar para erro passivo ou warning.

#### Icon

- Forma quadrada em 32, 40 ou 48 px.
- Exige `aria-label` ou nome visível por tooltip acessível.
- Não transforma o ícone em tile decorativo.

### Estados

#### Default

Contraste completo e hierarquia correspondente à variante.

#### Hover

Mudança curta de cor/surface; deslocamento vertical é dispensável.

#### Active

Cor pressed e feedback imediato. Não reduzir o alvo.

#### Focus-visible

- ring de 2 px com `color-focus`;
- offset de 2 px usando a cor do canvas;
- nunca remover outline sem substituição equivalente.

#### Disabled

- Sem hover/active.
- Contraste reduzido, mas texto ainda identificável.
- Cursor e semântica coerentes.
- Não depender apenas de opacidade.

#### Loading

- Preserva largura e posição do botão.
- Impede submissão repetida.
- Usa spinner discreto.
- Mantém rótulo ou alternativa acessível.
- Define `aria-busy="true"` quando aplicável.

### Linguagem de ação

Preferir ações completas e contextuais:

- Continuar estudando;
- Continuar missão;
- Estudar;
- Resolver questões;
- Ver cronograma;
- Revisar erros;
- Fazer simulado.

Evitar “Avançar”, “Explorar” ou “Continuar” sem contexto quando um verbo mais preciso estiver disponível.

## 13. Surface e Card — contrato conceitual

### Surface

Surface é uma região visual de organização, não necessariamente um card.

Propriedades conceituais:

- `level`: `canvas | base | raised | overlay`;
- `padding`: `none | sm | md | lg`;
- `border`: `none | subtle | strong`;
- `radius`: `none | sm | md | lg`;
- `as`: elemento semântico apropriado.

Regras:

- `base` usa `surface-1`.
- `raised` usa `surface-2` e, em regra, border antes de shadow.
- `overlay` é exclusivo de menu, popover, drawer e dialog.
- Surface não implica hover, clique ou sombra.

### Card

Card é uma Surface que representa uma unidade autônoma ou interativa.

Um Card só deve existir quando pelo menos uma condição for verdadeira:

- o bloco é acionável como unidade;
- pode ser reordenado, selecionado ou comparado;
- precisa ser compreendido fora da seção que o contém;
- possui estado próprio claramente delimitado.

### Proibição de nesting visual

Card dentro de Card deve ser substituído por:

- seção interna sem fundo;
- divider;
- lista;
- linha;
- callout sem elevação;
- mudança discreta de surface.

### Interação

- Card não clicável não recebe hover.
- Card clicável precisa de foco visível em toda a unidade.
- Ações internas não podem competir com o clique do card.
- Seleção usa border/surface, não glow.

## 14. Estados canônicos

### Loading

- Esqueleto quando a estrutura é conhecida.
- Loader de marca apenas para bloqueio integral e curto.
- Texto de estado visível em esperas potencialmente longas.

### Empty

- Explica por que está vazio.
- Indica o próximo passo.
- Tem CTA somente quando existe ação real.

### Error

- Diz o que falhou sem expor detalhe técnico.
- Diferencia erro recuperável, sessão expirada e falta de contexto.
- Oferece repetir, entrar novamente ou configurar quando aplicável.

### Success

- Confirma a conclusão sem bloquear o fluxo.
- Não usa o mesmo estilo de warning.

## 15. Acessibilidade mínima

- Contraste WCAG AA para texto e controles.
- Alvos de toque adequados.
- Foco visível em todos os elementos interativos.
- `aria-current` na navegação.
- Tabs com teclado e relacionamento tab/panel completo.
- Progressos com semântica e valores ARIA.
- Nenhum ID duplicado.
- Ícones sem texto exigem nome acessível.
- Zoom de 200% sem perda de função.
- Navegação funcional com `prefers-reduced-motion`.

## 16. Uso futuro do KokonutUI

Cada adoção exige:

1. problema real documentado;
2. revisão do código fonte;
3. lista de dependências;
4. teste de teclado e leitor de tela;
5. teste de reduced motion;
6. substituição integral dos estilos pelos tokens do Papiro;
7. remoção de efeitos decorativos;
8. decisão explícita de manutenção.

Candidatos iniciais de investigação: upload de edital e, se necessário, drawer acessível. Button, Surface, shell, questão, missão e teoria permanecem componentes próprios.

## 17. Plano exato para a primeira implementação de `/painel`

Nenhuma etapa abaixo deve começar sem aprovação desta Fase Visual 0.

### Gate 1 — sincronização e verdade funcional

1. Revalidar HEAD e diferenças de frontend entre `feature/redesign-frontend` e a branch-base ativa.
2. Incorporar mudanças concorrentes somente por estratégia Git explicitamente aprovada.
3. Registrar os dados já disponíveis no painel: usuário e objetivos.
4. Mapear, sem mudar banco, o read model já usado pelo cronograma para plano, sessões, revisões e ação de iniciar missão.
5. Não duplicar a regra de priorização dentro do painel.

### Gate 2 — teste de contrato antes da extração

1. Preservar os testes existentes de cronograma e missão.
2. Criar testes de caracterização para qualquer lógica extraída do cronograma.
3. Garantir que cronograma e painel recebam a mesma missão de hoje para o mesmo estado.
4. Se não for possível compartilhar o read model com segurança, a primeira versão do painel omite missão/próximos estudos e mantém CTA para o cronograma; não usa fixture em produção.

### Gate 3 — foundations isoladas

1. Criar uma folha de foundations nova e escopada; não reescrever `globals.css`.
2. Importar sem alterar a aparência de páginas legadas.
3. Implementar somente os tokens aprovados e necessários ao painel.
4. Disponibilizar Geist e IBM Plex Sans apenas no escopo do painel para comparação controlada; nenhuma delas se torna definitiva nessa etapa.

### Gate 4 — componentes mínimos

O Gate A da Fase Visual 1 implementa apenas:

- `Button`;
- `Surface`;
- `PageHeader`;
- `StudentAppShell` usado somente pelo painel, sem mover rotas.

`InlineAlert`, `Progress` e `CompactMetric` só entram em gates posteriores quando houver necessidade real sustentada por dado ou estado existente. Cada componente criado recebe teste de estados e acessibilidade proporcional ao risco.

### Gate 5 — composição posterior do painel

Ordem da página:

1. Shell e navegação.
2. Saudação compacta.
3. Bloco de próxima ação com “Continuar estudando” e “Ver cronograma”.
4. Missão de hoje, somente com dado real.
5. Progresso da missão conforme estado realmente disponível; não fabricar percentual.
6. “Continuar missão” reutilizando o fluxo existente de iniciar/recuperar missão.
7. Métricas compactas com contexto.
8. Próximos estudos derivados do mesmo plano do cronograma.
9. Ações “Estudar” usando contratos existentes e proteção contra clique duplo.
10. Estados sem objetivo, sem curso ativo, sem matrícula, loading parcial e erro recuperável.

### Gate 6 — navegação responsiva

1. Desktop com sidebar/rail claro e `aria-current`.
2. Tablet com navegação compacta testada.
3. Mobile com header e drawer, sem lista completa antes do conteúdo.
4. Foco preso e restaurado no drawer.
5. Logout e administração separados da navegação principal do aluno.

### Gate 7 — verificação

1. Lint e testes existentes.
2. Testes do read model extraído.
3. Testes de Button, Surface e shell.
4. Teclado completo.
5. Contraste.
6. Viewports 1440, 1024, 768, 480, 390 e 360 px.
7. Zoom de 200%.
8. Reduced motion.
9. Comparação de dados e ações com o painel/cronograma anterior.
10. Diff final restrito ao frontend e sem arquivos de agente, Supabase ou banco.

### Arquivos prováveis do Gate A

- `app/painel/page.tsx`;
- `app/layout.tsx`, somente para disponibilizar as duas variáveis de fonte sem alterar páginas legadas;
- nova folha de foundations escopada;
- `components/ui/Button.tsx`;
- `components/ui/Surface.tsx`;
- `components/ui/PageHeader.tsx`;
- `components/layout/StudentAppShell.tsx`;
- testes correspondentes.

Não alterar nessa implementação:

- Supabase, migrations, RPCs ou dados;
- regras de prioridade do cronograma;
- progressão pedagógica;
- outras páginas do aluno, exceto adaptação mínima estritamente necessária para não quebrar navegação;
- estrutura de rotas.

## 18. Gates ainda abertos

- Escolha definitiva entre Geist e IBM Plex Sans após comparação da mesma composição.
- Validação visual da referência em navegador conectado.
- Aprovação de uma família canônica de ícones antes de instalar dependência.
- Caracterização e aprovação do compartilhamento do read model do cronograma antes de missão de hoje ou próximos estudos.
- Impeccable permanece fora do projeto; `PRODUCT.md` e `DESIGN.md` são a fonte de verdade nesta fase.
