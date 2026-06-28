import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

type Backend = "herdr" | "tmux";

type Config = {
	backend: Backend;
	focus: boolean;
	closeOnExit: boolean;
	closeDelaySeconds: number;
};

const defaultConfig: Config = {
	backend: "herdr",
	focus: false,
	closeOnExit: false,
	closeDelaySeconds: 5,
};

function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function loadConfig(): Config {
	const path = join(agentDir(), "background-run.json");
	if (!existsSync(path)) return defaultConfig;

	try {
		const parsed = JSON.parse(readFileSync(path, "utf8")) as Partial<Config>;
		return {
			backend: parsed.backend === "tmux" ? "tmux" : "herdr",
			focus: parsed.focus ?? defaultConfig.focus,
			closeOnExit: parsed.closeOnExit ?? defaultConfig.closeOnExit,
			closeDelaySeconds: typeof parsed.closeDelaySeconds === "number" ? parsed.closeDelaySeconds : defaultConfig.closeDelaySeconds,
		};
	} catch {
		return defaultConfig;
	}
}

function safeLabel(value: string): string {
	const label = value.trim().replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "");
	return label.slice(0, 40) || "background";
}

function inferLabel(command: string): string {
	const firstWords = command.trim().split(/\s+/).slice(0, 2).join("-");
	return safeLabel(firstWords || "background");
}

