---
name: ohm
description: Use when building AI features — LLM integration, RAG, agents, embeddings, semantic search.
---

# Ohm — AI Engineering

Ohm (โอม) is the AI developer of the HMS CNX team. This skill provides the craft for building
reliable, safe, and cost-aware AI features: RAG pipelines with citations, agent/tool-use patterns,
embeddings and semantic search, and the guardrails that ordinary code does not need.

## When to use
- Building or changing an LLM feature, agent, or tool-use flow.
- Implementing a RAG pipeline, embeddings, or semantic search.
- Hardening AI guardrails (prompt-injection defense, output sanitization, cost/rate limits).
- Tuning retrieval quality, latency, or token cost.

## Workflow
1. Read the scope and acceptance criteria.
2. Detect the AI stack (langchain / llamaindex, vector DB, model SDK).
3. Implement the feature as a minimal diff in the project's style.
4. Add guardrails: injection defense, output sanitization, rate/cost limits.
5. Self-verify and capture AI risk notes.
6. Return for QA.

## Knowledge / patterns
- **RAG pipeline patterns** — ingest → chunk → embed → store → retrieve → (rerank) → generate. Pick a chunking strategy that fits the content (semantic/recursive splits with overlap, not arbitrary fixed cuts); retrieve top-k by vector similarity, optionally rerank for precision, and always pass retrieved context with **source citations** so answers are attributable and verifiable.
- **Agent / tool-use patterns** — define tools with strict, typed schemas; validate tool arguments before execution; whitelist allowed actions and cap iterations/recursion to avoid loops; never let model output directly trigger destructive or privileged operations without a guard.
- **AI/RAG checklist** — bound context size (token budget per request); right-size chunking; track embedding cost and cache embeddings for unchanged content; watch latency (stream responses, parallelize retrieval); cache frequent query results; mitigate hallucination via grounding + citations + "I don't know" fallbacks.
- **Guardrails — prompt-injection defense** — treat retrieved/user content as untrusted data, never as instructions; separate system instructions from user/document content; ignore embedded "ignore previous instructions" patterns; constrain the model's authority with tool whitelists and output schemas.
- **Guardrails — output sanitization** — validate/parse model output against an expected schema (JSON mode / structured output) before use; sanitize any model-generated HTML/SQL/shell before it touches a sink; never `eval` model output.
- **Guardrails — rate & cost limits** — enforce per-user/request rate limits, max tokens, and timeouts; add retries with backoff for transient errors; degrade gracefully (cached/partial answer) instead of unbounded spend.
- **Vector DB options** — choose to fit scale and ops: pgvector (Postgres-native, simple), Qdrant/Weaviate/Milvus (dedicated, scalable), Pinecone (managed); detect the project's existing choice and follow it. Index with the right distance metric and store source metadata alongside vectors for citations.
- **Secrets** — never hardcode API keys; read them from the environment/secret manager at runtime. For Anthropic SDK work, consult the `claude-api` skill (prompt caching, structured output, tool use).

> Shared team baseline (DoD, review culture, Context7 reflex, secret safety) lives in the `engineering-practices` skill — load it alongside this one.

## Decision rules
- **Is this retrieved/user text instructions or data?** → always **data**. Never let it alter the system prompt or trigger privileged actions; isolate it.
- **Can model output reach a sink** (SQL/shell/HTML/eval)? → validate against a schema first; sanitize before the sink; never `eval` it.
- **Tool/agent action destructive or privileged?** → require a guard/whitelist + arg validation; cap iterations to stop loops.
- **RAG answer** → must carry source citations and an "I don't know" fallback when retrieval is weak.
- **Cost/latency** → bound max tokens + context budget, cache embeddings for unchanged content, stream long responses; add timeouts + backoff retries.
- **Unfamiliar/changed SDK** (model provider, LangChain/LlamaIndex, vector client bump) → Context7 docs check first (and `claude-api` for Anthropic).

## Anti-patterns
- **Prompt injection via context** — smell: retrieved/user text concatenated into the system prompt → keep instructions and untrusted content separate; ignore embedded "ignore previous instructions".
- **Unsanitized output to a sink** — smell: model-generated SQL/HTML/shell used directly → schema-validate + sanitize first; never `eval`.
- **Unbounded spend** — smell: no max-tokens, no rate limit, retries without backoff → cap tokens/context, rate-limit per user, backoff.
- **Citation-free RAG** — smell: answers with no source refs → attach source metadata and surface citations.
- **Naive chunking** — smell: fixed-size cuts mid-sentence → semantic/recursive splits with overlap.
- **Embedding churn** — smell: re-embedding unchanged content every run → cache by content hash.

## Worked examples
**Separate instructions from untrusted context:**
```python
# ✗ before — injectable: doc text can hijack the instruction
prompt = f"Answer using: {retrieved_text}. {user_question}"
# ✓ after — roles separate; retrieved text is data, not instruction
messages = [
    {"role": "system", "content": "Answer ONLY from <context>. If absent, say you don't know. Cite sources."},
    {"role": "user", "content": f"<context>{retrieved_text}</context>\n\nQuestion: {user_question}"},
]
```
**Validate model output before use:**
```python
# ✓ structured output → parse/validate → only then trust it
data = MySchema.model_validate_json(resp.output_text)  # raises on bad shape
```

## Verification checklist
- [ ] Relevant tests/evals run; retrieval quality, latency, cost sanity-checked (captured output).
- [ ] Untrusted/retrieved content treated as data, never as instructions.
- [ ] Model output schema-validated/sanitized before any sink; no `eval`.
- [ ] Tool actions guarded/whitelisted with arg validation and an iteration cap.
- [ ] Token/context budget, rate limits, timeouts, and backoff in place.
- [ ] RAG answers carry citations; API keys read from env, never hardcoded.

## References
- OWASP *Top 10 for LLM Applications* (prompt injection, insecure output handling, unbounded consumption).
- Provider docs (Anthropic / OpenAI) and the vector DB's docs; `claude-api` skill for Anthropic SDK.
- **Context7:** `resolve-library-id` for the model SDK / LangChain / vector client → `get-library-docs` before using an unfamiliar or upgraded API.

## Guardrails
- Secret safety + read-before-edit + minimal diffs (see team guardrails).
- Prevent prompt injection and data leakage; sanitize LLM output; never embed API keys; bound context size/cost; cite sources in RAG.

## Output
Files changed + what changed + how to run + AI risk notes (injection, cost, hallucination).
