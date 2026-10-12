import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import {
  lerRevisaoPersonalizadaSolicitada,
  lerRevisaoSolicitada,
  montarLinkRevisaoPersonalizada,
} from "../utils/missao-cronograma.mjs";

// PAPIRO Beta 1.1 — Central de Revisões e Diagnóstico. Mesma técnica do
// resto do projeto: assert.match/doesNotMatch contra o texto REAL da
// migration/páginas, e mirror em JS da lógica SQL quando o comportamento
// (não só a presença de texto) é o que importa. Sem harness de banco nos
// testes deste projeto — cenários que exigem Postgres real ficam
// marcados "[requer banco vivo]".
const migracao = await readFile(
  new URL("../supabase/migrations/20261011090000_central_revisoes_personalizada.sql", import.meta.url),
  "utf8",
);
const migracaoBase = await readFile(
  new URL("../supabase/migrations/20261008120000_revisao_executavel.sql", import.meta.url),
  "utf8",
);
const migracaoHotfix = await readFile(
  new URL("../supabase/migrations/20261010120000_corrigir_ambiguidade_revisao.sql", import.meta.url),
  "utf8",
);
const questoesPage = await readFile(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const cadernoPage = await readFile(new URL("../app/caderno-de-erros/page.tsx", import.meta.url), "utf8");

const corpoContar = migracao.slice(
  migracao.indexOf("function public.contar_revisoes_personalizadas"),
  migracao.indexOf("$function$;", migracao.indexOf("function public.contar_revisoes_personalizadas")),
);
const corpoIniciarPersonalizada = migracao.slice(
  migracao.indexOf("function public.iniciar_revisao_personalizada"),
  migracao.indexOf("$function$;", migracao.indexOf("function public.iniciar_revisao_personalizada")),
);

// ============================================================================
// 1/19. o fluxo automático continua 100% intacto.
// ============================================================================

test("1/19. revisar tudo (fluxo automático) continua funcionando: iniciar_revisao()/concluir_revisao(bigint) não são redefinidas por esta migration", () => {
  assert.doesNotMatch(migracao, /create or replace function public\.iniciar_revisao\(\)/);
  assert.doesNotMatch(migracao, /create or replace function public\.concluir_revisao\(/);
  // app/questoes/page.tsx continua chamando a RPC automática sem nenhum parâmetro, como antes:
  assert.match(questoesPage, /supabase\.rpc\("iniciar_revisao"\)/);
  assert.doesNotMatch(questoesPage, /supabase\.rpc\("iniciar_revisao",/);
});

test("19/19. fluxo automático e personalizado são irmãos, nunca o mesmo parâmetro de URL: lerRevisaoSolicitada/lerRevisaoPersonalizadaSolicitada são mutuamente exclusivos", () => {
  assert.equal(lerRevisaoSolicitada("revisaoP=1"), false, "revisaoP=1 nao deve ser lido como revisao=1");
  assert.equal(lerRevisaoPersonalizadaSolicitada("revisao=1"), null, "revisao=1 nao deve ser lido como revisaoP=1");
  assert.equal(lerRevisaoSolicitada("revisao=1"), true);
  assert.ok(lerRevisaoPersonalizadaSolicitada("revisaoP=1"));
});

// ============================================================================
// 2/3/4/5. filtros — matéria, assunto, tipo de erro, situação.
// ============================================================================

test("2. filtro por matéria: WHERE das duas RPCs tem '(p_materia_id is null or q.materia_id = p_materia_id)'", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /and \(p_materia_id is null or q\.materia_id = p_materia_id\)/);
  }
});

test("3. filtro por assunto: WHERE das duas RPCs tem '(p_assunto_id is null or q.assunto_id = p_assunto_id)'", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /and \(p_assunto_id is null or q\.assunto_id = p_assunto_id\)/);
  }
});

test("4. filtro por tipo de erro: WHERE das duas RPCs tem '(p_tipo_erro is null or eu.tipo_erro = p_tipo_erro)', validado contra os 5 valores atuais de classificar_erro", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /and \(p_tipo_erro is null or eu\.tipo_erro = p_tipo_erro\)/);
    assert.match(corpo, /p_tipo_erro not in \('nao_sabia', 'duvida', 'chute', 'atencao', 'interpretacao'\)/);
  }
  // nunca aceita um valor legado (ex.: falta_conhecimento) como filtro válido:
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.doesNotMatch(corpo, /falta_conhecimento/);
  }
});

