// Consolidador das 100 explicações do Macro-Lote de Legislação Específica (100 questões)

import { explicacoesParte1 } from './macro-lote-le100-parte1.mjs';
import { explicacoesParte2 } from './macro-lote-le100-parte2.mjs';
import { explicacoesParte3 } from './macro-lote-le100-parte3.mjs';

export const explicacoes = [
  ...explicacoesParte1,
  ...explicacoesParte2,
  ...explicacoesParte3
];
