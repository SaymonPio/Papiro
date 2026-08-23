-- Curadoria das unidades pedagogicas de Internet e navegadores
-- (curso_conteudos.id = 38), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/internet_e_navegadores.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 38, assunto "Internet e navegadores")
-- e 2 recorte(s) pedagogico(s):
--   Unidade 1: Navegadores e ferramentas web
--   Unidade 2: Internet: conceitos, arquitetura e protocolos
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_internet_e_navegadores*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 38;
  v_unidade_1_id constant uuid := 'b66e09ca-3dc1-4b63-879d-c81292b94550';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Internet e navegadores",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Internet e navegadores'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Internet e navegadores nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 38 nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_1_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_1_id;
  end if;

  -- Garante que nenhuma outra unidade ja ocupa ordem=2 para este
  -- conteudo (execucao repetida nao deveria criar duplicata silenciosa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem = 2 and id <> 'd9153747-6150-4a1f-8bb8-f4ea433f672f'
  ) then
    raise exception 'Ja existe uma unidade ordem=2 diferente da esperada para o conteudo 38';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Navegadores e ferramentas web',
    escopo = 'Reconhecimento de recursos, ícones, atalhos e funcionalidades específicas de navegadores (Google Chrome, Mozilla Firefox) e de ferramentas web colaborativas acessadas via navegador (Google Drive, Google Meet, Microsoft Teams), com base em questões reais da Fundatec (2022-2026). Cobre: navegação privada/anônima e o que é ou não salvo localmente; recurso de limpar dados de navegação; organização de abas (fixar aba, abas contêiner); painel lateral (lista de leitura, histórico, favoritos); sincronização entre dispositivos (Firefox Sync); ferramentas de captura de tela; extensões e complementos; barra de endereços inteligente; ícones de ação da barra de ferramentas (compartilhar, recarregar); operadores de busca no Google Drive; permissões de moderador em videochamadas (Google Meet); recursos de reunião (Microsoft Teams, incluindo início instantâneo e múltiplos dispositivos). MÉTODO: para questões de reconhecimento de ícone/função, associar a descrição funcional (o que o recurso faz) ao nome oficial do recurso no produto, sem depender de uma única versão de interface como verdade permanente. CAUTELA DE PRODUTOS E VERSÕES: Chrome, Firefox, Drive, Meet e Teams mudam com atualizações — cada questão desta unidade é evidência histórica do que foi cobrado na época/versão da prova (2022 a 2026), não necessariamente do comportamento atual do produto; ao ensinar, distinguir "fato historicamente cobrado nesta prova" de "comportamento atual", contextualizando quando a interface tiver mudado. LIMITAÇÃO REGISTRADA: três questões reais sobre reconhecimento de ícone (que pedem a função de um ícone descrito textualmente no próprio enunciado, sem imagem) foram excluídas desta prática por suspeita/confirmação de dependência de um recurso visual original (imagem/screenshot) que o Papiro não possui — não usar essas questões como referência de cobertura desta unidade; caso a fidelidade seja resolvida no futuro, poderão ser incorporadas separadamente.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

  insert into public.unidades_pedagogicas
    (id, curso_conteudo_id, titulo, ordem, escopo, artigos_esperados, ativa)
  values
    ('d9153747-6150-4a1f-8bb8-f4ea433f672f', v_conteudo_id, 'Internet: conceitos, arquitetura e protocolos', 2,
     'Conceitos técnicos de arquitetura e funcionamento da internet, com base em questões reais da Fundatec (2025-2026). Cobre: camadas da web (Surface Web, Deep Web, Dark Web) com precisão técnica — Surface Web é a camada aberta e indexada pelos buscadores; Deep Web é a camada não indexada, incluindo áreas legítimas autenticadas/privadas (sistemas bancários, e-mails, intranets), acessível por navegadores comuns mediante login; Dark Web é um subconjunto deliberadamente oculto dentro da Deep Web, que exige tecnologias/redes específicas (como o Tor) para acesso — NÃO equiparar Deep Web a conteúdo ilegal nem a Dark Web (simplificação incorreta); Tor é a tecnologia/rede associada ao acesso a serviços .onion, distinta de ferramentas de análise forense digital como o Autopsy (não é navegador nem meio de acesso à Dark Web). Fingerprinting (rastreamento por características técnicas do dispositivo, sem depender de cookies ou login) como técnica de identificação web, distinta de cookies, rastreamento por URL, ID de usuário e pixels de rastreamento — tratado aqui como mecanismo técnico de identificação/rastreamento no contexto da navegação, não como ameaça de segurança (associação com privacidade não equivale a habilidade nuclear de Segurança da informação, conteúdo à parte). Protocolos de rede: DNS (resolução de nomes de domínio em endereços IP, camada de aplicação do modelo TCP/IP, porta 53) distinto de DHCP (configuração dinâmica automática de parâmetros de rede como IP/máscara/gateway) — não confundir a função de resolução de nomes com a de configuração automática, nem a camada de aplicação com a camada de transporte. Endereçamento: IPv4 (32 bits, 4 octetos decimais de 0 a 255) e URL (localizador uniforme de recursos, com protocolo + domínio + caminho). Computação em nuvem: definição geral (acesso remoto sob demanda a um pool de recursos computacionais configuráveis) e modelos de serviço IaaS, PaaS e SaaS — apresentados em termos de CAMADA DE SERVIÇO e RESPONSABILIDADE gerenciada pelo provedor (quanto mais se caminha de IaaS para PaaS para SaaS, mais componentes da pilha tornam-se gerenciados pelo provedor), não como ranking absoluto de qualidade ou completude; para a definição formal, priorizar a caracterização do NIST quando pertinente, verificando a formulação antes de atribuí-la à fonte. FONTES TÉCNICAS: para protocolos/padrões, priorizar RFCs/IETF e documentação técnica oficial quando disponível; para cloud computing, NIST; para produtos, documentação oficial do fornecedor — não depender apenas da explicação armazenada de cada questão.',
     null,
     true)
  on conflict (curso_conteudo_id, ordem) do update set
    titulo = excluded.titulo,
    escopo = excluded.escopo,
    artigos_esperados = excluded.artigos_esperados,
    ativa = excluded.ativa;
end;
$$;

commit;
