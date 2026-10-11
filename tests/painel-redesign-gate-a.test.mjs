import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const painel = await readFile(
  new URL("../app/painel/page.tsx", import.meta.url),
  "utf8",
);
const rootLayout = await readFile(
  new URL("../app/layout.tsx", import.meta.url),
  "utf8",
);
const painelLayout = await readFile(
  new URL("../app/painel/layout.tsx", import.meta.url),
  "utf8",
);
const styles = await readFile(
  new URL("../app/painel/painel.css", import.meta.url),
  "utf8",
);
const shell = await readFile(
  new URL("../components/layout/StudentAppShell.tsx", import.meta.url),
  "utf8",
);
const homeHeader = await readFile(
  new URL("../components/home/HomeHeader.tsx", import.meta.url),
  "utf8",
);
const homeStyles = await readFile(
  new URL("../app/home.module.css", import.meta.url),
  "utf8",
);
const weeklyStats = await readFile(
  new URL("../components/painel/WeeklyStatsCard.tsx", import.meta.url),
  "utf8",
);
const button = await readFile(
  new URL("../components/ui/Button.tsx", import.meta.url),
  "utf8",
);
const surface = await readFile(
  new URL("../components/ui/Surface.tsx", import.meta.url),
  "utf8",
);
const packageJson = await readFile(
  new URL("../package.json", import.meta.url),
  "utf8",
);
const packageLock = await readFile(
  new URL("../package-lock.json", import.meta.url),
  "utf8",
);
const configuracao = await readFile(
  new URL("../app/configuracao/page.tsx", import.meta.url),
  "utf8",
);
const catalogoCursos = await readFile(
  new URL("../lib/cursos.ts", import.meta.url),
  "utf8",
);

