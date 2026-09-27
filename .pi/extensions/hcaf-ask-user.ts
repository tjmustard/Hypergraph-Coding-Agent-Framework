/**
 * HCAF ask_user tool for the Pi coding agent.
 *
 * HCAF skills name an **ask-user** capability (see AGENTS.md → Harness Capability Map):
 * structured questions with labeled options, a free-text "Other" answer, and optional
 * multi-select. Pi has no built-in equivalent, so this extension registers `ask_user`.
 *
 * It uses only Pi's basic dialogs (ctx.ui.select / ctx.ui.input) so it stays stable
 * across Pi releases. Without an interactive UI (print/JSON mode) it tells the model to
 * fall back to plain-text questions instead of guessing an answer.
 *
 * Imports: the type-only import is erased at load time; `@sinclair/typebox` is aliased by
 * both current Pi (@earendil-works) and pre-rename Pi (@mariozechner) releases.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "@sinclair/typebox";

const OTHER = "Other (type your own answer)";

const OptionSchema = Type.Object({
	label: Type.String({ description: "Short option label (1-5 words)" }),
	description: Type.Optional(Type.String({ description: "What choosing this option means" })),
});

const QuestionSchema = Type.Object({
	question: Type.String({ description: "The full question text" }),
	header: Type.Optional(Type.String({ description: "Short topic label, e.g. 'Scope'" })),
	options: Type.Array(OptionSchema, {
		minItems: 1,
		description: "Options to choose from, recommended option first. 'Other' is added automatically.",
	}),
	multiSelect: Type.Optional(
		Type.Boolean({ description: "Allow several options when choices are not mutually exclusive" }),
	),
});

const AskUserParams = Type.Object({
	questions: Type.Array(QuestionSchema, { minItems: 1, maxItems: 4, description: "Questions to ask, in order" }),
});

interface Option {
	label: string;
	description?: string;
}

interface Question {
	question: string;
	header?: string;
	options: Option[];
	multiSelect?: boolean;
}

interface Answer {
	question: string;
	answer: string;
}

interface AskUserDetails {
	answers: Answer[];
	status: "answered" | "cancelled" | "no-ui";
}

type Ui = ExtensionContext["ui"];

function display(option: Option): string {
	return option.description ? `${option.label} — ${option.description}` : option.label;
}

async function askOther(ui: Ui, title: string, signal?: AbortSignal): Promise<string | undefined> {
	const text = await ui.input(title, "Type your answer", { signal });
	const trimmed = text?.trim();
	return trimmed ? trimmed : undefined;
}

async function askSingle(ui: Ui, title: string, q: Question, signal?: AbortSignal): Promise<string | undefined> {
	const choices = [...q.options.map(display), OTHER];
	for (;;) {
		const picked = await ui.select(title, choices, { signal });
		if (picked === undefined) return undefined;
		if (picked !== OTHER) return q.options[choices.indexOf(picked)].label;
		const custom = await askOther(ui, title, signal);
		if (custom !== undefined) return custom;
		// Empty "Other" input: show the options again.
	}
}

async function askMulti(ui: Ui, title: string, q: Question, signal?: AbortSignal): Promise<string | undefined> {
	const selected = new Set<number>();
	let other: string | undefined;
	for (;;) {
		const items = q.options.map((o, i) => `${selected.has(i) ? "[x]" : "[ ]"} ${display(o)}`);
		const otherItem = other ? `[x] Other: ${other}` : `[ ] ${OTHER}`;
		const done = `Done (${selected.size + (other ? 1 : 0)} selected)`;
		const picked = await ui.select(`${title}\n(toggle items, then choose Done)`, [...items, otherItem, done], {
			signal,
		});
		if (picked === undefined) return undefined;
		if (picked === done) break;
		if (picked === otherItem) {
			other = other ? undefined : await askOther(ui, title, signal);
			continue;
		}
		const index = items.indexOf(picked);
		if (selected.has(index)) selected.delete(index);
		else selected.add(index);
	}
	const labels = [...selected].sort((a, b) => a - b).map((i) => q.options[i].label);
	if (other) labels.push(`Other: ${other}`);
	return labels.length ? labels.join("; ") : "(none selected)";
}

function result(text: string, details: AskUserDetails) {
	return { content: [{ type: "text" as const, text }], details };
}

export default function hcafAskUser(pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask_user",
		label: "Ask User",
		description:
			"Ask the user 1-4 structured questions and wait for the answers. Each question has labeled " +
			"options (recommended first), an automatic free-text 'Other' choice, and optional multi-select. " +
			"Use it wherever an HCAF skill says **ask-user**.",
		promptSnippet: "Ask the user 1-4 multiple-choice questions (free-text Other, optional multi-select)",
		promptGuidelines: [
			"When an HCAF skill says **ask-user**, call ask_user: at most 2 questions per call unless the skill says otherwise, 2-4 options each, recommended option first.",
			"Ask open-ended questions (no known options) in plain text and end your turn instead of calling ask_user.",
			"If ask_user reports that no UI is available or the user cancelled, never assume an answer: ask in plain text and wait.",
		],
		parameters: AskUserParams,
		executionMode: "sequential",

		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			if (!ctx.hasUI) {
				return result(
					"ask_user is unavailable: this Pi session has no interactive UI. Ask the question(s) in plain " +
						"text with lettered options (A, B, C, plus 'Other: type your answer'), then end your turn " +
						"and wait for the user's reply.",
					{ answers: [], status: "no-ui" },
				);
			}

			const questions = params.questions as Question[];
			const answers: Answer[] = [];
			for (const [i, q] of questions.entries()) {
				const counter = questions.length > 1 ? ` (${i + 1}/${questions.length})` : "";
				const title = `${q.header ? `[${q.header}] ` : ""}${q.question}${counter}`;
				const answer = q.multiSelect ? await askMulti(ctx.ui, title, q, signal) : await askSingle(ctx.ui, title, q, signal);
				if (answer === undefined) {
					const partial = answers.map((a) => `Q: ${a.question}\nA: ${a.answer}`).join("\n\n");
					return result(
						`${partial ? `${partial}\n\n` : ""}The user dismissed "${q.question}" without answering. ` +
							"Do not assume an answer: ask again in plain text or stop and wait for the user.",
						{ answers, status: "cancelled" },
					);
				}
				answers.push({ question: q.question, answer });
			}

			return result(answers.map((a) => `Q: ${a.question}\nA: ${a.answer}`).join("\n\n"), {
				answers,
				status: "answered",
			});
		},
	});
}
