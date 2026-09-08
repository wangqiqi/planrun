---
name: api
description: >-
  REST/OpenAPI design review — URL shape, errors, pagination, auth, contract
  sync with client and mocks. Use on API or schema changes.
disable-model-invocation: true
user-invocable: true
---

# api · review checklist

Contract changes must update **server + client + mocks** in the same logical change (prefer same PR).

Standing discipline: [docs/discipline.md](../../../docs/discipline.md)

**用这个**：REST/OpenAPI 契约审查。**不是那个**：密钥/支付/webhook → **`security`**；合并前全量 → **`delivery`**.

## URL and resources

- [ ] Plural nouns, lowercase, kebab-case (`/users` not `/getUsers`)
- [ ] Nesting ≤2 levels; deeper nesting → query or separate resource
- [ ] Version strategy consistent (`/v1/` or header, project-wide)
- [ ] Idempotent writes (PUT/DELETE) semantics correct

## Request and response

- [ ] Stable error code / error type (not message-only)
- [ ] HTTP status semantics (401 vs 403, 404 vs 410)
- [ ] One pagination style (cursor **or** offset, not mixed)
- [ ] Dates ISO-8601; enums match OpenAPI schema

## Security and validation

- [ ] Auth + input validation on write paths
- [ ] Sensitive fields not over-exposed on GET list
- [ ] Rate limits / size limits considered for public endpoints

## Bounds and defaults

- [ ] Numeric params have documented min/max (clamp or 4xx)
- [ ] Enum/pattern fields allowlisted; unknown values rejected or safe fallback
- [ ] Pagination `limit` capped; no unbounded fetch
- [ ] Invalid config fails safe with observable fallback

## Contract sync

- [ ] OpenAPI/spec updated with implementation in same PR
- [ ] Client types / API wrappers updated
- [ ] Mock/fixture enums match server validation
- [ ] Breaking changes noted in CHANGELOG

## Anti-patterns (mark High)

- Backend field rename without client update
- `200` + `{ "error": "..." }` instead of 4xx
- Examples diverge from schema

## API testing

- [ ] Happy path + 401/403/404/422
- [ ] Contract or consumer-driven tests if project has them
- [ ] Pagination edges (empty, last page, invalid cursor)
- [ ] Project tests / `curl` examples match OpenAPI

## Vertical slice (full-stack new API domain)

Beyond the checklist above:

- [ ] Contract fixed before persistence/service churn
- [ ] Server + client types + mocks **same PR**
- [ ] Tests: happy path + main 4xx; project verify green
- [ ] User-visible behavior in docs / CHANGELOG

## Related skills

| Topic | Skill |
|-------|-------|
| Security on endpoints | **`security`** |
| Debug failing API tests | **`debug`** · **`test`** |
| Ship | **`release`** · **`delivery`** |
