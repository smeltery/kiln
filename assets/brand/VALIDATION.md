# Brand integration validation

Reviewed on 2026-10-31.

## Repository checks

- All 59 supplied files match the source ZIP byte-for-byte, including the
  original checksum manifest and font license notices.
- `bun run brand:check` verifies SHA-256 hashes for all 58 non-manifest brand
  files through the shared local, hook, and CI validation.
- Isolated copies confirmed that the check rejects changed, missing, and added
  assets, a missing manifest, and an empty library. An intentional `--write`
  followed by a check passes. The command works outside the repository's
  working directory.
- All 19 SVGs parse as XML and all 27 PNGs decode. Application and icon
  dimensions, the ICO's 16/32/48 px sizes, and the symbol's transparent
  background and chamber counter were verified.
- Markdown, HTML, and CSS local asset references resolve.
- `npm ci --ignore-scripts` passed with the existing dependency lockfile.
- `bun run check:docs` passed Markdown lint for 12 files, local link checks,
  four Mermaid diagrams, and brand integrity. Inline HTML is allowed for the
  theme-aware logos.
- `bun run check:loc` passed at 886/1,000 nonblank lines; every file is within
  the 250-line limit.
- Actionlint 1.7.7 passed for all workflows. CI's shared checks include brand
  integrity through `bun run check:docs`.
- `shellcheck scripts/*.sh` passed.
- `git diff --check` passed.

## Rendered review

- Inspected the supplied brand board and README banner, plus browser renders
  of the guide, README, and documentation index.
- Reviewed the supplied guide in Chromium at 320, 390, 768, and 1440 px.
- All three logo buttons load the matching asset, update their pressed state,
  and use the appropriate light or dark background.
- All five color buttons copy the expected hex value. Unavailable clipboard
  access displays the selectable-value fallback.
- Images and local Space Grotesk/JetBrains Mono fonts load. No horizontal page
  overflow, browser script errors, failed resources, or HTTP errors were found.
- Rendered README and documentation-index markup at 390 and 1440 px in light
  and dark modes using a local Markdown renderer. The banner loads, and the
  docs picture selects the primary or reversed lockup correctly.

## Verification limits

The Dockerfile and runtime scripts were not changed. Local container builds
and act smoke runs were not performed; CI tests direct and bootstrap modes.
Local Flox activation exited without providing a runnable environment, so the
focused checks above used locally available Node, Bun, actionlint, and shellcheck.
CodeRabbit review was unavailable because its CLI was signed out.

The documentation-header composition remains a design concept. The supplied
social-preview image is ready for upload; GitHub's repository social-preview
setting was not changed by this integration.
