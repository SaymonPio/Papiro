import fs from 'fs';

const data = JSON.parse(fs.readFileSync('C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/scratch/dh-lote1-raw.json', 'utf8'));
const letters = ['A', 'B', 'C', 'D', 'E'];

data.forEach((q, i) => {
  const cIndex = q.alternativas.findIndex(a => a.correta);
  const correctLetter = letters[cIndex];
  console.log(`=== ID ${q.id} (${i + 1}/50) | Correta: ${correctLetter} | ${q.banca} (${q.ano || 'N/A'}) ===`);
  console.log('ENUNCIADO:', q.enunciado);
  q.alternativas.forEach((a, idx) => {
    console.log(`  ${letters[idx]}) ${a.correta ? '[CORRETA] ' : ''}${a.texto}`);
  });
  console.log('');
});
