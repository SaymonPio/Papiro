"use client";

import Link from "next/link";
import {
  CalendarDays,
  ChartNoAxesColumnIncreasing,
  FileUp,
  LayoutDashboard,
  ListChecks,
  LogOut,
  Menu,
  NotebookTabs,
  Shield,
  Target,
  X,
  type LucideIcon,
} from "lucide-react";
import {
  useCallback,
  useEffect,
  useId,
  useRef,
  useState,
  type CSSProperties,
  type KeyboardEvent as ReactKeyboardEvent,
  type ReactNode,
  type RefObject,
} from "react";

type FontCandidate = "geist" | "plex";

type StudentAppShellProps = {
  children: ReactNode;
  currentHref: string;
  fontCandidate: FontCandidate;
  userEmail?: string;
  userName: string;
  onSignOut: () => void | Promise<void>;
};

type NavigationProps = {
  currentHref: string;
  onNavigate?: () => void;
  onSignOut: () => void | Promise<void>;
  userEmail?: string;
  userName: string;
};

type NavigationItem = {
  href: string;
  icon: LucideIcon;
  label: string;
};

const navigationGroups: Array<{
  label: string;
  items: NavigationItem[];
}> = [
  {
    label: "Estudo",
    items: [
      { href: "/painel", icon: LayoutDashboard, label: "Visão geral" },
      { href: "/cronograma", icon: CalendarDays, label: "Cronograma" },
      { href: "/questoes", icon: ListChecks, label: "Questões" },
      {
        href: "/caderno-de-erros",
        icon: NotebookTabs,
        label: "Caderno de erros",
      },
      {
        href: "/estatisticas",
        icon: ChartNoAxesColumnIncreasing,
        label: "Estatísticas",
      },
    ],
  },
  {
    label: "Planejamento",
    items: [{ href: "/editais", icon: FileUp, label: "Enviar edital" }],
  },
];

function Brand() {
  return (
    <Link className="papiro-shell-brand" href="/" aria-label="Papiro — início">
      <span className="papiro-shell-brand__mark" aria-hidden="true">
        <b>P</b>
      </span>
      <span className="papiro-shell-brand__copy">
        <strong>PAPIRO</strong>
        <small>PREPARAÇÃO POLICIAL</small>
      </span>
    </Link>
  );
}

function NavigationLink({
  currentHref,
  item,
  onGlowTarget,
  onNavigate,
}: {
  currentHref: string;
  item: NavigationItem;
  onGlowTarget?: (element: HTMLAnchorElement) => void;
  onNavigate?: () => void;
}) {
  const active = currentHref === item.href;
  const Icon = item.icon;

  return (
    <Link
      className="papiro-shell-navigation__link"
      data-label={item.label}
      href={item.href}
      aria-current={active ? "page" : undefined}
      onFocus={(event) => onGlowTarget?.(event.currentTarget)}
      onPointerEnter={(event) => onGlowTarget?.(event.currentTarget)}
      onClick={onNavigate}
    >
      <Icon aria-hidden="true" size={20} strokeWidth={1.8} />
      <span>{item.label}</span>
    </Link>
  );
}

function UserSummary({
  accountOpen,
  menuId,
  onKeyDown,
  onToggle,
  triggerRef,
  userEmail,
  userName,
}: {
  accountOpen: boolean;
  menuId: string;
  onKeyDown: (event: ReactKeyboardEvent<HTMLButtonElement>) => void;
  onToggle: () => void;
  triggerRef: RefObject<HTMLButtonElement | null>;
  userEmail?: string;
  userName: string;
}) {
  const initial = userName.trim().charAt(0).toLocaleUpperCase("pt-BR") || "A";

  return (
    <button
      ref={triggerRef}
      className="papiro-shell-user"
      type="button"
      aria-label={`${accountOpen ? "Fechar" : "Abrir"} menu da conta de ${userName}`}
      aria-controls={menuId}
      aria-expanded={accountOpen}
      aria-haspopup="menu"
      onKeyDown={onKeyDown}
      onClick={onToggle}
    >
      <span className="papiro-shell-user__copy">
        <strong>{userName}</strong>
        <small>{userEmail || "Conta conectada"}</small>
      </span>
      <span className="papiro-shell-user__avatar" aria-hidden="true">
        {initial}
      </span>
      <span
        className="papiro-shell-user__bend"
        data-open={accountOpen || undefined}
        aria-hidden="true"
      >
        <svg fill="none" viewBox="0 0 12 24">
          <path
            d="M2 4C6 8 6 16 2 20"
            fill="none"
            stroke="currentColor"
            strokeLinecap="round"
            strokeWidth="1.5"
          />
        </svg>
      </span>
    </button>
  );
}

