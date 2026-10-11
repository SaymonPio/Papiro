export type CursoDisponivel = {
  id: string;
  carreira: string;
  concurso: string;
  cargo: string;
  banca: string;
  dataProva: string;
  dataExibicao: string;
  imagem: string;
  previsao: boolean;
};

export const cursosDisponiveis: CursoDisponivel[] = [
  {
    id: "86d06052-d21d-4e2e-b7ef-d6cfab169185",
    carreira: "Guarda Municipal",
    concurso: "Guarda Municipal de Alvorada",
    cargo: "Guarda Municipal",
    banca: "Fundatec",
    dataProva: "2026-11-15",
    dataExibicao: "15/11/2026",
    imagem: "/cursos/gm-alvorada.png",
    previsao: true,
  },
  {
    id: "7543be16-4c5b-4cb6-8724-8fbdfb96f2d4",
    carreira: "Polícia Militar",
    concurso: "Brigada Militar do Rio Grande do Sul",
    cargo: "Soldado de Primeira Classe",
    banca: "Fundatec",
    dataProva: "2027-03-14",
    dataExibicao: "14/03/2027",
    imagem: "/cursos/brigada-militar-rs.png",
    previsao: true,
  },
];

function normalizarIdentificador(valor: string) {
  return valor
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim()
    .toLocaleLowerCase("pt-BR");
}

export function encontrarCursoPorObjetivo(concurso: string, cargo: string) {
  const concursoNormalizado = normalizarIdentificador(concurso);
  const cargoNormalizado = normalizarIdentificador(cargo);

  return (
    cursosDisponiveis.find(
      (curso) =>
        normalizarIdentificador(curso.concurso) === concursoNormalizado &&
        normalizarIdentificador(curso.cargo) === cargoNormalizado,
    ) ??
    cursosDisponiveis.find(
      (curso) =>
        normalizarIdentificador(curso.concurso) === concursoNormalizado,
    )
  );
}
