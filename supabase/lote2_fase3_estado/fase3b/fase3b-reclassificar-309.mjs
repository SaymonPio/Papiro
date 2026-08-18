#!/usr/bin/env node
// Propaga o UPGRADE da questao 309 (tecId 3085547, caderno 309) de VALIDA
// para VALIDA_COM_RESSALVA (achado da reaudit do sub-lote 2 da Fase 3B --
// nao e remocao, a questao continua aprovada para importacao, so ganha uma
// nota de ressalva). Motivo: o enunciado parafraseia o art. 7o, caput,
// omitindo o "entre outras" do texto legal original, apresentando a lista
// de 5 modalidades como se fosse fechada -- mesma familia de ressalva ja
// aplicada a 220/240/253/262/285/304 (nota sobre a violencia vicaria,
// Lei 15.384/2026), sem alterar o gabarito nem a aprovacao para a proxima
// fase.
//
// Arquivos atualizados: lote2_sublote3_classificacao_final.json (Fase 2,
// registro original), lote2_manifesto_fase2_533.json (Fase 2, manifesto),
// lote2_fase3a_candidatas_limpas_521.json (Fase 3A, pool -- 520 registros,
// so atualiza classificacao_final e motivo_ressalva, NAO remove),
// fase3b_sublote2_conteudo.json (Fase 3B, conteudo do sub-lote 2).
//
// So leitura/escrita local -- nao toca Supabase.

import fs from 'fs';

const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';
const TEC_ID = 3085547;
const CADERNO = 309;
const NOVA_CATEGORIA = 'VALIDA_COM_RESSALVA';
const MOTIVO = 'Achado da reaudit do sub-lote 2 da Fase 3B: o enunciado parafraseia o art. 7o, caput ("sao formas de violencia contra a mulher: a fisica, psicologica, sexual, patrimonial, e ___"), omitindo o "entre outras" que consta do texto legal original, apresentando a lista de 5 modalidades como se fosse fechada. Questao de 2024, anterior a Lei 15.384/2026 (violencia vicaria, art. 7o, VI). Gabarito D (moral) permanece correto e unico -- nenhuma alternativa oferece "vicaria" ou testa a completude do rol. Upgrade de VALIDA para VALIDA_COM_RESSALVA; nao afeta APROVADA_PARA_PROXIMA_FASE (continua true).';

function log(msg) { console.log(msg); }

// --- 1. lote2_sublote3_classificacao_final.json ---------------------------
{
  const path = `${SCRATCH}/lote2_sublote3_classificacao_final.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[1] tecId ${TEC_ID} nao encontrado em lote2_sublote3_classificacao_final.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[1] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.categoria !== 'VALIDA') throw new Error(`[1] categoria esperada VALIDA, encontrada ${rec.categoria}`);
  rec.categoria = NOVA_CATEGORIA;
  rec.motivo = MOTIVO;
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  log(`[1] lote2_sublote3_classificacao_final.json: caderno 309 VALIDA -> ${NOVA_CATEGORIA} (${arr.length} registros, inalterado)`);
}

// --- 2. lote2_manifesto_fase2_533.json -------------------------------------
{
  const path = `${SCRATCH}/lote2_manifesto_fase2_533.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[2] tecId ${TEC_ID} nao encontrado em lote2_manifesto_fase2_533.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[2] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.classificacao_final !== 'VALIDA') throw new Error(`[2] classificacao_final esperada VALIDA, encontrada ${rec.classificacao_final}`);
  if (rec.APROVADA_PARA_PROXIMA_FASE !== true) throw new Error('[2] APROVADA_PARA_PROXIMA_FASE esperado true (upgrade nao deve mudar aprovacao)');
  rec.classificacao_final = NOVA_CATEGORIA;
  rec.motivo_ressalva = MOTIVO;
  // APROVADA_PARA_PROXIMA_FASE permanece true -- upgrade, nao exclusao.
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  const aprovadas = arr.filter(r => r.APROVADA_PARA_PROXIMA_FASE === true).length;
  const reprovadas = arr.length - aprovadas;
  log(`[2] lote2_manifesto_fase2_533.json: caderno 309 VALIDA -> ${NOVA_CATEGORIA} (continua aprovada)`);
  log(`    Total ${arr.length} | aprovadas ${aprovadas} (esperado 520, inalterado) | reprovadas ${reprovadas} (esperado 13, inalterado)`);
}

// --- 3. lote2_fase3a_candidatas_limpas_521.json ----------------------------
{
  const path = `${SCRATCH}/lote2_fase3a_candidatas_limpas_521.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[3] tecId ${TEC_ID} nao encontrado em lote2_fase3a_candidatas_limpas_521.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[3] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.classificacao_final !== 'VALIDA') throw new Error(`[3] classificacao_final esperada VALIDA, encontrada ${rec.classificacao_final}`);
  rec.classificacao_final = NOVA_CATEGORIA;
  rec.motivo_ressalva = MOTIVO;
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  log(`[3] lote2_fase3a_candidatas_limpas_521.json: caderno 309 VALIDA -> ${NOVA_CATEGORIA} (${arr.length} registros, inalterado)`);
}

// --- 4. fase3b_sublote2_conteudo.json --------------------------------------
{
  const path = `${SCRATCH}/fase3b_sublote2_conteudo.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[4] tecId ${TEC_ID} nao encontrado em fase3b_sublote2_conteudo.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[4] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.classificacao_final !== 'VALIDA') throw new Error(`[4] classificacao_final esperada VALIDA, encontrada ${rec.classificacao_final}`);
  rec.classificacao_final = NOVA_CATEGORIA;
  rec.motivo_ressalva = MOTIVO;
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  log(`[4] fase3b_sublote2_conteudo.json: caderno 309 VALIDA -> ${NOVA_CATEGORIA} (${arr.length} registros, inalterado)`);
}

log('\nPropagacao do upgrade (309) concluida com sucesso em todos os 4 arquivos-fonte.');
