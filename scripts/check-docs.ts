import { existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { Window } from "happy-dom";

// Mermaid's parser sanitizes labels through a browser DOM, even without rendering.
const window = new Window();
Object.assign(globalThis, { window, document: window.document });
const { default: mermaid } = await import("mermaid");
mermaid.initialize({ startOnLoad: false, securityLevel: "strict" });
let diagrams = 0;
for (const file of ["README.md", ...new Bun.Glob("docs/**/*.md").scanSync()]) {
  const source = await Bun.file(file).text();
  for (const [, diagram] of source.matchAll(/^```mermaid\s*\n([\s\S]*?)^```/gm)) {
    try {
      await mermaid.parse(diagram);
      diagrams++;
    } catch (error) {
      throw new Error(`${file}: invalid Mermaid diagram`, { cause: error });
    }
  }
  for (const [, target] of source.matchAll(/\]\(([^\s)]+)(?:\s+"[^"]*")?\)/g)) {
    if (/^(?:[a-z]+:|#)/i.test(target)) continue;
    const path = resolve(dirname(file), decodeURIComponent(target.split("#")[0]));
    if (!existsSync(path)) throw new Error(`${file}: broken link ${target}`);
  }
}
if (!diagrams) throw new Error("Expected at least one Mermaid diagram");
console.log(`Documentation links and ${diagrams} Mermaid diagrams passed`);