function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'\\''`)}'`;
}

function wrapCommand(command: string, afterExit?: string): string {
	if (!afterExit) return command;
	return `${command}\nstatus=$?\n${afterExit}\nexit $status`;
}

function parseJson(stdout: string): any {
	return JSON.parse(stdout);
}

function getWorkspaces(payload: any): any[] {
	return payload?.result?.workspaces ?? payload?.workspaces ?? [];
}

function getWorkspaceId(workspace: any): string | undefined {
	return workspace?.workspace_id ?? workspace?.id;
}

function getWorkspaceCwd(workspace: any): string | undefined {
	return workspace?.cwd ?? workspace?.root_cwd;
}

function getTab(payload: any): any {
	return payload?.result?.tab ?? payload?.tab ?? payload?.result?.workspace?.tabs?.[0];
}

function getRootPane(payload: any): any {
	return payload?.result?.root_pane ?? payload?.root_pane;
}

export default function (pi: ExtensionAPI) {
	let config = loadConfig();

	async function runHerdr(command: string, cwd: string, label: string, focus: boolean, closeOnExit: boolean, closeDelaySeconds: number) {
		const list = await pi.exec("herdr", ["workspace", "list"]);
		if (list.code !== 0) throw new Error(`herdr workspace list failed: ${list.stderr || list.stdout}`);

		const workspaceLabel = safeLabel(basename(cwd));
		let workspaceId = getWorkspaces(parseJson(list.stdout)).map((workspace) => ({
			id: getWorkspaceId(workspace),
			cwd: getWorkspaceCwd(workspace),
			label: workspace?.label,
		})).find((workspace) => workspace.id && (workspace.cwd === cwd || workspace.label === workspaceLabel))?.id;

		if (!workspaceId) {
			const created = await pi.exec("herdr", ["workspace", "create", "--cwd", cwd, "--label", workspaceLabel, "--no-focus"]);
			if (created.code !== 0) throw new Error(`herdr workspace create failed: ${created.stderr || created.stdout}`);
			const payload = parseJson(created.stdout);
			workspaceId = payload?.result?.workspace?.workspace_id ?? payload?.workspace?.workspace_id ?? payload?.workspace?.id ?? payload?.id;
		}

		if (!workspaceId) throw new Error("Could not determine Herdr workspace id");

		const createdTab = await pi.exec("herdr", [
			"tab",
			"create",
			"--workspace",
			workspaceId,
			"--cwd",
			cwd,
			"--label",
			label,
			focus ? "--focus" : "--no-focus",
		]);
		if (createdTab.code !== 0) throw new Error(`herdr tab create failed: ${createdTab.stderr || createdTab.stdout}`);

		const tabPayload = parseJson(createdTab.stdout);
		const tab = getTab(tabPayload);
		const rootPane = getRootPane(tabPayload);
		const paneId = rootPane?.pane_id;
		const tabId = tab?.tab_id ?? tab?.id;
		if (!paneId) throw new Error("Could not determine Herdr pane id");
		if (!tabId) throw new Error("Could not determine Herdr tab id");

		const afterExit = closeOnExit
			? `sleep ${Math.max(0, closeDelaySeconds)}\nherdr tab close ${shellQuote(tabId)}`
			: undefined;
		const run = await pi.exec("herdr", ["pane", "run", paneId, wrapCommand(command, afterExit)]);
		if (run.code !== 0) throw new Error(`herdr pane run failed: ${run.stderr || run.stdout}`);

		return { backend: "herdr" as const, workspaceId, tabId, paneId };
	}

	async function runTmux(command: string, cwd: string, label: string, focus: boolean, closeOnExit: boolean, closeDelaySeconds: number) {
		const tmuxCommand = closeOnExit
			? `bash -lc ${shellQuote(wrapCommand(command, `sleep ${Math.max(0, closeDelaySeconds)}`))}`
			: `bash -lc ${shellQuote(`${command}\nstatus=$?\nprintf '\\n[background_run exited with status %s; press Ctrl-D or run exit to close]\\n' "$status"\nexec "$SHELL"`)}`;
		const inTmux = Boolean(process.env.TMUX);
		if (inTmux) {
			const args = ["new-window", "-d", "-n", label, "-c", cwd, tmuxCommand];
			const result = await pi.exec("tmux", args);
			if (result.code !== 0) throw new Error(`tmux new-window failed: ${result.stderr || result.stdout}`);
			if (focus) await pi.exec("tmux", ["select-window", "-t", label]);
			return { backend: "tmux" as const, target: label, attach: undefined as string | undefined };
		}

		const session = "pi-bg";
		const hasSession = await pi.exec("tmux", ["has-session", "-t", session]);
		const result = hasSession.code === 0
			? await pi.exec("tmux", ["new-window", "-t", session, "-d", "-n", label, "-c", cwd, tmuxCommand])
			: await pi.exec("tmux", ["new-session", "-d", "-s", session, "-n", label, "-c", cwd, tmuxCommand]);
		if (result.code !== 0) throw new Error(`tmux background run failed: ${result.stderr || result.stdout}`);

		return { backend: "tmux" as const, target: `${session}:${label}`, attach: `tmux attach -t ${session}` };
	}

	async function runBackground(input: { command: string; cwd?: string; label?: string; backend?: Backend; focus?: boolean; closeOnExit?: boolean; closeDelaySeconds?: number }, ctx: any) {
		config = loadConfig();
		const command = input.command.trim();
		if (!command) throw new Error("command is required");

		const cwd = input.cwd || ctx.cwd;
		const label = safeLabel(input.label || inferLabel(command));
		const backend = input.backend || config.backend;
		const focus = input.focus ?? config.focus;
		const closeOnExit = input.closeOnExit ?? config.closeOnExit;
		const closeDelaySeconds = input.closeDelaySeconds ?? config.closeDelaySeconds;

		if (backend === "tmux") return { command, cwd, label, focus, closeOnExit, closeDelaySeconds, ...(await runTmux(command, cwd, label, focus, closeOnExit, closeDelaySeconds)) };
		return { command, cwd, label, focus, closeOnExit, closeDelaySeconds, ...(await runHerdr(command, cwd, label, focus, closeOnExit, closeDelaySeconds)) };
	}

	pi.registerTool({
		name: "background_run",
		label: "Background Run",
		description: "Run a long shell command visibly in a Herdr tab or tmux window without waiting for it to finish.",
		promptSnippet: "Run long commands in a visible Herdr tab or tmux window instead of blocking on bash.",
		promptGuidelines: [
			"Use background_run for long-running commands when live output, manual inspection, or continued execution outside the chat is useful.",
			"Do not use background_run for quick commands where normal bash output is needed immediately.",
		],
		parameters: Type.Object({
			command: Type.String({ description: "Shell command to run." }),
			label: Type.Optional(Type.String({ description: "Short tab/window label. Defaults to the first words of command." })),
			cwd: Type.Optional(Type.String({ description: "Working directory. Defaults to Pi's current cwd." })),
			backend: Type.Optional(StringEnum(["herdr", "tmux"] as const, { description: "Backend to use. Defaults to config." })),
			focus: Type.Optional(Type.Boolean({ description: "Focus the created tab/window. Defaults to config." })),
			closeOnExit: Type.Optional(Type.Boolean({ description: "Close the created tab/window after the command exits. Defaults to config." })),
			closeDelaySeconds: Type.Optional(Type.Number({ description: "Seconds to wait before closing when closeOnExit is true. Defaults to config." })),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const result = await runBackground(params, ctx);
			const lines = [
				`Started background command in ${result.backend}.`,
				`Label: ${result.label}`,
				`Cwd: ${result.cwd}`,
				`Command: ${result.command}`,
			];
			if (result.backend === "herdr") lines.push(`Herdr workspace: ${result.workspaceId}`, `Herdr tab: ${result.tabId}`, `Herdr pane: ${result.paneId}`);
			if (result.backend === "tmux") lines.push(`tmux target: ${result.target}`, ...(result.attach ? [`Attach with: ${result.attach}`] : []));
			return { content: [{ type: "text", text: lines.join("\n") }], details: result };
		},
	});

	pi.registerCommand("background-run", {
		description: "Run a command in the configured background backend",
		handler: async (args, ctx) => {
			try {
				const result = await runBackground({ command: args }, ctx);
				ctx.ui.notify(`Started ${result.label} in ${result.backend}`, "info");
			} catch (error) {
				ctx.ui.notify((error as Error).message, "error");
			}
		},
	});
}
