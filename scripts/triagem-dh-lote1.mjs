import fs from 'fs';

const inputPath = 'C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/.system_generated/steps/600/output.txt';
const content = fs.readFileSync(inputPath, 'utf8');
const json = JSON.parse(content);
const match = json.result.match(/\[\s*\{[\s\S]*\}\s*\]/);
const data = JSON.parse(match[0]);

fs.writeFileSync('C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/scratch/dh-lote1-raw.json', JSON.stringify(data, null, 2), 'utf8');

console.log('Total de questoes:', data.length);
const letters = ['A', 'B', 'C', 'D', 'E'];
let problems = 0;

const summary = data.map(q => {
  const correctAlts = q.alternativas.filter(a => a.correta);
  const correctIndex = q.alternativas.findIndex(a => a.correta);
  const correctLetter = correctAlts.length === 1 ? letters[correctIndex] : 'ERROR';
  if (correctAlts.length !== 1 || (q.alternativas.length !== 4 && q.alternativas.length !== 5 && q.alternativas.length !== 2)) {
    console.error('Problema no ID:', q.id, 'alts:', q.alternativas.length, 'corretas:', correctAlts.length);
    problems++;
  }
  return { id: q.id, materia_id: q.materia_id, n_alt: q.alternativas.length, correta: correctLetter, banca: q.banca, ano: q.ano };
});

console.log('Problemas encontrados:', problems);
console.log('IDs:', JSON.stringify(summary.map(s => s.id)));
console.log('Resumo:', JSON.stringify(summary));
