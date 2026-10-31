# Brand provenance

## Supplied kit

The project owner supplied `kiln-brand-kit.zip` on 2026-10-31 for integration
into `smeltery/kiln`, using Bellows' brand integration as the reference. The
archive contains 59 files under `kiln-brand-kit/`. Those files are preserved
byte-for-byte in this directory, with the enclosing archive folder removed.
The Markdown integration documentation is added by the repository.

Archive SHA-256:

```text
d145586639a0c7a106dc3cb275a8054c78d72441e1d8ff0111adbd2285458153
```

The supplied guide and tokens describe a proposed revision. The repository now
uses its banner and light/dark lockups; the original proposal labels and
`1.0-proposal` token version remain intact as part of the supplied material.
The documentation header is a design concept, and its command specimens are
authored examples rather than captured run output. The original `VALIDATION.txt`
records delivery checks; [VALIDATION.md](VALIDATION.md) records integration checks.

## Artwork and references

The original [handoff](START-HERE.txt) describes native vector artwork with
outlined lettering. No generated mascot is included, and no new artwork or
font conversions were produced for this integration. The supplied SVGs and
PNGs are retained as separate masters and exports; no regeneration script
was included.

The handoff records these references:

- Kiln snapshot `a4e6816c0740abd46906c016ac3297e4b857f174`: product copy and
  documented commands, as recorded by the kit. Repository documentation reflects
  the checked-in Dockerfile, scripts, and workflows.
- [Bellows brand library](https://github.com/smeltery/bellows/tree/main/assets/brand):
  typography, neutral tokens, layout, interaction patterns, and handoff structure.
  The guide includes the Bellows lockup to illustrate the family relationship.

Artwork is integrated at the project owner's request. The archive does not
include a separate artwork license or author grant; this record does not assert
one. The repository's existing [license](../../LICENSE) is unchanged.

## Fonts

Both supplied variable TTFs are copied unchanged with their SIL Open Font
License notices:

- Space Grotesk: [supplied notice](fonts/SpaceGrotesk-OFL.txt),
  [upstream reference](https://github.com/google/fonts/tree/main/ofl/spacegrotesk).
- JetBrains Mono: [supplied notice](fonts/JetBrainsMono-OFL.txt),
  [upstream reference](https://github.com/google/fonts/tree/main/ofl/jetbrainsmono).

The source URLs come from the supplied handoff. The font licenses remain
alongside the distributed files.
