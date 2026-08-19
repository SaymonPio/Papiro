import fs from 'fs';

// Builder para as 100 explicações do Macro-Lote 100
// Vamos importar do raw e construir cada uma com alto rigor pedagógico

const raw = JSON.parse(fs.readFileSync('C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/scratch/macro-lote100-raw.json', 'utf8'));

console.log('Total no raw:', raw.length);

// Criamos o arquivo de script gerador com as 100 explicações completas
