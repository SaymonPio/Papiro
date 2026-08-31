-- Curadoria das unidades pedagogicas de Segurança da informação
-- (curso_conteudos.id = 40), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/seguranca_da_informacao.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 40, assunto "Segurança da informação")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Segurança da informação
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_seguranca_da_informacao*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 40;
  v_unidade_1_id constant uuid := 'a042af68-babf-4385-bcc4-2fa69e9b27cd';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Segurança da informação",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Segurança da informação'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Segurança da informação nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 40 nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_1_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_1_id;
  end if;

  -- Decisao aprovada: manter 1 unica unidade — nenhuma outra pode existir
  -- para este conteudo (execucao repetida nao deveria encontrar uma ordem
  -- criada por engano em outra etapa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem <> 1
  ) then
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 40 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Segurança da informação',
    escopo = 'Fundamentos de segurança da informação, com base nos fenômenos efetivamente observados em provas reais da Fundatec (2025-2026) mais quatro questões suplementares autorais. Organizado em seis eixos internos, sem fragmentação em unidades separadas (massa modesta de 13 questões vinculáveis, sem ruptura pedagógica que justifique split): EIXO 1 — PRINCÍPIOS DE SEGURANÇA (CIA): CONFIDENCIALIDADE (informação acessível apenas a entidades autorizadas), INTEGRIDADE (proteção contra alteração/destruição indevida, preservando exatidão e completude), DISPONIBILIDADE (acesso/uso quando requerido por entidade autorizada) — distinguir precisamente de AUTENTICIDADE (identidade/autoria) e CONFORMIDADE, termos frequentemente usados como distratores para confundir com confidencialidade e disponibilidade, respectivamente. EIXO 2 — AUTENTICAÇÃO: os três fatores de autenticação — CONHECIMENTO (algo que você sabe: senha, PIN), POSSE (algo que você tem: celular, token, aplicativo autenticador) e INERÊNCIA (algo que você é: biometria, impressão digital, reconhecimento facial); a AUTENTICAÇÃO EM DOIS FATORES (2FA/MFA) combina fatores de categorias diferentes — duas credenciais do mesmo tipo (ex.: duas senhas) continuam pertencendo à mesma categoria de fator e NÃO configuram multifator; sistemas modernos de MFA permitem que a primeira etapa não seja necessariamente uma senha tradicional (fluxos passwordless, biometria ou chave física como primeiro fator) — o ponto central é que senha NÃO é requisito universal do primeiro fator, sem transformar isso na afirmação de que "senha não é mais usada". EIXO 3 — MALWARE E CÓDIGOS MALICIOSOS: sintomas típicos de infecção (lentidão súbita, abertura espontânea de janelas/pop-ups); papel e limites do antivírus/antimalware (detecta, previne e remove determinadas ameaças, mas NÃO garante reversão de todos os danos — vazamento, exfiltração, destruição ou criptografia de arquivos já consumados podem ser irreversíveis, mesmo com antivírus); WORM como código malicioso autorreplicável que se propaga autonomamente pela rede, explorando vulnerabilidades, sem depender de arquivo hospedeiro nem de execução humana (diferente do vírus comum). A aula pode distinguir proporcionalmente vírus, worm, trojan, ransomware, spyware, adware e keylogger apenas na medida necessária para compreensão dos distratores e do eixo — sem alegar que cada uma dessas classes possui questão específica vinculada neste corpus. EIXO 4 — ATAQUES E FRAUDES: SPOOFING como falsificação/mascaramento de identidade ou origem (IP, e-mail, DNS, ARP, conforme o contexto), distinto de força bruta (tentativa e erro para descobrir senha), worm (autorreplicação) e DDoS (sobrecarga distribuída) — não tratar spoofing como sinônimo genérico de qualquer ataque; PHISHING como técnica de engenharia social em que uma mensagem eletrônica imita uma instituição/pessoa legítima para induzir a vítima a revelar credenciais ou executar ação prejudicial. EIXO 5 — CRIPTOGRAFIA E INTEGRIDADE: criptografia SIMÉTRICA (mesma chave secreta/compartilhada para cifrar e decifrar), distinta da ASSIMÉTRICA (par de chaves relacionadas, uma pública e uma privada); HASH como função de resumo/impressão digital de tamanho fixo usada para verificar se um arquivo permaneceu inalterado (útil em integridade e cadeia de custódia forense) — não chamar hash de "criptografia de mão única" (é uma função de resumo, não uma cifra), nem prometer que "hash prova sozinho autoria" ou que "hash cifra o arquivo". EIXO 6 — BACKUP: cópia preventiva de dados destinada à recuperação em caso de perda, corrupção, falha de hardware ou ataque, distinta de RESTORE (o processo de restauração a partir do backup), STORAGE (armazenamento) e sincronização (que não é necessariamente backup) — não expandir para a regra 3-2-1 ou detalhamento de tipos (full/incremental/differential) além do necessário para este corpus. RECORRÊNCIA: malware/códigos maliciosos é o ÚNICO eixo REAL com recorrência genuína neste corpus, observado em 3 provas/cadernos independentes (sintomas gerais, antivírus/limitações, worm) — a recorrência é do eixo, não do mesmo conceito específico repetido; demais fenômenos REAL (CIA, MFA, spoofing, criptografia simétrica, hash, backup) são INCIDÊNCIA REAL PONTUAL, observados em apenas 1 prova independente cada. PHISHING E 2FA — GAP DE PRÁTICA REAL: as duas questões sobre phishing (Q11, Q294) e as duas sobre 2FA/MFA autoral (Q15, Q32) são integralmente AUTORAL_PAPIRO — servem como cobertura suplementar de prática, mas não sustentam incidência histórica, recorrência ou frequência da banca; phishing especificamente não possui nenhuma questão REAL neste corpus, registrado como GAP_DE_PRATICA_ESPECIFICA_REAL_PHISHING (2FA/MFA, por outro lado, já possui 1 questão REAL — Q640 — sustentando incidência pontual). FONTES: para conceitos técnicos, priorizar fontes primárias/técnicas apropriadas ao tema quando necessário (NIST, CERT.br, CISA), sem atribuir formulações específicas a essas instituições sem verificação; para os fatos históricos em si, priorizar a prova/caderno/gabarito da banca. CAUTELA DE VARIAÇÃO TEMPORAL: o corpus REAL é recente (majoritariamente 2025-2026), mas segurança da informação evolui rapidamente — não transformar uma recomendação ou tecnologia de época em regra eterna, especialmente em relação a senhas, MFA, algoritmos criptográficos e mecanismos de defesa. LIMITAÇÕES REGISTRADAS: (1) Q11 é AUTORAL com metadado não padronizado (banca="Papiro — estilo FGV", divergente do padrão majoritário "estilo Fundatec" do curso) — registrado como PROBLEMA_DE_QUALIDADE_METADADOS_Q11, sinalizado e NÃO corrigido nesta curadoria, independente da qualidade pedagógica da questão (seu campo `explicacao` já foi corrigido em operação de saneamento separada, commit cab1779); (2) Q15 também teve seu campo `explicacao` corrigido na mesma operação de saneamento (commit cab1779), sem qualquer outro metadado pendente.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
