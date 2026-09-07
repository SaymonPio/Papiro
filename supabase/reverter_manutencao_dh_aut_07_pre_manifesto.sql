-- Reversao segura, POS-APPLY, da manutencao tecnica pre-manifesto do
-- DH-AUT-07 (Q13 estrutura+explicacao; Q29/Q177/Q178/Q179/Q263/Q264
-- somente explicacao).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer a manutencao ja confirmada (commit) de
-- supabase/manutencao_dh_aut_07_pre_manifesto.sql.
--
-- Mecanismo de identificacao: cada operacao so afeta a linha se o
-- estado atual bater exatamente com o estado NOVO (pos-manutencao)
-- auditado — nunca por materia_id/assunto_id/unidade. Ordem:
--   1) confirmar que Q13 esta no estado TARGET (new hash + fingerprint
--      AFTER, que inclui a alternativa ordem 5);
--   2) DELETE da alternativa ordem 5 de Q13, guardado por
--      questao_id+ordem+correta+texto exatos, com verificacao de
--      exatamente 1 linha afetada;
--   3) confirmar que Q13 voltou a exatamente 4 alternativas e que o
--      fingerprint BEFORE (sem a alternativa 5) volta a bater;
--   4) restaurar as 7 explicacoes OLD (Q13 + as 6 demais), cada uma
--      guardada por new_md5 E fingerprint imutavel simultaneamente.
--
-- Textos antigos representados em base64 (decode + convert_from),
-- reproduzindo byte a byte — inclusive as quebras de linha CRLF
-- originais — o conteudo que estava em producao antes da manutencao.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de manutencao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_ok boolean;
begin
  select
    md5(coalesce(explicacao, '')) = 'a59aba16c3ace7f13e31886c33ea5152'
    and md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
          (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
             from public.alternativas a where a.questao_id = questoes.id))) = 'c2e2d1e86cd8db01b4307cf159e356d9'
  into v_ok
  from public.questoes where id = 13;

  if v_ok is not true then
    raise exception 'Abortado: Q13 nao esta no estado TARGET esperado (new hash + fingerprint AFTER) — nao reverter as cegas';
  end if;
end $$;

do $$
declare
  v_rows int;
begin
  delete from public.alternativas
  where questao_id = 13
    and ordem = 5
    and correta = false
    and texto = 'Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado';
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    raise exception 'Abortado: delete da alternativa ordem5 de Q13 afetou % linha(s), esperado exatamente 1', v_rows;
  end if;
end $$;

do $$
declare
  v_cnt int;
  v_fp text;
begin
  select count(*) into v_cnt from public.alternativas where questao_id = 13;
  if v_cnt <> 4 then
    raise exception 'Abortado: Q13 deveria ter exatamente 4 alternativas apos o delete, encontrado %', v_cnt;
  end if;
  select md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
        (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
           from public.alternativas a where a.questao_id = questoes.id)))
  into v_fp from public.questoes where id = 13;
  if v_fp <> 'd9d1e4a35df7c53c03b1def16f51cc66' then
    raise exception 'Abortado: fingerprint BEFORE de Q13 nao confere apos o delete (%)', v_fp;
  end if;
end $$;

create temporary table _lote_reversao (
  ordem int primary key,
  questao_id bigint,
  new_md5 text,
  old_md5 text,
  fingerprint text,
  texto_base64 text
) on commit drop;

