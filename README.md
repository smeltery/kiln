# kiln 🔥🧱

[![CI](https://github.com/smeltery/kiln/actions/workflows/ci.yml/badge.svg)](https://github.com/smeltery/kiln/actions/workflows/ci.yml)
[![Publish](https://github.com/smeltery/kiln/actions/workflows/publish.yml/badge.svg)](https://github.com/smeltery/kiln/actions/workflows/publish.yml)
[![License: PolyForm Shield 1.0.0](https://img.shields.io/badge/License-PolyForm%20Shield%201.0.0-blue.svg)](https://polyformproject.org/licenses/shield/1.0.0/)

A hardened, Chainguard Wolfi-based runner image for [`nektos/act`](https://github.com/nektos/act) —
the kiln your CI bakes in. Built as a leaner, glibc-native alternative to
`catthehacker/ubuntu:act-latest`, with the same `act-medium` surface area
workflows expect from `ubuntu-latest`.

It pairs naturally with [`smeltery/bellows`](https://github.com/smeltery/bellows),
which runs your GitHub Actions workflows locally through act before you push:
**bellows feeds the fire; kiln does the hardening.**

The image is published to `ghcr.io/smeltery/kiln` by the publish workflow.
Published tags: `latest`, `act-latest`, `ubuntu-latest`, `ubuntu-24.04`,
`ubuntu-22.04` (drop-in aliases for catthehacker's tag scheme — all the same
digest today), plus immutable `sha-<sha>` and date-stamped tags.

## Quick start

```bash
docker pull ghcr.io/smeltery/kiln:latest

act -P ubuntu-latest=ghcr.io/smeltery/kiln:latest
```

Or use the repo's `.actrc`, which already pins `ubuntu-latest`,
`ubuntu-24.04`, and `ubuntu-22.04` to a local `kiln:dev` tag.

## Documentation

- [What's in the image](docs/packages.md) — the full package surface
- [Building and testing locally](docs/building.md) — `scripts/build.sh`, env knobs, build modes
- [Architecture](docs/architecture.md) — direct vs. bootstrap mode, the Wolfi bootstrap rationale
- [Maintenance](docs/maintenance.md) — bumping versions, adding/removing packages, verifying a published image
- [Automation surface](docs/automation.md) — the CI/publish workflows and what they do

## License

[PolyForm Shield License 1.0.0](LICENSE). © 2026 smeltery.
