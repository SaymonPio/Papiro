-- IMPORTACAO INFO-AUT-01 — 2 questoes autorais para a unidade
-- "Internet: conceitos, arquitetura e protocolos" (curso_conteudo_id=38),
-- curso Brigada Militar RS. Fecha o deficit de pratica desta unidade
-- (8 -> 10 uteis).
--
-- Padrao identico ao usado nos lotes AUT anteriores do projeto: staging
-- de questoes/explicacoes/alternativas, insercao por INSERT direto em
-- questoes/alternativas (nunca em questao_unidades_pedagogicas), vinculo
-- exclusivamente via classificar_questao_unidade_admin (RPC ja corrigida
-- para sincronizar curso_questoes automaticamente).
--
-- NAO altera nenhuma das 8 questoes REAL existentes na unidade. NAO
-- altera unidades/conteudos/materias/aulas.
--
-- ROLLBACK-TESTADO em importar_info_aut_01_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_info_aut_01.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key,
  codigo text,
  curso_conteudo_id bigint,
  dificuldade text,
  fonte text,
  enunciado text
) on commit drop;

insert into _lote_questoes (ordem, codigo, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 'info-aut-01-01', 38, 'facil', $FONTE0$PAPIRO — INFO-AUT-01 — 01 — HTTP x HTTPS$FONTE0$, $ENUN0$Em relação aos protocolos HTTP e HTTPS utilizados na Web, assinale a alternativa CORRETA.$ENUN0$),
(2, 'info-aut-01-02', 38, 'media', $FONTE1$PAPIRO — INFO-AUT-01 — 02 — TCP x UDP$FONTE1$, $ENUN1$Em relação aos protocolos de transporte TCP (Transmission Control Protocol) e UDP (User Datagram Protocol), assinale a alternativa CORRETA.$ENUN1$);

create temporary table _lote_explicacoes (
  ordem int primary key,
  explicacao text
) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL0$GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O HTTPS corresponde ao protocolo HTTP combinado com o uso do TLS (Transport Layer Security), que provê confidencialidade e integridade aos dados trocados entre cliente e servidor. Nesse processo, o certificado digital do servidor é um dos elementos utilizados na autenticação da comunicação, contribuindo para que o cliente tenha mais confiança de que está se comunicando com o servidor pretendido.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A porta 80 é o padrão comumente utilizado pelo HTTP, mas não existe impedimento técnico para configurar um servidor web para atender requisições HTTP em outra porta; a associação a uma porta específica é uma convenção, não uma obrigatoriedade absoluta do protocolo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O uso de HTTPS garante a confidencialidade e a integridade do canal de comunicação, mas não garante que o conteúdo do site seja seguro, verídico ou livre de softwares maliciosos — um site malicioso pode perfeitamente possuir um certificado HTTPS válido.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O HTTPS protege o conteúdo transmitido entre cliente e servidor, mas não oculta, por si só, o endereço IP de destino acessado, que permanece observável na camada de rede durante o estabelecimento da conexão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
SSL (Secure Sockets Layer) foi o protocolo historicamente utilizado antes do TLS; suas versões são hoje consideradas obsoletas e foram sucedidas pelo TLS. Os dois nomes não correspondem, atualmente, à mesma tecnologia em uso equivalente.

BIZU DE PROVA:
HTTPS = HTTP + TLS. TLS protege o CANAL (confidencialidade e integridade dos dados em trânsito) — não o conteúdo em si, não a idoneidade do site, e não o IP de destino. Porta 80 (HTTP) e porta 443 (HTTPS) são convenções, não regras absolutas. SSL foi o predecessor do TLS; atualmente, o protocolo utilizado para essa proteção é o TLS.$EXPL0$),
(2, $EXPL1$GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O TCP realiza controle de fluxo e retransmissão de pacotes perdidos, mecanismos que contribuem para seu maior overhead em relação ao UDP. Por não implementar, por si só, esses mecanismos, o UDP é frequentemente empregado em aplicações sensíveis à latência, como voz e vídeo em tempo real, nos casos em que a aplicação tolera alguma perda de dados ou implementa seus próprios mecanismos de controle.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O TCP fornece mecanismos de entrega confiável, como confirmação de recebimento e retransmissão de pacotes perdidos, mas isso não equivale a uma garantia incondicional de entrega em toda e qualquer circunstância — falhas de rede podem impedir a comunicação independentemente do protocolo utilizado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O DNS pode utilizar tanto UDP quanto TCP, dependendo da situação, não sendo incompatível com o TCP.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Nem todas as versões do HTTP utilizam o TCP como protocolo de transporte subjacente — o HTTP/3, por exemplo, utiliza o protocolo QUIC sobre UDP.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O UDP é um protocolo não orientado à conexão: ao contrário do TCP, ele não estabelece previamente um canal de comunicação entre origem e destino antes do envio dos dados.

BIZU DE PROVA:
TCP: orientado à conexão, com controle de fluxo, ordenação e retransmissão — maior confiabilidade, maior overhead. UDP: não orientado à conexão, menor overhead, sem garantias próprias de entrega/ordem. Cuidado com absolutos: TCP fornece mecanismos de entrega confiável, DNS pode usar UDP ou TCP e nem todo HTTP usa TCP — HTTP/3 utiliza QUIC sobre UDP.$EXPL1$);

create temporary table _lote_alternativas (
  ordem int,
  letra_ordem int,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT0_0$O protocolo HTTP opera obrigatoriamente na porta 80, sendo tecnicamente impossível configurar um servidor web para atender requisições HTTP em outra porta.$ALT0_0$, false),