test("5. filtro por situação: as 4 opções (vencidas/hoje/proximas/todas) mapeiam para a comparação correta de agendada_para — mirror em JS da mesma lógica SQL", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /p_situacao not in \('vencidas', 'hoje', 'proximas', 'todas'\)/);
    assert.match(corpo, /\(p_situacao = 'vencidas' and rv\.agendada_para < current_date\)/);
    assert.match(corpo, /\(p_situacao = 'hoje' and rv\.agendada_para = current_date\)/);
    assert.match(corpo, /\(p_situacao = 'proximas' and rv\.agendada_para > current_date\)/);
    assert.match(corpo, /\(p_situacao = 'todas'\)/);
  }

  function elegivelPorSituacao(situacao, agendadaPara, hoje) {
    if (situacao === "vencidas") return agendadaPara < hoje;
    if (situacao === "hoje") return agendadaPara === hoje;
    if (situacao === "proximas") return agendadaPara > hoje;
    return true; // todas
  }
  const hoje = "2026-10-11";
  assert.equal(elegivelPorSituacao("vencidas", "2026-10-01", hoje), true);
  assert.equal(elegivelPorSituacao("vencidas", "2026-10-11", hoje), false);
  assert.equal(elegivelPorSituacao("hoje", "2026-10-11", hoje), true);
  assert.equal(elegivelPorSituacao("proximas", "2026-10-20", hoje), true);
  assert.equal(elegivelPorSituacao("proximas", "2026-10-01", hoje), false);
  assert.equal(elegivelPorSituacao("todas", "2026-01-01", hoje), true);
});

// ============================================================================
// 6/7/8. quantidade — 10, 20, todas.
// ============================================================================

test("6/7/8. quantidade é clampada server-side entre 1 e 50 (10/20 passam direto; 'Todas' da UI mapeia para 50, o teto real)", () => {
  assert.match(corpoIniciarPersonalizada, /v_quantidade := greatest\(1, least\(50, coalesce\(p_quantidade, 20\)\)\);/);
  function clamp(valor) { return Math.max(1, Math.min(50, valor ?? 20)); }
  assert.equal(clamp(10), 10);
  assert.equal(clamp(20), 20);
  assert.equal(clamp(50), 50);
  assert.equal(clamp(9999), 50, "um valor absurdo nunca deveria vazar sem o clamp, mas o servidor protege mesmo assim");
  // a UI usa exatamente os mesmos 3 valores (10/20/50-"Todas"):
  assert.match(cadernoPage, /const OPCOES_QUANTIDADE = \[10, 20, 50\] as const;/);
  assert.match(cadernoPage, /\{quantidade === 50 \? "Todas" : quantidade\}/);
});

test("montarLinkRevisaoPersonalizada também clampa quantidade no cliente (defesa em profundidade, nunca a única validação)", () => {
  assert.match(montarLinkRevisaoPersonalizada({ quantidade: 9999 }), /quantidade=50/);
  assert.match(montarLinkRevisaoPersonalizada({ quantidade: 10 }), /quantidade=10/);
});

// ============================================================================
// 9. filtro sem resultados.
// ============================================================================

test("9. filtro sem resultados: iniciar_revisao_personalizada levanta mensagem PRÓPRIA (nunca a genérica de revisão automática), e o frontend a traduz", () => {
  assert.match(corpoIniciarPersonalizada, /raise exception 'Nenhuma revisao encontrada para os filtros selecionados';/);
  assert.match(questoesPage, /nenhuma revisao encontrada/i);
  assert.match(questoesPage, /Nenhuma revisão encontrada para os filtros selecionados\./);
});

// ============================================================================
// 10/11. usuário sem revisão / matrícula inativa.
// ============================================================================

test("10/11. mesmo preâmbulo de auth/curso ativo/matrícula ATIVA de iniciar_revisao() — matrícula inativa (ou curso sem matrícula) é recusada ANTES de qualquer seleção", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /and m\.status = 'ativa';/);
    assert.match(corpo, /if v_matricula_id is null then\s*\n\s*raise exception 'Matricula ativa no curso ativo nao encontrada';/);
    const indiceMatricula = corpo.indexOf("Matricula ativa no curso ativo nao encontrada");
    const indiceSelecao = corpo.indexOf("public.revisoes rv");
    assert.ok(indiceMatricula > -1 && indiceSelecao > -1 && indiceMatricula < indiceSelecao);
  }
});

