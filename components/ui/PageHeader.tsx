import type { ReactNode } from "react";

type PageHeaderProps = {
  eyebrow?: string;
  title: ReactNode;
  description?: ReactNode;
  status?: ReactNode;
  actions?: ReactNode;
};

export function PageHeader({
  eyebrow,
  title,
  description,
  status,
  actions,
}: PageHeaderProps) {
  return (
    <header className="papiro-page-header">
      <div className="papiro-page-header__copy">
        {eyebrow ? <p className="papiro-eyebrow">{eyebrow}</p> : null}
        <h1>{title}</h1>
        {description ? (
          <p className="papiro-page-header__description">{description}</p>
        ) : null}
      </div>
      {status || actions ? (
        <div className="papiro-page-header__tools">
          {status}
          {actions}
        </div>
      ) : null}
    </header>
  );
}
