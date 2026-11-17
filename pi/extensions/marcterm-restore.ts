import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { access } from "node:fs/promises";
import { isAbsolute } from "node:path";

export default function (pi: ExtensionAPI) {
    const endpoint = process.env.MARCTERM_PLUGIN_ENDPOINT;
    let token: string | undefined;

    try {
        token = JSON.parse(process.env.MARCTERM_PLUGIN_TOKENS ?? "{}").restore;
    } catch {
        return;
    }

    if (!endpoint || !token) return;

    let timer: ReturnType<typeof setInterval> | undefined;
    let lastDelivered: string | undefined;
    let generation = 0;
    let reporting = false;
    let interactive = false;
    let clearedPending = false;
    let queue: Promise<void> = Promise.resolve();

    async function send(payload: Record<string, unknown>) {
        const response = await fetch(endpoint!, {
            method: "POST",
            headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ payload }),
            signal: AbortSignal.timeout(5000),
        });

        if (!response.ok) throw new Error(`Restore report failed (${response.status})`);
        await response.json();
    }

    function report(ctx: ExtensionContext, expectedGeneration: number) {
        const file = ctx.sessionManager.getSessionFile();
        const cwd = ctx.cwd;
        if (reporting) return queue;
        reporting = true;

        queue = queue.catch(() => {}).then(async () => {
            if (generation !== expectedGeneration) return;
            const persisted = file && isAbsolute(file) && await access(file).then(() => true, () => false);
            if (!persisted) {
                if (!clearedPending) {
                    await send({ type: "pi.closed" });
                    if (generation === expectedGeneration) clearedPending = true;
                }
                return;
            }
            if (lastDelivered === file) return;

            await send({ type: "pi.session", locator: file, locator_format: "file", cwd });
            if (generation === expectedGeneration) lastDelivered = file;
        }).finally(() => { reporting = false; });

        return queue;
    }

    pi.on("session_start", async (_event, ctx) => {
        if (timer) clearInterval(timer);
        timer = undefined;
        generation += 1;
        lastDelivered = undefined;
        clearedPending = false;
        interactive = ctx.mode === "tui";
        if (!interactive) return;

        const currentGeneration = generation;
        timer = setInterval(() => {
            void report(ctx, currentGeneration).catch(() => {});
        }, 2000);
        timer.unref();
        await report(ctx, currentGeneration).catch(() => {});
    });

    pi.on("agent_start", async (_event, ctx) => {
        if (interactive && ctx.mode === "tui") await report(ctx, generation).catch(() => {});
    });

    pi.on("session_shutdown", async (event) => {
        const clearRecord = interactive && event.reason === "quit";
        interactive = false;
        if (timer) clearInterval(timer);
        timer = undefined;
        generation += 1;
        if (!clearRecord) return;

        queue = queue.catch(() => {}).then(() => send({ type: "pi.closed" }));
        await queue.catch(() => {});
    });
}
