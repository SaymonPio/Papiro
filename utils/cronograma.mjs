/**
 * Monta uma janela que cobre cada matéria disponível antes de usar as vagas
 * restantes para repetir as matérias mais prioritárias.
 *
 * @template {{ materiaId: number, prioridade: number, frequenciaHistorica: number | null }} T
 * @param {T[]} filaGlobal
 * @param {T[]} itensPriorizados
 * @param {number} ancora
 * @param {number} tamanho
 * @returns {T[]}
 */
export function montarJanelaSemanal(filaGlobal, itensPriorizados, ancora, tamanho = 7) {
  if (tamanho <= 0 || itensPriorizados.length === 0) return [];

  const porMateria = new Map();

  itensPriorizados.forEach((item) => {
    const grupo = porMateria.get(item.materiaId) ?? [];
    grupo.push(item);
    porMateria.set(item.materiaId, grupo);
  });

  const grupos = [...porMateria.entries()]
    .map(([materiaId, itens]) => ({
      materiaId,
      itens,
      prioridade: Math.max(...itens.map((item) => item.prioridade)),
      frequencia: Math.max(...itens.map((item) => Number(item.frequenciaHistorica ?? 0))),
    }))
    .sort((a, b) => b.prioridade - a.prioridade || b.frequencia - a.frequencia);

  const ciclo = Math.floor(Math.max(0, ancora) / tamanho);
  const repeticoesPorMateria = new Map();

  const escolherItem = (grupo) => {
    const repeticao = repeticoesPorMateria.get(grupo.materiaId) ?? 0;
    const raia = filaGlobal.filter((item) => item.materiaId === grupo.materiaId);
    const candidatos = raia.length > 0 ? raia : grupo.itens;
    const escolhido = candidatos[(ciclo + repeticao) % candidatos.length];
    repeticoesPorMateria.set(grupo.materiaId, repeticao + 1);
    return escolhido;
  };

  // Com até sete matérias relevantes, todas recebem uma vaga. Se houver mais,
  // a limitação de um bloco principal por dia mantém as sete mais prioritárias.
  const selecionados = grupos.slice(0, tamanho).map(escolherItem);

  // As vagas restantes voltam às matérias mais prioritárias, uma por vez.
  for (let indice = selecionados.length; indice < tamanho; indice += 1) {
    selecionados.push(escolherItem(grupos[(indice - grupos.length) % grupos.length]));
  }

  return selecionados;
}
