import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type NonInteractivePolicy = "block" | "allow";

type Rule = {
	id: string;
	description: string;
	pattern: string;
};

type Config = {
	enabled: boolean;
	nonInteractive: NonInteractivePolicy;
	rules: Rule[];
};

const defaultRules: Rule[] = [
	{
		id: "sudo",
		description: "Privilege escalation via sudo",
		pattern: String.raw`(^|[;&|()\s])sudo([\s;&|()]|$)`,
	},
	{
		id: "rm-recursive",
		description: "Recursive deletion",
		pattern: String.raw`(^|[;&|()\s])rm\s+(?:[^;&|]*\s)?(?:-[^\s;&|]*[rR][^\s;&|]*|--recursive)([\s;&|]|$)`,
	},
	{
		id: "chmod-777",
		description: "World-writable chmod",
		pattern: String.raw`(^|[;&|()\s])chmod\s+[^;&|]*\b777\b`,
	},
	{
		id: "chown",
		description: "Ownership changes",
		pattern: String.raw`(^|[;&|()\s])chown([\s;&|()]|$)`,
	},
	{
		id: "dd",
		description: "Raw disk writes/copies with dd",
		pattern: String.raw`(^|[;&|()\s])dd([\s;&|()]|$)`,
	},
	{
		id: "mkfs",
		description: "Filesystem creation/destruction",
		pattern: String.raw`(^|[;&|()\s])mkfs(?:\.[A-Za-z0-9_-]+)?([\s;&|()]|$)`,
	},
	{
		id: "diskutil-erase",
		description: "macOS disk erase operations",
		pattern: String.raw`(^|[;&|()\s])diskutil\s+erase`,
	},
	{
		id: "curl-sh",
		description: "Downloaded script piped into a shell",
		pattern: String.raw`\b(curl|wget)\b[^;&]*\|\s*(?:sudo\s+)?(?:sh|bash|zsh)\b`,
	},
];

const defaultConfig: Config = {
	enabled: true,
	nonInteractive: "block",
	rules: defaultRules,
};

function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function loadConfig(): Config {
	const path = join(agentDir(), "shell-guard.json");
	if (!existsSync(path)) return defaultConfig;

	try {
		const parsed = JSON.parse(readFileSync(path, "utf8")) as Partial<Config>;
		return {
			enabled: parsed.enabled ?? defaultConfig.enabled,
			nonInteractive: parsed.nonInteractive === "allow" ? "allow" : "block",
			rules: Array.isArray(parsed.rules) && parsed.rules.length > 0 ? parsed.rules : defaultRules,
		};
	} catch {
		return defaultConfig;
	}
}

function compileRules(rules: Rule[]): Array<Rule & { regex: RegExp }> {
	return rules.flatMap((rule) => {
		try {
			return [{ ...rule, regex: new RegExp(rule.pattern, "i") }];
		} catch {
			return [];
		}
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerFlag("unsafe", {
		description: "Disable shell command guardrails for this run",
		type: "boolean",
		default: false,
	});

	let config = loadConfig();
	let sessionEnabled = config.enabled;
	let compiledRules = compileRules(config.rules);
	const allowedCommands = new Set<string>();

	function isEnabled(): boolean {
		return sessionEnabled && !pi.getFlag("unsafe");
	}

	function matchCommand(command: string): (Rule & { regex: RegExp }) | undefined {
		return compiledRules.find((rule) => rule.regex.test(command));
	}

	async function guardCommand(command: string, ctx: any, source: "model" | "user") {
		if (!isEnabled()) return undefined;
		if (allowedCommands.has(command)) return undefined;

		const rule = matchCommand(command);
		if (!rule) return undefined;

		const reason = `${rule.description} (${rule.id})`;

		if (!ctx.hasUI) {
			if (config.nonInteractive === "allow") return undefined;
			return { block: true, reason: `Shell guard blocked ${source} command: ${reason}` };
		}

		const choice = await ctx.ui.select(
			`Shell command requires approval\n\nRule: ${reason}\nSource: ${source}\n\n${command}`,
			["Allow once", "Allow exact command this session", "Deny"],
		);

		if (choice === "Allow once") return undefined;
		if (choice === "Allow exact command this session") {
			allowedCommands.add(command);
			return undefined;
		}

		return { block: true, reason: `Blocked by shell guard: ${reason}` };
	}

	pi.registerCommand("shell-guard", {
		description: "Manage shell guard: /shell-guard on|off|status|rules|reload|clear",
		handler: async (args, ctx) => {
			const action = args.trim().toLowerCase() || "status";

			if (action === "on") {
				sessionEnabled = true;
				ctx.ui.notify("Shell guard enabled for this session", "info");
				return;
			}

			if (action === "off") {
				sessionEnabled = false;
				ctx.ui.notify("Shell guard disabled for this session", "warning");
				return;
			}

			if (action === "reload") {
				config = loadConfig();
				sessionEnabled = config.enabled;
				compiledRules = compileRules(config.rules);
				allowedCommands.clear();
				ctx.ui.notify("Shell guard config reloaded", "info");
				return;
			}

			if (action === "clear") {
				allowedCommands.clear();
				ctx.ui.notify("Shell guard session approvals cleared", "info");
				return;
			}

			if (action === "rules") {
				ctx.ui.notify(
					compiledRules.map((rule) => `${rule.id}: ${rule.description}`).join("\n"),
					"info",
				);
				return;
			}

			const flagStatus = pi.getFlag("unsafe") ? "disabled by --unsafe" : "not set";
			ctx.ui.notify(
				`Shell guard: ${isEnabled() ? "enabled" : "disabled"}\n--unsafe: ${flagStatus}\nNon-interactive: ${config.nonInteractive}\nRules: ${compiledRules.length}\nSession approvals: ${allowedCommands.size}`,
				"info",
			);
		},
	});

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = String((event.input as { command?: unknown }).command ?? "");
		const result = await guardCommand(command, ctx, "model");
		if (result?.block) return result;
		return undefined;
	});

	pi.on("user_bash", async (event, ctx) => {
		const result = await guardCommand(event.command, ctx, "user");
		if (!result?.block) return undefined;

		return {
			result: {
				output: result.reason ?? "Blocked by shell guard",
				exitCode: 1,
				cancelled: false,
				truncated: false,
			},
		};
	});
}