test("Gate V2 preserva a fonte de dados e os comportamentos atuais do painel", () => {
  assert.match(painel, /supabase\.auth\.getUser\(\)/);
  assert.match(painel, /\.from\("objetivos"\)/);
  assert.match(
    painel,
    /\.select\("id, concurso, cargo, banca, data_prova, horas_diarias"\)/,
  );
  assert.match(painel, /\.order\("data_prova", \{ ascending: true \}\)/);
  assert.match(painel, /supabase\.auth\.signOut\(\)/);
  assert.match(painel, /window\.location\.replace\("\/login"\)/);
  assert.match(painel, /<MarcaCarregando texto="Carregando seu plano\.\.\."/);
  assert.match(painel, /function diasAte\(/);
});

test("CTA principal é único, honesto e não duplica a lógica do cronograma", () => {
  assert.match(painel, /href="\/cronograma"/);
  assert.match(painel, />\s*Ver cronograma\s*<\/ButtonLink>/);
  assert.match(painel, />\s*Configurar objetivo\s*<\/ButtonLink>/);
  assert.equal((painel.match(/"\/cronograma"/g) ?? []).length, 1);
  assert.doesNotMatch(painel, /Continuar estudando/i);
  assert.doesNotMatch(painel, /Retome (?:o estudo|sua missão)/i);
  assert.doesNotMatch(painel, /iniciar_ou_recuperar_missao_diaria/);
  assert.equal((painel.match(/\.rpc\(/g) ?? []).length, 1);
  assert.match(painel, /supabase\.rpc\("revisoes_do_curso_ativo"\)/);
  assert.doesNotMatch(painel, /Missão de hoje/i);
  assert.doesNotMatch(painel, /Próximos estudos/i);
  assert.doesNotMatch(painel, /<progress/i);
});

test("painel usa somente dados permitidos e acessos rápidos reais", () => {
  for (const href of [
    "/questoes",
    "/caderno-de-erros",
    "/estatisticas",
  ]) {
    assert.match(painel, new RegExp(`href: "${href}"`));
  }
  assert.doesNotMatch(painel, /href: "\/editais"/);

  for (const termoVetado of [
    /percentual/i,
    /sequência/i,
    /medalha/i,
    /quantidade de questões/i,
    /próximos conteúdos/i,
  ]) {
    assert.doesNotMatch(painel, termoVetado);
  }
});

test("card do caderno mostra a próxima revisão usando a fonte canônica", () => {
  assert.match(painel, /type RevisaoPendente/);
  assert.match(painel, /revisao\.status === "pendente"/);
  assert.match(
    painel,
    /a\.agendada_para\.localeCompare\(b\.agendada_para\)/,
  );
  assert.match(painel, /proximaRevisao\?\.assunto_nome/);
  assert.match(painel, />\s*Próxima revisão\s*</);
  assert.match(painel, /Nenhuma revisão pendente/);
  assert.match(painel, /Seu próximo conteúdo aparecerá aqui/);
  assert.match(styles, /\.papiro-review-quick-card/);
  assert.doesNotMatch(painel, /iniciar_ou_recuperar_missao_diaria/);
});

test("painel reutiliza a capa canônica do curso sem alterar a consulta", () => {
  assert.match(painel, /import Image from "next\/image"/);
  assert.match(painel, /encontrarCursoPorObjetivo/);
  assert.match(painel, /src=\{cursoPrincipal\.imagem\}/);
  assert.match(painel, /alt=\{`Capa do curso \$\{cursoPrincipal\.concurso\}`\}/);
  assert.match(painel, /unoptimized/);
  assert.match(styles, /\.papiro-focus-card__media[\s\S]*?position:\s*absolute/);
  assert.match(styles, /\.papiro-focus-card__media[\s\S]*?inset:\s*0/);
  assert.match(styles, /\.papiro-focus-card__media[\s\S]*?height:\s*100%/);
  assert.match(styles, /\.papiro-focus-card__image[\s\S]*?object-fit:\s*cover/);
  assert.doesNotMatch(styles, /\.papiro-focus-card__media\s*\{[^}]*aspect-ratio/s);
  assert.match(
    painel,
    /<Link\s+className="papiro-focus-card__plan"\s+href="\/configuracao"/s,
  );
  assert.match(painel, /Escolher curso/);
  assert.doesNotMatch(painel, /papiro-plan-card__link/);
  assert.match(styles, /\.papiro-focus-card__plan:hover\s*\{/);
  assert.match(styles, /\.papiro-focus-card__plan:focus-visible\s*\{/);
  assert.match(configuracao, /import \{ cursosDisponiveis \} from "@\/lib\/cursos"/);
  assert.match(configuracao, /cursosDisponiveis\.map/);
  assert.match(catalogoCursos, /Brigada Militar do Rio Grande do Sul/);
  assert.match(catalogoCursos, /imagem: "\/cursos\/brigada-militar-rs\.png"/);
  assert.match(catalogoCursos, /encontrarCursoPorObjetivo/);
});

test("selecionar um curso conduz o aluno diretamente ao campo de horas", () => {
  assert.match(configuracao, /useRef<HTMLInputElement>\(null\)/);
  assert.match(configuracao, /onClick=\{\(\) => selecionarConcurso\(concurso\.id\)\}/);
  assert.match(configuracao, /ref=\{horasInputRef\}/);
  assert.match(configuracao, /campoHoras\.scrollIntoView\(\{/);
  assert.match(configuracao, /behavior: reduzirMovimento \? "auto" : "smooth"/);
  assert.match(configuracao, /block: "center"/);
  assert.match(configuracao, /campoHoras\.focus\(\{ preventScroll: true \}\)/);
  assert.equal(
    configuracao.indexOf("setCursoSelecionado(id)"),
    configuracao.lastIndexOf("setCursoSelecionado(id)"),
  );
  assert.match(configuracao, /supabase\.rpc\("configurar_curso_usuario"/);
});

test("card de estatísticas do painel usa o formato semanal com dados reais", () => {
  assert.match(painel, /import \{ WeeklyStatsCard \}/);
  assert.match(painel, /return <WeeklyStatsCard key=\{access\.href\} \/>/);
  assert.match(weeklyStats, /\.rpc\("estatisticas_do_curso_ativo"\)/);
  assert.match(weeklyStats, /sessao\.status === "concluida"/);
  assert.match(weeklyStats, /sessao\.questoes_respondidas/);
  assert.match(weeklyStats, /sessao\.acertos/);
  assert.match(weeklyStats, /Visão da semana/);
  assert.match(weeklyStats, /papiro-stats-quick-card__line/);
  assert.match(weeklyStats, /papiro-stats-quick-card__point/);
  assert.match(weeklyStats, /papiro-stats-quick-card__day/);
  assert.match(weeklyStats, /setDiaSelecionado/);
  assert.match(weeklyStats, /setDiaDestacado/);
  assert.match(weeklyStats, /onPointerEnter/);
  assert.match(weeklyStats, /onFocus/);
  assert.match(weeklyStats, /onKeyDown/);
  assert.match(weeklyStats, /role="button"/);
  assert.match(weeklyStats, /papiro-stats-quick-card__tooltip/);
  assert.match(weeklyStats, /grafico\.total/);
  assert.doesNotMatch(weeklyStats, /Horas de estudo/i);
  assert.match(
    styles,
    /\.papiro-stats-quick-card\s*\{[^}]*height:\s*196px/s,
  );
  assert.match(
    styles,
    /\.papiro-quick-grid\s*\{[^}]*grid-template-columns:\s*repeat\(3,\s*minmax\(0,\s*1fr\)\)/s,
  );
  assert.match(styles, /\.papiro-quick-card\s*\{[^}]*height:\s*196px/s);
  assert.match(
    styles,
    /\.papiro-stats-quick-card__line\s*\{[^}]*stroke:\s*var\(--papiro-color-brand-gold\)/s,
  );
  assert.match(styles, /@keyframes papiro-weekly-line-in/);
  assert.match(styles, /\.papiro-stats-quick-card__active-ring/);
});

test("IBM Plex Sans fica restrita ao layout aninhado do painel", () => {
  assert.doesNotMatch(rootLayout, /IBM_Plex_Sans/);
  assert.doesNotMatch(rootLayout, /--font-ibm-plex-sans/);
  assert.match(painelLayout, /IBM_Plex_Sans/);
  assert.match(painelLayout, /variable: "--font-ibm-plex-sans"/);
  assert.match(painelLayout, /weight: "variable"/);
  assert.match(painelLayout, /import "\.\/painel\.css"/);
  assert.match(painel, /useState<FontCandidate>\("geist"\)/);
  assert.match(painel, /aria-label="Comparação tipográfica"/);
  assert.match(painel, /function formatarNomeNatural\(/);
  assert.match(styles, /\.papiro-next\[data-font="plex"\]/);
  assert.match(styles, /--papiro-font-ui: var\(--font-ibm-plex-sans\)/);
});

test("StudentAppShell usa apenas navegação real e preserva o drawer acessível", () => {
  assert.match(shell, /<strong>PAPIRO<\/strong>/);
  assert.match(shell, /<small>PREPARAÇÃO POLICIAL<\/small>/);
  assert.doesNotMatch(shell, /Estudo orientado/);
  assert.doesNotMatch(
    styles,
    /\.papiro-shell-mobile-header \.papiro-shell-brand__copy small\s*\{[^}]*display:\s*none/s,
  );
  assert.ok(
    shell.indexOf('className="papiro-shell-account"') <
      shell.indexOf('className="papiro-shell-navigation__scroll"'),
  );
  assert.match(
    styles,
    /\.papiro-shell-account__popover\s*\{[^}]*top:\s*calc\(100% \+ 9px\);[^}]*bottom:\s*auto/s,
  );

  for (const href of [
    "/painel",
    "/cronograma",
    "/questoes",
    "/caderno-de-erros",
    "/estatisticas",
    "/editais",
    "/configuracao",
    "/admin",
  ]) {
    assert.match(shell, new RegExp(`"${href}"`));
  }

  assert.doesNotMatch(shell, /href: "#objetivos"/);
  assert.doesNotMatch(painel, /papiro-objective-list/);
  assert.doesNotMatch(painel, /Seus objetivos|Editar objetivos/);
  assert.match(painel, /Objetivo cadastrado/);
  assert.doesNotMatch(painel, /Objetivo ativo/);
  assert.match(shell, /aria-current=\{active \? "page" : undefined\}/);
  assert.match(shell, /aria-controls="papiro-mobile-navigation"/);
  assert.match(shell, /aria-expanded=\{menuOpen\}/);
  assert.match(shell, /aria-haspopup="menu"/);
  assert.match(shell, /aria-expanded=\{accountOpen\}/);
  assert.match(shell, /role="menu"/);
  assert.match(shell, /role="menuitem"/);
  assert.match(shell, /event\.key !== "ArrowDown"/);
  assert.match(shell, /event\.key !== "ArrowUp"/);
  assert.match(shell, /focusAccountItem/);
  assert.match(shell, /papiro-shell-user__bend/);
  assert.match(shell, /M2 4C6 8 6 16 2 20/);
  assert.match(shell, />Ajustar objetivo</);
  assert.match(shell, />Meus editais</);
  assert.match(shell, /accountButtonRef\.current\?\.focus\(\)/);
  assert.match(painel, /userEmail=\{email\}/);
  assert.match(shell, /role="dialog"/);
  assert.match(shell, /aria-modal="true"/);
  assert.match(shell, /event\.key === "Escape"/);
  assert.match(shell, /event\.key !== "Tab"/);
  assert.match(shell, /opener\?\.focus\(\)/);
  assert.match(shell, /inert=\{menuOpen \|\| undefined\}/);
  assert.match(shell, /Pular para o conteúdo/);
  assert.match(shell, /papiro-shell-navigation__glow/);
  assert.match(shell, /moveNavigationGlow/);
  assert.match(shell, /restoreNavigationGlow/);
  assert.match(shell, /onPointerEnter/);
  assert.match(shell, /onFocus/);
  assert.match(styles, /\.papiro-shell-navigation__glow\s*\{/);
  assert.match(
    styles,
    /\.papiro-shell-navigation__glow\[data-visible="true"\]/,
  );
  assert.match(styles, /--papiro-navigation-glow-y/);
  assert.match(styles, /drop-shadow\(0 0 7px/);
});

test("logos principais compartilham o mesmo movimento de marca", () => {
  assert.match(homeHeader, /className=\{styles\.brandMark\}/);
  assert.match(shell, /className="papiro-shell-brand__mark"/);
  assert.match(homeStyles, /\.brand:hover \.brandMark/);
  assert.match(homeStyles, /rotate\(45deg\) scale\(1\.08\)/);
  assert.match(styles, /\.papiro-shell-brand:hover \.papiro-shell-brand__mark/);
  assert.match(styles, /rotate\(45deg\) scale\(1\.08\)/);
});

test("marca compacta fica menor e centralizada no cabeçalho", () => {
  assert.match(
    styles,
    /\.papiro-shell-sidebar \.papiro-shell-brand,[\s\S]*?align-self: center;[\s\S]*?translate: 30px -8px;/,
  );
  assert.match(
    styles,
    /\.papiro-shell-sidebar \.papiro-shell-brand__mark,[\s\S]*?width: 32px;[\s\S]*?height: 32px;[\s\S]*?flex-basis: 32px;/,
  );
  assert.match(styles, /\.papiro-shell-sidebar \.papiro-shell-brand__mark b\s*\{[^}]*font-size: 18px;/s);
  assert.match(styles, /transform: rotate\(-45deg\);/);
});

test("Button e Surface preservam os contratos aprovados", () => {
  for (const variant of [
    "primary",
    "secondary",
    "outline",
    "ghost",
    "danger",
    "icon",
  ]) {
    assert.match(button, new RegExp(`\\| "${variant}"|= "${variant}"`));
  }

  for (const size of ["sm", "md", "lg"]) {
    assert.match(button, new RegExp(`\\| "${size}"|= "${size}"`));
  }

  assert.match(button, /aria-busy=\{loading \|\| undefined\}/);
  assert.match(button, /disabled=\{indisponivel\}/);
  assert.match(surface, /"canvas" \| "base" \| "raised" \| "overlay"/);
  assert.match(surface, /"none" \| "subtle" \| "strong"/);
});

test("CSS V2 permanece isolado e materializa a direção aprovada", () => {
  const semComentarios = styles.replace(/\/\*[\s\S]*?\*\//g, "");

  assert.match(semComentarios, /\.papiro-next \{/);
  assert.match(semComentarios, /grid-template-columns: 272px minmax\(0, 1fr\)/);
  assert.match(
    semComentarios,
    /@media \(min-width: 1024px\) and \(hover: hover\)[\s\S]*grid-template-columns: 78px minmax\(0, 1fr\)/,
  );
  assert.match(shell, /data-label=\{item\.label\}/);
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar,\s*\.papiro-shell-sidebar:hover,\s*\.papiro-shell-sidebar:focus-within\s*\{[^}]*width: 78px/s,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-navigation__scroll,[\s\S]*?width: 52px;[\s\S]*?border: 0;[\s\S]*?background: transparent;[\s\S]*?box-shadow: none;/,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-navigation__scroll,[\s\S]*top: 50%;[\s\S]*left: calc\(50% \+ 30px\);[\s\S]*transform: translate\(-50%, -50%\)/,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-navigation__link\s*\{[^}]*width: 42px;[^}]*border-radius: 50%/s,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-navigation__link > span\s*\{[^}]*max-width: 0;[^}]*flex: 0 0 0/,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-user\s*\{[^}]*width: 42px;[^}]*border-radius: 50%/s,
  );
  assert.match(
    semComentarios,
    /content: attr\(data-label\)/,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-account__popover\s*\{[^}]*top: calc\(100% \+ 10px\);[^}]*right: 0;[^}]*width: 228px/s,
  );
  assert.match(
    semComentarios,
    /\.papiro-shell-sidebar \.papiro-shell-account,[\s\S]*position: fixed;[\s\S]*top: 18px;[\s\S]*right: 28px/,
  );
  assert.match(
    semComentarios,
    /\.papiro-panel-topbar\s*\{[^}]*padding-right: 250px/,
  );
  assert.match(semComentarios, /overflow-x: hidden/);
  assert.match(semComentarios, /--papiro-color-brand-gold: #d7b35a/);
  assert.match(semComentarios, /--papiro-color-success: #45d483/);
  assert.match(semComentarios, /\.papiro-shell-navigation__link\[aria-current="page"\]/);
  assert.match(semComentarios, /\.papiro-focus-card \{/);
  assert.match(semComentarios, /\.papiro-quick-grid \{/);
  assert.match(
    semComentarios,
    /\.papiro-quick-grid\s*\{[^}]*grid-template-columns:\s*repeat\(3,\s*minmax\(0,\s*1fr\)\)/s,
  );
  assert.match(semComentarios, /box-shadow:/);
  assert.doesNotMatch(semComentarios, /\.dashboard-/);
  assert.doesNotMatch(semComentarios, /!important/);
  assert.doesNotMatch(semComentarios, /(?:linear|radial)-gradient/);
  assert.doesNotMatch(semComentarios, /url\(/);
  assert.match(semComentarios, /prefers-reduced-motion: reduce/);
  assert.match(semComentarios, /:focus-visible/);
});

test("Lucide é a única biblioteca de ícones e usa imports controlados", () => {
  assert.match(packageJson, /"lucide-react": "\^1\.33\.0"/);
  assert.match(packageLock, /"node_modules\/lucide-react"/);
  assert.match(shell, /from "lucide-react"/);
  assert.match(painel, /from "lucide-react"/);
  assert.doesNotMatch(`${shell}\n${painel}`, /import\s+\*\s+as/);
  assert.doesNotMatch(`${shell}\n${painel}`, /dynamicIconImports|\bicons\b/);
  assert.doesNotMatch(packageJson, /heroicons|react-icons|fontawesome/i);
  assert.match(shell, /aria-label="Abrir menu"/);
  assert.match(shell, /aria-label="Fechar menu"/);
  assert.match(`${shell}\n${painel}`, /aria-hidden="true"/);
});
