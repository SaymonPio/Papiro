import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const sql=await readFile(new URL("../supabase/missao_questoes_rpc.sql",import.meta.url),"utf8");
const pagina=await readFile(new URL("../app/questoes/page.tsx",import.meta.url),"utf8");
const resultado=await readFile(new URL("../app/questoes/resultado/page.tsx",import.meta.url),"utf8");

test("sessão fica ligada a uma única missão e congela a lista planejada",()=>{
  assert.match(sql,/add column if not exists missao_id uuid/);
  assert.match(sql,/sessoes_estudo_missao_unica_idx/);
  assert.match(sql,/create table if not exists public\.sessao_questoes_planejadas/);
  assert.match(sql,/array_agg\(sq\.questao_id order by sq\.ordem\)/);
});

test("início exige teoria completa e avança a missão no servidor",()=>{
  assert.match(sql,/iniciar_questoes_da_missao/);
  assert.match(sql,/Conclua a teoria antes de iniciar as questoes/);
  assert.match(sql,/v_total_concluidas<>v_total_unidades/);
  assert.match(sql,/status='questoes_iniciadas'/);
});

test("conclusão exige todas as questões planejadas e fecha missão e sessão",()=>{
  assert.match(sql,/concluir_questoes_da_missao/);
  assert.match(sql,/v_respondidas<>v_planejadas/);
  assert.match(sql,/set status='concluida',fim_em=coalesce/);
  assert.match(sql,/set status='concluida',concluida_em=coalesce/);
});

test("resposta duplicada, fora da lista ou depois do fim é bloqueada",()=>{
  assert.match(sql,/validar_resposta_da_sessao/);
  assert.match(sql,/Sessao nao esta em andamento/);
  assert.match(sql,/Questao ja respondida nesta sessao/);
  assert.match(sql,/Questao nao planejada para esta missao/);
});

test("tela usa as RPCs e preserva missionId até o resultado",()=>{
  const inicioLivre=pagina.slice(
    pagina.indexOf("async function iniciarSessao(meta"),
    pagina.indexOf("const iniciarSessaoPersonalizada"),
  );
  const inicioDaMissao=pagina.slice(
    pagina.indexOf("const iniciarSessaoPersonalizada"),
    pagina.indexOf("useEffect(() =>",pagina.indexOf("const iniciarSessaoPersonalizada")),
  );

  assert.doesNotMatch(inicioLivre,/iniciar_questoes_da_missao/);
  assert.match(inicioDaMissao,/iniciar_questoes_da_missao/);
  assert.match(inicioDaMissao,/if \(missionId\)/);
  assert.match(pagina,/concluir_questoes_da_missao/);
  assert.match(pagina,/setMissionId\(missao\.missionId\)/);
  assert.match(resultado,/missao_id/);
  assert.match(resultado,/MISSÃO CONCLUÍDA/);
  assert.match(resultado,/resultado\.missao_id \? "\/cronograma" : "\/painel"/);
  assert.match(resultado,/resultado\.missao_id \? "Voltar ao cronograma" : "Voltar ao painel"/);
});
