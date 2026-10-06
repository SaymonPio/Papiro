-- ROLLBACK MANUAL — NÃO EXECUTADO AUTOMATICAMENTE, NÃO FAZ PARTE DE
-- supabase/migrations/ DE PROPÓSITO (mesmo motivo de rollback_horas_
-- liquidas_fundacao.sql): um rollback manual nunca pode ficar no
-- diretório de migrations.
--
-- Reverte supabase/migrations/20261004180000_sessao_avulsa_recuperavel.sql.
--
-- ATENÇÃO antes de rodar: se já houver sessões avulsas reais criadas
-- com materia_id/assunto_id preenchidos, o DROP COLUMN abaixo perde
-- esse contexto permanentemente. Avalie exportar/arquivar antes.
-- Também recoloca o comportamento antigo (ambíguo) de
-- ids_questoes_para_usuario se alguém tiver recriado a sobrecarga de 1
-- parâmetro no meio tempo — normalmente não deveria ser necessário
-- reverter esse DROP (a versão de 3 parâmetros com DEFAULT já cobre os
-- mesmos usos).

drop function if exists public.obter_sessao_questoes_avulsa(bigint);
drop function if exists public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint);

drop index if exists public.sessoes_estudo_avulsa_em_andamento_idx;

alter table public.sessoes_estudo
  drop column if exists materia_id,
  drop column if exists assunto_id;

-- Não recriamos aqui a sobrecarga legada de ids_questoes_para_usuario(integer)
-- — ela nunca teve um arquivo-fonte neste projeto (ver comentário da
-- migration). Se for mesmo necessário restaurá-la, seria preciso
-- primeiro recuperar o corpo original por outro meio (ex.: backup do
-- banco), já que nenhum arquivo deste repositório o contém.