function Navigation({
  currentHref,
  onNavigate,
  onSignOut,
  userEmail,
  userName,
}: NavigationProps) {
  const [accountOpen, setAccountOpen] = useState(false);
  const accountRef = useRef<HTMLDivElement>(null);
  const accountButtonRef = useRef<HTMLButtonElement>(null);
  const accountMenuRef = useRef<HTMLDivElement>(null);
  const navigationScrollRef = useRef<HTMLDivElement>(null);
  const accountMenuId = useId();
  const [navigationGlow, setNavigationGlow] = useState({
    height: 42,
    top: 0,
    visible: false,
  });

  const moveNavigationGlow = useCallback((element: HTMLAnchorElement) => {
    const container = navigationScrollRef.current;
    if (!container) return;

    const containerRect = container.getBoundingClientRect();
    const elementRect = element.getBoundingClientRect();

    setNavigationGlow({
      height: elementRect.height,
      top: elementRect.top - containerRect.top + container.scrollTop,
      visible: true,
    });
  }, []);

  const restoreNavigationGlow = useCallback(() => {
    const activeLink = navigationScrollRef.current?.querySelector<HTMLAnchorElement>(
      '[aria-current="page"]',
    );

    if (activeLink) {
      moveNavigationGlow(activeLink);
      return;
    }

    setNavigationGlow((current) => ({ ...current, visible: false }));
  }, [moveNavigationGlow]);

  useEffect(() => {
    const frame = window.requestAnimationFrame(restoreNavigationGlow);
    window.addEventListener("resize", restoreNavigationGlow);

    return () => {
      window.cancelAnimationFrame(frame);
      window.removeEventListener("resize", restoreNavigationGlow);
    };
  }, [currentHref, restoreNavigationGlow]);

  useEffect(() => {
    if (!accountOpen) return;

    function handlePointerDown(event: PointerEvent) {
      if (
        event.target instanceof Node &&
        !accountRef.current?.contains(event.target)
      ) {
        setAccountOpen(false);
      }
    }

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key !== "Escape") return;
      event.preventDefault();
      setAccountOpen(false);
      accountButtonRef.current?.focus();
    }

    document.addEventListener("pointerdown", handlePointerDown);
    document.addEventListener("keydown", handleKeyDown);

    return () => {
      document.removeEventListener("pointerdown", handlePointerDown);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [accountOpen]);

  function handleAccountNavigation() {
    setAccountOpen(false);
    onNavigate?.();
  }

  function focusAccountItem(edge: "first" | "last") {
    requestAnimationFrame(() => {
      const items = accountMenuRef.current?.querySelectorAll<HTMLElement>(
        '[role="menuitem"]',
      );
      if (!items?.length) return;
      items[edge === "first" ? 0 : items.length - 1]?.focus();
    });
  }

  function handleAccountTriggerKeyDown(
    event: ReactKeyboardEvent<HTMLButtonElement>,
  ) {
    if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
    event.preventDefault();
    setAccountOpen(true);
    focusAccountItem(event.key === "ArrowDown" ? "first" : "last");
  }

  function handleAccountMenuKeyDown(
    event: ReactKeyboardEvent<HTMLDivElement>,
  ) {
    if (!["ArrowDown", "ArrowUp", "Home", "End"].includes(event.key)) return;

    const items = Array.from(
      accountMenuRef.current?.querySelectorAll<HTMLElement>(
        '[role="menuitem"]',
      ) ?? [],
    );
    if (!items.length) return;

    event.preventDefault();
    const currentIndex = items.indexOf(document.activeElement as HTMLElement);
    let nextIndex = currentIndex;

    if (event.key === "Home") nextIndex = 0;
    if (event.key === "End") nextIndex = items.length - 1;
    if (event.key === "ArrowDown") {
      nextIndex = currentIndex < items.length - 1 ? currentIndex + 1 : 0;
    }
    if (event.key === "ArrowUp") {
      nextIndex = currentIndex > 0 ? currentIndex - 1 : items.length - 1;
    }

    items[nextIndex]?.focus();
  }

  return (
    <div className="papiro-shell-navigation">
      <div ref={accountRef} className="papiro-shell-account">
        {accountOpen ? (
          <div
            ref={accountMenuRef}
            id={accountMenuId}
            className="papiro-shell-account__popover"
            role="menu"
            aria-label="Opções da conta"
            onKeyDown={handleAccountMenuKeyDown}
          >
            <Link
              className="papiro-shell-account__action"
              href="/painel"
              role="menuitem"
              onClick={handleAccountNavigation}
            >
              <LayoutDashboard aria-hidden="true" size={17} strokeWidth={1.8} />
              <span>Visão geral</span>
            </Link>
            <Link
              className="papiro-shell-account__action"
              href="/configuracao"
              role="menuitem"
              onClick={handleAccountNavigation}
            >
              <Target aria-hidden="true" size={17} strokeWidth={1.8} />
              <span>Ajustar objetivo</span>
            </Link>
            <Link
              className="papiro-shell-account__action"
              href="/editais"
              role="menuitem"
              onClick={handleAccountNavigation}
            >
              <FileUp aria-hidden="true" size={17} strokeWidth={1.8} />
              <span>Meus editais</span>
            </Link>
            <div className="papiro-shell-account__separator" aria-hidden="true" />
            <button
              className="papiro-shell-account__action papiro-shell-account__sign-out"
              type="button"
              role="menuitem"
              onClick={() => {
                setAccountOpen(false);
                void onSignOut();
              }}
            >
              <LogOut aria-hidden="true" size={17} strokeWidth={1.8} />
              <span>Sair</span>
            </button>
          </div>
        ) : null}

        <UserSummary
          accountOpen={accountOpen}
          menuId={accountMenuId}
          onKeyDown={handleAccountTriggerKeyDown}
          onToggle={() => setAccountOpen((open) => !open)}
          triggerRef={accountButtonRef}
          userEmail={userEmail}
          userName={userName}
        />
      </div>

      <div
        ref={navigationScrollRef}
        className="papiro-shell-navigation__scroll"
        onPointerLeave={restoreNavigationGlow}
        onBlur={(event) => {
          if (
            event.relatedTarget instanceof Node &&
            event.currentTarget.contains(event.relatedTarget)
          ) {
            return;
          }

          restoreNavigationGlow();
        }}
      >
        <span
          className="papiro-shell-navigation__glow"
          data-visible={navigationGlow.visible || undefined}
          style={
            {
              "--papiro-navigation-glow-height": `${navigationGlow.height}px`,
              "--papiro-navigation-glow-y": `${navigationGlow.top}px`,
            } as CSSProperties
          }
          aria-hidden="true"
        />
        <div className="papiro-shell-navigation__main">
          {navigationGroups.map((group) => (
            <nav key={group.label} aria-label={group.label}>
              <p className="papiro-shell-navigation__label">{group.label}</p>
              <div className="papiro-shell-navigation__items">
                {group.items.map((item) => (
                  <NavigationLink
                    key={item.href}
                    currentHref={currentHref}
                    item={item}
                    onGlowTarget={moveNavigationGlow}
                    onNavigate={onNavigate}
                  />
                ))}
              </div>
            </nav>
          ))}
        </div>

        <nav
          className="papiro-shell-navigation__management"
          aria-label="Administração"
        >
          <p className="papiro-shell-navigation__label">Gestão</p>
          <NavigationLink
            currentHref={currentHref}
            item={{ href: "/admin", icon: Shield, label: "Administração" }}
            onGlowTarget={moveNavigationGlow}
            onNavigate={onNavigate}
          />
        </nav>
      </div>

    </div>
  );
}

