export default function MarcaCarregando({ texto = "Carregando..." }: { texto?: string }) {
  return (
    <div className="marca-carregando" role="status" aria-live="polite" aria-atomic="true">
      <span className="brand-mark marca-carregando-simbolo" aria-hidden="true"><span>P</span></span>
      <span className="marca-carregando-texto">{texto}</span>
    </div>
  );
}
