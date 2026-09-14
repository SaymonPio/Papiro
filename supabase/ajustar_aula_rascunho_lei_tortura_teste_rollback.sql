-- TESTE DE ROLLBACK — AJUSTE CIRURGICO DO RASCUNHO (fluxo completo OLD ->
-- TARGET -> REVERT -> OLD_FINAL -> ROLLBACK; NAO aplica nada permanente;
-- ver ajustar_aula_rascunho_lei_tortura.sql para o apply real) — unidade "Lei de Tortura" (BM RS), Lote A1.
--
-- Incorpora ao rascunho v1 existente: (1) art. 1º, III (paragrafo no
-- conceito "nucleo" + 1 recall dedicado); (2) art. 1º, §7º + jurisprudencia
-- do STF (HC 111.840) sobre regime inicial fechado nao-automatico (1 novo
-- conceito + 1 novo recall); (3) art. 2º/extraterritorialidade explicitado
-- (reforco textual no conceito "consequencias" + bullet no resumo, sem
-- novo componente); (4) remocao das 3 extrapolacoes identificadas na
-- auditoria (art.1º,I,"c"; §1º; §4º,II/III). Preserva integralmente:
-- diagnostico original, questao_resolvida original (correta, dentro do
-- escopo), e a estrutura/redacao dos 2 conceitos e 2 recalls originais
-- fora dos trechos pontuais alterados.
--
-- Estrutura final: 10 componentes (3 conceito, 4 recall, 1 diagnostico,
-- 1 questao_resolvida, 1 resumo_visual) — validado localmente contra
-- supabase/functions/gerar-aula/validador.mjs (validarRespostaGerador):
-- ok=true.
--
-- NAO existe RPC/admin-flow canonico para editar o conteudo de uma
-- aula_versoes ja existente (confirmado via pg_proc: so existem
-- carregar_aula_rascunho_admin [leitura] e publicar_aula_versao_admin
-- [status] — nenhuma funcao de edicao de conteudo). Por isso este ajuste
-- usa UPDATE direto, escopado a UMA UNICA linha por aula_versao_id exato.
--
-- NAO altera status (permanece 'rascunho'), NAO publica, NAO toca
-- questoes/alternativas/questao_unidades_pedagogicas/curso_questoes/
-- unidades_pedagogicas/escopo/artigos_esperados/curso_conteudos ou
-- qualquer outra aula/aula_versao.
--
-- Alvo exato: aula_versao_id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'
-- (unidade 392fd9fe-a3d2-4062-b912-0a299b414429, "Lei de Tortura",
-- rascunho v1). Conteudo final integral documentado em
-- scripts/curadoria-pedagogica/relatorios/proposta-ajuste-lei-tortura-v2.json.
--
-- ROLLBACK-TESTADO em ajustar_aula_rascunho_lei_tortura_teste_rollback.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old on commit drop as
select av.id as aula_versao_id, av.estrutura, av.status, av.numero_versao
from public.aula_versoes av
where av.id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;

