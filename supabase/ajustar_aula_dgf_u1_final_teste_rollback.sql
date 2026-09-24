-- TESTE DE ROLLBACK — AJUSTE CIRURGICO DA AULA (fluxo completo OLD ->
-- TARGET -> REVERT -> OLD_FINAL -> ROLLBACK; NAO aplica nada permanente;
-- ver ajustar_aula_dgf_u1_final.sql para o apply real) — unidade
-- "Direitos Individuais e Coletivos Fundamentais" (BM RS) — inclui os
-- incisos XV e XIX do art. 5º.
--
-- Mandato: "PAPIRO — FASE 9.0.1 — REVISAO FINAL DA CURADORIA DGF ANTES
-- DO ROLLBACK TEST", secoes 3/4/14. SUBSTITUI o patch da Fase 9
-- (ajustar_aula_dgf_u1_inciso_xix.sql, removido nesta rodada). Mesmo
-- padrao ja usado em ajustar_aula_dgf_u1_caput_xviii.sql (UPDATE direto
-- em aula_versoes.estrutura — precedente ja confirmado via pg_proc: nao
-- existe RPC/admin-writer para editar conteudo de aula).
--
-- DUAS mudancas nesta rodada:
--
--   1) XIX (dissolucao compulsoria/suspensao judicial de associacoes) —
--   acrescimo cirurgico dentro do componente JA EXISTENTE "Liberdade de
--   associacao" (id 8d2e2070-...-43aa9), campos `explicacao` e
--   `ponto_de_prova`. Justificativa: questao real 46, item 3 do V/F.
--
--   2) XV (liberdade de locomocao) — NAO existe componente com relacao
--   tematica (o mandato desta rodada expressamente proibiu inserir XV
--   "artificialmente em componente sem relacao tematica"). Criado UM
--   componente NOVO tipo "conceito", com a MESMA estrutura pedagogica
--   dos demais (explicacao/exemplo/pegadinha/ponto_de_prova), inserido
--   logo apos "Sigilo de correspondencia e comunicacoes" (XII) e antes
--   de "Liberdade religiosa e assistencia religiosa" (VI/VII) — posicao
--   que preserva a ordem tematica geral (nao estritamente numerica; a
--   propria aula ja intercala XI/XII antes de VI/VII/XVI). Justificativa:
--   questao real 847 (gabarito literal em XV), direito individual
--   basico, coerente com o titulo da unidade.
--
-- Todos os 13 componentes ja existentes permanecem no array, na mesma
-- ordem relativa; apenas o de associacao ganha texto adicional. O array
-- de nivel superior `artigos_abordados` ganha "art. 5º, XV" e
-- "art. 5º, XIX" nas posicoes numericas naturais -- 14 -> 16 itens.
-- Total de componentes: 13 -> 14 (1 novo).
--
-- Deve ser aplicado em CONJUNTO com
-- atualizar_artigos_esperados_dgf_u1_final.sql (patch irmao na
-- unidade_pedagogica).
--
-- NAO regenera a aula. NAO cria nova aula_versao (numero_versao
-- permanece 1). NAO publica. NAO toca em: diagnostico, VI/VII/VIII/IX/
-- X/XI/XII/XVI/XVII/XXI, recalls, questao_resolvida, resumo_visual,
-- fonte, status, aula_id, aula_versao_id.
--
-- Este arquivo E o teste de rollback (preparado nesta mesma rodada);
-- execucao contra LIVE fica para uma fase de rollback-test dedicada,
-- nao esta.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_dgf_final on commit drop as
select av.id as aula_versao_id, av.estrutura, av.status
from public.aula_versoes av
where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

create temporary table _hash_outras_versoes_antes_dgf_final on commit drop as
select md5(string_agg(id::text || estrutura::text, '|' order by id)) as h
from public.aula_versoes
where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_status text;
  v_numero_versao int;
  v_qtd_componentes int;
  v_hash text;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes'), md5(estrutura::text)
  into v_status, v_numero_versao, v_qtd_componentes, v_hash
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_status is null then raise exception 'PRECOND: aula_versao nao encontrada'; end if;
  if v_status <> 'rascunho' then raise exception 'PRECOND: status esperado rascunho, encontrado %', v_status; end if;
  if v_numero_versao <> 1 then raise exception 'PRECOND: numero_versao esperado 1, encontrado %', v_numero_versao; end if;
  if v_qtd_componentes <> 13 then raise exception 'PRECOND: esperado 13 componentes, encontrado %', v_qtd_componentes; end if;
  if v_hash <> '6c7fd24a40d715e1fbfa28db520ddc57' then
    raise exception 'PRECOND: hash da estrutura atual diverge do estado auditado na Fase 9/9.0.1 — possivel alteracao concorrente, abortar';
  end if;

  raise notice 'PRECOND OK: status=rascunho, numero_versao=1, 13 componentes, hash da estrutura confere com o estado auditado';
