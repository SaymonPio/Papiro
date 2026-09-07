-- Teste transacional completo da manutencao tecnica pre-manifesto do
-- DH-AUT-07: OLD -> APPLY -> verificar TARGET -> executar a logica REAL
-- de reversao (delete da alternativa E de Q13 + restauracao das 7
-- explicacoes antigas) -> verificar OLD restaurado -> ROLLBACK final.
--
-- Todos os passos (staging, precondicoes, writes, poscondicoes,
-- reversao, pos-reversao) sao registrados em _relatorio como
-- insert...select em vez de RAISE EXCEPTION, para que o teste inteiro
-- rode ate o fim e produza um relatorio completo mesmo se algo falhar.
-- Termina em ROLLBACK — nenhuma alteracao e persistida.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(distinct q.id) from public.questoes q
     join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     where q.materia_id = 11 and q.ativa = true and up.ativa = true) as dh_uteis;

create temporary table _nova_alternativa_q13 (questao_id bigint, ordem smallint, correta boolean, texto text) on commit drop;
insert into _nova_alternativa_q13 (questao_id, ordem, correta, texto) values
(13, 5, false, convert_from(decode('TGl2cmVzLCBtYXMgY29tIGRpZ25pZGFkZSBlIGRpcmVpdG9zIGNvbmRpY2lvbmFkb3MgYW8gcmVjb25oZWNpbWVudG8gZG8gRXN0YWRv', 'base64'), 'UTF8'));