create temporary table _hash_outras_versoes_antes on commit drop as
select md5(string_agg(id::text || status || estrutura::text, '|' order by id)) as h
from public.aula_versoes
where id <> 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_status text;
  v_versao int;
  v_qtd_componentes int;
  v_escopo_ok boolean;
  v_artigos_ok boolean;
  v_q2124_ativa boolean;
  v_q2124_vinculada boolean;
  v_q2124_em_curso boolean;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes')
  into v_status, v_versao, v_qtd_componentes
  from _snapshot_old;

  if v_status is null then raise exception 'PRECOND: aula_versao_id alvo nao encontrado'; end if;
  if v_status <> 'rascunho' then raise exception 'PRECOND: status esperado rascunho, encontrado % — possivel publicacao concorrente, abortar', v_status; end if;
  if v_versao <> 1 then raise exception 'PRECOND: numero_versao esperado 1, encontrado % — abortar', v_versao; end if;
  if v_qtd_componentes <> 7 then raise exception 'PRECOND: esperado 7 componentes na versao ANTES do ajuste, encontrado % — conteudo pode ter mudado, abortar', v_qtd_componentes; end if;

  select array_length(artigos_esperados, 1) = 10
    and 'art. 1º, III' = any(artigos_esperados)
    and position('art. 1º, III' in escopo) > 0
  into v_escopo_ok
  from public.unidades_pedagogicas where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;
  if not coalesce(v_escopo_ok, false) then raise exception 'PRECOND: escopo LIVE da unidade nao esta atualizado com art. 1º, III (10 artigos_esperados) — abortar'; end if;

  select ativa into v_q2124_ativa from public.questoes where id = 2124;
  if coalesce(v_q2124_ativa, false) is not true then raise exception 'PRECOND: Q2124 nao esta ativa — abortar'; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=2124 and qup.unidade_pedagogica_id='392fd9fe-a3d2-4062-b912-0a299b414429'::uuid) into v_q2124_vinculada;
  if not v_q2124_vinculada then raise exception 'PRECOND: Q2124 nao esta vinculada a unidade alvo — abortar'; end if;

  select exists(select 1 from public.curso_questoes cq where cq.questao_id=2124 and cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4') into v_q2124_em_curso;
  if not v_q2124_em_curso then raise exception 'PRECOND: Q2124 nao esta em curso_questoes — abortar'; end if;

  raise notice 'PRECOND OK: rascunho v1 com 7 componentes (estado auditado); escopo LIVE ja atualizado com art.1º,III (10 artigos_esperados); Q2124 ativa/vinculada/em curso_questoes';
end $$;

-- ================= APPLY =================
update public.aula_versoes
set estrutura = $ESTRUTURA${
  "componentes": [
    {
      "id": "bc1cf1d2-4ae0-4006-8e8a-ed7a624241a3",
      "tipo": "diagnostico",
      "titulo": "Antes de decorar: reconheça a tortura na prática",
      "pergunta": "Um agente utiliza violência contra uma pessoa presa para obter uma confissão. Essa situação pode configurar tortura mesmo que a confissão não seja obtida? Qual é o elemento principal que você deve observar?",
      "introducao": "Antes de entrar nos detalhes da lei, quero ver se você já identifica os elementos centrais da conduta. Leia o caso e pense: há violência ou grave ameaça? Qual era a finalidade? A condição da vítima altera o enquadramento?",
      "resposta_esperada": "Sim. A tortura pode estar configurada quando alguém é constrangido, mediante violência ou grave ameaça, com a finalidade de obter informação, declaração ou confissão. O resultado pretendido não precisa ser alcançado; é essencial identificar a conduta, o meio empregado e a finalidade específica."
    },
    {
      "id": "4dbe4fa1-480a-418c-8102-087a411009f3",
      "tipo": "conceito",
      "titulo": "O núcleo da Lei de Tortura",
      "exemplo": "Um agente ameaça uma pessoa para obter informações sobre um terceiro. Ainda que a vítima permaneça em silêncio, a conduta pode configurar tortura, pois a finalidade de obter informação estava presente e o tipo legal não exige que a informação seja efetivamente fornecida.",
      "pegadinha": "Não confunda tortura com qualquer uso de força. Na forma principal, é necessário identificar a finalidade prevista na lei. Também não confunda a omissão: quem tinha o dever de evitar ou apurar a tortura responde por figura própria, com pena de detenção de **1 a 4 anos**. E não confunda a hipótese de violência doméstica reiterada (adiante) com as finalidades do inciso I: ali a lei exige uma finalidade específica; nesta outra hipótese, o que caracteriza a conduta é a reiteração da submissão no contexto doméstico e familiar, independentemente dessa finalidade.",
      "explicacao": "A Lei nº 9.455/1997 considera tortura, em uma de suas formas principais, constranger alguém, mediante violência ou grave ameaça, causando sofrimento físico ou mental com finalidade específica. Entre essas finalidades estão: obter informação, declaração ou confissão da vítima ou de terceira pessoa; ou provocar ação ou omissão de natureza criminosa.\n\nTambém existe a tortura-castigo: submeter pessoa que esteja sob guarda, poder ou autoridade do agente, mediante violência ou grave ameaça, a intenso sofrimento físico ou mental, como forma de aplicar castigo pessoal ou medida de caráter preventivo.\n\nHá ainda uma hipótese autônoma, introduzida mais recentemente à lei: submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar, sem prejuízo da aplicação das penas correspondentes a outras infrações penais. Essa hipótese **não é uma terceira finalidade** das formas anteriores — é uma conduta própria, com elementos diferentes: reiteração da submissão e contexto de violência doméstica e familiar, em vez de uma finalidade específica de obter informação/confissão ou provocar ato criminoso.\n\nA omissão também é tratada expressamente: quem se omite diante dessas condutas, tendo o dever de evitá-las ou apurá-las, responde por crime próprio, com pena diferente da aplicada às formas comissivas.",
      "ponto_de_prova": "Preste atenção à combinação: **violência ou grave ameaça + sofrimento físico ou mental + finalidade específica**. Na tortura-castigo, a vítima precisa estar sob **guarda, poder ou autoridade** do agente e o sofrimento deve ser intenso. Na hipótese de violência doméstica reiterada, o elemento central é a **reiteração** no contexto doméstico e familiar — não uma finalidade específica listada no inciso I."
    },
    {
      "id": "9768bd51-5d8b-4190-ab88-c24b715612ae",
      "tipo": "conceito",
      "titulo": "Consequências e circunstâncias relevantes",
      "exemplo": "Se um agente público pratica tortura, incide a causa de aumento prevista para essa condição, com aumento de 1/6 a 1/3, sem transformar essa circunstância em um novo crime.",
      "pegadinha": "A condição de agente público não é exigida para existir tortura nas formas principais. Ela funciona como causa de aumento. Outra atenção: a lei fala em **graça ou anistia** e em inafiançabilidade; não substitua essas expressões por outras consequências que não estejam no dispositivo.",
      "explicacao": "A pena básica das formas principais de tortura é de reclusão de **2 a 8 anos**. Se da tortura resultar lesão corporal de natureza grave ou gravíssima, a pena passa para reclusão de **4 a 10 anos**. Se resultar morte, passa para reclusão de **8 a 16 anos**.\n\nA pena aumenta de **1/6 a 1/3** quando o crime é cometido por agente público.\n\nO crime de tortura é **inafiançável e insuscetível de graça ou anistia**. A lei também prevê hipótese de extraterritorialidade (art. 2º): aplica-se ainda quando o crime não tenha sido cometido em território nacional, sendo a vítima brasileira ou encontrando-se o agente em local sob jurisdição brasileira.",
      "ponto_de_prova": "Memorize a sequência dos resultados: forma básica, **2 a 8 anos**; lesão grave ou gravíssima, **4 a 10 anos**; morte, **8 a 16 anos**. O fato de o agente ser público gera aumento de pena, além da consequência funcional prevista na lei."
    },
    {
      "id": "c1d2e3f4-a5b6-47c8-9d0e-1f2a3b4c5d6e",
      "tipo": "conceito",
      "titulo": "Regime inicial e a jurisprudência do STF (art. 1º, §7º)",
      "exemplo": "Um juiz condena um réu por tortura e, sem qualquer fundamentação adicional, aplica automaticamente o regime fechado apenas citando o §7º. Essa decisão pode ser questionada, pois o STF exige fundamentação concreta para a fixação do regime, não a simples aplicação automática do dispositivo.",
      "pegadinha": "Não afirme que \"o regime fechado é proibido\" nem que \"o §7º foi revogado\". O texto do §7º continua vigente; o que a jurisprudência afasta é sua aplicação **automática e obrigatória**, sem análise do caso concreto.",
      "explicacao": "O art. 1º, §7º, da Lei nº 9.455/1997 prevê que o condenado por crime de tortura iniciará o cumprimento da pena em regime fechado. O STF, no julgamento do HC 111.840 e em jurisprudência reiterada, entende que a imposição **automática e abstrata** desse regime, sem fundamentação concreta, viola o princípio da individualização da pena (art. 5º, XLVI, da CF). Por isso, a fixação do regime deve observar os critérios gerais aplicáveis ao caso concreto, com fundamentação judicial — o texto do §7º não deixou de existir, mas não pode ser aplicado de forma automática.",
      "ponto_de_prova": "Guarde a distinção: **texto literal do §7º** = regime fechado; **jurisprudência do STF (HC 111.840)** = essa imposição não pode ser automática/abstrata, exigindo fundamentação concreta."
    },
    {
      "id": "a0764da4-03cd-4169-b0d9-b2c53d4cb108",
      "tipo": "recall",
      "titulo": "Recupere os elementos antes de olhar a resposta",
      "dica": "Pense na sequência: **informação/confissão; crime**.",
      "pergunta": "Quais são as duas finalidades específicas previstas na forma de tortura baseada em constrangimento mediante violência ou grave ameaça?",
      "resposta": "Obter informação, declaração ou confissão da vítima ou de terceira pessoa; ou provocar ação ou omissão de natureza criminosa."
    },
    {
      "id": "41dedec2-e047-4836-8273-eca2ffa9eb35",
      "tipo": "recall",
      "titulo": "Diferença que muda o enquadramento",
      "dica": "Associe **castigo** à relação de guarda, poder ou autoridade; associe **confissão** à finalidade de obter informação ou declaração.",
      "pergunta": "Qual é a diferença central entre a tortura-castigo e a forma de tortura destinada a obter informação, declaração ou confissão?",
      "resposta": "Na tortura-castigo, a vítima está sob guarda, poder ou autoridade do agente, e o sofrimento intenso é imposto para aplicar castigo pessoal ou medida de caráter preventivo. Na outra forma, o constrangimento tem como finalidade obter informação, declaração ou confissão."
    },
    {
      "id": "e3f4a5b6-c7d8-49e0-bf1a-3b4c5d6e7f8a",
      "tipo": "recall",
      "titulo": "Inciso III é uma nova finalidade ou uma conduta própria?",
      "dica": "Pense: reiteração + contexto doméstico e familiar, sem exigir finalidade específica de obter confissão ou provocar crime.",
      "pergunta": "Um homem submete, de forma reiterada, sua companheira a intenso sofrimento psicológico no âmbito da convivência doméstica, sem que se identifique qualquer finalidade de obter confissão ou de provocar ato criminoso. Essa conduta pode configurar tortura? Por qual dispositivo?",
      "resposta": "Sim. Trata-se da hipótese autônoma do art. 1º, III, da Lei nº 9.455/1997: submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar. Não é necessário identificar a finalidade específica exigida pelo inciso I — o que caracteriza esta hipótese é a reiteração da submissão nesse contexto."
    },
    {
      "id": "d2e3f4a5-b6c7-48d9-ae0f-2a3b4c5d6e7f",
      "tipo": "recall",
      "titulo": "O que o STF decidiu sobre o regime fechado automático?",
      "dica": "Pense: o texto da lei continua existindo, mas não pode ser aplicado \"no automático\".",
      "pergunta": "O art. 1º, §7º, da Lei de Tortura prevê regime inicial fechado. O que a jurisprudência do STF (HC 111.840) estabeleceu sobre a aplicação desse dispositivo?",
      "resposta": "O STF entende que a imposição automática e abstrata do regime fechado, com base apenas no §7º, viola o princípio da individualização da pena. A fixação do regime deve observar os critérios gerais aplicáveis ao caso concreto, com fundamentação judicial."
    },
    {
      "id": "8573f9ad-1dc8-4961-9e26-c5830757a7a0",
      "tipo": "questao_resolvida",
      "gabarito": "B",
      "enunciado": "Durante uma abordagem, um agente público utiliza grave ameaça e violência para obrigar uma pessoa a fornecer informações sobre determinado fato. A pessoa não fornece qualquer informação. Considerando a Lei de Tortura, assinale a alternativa correta.",
      "pegadinha": "O ponto decisivo é separar **finalidade** de **resultado**. A lei exige que a conduta tenha a finalidade de obter informação, mas não exige que a vítima realmente forneça a informação.",
      "raciocinio": "A alternativa B está correta. A forma principal de tortura exige constrangimento mediante violência ou grave ameaça, sofrimento físico ou mental e uma finalidade específica, entre elas obter informação, declaração ou confissão. A obtenção efetiva da informação não é exigida pelo tipo. A alternativa A erra ao exigir o resultado; a C confunde essa forma com a modalidade envolvendo pessoa presa ou sujeita a medida de segurança; e a D erra porque a tortura pode ser praticada por agente público ou particular, sendo a condição de agente público uma causa de aumento de pena.",
      "alternativas": [
        {"letra": "A", "texto": "Não há tortura, porque a informação não foi efetivamente obtida."},
        {"letra": "B", "texto": "Pode haver tortura, pois a lei considera a finalidade de obter informação, ainda que o resultado pretendido não seja alcançado."},
        {"letra": "C", "texto": "Só haveria tortura se a vítima estivesse presa ou submetida a medida de segurança."},
        {"letra": "D", "texto": "A conduta é apenas ameaça, porque agente público não pode praticar tortura na forma prevista para particulares."}
      ]
    },
    {
      "id": "68800ffb-a699-4995-9e46-c3ee24d2b1ec",
      "tipo": "resumo_visual",
      "titulo": "Lei de Tortura — mapa para a prova",
      "pontos": [
        "**Forma principal:** violência ou grave ameaça + sofrimento físico ou mental + finalidade específica.",
        "Finalidades: obter informação, declaração ou confissão; ou provocar ação ou omissão criminosa.",
        "**Tortura-castigo:** vítima sob guarda, poder ou autoridade + intenso sofrimento + castigo pessoal ou medida preventiva.",
        "**Hipótese autônoma (art. 1º, III):** submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar — não é uma finalidade adicional do inciso I.",
        "Omissão de quem tinha dever de evitar ou apurar: detenção de **1 a 4 anos**.",
        "Resultados mais graves: lesão grave ou gravíssima, **4 a 10 anos**; morte, **8 a 16 anos**.",
        "Aumento de **1/6 a 1/3** quando o crime é cometido por agente público; crime inafiançável e insuscetível de graça ou anistia.",
        "**Regime inicial (art. 1º, §7º):** texto legal prevê regime fechado, mas o STF (HC 111.840) afasta sua aplicação automática, exigindo fundamentação concreta no caso.",
        "**Extraterritorialidade (art. 2º):** a lei se aplica mesmo fora do território nacional, se a vítima for brasileira ou o agente estiver em local sob jurisdição brasileira."
      ]
    }
  ],
  "schema_version": 1,
  "artigos_abordados": [
    "art. 1º, I, \"a\"",
    "art. 1º, I, \"b\"",
    "art. 1º, II",
    "art. 1º, III",
    "art. 1º, §2º",
    "art. 1º, §4º, I",
    "art. 1º, §5º",
    "art. 1º, §6º",
    "art. 1º, §7º",
    "art. 2º, caput"
  ]
}$ESTRUTURA$::jsonb
where id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;

-- ================= POSCONDICOES =================
do $$
declare
  v_status text;
  v_qtd_componentes int;
  v_tipos text[];
  v_artigos jsonb;
  v_texto_completo text;
begin
  select status, jsonb_array_length(estrutura->'componentes'),
         array(select jsonb_array_elements(estrutura->'componentes')->>'tipo'),
         estrutura->'artigos_abordados',
         estrutura::text
  into v_status, v_qtd_componentes, v_tipos, v_artigos, v_texto_completo
  from public.aula_versoes where id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;

  if v_status <> 'rascunho' then raise exception 'POSCOND: status mudou inesperadamente para %, esperado rascunho', v_status; end if;
  if v_qtd_componentes <> 10 then raise exception 'POSCOND: esperado 10 componentes, encontrado %', v_qtd_componentes; end if;
  if not (v_tipos @> array['diagnostico','conceito','recall','questao_resolvida','resumo_visual']) then
    raise exception 'POSCOND: um ou mais tipos obrigatorios ausentes: %', v_tipos;
  end if;
  if jsonb_array_length(v_artigos) <> 10 then raise exception 'POSCOND: artigos_abordados esperado 10 itens, encontrado %', jsonb_array_length(v_artigos); end if;
  if not (v_artigos ? 'art. 1º, III') then raise exception 'POSCOND: artigos_abordados nao contem art. 1º, III'; end if;
  if position('art. 1º, I, "c"' in v_texto_completo) > 0 then raise exception 'POSCOND: extrapolacao art.1º,I,"c" ainda presente'; end if;

  declare
    v_total_depois int;
    v_total_antes int;
    v_hash_depois text;
    v_hash_antes text;
  begin
    select count(*) into v_total_antes from public.aula_versoes;
    select count(*) into v_total_depois from public.aula_versoes;
    if v_total_depois <> v_total_antes then
      raise exception 'POSCOND: contagem total de aula_versoes mudou inesperadamente dentro da mesma transacao';
    end if;

    select h into v_hash_antes from _hash_outras_versoes_antes;
    select md5(string_agg(id::text || status || estrutura::text, '|' order by id))
    into v_hash_depois
    from public.aula_versoes
    where id <> 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;
    if v_hash_depois is distinct from v_hash_antes then
      raise exception 'POSCOND: conteudo de OUTRAS aula_versoes mudou — vazamento de escopo do UPDATE';
    end if;
  end;

  raise notice 'POSCOND OK: status=rascunho preservado, 10 componentes, 5 tipos obrigatorios presentes, 10 artigos_abordados incl. art.1º,III, extrapolacao I-c ausente, nenhuma outra aula_versao tocada';
end $$;

-- Confirma que Q2124/vinculo/curso_questoes/escopo da unidade permanecem
-- intocados (nenhuma instrucao de escrita neste arquivo sobre essas
-- tabelas — checagem apenas declarativa/confirmatoria).
do $$
declare
  v_q2124_ativa boolean;
  v_q2124_vinculada boolean;
  v_q2124_em_curso boolean;
  v_artigos_qtd int;
begin
  select ativa into v_q2124_ativa from public.questoes where id = 2124;
  select exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=2124 and qup.unidade_pedagogica_id='392fd9fe-a3d2-4062-b912-0a299b414429'::uuid) into v_q2124_vinculada;
  select exists(select 1 from public.curso_questoes cq where cq.questao_id=2124 and cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4') into v_q2124_em_curso;
  select array_length(artigos_esperados, 1) into v_artigos_qtd from public.unidades_pedagogicas where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

  if coalesce(v_q2124_ativa, false) is not true or not v_q2124_vinculada or not v_q2124_em_curso then
    raise exception 'POSCOND: Q2124/vinculo/curso_questoes divergiu do esperado apos o apply';
  end if;
  if v_artigos_qtd <> 10 then raise exception 'POSCOND: artigos_esperados da unidade mudou inesperadamente (esperado 10, encontrado %)', v_artigos_qtd; end if;

  raise notice 'POSCOND OK: Q2124 intacta; escopo/artigos_esperados da unidade inalterados (10 itens)';
end $$;

-- ================= REVERT (restaura a partir do snapshot OLD) =================
update public.aula_versoes av
set
  estrutura = t.estrutura,
  status = t.status
from _snapshot_old t
where av.id = t.aula_versao_id;

-- ================= OLD_FINAL (confirma identidade byte-a-byte com OLD) =================
do $$
declare
  v_estrutura_igual boolean;
  v_status_igual boolean;
begin
  select (av.estrutura = t.estrutura), (av.status = t.status)
  into v_estrutura_igual, v_status_igual
  from public.aula_versoes av
  join _snapshot_old t on t.aula_versao_id = av.id
  where av.id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73'::uuid;

  if not v_estrutura_igual then raise exception 'OLD_FINAL: estrutura NAO retornou identica a original'; end if;
  if not v_status_igual then raise exception 'OLD_FINAL: status NAO retornou identico ao original'; end if;

  raise notice 'OLD_FINAL OK: estrutura e status identicos ao estado OLD original (7 componentes) — reversao comprovada';
end $$;

rollback;
