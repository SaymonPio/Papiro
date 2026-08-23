# Papiro — contexto de produto

> Status: proposta inicial da Fase Visual 0. Este documento registra contexto e restrições; não autoriza mudanças funcionais, de dados ou de interface por si só.

## 1. Resumo do produto

Papiro é uma plataforma de estudos para concursos. A presença inicial é forte na área policial, mas o produto deve ser capaz de crescer para outras carreiras sem carregar uma estética militar literal.

O Papiro transforma objetivo, disponibilidade, conteúdo do curso, prioridades, desempenho, revisões e erros do aluno em uma próxima ação de estudo compreensível. Sua responsabilidade central é reduzir a incerteza recorrente de quem estuda: **o que eu preciso estudar agora?**

O produto não é apenas um dashboard de métricas. É um ambiente de estudo orientado a ação, continuidade e consolidação.

## 2. Público principal

### Aluno em preparação prolongada

- Estuda durante semanas ou meses.
- Alterna sessões curtas e períodos longos de leitura e questões.
- Precisa retomar rapidamente de onde parou.
- Pode conciliar trabalho, deslocamento, família e preparação.
- Valoriza clareza, previsibilidade e evidência de avanço.
- É sensível a distração, sobrecarga e sensação de atraso.

### Aluno com foco inicial em concursos policiais

- Reconhece a seriedade e a exigência da carreira.
- Não precisa que a interface simule um ambiente tático para sentir pertinência.
- Deve perceber disciplina, preparação e confiança pela precisão do produto, não por fotos de farda, armas, viaturas ou efeitos cinematográficos.

### Expansão futura

A identidade deve permitir novos concursos e carreiras. Elementos centrais da marca precisam remeter a estudo, direção, progresso, domínio e método — não a uma corporação específica.

## 3. Trabalho que o Papiro realiza para o aluno

1. Traduzir um objetivo de concurso em um plano executável.
2. Indicar a próxima ação de estudo com baixa carga cognitiva.
3. Organizar teoria, questões e revisões em uma sequência coerente.
4. Preservar o contexto entre cronograma, missão, teoria e prática.
5. Transformar erro em diagnóstico e revisão.
6. Mostrar progresso sem substituir ação por métricas decorativas.
7. Ajudar o aluno a retornar ao estudo com o mínimo de fricção.

## 4. Promessa de experiência

Ao entrar no Papiro, o aluno deve:

- entender rapidamente onde está;
- encontrar o próximo passo sem procurar em vários cards;
- confiar que a ação apresentada usa dados reais do seu curso e histórico;
- estudar por longos períodos sem fadiga visual desnecessária;
- perceber progresso sem gamificação infantil;
- navegar por teclado, toque ou mouse com segurança;
- continuar uma missão interrompida sem reconstruir mentalmente o contexto.

## 5. Princípios de produto

### A próxima ação vence a decoração

A interface deve priorizar o que o aluno precisa fazer. Métricas e contexto apoiam a ação; não competem com ela.

### Verdade de dados

Nenhuma missão, progresso, prioridade, recomendação ou métrica pode ser inventada para preencher uma composição visual. Quando um dado não existe ou não pode ser determinado com segurança, a interface deve:

- omitir o bloco;
- apresentar um estado indisponível honesto; ou
- oferecer uma ação segura para chegar ao dado.

### Continuidade pedagógica

O redesign deve preservar os fluxos validados de cronograma, teoria por unidades, prática, classificação do erro, caderno de erros, revisões e Missão Final.

### Densidade com legibilidade

O produto deve ser relativamente compacto, mas nunca apertado. Densidade significa reduzir espaço e superfícies sem função — não reduzir texto, alvos de toque ou line-height abaixo do confortável.

### Seriedade sem militarização

Disciplina, confiança e foco devem vir de tipografia, hierarquia, ritmo, conteúdo e consistência. Fotos táticas e linguagem militar repetitiva não são atalhos de identidade.

### Premium pela precisão

A sensação premium deve surgir de alinhamento, contraste, estados completos, resposta rápida, microinterações discretas e ausência de ruído.

## 6. Personalidade e voz

O Papiro é:

- claro;
- direto;
- encorajador sem euforia;
- sério sem ser hostil;
- confiante sem prometer resultado;
- orientado a ação;
- pedagógico sem infantilizar.

### Padrão de escrita

- Preferir verbos explícitos: “Continuar estudando”, “Continuar missão”, “Resolver questões”, “Revisar erros”.
- Explicar estados e consequências em linguagem simples.
- Evitar jargão de sistema quando a ação do aluno é conhecida.
- Evitar caixa-alta em textos longos e rótulos frequentes.
- Usar “missão” apenas quando corresponde ao fluxo pedagógico real, não como sinônimo universal de página, card ou ação.
- Não usar urgência artificial, culpa ou linguagem de combate.

