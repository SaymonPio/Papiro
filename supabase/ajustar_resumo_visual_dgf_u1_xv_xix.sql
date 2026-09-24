-- AJUSTE CIRURGICO DO RESUMO VISUAL — unidade "Direitos Individuais e
-- Coletivos Fundamentais" (BM RS) — atualiza o componente `resumo_visual`
-- para refletir os incisos XV e XIX, ja ensinados nos componentes
-- proprios ("Liberdade de locomocao") e complementar ("Liberdade de
-- associacao") desde a Fase 9.2, mas ainda ausentes do resumo final.
--
-- Mandato: "PAPIRO — FECHAMENTO FINAL DA UNIDADE 1 DGF / CORRIGIR APENAS
-- O RESUMO VISUAL". Mesmo padrao ja usado em
-- ajustar_aula_dgf_u1_final.sql / ajustar_aula_dgf_u1_caput_xviii.sql
-- (UPDATE direto em aula_versoes.estrutura — precedente ja confirmado
-- via pg_proc: nao existe RPC/admin-writer para editar conteudo de
-- aula).
--
-- Alteracao UNICA: dentro do componente `resumo_visual`
-- (id 1161ed27-8546-4047-9e16-5952a7eb3565), o array `pontos` ganha
-- 1 item NOVO ("Locomoção", inserido logo apos "Sigilo telefônico" e
-- antes de "Religião" -- mesma posicao relativa do componente real de
-- XV na aula, entre "Sigilo de correspondencia" e "Liberdade
-- religiosa") e 1 item ATUALIZADO ("Direitos coletivos", que passa a
-- tambem resumir a suspensao de atividades e a dissolucao compulsoria
-- por decisao judicial, com transito em julgado exigido para a
-- dissolucao) -- preservando tudo o que ja existia sobre associacao
-- licita, vedacao de carater paramilitar, criacao sem autorizacao e
-- representacao mediante autorizacao expressa. Os outros 5 pontos
-- (Igualdade, Expressao, Privacidade, Casa, Religiao) ficam
-- byte-a-byte identicos. `id`, `tipo` e `titulo` do componente
-- resumo_visual nao mudam. Nenhum dos OUTROS 13 componentes muda.
-- `artigos_abordados` (ja em 16 desde a Fase 9.2) nao muda.
--
-- NAO regenera a aula. NAO cria nova aula_versao (numero_versao
-- permanece 1). NAO publica. NAO toca em: diagnostico, conceitos
-- (incl. componente XV e componente de associacao), recalls, questao
-- resolvida, fontes, artigos_abordados, artigos_esperados, status,
-- questoes da pratica, vinculos.
--
-- ROLLBACK-TESTADO em
-- ajustar_resumo_visual_dgf_u1_xv_xix_teste_rollback.sql (preparado
-- nesta mesma rodada; execucao contra LIVE fica para uma fase de
-- rollback-test dedicada, nao esta).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_resumo_dgf on commit drop as
select av.id as aula_versao_id, av.estrutura, av.status
from public.aula_versoes av
where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

create temporary table _hash_outras_versoes_antes_resumo_dgf on commit drop as
select md5(string_agg(id::text || estrutura::text, '|' order by id)) as h
from public.aula_versoes
where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_status text;
  v_numero_versao int;
  v_qtd_componentes int;
  v_qtd_artigos int;
  v_hash text;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes'), jsonb_array_length(estrutura->'artigos_abordados'), md5(estrutura::text)
  into v_status, v_numero_versao, v_qtd_componentes, v_qtd_artigos, v_hash
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_status is null then raise exception 'PRECOND: aula_versao nao encontrada'; end if;
  if v_status <> 'rascunho' then raise exception 'PRECOND: status esperado rascunho, encontrado %', v_status; end if;
  if v_numero_versao <> 1 then raise exception 'PRECOND: numero_versao esperado 1, encontrado %', v_numero_versao; end if;
  if v_qtd_componentes <> 14 then raise exception 'PRECOND: esperado 14 componentes, encontrado %', v_qtd_componentes; end if;
  if v_qtd_artigos <> 16 then raise exception 'PRECOND: esperado 16 artigos_abordados, encontrado %', v_qtd_artigos; end if;
  if v_hash <> '2659c2eb77abad7915039de94aa807d6' then
    raise exception 'PRECOND: hash da estrutura atual diverge do estado auditado apos a Fase 9.2 — possivel alteracao concorrente, abortar';
  end if;

  raise notice 'PRECOND OK: status=rascunho, numero_versao=1, 14 componentes, 16 artigos_abordados, hash da estrutura confere com o estado pos-Fase-9.2';
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
        "**Locomoção:** livre no território nacional em tempo de paz; qualquer pessoa pode entrar, permanecer ou sair com seus bens, nos termos da lei.",
        "**Religião:** liberdade de consciência e crença, livre culto, proteção dos locais e liturgias e assistência religiosa em entidades civis e militares de internação coletiva.",
        "**Direitos coletivos:** reunião sem autorização, mas com prévio aviso; associação lícita sem autorização estatal, vedado caráter paramilitar, representação de filiados mediante autorização expressa, e suspensão de atividades ou dissolução compulsória somente por decisão judicial (a dissolução exige também trânsito em julgado)."
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
  v_resumo jsonb;
  v_pontos_texto text;
begin
  select status, numero_versao, jsonb_array_length(estrutura->'componentes'), jsonb_array_length(estrutura->'artigos_abordados')
  into v_status, v_numero_versao, v_qtd_componentes, v_qtd_artigos
  from public.aula_versoes where id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_status <> 'rascunho' then raise exception 'POSCOND: status mudou inesperadamente para %', v_status; end if;
  if v_numero_versao <> 1 then raise exception 'POSCOND: numero_versao mudou inesperadamente para %', v_numero_versao; end if;
  if v_qtd_componentes <> 14 then raise exception 'POSCOND: esperado 14 componentes (nenhum adicionado/removido), encontrado %', v_qtd_componentes; end if;
  if v_qtd_artigos <> 16 then raise exception 'POSCOND: esperado 16 artigos_abordados (inalterado), encontrado %', v_qtd_artigos; end if;

  select c.value
  into v_resumo
  from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
    and c.value->>'id' = '1161ed27-8546-4047-9e16-5952a7eb3565';

  if v_resumo is null then raise exception 'POSCOND: componente resumo_visual nao encontrado apos o UPDATE'; end if;
  if v_resumo->>'tipo' <> 'resumo_visual' then raise exception 'POSCOND: tipo do componente alvo nao e resumo_visual'; end if;
  if jsonb_array_length(v_resumo->'pontos') <> 8 then
    raise exception 'POSCOND: esperado 8 pontos no resumo (7 antigos + 1 novo de locomocao), encontrado %', jsonb_array_length(v_resumo->'pontos');
  end if;

  select string_agg(p.value::text, ' ') into v_pontos_texto from jsonb_array_elements_text(v_resumo->'pontos') p(value);

  if position('Locomoção' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo nao contem o novo ponto de Locomocao';
  end if;
  if position('em tempo de paz' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo nao contem a condicionante "em tempo de paz"';
  end if;
  if position('suspensão de atividades' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo nao contem a suspensao de atividades das associacoes';
  end if;
  if position('dissolução compulsória' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo nao contem a dissolucao compulsoria das associacoes';
  end if;
  if position('trânsito em julgado' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo nao contem a exigencia de transito em julgado para a dissolucao';
  end if;
  if position('associação lícita' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo perdeu a mencao a associacao licita (conteudo antigo preservado)';
  end if;
  if position('caráter paramilitar' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo perdeu a mencao a vedacao de carater paramilitar (conteudo antigo preservado)';
  end if;
  if position('autorização expressa' in v_pontos_texto) = 0 then
    raise exception 'POSCOND: resumo perdeu a mencao a representacao mediante autorizacao expressa (conteudo antigo preservado)';
  end if;

  -- confirma que os outros 6 pontos antigos (Igualdade/Expressao/
  -- Privacidade/Casa/Sigilo telefonico/Religiao) permanecem, byte-a-
  -- byte, dentro do array.
  if not (v_resumo->'pontos' ? '**Igualdade:** todos são iguais perante a lei; homens e mulheres são iguais em direitos e obrigações nos termos da Constituição.') then
    raise exception 'POSCOND: ponto de Igualdade nao esta mais identico ao original';
  end if;
  if not (v_resumo->'pontos' ? '**Expressão:** manifestação do pensamento é livre, mas o anonimato é vedado; atividade intelectual, artística, científica e de comunicação independe de censura ou licença.') then
    raise exception 'POSCOND: ponto de Expressao nao esta mais identico ao original';
  end if;
  if not (v_resumo->'pontos' ? '**Privacidade:** intimidade, vida privada, honra e imagem são invioláveis, com indenização por dano material ou moral decorrente da violação.') then
    raise exception 'POSCOND: ponto de Privacidade nao esta mais identico ao original';
  end if;
  if not (v_resumo->'pontos' ? '**Casa:** consentimento do morador é a regra; exceções são flagrante, desastre, socorro e ordem judicial durante o dia.') then
    raise exception 'POSCOND: ponto de Casa nao esta mais identico ao original';
  end if;
  if not (v_resumo->'pontos' ? '**Sigilo telefônico:** ressalva mediante ordem judicial, na forma legal, para investigação criminal ou instrução processual penal.') then
    raise exception 'POSCOND: ponto de Sigilo telefonico nao esta mais identico ao original';
  end if;
  if not (v_resumo->'pontos' ? '**Religião:** liberdade de consciência e crença, livre culto, proteção dos locais e liturgias e assistência religiosa em entidades civis e militares de internação coletiva.') then
    raise exception 'POSCOND: ponto de Religiao nao esta mais identico ao original';
  end if;

  raise notice 'POSCOND OK: 14 componentes, 16 artigos_abordados, resumo_visual com 8 pontos (Locomocao novo, Direitos coletivos atualizado com XIX, os outros 6 pontos preservados byte-a-byte)';
end $$;

-- Confirma que os OUTROS 13 componentes (tudo exceto resumo_visual)
-- permanecem byte-a-byte identicos ao snapshot OLD.
do $$
declare
  v_outros_antes jsonb;
  v_outros_depois jsonb;
begin
  select jsonb_agg(x.value order by x.ordinality)
  into v_outros_antes
  from _snapshot_old_resumo_dgf t,
       jsonb_array_elements(t.estrutura->'componentes') with ordinality as x(value, ordinality)
  where x.value->>'id' <> '1161ed27-8546-4047-9e16-5952a7eb3565';

  select jsonb_agg(x.value order by x.ordinality)
  into v_outros_depois
  from public.aula_versoes av,
       jsonb_array_elements(av.estrutura->'componentes') with ordinality as x(value, ordinality)
  where av.id = '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid
    and x.value->>'id' <> '1161ed27-8546-4047-9e16-5952a7eb3565';

  if v_outros_antes is distinct from v_outros_depois then
    raise exception 'POSCOND: um ou mais dos outros 13 componentes mudou — este patch so pode tocar o resumo_visual';
  end if;

  raise notice 'POSCOND OK: os outros 13 componentes permanecem byte-a-byte identicos ao snapshot OLD';
end $$;

-- Confirma que NENHUMA outra aula_versao foi tocada.
do $$
declare
  v_hash_depois text;
  v_hash_antes text;
begin
  select h into v_hash_antes from _hash_outras_versoes_antes_resumo_dgf;
  select md5(string_agg(id::text || estrutura::text, '|' order by id))
  into v_hash_depois
  from public.aula_versoes
  where id <> '52756262-8be4-4fb2-a9f3-2f5a158ea1d4'::uuid;

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS aula_versoes mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'POSCOND OK: nenhuma outra aula_versao foi tocada (hash de conteudo identico)';
end $$;

commit;
