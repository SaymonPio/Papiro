-- Manutencao tecnica PRE-MANIFESTO do DH-AUT-07 (Direitos Humanos e
-- Cidadania, materia_id=11, curso Brigada Militar RS).
--
-- Escopo EXATO desta manutencao:
--   Q13  (cc98 - Dignidade humana): INSERT de exatamente 1 alternativa
--        nova (ordem=5, correta=false) + UPDATE de explicacao (A-E).
--   Q29, Q177, Q178, Q179, Q263, Q264: UPDATE somente de explicacao,
--        corrigindo contaminacao cruzada de conteudo de outras unidades
--        (Belem do Para em Q177/Q178; Comissao Interamericana em Q179;
--        DUDH arts.1/28/29 em Q29/Q263/Q264), identificada e congelada
--        nas fases de auditoria/microauditoria pedagogica anteriores.
--
-- Nenhuma outra coluna, questao, alternativa ou vinculo e tocado.
-- Nenhuma questao nova e criada. Nenhum vinculo novo e criado.
--
-- Textos novos representados em base64 UTF-8 (convert_from(decode(...,
-- 'base64'),'UTF8')) para eliminar risco de transcricao de acentos/CRLF.
-- Guardas duplas por old_md5 (antes) e conferencia do proprio texto
-- staged contra o new_md5 congelado (antes de qualquer escrita) e,
-- apos a escrita, por new_md5 + fingerprint imutavel (id+enunciado+
-- dificuldade+ativa+alternativas, sem explicacao) para garantir que
-- absolutamente nada alem de explicacao (e, no caso de Q13, a unica
-- alternativa nova) mudou.
--
-- Termina em COMMIT.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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

