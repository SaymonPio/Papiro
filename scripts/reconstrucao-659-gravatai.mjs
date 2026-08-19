// RECONSTRUCAO DOCUMENTAL DA QUESTAO 659 -- fonte oficial FUNDATEC,
// concurso 1021 (Prefeitura de Gravataí/RS, Guarda Municipal, aplicada
// 25/01/2026), Questão 48 do caderno de provas.
//
// PDF oficial: https://www.fundatec.org.br/home/portal/concursos/provas/1021.018_CE_Guarda_Municipal_NM_DT_POS-PRELO.PDF
// Gabarito definitivo oficial (Edital nº 34-K/2026): https://concursos-publicacoes.s3.amazonaws.com/1021/publico/1021_Edital_34-K-2026_GabaritosDefinitivosdasProvasGuarda_698ded482fd62.pdf
//
// Texto extraido diretamente do PDF baixado (scratchpad/prova_guarda_gravatai.pdf)
// via `pdftotext -layout -enc UTF-8`, nao de transcricao de terceiros --
// ver scratchpad/prova_guarda_gravatai_utf8.txt linhas 730-740. Nenhuma
// palavra foi parafraseada; a unica correcao feita foi juntar duas
// palavras que a extracao de PDF colou sem espaco ("dosmoradores" ->
// "dos moradores", "amanifestação" -> "a manifestação"), consistente com
// o mesmo tipo de artefato ja documentado em outras questoes deste
// projeto (ver nota do sub-lote 5 da Fase 3B sobre o mesmo fenomeno).
//
// Gabarito oficial da Questão 48 (tabela "18 - Guarda Municipal" do
// Edital 34-K/2026): alternativa B -- confere exatamente com o que ja
// estava marcado correta=true no banco antes desta reconstrucao.

export const enunciadoReconstruido =
  'Um grupo de pessoas se reuniu na praça central de uma cidade e passou a realizar discursos em defesa do nudismo, o que foi considerado por muitos dos moradores como algo inadequado, levando-os a solicitar que a Guarda Municipal retirasse os manifestantes do local. Chegando ao local, os guardas informaram que a manifestação não era proibida, sendo permitida pela Constituição Federal através de seu art. 5º, que indica que é garantido(a) o(a)';

export const alternativaAReconstruida = 'atentado à moral e aos bons costumes.';

// B, C, D e E ja estavam identicas ao original -- nao alteradas.

export const explicacao = `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 5º, IX, da CF/88 assegura que "é livre a expressão da atividade intelectual, artística, científica e de comunicação, independentemente de censura ou licença" — combinado com o art. 5º, IV ("é livre a manifestação do pensamento, sendo vedado o anonimato"). Um discurso público defendendo uma posição, ainda que controversa ou mal vista por parte da população (como a defesa do nudismo), é exercício legítimo dessa liberdade de expressão/comunicação: o simples fato de o conteúdo ser considerado "inadequado" por terceiros não retira a proteção constitucional, que existe justamente para abranger também ideias impopulares ou minoritárias.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Constituição não "garante" um atentado à moral e aos bons costumes — essa expressão nem sequer corresponde a um direito ou liberdade prevista no art. 5º; é, no máximo, um juízo de valor que alguns poderiam usar para tentar justificar a supressão do discurso, mas que não tem respaldo constitucional como fundamento de uma garantia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Crime inafiançável é uma classificação de gravidade penal (aplicável, por exemplo, ao racismo e à tortura, art. 5º, XLII e XLIII), sem qualquer relação com o direito exercido no discurso público do enunciado — não é logicamente um "direito garantido" que o art. 5º concederia a quem discursa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A liberdade de locomoção (art. 5º, XV) é assegurada em tempo de paz, sem restrição a "horário comercial" — essa condicionante não existe no texto constitucional, e, além disso, não é o direito pertinente ao ato de discursar em praça pública, que é questão de expressão, não de locomoção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Perturbação do descanso público é uma contravenção penal (art. 42 da Lei de Contravenções Penais, relacionada a sossego alheio), não um direito garantido pela Constituição — a alternativa inverte a lógica da pergunta, atribuindo à Constituição a garantia de uma conduta irregular.

BIZU DE PROVA:
Discurso ou manifestação de ideia impopular ou controversa continua protegido pela liberdade de expressão (art. 5º, IV e IX) — a reprovação social ("as pessoas acharam inadequado") não é motivo constitucional para a autoridade calar ou remover quem fala. Desconfie de alternativas que descrevem crimes/contravenções (C, E) ou direitos deslocados de contexto (D) como se fossem a resposta para "o que a Constituição garante" nesse tipo de cenário.`;
