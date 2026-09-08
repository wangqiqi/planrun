# delivery · checklist §1–7 (core)

### 1. Visual consistency

- [ ] typography matches design system / neighboring pages
- [ ] colors from tokens/variables, not scattered literals (grep `#` · `rgb(` · magic px)
- [ ] spacing, radius, shadows match component library
- [ ] responsive/dark mode (if product has them)

#### Anti–AI-template self-check

- [ ] avoid default trio (warm cream+serif / pure black+acid / newspaper zero-radius) unless brief asks
- [ ] one **signature** element; rest restrained
- [ ] motion serves theme, not decoration
- [ ] copy is user-facing; empty/error states give next step

### 2. Internationalization (i18n)

> Project paths → `.dsh/growth/learn/acceptance.md`

**Skip** (state in report): internal CLI/lib only, no user UI, or team waived i18n this release.

- [ ] user-visible strings use i18n API when stack has i18n
- [ ] no stray literals (grep UI strings vs key files)
- [ ] new keys in all locales; no empty translations
- [ ] date/number/plural per locale
- [ ] errors/toasts/empty states i18n-aligned

### 3. Docs ↔ implementation

- [ ] spec/README describes shipped behavior
- [ ] shipped behavior documented (not code-only)
- [ ] conflicts → **`Decision needed`**

| Scripted | Manual |
|----------|--------|
| project `docs/scripts/verify_doc_*.sh` if any | semantic completeness · reader clarity |

### 4. Backend · API · data

- [ ] API docs enable parallel FE/BE work (examples, errors, auth)
- [ ] fields, types, enums, pagination unambiguous
- [ ] implementation matches docs (**api** skill v0.2+)
- [ ] DB/schema/migration matches docs
- [ ] mocks/fixtures match production schema
- [ ] conflicts → **`Decision needed`**

### 5. Components · interaction · IA

- [ ] primary pages have clear workflow intent
- [ ] role-based landing/sidebar matches RBAC if applicable
- [ ] multi-step flows show entity context (breadcrumb/bar)
- [ ] no TODO/FIXME on production paths
- [ ] loading/empty/error states present
- [ ] forms: validation, disabled, submit feedback
- [ ] dialogs: title, confirm/cancel, overlay/ESC behavior

### 6. Extensibility · maintainability

- [ ] feature in correct module layer
- [ ] minimal diff; no drive-by refactors (**scope** · **`review`**)
- [ ] feature flags documented if used

### 7. Production readiness

- [ ] no debug flags, mock data, test accounts on prod paths
- [ ] auth aligns with **security** (v0.2+)
- [ ] logs: no PII/secrets; user-friendly errors
- [ ] matches project verify (already green)