do $$
begin
  if (select count(*) from _nova_alternativa_q13) <> 1 then
    raise exception 'Precondicao falhou: staging alternativa Q13 deveria ter 1 linha';
  end if;
  if (select count(*) from _novas_explicacoes) <> 7 then
    raise exception 'Precondicao falhou: staging explicacoes deveria ter 7 linhas';
  end if;

  if (select md5(texto) from _nova_alternativa_q13) <> md5('Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado') then
    raise exception 'Precondicao falhou: texto staged da alternativa E nao bate com o congelado';
  end if;

  if (select md5(explicacao) from _novas_explicacoes where questao_id = 13) <> 'a59aba16c3ace7f13e31886c33ea5152' then
    raise exception 'Precondicao falhou: staged new_md5 Q13 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 29) <> '5da6b6a430faab0aff4efe54f3ef6e30' then
    raise exception 'Precondicao falhou: staged new_md5 Q29 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 177) <> 'a7ffa30db36ca95478c1e429cc65eea0' then
    raise exception 'Precondicao falhou: staged new_md5 Q177 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 178) <> '9843efe8206346c66f628cdaa36e383d' then
    raise exception 'Precondicao falhou: staged new_md5 Q178 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 179) <> '8da95e4315db7f0dca91d802c75495f6' then
    raise exception 'Precondicao falhou: staged new_md5 Q179 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 263) <> '84b9678d3115633bd15c43c3f4bce4da' then
    raise exception 'Precondicao falhou: staged new_md5 Q263 nao bate';
  end if;
  if (select md5(explicacao) from _novas_explicacoes where questao_id = 264) <> '075f145453b7e592023d8f0c5deae5d1' then
    raise exception 'Precondicao falhou: staged new_md5 Q264 nao bate';
  end if;

  if not exists (select 1 from public.questoes where id = 13 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q13 nao encontrada ou ativa/dificuldade divergente';
  end if;
  if md5(coalesce((select explicacao from public.questoes where id = 13), '')) <> 'ba357b5ddcab13cf94f22490c7e485b2' then
    raise exception 'Precondicao falhou: Q13 old_explicacao_md5 divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 13) <> 'd9d1e4a35df7c53c03b1def16f51cc66' then
    raise exception 'Precondicao falhou: Q13 fingerprint BEFORE divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 13) <> 4 then
    raise exception 'Precondicao falhou: Q13 nao tem exatamente 4 alternativas';
  end if;
  if exists (select 1 from public.alternativas where questao_id = 13 and ordem = 5) then
    raise exception 'Precondicao falhou: Q13 ja possui alternativa ordem 5';
  end if;
  if (select count(*) from public.alternativas where questao_id = 13 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q13 gabarito nao e ordem 1 unico';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and texto = 'Livres e iguais em dignidade e direitos' and correta = true) then
    raise exception 'Precondicao falhou: Q13 alternativa 1 divergente';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 2 and texto = 'Submetidos aos direitos definidos por sua profissão' and correta = false) then
    raise exception 'Precondicao falhou: Q13 alternativa 2 divergente';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 3 and texto = 'Com direitos condicionados à nacionalidade' and correta = false) then
    raise exception 'Precondicao falhou: Q13 alternativa 3 divergente';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 4 and texto = 'Iguais apenas perante autoridades administrativas' and correta = false) then
    raise exception 'Precondicao falhou: Q13 alternativa 4 divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 13 and unidade_pedagogica_id = '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid) then
    raise exception 'Precondicao falhou: Q13 vinculo cc98 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 29), '')) <> '8849b9ec07a4e93ccb11d105ad24fd76' then
    raise exception 'Precondicao falhou: Q29 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 29) <> '1e1906c2da85377c3c8ffca4751b3453' then
    raise exception 'Precondicao falhou: Q29 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 29 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q29 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 29) <> 5
     or (select count(*) from public.alternativas where questao_id = 29 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 29 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q29 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 29 and unidade_pedagogica_id = '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid) then
    raise exception 'Precondicao falhou: Q29 vinculo cc99 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 177), '')) <> 'cec5f485195cda3a3cb6e7f29c809a5b' then
    raise exception 'Precondicao falhou: Q177 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 177) <> '7164a1e32c019207b99c53e99929d078' then
    raise exception 'Precondicao falhou: Q177 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 177 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q177 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 177) <> 5
     or (select count(*) from public.alternativas where questao_id = 177 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 177 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q177 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 177 and unidade_pedagogica_id = '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid) then
    raise exception 'Precondicao falhou: Q177 vinculo cc96 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 178), '')) <> '2fe5237594436bfa86ee6b22819eae61' then
    raise exception 'Precondicao falhou: Q178 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 178) <> '4002e9836976d6ebc168396b2ad955dc' then
    raise exception 'Precondicao falhou: Q178 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 178 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q178 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 178) <> 5
     or (select count(*) from public.alternativas where questao_id = 178 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 178 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q178 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 178 and unidade_pedagogica_id = '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid) then
    raise exception 'Precondicao falhou: Q178 vinculo cc96 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 179), '')) <> '1636880b23fa9d185b2ca697439b301d' then
    raise exception 'Precondicao falhou: Q179 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 179) <> '7d28dfb34f497a41405ca7022cd2fa3d' then
    raise exception 'Precondicao falhou: Q179 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 179 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q179 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 179) <> 5
     or (select count(*) from public.alternativas where questao_id = 179 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 179 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q179 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 179 and unidade_pedagogica_id = '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid) then
    raise exception 'Precondicao falhou: Q179 vinculo cc96 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 263), '')) <> '51d3492db3804859e09dfb7dfa0692eb' then
    raise exception 'Precondicao falhou: Q263 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 263) <> '0ae45b1b7e588e36f1d7214f2e7facb0' then
    raise exception 'Precondicao falhou: Q263 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 263 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q263 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 263) <> 5
     or (select count(*) from public.alternativas where questao_id = 263 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 263 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q263 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 263 and unidade_pedagogica_id = '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid) then
    raise exception 'Precondicao falhou: Q263 vinculo cc99 divergente';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 264), '')) <> 'a86b15931d15029cbea03ecadd0e1810' then
    raise exception 'Precondicao falhou: Q264 old hash divergente';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 264) <> '88c73e4da2398b5d5c401d8afd1ba396' then
    raise exception 'Precondicao falhou: Q264 fingerprint divergente';
  end if;
  if not exists (select 1 from public.questoes where id = 264 and ativa = true and dificuldade = 'media') then
    raise exception 'Precondicao falhou: Q264 ativa/dificuldade divergente';
  end if;
  if (select count(*) from public.alternativas where questao_id = 264) <> 5
     or (select count(*) from public.alternativas where questao_id = 264 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 264 and ordem = 1 and correta = true) then
    raise exception 'Precondicao falhou: Q264 estrutura de alternativas divergente';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 264 and unidade_pedagogica_id = '1c05566b-5c71-4baa-b965-3577b8ffdc17'::uuid) then
    raise exception 'Precondicao falhou: Q264 vinculo cc99 divergente';
  end if;

  if (select total_questoes from _snapshot_antes) <> 1138
     or (select total_alternativas from _snapshot_antes) <> 5443
     or (select total_vinculos from _snapshot_antes) <> 915
     or (select dh_uteis from _snapshot_antes) <> 281 then
    raise exception 'Precondicao falhou: baseline global diverge do esperado';
  end if;

  raise notice 'Precondicoes OK';
end $$;

insert into public.alternativas (questao_id, ordem, correta, texto)
select questao_id, ordem, correta, texto from _nova_alternativa_q13;

update public.questoes q
set explicacao = ne.explicacao
from _novas_explicacoes ne
where q.id = ne.questao_id;

