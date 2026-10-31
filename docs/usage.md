# Use kiln

Install Docker with a running daemon and [act](https://nektosact.com/installation/index.html).
Pull the image before running a workflow:

```bash
docker pull ghcr.io/smeltery/kiln:latest
act -P ubuntu-latest=ghcr.io/smeltery/kiln:latest
```

## Runner mappings and tags

Add these mappings to your project's `.actrc`:

```text
-P ubuntu-latest=ghcr.io/smeltery/kiln:latest
-P ubuntu-24.04=ghcr.io/smeltery/kiln:latest
-P ubuntu-22.04=ghcr.io/smeltery/kiln:latest
```

`latest`, `act-latest`, `ubuntu-latest`, `ubuntu-24.04`, and `ubuntu-22.04`
are compatibility aliases for one Wolfi image, not separate Ubuntu distributions.
Releases add version tags; scheduled builds add date tags. Use an image digest
(`ghcr.io/smeltery/kiln@sha256:…`) when you need immutable inputs: source SHA tags
can change when packages are rebuilt from the same commit.

The repository's own `.actrc` uses `kiln:dev`; build it with `scripts/build.sh`.
On ARM hosts, native runs can use `--container-architecture linux/arm64`.
The repository smoke script defaults to AMD64 to match CI.

## Compatibility and trust

The image provides glibc, Node.js, and common build tools. It uses `apk`, not
`apt`, and does not include systemd or every GitHub-hosted runner tool.
Docker clients connect to a host daemon; the image does not run Docker itself.
Run only workflows you trust with your Docker socket and secrets.

## Troubleshooting

- **Cannot connect to Docker:** start your Docker daemon and check `docker info`.
- **Image missing:** pull the published image or run `scripts/build.sh` first.
- **Missing tool:** check [packages](packages.md); install extra Wolfi packages
  in your workflow or [extend the image](maintenance.md).
- **Registry blocked:** try the [bootstrap build](building.md). It still needs
  network access to Docker Hub and the Wolfi package repository.
- **Executable format error:** match your image architecture to act's
  `--container-architecture`, or configure Docker's emulation support.

For signature and SBOM inspection, see [maintenance](maintenance.md).