// ============================================================================
// 12. revisão de outro usuário.
// ============================================================================

test("12. revisão de outro usuário é recusada: toda seleção é filtrada por rv.usuario_id = v_usuario_id (nunca um id de usuário vindo do cliente)", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /where rv\.usuario_id = v_usuario_id/);
  }
  // a recuperação de sessão existente (igual a iniciar_revisao()) também é filtrada por usuario_id:
  assert.match(corpoIniciarPersonalizada, /where s\.usuario_id = v_usuario_id/);
});

// ============================================================================
// 13. filtro com ID de outra matrícula/curso.
// ============================================================================

test("13. materia_id/assunto_id de OUTRO curso são rejeitados: validados contra curso_materias/curso_conteudos do curso ATIVO (v_curso_ativo_id), nunca aceitos só por existirem em algum curso", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /from public\.curso_materias cm\s*\n\s*where cm\.curso_id = v_curso_ativo_id\s*\n\s*and cm\.materia_id = p_materia_id\s*\n\s*and cm\.relevante_para_preparacao = true/);
    assert.match(corpo, /raise exception 'Materia nao pertence ao curso desta matricula';/);
    assert.match(corpo, /from public\.curso_conteudos cc\s*\n\s*join public\.curso_materias cm on cm\.id = cc\.curso_materia_id\s*\n\s*where cm\.curso_id = v_curso_ativo_id/);
    assert.match(corpo, /raise exception 'Assunto invalido para esta materia\/curso';/);
    // assunto sem matéria é rejeitado antes de qualquer consulta:
    assert.match(corpo, /if p_assunto_id is not null and p_materia_id is null then\s*\n\s*raise exception 'p_assunto_id informado sem p_materia_id';/);
  }
  // mirror da lógica de pertencimento contra um dataset fake (mesma técnica de tests/missao-cronograma):
  const cursoMaterias = [{ curso_id: "curso-A", materia_id: 10, relevante_para_preparacao: true }];
  function materiaValida(cursoId, materiaId) {
    return cursoMaterias.some((cm) => cm.curso_id === cursoId && cm.materia_id === materiaId && cm.relevante_para_preparacao);
  }
  assert.equal(materiaValida("curso-A", 10), true);
  assert.equal(materiaValida("curso-B", 10), false, "materia_id que só existe em OUTRO curso deve ser rejeitada");
});

// ============================================================================
// 14. 1 marco por erro (Opção B) também na personalizada.
// ============================================================================

test("14. a seleção personalizada também usa 'distinct on (rv.erro_id) ... order by rv.erro_id, rv.ordem' — mesma independência de marcos da automática", () => {
  assert.match(corpoContar, /select distinct on \(rv\.erro_id\) rv\.id/);
  assert.match(corpoIniciarPersonalizada, /select distinct on \(rv\.erro_id\) rv\.id, rv\.agendada_para/);
});

// ============================================================================
// 15. sessão personalizada recuperável (idempotência compartilhada).
// ============================================================================

test("15. iniciar_revisao_personalizada usa o MESMO lock e a MESMA recuperação idempotente de iniciar_revisao() — automática e personalizada compartilham a mesma sessão em_andamento", () => {
  assert.match(corpoIniciarPersonalizada, /perform pg_advisory_xact_lock\(\s*\n\s*hashtextextended\('revisao:' \|\| v_usuario_id::text \|\| ':' \|\| v_matricula_id::text, 0\)\s*\n\s*\);/);
  assert.match(corpoIniciarPersonalizada, /and s\.status = 'em_andamento'\s*\n\s*and s\.nivel_meta = 'revisao'/);
  assert.match(corpoIniciarPersonalizada, /return query select v_sessao_id, v_status, v_questao_ids, true;/);
  // a chave do lock é IDÊNTICA à da automática (mesmo texto, mesma migration-fonte iniciar_revisao()):
  const chaveAutomatica = migracaoHotfix.match(/hashtextextended\('revisao:'[^)]*\)/)?.[0];
  const chavePersonalizada = corpoIniciarPersonalizada.match(/hashtextextended\('revisao:'[^)]*\)/)?.[0];
  assert.ok(chaveAutomatica && chavePersonalizada);
  assert.equal(chaveAutomatica, chavePersonalizada, "as duas RPCs precisam disputar/recuperar a MESMA sessao — chave do lock tem que ser igual");
});

