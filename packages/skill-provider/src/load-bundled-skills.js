/**
 * Parse bundled skill directories and build immutable provider candidates.
 *
 * @module @dsh-super/skill-provider/load-bundled-skills
 */
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseYaml } from 'yaml';
import { BUNDLED_SKILL_RANK, isSkillName, } from './dsh-skill-shim.ts';
const PROVIDER_NAME = 'dsh-super';
const SKILLS_ROOT = fileURLToPath(new URL('../skills/', import.meta.url));
function parseFrontmatter(raw) {
    const normalized = raw.replace(/\r\n/g, '\n');
    if (!normalized.startsWith('---\n'))
        return undefined;
    const end = normalized.indexOf('\n---\n', 4);
    if (end === -1)
        return undefined;
    const yamlBlock = normalized.slice(4, end);
    const body = normalized.slice(end + 5);
    const data = parseYaml(yamlBlock);
    if (data === null || typeof data !== 'object' || Array.isArray(data))
        return undefined;
    return { data: data, body };
}
function parseBoolean(value, defaultValue) {
    if (value === undefined || value === null)
        return defaultValue;
    if (typeof value === 'boolean')
        return value;
    if (typeof value === 'number')
        return value !== 0;
    if (typeof value === 'string') {
        const lower = value.trim().toLowerCase();
        if (['true', 'yes', 'on', '1'].includes(lower))
            return true;
        if (['false', 'no', 'off', '0'].includes(lower))
            return false;
    }
    return undefined;
}
function parseInvocation(data) {
    const disableModelInvocation = parseBoolean(data['disable-model-invocation'], false);
    if (disableModelInvocation === undefined)
        return undefined;
    const userInvocable = parseBoolean(data['user-invocable'], true);
    if (userInvocable === undefined)
        return undefined;
    return {
        modelInvocable: !disableModelInvocation,
        userInvocable,
    };
}
function loadSkillDirectory(dirName) {
    const skillMd = join(SKILLS_ROOT, dirName, 'SKILL.md');
    let raw;
    try {
        raw = readFileSync(skillMd, 'utf8');
    }
    catch {
        return undefined;
    }
    const parsed = parseFrontmatter(raw);
    if (parsed === undefined)
        return undefined;
    const nameValue = parsed.data['name'];
    const descriptionValue = parsed.data['description'];
    if (typeof nameValue !== 'string' || !isSkillName(nameValue))
        return undefined;
    if (typeof descriptionValue !== 'string' || descriptionValue.trim() === '')
        return undefined;
    const invocation = parseInvocation(parsed.data);
    if (invocation === undefined)
        return undefined;
    const whenToUse = typeof parsed.data['whenToUse'] === 'string' ? parsed.data['whenToUse'] : undefined;
    const resourceBasePath = join(SKILLS_ROOT, dirName);
    const candidate = {
        name: nameValue,
        description: descriptionValue.trim(),
        whenToUse,
        invocation,
        provider: PROVIDER_NAME,
        source: 'bundled',
        resourceBase: { kind: 'directory', path: resourceBasePath },
        rank: BUNDLED_SKILL_RANK,
        locator: skillMd,
        path: skillMd,
    };
    return { candidate, bodyPath: skillMd, resourceBasePath };
}
/** Load every valid skill bundle under `skills/`. */
export function loadBundledSkills() {
    const records = [];
    for (const entry of readdirSync(SKILLS_ROOT)) {
        const path = join(SKILLS_ROOT, entry);
        if (!statSync(path).isDirectory())
            continue;
        const record = loadSkillDirectory(entry);
        if (record !== undefined)
            records.push(record);
    }
    records.sort((a, b) => a.candidate.name.localeCompare(b.candidate.name));
    return records;
}
/** Build a lookup map from loaded bundled skills. */
export function bundledSkillMap(records) {
    return new Map(records.map((record) => [record.candidate.name, record]));
}
/** Read the current markdown body for one bundled skill. */
export function readSkillBody(record) {
    const raw = readFileSync(record.bodyPath, 'utf8');
    const parsed = parseFrontmatter(raw);
    return parsed?.body ?? raw;
}
/** Materialize a full skill definition from a bundled record. */
export function toDefinition(record) {
    const { candidate } = record;
    return {
        name: candidate.name,
        description: candidate.description,
        whenToUse: candidate.whenToUse,
        invocation: candidate.invocation,
        provider: candidate.provider,
        source: candidate.source,
        resourceBase: candidate.resourceBase,
        path: candidate.path,
        content: readSkillBody(record),
    };
}
export { PROVIDER_NAME };
//# sourceMappingURL=load-bundled-skills.js.map