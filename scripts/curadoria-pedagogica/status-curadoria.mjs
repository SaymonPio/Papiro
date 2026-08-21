#!/usr/bin/env node
// Relatório visual de progresso da fila de curadoria pedagógica — leitura
// 100% local de config/ordem-curadoria.json, NUNCA toca o Supabase (ao
// contrário de auditar-geral.mjs).
//
// Uso: node status-curadoria.mjs

import { lerJson, caminhoOrdemCuradoria, validarOrdemCuradoria } from "./lib/comum.mjs";

const fila = lerJson(caminhoOrdemCuradoria());
validarOrdemCuradoria(fila);

const ordenada = [...fila].sort((a, b) => a.ordem - b.ordem);
const concluidos = ordenada.filter((i) => i.status === "concluido");
const pendentes = ordenada.filter((i) => i.status === "pendente");
const percentual = ((concluidos.length / ordenada.length) * 100).toFixed(1).replace(".", ",");

console.log("================================");
console.log("CURADORIA PAPIRO");
console.log("================================");
console.log("");
console.log("Concluídos:");
for (const item of concluidos) {
  console.log(`✅ ${item.nome}`);
}
console.log("");
console.log("Pendentes:");
for (const item of pendentes) {
  console.log(`⬜ ${item.nome}`);
}
console.log("");
console.log("Progresso:");
console.log(`${concluidos.length}/${ordenada.length} conteúdos`);
console.log(`${percentual}%`);
