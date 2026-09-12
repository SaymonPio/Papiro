import type { HTMLAttributes } from "react";

export type SurfaceLevel = "canvas" | "base" | "raised" | "overlay";
export type SurfacePadding = "none" | "sm" | "md" | "lg";
export type SurfaceBorder = "none" | "subtle" | "strong";
export type SurfaceRadius = "none" | "sm" | "md" | "lg";

type SurfaceElement = "div" | "section" | "article" | "aside";

export type SurfaceProps = HTMLAttributes<HTMLElement> & {
  as?: SurfaceElement;
  level?: SurfaceLevel;
  padding?: SurfacePadding;
  border?: SurfaceBorder;
  radius?: SurfaceRadius;
};

export function Surface({
  as: Tag = "div",
  level = "base",
  padding = "md",
  border = "subtle",
  radius = "md",
  className,
  ...props
}: SurfaceProps) {
  const classes = [
    "papiro-surface",
    `papiro-surface--${level}`,
    `papiro-surface--padding-${padding}`,
    `papiro-surface--border-${border}`,
    `papiro-surface--radius-${radius}`,
    className ?? "",
  ]
    .filter(Boolean)
    .join(" ");

  return <Tag {...props} className={classes} />;
}
