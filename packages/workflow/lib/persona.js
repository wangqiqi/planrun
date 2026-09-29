import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { resolvePlanrunHome } from './growth.js';
const WORKFLOW_PKG = fileURLToPath(new URL('.', import.meta.url));
function walkUpForFile(start, relative) {
    let dir = start;
    while (dir !== dirname(dir)) {
        const candidate = join(dir, relative);
        if (existsSync(candidate))
            return candidate;
        dir = dirname(dir);
    }
    return undefined;
}
/** Bundled roles catalog shipped with @planrun/skill-provider. */
export function resolveRolesPath(planrunHome) {
    const home = resolvePlanrunHome(planrunHome);
    const candidates = [
        home ? join(home, 'packages/skill-provider/config/roles.json') : undefined,
        join(WORKFLOW_PKG, '../../skill-provider/config/roles.json'),
        walkUpForFile(process.cwd(), 'node_modules/@planrun/skill-provider/config/roles.json'),
    ].filter(Boolean);
    for (const path of candidates) {
        if (existsSync(path))
            return path;
    }
    return undefined;
}
export function loadRolesCatalog(rolesPath) {
    const path = rolesPath ?? resolveRolesPath();
    if (!path || !existsSync(path))
        return undefined;
    return JSON.parse(readFileSync(path, 'utf8'));
}
export function resolveSessionDir(cwd) {
    const dsh = join(cwd, '.dsh/growth/session');
    if (existsSync(join(cwd, '.dsh/growth')))
        return dsh;
    const legacy = join(cwd, '.cursorGrowth/session');
    if (existsSync(legacy) || existsSync(join(cwd, '.cursorGrowth')))
        return legacy;
    return dsh;
}
export function resolveSessionPersonaPath(cwd) {
    return join(resolveSessionDir(cwd), 'persona.json');
}
export function resolveAliasesPath(cwd) {
    const candidates = [
        join(cwd, '.dsh/growth/session/aliases.json'),
        walkUpForFile(cwd, '.dsh/growth/session/aliases.json'),
        walkUpForFile(cwd, '.cursorGrowth/session/aliases.json'),
    ].filter(Boolean);
    for (const path of candidates) {
        if (existsSync(path))
            return path;
    }
    return undefined;
}
export function readSessionPersona(cwd) {
    const path = resolveSessionPersonaPath(cwd);
    if (!existsSync(path))
        return undefined;
    try {
        const data = JSON.parse(readFileSync(path, 'utf8'));
        if (!data.persona_id)
            return undefined;
        return data;
    }
    catch {
        return undefined;
    }
}
export function writeSessionPersona(cwd, personaId, resolvedVia) {
    const sessionDir = resolveSessionDir(cwd);
    mkdirSync(sessionDir, { recursive: true });
    const payload = {
        persona_id: personaId,
        resolved_via: resolvedVia,
        updated_at: new Date().toISOString(),
    };
    writeFileSync(join(sessionDir, 'persona.json'), `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
    return payload;
}
function personaKeys(persona) {
    const keys = new Set();
    for (const value of [persona.id, persona.role_name, persona.given_name]) {
        if (value)
            keys.add(value.toLowerCase());
    }
    for (const nick of persona.nicknames ?? []) {
        keys.add(String(nick).toLowerCase());
    }
    return keys;
}
export function resolvePersonaByQuery(query, cwd, planrunHome) {
    const catalog = loadRolesCatalog(resolveRolesPath(planrunHome));
    if (!catalog)
        return { status: 'error', message: 'roles.json not found' };
    const q = query.trim().toLowerCase();
    if (!q)
        return { status: 'miss' };
    const byId = new Map(catalog.personas.map((p) => [p.id, p]));
    const aliasesPath = resolveAliasesPath(cwd);
    if (aliasesPath) {
        try {
            const aliases = JSON.parse(readFileSync(aliasesPath, 'utf8'));
            for (const [alias, personaId] of Object.entries(aliases.aliases ?? {})) {
                if (String(alias).trim().toLowerCase() !== q)
                    continue;
                const persona = byId.get(personaId);
                if (!persona) {
                    return { status: 'error', message: `alias target missing: ${personaId}` };
                }
                return {
                    status: 'ok',
                    persona: { ...persona, _resolved_via: `growth_alias:${alias}` },
                };
            }
        }
        catch (err) {
            return { status: 'error', message: `aliases unreadable: ${String(err)}` };
        }
    }
    const hits = catalog.personas.filter((p) => personaKeys(p).has(q));
    if (hits.length === 1) {
        return { status: 'ok', persona: { ...hits[0], _resolved_via: 'roles.json' } };
    }
    if (hits.length > 1) {
        return { status: 'ambiguous', ids: hits.map((h) => h.id) };
    }
    return { status: 'miss' };
}
export function loadActivePersona(cwd, planrunHome) {
    const catalog = loadRolesCatalog(resolveRolesPath(planrunHome));
    if (!catalog)
        return undefined;
    const session = readSessionPersona(cwd);
    const personaId = session?.persona_id || catalog.default;
    const persona = catalog.personas.find((p) => p.id === personaId);
    if (!persona)
        return undefined;
    return {
        ...persona,
        _resolved_via: session?.resolved_via ?? 'default',
    };
}
export function buildPersonaHint(persona, catalog) {
    const rules = catalog?.speech_rules;
    const cues = persona.voice_cues ?? {};
    const emotions = persona.emotion_cues ?? {};
    const examples = (persona.speech_examples ?? []).slice(0, 3);
    const forbid = rules?.forbid_self_name_opener ? '**禁止**以 given_name 或 nicknames 开场。' : '';
    return [
        '## PlanRun · Persona hint',
        `- **Active persona**: \`${persona.id}\` (${persona.role_name ?? persona.id}) · via ${persona._resolved_via ?? 'default'}`,
        `- **Tone**: ${persona.tone ?? 'neutral'} · ${persona.attitude ?? ''} · intensity ${persona.intensity ?? 0}`,
        `- **Hint**: ${persona.hint ?? ''}`,
        `- **Address user**: ${cues.address_user ?? '你'}`,
        `- **Rhythm / flavor**: ${cues.rhythm ?? ''} · ${cues.flavor ?? ''}`,
        `- **Never**: ${cues.never ?? ''}`,
        `- **Emotion cues**: success=${emotions.on_success ?? ''}; blocker=${emotions.on_blocker ?? ''}; decision=${emotions.on_decision ?? ''}; grind=${emotions.on_grind ?? ''}`,
        forbid,
        examples.length ? `- **Speech anchors**: ${examples.map((e) => `「${e}」`).join(' · ')}` : '',
        '- **Skills policy**: full — persona changes voice only; never skip verify or gate-check.',
    ]
        .filter(Boolean)
        .join('\n');
}
export function buildPersonaStartContext(cwd, planrunHome) {
    const catalog = loadRolesCatalog(resolveRolesPath(planrunHome));
    const persona = loadActivePersona(cwd, planrunHome);
    if (!persona)
        return undefined;
    return buildPersonaHint(persona, catalog);
}
//# sourceMappingURL=persona.js.map