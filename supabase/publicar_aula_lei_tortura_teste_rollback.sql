-- Rollback-test da publicação da aula rascunho de Lei de Tortura via o
-- writer canônico public.publicar_aula_versao_admin.
-- aula_versao_id alvo: a3464ad9-ca13-4adf-a6f6-262ad1576f73
-- Ciclo: PRECHECK -> chamar o writer -> validar TARGET -> ROLLBACK.
-- Este arquivo NUNCA aplica de fato: termina em ROLLBACK.

begin;

do $PRECHECK$
declare
  v_status text;
  v_publicado_em timestamptz;
  v_hash text;
begin
  select status, publicado_em, md5(estrutura::text)
    into v_status, v_publicado_em, v_hash
    from aula_versoes where id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73';
  if v_status <> 'rascunho' then
    raise exception 'PRECHECK FALHOU: status atual e %, esperado rascunho', v_status;
  end if;
  if v_publicado_em is not null then
    raise exception 'PRECHECK FALHOU: publicado_em ja preenchido (%), esperado null', v_publicado_em;
  end if;
  if v_hash <> 'c0edac8a261955fa197461319f29e6c1' then
    raise exception 'PRECHECK FALHOU: hash da estrutura (%) nao corresponde ao esperado', v_hash;
  end if;
  raise notice 'PRECHECK OK: status=rascunho, publicado_em=null, hash=%', v_hash;
end;
$PRECHECK$;

-- Chamada real do writer canonico, dentro da transacao de teste.
select * from public.publicar_aula_versao_admin('a3464ad9-ca13-4adf-a6f6-262ad1576f73');

do $CHECK_TARGET$
declare
  v_status text;
  v_publicado_em timestamptz;
  v_qtd int;
  v_qtd_juris int;
  v_qtd_artigos int;
  v_hash text;
begin
  select status, publicado_em, jsonb_array_length(estrutura->'componentes'),
         jsonb_array_length(estrutura->'artigos_abordados'), md5(estrutura::text)
    into v_status, v_publicado_em, v_qtd, v_qtd_artigos, v_hash
    from aula_versoes where id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73';
  if v_status <> 'publicada' then
    raise exception 'TARGET FALHOU: status e %, esperado publicada', v_status;
  end if;
  if v_publicado_em is null then
    raise exception 'TARGET FALHOU: publicado_em nao foi preenchido';
  end if;
  if v_qtd <> 11 then
    raise exception 'TARGET FALHOU: esperado 11 componentes, obtido %', v_qtd;
  end if;
  if v_qtd_artigos <> 10 then
    raise exception 'TARGET FALHOU: esperado 10 artigos_abordados, obtido %', v_qtd_artigos;
  end if;
  if v_hash <> 'c0edac8a261955fa197461319f29e6c1' then
    raise exception 'TARGET FALHOU: conteudo/estrutura mudou (hash %) -- a publicacao NUNCA deve alterar conteudo', v_hash;
  end if;
  select count(*) into v_qtd_juris
    from aula_versoes, jsonb_array_elements(estrutura->'componentes') c
    where id = 'a3464ad9-ca13-4adf-a6f6-262ad1576f73' and c->>'tipo' = 'jurisprudencia_essencial';
  if v_qtd_juris <> 1 then
    raise exception 'TARGET FALHOU: esperado exatamente 1 jurisprudencia_essencial, obtido %', v_qtd_juris;
  end if;
  raise notice 'TARGET OK: status=publicada, publicado_em=%, 11 componentes, 10 artigos_abordados, 1 jurisprudencia_essencial, hash de conteudo inalterado', v_publicado_em;
end;
$CHECK_TARGET$;