(1, 2, $ALT0_1$Por utilizar criptografia, um site acessado via HTTPS garante que seu conteúdo é seguro e livre de softwares maliciosos.$ALT0_1$, false),
(1, 3, $ALT0_2$Ao utilizar HTTPS, o endereço IP do servidor de destino acessado pelo usuário permanece oculto de qualquer observador na rede.$ALT0_2$, false),
(1, 4, $ALT0_3$O HTTPS corresponde ao protocolo HTTP associado ao uso do TLS (Transport Layer Security), que provê confidencialidade e integridade aos dados transmitidos entre cliente e servidor, sendo o certificado digital do servidor um elemento utilizado no processo de autenticação dessa comunicação.$ALT0_3$, true),
(1, 5, $ALT0_4$SSL (Secure Sockets Layer) e TLS (Transport Layer Security) são, atualmente, exatamente a mesma tecnologia em uso simultâneo e equivalente, sendo os nomes intercambiáveis nas versões utilizadas hoje em dia.$ALT0_4$, false),
(2, 1, $ALT1_0$O TCP é um protocolo orientado à conexão que garante, em toda e qualquer circunstância, a entrega dos dados ao destinatário.$ALT1_0$, false),
(2, 2, $ALT1_1$O protocolo DNS utiliza exclusivamente o UDP para todas as suas consultas, sendo tecnicamente incompatível com o uso do TCP.$ALT1_1$, false),
(2, 3, $ALT1_2$O protocolo HTTP, em todas as suas versões, utiliza obrigatoriamente o TCP como protocolo de transporte subjacente.$ALT1_2$, false),
(2, 4, $ALT1_3$O UDP é um protocolo orientado à conexão que, assim como o TCP, estabelece previamente um canal de comunicação entre origem e destino antes do envio de dados.$ALT1_3$, false),
(2, 5, $ALT1_4$O TCP realiza controle de fluxo e retransmissão de pacotes perdidos, características que contribuem para seu maior overhead em relação ao UDP; este último, por não implementar por si só tais mecanismos, é frequentemente empregado em aplicações sensíveis à latência, como voz e vídeo em tempo real, quando a aplicação tolera alguma perda de dados ou implementa seus próprios mecanismos de controle.$ALT1_4$, true);

-- ================= PRECONDICOES =================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int;
  v_autoral int;
  v_gap int;
  v_dup int;
begin
  select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
  into v_unidade_ok
  from public.unidades_pedagogicas up
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where up.id = 'd9153747-6150-4a1f-8bb8-f4ea433f672f';
  if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade/conteudo/materia nao estao ativos/relevantes conforme esperado'; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 8 then raise exception 'PRECOND: uteis atuais=% esperado 8', v_uteis; end if;

  select count(distinct q.id) into v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and coalesce(lower(q.banca),'') like '%papiro%';
  if v_autoral <> 0 then raise exception 'PRECOND: ja existem % questao(oes) AUTORAL nesta unidade — possivel reexecucao', v_autoral; end if;

  select count(*) into v_gap
  from (
    select distinct q.id from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join public.curso_materias cm on cm.id=cc.curso_materia_id and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao
    where q.ativa and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
  ) g;
  if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes=% esperado 0', v_gap; end if;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and (lower(q.enunciado) = lower('Em relação aos protocolos HTTP e HTTPS utilizados na Web, assinale a alternativa CORRETA.')
    or lower(q.enunciado) = lower('Em relação aos protocolos de transporte TCP (Transmission Control Protocol) e UDP (User Datagram Protocol), assinale a alternativa CORRETA.'));
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES OK: unidade/conteudo/materia corretos, 8 uteis, 0 autoral, gap curso_questoes=0, 0 duplicidade de enunciado';
end $$;

-- ================= INSERT das 2 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria INFO-AUT-01 - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = 38
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_novo_id);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;
  end loop;
end $$;

-- ================= VINCULO via RPC sancionada =================
do $$
declare
  r record;
begin
  for r in select questao_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid);
  end loop;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_snap record;
  v_uteis int; v_real int; v_autoral int;
  v_vinc_novos int; v_cq_novos int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes - v_snap.total_questoes <> 2 then raise exception 'POSCOND: questoes criadas=% esperado 2', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 10 then raise exception 'POSCOND: alternativas criadas=% esperado 10', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 2 then raise exception 'POSCOND: vinculos criados=% esperado 2', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 2 then raise exception 'POSCOND: curso_questoes criadas=% esperado 2', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis da unidade=% esperado 10', v_uteis; end if;

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_real <> 8 then raise exception 'POSCOND: REAL=% esperado 8', v_real; end if;
  if v_autoral <> 2 then raise exception 'POSCOND: AUTORAL=% esperado 2', v_autoral; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos
  from _mapa_ids m;
  if v_gabaritos <> 'DE' then raise exception 'POSCOND: gabaritos=% esperado DE', v_gabaritos; end if;

  select count(*) into v_vinc_novos from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f');
  if v_vinc_novos <> 2 then raise exception 'POSCOND: %/2 vinculos novos confirmados', v_vinc_novos; end if;

  select count(*) into v_cq_novos from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_novos <> 2 then raise exception 'POSCOND: %/2 curso_questoes novas confirmadas', v_cq_novos; end if;

  raise notice 'POSCONDICOES OK: +2 questoes, +10 alternativas, +2 vinculos, +2 curso_questoes; unidade agora com 10 uteis (8 REAL + 2 AUTORAL); gabaritos D,E confirmados';
end $$;

commit;
