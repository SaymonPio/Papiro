-- Curadoria das unidades pedagogicas de Windows
-- (curso_conteudos.id = 35), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/windows.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id 35, assunto "Windows")
-- e 1 recorte(s) pedagogico(s):
--   Unidade 1: Windows
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_windows*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := 35;
  v_unidade_1_id constant uuid := '936d2d9d-0f83-4a25-8066-9e035a12ca16';
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "Windows",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = 'Windows'
      and cm.materia_id = 9
      and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  ) then
    raise exception 'Conteudo canonico de Windows nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo 35 nao encontrada';
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
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo 35 — decisao aprovada foi manter unidade unica';
  end if;

  update public.unidades_pedagogicas set
    titulo = 'Windows',
    escopo = 'Uso do sistema operacional Microsoft Windows (predominantemente Windows 10, com questões de Windows 11), com base em questões reais da Fundatec (2022-2026) mais uma questão suplementar autoral. Organizado em três eixos internos, sem fragmentação em unidades separadas (o corpus forma um bloco coerente de "uso do sistema operacional", sem a mesma ruptura conceitual que justificou 2 unidades em Internet e navegadores): EIXO 1 — ARQUIVOS E PASTAS: Lixeira (mover para a Lixeira permite restaurar o item; não criptografa, não envia à nuvem, não oculta, não afeta backups externos — Shift+Delete exclui permanentemente sem passar pela Lixeira); caracteres proibidos em nomes de arquivo/pasta (\ / : * ? " < > |, com destaque para "?" e ":" efetivamente cobrados no corpus) — CAUTELA: ensinar apenas os 9 caracteres proibidos tradicionais como o que este banco comprova, sem afirmar que são as ÚNICAS restrições possíveis para qualquer nome no Windows (existem também nomes reservados e restrições contextuais não cobradas neste corpus, não ensinar como se essa lista fosse exaustiva); atalhos (.lnk) como arquivo de vínculo/ponteiro lógico para um programa/arquivo/pasta original, identificável pela seta no canto inferior esquerdo do ícone — o atalho não é cópia do original: se o destino for movido, apagado, renomeado de forma incompatível ou se tornar inacessível, o atalho pode deixar de funcionar corretamente (evitar a simplificação "atalho = arquivo original"; excluir o atalho não apaga o original, mas apagar/mover o original quebra o atalho); propriedades de arquivo (aba Geral: tipo, local, tamanho, tamanho em disco, datas de criado/modificado/acessado, atributos — não existe contador de "número de acessos" ao arquivo). EIXO 2 — EXPLORADOR DE ARQUIVOS: Barra de Ferramentas de Acesso Rápido (Nova Pasta, Desfazer, Refazer, Excluir, Propriedades) distinta dos botões de navegação da barra de endereços (Voltar, Avançar, Pasta Acima) — o fato testado é específico da versão/época da prova, não uma verdade atemporal sobre toda interface futura do Windows. EIXO 3 — INTERFACE E UTILITÁRIOS DO SISTEMA: Barra de Tarefas (permite fixar aplicativo e verificar a hora do sistema; não é o local padrão para esvaziar a Lixeira, que fica na Área de Trabalho); Painel de Controle clássico por categoria (categoria "Programas" contém desinstalar programa; distinto de Sistema e Segurança, Aparência e Personalização, Contas de Usuário, Rede e Internet) — CAUTELA DE VERSÃO: o Windows moderno também possui o aplicativo "Configurações", e uma questão histórica sobre o Painel de Controle continua válida como evidência da prova mesmo com mudanças de interface entre versões; modos de energia — SUSPENSÃO (baixo consumo, sessão mantida na memória para retomada rápida/quase instantânea) em contraste funcional com HIBERNAÇÃO (estado persistido para retomada posterior, com comportamento distinto da suspensão) — usar essa diferença como explicação pedagógica tradicional COM LIMITE, sem reduzir a aula a uma fórmula simplista do tipo "RAM vs disco" como se isso descrevesse de forma completa toda implementação interna de qualquer versão; Gerenciador de Tarefas com suas guias (Processos: consumo de CPU/memória/disco/rede/GPU por programa, NÃO é a guia destinada a listar usuários conectados — isso fica na guia Usuários; Desempenho: gráficos/métricas de hardware em tempo real; demais guias como Histórico de Aplicativos, Inicializar, Usuários, Detalhes e Serviços tratadas apenas como mapa conceitual quando pertinente, sem apagamento das distinções efetivamente cobradas); Histórico da Área de Transferência (Win+V, disponível para textos e imagens, distinto do simples Ctrl+C/Ctrl+V) — questão associada ao Windows 11/época da prova, com cautela de versão/configuração, sem garantir que todo comportamento atual de interface seja idêntico ao da prova histórica. RECORRÊNCIA NESTE CORPUS (fenômenos observados em 2 ou mais provas/cadernos independentes, não apenas questões): caracteres proibidos em nomes de arquivo/pasta, Gerenciador de Tarefas (Processos×Desempenho), atalhos do Windows, e Painel de Controle — registrados como RECORRENTES NESTE CORPUS, sem elevar essa constatação a "um dos temas mais cobrados pela Fundatec" sem uma análise comparativa global entre todos os conteúdos. INCIDÊNCIA PONTUAL (observada em apenas 1 prova independente cada, não chamar recorrente): Barra de Acesso Rápido do Explorador, demais funções da Barra de Tarefas, Suspensão/Hibernação, Área de Transferência e Propriedades de arquivo — registradas como OBSERVADAS NESTE CORPUS. CAUTELA DE PRODUTO/VERSÃO: o Windows é um produto evolutivo; o corpus contém majoritariamente questões de Windows 10, com duas questões específicas de Windows 11 (Q643, Q645) — sempre distinguir o FATO EFETIVAMENTE COBRADO NA ÉPOCA/VERSÃO DA PROVA do COMPORTAMENTO ATUAL DA VERSÃO MAIS RECENTE, sem alterar a leitura de uma questão histórica porque a interface moderna mudou. FONTES: para fatos atuais/futuros sobre o produto, priorizar a documentação oficial da Microsoft; para a incidência histórica em si, priorizar a prova/caderno/gabarito da banca, sem depender exclusivamente da explicação armazenada em cada questão. LIMITAÇÕES REGISTRADAS: (1) Q31 é AUTORAL_PAPIRO com metadados não padronizados (banca="Papiro - estilo Fundatec", ano=NULL) — registrada como PROBLEMA_DE_QUALIDADE_METADADOS_Q31, sinalizada mas não corrigida nesta curadoria; o conteúdo em si é tecnicamente correto e a questão permanece vinculada como cobertura suplementar de prática sobre a Lixeira, sem contar para incidência histórica, recorrência, frequência Fundatec ou recência; (2) Q836 é duplicata textual de Q101 (mesmo enunciado, mesmas 5 alternativas, mesmo gabarito B, mesmo bloco de Informática do concurso SUSEPE/Polícia Penal RS 01/2022, com glitch "arquivoinválido" sem espaço) — Q101 é a questão canônica vinculada; Q836 permanece ATIVA, INTACTA e SEM vínculo neste conteúdo, excluída como DUPLICATA_Q836, sem correção do glitch textual nesta operação e sem ser contabilizada como uma segunda incidência independente do fenômeno de caracteres proibidos.',
    artigos_esperados = null,
    ativa = true
  where id = v_unidade_1_id;

end;
$$;

commit;