do $CHECK_OUTRAS$
begin
  if not exists (select 1 from aula_versoes where id = '141b5e3f-0e34-4850-a3ff-b9145667f689' and md5(estrutura::text) = '544ce3e6f4166fca41350026814c7432' and status = 'publicada' and publicado_em = '2026-08-14 18:48:12.150383+00') then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '141b5e3f-0e34-4850-a3ff-b9145667f689';
  end if;
  if not exists (select 1 from aula_versoes where id = '49810ea3-20c3-4222-891c-20a3cab5aac8' and md5(estrutura::text) = '126fd2bbd1ec1b9010764dc12b0437b4' and status = 'publicada' and publicado_em = '2026-08-14 18:48:01.558057+00') then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '49810ea3-20c3-4222-891c-20a3cab5aac8';
  end if;
  if not exists (select 1 from aula_versoes where id = '4fd064f5-5e2a-4cde-902a-07f5e9e32db5' and md5(estrutura::text) = 'd2608aee7d2141e4158b262899937351' and status = 'rascunho' and publicado_em is null) then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '4fd064f5-5e2a-4cde-902a-07f5e9e32db5';
  end if;
  if not exists (select 1 from aula_versoes where id = '6e586ac8-0696-42ac-8f23-c11f63cd92d0' and md5(estrutura::text) = 'd4a24bed9a7ed49726b98c1cb9ce0eaa' and status = 'rascunho' and publicado_em is null) then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '6e586ac8-0696-42ac-8f23-c11f63cd92d0';
  end if;
  if not exists (select 1 from aula_versoes where id = '8cfde0f2-4257-48d2-bfe1-463fe3d28ddf' and md5(estrutura::text) = '2f526029d62cf33355918d5f60300ff9' and status = 'rascunho' and publicado_em is null) then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '8cfde0f2-4257-48d2-bfe1-463fe3d28ddf';
  end if;
  if not exists (select 1 from aula_versoes where id = '9b430867-7595-4600-a2a8-7a769661cb5e' and md5(estrutura::text) = 'aa7eff5425bf393766dcdb2ed9684f73' and status = 'publicada' and publicado_em = '2026-08-14 18:47:33.115898+00') then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '9b430867-7595-4600-a2a8-7a769661cb5e';
  end if;
  if not exists (select 1 from aula_versoes where id = '9c715cf6-5617-45a8-956a-a04e81653959' and md5(estrutura::text) = 'abda6342aa71850f1c52880d04904361' and status = 'rascunho' and publicado_em is null) then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', '9c715cf6-5617-45a8-956a-a04e81653959';
  end if;
  if not exists (select 1 from aula_versoes where id = 'cfd879d2-4bb0-41b3-9da1-32ae3533966a' and md5(estrutura::text) = 'ca1b8cd523829aa63309d476177510c9' and status = 'publicada' and publicado_em = '2026-08-14 18:47:47.796184+00') then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', 'cfd879d2-4bb0-41b3-9da1-32ae3533966a';
  end if;
  if not exists (select 1 from aula_versoes where id = 'd304383f-31f5-4259-8954-d5368e2be459' and md5(estrutura::text) = '53e05464d16160ad270a3267ee2c53ed' and status = 'rascunho' and publicado_em is null) then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', 'd304383f-31f5-4259-8954-d5368e2be459';
  end if;
  if not exists (select 1 from aula_versoes where id = 'dc5b3e4f-a7cc-4244-9bac-9389cb0057b8' and md5(estrutura::text) = 'bbe2f8b088f644f36f810070321982d8' and status = 'publicada' and publicado_em = '2026-08-14 18:48:25.98299+00') then
    raise exception 'REGRESSAO: aula_versao % foi alterada inesperadamente', 'dc5b3e4f-a7cc-4244-9bac-9389cb0057b8';
  end if;
  if (select count(*) from aula_versoes) <> 11 then
    raise exception 'REGRESSAO: total de aula_versoes mudou (esperado 11)';
  end if;
  raise notice 'OK: nenhuma outra aula_versao foi alterada, total continua 11';
end;
$CHECK_OUTRAS$;

rollback;
