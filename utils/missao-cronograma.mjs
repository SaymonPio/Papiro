const inteiroPositivo = (valor) => {
  const numero = Number(valor);
  return Number.isInteger(numero) && numero > 0 ? numero : null;
};

export function montarLinkMissao({
  cursoMateriaId,
  conteudoId,
  materiaId,
  assuntoId,
  quantidade = 10,
}) {
  if (!materiaId) return "/questoes";

  const parametros = new URLSearchParams({
    origem: "cronograma",
    materia: String(materiaId),
    quantidade: String(Math.max(1, Math.min(100, quantidade))),
  });

  if (assuntoId) parametros.set("assunto", String(assuntoId));
  if (cursoMateriaId) parametros.set("cursoMateria", String(cursoMateriaId));
  if (conteudoId) parametros.set("conteudo", String(conteudoId));

  return `/questoes?${parametros.toString()}`;
}

export function lerMissaoCronograma(busca) {
  const parametros = new URLSearchParams(busca);
  if (parametros.get("origem") !== "cronograma") return null;

  const materiaId = inteiroPositivo(parametros.get("materia"));
  if (!materiaId) return null;

  return {
    materiaId,
    assuntoId: inteiroPositivo(parametros.get("assunto")),
    cursoMateriaId: inteiroPositivo(parametros.get("cursoMateria")),
    conteudoId: inteiroPositivo(parametros.get("conteudo")),
    quantidade: inteiroPositivo(parametros.get("quantidade")) ?? 10,
  };
}
