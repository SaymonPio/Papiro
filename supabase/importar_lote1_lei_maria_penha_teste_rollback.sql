-- ============================================================================
-- LOTE 1 — IMPORTACAO DAS 85 QUESTOES VALIDAS DA LEI MARIA DA PENHA
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-lote1-import-harness.mjs a
-- partir de supabase/lote_1_reclassificacao_supabase_86.csv
-- (importar_agora = 'sim', 85 linhas). NAO editar este arquivo a mao — editar
-- o CSV/gerador e regerar, para manter os dois em sincronia. Fonte da
-- verdade da classificacao/auditoria: supabase/lote_1_reclassificacao_supabase_86.md.
--
-- Caderno 950 (colisao de tec_id, PROBLEMATICA) e caderno 999 (sem metadados
-- confirmaveis) permanecem FORA — nao aparecem em nenhuma linha abaixo,
-- confirmado por assert antes de qualquer escrita.
--
-- Achados de qualidade de dados tratados nesta geracao (ver .md do Lote 1
-- para o restante da auditoria):
--   - 12 questoes formato CEBRASPE/VUNESP "julgue o item" (gabarito Certo/
--     Errado) vieram com a coluna "alternativas" vazia — a extracao original
--     colou "Certo Errado" ao final do proprio enunciado. Corrigido aqui:
--     sufixo removido do enunciado, alternativas geradas como texto="Certo"/
--     "Errado" (o par literal do proprio formato, correta = gabarito).
--   - As 73 restantes vinham com prefixo de letra ("a) ", "b) "...) dentro do
--     texto de cada alternativa — removido para bater com o formato ja usado
--     pelas questoes reais existentes (nenhuma tem prefixo de letra
--     armazenado; a letra e responsabilidade da UI, nao do dado).
--   - Confirmado por consulta direta ao Supabase (MCP, so leitura) antes de
--     gerar este arquivo: nenhum dos 85 tec_id ja aparece em questoes.fonte
--     em NENHUMA materia/curso — sem risco de duplicata cega.
--
-- Composicao: 85 questoes novas, 364 alternativas,
-- 9 sem vinculo de unidade (banco geral, elegiveis so a
-- Missao Final apos o patch de selecionar_candidatas_conteudo — commit
-- 027a3f6), 76 com vinculo (8
-- delas multiunidade), 84 linhas de vinculo ao todo.
--
-- Usa a MESMA RPC administrativa do app para os vinculos
-- (public.classificar_questao_unidade_admin), no MESMO padrao de
-- supabase/classificar_questoes_unidades_lei_maria_penha_teste_rollback.sql:
-- como esta sessao roda como "postgres" via MCP/SQL Editor (sem sessao real
-- de auth), simula a claim JWT do unico administrador cadastrado com "set
-- local" — efeito restrito a esta transacao, nunca contorna eh_admin().
--
-- Precisa rodar com um role de ESCRITA (nao funciona via MCP read-only).
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — prova de ausencia de efeito colateral fora do esperado.
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

-- ----------------------------------------------------------------------------
-- Staging: 85 questoes (chave local = caderno_numero, nunca usado como id
-- real — o id real vem do IDENTITY de public.questoes no INSERT abaixo).
-- ----------------------------------------------------------------------------
create temporary table _lote1_questoes (
  caderno_numero int primary key,
  tec_id bigint,
  banca text,
  concurso text,
  ano int,
  enunciado text,
  fonte text
) on commit drop;