create temporary table _novas_explicacoes (questao_id bigint, explicacao text) on commit drop;
insert into _novas_explicacoes (questao_id, explicacao) values
(13, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gYXJ0LiAxwrogZGEgRGVjbGFyYcOnw6NvIFVuaXZlcnNhbCBkb3MgRGlyZWl0b3MgSHVtYW5vcyBlc3RhYmVsZWNlIHF1ZSB0b2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZW0gZGlyZWl0b3MgZSwgZG90YWRvcyBkZSByYXrDo28gZSBjb25zY2nDqm5jaWEsIGRldmVtIGFnaXIgdW5zIHBhcmEgY29tIG9zIG91dHJvcyBlbSBlc3DDrXJpdG8gZGUgZnJhdGVybmlkYWRlLiBBIGFsdGVybmF0aXZhIEEgcmVwcm9kdXogbyBuw7pjbGVvIGRlc3NhIGRpc3Bvc2nDp8Ojby4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKQSBEVURIIG7Do28gY29uZGljaW9uYSBvcyBkaXJlaXRvcyBodW1hbm9zIMOgIHByb2Zpc3PDo28gZXhlcmNpZGEuIE8gYXJ0LiAxwrogYWZpcm1hIHF1ZSB0b2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZGlyZWl0b3MuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6CkEgRFVESCBuw6NvIGNvbmRpY2lvbmEgYSB0aXR1bGFyaWRhZGUgZG9zIGRpcmVpdG9zIGh1bWFub3Mgw6AgbmFjaW9uYWxpZGFkZS4gTyBhcnQuIDHCuiBhdHJpYnVpIGxpYmVyZGFkZSBlIGlndWFsZGFkZSBlbSBkaWduaWRhZGUgZSBkaXJlaXRvcyBhIHRvZG9zIG9zIHNlcmVzIGh1bWFub3MuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRCBFU1TDgSBJTkNPUlJFVEE6CkEgaWd1YWxkYWRlIHByZXZpc3RhIG5vIGFydC4gMcK6IG7Do28gc2UgbGltaXRhIMOgIHJlbGHDp8OjbyBjb20gYXV0b3JpZGFkZXMgYWRtaW5pc3RyYXRpdmFzLiBBIERlY2xhcmHDp8OjbyBhZmlybWEgdW1hIGlndWFsZGFkZSBpbmVyZW50ZSBhIHRvZG9zIG9zIHNlcmVzIGh1bWFub3MgZW0gZGlnbmlkYWRlIGUgZGlyZWl0b3MuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6CkEgZGlnbmlkYWRlIGUgb3MgZGlyZWl0b3MgbWVuY2lvbmFkb3Mgbm8gYXJ0LiAxwrogbsOjbyBkZXBlbmRlbSBkZSByZWNvbmhlY2ltZW50byBwcsOpdmlvIGRvIEVzdGFkby4gQSBkaXNwb3Npw6fDo28gb3MgYXRyaWJ1aSBhIHRvZG9zIG9zIHNlcmVzIGh1bWFub3MgZGVzZGUgbyBuYXNjaW1lbnRvLg==', 'base64'), 'UTF8')),
(29, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gYXJ0aWdvIDIsIGl0ZW0gMiwgZGEgQ29udmVuw6fDo28gZGEgT05VIGNvbnRyYSBhIFRvcnR1cmEgZSBPdXRyb3MgVHJhdGFtZW50b3Mgb3UgUGVuYXMgQ3J1w6lpcywgRGVzdW1hbm9zIG91IERlZ3JhZGFudGVzICgxOTg0KSBlc3RhYmVsZWNlIHF1ZSBuZW5odW1hIGNpcmN1bnN0w6JuY2lhIGV4Y2VwY2lvbmFsLCBzZWphIGVzdGFkbyBkZSBndWVycmEgb3UgYW1lYcOnYSBkZSBndWVycmEsIGluc3RhYmlsaWRhZGUgcG9sw610aWNhIGludGVybmEgb3UgcXVhbHF1ZXIgb3V0cmEgZW1lcmfDqm5jaWEgcMO6YmxpY2EsIHBvZGUgc2VyIGludm9jYWRhIGNvbW8ganVzdGlmaWNhw6fDo28gcGFyYSBhIHRvcnR1cmEuIEEgcHJvaWJpw6fDo28gw6ksIHBvcnRhbnRvLCBhYnNvbHV0YSBlIG7Do28gYWRtaXRlIGV4Y2XDp8O1ZXMuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6Ck8gYXJ0aWdvIDIsIGl0ZW0gMywgZGEgbWVzbWEgQ29udmVuw6fDo28gZGlzcMO1ZSBleHByZXNzYW1lbnRlIHF1ZSBhIG9yZGVtIGRlIHVtIGZ1bmNpb27DoXJpbyBzdXBlcmlvciBvdSBkZSB1bWEgYXV0b3JpZGFkZSBww7pibGljYSBuw6NvIHBvZGUgc2VyIGludm9jYWRhIGNvbW8ganVzdGlmaWNhw6fDo28gcGFyYSBhIHRvcnR1cmEuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6CkEgc2l0dWHDp8OjbyBkZSBlc3RhZG8gZGUgZGVmZXNhIG7Do28gY3JpYSBleGNlw6fDo28gw6AgcHJvaWJpw6fDo28gZGEgdG9ydHVyYS4gTyBhcnRpZ28gMiwgaXRlbSAyLCBkYSBDb252ZW7Dp8OjbyBhZmFzdGEgYSBwb3NzaWJpbGlkYWRlIGRlIGludm9jYXIgY2lyY3Vuc3TDom5jaWFzIGV4Y2VwY2lvbmFpcywgaW5jbHVpbmRvIGluc3RhYmlsaWRhZGUgcG9sw610aWNhIGludGVybmEgb3UgcXVhbHF1ZXIgb3V0cmEgZW1lcmfDqm5jaWEgcMO6YmxpY2EsIGNvbW8ganVzdGlmaWNhw6fDo28gcGFyYSBhIHByw6F0aWNhLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpBIHVyZ8OqbmNpYSBlbSBvYnRlciBpbmZvcm1hw6fDo28gbsOjbyBmaWd1cmEgZW50cmUgYXMgaGlww7N0ZXNlcyBhZG1pdGlkYXMgcGVsYSBDb252ZW7Dp8OjbzsgYW8gY29udHLDoXJpbywgbyB0ZXh0byBjb252ZW5jaW9uYWwgYWZhc3RhIHF1YWxxdWVyIGVtZXJnw6puY2lhIHDDumJsaWNhIGNvbW8ganVzdGlmaWNhdGl2YSBwYXJhIGEgdG9ydHVyYS4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToKQSBhbHRlcm5hdGl2YSBFIGVzdMOhIGluY29ycmV0YSBwb3JxdWUgYSBkZWZpbmnDp8OjbyBkZSB0b3J0dXJhIGRhIENvbnZlbsOnw6NvIG7Do28gZXhpZ2UgbGVzw6NvIHBlcm1hbmVudGUuIE8gYXJ0LiAxwrogY29uc2lkZXJhLCBlbnRyZSBvdXRyb3MgZWxlbWVudG9zLCBhIGltcG9zacOnw6NvIGludGVuY2lvbmFsIGRlIGRvcmVzIG91IHNvZnJpbWVudG9zIGFndWRvcywgZsOtc2ljb3Mgb3UgbWVudGFpczsgZSBvIGFydC4gMsK6IGltcGVkZSBxdWUgY2lyY3Vuc3TDom5jaWFzIGV4Y2VwY2lvbmFpcyBzZWphbSB1c2FkYXMgcGFyYSBqdXN0aWZpY2FyIGEgcHLDoXRpY2Eu', 'base64'), 'UTF8')),
(177, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gUHJvZ3JhbWEgTmFjaW9uYWwgZGUgRGlyZWl0b3MgSHVtYW5vcyAtIFBOREgtMywgYXByb3ZhZG8gcGVsbyBEZWNyZXRvIG7CuiA3LjAzNywgZGUgMjEgZGUgZGV6ZW1icm8gZGUgMjAwOSwgw6kgZGVkaWNhZG8gw6AgcHJvbW/Dp8OjbyBlIMOgIHByb3Rlw6fDo28gZG9zIGRpcmVpdG9zIGh1bWFub3Mgbm8gQnJhc2lsLCBvcmdhbml6YW5kbyBkaXJldHJpemVzLCBvYmpldGl2b3MgZXN0cmF0w6lnaWNvcyBlIGHDp8O1ZXMgcHJvZ3JhbcOhdGljYXMgZG8gRXN0YWRvIGJyYXNpbGVpcm8gbmVzc2EgbWF0w6lyaWEuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6ClBvbMOtdGljYSBtb25ldMOhcmlhIMOpIG1hdMOpcmlhIGFmZXRhIGFvIFNpc3RlbWEgRmluYW5jZWlybyBOYWNpb25hbCBlIGFvIEJhbmNvIENlbnRyYWwsIGVzdHJhbmhhIGFvIG9iamV0byBkbyBQTkRILTMuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6CkFkbWluaXN0cmHDp8OjbyB0cmlidXTDoXJpYSBuw6NvIGludGVncmEgbyBvYmpldG8gZG8gUE5ESC0zLCBxdWUgdHJhdGEgZGEgcHJvbW/Dp8OjbyBlIHByb3Rlw6fDo28gZG9zIGRpcmVpdG9zIGh1bWFub3MsIG7Do28gZGEgYXJyZWNhZGHDp8OjbyBvdSBmaXNjYWxpemHDp8OjbyBkZSB0cmlidXRvcy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBEIEVTVMOBIElOQ09SUkVUQToKRGVmZXNhIGNvbWVyY2lhbCDDqSB0ZW1hIGRlIHBvbMOtdGljYSBlY29uw7RtaWNhIGV4dGVybmEsIHNlbSByZWxhw6fDo28gY29tIG8gb2JqZXRvIGRvIFBOREgtMy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToKTyBQTkRILTMgbsOjbyBzZSBkZXN0aW5hIGEgcmVndWxhciBwYXJ0aWRvcyBwb2zDrXRpY29zOyB0cmF0YS1zZSBkZSBwcm9ncmFtYSB2b2x0YWRvIMOgIHByb21vw6fDo28gZSBwcm90ZcOnw6NvIGRvcyBkaXJlaXRvcyBodW1hbm9zIGVtIHNlbnRpZG8gYW1wbG8u', 'base64'), 'UTF8')),
(178, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gUHJvZ3JhbWEgTmFjaW9uYWwgZGUgRGlyZWl0b3MgSHVtYW5vcyAtIFBOREgtMyBmb2kgYXByb3ZhZG8gcGVsbyBEZWNyZXRvIG7CuiA3LjAzNywgZGUgMjEgZGUgZGV6ZW1icm8gZGUgMjAwOSwgYXRvIG5vcm1hdGl2byBmZWRlcmFsIGV4cGVkaWRvIHBlbG8gUHJlc2lkZW50ZSBkYSBSZXDDumJsaWNhLiBFbnRyZSBhcyBhbHRlcm5hdGl2YXMgYXByZXNlbnRhZGFzLCBwb3J0YW50bywgYSBjb3JyZXRhIMOpICJEZWNyZXRvIGZlZGVyYWwiLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOgpPIFBOREgtMyBuw6NvIGZvaSBhcHJvdmFkbyBwb3IgZW1lbmRhIGNvbnN0aXR1Y2lvbmFsOyBvIERlY3JldG8gbsK6IDcuMDM3LzIwMDkgbsOjbyBhbHRlcm91IG8gdGV4dG8gZGEgQ29uc3RpdHVpw6fDo28uCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6Ck8gUE5ESC0zIG7Do28gZGVjb3JyZSBkZSBsZWkgY29tcGxlbWVudGFyIGVzdGFkdWFsOyBzdWEgYXByb3Zhw6fDo28gb2NvcnJldSBwb3IgYXRvIG5vcm1hdGl2byBmZWRlcmFsLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpPIFBOREgtMyBuw6NvIGZvaSBhcHJvdmFkbyBwb3IgcmVzb2x1w6fDo28gbXVuaWNpcGFsOyBvIGF0byBjb3JyZXNwb25kZW50ZSDDqSBvIERlY3JldG8gZmVkZXJhbCBuwrogNy4wMzcvMjAwOS4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToKTyBQTkRILTMgbsOjbyBkZWNvcnJlIGRlIHNlbnRlbsOnYSBpbnRlcm5hY2lvbmFsOyBzdWEgYXByb3Zhw6fDo28gb2NvcnJldSBwb3IgYXRvIG5vcm1hdGl2byBpbnRlcm5vIGRvIFBvZGVyIEV4ZWN1dGl2byBmZWRlcmFsLg==', 'base64'), 'UTF8')),
(179, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gQW5leG8gZG8gRGVjcmV0byBuwrogNy4wMzcvMjAwOSBvcmdhbml6YSBvIFBOREgtMyBlbSBFaXhvcyBPcmllbnRhZG9yZXMsIGRvcyBxdWFpcyBkZWNvcnJlbSBEaXJldHJpemVzLCBxdWUgc2UgZGVzZG9icmFtIGVtIE9iamV0aXZvcyBFc3RyYXTDqWdpY29zIGUgZXN0ZXMgZW0gQcOnw7VlcyBQcm9ncmFtw6F0aWNhcywgZXN0cnV0dXJhIHF1ZSBvcmllbnRhIGEgYXR1YcOnw6NvIGRhIGFkbWluaXN0cmHDp8OjbyBww7pibGljYSBmZWRlcmFsIGVtIG1hdMOpcmlhIGRlIGRpcmVpdG9zIGh1bWFub3MuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6Ck8gUE5ESC0zIG7Do28gc2UgbGltaXRhIGEgZGVmaW5pciB0aXBvcyBwZW5haXM7IMOpIHVtIHByb2dyYW1hIGRlIHBvbMOtdGljYXMgcMO6YmxpY2FzIGVzdHJ1dHVyYWRvIGVtIGVpeG9zLCBkaXJldHJpemVzLCBvYmpldGl2b3MgZSBhw6fDtWVzLCBlIG7Do28gdW0gZGlwbG9tYSBkZSBuYXR1cmV6YSBwZW5hbC4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToKTyBQTkRILTMgbsOjbyBzZSByZXN1bWUgYSByZWdyYXMgdHJpYnV0w6FyaWFzOyBzdWEgZXN0cnV0dXJhIG9yZ2FuaXphIHBvbMOtdGljYXMgcMO6YmxpY2FzIGRlIGRpcmVpdG9zIGh1bWFub3MsIHNlbSB0cmF0YXIgZGUgdHJpYnV0YcOnw6NvLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpPIFBOREgtMyBuw6NvIHNlIG9yZ2FuaXphIGV4Y2x1c2l2YW1lbnRlIGVtIG5vcm1hcyBtaWxpdGFyZXM7IHNldSBlc2NvcG8gYWJyYW5nZSBkaXZlcnNhcyDDoXJlYXMgZGEgYXR1YcOnw6NvIGVzdGF0YWwgcmVsYWNpb25hZGFzIGFvcyBkaXJlaXRvcyBodW1hbm9zLCBwYXJhIGFsw6ltIGRhIGVzZmVyYSBtaWxpdGFyLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOgpPIFBOREgtMyBuw6NvIHNlIGxpbWl0YSBhIG1ldGFzIGZpc2NhaXM7IHN1YSBlc3RydXR1cmEgZGUgZWl4b3MsIGRpcmV0cml6ZXMsIG9iamV0aXZvcyBlc3RyYXTDqWdpY29zIGUgYcOnw7VlcyBwcm9ncmFtw6F0aWNhcyB0ZW0gbmF0dXJlemEgZGUgcG9sw610aWNhIHDDumJsaWNhIGRlIGRpcmVpdG9zIGh1bWFub3MsIG7Do28gZGUgcGxhbmVqYW1lbnRvIGZpc2NhbC4=', 'base64'), 'UTF8')),
(263, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6CkEgQ29udmVuw6fDo28gZGEgT05VIGNvbnRyYSBhIFRvcnR1cmEgZSBPdXRyb3MgVHJhdGFtZW50b3Mgb3UgUGVuYXMgQ3J1w6lpcywgRGVzdW1hbm9zIG91IERlZ3JhZGFudGVzICgxOTg0KSwgZW0gc2V1IGFydGlnbyAyLCB2ZWRhIGEgdG9ydHVyYSBlbSBxdWFscXVlciBjaXJjdW5zdMOibmNpYSwgbyBxdWUgcmVmbGV0ZSBvIGVudGVuZGltZW50byBkZSBxdWUgZXNzYSBwcsOhdGljYSDDqSBhYnNvbHV0YW1lbnRlIGluY29tcGF0w612ZWwgY29tIGEgZGlnbmlkYWRlIGh1bWFuYSBlIG7Do28gY29tcG9ydGEgZXhjZcOnw7Vlcy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKTyBhcnRpZ28gMiwgaXRlbSAzLCBkYSBDb252ZW7Dp8OjbyBhZmFzdGEgZXhwcmVzc2FtZW50ZSBhIG9yZGVtIGRlIHN1cGVyaW9yIGhpZXLDoXJxdWljbyBvdSBkZSBhdXRvcmlkYWRlIHDDumJsaWNhIGNvbW8ganVzdGlmaWNhdGl2YSBwYXJhIGEgdG9ydHVyYS4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToKQSBhbHRlcm5hdGl2YSBDIGVzdMOhIGluY29ycmV0YSBwb3JxdWUgYSBDb252ZW7Dp8OjbyBkZXRlcm1pbmEgcXVlIG9zIEVzdGFkb3MgYXNzZWd1cmVtIHF1ZSBvcyBhdG9zIGRlIHRvcnR1cmEgc2VqYW0gY29uc2lkZXJhZG9zIGNyaW1lcyBzZWd1bmRvIHN1YSBsZWdpc2xhw6fDo28gcGVuYWwgZSBzZWphbSBwdW5pZG9zIGNvbSBwZW5hcyBhZGVxdWFkYXMgcXVlIGxldmVtIGVtIGNvbnRhIHN1YSBncmF2aWRhZGU7IHBvcnRhbnRvLCBuw6NvIHNlIHRyYXRhIGRlIG1lcmEgaW5mcmHDp8OjbyBkaXNjaXBsaW5hci4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBEIEVTVMOBIElOQ09SUkVUQToKQSBvYnRlbsOnw6NvIGRlIGNvbmZpc3PDo28gbsOjbyBsZWdpdGltYSBhIHRvcnR1cmE7IGEgQ29udmVuw6fDo28gcHJvw61iZSBhIHByw6F0aWNhIGluZGVwZW5kZW50ZW1lbnRlIGRhIGZpbmFsaWRhZGUgcHJvYmF0w7NyaWEgcGVyc2VndWlkYS4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToKQSBwcm9pYmnDp8OjbyBkYSB0b3J0dXJhIG7Do28gc2UgY29uZGljaW9uYSDDoCBleGlzdMOqbmNpYSBvdSBhdXPDqm5jaWEgZGUgYXV0b3JpemHDp8OjbyBqdWRpY2lhbDsgYSB2ZWRhw6fDo28gw6kgYWJzb2x1dGEgZSBuZW5odW1hIGF1dG9yaWRhZGUsIGp1ZGljaWFsIG91IGFkbWluaXN0cmF0aXZhLCBwb2RlIGxlZ2l0aW1hciBhIHByw6F0aWNhLg==', 'base64'), 'UTF8')),
(264, convert_from(decode('R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gYXJ0aWdvIDHCuiBkbyBQcm90b2NvbG8gRmFjdWx0YXRpdm8gw6AgQ29udmVuw6fDo28gZGEgT05VIGNvbnRyYSBhIFRvcnR1cmEgKE9QQ0FUKSBlc3RhYmVsZWNlIHVtIHNpc3RlbWEgZGUgdmlzaXRhcyByZWd1bGFyZXMsIHJlYWxpemFkYXMgcG9yIMOzcmfDo29zIGludGVybmFjaW9uYWlzIGUgbmFjaW9uYWlzIGluZGVwZW5kZW50ZXMsIGEgbG9jYWlzIG9uZGUgc2UgZW5jb250cmVtIHBlc3NvYXMgcHJpdmFkYXMgZGUgbGliZXJkYWRlLCBjb20gbyBvYmpldGl2byBkZSBwcmV2ZW5pciBhIHRvcnR1cmEgZSBvdXRyb3MgdHJhdGFtZW50b3Mgb3UgcGVuYXMgY3J1w6lpcywgZGVzdW1hbm9zIG91IGRlZ3JhZGFudGVzLCByZWR1emluZG8gcmlzY29zIGRlIG1hdXMtdHJhdG9zIGUgZm9ydGFsZWNlbmRvIGFzIGdhcmFudGlhcyBkYXMgcGVzc29hcyBjdXN0b2RpYWRhcy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKT3MgbWVjYW5pc21vcyBkZSBpbnNwZcOnw6NvIGUgbW9uaXRvcmFtZW50byBwcmV2aXN0b3Mgbm8gT1BDQVQgbsOjbyBzdWJzdGl0dWVtIG8gUG9kZXIgSnVkaWNpw6FyaW87IGF0dWFtIGRlIGZvcm1hIHByZXZlbnRpdmEgZSBjb21wbGVtZW50YXIsIHNlbSBleGVyY2VyIGZ1bsOnw6NvIGp1cmlzZGljaW9uYWwuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6CkVzc2VzIG1lY2FuaXNtb3MgbsOjbyB0w6ptIHBvciBmaW5hbGlkYWRlIGF1dG9yaXphciBwZW5hcyBpbmZvcm1haXM7IHN1YSBmdW7Dp8OjbyDDqSBmaXNjYWxpemFyIGxvY2FpcyBkZSBwcml2YcOnw6NvIGRlIGxpYmVyZGFkZSBwYXJhIHByZXZlbmlyIG1hdXMtdHJhdG9zLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpBIGFsdGVybmF0aXZhIEQgZXN0w6EgaW5jb3JyZXRhIHBvcnF1ZSBvcyBtZWNhbmlzbW9zIHByZXZpc3RvcyBubyBPUENBVCBhbXBsaWFtIG8gbW9uaXRvcmFtZW50byBwcmV2ZW50aXZvIGRvcyBsb2NhaXMgZGUgcHJpdmHDp8OjbyBkZSBsaWJlcmRhZGUgcG9yIMOzcmfDo29zIG5hY2lvbmFpcyBlIGludGVybmFjaW9uYWlzIGluZGVwZW5kZW50ZXM7IG7Do28gdMOqbSBwb3IgZmluYWxpZGFkZSBhZmFzdGFyIGEgZmlzY2FsaXphw6fDo28gZXhpc3RlbnRlLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOgpBIGFsdGVybmF0aXZhIEUgZXN0w6EgaW5jb3JyZXRhIHBvcnF1ZSBpbXBlZGlyIHJlZ2lzdHJvcyBkZSBjdXN0w7NkaWEgbsOjbyBjb25zdGl0dWkgZmluYWxpZGFkZSBkb3MgbWVjYW5pc21vcyBwcmV2ZW50aXZvcy4gTyBvYmpldGl2byBwcmV2aXN0byBubyBPUENBVCDDqSByZWFsaXphciB2aXNpdGFzIHJlZ3VsYXJlcyBhIGxvY2FpcyBkZSBwcml2YcOnw6NvIGRlIGxpYmVyZGFkZSBwYXJhIHByZXZlbmlyIGEgdG9ydHVyYSBlIG91dHJvcyB0cmF0YW1lbnRvcyBvdSBwZW5hcyBjcnXDqWlzLCBkZXN1bWFub3Mgb3UgZGVncmFkYW50ZXMu', 'base64'), 'UTF8'));

-- FASE PRECONDICAO
insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging counts',
  (select count(*) from _nova_alternativa_q13) = 1 and (select count(*) from _novas_explicacoes) = 7,
  'alt_q13=' || (select count(*) from _nova_alternativa_q13) || ' explicacoes=' || (select count(*) from _novas_explicacoes);

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging alt E texto',
  (select md5(texto) from _nova_alternativa_q13) = md5('Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado'),
  'md5 staged=' || (select md5(texto) from _nova_alternativa_q13);

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'staging new_md5 Q' || questao_id,
  case questao_id
    when 13 then md5(explicacao) = 'a59aba16c3ace7f13e31886c33ea5152'
    when 29 then md5(explicacao) = '5da6b6a430faab0aff4efe54f3ef6e30'
    when 177 then md5(explicacao) = 'a7ffa30db36ca95478c1e429cc65eea0'
    when 178 then md5(explicacao) = '9843efe8206346c66f628cdaa36e383d'
    when 179 then md5(explicacao) = '8da95e4315db7f0dca91d802c75495f6'
    when 263 then md5(explicacao) = '84b9678d3115633bd15c43c3f4bce4da'
    when 264 then md5(explicacao) = '075f145453b7e592023d8f0c5deae5d1'
  end,
  'md5=' || md5(explicacao)
from _novas_explicacoes;

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'Q13 old state',
  exists (select 1 from public.questoes where id = 13 and ativa = true and dificuldade = 'media')
  and md5(coalesce((select explicacao from public.questoes where id = 13), '')) = 'ba357b5ddcab13cf94f22490c7e485b2'
  and (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 13) = 'd9d1e4a35df7c53c03b1def16f51cc66'
  and (select count(*) from public.alternativas where questao_id = 13) = 4
  and not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 5)
  and (select count(*) from public.alternativas where questao_id = 13 and correta = true) = 1
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and correta = true and texto = 'Livres e iguais em dignidade e direitos')
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 2 and correta = false and texto = 'Submetidos aos direitos definidos por sua profissão')
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 3 and correta = false and texto = 'Com direitos condicionados à nacionalidade')
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 4 and correta = false and texto = 'Iguais apenas perante autoridades administrativas')
  and exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 13 and unidade_pedagogica_id = '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid),
  'old_md5/fingerprint/4alt/vinculo';

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'Q' || t.id || ' old state',
  md5(coalesce((select explicacao from public.questoes where id = t.id), '')) = t.old_md5
  and (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = t.id) = t.fingerprint
  and exists (select 1 from public.questoes where id = t.id and ativa = true and dificuldade = 'media')
  and (select count(*) from public.alternativas where questao_id = t.id) = 5
  and (select count(*) from public.alternativas where questao_id = t.id and correta = true) = 1
  and exists (select 1 from public.alternativas where questao_id = t.id and ordem = 1 and correta = true)
  and exists (select 1 from public.questao_unidades_pedagogicas where questao_id = t.id and unidade_pedagogica_id = t.unidade::uuid),
  'old_md5/fingerprint/5alt/vinculo'
from (values
  (29, '8849b9ec07a4e93ccb11d105ad24fd76', '1e1906c2da85377c3c8ffca4751b3453', '1c05566b-5c71-4baa-b965-3577b8ffdc17'),
  (177, 'cec5f485195cda3a3cb6e7f29c809a5b', '7164a1e32c019207b99c53e99929d078', '384edb2e-1b4a-4028-99f3-c6e54b154826'),
  (178, '2fe5237594436bfa86ee6b22819eae61', '4002e9836976d6ebc168396b2ad955dc', '384edb2e-1b4a-4028-99f3-c6e54b154826'),
  (179, '1636880b23fa9d185b2ca697439b301d', '7d28dfb34f497a41405ca7022cd2fa3d', '384edb2e-1b4a-4028-99f3-c6e54b154826'),
  (263, '51d3492db3804859e09dfb7dfa0692eb', '0ae45b1b7e588e36f1d7214f2e7facb0', '1c05566b-5c71-4baa-b965-3577b8ffdc17'),
  (264, 'a86b15931d15029cbea03ecadd0e1810', '88c73e4da2398b5d5c401d8afd1ba396', '1c05566b-5c71-4baa-b965-3577b8ffdc17')
) as t(id, old_md5, fingerprint, unidade);

insert into _relatorio (fase, item, ok, detalhe)
select 'PRECONDICAO', 'baseline globais',
  (select total_questoes from _snapshot_antes) = 1138
  and (select total_alternativas from _snapshot_antes) = 5443
  and (select total_vinculos from _snapshot_antes) = 915
  and (select dh_uteis from _snapshot_antes) = 281,
  'questoes=' || (select total_questoes from _snapshot_antes) || ' alternativas=' || (select total_alternativas from _snapshot_antes)
  || ' vinculos=' || (select total_vinculos from _snapshot_antes) || ' dh_uteis=' || (select dh_uteis from _snapshot_antes);

-- WRITE 1 e WRITE 2 (identicos ao apply real)
insert into public.alternativas (questao_id, ordem, correta, texto)
select questao_id, ordem, correta, texto from _nova_alternativa_q13;

update public.questoes q
set explicacao = ne.explicacao
from _novas_explicacoes ne
where q.id = ne.questao_id;

-- FASE POSCONDICAO (estado TARGET, dentro da transacao de teste)
insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'Q13 target state',
  (select count(*) from public.alternativas where questao_id = 13) = 5
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 5 and correta = false and texto = 'Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado')
  and (select count(*) from public.alternativas where questao_id = 13 and correta = true) = 1
  and exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and correta = true and texto = 'Livres e iguais em dignidade e direitos')
  and md5(coalesce((select explicacao from public.questoes where id = 13), '')) = 'a59aba16c3ace7f13e31886c33ea5152'
  and (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 13) = 'c2e2d1e86cd8db01b4307cf159e356d9'
  and exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 13 and unidade_pedagogica_id = '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid),
  '5alt/new_md5/fingerprint_after';

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'Q' || t.id || ' new state',
  md5(coalesce((select explicacao from public.questoes where id = t.id), '')) = t.new_md5
  and (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = t.id) = t.fingerprint,
  'new_md5/fingerprint preservado'