// ============================================================================
// 16. conclusão idempotente (concluir_revisao reaproveitada sem mudança).
// ============================================================================

test("16. concluir_revisao(bigint) é 100% reaproveitada — esta migration não a toca, e ela continua idempotente (ver tests/revisao-executavel.test.mjs para a prova detalhada)", () => {
  assert.doesNotMatch(migracao, /create or replace function public\.concluir_revisao/);
  assert.match(migracaoHotfix, /if v_sessao\.status = 'concluida' then/, "a fonte de verdade atual de concluir_revisao continua tendo o ramo idempotente");
});

// ============================================================================
// 17. erro durante a revisão cria novo ciclo sem entrar na sessão atual.
// ============================================================================

test("17. revisao_ids é escrito UMA ÚNICA VEZ (no INSERT) também na personalizada — nenhum UPDATE a recalcula depois, então um erro novo durante a sessão nunca entra nela", () => {
  assert.doesNotMatch(migracao, /update public\.sessoes_estudo\s*\n\s*set[^;]*revisao_ids/s);
  assert.match(corpoIniciarPersonalizada, /insert into public\.sessoes_estudo as se \(\s*\n\s*usuario_id, matricula_id, nivel_meta, status,\s*\n\s*inicio_em, minutos_revisao, questoes_planejadas, revisao_ids/);
});

// ============================================================================
// 18. cronômetro usa tipoAtividade="revisao" também na personalizada.
// ============================================================================

test("18. tipoAtividade do cronômetro depende só de nivel==='revisao' — a personalizada seta o MESMO nivel, então herda o mesmo cronômetro sem nenhum código novo", () => {
  assert.match(questoesPage, /tipoAtividade: nivel === "revisao" \? "revisao" : "questoes"/);
  assert.match(questoesPage, /setNivel\("revisao"\);/g);
  // iniciarRevisaoPersonalizada também chama setNivel("revisao") — mesmo caminho da automática:
  const corpoIniciarPersonalizadaFrontend = questoesPage.slice(
    questoesPage.indexOf("const iniciarRevisaoPersonalizada = useCallback"),
    questoesPage.indexOf("}, []);", questoesPage.indexOf("const iniciarRevisaoPersonalizada = useCallback")),
  );
  assert.match(corpoIniciarPersonalizadaFrontend, /setNivel\("revisao"\);/);
  // nenhum outro cronômetro foi criado:
  assert.equal((questoesPage.match(/\buseSessaoTempo\(/g) ?? []).length, 1);
});

// ============================================================================
// Permissões e endurecimento (mesmo padrão das duas RPCs anteriores).
// ============================================================================

test("grants: as duas RPCs novas são authenticated-only, nunca public/anon", () => {
  assert.match(migracao, /revoke all on function public\.contar_revisoes_personalizadas\(bigint, bigint, text, text\) from public, anon;/);
  assert.match(migracao, /grant execute on function public\.contar_revisoes_personalizadas\(bigint, bigint, text, text\) to authenticated;/);
  assert.match(migracao, /revoke all on function public\.iniciar_revisao_personalizada\(bigint, bigint, text, text, integer\) from public, anon;/);
  assert.match(migracao, /grant execute on function public\.iniciar_revisao_personalizada\(bigint, bigint, text, text, integer\) to authenticated;/);
});

test("ambas as RPCs novas são SECURITY DEFINER com search_path travado", () => {
  for (const corpo of [corpoContar, corpoIniciarPersonalizada]) {
    assert.match(corpo, /security definer/);
    assert.match(corpo, /set search_path to ''/);
  }
});

test("nenhuma referência não qualificada a 'status' em iniciar_revisao_personalizada (mesma vigilância do hotfix 42702) — INSERT...RETURNING usa alias 'se'", () => {
  assert.match(corpoIniciarPersonalizada, /insert into public\.sessoes_estudo as se \(/);
  assert.match(corpoIniciarPersonalizada, /returning se\.id, se\.status into v_sessao_id, v_status;/);
  assert.doesNotMatch(corpoIniciarPersonalizada, /\)\s*returning id, status into/);
});

// ============================================================================
// Reuso do motor de questões / frontend.
// ============================================================================

test("NÃO existe uma segunda tela/motor de questões: iniciarRevisaoPersonalizada reaproveita buscarMatriculaAtiva/buscarDetalhesQuestoes/atualizarUrlSessaoAvulsa, igual à automática", () => {
  const corpo = questoesPage.slice(
    questoesPage.indexOf("const iniciarRevisaoPersonalizada = useCallback"),
    questoesPage.indexOf("}, []);", questoesPage.indexOf("const iniciarRevisaoPersonalizada = useCallback")),
  );
  assert.match(corpo, /buscarMatriculaAtiva\(supabase, user\.id\)/);
  assert.match(corpo, /buscarDetalhesQuestoes\(supabase, ids\)/);
  assert.match(corpo, /atualizarUrlSessaoAvulsa\(Number\(linha\.sessao_id\)\)/);
  assert.match(corpo, /supabase\.rpc\("iniciar_revisao_personalizada", \{/);
});

test("Central de Revisões reaproveita RPCs já existentes para indicadores/diagnóstico/matérias — nenhuma RPC nova foi criada só para exibição", () => {
  assert.match(cadernoPage, /supabase\.rpc\("erros_do_curso_ativo"\)/);
  assert.match(cadernoPage, /supabase\.rpc\("revisoes_do_curso_ativo"\)/);
  assert.match(cadernoPage, /supabase\.rpc\("materias_do_curso_ativo"\)/);
  assert.match(cadernoPage, /\.rpc\("assuntos_do_curso_ativo", \{ p_materia_id: filtroMateriaId \}\)/);
  assert.match(cadernoPage, /\.rpc\("contar_revisoes_personalizadas", \{/);
});

test("taxa de recuperação nunca é uma métrica fictícia: null quando não há revisões concluídas com desempenho_pos_revisao conhecido (nunca 0%/100% forçado)", () => {
  assert.match(cadernoPage, /const taxaRecuperacao = concluidasComDesempenho\.length > 0/);
  assert.match(cadernoPage, /\{indicadores\.taxaRecuperacao === null \? "—" : `\$\{indicadores\.taxaRecuperacao\}%`\}/);
  // mirror da regra: com os 2 dados reais confirmados na auditoria (ambos desempenho_pos_revisao nulo), a taxa tem que ser null:
  function taxaRecuperacao(revisoes) {
    const concluidasComDesempenho = revisoes.filter((r) => r.status === "concluida" && r.desempenho_pos_revisao !== null);
    if (concluidasComDesempenho.length === 0) return null;
    const recuperadas = concluidasComDesempenho.filter((r) => Number(r.desempenho_pos_revisao) >= 1);
    return Math.round((recuperadas.length / concluidasComDesempenho.length) * 100);
  }
  assert.equal(
    taxaRecuperacao([{ status: "concluida", desempenho_pos_revisao: null }, { status: "concluida", desempenho_pos_revisao: null }]),
    null,
    "dataset real confirmado na auditoria: 2 concluidas, ambas com desempenho_pos_revisao nulo — taxa precisa ser null, nunca 0%",
  );
  assert.equal(
    taxaRecuperacao([{ status: "concluida", desempenho_pos_revisao: 1 }, { status: "concluida", desempenho_pos_revisao: 0 }]),
    50,
  );
});

test("diagnóstico de tipos de erro mostra 'Não classificado' honestamente (não força os 5 valores de classificar_erro quando o dado real é null)", () => {
  assert.match(cadernoPage, /"__nao_classificado__"/);
  assert.match(cadernoPage, /rotulo: chave === "__nao_classificado__" \? "Não classificado"/);
});

// ============================================================================
// Hotfix P2 — "Revisar matéria" usa a situação coerente com as pendências
// reais da matéria (antes fixava situacao="vencidas" mesmo quando a matéria
// só tinha pendências "hoje"/"próximas", gerando um "Nenhuma revisão
// encontrada" evitável). Mirror em JS de obterSituacaoRevisaoMateria, mesma
// prioridade temporal vencida > hoje > futura já usada pelos indicadores
// desta tela (ver teste "5." acima).
// ============================================================================

function obterSituacaoRevisaoMateria(materia) {
  if (materia.vencidas > 0) return "vencidas";
  if (materia.hoje > 0) return "hoje";
  if (materia.proximas > 0) return "proximas";
  return null;
}

test("hotfix P2 (1). matéria com vencidas > 0 → botão usa situacao=vencidas", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 3, hoje: 2, proximas: 1 }), "vencidas");
});

test("hotfix P2 (2). matéria com vencidas=0 e hoje>0 → botão usa situacao=hoje", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 0, hoje: 1, proximas: 4 }), "hoje");
});