insert into _lote1_questoes (caderno_numero, tec_id, banca, concurso, ano, enunciado, fonte) values
  (216, 3564240, 'IGEDUC', 'ASoc (Pref Japaratinga)/Pref Japaratinga/2025', 2025, 'A Lei Maria da Penha foi criada para prevenir, punir e erradicar a violência doméstica e familiar contra a mulher no Brasil, estabelecendo mecanismos para garantir a proteção das vítimas e a responsabilização dos agressores. Sobre essa legislação, assinale a alternativa correta.', 'TEC Concursos — questão 3564240 — IGEDUC — ASoc (Pref Japaratinga)/Pref Japaratinga/2025'),
  (221, 3520358, 'FACAPE', 'Ed Soc (Pref Afrânio)/Pref Afrânio/2025', 2025, 'Paula registrou boletim de ocorrência contra seu ex-companheiro, Fábio, com quem conviveu em união estável por cinco anos. Segundo o relato dela, ele passou a enviar dezenas de mensagens diárias com xingamentos, humilhações e ameaças veladas, além de vigiá-la nas redes sociais e comparecer repetidamente em seu trabalho. Diante da situação, foi requerido o reconhecimento da prática de violência psicológica contra a mulher. Considerando a situação narrada e a legislação aplicável, assinale a alternativa correta.', 'TEC Concursos — questão 3520358 — FACAPE — Ed Soc (Pref Afrânio)/Pref Afrânio/2025'),
  (260, 3824093, 'Instituto ACCESS', 'ASoc (Pref Rodeiro)/Pref Rodeiro/2025', 2025, 'Na forma da Lei Maria da Penha, nome pelo qual ficou popularmente conhecido o instrumento que criou mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do art. 226, § 8º da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Discriminação contra as Mulheres e da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; altera o Código de Processo Penal, o Código Penal e a Lei de Execução Penal; e dá outras providências, podemos afirmar que a violência psicológica se configura corretamente quando a conduta do(a) agressor(a)', 'TEC Concursos — questão 3824093 — Instituto ACCESS — ASoc (Pref Rodeiro)/Pref Rodeiro/2025'),
  (275, 3138220, 'IGEDUC', 'Vig (CM Tuparetama)/CM Tuparetama/2024', 2024, 'Sobre a Lei “Maria da Penha”, assinale a alternativa correta.', 'TEC Concursos — questão 3138220 — IGEDUC — Vig (CM Tuparetama)/CM Tuparetama/2024'),
  (284, 3124680, 'FAUEL', 'Ed Soc (Pref Maringá)/Pref Maringá/2024', 2024, 'Considerando que a Lei Maria da Penha (Lei nº 11.340/2006) é um marco na proteção e no combate à violência doméstica e familiar contra a mulher no Brasil, analise as afirmativas a seguir. I. A Lei Maria da Penha prevê a criação de juizados especiais de violência doméstica e familiar contra a mulher, que são responsáveis por processar e julgar os casos de violência doméstica, bem como promover o atendimento multidisciplinar às vítimas. II. A Lei Maria da Penha estabelece medidas protetivas de urgência, que podem ser solicitadas pela vítima para garantir sua segurança e integridade física, como o afastamento do agressor do lar ou local de convivência com a vítima, a suspensão da posse ou restrição do porte de armas e a determinação de prestação de alimentos provisórios ou provisionais. III. A Lei Maria da Penha aplica-se a todas as formas de violência doméstica e familiar contra a mulher, incluindo violência física, psicológica, sexual, patrimonial e moral, abrangendo relações de convivência esporádica, sendo necessária a coabitação entre vítima e agressor para a caracterização da violência doméstica. Está correto o que se afirma em 17/42', 'TEC Concursos — questão 3124680 — FAUEL — Ed Soc (Pref Maringá)/Pref Maringá/2024'),
  (370, 2936068, 'FGV', 'Ass Soc (TJ SC)/TJ SC/2024', 2024, 'Analise as situações hipotéticas a seguir. I. O marido de AGV, 22 anos, é policial militar e a agrediu fisicamente gerando inúmeras lesões de natureza média. Neste caso, poderá o juiz aplicar, de imediato, suspensão da posse ou restrição do porte de armas. II. APL, 35 anos, cessou a relação amorosa com seu namorado no dia 02/03/22; em 10/04/23, movido por ciúmes ao vê-la com um novo companheiro, seu ex- namorado a agrediu verbalmente em via pública. Nesta situação não deve ser aplicada a Lei Maria da Penha pelo eventual delito cometido pelo ex-namorado contra APL. III. ACV, 38 anos, é vítima de constantes agressões pelo marido; desejando dar fim a esta situação ela irá propor ação de divórcio. Neste caso, a ofendida deverá propor ação de divórcio ou de dissolução de união estável no Juizado de Violência Doméstica e Familiar contra a Mulher. IV. CAG, 28 anos, é comprovadamente vítima de esbulho patrimonial por seu esposo. Nesta situação, a prática de violência patrimonial não encontra amparo no âmbito do ordenamento jurídico abarcado pela Lei nº 11.340/2006. No que concerne à Lei nº 11.340/2006 – Lei Maria da Penha, está correto o que se afirma em', 'TEC Concursos — questão 2936068 — FGV — Ass Soc (TJ SC)/TJ SC/2024'),
  (378, 2919563, 'MS (SARMENTO)', 'ASoc Sau (Pref Adustina)/Pref Adustina/2024', 2024, 'Analise as afirmativas a seguir: I. A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos, cuja política pública que visa coibir a violência doméstica e familiar contra a mulher deve ser feita pela articulação de ações da União, dos Estados, do Distrito Federal e dos Municípios e de ações não- governamentais. II. Define-se violência doméstica e familiar contra a mulher qualquer ação baseada no gênero que lhe cause morte, lesão, sofrimento físico ou sexual. Marque a alternativa CORRETA:', 'TEC Concursos — questão 2919563 — MS (SARMENTO) — ASoc Sau (Pref Adustina)/Pref Adustina/2024'),
  (393, 2718877, 'IBAM', 'CSoc (Pref Guarujá (SP))/Pref Guarujá (SP)/2023', 2023, 'Ares passou a ridicularizar e a difamar publicamente Atena, sua namorada havia dois anos, como expressão de seu excessivo ciúme e visando controlar suas ações. Atena vem suportando tal sofrimento porque está sob ameaça de morte de seu filho menor, fruto de relação anterior, caso ela se separe de Ares. Não suportando mais a situação nociva, ela toma coragem e rompe com Ares. Pouco tempo depois da separação, Atena recebe uma ligação de Ares que lhe diz para cuidar mais do filho, pois está em perigo, e finaliza abruptamente a ligação. No dia seguinte, Ares desfere um tapa no rosto de Atena quando ela saía da faculdade. Considerando-se o caso hipotético, assinale a afirmativa correta.', 'TEC Concursos — questão 2718877 — IBAM — CSoc (Pref Guarujá (SP))/Pref Guarujá (SP)/2023'),
  (395, 3622849, 'URI', 'ASoc (Pref Entre-Ijuís)/Pref Entre-Ijuís/2023', 2023, 'A Lei Maria da Penha (Lei nº 11.340 de 07 de agosto de 2006) “cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Violência contra a Mulher, da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher e de outros tratados internacionais ratificados pela República Federativa do Brasil; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; e estabelece medidas de assistência e proteção às mulheres em situação de violência doméstica e familiar”. Segundo esta Lei, é caracterizada como violência doméstica contra mulher', 'TEC Concursos — questão 3622849 — URI — ASoc (Pref Entre-Ijuís)/Pref Entre-Ijuís/2023'),
  (411, 2925122, 'IBFC', 'ASoc (EBSERH)/HU Brasil/2023', 2023, 'De acordo com o art. 29 da lei nº. 11.340/06, os Juizados de Violência Doméstica e Familiar contra a Mulher que vierem a ser criados poderão contar com uma equipe de atendimento multidisciplinar, a ser integrada por profissionais especializados nas áreas psicossocial, jurídica e de saúde. Nesse sentido, é correto afirmar:', 'TEC Concursos — questão 2925122 — IBFC — ASoc (EBSERH)/HU Brasil/2023'),
  (429, 2832645, 'FUNDATEC', 'ASG (CM Sapucaia do Sul)/CM Sapucaia do Sul/2023', 2023, 'A respeito da Lei nº 11.340, de 7 de agosto de 2006, Lei Maria da Penha, assinale a alternativa correta.', 'TEC Concursos — questão 2832645 — FUNDATEC — ASG (CM Sapucaia do Sul)/CM Sapucaia do Sul/2023'),
  (436, 2828648, 'FCC', 'AJ (TJ BA)/TJ BA/Apoio Especializado/Pedagogo/2023', 2023, 'Maria é médica e é casada com Diego, que é engenheiro. Ambos são servidores concursados da Prefeitura de Agudo. O casal tem dois filhos: João, de 18 anos, e Alice, de 13 anos. Certo dia, João chegou em casa alcoolizado, pois havia passado a noite ingerindo bebida alcoólica com os amigos em uma festa. No momento, Maria estava sozinha em casa, pois Diego já havia saído para trabalhar e Alice estava na escola. Vendo o estado em que se encontrava João, Maria pediu que ele tomasse um banho frio e um café, para que pudessem conversar sobre o ocorrido. João, que estava visivelmente alterado, começou a gritar com a mãe e agredi-la com socos, tapas e chutes, empreendendo fuga da residência na sequência. Após as agressões, Maria conseguiu ligar para seu marido, tendo sido socorrida e levada ao hospital para atendimento. Com base nos fatos narrados, assinale a alternativa correta, conforme as disposições da Lei Maria da Penha.', 'TEC Concursos — questão 2828648 — FCC — AJ (TJ BA)/TJ BA/Apoio Especializado/Pedagogo/2023'),
  (441, 2769196, 'INSTITUTO MAIS', 'GCM (Pref Santos)/Pref Santos/2023', 2023, 'De acordo com o disposto na Lei Maria da Penha (Lei nº 11.340/2006), a proteção e os direitos das mulheres em situação de violência doméstica e familiar incluem:', 'TEC Concursos — questão 2769196 — INSTITUTO MAIS — GCM (Pref Santos)/Pref Santos/2023'),
  (468, 2582271, 'Unifil', 'Educ (Pref Tamarana)/Pref Tamarana/2023', 2023, 'De acordo com a Lei Maria da Penha, que institui mecanismos para coibir a violência doméstica e familiar contra a mulher, é correto afirmar que:', 'TEC Concursos — questão 2582271 — Unifil — Educ (Pref Tamarana)/Pref Tamarana/2023'),
  (470, 2561017, 'FUNDATEC', 'AST (PROCERGS)/PROCERGS/Técnico em Administração/2023', 2023, 'De acordo com Lei nº 11.340/2006, informe se é verdadeiro (V) ou falso (F) para o que se afirma e assinale a alternativa com a sequência correta. ( ) Para a configuração da violência doméstica em relações íntimas de afeto, é necessária a coabitação com o agressor. ( ) É assegurada à mulher em situação de violência doméstica ou familiar, a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até 9 meses. ( ) Nas causas decorrentes da prática de violência doméstica e familiar contra a mulher, os atos processuais não poderão ser realizados em horário noturno. ( ) Constatada a violência doméstica o juiz poderá determinar, de imediato, a prestação de alimentos provisionais. ( ) Nos casos de violência doméstica, o juiz poderá determinar o afastamento do agressor do lar, mas não caberá a prisão preventiva.', 'TEC Concursos — questão 2561017 — FUNDATEC — AST (PROCERGS)/PROCERGS/Técnico em Administração/2023'),
  (481, 2480489, 'Instituto ACCESS', 'GCM (Pref RP)/Pref RP/2023', 2023, 'Considere a lei alcunhada de Maria da Penha, que estabelece normativa sobre a violência doméstica contra a mulher. Com base em tal regra de direito, é correto afirmar que:', 'TEC Concursos — questão 2480489 — Instituto ACCESS — GCM (Pref RP)/Pref RP/2023'),
  (484, 2460051, 'FUNDATEC', 'ACS (Pref Porto Alegre)/Pref Porto Alegre/2023', 2023, 'Rute, de 75 anos de idade, viúva, com múltiplos problemas de saúde, reside com a filha Teresa, de 42 anos de idade, e seu esposo João, de 49 anos de idade. Sempre que o casal discute, entre outros motivos, pelo ciúme de João para com a esposa, Rute fica muito nervosa e passa mal. Algumas vezes já aconteceu de João agredir fisicamente a esposa e verbalmente a sogra, que fica preocupada com a possibilidade da situação se agravar, pois João tem uma arma em casa. Considerando essa situação hipotética, assinale a opção correta, com base na Lei Maria da Penha.', 'TEC Concursos — questão 2460051 — FUNDATEC — ACS (Pref Porto Alegre)/Pref Porto Alegre/2023'),
  (534, 2028910, 'CEBRASPE (CESPE)', 'Assist Soc (FUB)/FUB/2022', 2022, 'Considere as afirmações abaixo. I - Para os efeitos da Lei, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. II - Para os efeitos da Lei, apenas configura violência doméstica contra a mulher a ação praticada pelo marido, no espaço restrito do âmbito familiar. III - A política pública que visa a coibir a violência doméstica e familiar contra a mulher far-se-á por meio de um conjunto articulado de ações da União, dos Estados, do Distrito Federal e dos Municípios e de ações não governamentais. IV - Constatada a prática de violência doméstica e familiar contra a mulher, o Delegado poderá suspender a posse de armas do agressor, sendo vedadas, sempre, medidas arbitrárias como o afastamento do lar, pelo princípio constitucional de proteção da família. Quais estão de acordo com a Lei Federal nº 11.340, de 07 de agosto de 2006, que cria mecanismos para coibir a violência doméstica e familiar contra a mulher e dá outras providências?', 'TEC Concursos — questão 2028910 — CEBRASPE (CESPE) — Assist Soc (FUB)/FUB/2022'),
  (561, 3095842, 'EJUD PI', 'Estag (TJ PI)/TJ PI/Serviço Social/2022', 2022, 'A vítima de violência, por meio da lei que garante a assistência à mulher em situação de violência doméstica e familiar, pode ter:', 'TEC Concursos — questão 3095842 — EJUD PI — Estag (TJ PI)/TJ PI/Serviço Social/2022'),
  (574, 2748613, 'IVIN', 'CSoc (Pref Estreito)/Pref Estreito/2022', 2022, 'Analise as afirmativas; marque V para as verdadeiras e F para as falsas. ( ) Cabe singularmente à União criar condições necessárias para o efetivo exercício dos direitos vinculados à proteção da mulher contra a violência doméstica. ( ) Com relação à violência doméstica contra a mulher pode- -se afirmar que se constitui em uma das formas de violação dos direitos da pessoa humana. ( ) É atribuição exclusiva do Município onde a mulher reside desenvolver políticas públicas que coíbam a violência doméstica contra a mulher. ( ) É direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado. A sequência está correta em', 'TEC Concursos — questão 2748613 — IVIN — CSoc (Pref Estreito)/Pref Estreito/2022'),
  (577, 2505524, 'FUNDATEC', 'AEI (Paim Filho)/Pref Paim Filho/2022', 2022, 'No que diz respeito à violência doméstica e familiar contra a mulher, objeto da Lei nº 11.340/2006 (Lei Maria da Penha), assinale a afirmativa correta.', 'TEC Concursos — questão 2505524 — FUNDATEC — AEI (Paim Filho)/Pref Paim Filho/2022'),
  (606, 1752622, 'CEBRASPE (CESPE)', 'Prom Jus (MPE SC)/MPE SC/2021', 2021, 'Considerando o diploma legal conhecido como Lei Maria da Penha (Lei nº 11.340/2006) e a jurisprudência dos Tribunais Superiores sobre a violência doméstica e familiar contra a mulher é possível afirmar que:', 'TEC Concursos — questão 1752622 — CEBRASPE (CESPE) — Prom Jus (MPE SC)/MPE SC/2021'),
  (619, 1789562, 'FGV', 'AJ (TJ RO)/TJ RO/Oficial de Justiça/2021', 2021, 'Sobre a Lei nº 11.340/06 (Lei Maria da Penha), analise as assertivas a seguir. I - A lei 11.340/06 (Lei Maria da Penha) apresenta como formas de violência doméstica e familiar contra a mulher, entre outras, a violência física, a violência moral, a violência sexual, a violência psicológica e a violência patrimonial. II - Nos termos da Lei 11.340/06 (Lei Maria da Penha), considera-se violência física qualquer conduta que configure calúnia, difamação ou injúria. III - Nos termos da Lei 11.340/06 (Lei Maria da Penha), considera-se patrimonial qualquer conduta que ofenda sua integridade ou sua saúde corporal. IV - Nos termos da Lei 11.340/06 (Lei Maria da Penha), considera-se violência patrimonial qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades. V - Segundo o art. 24-A da Lei 11.340/06, é crime a conduta de descumprir decisão judicial que defere medidas protetivas de urgência previstas na Lei 11.340/06 (Lei Maria da Penha). Assinale a alternativa correta.', 'TEC Concursos — questão 1789562 — FGV — AJ (TJ RO)/TJ RO/Oficial de Justiça/2021'),
  (646, 1256097, 'VUNESP', 'Coo (Pref Cananéia)/Pref Cananéia/Centro de Referência e Assistência Social/2020', 2020, 'No que se refere ao atendimento policial a grupos vulneráveis, julgue o item a seguir. A conduta de um namorado que ameaça divulgar fotos de sua namorada nua caso ela termine o relacionamento com ele pode ser enquadrada na Lei Maria da Penha.', 'TEC Concursos — questão 1256097 — VUNESP — Coo (Pref Cananéia)/Pref Cananéia/Centro de Referência e Assistência Social/2020'),
  (653, 1501575, 'EDUCA PB', 'ASoc (Pref C Índios)/Pref C dos Índios/2020', 2020, 'A respeito da violência contra a mulher, julgue a alternativa CORRETA:', 'TEC Concursos — questão 1501575 — EDUCA PB — ASoc (Pref C Índios)/Pref C dos Índios/2020'),
  (664, 1479113, 'IBADE', 'GM (Cariacica)/Pref Cariacica/2020', 2020, 'No que se refere ao atendimento policial a grupos vulneráveis, julgue o item a seguir. A violência doméstica e familiar pode ser caracterizada tanto por ação quanto por omissão.', 'TEC Concursos — questão 1479113 — IBADE — GM (Cariacica)/Pref Cariacica/2020'),
  (696, 908463, 'CEBRASPE (CESPE)', 'Ana GRS (SLU DF)/SLU DF/Serviço Social/2019', 2019, 'Leia a seguinte notícia, publicada na Revista Exame em 05/12/2018: “O plenário da Câmara dos Deputados aprovou projeto de lei que obriga agressor a ressarcir o Sistema Único de Saúde por custos com vítimas de violência doméstica. A medida, que visa aumentar o rigor da Lei Maria da Penha, também determina que dispositivos de segurança usados no monitoramento das vítimas sejam custeados pelo agressor. A matéria segue para o Senado”. No que se refere à Lei Federal nº 11.340/2006, que cria mecanismos para coibir a agressão contra a mulher, relacione a Coluna 1 à Coluna 2, associando algumas das formas de violência doméstica e familiar às suas definições. Coluna 1 1. Física. 2. Moral. 3. Psicológica. Coluna 2 ( ) Qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, ridicularização, exploração e limitação do direito de ir e vir. ( ) Qualquer conduta que ofenda sua integridade ou saúde corporal. ( ) Qualquer conduta que configure calúnia, difamação ou injúria. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:', 'TEC Concursos — questão 908463 — CEBRASPE (CESPE) — Ana GRS (SLU DF)/SLU DF/Serviço Social/2019'),
  (706, 861698, 'VUNESP', 'Ori Soc (Itapevi)/Pref Itapevi/2019', 2019, 'O Núcleo Especial de Defesa dos Direitos da Mulher (Nudem) é o órgão da Defensoria Pública do Estado do Rio de Janeiro especializado na promoção e na defesa dos direitos das mulheres no estado. Sandra procurou o Nudem para relatar que a sua companheira Aline passou a ameaçá-la e a provocar escândalos em seu local de trabalho, desde que lhe comunicara a decisão de terminar o relacionamento de cinco anos. Sobre a situação relatada acima, é correto afirmar que:', 'TEC Concursos — questão 861698 — VUNESP — Ori Soc (Itapevi)/Pref Itapevi/2019'),
  (711, 838571, 'IBRAE', 'EDAS (SEDES DF)/SEDES DF/Direito e Legislação/2019', 2019, 'Sobre o que prevê a Lei no 11.340/2006, é correto afirmar que', 'TEC Concursos — questão 838571 — IBRAE — EDAS (SEDES DF)/SEDES DF/Direito e Legislação/2019'),
  (726, 1270278, 'OBJETIVA CONCURSOS', 'Enf (S Martinho S)/Pref S Martinho da S/2019', 2019, 'A Lei Maria da Penha cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher, nos termos do § 8º do Art. 226 da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Violência contra a Mulher, da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher e de outros tratados internacionais ratificados pela República Federativa do Brasil; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; e estabelece medidas de assistência e proteção às mulheres em situação de violência doméstica e familiar. Isso posto, assinale a alternativa que identifica o público-alvo dessa lei:', 'TEC Concursos — questão 1270278 — OBJETIVA CONCURSOS — Enf (S Martinho S)/Pref S Martinho da S/2019'),
  (728, 1273091, 'OBJETIVA CONCURSOS', 'Ag (Taquaruçu Sul)/Pref Taquaruçu Sul/Social/2019', 2019, 'Sobre a violência contra a mulher, analisar os itens abaixo: I. Qualquer conduta que ofenda a integridade ou saúde corporal da mulher é compreendida como violência física. II. No atendimento à mulher em situação de violência doméstica e familiar, a autoridade policial deverá, entre outras providências, encaminhar a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal.', 'TEC Concursos — questão 1273091 — OBJETIVA CONCURSOS — Ag (Taquaruçu Sul)/Pref Taquaruçu Sul/Social/2019'),
  (730, 1284278, 'OBJETIVA CONCURSOS', 'TEnf (P Bandeira)/Pref Pinto Bandeira/2019', 2019, 'De acordo com a Lei nº 11.340/2006, analisar a sentença abaixo: A violência psicológica é entendida como qualquer conduta que cause à mulher dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação (1ª parte). Os Juizados de Violência Doméstica e Familiar contra a Mulher que vierem a ser criados poderão contar com uma equipe de atendimento multidisciplinar, a ser integrada por profissionais especializados nas áreas psicossocial, jurídica e de saúde (2ª parte). A sentença está:', 'TEC Concursos — questão 1284278 — OBJETIVA CONCURSOS — TEnf (P Bandeira)/Pref Pinto Bandeira/2019'),
  (738, 714814, 'IADES', 'Sold (PM DF)/PM DF/Músico/2018', 2018, 'Acerca dos mecanismos para coibir a violência doméstica e familiar contra a mulher, trazidos nos exatos termos da Lei nº 11.340/06, é correto afirmar que', 'TEC Concursos — questão 714814 — IADES — Sold (PM DF)/PM DF/Músico/2018'),
  (739, 692312, 'IBADE', 'Ana Prev (IPM JP)/IPM JP/Assistente Social/2018', 2018, 'Joana e Marcos mantiveram um relacionamento amoroso durante 12 anos. O término da relação ocorreu em razão do ciúme descontrolado de Marcos e da respectiva tentativa constante de controle sobre o corpo, o modo de agir e a mente da então companheira, culminando em agressões de ordem psicológica e caracterizando, portanto, um ciclo de violência doméstica.7 Considerando a situação hipotética apresentada e com base na Lei Maria da Penha, assinale a alternativa correta.', 'TEC Concursos — questão 692312 — IBADE — Ana Prev (IPM JP)/IPM JP/Assistente Social/2018'),
  (741, 612958, 'AOCP', 'Cad (PM TO)/PM TO/2018', 2018, 'Maria Nilda, 59 anos de idade, natural do estado de São Paulo, com ensino fundamental incompleto, compareceu com seus quatro filhos a uma unidade pública de saúde do Distrito Federal, buscando orientações para melhorar a sua atual situação. Em atendimento com a assistente social, Maria informou que mora há apenas três anos no Distrito Federal e que veio de sua cidade natal em busca de melhores condições de vida. Na ocasião, estava na companhia dos seus filhos: Helena, com 24 anos de idade, ensino médio incompleto, no quarto mês de gestação, ainda não sabe se deseja permanecer com seu filho, pois acredita que não terá condições de criá-lo — relata essa dificuldade com base no fato de seu companheiro ter sido morto; Ricardo, 15 anos de idade, ensino médio incompleto, deficiente físico; Miguel, 13 anos de idade, estudante do ensino fundamental; e Pedro Gustavo, 11 anos de idade, atualmente fora da escola. Maria Nilda relatou vivenciar uma relação abusiva com o seu marido, José Ferreira, 63 anos de idade, o qual, por mais de trinta anos, tem constantemente a insultado e ofendido, questionando, inclusive, a própria paternidade dos filhos. Conta que atualmente seu marido sempre comparece em sua residência alcoolizado e os xingamentos têm piorado. Dada a sobrecarga da responsabilidade familiar, ela acredita que a necessidade de trabalhar a fez ser negligente com os filhos, o que a faz sentir-se culpada, ainda mais pelo fato de Miguel e Pedro Gustavo terem cometido ato infracional tipificado como roubo, sendo este o terceiro ato ilícito de Miguel e o segundo de Pedro Gustavo. A partir dessa situação hipotética, julgue o item subsecutivo, considerando o que dispõem a Lei Maria da Penha, o Estatuto da Criança e do Adolescente e o Estatuto do Idoso. A violência patrimonial sofrida por Maria Nilda deverá ser classificada como violência simbólica.', 'TEC Concursos — questão 612958 — AOCP — Cad (PM TO)/PM TO/2018'),
  (749, 1336891, 'IMPARH', 'PTNS (SDHDS)/Pref Fortaleza/Direito/2018', 2018, 'A Lei Maria da Penha, sancionada em 7 de agosto de 2006, como Lei n.º 11.340 visa proteger a mulher da violência doméstica e familiar. Sobre a Lei, é correto afirmar, EXCETO:', 'TEC Concursos — questão 1336891 — IMPARH — PTNS (SDHDS)/Pref Fortaleza/Direito/2018'),
  (774, 1742016, 'EJUD PI', 'Estag (TJ PI)/TJ PI/Direito/2018', 2018, 'A trajetória histórica dos movimentos sociais e das lutas para a garantia de direitos de crianças, adolescentes, mulheres e idosos permitiu a criação de leis para esses públicos: o Estatuto da Criança e do Adolescente (ECA); o Estatuto do Idoso; e a Lei n.º 11.340/2006, conhecida como Lei Maria da Penha. Com base nessas legislações, julgue o item. Para efeito da Lei Maria da Penha, considera‐se como violência doméstica e familiar contra a mulher qualquer ação ou omissão que cause morte, lesão, sofrimento físico, sexual ou psicológico à mulher.', 'TEC Concursos — questão 1742016 — EJUD PI — Estag (TJ PI)/TJ PI/Direito/2018'),
  (786, 631048, 'IESES', 'Papilo (PCien SC)/PCien SC/2017', 2017, 'A Lei Nº 11.340/06, “Lei Maria da Penha”, criou inúmeros mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher. Sobre o tema, assinale a alternativa CORRETA.', 'TEC Concursos — questão 631048 — IESES — Papilo (PCien SC)/PCien SC/2017'),
  (804, 581287, 'COSEAC UFF', 'Ag (Pref Niterói)/Pref Niterói/Coordenação de Turno/2016', 2016, 'Com relação às disposições da Lei n.º 11.340/2006 — Lei Maria da Penha —, assinale a opção correta.', 'TEC Concursos — questão 581287 — COSEAC UFF — Ag (Pref Niterói)/Pref Niterói/Coordenação de Turno/2016'),
  (818, 301540, 'SMA-RJ (antiga FJG)', 'Ana Leg (CM RJ)/CM RJ/Assistência Social/2015', 2015, 'DULCE mantém relacionamento afetivo com ANA por cerca de dez anos, sendo diariamente ofendida, por meio de palavras e gestos. Deprimida, DULCE perdeu o emprego e assinou procuração à companheira ANA, que vem dilapidando o patrimônio comum do casal e bens particulares da companheira, sem prestação de contas ou partilha. DULCE se dirigiu à Delegacia de Defesa da Mulher, onde:', 'TEC Concursos — questão 301540 — SMA-RJ (antiga FJG) — Ana Leg (CM RJ)/CM RJ/Assistência Social/2015'),
  (823, 328682, 'FCC', 'AgDP (DPE SP)/DPE SP/Assistente Social/2015', 2015, 'Durante o plantão social em uma instituição, a equipe do Serviço Social atendeu uma senhora de 70 anos, esposa de um policial militar reformado de 82 anos. Essa senhora procurou o Serviço Social após a orientação e o encaminhamento da Corregedoria da referida instituição. No encaminhamento havia a indicação de acompanhamento social e psicológico pela equipe da Divisão de Assistência Social para a restauração da harmonia familiar. No decorrer da entrevista, a senhora relatou que era constantemente insultada pelo marido, e, às vezes, difamada e humilhada por ele. Acrescentou que esse fato tem sido recorrente, e, como consequência, sente que a sua autoestima vem diminuindo. Pelo fato de ambos serem idosos, a equipe do Serviço Social encaminhou o caso ao Ministério Público. Contudo, com base na Lei nº 11.340/2006 – Lei Maria da Penha –, a equipe também poderia ter acionado a rede de proteção à mulher, em especial pelo relato apresentar demandas relacionadas à situação de:', 'TEC Concursos — questão 328682 — FCC — AgDP (DPE SP)/DPE SP/Assistente Social/2015'),
  (851, 972388, 'FUNRIO', 'Ass Soc (IF BA)/IF BA/2014', 2014, 'Há oito anos, em 07 de agosto de 2006, era aprovada a Lei nº 11.340, conhecida nacionalmente como Lei Maria da Penha. O instrumento legal foi um passo importante para o enfrentamento da violência contra a mulher, alterando o Código Penal em favor daquelas vítimas de violência. Quanto às formas de violência contra a mulher de acordo com a lei, analise os itens a seguir: I – a difamação por mídia virtual; II – a proibição de usar métodos contraceptivos; III – a destruição de documentos pessoais; IV – o cárcere privado; V – a agressão física por companheira em relação homoafetiva. O(s) item(ns) correto(s) é/são:', 'TEC Concursos — questão 972388 — FUNRIO — Ass Soc (IF BA)/IF BA/2014'),
  (863, 215155, 'VUNESP', 'DTP (PC SP)/PC SP/2014', 2014, 'Com relação aos direitos da criança e do adolescente (Lei n.º 8.069/1990 — Estatuto da Criança e do Adolescente) e ao direito da mulher à proteção contra a violência doméstica e familiar (Lei n.º 11.340/2006 — Lei Maria da Penha), julgue o item que se segue. Constitui violência doméstica e familiar contra mulher a conduta praticada pelo marido que configure calúnia, difamação ou injúria, sendo tal conduta entendida como violência moral.', 'TEC Concursos — questão 215155 — VUNESP — DTP (PC SP)/PC SP/2014'),
  (864, 492358, 'Com. Exam. (MPE PR)', 'Prom Jus (MPE PR)/MPE PR/2014', 2014, 'À luz da Lei n.º 11.340/2006 – Lei Maria da Penha, é correto afirmar que', 'TEC Concursos — questão 492358 — Com. Exam. (MPE PR) — Prom Jus (MPE PR)/MPE PR/2014'),
  (871, 496087, 'ESPP', 'Psico (MPE PR)/MPE PR/2013', 2013, 'Fulano, casado com Ciclana, num momento de discussão no lar, destruiu parte dos instrumentos de trabalho de sua esposa. Considerando a conduta de Fulano em face do disposto na Lei Maria da Penha, pode-se afirmar que', 'TEC Concursos — questão 496087 — ESPP — Psico (MPE PR)/MPE PR/2013'),
  (884, 3500525, 'FADURPE', 'Ass Soc (Pref Arapiraca)/Pref Arapiraca/2013', 2013, 'Com base no disposto na Lei Maria da Penha — Lei n.º 11.340/2006 —, assinale a opção correta.', 'TEC Concursos — questão 3500525 — FADURPE — Ass Soc (Pref Arapiraca)/Pref Arapiraca/2013'),
  (889, 113946, 'CEBRASPE (CESPE)', 'Escr (PC BA)/PC BA/2013', 2013, 'No que se refere a competência, sujeitos processuais, provas, medidas cautelares e recursos, julgue o item a seguir. O castigo corporal excessivo imposto pela mãe à filha, com o intuito de estabelecer limites, não é da competência dos juizados de violência doméstica e familiar contra a mulher.', 'TEC Concursos — questão 113946 — CEBRASPE (CESPE) — Escr (PC BA)/PC BA/2013'),
  (908, 1569268, 'FCC', 'Ana Min (MPE AP)/MPE AP/Psicologia/2012', 2012, 'De acordo com a Lei Maria da Penha, Lei n. 11.340/2006, assinale a alternativa INCORRETA.', 'TEC Concursos — questão 1569268 — FCC — Ana Min (MPE AP)/MPE AP/Psicologia/2012'),
  (912, 1254876, 'CAIPIMES', 'Psic (Pref St André)/Pref Santo André/2012', 2012, 'A dimensão jurídico- política da profissão caracteriza-se por um aparato estritamente profissional e outro, de caráter mais abrangente. Esse último envolve o conjunto de leis (a legislação social) advindas do capítulo da Ordem Social da CF, que, embora não exclusivo da profissão, a ela diz respeito tanto pela sua implementação por assistentes sociais em suas áreas de intervenção quanto pela participação que tiveram as vanguardas profissionais na construção e aprovação das leis e no reconhecimento dos direitos na legislação social por parte do Estado. Joaquina Barata Teixeira e Marcelo Braz. O projeto ético-político do Serviço Social. In: CFESS/ABEPSS. Serviço Social: direitos sociais e competências profissionais. Brasília: 2009, p.192 (com adaptações). Considerando o tema abordado pelo texto acima, julgue o item subsequente. De acordo com a Lei Maria da Penha, a violência contra a mulher caracteriza-se pela lesão corporal, de modo que um dano patrimonial, por exemplo, não pode caracterizar ato de violência doméstica e familiar contra a mulher.', 'TEC Concursos — questão 1254876 — CAIPIMES — Psic (Pref St André)/Pref Santo André/2012'),
  (921, 802381, 'FGR', 'GM (Pref Congonhas)/Pref Congonhas/2012', 2012, 'Relativamente aos delitos de violência doméstica previstos na Lei nº 11.340/2006 (Lei Maria da Penha), considere as assertivas abaixo. I – As agressões perpetradas de irmão contra irmã e de nora contra sogra se subsumem à Lei Maria da Penha. II – Processar e julgar maus-tratos cometidos pelos pais adotivos contra a filha criança não é de Violência Doméstica e Familiar contra a Mulher. III – Aplica-se aos crimes praticados com violência doméstica a mulher a Lei nº 9.099/1995 (Lei dos Juizados Especiais Criminais), quando a pena máxima prevista dor inferior a 2 (dois) anos. Quais são corretas?', 'TEC Concursos — questão 802381 — FGR — GM (Pref Congonhas)/Pref Congonhas/2012'),
  (926, 2951436, 'COPS UEL', 'AgUniProf (UEL)/UEL/Cirurgião Dentista/2010', 2010, 'A farmacêutica Maria da Penha Maia Fernandes foi homenageada com o vínculo de seu nome à lei 11.340. Ela foi agredida pelo marido durante seis anos. Em 1983, por duas vezes, ele tentou assassiná-la. Na primeira com arma de fogo, deixando-a paraplégica, e na segunda por eletrocução e afogamento. O marido de Maria da Penha só foi punido depois de 19 anos de julgamento e ficou apenas dois anos em regime fechado. A lei 11.340, de 07 de agosto de 2006, criou mecanismos para coibir a violência doméstica e familiar contra a mulher. Nos termos da Lei Maria da Penha é INCORRETO afirmar:', 'TEC Concursos — questão 2951436 — COPS UEL — AgUniProf (UEL)/UEL/Cirurgião Dentista/2010'),
  (941, 1714489, 'CCC IFCE', 'Ass (IF CE)/IF CE/Alunos/2009', 2009, 'Sobre a Lei Maria da Penha, é incorreto afirmar.', 'TEC Concursos — questão 1714489 — CCC IFCE — Ass (IF CE)/IF CE/Alunos/2009'),
  (943, 686025, 'FCC', 'Prom Jus (MPE PE)/MPE PE/2008', 2008, 'Relativamente à Lei Maria da Penha (11.340/2006), assinale a afirmativa incorreta.', 'TEC Concursos — questão 686025 — FCC — Prom Jus (MPE PE)/MPE PE/2008'),
  (945, 2184657, 'VUNESP', 'Prom Jus (MPE SP)/MPE SP/2008', 2008, 'A respeito da prisão preventiva e com base no entendimento atual do STJ acerca dessa matéria, julgue o próximo item. A possibilidade real de o acusado de prática de crime contra a mulher no âmbito doméstico e familiar cumprir ameaças de morte dirigidas a sua ex-esposa basta como fundamento para a sua segregação, sobretudo ante a disciplina protetiva da Lei Maria da Penha, que visa a proteção da saúde mental e física da mulher.', 'TEC Concursos — questão 2184657 — VUNESP — Prom Jus (MPE SP)/MPE SP/2008'),
  (947, 1060353, 'INSTITUTO OPET', 'Asst (CM Curitiba)/CM Curitiba/Social/2007', 2007, 'A Lei nº 11.340, de 07 de Agosto de 2006, cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Discriminação contra as Mulheres e da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; altera o Código de Processo Penal, o Código Penal e a Lei de Execução Penal e dá outras providências. Com supedâneo nesta afirmativa assinale a única opção CORRETA:', 'TEC Concursos — questão 1060353 — INSTITUTO OPET — Asst (CM Curitiba)/CM Curitiba/Social/2007'),
  (949, 3803406, 'FGV', 'Del Pol (PC PI)/PC PI/2026', 2026, 'A assistência à mulher em situação de violência doméstica e familiar, conforme previsto na Lei nº 11.340/2006 (Lei Maria da Penha), constitui um dever do Estado e um direito fundamental à dignidade e à integridade física e psicológica da vítima. Segundo Saffioti (2004, p. 132), “a violência contra a mulher é uma expressão das relações desiguais de poder entre os sexos, sustentadas por uma cultura patriarcal que naturaliza a dominação masculina”. Assim, a assistência deve ultrapassar o atendimento emergencial, promovendo a reconstrução da cidadania e o empoderamento das mulheres. Fonte: SAFFIOTI, Heleieth I. B. Gênero, patriarcado, violência São Paulo: Fundação Perseu Abramo, 2004. Disponível em: http://dspace.sistemas.mpba.mp.br/jspui/handle/123456789/754. Acesso em: 28 de out de 2025. De acordo com esse contexto e o que trata a Lei nº 11.340/2006 (e suas atualizações), marque a alternativa CORRETA.', 'TEC Concursos — questão 3803406 — FGV — Del Pol (PC PI)/PC PI/2026'),
  (954, 3791633, 'Instituto AOCP', 'Pol Pen (DEPEN MG)/DEPEN MG/2026', 2026, 'Ao tomar conhecimento da prática de violência doméstica e familiar contra a mulher, a autoridade policial deverá adotar providências imediatas. De acordo exclusivamente com a Lei Maria da Penha, assinale a alternativa que apresenta uma dessas providências.', 'TEC Concursos — questão 3791633 — Instituto AOCP — Pol Pen (DEPEN MG)/DEPEN MG/2026'),
  (955, 3771993, 'Unifil', 'Psi (Pref Amélia)/Pref Amélia/II/2026', 2026, 'Em municipio que nao e sede de comarca, Bruna aciona a policia as 2h30min, relatando que seu companheiro, embriagado, a ameaçou de morte e quebrou objetos da casa. A equipe policial se dirige ao local e constata risco atual à integridade fisica da ofendida. No momento da ocorrencia, não há delegado disponível, e o plantao judicial ainda nao foi instalado. Nessa situação, conforme a Lei n° 11.340/2006, é correto afirmar que o agressor devera ser imediatamente afastado do lar por determinacao', 'TEC Concursos — questão 3771993 — Unifil — Psi (Pref Amélia)/Pref Amélia/II/2026'),
  (956, 4042000, 'CEBRASPE (CESPE)', 'Alun Of (PM DF)/PM DF/2026', 2026, 'A Lei Maria da Penha prevê que o agressor pode ser afastado do lar quando', 'TEC Concursos — questão 4042000 — CEBRASPE (CESPE) — Alun Of (PM DF)/PM DF/2026'),
  (957, 3949276, 'IBFC', 'Prof (SEC BA)/SEC BA/Orientador de Estágio em Saúde/Enfermagem/2026', 2026, 'De acordo com a Lei Maria da Penha, assinale a opção correta.', 'TEC Concursos — questão 3949276 — IBFC — Prof (SEC BA)/SEC BA/Orientador de Estágio em Saúde/Enfermagem/2026'),
  (960, 3803957, 'FGV', 'Of Inv Pol (PC PI)/PC PI/2026', 2026, 'A Lei Maria da Penha (Lei nº 11.340/2006) estabelece que a assistência à mulher em situação de violência doméstica e familiar deve ser prestada de forma articulada, integrando princípios da assistência social, da saúde e da segurança pública. No que concerne às determinações que o juiz deve assegurar à mulher vítima de violência para a preservação da sua integridade física e psicológica, assim como para a garantia do seu atendimento integral, a Lei Maria da Penha dispõe que', 'TEC Concursos — questão 3803957 — FGV — Of Inv Pol (PC PI)/PC PI/2026'),
  (961, 3475690, 'CEBRASPE (CESPE)', 'Tec SS (CAESB)/CAESB/Técnico de Edificações/2025', 2025, 'Maria, residente e domiciliada no diminuto Município Alfa, vem sendo vítima de frequentes agressões perpetradas pelo seu companheiro Caio. Registre-se que, em razão dos eventos, Maria procurou, com urgência, o auxílio das autoridades públicas competentes. Nesse caso, considerando as disposições da Lei nº 11.340/2006, verificada a existência de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher em situação de violência doméstica e familiar, o agressor será imediatamente afastado do lar, domicílio ou local de convivência com a ofendida, pelo (a)', 'TEC Concursos — questão 3475690 — CEBRASPE (CESPE) — Tec SS (CAESB)/CAESB/Técnico de Edificações/2025'),
  (962, 3542689, 'IBADE', 'ASoc EEC (Pref Rolim de Moura)/Pref Rolim de Moura/2025', 2025, 'Segundo a Lei Maria da Penha (Lei n.º 11.340/2006), em caso de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher em situação de violência doméstica e familiar, o afastamento imediato do agressor do lar de convivência com a ofendida pode ser determinado', 'TEC Concursos — questão 3542689 — IBADE — ASoc EEC (Pref Rolim de Moura)/Pref Rolim de Moura/2025'),
  (964, 3462034, 'AVANÇASP', 'Psic (FUSAM)/FUSAM/Sem Área/2025', 2025, 'A Lei Maria da Penha, Lei Federal nº 11.340/2006, cria mecanismos para coibir a violência doméstica e familiar contra a mulher. Tendo em vista a importância de entender e se aproximar dessa lei e dos seus mecanismos, nos processos de trabalho em que se inserem os assistentes sociais, assinale a afirmativa correta.', 'TEC Concursos — questão 3462034 — AVANÇASP — Psic (FUSAM)/FUSAM/Sem Área/2025'),
  (965, 3606498, 'CEBRASPE (CESPE)', 'AJ (TJ PA)/TJ PA/Serviço Social/2025', 2025, 'De acordo com a legislação vigente, aquele que, por ação ou omissão, causar lesão, violência física, sexual ou psicológica, e dano moral ou patrimonial a uma mulher fica obrigado a:', 'TEC Concursos — questão 3606498 — CEBRASPE (CESPE) — AJ (TJ PA)/TJ PA/Serviço Social/2025'),
  (967, 3606496, 'CEBRASPE (CESPE)', 'AJ (TJ PA)/TJ PA/Serviço Social/2025', 2025, 'De acordo com a Lei Maria da Penha (Lei nº 11.340/2006), após o registro da ocorrência de violência doméstica e familiar contra a mulher, a autoridade policial deverá, de imediato, sem prejuízo dos demais procedimentos legais,', 'TEC Concursos — questão 3606496 — CEBRASPE (CESPE) — AJ (TJ PA)/TJ PA/Serviço Social/2025'),
  (969, 3605442, 'Legatus', 'GCM (Pref Piripiri)/Pref Piripiri/2025', 2025, 'Analise as seguintes asserções e a relação proposta entre elas, tendo por referência a Lei no 11.340/2006, Lei Maria da Penha: I. A política pública que visa coibir a violência doméstica familiar contra a mulher é responsabilidade primordial do Estado, visto ser este o responsável pela Polícia Civil e Militar, que possuem como função a prevenção de crimes. PORQUE II. A Lei Maria da Penha elenca a capacitação permanente das Polícias Civil e Militar, da Guarda Municipal, do Corpo de Bombeiros quanto às questões de gênero e de raça ou etnia como diretriz para coibir a violência doméstica e familiar contra a mulher. A respeito dessas asserções, assinale a alternativa correta.', 'TEC Concursos — questão 3605442 — Legatus — GCM (Pref Piripiri)/Pref Piripiri/2025'),
  (970, 3719812, 'CEV URCA', 'ASoc (Pref L Mangabeira)/Pref L Mangabeira/2025', 2025, 'A Lei Federal nº 11.340, de 7 de agosto de 2006, conhecida como Lei Maria da Penha, estabelece disposições sobre a assistência à mulher em situação de violência doméstica e familiar. Sobre esta lei e suas alterações, analise os itens a seguir: I. Em casos excepcionais, a autoridade policial pode afastar o suposto agressor do domicílio ou do lugar de convivência quando for verificado risco à vida ou à integridade da mulher, mesmo sem autorização judicial prévia. II. A lei alterou o Código de Processo Penal para possibilitar ao juiz a decretação da prisão preventiva quando houver riscos à integridade física ou psicológica da mulher. III. As medidas protetivas de urgência serão concedidas independentemente da tipificação penal da violência, do ajuizamento de ação penal ou cível, da existência de inquérito policial ou do registro de boletim de ocorrência. Está(ão) correto(s):', 'TEC Concursos — questão 3719812 — CEV URCA — ASoc (Pref L Mangabeira)/Pref L Mangabeira/2025'),
  (971, 3675819, 'FUNDATEC', 'ASoc (Estância V)/Pref Estância Velha/2025', 2025, '(PMLM/URCA 2025) A lei Nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher, nos termos do $ 8º do art. 226 da constituição federal, da convenção sobre a eliminação de todas as formas de discriminação contra as mulheres e da convenção interamericana para prevenir, punir e erradicar a violência contra a mulher; dispõe sobre a criação dos juizados de violência doméstica e familiar contra a mulher; altera os decretos-lei Nº 3.689, de 3 de outubro de 1941 (código de processo penal), e 2.848, de 7 de dezembro de 1940 (código penal), e a lei Nº 7.210, de 11 de julho de 1984 (lei de execução penal); e dá outras providências (lei maria da penha). o capítulo III - que trata do atendimento pela autoridade policial, em seu Art. 10-a. coloca que: é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores - preferencialmente do sexo feminino - previamente capacitados. (incluído pela lei nº 13.505, de 2017) em seu $ 1º a inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá diretrizes, assinale abaixo, a alternativa correta:', 'TEC Concursos — questão 3675819 — FUNDATEC — ASoc (Estância V)/Pref Estância Velha/2025'),
  (972, 3559254, 'COGEPS UNIOESTE', 'GCM (Pref SM do Iguaçu)/Pref SM do Iguaçu/2025', 2025, 'A violência contra a mulher vem sendo amplamente estudada pela sociedade brasileira, tendo motivado a formulação e implementação de políticas públicas articuladas entre a União, os Estados, o Distrito Federal e os Municípios, com vistas à sua prevenção. Assinale a alternativa que NÃO é uma medida de prevenção à violência doméstica prevista na Lei Maria da Penha.', 'TEC Concursos — questão 3559254 — COGEPS UNIOESTE — GCM (Pref SM do Iguaçu)/Pref SM do Iguaçu/2025'),
  (974, 3237914, 'CEBRASPE (CESPE)', 'AAAPC (PC DF)/PC DF/Agente Administrativo/2025', 2025, '(PMLM/URCA 2025) A lei nº 11.340, de 7 de agosto de 2006 - cria mecanismos para coibir a violência doméstica e familiar contra a mulher no título III da assistência à mulher em situação de violência doméstica e familiar em seu capítulo i, que trata das medidas integradas de prevenção, no seu art. 8º a política pública que visa coibir a violência doméstica e familiar contra a mulher far-se-á por meio de um conjunto articulado de ações da união, dos estados, do distrito federal e dos municípios e de ações não-governamentais, tendo por diretrizes: assinale a alternativa incorreta:', 'TEC Concursos — questão 3237914 — CEBRASPE (CESPE) — AAAPC (PC DF)/PC DF/Agente Administrativo/2025'),
  (975, 3339061, 'FAFIPA', 'GCM (Pref Araucária)/Pref Araucária/2025', 2025, 'Julgue o item a seguir, considerando as disposições da Lei Maria da Penha (Lei n.º 11.340/2006). Em todos os casos de violência doméstica e familiar contra a mulher, feito o registro da ocorrência, deve a autoridade policial proceder, de imediato, à oitiva do agressor e das eventuais testemunhas.', 'TEC Concursos — questão 3339061 — FAFIPA — GCM (Pref Araucária)/Pref Araucária/2025'),
  (976, 3750104, 'FUNDATEC', 'Of Adm (Pref Soledade (RS))/Pref Soledade (RS)/2025', 2025, 'A respeito da Lei nº 11.340/2006, mais conhecida como Lei Maria da Penha, assinale a alternativa INCORRETA.', 'TEC Concursos — questão 3750104 — FUNDATEC — Of Adm (Pref Soledade (RS))/Pref Soledade (RS)/2025'),
  (980, 3749202, 'EDUCA PB', 'GCM (Pref Santa Cecília)/Pref Sta Cecília PB/2025', 2025, 'Com base na Lei Maria da Penha (Lei n.º 11.340/2006), julgue o item seguinte. Após o registro da ocorrência de um caso de violência doméstica e familiar contra a mulher, é prerrogativa da autoridade policial a deliberação sobre a necessidade de oitiva do agressor e das testemunhas elencadas.', 'TEC Concursos — questão 3749202 — EDUCA PB — GCM (Pref Santa Cecília)/Pref Sta Cecília PB/2025'),
  (981, 3500155, 'CEBRASPE (CESPE)', 'Psic (PF)/PF/Clínico/2025', 2025, 'A respeito do art. 12 da Lei nº 11.340 de 2006 (Lei Maria da Penha), nos casos de violência doméstica e familiar contra a mulher, feito o registro da ocorrência, deverá a autoridade policial remeter, no prazo de:', 'TEC Concursos — questão 3500155 — CEBRASPE (CESPE) — Psic (PF)/PF/Clínico/2025'),
  (982, 3674860, 'Marinha', 'QT (Marinha)/Marinha/Serviço Social/2025', 2025, 'Com base no disposto na Lei n.º 11.340/2006 (Lei Maria da Penha), julgue o item a seguir. Para fins de assistência à mulher em situação de violência doméstica e familiar, a política pública voltada a coibir esse tipo de violência terá, entre outras diretrizes, a integração operacional do Poder Judiciário, do Ministério Público e das polícias civis com as áreas de assistência social, saúde, educação, trabalho e transporte.', 'TEC Concursos — questão 3674860 — Marinha — QT (Marinha)/Marinha/Serviço Social/2025'),
  (983, 3417035, 'VUNESP', 'Adv CREAS (Pref Itapevi)/Pref Itapevi/2025', 2025, 'Com base na Lei nº 11.340/2008, que cria mecanismos para coibir a violência doméstica e familiar contra a mulher, é correto afirmar que:', 'TEC Concursos — questão 3417035 — VUNESP — Adv CREAS (Pref Itapevi)/Pref Itapevi/2025'),
  (984, 3597170, 'IBAM', 'GCM (S Vicente)/Pref São Vicente/2025', 2025, 'Joana é médica e possui vínculo trabalhista formalizado com o Hospital Infantil Julieta. Na última sexta-feira, enquanto trabalhava no plantão noturno, seu marido, José, entrou no consultório em que ela estava e a esfaqueou, deixando-a em perigo de vida. Joana foi rapidamente atendida e transferida para um hospital do Sistema Único de Saúde (SUS) e sobreviveu. Com base na situação hipotética e no disposto na Lei Maria da Penha, assinale a alternativa correta.', 'TEC Concursos — questão 3597170 — IBAM — GCM (S Vicente)/Pref São Vicente/2025'),
  (985, 3764647, 'CEV UECE', 'GCM (Pref Tauá)/Pref Tauá/2025', 2025, 'A Lei Maria da Penha estabelece diretrizes para uma política pública de enfrentamento à violência doméstica e familiar contra a mulher, com enfoque na articulação entre instituições do Estado e da sociedade civil. Um dos pilares dessa política é a transversalidade, que exige a integração entre diferentes áreas e agentes públicos, bem como a adoção de medidas preventivas e educativas. Acerca do assunto, marque (V) para as afirmativas verdadeiras, e (F), para as falsas. (__)A integração entre Poder Judiciário, Ministério Público, Defensoria Pública e áreas como segurança pública, saúde e educação é uma diretriz expressa da política pública de combate à violência contra a mulher. (__)A criação de mecanismos legais de mediação entre vítima e agressor é uma das estratégias recomendadas pela Lei Maria da Penha para pacificação familiar, inclusive nos casos de reincidência. (__)A articulação entre entes federativos é opcional e apenas recomendada, sendo dispensável na efetivação das políticas públicas previstas na Lei Maria da Penha. (__)A capacitação permanente dos profissionais das áreas de segurança, saúde, educação e assistência social é prevista como uma diretriz da política pública de enfrentamento à violência de gênero. Após análise, assinale a alternativa que apresenta a sequência correta dos itens acima.', 'TEC Concursos — questão 3764647 — CEV UECE — GCM (Pref Tauá)/Pref Tauá/2025'),
  (987, 3623830, 'FUNDATEC', 'Ag Adm Sau (Pref Lajeado)/Pref Lajeado (RS)/2025', 2025, 'Assinale a alternativa que está de acordo com a Lei Maria da Penha:', 'TEC Concursos — questão 3623830 — FUNDATEC — Ag Adm Sau (Pref Lajeado)/Pref Lajeado (RS)/2025'),
  (989, 3852897, 'FUNDATEC', 'OGM (Pref Imbé)/Pref Imbé/2025', 2025, 'Com base nas disposições da lei que disciplina o Sistema Nacional de Políticas Públicas sobre Drogas e da Lei Maria da Penha, julgue o item a seguir. Verificado risco atual ou iminente à vida ou à integridade física ou psicológica da mulher em situação de violência doméstica, a competência para determinar o afastamento do agressor do lar é exclusiva da autoridade judicial.', 'TEC Concursos — questão 3852897 — FUNDATEC — OGM (Pref Imbé)/Pref Imbé/2025'),
  (991, 3399155, 'FGV', 'Ana MPU/MPU/Serviço Social/2025', 2025, 'Ana Paula, servidora pública de órgão estadual, procurou o Ministério Público para denunciar situação de violência doméstica cometida pelo companheiro. Ela relatou que sente medo de novas violências e que se sentiria mais segura indo para casa de familiares que moram em outro município, mas no mesmo Estado, porém não sabe quais são os seus direitos frente à transferência ou ausência de local de trabalho. Com base na Lei n° 11.340/2006, o técnico que atendeu Ana Paula explicou corretamente que o juiz assegurará à mulher em situação de violência doméstica', 'TEC Concursos — questão 3399155 — FGV — Ana MPU/MPU/Serviço Social/2025'),
  (992, 3559251, 'COGEPS UNIOESTE', 'GCM (Pref SM do Iguaçu)/Pref SM do Iguaçu/2025', 2025, 'Ruth foi obrigada a mudar de cidade devido aos vários episódios de violência física e psicológica praticados por seu marido. Na nova cidade, procurou a rede pública de educação para matricular seus filhos menores de idade. Entretanto, foi informada de que, por não haver mais vagas disponíveis, ela deveria se dirigir a outro município. Ao procurar o Serviço Social, ela foi informada de que, de acordo com a Lei Maria da Penha:', 'TEC Concursos — questão 3559251 — COGEPS UNIOESTE — GCM (Pref SM do Iguaçu)/Pref SM do Iguaçu/2025'),
  (994, 3364927, 'OBJETIVA CONCURSOS', 'Ag (Pref Gramado)/Pref Gramado/Comunitário de Saúde/2025', 2025, 'Segundo a Lei Maria da Penha, a política pública que visa coibir a violência doméstica e familiar contra a mulher far-se-á por meio de um conjunto articulado de ações da União, dos Estados, do Distrito Federal e dos Municípios e de ações não-governamentais, tendo por diretrizes, EXCETO:', 'TEC Concursos — questão 3364927 — OBJETIVA CONCURSOS — Ag (Pref Gramado)/Pref Gramado/Comunitário de Saúde/2025'),
  (995, 3746930, 'EDUCA PB', 'Ass (Pref Santa Cecília)/Pref Sta Cecília PB/Sala/2025', 2025, 'Em conformidade com a Lei nº 11.340/2006 − Lei Maria da Penha, a assistência à mulher em situação de violência doméstica e familiar compreenderá o acesso aos benefícios decorrentes do desenvolvimento científico e tecnológico, incluindo alguns serviços, EXCETO:', 'TEC Concursos — questão 3746930 — EDUCA PB — Ass (Pref Santa Cecília)/Pref Sta Cecília PB/Sala/2025');