from (values
  (29, '5da6b6a430faab0aff4efe54f3ef6e30', '1e1906c2da85377c3c8ffca4751b3453'),
  (177, 'a7ffa30db36ca95478c1e429cc65eea0', '7164a1e32c019207b99c53e99929d078'),
  (178, '9843efe8206346c66f628cdaa36e383d', '4002e9836976d6ebc168396b2ad955dc'),
  (179, '8da95e4315db7f0dca91d802c75495f6', '7d28dfb34f497a41405ca7022cd2fa3d'),
  (263, '84b9678d3115633bd15c43c3f4bce4da', '0ae45b1b7e588e36f1d7214f2e7facb0'),
  (264, '075f145453b7e592023d8f0c5deae5d1', '88c73e4da2398b5d5c401d8afd1ba396')
) as t(id, new_md5, fingerprint);

insert into _relatorio (fase, item, ok, detalhe)
select 'POSCONDICAO', 'globais pos-apply',
  (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes)
  and (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 1
  and (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes)
  and (select count(distinct q.id) from public.questoes q
        join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
        join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
        where q.materia_id = 11 and q.ativa = true and up.ativa = true) = (select dh_uteis from _snapshot_antes),
  'questoes 0 delta / alternativas +1 / vinculos 0 delta / DH uteis inalterado';

-- FASE REVERT: exercer a logica REAL de reversao dentro do mesmo teste
insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_GUARD', 'Q13 no estado TARGET antes do delete',
  exists (
    select 1 from public.questoes
    where id = 13
      and md5(coalesce(explicacao, '')) = 'a59aba16c3ace7f13e31886c33ea5152'
      and md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
            (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
               from public.alternativas a where a.questao_id = questoes.id))) = 'c2e2d1e86cd8db01b4307cf159e356d9'
  ),
  'guard pre-delete';

