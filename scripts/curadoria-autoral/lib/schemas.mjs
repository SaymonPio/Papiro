// Definicoes de schema (contrato de dados) do payload e da questao gerada.
// Sao objetos simples, documentacionais — a validacao de fato roda em
// validador-questoes.mjs (checks explicitos, no mesmo estilo hand-rolled
// de supabase/functions/gerar-aula/validador.mjs), nao um motor de JSON
// Schema generico. Nenhuma dependencia nova foi adicionada para isto.
//
// Ambos os schemas tem additionalProperties=false nos niveis em que faz
// sentido (Secao 21) para ficarem compativeis, no futuro, com Structured
// Outputs da API de IA — sem que isso exija chamar API nesta fase.

export const PAYLOAD_SCHEMA_VERSION = 1;
export const QUESTION_SCHEMA_VERSION = 1;

export const DIFICULDADES_VALIDAS = Object.freeze(["facil", "media", "dificil"]);
export const LETRAS_ALTERNATIVAS = Object.freeze(["A", "B", "C", "D", "E"]);

export const STATUS_BANCA = Object.freeze({
  RESOLVED: "RESOLVED",
  REVIEW_CONFLICT: "REVIEW_CONFLICT",
  REVIEW_FALLBACK: "REVIEW_FALLBACK",
  BLOCKED_NO_BANK: "BLOCKED_NO_BANK",
});

// Fase 2A.1 — SEPARACAO OBRIGATORIA (achado de hardening): a Fase 2A
// original tinha um unico "STATUS_FONTE" que confundia duas perguntas
// diferentes:
//   "sabemos O QUE ensinar/cobrar?"          (contexto pedagogico)
//   "a informacao factual/normativa esta
//    documentalmente validada por um humano?" (validacao de fonte)
// unidades_pedagogicas.escopo e artigos_esperados respondem SOMENTE a
// primeira pergunta — sao metadados pedagogicos, nunca prova de fonte.
// Confundir as duas permitia que qualquer unidade com artigos_esperados
// nao-vazio virasse SOURCE_VALIDATED so por ter a lista, mesmo quando
// ninguem nunca confirmou o texto normativo real (caso real descoberto
// nesta sessao: LC 16.450/2025, art.10 confirmado, resto da lei nao).

// "Existe contexto suficiente para saber O QUE deve ser ensinado?" — NUNCA
// prova fonte factual/normativa, so completude do metadado pedagogico.
export const STATUS_CONTEXTO_PEDAGOGICO = Object.freeze({
  PEDAGOGICAL_CONTEXT_COMPLETE: "PEDAGOGICAL_CONTEXT_COMPLETE",
  PEDAGOGICAL_CONTEXT_PARTIAL: "PEDAGOGICAL_CONTEXT_PARTIAL",
  PEDAGOGICAL_CONTEXT_INSUFFICIENT: "PEDAGOGICAL_CONTEXT_INSUFFICIENT",
});

// "A informacao esta documentalmente validada?" — so pode ser VALIDATED
// quando existir um registro em sources/*.json com validated=true
// (ver lib/source-manifest.mjs) cobrindo esta unidade. NUNCA inferido de
// escopo/artigos_esperados sozinhos.
export const STATUS_VALIDACAO_FONTE = Object.freeze({
  SOURCE_VALIDATED: "SOURCE_VALIDATED",
  SOURCE_PARTIAL: "SOURCE_PARTIAL",
  SOURCE_MISSING: "SOURCE_MISSING",
  SOURCE_REQUIRES_HUMAN_VALIDATION: "SOURCE_REQUIRES_HUMAN_VALIDATION",
});

export const STATUS_ELEGIBILIDADE = Object.freeze({
  ELIGIBLE_FOR_GENERATION: "ELIGIBLE_FOR_GENERATION",
  BLOCKED: "BLOCKED",
});

export const STATUS_CURSO_SEM_ANDAIME = "BLOCKED_NO_PEDAGOGICAL_SCAFFOLD";

export const PRIORIDADES = Object.freeze(["P0", "P1", "P2", "P3", "BLOCKED"]);

// Forma canonica do payload enviado (no futuro) ao gerador — Fase 2A Secao
// 18. Mantido como objeto de referencia/documentacao (usado pelos testes
// para conferir que o payload-builder produz exatamente estas chaves de
// primeiro nivel).
export const CHAVES_PAYLOAD_NIVEL_1 = Object.freeze([
  "schema_version",
  "run_id",
  "course",
  "bank",
  "subject",
  "content",
  "unit",
  "lesson",
  "coverage",
  "generation",
  "references",
  "pedagogical_context",
  "source",
  "constraints",
  "audit_policy",
]);

// Forma canonica da questao gerada — Fase 2A Secao 20. Idem: referencia
// para os testes, a validacao real esta em validador-questoes.mjs.
export const CHAVES_QUESTAO_GERADA = Object.freeze([
  "schema_version",
  "run_id",
  "question_key",
  "origem",
  "enunciado",
  "alternativas",
  "gabarito",
  "explicacao",
  "fundamento",
  "dificuldade",
  "banca_alvo",
  "curso_id",
  "materia_id",
  "conteudo_id",
  "curso_conteudo_id",
  "unidade_id",
  "aula_id",
  "justificativa_aderencia",
  "fonte_utilizada",
  "status_inicial",
  "riscos_identificados",
  "model",
  "prompt_version",
  "generated_at",
]);

export const ORIGEM_QUESTAO_FUTURA = "AUTORAL_PAPIRO";

// Contrato futuro (Secao 14): toda questao nova desta esteira, quando a
// Fase 2B existir, tera exatamente esta combinacao — nao escrito no banco
// agora, so documentado aqui para os testes e o README apontarem para um
// unico lugar.
export const CONTRATO_ORIGEM_FUTURA = Object.freeze({
  origem: ORIGEM_QUESTAO_FUTURA,
  banca: "Papiro",
  gerada_por_ia: true,
});

// Fase 2A.1 — schema do manifesto de fontes local (scripts/curadoria-autoral/sources/*.json).
// Ver lib/source-manifest.mjs para o loader/avaliador.
export const SOURCE_MANIFEST_SCHEMA_VERSION = 1;

export const TIPOS_FONTE = Object.freeze([
  "official_law",
  "official_document",
  "lesson_material",
  "technical_documentation",
  "pedagogical_reference",
  "other",
]);

export const CHAVES_FONTE_MANIFESTO = Object.freeze([
  "schema_version",
  "source_key",
  "type",
  "title",
  "reference",
  "content",
  "content_hash",
  "applies_to_unit_ids",
  "covers_articles",
  "validated",
  "validated_by",
  "validated_at",
  "notes",
]);
