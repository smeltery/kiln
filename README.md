# kiln 🔥🧱

[![CI](https://github.com/smeltery/kiln/actions/workflows/ci.yml/badge.svg)](https://github.com/smeltery/kiln/actions/workflows/ci.yml)
[![Publish](https://github.com/smeltery/kiln/actions/workflows/publish.yml/badge.svg)](https://github.com/smeltery/kiln/actions/workflows/publish.yml)
[![Release](https://img.shields.io/github/v/release/smeltery/kiln)](https://github.com/smeltery/kiln/releases)
[![Wolfi](https://img.shields.io/badge/Linux-Wolfi-blue)](https://wolfi.dev)
[![Docker](https://img.shields.io/badge/OCI-Docker-2496ED?logo=docker&logoColor=white)](https://github.com/smeltery/kiln/pkgs/container/kiln)
[![Flox](https://img.shields.io/badge/dev-Flox-7B61FF)](docs/development.md)
[![Bun](https://img.shields.io/badge/checks-Bun-black?logo=bun)](package.json)
[![License](https://img.shields.io/badge/license-PolyForm_Shield_1.0.0-blue)](LICENSE)

A Wolfi-based, glibc-native container image for running GitHub Actions locally
with [act](https://github.com/nektos/act). Includes shell utilities, Node.js,
Python, a C/C++ toolchain, Git, and Docker clients. Published for AMD64 and ARM64
with signatures, SBOMs, and build provenance.

```bash
docker pull ghcr.io/smeltery/kiln:latest
act -P ubuntu-latest=ghcr.io/smeltery/kiln:latest
```

Ubuntu-style tags are runner aliases; the image runs Wolfi and uses `apk`.
Workflows requiring `apt`, systemd, or a full GitHub-hosted VM need adaptation.

See [docs/](docs/README.md) for [usage](docs/usage.md),
[packages](docs/packages.md), [development](docs/development.md),
[build options](docs/building.md), and [releases](docs/automation.md).

[PolyForm Shield License 1.0.0](LICENSE) · © 2026 smeltery.
