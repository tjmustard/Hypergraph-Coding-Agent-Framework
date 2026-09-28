/**
 * HCAF `/hyper-<name>` command alias for the Pi coding agent.
 *
 * Pi loads every skill in `.agents/skills/` natively and exposes it as `/skill:<name>`, so
 * HCAF keeps no per-skill command files for Pi. This extension lets users type the same
 * `/hyper-<name> [args]` commands as in other harnesses: it rewrites the input to
 * `/skill:hyper-<name> [args]` before Pi expands skill commands, and Pi then inlines that
 * skill's SKILL.md. New skills work immediately, with nothing else to keep in sync.
 *
 * Input that does not name a loaded skill passes through unchanged.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const HYPER_COMMAND = /^\/(hyper-[a-z0-9-]+)(?=\s|$)/;

export default function hcafCommands(pi: ExtensionAPI) {
	pi.on("input", (event) => {
		const name = HYPER_COMMAND.exec(event.text)?.[1];
		if (!name || !pi.getCommands().some((command) => command.name === `skill:${name}`)) {
			return { action: "continue" };
		}
		return { action: "transform", text: `/skill:${event.text.slice(1)}`, images: event.images };
	});
}
