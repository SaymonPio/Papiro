// Exportação consolidada das 100 explicações pedagógicas do Macro-Lote 100

import { explicacoesParte1 } from './macro-lote100-parte1.mjs';
import { explicacoesParte2 } from './macro-lote100-parte2.mjs';
import { explicacoesParte3 } from './macro-lote100-parte3.mjs';

export const explicacoes = [
  ...explicacoesParte1,
  ...explicacoesParte2,
  ...explicacoesParte3
];