## 7. Fluxos centrais que devem ser preservados

1. Autenticação e recuperação de acesso.
2. Escolha e configuração do objetivo.
3. Entrada no painel.
4. Consulta do cronograma.
5. Início ou retomada de missão.
6. Teoria organizada por unidades pedagógicas.
7. Prática por questões.
8. Feedback e diagnóstico do erro.
9. Resultado da unidade ou sessão.
10. Caderno de erros e revisões.
11. Estatísticas do curso ativo.
12. Envio e acompanhamento de edital.

Mudanças visuais não podem alterar contratos de banco, RPCs, regras de prioridade, montagem do cronograma ou progressão pedagógica sem uma fase funcional separada e explicitamente autorizada.

## 8. Hierarquia futura do painel

O painel deve responder de imediato: **“O que eu preciso estudar agora?”**

Ordem aprovada:

1. Saudação compacta.
2. “Seu próximo passo está aqui”.
3. Ação primária “Continuar estudando”.
4. Ação secundária “Ver cronograma”.
5. Missão de hoje, quando sustentada por dados reais.
6. Progresso real da missão ou um estado honesto quando o progresso granular não existir.
7. Ação “Continuar missão”.
8. Métricas compactas e acionáveis.
9. Próximos estudos derivados do plano real.
10. Ações “Estudar” somente quando puderem iniciar ou retomar o fluxo validado.

## 9. Referências e uso correto

### Referência estética principal

`https://template-07-saas.vercel.app/`

Usar como referência de acabamento, composição dark, ritmo e apresentação de produto. Não copiar conteúdo, marca, estrutura de marketing ou padrões que transformem o Papiro em um template SaaS genérico.

### Referência adicional

Linear.

Usar como referência de densidade, hierarquia, navegação, velocidade percebida e redução de ruído. Não copiar sua marca, tipografia, paleta ou modelo de informação.

### KokonutUI

Fonte seletiva de implementação. Um componente só pode ser adotado quando resolver um problema concreto melhor do que o sistema próprio, após auditoria de dependências, acessibilidade, motion e aderência à identidade.

## 10. Anti-referências

- estética policial ou militar cinematográfica;
- fotos táticas como background global;
- glow, neon e glassmorphism;
- gradientes usados como preenchimento padrão;
- cards gigantes;
- cards dentro de cards;
- pills como linguagem predominante;
- dashboard SaaS genérico;
- ícones em quadrados decorativos sem função;
- efeitos apenas decorativos;
- animações chamativas ou elásticas;
- títulos desproporcionais em telas operacionais;
- texto cinza de baixo contraste em superfícies coloridas;
- tipografia genérica ou inconsistente;
- métricas sem decisão ou ação associada.

## 11. Fora do escopo da Fase Visual 0

- redesenhar páginas;
- aplicar fontes;
- criar componentes de produção;
- mover rotas;
- refatorar integralmente `globals.css`;
- instalar KokonutUI ou outras bibliotecas;
- mudar Supabase, banco, migrations, RPCs ou dados;
- mudar regras de negócio ou fluxos pedagógicos;
- criar métricas ou recomendações inexistentes.

## 12. Critérios de sucesso da modernização

- O aluno identifica a próxima ação em poucos segundos.
- A navegação mantém contexto entre as telas do aluno.
- A leitura longa de teoria permanece confortável.
- Os estados loading, empty, error, success e disabled são completos e consistentes.
- Desktop e mobile compartilham a mesma hierarquia, adaptada ao espaço.
- O sistema reduz duplicações e valores hardcoded progressivamente.
- A identidade é reconhecível sem depender de fotografia policial.
- Nenhum ganho visual depende de regressão funcional ou de dados fictícios.

## 13. Decisões e gates da primeira implementação

- A Fase Visual 0, suas foundations e os contratos conceituais de Button e Surface estão aprovados como direção inicial.
- Geist e IBM Plex Sans permanecem candidatas. A mesma composição do painel deve permitir comparação controlada entre as duas, sem mudar conteúdo, pesos, spacing ou layout.
- Não adotar família ornamental ou serif na Fase Visual 1.
- Comparar a tela-modelo nos viewports aprovados antes de escolher a família definitiva.
- Não instalar Impeccable no projeto nesta fase. `PRODUCT.md` e `DESIGN.md` são a fonte de verdade de produto e design.
- Não instalar biblioteca de ícones antes de aprovar uma família canônica.
- Confirmar o read model que abastecerá missão de hoje e próximos estudos sem duplicar regras do cronograma. Se o compartilhamento for arriscado, omitir os blocos na primeira entrega.
