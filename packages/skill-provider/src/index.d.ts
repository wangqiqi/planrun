/**
 * Bundled planrun skill provider.
 *
 * @module @planrun/skill-provider
 */
import type { Context } from './dsh-skill-shim.ts';
/** Cordis plugin name. */
export declare const name = "planrun-skill-provider";
/** Registers on the skill registry. */
export declare const inject: string[];
/** Register bundled Super Cursor–adapted skills on `ctx.skills`. */
export declare function apply(ctx: Context): void;
//# sourceMappingURL=index.d.ts.map