export function StudentAppShell({
  children,
  currentHref,
  fontCandidate,
  userEmail,
  userName,
  onSignOut,
}: StudentAppShellProps) {
  const [menuOpen, setMenuOpen] = useState(false);
  const closeButtonRef = useRef<HTMLButtonElement>(null);
  const drawerRef = useRef<HTMLElement>(null);
  const openerRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!menuOpen) return;

    const previousOverflow = document.body.style.overflow;
    const opener = openerRef.current;
    document.body.style.overflow = "hidden";
    closeButtonRef.current?.focus();

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        event.preventDefault();
        setMenuOpen(false);
        return;
      }

      if (event.key !== "Tab" || !drawerRef.current) return;

      const focusable = Array.from(
        drawerRef.current.querySelectorAll<HTMLElement>(
          'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])',
        ),
      );

      if (focusable.length === 0) return;

      const first = focusable[0];
      const last = focusable[focusable.length - 1];

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener("keydown", handleKeyDown);

    return () => {
      document.body.style.overflow = previousOverflow;
      document.removeEventListener("keydown", handleKeyDown);
      opener?.focus();
    };
  }, [menuOpen]);

  function closeMenu() {
    setMenuOpen(false);
  }

  return (
    <main className="papiro-next" data-font={fontCandidate}>
      <a className="papiro-skip-link" href="#conteudo-principal">
        Pular para o conteúdo
      </a>

      <aside className="papiro-shell-sidebar" aria-label="Menu do aluno">
        <Brand />
        <Navigation
          currentHref={currentHref}
          onSignOut={onSignOut}
          userEmail={userEmail}
          userName={userName}
        />
      </aside>

      <header className="papiro-shell-mobile-header">
        <Brand />
        <button
          ref={openerRef}
          className="papiro-shell-menu-button"
          type="button"
          aria-label="Abrir menu"
          aria-controls="papiro-mobile-navigation"
          aria-expanded={menuOpen}
          onClick={() => setMenuOpen(true)}
        >
          <Menu aria-hidden="true" size={19} strokeWidth={1.9} />
          <span>Menu</span>
        </button>
      </header>

      {menuOpen ? (
        <>
          <button
            className="papiro-shell-backdrop"
            type="button"
            aria-label="Fechar menu"
            tabIndex={-1}
            onClick={closeMenu}
          />
          <aside
            ref={drawerRef}
            id="papiro-mobile-navigation"
            className="papiro-shell-drawer"
            role="dialog"
            aria-modal="true"
            aria-label="Menu do aluno"
          >
            <div className="papiro-shell-drawer__header">
              <Brand />
              <button
                ref={closeButtonRef}
                className="papiro-shell-close-button"
                type="button"
                aria-label="Fechar menu"
                onClick={closeMenu}
              >
                <X aria-hidden="true" size={20} strokeWidth={1.9} />
              </button>
            </div>
            <Navigation
              currentHref={currentHref}
              onNavigate={closeMenu}
              onSignOut={onSignOut}
              userEmail={userEmail}
              userName={userName}
            />
          </aside>
        </>
      ) : null}

      <div
        className="papiro-shell-content"
        aria-hidden={menuOpen || undefined}
        inert={menuOpen || undefined}
      >
        {children}
      </div>
    </main>
  );
}
