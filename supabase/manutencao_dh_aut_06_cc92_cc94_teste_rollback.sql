-- TESTE DE ROLLBACK da manutencao DH-AUT-06 (cc92/cc94) — Q180/Q181/
-- Q182/Q189/Q190/Q191.
--
-- Mirror exato de supabase/manutencao_dh_aut_06_cc92_cc94.sql,
-- substituindo apenas o COMMIT final por ROLLBACK, para garantir que
-- a logica testada (precondicoes, updates individuais com checagem
-- de row_count, poscondicoes com checagem de hash/fingerprint/
-- estrutura) seja byte-identica a que sera efetivamente aplicada.
--
-- Gerado programaticamente a partir do arquivo de aplicacao real,
-- eliminando risco de divergencia por retranscricao manual.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _lote_manutencao (
  ordem int primary key,
  questao_id bigint,
  old_md5 text,
  new_md5 text,
  fingerprint text,
  texto_base64 text
) on commit drop;

insert into _lote_manutencao (ordem, questao_id, old_md5, new_md5, fingerprint, texto_base64) values
(1, 180, '4ace86b95f26fd0f077c3f312669f96f', 'c189e7cb437586cc94cae1de61903cae', 'ba1190ee35c21e754efd72188b1831ed',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gUHJvdG9jb2xvIGRlIEFzc3Vuw6fDo28gc29icmUgQ29tcHJvbWlzc28gY29tIGEgUHJvbW/Dp8OjbyBlIFByb3Rlw6fDo28gZG9zIERpcmVpdG9zIEh1bWFub3MgZG8gTWVyY29zdWwgKERlY3JldG8gbsK6IDcuMjI1LzIwMTApIHRlbSBjb21vIG9iamV0bywgY29uZm9ybWUgc2V1IHByw7NwcmlvIHTDrXR1bG8gZSBvIGRpc3Bvc3RvIGVtIHNldXMgYXJ0cy4gMcK6IGUgMsK6LCBhIHByb21vw6fDo28gZSBhIHByb3Rlw6fDo28gZWZldGl2YSBkb3MgZGlyZWl0b3MgaHVtYW5vcyBlIGRhcyBsaWJlcmRhZGVzIGZ1bmRhbWVudGFpcyBubyDDom1iaXRvIGRvIGJsb2NvLCBwb3IgbWVpbyBkb3MgbWVjYW5pc21vcyBpbnN0aXR1Y2lvbmFpcyBkbyBNZXJjb3N1bC4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKTyBQcm90b2NvbG8gbsOjbyB0cmF0YSBkZSBwb2zDrXRpY2EgbW9uZXTDoXJpYSBuZW0gcHJldsOqIGEgY3JpYcOnw6NvIGRlIG1vZWRhIMO6bmljYSBlbnRyZSBvcyBFc3RhZG9zIFBhcnRlcy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToKTyBQcm90b2NvbG8gbsOjbyB2ZXJzYSBzb2JyZSB1bmlmaWNhw6fDo28gdHJpYnV0w6FyaWEsIG1hdMOpcmlhIGVzdHJhbmhhIGFvIHNldSBvYmpldG8uCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRCBFU1TDgSBJTkNPUlJFVEE6Ck8gUHJvdG9jb2xvIG7Do28gaW5zdGl0dWkgcXVhbHF1ZXIgZGVmZXNhIG1pbGl0YXIgY29tdW0gZW50cmUgb3MgRXN0YWRvcyBQYXJ0ZXMuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6Ck8gUHJvdG9jb2xvIG7Do28gdHJhdGEgZGUgZXh0aW7Dp8OjbyBkZSBmcm9udGVpcmFzLCB0ZW1hIGFsaGVpbyBhbyBzZXUgb2JqZXRvIGRlIHByb21vw6fDo28gZSBwcm90ZcOnw6NvIGRvcyBkaXJlaXRvcyBodW1hbm9zLg=='),
(2, 181, '30858e94c4ac4d6203c6615cdf9b1fab', '950ddb18cfb2857907c09b7297751cf8', 'e5954ed8514c572e0ca1ed50c6bd14a4',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gUHJvdG9jb2xvIGRlIEFzc3Vuw6fDo28gc29icmUgQ29tcHJvbWlzc28gY29tIGEgUHJvbW/Dp8OjbyBlIFByb3Rlw6fDo28gZG9zIERpcmVpdG9zIEh1bWFub3MgZG8gTWVyY29zdWwgKERlY3JldG8gbsK6IDcuMjI1LzIwMTApIMOpIGluc3RydW1lbnRvIG5vcm1hdGl2byBwcsOzcHJpbyBkbyBibG9jbyByZWdpb25hbCwgaW50ZWdyYW5kbyBvIGNvbmp1bnRvIGRlIG5vcm1hcyBkbyBNZXJjb3N1bCB2b2x0YWRhcyBlc3BlY2lmaWNhbWVudGUgw6AgbWF0w6lyaWEgZGUgZGlyZWl0b3MgaHVtYW5vcy4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKTyBQcm90b2NvbG8gbsOjbyBwZXJ0ZW5jZSBhbyBvcmRlbmFtZW50byBub3JtYXRpdm8gZGEgVW5pw6NvIEV1cm9wZWlhLCB0YW1wb3VjbyBkaXNjaXBsaW5hIGRpcmVpdG8gbWFyw610aW1vLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOgpPIFByb3RvY29sbyBuw6NvIMOpIGluc3RydW1lbnRvIGRvIHNpc3RlbWEgbm9ybWF0aXZvIGRhIE9yZ2FuaXphw6fDo28gZGFzIE5hw6fDtWVzIFVuaWRhcywgbmVtIHRyYXRhIGRlIGRpcmVpdG8gcGVuYWwgaW50ZXJuYWNpb25hbC4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBEIEVTVMOBIElOQ09SUkVUQToKTyBQcm90b2NvbG8gw6kgdHJhdGFkbyByZWdpb25hbCBkbyBNZXJjb3N1bCwgbsOjbyBpbnRlZ3JhbmRvIG8gZGlyZWl0byBlbGVpdG9yYWwgaW50ZXJubyBicmFzaWxlaXJvLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOgpPIFByb3RvY29sbyBuw6NvIMOpIGluc3RydW1lbnRvIGRvIEZ1bmRvIE1vbmV0w6FyaW8gSW50ZXJuYWNpb25hbCBuZW0gZGlzY2lwbGluYSBwb2zDrXRpY2EgbW9uZXTDoXJpYS4='),
(3, 182, 'c64cf9fd654bc2ed71261935c8fc79dc', 'a6033d457b0f9e24528ba2245d3fdb38', '0ef612cc4ab918bb2b0785c1a7731d19',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gYXJ0LiAxwrogZG8gUHJvdG9jb2xvIGRlIEFzc3Vuw6fDo28gZXN0YWJlbGVjZSBxdWUgYSBwbGVuYSB2aWfDqm5jaWEgZGFzIGluc3RpdHVpw6fDtWVzIGRlbW9jcsOhdGljYXMgZSBvIHJlc3BlaXRvIGFvcyBkaXJlaXRvcyBodW1hbm9zIGUgw6BzIGxpYmVyZGFkZXMgZnVuZGFtZW50YWlzIHPDo28gY29uZGnDp8O1ZXMgZXNzZW5jaWFpcyBwYXJhIGEgdmlnw6puY2lhIGUgZXZvbHXDp8OjbyBkbyBwcm9jZXNzbyBkZSBpbnRlZ3Jhw6fDo28gZW50cmUgYXMgUGFydGVzIOKAlCBmb3JtdWxhw6fDo28gYWluZGEgbWFpcyBmb3J0ZSBkbyBxdWUgYSBtZXJhICJyZWxldsOibmNpYSIgaW5kaWNhZGEgbmEgYWx0ZXJuYXRpdmEsIG8gcXVlIGNvbmZpcm1hIHN1YSBjb21wYXRpYmlsaWRhZGUgY29tIGEgbMOzZ2ljYSBkbyBQcm90b2NvbG8uCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6Ck8gUHJvdG9jb2xvIGNvbnRyYXJpYSBkaXJldGFtZW50ZSBlc3NhIGlkZWlhLCBwb2lzIG8gYXJ0LiAxwrogdmluY3VsYSBvIHJlc3BlaXRvIGFvcyBkaXJlaXRvcyBodW1hbm9zIMOgIHZpZ8OqbmNpYSBlIMOgIGV2b2x1w6fDo28gZG8gcHJvY2Vzc28gZGUgaW50ZWdyYcOnw6NvLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOgpPIFByb3RvY29sbyBkZW1vbnN0cmEgcXVlIG8gYmxvY28gdGFtYsOpbSBzZSBvY3VwYSBkYSBwcm9tb8Onw6NvIGUgcHJvdGXDp8OjbyBkb3MgZGlyZWl0b3MgaHVtYW5vcywgbsOjbyBhcGVuYXMgZGUgbWF0w6lyaWEgY29tZXJjaWFsLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpPIFByb3RvY29sbyBuw6NvIGltcMO1ZSBxdWFscXVlciByZW7Dum5jaWEgZG9zIEVzdGFkb3MgUGFydGVzIMOgcyBzdWFzIENvbnN0aXR1acOnw7VlcyBuYWNpb25haXMuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6Ck8gUHJvdG9jb2xvIMOpIGluc3RydW1lbnRvIGRvIE1lcmNvc3VsIGUgbsOjbyB0ZW0gcG9yIGVmZWl0byBzdWJzdGl0dWlyIGEgT3JnYW5pemHDp8OjbyBkb3MgRXN0YWRvcyBBbWVyaWNhbm9zLCBzaXN0ZW1hIGRpc3RpbnRvIGRlIHByb3Rlw6fDo28gZG9zIGRpcmVpdG9zIGh1bWFub3Mu'),
(4, 189, 'c7bfa453bb11f933260036c92e837063', '214e0ec3a8ee94a22e39e16abd5398c5', '9241e23edeaeb79e0d594eed8ecf028f',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gVHJhdGFkbyBkZSBNYXJyYXF1ZWNoZSBwYXJhIEZhY2lsaXRhciBvIEFjZXNzbyBhIE9icmFzIFB1YmxpY2FkYXMgw6BzIFBlc3NvYXMgQ2VnYXMsIGNvbSBEZWZpY2nDqm5jaWEgVmlzdWFsIG91IGNvbSBPdXRyYXMgRGlmaWN1bGRhZGVzIHBhcmEgVGVyIEFjZXNzbyBhbyBUZXh0byBJbXByZXNzbyAoRGVjcmV0byBuwrogOS41MjIvMjAxOCkgaWRlbnRpZmljYSwgZW0gc2V1IGFydC4gM8K6LCBjYXRlZ29yaWFzIGVzcGVjw61maWNhcyBkZSBiZW5lZmljacOhcmlvcyByZWxhY2lvbmFkYXMgw6AgZGlmaWN1bGRhZGUgZGUgYWNlc3NvIGFvIHRleHRvIGltcHJlc3NvLCBhYnJhbmdlbmRvIGRlc2RlIGEgY2VndWVpcmEgYXTDqSBkZWZpY2nDqm5jaWFzIGbDrXNpY2FzIHF1ZSBpbXBlw6dhbSBvIG1hbnVzZWlvIGRvIGxpdnJvIG91IG8gbW92aW1lbnRvIG9jdWxhciBhcHJvcHJpYWRvIMOgIGxlaXR1cmEuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6Ck8gVHJhdGFkbyBuw6NvIHJlc3RyaW5nZSBzZXVzIGJlbmVmaWNpw6FyaW9zIMOgIGNvbmRpw6fDo28gZGUgZXN0cmFuZ2Vpcm87IG8gYXJ0LiAzwrogbsOjbyBlc3RhYmVsZWNlIG5hY2lvbmFsaWRhZGUgY29tbyBjcml0w6lyaW8gcGFyYSBhIGNvbmRpw6fDo28gZGUgYmVuZWZpY2nDoXJpby4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBDIEVTVMOBIElOQ09SUkVUQToKTyBUcmF0YWRvIG7Do28gY29uZGljaW9uYSBhIGNvbmRpw6fDo28gZGUgYmVuZWZpY2nDoXJpbyBhIHVtYSBpZGFkZSBtw61uaW1hLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpPIFRyYXRhZG8gbsOjbyByZXN0cmluZ2Ugc2V1cyBiZW5lZmljacOhcmlvcyBhIHNlcnZpZG9yZXMgcMO6YmxpY29zLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEUgRVNUw4EgSU5DT1JSRVRBOgpPIFRyYXRhZG8gZGVzdGluYS1zZSBhIHF1ZW0gdGVtIGRpZmljdWxkYWRlIGRlIGFjZXNzbyDDoCBsZWl0dXJhLCBlIG7Do28gYW9zIGF1dG9yZXMgZGFzIG9icmFzLg=='),
(5, 190, '83d40871e689b73773e6399ab85c2deb', '5f0a106956022042a6a212904b4ff65b', 'e762471c699ff3186dbf21370de289c9',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gVHJhdGFkbyBkZSBNYXJyYXF1ZWNoZSBmb2kgYXByb3ZhZG8gcGVsbyBDb25ncmVzc28gTmFjaW9uYWwgcG9yIG1laW8gZG8gRGVjcmV0byBMZWdpc2xhdGl2byBuwrogMjYxLzIwMTUsIHNlZ3VuZG8gbyBwcm9jZWRpbWVudG8gZG8gYXJ0LiA1wrosIMKnM8K6LCBkYSBDb25zdGl0dWnDp8OjbyBGZWRlcmFsLiBFbSByYXrDo28gZGVzc2Ugcml0byBjb25zdGl0dWNpb25hbCwgbyBUcmF0YWRvIMOpIGVxdWl2YWxlbnRlIMOgcyBlbWVuZGFzIGNvbnN0aXR1Y2lvbmFpcy4gQSBhcHJvdmHDp8OjbyBwZWxvIERlY3JldG8gTGVnaXNsYXRpdm8gbsK6IDI2MS8yMDE1IG7Do28gc2UgY29uZnVuZGUgY29tIHN1YSBwcm9tdWxnYcOnw6NvIHBlbG8gRGVjcmV0byBuwrogOS41MjIvMjAxOC4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBCIEVTVMOBIElOQ09SUkVUQToKTyByaXRvIHF1YWxpZmljYWRvIHV0aWxpemFkbyAoZG9pcyB0dXJub3MsIHRyw6pzIHF1aW50b3MgZG9zIHZvdG9zIGVtIGNhZGEgQ2FzYSkgbsOjbyByZXN1bHRhIGVtIG1lcm8gc3RhdHVzIGRlIGxlaSBvcmRpbsOhcmlhLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOgpPIFRyYXRhZG8gbsOjbyBmb2kgYXByb3ZhZG8gcG9yIGRlY3JldG8gbXVuaWNpcGFsLCBhdG8gZXN0cmFuaG8gYW8gcHJvY2VkaW1lbnRvIGRlIGluY29ycG9yYcOnw6NvIGRlIHRyYXRhZG9zIGludGVybmFjaW9uYWlzLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEQgRVNUw4EgSU5DT1JSRVRBOgpPIFRyYXRhZG8gbsOjbyBmb2kgYXByb3ZhZG8gcG9yIHBvcnRhcmlhLCBhdG8gZGUgbmF0dXJlemEgYWRtaW5pc3RyYXRpdmEgaW5jb21wYXTDrXZlbCBjb20gbyByaXRvIGNvbnN0aXR1Y2lvbmFsIGRlIGFwcm92YcOnw6NvIGRlIHRyYXRhZG9zIGRlIGRpcmVpdG9zIGh1bWFub3MuCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRSBFU1TDgSBJTkNPUlJFVEE6Ck8gVHJhdGFkbyBuw6NvIGZvaSBhcHJvdmFkbyBwb3IgcmVzb2x1w6fDo28gYWRtaW5pc3RyYXRpdmEsIGF0byBlc3RyYW5obyBhbyBwcm9jZWRpbWVudG8gZG8gYXJ0LiA1wrosIMKnM8K6LCBkYSBDb25zdGl0dWnDp8OjbyBGZWRlcmFsLg=='),
(6, 191, '687b0faf0f5e980c3842c2da502b5cd9', '06d4e174f2db3310fec46b97c14e69d6', 'fdf216411ced3f5f58a68d28be58da75',
 'R0FCQVJJVE86IGFsdGVybmF0aXZhIEEKClBPUiBRVUUgQSBBTFRFUk5BVElWQSBBIEVTVMOBIENPUlJFVEE6Ck8gVHJhdGFkbyBkZSBNYXJyYXF1ZWNoZSB0ZW0gcG9yIGZpbmFsaWRhZGUgYW1wbGlhciBlIGZhY2lsaXRhciBvIGFjZXNzbyBkZSBzZXVzIGJlbmVmaWNpw6FyaW9zIGEgb2JyYXMgcHVibGljYWRhcywgbWVkaWFudGUgZXhlbXBsYXJlcyBlbSBmb3JtYXRvIGFjZXNzw612ZWwsIHJlbGFjaW9uYW5kby1zZSwgY29uZm9ybWUgcmVjb25oZWNlIHNldSBwcmXDom1idWxvLCBhbyBhY2Vzc28gw6AgaW5mb3JtYcOnw6NvLCDDoCBlZHVjYcOnw6NvIGUgw6AgcGFydGljaXBhw6fDo28gbmEgdmlkYSBjdWx0dXJhbC4gQSBhbHRlcm5hdGl2YSBBIHNpbnRldGl6YSBjb3JyZXRhbWVudGUgZXNzYSBmaW5hbGlkYWRlIGUgb3MgbWVjYW5pc21vcyBkbyBUcmF0YWRvLCBzZW0gY29ycmVzcG9uZGVyIMOgIHRyYW5zY3Jpw6fDo28gbGl0ZXJhbCBkZSB1bSBhcnRpZ28gZXNwZWPDrWZpY28uCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgQiBFU1TDgSBJTkNPUlJFVEE6Ck8gVHJhdGFkbyBuw6NvIHRyYXRhIGRlIG1hdMOpcmlhIHRyaWJ1dMOhcmlhLgoKUE9SIFFVRSBBIEFMVEVSTkFUSVZBIEMgRVNUw4EgSU5DT1JSRVRBOgpPIFRyYXRhZG8gbsOjbyBkaXNjaXBsaW5hIHBvcnRlIGRlIGFybWEsIG1hdMOpcmlhIGVzdHJhbmhhIGFvIHNldSBvYmpldG8uCgpQT1IgUVVFIEEgQUxURVJOQVRJVkEgRCBFU1TDgSBJTkNPUlJFVEE6Ck8gVHJhdGFkbyBuw6NvIHRyYXRhIGRlIGRpcmVpdG8gZWxlaXRvcmFsIHBhc3Npdm8gb3UgZGUgY29uZGnDp8O1ZXMgZGUgZWxlZ2liaWxpZGFkZS4KClBPUiBRVUUgQSBBTFRFUk5BVElWQSBFIEVTVMOBIElOQ09SUkVUQToKTyBUcmF0YWRvIG7Do28gZGlzY2lwbGluYSBwb2zDrXRpY2EgbW9uZXTDoXJpYS4=');

-- Precondicoes: hashes/fingerprints atuais devem bater exatamente com os congelados
do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt
  from _lote_manutencao lm
  join public.questoes q on q.id = lm.questao_id
  where md5(coalesce(q.explicacao,'')) = lm.old_md5
    and md5(
      concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
           from public.alternativas a where a.questao_id = q.id))
    ) = lm.fingerprint;
  if v_cnt <> 6 then
    raise exception 'Abortado: apenas % de 6 questao(oes) conferem simultaneamente old_md5 e fingerprint (drift detectado ou reexecucao apos apply anterior)', v_cnt;
  end if;
end $$;

-- Update por questao, guardado individualmente por old_md5 + fingerprint
do $$
declare r record; v_rows int;
begin
  for r in select * from _lote_manutencao order by ordem loop
    update public.questoes
    set explicacao = convert_from(decode(r.texto_base64, 'base64'), 'UTF8')
    where id = r.questao_id
      and md5(coalesce(explicacao,'')) = r.old_md5
      and md5(
        concat_ws('|', id::text, enunciado, dificuldade, ativa::text,
          (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
             from public.alternativas a where a.questao_id = questoes.id))
      ) = r.fingerprint;
    get diagnostics v_rows = row_count;
    if v_rows <> 1 then
      raise exception 'Abortado: update de questao_id=% afetou % linha(s), esperado exatamente 1', r.questao_id, v_rows;
    end if;
  end loop;
end $$;

-- Poscondicoes ENDURECIDAS
do $$
declare
  v_cnt int;
  r record;
  v_new_md5 text;
  v_fp text;
begin
  for r in select * from _lote_manutencao order by ordem loop
    select md5(coalesce(explicacao,'')) into v_new_md5 from public.questoes where id = r.questao_id;
    if v_new_md5 <> r.new_md5 then
      raise exception 'Abortado: hash pos-update de questao_id=% nao confere: esperado %, obtido %', r.questao_id, r.new_md5, v_new_md5;
    end if;

    select md5(
      concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.ativa::text,
        (select string_agg(ordem::text || ':' || texto || ':' || correta::text, '||' order by ordem)
           from public.alternativas a where a.questao_id = q.id))
    ) into v_fp
    from public.questoes q where q.id = r.questao_id;
    if v_fp <> r.fingerprint then
      raise exception 'Abortado: fingerprint imutavel de questao_id=% mudou (esperado %, obtido %) — campo alem de explicacao foi alterado', r.questao_id, r.fingerprint, v_fp;
    end if;
  end loop;

  select count(*) into v_cnt from public.questoes
  where id in (180,181,182,189,190,191)
    and md5(coalesce(explicacao,'')) in (
      'c189e7cb437586cc94cae1de61903cae','950ddb18cfb2857907c09b7297751cf8','a6033d457b0f9e24528ba2245d3fdb38',
      '214e0ec3a8ee94a22e39e16abd5398c5','5f0a106956022042a6a212904b4ff65b','06d4e174f2db3310fec46b97c14e69d6'
    );
  if v_cnt <> 6 then
    raise exception 'Abortado: esperado exatamente 6 questoes com os novos hashes, encontrado %', v_cnt;
  end if;

  -- estrutura inalterada: 5 alternativas e exatamente 1 correta por questao
  if (select count(*) from public.alternativas where questao_id in (180,181,182,189,190,191)) <> 30 then
    raise exception 'Abortado: total de alternativas das 6 questoes nao e 30';
  end if;
  if (select count(*) from (
        select questao_id from public.alternativas where questao_id in (180,181,182,189,190,191)
        group by questao_id having count(*) filter (where correta) <> 1
      ) x) <> 0 then
    raise exception 'Abortado: alguma das 6 questoes nao tem exatamente 1 alternativa correta';
  end if;

  -- vinculos e utilidade das unidades inalterados
  if (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=92) <> 4 then
    raise exception 'Abortado: cc92_uteis mudou (deveria permanecer 4 nesta fase)';
  end if;
  if (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=94) <> 4 then
    raise exception 'Abortado: cc94_uteis mudou (deveria permanecer 4 nesta fase)';
  end if;

  raise notice 'Poscondicoes OK: 6 explicacoes corrigidas (Q180,Q181,Q182,Q189,Q190,Q191); nenhum outro campo alterado; estrutura/vinculos/uteis inalterados.';
end $$;

rollback;
