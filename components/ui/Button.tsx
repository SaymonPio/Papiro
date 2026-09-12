import Link from "next/link";
import type {
  ButtonHTMLAttributes,
  ComponentProps,
  ReactNode,
} from "react";

export type ButtonVariant =
  | "primary"
  | "secondary"
  | "outline"
  | "ghost"
  | "danger"
  | "icon";

export type ButtonSize = "sm" | "md" | "lg";

type ButtonVisualProps = {
  variant?: ButtonVariant;
  size?: ButtonSize;
  leadingIcon?: ReactNode;
  trailingIcon?: ReactNode;
  fullWidth?: boolean;
};

export type ButtonProps = ButtonVisualProps &
  Omit<ButtonHTMLAttributes<HTMLButtonElement>, "children"> & {
    children: ReactNode;
    loading?: boolean;
  };

export type ButtonLinkProps = ButtonVisualProps &
  Omit<ComponentProps<typeof Link>, "children"> & {
    children: ReactNode;
  };

function classes(
  variant: ButtonVariant,
  size: ButtonSize,
  fullWidth: boolean,
  className?: string,
) {
  return [
    "papiro-button",
    `papiro-button--${variant}`,
    `papiro-button--${size}`,
    fullWidth ? "papiro-button--full" : "",
    className ?? "",
  ]
    .filter(Boolean)
    .join(" ");
}

function ButtonContent({
  children,
  leadingIcon,
  trailingIcon,
  loading = false,
}: {
  children: ReactNode;
  leadingIcon?: ReactNode;
  trailingIcon?: ReactNode;
  loading?: boolean;
}) {
  return (
    <>
      {loading ? (
        <span className="papiro-button__spinner" aria-hidden="true" />
      ) : leadingIcon ? (
        <span className="papiro-button__icon" aria-hidden="true">
          {leadingIcon}
        </span>
      ) : null}
      <span className="papiro-button__label">{children}</span>
      {!loading && trailingIcon ? (
        <span className="papiro-button__icon" aria-hidden="true">
          {trailingIcon}
        </span>
      ) : null}
    </>
  );
}

export function Button({
  children,
  variant = "primary",
  size = "md",
  leadingIcon,
  trailingIcon,
  fullWidth = false,
  loading = false,
  disabled = false,
  className,
  type = "button",
  ...props
}: ButtonProps) {
  const indisponivel = disabled || loading;

  return (
    <button
      {...props}
      type={type}
      className={classes(variant, size, fullWidth, className)}
      disabled={indisponivel}
      aria-busy={loading || undefined}
    >
      <ButtonContent
        leadingIcon={leadingIcon}
        trailingIcon={trailingIcon}
        loading={loading}
      >
        {children}
      </ButtonContent>
    </button>
  );
}

export function ButtonLink({
  children,
  variant = "primary",
  size = "md",
  leadingIcon,
  trailingIcon,
  fullWidth = false,
  className,
  ...props
}: ButtonLinkProps) {
  return (
    <Link
      {...props}
      className={classes(variant, size, fullWidth, className)}
    >
      <ButtonContent
        leadingIcon={leadingIcon}
        trailingIcon={trailingIcon}
      >
        {children}
      </ButtonContent>
    </Link>
  );
}