do $$
declare
  v_fp text;
begin
  if (select count(*) from public.alternativas where questao_id = 13) <> 5 then
    raise exception 'Poscondicao falhou: Q13 nao tem 5 alternativas';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 5 and correta = false and texto = 'Livres, mas com dignidade e direitos condicionados ao reconhecimento do Estado') then
    raise exception 'Poscondicao falhou: Q13 alternativa ordem5 incorreta';
  end if;
  if (select count(*) from public.alternativas where questao_id = 13 and correta = true) <> 1
     or not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and correta = true) then
    raise exception 'Poscondicao falhou: Q13 gabarito alterado';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 1 and texto = 'Livres e iguais em dignidade e direitos' and correta = true) then
    raise exception 'Poscondicao falhou: Q13 alternativa 1 alterada';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 2 and texto = 'Submetidos aos direitos definidos por sua profissão' and correta = false) then
    raise exception 'Poscondicao falhou: Q13 alternativa 2 alterada';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 3 and texto = 'Com direitos condicionados à nacionalidade' and correta = false) then
    raise exception 'Poscondicao falhou: Q13 alternativa 3 alterada';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 13 and ordem = 4 and texto = 'Iguais apenas perante autoridades administrativas' and correta = false) then
    raise exception 'Poscondicao falhou: Q13 alternativa 4 alterada';
  end if;
  if md5(coalesce((select explicacao from public.questoes where id = 13), '')) <> 'a59aba16c3ace7f13e31886c33ea5152' then
    raise exception 'Poscondicao falhou: Q13 new_explicacao_md5 nao bate';
  end if;
  v_fp := (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 13);
  if v_fp <> 'c2e2d1e86cd8db01b4307cf159e356d9' then
    raise exception 'Poscondicao falhou: Q13 fingerprint AFTER nao bate (%)', v_fp;
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 13 and unidade_pedagogica_id = '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid) then
    raise exception 'Poscondicao falhou: Q13 vinculo cc98 alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 29), '')) <> '5da6b6a430faab0aff4efe54f3ef6e30' then
    raise exception 'Poscondicao falhou: Q29 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 29) <> '1e1906c2da85377c3c8ffca4751b3453' then
    raise exception 'Poscondicao falhou: Q29 fingerprint alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 177), '')) <> 'a7ffa30db36ca95478c1e429cc65eea0' then
    raise exception 'Poscondicao falhou: Q177 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 177) <> '7164a1e32c019207b99c53e99929d078' then
    raise exception 'Poscondicao falhou: Q177 fingerprint alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 178), '')) <> '9843efe8206346c66f628cdaa36e383d' then
    raise exception 'Poscondicao falhou: Q178 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 178) <> '4002e9836976d6ebc168396b2ad955dc' then
    raise exception 'Poscondicao falhou: Q178 fingerprint alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 179), '')) <> '8da95e4315db7f0dca91d802c75495f6' then
    raise exception 'Poscondicao falhou: Q179 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 179) <> '7d28dfb34f497a41405ca7022cd2fa3d' then
    raise exception 'Poscondicao falhou: Q179 fingerprint alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 263), '')) <> '84b9678d3115633bd15c43c3f4bce4da' then
    raise exception 'Poscondicao falhou: Q263 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 263) <> '0ae45b1b7e588e36f1d7214f2e7facb0' then
    raise exception 'Poscondicao falhou: Q263 fingerprint alterado';
  end if;

  if md5(coalesce((select explicacao from public.questoes where id = 264), '')) <> '075f145453b7e592023d8f0c5deae5d1' then
    raise exception 'Poscondicao falhou: Q264 new hash nao bate';
  end if;
  if (select md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)))
      from public.questoes q where q.id = 264) <> '88c73e4da2398b5d5c401d8afd1ba396' then
    raise exception 'Poscondicao falhou: Q264 fingerprint alterado';
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Poscondicao falhou: total de questoes mudou (esperado 0 delta)';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 1 then
    raise exception 'Poscondicao falhou: total de alternativas nao teve exatamente +1';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) then
    raise exception 'Poscondicao falhou: total de vinculos mudou (esperado 0 delta)';
  end if;
  if (select count(distinct q.id) from public.questoes q
        join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
        join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
        where q.materia_id = 11 and q.ativa = true and up.ativa = true) <> (select dh_uteis from _snapshot_antes) then
    raise exception 'Poscondicao falhou: DH uteis mudou (esperado 0 delta)';
  end if;

  raise notice 'Pos-condicoes OK: 1 alternativa inserida (Q13 ordem5) / 7 explicacoes atualizadas / totais: questoes 0 delta, alternativas +1, vinculos 0 delta, DH uteis inalterado';
end $$;

commit;