test("hotfix P2 (3). matéria com vencidas=0, hoje=0 e próximas>0 → botão usa situacao=proximas", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 0, hoje: 0, proximas: 5 }), "proximas");
});

test("hotfix P2 (4). matéria sem nenhuma pendência → botão não aparece (situacao null, nenhum link gerado)", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 0, hoje: 0, proximas: 0 }), null);
});

test("hotfix P2 (5). vencidas têm prioridade sobre hoje/próximas mesmo quando as três são > 0", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 1, hoje: 10, proximas: 10 }), "vencidas");
});

test("hotfix P2 (6). hoje tem prioridade sobre próximas quando vencidas=0", () => {
  assert.equal(obterSituacaoRevisaoMateria({ vencidas: 0, hoje: 1, proximas: 10 }), "hoje");
});

test("hotfix P2 (7). nenhum dos 4 ramos possíveis devolve 'todas' — o botão da matéria nunca usa esse valor por padrão", () => {
  for (const materia of [
    { vencidas: 3, hoje: 0, proximas: 0 },
    { vencidas: 0, hoje: 3, proximas: 0 },
    { vencidas: 0, hoje: 0, proximas: 3 },
    { vencidas: 0, hoje: 0, proximas: 0 },
  ]) {
    assert.notEqual(obterSituacaoRevisaoMateria(materia), "todas");
  }
  assert.doesNotMatch(cadernoPage, /materiaId: materia\.materiaId, situacao: "todas"/);
});

