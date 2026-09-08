#!/usr/bin/env node
/**
 * resolve-persona.mjs — CLI for persona lookup (PlanRun)
 * Usage: node scripts/resolve-persona.mjs <query> [project_root]
 * Exit 0 + JSON persona; 2 ambiguous; 1 miss/error
 */
import { resolvePersonaByQuery, loadActivePersona, buildPersonaHint, loadRolesCatalog, resolveRolesPath } from '../packages/workflow/lib/persona.js'

const [query, projectRoot = process.cwd()] = process.argv.slice(2)

if (!query) {
  const persona = loadActivePersona(projectRoot)
  if (!persona) {
    console.error(JSON.stringify({ error: 'no_active_persona' }))
    process.exit(1)
  }
  const catalog = loadRolesCatalog(resolveRolesPath())
  console.log(JSON.stringify({ persona, hint: buildPersonaHint(persona, catalog) }, null, 2))
  process.exit(0)
}

const result = resolvePersonaByQuery(query, projectRoot)
switch (result.status) {
  case 'ok':
    console.log(JSON.stringify(result.persona, null, 2))
    process.exit(0)
  case 'ambiguous':
    console.error(JSON.stringify({ ambiguous: true, ids: result.ids }))
    process.exit(2)
  case 'error':
    console.error(JSON.stringify({ error: result.message }))
    process.exit(1)
  default:
    console.error(JSON.stringify({ error: 'miss' }))
    process.exit(1)
}
