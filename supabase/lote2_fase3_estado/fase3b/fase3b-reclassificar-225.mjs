#!/usr/bin/env node
// Propaga a reclassificacao da questao 225 (tecId 3502460, caderno 225) de
// VALIDA para PROBLEMATICA_GABARITO_AMBIGUO por TODOS os arquivos-fonte que
// dependem dela, de forma programatica (nao manual), para que ela nao seja
// importada em nenhuma fase futura. Motivo (reaudit pedido pelo usuario):
// a alternativa D ("namorado divulga fotos intimas sem consentimento")
// tambem se enquadra em "violacao de sua intimidade" (art. 7o, II, na
// redacao vigente pos Lei 13.772/2018), tornando A e D simultaneamente
// corretas para o comando de resposta unica "assinale a que configura
// violencia psicologica".
//
// Arquivos atualizados, em cascata:
//   1. lote2_sublote1_classificacao_final.json  (Fase 2, registro original)
//   2. lote2_manifesto_fase2_533.json           (Fase 2, manifesto consolidado)
//   3. lote2_fase3a_candidatas_limpas_521.json  (Fase 3A, pool limpo -- 521 -> 520)
//   4. fase3b_sublotes_ids.json                 (Fase 3B, mapa de sub-lotes -- remove do sub-lote 1)
//   5. fase3b_sublote1_conteudo.json            (Fase 3B, conteudo do sub-lote 1 -- 38 -> 37)
//
// So leitura/escrita local -- nao toca Supabase.

import fs from 'fs';

const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';
const TEC_ID = 3502460;
const CADERNO = 225;
const NOVA_CATEGORIA = 'PROBLEMATICA_GABARITO_AMBIGUO';
const MOTIVO = 'Reaudit solicitado pelo usuario: a alternativa D ("namorado divulga fotos intimas da namorada sem o consentimento dela") tambem se enquadra em "violacao de sua intimidade", meio expressamente listado na definicao de violencia psicologica do art. 7o, II, na redacao vigente (pos Lei 13.772/2018). O enunciado pede a UNICA alternativa que configura violencia psicologica, mas tanto A (humilhacao/diminuicao de autoestima) quanto D (violacao de intimidade) satisfazem objetivamente essa definicao, sem criterio textual que preserve a unicidade de A. Gabarito original (A) nao sustentavel isoladamente -- questao ambigua, excluida da importacao.';

function log(msg) { console.log(msg); }

// --- 1. lote2_sublote1_classificacao_final.json ---------------------------
{
  const path = `${SCRATCH}/lote2_sublote1_classificacao_final.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[1] tecId ${TEC_ID} nao encontrado em lote2_sublote1_classificacao_final.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[1] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.categoria !== 'VALIDA') throw new Error(`[1] categoria esperada VALIDA, encontrada ${rec.categoria}`);
  rec.categoria = NOVA_CATEGORIA;
  rec.motivo = MOTIVO;
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  log(`[1] lote2_sublote1_classificacao_final.json: caderno 225 VALIDA -> ${NOVA_CATEGORIA} (${arr.length} registros, inalterado)`);
}

// --- 2. lote2_manifesto_fase2_533.json -------------------------------------
{
  const path = `${SCRATCH}/lote2_manifesto_fase2_533.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[2] tecId ${TEC_ID} nao encontrado em lote2_manifesto_fase2_533.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[2] cadernoNumero divergente: ${rec.cadernoNumero}`);
  if (rec.classificacao_final !== 'VALIDA') throw new Error(`[2] classificacao_final esperada VALIDA, encontrada ${rec.classificacao_final}`);
  if (rec.APROVADA_PARA_PROXIMA_FASE !== true) throw new Error('[2] APROVADA_PARA_PROXIMA_FASE esperado true');
  rec.classificacao_final = NOVA_CATEGORIA;
  rec.motivo_ressalva = MOTIVO;
  rec.APROVADA_PARA_PROXIMA_FASE = false;
  fs.writeFileSync(path, JSON.stringify(arr, null, 2), 'utf8');
  const aprovadas = arr.filter(r => r.APROVADA_PARA_PROXIMA_FASE === true).length;
  const reprovadas = arr.length - aprovadas;
  log(`[2] lote2_manifesto_fase2_533.json: caderno 225 VALIDA/aprovada -> ${NOVA_CATEGORIA}/reprovada`);
  log(`    Total ${arr.length} | aprovadas ${aprovadas} (esperado 520) | reprovadas ${reprovadas} (esperado 13)`);
}

// --- 3. lote2_fase3a_candidatas_limpas_521.json ----------------------------
{
  const path = `${SCRATCH}/lote2_fase3a_candidatas_limpas_521.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const antes = arr.length;
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[3] tecId ${TEC_ID} nao encontrado em lote2_fase3a_candidatas_limpas_521.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[3] cadernoNumero divergente: ${rec.cadernoNumero}`);
  const depois = arr.filter(r => r.tecId !== TEC_ID);
  if (depois.length !== antes - 1) throw new Error('[3] remocao nao resultou em -1 registro');
  fs.writeFileSync(path, JSON.stringify(depois, null, 2), 'utf8');
  log(`[3] lote2_fase3a_candidatas_limpas_521.json: ${antes} -> ${depois.length} registros (caderno 225 removido)`);
}

// --- 4. fase3b_sublotes_ids.json -------------------------------------------
{
  const path = `${SCRATCH}/fase3b_sublotes_ids.json`;
  const sublotes = JSON.parse(fs.readFileSync(path, 'utf8'));
  let achado = false;
  for (let i = 0; i < sublotes.length; i++) {
    const idx = sublotes[i].indexOf(TEC_ID);
    if (idx !== -1) {
      sublotes[i].splice(idx, 1);
      achado = true;
      log(`[4] fase3b_sublotes_ids.json: tecId ${TEC_ID} removido do sub-lote ${i + 1} (agora ${sublotes[i].length} ids)`);
    }
  }
  if (!achado) throw new Error(`[4] tecId ${TEC_ID} nao encontrado em nenhum sub-lote de fase3b_sublotes_ids.json`);
  const totalIds = sublotes.reduce((s, a) => s + a.length, 0);
  fs.writeFileSync(path, JSON.stringify(sublotes, null, 2), 'utf8');
  log(`    Total de tecIds em todos os sub-lotes: ${totalIds} (esperado 520)`);
}

// --- 5. fase3b_sublote1_conteudo.json --------------------------------------
{
  const path = `${SCRATCH}/fase3b_sublote1_conteudo.json`;
  const arr = JSON.parse(fs.readFileSync(path, 'utf8'));
  const antes = arr.length;
  const rec = arr.find(r => r.tecId === TEC_ID);
  if (!rec) throw new Error(`[5] tecId ${TEC_ID} nao encontrado em fase3b_sublote1_conteudo.json`);
  if (rec.cadernoNumero !== CADERNO) throw new Error(`[5] cadernoNumero divergente: ${rec.cadernoNumero}`);
  const depois = arr.filter(r => r.tecId !== TEC_ID);
  if (depois.length !== antes - 1) throw new Error('[5] remocao nao resultou em -1 registro');
  fs.writeFileSync(path, JSON.stringify(depois, null, 2), 'utf8');
  log(`[5] fase3b_sublote1_conteudo.json: ${antes} -> ${depois.length} registros (caderno 225 removido)`);
}

log('\nPropagacao concluida com sucesso em todos os 5 arquivos-fonte.');