end $$;

-- ================= APPLY =================
update public.aula_versoes
set estrutura = $ESTRUTURA$
{
  "artigos_abordados": [
    "art. 5º, caput",
    "art. 5º, I",
    "art. 5º, IV",
    "art. 5º, VI",
    "art. 5º, VII",
    "art. 5º, VIII",
    "art. 5º, IX",
    "art. 5º, X",
    "art. 5º, XI",
    "art. 5º, XII",
    "art. 5º, XV",
    "art. 5º, XVI",
    "art. 5º, XVII",
    "art. 5º, XVIII",
    "art. 5º, XIX",
    "art. 5º, XXI"
  ],
  "componentes": [
    {
      "id": "3288d9e3-6ab7-4327-941e-37b816425e36",
      "introducao": "Antes de decorar os incisos, quero ver se você reconhece a regra na prática. Um grupo pretende realizar uma reunião pacífica, sem armas, em uma praça pública. O encontro não impedirá outra reunião anteriormente marcada, e a autoridade competente foi avisada.",
      "pergunta": "Esse grupo ainda precisa pedir autorização ao poder público para realizar a reunião?",
      "resposta_esperada": "Não. A reunião em local aberto ao público **independe de autorização**. Exigem-se caráter pacífico, ausência de armas, respeito a outra reunião anteriormente convocada para o mesmo local e **prévio aviso** à autoridade competente.",
      "tipo": "diagnostico",
      "titulo": "Autorização ou simples aviso?"
    },
    {
      "exemplo": "Uma regra pública não pode estabelecer tratamento desfavorável a alguém apenas por ser homem ou mulher, salvo diferenciação amparada pela própria Constituição.",
      "explicacao": "O art. 5º começa afirmando que todos são iguais perante a lei, sem distinção de qualquer natureza, e garante aos brasileiros e aos estrangeiros residentes no País a inviolabilidade dos direitos à **vida, liberdade, igualdade, segurança e propriedade**.\n\nAlém disso, homens e mulheres são iguais em direitos e obrigações, **nos termos da Constituição**. Presta atenção à literalidade: a igualdade não elimina todas as diferenças possíveis; ela impede distinções incompatíveis com a própria Constituição.",
      "id": "cefe11d4-c894-487a-a289-d1f68c385f9c",
      "pegadinha": "Trocar “nos termos da Constituição” por “nos termos da lei” altera a literalidade do inciso I e pode tornar a afirmação incorreta.",
      "ponto_de_prova": "A expressão correta é: homens e mulheres são iguais em direitos e obrigações **nos termos da Constituição**.",
      "tipo": "conceito",
      "titulo": "Igualdade e liberdade como direitos centrais"
    },
    {
      "exemplo": "Uma pessoa pode publicar uma crítica identificada e um artista pode divulgar sua obra sem precisar de licença prévia para expressar seu conteúdo.",
      "explicacao": "A manifestação do pensamento é livre, mas a Constituição **veda o anonimato**. Portanto, a pessoa pode expor suas ideias, porém não possui proteção constitucional para ocultar completamente sua identidade ao manifestá-las.\n\nTambém é livre a expressão da atividade intelectual, artística, científica e de comunicação, **independentemente de censura ou licença**.",
      "id": "4ac6d875-1d8c-4b55-850f-e3888943053b",
      "pegadinha": "Dizer que a liberdade de manifestação assegura o anonimato inverte expressamente o texto constitucional.",
      "ponto_de_prova": "Grave a diferença: manifestação do pensamento — **vedado o anonimato**; atividade intelectual, artística, científica e de comunicação — **independente de censura ou licença**.",
      "tipo": "conceito",
      "titulo": "Manifestação do pensamento e liberdade de expressão"
    },
    {
      "exemplo": "A divulgação indevida de conteúdo privado ou da imagem de uma pessoa pode atingir os direitos protegidos pelo inciso X.",
      "explicacao": "São invioláveis a **intimidade, a vida privada, a honra e a imagem** das pessoas. Se houver violação, a Constituição assegura indenização pelo dano material ou moral decorrente.\n\nNão confunda os bens protegidos: intimidade e vida privada dizem respeito à esfera pessoal; honra está ligada à consideração da pessoa; imagem corresponde à sua representação. Para a prova, o principal é memorizar o conjunto dos quatro direitos.",
      "id": "737896bf-b708-4c69-9759-19605a68e9ba",
      "pegadinha": "A Constituição não exige que existam simultaneamente dano material e dano moral. O texto utiliza a expressão dano material **ou** moral.",
      "ponto_de_prova": "A sequência constitucional é: **intimidade, vida privada, honra e imagem**, com indenização por dano material ou moral decorrente da violação.",
      "tipo": "conceito",
      "titulo": "Intimidade, vida privada, honra e imagem"
    },
    {
      "exemplo": "Havendo incêndio em uma residência, é possível ingressar sem consentimento para prestar socorro. Já o simples cumprimento de uma determinação judicial de entrada deve ocorrer durante o dia.",
      "explicacao": "A casa é o asilo inviolável do indivíduo. A regra é que ninguém pode entrar sem o **consentimento do morador**.\n\nA Constituição admite ingresso sem consentimento em quatro situações: **flagrante delito**, **desastre**, **prestação de socorro** e, **durante o dia**, por determinação judicial.\n\nA limitação temporal aparece apenas para a determinação judicial. Logo, ordem judicial não autoriza, pelo texto constitucional, ingresso durante a noite.",
      "id": "f0614831-dbff-4c68-b7f9-b3d31425adb4",
      "pegadinha": "Ordem judicial não é autorização constitucional para ingresso domiciliar a qualquer hora. Durante a noite, ela não basta para afastar a inviolabilidade da casa.",
      "ponto_de_prova": "O consentimento é do **morador**, não necessariamente do proprietário. E somente a determinação judicial vem acompanhada da expressão **durante o dia**.",
      "tipo": "conceito",
      "titulo": "Inviolabilidade do domicílio"
    },
    {
      "exemplo": "Uma autoridade administrativa não pode, por decisão própria e para qualquer finalidade, determinar o afastamento do sigilo das comunicações telefônicas.",
      "explicacao": "A Constituição protege o sigilo da correspondência, das comunicações telegráficas, de dados e das comunicações telefônicas.\n\nNo texto do inciso XII, a ressalva expressa recai sobre o **último caso**, isto é, as comunicações telefônicas. Seu sigilo pode ser afastado por **ordem judicial**, nas hipóteses e na forma estabelecidas em lei, para fins de **investigação criminal ou instrução processual penal**.",
      "id": "2b13bd2d-8042-4575-aefe-998b3f1f7b07",
      "pegadinha": "A expressão “no último caso” refere-se às comunicações telefônicas, e não indistintamente a todas as modalidades de sigilo enumeradas no inciso XII.",
      "ponto_de_prova": "Comunicações telefônicas: **ordem judicial + hipóteses e forma legais + investigação criminal ou instrução processual penal**.",
      "tipo": "conceito",
      "titulo": "Sigilo de correspondência e comunicações"
    },
    {
      "exemplo": "Uma pessoa pode se mudar livremente de um estado para outro, levando seus bens consigo, sem pedir autorização de qualquer autoridade — mas, em caso de guerra declarada, essa liberdade pode sofrer restrições excepcionais.",
      "explicacao": "É livre a locomoção no território nacional **em tempo de paz**, podendo qualquer pessoa, nos termos da lei, nele entrar, permanecer ou dele sair com seus bens.\n\nA condicionante constitucional **\"em tempo de paz\"** é expressa: é um dos poucos incisos do art. 5º com limitação temporal explícita no próprio texto. Em tempo de guerra, a Constituição admite restrições excepcionais a essa liberdade.",
      "id": "a15c7024-3e9b-4c1a-9f22-5d8e2b6c4a19",
      "pegadinha": "Estender a liberdade de locomoção também ao \"tempo de guerra\" inverte o texto constitucional — a condicionante \"em tempo de paz\" é expressa e não pode ser apagada nem generalizada.",
      "ponto_de_prova": "A liberdade de locomoção do art. 5º, XV, vale expressamente **em tempo de paz** — bancas adoram estender a regra também ao tempo de guerra para forçar o erro.",
      "tipo": "conceito",
      "titulo": "Liberdade de locomoção"
    },
    {
      "exemplo": "Uma pessoa internada em entidade militar de internação coletiva possui direito à prestação de assistência religiosa, nos termos da lei.",
      "explicacao": "É inviolável a liberdade de consciência e de crença. São assegurados o livre exercício dos cultos religiosos e, na forma da lei, a proteção aos locais de culto e às suas liturgias.\n\nTambém é assegurada, nos termos da lei, assistência religiosa nas entidades **civis e militares de internação coletiva**.\n\nNinguém será privado de direitos por motivo de crença religiosa ou convicção filosófica ou política. Existe uma ressalva: a pessoa não pode invocar essas convicções para se eximir de obrigação legal imposta a todos e, ao mesmo tempo, **recusar a prestação alternativa fixada em lei**.",
      "id": "744eefcb-5150-452f-8f0c-fa86a575124a",
      "pegadinha": "A simples existência de determinada crença não autoriza a privação de direitos. A ressalva constitucional depende também da recusa ao cumprimento da prestação alternativa legalmente fixada.",
      "ponto_de_prova": "A ressalva exige duas condutas combinadas: invocar a convicção para escapar de obrigação legal imposta a todos **e recusar** a prestação alternativa fixada em lei.",
      "tipo": "conceito",
      "titulo": "Liberdade religiosa e assistência religiosa"
    },
    {
      "exemplo": "Uma caminhada pacífica em via pública pode ocorrer sem autorização, desde que seus participantes estejam sem armas, haja prévio aviso e não seja frustrada reunião anteriormente convocada para o mesmo local.",
      "explicacao": "Todos podem reunir-se **pacificamente**, **sem armas** e em locais abertos ao público. A reunião independe de autorização, desde que não frustre outra anteriormente convocada para o mesmo local.\n\nA Constituição exige apenas **prévio aviso à autoridade competente**. Avisar não é pedir permissão.",
      "id": "5fc9e06f-d531-419c-a633-3ea50a6ef45d",
      "pegadinha": "Substituir prévio aviso por autorização prévia transforma uma comunicação obrigatória em pedido de permissão e contraria o inciso XVI.",
      "ponto_de_prova": "Reunião: **sem autorização, mas com prévio aviso**.",
      "tipo": "conceito",
      "titulo": "Direito de reunião"
    },
    {
      "exemplo": "Um grupo pode criar uma associação lícita sem pedir autorização estatal. Para que a entidade represente seus filiados, porém, deve existir autorização expressa deles.",
      "explicacao": "É plena a liberdade de associação para **fins lícitos**, sendo vedada a associação de caráter **paramilitar**.\n\nA criação de associações e, na forma da lei, a de cooperativas independem de autorização, e é vedada a interferência estatal em seu funcionamento.\n\nAs entidades associativas podem representar seus filiados judicial ou extrajudicialmente, mas precisam estar **expressamente autorizadas** para essa representação.\n\nAs associações só poderão ser **compulsoriamente dissolvidas** ou ter suas **atividades suspensas** por decisão judicial, exigindo-se, no caso de dissolução, o **trânsito em julgado**.",
      "id": "8d2e2070-ac34-4134-af40-76a08fb43aa9",
      "pegadinha": "A autorização expressa exigida para representar filiados não é uma autorização do Estado para criar a associação.",
      "ponto_de_prova": "Não confunda: a **criação** da associação (e, na forma da lei, a de cooperativas) independe de autorização; a **representação dos filiados** exige autorização expressa; e a **dissolução compulsória** ou **suspensão de atividades** só por decisão judicial — a dissolução, além disso, exige trânsito em julgado.",
      "tipo": "conceito",
      "titulo": "Liberdade de associação"
    },
    {
      "dica": "Associe três situações urgentes — flagrante, desastre e socorro — a uma situação condicionada ao período diurno: determinação judicial.",
      "id": "e1df1bbd-1882-489c-81dc-d7583b7c3c2b",
      "pergunta": "Sem consultar o texto, quais são as quatro hipóteses constitucionais de ingresso na casa sem consentimento do morador?",
      "resposta": "**Flagrante delito, desastre, prestação de socorro e, durante o dia, determinação judicial.**",
      "tipo": "recall",
      "titulo": "Mapa mental do domicílio"
    },
    {
      "dica": "Criação e reunião: liberdade. Representação: manifestação expressa do filiado.",
      "id": "90d4381f-c0e2-4697-ad77-56b9abd41694",
      "pergunta": "Complete mentalmente: reunião em local aberto ao público ______ de autorização; criação de associação ______ de autorização; representação dos filiados pela associação exige autorização ______.",
      "resposta": "A reunião **independe** de autorização; a criação da associação também **independe** de autorização; a representação dos filiados exige autorização **expressa**.",
      "tipo": "recall",
      "titulo": "Reunião e associação: qual autorização é exigida?"
    },
    {
      "alternativas": [
        {
          "letra": "A",
          "texto": "A reunião pacífica e sem armas em local aberto ao público depende de autorização da autoridade competente, sendo dispensado o prévio aviso."
        },
        {
          "letra": "B",
          "texto": "A determinação judicial permite o ingresso em domicílio sem consentimento do morador em qualquer horário."
        },
        {
          "letra": "C",
          "texto": "O sigilo das comunicações telefônicas pode ser afastado por decisão administrativa para qualquer finalidade de interesse público."
        },
        {
          "letra": "D",
          "texto": "A criação de associações independe de autorização, mas a entidade associativa precisa de autorização expressa para representar seus filiados judicial ou extrajudicialmente."
        }
      ],
      "enunciado": "Com base exclusivamente nos direitos individuais e coletivos previstos no art. 5º da Constituição Federal, assinale a alternativa correta.",
      "gabarito": "D",
      "id": "646c9c83-26cc-459a-9436-24e6cc16793e",
      "pegadinha": "O ponto central é não misturar três regimes diferentes: prévio aviso para reunião, independência de autorização para criar associação e autorização expressa para representar filiados.",
      "raciocinio": "A alternativa D reproduz duas regras constitucionais: a criação de associações **independe de autorização**, enquanto a representação dos filiados exige autorização **expressa**.\n\nA alternativa A está errada porque reunião não depende de autorização; exige prévio aviso. A alternativa B está errada porque o ingresso por determinação judicial somente é admitido **durante o dia**. A alternativa C está errada porque a ressalva relativa às comunicações telefônicas exige **ordem judicial**, nas hipóteses e na forma legais, para investigação criminal ou instrução processual penal.",
      "tipo": "questao_resolvida"
    },
    {
      "id": "1161ed27-8546-4047-9e16-5952a7eb3565",
      "pontos": [
        "**Igualdade:** todos são iguais perante a lei; homens e mulheres são iguais em direitos e obrigações nos termos da Constituição.",
        "**Expressão:** manifestação do pensamento é livre, mas o anonimato é vedado; atividade intelectual, artística, científica e de comunicação independe de censura ou licença.",
        "**Privacidade:** intimidade, vida privada, honra e imagem são invioláveis, com indenização por dano material ou moral decorrente da violação.",
        "**Casa:** consentimento do morador é a regra; exceções são flagrante, desastre, socorro e ordem judicial durante o dia.",
        "**Sigilo telefônico:** ressalva mediante ordem judicial, na forma legal, para investigação criminal ou instrução processual penal.",
        "**Religião:** liberdade de consciência e crença, livre culto, proteção dos locais e liturgias e assistência religiosa em entidades civis e militares de internação coletiva.",
        "**Direitos coletivos:** reunião sem autorização, mas com prévio aviso; associação lícita sem autorização estatal, vedado caráter paramilitar, e representação de filiados mediante autorização expressa."
      ],
      "tipo": "resumo_visual",
      "titulo": "Direitos individuais e coletivos em uma passada de olhos"
    }
  ],
  "schema_version": 1
}
$ESTRUTURA$::jsonb
where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

