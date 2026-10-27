import { existsSync, renameSync } from 'node:fs';
import { dirname, join } from 'node:path';
/** Canonical project-local Growth root (aligned with Super Cursor `.cursor/config/workflow.json`). */
export const GROWTH_REL = '.growing';
export const PLAN_REL_CANDIDATES = [
    `${GROWTH_REL}/plan.md`,
    '.dsh/growth/plan.md',
    '.cursorGrowth/plan.md',
];
export function growthDirAt(projectRoot) {
    return join(projectRoot, GROWTH_REL);
}
/**
 * One-time migration when only a legacy tree exists. Does not merge if both legacy and `.growing` exist.
 */
export function migrateLegacyGrowth(projectRoot) {
    const target = growthDirAt(projectRoot);
    if (existsSync(target))
        return false;
    const dshGrowth = join(projectRoot, '.dsh', 'growth');
    const cursorGrowth = join(projectRoot, '.cursorGrowth');
    if (existsSync(dshGrowth)) {
        renameSync(dshGrowth, target);
        return true;
    }
    if (existsSync(cursorGrowth)) {
        renameSync(cursorGrowth, target);
        return true;
    }
    return false;
}
export function walkUpForExistingPlan(start) {
    let dir = start;
    for (;;) {
        for (const rel of PLAN_REL_CANDIDATES) {
            const candidate = join(dir, rel);
            if (existsSync(candidate))
                return candidate;
        }
        const parent = dirname(dir);
        if (parent === dir)
            break;
        dir = parent;
    }
    return undefined;
}
//# sourceMappingURL=growth-paths.js.map