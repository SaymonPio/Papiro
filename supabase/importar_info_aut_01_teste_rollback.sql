-- TESTE DE ROLLBACK REAL da importacao INFO-AUT-01.
-- OLD -> APPLY (mesma logica do apply real) -> TARGET (verifica) ->
-- REVERSAO REAL (mesma logica do reverter real) -> OLD (verifica) ->
-- rollback externo. Nada e alterado permanentemente.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _lote_questoes (
  ordem int primary key, codigo text, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;
insert into _lote_questoes (ordem, codigo, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 'info-aut-01-01', 38, 'facil', $FONTE0$PAPIRO — INFO-AUT-01 — 01 — HTTP x HTTPS$FONTE0$, $ENUN0$Em relação aos protocolos HTTP e HTTPS utilizados na Web, assinale a alternativa CORRETA.$ENUN0$),
(2, 'info-aut-01-02', 38, 'media', $FONTE1$PAPIRO — INFO-AUT-01 — 02 — TCP x UDP$FONTE1$, $ENUN1$Em relação aos protocolos de transporte TCP (Transmission Control Protocol) e UDP (User Datagram Protocol), assinale a alternativa CORRETA.$ENUN1$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
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

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;
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

-- ===================== FASE OLD =====================
do $$
declare
  v_uteis int; v_autoral int; v_dup int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_8', v_uteis=8, v_uteis::text);

  select count(distinct q.id) into v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true and coalesce(lower(q.banca),'') like '%papiro%';
  insert into _relatorio values ('OLD','autoral_0', v_autoral=0, v_autoral::text);

  select count(*) into v_dup from public.questoes q where q.ativa=true
    and q.enunciado in (select enunciado from _lote_questoes);
  insert into _relatorio values ('OLD','sem_duplicidade_previa', v_dup=0, v_dup::text);
end $$;

-- ===================== APPLY (mesma logica do apply real) =====================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_criadas int := 0;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria INFO-AUT-01 - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem), r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2 join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = 38
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_novo_id);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta from _lote_alternativas la where la.ordem = r.ordem;

    perform public.classificar_questao_unidade_admin(v_novo_id, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid);
    v_criadas := v_criadas + 1;
  end loop;
  insert into _relatorio values ('APPLY','questoes_criadas_2', v_criadas=2, v_criadas::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_uteis int; v_real int; v_autoral int; v_gabaritos text; v_vinc int; v_cq int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_10', v_uteis=10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','real_8', v_real=8, v_real::text);
  insert into _relatorio values ('TARGET','autoral_2', v_autoral=2, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m;
  insert into _relatorio values ('TARGET','gabaritos_DE', v_gabaritos='DE', v_gabaritos);

  select count(*) into v_vinc from _mapa_ids m where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f');
  insert into _relatorio values ('TARGET','vinculos_2de2', v_vinc=2, v_vinc::text);

  select count(*) into v_cq from _mapa_ids m where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET','curso_questoes_2de2', v_cq=2, v_cq::text);
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_ids bigint[];
  v_rows_qup int; v_rows_alt int; v_rows_cq int; v_rows_q int;
begin
  select array_agg(questao_id) into v_ids from _mapa_ids;

  delete from public.questao_unidades_pedagogicas where questao_id = any(v_ids);
  get diagnostics v_rows_qup = row_count;
  delete from public.curso_questoes where questao_id = any(v_ids);
  get diagnostics v_rows_cq = row_count;
  delete from public.alternativas where questao_id = any(v_ids);
  get diagnostics v_rows_alt = row_count;
  delete from public.questoes where id = any(v_ids);
  get diagnostics v_rows_q = row_count;

  insert into _relatorio values ('REVERSAO','questoes_removidas_2', v_rows_q=2, v_rows_q::text);
  insert into _relatorio values ('REVERSAO','alternativas_removidas_10', v_rows_alt=10, v_rows_alt::text);
  insert into _relatorio values ('REVERSAO','vinculos_removidos_2', v_rows_qup=2, v_rows_qup::text);
  insert into _relatorio values ('REVERSAO','curso_questoes_removidas_2', v_rows_cq=2, v_rows_cq::text);
end $$;

-- ===================== FASE OLD (novamente) =====================
do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_8', v_uteis=8, v_uteis::text);
end $$;

select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — INFO_AUT_01_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