create temporary table _lote1_alternativas (
  caderno_numero int,
  ordem smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote1_alternativas (caderno_numero, ordem, texto, correta) values
  (216, 1, 'A Lei Maria da Penha prevê medidas protetivas de urgência que podem ser concedidas independentemente da existência de processo criminal contra o agressor.', true),
  (216, 2, 'A Lei Maria da Penha prevê que, para garantir a proteção da vítima, o juiz deve ouvir obrigatoriamente o agressor antes da concessão de medidas protetivas.', false),
  (216, 3, 'A Lei Maria da Penha determina que a pena do agressor só poderá ser aplicada caso a vítima registre boletim de ocorrência e solicite expressamente a punição.', false),
  (216, 4, 'A aplicação da Lei Maria da Penha depende da comprovação de que a vítima e o agressor possuem vínculo matrimonial ou relação estável, não se aplicando a relacionamentos casuais.', false),
  (221, 1, 'A violência psicológica contra a mulher configura infração de menor potencial ofensivo e, portanto, sua punibilidade exige a tentativa de conciliação entre as partes antes do oferecimento da denúncia.', false),
  (221, 2, 'Para a caracterização da violência psicológica, é necessário que a agressão seja praticada presencialmente.', false),
  (221, 3, 'A prática de violência psicológica contra a mulher exige vínculo de coabitação entre agressor e vítima no momento dos fatos.', false),
  (221, 4, 'A conduta descrita configura apenas contravenção penal de perturbação do sossego, sendo inaplicável a Lei nº 11.340/2006 fora do contexto de convivência atual.', false),
  (221, 5, 'A prática de violência psicológica contra a mulher é prevista expressamente na Lei Maria da Penha, podendo ser oferecida denúncia pelo crime previsto no art. 147-B do Código Penal.', true),
  (260, 1, 'configurar ofensa à integridade ou saúde corporal da vítima.', false),
  (260, 2, 'configurar retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer as necessidades da vítima.', false),
  (260, 3, 'configurar calúnia, difamação ou injúria.', false),
  (260, 4, 'conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos da vítima.', false),
  (260, 5, 'configurar dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde mental e à autodeterminação da vítima.', true),
  (275, 1, 'A mencionada Lei cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher e o homem.', false),
  (275, 2, 'Os Juizados de Violência Doméstica e Familiar foram criados pela mencionada Lei.', true),
  (275, 3, 'Apenas a pessoa do sexo masculino pode ser autora de violência doméstica e familiar.', false),
  (275, 4, 'Qualquer conduta que configure calúnia, difamação ou injúria contra a mulher será considerada violência psicológica.', false),
  (284, 1, 'I, II e III.', false),
  (284, 2, 'I e II, apenas. https://www.tecconcursos.com.br/questoes/cadernos/100938882/imprimir', true),
  (284, 3, 'I e III, apenas.', false),
  (284, 4, 'II e III, apenas.', false),
  (370, 1, 'I, II, III e IV.', false),
  (370, 2, 'I e III, apenas.', true),
  (370, 3, 'II e IV, apenas.', false),
  (370, 4, 'III e IV, apenas.', false),
  (378, 1, 'As duas afirmativas são verdadeiras.', false),
  (378, 2, 'A afirmativa I é verdadeira, e a II é falsa.', true),
  (378, 3, 'A afirmativa II é verdadeira, e a I é falsa.', false),
  (378, 4, 'As duas afirmativas são falsas.', false),
  (393, 1, 'Ao caso é aplicada a Lei Maria da Penha por se tratar de violência de relação íntima de afeto, mas, por envolver ameaça e lesão corporal leve, a ação penal pública é condicionada à representação de Atena.', false),
  (393, 2, 'Ao caso é aplicada a Lei Maria da Penha, visto que a normativa abrange qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', true),
  (393, 3, 'Ao caso não é aplicada a Lei Maria da Penha por inexistir violência física concreta contra a mulher. A hipótese narrada configura crimes de ameaça e de lesão corporal leve, além de ser aplicado o Estatuto da Criança e do Adolescente em relação ao filho menor.', false),
  (393, 4, 'Na hipótese, estão configurados os crimes de ameaça e de lesão corporal leve, previstos no Código Penal, já que a Lei Maria da Penha apenas seria aplicada, caso Ares e Atena ainda estivessem namorando quando da ameaça real e da lesão corporal ou, ao menos, convivessem no mesmo ambiente familiar.', false),
  (395, 1, 'toda ação prática realizada dentro, ou fora do domicílio, que cause sofrimento, aflição psicológica e emocional.', false),
  (395, 2, 'toda prática social realizada contra a esposa e os filhos que cause lesão física, ou dano psicológico.', false),
  (395, 3, 'qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.', true),
  (395, 4, 'toda ação realizada dentro da unidade familiar que cause sofrimento físico e/ou emocional.', false),
  (395, 5, 'qualquer prática social sobre a esposa que gere dor física, emocional e dano moral.', false),
  (411, 1, 'a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos;', true),
  (411, 2, 'Em todos os casos de violência doméstica e familiar contra a mulher, o dever da autoridade policial se restringe a adotar o procedimento consistente na oitiva da vítima e lavratura do boletim de ocorrência;', false),
  (411, 3, 'no atendimento à mulher em situação de violência doméstica e familiar, a autoridade policial ou a guarda municipal terá somente a atribuição de fornecer transporte para a ofendida e seus dependentes para abrigo ou local seguro, quando houver risco de vida;', false),
  (411, 4, 'A Lei Maria da Penha visa a proteção exclusiva da violência sexual contra a mulher quando o ato se enquadrar no crime de estupro ou de atentado violento ao pudor.', false),
  (429, 1, 'São formas de violência doméstica e familiar contra a mulher, entre outras, a violência psicológica, entendida como qualquer conduta que configure calúnia, difamação ou injúria', false),
  (429, 2, 'Em termos de assistência à mulher em situação de violência doméstica e famílias, o juiz determinará a inclusão da mulher em situação de violência doméstica e familiar no cadastro de programas assistenciais do governo federal, estadual e municipal, ainda que por prazo incerto', false),
  (429, 3, 'O juiz assegurará à mulher em situação de violência doméstica e familiar, para preservar sua integridade física e psicológica, entre outras providências, a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até seis meses', true),
  (429, 4, 'A inquirição de mulher em situação de violência doméstica e familiar ou de testemunha de violência doméstica, quando se tratar de crime contra a mulher, obedecerá, entre outras diretrizes garantia de que, em hipótese específicas, a mulher em situação de violência doméstica e familiar, familiares e testemunhas terão contato direto com investigados ou suspeitos e pessoas a eles relacionadas', false),
  (436, 1, 'A situação narrada não configura violência doméstica, pois a relação de João e Maria é de mãe e filho.', false),
  (436, 2, 'Não será aplicada a Lei Maria da Penha, pois João é adolescente, o que atrai a aplicação do Estatuto da Criança e do Adolescente.', false),
  (436, 3, 'Como não se verifica situação de vulnerabilidade entre vítima e agressor, já que Maria é médica, tem trabalho estável e residência fixa, afasta-se a aplicação das disposições da Lei Maria da Penha.', false),
  (436, 4, 'No caso em tela, serão aplicadas as disposições da Lei Maria da Penha, uma vez que configura violência contra a mulher em contexto doméstico e familiar.', true),
  (436, 5, 'Embora seja existente o vínculo familiar entre Maria e João, o que em um primeiro momento atrai a aplicação da Lei Maria da Penha, no caso em tela não se pode falar em aplicação da referida lei, ao passo que Maria é mãe de João e, estando em uma posição hierárquica superior em relação ao filho, afasta o requisito da situação de vulnerabilidade da vítima.', false),
  (441, 1, 'A criminalização da violência física, psicológica, sexual, patrimonial e moral, bem como o estabelecimento de medidas de prevenção e assistência às vítimas.', true),
  (441, 2, 'A obrigatoriedade do comparecimento da vítima à audiência de conciliação com o agressor, visando à reconciliação e à resolução pacífica do conflito.', false),
  (441, 3, 'A suspensão temporária e imediata das procurações conferidas pelo agressor à ofendida.', false),
  (441, 4, 'A aplicação de penas alternativas aos agressores, visando à sua reintegração social, mesmo em casos de reincidência.', false),
  (468, 1, 'A medida protetiva de afastamento do lar pode ser concedida apenas quando há risco de vida iminente para a mulher agredida.', false),
  (468, 2, 'A denúncia de violência doméstica não pode ser feita por qualquer pessoa, devendo ser feita necessariamente pela vítima.', false),
  (468, 3, 'Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.', true),
  (468, 4, 'A pena para o agressor em casos de violência doméstica é sempre a prisão em regime fechado, independentemente da gravidade da agressão.', false),
  (468, 5, 'A Lei Maria da Penha não se aplica a casais homoafetivos, somente a casais heterossexuais.', false),
  (470, 1, 'V – F – V – F – V.', false),
  (470, 2, 'F – F – F – V – F.', true),
  (470, 3, 'V – V – V – F – V.', false),
  (470, 4, 'V – F – F – F – V.', false),
  (481, 1, 'É indispensável que o agressor e a agredida tenham cohabitado para que se tipifique a violência doméstica.', false),
  (481, 2, 'Não há violência doméstica, se o marido exige o cumprimento do débito conjugal, previsto no Código Civil.', false),
  (481, 3, 'A mulher não pode alegar violência doméstica, se lhe for negado pelo companheiro, por razões religiosas, o uso de contraceptivo.', false),
  (481, 4, 'A injúria é crime que está regulado no Código Penal, pelo que não prevalece o bis in idem para qualificá-la como ato de violência contra a mulher.', false),
  (481, 5, 'Traduz violência patrimonial contra a mulher, passível de enquadramento na lei própria, a destruição parcial ou total de seus instrumentos de trabalho.', true),
  (484, 1, 'As situações vivenciadas por Rute podem ser classificadas como violência psicológica, que é entendida como qualquer conduta que cause dano emocional e diminuição da autoestima ou que cause prejuízo à saúde psicológica.', true),
  (484, 2, 'Caso Teresa e Rute sejam agredidas fisicamente e registrem uma ocorrência contra João, compete à autoridade policial conceder medida protetiva de urgência no prazo de 24 horas e aguardar que o juiz faça a solicitação do pedido de exame de corpo de delito.', false),
  (484, 3, 'Mesmo que Teresa comunique no ato da ocorrência o porte de arma por João, a autoridade policial está impedida de registrar essa informação, por se tratar de competência exclusiva do Sistema Nacional de Armas.', false),
  (484, 4, 'O juiz pode decretar a prisão preventiva de João somente quando o inquérito policial estiver concluído, por ter caráter irrevogável.', false),
  (534, 1, 'Apenas I, II e III.', false),
  (534, 2, 'Apenas II e IV.', false),
  (534, 3, 'Apenas II e III.', false),
  (534, 4, 'Apenas I e III.', true),
  (534, 5, 'Apenas III e IV.', false),
  (561, 1, 'manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até seis meses;', true),
  (561, 2, 'manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até 03 meses;', false),
  (561, 3, 'manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até um ano;', false),
  (561, 4, 'manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, pelo período de seis meses a um ano;', false),
  (561, 5, 'Não a possibilidade de manter o vínculo trabalhista em caso de afastamento do local;', false),
  (574, 1, 'F, F, F, F.', false),
  (574, 2, 'F, V, F, V.', true),
  (574, 3, 'V, F, V, F.', false),
  (574, 4, 'V, V, V, V.', false),
  (577, 1, 'A pena por crime de violência doméstica admite substituição por quaisquer das penas restritivas de direitos.', false),
  (577, 2, 'A denúncia por lesão corporal contra o agressor não é condicionada à representação da ofendida.', true),
  (577, 3, 'A situação de violência doméstica depende de coabitação, atual ou pretérita, entre agressor e ofendida.', false),
  (577, 4, 'A legislação sobre violência doméstica não se aplica a relações homoafetivas entre duas mulheres.', false),
  (577, 5, 'O descumprimento de uma medida protetiva de urgência, por si só, não constitui crime.', false),
  (606, 1, 'Os crimes praticados com violência doméstica e familiar contra a mulher não admitem transação penal, mesmo que a pena máxima cominada não ultrapasse os dois anos.', true),
  (606, 2, 'Em qualquer hipótese, é vedada a substituição da pena privativa de liberdade por restritiva de direitos, nos casos de violência doméstica e familiar contra a mulher.', false),
  (606, 3, 'A caracterização da violência doméstica e familiar contra a mulher exige que agressor e vítima coabitem ou ao menos tenham coabitado.', false),
  (606, 4, 'A suspensão condicional do processo, por não ser aplicável somente às infrações de menor potencial ofensivo, aplica-se aos casos de violência doméstica e familiar contra a mulher, nada obstante a vedação estabelecida pela Lei Maria da Penha.', false),
  (606, 5, 'O crime de lesão corporal leve praticado contra mulher no âmbito doméstico e familiar enseja a propositura de ação penal pública condicionada à representação.', false),
  (619, 1, 'Apenas l e II, estão corretas.', false),
  (619, 2, 'Apenas l e III, estão corretas.', false),
  (619, 3, 'Apenas II e IV, estão corretas.', false),
  (619, 4, 'Apenas I, III e V, estão corretas.', false),
  (619, 5, 'Apenas I, IV e V, estão corretas.', true),
  (646, 1, 'Certo', true),
  (646, 2, 'Errado', false),
  (653, 1, 'A legislação atual, prevê o afastamento do trabalho com manutenção do vínculo trabalhista, apenas, nos casos de violência doméstica com lesão corporal grave.', false),
  (653, 2, 'A violência contra a mulher é uma violação dos direitos humanos.', true),
  (653, 3, 'A lei Maria da Penha define que a violência doméstica e familiar contra a mulher é a praticada somente por agressor masculino e que necessariamente possua relação de parentesco ou afeto com a vítima.', false),
  (653, 4, 'A primeira legislação brasileira com objetivo de combater a violência doméstica e familiar contra a mulher, foi criada em 1998.', false),
  (664, 1, 'Certo', true),
  (664, 2, 'Errado', false),
  (696, 1, '3 – 1 – 2.', true),
  (696, 2, '1 – 2 – 3.', false),
  (696, 3, '3 – 2 – 1.', false),
  (696, 4, '2 – 1 – 3.', false),
  (696, 5, '2 – 3 – 1.', false),
  (706, 1, 'não está tipificada como situação de violência contra a mulher por se tratar de união homoafetiva;', false),
  (706, 2, 'configura conduta de violência psicológica e moral praticada por Aline, contra Sandra;', true),
  (706, 3, 'constitui conduta de violência de gênero contra Aline, praticada por Sandra;', false),
  (706, 4, 'não configura forma de violência prevista na lei, já que se trata de conduta decorrente de conflito conjugal;', false),
  (706, 5, 'poderá ensejar a condenação de Aline ao pagamento de cesta básica por ofender a integridade psicológica de Sandra.', false),
  (711, 1, 'a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', true),
  (711, 2, 'é direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores públicos do sexo masculino ou feminino, previamente capacitados.', false),
  (711, 3, 'as medidas protetivas de urgência poderão ser concedidas pelo juiz apenas a requerimento da ofendida.', false),
  (711, 4, 'as medidas protetivas de urgência serão aplicadas de forma isolada e não poderão ser substituídas por outras de maior eficácia.', false),
  (711, 5, 'a ofendida, para dar celeridade ao processo, poderá entregar intimação ou notificação ao agressor.', false),
  (726, 1, 'Apenas mulheres heterossexuais e casadas.', false),
  (726, 2, 'Todas mulheres e homens vítimas de violência doméstica.', false),
  (726, 3, 'Todas as pessoas que se identificam com o sexo feminino, heterossexuais, transsexuais e homossexuais.', true),
  (726, 4, 'Todas as pessoas que se identificam com o sexo feminino, seguem uma filosofia cristã e de defesa da família.', false),
  (726, 5, 'Todas as pessoas que se identificam com o sexo feminino, menos profissionais do sexo.', false),
  (728, 1, 'Os itens I e II estão corretos.', true),
  (728, 2, 'Somente o item I está correto.', false),
  (728, 3, 'Somente o item II está correto.', false),
  (728, 4, 'Os itens I e II estão incorretos.', false),
  (730, 1, 'Totalmente correta.', true),
  (730, 2, 'Correta somente em sua 1ª parte.', false),
  (730, 3, 'Correta somente em sua 2ª parte.', false),
  (730, 4, 'Totalmente incorreta.', false),
  (738, 1, 'a assistência à mulher em situação de violência doméstica e familiar compreenderá o acesso aos benefícios decorrentes do desenvolvimento científico e tecnológico, excluindo-se, porém, os serviços de contracepção de emergência, a profilaxia das Doenças Sexualmente Transmissíveis (DST) e da Síndrome da Imunodeficiência Adquirida (AIDS).', false),
  (738, 2, 'na hipótese da iminência ou da prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência dependerá de autorização judicial para adoção das providências legais cabíveis.', false),
  (738, 3, 'nas ações penais públicas condicionadas à representação da ofendida de que trata a lei em comento só será admitida a renúncia à representação perante o juiz, em audiência especialmente designada com tal finalidade, após o recebimento da denúncia e ouvido o Ministério Público.', false),
  (738, 4, 'a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', true),
  (738, 5, 'a aplicação, nos casos de violência doméstica e familiar contra a mulher, de penas de cesta básica ou outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa, é medida autorizada pela norma sob análise.', false),
  (739, 1, 'A coabitação é um requisito para aplicação da Lei Maria da Penha.', false),
  (739, 2, 'A competência dos processos cíveis, por opção do ofensor, será do respectivo domicílio ou da respectiva residência, do lugar do fato em que baseou a demanda e do domicílio da ofendida.', false),
  (739, 3, 'A prisão preventiva do agressor, em qualquer fase do inquérito policial ou da instrução criminal, deverá ser determinada pela autoridade policial competente.', false),
  (739, 4, 'A pena de cesta básica e outras de caráter pecuniário, bem como os institutos despenalizadores da Lei Maria da Penha, são aplicáveis aos processos da própria competência.', false),
  (739, 5, 'O ciclo de violência doméstica é uma forma de violação dos direitos humanos.', true),
  (741, 1, 'Certo', false),
  (741, 2, 'Errado', true),
  (749, 1, 'A lei serve para todas as pessoas que se identificam com o sexo feminino, heterossexuais e homossexuais. Isto quer dizer que as mulheres transexuais também estão incluídas.', false),
  (749, 2, 'A vítima precisa estar em situação de vulnerabilidade em relação ao agressor. Este não precisa ser necessariamente o marido ou companheiro: pode ser um parente ou uma pessoa do seu convívio.', false),
  (749, 3, 'A Lei traz novidades como a prisão do suspeito de agressão e não é mais possível substituir a pena por doação de cesta básica ou multas.', false),
  (749, 4, 'Uma característica inovadora é que a Lei contempla especificamente a agressão física sofrida pela mulher.', true),
  (749, 5, 'Anos depois de ter entrado em vigor, a lei Maria da Penha pode ser considerada um sucesso. Apenas 2% dos brasileiros nunca ouviram falar desta lei e houve um aumento de 86% de denúncias de violência familiar e doméstica após sua criação.', false),
  (774, 1, 'Certo', false),
  (774, 2, 'Errado', true),
  (786, 1, 'A violência doméstica e familiar contra a mulher se constitui em uma das formas de violação dos direitos humanos.', true),
  (786, 2, 'Cabe exclusivamente ao poder público criar as condições necessárias para o efetivo exercício dos direitos enunciados na legislação.', false),
  (786, 3, 'Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral, exceto o patrimonial.', false),
  (786, 4, 'A política pública que visa coibir a violência doméstica e familiar contra a mulher far-se-á por meio exclusivo de ações da União e dos Estados.', false),
  (786, 5, 'A criação dos Juizados de Violência Doméstica e Familiar contra a Mulher, órgãos da Justiça Ordinária com competência cível e criminal, é de competência da União, estando distribuídos nos Estados e no Distrito Federal, para o processo, o julgamento e a execução das causas decorrentes da prática de violência doméstica e familiar contra a mulher.', false),
  (804, 1, 'Para os efeitos da referida lei, a configuração da violência doméstica e familiar contra a mulher depende da demonstração de coabitação da ofendida e do agressor.', false),
  (804, 2, 'Os juizados especiais de violência doméstica e familiar contra a mulher têm competência exclusivamente criminal.', false),
  (804, 3, 'É tido como o âmbito da unidade doméstica o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, salvo as esporadicamente agregadas.', false),
  (804, 4, 'A ofendida poderá entregar intimação ou notificação ao agressor se não houver outro meio de realizar a comunicação.', false),
  (804, 5, 'Considera-se violência sexual a conduta de forçar a mulher ao matrimônio mediante coação, chantagem, suborno ou manipulação, assim como a conduta de limitar ou anular o exercício de seus direitos sexuais e reprodutivos.', true),
  (818, 1, 'recebeu notificação para entrega à companheira ANA comparecer, na condição de averiguada, perante a Autoridade Policial, para prestar esclarecimentos.', false),
  (818, 2, 'foi lavrado Termo Circunstanciado pela possível prática de delito de menor potencial ofensivo, regido pela Lei dos Juizados Especiais Criminais (Lei no 9.099/99).', false),
  (818, 3, 'foi lavrado Boletim de Ocorrência, após notícia dos fatos, porque DULCE foi vítima de violência patrimonial e psicológica, por condição de gênero feminino.', true),
  (818, 4, 'não foi lavrado Boletim de Ocorrência, após notícia dos fatos, porque ANA, autora dos fatos, é mulher, e, portanto, DULCE não está em situação de vulnerabilidade.', false),
  (818, 5, 'não foi lavrado Boletim de Ocorrência, após notícia dos fatos, porque a violência patrimonial implica ilícito civil, não contemplado pela Lei Maria da Penha (Lei no 11.340/06).', false),
  (823, 1, 'abandono;', false),
  (823, 2, 'maus tratos;', false),
  (823, 3, 'vulnerabilidade socioeconômica;', false),
  (823, 4, 'violência psicológica;', true),
  (823, 5, 'violência emocional.', false),
  (851, 1, 'somente II;', false),
  (851, 2, 'somente I, II e IV;', false),
  (851, 3, 'somente I, III e V;', false),
  (851, 4, 'somente IV e V;', false),
  (851, 5, 'I, II, III, IV e V.', true),
  (863, 1, 'Certo', true),
  (863, 2, 'Errado', false),
  (864, 1, 'é permitida a aplicação, nos casos de violência doméstica e familiar contra a mulher, de penas de cesta básica ou outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa.', false),
  (864, 2, 'aplica-se a Lei n.º 9.099/1995 – Juizados Especiais Cíveis e Criminais – aos crimes praticados com violência doméstica e familiar contra a mulher.', false),
  (864, 3, 'a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', true),
  (864, 4, 'não caracteriza violência moral a conduta que configure calúnia, difamação ou injúria contra a mulher.', false),
  (864, 5, 'tal norma não é aplicável aos crimes praticados com violência doméstica e familiar contra crianças e adolescentes de sexo feminino.', false),
  (871, 1, 'Fulano, pela sua conduta, poderá ser submetido à pena de pagamento de cestas básicas em favor de entidades assistenciais.', false),
  (871, 2, 'Fulano não se sujeitará às penas da Lei Maria da Penha, pois a sua conduta ocorreu apenas dentro do ambiente familiar.', false),
  (871, 3, 'Fulano estará sujeito à prisão preventiva, a ser decretada pelo juiz, de ofício, a requerimento do Ministério Público ou mediante representação da autoridade policial.', true),
  (871, 4, 'Fulano não poderá ser processado pela Lei Maria da Penha, tendo em vista que esta se destina a proteger a mulher contra agressões físicas, psicológicas ou morais, mas não patrimoniais.', false),
  (871, 5, 'Ciclana terá direito a obter medida judicial protetiva de urgência contra Fulano, podendo entregar pessoalmente a intimação da respectiva medida ao seu marido.', false),
  (884, 1, 'A lei em pauta estabelece a habitualidade das condutas como requisito configurador das infrações nela contempladas, ou seja, como elemento constitutivo do tipo.', false),
  (884, 2, 'Caso uma empregada doméstica, maior e capaz, ao receber a notícia que será despedida, sob a suspeita da prática de furtos, agrida seu patrão — este com sessenta e sete anos de idade — e fuja, tal conduta da empregada em face do patrão caracterizará violência doméstica expressamente tipificada na lei em questão.', false),
  (884, 3, 'A violência familiar, assim considerada para efeitos da lei em pauta, engloba a praticada entre pessoas unidas por vínculo jurídico de natureza familiar ou por vontade expressa.', true),
  (884, 4, 'O conflito entre vizinhas de que resulte violência física e agressões verbais constitui evento que integra a esfera da violência doméstica e familiar de que trata a lei em apreço.', false),
  (884, 5, 'Para a caracterização de violência doméstica e familiar é imprescindível a existência de vínculo familiar entre o agente e o paciente.', false),
  (889, 1, 'Certo', true),
  (889, 2, 'Errado', false),
  (908, 1, 'Aos crimes praticados com violência doméstica e familiar contra a mulher, independentemente da pena prevista, aplica-se a Lei n. 9.099, de 26 de setembro de 1995.', true),
  (908, 2, 'Nos casos de violência doméstica contra a mulher, o juiz poderá determinar o comparecimento obrigatório do agressor a programas de recuperação e reeducação.', false),
  (908, 3, 'Caberá ao Ministério Público, sem prejuízo de outras atribuições, nos casos de violência doméstica e familiar contra a mulher cadastrar esses casos de violência.', false),
  (908, 4, 'A violência doméstica e familiar contra a mulher qualifica-se como violência sexual quando ela for impedida de usar qualquer método contraceptivo, mediante coação, chantagem, suborno ou manipulação.', false),
  (912, 1, 'Certo', false),
  (912, 2, 'Errado', true),
  (921, 1, 'Apenas I', false),
  (921, 2, 'Apenas II', false),
  (921, 3, 'Apenas III', false),
  (921, 4, 'Apenas I e II', true),
  (921, 5, 'I, II e III', false),
  (926, 1, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação do direitos humanos.', false),
  (926, 2, 'No atendimento à mulher em situação de violência doméstica e familiar, a autoridade policial deverá encaminhar a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal.', false),
  (926, 3, 'Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou pisicológico e dano moral ou patrimonial.', false),
  (926, 4, 'Para os processos regidos pela Lei Maria da Penha, é corretamente, independente da opção da ofendida, o Juizado do seu domicílio ou de sua residência.', true),
  (941, 1, 'Inserem-se no âmbito de aplicação da Lei as relações entre ex-namorados, ainda que não tenha havido convivência.', false),
  (941, 2, 'Crime de violência doméstica, praticado contra a mulher a bordo de aeronave, será julgado perante a Justiça Estadual.', true),
  (941, 3, 'A Lei nº 11.340/06 não previu rito diferenciado.', false),
  (941, 4, 'Apelação interposta contra sentença prolatada por Juizado de violência doméstica e familiar contra a mulher será julgada pelo Tribunal de Justiça respectivo.', false),
  (941, 5, 'A Lei supra fugiu da ratio essendi original, de destinar especial cuidado às vítima maltratadas por seus parceiros, abarcando relações homoafetivas entre mulheres.', false),
  (943, 1, 'Considera-se violência doméstica e familiar contra a mulher, entre outras condutas, a conduta que configure destruição parcial ou total de seus objetos, instrumentos de trabalho, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (943, 2, 'A Lei Maria da Penha (11.340/2006) não considera violência doméstica contra a mulher a omissão baseada no gênero que lhe cause sofrimento apenas psicológico em uma relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida.', true),
  (943, 3, 'Constatada a prática de violência doméstica e familiar contra a mulher, nos termos da lei, o juiz poderá aplicar, de imediato, ao agressor, em conjunto ou separadamente, medidas protetivas de urgência, dentre elas o afastamento do lar, proibição de aproximação da ofendida e a prestação de alimentos provisórios.', false),
  (943, 4, 'É vedada a aplicação, nos casos de violência doméstica e familiar contra a mulher, de penas de cesta básica ou outras de prestação pecuniária, bem como a substituição de pena que implique o pagamento isolado de multa.', false),
  (943, 5, 'Nas ações penais públicas condicionadas à representação da ofendida de que trata essa lei, só será admitida a renúncia à representação perante o juiz, em audiência especialmente designada com tal finalidade, antes do recebimento da denúncia e ouvido o Ministério Público.', false),
  (945, 1, 'Certo', true),
  (945, 2, 'Errado', false),
  (947, 1, 'são formas de violência doméstica e familiar contra a mulher, entre outras a violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (947, 2, 'no atendimento à mulher em situação de violência doméstica e familiar, a autoridade policial deverá fornecer proteção referente à sua segurança pessoal, não incluindo nestes procedimentos acompanhar a ofendida para assegurar a retirada de seus pertences do local da ocorrência ou do domicílio familiar.', false),
  (947, 3, 'dependendo da gravidade da violência doméstica e familiar contra a mulher, feito o registro da ocorrência, poderá a autoridade policial, no caso específico, adotar procedimentos determinando que se proceda ao exame de corpo de delito da ofendida.', false),
  (947, 4, 'como medida protetiva de urgência à ofendida, poderá o juiz, quando necessário, sem prejuízo de outras medidas, determinar o afastamento da ofendida do lar, sem determinar a separação de corpos, por tratar-se tal separação de matéria de direito civil.', false),
  (949, 1, 'O juiz assegurará à mulher em situação de violência doméstica e familiar, para preservar sua integridade física e psicológica, a manutenção do seu vínculo trabalhista e, quando necessário, o afastamento do local de trabalho por até um ano.', false),
  (949, 2, 'O juiz somente poderá assegurar à mulher servidora pública vítima de violência doméstica e familiar prioridade remoção do local de trabalho, quando houver comprovação de lesão corporal, de forma a garantir que ela se afaste do ambiente que representa risco à sua segurança e possa reconstruir sua rotina com dignidade e proteção efetiva.', false),
  (949, 3, 'Os dispositivos de segurança destinados a situações de perigo iminente, disponibilizados para o monitoramento de vítimas de violência doméstica ou familiar amparadas por medidas protetivas terão seus custos ressarcidos pelo agressor.', true),
  (949, 4, 'Aquele que, por ação ou omissão, causar lesão ou dano à mulher, nos casos específicos de violência física e sexual, ficará obrigado a ressarcir integralmente todos os prejuízos decorrentes, inclusive a restituir ao Sistema Único de Saúde (SUS), conforme a tabela oficial, os custos relativos aos serviços de saúde prestados para o tratamento completo das vítimas de violência doméstica e familiar.', false),
  (949, 5, 'A mulher em situação de violência doméstica e familiar possui prioridade para matricular seus dependentes em instituições de educação básica próximas ao seu domicílio, bem como para transferi-los para tais instituições, sem a exigência de apresentação de documentos comprobatórios da ocorrência policial, visando à preservação da integridade física e psicológica de seus dependentes.', false),
  (954, 1, 'Registrar a ocorrência e aguardar manifestação do Ministério Público para adoção de medidas.', false),
  (954, 2, 'Informar à vítima seus direitos e os serviços disponíveis de atendimento.', true),
  (954, 3, 'Encaminhar a vítima ao Instituto Médico-Legal apenas se houver lesão corporal grave.', false),
  (954, 4, 'Conceder diretamente as medidas protetivas de urgência.', false),
  (954, 5, 'Aguardar representação formal da vítima para iniciar qualquer procedimento.', false),
  (955, 1, 'do Chefe de Cartório, mediante decisão liminar ad referendum da autoridade judicial competente.', false),
  (955, 2, 'do Delegado de Polícia da comarca vizinha, com posterior comunicação ao juízo.', false),
  (955, 3, 'do policial que atendeu à ocorrência, diante da ausencia de delegado e por não se tratar de sede de comarca.', true),
  (955, 4, 'do membro do Ministério Público, por meio de requisição à autoridade policial.', false),
  (956, 1, 'verificada a existência de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher em situação de violência doméstica e familiar, ou de seus dependentes.', true),
  (956, 2, 'verificada a existência de risco iminente apenas.', false),
  (956, 3, 'o risco envolver exclusivamente a integridade patrimonial da mulher.', false),
  (956, 4, 'verificada o risco exclusivamente físico à mulher, não se aplicando a situações de risco psicológico ou aos seus dependentes.', false),
  (956, 5, 'o risco envolver exclusivamente os dependentes da mulher, não sendo aplicáveis nos casos de ameaça direta à integridade dela.', false),
  (957, 1, 'Feito o registro da ocorrência, em todos os casos de violência doméstica e familiar contra a mulher, a autoridade policial deverá, de imediato, colher todas as provas que servirem para o esclarecimento do fato e de suas circunstâncias.', true),
  (957, 2, 'A autoridade policial que tomar conhecimento da ocorrência durante o atendimento policial somente adotará as providências legais cabíveis quando da confirmação da prática de violência doméstica e familiar contra a mulher.', false),
  (957, 3, 'A autoridade policial que atender uma mulher em situação de violência doméstica deverá garantir a imediata proteção policial da vítima e comunicar o fato ao Ministério Público e ao Poder Judiciário no prazo de 24 horas.', false),
  (957, 4, 'Feito o registro da ocorrência, nos casos de violência física contra a mulher, a autoridade policial deverá remeter, no prazo de 24 horas, expediente apartado ao juiz com o pedido da ofendida para concessão de medidas protetivas de urgência.', false),
  (957, 5, 'Verificada a existência de risco à vida da mulher em situação de violência doméstica ou familiar, caberá ao policial, em qualquer hipótese, afastar imediatamente o agressor do lar de convivência com a ofendida.', false),
  (960, 1, 'a manutenção do vínculo laboral, em caso de necessidade de afastamento do local de trabalho, será garantida pelo prazo mínimo de doze meses.', false),
  (960, 2, 'o acesso prioritário à remoção é um direito garantido a todas as trabalhadoras ofendidas, independentemente de serem do setor público ou privado.', false),
  (960, 3, 'a assistência compreenderá o acesso aos benefícios do desenvolvimento científico e tecnológico, incluindo a profilaxia das Doenças Sexualmente Transmissíveis (DST).', true),
  (960, 4, 'a inclusão da mulher no cadastro de programas assistenciais do governo deve ser determinada pela autoridade judiciária por prazo indeterminado.', false),
  (961, 1, 'autoridade judicial; pelo Promotor de Justiça, quando o Município não for sede de comarca; ou pelo delegado de polícia, quando o Município não for sede de comarca e não houver representante do Ministério Público disponível no momento da denúncia.', false),
  (961, 2, 'autoridade judicial; pelo delegado de polícia, quando o Município não for sede de comarca; ou pelo policial, quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia.', true),
  (961, 3, 'Promotor de Justiça; pelo delegado de polícia, quando o Município não for sede de comarca; ou pelo policial, quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia.', false),
  (961, 4, 'Promotor de Justiça; ou pelo delegado de polícia, quando o Município não for sede de comarca.', false),
  (961, 5, 'autoridade judicial; ou pelo Promotor de Justiça, quando o Município não for sede de comarca.', false),
  (962, 1, 'somente pela autoridade judicial.', false),
  (962, 2, 'somente pela autoridade judicial e pelo delegado de polícia, em qualquer situação.', false),
  (962, 3, 'pelo delegado de polícia, quando o município não for sede de comarca.', true),
  (962, 4, 'pelo policial, em qualquer situação.', false),
  (962, 5, 'somente pelo policial, quando o município não for sede de comarca.', false),
  (964, 1, 'A violência estrutural é aquela entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (964, 2, 'A violência psicológica e patrimonial é entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (964, 3, 'A política pública que visa coibir a violência doméstica e familiar contra a mulher far-se-á exclusivamente por meio das ações da União no âmbito do governo federal.', false),
  (964, 4, 'Na hipótese da iminência ou da prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência adotará, de imediato, as providências legais cabíveis.', true),
  (965, 1, 'Ressarcir os danos psicológicos, incluindo o pagamento de sessões de acompanhamento psicológico para a vítima.', false),
  (965, 2, 'Ressarcir todos os danos causados, inclusive ressarcir ao Sistema Único de Saúde (SUS), pelos custos relativos aos serviços de saúde prestados para o total tratamento das vítimas.', true),
  (965, 3, 'Ressarcir exclusivamente os danos morais e materiais comprovados pela vítima, sem outras obrigações.', false),
  (965, 4, 'Realizar o pagamento de um benefício mensal à vítima enquanto durar o tratamento médico ou psicológico.', false),
  (965, 5, 'Contratar serviços privados de saúde e assistência para atender à vítima, a critério dela.', false),
  (967, 1, 'ouvir a ofendida, lavrar o boletim de ocorrência e tomar a representação a termo, se apresentada.', true),
  (967, 2, 'remeter os autos ao juiz, no prazo de até 36 horas e solicitar, diretamente ao juízo, a decretação da prisão preventiva do agressor.', false),
  (967, 3, 'solicitar autorização judicial para a realização do exame de corpo de delito e ouvir o agressor após a manifestação do Ministério Público.', false),
  (967, 4, 'requerer a autorização para proceder com a oitiva das testemunhas indicadas pela ofendida e das partes.', false),
  (967, 5, 'manter a ofendida em ambiente isolado pelo prazo de 48 horas para que não tenha contato com o agressor nesse período.', false),
  (969, 1, 'As asserções I e II são proposições verdadeiras, e a II é uma justificativa da I.', false),
  (969, 2, 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa da I.', false),
  (969, 3, 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', false),
  (969, 4, 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', true),
  (969, 5, 'As asserções I e II são proposições falsas.', false),
  (970, 1, 'Apenas I', false),
  (970, 2, 'Apenas II', false),
  (970, 3, 'Apenas III', false),
  (970, 4, 'Apenas I e II', false),
  (970, 5, 'I, II e III', true),
  (971, 1, 'O depoimento será registrado em meio eletrônico ou magnético, devendo a degravação e a mídia integrar o inquérito; encaminhar a ofendida ao hospital ou posto de saúde e ao Instituto Médico Legal;', false),
  (971, 2, 'Salvaguarda da integridade física, psíquica e emocional da depoente, considerada a sua condição peculiar de pessoa em situação de violência doméstica e familiar; garantia de que, em nenhuma hipótese, a mulher em situação de violência doméstica e familiar, familiares e testemunhas terão contato direto com investigados ou suspeitos e pessoas a eles relacionadas;', true),
  (971, 3, 'Se necessário, acompanhar a ofendida para assegurar a retirada de seus pertences do local da ocorrência ou do domicílio familiar; quando for o caso, a inquirição será intermediada por profissional especializado em violência doméstica e familiar designado pela autoridade judiciária ou policial;', false),
  (971, 4, 'Na hipótese da iminência ou da prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência adotará, de imediato, as providências legais cabíveis;', false),
  (971, 5, 'A mulher em situação de violência doméstica e familiar tem prioridade para matricular seus dependentes em instituição de educação básica mais próxima de seu domicílio, ou transferi-los para essa instituição, mediante a apresentação dos documentos comprobatórios do registro da ocorrência policial ou do processo de violência doméstica e familiar em curso.', false),
  (972, 1, 'Capacitação da mulher para ingressar no mercado de trabalho.', true),
  (972, 2, 'Promoção e realização de campanhas educativas de prevenção da violência doméstica e familiar contra a mulher.', false),
  (972, 3, 'Capacitação permanente das Polícias Civil e Militar, da Guarda Municipal, do Corpo de Bombeiros quanto às questões de gênero e de raça ou etnia.', false),
  (972, 4, 'Promoção de estudos e pesquisas, estatísticas e outras informações relevantes, com a perspectiva de gênero.', false),
  (972, 5, 'Integração operacional do Poder Judiciário, do Ministério Público e da Defensoria Pública com as áreas de segurança pública, assistência social, saúde, educação, trabalho e habitação', false),
  (974, 1, 'A promoção de estudos e pesquisas, estatísticas e outras informações relevantes, com a perspectiva de gênero e de raça ou etnia, concernentes às causas, às consequências e à frequência da violência doméstica e familiar contra a mulher, para a sistematização de dados, a serem unificados nacionalmente, e a avaliação periódica dos resultados das medidas adotadas;', false),
  (974, 2, 'A celebração de convênios, protocolos, ajustes, termos ou outros instrumentos de promoção de parceria entre órgãos governamentais ou entre estes e entidades nãogovernamentais, tendo por objetivo a implementação de programas de erradicação da violência doméstica e familiar contra a mulher;', false),
  (974, 3, 'A assistência à mulher em situação de violência doméstica e familiar compreenderá o acesso aos benefícios decorrentes do desenvolvimento científico e tecnológico, incluindo os serviços de contracepção de emergência, a profilaxia das Doenças Sexualmente Transmissíveis (DST) e da Síndrome da Imunodeficiência Adquirida (AIDS) e outros procedimentos médicos necessários e cabíveis nos casos de violência sexual;', true),
  (974, 4, 'A promoção de programas educacionais que disseminem valores éticos de irrestrito respeito à dignidade da pessoa humana com a perspectiva de gênero e de raça ou etnia;', false),
  (974, 5, 'A promoção e a realização de campanhas educativas de prevenção da violência doméstica e familiar contra a mulher, voltadas ao público escolar e à sociedade em geral, e a difusão desta Lei e dos instrumentos de proteção aos direitos humanos das mulheres.', false),
  (975, 1, 'Certo', true),
  (975, 2, 'Errado', false),
  (976, 1, 'Em qualquer fase do inquérito policial ou da instrução criminal, caberá a prisão preventivav do agressor, decretada pelo juiz, de ofício, a requerimento do Ministério Público ou mediante representação da autoridade policial.', false),
  (976, 2, 'Na interpretação desta Lei, serão considerados os fins sociais a que ela se destina e, especialmente, as condições peculiares das mulheres em situação de violência doméstica e familiar.', false),
  (976, 3, 'O juiz determinará, por prazo certo, a inclusão da mulher em situação de violência doméstica e familiar no cadastro de programas assistenciais do governo federal, estadual e municipal.', false),
  (976, 4, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', false),
  (976, 5, 'Na hipótese da iminência ou da prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência adotadará, em até 48 (quarenta e oito) horas, as providências legais cabíveis.', true),
  (980, 1, 'Certo', false),
  (980, 2, 'Errado', true),
  (981, 1, '12 (doze) horas, expediente apartado ao juiz com o pedido da ofendida, para a concessão de medidas protetivas de urgência.', false),
  (981, 2, '24 (vinte e quatro) horas, expediente apartado ao juiz com o pedido da ofendida, para a concessão de medidas protetivas de urgência.', false),
  (981, 3, '36 (trinta e seis) horas, expediente apartado ao juiz com o pedido da ofendida, para a concessão de medidas protetivas de urgência.', false),
  (981, 4, '48 (quarenta e oito) horas, expediente apartado ao juiz com o pedido da ofendida, para a concessão de medidas protetivas de urgência.', true),
  (982, 1, 'Certo', false),
  (982, 2, 'Errado', true),
  (983, 1, 'nos casos de risco à integridade física da ofendida ou à efetividade da medida protetiva de urgência, poderá ser concedida liberdade provisória ao agressor após audiência de custódia.', false),
  (983, 2, 'verificada a existência de risco atual ou iminente à vida ou à integridade física ou psicológica da mulher em situação de violência doméstica e familiar, ou de seus dependentes, o agressor será imediatamente afastado do lar, domicílio ou local de convivência com a ofendida, pelo policial, quando o Município não for sede de comarca e não houver delegado disponível no momento da denúncia.', true),
  (983, 3, 'devido à proteção dos dados pessoais da ofendida, não serão admitidos como meios de prova os laudos ou prontuários médicos fornecidos por hospitais e postos de saúde.', false),
  (983, 4, 'em todos os casos de violência doméstica e familiar contra a mulher, feito o registro da ocorrência, deverá a autoridade policial remeter, no prazo de 24 (vinte e quatro) horas, expediente apartado ao juiz com pedido da ofendida, para a concessão de medidas protetivas de urgência.', false),
  (983, 5, 'em casos leves envolvendo violência doméstica e familiar contra a mulher, poderão ser aplicadas penas de cesta básica ou de prestação pecuniária ao agressor.', false),
  (984, 1, 'Joana deverá ser obrigatoriamente inquirida por servidoras do sexo feminino, em recinto especialmente projetado para esse fim, por profissional especializada em violência doméstica e familiar, e o depoimento será registrado em meio eletrônico ou magnético, devendo a degravação e a mídia integrarem o inquérito.', false),
  (984, 2, 'A autoridade policial que atender à ocorrência deverá remeter, no prazo de 24 (vinte e quatro) horas, expediente apartado ao juiz com o pedido de Joana, para a concessão de medidas protetivas de urgência.', false),
  (984, 3, 'O policial, verificando a existência de risco atual ou iminente à vida de Joana, deverá imediatamente afastar José do lar, pois o crime ocorreu na sexta-feira à noite, horário em que não há juiz de plantão na comarca.', false),
  (984, 4, 'José é obrigado a ressarcir ao SUS, de acordo com a tabela SUS, os custos relativos aos serviços de saúde prestados para o total tratamento de Joana, recolhidos os recursos assim arrecadados ao Fundo de Saúde do ente federado responsável pela unidade de saúde que prestou o serviço.', true),
  (984, 5, 'A Joana é assegurada a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até um ano.', false),
  (985, 1, 'V, F, F, F.', false),
  (985, 2, 'V, F, F, V.', true),
  (985, 3, 'V, V, V, V.', false),
  (985, 4, 'F, F, V, V.', false),
  (987, 1, 'É permitida a aplicação de penas de cesta básica ou outras de prestação pecuniária, porém, é vedada a substituição de pena que implique o pagamento isolado de multa.', false),
  (987, 2, 'O nome da ofendida e do ofensor ficarão sob sigilo nos processos em que se apuram crimes violentos praticados contra a mulher.', false),
  (987, 3, 'A ofendida deverá ser comunicada dos atos processuais relativos ao agressor, inclusive aos pertinentes ao ingresso e à saída da prisão, exclusivamente por seu advogado constituído ou defensor público.', false),
  (987, 4, 'O juiz poderá assegurar à mulher em situação de violência doméstica, para preservar sua integridade física e psicológica, a manutenção do vínculo trabalhista, quando necessário o afastamento do local de trabalho, por até seis meses.', true),
  (987, 5, 'É direito da mulher em situação de violência doméstica e familiar o atendimento policial e pericial especializado, ininterrupto e prestado por servidores – exclusivamente do sexo feminino – previamente capacitados.', false),
  (989, 1, 'Certo', false),
  (989, 2, 'Errado', true),
  (991, 1, 'acesso à licença remunerada por até 12 meses quando servidora pública, integrante da administração direta ou indireta.', false),
  (991, 2, 'acesso prioritário à remoção quando servidora pública, integrante da administração direta ou indireta.', true),
  (991, 3, 'acesso a benefícios previdenciários de natureza indenizatória quando servidora pública, integrante da administração direta ou indireta.', false),
  (991, 4, 'acesso ao afastamento do local de trabalho sem remuneração por até 36 meses quando servidora pública, integrante da administração direta ou indireta.', false),
  (991, 5, 'acesso à redistribuição quando servidora pública, integrante da administração direta ou indireta.', false),
  (992, 1, 'a direção da escola mais próxima do domicílio da mulher em situação de violência, seja ela pública ou privada, é obrigada a receber os filhos menores até haver uma vaga definitiva;', false),
  (992, 2, 'caso a rede pública de educação não tenha vaga para os dependentes menores, a rede de educação privada é obrigada a recebê-los;', false),
  (992, 3, 'os filhos menores serão matriculados no estabelecimento público de educação em que houver vaga, e a Prefeitura ofertará transporte, caso seja necessário;', false),
  (992, 4, 'a mulher em situação de violência doméstica e familiar tem prioridade para matricular seus dependentes em instituição de educação básica mais próxima de seu domicílio;', true),
  (992, 5, 'configurando-se a ausência de vagas na rede pública próxima ao domicílio, não há o que possa ser feito, e os dependentes menores serão matriculados onde houver vaga.', false),
  (994, 1, 'A implementação de atendimento policial especializado para as mulheres, em particular nas Delegacias de Atendimento à Mulher.', false),
  (994, 2, 'A promoção de programas educacionais que disseminem valores éticos de restrito respeito à dignidade da pessoa humana com a perspectiva de gênero e de raça ou etnia.', true),
  (994, 3, 'O destaque, nos currículos escolares de todos os níveis de ensino, para os conteúdos relativos aos direitos humanos, à equidade de gênero e de raça ou etnia e ao problema da violência doméstica e familiar contra a mulher.', false),
  (994, 4, 'A promoção e a realização de campanhas educativas de prevenção da violência doméstica e familiar contra a mulher, voltadas ao público escolar e à sociedade em geral, e a difusão desta Lei e dos instrumentos de proteção aos direitos humanos das mulheres.', false),
  (995, 1, 'Contracepção de emergência.', false),
  (995, 2, 'Profilaxia das Doenças Sexualmente Transmissíveis.', false),
  (995, 3, 'Profilaxia da Trombose.', true),
  (995, 4, 'Profilaxia da Síndrome da Imunodeficiência Adquirida.', false);

create temporary table _lote1_vinculos (
  caderno_numero int,
  unidade_pedagogica_id uuid
) on commit drop;

insert into _lote1_vinculos (caderno_numero, unidade_pedagogica_id) values
  (216, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (221, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (260, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (275, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (284, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (284, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
  (370, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (378, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (378, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (393, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (395, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (411, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (429, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (436, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (468, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (481, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (484, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (534, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (534, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (561, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (577, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
  (606, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
  (619, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (619, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (646, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (653, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (664, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (696, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (706, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (711, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (726, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (728, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (728, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (730, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (730, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
  (738, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (739, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (741, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (749, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (774, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (786, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (804, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (818, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (823, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (851, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (863, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (864, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (871, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (884, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (889, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (912, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (921, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (945, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (947, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid),
  (949, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (954, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (955, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (957, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (960, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (961, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (962, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (964, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (965, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (967, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (969, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (970, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (970, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid),
  (971, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (972, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (974, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (975, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (980, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (981, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (982, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (983, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (984, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (984, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (985, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (987, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (989, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid),
  (991, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (992, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (994, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid),
  (995, 'ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid);

-- ----------------------------------------------------------------------------
-- Revalidacao de premissas dentro da propria transacao antes de qualquer
-- escrita real (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
begin
  if (select count(*) from _lote1_questoes) <> 85 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 85 questoes';
  end if;
  if exists (select 1 from _lote1_questoes where caderno_numero in (950, 999)) then
    raise exception 'Precondicao falhou: caderno 950 ou 999 presente no staging';
  end if;

  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 53;

  if v_materia_id is distinct from 10 or v_assunto_id is distinct from 19 then
    raise exception 'Precondicao falhou: conteudo 53 materia_id=% assunto_id=% (esperado 10/19)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true) <> 5 then
    raise exception 'Precondicao falhou: nao ha exatamente 5 unidades pedagogicas ativas para o conteudo 53';
  end if;

  if exists (
    select 1 from public.questoes q
    join _lote1_questoes l on q.fonte like '%' || l.tec_id::text || '%'
  ) then
    raise exception 'Precondicao falhou: algum tec_id do Lote 1 ja existe em questoes.fonte (possivel duplicata)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — questoes (loop explicito para mapear caderno_numero -> id real
-- de forma inequivoca, sem depender de ordem implicita de RETURNING).
-- ----------------------------------------------------------------------------
create temporary table _lote1_ids (caderno_numero int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_id bigint;
begin
  for r in select * from _lote1_questoes order by caderno_numero loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, enunciado, fonte, ano, ativa)
    values (10, 19, r.banca, r.concurso, r.enunciado, r.fonte, r.ano, true)
    returning id into v_id;

    insert into _lote1_ids (caderno_numero, questao_id) values (r.caderno_numero, v_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — alternativas.
-- ----------------------------------------------------------------------------
insert into public.alternativas (questao_id, texto, correta, ordem)
select m.questao_id, a.texto, a.correta, a.ordem
from _lote1_alternativas a
join _lote1_ids m using (caderno_numero);

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — curso_questoes (todas as 85 no mesmo curso do conteudo 53,
-- mesmo curso ja usado pelas 27 questoes reais existentes deste assunto).
-- ----------------------------------------------------------------------------
insert into public.curso_questoes (curso_id, questao_id)
select '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, questao_id
from _lote1_ids;

-- ----------------------------------------------------------------------------
-- ESCRITA 4 — vinculos de unidade pedagogica, via RPC oficial (mesma usada
-- pelo app), nunca INSERT direto em questao_unidades_pedagogicas.
-- ----------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select m.questao_id, v.unidade_pedagogica_id
    from _lote1_vinculos v
    join _lote1_ids m using (caderno_numero)
  loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_lote1_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_lote1_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_lote1_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_antes record;
  v_depois record;
  v_sem_correta int;
  v_multi_correta int;
  v_banco_geral_com_vinculo int;
  v_faltando_vinculo int;
  v_multiunidade_com_2 int;
  v_missao_final bigint[];
  v_ids_banco_geral bigint[];
  v_ids_unidade bigint[];
  v_banco_geral_na_missao int;
  v_unidade_na_missao int;
  v_banco_geral_vazando_u1 int;
begin
  select * into v_antes from _snapshot_antes;
  select
    (select count(*) from public.questoes)                     as total_questoes,
    (select count(*) from public.alternativas)                 as total_alternativas,
    (select count(*) from public.unidades_pedagogicas)          as total_unidades,
    (select count(*) from public.curso_conteudos)               as total_conteudos,
    (select count(*) from public.curso_questoes)                as total_curso_questoes,
    (select count(*) from public.respostas_usuarios)            as total_respostas,
    (select count(*) from public.sessoes_estudo)                as total_sessoes,
    (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos
  into v_depois;

  call teste_lote1_assert('questoes +85', v_depois.total_questoes = v_antes.total_questoes + 85);
  call teste_lote1_assert('alternativas +364', v_depois.total_alternativas = v_antes.total_alternativas + 364);
  call teste_lote1_assert('curso_questoes +85', v_depois.total_curso_questoes = v_antes.total_curso_questoes + 85);
  call teste_lote1_assert('questao_unidades_pedagogicas +84', v_depois.total_vinculos = v_antes.total_vinculos + 84);
  call teste_lote1_assert('unidades_pedagogicas inalterada (nenhuma unidade criada/removida)', v_depois.total_unidades = v_antes.total_unidades);
  call teste_lote1_assert('curso_conteudos inalterada', v_depois.total_conteudos = v_antes.total_conteudos);
  call teste_lote1_assert('respostas_usuarios inalterada', v_depois.total_respostas = v_antes.total_respostas);
  call teste_lote1_assert('sessoes_estudo inalterada', v_depois.total_sessoes = v_antes.total_sessoes);

  select count(*) into v_sem_correta
  from _lote1_ids m
  where (select count(*) from public.alternativas a where a.questao_id = m.questao_id and a.correta) <> 1;
  call teste_lote1_assert('todas as 85 questoes tem exatamente 1 alternativa correta', v_sem_correta = 0);

  select count(*) into v_banco_geral_com_vinculo
  from _lote1_ids m
  where m.caderno_numero not in (select caderno_numero from _lote1_vinculos)
    and exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  call teste_lote1_assert('as 9 banco geral nao ganharam nenhum vinculo de unidade', v_banco_geral_com_vinculo = 0);

  select count(*) into v_faltando_vinculo
  from (select distinct caderno_numero from _lote1_vinculos) c
  join _lote1_ids m using (caderno_numero)
  where not exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  call teste_lote1_assert('as 76 questoes com unidade no CSV tem pelo menos 1 vinculo real', v_faltando_vinculo = 0);

  select count(*) into v_multiunidade_com_2
  from (
    select caderno_numero, count(*) as n from _lote1_vinculos group by caderno_numero having count(*) > 1
  ) multi
  join _lote1_ids m using (caderno_numero)
  where (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id) <> multi.n;
  call teste_lote1_assert('as 8 questoes multiunidade tem exatamente 2 vinculos cada', v_multiunidade_com_2 = 0);

  -- Ponta a ponta: confirma que o patch de selecionar_candidatas_conteudo
  -- (commit 027a3f6) + esta importacao juntos tornam as 9 banco geral
  -- elegiveis na Missao Final, sem tocar a pratica de unidade.
  select array_agg(m.questao_id) into v_ids_banco_geral
  from _lote1_ids m
  where m.caderno_numero not in (select caderno_numero from _lote1_vinculos);

  select array_agg(x.questao_id) into v_missao_final
  from public.selecionar_candidatas_conteudo(
    'e5523807-6cc8-4867-8a56-77c17552e56e'::uuid, 53::bigint, '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, 500, '{}'::bigint[], null
  ) x(questao_id);

  select count(*) into v_banco_geral_na_missao
  from unnest(v_ids_banco_geral) qid where qid = any(v_missao_final);

  call teste_lote1_assert(
    'todas as 9 banco geral novas aparecem na Missao Final (conteudo 53)',
    v_banco_geral_na_missao = 9
  );

  select array_agg(m.questao_id) into v_ids_unidade
  from _lote1_ids m
  where m.caderno_numero in (select caderno_numero from _lote1_vinculos);

  select count(*) into v_unidade_na_missao
  from unnest(v_ids_unidade) qid where qid = any(v_missao_final);

  call teste_lote1_assert(
    'todas as 76 questoes vinculadas tambem aparecem na Missao Final (conteudo 53)',
    v_unidade_na_missao = 76
  );

  select count(*) into v_banco_geral_vazando_u1
  from unnest(v_ids_banco_geral) qid
  where qid = any(array(
    select x.questao_id from public.selecionar_candidatas_unidade_pedagogica(
      'e5523807-6cc8-4867-8a56-77c17552e56e'::uuid, 'e260b54c-6a75-4398-97f6-7a432c405041'::uuid, '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, 500, '{}'::bigint[], null
    ) x(questao_id)
  ));

  call teste_lote1_assert(
    'nenhuma das 9 banco geral aparece na pratica da unidade U1',
    v_banco_geral_vazando_u1 = 0
  );
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_lote1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, questoes, alternativas, curso_questoes, vinculos e
-- as tabelas de assert — tudo desfeito abaixo.
ROLLBACK;
