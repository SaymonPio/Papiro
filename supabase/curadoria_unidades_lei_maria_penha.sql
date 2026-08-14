-- Curadoria inicial da Lei Maria da Penha para a Fase 2J-C.
-- Um único curso_conteudos (id 53) e cinco recortes pedagógicos.
-- Divisão conferida no texto atualizado da Lei 11.340/2006 no Planalto em
-- 14/08/2026. Não publica nem gera aulas automaticamente.
begin;

do $$
declare v_conteudo_id bigint := 53; v_unidade_padrao uuid;
begin
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id=cc.assunto_id
    where cc.id=v_conteudo_id and a.nome='Lei Maria da Penha'
  ) then raise exception 'Conteudo canonico da Lei Maria da Penha nao confere'; end if;

  select id into v_unidade_padrao from public.unidades_pedagogicas
  where curso_conteudo_id=v_conteudo_id and ordem=1;
  if v_unidade_padrao is null then raise exception 'Unidade padrao do conteudo 53 nao encontrada'; end if;

  update public.unidades_pedagogicas set
    titulo='Fundamentos e campo de aplicação',
    escopo='Lei 11.340/2006, arts. 1º a 7º: finalidade, direitos, configuração da violência doméstica e familiar e suas formas, incluindo a violência vicária do art. 7º, VI (Lei 15.384/2026). Não antecipar assistência, atendimento policial, procedimentos ou medidas protetivas.',
    artigos_esperados=array['art. 1º','art. 2º','art. 3º','art. 4º','art. 5º','art. 6º','art. 7º']::text[],
    ativa=true
  where id=v_unidade_padrao;

  insert into public.unidades_pedagogicas
    (curso_conteudo_id,titulo,ordem,escopo,artigos_esperados,ativa)
  values
    (v_conteudo_id,'Prevenção e assistência à mulher',2,
     'Lei 11.340/2006, arts. 8º e 9º: medidas integradas de prevenção e assistência à mulher em situação de violência doméstica e familiar. No caput vigente do art. 9º, destacar o caráter prioritário no SUS e no Susp e a redação da Lei 14.887/2024; ignorar a redação anterior tachada na fonte oficial. Não ensinar atendimento policial nem medidas protetivas.',
     array['art. 8º','art. 9º']::text[],true),
    (v_conteudo_id,'Atendimento policial e providências imediatas',3,
     'Lei 11.340/2006, arts. 10 a 12-D: atendimento pela autoridade policial, inquirição, providências, pedido da ofendida, afastamento emergencial e monitoração eletrônica. Incluir as redações vigentes de 2026: art. 11, parágrafo único (Lei 15.455/2026), art. 12-C (Lei 15.411/2026) e art. 12-D (Lei 15.383/2026), ignorando versões anteriores tachadas. Não avançar para competência, processo judicial ou medidas protetivas dos arts. 18 e seguintes.',
     array['art. 10','art. 10-A','art. 11','art. 12','art. 12-A','art. 12-B','art. 12-C','art. 12-D']::text[],true),
    (v_conteudo_id,'Procedimentos e medidas protetivas de urgência',4,
     'Lei 11.340/2006, arts. 13 a 24-A: disposições processuais, Juizados, competência, retratação, vedações, sigilo, concessão e espécies de medidas protetivas e crime de descumprimento. Incluir as alterações vigentes de 2026 nos arts. 16, 16-A, 22 e 24-A (Leis 15.380, 15.438, 15.383 e 15.412), ignorando versões anteriores tachadas. Não ensinar atuação do Ministério Público, equipe multidisciplinar ou disposições finais.',
     array['art. 13','art. 14','art. 14-A','art. 15','art. 16','art. 16-A','art. 17','art. 17-A','art. 18','art. 19','art. 20','art. 21','art. 22','art. 23','art. 24','art. 24-A']::text[],true),
    (v_conteudo_id,'Rede de justiça, equipe multidisciplinar e disposições finais',5,
     'Lei 11.340/2006, arts. 25 a 46: Ministério Público, assistência judiciária, equipe multidisciplinar, disposições transitórias e finais e alterações legislativas promovidas pela lei. Incluir os parágrafos únicos vigentes dos arts. 35 e 39 acrescentados pela Lei 15.383/2026 e ignorar versões anteriores tachadas.',
     array['art. 25','art. 26','art. 27','art. 28','art. 29','art. 30','art. 31','art. 32','art. 33','art. 34','art. 35','art. 36','art. 37','art. 38','art. 38-A','art. 39','art. 40','art. 40-A','art. 41','art. 42','art. 43','art. 44','art. 45','art. 46']::text[],true)
  on conflict (curso_conteudo_id,ordem) do update set
    titulo=excluded.titulo, escopo=excluded.escopo,
    artigos_esperados=excluded.artigos_esperados, ativa=excluded.ativa;
end;
$$;

commit;
