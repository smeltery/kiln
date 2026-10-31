# Kiln brand

A solid base. For local CI.

Use “A Wolfi-based runner image for act.” as the short description, and
“Built for the work.” as the supporting line. Bellows plans and orchestrates
local workflows; Kiln supplies the runner environment.

This directory is the canonical asset library, following
[Bellows' brand-library structure](https://github.com/smeltery/bellows/tree/main/assets/brand).
The supplied kit is preserved with its original filenames and relative paths.
Its “proposed” labels describe the original handoff; this README records how
the repository uses it.

## Preview and source material

Open [index.html](index.html) locally for the responsive guide, logo switcher,
color swatches, typography, and downloads. All artwork and fonts are local.
For clipboard support, serve the repository from localhost with a static HTTP
server, for example `python3 -m http.server --bind 127.0.0.1 8000`, then open
`http://127.0.0.1:8000/assets/brand/`. Swatches also show selectable hex values
when copying is unavailable.

- [Brand guide](kiln-brand-guide.pdf): eight-page visual reference.
- [Brand board](brand-board.png): overview of the identity.
- [Original handoff](START-HERE.txt): supplied usage notes and references.
- [Provenance](PROVENANCE.md): archive identity, font sources, and licensing notes.
- [Integration validation](VALIDATION.md): repository checks and rendered review.
- [Original validation](VALIDATION.txt): checks recorded in the supplied kit.

## Artwork

| Asset | Use |
| --- | --- |
| [Primary lockup](logos/svg/kiln-primary.svg) | Gold symbol and Ink lettering on light surfaces |
| [Reversed lockup](logos/svg/kiln-reversed.svg) | Gold symbol and Paper lettering on dark surfaces |
| `logos/svg/kiln-{ink,paper}.svg` | One-color lockups |
| `logos/svg/kiln-on-{paper,ink,gold}.svg` | Lockups with intentional, opaque backgrounds |
| [Stacked lockup](logos/svg/kiln-stacked.svg) | Taller compositions |
| `logos/svg/wordmark-*.svg`, `logos/svg/symbol-*.svg` | Separate lettering and symbols |
| [App tile](logos/png/app-icon.png) | 512 px avatar or application icon |
| [Adaptive favicon](logos/svg/favicon.svg) | Browser icon with light/dark preference support |
| `logos/png/icon-{size}.png`, [favicon.ico](logos/png/favicon.ico) | 16, 32, 48, 64, 180, 192, 256, and 512 px tiles; multi-size ICO |
| [README banner](applications/readme-banner.png) | 1600 × 480 repository banner |
| [Social preview](applications/social-preview.png) | 1280 × 640 repository or social card |
| [Documentation concept](applications/docs-header.png) | 1600 × 900 design reference |

SVG masters have outlined lettering and do not need installed fonts. Matching
PNG exports live in `logos/png/`; application compositions have SVG and PNG
versions in `applications/`. Keep the vector masters when placing or editing
artwork. Transparent exports retain alpha; background-specific variants are opaque.

Preserve the proportions, spacing, lowercase lettering, and orientation. Keep
one quarter of the symbol height clear around the visible artwork. Minimum
digital sizes are 160 px wide for a lockup and 16 px high for a symbol. Do not
add effects or decorations to the mark.

## Colors and typography

[tokens/brand-tokens.json](tokens/brand-tokens.json) records the palette,
type scale, spacing, logo constraints, and approved normal-text contrast pairs.
[tokens/brand.css](tokens/brand.css) provides matching CSS variables and local
font loading; preserve its sibling `fonts/` directory when reusing it.
[tokens/kiln.gpl](tokens/kiln.gpl) is the editor palette.

Use Paper (`#F5F3ED`) and Ink (`#191C22`) for the main surfaces, with Gold
(`#E5B05C`) for emphasis. Use Ink text on Gold, Burnt Gold (`#7A4D16`) for
accent text on Paper, and Paper or `#BBC2CA` text on Ink. Steel (`#626B75`)
is secondary text on Paper. Use the supplied semantic colors on light surfaces
and pair statuses with visible labels.

Use locally hosted Space Grotesk 400–700 for headings and body text, and
JetBrains Mono 400–500 for commands, metadata, and technical data. Both original
variable TTFs and their SIL Open Font License notices are in `fonts/`. The CSS
uses `font-display: swap` with system fallbacks. Logo lettering is supplied as
artwork and does not depend on interface font rendering.

## Repository integration

The root README uses the supplied banner. The documentation index uses the
primary and reversed SVG lockups according to the reader's color preference.
Both reference this library directly. The documentation concept remains
reference artwork; user documentation lives in Markdown under `docs/`.
Brand assets are excluded from the Docker build context.

Keep product language direct and specific. Name Wolfi and its `apk` package
manager; Ubuntu-style tags are compatibility aliases. Workflows that need
`apt`, `systemd`, or the full hosted VM need adaptation. Docker clients use a
host daemon. Keep image references and versions exact, use digests for immutable
inputs, and explain how to inspect signatures, SBOMs, and provenance. Performance
and security claims need evidence.

To set GitHub's repository social preview, upload
`applications/social-preview.png` through the repository settings. Committing
the image does not update that setting.

## Updating assets

Edit assets here and retain the local font licenses and relative paths. Review
the guide on desktop and mobile, including all three logo variants, then run:

```bash
bun run brand:update
bun run brand:check
```

`checksums.json` records SHA-256 hashes of all non-Markdown brand files except
the manifest itself. `bun run check:docs` runs the check through the shared local,
hook, and CI validation to detect changed, added, or missing files. Regenerate
the manifest only after reviewing intentional changes.
The hash check verifies integrity; it does not regenerate PNGs from SVGs or
prove visual equivalence. No export generator was supplied with this kit.
Git attributes preserve the upstream font licenses' original line endings and
whitespace.