-- ================= POSCONDICOES =================
do $$
declare
  v_status text;
  v_numero_versao int;
  v_qtd_componentes int;
  v_qtd_artigos int;
  v_explicacao_assoc text;
  v_ponto_prova_assoc text;
  v_componente_xv jsonb;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes'), jsonb_array_length(estrutura->'artigos_abordados')
  into v_status, v_numero_versao, v_qtd_componentes, v_qtd_artigos
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_status <> 'rascunho' then raise exception 'POSCOND: status mudou inesperadamente para %', v_status; end if;
  if v_numero_versao <> 1 then raise exception 'POSCOND: numero_versao mudou inesperadamente para %', v_numero_versao; end if;
  if v_qtd_componentes <> 14 then raise exception 'POSCOND: esperado 14 componentes (13 antigos + 1 novo de XV), encontrado %', v_qtd_componentes; end if;
  if v_qtd_artigos <> 16 then raise exception 'POSCOND: esperado 16 artigos_abordados, encontrado %', v_qtd_artigos; end if;

  select c.value->>'explicacao', c.value->>'ponto_de_prova'
  into v_explicacao_assoc, v_ponto_prova_assoc
  from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
    and c.value->>'id' = '8d2e2070-ac34-4134-af40-76a08fb43aa9';

  if position('compulsoriamente dissolvidas' in v_explicacao_assoc) = 0 then
    raise exception 'POSCOND: explicacao do componente de associacao nao contem a correcao sobre XIX';
  end if;
  if position('dissolução compulsória' in v_ponto_prova_assoc) = 0 then
    raise exception 'POSCOND: ponto_de_prova do componente de associacao nao contem a correcao sobre XIX';
  end if;

  select c.value
  into v_componente_xv
  from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
    and c.value->>'id' = 'a15c7024-3e9b-4c1a-9f22-5d8e2b6c4a19';

  if v_componente_xv is null then raise exception 'POSCOND: novo componente de XV (liberdade de locomocao) nao encontrado'; end if;
  if v_componente_xv->>'tipo' <> 'conceito' then raise exception 'POSCOND: novo componente de XV deveria ser tipo conceito'; end if;
  if v_componente_xv->>'explicacao' is null or v_componente_xv->>'exemplo' is null or v_componente_xv->>'pegadinha' is null or v_componente_xv->>'ponto_de_prova' is null then
    raise exception 'POSCOND: novo componente de XV nao tem a estrutura pedagogica completa (explicacao/exemplo/pegadinha/ponto_de_prova)';
  end if;
  if position('tempo de paz' in (v_componente_xv->>'explicacao')) = 0 then
    raise exception 'POSCOND: explicacao do novo componente XV nao menciona a condicionante "tempo de paz"';
  end if;

  if not (
    select estrutura->'artigos_abordados' ? 'art. 5º, XV'
    from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
  ) then
    raise exception 'POSCOND: art. 5º, XV ausente de artigos_abordados';
  end if;
  if not (
    select estrutura->'artigos_abordados' ? 'art. 5º, XIX'
    from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
  ) then
    raise exception 'POSCOND: art. 5º, XIX ausente de artigos_abordados';
  end if;

  raise notice 'POSCOND OK: 14 componentes (13 antigos + 1 novo de XV), 16 artigos_abordados, componente de associacao com a correcao XIX, novo componente XV com estrutura pedagogica completa';
end $$;

-- Confirma que NENHUMA outra aula_versao foi tocada.
do $$
declare
  v_hash_depois text;
  v_hash_antes text;
begin
  select h into v_hash_antes from _hash_outras_versoes_antes_dgf_final;
  select md5(string_agg(id::text || estrutura::text, '|' order by id))
  into v_hash_depois
  from public.aula_versoes
  where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS aula_versoes mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'POSCOND OK: nenhuma outra aula_versao foi tocada (hash de conteudo identico)';
end $$;

-- ================= REVERT (restaura a partir do snapshot OLD) =================
update public.aula_versoes av
set estrutura = t.estrutura, status = t.status
from _snapshot_old_dgf_final t
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
  join _snapshot_old_dgf_final t on t.aula_versao_id = av.id
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if not v_estrutura_igual then raise exception 'OLD_FINAL: estrutura NAO retornou identica a original'; end if;
  if not v_status_igual then raise exception 'OLD_FINAL: status NAO retornou identico ao original'; end if;

  raise notice 'OLD_FINAL OK: estrutura e status identicos ao estado OLD original (13 componentes, 14 artigos_abordados, sem XV/XIX) — reversao comprovada';
end $$;

rollback;