test("hotfix P2 (8). código real: o botão 'Revisar matéria' não fixa mais situacao=\"vencidas\" e passa a usar o resultado de obterSituacaoRevisaoMateria", () => {
  assert.doesNotMatch(
    cadernoPage,
    /montarLinkRevisaoPersonalizada\(\{ materiaId: materia\.materiaId, situacao: "vencidas" \}\)/,
    "o hardcode antigo (sempre vencidas) não pode mais existir",
  );
  assert.match(cadernoPage, /function obterSituacaoRevisaoMateria\(materia: \{ vencidas: number; hoje: number; proximas: number \}\): Situacao \| null \{/);
  assert.match(cadernoPage, /if \(materia\.vencidas > 0\) return "vencidas";\s*\n\s*if \(materia\.hoje > 0\) return "hoje";\s*\n\s*if \(materia\.proximas > 0\) return "proximas";\s*\n\s*return null;/);
  assert.match(cadernoPage, /const situacaoRevisaoMateria = obterSituacaoRevisaoMateria\(materia\);/);
  assert.match(cadernoPage, /materia\.materiaId !== null && situacaoRevisaoMateria !== null && \(/);
  assert.match(cadernoPage, /montarLinkRevisaoPersonalizada\(\{ materiaId: materia\.materiaId, situacao: situacaoRevisaoMateria \}\)/);
  // agregação por matéria agora guarda hoje/proximas, além de vencidas (mínimo necessário, sem RPC nova):
  assert.match(cadernoPage, /const hoje = pendentes\.filter\(\(r\) => r\.agendada_para === hojeChave\);/);
  assert.match(cadernoPage, /const proximas = pendentes\.filter\(\(r\) => r\.agendada_para > hojeChave\);/);
  assert.match(cadernoPage, /hoje: hoje\.length,\s*\n\s*proximas: proximas\.length,/);
});

test("hotfix P2 (9). a revisão automática (cr-hero \"Revisar pendências de hoje\") continua usando montarLinkRevisao() sem parâmetros — hotfix não tocou nela", () => {
  assert.match(cadernoPage, /href=\{montarLinkRevisao\(\)\}/);
  assert.doesNotMatch(cadernoPage, /montarLinkRevisao\([^)]+\)/, "montarLinkRevisao nunca recebe argumentos");
});

// ============================================================================
// [requer banco vivo]
// ============================================================================

test("[requer banco vivo] concorrência real entre uma chamada automática e uma personalizada simultâneas (mesmo lock, duas transações de fato) só pode ser confirmada contra Postgres real", () => {
  assert.match(corpoIniciarPersonalizada, /pg_advisory_xact_lock/);
});