insert into _lote_reversao (ordem, questao_id, new_md5, old_md5, fingerprint, texto_base64) values
(1, 13, 'a59aba16c3ace7f13e31886c33ea5152', 'ba357b5ddcab13cf94f22490c7e485b2', 'd9d1e4a35df7c53c03b1def16f51cc66',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgRGVjbGFyYcOnw6NvIFVuaXZlcnNhbCBkb3MgRGlyZWl0b3MgSHVtYW5vcyAoRFVESCksIGFkb3RhZGEgZW0gMTAgZGUgZGV6ZW1icm8gZGUgMTk0OCBwZWxhIEFzc2VtYmxlaWEgR2VyYWwgZGEgT05VIChSZXNvbHXDp8OjbyAyMTcgQSBJSUkpLCBlc3RhYmVsZWNlIGV4cHJlc3NhbWVudGUgZW0gc2V1IEFydGlnbyAxwrogcXVlICJ0b2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZW0gZGlyZWl0b3MuIERvdGFkb3MgZGUgcmF6w6NvIGUgZGUgY29uc2Npw6puY2lhLCBkZXZlbSBhZ2lyIHVucyBwYXJhIGNvbSBvcyBvdXRyb3MgZW0gZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZSIuIEEgZGlnbmlkYWRlIGRhIHBlc3NvYSBodW1hbmEgw6kgYSBtYXRyaXogYXhpb2zDs2dpY2EgZSBvIHBvc3R1bGFkbyBjZW50cmFsIGRlIHRvZG8gbyBzaXN0ZW1hIGludGVybmFjaW9uYWwgZGUgcHJvdGXDp8OjbyBkb3MgZGlyZWl0b3MgaHVtYW5vcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIMOpIHVtIGRvY3VtZW50byB1bml2ZXJzYWwgdm9sdGFkbyDDoCBwcm90ZcOnw6NvIGRlIHRvZG9zIG9zIHNlcmVzIGh1bWFub3MsIGUgbsOjbyByZXN0cml0byBhIGFnZW50ZXMgcMO6YmxpY29zIG91IHNlcnZpZG9yZXMgZG8gRXN0YWRvLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpPcyBkaXJlaXRvcyBodW1hbm9zIGNhcmFjdGVyaXphbS1zZSBwZWxhIGluYWxpZW5hYmlsaWRhZGUgZSBpcnJlbnVuY2lhYmlsaWRhZGUsIG7Do28gcG9kZW5kbyBzZXIgY29tZXJjaWFsaXphZG9zIG91IHRyYW5zZmVyaWRvcyBlbnRyZSBwYXJ0aWN1bGFyZXMuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBEIEVTVMOBIElOQ09SUkVUQToNCkEgRFVESCBwb3NzdWkgYXBsaWNhw6fDo28gcGVybWFuZW50ZSBlIHVuaXZlcnNhbCwgaW5jaWRpbmRvIHRhbnRvIGVtIHRlbXBvcyBkZSBwYXogcXVhbnRvIGVtIHF1YWlzcXVlciBjb250ZXh0b3MgZGUgY29udml2w6puY2lhIGNpdmlsaXphdMOzcmlhLg0KDQpCSVpVIERFIFBST1ZBOg0KRFVESCAoMTk0OCkgLSBBcnRpZ28gMcK6Og0KIlRvZG9zIG9zIHNlcmVzIGh1bWFub3MgbmFzY2VtIExJVlJFUyBlIElHVUFJUyBlbSBESUdOSURBREUgZSBESVJFSVRPUy4iDQpUcsOtYWRlIGlsdW1pbmlzdGE6IExpYmVyZGFkZSwgSWd1YWxkYWRlIGUgRnJhdGVybmlkYWRlIQ=='),
(2, 29, '5da6b6a430faab0aff4efe54f3ef6e30', '8849b9ec07a4e93ccb11d105ad24fd76', '1e1906c2da85377c3c8ffca4751b3453',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDHCuiBkYSBEVURILzE5NDggY29uc2FncmEgb3MgaWRlYWlzIGRlIGxpYmVyZGFkZSwgaWd1YWxkYWRlIGUgZnJhdGVybmlkYWRlIGFvIHByZXNjcmV2ZXI6ICJUb2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZW0gZGlyZWl0b3MuIERvdGFkb3MgZGUgcmF6w6NvIGUgZGUgY29uc2Npw6puY2lhLCBkZXZlbSBhZ2lyIHVucyBwYXJhIGNvbSBvcyBvdXRyb3MgZW0gZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZS4iDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToNCkEgRFVESCBuw6NvIHByZXbDqiBoaWVyYXJxdWlhIGRlIHN1cGVyaW9yaWRhZGUgZW50cmUgc2VyZXMgaHVtYW5vczsgY29uc2FncmEgYSBpZ3VhbGRhZGUgYWJzb2x1dGEgZW0gZGlnbmlkYWRlLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIHByb3Rlw6fDo28gYW9zIGRpcmVpdG9zIGh1bWFub3MgaW5kZXBlbmRlIGRlIG5hY2lvbmFsaWRhZGUsIGNsYXNzZSBzb2NpYWwsIGfDqm5lcm8gb3UgdsOtbmN1bG8gZnVuY2lvbmFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRCBFU1TDgSBJTkNPUlJFVEE6DQpPcyBkaXJlaXRvcyBodW1hbm9zIHPDo28gdW5pdmVyc2FpcyBlIGluYWxpZW7DoXZlaXMsIG7Do28gc2VuZG8gcGFzc8OtdmVpcyBkZSByZW7Dum5jaWEgdMOhY2l0YS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIG7Do28gY29uZGljaW9uYSBhIGRpZ25pZGFkZSBodW1hbmEgw6AgYXByb3Zhw6fDo28gZGUgbGVpcyBtdW5pY2lwYWlzLg0KDQpCSVpVIERFIFBST1ZBOg0KQXJ0aWdvIDHCuiBkYSBEVURIOg0KQ29uc2FncmEgZXhwcmVzc2FtZW50ZToNCjEuIExpYmVyZGFkZSAoIm5hc2NlbSBsaXZyZXMiKTsNCjIuIElndWFsZGFkZSAoImlndWFpcyBlbSBkaWduaWRhZGUgZSBkaXJlaXRvcyIpOw0KMy4gRnJhdGVybmlkYWRlICgiZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZSIpLg=='),
(3, 177, 'a7ffa30db36ca95478c1e429cc65eea0', 'cec5f485195cda3a3cb6e7f29c809a5b', '7164a1e32c019207b99c53e99929d078',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgQ29udmVuw6fDo28gZGUgQmVsw6ltIGRvIFBhcsOhICgxOTk0KSBjb25zYWdyYSBlbSBzZXUgQXJ0aWdvIDPCuiBxdWUgdG9kYSBtdWxoZXIgdGVtIG8gZGlyZWl0byBhIHVtYSB2aWRhIGxpdnJlIGRlIHZpb2zDqm5jaWEsIHRhbnRvIG5vIMOibWJpdG8gcMO6YmxpY28gcXVhbnRvIG5vIHByaXZhZG8sIGluY2x1aW5kbyBvIGRpcmVpdG8gZGUgc2VyIGxpdnJlIGRlIHF1YWxxdWVyIGZvcm1hIGRlIGRpc2NyaW1pbmHDp8OjbyBlIGRlIHNlciB2YWxvcml6YWRhIGUgZWR1Y2FkYSBsaXZyZSBkZSBwYWRyw7VlcyBlc3RlcmVvdGlwYWRvcyBkZSBjb21wb3J0YW1lbnRvLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIHByb3Rlw6fDo28gbsOjbyBzZSByZXN0cmluZ2Ugw6AgZXNmZXJhIHBhdHJpbW9uaWFsIG91IGVtcHJlc2FyaWFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIENvbnZlbsOnw6NvIHByb3RlZ2UgdG9kYXMgYXMgbXVsaGVyZXMsIGUgbsOjbyBhcGVuYXMgc2Vydmlkb3JhcyBlc3RhdGFpcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBub3JtYSB2ZWRhIGEgdmlvbMOqbmNpYSBlbSBxdWFscXVlciBlc3Bhw6dvLCBuw6NvIHNlIGxpbWl0YW5kbyBhbyBkb21pY8OtbGlvIGNvbmp1Z2FsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpBIENvbnZlbsOnw6NvIMOpIHBlcm1hbmVudGUgZSBuw6NvIGRlcGVuZGUgZGUgZGVjbGFyYcOnw6NvIGRlIGVzdGFkbyBkZSBlbWVyZ8OqbmNpYS4NCg0KQklaVSBERSBQUk9WQToNCkFydC4gM8K6IGRhIENvbnZlbsOnw6NvIGRlIEJlbMOpbSBkbyBQYXLDoToNCiJUb2RhIG11bGhlciB0ZW0gZGlyZWl0byBhIHVtYSB2aWRhIGxpdnJlIGRlIHZpb2zDqm5jaWEsIG5hIGVzZmVyYSBww7pibGljYSBlIG5hIGVzZmVyYSBwcml2YWRhLiI='),
(4, 178, '9843efe8206346c66f628cdaa36e383d', '2fe5237594436bfa86ee6b22819eae61', '4002e9836976d6ebc168396b2ad955dc',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk5vcyB0ZXJtb3MgZGEgQ29udmVuw6fDo28gZGUgQmVsw6ltIGRvIFBhcsOhIChBcnQuIDfCuiksIG9zIEVzdGFkb3MtcGFydGVzIGNvbXByb21ldGVtLXNlIGEgYWRvdGFyIHBvbMOtdGljYXMgb3JpZW50YWRhcyBhIHByZXZlbmlyLCBwdW5pciBlIGVycmFkaWNhciBhIHZpb2zDqm5jaWEgY29udHJhIGEgbXVsaGVyLCBpbmNsdWluZG8gYSBjcmlhw6fDo28gZGUgc2VydmnDp29zIGVzcGVjaWFsaXphZG9zIGRlIGF0ZW5kaW1lbnRvLCBjYXBhY2l0YcOnw6NvIGRlIGFnZW50ZXMgcMO6YmxpY29zIGUgbWVjYW5pc21vcyBqdWRpY2lhaXMgY8OpbGVyZXMgZSBlZmljYXplcyBkZSBwcm90ZcOnw6NvIMOgcyB2w610aW1hcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KQSBDb252ZW7Dp8OjbyByZWNoYcOnYSBleHByZXNzYW1lbnRlIGEgaW7DqXJjaWEsIGEgaW1wdW5pZGFkZSBlIGEgdG9sZXLDom5jaWEgZXN0YXRhbCDDoCB2aW9sw6puY2lhLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpOw6NvIHByZXbDqiBhbmlzdGlhIGEgYWdyZXNzb3JlcyBkZSBtdWxoZXJlcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBwcm90ZcOnw6NvIGFicmFuZ2UgdG9kYXMgYXMgbXVsaGVyZXMgc2VtIGRpc3RpbsOnw6NvIGRlIHJlbmRhIG91IG5hY2lvbmFsaWRhZGUuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToNCk8gdHJhdGFkbyBpbXDDtWUgZGV2ZXJlcyBkZSBhZ2lyIGNvbmNyZXRvcyBhbyBFc3RhZG8sIGUgbsOjbyBtZXJhIGZhY3VsZGFkZSBkaXNjcmljaW9uw6FyaWEuDQoNCkJJWlUgREUgUFJPVkE6DQpEZXZlcmVzIGRvIEVzdGFkbyBuYSBDb252ZW7Dp8OjbyBkZSBCZWzDqW0gZG8gUGFyw6E6DQpEZXZlciBkZSBhZ2lyIGNvbSBERVZJREEgRElMSUfDik5DSUEgcGFyYSBwcmV2ZW5pciwgaW52ZXN0aWdhciBlIHB1bmlyIGEgdmlvbMOqbmNpYSBjb250cmEgYSBtdWxoZXIu'),
(5, 179, '8da95e4315db7f0dca91d802c75495f6', '1636880b23fa9d185b2ca697439b301d', '7d28dfb34f497a41405ca7022cd2fa3d',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgQ29taXNzw6NvIEludGVyYW1lcmljYW5hIGRlIERpcmVpdG9zIEh1bWFub3MgKENJREgpIGF0dWEgY29tbyDDs3Jnw6NvIGNvbnN1bHRpdm8gZGEgT0VBIGUgcG9zc3VpIGEgYXRyaWJ1acOnw6NvIGZvcm1hbCBkZSByZWFsaXphciB2aXNpdGFzIGluIGxvY28gYW9zIHBhw61zZXMgbWVtYnJvcyBwYXJhIGV4YW1pbmFyIGEgc2l0dWHDp8OjbyBkb3MgZGlyZWl0b3MgaHVtYW5vcywgcHVibGljYXIgcmVsYXTDs3Jpb3MgdGVtw6F0aWNvcyBlIGRlIHBhw61zIGUgZW1pdGlyIHJlY29tZW5kYcOnw7VlcyBhb3MgZ292ZXJub3MgcGFyYSBvIGFwcmltb3JhbWVudG8gZGUgc3VhcyBwb2zDrXRpY2FzIHDDumJsaWNhcyBlIGluc3RpdHVpw6fDtWVzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIENJREggbsOjbyBjb21hbmRhIG9wZXJhw6fDtWVzIG1pbGl0YXJlcyBlc3RyYW5nZWlyYXMuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToNCk7Do28gZXhlcmNlIGZ1bsOnw7VlcyBkZSBhdWRpdG9yaWEgZmluYW5jZWlyYSBlbXByZXNhcmlhbC4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KTsOjbyBwb3NzdWkgY29tcGV0w6puY2lhIHBhcmEgbGVnaXNsYXIgb3UgYWx0ZXJhciBjb25zdGl0dWnDp8O1ZXMgbmFjaW9uYWlzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpOw6NvIGltcMO1ZSBwZW5hbGlkYWRlcyBhbGZhbmRlZ8OhcmlhcyBhb3MgRXN0YWRvcy4NCg0KQklaVSBERSBQUk9WQToNCkluc3RydW1lbnRvcyBkZSBBdHVhw6fDo28gZGEgQ0lESDoNCi0gVmlzaXRhcyBpbiBsb2NvIG5vcyBwYcOtc2VzOw0KLSBSZWxhdMOzcmlvcyBHZXJhaXMgZSBUZW3DoXRpY29zOw0KLSBSZWNvbWVuZGHDp8O1ZXMgZSBNZWRpZGFzIENhdXRlbGFyZXMu'),
(6, 263, '84b9678d3115633bd15c43c3f4bce4da', '51d3492db3804859e09dfb7dfa0692eb', '0ae45b1b7e588e36f1d7214f2e7facb0',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDI4IGRhIERVREggZXN0YWJlbGVjZTogIlRvZG8gc2VyIGh1bWFubyB0ZW0gZGlyZWl0byBhIHVtYSBvcmRlbSBzb2NpYWwgZSBpbnRlcm5hY2lvbmFsIG5hIHF1YWwgb3MgZGlyZWl0b3MgZSBsaWJlcmRhZGVzIGVzdGFiZWxlY2lkb3MgbmVzdGEgRGVjbGFyYcOnw6NvIHBvc3NhbSBzZXIgcGxlbmFtZW50ZSByZWFsaXphZG9zLiIgRXNzZSBhcnRpZ28gY29uc2FncmEgYSBkaW1lbnPDo28gZXN0cnV0dXJhbCBlIGNvc21vcG9saXRhIGRhIGdhcmFudGlhIGRvcyBkaXJlaXRvcyBodW1hbm9zIGVtIMOibWJpdG8gZ2xvYmFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIG9yZGVtIGludGVybmFjaW9uYWwgZGV2ZSBzZXIgb3JpZW50YWRhIMOgIGNvb3BlcmHDp8OjbywgcGF6IGUgZWZldGl2YcOnw6NvIGRlIGRpcmVpdG9zLCBlIG7Do28gYW8gZG9tw61uaW8gYmVsaWNpc3RhLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIHJlc3BvbnNhYmlsaWRhZGUgZGUgY29uc3RydWlyIHVtYSBvcmRlbSBqdXN0YSB2aW5jdWxhIHRvZG9zIG9zIEVzdGFkb3MgZSBpbnN0aXR1acOnw7VlcyBpbnRlcm5hY2lvbmFpcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIGV4aWdlIGNvbmRpw6fDtWVzIHNvY2lhaXMgcmVhaXMgcGFyYSBxdWUgYXMgbGliZXJkYWRlcyBuw6NvIHNlamFtIG1lcmFtZW50ZSBmb3JtYWlzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpBIHNvbGlkYXJpZWRhZGUgaW50ZXJuYWNpb25hbCDDqSBpbmRpc3BlbnPDoXZlbCBwYXJhIG8gY3VtcHJpbWVudG8gZG9zIGRpcmVpdG9zIGh1bWFub3MuDQoNCkJJWlUgREUgUFJPVkE6DQpBcnRpZ28gMjggZGEgRFVESDoNCkRpcmVpdG8gYSB1bWEgT1JERU0gU09DSUFMIEUgSU5URVJOQUNJT05BTCBqdXN0YSBxdWUgdmlhYmlsaXplIGEgcGxlbmEgZWZpY8OhY2lhIGRlIHRvZG9zIG9zIGRpcmVpdG9zIGh1bWFub3Mu'),
(7, 264, '075f145453b7e592023d8f0c5deae5d1', 'a86b15931d15029cbea03ecadd0e1810', '88c73e4da2398b5d5c401d8afd1ba396',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDI5IGRhIERVREggY29uc2FncmEgb3MgREVWRVJFUyBETyBJTkRJVsONRFVPIGUgb3MgbGltaXRlcyBsZWfDrXRpbW9zIGFvcyBkaXJlaXRvczogIjEuIFRvZG8gc2VyIGh1bWFubyB0ZW0gZGV2ZXJlcyBwYXJhIGNvbSBhIGNvbXVuaWRhZGUsIG5hIHF1YWwgbyBsaXZyZSBlIHBsZW5vIGRlc2Vudm9sdmltZW50byBkYSBzdWEgcGVyc29uYWxpZGFkZSDDqSBwb3Nzw612ZWwuIDIuIE5vIGV4ZXJjw61jaW8gZGUgc2V1cyBkaXJlaXRvcyBlIGxpYmVyZGFkZXMsIHRvZG8gc2VyIGh1bWFubyBlc3RhcsOhIHN1amVpdG8gYXBlbmFzIMOgcyBsaW1pdGHDp8O1ZXMgZGV0ZXJtaW5hZGFzIHBlbGEgbGVpLCBleGNsdXNpdmFtZW50ZSBjb20gbyBmaW0gZGUgYXNzZWd1cmFyIG8gZGV2aWRvIHJlY29uaGVjaW1lbnRvIGUgcmVzcGVpdG8gZG9zIGRpcmVpdG9zIGUgbGliZXJkYWRlcyBkZSBvdXRyZW0gZSBkZSBzYXRpc2ZhemVyIGFzIGp1c3RhcyBleGlnw6puY2lhcyBkYSBtb3JhbCwgZGEgb3JkZW0gcMO6YmxpY2EgZSBkbyBiZW0tZXN0YXIgZ2VyYWwgbnVtYSBzb2NpZWRhZGUgZGVtb2Nyw6F0aWNhLiINCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KT3MgZGlyZWl0b3MgaHVtYW5vcyBuw6NvIHPDo28gYWJzb2x1dG9zIGUgaWxpbWl0YWRvcyBwZXJhbnRlIG9zIGRpcmVpdG9zIGFsaGVpb3MgZSBhIG9yZGVtIGRlbW9jcsOhdGljYS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOg0KTyBpbmRpdsOtZHVvIHBvc3N1aSBkZXZlcmVzIGRlIHNvbGlkYXJpZWRhZGUgcGFyYSBjb20gYSBjb211bmlkYWRlIG9uZGUgdml2ZS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQXMgbGltaXRhw6fDtWVzIGRldmVtIHNlciBwcmV2aXN0YXMgZW0gbGVpIGVtIHByb2wgZG8gYmVtLWVzdGFyIGVtIHNvY2llZGFkZSBkZW1vY3LDoXRpY2EuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToNCk7Do28gc2UgYWRtaXRlIG8gYWJ1c28gZGUgZGlyZWl0byBwYXJhIGRlc3RydWlyIGxpYmVyZGFkZXMgZnVuZGFtZW50YWlzLg0KDQpCSVpVIERFIFBST1ZBOg0KQXJ0aWdvIDI5IGRhIERVREg6DQotIERldmVyZXMgZG8gaW5kaXbDrWR1byBwZXJhbnRlIGEgY29tdW5pZGFkZTsNCi0gTGltaXRlcyBsZWfDrXRpbW9zIGFvcyBkaXJlaXRvcyBodW1hbm9zOiBhcGVuYXMgcG9yIExFSSBwYXJhIGdhcmFudGlyIG9zIGRpcmVpdG9zIGRlIG91dHJlbSBlIGEgb3JkZW0gcMO6YmxpY2EgbnVtYSBTT0NJRURBREUgREVNT0NSw4FUSUNBLg==');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt
  from _lote_reversao lr
  join public.questoes q on q.id = lr.questao_id
  where md5(coalesce(q.explicacao, '')) = lr.new_md5
    and md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
          (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
             from public.alternativas a where a.questao_id = q.id))) = lr.fingerprint;
  if v_cnt <> 7 then
    raise exception 'Abortado: apenas % de 7 questao(oes) conferem simultaneamente new_md5 e fingerprint — nao reverter as cegas', v_cnt;
  end if;
end $$;

do $$
declare r record; v_rows int;
begin
  for r in select * from _lote_reversao order by ordem loop
    update public.questoes
    set explicacao = convert_from(decode(r.texto_base64, 'base64'), 'UTF8')
    where id = r.questao_id
      and md5(coalesce(explicacao, '')) = r.new_md5
      and md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
            (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
               from public.alternativas a where a.questao_id = questoes.id))) = r.fingerprint;
    get diagnostics v_rows = row_count;
    if v_rows <> 1 then
      raise exception 'Abortado: reversao de questao_id=% afetou % linha(s), esperado exatamente 1 — nao reverter as cegas', r.questao_id, v_rows;
    end if;
  end loop;
end $$;

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes
  where id in (13,29,177,178,179,263,264)
    and md5(coalesce(explicacao, '')) in (
      'ba357b5ddcab13cf94f22490c7e485b2','8849b9ec07a4e93ccb11d105ad24fd76','cec5f485195cda3a3cb6e7f29c809a5b',
      '2fe5237594436bfa86ee6b22819eae61','1636880b23fa9d185b2ca697439b301d','51d3492db3804859e09dfb7dfa0692eb',
      'a86b15931d15029cbea03ecadd0e1810'
    );
  if v_cnt <> 7 then
    raise exception 'Abortado: apos reversao, esperado exatamente 7 questoes com os hashes originais, encontrado %', v_cnt;
  end if;
end $$;

commit;