do $$
declare v_rows int;
begin
  delete from public.alternativas
  where questao_id = 13
    and ordem = 5
    and correta = false
    and texto = 'Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado';
  get diagnostics v_rows = row_count;
  insert into _relatorio (fase, item, ok, detalhe)
  values ('REVERT_APPLY', 'delete alternativa ordem5 Q13', v_rows = 1, 'rows_affected=' || v_rows);
end $$;

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', 'Q13 de volta a BEFORE',
  (select count(*) from public.alternativas where questao_id = 13) = 4
  and (select md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
        (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
           from public.alternativas a where a.questao_id = questoes.id)))
      from public.questoes where id = 13) = 'd9d1e4a35df7c53c03b1def16f51cc66',
  '4 alternativas / fingerprint BEFORE restaurado';

create temporary table _lote_reversao_teste (
  ordem int primary key,
  questao_id bigint,
  new_md5 text,
  old_md5 text,
  fingerprint text,
  texto_base64 text
) on commit drop;

insert into _lote_reversao_teste (ordem, questao_id, new_md5, old_md5, fingerprint, texto_base64)
select r.ordem, r.questao_id, r.new_md5, r.old_md5, r.fingerprint, b.old_b64
from (values
  (1, 13, 'a59aba16c3ace7f13e31886c33ea5152', 'ba357b5ddcab13cf94f22490c7e485b2', 'd9d1e4a35df7c53c03b1def16f51cc66'),
  (2, 29, '5da6b6a430faab0aff4efe54f3ef6e30', '8849b9ec07a4e93ccb11d105ad24fd76', '1e1906c2da85377c3c8ffca4751b3453'),
  (3, 177, 'a7ffa30db36ca95478c1e429cc65eea0', 'cec5f485195cda3a3cb6e7f29c809a5b', '7164a1e32c019207b99c53e99929d078'),
  (4, 178, '9843efe8206346c66f628cdaa36e383d', '2fe5237594436bfa86ee6b22819eae61', '4002e9836976d6ebc168396b2ad955dc'),
  (5, 179, '8da95e4315db7f0dca91d802c75495f6', '1636880b23fa9d185b2ca697439b301d', '7d28dfb34f497a41405ca7022cd2fa3d'),
  (6, 263, '84b9678d3115633bd15c43c3f4bce4da', '51d3492db3804859e09dfb7dfa0692eb', '0ae45b1b7e588e36f1d7214f2e7facb0'),
  (7, 264, '075f145453b7e592023d8f0c5deae5d1', 'a86b15931d15029cbea03ecadd0e1810', '88c73e4da2398b5d5c401d8afd1ba396')
) as r(ordem, questao_id, new_md5, old_md5, fingerprint)
join (values
  (13, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgRGVjbGFyYcOnw6NvIFVuaXZlcnNhbCBkb3MgRGlyZWl0b3MgSHVtYW5vcyAoRFVESCksIGFkb3RhZGEgZW0gMTAgZGUgZGV6ZW1icm8gZGUgMTk0OCBwZWxhIEFzc2VtYmxlaWEgR2VyYWwgZGEgT05VIChSZXNvbHXDp8OjbyAyMTcgQSBJSUkpLCBlc3RhYmVsZWNlIGV4cHJlc3NhbWVudGUgZW0gc2V1IEFydGlnbyAxwrogcXVlICJ0b2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZW0gZGlyZWl0b3MuIERvdGFkb3MgZGUgcmF6w6NvIGUgZGUgY29uc2Npw6puY2lhLCBkZXZlbSBhZ2lyIHVucyBwYXJhIGNvbSBvcyBvdXRyb3MgZW0gZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZSIuIEEgZGlnbmlkYWRlIGRhIHBlc3NvYSBodW1hbmEgw6kgYSBtYXRyaXogYXhpb2zDs2dpY2EgZSBvIHBvc3R1bGFkbyBjZW50cmFsIGRlIHRvZG8gbyBzaXN0ZW1hIGludGVybmFjaW9uYWwgZGUgcHJvdGXDp8OjbyBkb3MgZGlyZWl0b3MgaHVtYW5vcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIMOpIHVtIGRvY3VtZW50byB1bml2ZXJzYWwgdm9sdGFkbyDDoCBwcm90ZcOnw6NvIGRlIHRvZG9zIG9zIHNlcmVzIGh1bWFub3MsIGUgbsOjbyByZXN0cml0byBhIGFnZW50ZXMgcMO6YmxpY29zIG91IHNlcnZpZG9yZXMgZG8gRXN0YWRvLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpPcyBkaXJlaXRvcyBodW1hbm9zIGNhcmFjdGVyaXphbS1zZSBwZWxhIGluYWxpZW5hYmlsaWRhZGUgZSBpcnJlbnVuY2lhYmlsaWRhZGUsIG7Do28gcG9kZW5kbyBzZXIgY29tZXJjaWFsaXphZG9zIG91IHRyYW5zZmVyaWRvcyBlbnRyZSBwYXJ0aWN1bGFyZXMuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBEIEVTVMOBIElOQ09SUkVUQToNCkEgRFVESCBwb3NzdWkgYXBsaWNhw6fDo28gcGVybWFuZW50ZSBlIHVuaXZlcnNhbCwgaW5jaWRpbmRvIHRhbnRvIGVtIHRlbXBvcyBkZSBwYXogcXVhbnRvIGVtIHF1YWlzcXVlciBjb250ZXh0b3MgZGUgY29udml2w6puY2lhIGNpdmlsaXphdMOzcmlhLg0KDQpCSVpVIERFIFBST1ZBOg0KRFVESCAoMTk0OCkgLSBBcnRpZ28gMcK6Og0KIlRvZG9zIG9zIHNlcmVzIGh1bWFub3MgbmFzY2VtIExJVlJFUyBlIElHVUFJUyBlbSBESUdOSURBREUgZSBESVJFSVRPUy4iDQpUcsOtYWRlIGlsdW1pbmlzdGE6IExpYmVyZGFkZSwgSWd1YWxkYWRlIGUgRnJhdGVybmlkYWRlIQ=='),
  (29, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDHCuiBkYSBEVURILzE5NDggY29uc2FncmEgb3MgaWRlYWlzIGRlIGxpYmVyZGFkZSwgaWd1YWxkYWRlIGUgZnJhdGVybmlkYWRlIGFvIHByZXNjcmV2ZXI6ICJUb2RvcyBvcyBzZXJlcyBodW1hbm9zIG5hc2NlbSBsaXZyZXMgZSBpZ3VhaXMgZW0gZGlnbmlkYWRlIGUgZW0gZGlyZWl0b3MuIERvdGFkb3MgZGUgcmF6w6NvIGUgZGUgY29uc2Npw6puY2lhLCBkZXZlbSBhZ2lyIHVucyBwYXJhIGNvbSBvcyBvdXRyb3MgZW0gZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZS4iDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToNCkEgRFVESCBuw6NvIHByZXbDqiBoaWVyYXJxdWlhIGRlIHN1cGVyaW9yaWRhZGUgZW50cmUgc2VyZXMgaHVtYW5vczsgY29uc2FncmEgYSBpZ3VhbGRhZGUgYWJzb2x1dGEgZW0gZGlnbmlkYWRlLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIHByb3Rlw6fDo28gYW9zIGRpcmVpdG9zIGh1bWFub3MgaW5kZXBlbmRlIGRlIG5hY2lvbmFsaWRhZGUsIGNsYXNzZSBzb2NpYWwsIGfDqm5lcm8gb3UgdsOtbmN1bG8gZnVuY2lvbmFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRCBFU1TDgSBJTkNPUlJFVEE6DQpPcyBkaXJlaXRvcyBodW1hbm9zIHPDo28gdW5pdmVyc2FpcyBlIGluYWxpZW7DoXZlaXMsIG7Do28gc2VuZG8gcGFzc8OtdmVpcyBkZSByZW7Dum5jaWEgdMOhY2l0YS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIG7Do28gY29uZGljaW9uYSBhIGRpZ25pZGFkZSBodW1hbmEgw6AgYXByb3Zhw6fDo28gZGUgbGVpcyBtdW5pY2lwYWlzLg0KDQpCSVpVIERFIFBST1ZBOg0KQXJ0aWdvIDHCuiBkYSBEVURIOg0KQ29uc2FncmEgZXhwcmVzc2FtZW50ZToNCjEuIExpYmVyZGFkZSAoIm5hc2NlbSBsaXZyZXMiKTsNCjIuIElndWFsZGFkZSAoImlndWFpcyBlbSBkaWduaWRhZGUgZSBkaXJlaXRvcyIpOw0KMy4gRnJhdGVybmlkYWRlICgiZXNww61yaXRvIGRlIGZyYXRlcm5pZGFkZSIpLg=='),
  (177, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgQ29udmVuw6fDo28gZGUgQmVsw6ltIGRvIFBhcsOhICgxOTk0KSBjb25zYWdyYSBlbSBzZXUgQXJ0aWdvIDPCuiBxdWUgdG9kYSBtdWxoZXIgdGVtIG8gZGlyZWl0byBhIHVtYSB2aWRhIGxpdnJlIGRlIHZpb2zDqm5jaWEsIHRhbnRvIG5vIMOibWJpdG8gcMO6YmxpY28gcXVhbnRvIG5vIHByaXZhZG8sIGluY2x1aW5kbyBvIGRpcmVpdG8gZGUgc2VyIGxpdnJlIGRlIHF1YWxxdWVyIGZvcm1hIGRlIGRpc2NyaW1pbmHDp8OjbyBlIGRlIHNlciB2YWxvcml6YWRhIGUgZWR1Y2FkYSBsaXZyZSBkZSBwYWRyw7VlcyBlc3RlcmVvdGlwYWRvcyBkZSBjb21wb3J0YW1lbnRvLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIHByb3Rlw6fDo28gbsOjbyBzZSByZXN0cmluZ2Ugw6AgZXNmZXJhIHBhdHJpbW9uaWFsIG91IGVtcHJlc2FyaWFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIENvbnZlbsOnw6NvIHByb3RlZ2UgdG9kYXMgYXMgbXVsaGVyZXMsIGUgbsOjbyBhcGVuYXMgc2Vydmlkb3JhcyBlc3RhdGFpcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBub3JtYSB2ZWRhIGEgdmlvbMOqbmNpYSBlbSBxdWFscXVlciBlc3Bhw6dvLCBuw6NvIHNlIGxpbWl0YW5kbyBhbyBkb21pY8OtbGlvIGNvbmp1Z2FsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpBIENvbnZlbsOnw6NvIMOpIHBlcm1hbmVudGUgZSBuw6NvIGRlcGVuZGUgZGUgZGVjbGFyYcOnw6NvIGRlIGVzdGFkbyBkZSBlbWVyZ8OqbmNpYS4NCg0KQklaVSBERSBQUk9WQToNCkFydC4gM8K6IGRhIENvbnZlbsOnw6NvIGRlIEJlbMOpbSBkbyBQYXLDoToNCiJUb2RhIG11bGhlciB0ZW0gZGlyZWl0byBhIHVtYSB2aWRhIGxpdnJlIGRlIHZpb2zDqm5jaWEsIG5hIGVzZmVyYSBww7pibGljYSBlIG5hIGVzZmVyYSBwcml2YWRhLiI='),
  (178, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk5vcyB0ZXJtb3MgZGEgQ29udmVuw6fDo28gZGUgQmVsw6ltIGRvIFBhcsOhIChBcnQuIDfCuiksIG9zIEVzdGFkb3MtcGFydGVzIGNvbXByb21ldGVtLXNlIGEgYWRvdGFyIHBvbMOtdGljYXMgb3JpZW50YWRhcyBhIHByZXZlbmlyLCBwdW5pciBlIGVycmFkaWNhciBhIHZpb2zDqm5jaWEgY29udHJhIGEgbXVsaGVyLCBpbmNsdWluZG8gYSBjcmlhw6fDo28gZGUgc2VydmnDp29zIGVzcGVjaWFsaXphZG9zIGRlIGF0ZW5kaW1lbnRvLCBjYXBhY2l0YcOnw6NvIGRlIGFnZW50ZXMgcMO6YmxpY29zIGUgbWVjYW5pc21vcyBqdWRpY2lhaXMgY8OpbGVyZXMgZSBlZmljYXplcyBkZSBwcm90ZcOnw6NvIMOgcyB2w610aW1hcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KQSBDb252ZW7Dp8OjbyByZWNoYcOnYSBleHByZXNzYW1lbnRlIGEgaW7DqXJjaWEsIGEgaW1wdW5pZGFkZSBlIGEgdG9sZXLDom5jaWEgZXN0YXRhbCDDoCB2aW9sw6puY2lhLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpOw6NvIHByZXbDqiBhbmlzdGlhIGEgYWdyZXNzb3JlcyBkZSBtdWxoZXJlcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBwcm90ZcOnw6NvIGFicmFuZ2UgdG9kYXMgYXMgbXVsaGVyZXMgc2VtIGRpc3RpbsOnw6NvIGRlIHJlbmRhIG91IG5hY2lvbmFsaWRhZGUuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToNCk8gdHJhdGFkbyBpbXDDtWUgZGV2ZXJlcyBkZSBhZ2lyIGNvbmNyZXRvcyBhbyBFc3RhZG8sIGUgbsOjbyBtZXJhIGZhY3VsZGFkZSBkaXNjcmljaW9uw6FyaWEuDQoNCkJJWlUgREUgUFJPVkE6DQpEZXZlcmVzIGRvIEVzdGFkbyBuYSBDb252ZW7Dp8OjbyBkZSBCZWzDqW0gZG8gUGFyw6E6DQpEZXZlciBkZSBhZ2lyIGNvbSBERVZJREEgRElMSUfDik5DSUEgcGFyYSBwcmV2ZW5pciwgaW52ZXN0aWdhciBlIHB1bmlyIGEgdmlvbMOqbmNpYSBjb250cmEgYSBtdWxoZXIu'),
  (179, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCkEgQ29taXNzw6NvIEludGVyYW1lcmljYW5hIGRlIERpcmVpdG9zIEh1bWFub3MgKENJREgpIGF0dWEgY29tbyDDs3Jnw6NvIGNvbnN1bHRpdm8gZGEgT0VBIGUgcG9zc3VpIGEgYXRyaWJ1acOnw6NvIGZvcm1hbCBkZSByZWFsaXphciB2aXNpdGFzIGluIGxvY28gYW9zIHBhw61zZXMgbWVtYnJvcyBwYXJhIGV4YW1pbmFyIGEgc2l0dWHDp8OjbyBkb3MgZGlyZWl0b3MgaHVtYW5vcywgcHVibGljYXIgcmVsYXTDs3Jpb3MgdGVtw6F0aWNvcyBlIGRlIHBhw61zIGUgZW1pdGlyIHJlY29tZW5kYcOnw7VlcyBhb3MgZ292ZXJub3MgcGFyYSBvIGFwcmltb3JhbWVudG8gZGUgc3VhcyBwb2zDrXRpY2FzIHDDumJsaWNhcyBlIGluc3RpdHVpw6fDtWVzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIENJREggbsOjbyBjb21hbmRhIG9wZXJhw6fDtWVzIG1pbGl0YXJlcyBlc3RyYW5nZWlyYXMuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToNCk7Do28gZXhlcmNlIGZ1bsOnw7VlcyBkZSBhdWRpdG9yaWEgZmluYW5jZWlyYSBlbXByZXNhcmlhbC4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KTsOjbyBwb3NzdWkgY29tcGV0w6puY2lhIHBhcmEgbGVnaXNsYXIgb3UgYWx0ZXJhciBjb25zdGl0dWnDp8O1ZXMgbmFjaW9uYWlzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpOw6NvIGltcMO1ZSBwZW5hbGlkYWRlcyBhbGZhbmRlZ8OhcmlhcyBhb3MgRXN0YWRvcy4NCg0KQklaVSBERSBQUk9WQToNCkluc3RydW1lbnRvcyBkZSBBdHVhw6fDo28gZGEgQ0lESDoNCi0gVmlzaXRhcyBpbiBsb2NvIG5vcyBwYcOtc2VzOw0KLSBSZWxhdMOzcmlvcyBHZXJhaXMgZSBUZW3DoXRpY29zOw0KLSBSZWNvbWVuZGHDp8O1ZXMgZSBNZWRpZGFzIENhdXRlbGFyZXMu'),
  (263, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDI4IGRhIERVREggZXN0YWJlbGVjZTogIlRvZG8gc2VyIGh1bWFubyB0ZW0gZGlyZWl0byBhIHVtYSBvcmRlbSBzb2NpYWwgZSBpbnRlcm5hY2lvbmFsIG5hIHF1YWwgb3MgZGlyZWl0b3MgZSBsaWJlcmRhZGVzIGVzdGFiZWxlY2lkb3MgbmVzdGEgRGVjbGFyYcOnw6NvIHBvc3NhbSBzZXIgcGxlbmFtZW50ZSByZWFsaXphZG9zLiIgRXNzZSBhcnRpZ28gY29uc2FncmEgYSBkaW1lbnPDo28gZXN0cnV0dXJhbCBlIGNvc21vcG9saXRhIGRhIGdhcmFudGlhIGRvcyBkaXJlaXRvcyBodW1hbm9zIGVtIMOibWJpdG8gZ2xvYmFsLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6DQpBIG9yZGVtIGludGVybmFjaW9uYWwgZGV2ZSBzZXIgb3JpZW50YWRhIMOgIGNvb3BlcmHDp8OjbywgcGF6IGUgZWZldGl2YcOnw6NvIGRlIGRpcmVpdG9zLCBlIG7Do28gYW8gZG9tw61uaW8gYmVsaWNpc3RhLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQyBFU1TDgSBJTkNPUlJFVEE6DQpBIHJlc3BvbnNhYmlsaWRhZGUgZGUgY29uc3RydWlyIHVtYSBvcmRlbSBqdXN0YSB2aW5jdWxhIHRvZG9zIG9zIEVzdGFkb3MgZSBpbnN0aXR1acOnw7VlcyBpbnRlcm5hY2lvbmFpcy4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQSBEVURIIGV4aWdlIGNvbmRpw6fDtWVzIHNvY2lhaXMgcmVhaXMgcGFyYSBxdWUgYXMgbGliZXJkYWRlcyBuw6NvIHNlamFtIG1lcmFtZW50ZSBmb3JtYWlzLg0KDQpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6DQpBIHNvbGlkYXJpZWRhZGUgaW50ZXJuYWNpb25hbCDDqSBpbmRpc3BlbnPDoXZlbCBwYXJhIG8gY3VtcHJpbWVudG8gZG9zIGRpcmVpdG9zIGh1bWFub3MuDQoNCkJJWlUgREUgUFJPVkE6DQpBcnRpZ28gMjggZGEgRFVESDoNCkRpcmVpdG8gYSB1bWEgT1JERU0gU09DSUFMIEUgSU5URVJOQUNJT05BTCBqdXN0YSBxdWUgdmlhYmlsaXplIGEgcGxlbmEgZWZpY8OhY2lhIGRlIHRvZG9zIG9zIGRpcmVpdG9zIGh1bWFub3Mu'),
  (264, 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEENCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEEgRVNUw4EgQ09SUkVUQToNCk8gQXJ0aWdvIDI5IGRhIERVREggY29uc2FncmEgb3MgREVWRVJFUyBETyBJTkRJVsONRFVPIGUgb3MgbGltaXRlcyBsZWfDrXRpbW9zIGFvcyBkaXJlaXRvczogIjEuIFRvZG8gc2VyIGh1bWFubyB0ZW0gZGV2ZXJlcyBwYXJhIGNvbSBhIGNvbXVuaWRhZGUsIG5hIHF1YWwgbyBsaXZyZSBlIHBsZW5vIGRlc2Vudm9sdmltZW50byBkYSBzdWEgcGVyc29uYWxpZGFkZSDDqSBwb3Nzw612ZWwuIDIuIE5vIGV4ZXJjw61jaW8gZGUgc2V1cyBkaXJlaXRvcyBlIGxpYmVyZGFkZXMsIHRvZG8gc2VyIGh1bWFubyBlc3RhcsOhIHN1amVpdG8gYXBlbmFzIMOgcyBsaW1pdGHDp8O1ZXMgZGV0ZXJtaW5hZGFzIHBlbGEgbGVpLCBleGNsdXNpdmFtZW50ZSBjb20gbyBmaW0gZGUgYXNzZWd1cmFyIG8gZGV2aWRvIHJlY29uaGVjaW1lbnRvIGUgcmVzcGVpdG8gZG9zIGRpcmVpdG9zIGUgbGliZXJkYWRlcyBkZSBvdXRyZW0gZSBkZSBzYXRpc2ZhemVyIGFzIGp1c3RhcyBleGlnw6puY2lhcyBkYSBtb3JhbCwgZGEgb3JkZW0gcMO6YmxpY2EgZSBkbyBiZW0tZXN0YXIgZ2VyYWwgbnVtYSBzb2NpZWRhZGUgZGVtb2Nyw6F0aWNhLiINCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEIgRVNUw4EgSU5DT1JSRVRBOg0KT3MgZGlyZWl0b3MgaHVtYW5vcyBuw6NvIHPDo28gYWJzb2x1dG9zIGUgaWxpbWl0YWRvcyBwZXJhbnRlIG9zIGRpcmVpdG9zIGFsaGVpb3MgZSBhIG9yZGVtIGRlbW9jcsOhdGljYS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOg0KTyBpbmRpdsOtZHVvIHBvc3N1aSBkZXZlcmVzIGRlIHNvbGlkYXJpZWRhZGUgcGFyYSBjb20gYSBjb211bmlkYWRlIG9uZGUgdml2ZS4NCg0KUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOg0KQXMgbGltaXRhw6fDtWVzIGRldmVtIHNlciBwcmV2aXN0YXMgZW0gbGVpIGVtIHByb2wgZG8gYmVtLWVzdGFyIGVtIHNvY2llZGFkZSBkZW1vY3LDoXRpY2EuDQoNClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToNCk7Do28gc2UgYWRtaXRlIG8gYWJ1c28gZGUgZGlyZWl0byBwYXJhIGRlc3RydWlyIGxpYmVyZGFkZXMgZnVuZGFtZW50YWlzLg0KDQpCSVpVIERFIFBST1ZBOg0KQXJ0aWdvIDI5IGRhIERVREg6DQotIERldmVyZXMgZG8gaW5kaXbDrWR1byBwZXJhbnRlIGEgY29tdW5pZGFkZTsNCi0gTGltaXRlcyBsZWfDrXRpbW9zIGFvcyBkaXJlaXRvcyBodW1hbm9zOiBhcGVuYXMgcG9yIExFSSBwYXJhIGdhcmFudGlyIG9zIGRpcmVpdG9zIGRlIG91dHJlbSBlIGEgb3JkZW0gcMO6YmxpY2EgbnVtYSBTT0NJRURBREUgREVNT0NSw4FUSUNBLg==')
) as b(questao_id, old_b64)
on b.questao_id = r.questao_id;

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_GUARD', '7/7 new_md5+fingerprint simultaneo',
  (select count(*)
   from _lote_reversao_teste lr
   join public.questoes q on q.id = lr.questao_id
   where md5(coalesce(q.explicacao, '')) = lr.new_md5
     and md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
           (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
              from public.alternativas a where a.questao_id = q.id))) = lr.fingerprint
  ) = 7,
  'contagem de conferencias simultaneas';

do $$
declare r record; v_rows int;
begin
  for r in select * from _lote_reversao_teste order by ordem loop
    update public.questoes
    set explicacao = convert_from(decode(r.texto_base64, 'base64'), 'UTF8')
    where id = r.questao_id
      and md5(coalesce(explicacao, '')) = r.new_md5
      and md5(concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
            (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
               from public.alternativas a where a.questao_id = questoes.id))) = r.fingerprint;
    get diagnostics v_rows = row_count;
    insert into _relatorio (fase, item, ok, detalhe)
    values ('REVERT_APPLY', 'restaurar explicacao questao_id=' || r.questao_id, v_rows = 1, 'rows_affected=' || v_rows);
  end loop;
end $$;

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', '7/7 old hashes restaurados',
  (select count(*) from public.questoes
   where id in (13,29,177,178,179,263,264)
     and md5(coalesce(explicacao, '')) in (
       'ba357b5ddcab13cf94f22490c7e485b2','8849b9ec07a4e93ccb11d105ad24fd76','cec5f485195cda3a3cb6e7f29c809a5b',
       '2fe5237594436bfa86ee6b22819eae61','1636880b23fa9d185b2ca697439b301d','51d3492db3804859e09dfb7dfa0692eb',
       'a86b15931d15029cbea03ecadd0e1810'
     )) = 7,
  'contagem pos-restauracao';

insert into _relatorio (fase, item, ok, detalhe)
select 'REVERT_VERIFY', 'globais restaurados a baseline',
  (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes)
  and (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes)
  and (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes)
  and (select count(distinct q.id) from public.questoes q
        join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
        join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
        where q.materia_id = 11 and q.ativa = true and up.ativa = true) = (select dh_uteis from _snapshot_antes),
  'questoes/alternativas/vinculos/dh_uteis identicos ao baseline';

-- RESUMO FINAL
select
  bool_and(ok) as tudo_ok,
  count(*) as total_checks,
  count(*) filter (where ok) as checks_ok,
  count(*) filter (where not ok) as checks_falhos
from _relatorio;

select fase, item, ok, detalhe from _relatorio order by
  case fase
    when 'PRECONDICAO' then 1
    when 'POSCONDICAO' then 2
    when 'REVERT_GUARD' then 3
    when 'REVERT_APPLY' then 4
    when 'REVERT_VERIFY' then 5
  end, item;

rollback;
