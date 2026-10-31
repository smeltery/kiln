const files = Bun.spawnSync(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"]);
if (files.exitCode) throw new Error(files.stderr.toString());
const paths = [...new Set(files.stdout.toString().split("\0"))].filter((path) =>
  /^(Dockerfile|\.bellows\.yml|\.pre-commit-config\.yaml|scripts\/.*\.(sh|ts)|tests\/.*\.sh|\.github\/.*\.ya?ml)$/.test(path),
);
let total = 0;
for (const path of paths) {
  const lines = (await Bun.file(path).text()).split("\n").filter((line) => line.trim()).length;
  if (lines > 250) throw new Error(`${path}: ${lines} nonblank lines exceeds 250`);
  total += lines;
}
if (total > 1000) throw new Error(`${total} nonblank lines exceeds project budget of 1000`);
console.log(`LOC budget: ${total}/1000 nonblank lines; each file <= 250`);
